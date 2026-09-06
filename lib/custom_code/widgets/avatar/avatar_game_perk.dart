import 'package:flutter/material.dart';

/// ⚡ Perk Category for In-Game Involvements across the 90 Avatars
enum PerkType {
  ironDome, // Intercepts enemy raid missiles / deflects breach damage
  armyKnights, // Stations extra guard knights for fortress defense
  fdcBoost, // Awards bonus Fortress Defense Credits on calls/chats/vibes
  siegeDamage, // Deals bonus breach destruction on fortress raids
  timeFreeze, // Extends question challenge timers during raids
  vaultLoot, // Steals extra coins on raid victory & shields vault
  fortressShield, // Fortifies max fortress HP / structure integrity
}

/// 🛡️ Avatar Game Perk Model for 90 Days of English Mastery
/// Every companion provides an active, tangible fortress benefit!
class AvatarGamePerk {
  final int day;
  final String title;
  final String description;
  final String icon;
  final PerkType perkType;
  final int bonusValue;
  final Color badgeColor;

  const AvatarGamePerk({
    required this.day,
    required this.title,
    required this.description,
    required this.icon,
    required this.perkType,
    required this.bonusValue,
    required this.badgeColor,
  });

  String get perkCategoryCode {
    switch (perkType) {
      case PerkType.ironDome:
        return 'iron_dome';
      case PerkType.armyKnights:
        return 'army_knights';
      case PerkType.fdcBoost:
        return 'fdc_boost';
      case PerkType.siegeDamage:
        return 'siege_damage';
      case PerkType.timeFreeze:
        return 'time_freeze';
      case PerkType.vaultLoot:
        return 'vault_loot';
      case PerkType.fortressShield:
        return 'fortress_shield';
    }
  }

  String get shortBadgeText {
    switch (perkType) {
      case PerkType.ironDome:
        return '🛡️ Tier $bonusValue Iron Dome';
      case PerkType.armyKnights:
        return '⚔️ +$bonusValue Stationed Knights';
      case PerkType.fdcBoost:
        return '🎙️ +$bonusValue FDC Credit Boost';
      case PerkType.siegeDamage:
        return '💥 +$bonusValue Raid Breach DMG';
      case PerkType.timeFreeze:
        return '⏳ +${bonusValue}s Question Timer';
      case PerkType.vaultLoot:
        return '🪙 +$bonusValue% Vault Loot';
      case PerkType.fortressShield:
        return '🏰 +$bonusValue Fortress HP';
    }
  }

  /// Deterministically retrieve the unique perk for any of the 90 days
  static AvatarGamePerk forDay(int stage) {
    final day = stage.clamp(1, 90);
    return _k90DayPerks[day - 1];
  }

