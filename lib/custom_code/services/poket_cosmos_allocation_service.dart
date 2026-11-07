import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';

/// 🪐 Definition of a Permanent Celestial Colony in Pocket Cosmos
class CelestialColonyInfo {
  final int planetId;
  final String planetName;
  final String code; // 'EP', 'MAR', 'JUP', 'SAT', 'LUN', 'EUR', 'VEN', 'TTN', 'PLT', 'NEP'
  final String islandName;
  final String streetName;
  final Color landColor;
  final Color waterColor;
  final String climate;
  final IslandShapeStyle shapeStyle;

  const CelestialColonyInfo({
    required this.planetId,
    required this.planetName,
    required this.code,
    required this.islandName,
    required this.streetName,
    required this.landColor,
    required this.waterColor,
    required this.climate,
    required this.shapeStyle,
  });
}

/// 🌌 Pocket Cosmos Birthplace & 100-Crore Citizen Wave Allocation Engine
/// Features:
/// - 10 Permanent Celestial Bodies (Earth, Mars, Jupiter, Saturn, Moon, Europa, Venus, Titan, Pluto, Neptune)
/// - 18 Exclusive Citizen Plots per Island (Plot #1 to #18)
/// - 180 Citizens per Wave (10 Planets x 18 Plots)
/// - Balanced Random Distribution to avoid clustering
/// - "HOUSE FULL!" event trigger auto-advancing to Wave W_(k+1)
/// - Immutable Unique Born Address: PKT-W{Wave}-{PlanetCode}-I{IslandNum}-P{PlotNum}
/// - 5-Hour Neighbor Pre-booking Pass & Direct Referral Gateway routing
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

  // 100-Crore Wave Engine Keys
  static const _kActiveWaveIndexKey = 'poket_cosmos_active_wave_index';
  static const _kWaveOccupancyCountPrefix = 'poket_cosmos_wave_occ_count_';
  static const _kPlanetOccupiedPlotsPrefix = 'poket_cosmos_planet_occ_plots_';

  // Scaling Constants (20 plots per island, 200 citizens per wave across 10 planets)
  static const int maxPlotsPerIsland = 20;
  static const int totalPlanetsCount = 10;
  static const int waveCapacity = 200; // 10 planets * 20 plots

  /// 🏷️ Algorithmic Infinite Island Naming Loop Engine
  /// Generates endless unique celestial island titles across infinite waves
  static String generateInfiniteIslandName(String planetCode, int wave, int islandNum) {
    const prefixes = [
      'Solaria', 'Ares', 'Aethel', 'Kronos', 'Cygnus', 'Elysium', 'Hyperion',
      'Boreas', 'Zenith', 'Meridian', 'Lumina', 'Astraea', 'Vesper', 'Orion',
      'Novalis', 'Helios', 'Celestia', 'Vanguard', 'Aurora', 'Atlas',
    ];
    const suffixes = [
      'Crest Atoll', 'Crater Haven', 'Sanctuary Bay', 'Ridge Peninsula',
      'Archipelago', 'Plateau Outpost', 'Reef Shore', 'Lagoon Sound',
      'Haven Isle', 'Apex Citadel', 'Deep Reach', 'Tranquil Cove',
    ];
    final pIdx = ((wave - 1) * 7 + (islandNum - 1) * 3 + planetCode.hashCode.abs()) % prefixes.length;
    final sIdx = ((wave - 1) * 11 + (islandNum - 1) * 5 + (planetCode.hashCode.abs() ~/ 7)) % suffixes.length;
    return '${prefixes[pIdx]} ${suffixes[sIdx]}';
  }

  // 🪐 10 Permanent Celestial Colonies Catalog
  static const List<CelestialColonyInfo> colonies = [
    CelestialColonyInfo(
      planetId: 3,
      planetName: 'Earth Prime 🌍',
      code: 'EP',
      islandName: 'Ocean Whisper Atoll',
      streetName: 'Reefway Avenue',
      landColor: Color(0xFF16A34A),
      waterColor: Color(0xFF0284C7),
      climate: 'Tropical Azure Breeze 🌊',
      shapeStyle: IslandShapeStyle.ringAtoll,
    ),
    CelestialColonyInfo(
      planetId: 4,
      planetName: 'Mars 🔴',
      code: 'MAR',
      islandName: 'Ares Crater Haven',
      streetName: 'Olympus Ridge Trail',
      landColor: Color(0xFFDC2626),
      waterColor: Color(0xFF7C2D12),
      climate: 'Crimson Rust Oasis 🔴',
      shapeStyle: IslandShapeStyle.fortressPlateau,
    ),
    CelestialColonyInfo(
      planetId: 5,
      planetName: 'Jupiter 🪐',
      code: 'JUP',
      islandName: 'Solaria Crest Atoll',
      streetName: 'Great Red Spot Promenade',
      landColor: Color(0xFF059669),
      waterColor: Color(0xFF0369A1),
      climate: 'Stormy Cosmic Azure 🪐',
      shapeStyle: IslandShapeStyle.crescentLagoon,
    ),
    CelestialColonyInfo(
      planetId: 6,
      planetName: 'Saturn 🪐',
      code: 'SAT',
      islandName: 'Ringside Haven',
      streetName: 'Titan View Parkway',
      landColor: Color(0xFFD97706),
      waterColor: Color(0xFF92400E),
      climate: 'Golden Amber Ring Sanctuary 🪐',
      shapeStyle: IslandShapeStyle.sCurveArchipelago,
    ),
    CelestialColonyInfo(
      planetId: 30,
      planetName: 'The Moon 🌕',
      code: 'LUN',
      islandName: 'Mare Tranquillitatis Isle',
      streetName: 'Apollo Lunar Boulevard',
      landColor: Color(0xFF94A3B8),
      waterColor: Color(0xFF334155),
      climate: 'Silvery Starlit Crater 🌕',
      shapeStyle: IslandShapeStyle.hookPeninsula,
    ),
    CelestialColonyInfo(
      planetId: 51,
      planetName: 'Europa 🧊',
      code: 'EUR',
      islandName: 'Glacier Rift Sanctuary',
      streetName: 'Subsurface Ocean Way',
      landColor: Color(0xFF38BDF8),
      waterColor: Color(0xFF0369A1),
      climate: 'Crystalline Ice Ocean ❄️',
      shapeStyle: IslandShapeStyle.dualIsletBridge,
    ),
    CelestialColonyInfo(
      planetId: 2,
      planetName: 'Venus ☀️',
      code: 'VEN',
      islandName: 'Aphrodite Highland Atoll',
      streetName: 'Sulfur Dawn Expressway',
      landColor: Color(0xFFF59E0B),
      waterColor: Color(0xFFB45309),
      climate: 'Golden Cloud Horizon ☀️',
      shapeStyle: IslandShapeStyle.starAtoll,
    ),
    CelestialColonyInfo(
      planetId: 61,
      planetName: 'Titan 🪐',
      code: 'TTN',
      islandName: 'Kraken Mare Shore',
      streetName: 'Methane Dunes Parkway',
      landColor: Color(0xFF10B981),
      waterColor: Color(0xFF065F46),
      climate: 'Emerald Hydrocarbon Bay 🪐',
      shapeStyle: IslandShapeStyle.heartSanctuary,
    ),
    CelestialColonyInfo(
      planetId: 9,
      planetName: 'Pluto 🌌',
      code: 'PLT',
      islandName: 'Tombaugh Heart Outpost',
      streetName: 'Cryo Frost Path',
      landColor: Color(0xFFA855F7),
      waterColor: Color(0xFF581C87),
      climate: 'Deep Cosmic Frost 🌌',
      shapeStyle: IslandShapeStyle.cloverBays,
    ),
    CelestialColonyInfo(
      planetId: 8,
      planetName: 'Neptune 🌊',
      code: 'NEP',
      islandName: 'Triton Deep Bay',
      streetName: 'Azure Tempest Causeway',
      landColor: Color(0xFF2563EB),
      waterColor: Color(0xFF1E3A8A),
      climate: 'Deep Oceanic Tempest 🌊',
      shapeStyle: IslandShapeStyle.citadelApex,
    ),
  ];

  /// Finds colony info matching a planet name or code
  CelestialColonyInfo getColonyByPlanetName(String planetName) {
    final lower = planetName.toLowerCase();
    for (final c in colonies) {
      if (lower.contains(c.code.toLowerCase()) ||
          lower.contains(c.planetName.toLowerCase()) ||
          c.planetName.toLowerCase().contains(lower.split(' ').first)) {
        return c;
      }
    }
    return colonies.first; // Earth Prime fallback
  }

  /// 🌟 Cached Result of a Birthplace Allocation
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
        final colony = getColonyByPlanetName(reservation.planetName);
        final activeWave = await getActiveWaveIndex();

        // Mark the reserved plot occupied in this wave & colony
        await _markPlotOccupied(activeWave, colony.code, reservation.plotNumber);

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
          tier: (reservation.plotNumber == 1)
              ? PlotDeedTier.presidential
              : (reservation.plotNumber <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
          status: PlotStatus.occupied,
        );
        await saveBirthplace(plot);
        _cachedBirthPlot = plot;
        return plot;
      }
    }

    // 3. Case A: Universal "Destiny" Allocation via 100-Crore Wave Engine
    int currentWave = await getActiveWaveIndex();

    // Find the colony in the current wave with the least occupancy
    CelestialColonyInfo pickedColony = colonies.first;
    int pickedPlotNum = 1;

    // Check all 10 colonies
    final colonyOccupancy = <CelestialColonyInfo, List<int>>{};
    for (final col in colonies) {
      final occ = await _getOccupiedPlotsForPlanet(currentWave, col.code);
      colonyOccupancy[col] = occ;
    }

    // Filter colonies that still have space (< 18)
    final availableColonies = colonies.where((c) => (colonyOccupancy[c]?.length ?? 0) < maxPlotsPerIsland).toList();

    if (availableColonies.isEmpty) {
      // 🎉 ALL 180 PLOTS FULL! "HOUSE FULL" EVENT! Auto-advance to Wave W_(k+1)!
      currentWave++;
      await prefs.setInt(_kActiveWaveIndexKey, currentWave);
      debugPrint('🎉 HOUSE FULL! All 180 plots occupied. Advancing to Wave W$currentWave!');

      // On the fresh wave, pick colony evenly
      final randIdx = math.Random().nextInt(colonies.length);
      pickedColony = colonies[randIdx];
      pickedPlotNum = 1;
    } else {
      // Find minimum occupied count to ensure balanced distribution across all 10 planets
      int minCount = maxPlotsPerIsland;
      for (final c in availableColonies) {
        final count = colonyOccupancy[c]?.length ?? 0;
        if (count < minCount) minCount = count;
      }

      final leastOccupiedColonies = availableColonies
          .where((c) => (colonyOccupancy[c]?.length ?? 0) == minCount)
          .toList();

      // Deterministic yet balanced pick based on user name seed
      final seed = (userName.hashCode ^ DateTime.now().microsecondsSinceEpoch).abs();
      pickedColony = leastOccupiedColonies[seed % leastOccupiedColonies.length];

      final occupiedInPicked = colonyOccupancy[pickedColony] ?? [];
      final activeReservations = await getActiveReservationsForIsland(pickedColony.planetId * 100 + currentWave);
      final reservedPlots = activeReservations.map((r) => r.plotNumber).toSet();

      for (int p = 1; p <= maxPlotsPerIsland; p++) {
        if (!occupiedInPicked.contains(p) && !reservedPlots.contains(p)) {
          pickedPlotNum = p;
          break;
        }
      }

      // If all plots on pickedColony are occupied or reserved, check other available colonies
      if (occupiedInPicked.contains(pickedPlotNum) || reservedPlots.contains(pickedPlotNum)) {
        for (final col in availableColonies) {
          final occ = colonyOccupancy[col] ?? [];
          final res = await getActiveReservationsForIsland(col.planetId * 100 + currentWave);
          final resSet = res.map((r) => r.plotNumber).toSet();
          for (int p = 1; p <= maxPlotsPerIsland; p++) {
            if (!occ.contains(p) && !resSet.contains(p)) {
              pickedColony = col;
              pickedPlotNum = p;
              break;
            }
          }
          if (!occ.contains(pickedPlotNum) && !resSet.contains(pickedPlotNum)) break;
        }
      }
    }

    // Mark plot occupied
    await _markPlotOccupied(currentWave, pickedColony.code, pickedPlotNum);

    // Format Immutable Born Address: PKT-W{Wave}-{PlanetCode}-I{IslandNum}-P{PlotNum}
    final waveStr = currentWave.toString().padLeft(2, '0');
    final plotStr = pickedPlotNum.toString().padLeft(2, '0');
    final cosmosPin = 'PKT-W$waveStr-${pickedColony.code}-I$waveStr-P$plotStr';

    final plot = CitizenPlot(
      plotNumber: pickedPlotNum,
      userId: SupaFlow.client.auth.currentUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName.isNotEmpty ? userName : 'Adventurer',
      userAvatar: avatar.isNotEmpty ? avatar : '🦁',
      day: 1,
      pocketScore: 500,
      streetName: pickedColony.streetName,
      postOffice: pickedColony.islandName,
      countryName: pickedColony.islandName,
      planetName: pickedColony.planetName,
      coordinates: Offset.zero,
      postalPinCode: cosmosPin,
      tier: (pickedPlotNum == 1)
          ? PlotDeedTier.presidential
          : (pickedPlotNum <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
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
          'bio': '🏡 Citizen of ${plot.countryName}, ${plot.planetName} (${plot.postalPinCode})',
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
        postalPinCode: pin ?? 'PKT-W01-EP-I01-P${plotNum.toString().padLeft(2, '0')}',
      );
    }
    return null;
  }

  // =========================================================================
  // 🌊 100-CRORE WAVE OCCUPANCY & "HOUSE FULL" ENGINE
  // =========================================================================

  /// Gets the currently active Wave Index (starts at 1)
  Future<int> getActiveWaveIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kActiveWaveIndexKey) ?? 1;
  }

  /// Gets occupied plot numbers (1..18) for a planet in a given wave
  Future<List<int>> _getOccupiedPlotsForPlanet(int wave, String planetCode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPlanetOccupiedPlotsPrefix' 'W${wave}_$planetCode';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  /// Marks a plot occupied and checks for "HOUSE FULL!" wave completion
  Future<void> _markPlotOccupied(int wave, String planetCode, int plotNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPlanetOccupiedPlotsPrefix' 'W${wave}_$planetCode';
    final currentPlots = await _getOccupiedPlotsForPlanet(wave, planetCode);

    if (!currentPlots.contains(plotNumber)) {
      currentPlots.add(plotNumber);
      await prefs.setString(key, jsonEncode(currentPlots));

      // Increment wave total occupancy count
      final waveCountKey = '$_kWaveOccupancyCountPrefix$wave';
      final currentWaveTotal = (prefs.getInt(waveCountKey) ?? 0) + 1;
      await prefs.setInt(waveCountKey, currentWaveTotal);

      // Check for "HOUSE FULL!" (180 citizens in wave)
      if (currentWaveTotal >= waveCapacity) {
        final nextWave = wave + 1;
        await prefs.setInt(_kActiveWaveIndexKey, nextWave);
        debugPrint('🎉 HOUSE FULL REACHED! Wave W$wave is 100% full. Wave W$nextWave unlocked!');
      }
    }
  }

  /// 👥 Backfills & Allocates all existing registered users across the 100-Crore Wave Engine
  /// Assigns 18 citizens per island, 180 per wave across the 10 permanent Celestial Colonies.
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

      int newlyAllocated = 0;
      int alreadyAllocated = 0;

      for (int i = 0; i < profiles.length; i++) {
        final item = profiles[i] as Map<String, dynamic>;
        final String userId = item['id'] as String;
        final String? existingBio = item['bio'] as String?;

        // If user already has an allocated bio/PIN, count as already allocated
        if (existingBio != null && (existingBio.contains('PKT-EP') || existingBio.contains('PKT-W'))) {
          alreadyAllocated++;
          continue;
        }

        // Determine wave, colony and plot number (18 per island, 180 per wave)
        final waveIdx = (i ~/ waveCapacity) + 1;
        final colonyIdx = ((i % waveCapacity) ~/ maxPlotsPerIsland) % colonies.length;
        final targetColony = colonies[colonyIdx];
        final plotNum = (i % maxPlotsPerIsland) + 1;

        final waveStr = waveIdx.toString().padLeft(2, '0');
        final plotStr = plotNum.toString().padLeft(2, '0');
        final cosmosPin = 'PKT-W$waveStr-${targetColony.code}-I$waveStr-P$plotStr';

        // Update profile in Supabase
        await SupaFlow.client.from('profile').update({
          'country': targetColony.islandName,
          'city': targetColony.streetName,
          'bio': '🏡 Citizen of ${targetColony.islandName}, ${targetColony.planetName} ($cosmosPin)',
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

  // =========================================================================
  // 🪐 CELESTIAL COLONY REAL DATABASE USERS & OCCUPIED PLOTS
  // =========================================================================
  final Map<String, List<CitizenPlot>> _colonyPlotsCache = {};

  /// 🪐 Returns all occupied plots for a specific colony & wave
  /// Fetches real Supabase database users + permanent colony pioneers,
  /// leaving the remaining plots vacant (or with neighbor reservations).
  Future<List<CitizenPlot>> getOccupiedPlotsForColony(
    CelestialColonyInfo colony, {
    int wave = 1,
  }) async {
    final cacheKey = '${colony.code}_$wave';
    if (_colonyPlotsCache.containsKey(cacheKey) && _colonyPlotsCache[cacheKey]!.isNotEmpty) {
      return _colonyPlotsCache[cacheKey]!;
    }

    final coords = IslandAerialPainter.get35PlotCoordinates(colony.shapeStyle);
    final Map<int, CitizenPlot> plotMap = {};

    // 1. Seed Iconic Community Pioneers for this colony (ensuring every island is rich & alive)
    final pioneers = _getColonyPioneers(colony);
    for (final p in pioneers) {
      if (p.plotNumber <= maxPlotsPerIsland && p.plotNumber - 1 < coords.length) {
        plotMap[p.plotNumber] = p.copyWith(
          coordinates: coords[p.plotNumber - 1],
        );
      }
    }

    // 2. Fetch real registered users from Supabase profile table
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, user_id, name, display_name, profile_image_url, current_day, user_day, learning_day, pocket_score, bio, country')
          .order('created_at', ascending: true)
          .limit(200);

      final List<dynamic> profiles = res as List<dynamic>;

      for (int i = 0; i < profiles.length; i++) {
        final item = profiles[i] as Map<String, dynamic>;
        final String uid = (item['user_id'] ?? item['id'] ?? '').toString();
        if (uid.isEmpty) continue;

        final String rawName = (item['display_name'] ?? item['name'] ?? 'Citizen ${i + 1}').toString();
        final String name = rawName.isNotEmpty ? rawName : 'Citizen ${i + 1}';
        final String? avatarUrl = item['profile_image_url'] as String?;
        final int day = (item['learning_day'] ?? item['current_day'] ?? item['user_day'] ?? (25 + (i * 7) % 65)) as int;
        final int score = (item['pocket_score'] ?? (600 + (i * 45) % 800)) as int;
        final String? bio = item['bio'] as String?;
        final String? country = item['country'] as String?;

        // Determine if this user belongs to this colony
        bool matchesColony = false;
        int targetPlot = 0;

        // Check if bio contains cosmic pin (e.g., PKT-W01-MAR-I01-P04)
        if (bio != null && bio.contains('PKT-W')) {
          final regex = RegExp(r'PKT-W(\d+)-([A-Z]+)-I\d+-P(\d+)');
          final match = regex.firstMatch(bio);
          if (match != null) {
            final pinWave = int.tryParse(match.group(1) ?? '1') ?? 1;
            final pinCode = match.group(2) ?? '';
            final pinPlot = int.tryParse(match.group(3) ?? '1') ?? 1;
            if (pinWave == wave && pinCode == colony.code) {
              matchesColony = true;
              targetPlot = pinPlot;
            }
          }
        }

        // If not matched by bio, use deterministic round-robin wave distribution
        if (!matchesColony && (country == null || country.isEmpty || country == colony.islandName)) {
          final userWave = (i ~/ waveCapacity) + 1;
          final colonyIdx = ((i % waveCapacity) ~/ maxPlotsPerIsland) % colonies.length;
          if (userWave == wave && colonies[colonyIdx].code == colony.code) {
            matchesColony = true;
            targetPlot = (i % maxPlotsPerIsland) + 1;
          }
        }

        if (matchesColony && targetPlot >= 1 && targetPlot <= maxPlotsPerIsland) {
          final coord = (targetPlot - 1 < coords.length) ? coords[targetPlot - 1] : Offset.zero;
          final waveStr = wave.toString().padLeft(2, '0');
          final plotStr = targetPlot.toString().padLeft(2, '0');
          final pin = 'PKT-W$waveStr-${colony.code}-I$waveStr-P$plotStr';

          plotMap[targetPlot] = CitizenPlot(
            plotNumber: targetPlot,
            userId: uid,
            userName: name,
            userAvatar: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : '🚀',
            day: math.max(1, day),
            pocketScore: score,
            streetName: colony.streetName,
            postOffice: colony.islandName,
            countryName: colony.islandName,
            planetName: colony.planetName,
            coordinates: coord,
            postalPinCode: pin,
            tier: targetPlot == 1
                ? PlotDeedTier.presidential
                : (targetPlot <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
            status: PlotStatus.occupied,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fetching Supabase profiles for colony non-fatal: $e');
    }

    // 3. Inject current user's local birthplace if on this island
    if (_cachedBirthPlot != null &&
        _cachedBirthPlot!.planetName == colony.planetName &&
        _cachedBirthPlot!.plotNumber <= maxPlotsPerIsland) {
      final pNum = _cachedBirthPlot!.plotNumber;
      final coord = (pNum - 1 < coords.length) ? coords[pNum - 1] : Offset.zero;
      plotMap[pNum] = _cachedBirthPlot!.copyWith(coordinates: coord);
    }

    final result = plotMap.values.toList()
      ..sort((a, b) => a.plotNumber.compareTo(b.plotNumber));
    _colonyPlotsCache[cacheKey] = result;
    return result;
  }

  /// 🏛️ Iconic Community Pioneers across all 10 celestial bodies
  List<CitizenPlot> _getColonyPioneers(CelestialColonyInfo colony) {
    switch (colony.code) {
      case 'EP':
        return [
          _createPioneer(colony, 1, 'Captain Gaia', '👑', 90, 1250, PlotDeedTier.presidential),
          _createPioneer(colony, 3, 'Arjun Varma', '🏄', 68, 840, PlotDeedTier.beachfront),
          _createPioneer(colony, 5, 'Sophia Chen', '🌿', 52, 710, PlotDeedTier.beachfront),
          _createPioneer(colony, 8, 'Marcus Brody', '☕', 34, 490, PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Ananya Nair', '🎨', 82, 990, PlotDeedTier.standard),
        ];
      case 'MAR':
        return [
          _createPioneer(colony, 1, 'Commander Ares', '👑', 88, 1180, PlotDeedTier.presidential),
          _createPioneer(colony, 3, 'Dr. Ryan Stone', '🚀', 64, 830, PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Elena Rostova', '👩‍🚀', 45, 650, PlotDeedTier.beachfront),
          _createPioneer(colony, 9, 'Kenji Sato', '🛰️', 38, 540, PlotDeedTier.standard),
          _createPioneer(colony, 14, 'Maya Al-Mansoor', '🔭', 74, 920, PlotDeedTier.standard),
        ];
      case 'JUP':
        return [
          _createPioneer(colony, 1, 'Solaria Prime', '👑', 92, 1310, PlotDeedTier.presidential),
          _createPioneer(colony, 4, 'Galileo Vance', '🪐', 70, 880, PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Lyra Thorne', '⚡', 55, 730, PlotDeedTier.standard),
          _createPioneer(colony, 10, 'Zephyr Cole', '🌌', 40, 580, PlotDeedTier.standard),
        ];
      case 'LUN':
        return [
          _createPioneer(colony, 1, 'Apollo Warden', '👑', 85, 1150, PlotDeedTier.presidential),
          _createPioneer(colony, 3, 'Luna Armstrong', '🌕', 62, 810, PlotDeedTier.beachfront),
          _createPioneer(colony, 5, 'Viktor Cross', '👨‍🚀', 48, 670, PlotDeedTier.beachfront),
          _createPioneer(colony, 11, 'Selene Zhao', '✨', 76, 930, PlotDeedTier.standard),
        ];
      case 'SAT':
        return [
          _createPioneer(colony, 1, 'Titan Overseer', '👑', 89, 1220, PlotDeedTier.presidential),
          _createPioneer(colony, 4, 'Cassini Drake', '🪐', 66, 850, PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Rhea Sterling', '💍', 51, 690, PlotDeedTier.standard),
          _createPioneer(colony, 13, 'Hyperion Reed', '🛰️', 36, 510, PlotDeedTier.standard),
        ];
      case 'EUR':
        return [
          _createPioneer(colony, 1, 'Cryo Explorer', '👑', 84, 1140, PlotDeedTier.presidential),
          _createPioneer(colony, 3, 'Frost Voyager', '❄️', 58, 770, PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Glacia North', '🧊', 44, 620, PlotDeedTier.beachfront),
          _createPioneer(colony, 10, 'Boreas Vance', '🔬', 72, 900, PlotDeedTier.standard),
        ];
      case 'VEN':
        return [
          _createPioneer(colony, 1, 'Aphrodite Sentinel', '👑', 87, 1190, PlotDeedTier.presidential),
          _createPioneer(colony, 4, 'Solar Flare', '☀️', 61, 800, PlotDeedTier.beachfront),
          _createPioneer(colony, 8, 'Aurelia Blaze', '🔥', 47, 660, PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Helios Thorne', '✨', 78, 940, PlotDeedTier.standard),
        ];
      case 'TTN':
        return [
          _createPioneer(colony, 1, 'Kraken Voyager', '👑', 86, 1170, PlotDeedTier.presidential),
          _createPioneer(colony, 3, 'Methane Drifter', '🛶', 59, 790, PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Dune Navigator', '🪐', 43, 610, PlotDeedTier.standard),
          _createPioneer(colony, 11, 'Huygens Lee', '🔬', 75, 910, PlotDeedTier.standard),
        ];
      case 'PLT':
        return [
          _createPioneer(colony, 1, 'Tombaugh Warden', '👑', 91, 1280, PlotDeedTier.presidential),
          _createPioneer(colony, 4, 'Starlight Nomad', '🌌', 65, 840, PlotDeedTier.beachfront),
          _createPioneer(colony, 8, 'Charon Shade', '❄️', 50, 680, PlotDeedTier.standard),
          _createPioneer(colony, 13, 'Nyx Celestial', '✨', 79, 950, PlotDeedTier.standard),
        ];
      case 'NEP':
        return [
          _createPioneer(colony, 1, 'Triton Vanguard', '👑', 88, 1200, PlotDeedTier.presidential),
          _createPioneer(colony, 4, 'Azure Siren', '🌊', 63, 820, PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Abyss Diver', '🐬', 49, 670, PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Oceanic Prime', '🌀', 77, 930, PlotDeedTier.standard),
        ];
      default:
        return [
          _createPioneer(colony, 1, 'Cosmic Pioneer', '👑', 80, 1000, PlotDeedTier.presidential),
          _createPioneer(colony, 4, 'Starlight Explorer', '🚀', 50, 700, PlotDeedTier.standard),
        ];
    }
  }

  CitizenPlot _createPioneer(
    CelestialColonyInfo colony,
    int plotNum,
    String name,
    String avatar,
    int day,
    int score,
    PlotDeedTier tier,
  ) {
    final plotStr = plotNum.toString().padLeft(2, '0');
    return CitizenPlot(
      plotNumber: plotNum,
      userId: 'pioneer_${colony.code}_$plotNum',
      userName: name,
      userAvatar: avatar,
      day: day,
      pocketScore: score,
      streetName: colony.streetName,
      postOffice: colony.islandName,
      countryName: colony.islandName,
      planetName: colony.planetName,
      coordinates: Offset.zero,
      postalPinCode: 'PKT-W01-${colony.code}-I01-P$plotStr',
      tier: tier,
      status: PlotStatus.occupied,
    );
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

  // =========================================================================
  // 🤝 5-HOUR NEIGHBOR PRE-BOOKING & INVITATION SYSTEM
  // =========================================================================

  /// 🎟️ Generates a 5-hour Neighbor Pre-Booking Pass with unique PIN
  Future<NeighborReservationPass> createNeighborInvitePass({
    required int islandId,
    required String islandName,
    required String planetName,
    required String streetName,
    required int plotNumber,
    required String hostUserName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final colony = getColonyByPlanetName(planetName);
    final currentWave = await getActiveWaveIndex();

    final waveStr = currentWave.toString().padLeft(2, '0');
    final plotStr = plotNumber.toString().padLeft(2, '0');
    final cosmosPin = 'PKT-W$waveStr-${colony.code}-I$waveStr-P$plotStr';
    final code = cosmosPin;

    final expiresAt = DateTime.now().add(const Duration(hours: 5));

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

    final rawJson = prefs.getString(_kReservationsKey);
    final Map<String, dynamic> store = rawJson != null ? jsonDecode(rawJson) : {};
    store[code] = pass.toJson();
    await prefs.setString(_kReservationsKey, jsonEncode(store));

    return pass;
  }

  /// 📋 Gets all active (unexpired) reservations for a specific island
  Future<List<NeighborReservationPass>> getActiveReservationsForIsland(int islandId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    if (rawJson == null) return [];

    try {
      final Map<String, dynamic> store = jsonDecode(rawJson);
      final List<NeighborReservationPass> active = [];
      final Map<String, dynamic> cleanedStore = {};
      bool storeModified = false;

      final now = DateTime.now();
      for (final entry in store.entries) {
        try {
          final pass = NeighborReservationPass.fromJson(entry.value as Map<String, dynamic>);
          if (!now.isAfter(pass.expiresAt)) {
            cleanedStore[entry.key] = entry.value;
            if (pass.islandId == islandId) {
              active.add(pass);
            }
          } else {
            storeModified = true; // Expired, auto-cleansed
          }
        } catch (_) {}
      }

      if (storeModified) {
        await prefs.setString(_kReservationsKey, jsonEncode(cleanedStore));
      }

      return active;
    } catch (_) {
      return [];
    }
  }

  /// 🗺️ Gets map of plotNumber -> NeighborReservationPass for O(1) map painter lookups
  Future<Map<int, NeighborReservationPass>> getActiveReservationsMap(int islandId) async {
    final list = await getActiveReservationsForIsland(islandId);
    return {for (final pass in list) pass.plotNumber: pass};
  }

  /// ❌ Cancels an active reservation
  Future<void> cancelReservation(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    if (rawJson == null) return;
    try {
      final Map<String, dynamic> store = jsonDecode(rawJson);
      if (store.remove(code) != null) {
        await prefs.setString(_kReservationsKey, jsonEncode(store));
      }
    } catch (_) {}
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
      cosmosPin: 'PKT-W01-EP-I01-P${plotNumber.toString().padLeft(2, '0')}',
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

  /// 🔍 Validates a Neighbor Pre-Booking Code or Born Address
  Future<NeighborReservationPass?> validateNeighborInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();

    // 1. Check Jupiter test presets
    if (cleanCode.contains('JUP') || cleanCode == 'PKT-JUPITER' || cleanCode == 'JUPITER') {
      final col = colonies[2]; // Jupiter
      return NeighborReservationPass(
        code: cleanCode,
        islandId: 501,
        islandName: col.islandName,
        planetName: col.planetName,
        streetName: col.streetName,
        plotNumber: 15, // Neighbor to Plot #14
        hostUserName: 'Jupiter Citizen A',
        cosmosPin: 'PKT-W01-JUP-I01-P15',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );
    }

    // 2. Check Saturn test presets
    if (cleanCode.contains('SAT') || cleanCode == 'PKT-SATURN' || cleanCode == 'SATURN') {
      final col = colonies[3]; // Saturn
      return NeighborReservationPass(
        code: cleanCode,
        islandId: 601,
        islandName: col.islandName,
        planetName: col.planetName,
        streetName: col.streetName,
        plotNumber: 8,
        hostUserName: 'Saturn Host',
        cosmosPin: 'PKT-W01-SAT-I01-P08',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );
    }

    // 3. Check Earth Prime test presets (PKT-TEST)
    if (cleanCode == 'PKT-TEST' || cleanCode == 'TEST') {
      return generateQuickTestFriendPass();
    }

    // 4. Check dynamic Born Address format: PKT-W{wave}-{planetCode}-I{island}-P{plot}
    // e.g. PKT-W01-JUP-I01-P07
    final pinRegex = RegExp(r'^PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)$');
    final match = pinRegex.firstMatch(cleanCode);
    if (match != null) {
      final wave = match.group(1)!;
      final planetCode = match.group(2)!;
      final island = match.group(3)!;
      final hostPlot = int.tryParse(match.group(4)!) ?? 1;

      final colony = colonies.firstWhere(
        (c) => c.code == planetCode,
        orElse: () => colonies.first,
      );

      // Reserve adjacent neighbor plot (clamped within 1..18)
      int neighborPlot = hostPlot + 1;
      if (neighborPlot > maxPlotsPerIsland) neighborPlot = hostPlot - 1;
      if (neighborPlot < 1) neighborPlot = 2;

      final neighborPlotStr = neighborPlot.toString().padLeft(2, '0');
      final pin = 'PKT-W$wave-$planetCode-I$island-P$neighborPlotStr';

      return NeighborReservationPass(
        code: cleanCode,
        islandId: colony.planetId * 100 + int.parse(island),
        islandName: colony.islandName,
        planetName: colony.planetName,
        streetName: colony.streetName,
        plotNumber: neighborPlot,
        hostUserName: 'Neighbor Friend (Plot #$hostPlot)',
        cosmosPin: pin,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );
    }

    // 5. Check local registry of created passes
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

    // 6. Graceful deterministic fallback for valid custom referral codes
    if (cleanCode.length >= 3) {
      final hash = cleanCode.hashCode.abs();
      final colony = colonies[hash % colonies.length];
      final plot = (hash % (maxPlotsPerIsland - 1)) + 2; // plot between 2 and 18

      return NeighborReservationPass(
        code: cleanCode,
        islandId: colony.planetId * 100 + 1,
        islandName: colony.islandName,
        planetName: colony.planetName,
        streetName: colony.streetName,
        plotNumber: plot,
        hostUserName: 'Cosmos Citizen (Host)',
        cosmosPin: 'PKT-W01-${colony.code}-I01-P${plot.toString().padLeft(2, '0')}',
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
      "🏡 POCKET WORLD (പോക്കറ്റ് വേൾഡ്)\n"
      "----------------------------------------\n"
      "Hey! I reserved Plot #$plotNumber for you right next to my house in Pocket Cosmos!\n\n"
      "📍 Location: $streetName, $islandName\n"
      "🪐 Celestial Body: $planetName\n"
      "🔑 Born PIN / Referral Code: $code\n\n"
      "Join as my neighbor using my exclusive Born Code before the 5-hour pass expires!\n\n"
      "📲 Download Pocket Mates App:\n"
      "🤖 Android (Play Store): https://play.google.com/store/apps/details?id=com.pocketmates.app\n"
      "🍎 iOS (App Store): https://apps.apple.com/app/pocket-mates/id6470000000\n"
      "🌐 Direct Join: https://pocketmates.app/join?bornCode=$code";

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
