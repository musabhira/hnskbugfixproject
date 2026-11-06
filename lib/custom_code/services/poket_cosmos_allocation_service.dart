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
      (301, 'Ocean Whisper Atoll', 'Earth Prime 🌍', 'Reefway Avenue'),
      (302, 'Haven Peninsula', 'Earth Prime 🌍', 'Highland Crest Road'),
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

  /// 🔍 Validates a Neighbor Pre-Booking Code
  Future<NeighborReservationPass?> validateNeighborInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    if (rawJson == null) return null;

    final Map<String, dynamic> store = jsonDecode(rawJson);
    if (!store.containsKey(cleanCode)) return null;

    final pass = NeighborReservationPass.fromJson(store[cleanCode]);

    // Check if 5-hour window has expired
    if (DateTime.now().isAfter(pass.expiresAt)) {
      store.remove(cleanCode);
      await prefs.setString(_kReservationsKey, jsonEncode(store));
      return null;
    }

    return pass;
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
