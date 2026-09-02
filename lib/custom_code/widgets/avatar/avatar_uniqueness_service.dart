import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/bored_ape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/nft_marketplace/nft_models.dart';

class AvatarClaimRecord {
  final String avatarId;
  final String userId;
  final String username;
  final String dnaHash;
  final DateTime claimedAt;

  AvatarClaimRecord({
    required this.avatarId,
    required this.userId,
    required this.username,
    required this.dnaHash,
    required this.claimedAt,
  });

  Map<String, dynamic> toMap() => {
        'avatar_id': avatarId,
        'user_id': userId,
        'username': username,
        'dna_hash': dnaHash,
        'claimed_at': claimedAt.toIso8601String(),
      };

  factory AvatarClaimRecord.fromMap(Map<String, dynamic> map) => AvatarClaimRecord(
        avatarId: map['avatar_id'] ?? '',
        userId: map['user_id'] ?? '',
        username: map['username'] ?? 'Anonymous',
        dnaHash: map['dna_hash'] ?? '',
        claimedAt: DateTime.tryParse(map['claimed_at'] ?? '') ?? DateTime.now(),
      );
}

class AvatarUniquenessService {
  static final AvatarUniquenessService _instance = AvatarUniquenessService._internal();
  factory AvatarUniquenessService() => _instance;
  AvatarUniquenessService._internal();

  final Map<String, AvatarClaimRecord> _claimedRegistry = {};
  final Set<String> _usedDnaHashes = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('claimed_avatars_registry');
    if (raw != null) {
      try {
        final List list = jsonDecode(raw);
        for (final item in list) {
          final record = AvatarClaimRecord.fromMap(Map<String, dynamic>.from(item));
          _claimedRegistry[record.avatarId] = record;
          _usedDnaHashes.add(record.dnaHash);
        }
      } catch (_) {}
    }
  }

  bool isClaimed(String avatarId) => _claimedRegistry.containsKey(avatarId);

  AvatarClaimRecord? getClaimRecord(String avatarId) => _claimedRegistry[avatarId];

  Future<bool> claimAvatar({
    required String avatarId,
    required String userId,
    required String username,
    required String dnaHash,
  }) async {
    if (_claimedRegistry.containsKey(avatarId)) {
      return false; // Already claimed by another user!
    }

    final record = AvatarClaimRecord(
      avatarId: avatarId,
      userId: userId,
      username: username,
      dnaHash: dnaHash,
      claimedAt: DateTime.now(),
    );

    _claimedRegistry[avatarId] = record;
    _usedDnaHashes.add(dnaHash);

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_claimedRegistry.values.map((v) => v.toMap()).toList());
    await prefs.setString('claimed_avatars_registry', encoded);

    // Save claim record to Supabase if logged in
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'claimed_avatar_id': avatarId,
          'avatar_dna': dnaHash,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
      }
    } catch (_) {}

    return true;
  }

  /// Procedurally generates a batch of 50+ unique, never-before-seen Bored Ape avatars!
  List<NftItem> generateProceduralBoredApes({int count = 50}) {
    final rand = Random();
    final List<NftItem> results = [];

    final furs = ['brown', 'leopard', 'gold', 'cyber_grey', 'zombie_green', 'obsidian'];
    final eyes = ['laser_beams', 'cyborg_red', '3d_glasses', 'vr_visor', 'x_eyes', 'sleepy'];
    final mouths = ['wide_grin', 'tongue_out', 'cigarette', 'pout'];
    final headwears = ['none', 'sailor_hat', 'captain_hat', 'gold_crown'];
    final outfits = ['military_jacket', 'cyber_armor', 'naked'];
    final bgs = ['orange', 'teal', 'cyan', 'purple', 'amber', 'dark'];

    final artistNames = [
      'Rocky Rio',
      'Zoya Rex Studio',
      'Neon Apex',
      'Doodle Master',
      'Tokyo Synth',
      'Arcade Legend',
      'Celestial Arts',
      'Pocket Labs',
    ];

    for (int i = 0; i < count; i++) {
      final id = 'BAYC-GEN-${DateTime.now().millisecondsSinceEpoch % 1000000}-$i';
      
      // Generate unique DNA
      String dna = '';
      do {
        final h1 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
        final h2 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
        final h3 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
        dna = '0x$h1-$h2-$h3';
      } while (_usedDnaHashes.contains(dna));

      final f = furs[rand.nextInt(furs.length)];
      final e = eyes[rand.nextInt(eyes.length)];
      final m = mouths[rand.nextInt(mouths.length)];
      final h = headwears[rand.nextInt(headwears.length)];
      final o = outfits[rand.nextInt(outfits.length)];
      final b = bgs[rand.nextInt(bgs.length)];
      final earring = rand.nextBool();

      final artist = artistNames[rand.nextInt(artistNames.length)];
      final number = rand.nextInt(900) + 100;
      final rarity = rand.nextDouble() < 0.15
          ? 'Mythic 1-of-1'
          : (rand.nextDouble() < 0.4 ? 'Legendary' : 'Rare');

      final apeTraits = BoredApeTraits(
        furColor: f,
        eyes: e,
        mouth: m,
        headwear: h,
        outfit: o,
        background: b,
        hasEarring: earring,
      );

      final claimInfo = _claimedRegistry[id];

      results.add(
        NftItem(
          id: id,
          title: 'Bored Ape #$number',
          collectionName: 'Bored Ape Yacht Club',
          artistName: artist,
          artistHandle: '@${artist.toLowerCase().replaceAll(' ', '_')}',
          artistAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
          imageUrl: '',
          apeTraits: apeTraits,
          priceEth: (rand.nextInt(50) + 10) / 100,
          priceCoins: (rand.nextInt(8) + 2) * 100,
          priceInr: (rand.nextInt(30) + 10) * 10.0,
          likesCount: rand.nextInt(500) + 50,
          rarityTier: rarity,
          dnaHash: dna,
          auctionEndsAt: DateTime.now().add(Duration(hours: rand.nextInt(48) + 1)),
          cardColor: BoredApeTraits.getBackgroundColor(b),
          isClaimed: claimInfo != null,
          claimedByUsername: claimInfo?.username,
          traits: [
            NftTrait(traitType: 'Fur', value: f, rarityPercent: (rand.nextInt(10) + 1).toDouble()),
            NftTrait(traitType: 'Eyes', value: e, rarityPercent: (rand.nextInt(8) + 1).toDouble()),
            NftTrait(traitType: 'Headwear', value: h, rarityPercent: (rand.nextInt(6) + 1).toDouble()),
            NftTrait(traitType: 'Outfit', value: o, rarityPercent: (rand.nextInt(12) + 1).toDouble()),
          ],
        ),
      );
    }

    return results;
  }
}
