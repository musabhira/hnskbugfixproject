import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/bored_ape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/nft_marketplace/nft_models.dart';

class AvatarProvenanceEvent {
  final String eventType; // 'MINTED' | 'CLAIMED' | 'TRANSFERRED' | 'EQUIPPED'
  final String from;
  final String to;
  final DateTime timestamp;
  final String txHash;
  final String? note;

  AvatarProvenanceEvent({
    required this.eventType,
    required this.from,
    required this.to,
    required this.timestamp,
    required this.txHash,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'event_type': eventType,
        'from': from,
        'to': to,
        'timestamp': timestamp.toIso8601String(),
        'tx_hash': txHash,
        'note': note,
      };

  factory AvatarProvenanceEvent.fromMap(Map<String, dynamic> map) =>
      AvatarProvenanceEvent(
        eventType: map['event_type'] ?? 'MINTED',
        from: map['from'] ?? 'Pocket Labs',
        to: map['to'] ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        txHash: map['tx_hash'] ?? '0xGENESIS',
        note: map['note'],
      );
}

class AvatarClaimRecord {
  final String avatarId;
  final String userId;
  final String username;
  final String dnaHash;
  final DateTime claimedAt;
  final List<AvatarProvenanceEvent> history;

  AvatarClaimRecord({
    required this.avatarId,
    required this.userId,
    required this.username,
    required this.dnaHash,
    required this.claimedAt,
    List<AvatarProvenanceEvent>? history,
  }) : history = history ?? [];

  Map<String, dynamic> toMap() => {
        'avatar_id': avatarId,
        'user_id': userId,
        'username': username,
        'dna_hash': dnaHash,
        'claimed_at': claimedAt.toIso8601String(),
        'history': history.map((e) => e.toMap()).toList(),
      };

  factory AvatarClaimRecord.fromMap(Map<String, dynamic> map) {
    final rawHist = map['history'] as List? ?? [];
    return AvatarClaimRecord(
      avatarId: map['avatar_id'] ?? '',
      userId: map['user_id'] ?? '',
      username: map['username'] ?? 'Anonymous',
      dnaHash: map['dna_hash'] ?? '',
      claimedAt: DateTime.tryParse(map['claimed_at'] ?? '') ?? DateTime.now(),
      history: rawHist
          .map((e) => AvatarProvenanceEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class AvatarUniquenessService {
  static final AvatarUniquenessService _instance =
      AvatarUniquenessService._internal();
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
          final record =
              AvatarClaimRecord.fromMap(Map<String, dynamic>.from(item));
          _claimedRegistry[record.avatarId] = record;
          _usedDnaHashes.add(record.dnaHash);
        }
      } catch (_) {}
    }
  }

  bool isClaimed(String avatarId) => _claimedRegistry.containsKey(avatarId);

  AvatarClaimRecord? getClaimRecord(String avatarId) =>
      _claimedRegistry[avatarId];

  List<AvatarProvenanceEvent> getProvenance(String avatarId,
      {String creator = 'Pocket Labs', String? dnaHash}) {
    final record = _claimedRegistry[avatarId];
    final hash = dnaHash ?? record?.dnaHash ?? '0xMATE-${avatarId.hashCode.abs() % 999999}';

    final List<AvatarProvenanceEvent> events = [
      AvatarProvenanceEvent(
        eventType: 'MINTED',
        from: 'Smart Contract Engine',
        to: creator,
        timestamp: DateTime.now().subtract(const Duration(days: 14)),
        txHash: '0xMINT-${hash.replaceAll('0x', '')}',
        note: 'Genesis 1-of-1 Minted on Pocket Mates Network',
      ),
    ];

    if (record != null) {
      events.add(
        AvatarProvenanceEvent(
          eventType: 'CLAIMED',
          from: creator,
          to: '@${record.username}',
          timestamp: record.claimedAt,
          txHash: '0xCLAIM-${record.dnaHash.replaceAll('0x', '')}',
          note: 'Verified 1-of-1 Ownership Established',
        ),
      );
      events.addAll(record.history);
    }

    return events;
  }

