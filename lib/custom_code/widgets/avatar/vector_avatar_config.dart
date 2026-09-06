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
  /// 🌟 90 COMPLETELY UNIQUE ANIMAL SPECIES (1 UNIQUE ANIMAL FOR EVERY SINGLE DAY FROM 1 TO 90)
  /// Designed for Flame/Vector rendering with tailored biomes, accessories, and rarity tiers.
  static const List<({
    String species,
    String furColor,
    String eyeColor,
    String outfitColor,
    String outfitAccent,
    String accessory,
    String auraStyle,
    String rarityTier,
  })> _k90DayAnimals = [
    // 🐱 1–10: Urban Cyber Predators (Genesis Tier)
    (species: 'cyber_cat', furColor: '#F59E0B', eyeColor: '#10B981', outfitColor: '#1E293B', outfitAccent: '#FFFC00', accessory: 'none', auraStyle: 'neon_yellow', rarityTier: 'Neon Cyber Cat'),
    (species: 'cyber_fox', furColor: '#F97316', eyeColor: '#FFD700', outfitColor: '#7F1D1D', outfitAccent: '#F97316', accessory: 'none', auraStyle: 'sunset_orange', rarityTier: 'Mystic Kitsune Fox'),
    (species: 'shadow_wolf', furColor: '#334155', eyeColor: '#00F0FF', outfitColor: '#0F172A', outfitAccent: '#38BDF8', accessory: 'headphones', auraStyle: 'electric_blue', rarityTier: 'Midnight Shadow Wolf'),
    (species: 'royal_tiger', furColor: '#FB923C', eyeColor: '#FACC15', outfitColor: '#1E1B4B', outfitAccent: '#FFD700', accessory: 'none', auraStyle: 'golden_sparks', rarityTier: 'Royal Bengal Tiger'),
    (species: 'golden_lion', furColor: '#F59E0B', eyeColor: '#38BDF8', outfitColor: '#451A03', outfitAccent: '#FFD700', accessory: 'gold_chain', auraStyle: 'golden_sparks', rarityTier: '24K Golden Lion'),
    (species: 'mighty_elephant', furColor: '#64748B', eyeColor: '#10B981', outfitColor: '#064E3B', outfitAccent: '#34D399', accessory: 'none', auraStyle: 'neon_green', rarityTier: 'Colossal Tusker'),
    (species: 'ninja_panda', furColor: '#F8FAFC', eyeColor: '#38BDF8', outfitColor: '#1E1E24', outfitAccent: '#22C55E', accessory: 'samurai_headband', auraStyle: 'neon_green', rarityTier: 'Shaolin Ninja Panda'),
    (species: 'noble_bear', furColor: '#78350F', eyeColor: '#FDE047', outfitColor: '#1C1917', outfitAccent: '#F59E0B', accessory: 'cap', auraStyle: 'sunset_orange', rarityTier: 'Armored Kodiak Bear'),
    (species: 'bored_ape', furColor: '#8D5B4C', eyeColor: '#FFD700', outfitColor: '#0F172A', outfitAccent: '#FF007A', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Cyber Primate Ape'),
    (species: 'majestic_eagle', furColor: '#CBD5E1', eyeColor: '#F59E0B', outfitColor: '#1E3A8A', outfitAccent: '#FFD700', accessory: 'cool_sunglasses', auraStyle: 'golden_sparks', rarityTier: 'Imperial Storm Eagle'),

    // 🐺 11–20: Wild Hunters & Agile Spirits
    (species: 'shadow_leopard', furColor: '#F59E0B', eyeColor: '#10B981', outfitColor: '#18181B', outfitAccent: '#F59E0B', accessory: 'gold_chain', auraStyle: 'neon_green', rarityTier: 'Shadow Leopard'),
    (species: 'cosmic_unicorn', furColor: '#FAE8FF', eyeColor: '#00F0FF', outfitColor: '#4C1D95', outfitAccent: '#38BDF8', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Starlight Unicorn'),
    (species: 'solar_phoenix', furColor: '#EF4444', eyeColor: '#FFD700', outfitColor: '#7F1D1D', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Solar Crimson Phoenix'),
    (species: 'armored_rhino', furColor: '#64748B', eyeColor: '#DC2626', outfitColor: '#1E293B', outfitAccent: '#EF4444', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Titan Battle Rhino'),
    (species: 'thunder_bison', furColor: '#78350F', eyeColor: '#38BDF8', outfitColor: '#18181B', outfitAccent: '#FACC15', accessory: 'gold_chain', auraStyle: 'golden_sparks', rarityTier: 'Thunder Bison'),
    (species: 'mystic_croc', furColor: '#065F46', eyeColor: '#FACC15', outfitColor: '#0F172A', outfitAccent: '#10B981', accessory: 'pirate_eyepatch', auraStyle: 'neon_green', rarityTier: 'Prehistoric Croc'),
    (species: 'abyssal_shark', furColor: '#0284C7', eyeColor: '#00F0FF', outfitColor: '#0C4A6E', outfitAccent: '#38BDF8', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Abyssal Megalodon'),
    (species: 'wisdom_owl', furColor: '#92400E', eyeColor: '#FFD700', outfitColor: '#3B0764', outfitAccent: '#A855F7', accessory: 'round_glasses', auraStyle: 'cyber_purple', rarityTier: 'Astral Wisdom Owl'),
    (species: 'astral_stag', furColor: '#B45309', eyeColor: '#10B981', outfitColor: '#134E4A', outfitAccent: '#2DD4BF', accessory: 'crown', auraStyle: 'cherry_blossom', rarityTier: 'Celestial Forest Stag'),
    (species: 'silverback_titan', furColor: '#1E293B', eyeColor: '#EA580C', outfitColor: '#09090B', outfitAccent: '#F97316', accessory: 'gold_chain', auraStyle: 'sunset_orange', rarityTier: 'Silverback Titan'),

    // 🎯 21–30: Habit Anchors & Rare Sovereigns
    (species: 'imperial_cobra', furColor: '#059669', eyeColor: '#DC2626', outfitColor: '#0F172A', outfitAccent: '#F59E0B', accessory: 'crown', auraStyle: 'neon_green', rarityTier: 'Day 21 Habit Anchor Cobra'),
    (species: 'pegasus_stallion', furColor: '#E2E8F0', eyeColor: '#0284C7', outfitColor: '#1E3A8A', outfitAccent: '#60A5FA', accessory: 'samurai_headband', auraStyle: 'electric_blue', rarityTier: 'Winged Pegasus'),
    (species: 'royal_peacock', furColor: '#0284C7', eyeColor: '#8B5CF6', outfitColor: '#312E81', outfitAccent: '#38BDF8', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Prismatic Peacock'),
    (species: 'combat_kangaroo', furColor: '#D97706', eyeColor: '#78350F', outfitColor: '#18181B', outfitAccent: '#EF4444', accessory: 'samurai_headband', auraStyle: 'sunset_orange', rarityTier: 'Outback Boxer'),
    (species: 'nightfang_bat', furColor: '#1E1E24', eyeColor: '#EF4444', outfitColor: '#0F172A', outfitAccent: '#DC2626', accessory: 'ninja_mask', auraStyle: 'cyber_purple', rarityTier: 'Nightfang Vampire Bat'),
    (species: 'zen_sloth', furColor: '#64748B', eyeColor: '#854D0E', outfitColor: '#27272A', outfitAccent: '#10B981', accessory: 'headphones', auraStyle: 'cherry_blossom', rarityTier: 'Zen Forest Sloth'),
    (species: 'celestial_hound', furColor: '#F59E0B', eyeColor: '#38BDF8', outfitColor: '#0F172A', outfitAccent: '#F59E0B', accessory: 'cool_sunglasses', auraStyle: 'golden_sparks', rarityTier: 'Celestial Anubis Hound'),
    (species: 'astral_rabbit', furColor: '#FFFFFF', eyeColor: '#EC4899', outfitColor: '#312E81', outfitAccent: '#F472B6', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Astral Moon Rabbit'),
    (species: 'abyssal_kraken', furColor: '#831843', eyeColor: '#FACC15', outfitColor: '#0F172A', outfitAccent: '#F43F5E', accessory: 'pirate_eyepatch', auraStyle: 'cyber_purple', rarityTier: 'Abyssal Deep Kraken'),
    (species: 'cosmic_dragon', furColor: '#7C3AED', eyeColor: '#FFD700', outfitColor: '#050B14', outfitAccent: '#F97316', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Day 30 Celestial Dragon'),

    // 🐆 31–40: Swift Nomads & Arctic Wanderers
    (species: 'golden_cheetah', furColor: '#F59E0B', eyeColor: '#065F46', outfitColor: '#18181B', outfitAccent: '#FBBF24', accessory: 'cool_sunglasses', auraStyle: 'neon_yellow', rarityTier: 'Hyper-Speed Cheetah'),
    (species: 'polar_bear', furColor: '#E0F2FE', eyeColor: '#0284C7', outfitColor: '#0F172A', outfitAccent: '#38BDF8', accessory: 'beanie', auraStyle: 'electric_blue', rarityTier: 'Arctic Polar Bear'),
    (species: 'wild_boar', furColor: '#57534E', eyeColor: '#DC2626', outfitColor: '#292524', outfitAccent: '#EA580C', accessory: 'gold_chain', auraStyle: 'sunset_orange', rarityTier: 'Razorback Boar'),
    (species: 'electric_ray', furColor: '#0284C7', eyeColor: '#00F0FF', outfitColor: '#0C4A6E', outfitAccent: '#00F0FF', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Volt Manta Ray'),
    (species: 'cyber_chameleon', furColor: '#10B981', eyeColor: '#EC4899', outfitColor: '#064E3B', outfitAccent: '#A7F3D0', accessory: 'cool_sunglasses', auraStyle: 'neon_green', rarityTier: 'Prismatic Chameleon'),
    (species: 'armored_armadillo', furColor: '#78716C', eyeColor: '#F59E0B', outfitColor: '#1C1917', outfitAccent: '#EAB308', accessory: 'cap', auraStyle: 'minimal_dark', rarityTier: 'Steel Armadillo'),
    (species: 'red_panda', furColor: '#EA580C', eyeColor: '#78350F', outfitColor: '#451A03', outfitAccent: '#FDBA74', accessory: 'samurai_headband', auraStyle: 'cherry_blossom', rarityTier: 'Mystic Red Panda'),
    (species: 'peregrine_falcon', furColor: '#475569', eyeColor: '#FACC15', outfitColor: '#1E293B', outfitAccent: '#FDE047', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Supersonic Falcon'),
    (species: 'iron_wolverine', furColor: '#451A03', eyeColor: '#38BDF8', outfitColor: '#18181B', outfitAccent: '#F59E0B', accessory: 'gold_chain', auraStyle: 'sunset_orange', rarityTier: 'Iron Wolverine'),
    (species: 'tundra_lynx', furColor: '#CBD5E1', eyeColor: '#00F0FF', outfitColor: '#1E293B', outfitAccent: '#93C5FD', accessory: 'headphones', auraStyle: 'electric_blue', rarityTier: 'Tundra Lynx'),

    // 🌊 41–50: Deep Ocean & Savanna Titans
    (species: 'colossal_walrus', furColor: '#78716C', eyeColor: '#38BDF8', outfitColor: '#1C1917', outfitAccent: '#CBD5E1', accessory: 'pirate_eyepatch', auraStyle: 'minimal_dark', rarityTier: 'Colossal Walrus'),
    (species: 'apex_orca', furColor: '#0F172A', eyeColor: '#38BDF8', outfitColor: '#0284C7', outfitAccent: '#FFFFFF', accessory: 'cool_sunglasses', auraStyle: 'electric_blue', rarityTier: 'Apex Orca Titan'),
    (species: 'honey_badger', furColor: '#1E293B', eyeColor: '#EF4444', outfitColor: '#0F172A', outfitAccent: '#FFFFFF', accessory: 'samurai_headband', auraStyle: 'sunset_orange', rarityTier: 'Fearless Honey Badger'),
    (species: 'spotted_hyena', furColor: '#B45309', eyeColor: '#F59E0B', outfitColor: '#292524', outfitAccent: '#FDE047', accessory: 'gold_chain', auraStyle: 'sunset_orange', rarityTier: 'Savanna Hyena'),
    (species: 'armored_hippo', furColor: '#64748B', eyeColor: '#EC4899', outfitColor: '#1E293B', outfitAccent: '#F43F5E', accessory: 'beanie', auraStyle: 'neon_green', rarityTier: 'River Hippo Titan'),
    (species: 'savanna_giraffe', furColor: '#D97706', eyeColor: '#78350F', outfitColor: '#451A03', outfitAccent: '#FDE047', accessory: 'round_glasses', auraStyle: 'neon_yellow', rarityTier: 'Savanna Giraffe'),
    (species: 'tree_viper', furColor: '#059669', eyeColor: '#EF4444', outfitColor: '#064E3B', outfitAccent: '#34D399', accessory: 'ninja_mask', auraStyle: 'neon_green', rarityTier: 'Emerald Tree Viper'),
    (species: 'horned_ram', furColor: '#78350F', eyeColor: '#FACC15', outfitColor: '#1C1917', outfitAccent: '#F59E0B', accessory: 'samurai_headband', auraStyle: 'golden_sparks', rarityTier: 'Bighorn Ram'),
    (species: 'emperor_penguin', furColor: '#1E293B', eyeColor: '#F59E0B', outfitColor: '#0F172A', outfitAccent: '#FDE047', accessory: 'crown', auraStyle: 'electric_blue', rarityTier: 'Emperor Penguin'),
    (species: 'golden_jaguar', furColor: '#F59E0B', eyeColor: '#10B981', outfitColor: '#1C1917', outfitAccent: '#FFD700', accessory: 'gold_chain', auraStyle: 'golden_sparks', rarityTier: 'Golden Jaguar'),

    // 🌴 51–60: Jungle Lords & Prehistoric Behemoths
    (species: 'sea_otter', furColor: '#92400E', eyeColor: '#38BDF8', outfitColor: '#1E3A8A', outfitAccent: '#67E8F9', accessory: 'headphones', auraStyle: 'cherry_blossom', rarityTier: 'River Sea Otter'),
    (species: 'giant_anteater', furColor: '#475569', eyeColor: '#F59E0B', outfitColor: '#1E293B', outfitAccent: '#CBD5E1', accessory: 'cap', auraStyle: 'minimal_dark', rarityTier: 'Giant Anteater'),
    (species: 'woolly_mammoth', furColor: '#78350F', eyeColor: '#38BDF8', outfitColor: '#1C1917', outfitAccent: '#FACC15', accessory: 'gold_chain', auraStyle: 'sunset_orange', rarityTier: 'Woolly Mammoth'),
    (species: 'swordfish', furColor: '#0284C7', eyeColor: '#00F0FF', outfitColor: '#0C4A6E', outfitAccent: '#38BDF8', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Ocean Swordfish'),
    (species: 'komodo_titan', furColor: '#3F3F46', eyeColor: '#EAB308', outfitColor: '#18181B', outfitAccent: '#84CC16', accessory: 'samurai_headband', auraStyle: 'neon_green', rarityTier: 'Komodo Titan'),
    (species: 'rainforest_toucan', furColor: '#0F172A', eyeColor: '#38BDF8', outfitColor: '#1E293B', outfitAccent: '#F59E0B', accessory: 'cool_sunglasses', auraStyle: 'neon_yellow', rarityTier: 'Rainforest Toucan'),
    (species: 'crimson_flamingo', furColor: '#F43F5E', eyeColor: '#FFD700', outfitColor: '#881337', outfitAccent: '#FDA4AF', accessory: 'crown', auraStyle: 'cherry_blossom', rarityTier: 'Crimson Flamingo'),
    (species: 'cyber_meerkat', furColor: '#D97706', eyeColor: '#00F0FF', outfitColor: '#18181B', outfitAccent: '#38BDF8', accessory: 'headphones', auraStyle: 'neon_yellow', rarityTier: 'Sentinel Meerkat'),
    (species: 'shadow_manticore', furColor: '#7F1D1D', eyeColor: '#EF4444', outfitColor: '#450A0A', outfitAccent: '#DC2626', accessory: 'ninja_mask', auraStyle: 'cyber_purple', rarityTier: 'Shadow Manticore'),
    (species: 'golden_griffin', furColor: '#F59E0B', eyeColor: '#FFD700', outfitColor: '#451A03', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Day 60 Golden Griffin'),

    // 🔥 61–70: Mythic Beasts & Elemental Guardians
    (species: 'volcanic_salamander', furColor: '#DC2626', eyeColor: '#FACC15', outfitColor: '#1C1917', outfitAccent: '#F97316', accessory: 'cyber_visor', auraStyle: 'sunset_orange', rarityTier: 'Volcanic Salamander'),
    (species: 'oceanic_narwhal', furColor: '#0284C7', eyeColor: '#00F0FF', outfitColor: '#075985', outfitAccent: '#E0F2FE', accessory: 'crown', auraStyle: 'electric_blue', rarityTier: 'Oceanic Narwhal'),
    (species: 'snow_leopard', furColor: '#E2E8F0', eyeColor: '#00F0FF', outfitColor: '#0F172A', outfitAccent: '#94A3B8', accessory: 'cool_sunglasses', auraStyle: 'electric_blue', rarityTier: 'Ghost Snow Leopard'),
    (species: 'fennec_fox', furColor: '#FDE047', eyeColor: '#78350F', outfitColor: '#451A03', outfitAccent: '#FBBF24', accessory: 'headphones', auraStyle: 'neon_yellow', rarityTier: 'Desert Fennec Fox'),
    (species: 'cyber_mantis', furColor: '#10B981', eyeColor: '#00F0FF', outfitColor: '#064E3B', outfitAccent: '#6EE7B7', accessory: 'ninja_mask', auraStyle: 'neon_green', rarityTier: 'Cyber Mantis'),
    (species: 'ghost_jellyfish', furColor: '#A855F7', eyeColor: '#00F0FF', outfitColor: '#3B0764', outfitAccent: '#C084FC', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Ghost Jellyfish'),
    (species: 'armored_pangolin', furColor: '#D97706', eyeColor: '#10B981', outfitColor: '#1C1917', outfitAccent: '#FDE047', accessory: 'gold_chain', auraStyle: 'golden_sparks', rarityTier: 'Armored Pangolin'),
    (species: 'black_panther', furColor: '#18181B', eyeColor: '#A855F7', outfitColor: '#09090B', outfitAccent: '#C084FC', accessory: 'ninja_mask', auraStyle: 'cyber_purple', rarityTier: 'Obsidian Black Panther'),
    (species: 'sky_thunderbird', furColor: '#1E3A8A', eyeColor: '#FACC15', outfitColor: '#172554', outfitAccent: '#FDE047', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Sky Thunderbird'),
    (species: 'cerberus_hound', furColor: '#450A0A', eyeColor: '#EF4444', outfitColor: '#18181B', outfitAccent: '#DC2626', accessory: 'gold_chain', auraStyle: 'sunset_orange', rarityTier: 'Nether Cerberus'),

    // 👑 71–80: Enchanted & Prismatic Monarchs
    (species: 'reef_seahorse', furColor: '#0284C7', eyeColor: '#FACC15', outfitColor: '#0C4A6E', outfitAccent: '#38BDF8', accessory: 'crown', auraStyle: 'electric_blue', rarityTier: 'Imperial Seahorse'),
    (species: 'gorilla_king', furColor: '#1E293B', eyeColor: '#FFD700', outfitColor: '#0F172A', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Gorilla Sovereign King'),
    (species: 'cyber_chimera', furColor: '#7C3AED', eyeColor: '#F59E0B', outfitColor: '#1E1B4B', outfitAccent: '#EC4899', accessory: 'samurai_headband', auraStyle: 'cyber_purple', rarityTier: 'Cyber Chimera'),
    (species: 'tree_frog', furColor: '#2563EB', eyeColor: '#F59E0B', outfitColor: '#1E3A8A', outfitAccent: '#60A5FA', accessory: 'cool_sunglasses', auraStyle: 'electric_blue', rarityTier: 'Poison Dart Frog'),
    (species: 'monarch_butterfly', furColor: '#EA580C', eyeColor: '#38BDF8', outfitColor: '#431407', outfitAccent: '#FDE047', accessory: 'crown', auraStyle: 'cherry_blossom', rarityTier: 'Monarch Queen'),
    (species: 'musk_ox', furColor: '#44403C', eyeColor: '#38BDF8', outfitColor: '#1C1917', outfitAccent: '#CBD5E1', accessory: 'beanie', auraStyle: 'minimal_dark', rarityTier: 'Arctic Musk Ox'),
    (species: 'chameleon_king', furColor: '#8B5CF6', eyeColor: '#00F0FF', outfitColor: '#3B0764', outfitAccent: '#F43F5E', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Prism Chameleon King'),
    (species: 'horned_lizard', furColor: '#B45309', eyeColor: '#DC2626', outfitColor: '#292524', outfitAccent: '#F59E0B', accessory: 'ninja_mask', auraStyle: 'sunset_orange', rarityTier: 'Desert Horned Lizard'),
    (species: 'angler_leviathan', furColor: '#0F172A', eyeColor: '#00F0FF', outfitColor: '#0284C7', outfitAccent: '#FACC15', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Abyssal Angler Leviathan'),
    (species: 'mecha_wolf', furColor: '#334155', eyeColor: '#00F0FF', outfitColor: '#0F172A', outfitAccent: '#38BDF8', accessory: 'cyber_visor', auraStyle: 'electric_blue', rarityTier: 'Mecha Cyber Wolf Alpha'),

    // 🌌 81–90: Celestial Sovereigns & Cosmic Grandmasters
    (species: 'kitsune_emperor', furColor: '#FF6D00', eyeColor: '#FFD700', outfitColor: '#7F1D1D', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Celestial Kitsune Emperor'),
    (species: 'solar_lion', furColor: '#F59E0B', eyeColor: '#38BDF8', outfitColor: '#451A03', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Solar Sovereign Lion'),
    (species: 'sea_dragon', furColor: '#0284C7', eyeColor: '#00F0FF', outfitColor: '#082F49', outfitAccent: '#38BDF8', accessory: 'crown', auraStyle: 'electric_blue', rarityTier: 'Mythic Sea Dragon'),
    (species: 'thunder_roc', furColor: '#1E3A8A', eyeColor: '#FFD700', outfitColor: '#172554', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Tempest Roc Apex'),
    (species: 'obsidian_basilisk', furColor: '#18181B', eyeColor: '#10B981', outfitColor: '#09090B', outfitAccent: '#10B981', accessory: 'crown', auraStyle: 'neon_green', rarityTier: 'Obsidian Basilisk'),
    (species: 'celestial_phoenix', furColor: '#EF4444', eyeColor: '#FFD700', outfitColor: '#7F1D1D', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: '24K Celestial Phoenix'),
    (species: 'cosmic_hydra', furColor: '#6B21A8', eyeColor: '#00F0FF', outfitColor: '#3B0764', outfitAccent: '#C084FC', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Astral Void Hydra'),
    (species: 'chrono_dragon', furColor: '#D97706', eyeColor: '#00F0FF', outfitColor: '#1E1B4B', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Chrono Time Dragon'),
    (species: 'astral_titan', furColor: '#4338CA', eyeColor: '#FFD700', outfitColor: '#0F172A', outfitAccent: '#818CF8', accessory: 'crown', auraStyle: 'cyber_purple', rarityTier: 'Eternal Astral Titan'),
    (species: 'cosmic_dragon_sovereign', furColor: '#7C3AED', eyeColor: '#00F0FF', outfitColor: '#050B14', outfitAccent: '#FFD700', accessory: 'crown', auraStyle: 'golden_sparks', rarityTier: 'Supreme Cosmic Dragon God (Day 90 Master)'),
  ];

  static VectorAvatarConfig getEvolutionAvatarForStage(int stage, {String? talismanId}) {
    final day = stage.clamp(1, 90);
    final animal = _k90DayAnimals[day - 1];

    final species = animal.species;
    final furColor = animal.furColor;
    final eyeColor = animal.eyeColor;
    final outfitColor = animal.outfitColor;
    final outfitAccent = animal.outfitAccent;
    final accessory = animal.accessory;
    final auraStyle = animal.auraStyle;
    final rarityTier = animal.rarityTier;
    const hairStyle = 'short_crop';

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

  /// 🎨 90 DISTINCT BANNER DECORATIONS (1 PER ANIMAL AVATAR)
  /// Generates a uniquely styled luxury banner gradient, border glow, and shadow for each of the 90 animals!
  static BoxDecoration getEvolutionBannerDecoration(int stage) {
    final day = stage.clamp(1, 90);
    final animal = _k90DayAnimals[day - 1];
    final primary = parseHex(animal.outfitAccent, fallback: const Color(0xFF00F0FF));
    final fur = parseHex(animal.furColor, fallback: const Color(0xFFF59E0B));
    final darkBg = parseHex(animal.outfitColor, fallback: const Color(0xFF0F172A));

    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primary.withValues(alpha: day == 90 ? 0.95 : 0.65),
        width: day == 90 ? 2.2 : 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: day == 90 ? 0.45 : 0.22),
          blurRadius: day == 90 ? 24 : 16,
          spreadRadius: day == 90 ? 2 : 0,
        ),
      ],
      gradient: LinearGradient(
        colors: [
          darkBg,
          Color.lerp(darkBg, fur, 0.30) ?? darkBg,
          Color.lerp(darkBg, primary, 0.48) ?? primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
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
