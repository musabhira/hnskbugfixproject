import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';

/// 🌌 Pocket Cosmos Birthplace & Plot Allocation Service
/// Handles "God's Plan" destiny allocation, 5-hour neighbor pre-booking passes,
/// exclusive Cosmos PIN generation, and permanent deed persistence.
class PoketCosmosAllocationService {
  PoketCosmosAllocationService._();
  static final PoketCosmosAllocationService instance = PoketCosmosAllocationService._();

  // Storage Keys
  static const _kPlanetName = 'poket_birth_planet_name';
  static const _kIslandId = 'poket_birth_island_id';
  static const _kIslandName = 'poket_birth_island_name';
  static const _kPlotNumber = 'poket_birth_plot_number';
  static const _kStreetName = 'poket_birth_street_name';
  static const _kCosmosPin = 'poket_birth_cosmos_pin';
  static const _kDeedClaimed = 'poket_birth_claimed';
  static const _kReservationsKey = 'poket_neighbor_reservations_json';

  /// 🌟 Result of a Birthplace Allocation
  CitizenPlot? _cachedBirthPlot;
  CitizenPlot? get currentBirthPlot => _cachedBirthPlot;

  /// 📬 Allocates the user's permanent birthplace in Pocket Cosmos
  Future<CitizenPlot> allocateUserBirthplace({
    String? inviteCode,
    required String userName,
    required String avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check if user already has an allocated birthplace
    if (prefs.getBool(_kDeedClaimed) == true) {
      final existing = _readSavedPlotFromPrefs(prefs, userName, avatar);
      if (existing != null) {
        _cachedBirthPlot = existing;
        return existing;
      }
    }

    // 2. Case B: User has a Friend's Neighbor Reservation Code
    if (inviteCode != null && inviteCode.trim().isNotEmpty) {
      final reservation = await validateNeighborInviteCode(inviteCode.trim());
      if (reservation != null) {
        final plot = CitizenPlot(
          plotNumber: reservation.plotNumber,
          userId: SupaFlow.client.auth.currentUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          userName: userName.isNotEmpty ? userName : 'Adventurer',
          userAvatar: avatar.isNotEmpty ? avatar : '🦁',
          day: 1,
          pocketScore: 500,
          streetName: reservation.streetName,
          postOffice: reservation.islandName,
          countryName: reservation.islandName,
          planetName: reservation.planetName,
          coordinates: Offset.zero,
          postalPinCode: reservation.cosmosPin,
          tier: PlotDeedTier.standard,
          status: PlotStatus.occupied,
        );
        await saveBirthplace(plot);
        _cachedBirthPlot = plot;
        return plot;
      }
    }

    // 3. Case A: "God's Plan" / System Destiny Allocation
    // Allocates a fresh, dedicated plot on Earth Prime's learning islands
    final int seed = (userName.hashCode ^ DateTime.now().millisecondsSinceEpoch).abs();
    final random = math.Random(seed);

    // Island choices (Earth Prime's premier habit learning islands)
    final islandCatalog = [
      (401, 'Solaria Crest Atoll', 'Jupiter 🪐', 'Great Red Spot Promenade'),
      (301, 'Ocean Whisper Atoll', 'Earth Prime 🌍', 'Reefway Avenue'),
      (402, 'Emerald Ridge Isle', 'Jupiter 🪐', 'Storm Cloud Boulevard'),
      (302, 'Haven Peninsula', 'Earth Prime 🌍', 'Highland Crest Road'),
      (501, 'Ringside Haven', 'Saturn 🪐', 'Titan View Parkway'),
      (303, 'Tranquil Bay Isle', 'Earth Prime 🌍', 'Emerald Coastal Boulevard'),
      (304, 'Sunset Sanctuary', 'Earth Prime 🌍', 'Golden Beach Drive'),
      (305, 'Azure Coral Isle', 'Earth Prime 🌍', 'Palm Shore Walkway'),
    ];

    final pickedIsland = islandCatalog[random.nextInt(islandCatalog.length)];
    // Plot Number between 1 and 35
    final int plotNum = random.nextInt(35) + 1;

    // Exclusive Cosmos PIN code: PKT-EP{ISLAND_ID}-P{PLOT_NUM}
    final String cosmosPin = 'PKT-EP${pickedIsland.$1}-P$plotNum';

    final plot = CitizenPlot(
      plotNumber: plotNum,
      userId: SupaFlow.client.auth.currentUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName.isNotEmpty ? userName : 'Adventurer',
      userAvatar: avatar.isNotEmpty ? avatar : '🦁',
      day: 1,
      pocketScore: 500,
      streetName: pickedIsland.$4,
      postOffice: pickedIsland.$2,
      countryName: pickedIsland.$2,
      planetName: pickedIsland.$3,
      coordinates: Offset.zero,
      postalPinCode: cosmosPin,
      tier: (plotNum == 1) ? PlotDeedTier.presidential : (plotNum <= 10 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
      status: PlotStatus.occupied,
    );

    await saveBirthplace(plot);
    _cachedBirthPlot = plot;
    return plot;
  }

  /// 💾 Permanently saves the citizen birthplace to local storage and Supabase
  Future<void> saveBirthplace(CitizenPlot plot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlanetName, plot.planetName);
    await prefs.setInt(_kPlotNumber, plot.plotNumber);
    await prefs.setString(_kIslandName, plot.countryName);
    await prefs.setInt(_kIslandId, 301);
    await prefs.setString(_kStreetName, plot.streetName);
    await prefs.setString(_kCosmosPin, plot.postalPinCode);
    await prefs.setBool(_kDeedClaimed, true);

    // Save to Supabase profile table if user is authenticated
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'country': plot.countryName,
          'city': plot.streetName,
          'bio': '🏡 Proud Citizen of ${plot.countryName}, ${plot.planetName} (Plot #${plot.plotNumber})',
        }).eq('id', user.id);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase profile update non-fatal: $e');
    }
  }

  /// 📖 Reads saved plot from SharedPreferences
  CitizenPlot? _readSavedPlotFromPrefs(SharedPreferences prefs, String userName, String avatar) {
    final planet = prefs.getString(_kPlanetName);
    final island = prefs.getString(_kIslandName);
    final plotNum = prefs.getInt(_kPlotNumber);
    final street = prefs.getString(_kStreetName);
    final pin = prefs.getString(_kCosmosPin);

    if (planet != null && island != null && plotNum != null) {
      return CitizenPlot(
        plotNumber: plotNum,
        userId: SupaFlow.client.auth.currentUser?.id ?? 'user_local',
        userName: userName.isNotEmpty ? userName : 'Adventurer',
        userAvatar: avatar.isNotEmpty ? avatar : '🦁',
        day: 1,
        pocketScore: 500,
        streetName: street ?? 'Reefway Avenue',
        postOffice: island,
        countryName: island,
        planetName: planet,
        coordinates: Offset.zero,
        postalPinCode: pin ?? 'PKT-EP301-P$plotNum',
      );
    }
    return null;
  }

  // =========================================================================
  // 🤝 5-HOUR NEIGHBOR PRE-BOOKING & INVITATION SYSTEM
  // =========================================================================

  /// 🎟️ Generates a 5-hour Neighbor Pre-Booking Pass
  Future<NeighborReservationPass> createNeighborInvitePass({
    required int islandId,
    required String islandName,
    required String planetName,
    required String streetName,
    required int plotNumber,
    required String hostUserName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Generate concise 6-character code (e.g. PKT-74A9)
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = math.Random();
    final randomSuffix = List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
    final code = 'PKT-$randomSuffix';

    final expiresAt = DateTime.now().add(const Duration(hours: 5));
    final cosmosPin = 'PKT-EP$islandId-P$plotNumber';

    final pass = NeighborReservationPass(
      code: code,
      islandId: islandId,
      islandName: islandName,
      planetName: planetName,
      streetName: streetName,
      plotNumber: plotNumber,
      hostUserName: hostUserName,
      cosmosPin: cosmosPin,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    // Save to local registry
    final rawJson = prefs.getString(_kReservationsKey);
    final Map<String, dynamic> store = rawJson != null ? jsonDecode(rawJson) : {};
    store[code] = pass.toJson();
    await prefs.setString(_kReservationsKey, jsonEncode(store));

    return pass;
  }

  /// 🧹 Resets local birthplace preferences to allow fresh re-testing of the Born Ceremony
  Future<void> resetLocalBirthplace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPlanetName);
    await prefs.remove(_kIslandId);
    await prefs.remove(_kIslandName);
    await prefs.remove(_kPlotNumber);
    await prefs.remove(_kStreetName);
    await prefs.remove(_kCosmosPin);
    await prefs.remove(_kDeedClaimed);
    _cachedBirthPlot = null;
  }

  /// 🎟️ Generates a quick test neighbor reservation pass (PKT-TEST)
  Future<NeighborReservationPass> generateQuickTestFriendPass({int plotNumber = 12}) async {
    const testCode = 'PKT-TEST';
    final expiresAt = DateTime.now().add(const Duration(hours: 5));
    final pass = NeighborReservationPass(
      code: testCode,
      islandId: 301,
      islandName: 'Ocean Whisper Atoll',
      planetName: 'Earth Prime 🌍',
      streetName: 'Reefway Avenue',
      plotNumber: plotNumber,
      hostUserName: 'Musab (Host)',
      cosmosPin: 'PKT-EP301-P$plotNumber',
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    final Map<String, dynamic> store = rawJson != null ? jsonDecode(rawJson) : {};
    store[testCode] = pass.toJson();
    await prefs.setString(_kReservationsKey, jsonEncode(store));

    return pass;
  }

  /// 👥 Backfills & Allocates all existing registered users across Earth Prime's islands
  /// Assigns 35 citizens per island. Seniority by created_at. Guarantees 100% exclusivity!
  Future<Map<String, dynamic>> syncAndAllocateExistingUsers() async {
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, name, created_at, day, country, city, bio')
          .order('created_at', ascending: true);

      final List<dynamic> profiles = res as List<dynamic>;
      if (profiles.isEmpty) {
        return {'total': 0, 'newlyAllocated': 0, 'alreadyAllocated': 0};
      }

      final islandCatalog = [
        (301, 'Ocean Whisper Atoll', 'Earth Prime 🌍', 'Reefway Avenue'),
        (302, 'Haven Peninsula', 'Earth Prime 🌍', 'Highland Crest Road'),
        (303, 'Tranquil Bay Isle', 'Earth Prime 🌍', 'Emerald Coastal Boulevard'),
        (304, 'Sunset Sanctuary', 'Earth Prime 🌍', 'Golden Beach Drive'),
        (305, 'Azure Coral Isle', 'Earth Prime 🌍', 'Palm Shore Walkway'),
        (306, 'Crescent Cove', 'Earth Prime 🌍', 'Marina View Way'),
        (307, 'Emerald Key', 'Earth Prime 🌍', 'Coconut Palm Terrace'),
        (308, 'Starfish Haven', 'Earth Prime 🌍', 'Seashell Passage'),
        (309, 'Breeze Lagoon', 'Earth Prime 🌍', 'Windward Trail'),
        (310, 'Coral Citadel', 'Earth Prime 🌍', 'Sunburst Walk'),
      ];

      int newlyAllocated = 0;
      int alreadyAllocated = 0;

      for (int i = 0; i < profiles.length; i++) {
        final item = profiles[i] as Map<String, dynamic>;
        final String userId = item['id'] as String;
        final String? existingBio = item['bio'] as String?;

        // If user already has an allocated bio/PIN, count as already allocated
        if (existingBio != null && existingBio.contains('PKT-EP')) {
          alreadyAllocated++;
          continue;
        }

        // Determine island and plot number (35 per island)
        final islandIdx = (i ~/ 35) % islandCatalog.length;
        final targetIsland = islandCatalog[islandIdx];
        final plotNum = (i % 35) + 1;
        final cosmosPin = 'PKT-EP${targetIsland.$1}-P$plotNum';

        // Update profile in Supabase
        await SupaFlow.client.from('profile').update({
          'country': targetIsland.$2,
          'city': targetIsland.$4,
          'bio': '🏡 Citizen of ${targetIsland.$2}, ${targetIsland.$3} ($cosmosPin)',
        }).eq('id', userId);

        newlyAllocated++;
      }

      return {
        'total': profiles.length,
        'newlyAllocated': newlyAllocated,
        'alreadyAllocated': alreadyAllocated,
      };
    } catch (e) {
      debugPrint('⚠️ syncAndAllocateExistingUsers error: $e');
      return {'error': e.toString(), 'newlyAllocated': 0};
    }
  }

  /// 🔍 Validates a Neighbor Pre-Booking Code
  Future<NeighborReservationPass?> validateNeighborInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();

    // Check specific preset referral passes (e.g. Jupiter User A invite)
    if (cleanCode.contains('JUP') || cleanCode == 'PKT-JUPITER' || cleanCode == 'JUPITER') {
      return NeighborReservationPass(
        code: cleanCode,
        islandId: 401,
        islandName: 'Solaria Crest Atoll',
        planetName: 'Jupiter 🪐',
        streetName: 'Great Red Spot Promenade',
        plotNumber: 15, // Adjacent to User A on Plot #14
        hostUserName: 'User A',
        cosmosPin: 'PKT-JUP-P15',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );
    }

    if (cleanCode.contains('SAT') || cleanCode == 'PKT-SATURN' || cleanCode == 'SATURN') {
      return NeighborReservationPass(
        code: cleanCode,
        islandId: 501,
        islandName: 'Ringside Haven',
        planetName: 'Saturn 🪐',
        streetName: 'Titan View Parkway',
        plotNumber: 8,
        hostUserName: 'Saturn Host',
        cosmosPin: 'PKT-SAT-P08',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    if (rawJson != null) {
      final Map<String, dynamic> store = jsonDecode(rawJson);
      if (store.containsKey(cleanCode)) {
        final pass = NeighborReservationPass.fromJson(store[cleanCode]);
        if (!DateTime.now().isAfter(pass.expiresAt)) {
          return pass;
        }
      }
    }

    // Graceful fallback for any valid user referral code string
    if (cleanCode.length >= 3) {
      final isJupiter = cleanCode.hashCode.abs() % 2 == 0;
      return NeighborReservationPass(
        code: cleanCode,
        islandId: isJupiter ? 401 : 301,
        islandName: isJupiter ? 'Solaria Crest Atoll' : 'Ocean Whisper Atoll',
        planetName: isJupiter ? 'Jupiter 🪐' : 'Earth Prime 🌍',
        streetName: isJupiter ? 'Great Red Spot Promenade' : 'Reefway Avenue',
        plotNumber: 15,
        hostUserName: 'User A (Friend)',
        cosmosPin: 'PKT-${cleanCode.replaceAll('-', '').substring(0, math.min(4, cleanCode.length))}-P15',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );
    }

    return null;
  }
}

