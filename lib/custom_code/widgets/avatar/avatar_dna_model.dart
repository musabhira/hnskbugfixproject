import 'dart:convert';

/// Component specifications defining the visual and genetic DNA traits of an avatar
class AvatarComponents {
  final String skinId;
  final String faceId;
  final String eyesId;
  final String eyebrowsId;
  final String hairId;
  final String beardId;
  final String outfitId;
  final String shoesId;
  final String accessoryId;
  final String backgroundId;

  // Extensibility metadata
  final String artStyle; // 'vector', 'doodle', 'pixel', 'cyberpunk', 'bayc', 'network'
  final String species; // 'human', 'cyber_fox', 'bored_ape', etc.
  final String gender;

  const AvatarComponents({
    this.skinId = 'SK01',
    this.faceId = 'FC01',
    this.eyesId = 'EY01',
    this.eyebrowsId = 'EB01',
    this.hairId = 'HR01',
    this.beardId = 'BD00',
    this.outfitId = 'OT01',
    this.shoesId = 'SH01',
    this.accessoryId = 'AC00',
    this.backgroundId = 'BG01',
    this.artStyle = 'vector',
    this.species = 'human',
    this.gender = 'male',
  });

  Map<String, dynamic> toMap() => {
        'skin_id': skinId,
        'face_id': faceId,
        'eyes_id': eyesId,
        'eyebrows_id': eyebrowsId,
        'hair_id': hairId,
        'beard_id': beardId,
        'outfit_id': outfitId,
        'shoes_id': shoesId,
        'accessory_id': accessoryId,
        'background_id': backgroundId,
        'art_style': artStyle,
        'species': species,
        'gender': gender,
      };

  factory AvatarComponents.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AvatarComponents();
    return AvatarComponents(
      skinId: map['skin_id'] ?? map['skinId'] ?? 'SK01',
      faceId: map['face_id'] ?? map['faceId'] ?? 'FC01',
      eyesId: map['eyes_id'] ?? map['eyesId'] ?? 'EY01',
      eyebrowsId: map['eyebrows_id'] ?? map['eyebrowsId'] ?? 'EB01',
      hairId: map['hair_id'] ?? map['hairId'] ?? 'HR01',
      beardId: map['beard_id'] ?? map['beardId'] ?? 'BD00',
      outfitId: map['outfit_id'] ?? map['outfitId'] ?? 'OT01',
      shoesId: map['shoes_id'] ?? map['shoesId'] ?? 'SH01',
      accessoryId: map['accessory_id'] ?? map['accessoryId'] ?? 'AC00',
      backgroundId: map['background_id'] ?? map['backgroundId'] ?? 'BG01',
      artStyle: map['art_style'] ?? map['artStyle'] ?? 'vector',
      species: map['species'] ?? 'human',
      gender: map['gender'] ?? 'male',
    );
  }

  AvatarComponents copyWith({
    String? skinId,
    String? faceId,
    String? eyesId,
    String? eyebrowsId,
    String? hairId,
    String? beardId,
    String? outfitId,
    String? shoesId,
    String? accessoryId,
    String? backgroundId,
    String? artStyle,
    String? species,
    String? gender,
  }) {
    return AvatarComponents(
      skinId: skinId ?? this.skinId,
      faceId: faceId ?? this.faceId,
      eyesId: eyesId ?? this.eyesId,
      eyebrowsId: eyebrowsId ?? this.eyebrowsId,
      hairId: hairId ?? this.hairId,
      beardId: beardId ?? this.beardId,
      outfitId: outfitId ?? this.outfitId,
      shoesId: shoesId ?? this.shoesId,
      accessoryId: accessoryId ?? this.accessoryId,
      backgroundId: backgroundId ?? this.backgroundId,
      artStyle: artStyle ?? this.artStyle,
      species: species ?? this.species,
      gender: gender ?? this.gender,
    );
  }
}

