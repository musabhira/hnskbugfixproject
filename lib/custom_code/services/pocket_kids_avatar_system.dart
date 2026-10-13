import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';

/// 🎨 Dedicated 100 Vector Avatar System for Kids Mode
///
/// Pure 100% child-friendly vector avatars matching the adult avatar engine's rich
/// visual quality (Custom fur, playful eyes, cute accessories, outfits, and auras).
/// Completely separate from adult avatars, tailored for Kids Days 1–100!
class PocketKidsAvatarSystem {
  static const List<String> zodiacSigns = [
    'Capricorn ♑',
    'Aquarius ♒',
    'Pisces ♓',
    'Aries ♈',
    'Taurus ♉',
    'Gemini ♊',
    'Cancer ♋',
    'Leo ♌',
    'Virgo ♍',
    'Libra ♎',
    'Scorpio ♏',
    'Sagittarius ♐',
  ];

  static String getZodiacForDay(int day) {
    return zodiacSigns[(day - 1) % zodiacSigns.length];
  }

  static String getZodiacNameOnly(int day) {
    final full = getZodiacForDay(day);
    return full.split(' ').first;
  }

  /// 🌟 100 Unique Artistic Vector Avatar Configurations for Kids Mode
  static VectorAvatarConfig getAvatarConfigForDay(int day) {
    final clamped = day.clamp(1, 100);
    return _generateKidConfig(clamped);
  }

