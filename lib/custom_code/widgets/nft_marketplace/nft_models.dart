import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/bored_ape_painter.dart';

class NftTrait {
  final String traitType;
  final String value;
  final double rarityPercent;

  const NftTrait({
    required this.traitType,
    required this.value,
    required this.rarityPercent,
  });
}

class NftItem {
  final String id;
  final String title;
  final String collectionName;
  final String artistName;
  final String artistHandle;
  final String artistAvatar;
  final String imageUrl;
  final BoredApeTraits? apeTraits; // Authentic Vector Bored Ape traits
  final double priceEth;
  final int priceCoins;
  final double priceInr;
  final int likesCount;
  final String rarityTier; // 'Mythic 1-of-1' | 'Legendary' | 'Epic' | 'Rare'
  final String dnaHash;
  final DateTime auctionEndsAt;
  final Color cardColor;
  final List<NftTrait> traits;
  final bool isVerified;
  final bool isTrending;
  final bool isClaimed;
  final String? claimedByUsername;
  final bool isPremium;

  const NftItem({
    required this.id,
    required this.title,
    required this.collectionName,
    required this.artistName,
    required this.artistHandle,
    required this.artistAvatar,
    required this.imageUrl,
    this.apeTraits,
    required this.priceEth,
    required this.priceCoins,
    required this.priceInr,
    required this.likesCount,
    required this.rarityTier,
    required this.dnaHash,
    required this.auctionEndsAt,
    required this.cardColor,
    required this.traits,
    this.isVerified = true,
    this.isTrending = false,
    this.isClaimed = false,
    this.claimedByUsername,
    this.isPremium = false,
  });

  String get timeRemaining {
    final diff = auctionEndsAt.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours : $minutes : $seconds';
  }
}

class NftMockData {
  static List<NftItem> getItems() {
    final now = DateTime.now();
    return [
      // 1. Ape 1 from User Image: Laser Eyes, Grin, Military Jacket, Orange
      NftItem(
        id: 'BAYC-001',
        title: 'Bored Ape Laser #320',
        collectionName: 'Bored Ape Yacht Club',
        artistName: 'Rocky Rio',
        artistHandle: '@rocky_rio',
        artistAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
        apeTraits: const BoredApeTraits(
          furColor: 'brown',
          eyes: 'laser_beams',
          mouth: 'wide_grin',
          outfit: 'military_jacket',
          background: 'orange',
          hasEarring: false,
        ),
        priceEth: 0.20,
        priceCoins: 500,
        priceInr: 199.0,
        likesCount: 320,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0x8F-4A-91-C2',
        auctionEndsAt: now.add(const Duration(hours: 5, minutes: 35, seconds: 9)),
        cardColor: const Color(0xFFE58E26),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Eyes', value: 'Cyan Laser Beams', rarityPercent: 0.8),
          NftTrait(traitType: 'Mouth', value: 'Wide Grin Teeth', rarityPercent: 2.1),
          NftTrait(traitType: 'Outfit', value: 'Military Army Jacket', rarityPercent: 3.4),
          NftTrait(traitType: 'Fur', value: 'Classic Brown', rarityPercent: 12.0),
        ],
      ),

      // 2. Ape 2 from User Image: Sailor Hat, Cyborg Red Eye, Earring, Cyan
      NftItem(
        id: 'BAYC-002',
        title: 'Bored Ape Sailor Cyborg #411',
        collectionName: 'Bored Ape Yacht Club',
        artistName: 'Rocky Rio',
        artistHandle: '@rocky_rio',
        artistAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=800&auto=format&fit=crop&q=80',
        apeTraits: const BoredApeTraits(
          furColor: 'brown',
          eyes: 'cyborg_red',
          mouth: 'pout',
          headwear: 'sailor_hat',
          outfit: 'naked',
          background: 'cyan',
          hasEarring: true,
        ),
        priceEth: 0.35,
        priceCoins: 750,
        priceInr: 299.0,
        likesCount: 480,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0xFE-11-9A-02',
        auctionEndsAt: now.add(const Duration(hours: 8, minutes: 20, seconds: 12)),
        cardColor: const Color(0xFF00CEC9),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Headwear', value: 'Navy Sailor Hat', rarityPercent: 1.5),
          NftTrait(traitType: 'Eyes', value: 'Cyborg Terminator Eye', rarityPercent: 1.1),
          NftTrait(traitType: 'Earring', value: 'Gold Hoop', rarityPercent: 4.8),
        ],
      ),