  /// All 90 unique perks mapped 1-to-1 to each day's companion animal
  static const List<AvatarGamePerk> _k90DayPerks = [
    // 🐱 1–10: Urban Cyber Predators (Genesis Tier)
    AvatarGamePerk(
      day: 1,
      title: 'Vocal FDC Surge',
      description: 'Awards +10 bonus Fortress Defense Credits (FDC) on Voice Calls & English Chats.',
      icon: '🎙️',
      perkType: PerkType.fdcBoost,
      bonusValue: 10,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 2,
      title: 'Kitsune Chrono Cunning',
      description: 'Adds +5 extra seconds to solve defense challenge questions during fortress raids.',
      icon: '🦊',
      perkType: PerkType.timeFreeze,
      bonusValue: 5,
      badgeColor: Color(0xFFF97316),
    ),
    AvatarGamePerk(
      day: 3,
      title: 'Midnight Breach Piercing',
      description: 'Inflicts +10 bonus siege destruction damage on correct raid answers.',
      icon: '⚔️',
      perkType: PerkType.siegeDamage,
      bonusValue: 10,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 4,
      title: 'Royal Bengal Garrison',
      description: 'Stations +1 extra royal knight guard at your house to intercept intruders.',
      icon: '🐅',
      perkType: PerkType.armyKnights,
      bonusValue: 1,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 5,
      title: '24K Golden Vault Guard',
      description: 'Secures +20% bonus vault coins on victory and shields your treasury.',
      icon: '🪙',
      perkType: PerkType.vaultLoot,
      bonusValue: 20,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 6,
      title: 'Colossal Rampart',
      description: 'Bolsters fortress defenses with +25 max house structure integrity.',
      icon: '🐘',
      perkType: PerkType.fortressShield,
      bonusValue: 25,
      badgeColor: Color(0xFF34D399),
    ),
    AvatarGamePerk(
      day: 7,
      title: 'Shaolin Focus Matrix',
      description: 'Zen mindfulness extends raid puzzle timers by +8 seconds.',
      icon: '⏳',
      perkType: PerkType.timeFreeze,
      bonusValue: 8,
      badgeColor: Color(0xFF22C55E),
    ),
    AvatarGamePerk(
      day: 8,
      title: 'Kodiak Iron Dome Aegis',
      description: 'Equips a Tier 1 Iron Dome interceptor to deflect incoming explosive hits!',
      icon: '🛡️',
      perkType: PerkType.ironDome,
      bonusValue: 1,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 9,
      title: 'Cyber Primate Firewall',
      description: 'Hacks enemy defenses for +15 FDC per English challenge solved.',
      icon: '💻',
      perkType: PerkType.fdcBoost,
      bonusValue: 15,
      badgeColor: Color(0xFFC084FC),
    ),
    AvatarGamePerk(
      day: 10,
      title: 'Imperial Aerial Bombardment',
      description: 'Airstrikes deal +15 devastating breach damage against enemy citadels.',
      icon: '🦅',
      perkType: PerkType.siegeDamage,
      bonusValue: 15,
      badgeColor: Color(0xFFFFD700),
    ),

    // 🐺 11–20: Wild Hunters & Agile Spirits
    AvatarGamePerk(
      day: 11,
      title: 'Shadow Prowler Blitz',
      description: 'Inflicts +12 bonus siege destruction damage on correct raid answers.',
      icon: '🐆',
      perkType: PerkType.siegeDamage,
      bonusValue: 12,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 12,
      title: 'Starlight Iron Dome',
      description: 'Summons a Tier 2 Starlight Iron Dome to deflect multiple incoming missiles!',
      icon: '✨',
      perkType: PerkType.ironDome,
      bonusValue: 2,
      badgeColor: Color(0xFFC084FC),
    ),
    AvatarGamePerk(
      day: 13,
      title: 'Solar Core Rebirth',
      description: 'Passive radiant energy grants +20 max fortress integrity and fast repair.',
      icon: '🔥',
      perkType: PerkType.fortressShield,
      bonusValue: 20,
      badgeColor: Color(0xFFEF4444),
    ),
    AvatarGamePerk(
      day: 14,
      title: 'Titan Rhino Juggernaut',
      description: 'Heavy armor breaks through enemy gates with +15 raid siege damage.',
      icon: '🦏',
      perkType: PerkType.siegeDamage,
      bonusValue: 15,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 15,
      title: 'Thunder Herd Garrison',
      description: 'Stations +1 extra heavy knight guard to defend against neighbor raids.',
      icon: '🦬',
      perkType: PerkType.armyKnights,
      bonusValue: 1,
      badgeColor: Color(0xFFFACC15),
    ),
    AvatarGamePerk(
      day: 16,
      title: 'Abyssal Snare',
      description: 'Submerged traps grant +8 seconds on question timers for steady answering.',
      icon: '🐊',
      perkType: PerkType.timeFreeze,
      bonusValue: 8,
      badgeColor: Color(0xFF10B981),
    ),
    AvatarGamePerk(
      day: 17,
      title: 'Megalodon Devastator',
      description: 'Abyssal jaws inflict +18 devastating breach damage during neighbor attacks.',
      icon: '🦈',
      perkType: PerkType.siegeDamage,
      bonusValue: 18,
      badgeColor: Color(0xFF00F0FF),
    ),
    AvatarGamePerk(
      day: 18,
      title: 'Astral Intellect Surge',
      description: 'Owl wisdom grants +15 bonus FDC on voice practice and group English discussions.',
      icon: '🦉',
      perkType: PerkType.fdcBoost,
      bonusValue: 15,
      badgeColor: Color(0xFFA855F7),
    ),
    AvatarGamePerk(
      day: 19,
      title: 'Sylvan Aegis Shield',
      description: 'Forest enchantment reinforces house ramparts with +20 structural HP.',
      icon: '🦌',
      perkType: PerkType.fortressShield,
      bonusValue: 20,
      badgeColor: Color(0xFF2DD4BF),
    ),
    AvatarGamePerk(
      day: 20,
      title: 'Silverback Titan Garrison',
      description: 'Commands +2 elite heavy army knights stationed at your fortress gate.',
      icon: '🦍',
      perkType: PerkType.armyKnights,
      bonusValue: 2,
      badgeColor: Color(0xFFF97316),
    ),

    // 🎯 21–30: Habit Anchors & Rare Sovereigns
    AvatarGamePerk(
      day: 21,
      title: 'Day 21 Habit Iron Dome',
      description: 'Milestone achievement unlocks Tier 1 Iron Dome Aegis with zero coin upkeep!',
      icon: '🐍',
      perkType: PerkType.ironDome,
      bonusValue: 1,
      badgeColor: Color(0xFF10B981),
    ),
    AvatarGamePerk(
      day: 22,
      title: 'Winged Chrono Glide',
      description: 'Pegasus flight extends question timers by +10 seconds during fortress raids.',
      icon: '🪽',
      perkType: PerkType.timeFreeze,
      bonusValue: 10,
      badgeColor: Color(0xFF60A5FA),
    ),
    AvatarGamePerk(
      day: 23,
      title: 'Prismatic Vault Luster',
      description: 'Plumes dazzle opponents for +20% extra looted coins upon victory.',
      icon: '🦚',
      perkType: PerkType.vaultLoot,
      bonusValue: 20,
      badgeColor: Color(0xFF8B5CF6),
    ),
    AvatarGamePerk(
      day: 24,
      title: 'Outback Boxer Impact',
      description: 'Punching strikes deliver +15 bonus siege destruction damage on correct hits.',
      icon: '🦘',
      perkType: PerkType.siegeDamage,
      bonusValue: 15,
      badgeColor: Color(0xFFEF4444),
    ),
    AvatarGamePerk(
      day: 25,
      title: 'Nightfang Coin Siphon',
      description: 'Vampiric stealth siphons +20% extra gold coins from the defender vault.',
      icon: '🦇',
      perkType: PerkType.vaultLoot,
      bonusValue: 20,
      badgeColor: Color(0xFFDC2626),
    ),
    AvatarGamePerk(
      day: 26,
      title: 'Zen Temporal Anchor',
      description: 'Sloth serenity grants a huge +12 seconds question timer on raid gates.',
      icon: '🦥',
      perkType: PerkType.timeFreeze,
      bonusValue: 12,
      badgeColor: Color(0xFF10B981),
    ),
    AvatarGamePerk(
      day: 27,
      title: 'Anubis Sentry Corps',
      description: 'Guards the home perimeter with +2 disciplined celestial army knights.',
      icon: '🐕',
      perkType: PerkType.armyKnights,
      bonusValue: 2,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 28,
      title: 'Lunar Rabbit Surge',
      description: 'Swift moon agility gives +10 seconds timer and +10 bonus FDC per activity.',
      icon: '🐇',
      perkType: PerkType.timeFreeze,
      bonusValue: 10,
      badgeColor: Color(0xFFEC4899),
    ),
    AvatarGamePerk(
      day: 29,
      title: 'Kraken Tentacle Breaker',
      description: 'Crushes enemy barriers with +20 massive siege destruction damage.',
      icon: '🦑',
      perkType: PerkType.siegeDamage,
      bonusValue: 20,
      badgeColor: Color(0xFFF43F5E),
    ),
    AvatarGamePerk(
      day: 30,
      title: 'Day 30 Dragon Iron Dome',
      description: 'Celestial Dragon unlocks Free Tier 3 Iron Dome and +20 raid damage!',
      icon: '🐉',
      perkType: PerkType.ironDome,
      bonusValue: 3,
      badgeColor: Color(0xFFFFD700),
    ),

    // 🐆 31–40: Swift Nomads & Arctic Wanderers
    AvatarGamePerk(
      day: 31,
      title: 'Hyper-Speed Sprint',
      description: 'Cheetah velocity adds +10 seconds to challenge timers during combat.',
      icon: '🐆',
      perkType: PerkType.timeFreeze,
      bonusValue: 10,
      badgeColor: Color(0xFFFBBF24),
    ),
    AvatarGamePerk(
      day: 32,
      title: 'Glacial Permafrost Wall',
      description: 'Ice fortress armor reinforces maximum house structural HP by +30.',
      icon: '🐻‍❄️',
      perkType: PerkType.fortressShield,
      bonusValue: 30,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 33,
      title: 'Razorback Battering Ram',
      description: 'Wild boar charge inflicts +15 siege destruction damage on gate locks.',
      icon: '🐗',
      perkType: PerkType.siegeDamage,
      bonusValue: 15,
      badgeColor: Color(0xFFEA580C),
    ),
    AvatarGamePerk(
      day: 34,
      title: 'Volt EMP Interceptor',
      description: 'Electric ray discharges EMP to deflect 1 incoming missile strike per raid.',
      icon: '⚡',
      perkType: PerkType.ironDome,
      bonusValue: 1,
      badgeColor: Color(0xFF00F0FF),
    ),
    AvatarGamePerk(
      day: 35,
      title: 'Prismatic Camouflage',
      description: 'Cloaks your vault, reducing enemy coin looting by 15% during breaches.',
      icon: '🦎',
      perkType: PerkType.vaultLoot,
      bonusValue: 15,
      badgeColor: Color(0xFFA7F3D0),
    ),
    AvatarGamePerk(
      day: 36,
      title: 'Steel Armadillo Shell',
      description: 'Hardened carapace boosts fortress structural durability by +25 HP.',
      icon: '🛡️',
      perkType: PerkType.fortressShield,
      bonusValue: 25,
      badgeColor: Color(0xFFEAB308),
    ),
    AvatarGamePerk(
      day: 37,
      title: 'Panda Harmonic Focus',
      description: 'Awards +15 bonus FDC on voice calls and English group chats.',
      icon: '🐾',
      perkType: PerkType.fdcBoost,
      bonusValue: 15,
      badgeColor: Color(0xFFFDBA74),
    ),
    AvatarGamePerk(
      day: 38,
      title: 'Supersonic Dive-Bomb',
      description: 'Falcon dive strikes inflict +18 critical siege damage against enemy houses.',
      icon: '🦅',
      perkType: PerkType.siegeDamage,
      bonusValue: 18,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 39,
      title: 'Adamantine Wolverine Retaliation',
      description: 'Stations +2 relentless ferocious army knights to guard your compound.',
      icon: '🐾',
      perkType: PerkType.armyKnights,
      bonusValue: 2,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 40,
      title: 'Tundra Freeze Matrix',
      description: 'Lynx stealth grants +10 seconds calm solving time on difficult trap questions.',
      icon: '🐱',
      perkType: PerkType.timeFreeze,
      bonusValue: 10,
      badgeColor: Color(0xFF93C5FD),
    ),

    // 🌊 41–50: Deep Ocean & Savanna Titans
    AvatarGamePerk(
      day: 41,
      title: 'Walrus Tusk Barricade',
      description: 'Sturdy coastal tusk armor fortifies house defense with +30 structural HP.',
      icon: '🦭',
      perkType: PerkType.fortressShield,
      bonusValue: 30,
      badgeColor: Color(0xFFCBD5E1),
    ),
    AvatarGamePerk(
      day: 42,
      title: 'Apex Orca Breach',
      description: 'Ocean apex strikes deal +22 devastating breach damage during neighbor attacks.',
      icon: '🐋',
      perkType: PerkType.siegeDamage,
      bonusValue: 22,
      badgeColor: Color(0xFF0284C7),
    ),
    AvatarGamePerk(
      day: 43,
      title: 'Indomitable Badger Garrison',
      description: 'Stations +2 fearless honey badger guards immune to fear or hesitation.',
      icon: '🦡',
      perkType: PerkType.armyKnights,
      bonusValue: 2,
      badgeColor: Color(0xFFEF4444),
    ),
    AvatarGamePerk(
      day: 44,
      title: 'Hyena Pack Marauder',
      description: 'Coordinated pack tactics plunder +25% extra gold coins from enemy vaults.',
      icon: '🐺',
      perkType: PerkType.vaultLoot,
      bonusValue: 25,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 45,
      title: 'River Hippo Citadel',
      description: 'Massive bulk provides a gigantic +35 HP reinforcement to house structure.',
      icon: '🦛',
      perkType: PerkType.fortressShield,
      bonusValue: 35,
      badgeColor: Color(0xFFF43F5E),
    ),
    AvatarGamePerk(
      day: 46,
      title: 'Savanna Lookout Post',
      description: 'High-altitude vision grants +12 seconds question timer on raid gates.',
      icon: '🦒',
      perkType: PerkType.timeFreeze,
      bonusValue: 12,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 47,
      title: 'Emerald Viper Neurotoxin',
      description: 'Poisonous strike deals +15 bonus siege damage directly past gate barriers.',
      icon: '🐍',
      perkType: PerkType.siegeDamage,
      bonusValue: 15,
      badgeColor: Color(0xFF34D399),
    ),
    AvatarGamePerk(
      day: 48,
      title: 'Bighorn Ram Batter',
      description: 'Mountain ram battering horns deliver +20 siege damage per correct hit.',
      icon: '🐏',
      perkType: PerkType.siegeDamage,
      bonusValue: 20,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 49,
      title: 'Emperor Penguin Legion',
      description: 'Imperial polar decree stations +2 disciplined knights at the front line.',
      icon: '🐧',
      perkType: PerkType.armyKnights,
      bonusValue: 2,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 50,
      title: '24K Golden Jaguar Marauder',
      description: 'Apex predator delivers +25% bonus looted coins and +15 raid siege damage.',
      icon: '🐆',
      perkType: PerkType.vaultLoot,
      bonusValue: 25,
      badgeColor: Color(0xFFFFD700),
    ),

    // 🌴 51–60: Jungle Lords & Prehistoric Behemoths
    AvatarGamePerk(
      day: 51,
      title: 'River Dynamo Surge',
      description: 'Energetic otter play grants +20 bonus FDC on voice calls and English vibes.',
      icon: '🦦',
      perkType: PerkType.fdcBoost,
      bonusValue: 20,
      badgeColor: Color(0xFF67E8F9),
    ),
    AvatarGamePerk(
      day: 52,
      title: 'Anteater Sentry Net',
      description: 'Carefully scouts defenses, earning +15 bonus FDC on English chats.',
      icon: '🐜',
      perkType: PerkType.fdcBoost,
      bonusValue: 15,
      badgeColor: Color(0xFFCBD5E1),
    ),
    AvatarGamePerk(
      day: 53,
      title: 'Woolly Mammoth Fortress Bastion',
      description: 'Ice-age colossus reinforces house HP by a massive +40 structural health.',
      icon: '🦣',
      perkType: PerkType.fortressShield,
      bonusValue: 40,
      badgeColor: Color(0xFFFACC15),
    ),
    AvatarGamePerk(
      day: 54,
      title: 'Swordfish Torpedo Piercing',
      description: 'Sharp oceanic rostrum inflicts +22 bonus siege destruction damage.',
      icon: '🗡️',
      perkType: PerkType.siegeDamage,
      bonusValue: 22,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 55,
      title: 'Komodo Titan Vanguard',
      description: 'Venomous dragon presence stations +2 battle-hardened sentinel knights.',
      icon: '🦎',
      perkType: PerkType.armyKnights,
      bonusValue: 2,
      badgeColor: Color(0xFF84CC16),
    ),
    AvatarGamePerk(
      day: 56,
      title: 'Canopy Echo Surge',
      description: 'Loud tropical calling awards +20 bonus FDC per completed voice talk.',
      icon: '🦜',
      perkType: PerkType.fdcBoost,
      bonusValue: 20,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 57,
      title: 'Flamingo Phoenix Aura',
      description: 'Graceful crimson feathers grant +25 max fortress integrity and fast healing.',
      icon: '🦩',
      perkType: PerkType.fortressShield,
      bonusValue: 25,
      badgeColor: Color(0xFFFDA4AF),
    ),
    AvatarGamePerk(
      day: 58,
      title: 'Sentinel Meerkat Radar Dome',
      description: 'Advanced lookout radar unlocks Free Tier 2 Iron Dome to shoot down raids!',
      icon: '📡',
      perkType: PerkType.ironDome,
      bonusValue: 2,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 59,
      title: 'Manticore Sting Devastation',
      description: 'Venomous tail strike delivers +25 overwhelming siege breach damage.',
      icon: '🦂',
      perkType: PerkType.siegeDamage,
      bonusValue: 25,
      badgeColor: Color(0xFFDC2626),
    ),
    AvatarGamePerk(
      day: 60,
      title: 'Day 60 Golden Griffin Sovereign',
      description: 'Mythic Griffin commands +3 stationed Army Knights and +25 bonus FDC!',
      icon: '🦅',
      perkType: PerkType.armyKnights,
      bonusValue: 3,
      badgeColor: Color(0xFFFFD700),
    ),

    // 🔥 61–70: Mythic Beasts & Elemental Guardians
    AvatarGamePerk(
      day: 61,
      title: 'Magma Salamander Armor',
      description: 'Volcanic magma skin fortifies maximum house integrity by +35 HP.',
      icon: '🦎',
      perkType: PerkType.fortressShield,
      bonusValue: 35,
      badgeColor: Color(0xFFF97316),
    ),
    AvatarGamePerk(
      day: 62,
      title: 'Narwhal Glacial Spiral',
      description: 'Crystalline unicorn horn inflicts +24 piercing raid breach damage.',
      icon: '🦄',
      perkType: PerkType.siegeDamage,
      bonusValue: 24,
      badgeColor: Color(0xFFE0F2FE),
    ),
    AvatarGamePerk(
      day: 63,
      title: 'Ghost Leopard Camouflage',
      description: 'Phantom stealth adds +15 seconds to solve tricky defense trap questions.',
      icon: '🐆',
      perkType: PerkType.timeFreeze,
      bonusValue: 15,
      badgeColor: Color(0xFF94A3B8),
    ),
    AvatarGamePerk(
      day: 64,
      title: 'Fennec Acoustic Radar',
      description: 'Desert radar ears earn +25 bonus FDC on anonymous English voice calls.',
      icon: '🦊',
      perkType: PerkType.fdcBoost,
      bonusValue: 25,
      badgeColor: Color(0xFFFBBF24),
    ),
    AvatarGamePerk(
      day: 65,
      title: 'Cyber Mantis Nano Blades',
      description: 'Razor-sharp nano scythes deal +26 high-speed breach damage on targets.',
      icon: '🦗',
      perkType: PerkType.siegeDamage,
      bonusValue: 26,
      badgeColor: Color(0xFF6EE7B7),
    ),
    AvatarGamePerk(
      day: 66,
      title: 'Ghost Jellyfish Iron Shield',
      description: 'Bioluminescent energy sphere deploys Free Tier 2 Iron Dome interceptor!',
      icon: '🪼',
      perkType: PerkType.ironDome,
      bonusValue: 2,
      badgeColor: Color(0xFFC084FC),
    ),
    AvatarGamePerk(
      day: 67,
      title: 'Armored Pangolin Bastion',
      description: 'Diamond scales bolster your fortress walls with +40 max structural HP.',
      icon: '🛡️',
      perkType: PerkType.fortressShield,
      bonusValue: 40,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 68,
      title: 'Obsidian Panther Strike',
      description: 'Lethal night ambush deals +28 crushing siege damage on neighbor gates.',
      icon: '🐈‍⬛',
      perkType: PerkType.siegeDamage,
      bonusValue: 28,
      badgeColor: Color(0xFFC084FC),
    ),
    AvatarGamePerk(
      day: 69,
      title: 'Sky Thunderbird Shockwave',
      description: 'Electric storm dive deals +28 destructive siege damage on enemy defenses.',
      icon: '⚡',
      perkType: PerkType.siegeDamage,
      bonusValue: 28,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 70,
      title: 'Cerberus Hellgate Garrison',
      description: 'Three-headed beast commands +3 ferocious knights stationed at the portal.',
      icon: '🐕‍🦺',
      perkType: PerkType.armyKnights,
      bonusValue: 3,
      badgeColor: Color(0xFFDC2626),
    ),

    // 👑 71–80: Enchanted & Prismatic Monarchs
    AvatarGamePerk(
      day: 71,
      title: 'Coral Reef Sanctuary',
      description: 'Living coral magic reinforces your house integrity by +30 maximum HP.',
      icon: '🫧',
      perkType: PerkType.fortressShield,
      bonusValue: 30,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 72,
      title: 'Gorilla Sovereign Scepter',
      description: 'Royal strength stations +3 army knights and secures +25% vault coins.',
      icon: '👑',
      perkType: PerkType.armyKnights,
      bonusValue: 3,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 73,
      title: 'Cyber Chimera Barrage',
      description: 'Tri-elemental blast delivers +30 massive siege damage against fortresses.',
      icon: '🦁',
      perkType: PerkType.siegeDamage,
      bonusValue: 30,
      badgeColor: Color(0xFFEC4899),
    ),
    AvatarGamePerk(
      day: 74,
      title: 'Poison Dart Time Warp',
      description: 'Paralytic darts slow enemy defenses, granting +15s question time on raids.',
      icon: '🐸',
      perkType: PerkType.timeFreeze,
      bonusValue: 15,
      badgeColor: Color(0xFF60A5FA),
    ),
    AvatarGamePerk(
      day: 75,
      title: 'Chrysalis Vibe Surge',
      description: 'Metamorphic beauty awards +30 bonus FDC per English vibe posted.',
      icon: '🦋',
      perkType: PerkType.fdcBoost,
      bonusValue: 30,
      badgeColor: Color(0xFFFDE047),
    ),
    AvatarGamePerk(
      day: 76,
      title: 'Arctic Musk Ox Phalanx',
      description: 'Impenetrable tundra circle fortifies house defenses with +45 max HP.',
      icon: '🐂',
      perkType: PerkType.fortressShield,
      bonusValue: 45,
      badgeColor: Color(0xFFCBD5E1),
    ),
    AvatarGamePerk(
      day: 77,
      title: 'Prism Mirage Iron Dome',
      description: 'Prismatic light refraction grants a Free Tier 2 Iron Dome missile shield!',
      icon: '🌈',
      perkType: PerkType.ironDome,
      bonusValue: 2,
      badgeColor: Color(0xFFF43F5E),
    ),
    AvatarGamePerk(
      day: 78,
      title: 'Desert Horned Citadel',
      description: 'Thorned reptilian scales reinforce house structure durability by +35 HP.',
      icon: '🦎',
      perkType: PerkType.fortressShield,
      bonusValue: 35,
      badgeColor: Color(0xFFF59E0B),
    ),
    AvatarGamePerk(
      day: 79,
      title: 'Angler Siren Lure',
      description: 'Deep light lure breaches enemy citadels with +30 devastating siege damage.',
      icon: '💡',
      perkType: PerkType.siegeDamage,
      bonusValue: 30,
      badgeColor: Color(0xFFFACC15),
    ),
    AvatarGamePerk(
      day: 80,
      title: 'Mecha Cyber Alpha Pack',
      description: 'High-tech cyber wolf summons +3 stationed advanced android knights!',
      icon: '🐺',
      perkType: PerkType.armyKnights,
      bonusValue: 3,
      badgeColor: Color(0xFF38BDF8),
    ),

    // 🌌 81–90: Celestial Sovereigns & Cosmic Grandmasters
    AvatarGamePerk(
      day: 81,
      title: 'Nine-Tailed Solar Aegis',
      description: 'Mythic Kitsune grants Free Tier 3 Iron Dome and +25 bonus FDC credits!',
      icon: '🦊',
      perkType: PerkType.ironDome,
      bonusValue: 3,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 82,
      title: 'Solar Sovereign Supernova',
      description: 'Blinding sunburst inflicts +32 catastrophic siege damage against defenses.',
      icon: '☀️',
      perkType: PerkType.siegeDamage,
      bonusValue: 32,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 83,
      title: 'Mythic Sea Dragon Tsunami',
      description: 'Ocean tidal wave deals +32 raid damage and plunders +25% extra gold coins.',
      icon: '🌊',
      perkType: PerkType.siegeDamage,
      bonusValue: 32,
      badgeColor: Color(0xFF38BDF8),
    ),
    AvatarGamePerk(
      day: 84,
      title: 'Tempest Roc Cataclysm',
      description: 'Hurricane wing beats crush enemy structures with +34 siege breach damage.',
      icon: '🌪️',
      perkType: PerkType.siegeDamage,
      bonusValue: 34,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 85,
      title: 'Obsidian Basilisk Gaze',
      description: 'Petrifying glance freezes time, adding a massive +20 seconds to all raid timers.',
      icon: '👁️',
      perkType: PerkType.timeFreeze,
      bonusValue: 20,
      badgeColor: Color(0xFF10B981),
    ),
    AvatarGamePerk(
      day: 86,
      title: '24K Celestial Phoenix Rebirth',
      description: 'Astral flame grants +50 max fortress integrity and instant passive repairs.',
      icon: '🔥',
      perkType: PerkType.fortressShield,
      bonusValue: 50,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 87,
      title: 'Void Hydra Multi-Strike',
      description: 'Multi-headed cosmic strike unleashes +35 extreme siege damage on target.',
      icon: '🐉',
      perkType: PerkType.siegeDamage,
      bonusValue: 35,
      badgeColor: Color(0xFFC084FC),
    ),
    AvatarGamePerk(
      day: 88,
      title: 'Chrono Time Dragon Reality Warp',
      description: 'Warp reality with +25s puzzle time and an unbreakable Tier 3 Iron Dome!',
      icon: '⌛',
      perkType: PerkType.timeFreeze,
      bonusValue: 25,
      badgeColor: Color(0xFFFFD700),
    ),
    AvatarGamePerk(
      day: 89,
      title: 'Astral Titan Phalanx',
      description: 'Commands +4 cosmic titan knights and fortifies house with +50 max HP.',
      icon: '🛡️',
      perkType: PerkType.armyKnights,
      bonusValue: 4,
      badgeColor: Color(0xFF818CF8),
    ),
    AvatarGamePerk(
      day: 90,
      title: 'Supreme Cosmic Godhead',
      description: 'Supreme Grandmaster power: Permanent Tier 3 Iron Dome, +4 Knights, +40 Raid DMG, & +50% Vault Gold!',
      icon: '👑',
      perkType: PerkType.ironDome,
      bonusValue: 3,
      badgeColor: Color(0xFFFFD700),
    ),
  ];
}
