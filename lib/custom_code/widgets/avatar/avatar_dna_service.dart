import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'avatar_dna_model.dart';
import 'vector_avatar_config.dart';

/// Core Service managing the Pocket Mates Avatar DNA & 1-of-1 Collectible Ownership Engine
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final supabase = SupaFlow.client;

  /// Generates a standardized, deterministic Avatar DNA string based on selected components
  /// Example format: "SK12-FC04-EY07-EB03-HR45-BD01-OT93-SH15-AC11-BG08"
  String generateAvatarDNA(AvatarComponents components) {
    final cleanSkin = _normalizeCode('SK', components.skinId);
    final cleanFace = _normalizeCode('FC', components.faceId);
    final cleanEyes = _normalizeCode('EY', components.eyesId);
    final cleanEyebrows = _normalizeCode('EB', components.eyebrowsId);
    final cleanHair = _normalizeCode('HR', components.hairId);
    final cleanBeard = _normalizeCode('BD', components.beardId);
    final cleanOutfit = _normalizeCode('OT', components.outfitId);
    final cleanShoes = _normalizeCode('SH', components.shoesId);
    final cleanAccessory = _normalizeCode('AC', components.accessoryId);
    final cleanBg = _normalizeCode('BG', components.backgroundId);

    return '$cleanSkin-$cleanFace-$cleanEyes-$cleanEyebrows-$cleanHair-$cleanBeard-$cleanOutfit-$cleanShoes-$cleanAccessory-$cleanBg';
  }

  String _normalizeCode(String prefix, String val) {
    if (val.toUpperCase().startsWith(prefix)) {
      return val.toUpperCase();
    }
    // Hash string into a deterministic 2-digit number if given as descriptive name
    final hashNum = (val.hashCode.abs() % 99) + 1;
    final numStr = hashNum.toString().padLeft(2, '0');
    return '$prefix$numStr';
  }

  /// Calculates deterministic collectible rarity based on component traits & species
  String calculateRarity(AvatarComponents components) {
    final seed = '${components.skinId}_${components.hairId}_${components.outfitId}_${components.accessoryId}_${components.species}';
    final score = seed.hashCode.abs() % 100;

    if (score >= 95) return 'Mythic 1-of-1';
    if (score >= 82) return 'Legendary';
    if (score >= 60) return 'Epic';
    if (score >= 30) return 'Rare';
    return 'Original';
  }

  /// Checks whether a given DNA string is completely unique and available for claim
  Future<bool> checkDNAAvailability(String dna) async {
    try {
      final res = await supabase
          .from('avatars')
          .select('id, dna')
          .eq('dna', dna)
          .maybeSingle();

      return res == null;
    } catch (e) {
      debugPrint('AvatarService.checkDNAAvailability error: $e');
      // Fallback check against local cache
      final prefs = await SharedPreferences.getInstance();
      final claimedList = prefs.getStringList('claimed_dna_hashes') ?? [];
      return !claimedList.contains(dna);
    }
  }

  /// Creates an un-minted, previewable AvatarModel instance with generated DNA and metadata
  AvatarModel createAvatar({
    required String userId,
    required AvatarComponents components,
    Map<String, dynamic>? configJson,
    String? customId,
  }) {
    final dna = generateAvatarDNA(components);
    final rarity = calculateRarity(components);
    final serial = (dna.hashCode.abs() % 900000) + 100000;
    final avatarId = customId ?? 'Avatar #$serial';
    final now = DateTime.now();

    final genesisEvent = AvatarHistoryEvent(
      event: 'MINTED',
      fromOwner: 'Pocket Labs Genesis Factory',
      toOwner: userId.isNotEmpty ? userId : 'Pending Owner',
      timestamp: now,
      txHash: '0xDNA-${dna.hashCode.abs().toRadixString(16).toUpperCase()}',
      note: 'Unique 1-of-1 Genesis Identity Formed',
    );

    return AvatarModel(
      id: avatarId,
      ownerId: userId,
      dna: dna,
      components: components,
      rarity: rarity,
      status: 'active',
      configJson: configJson ?? {},
      history: [genesisEvent],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Claims an avatar permanently for the user, locking the DNA and archiving any previous active avatar
  Future<AvatarClaimResult> claimAvatar({
    required String userId,
    required AvatarModel avatar,
    String? username,
  }) async {
    try {
      // 1. Double check DNA uniqueness constraint
      final isAvailable = await checkDNAAvailability(avatar.dna);
      if (!isAvailable) {
        return AvatarClaimResult(
          success: false,
          errorMessage: 'This Avatar DNA (${avatar.dna}) has already been claimed by another user!',
        );
      }

      final now = DateTime.now();

      // 2. Archive previous active avatars for this user so only 1 remains active
      try {
        await supabase
            .from('avatars')
            .update({
              'status': 'archived',
              'updated_at': now.toIso8601String(),
            })
            .eq('owner_id', userId)
            .eq('status', 'active');
      } catch (_) {}

      // 3. Create claim event in provenance history
      final claimEvent = AvatarHistoryEvent(
        event: 'CLAIMED',
        fromOwner: 'Pocket Labs Factory',
        toOwner: username != null ? '@$username' : userId,
        timestamp: now,
        txHash: '0xCLM-${now.millisecondsSinceEpoch % 1000000}',
        note: 'Exclusive 1-of-1 Ownership Established',
      );

      final updatedHistory = List<AvatarHistoryEvent>.from(avatar.history)..add(claimEvent);

      final claimedAvatar = avatar.copyWith(
        ownerId: userId,
        status: 'active',
        history: updatedHistory,
        updatedAt: now,
      );

      // 4. Save to Supabase 'avatars' table
      await supabase.from('avatars').upsert(claimedAvatar.toMap());

      // 5. Update profile table's avatar_config (without touching profile_image_url)
      await supabase.from('profile').update({
        'avatar_config': claimedAvatar.configJson.isNotEmpty
            ? claimedAvatar.configJson
            : claimedAvatar.components.toMap(),
        'claimed_avatar_id': claimedAvatar.id,
        'avatar_dna': claimedAvatar.dna,
        'updated_at': now.toIso8601String(),
      }).eq('user_id', userId);

      // 6. Cache locally in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_avatar_$userId', claimedAvatar.toJson());
      
      final claimedList = prefs.getStringList('claimed_dna_hashes') ?? [];
      if (!claimedList.contains(claimedAvatar.dna)) {
        claimedList.add(claimedAvatar.dna);
        await prefs.setStringList('claimed_dna_hashes', claimedList);
      }

      return AvatarClaimResult(
        success: true,
        avatar: claimedAvatar,
      );
    } catch (e) {
      debugPrint('AvatarService.claimAvatar error: $e');
      return AvatarClaimResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Seamlessly changes/upgrades the user's avatar to a new configuration
  /// The previous avatar remains permanently archived in history and owned by user
  Future<AvatarClaimResult> changeAvatar({
    required String userId,
    required AvatarComponents newComponents,
    Map<String, dynamic>? configJson,
    String? username,
  }) async {
    final newAvatar = createAvatar(
      userId: userId,
      components: newComponents,
      configJson: configJson,
    );

    return claimAvatar(
      userId: userId,
      avatar: newAvatar,
      username: username,
    );
  }

  /// Fetches the currently active AvatarModel for the given user
  Future<AvatarModel?> getUserAvatar(String userId) async {
    try {
      final res = await supabase
          .from('avatars')
          .select()
          .eq('owner_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null) {
        return AvatarModel.fromMap(Map<String, dynamic>.from(res));
      }

      // Check local cache fallback
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('active_avatar_$userId');
      if (cached != null) {
        return AvatarModel.fromJson(cached);
      }
    } catch (e) {
      debugPrint('AvatarService.getUserAvatar error: $e');
    }
    return null;
  }

  /// Fetches all historical avatars ever owned or created by this user
  Future<List<AvatarModel>> getAvatarHistory(String userId) async {
    try {
      final res = await supabase
          .from('avatars')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final List list = res as List;
      return list
          .map((item) => AvatarModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('AvatarService.getAvatarHistory error: $e');
    }
    return [];
  }

  /// Look up an avatar by its unique DNA string
  Future<AvatarModel?> getAvatarByDNA(String dna) async {
    try {
      final res = await supabase
          .from('avatars')
          .select()
          .eq('dna', dna)
          .maybeSingle();

      if (res != null) {
        return AvatarModel.fromMap(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      debugPrint('AvatarService.getAvatarByDNA error: $e');
    }
    return null;
  }

  /// Utility converter from VectorAvatarConfig to AvatarComponents & AvatarModel
  AvatarComponents fromVectorConfig(VectorAvatarConfig config) {
    return AvatarComponents(
      skinId: 'SK_${config.skinColor.replaceAll('#', '')}',
      faceId: 'FC_${config.faceShape}',
      eyesId: 'EY_${config.eyeStyle}_${config.eyeColor.replaceAll('#', '')}',
      eyebrowsId: 'EB_${config.eyebrowStyle}',
      hairId: 'HR_${config.hairStyle}_${config.hairColor.replaceAll('#', '')}',
      beardId: 'BD_${config.beardStyle}',
      outfitId: 'OT_${config.outfitStyle}_${config.outfitColor.replaceAll('#', '')}',
      shoesId: 'SH_classic',
      accessoryId: 'AC_${config.accessory}',
      backgroundId: 'BG_${config.auraStyle}',
      artStyle: config.artStyle,
      species: config.species,
      gender: config.gender,
    );
  }
}

class AvatarClaimResult {
  final bool success;
  final AvatarModel? avatar;
  final String? errorMessage;

  AvatarClaimResult({
    required this.success,
    this.avatar,
    this.errorMessage,
  });
}