  static VectorAvatarConfig _generateKidConfig(int day) {
    // 🦁 Special Sovereign Lion for Day 100 and Mentor
    if (day == 100) {
      return const VectorAvatarConfig(
        artStyle: 'vector',
        species: 'golden_lion',
        gender: 'neutral',
        skinColor: '#F59E0B',
        faceShape: 'sharp',
        eyeStyle: 'sparkle',
        eyeColor: '#38BDF8',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        hairStyle: 'short_crop',
        hairColor: '#F59E0B',
        outfitStyle: 'varsity_jacket',
        outfitColor: '#451A03',
        outfitAccentColor: '#FFD700',
        accessory: 'crown',
        accessoryColor: '#FFD700',
        auraStyle: 'golden_sparks',
        mintId: '#KID-DAY100-LION',
        rarityTier: 'Supreme Summit Sovereign',
      );
    }

    // Curated child-friendly archetypes across the 100 days
    final speciesList = [
      'royal_tiger', 'ninja_panda', 'astral_rabbit', 'celestial_hound',
      'cyber_cat', 'noble_bear', 'bored_ape', 'majestic_eagle',
      'shadow_leopard', 'cosmic_unicorn', 'solar_phoenix', 'armored_rhino',
      'thunder_bison', 'wisdom_owl', 'astral_stag', 'silverback_titan',
      'pegasus_stallion', 'royal_peacock', 'combat_kangaroo', 'zen_sloth',
      'golden_cheetah', 'polar_bear', 'red_panda', 'peregrine_falcon',
      'tundra_lynx', 'apex_orca', 'savanna_giraffe', 'emperor_penguin',
      'sea_otter', 'woolly_mammoth', 'rainforest_toucan', 'cyber_meerkat',
      'snow_leopard', 'fennec_fox', 'sky_thunderbird', 'gorilla_king',
      'cyber_fox', 'kitsune_emperor', 'solar_lion', 'sea_dragon',
      'thunder_roc', 'celestial_phoenix', 'cosmic_dragon', 'golden_lion'
    ];

    final species = speciesList[(day - 1) % speciesList.length];

    // Child-friendly vibrant fur palettes
    final furColors = [
      '#F59E0B', '#FB923C', '#F8FAFC', '#38BDF8', '#EC4899',
      '#10B981', '#A855F7', '#FBBF24', '#34D399', '#60A5FA',
      '#E879F9', '#F43F5E', '#2DD4BF', '#FDE047', '#CBD5E1',
    ];
    final furColor = furColors[(day * 3) % furColors.length];

    // Playful eye colors
    final eyeColors = [
      '#38BDF8', '#10B981', '#F59E0B', '#EC4899', '#A855F7', '#00F0FF',
    ];
    final eyeColor = eyeColors[day % eyeColors.length];

    // Outfits suited for kids (hoodies, jerseys, aprons, space suits)
    final outfits = [
      'hoodie', 'varsity_jacket', 'sports_jersey', 'artist_apron',
      'astronaut_suit', 'superman_suit', 'denim_jacket'
    ];
    final outfitStyle = outfits[(day ~/ 5) % outfits.length];

    final outfitColors = [
      '#1E293B', '#1E1B4B', '#064E3B', '#451A03', '#312E81',
      '#831843', '#0F172A', '#134E4A', '#2E1065', '#172554',
    ];
    final outfitColor = outfitColors[day % outfitColors.length];

    final outfitAccents = [
      '#FFFC00', '#FFD700', '#38BDF8', '#F472B6', '#34D399', '#A78BFA',
    ];
    final outfitAccent = outfitAccents[(day * 2) % outfitAccents.length];

    // Cute accessories
    String accessory = 'none';
    if (day >= 90) {
      accessory = 'crown';
    } else if (day % 7 == 0) {
      accessory = 'crown';
    } else if (day % 5 == 0) {
      accessory = 'headphones';
    } else if (day % 4 == 0) {
      accessory = 'round_glasses';
    } else if (day % 3 == 0) {
      accessory = 'cool_sunglasses';
    } else if (day % 2 == 0) {
      accessory = 'cap';
    }

    // Auras
    final auras = [
      'neon_yellow', 'golden_sparks', 'electric_blue', 'cyber_purple',
      'cherry_blossom', 'sunset_orange', 'pixel_arcade', 'matrix_green',
    ];
    final auraStyle = auras[(day ~/ 4) % auras.length];

    String rarity = 'Junior Scout';
    if (day >= 90) {
      rarity = 'Supreme Champion 👑';
    } else if (day >= 70) {
      rarity = 'Grand Master 🌟';
    } else if (day >= 40) {
      rarity = 'Mountain Hero ⚡';
    } else if (day >= 15) {
      rarity = 'Trail Pioneer 🐾';
    }

    return VectorAvatarConfig(
      artStyle: 'vector',
      species: species,
      gender: 'neutral',
      skinColor: furColor,
      faceShape: 'round',
      eyeStyle: day >= 75 ? 'sparkle' : (day % 2 == 0 ? 'anime' : 'chill'),
      eyeColor: eyeColor,
      eyebrowStyle: 'confident',
      mouthStyle: day % 3 == 0 ? 'laugh' : 'smile',
      hairStyle: 'short_crop',
      hairColor: furColor,
      outfitStyle: outfitStyle,
      outfitColor: outfitColor,
      outfitAccentColor: outfitAccent,
      accessory: accessory,
      accessoryColor: '#FFD700',
      auraStyle: auraStyle,
      mintId: '#KID-DAY$day',
      dnaHash: '0xKID-${species.toUpperCase()}-D$day',
      rarityTier: rarity,
    );
  }

  /// Get luxury card gradient decoration matching the kid's avatar
  static BoxDecoration getKidBannerDecoration(int day) {
    final cfg = getAvatarConfigForDay(day);
    final primary = VectorAvatarConfig.parseHex(cfg.outfitAccentColor, fallback: const Color(0xFFFFD700));
    final fur = VectorAvatarConfig.parseHex(cfg.skinColor, fallback: const Color(0xFFF59E0B));
    final darkBg = VectorAvatarConfig.parseHex(cfg.outfitColor, fallback: const Color(0xFF0F172A));

    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          darkBg,
          Color.lerp(darkBg, fur, 0.35) ?? darkBg,
          Color.lerp(darkBg, primary, 0.50) ?? primary,
        ],
      ),
      border: Border.all(
        color: primary.withValues(alpha: 0.8),
        width: 1.8,
      ),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