      // 3. Ape 3 from User Image: Captain Hat, 3D Glasses, Cigarette, Cyber Armor, Teal
      NftItem(
        id: 'BAYC-003',
        title: 'Captain 3D Cyber Ape #777',
        collectionName: 'Bored Ape Yacht Club',
        artistName: 'Zoya Rex Art',
        artistHandle: '@zoyarex',
        artistAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=800&auto=format&fit=crop&q=80',
        apeTraits: const BoredApeTraits(
          furColor: 'brown',
          eyes: '3d_glasses',
          mouth: 'cigarette',
          headwear: 'captain_hat',
          outfit: 'cyber_armor',
          background: 'teal',
          hasEarring: false,
        ),
        priceEth: 0.45,
        priceCoins: 900,
        priceInr: 349.0,
        likesCount: 620,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0x99-BC-44-11',
        auctionEndsAt: now.add(const Duration(hours: 14, minutes: 10, seconds: 0)),
        cardColor: const Color(0xFF00B894),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Headwear', value: 'Captain Officer Hat', rarityPercent: 0.9),
          NftTrait(traitType: 'Eyes', value: '3D Stereo Glasses', rarityPercent: 2.2),
          NftTrait(traitType: 'Mouth', value: 'Cigarette Joint', rarityPercent: 3.8),
          NftTrait(traitType: 'Outfit', value: 'Cybernetic Plate Armor', rarityPercent: 1.6),
        ],
      ),

      // 4. Ape 4 from User Image: Leopard Fur, Sleepy Eyes, Tongue Out, Purple
      NftItem(
        id: 'BAYC-004',
        title: 'Leopard Cheetah Ape #204',
        collectionName: 'Bored Ape Yacht Club',
        artistName: 'Tokyo Synth',
        artistHandle: '@tokyosynth',
        artistAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1614680376593-902f749f7ffc?w=800&auto=format&fit=crop&q=80',
        apeTraits: const BoredApeTraits(
          furColor: 'leopard',
          eyes: 'sleepy',
          mouth: 'tongue_out',
          outfit: 'naked',
          background: 'purple',
          hasEarring: false,
        ),
        priceEth: 0.28,
        priceCoins: 600,
        priceInr: 249.0,
        likesCount: 390,
        rarityTier: 'Legendary',
        dnaHash: '0x7C-12-88-DA',
        auctionEndsAt: now.add(const Duration(hours: 3, minutes: 40, seconds: 22)),
        cardColor: const Color(0xFF6C5CE7),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Fur', value: 'Leopard / Cheetah Spots', rarityPercent: 0.6),
          NftTrait(traitType: 'Mouth', value: 'Tongue Out', rarityPercent: 1.9),
          NftTrait(traitType: 'Eyes', value: 'Sleepy Drooping Eyelids', rarityPercent: 5.1),
        ],
      ),

      // 5. Ape 5 from User Image: VR Neon Visor, Cigarette, Grey Fur, Cyan
      NftItem(
        id: 'BAYC-005',
        title: 'VR Neon Cyber Ape #819',
        collectionName: 'Bored Ape Yacht Club',
        artistName: 'Musab Hira',
        artistHandle: '@musabhira',
        artistAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1633167606207-d840b5070fc2?w=800&auto=format&fit=crop&q=80',
        apeTraits: const BoredApeTraits(
          furColor: 'cyber_grey',
          eyes: 'vr_visor',
          mouth: 'cigarette',
          outfit: 'naked',
          background: 'cyan',
          hasEarring: false,
        ),
        priceEth: 0.32,
        priceCoins: 650,
        priceInr: 279.0,
        likesCount: 410,
        rarityTier: 'Legendary',
        dnaHash: '0x34-90-E1-F5',
        auctionEndsAt: now.add(const Duration(hours: 19, minutes: 12, seconds: 50)),
        cardColor: const Color(0xFF00CEC9),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Eyes', value: 'VR Glowing Blue Visor', rarityPercent: 1.4),
          NftTrait(traitType: 'Fur', value: 'Cyber Grey', rarityPercent: 4.2),
          NftTrait(traitType: 'Mouth', value: 'Cigarette', rarityPercent: 3.8),
        ],
      ),

      // 6. Ape 6 from User Image: Dead X-Eyes, Grin, Earring, Cyber Armor, Amber
      NftItem(
        id: 'BAYC-006',
        title: 'Dead X Cyber Ape #042',
        collectionName: 'Bored Ape Yacht Club',
        artistName: 'Arcade Legend',
        artistHandle: '@arcade_legend',
        artistAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
        apeTraits: const BoredApeTraits(
          furColor: 'brown',
          eyes: 'x_eyes',
          mouth: 'wide_grin',
          outfit: 'cyber_armor',
          background: 'amber',
          hasEarring: true,
        ),
        priceEth: 0.38,
        priceCoins: 800,
        priceInr: 319.0,
        likesCount: 530,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0x12-34-56-78',
        auctionEndsAt: now.add(const Duration(hours: 7, minutes: 30, seconds: 0)),
        cardColor: const Color(0xFFF39C12),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Eyes', value: 'Dead Cross X-Eyes', rarityPercent: 0.7),
          NftTrait(traitType: 'Mouth', value: 'Wide Grin Teeth', rarityPercent: 2.1),
          NftTrait(traitType: 'Outfit', value: 'Cyber Armor Neck', rarityPercent: 1.6),
          NftTrait(traitType: 'Earring', value: 'Gold Hoop', rarityPercent: 4.8),
        ],
      ),
    ];
  }
}