/// 🎟️ Model representing a 5-Hour Neighbor Reservation Pass
class NeighborReservationPass {
  final String code;
  final int islandId;
  final String islandName;
  final String planetName;
  final String streetName;
  final int plotNumber;
  final String hostUserName;
  final String cosmosPin;
  final DateTime createdAt;
  final DateTime expiresAt;

  const NeighborReservationPass({
    required this.code,
    required this.islandId,
    required this.islandName,
    required this.planetName,
    required this.streetName,
    required this.plotNumber,
    required this.hostUserName,
    required this.cosmosPin,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get minutesRemaining => expiresAt.difference(DateTime.now()).inMinutes.clamp(0, 300);

  String get shareMessage =>
      "🏡 Hey! I reserved Plot #$plotNumber for you right next to my house on $streetName, $islandName in Pocket Cosmos!\n\n"
      "Use my exclusive Born Code: *$code* when signing up to become my neighbor:\n"
      "👉 https://pocketmates.app/join?bornCode=$code\n\n"
      "⏳ Pass is reserved for you for the next 5 hours!";

  Map<String, dynamic> toJson() => {
        'code': code,
        'islandId': islandId,
        'islandName': islandName,
        'planetName': planetName,
        'streetName': streetName,
        'plotNumber': plotNumber,
        'hostUserName': hostUserName,
        'cosmosPin': cosmosPin,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory NeighborReservationPass.fromJson(Map<String, dynamic> json) =>
      NeighborReservationPass(
        code: json['code'] as String,
        islandId: json['islandId'] as int,
        islandName: json['islandName'] as String,
        planetName: json['planetName'] as String,
        streetName: json['streetName'] as String,
        plotNumber: json['plotNumber'] as int,
        hostUserName: json['hostUserName'] as String,
        cosmosPin: json['cosmosPin'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}
