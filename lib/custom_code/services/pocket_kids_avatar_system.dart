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

    // Curated 100 legendary cartoon & anime animal heroes across all 100 days
    // Each day has an iconic, beloved, child-friendly character identity!
    final cartoonSpeciesList = [
      // 1–10: Classic Toons & Tiny Explorers
      'cyber_cat',          // Day 1: Tom & Jerry Cat
      'astral_rabbit',      // Day 2: Bugs Bunny / Roger
      'ninja_panda',        // Day 3: Po Dragon Warrior Panda
      'celestial_hound',    // Day 4: Scooby Doo / Courage Hound
      'bored_ape',          // Day 5: Curious George Chimp
      'royal_tiger',        // Day 6: Tigger Bouncy Tiger
      'noble_bear',         // Day 7: Winnie Honey Bear
      'cyber_fox',          // Day 8: Nick Wilde Zootopia Fox
      'majestic_eagle',     // Day 9: Mighty Eagle Angry Birds
      'sea_otter',          // Day 10: Shellington Sea Otter

      // 11–20: Jungle & Safari Buddies
      'savanna_giraffe',    // Day 11: Melman Giraffe
      'hippo_behemoth',     // Day 12: Gloria Hippo
      'golden_lion',        // Day 13: Simba Lion King Cub
      'woolly_mammoth',     // Day 14: Manny Mammoth
      'zen_sloth',          // Day 15: Flash Sloth Zootopia
      'rainforest_toucan',  // Day 16: Rafael Toucan
      'red_panda',          // Day 17: Master Shifu Red Panda
      'emperor_penguin',    // Day 18: Skipper Madagascar Penguin
      'polar_bear',         // Day 19: Ice Bear We Bare Bears
      'grizzly_titan',      // Day 20: Grizzly We Bare Bears

      // 21–30: Woodland & River Friends
      'woodland_badger',    // Day 21: Barnaby Badger
      'meadow_chipmunk',    // Day 22: Alvin Chipmunk
      'fennec_fox',         // Day 23: Fennec Desert Fox
      'tundra_lynx',        // Day 24: Lynx Cat Stalker
      'wisdom_owl',         // Day 25: Archimedes Wise Owl
      'combat_kangaroo',    // Day 26: Boomerang Kangaroo
      'apex_orca',          // Day 27: Willy Orca
      'oceanic_narwhal',    // Day 28: Buddy Narwhal
      'reef_seahorse',      // Day 29: Coral Seahorse
      'cyber_meerkat',      // Day 30: Timon Meerkat

      // 31–40: Cartoon Heroes & Adventurers
      'kitsune_emperor',    // Day 31: Naruto Nine Tails Fox
      'shadow_wolf',        // Day 32: Balto Arctic Wolf
      'cerberus_hound',     // Day 33: Bolt Superdog
      'thunder_bison',      // Day 34: Appa Sky Bison
      'astral_stag',        // Day 35: Bambi Prince Stag
      'golden_cheetah',     // Day 36: Cheetara Speed Cheetah
      'snow_leopard',       // Day 37: Tai Lung Snow Leopard
      'royal_peacock',      // Day 38: Lord Shen Peacock
      'peregrine_falcon',   // Day 39: Falco Ace Falcon
      'sky_thunderbird',    // Day 40: Zapdos Thunderbird

      // 41–50: Mythic Beasts & Pokémon Champions
      'cosmic_unicorn',     // Day 41: Rapidash / My Little Pony
      'pegasus_stallion',   // Day 42: Hercules Pegasus
      'solar_phoenix',      // Day 43: Moltres Phoenix
      'celestial_phoenix',  // Day 44: Ho-Oh Rainbow Phoenix
      'thunder_roc',        // Day 45: Roc Giant Golden Eagle
      'sea_dragon',         // Day 46: Dragonair Sea Dragon
      'chrono_dragon',      // Day 47: Toothless Night Fury
      'cosmic_dragon',      // Day 48: Charizard Flame Dragon
      'dragon_sovereign',   // Day 49: Shenron Wish Dragon
      'golden_griffin',     // Day 50: Buckbeak Sky Griffin

      // 51–60: Prehistoric & Wild Titans
      'silverback_titan',   // Day 51: Donkey Kong Gorilla
      'gorilla_king',       // Day 52: King Kong Jungle Monarch
      'rhino_juggernaut',   // Day 53: Rocksteady Rhino
      'armored_rhino',      // Day 54: Rhyhorn Armored Rhino
      'iron_bull',          // Day 55: Ferdinand Gentle Bull
      'golden_ram',         // Day 56: Aries Golden Fleece Ram
      'bison_colossus',     // Day 57: Chief Bogo Cape Buffalo
      'moose_emperor',      // Day 58: Bullwinkle Moose
      'colossal_walrus',    // Day 59: Wally Walrus
      'abyssal_kraken',     // Day 60: Kraken Deep Explorer

      // 61–70: Swift Hunters & Kung Fu Masters
      'caracal_monarch',    // Day 61: Caracal Desert Lynx
      'ocelot_prince',      // Day 62: Puss in Boots Ocelot
      'black_panther',      // Day 63: Bagheera Jungle Panther
      'shadow_leopard',     // Day 64: Shadow Panther Phantom
      'golden_jaguar',      // Day 65: Jaguar Sun Warrior
      'sabertooth_tiger',   // Day 66: Diego Ice Age Sabertooth
      'timber_wolf',        // Day 67: Alpha Wolf Leader
      'arctic_fox',         // Day 68: Swiper Sly Fox
      'maned_wolf',         // Day 69: Leggy Maned Wolf
      'dhole_hunter',       // Day 70: Red Dhole Hunter

      // 71–80: High Sky Raptors & Avians
      'harpy_eagle',        // Day 71: Harpy Giant Sky Eagle
      'raven_sovereign',    // Day 72: Raven Crow Mystic
      'barn_owl',           // Day 73: Soren Guardian Owl
      'osprey_diver',       // Day 74: Osprey River Ace
      'kingfisher_dart',    // Day 75: Kingfisher Rainbow Diver
      'crimson_flamingo',   // Day 76: Flamingo Ballet Queen
      'albatross_glider',   // Day 77: Wilbur Albatross
      'electric_ray',       // Day 78: Mantine Electric Ray
      'manta_sovereign',    // Day 79: Ray Manta Sovereign
      'hammerhead_titan',   // Day 80: Anchor Hammerhead Shark

      // 81–90: Cosmic & Celestial Legends
      'abyssal_shark',      // Day 81: Bruce Great White Shark
      'swordfish',          // Day 82: Marlin Speed Swordfish
      'axolotl_sprite',     // Day 83: Wooper Cute Axolotl
      'chameleon_king',     // Day 84: Pascal Tangled Chameleon
      'thorny_devil',       // Day 85: Rango Desert Lizard
      'komodo_titan',       // Day 86: Komodo Dragon Warrior
      'volcanic_salamander',// Day 87: Charmander Fire Salamander
      'cyber_chimera',      // Day 88: Chimera Mythic Beast
      'solar_lion',         // Day 89: Mufasa Great Sun Lion
      'golden_lion',        // Day 90: Aslan Narnia Golden Lion

      // 91–99: Imperial Champions & Royal Paladins
      'cyber_cat',          // Day 91: Doraemon / Meowth Champion
      'astral_rabbit',      // Day 92: Peter Rabbit Royal Paladin
      'ninja_panda',        // Day 93: Grand Panda Master
      'royal_tiger',        // Day 94: Shere Khan / Royal Tiger
      'cosmic_dragon',      // Day 95: Rayquaza Sky Ruler Dragon
      'pegasus_stallion',   // Day 96: Starlight Pegasus Paladin
      'solar_phoenix',      // Day 97: Immortal Sun Phoenix
      'golden_griffin',     // Day 98: Crowned Sky Griffin Sovereign
      'silverback_titan',   // Day 99: Primate Titan Prime Guardian
    ];

    final species = (day <= cartoonSpeciesList.length)
        ? cartoonSpeciesList[day - 1]
        : 'golden_lion';

    // 100 Child-friendly bright palettes (Yellow, Sky Blue, Lime, Ruby, Coral, Tangerine, Pink, Violet)
    final furColors = [
      '#F59E0B', '#FB923C', '#F8FAFC', '#38BDF8', '#EC4899',
      '#10B981', '#A855F7', '#FBBF24', '#34D399', '#60A5FA',
      '#E879F9', '#F43F5E', '#2DD4BF', '#FDE047', '#CBD5E1',
      '#FF7043', '#4DD0E1', '#81C784', '#FFD54F', '#BA68C8',
    ];
    final furColor = furColors[(day * 7) % furColors.length];

    // Playful, expressive cartoon eyes
    final eyeColors = [
      '#38BDF8', '#10B981', '#F59E0B', '#EC4899', '#A855F7', '#00F0FF', '#FFD700',
    ];
    final eyeColor = eyeColors[day % eyeColors.length];

    // Child-friendly cartoon hero costumes
    final outfits = [
      'hoodie', 'varsity_jacket', 'sports_jersey', 'artist_apron',
      'astronaut_suit', 'superman_suit', 'denim_jacket'
    ];
    final outfitStyle = outfits[(day ~/ 4) % outfits.length];

    final outfitColors = [
      '#1E293B', '#1E1B4B', '#064E3B', '#451A03', '#312E81',
      '#831843', '#0F172A', '#134E4A', '#2E1065', '#172554',
      '#7C2D12', '#701A75', '#14532D', '#1E3A8A', '#3B0764',
    ];
    final outfitColor = outfitColors[(day * 3) % outfitColors.length];

    final outfitAccents = [
      '#FFFC00', '#FFD700', '#38BDF8', '#F472B6', '#34D399', '#A78BFA', '#FB923C',
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

    // Cartoon magical auras
    final auras = [
      'neon_yellow', 'golden_sparks', 'electric_blue', 'cyber_purple',
      'cherry_blossom', 'sunset_orange', 'pixel_arcade', 'matrix_green',
    ];
    final auraStyle = auras[(day ~/ 3) % auras.length];

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
      dnaHash: '0xCARTOON-${species.toUpperCase()}-D$day',
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