  Future<bool> claimAvatar({
    required String avatarId,
    required String userId,
    required String username,
    required String dnaHash,
    String creator = 'Pocket Labs',
  }) async {
    if (_claimedRegistry.containsKey(avatarId)) {
      return false; // Already claimed by another user!
    }

    final initialHistory = [
      AvatarProvenanceEvent(
        eventType: 'CLAIMED',
        from: creator,
        to: '@$username',
        timestamp: DateTime.now(),
        txHash: '0xCLAIM-${DateTime.now().millisecondsSinceEpoch % 1000000}',
        note: 'Initial 1-of-1 Claim',
      ),
    ];

    final record = AvatarClaimRecord(
      avatarId: avatarId,
      userId: userId,
      username: username,
      dnaHash: dnaHash,
      claimedAt: DateTime.now(),
      history: initialHistory,
    );

    _claimedRegistry[avatarId] = record;
    _usedDnaHashes.add(dnaHash);

    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(_claimedRegistry.values.map((v) => v.toMap()).toList());
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

  Future<bool> transferAvatar({
    required String avatarId,
    required String fromUserId,
    required String fromUsername,
    required String toUserId,
    required String toUsername,
  }) async {
    final existing = _claimedRegistry[avatarId];
    if (existing == null || existing.userId != fromUserId) {
      return false; // Not owned by fromUser
    }

    final transferEvent = AvatarProvenanceEvent(
      eventType: 'TRANSFERRED',
      from: '@$fromUsername',
      to: '@$toUsername',
      timestamp: DateTime.now(),
      txHash: '0xTX-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      note: 'Ownership Transferred on Pocket Mates Network',
    );

    final updatedHistory = List<AvatarProvenanceEvent>.from(existing.history)
      ..add(transferEvent);

    final updatedRecord = AvatarClaimRecord(
      avatarId: avatarId,
      userId: toUserId,
      username: toUsername,
      dnaHash: existing.dnaHash,
      claimedAt: existing.claimedAt,
      history: updatedHistory,
    );

    _claimedRegistry[avatarId] = updatedRecord;

    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(_claimedRegistry.values.map((v) => v.toMap()).toList());
    await prefs.setString('claimed_avatars_registry', encoded);

    return true;
  }

  /// Procedurally generates a batch of up to 500+ unique, never-before-seen 1-of-1 NFT avatars!
  List<NftItem> generateProceduralBoredApes({int count = 100}) {
    final rand = Random();
    final List<NftItem> results = [];

    final furs = ['brown', 'leopard', 'gold', 'cyber_grey', 'zombie_green', 'obsidian', 'trippy', 'pink_fur', 'crystal_blue'];
    final eyes = ['laser_beams', 'cyborg_red', '3d_glasses', 'vr_visor', 'x_eyes', 'sleepy', 'hologram', 'golden_glow'];
    final mouths = ['wide_grin', 'tongue_out', 'cigarette', 'pout', 'diamond_grill', 'vampire_fangs', 'bubblegum'];
    final headwears = ['none', 'sailor_hat', 'captain_hat', 'gold_crown', 'cyber_helmet', 'ninja_headband', 'beanie', 'halo'];
    final outfits = ['military_jacket', 'cyber_armor', 'naked', 'tuxedo', 'space_suit', 'hoodie', 'samurai_robe'];
    final bgs = ['orange', 'teal', 'cyan', 'purple', 'amber', 'dark', 'matrix_green', 'sunset_violet', 'ruby_red'];

    final collections = [
      'Bored Ape Yacht Club',
      'Cyberpunk 2099 Legends',
      'Anime Neon Knights',
      'Pixel Retro Champs',
      'Golden Monarchs 1-of-1',
    ];

    final artistNames = [
      'Rocky Rio',
      'Zoya Rex Studio',
      'Neon Apex',
      'Doodle Master',
      'Tokyo Synth',
      'Arcade Legend',
      'Celestial Arts',
      'Pocket Labs',
      'Apex Cybernetics',
      'Meta Dynasty',
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

      final collection = collections[rand.nextInt(collections.length)];
      final artist = artistNames[rand.nextInt(artistNames.length)];
      final number = rand.nextInt(9000) + 1000;
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
          title: '$collection #$number',
          collectionName: collection,
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
