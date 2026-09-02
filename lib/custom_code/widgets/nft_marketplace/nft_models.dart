import 'package:flutter/material.dart';

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

  const NftItem({
    required this.id,
    required this.title,
    required this.collectionName,
    required this.artistName,
    required this.artistHandle,
    required this.artistAvatar,
    required this.imageUrl,
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
      NftItem(
        id: 'APE-001',
        title: 'Cyber Ape Illustration #320',
        collectionName: 'Pocket Bored Apes',
        artistName: 'Rocky Rio',
        artistHandle: '@rocky_rio',
        artistAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
        priceEth: 0.20,
        priceCoins: 500,
        priceInr: 199.0,
        likesCount: 320,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0x8F-4A-91-C2',
        auctionEndsAt: now.add(const Duration(hours: 5, minutes: 35, seconds: 9)),
        cardColor: const Color(0xFF8B5CF6),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Species', value: 'Bored Ape', rarityPercent: 1.2),
          NftTrait(traitType: 'Eyes', value: 'Neon Cyber Glasses', rarityPercent: 3.5),
          NftTrait(traitType: 'Outfit', value: 'Tuxedo Bowtie', rarityPercent: 4.8),
          NftTrait(traitType: 'Headwear', value: 'Artist Pencil', rarityPercent: 2.1),
        ],
      ),
      NftItem(
        id: 'APE-002',
        title: 'Golden Monarch Ape #789',
        collectionName: 'Pocket Bored Apes',
        artistName: 'Rocky Rio',
        artistHandle: '@rocky_rio',
        artistAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=800&auto=format&fit=crop&q=80',
        priceEth: 0.45,
        priceCoins: 850,
        priceInr: 349.0,
        likesCount: 540,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0xDA-22-B1-FE',
        auctionEndsAt: now.add(const Duration(hours: 9, minutes: 12, seconds: 40)),
        cardColor: const Color(0xFFFFB700),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Species', value: 'Royal Ape', rarityPercent: 0.8),
          NftTrait(traitType: 'Crown', value: 'Solar Gold Crown', rarityPercent: 1.0),
          NftTrait(traitType: 'Robes', value: 'King Robes', rarityPercent: 2.4),
        ],
      ),
      NftItem(
        id: 'APE-003',
        title: 'Samurai Shinobi Ape #142',
        collectionName: 'Pocket Shinobi',
        artistName: 'Zoya Rex Art',
        artistHandle: '@zoyarex',
        artistAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=800&auto=format&fit=crop&q=80',
        priceEth: 0.18,
        priceCoins: 420,
        priceInr: 169.0,
        likesCount: 290,
        rarityTier: 'Legendary',
        dnaHash: '0x33-88-7A-01',
        auctionEndsAt: now.add(const Duration(hours: 12, minutes: 4, seconds: 0)),
        cardColor: const Color(0xFFFF007A),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Species', value: 'Shinobi Ape', rarityPercent: 4.1),
          NftTrait(traitType: 'Headband', value: 'Red Rising Sun', rarityPercent: 5.2),
          NftTrait(traitType: 'Armor', value: 'Shadow Kimono', rarityPercent: 3.9),
        ],
      ),
      NftItem(
        id: 'KONG-004',
        title: 'Mecha Cyber Titan #909',
        collectionName: 'Cyber Kongz 3000',
        artistName: 'Tokyo Synth',
        artistHandle: '@tokyosynth',
        artistAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1614680376593-902f749f7ffc?w=800&auto=format&fit=crop&q=80',
        priceEth: 0.35,
        priceCoins: 700,
        priceInr: 299.0,
        likesCount: 480,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0x00-FF-66-99',
        auctionEndsAt: now.add(const Duration(hours: 3, minutes: 18, seconds: 22)),
        cardColor: const Color(0xFF00E5FF),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Species', value: 'Mecha Cyber Kong', rarityPercent: 0.9),
          NftTrait(traitType: 'Visor', value: 'Holographic Scanner', rarityPercent: 1.5),
        ],
      ),
      NftItem(
        id: 'DRAGON-005',
        title: 'Astral Cosmic Dragon #888',
        collectionName: 'Celestial Beasts',
        artistName: 'Musab Hira',
        artistHandle: '@musabhira',
        artistAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1633167606207-d840b5070fc2?w=800&auto=format&fit=crop&q=80',
        priceEth: 0.50,
        priceCoins: 1000,
        priceInr: 399.0,
        likesCount: 710,
        rarityTier: 'Mythic 1-of-1',
        dnaHash: '0x99-AA-BB-CC',
        auctionEndsAt: now.add(const Duration(hours: 18, minutes: 50, seconds: 15)),
        cardColor: const Color(0xFF7928CA),
        isTrending: true,
        traits: const [
          NftTrait(traitType: 'Species', value: 'Cosmic Dragon', rarityPercent: 0.5),
          NftTrait(traitType: 'Aura', value: 'Starlight Supernova', rarityPercent: 0.7),
        ],
      ),
      NftItem(
        id: 'PUNK-006',
        title: 'Neon Tokyo Voxel Punk #042',
        collectionName: 'Pixel Punks',
        artistName: 'Arcade Legend',
        artistHandle: '@arcade_legend',
        artistAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&auto=format&fit=crop&q=80',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
        priceEth: 0.12,
        priceCoins: 300,
        priceInr: 99.0,
        likesCount: 180,
        rarityTier: 'Rare',
        dnaHash: '0x12-34-56-78',
        auctionEndsAt: now.add(const Duration(hours: 7, minutes: 20, seconds: 0)),
        cardColor: const Color(0xFF10B981),
        isTrending: false,
        traits: const [
          NftTrait(traitType: 'Art Style', value: '8-Bit Voxel', rarityPercent: 8.5),
          NftTrait(traitType: 'Accessory', value: 'VR Goggles', rarityPercent: 6.2),
        ],
      ),
    ];
  }
}