/// Provenance / Audit Event recording the complete ownership lifecycle of an Avatar
class AvatarHistoryEvent {
  final String event; // 'MINTED' | 'CLAIMED' | 'EQUIPPED' | 'ARCHIVED' | 'TRANSFERRED'
  final String fromOwner;
  final String toOwner;
  final DateTime timestamp;
  final String txHash;
  final String? note;

  AvatarHistoryEvent({
    required this.event,
    required this.fromOwner,
    required this.toOwner,
    required this.timestamp,
    required this.txHash,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'event': event,
        'from_owner': fromOwner,
        'to_owner': toOwner,
        'timestamp': timestamp.toIso8601String(),
        'tx_hash': txHash,
        'note': note,
      };

  factory AvatarHistoryEvent.fromMap(Map<String, dynamic> map) =>
      AvatarHistoryEvent(
        event: map['event'] ?? 'MINTED',
        fromOwner: map['from_owner'] ?? 'Pocket Labs Core Engine',
        toOwner: map['to_owner'] ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        txHash: map['tx_hash'] ?? '0xGENESIS',
        note: map['note'],
      );
}

/// Scalable Core Avatar Model representing a 1-of-1 Unique Identity in Pocket Mates
class AvatarModel {
  final String id; // e.g. 'Avatar #928173' or 'PM-849201'
  final String ownerId; // User UID
  final String dna; // e.g. 'SK12-FC04-EY07-EB03-HR45-BD01-OT93-SH15-AC11-BG08'
  final AvatarComponents components;
  final String rarity; // 'Common' | 'Rare' | 'Epic' | 'Legendary' | 'Mythic 1-of-1'
  final String status; // 'active' | 'archived' | 'transferred'
  final Map<String, dynamic> configJson;
  final List<AvatarHistoryEvent> history;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AvatarModel({
    required this.id,
    required this.ownerId,
    required this.dna,
    required this.components,
    this.rarity = 'Original',
    this.status = 'active',
    this.configJson = const {},
    this.history = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isArchived => status == 'archived';

  Map<String, dynamic> toMap() => {
        'id': id,
        'owner_id': ownerId,
        'dna': dna,
        'skin_id': components.skinId,
        'face_id': components.faceId,
        'eyes_id': components.eyesId,
        'eyebrows_id': components.eyebrowsId,
        'hair_id': components.hairId,
        'beard_id': components.beardId,
        'outfit_id': components.outfitId,
        'shoes_id': components.shoesId,
        'accessory_id': components.accessoryId,
        'background_id': components.backgroundId,
        'rarity': rarity,
        'status': status,
        'config_json': configJson,
        'history': history.map((e) => e.toMap()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory AvatarModel.fromMap(Map<String, dynamic> map) {
    final rawHist = map['history'] as List? ?? [];
    return AvatarModel(
      id: map['id']?.toString() ?? '',
      ownerId: map['owner_id']?.toString() ?? '',
      dna: map['dna']?.toString() ?? '',
      components: AvatarComponents.fromMap(
        map['components'] is Map
            ? Map<String, dynamic>.from(map['components'])
            : map,
      ),
      rarity: map['rarity']?.toString() ?? 'Original',
      status: map['status']?.toString() ?? 'active',
      configJson: map['config_json'] is Map
          ? Map<String, dynamic>.from(map['config_json'])
          : {},
      history: rawHist
          .map((e) => AvatarHistoryEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory AvatarModel.fromJson(String str) => AvatarModel.fromMap(jsonDecode(str));

  AvatarModel copyWith({
    String? id,
    String? ownerId,
    String? dna,
    AvatarComponents? components,
    String? rarity,
    String? status,
    Map<String, dynamic>? configJson,
    List<AvatarHistoryEvent>? history,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvatarModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      dna: dna ?? this.dna,
      components: components ?? this.components,
      rarity: rarity ?? this.rarity,
      status: status ?? this.status,
      configJson: configJson ?? this.configJson,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
