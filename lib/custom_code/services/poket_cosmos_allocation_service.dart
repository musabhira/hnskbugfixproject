import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_group_service.dart';
import 'poket_cosmos_vocab_dictionary.dart';
import 'poket_cosmos_distance_service.dart';

/// 🪐 Definition of a Permanent Celestial Colony in Pocket Cosmos
class CelestialColonyInfo {
  final int planetId;
  final String planetName;
  final String
      code; // 'EP', 'MAR', 'JUP', 'SAT', 'LUN', 'EUR', 'VEN', 'TTN', 'PLT', 'NEP'
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
/// - 4-Hour Neighbor Pre-booking Pass & Direct Referral Gateway routing
class PoketCosmosAllocationService {
  PoketCosmosAllocationService._();
  static final PoketCosmosAllocationService instance =
      PoketCosmosAllocationService._();

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

  // Scaling Constants (25 plots per island, 375 citizens per wave across 15 Celestial Worlds)
  static const int maxPlotsPerIsland = 25;
  static const int totalPlanetsCount = 15;
  static const int waveCapacity = 375; // 15 celestial worlds * 25 plots

  /// 🏷️ Algorithmic Infinite Island Naming Loop Engine
  /// Generates endless unique celestial island titles across infinite waves.
  /// First 2,000 islands receive unique English vocabulary root words.
  /// Island 2001+ increments cycle count (e.g. 'Serenity 1 Atoll', 'Horizon 1 Bay').
  static String generateInfiniteIslandName(
      String planetCode, int wave, int islandNum) {
    final colonyIndex = colonies.indexWhere((c) => c.code == planetCode);
    final int safeColonyIdx = colonyIndex >= 0 ? colonyIndex : 0;
    // Sequential island index in the universe (1-based)
    final int globalIslandIndex =
        ((wave - 1) * totalPlanetsCount) + safeColonyIdx + 1;

    final int vocabIndex = (globalIslandIndex - 1) % kCosmosVocab2000.length;
    final int cycle = (globalIslandIndex - 1) ~/ kCosmosVocab2000.length;
    final String rootWord = kCosmosVocab2000[vocabIndex];

    const landforms = [
      'Atoll',
      'Haven',
      'Bay',
      'Sound',
      'Peninsula',
      'Archipelago',
      'Plateau',
      'Shores',
      'Lagoon',
      'Citadel',
      'Cove',
      'Crest',
      'Oasis',
      'Terrace',
      'Sanctuary',
    ];
    final String landform =
        landforms[(globalIslandIndex * 3 + safeColonyIdx) % landforms.length];

    if (cycle == 0) {
      return '$rootWord $landform';
    } else {
      return '$rootWord Island Wave $cycle';
    }
  }

  // 🪐 10 Permanent Celestial Colonies Catalog
  static const List<CelestialColonyInfo> colonies = [
    CelestialColonyInfo(
      planetId: 3,
      planetName: 'Earth Prime 🌍',
      code: 'EP',
      islandName: 'Serenity Atoll',
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
      islandName: 'Courage Haven',
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
      islandName: 'Zenith Crest',
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
      islandName: 'Harmony Shores',
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
      islandName: 'Tranquility Isle',
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
      islandName: 'Resilience Sanctuary',
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
      islandName: 'Radiance Atoll',
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
      islandName: 'Ambition Shore',
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
      islandName: 'Solitude Outpost',
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
      islandName: 'Odyssey Bay',
      streetName: 'Azure Tempest Causeway',
      landColor: Color(0xFF2563EB),
      waterColor: Color(0xFF1E3A8A),
      climate: 'Deep Oceanic Tempest 🌊',
      shapeStyle: IslandShapeStyle.citadelApex,
    ),
    // Additional 5 Solar & Interstellar Celestial Worlds
    CelestialColonyInfo(
      planetId: 1,
      planetName: 'Mercury ⚪',
      code: 'MER',
      islandName: 'Caloris Basin',
      streetName: 'Scorched Ridge Way',
      landColor: Color(0xFF64748B),
      waterColor: Color(0xFF1E293B),
      climate: 'High Heat Caloris 🔥',
      shapeStyle: IslandShapeStyle.fortressPlateau,
    ),
    CelestialColonyInfo(
      planetId: 52,
      planetName: 'Ganymede 🛡️',
      code: 'GAN',
      islandName: 'Perrine Regio',
      streetName: 'Magnetic Citadel Path',
      landColor: Color(0xFF475569),
      waterColor: Color(0xFF0284C7),
      climate: 'Magnetic Ocean Glow ⚡',
      shapeStyle: IslandShapeStyle.fortressPlateau,
    ),
    CelestialColonyInfo(
      planetId: 7,
      planetName: 'Uranus 💎',
      code: 'URA',
      islandName: 'Miranda Glade',
      streetName: 'Cyan Ridge Boulevard',
      landColor: Color(0xFF0E7490),
      waterColor: Color(0xFF0891B2),
      climate: 'Cyan Cryo Chill 🧊',
      shapeStyle: IslandShapeStyle.hookPeninsula,
    ),
    CelestialColonyInfo(
      planetId: 81,
      planetName: 'Triton 🔱',
      code: 'TRI',
      islandName: 'Triton Geyser',
      streetName: 'Sub-Zero Geyser Avenue',
      landColor: Color(0xFF1E40AF),
      waterColor: Color(0xFF60A5FA),
      climate: 'Cryo Plume Frost ❄️',
      shapeStyle: IslandShapeStyle.crescentLagoon,
    ),
    CelestialColonyInfo(
      planetId: 452,
      planetName: 'Kepler-452b 🌌',
      code: 'KEP',
      islandName: 'Cygnus Haven',
      streetName: 'Super-Earth Exoplanet Trail',
      landColor: Color(0xFF065F46), // Exotic alien deep emerald
      waterColor:
          Color(0xFF312E81), // Bioluminescent deep indigo exoplanet ocean
      climate: 'Bioluminescent Exosphere 🌌',
      shapeStyle: IslandShapeStyle.cloverBays,
    ),
  ];

  /// Finds colony info matching a planet code (e.g. 'EP', 'MAR', 'JUP', 'MER', 'KEP')
  CelestialColonyInfo getColonyByCode(String code) {
    var upper = code.trim().toUpperCase();
    if (upper == 'MOON') upper = 'LUN';
    if (upper == 'TIT' || upper == 'TITAN') upper = 'TTN';
    if (upper == 'EARTH' || upper == 'EARTH PRIME') upper = 'EP';
    if (upper == 'MERCURY') upper = 'MER';
    if (upper == 'VENUS') upper = 'VEN';
    if (upper == 'MARS') upper = 'MAR';
    if (upper == 'JUPITER') upper = 'JUP';
    if (upper == 'EUROPA') upper = 'EUR';
    if (upper == 'GANYMEDE') upper = 'GAN';
    if (upper == 'SATURN') upper = 'SAT';
    if (upper == 'URANUS') upper = 'URA';
    if (upper == 'NEPTUNE') upper = 'NEP';
    if (upper == 'TRITON') upper = 'TRI';
    if (upper == 'PLUTO') upper = 'PLT';
    if (upper == 'KEPLER' || upper == 'KEPLER-452B') upper = 'KEP';

    for (final c in colonies) {
      if (c.code.toUpperCase() == upper) return c;
    }
    return getColonyByPlanetName(code);
  }

  /// Finds colony info matching a planet name or code
  CelestialColonyInfo getColonyByPlanetName(String planetName) {
    final lower = planetName.toLowerCase().trim();
    // 1. Exact or alias code match
    for (final c in colonies) {
      if (c.code.toLowerCase() == lower) return c;
    }
    // 2. Exact or partial planet name match (e.g., 'mercury', 'kepler', 'ganymede', 'mars', 'earth')
    for (final c in colonies) {
      final baseClean =
          c.planetName.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final words = baseClean.split(' ');
      final mainWord = words.first;
      if (lower.contains(baseClean) ||
          baseClean.contains(lower) ||
          lower.contains(mainWord) ||
          mainWord.contains(lower)) {
        return c;
      }
    }
    // 3. Island name match (e.g., 'caloris basin', 'cygnus haven', 'tranquility base')
    for (final c in colonies) {
      if (lower.contains(c.islandName.toLowerCase()) ||
          c.islandName.toLowerCase().contains(lower)) {
        return c;
      }
    }
    return colonies.first; // Earth Prime fallback
  }

  /// 🌐 Computes the unique global sequential plot number (1 to 375 in Wave 1, 376 to 750 in Wave 2, etc.)
  /// Planetary block layout: Earth: 1-25, Mars: 26-50, Jupiter: 51-75, ..., Neptune: 226-250, ..., Kepler: 351-375.
  /// Guarantees that Plot #2 is strictly on Earth Prime and Plot #250 is strictly on Neptune with zero duplicates!
  static int calculateGlobalPlotNumber({
    int wave = 1,
    required String planetCode,
    required int localPlotNumber,
  }) {
    final cleanCode = planetCode.trim().toUpperCase();
    int planetIndex =
        colonies.indexWhere((c) => c.code.toUpperCase() == cleanCode);
    if (planetIndex == -1) planetIndex = 0; // Default to Earth
    final clampedLocal = localPlotNumber.clamp(1, maxPlotsPerIsland);
    final clampedWave = math.max(1, wave);
    final offsetWithinWave =
        (planetIndex * maxPlotsPerIsland) + (clampedLocal - 1);
    return ((clampedWave - 1) * waveCapacity) + offsetWithinWave + 1;
  }

  /// 🌐 Parses a global sequential plot number back into wave, planet colony, and local plot number
  static Map<String, dynamic> parseGlobalPlotNumber(int globalPlotNumber) {
    final gNum = math.max(1, globalPlotNumber);
    final wave = ((gNum - 1) ~/ waveCapacity) + 1;
    final withinWave = (gNum - 1) % waveCapacity;
    final planetIndex =
        (withinWave ~/ maxPlotsPerIsland).clamp(0, colonies.length - 1);
    final localPlot = (withinWave % maxPlotsPerIsland) + 1;
    final colony = colonies[planetIndex];
    return {
      'wave': wave,
      'colony': colony,
      'planetCode': colony.code,
      'planetName': colony.planetName,
      'localPlotNumber': localPlot,
      'globalPlotNumber': gNum,
    };
  }

  /// 🏝️ Dynamic Procedural Island Loop Engine
  /// Scales infinitely to unlimited islands per celestial world.
  /// Generates procedural names, unique shape variations, subtle land/water color shifts,
  /// and dynamic occupancy per wave.
  static PoketCountryMap generateProceduralIsland({
    required CelestialColonyInfo colony,
    required int wave,
    int? activeWave,
    int? filledSlots,
  }) {
    final int safeWave = math.max(1, wave);
    final int currentWave = activeWave ?? 1;

    // 1. Procedural Unique Island Name (Algorithmic English Vocabulary Generator)
    final String islandName = (safeWave == 1)
        ? colony.islandName
        : generateInfiniteIslandName(colony.code, safeWave, safeWave);

    // 2. Procedural Island Shape Style (Loop system across citizen shapes)
    // Note: citadelApex is reserved strictly for President's Citadel on Earth Prime
    const citizenShapes = [
      IslandShapeStyle.crescentLagoon,
      IslandShapeStyle.ringAtoll,
      IslandShapeStyle.starAtoll,
      IslandShapeStyle.sCurveArchipelago,
      IslandShapeStyle.dualIsletBridge,
      IslandShapeStyle.hookPeninsula,
      IslandShapeStyle.heartSanctuary,
      IslandShapeStyle.cloverBays,
      IslandShapeStyle.fortressPlateau,
    ];
    final int shapeIndex =
        ((colony.planetId * 7) + (safeWave * 3)) % citizenShapes.length;
    final IslandShapeStyle shapeStyle =
        (safeWave == 1) ? colony.shapeStyle : citizenShapes[shapeIndex];

    // 3. Shape Seed (unique integer for procedural coastline variations)
    final int shapeSeed = (colony.planetId * 1000) + (safeWave * 37) + 1;

    // 4. Procedural Biome Variations (Subtle color gradient shifts per wave)
    final hslLand = HSLColor.fromColor(colony.landColor);
    final double hueShift = ((safeWave - 1) * 11.0) % 24.0 - 12.0;
    final double lightShift = (((safeWave - 1) * 3) % 12 - 6) / 100.0;
    final dynamicLandColor = hslLand
        .withHue((hslLand.hue + hueShift).clamp(0.0, 360.0))
        .withLightness((hslLand.lightness + lightShift).clamp(0.18, 0.82))
        .toColor();

    final hslWater = HSLColor.fromColor(colony.waterColor);
    final double waterHueShift = ((safeWave - 1) * 7.0) % 18.0 - 9.0;
    final dynamicWaterColor = hslWater
        .withHue((hslWater.hue + waterHueShift).clamp(0.0, 360.0))
        .toColor();

    // 5. Procedural Climate Descriptions & Icons
    const climateVariations = [
      'Azure Trade Winds 🍃',
      'Coral Reef Shallows 🌊',
      'Emerald Palm Ridge 🌴',
      'Bioluminescent Twilight ✨',
      'Golden Sunrise Haven 🌅',
      'Crystal Tide Shallows 💎',
      'Misty Ocean Horizon 🌫️',
      'Tropical Rain Sanctuary 🌧️',
    ];
    final String dynamicClimate = (safeWave == 1)
        ? colony.climate
        : climateVariations[
            (safeWave + colony.planetId) % climateVariations.length];

    const climateIcons = [
      Icons.air_rounded,
      Icons.waves_rounded,
      Icons.eco_rounded,
      Icons.wb_sunny_rounded,
      Icons.water_drop_rounded,
      Icons.nightlight_round,
    ];
    final IconData dynamicIcon =
        climateIcons[(safeWave + colony.planetId) % climateIcons.length];

    const islandEmojis = ['🏝️', '🌴', '🌊', '🌺', '🐚', '🦜'];
    final String dynamicEmoji = (safeWave == 1)
        ? (colony.planetName.contains('🌍')
            ? '🏝️'
            : colony.planetName.split(' ').last)
        : islandEmojis[(safeWave + colony.planetId) % islandEmojis.length];

    // 6. Slots & Occupancy (25 plots per island)
    final int slots = maxPlotsPerIsland; // 25
    final int effectiveFilled = filledSlots ??
        (safeWave < currentWave ? 25 : (safeWave == currentWave ? 12 : 0));

    final int islandId = colony.planetId * 10000 + safeWave;

    return PoketCountryMap(
      id: islandId,
      name: islandName,
      tag: (safeWave == 1)
          ? 'Genesis Colony Island'
          : 'Wave $safeWave Expansion Island',
      landColor: (safeWave == 1) ? colony.landColor : dynamicLandColor,
      waterColor: (safeWave == 1) ? colony.waterColor : dynamicWaterColor,
      totalSlots: slots,
      filledSlots: effectiveFilled,
      climate: dynamicClimate,
      climateIcon: dynamicIcon,
      islandEmoji: dynamicEmoji,
      shapeSeed: shapeSeed,
      shapeStyle: shapeStyle,
      wave: safeWave,
      planetCode: colony.code,
      isPresidential:
          false, // President's Citadel is strictly separate on Earth Prime
    );
  }

  /// 🌐 Returns all islands generated across planets for the given active wave count
  static List<Map<String, dynamic>> getAllIslandsCatalog({int maxWaves = 1}) {
    final List<Map<String, dynamic>> list = [];
    for (int w = 1; w <= math.max(1, maxWaves); w++) {
      for (final colony in colonies) {
        final island = generateProceduralIsland(
            colony: colony, wave: w, activeWave: maxWaves);
        list.add({
          'wave': w,
          'colony': colony,
          'planetCode': colony.code,
          'planetName': colony.planetName,
          'islandName': island.name,
          'streetName':
              (w == 1) ? colony.streetName : 'Wave $w ${colony.streetName}',
          'climate': island.climate,
          'shapeStyle': island.shapeStyle,
          'totalPlots': maxPlotsPerIsland,
          'occupiedCount': island.filledSlots,
        });
      }
    }
    return list;
  }

  /// 👥 Cached list of all registered profile records from Supabase, sorted by created_at ASC
  List<Map<String, dynamic>> _allRegisteredProfiles = [];
  bool _profilesLoaded = false;

  /// Loads all real registered users from Supabase profile table
  Future<List<Map<String, dynamic>>> loadAllRegisteredProfiles(
      {bool forceRefresh = false}) async {
    if (_profilesLoaded && !forceRefresh && _allRegisteredProfiles.isNotEmpty) {
      return _allRegisteredProfiles;
    }
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select(
              'id, user_id, name, bio, profile_image_url, pocket_score, created_at')
          .order('created_at', ascending: true);
      _allRegisteredProfiles = List<Map<String, dynamic>>.from(res);
      _profilesLoaded = true;
    } catch (e) {
      debugPrint('⚠️ loadAllRegisteredProfiles non-fatal: $e');
    }
    return _allRegisteredProfiles;
  }

  /// Synchronous count of registered profiles
  static int get totalRegisteredUsersCount =>
      instance._allRegisteredProfiles.isNotEmpty
          ? instance._allRegisteredProfiles.length
          : 277;

  /// 📈 Dynamic Real Estate Valuation Algorithm
  /// Calculates the current Pocket Score price for any plot based on wave occupancy, planet prestige, and parcel tier
  static int calculatePlotMarketPrice({
    required int wave,
    required String planetCode,
    required int localPlotNumber,
    int? totalOccupiedInWave,
  }) {
    final int occupied = totalOccupiedInWave ??
        (wave == 1
            ? waveCapacity
            : math.max(
                0,
                instance._allRegisteredProfiles.length -
                    ((wave - 1) * waveCapacity)));
    final double occupancyRatio = (occupied / waveCapacity).clamp(0.0, 1.0);

    // Dynamic market curve:
    // When new wave releases (0-35% occupancy): 150-250 PS (Cheap Season / High Supply!)
    // When 40-75% occupancy: 300-550 PS (Normal demand)
    // When 75-90% occupancy: 600-950 PS (Growing scarcity)
    // When 90-100% occupancy: 1,200-2,500 PS (Rare peak rush!)
    int basePrice;
    if (occupancyRatio < 0.35) {
      basePrice = 150 + (occupancyRatio * 280).toInt();
    } else if (occupancyRatio < 0.75) {
      basePrice = 250 + ((occupancyRatio - 0.35) * 750).toInt();
    } else if (occupancyRatio < 0.90) {
      basePrice = 550 + ((occupancyRatio - 0.75) * 2600).toInt();
    } else {
      basePrice = 950 + ((occupancyRatio - 0.90) * 15500).toInt();
    }

    // Planetary prestige multiplier
    double planetMultiplier = 1.0;
    if (planetCode == 'EP') {
      planetMultiplier = 1.30; // Earth Prime capital world
    } else if (planetCode == 'MAR' ||
        planetCode == 'JUP' ||
        planetCode == 'SAT') {
      planetMultiplier = 1.10;
    } else if (planetCode == 'LUN' || planetCode == 'EUR') {
      planetMultiplier = 1.05;
    } else {
      planetMultiplier = 0.90; // Deep space frontier (Pluto, Neptune)
    }

    // Parcel location multiplier
    double tierMultiplier = 1.0;
    if (localPlotNumber <= 6) {
      tierMultiplier = 1.25; // Beachfront ocean view parcel
    } else if (localPlotNumber <= 12) {
      tierMultiplier = 1.10; // Palm grove ridge parcel
    }

    return (basePrice * planetMultiplier * tierMultiplier).round();
  }

  /// 🏡 Allows a user to buy and move their permanent residence to an available plot with Pocket Score
  Future<bool> buyAndSwitchPlot({
    required BuildContext context,
    required String targetPlanetCode,
    required int targetPlotNumber,
    required int targetWave,
  }) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please log in to purchase a plot in Pocket Cosmos!')),
      );
      return false;
    }

    final price = calculatePlotMarketPrice(
      wave: targetWave,
      planetCode: targetPlanetCode,
      localPlotNumber: targetPlotNumber,
    );

    // Fetch user profile and score (checking both id and user_id for RLS compatibility)
    int userScore = 0;
    String userName = 'Citizen';
    String userAvatar = '🦁';
    String? profileDocId;
    String existingBio = '';
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, user_id, name, profile_image_url, pocket_score, bio')
          .or('id.eq.$uid,user_id.eq.$uid')
          .maybeSingle();
      if (res != null) {
        profileDocId = res['id']?.toString();
        userScore = (res['pocket_score'] as num?)?.toInt() ?? 0;
        userName = res['name']?.toString() ?? 'Citizen';
        userAvatar = res['profile_image_url']?.toString() ?? '🦁';
        existingBio = res['bio']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('⚠️ buyAndSwitchPlot fetch profile non-fatal: $e');
    }

    if (userScore < price) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Insufficient Pocket Score! Needs $price PS (You have $userScore PS). Complete daily English tasks to earn more!'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return false;
    }

    // Deduct Pocket Score and update bio with new Cosmos Pin
    final colony = getColonyByCode(targetPlanetCode);
    final waveStr = targetWave.toString().padLeft(2, '0');
    final plotStr = targetPlotNumber.toString().padLeft(2, '0');
    final newPin = 'PKT-W$waveStr-$targetPlanetCode-I$waveStr-P$plotStr';
    final newScore = userScore - price;
    final effectiveIslandName = (targetWave == 1)
        ? colony.islandName
        : generateInfiniteIslandName(colony.code, targetWave, targetWave);
    final effectiveStreetName = (targetWave == 1)
        ? colony.streetName
        : 'Wave $targetWave ${colony.streetName}';

    try {
      // Clean previous pin from bio and append new pin, keeping user's personal bio
      final cleanBio = existingBio
          .replaceAll(
              RegExp(r'\s*(\n\n)?🏡\s*PKT-W\d+-[A-Z]+-I\d+-P\d+.*$'), '')
          .trim();
      final newBio = cleanBio.isEmpty
          ? '🏡 Citizen of $effectiveIslandName, ${colony.planetName} ($newPin)'
          : '$cleanBio\n\n🏡 $newPin';

      final updatePayload = {
        'pocket_score': newScore,
        'bio': newBio,
        'country': effectiveIslandName,
        'city': effectiveStreetName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (profileDocId != null && profileDocId.isNotEmpty) {
        try {
          await SupaFlow.client
              .from('profile')
              .update(updatePayload)
              .eq('id', profileDocId);
        } catch (_) {}
      }
      try {
        await SupaFlow.client
            .from('profile')
            .update(updatePayload)
            .eq('user_id', uid);
      } catch (_) {}

      // Update in-memory user plot
      final newPlot = CitizenPlot(
        plotNumber: targetPlotNumber,
        userId: uid,
        userName: userName,
        userAvatar: userAvatar,
        day: 1,
        pocketScore: newScore,
        streetName: effectiveStreetName,
        postOffice: effectiveIslandName,
        countryName: effectiveIslandName,
        planetName: colony.planetName,
        postalPinCode: newPin,
        coordinates: Offset.zero,
        tier: (targetPlotNumber <= 6)
            ? PlotDeedTier.beachfront
            : PlotDeedTier.standard,
        status: PlotStatus.occupied,
      );
      _userBirthPlots[uid] = newPlot;
      _cachedBirthPlot = newPlot;

      // Save to SharedPreferences
      await saveBirthplace(newPlot);

      // 🚪 Global Relocation Tracking (Enforces Single Global Plot Deed & Vacates Old Plot Instantly)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cosmos_user_relocated_pin_$uid', newPin);
      await prefs.setString(
          'cosmos_user_relocated_planet_$uid', targetPlanetCode);
      await prefs.setInt('cosmos_user_relocated_plot_$uid', targetPlotNumber);
      await prefs.setInt('cosmos_user_relocated_wave_$uid', targetWave);

      final relocatedList =
          prefs.getStringList('cosmos_all_relocated_uids') ?? [];
      if (!relocatedList.contains(uid)) {
        relocatedList.add(uid);
        await prefs.setStringList('cosmos_all_relocated_uids', relocatedList);
      }

      // 🏝️ Global Island Neighbors Group Relocation Hook:
      // Automatically leaves the old island group and joins the new island group!
      final prevMatch =
          RegExp(r'PKT-W(\d+)-([A-Z]+)-I\d+-P(\d+)').firstMatch(existingBio);
      final oldCode = prevMatch?.group(2) ?? 'EP';
      final oldWave = int.tryParse(prevMatch?.group(1) ?? '1') ?? 1;

      unawaited(
        PocketIslandGroupService.instance.onUserRelocated(
          userId: uid,
          oldPlanetCode: oldCode,
          newPlanetCode: targetPlanetCode,
          oldWave: oldWave,
          newWave: targetWave,
          newPlotNumber: targetPlotNumber,
          newPlanetName: colony.planetName,
          newIslandName: effectiveIslandName,
        ),
      );

      // Update in-memory profile immediately so UI updates with zero delay
      final profIdx = _allRegisteredProfiles.indexWhere((p) =>
          (p['id']?.toString() == uid) || (p['user_id']?.toString() == uid));
      if (profIdx != -1) {
        _allRegisteredProfiles[profIdx]['bio'] = newBio;
        _allRegisteredProfiles[profIdx]['pocket_score'] = newScore;
        _allRegisteredProfiles[profIdx]['country'] = effectiveIslandName;
        _allRegisteredProfiles[profIdx]['city'] = effectiveStreetName;
      }

      // Refresh registered profiles cache & clear cached plots
      clearPlotCaches();
      await loadAllRegisteredProfiles(forceRefresh: true);

      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '🎉 Congratulations! You successfully acquired Plot #$targetPlotNumber on ${colony.planetName} for $price PS!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to complete purchase: $e'),
            backgroundColor: Colors.red),
      );
      return false;
    }
  }

  /// 🌐 Returns all plots across waves for Search Page Plots Grid with real owner info
  static List<Map<String, dynamic>> getWavePlotsCatalog({int maxWaves = 2}) {
    final List<Map<String, dynamic>> list = [];
    final int endPlot = math.max(1, maxWaves) * waveCapacity;
    final profiles = instance._allRegisteredProfiles;

    // Map globalPlotNumber -> Real User Profile
    final Map<int, Map<String, dynamic>> plotToProfile = {};
    final Set<int> relocatedUserIndices = {};

    for (int i = 0; i < profiles.length; i++) {
      final prof = profiles[i];
      final uid = (prof['user_id'] ?? prof['id'] ?? '').toString();
      final bio = prof['bio']?.toString() ?? '';
      final match =
          RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(bio);
      if (match != null) {
        final w = int.tryParse(match.group(1) ?? '1') ?? 1;
        final pCode = match.group(2) ?? 'EP';
        final lPlot = int.tryParse(match.group(4) ?? '1') ?? 1;
        final g = calculateGlobalPlotNumber(
            wave: w, planetCode: pCode, localPlotNumber: lPlot);
        plotToProfile[g] = prof;
        relocatedUserIndices.add(i);
      } else if (instance._userBirthPlots.containsKey(uid)) {
        relocatedUserIndices.add(i);
      }
    }

    // Allocate remaining users to their deterministic round-robin slot
    for (int i = 0; i < profiles.length; i++) {
      if (!relocatedUserIndices.contains(i)) {
        final g = i + 1;
        if (!plotToProfile.containsKey(g)) {
          plotToProfile[g] = profiles[i];
        }
      }
    }

    for (int gNum = 1; gNum <= endPlot; gNum++) {
      final parsed = parseGlobalPlotNumber(gNum);
      final colony = parsed['colony'] as CelestialColonyInfo;
      final int lNum = parsed['localPlotNumber'] as int;

      String ownerName = 'Available';
      String avatar = '🟢';
      bool isOccupied = false;
      String userId = '';

      if (plotToProfile.containsKey(gNum)) {
        final prof = plotToProfile[gNum]!;
        final rawName = prof['name']?.toString().trim();
        ownerName = (rawName != null && rawName.isNotEmpty)
            ? rawName
            : 'Citizen #$gNum';
        final rawAvatar = prof['profile_image_url']?.toString().trim();
        avatar = (rawAvatar != null && rawAvatar.isNotEmpty) ? rawAvatar : '🦁';
        userId = prof['id']?.toString() ?? prof['user_id']?.toString() ?? '';
        isOccupied = true;
      }

      // 2. Check active in-memory user plot overrides (e.g. bought/switched plots)
      for (final entry in instance._userBirthPlots.entries) {
        final plot = entry.value;
        if (plot.planetName == colony.planetName &&
            (plot.plotNumber == gNum || plot.plotNumber == lNum)) {
          ownerName = plot.userName;
          avatar = plot.userAvatar;
          userId = entry.key;
          isOccupied = true;
          break;
        }
      }

      // 3. Iconic Pioneers on Wave 1 (Genesis Islands)
      final int wave = parsed['wave'] as int? ?? 1;
      if (!isOccupied && wave == 1) {
        final pioneers = instance.getColonyPioneers(colony);
        for (final p in pioneers) {
          final pLocal = (p.plotNumber <= maxPlotsPerIsland)
              ? p.plotNumber
              : (((p.plotNumber - 1) % waveCapacity) % maxPlotsPerIsland) + 1;
          if (pLocal == lNum) {
            ownerName = p.userName;
            avatar = p.userAvatar;
            userId = p.userId;
            isOccupied = true;
            break;
          }
        }

        // Fill deterministic pioneer slots matching getOccupiedPlotsForColony
        if (!isOccupied) {
          const defaultCandidateSlots = [1, 2, 3, 4, 6, 7, 9, 10, 11, 12, 14, 15];
          final slotIdx = defaultCandidateSlots.indexOf(lNum);
          if (slotIdx != -1) {
            final defaultPioneerNames = [
              'Commander ${colony.islandName.split(' ').first}',
              'Dr. ${colony.code} Horizon',
              'Pioneer Zephyr',
              'Solar Warden',
              'Astro Navigator',
              'Cosmic Sentinel',
              'Starlight Scholar',
              'Nebula Guardian',
              'Orbital Scout',
              'Deep Void Ranger',
              'Galaxy Pioneer',
              'Aero Veteran',
            ];
            final defaultAvatars = [
              '🧑‍🚀', '👨‍🚀', '👩‍🚀', '🦁', '🦅', '🐺', '🦊', '🐯', '⚡', '🌟', '🚀', '✨'
            ];
            ownerName = defaultPioneerNames[slotIdx % defaultPioneerNames.length];
            avatar = defaultAvatars[slotIdx % defaultAvatars.length];
            userId = 'pioneer_${colony.code}_$gNum';
            isOccupied = true;
          }
        }
      }

      parsed['ownerName'] = ownerName;
      parsed['ownerAvatar'] = avatar;
      parsed['isOccupied'] = isOccupied;
      parsed['userId'] = userId;
      list.add(parsed);
    }
    return list;
  }

  /// 🌟 Cached Result of a Birthplace Allocation
  CitizenPlot? _cachedBirthPlot;
  CitizenPlot? get currentBirthPlot => _cachedBirthPlot;

  /// 🌟 Returns the verified birthplace plot of the active logged in user
  CitizenPlot? get currentUserBirthPlot {
    if (_cachedBirthPlot != null) return _cachedBirthPlot;
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid != null) {
      if (_userBirthPlots.containsKey(uid)) {
        return _userBirthPlots[uid];
      }
      final plot = getCachedUserPlot(uid);
      if (plot != null) {
        _cachedBirthPlot = plot;
        return plot;
      }
    }
    return null;
  }

  /// 🪐 Returns the exact, verified planet code of the currently viewing user
  String getCurrentViewerPlanetCode() {
    if (_cachedBirthPlot != null) {
      return PoketCosmosDistanceService.instance
          .resolvePlanetCode(_cachedBirthPlot!.planetName);
    }
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid != null) {
      if (_userBirthPlots.containsKey(uid)) {
        return PoketCosmosDistanceService.instance
            .resolvePlanetCode(_userBirthPlots[uid]!.planetName);
      }
      final plot = getCachedUserPlot(uid);
      if (plot != null) {
        _cachedBirthPlot = plot;
        return PoketCosmosDistanceService.instance
            .resolvePlanetCode(plot.planetName);
      }
    }
    return 'EP';
  }

  /// 🪐 Returns the clean name of the current viewing user's home planet
  String getCurrentViewerPlanetName() {
    final code = getCurrentViewerPlanetCode();
    return PoketCosmosDistanceService.instance.getCleanPlanetName(code);
  }

  // User-scoped in-memory cache
  final Map<String, CitizenPlot> _userBirthPlots = {};

  String _userKey(String? uid, String key) =>
      (uid != null && uid.isNotEmpty) ? '${uid}_$key' : key;

  /// 🌍 Ensures the current user (new or existing) has a permanent Cosmos Born Address allocated
  Future<CitizenPlot> ensureUserHasAllocatedPlot(
      {String? defaultName, String? defaultAvatar}) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    String name = defaultName ?? '';
    String avatar = defaultAvatar ?? '🦁';

    if (uid != null && name.isEmpty) {
      try {
        final res = await SupaFlow.client
            .from('profile')
            .select('name, profile_image_url')
            .eq('id', uid)
            .maybeSingle();
        if (res != null) {
          name = res['name']?.toString() ?? 'Citizen';
          avatar = res['profile_image_url']?.toString() ?? '🦁';
        }
      } catch (_) {}
    }

    return allocateUserBirthplace(
      userName: name.isNotEmpty ? name : 'Citizen',
      avatar: avatar,
    );
  }

  /// Synchronous plot lookup from memory cache or registered profiles index
  CitizenPlot? getCachedUserPlot(String userId) {
    if (_userBirthPlots.containsKey(userId)) {
      return _userBirthPlots[userId];
    }
    if (PocketRobotService.isRobotId(userId)) {
      final meta = PocketRobotService.getCosmosAddressForRobotId(userId);
      final colony = getColonyByCode(meta['planetCode'] ?? 'EP');
      final plot = CitizenPlot(
        plotNumber: meta['plotNumber'] as int? ?? 1,
        userId: userId,
        userName: meta['robotName'] ?? 'Pocket Robot',
        userAvatar: '🤖',
        day: 7,
        pocketScore: 500,
        streetName: meta['streetName'] ?? colony.streetName,
        postOffice: meta['islandName'] ?? colony.islandName,
        countryName: meta['islandName'] ?? colony.islandName,
        planetName: meta['planetName'] ?? colony.planetName,
        postalPinCode: meta['cosmosPin'] ?? 'PKT-W01-${colony.code}-I01-P01',
        coordinates: Offset.zero,
        isVip: false,
        isPresident: false,
        tier: PlotDeedTier.standard,
        status: PlotStatus.occupied,
      );
      _userBirthPlots[userId] = plot;
      return plot;
    }
    if (_allRegisteredProfiles.isNotEmpty) {
      final profIdx = _allRegisteredProfiles.indexWhere((p) {
        final id = p['id']?.toString();
        final uid = p['user_id']?.toString();
        return (id != null && id == userId) || (uid != null && uid == userId);
      });
      if (profIdx != -1) {
        final prof = _allRegisteredProfiles[profIdx];
        final gNum = profIdx + 1;
        final parsed = parseGlobalPlotNumber(gNum);
        final colony = parsed['colony'] as CelestialColonyInfo;
        final localPlot = parsed['localPlotNumber'] as int;
        final wave = parsed['wave'] as int;
        final pinStr =
            'PKT-W${wave.toString().padLeft(2, '0')}-${colony.code}-I${wave.toString().padLeft(2, '0')}-P${localPlot.toString().padLeft(2, '0')}';
        final plot = CitizenPlot(
          plotNumber: gNum,
          userId: userId,
          userName: prof['name']?.toString() ?? 'Citizen #$gNum',
          userAvatar: prof['profile_image_url']?.toString() ?? '🦁',
          day: 1,
          pocketScore: prof['pocket_score'] as int? ?? 100,
          streetName: (wave == 1)
              ? colony.streetName
              : 'Wave $wave ${colony.streetName}',
          postOffice: (wave == 1)
              ? colony.islandName
              : generateInfiniteIslandName(colony.code, wave, wave),
          countryName: (wave == 1)
              ? colony.islandName
              : generateInfiniteIslandName(colony.code, wave, wave),
          planetName: colony.planetName,
          postalPinCode: pinStr,
          coordinates: Offset.zero,
          isVip: false,
          isPresident: false,
          tier: (localPlot <= 6
              ? PlotDeedTier.beachfront
              : PlotDeedTier.standard),
          status: PlotStatus.occupied,
        );
        _userBirthPlots[userId] = plot;
        return plot;
      }
    }
    return null;
  }

  /// 🎯 Loads or resolves the exact permanent CitizenPlot for ANY specific userId (Human or Robot)
  /// Guaranteed 100% consistent across Profile, Citadel Attack Page, and Island Aerial View!
  Future<CitizenPlot> getUserPlot({
    required String userId,
    String? fallbackName,
    String? fallbackAvatar,
  }) async {
    // 1. In-memory cache
    if (_userBirthPlots.containsKey(userId)) {
      return _userBirthPlots[userId]!;
    }

    // 2. Robot user check
    if (PocketRobotService.isRobotId(userId)) {
      final meta = PocketRobotService.getCosmosAddressForRobotId(userId);
      final colony = getColonyByCode(meta['planetCode'] ?? 'EP');
      final plot = CitizenPlot(
        plotNumber: meta['plotNumber'] as int? ?? 1,
        userId: userId,
        userName: meta['robotName'] ?? fallbackName ?? 'Pocket Robot',
        userAvatar: '🤖',
        day: 7,
        pocketScore: 500,
        streetName: meta['streetName'] ?? colony.streetName,
        postOffice: meta['islandName'] ?? colony.islandName,
        countryName: meta['islandName'] ?? colony.islandName,
        planetName: meta['planetName'] ?? colony.planetName,
        postalPinCode: meta['cosmosPin'] ?? 'PKT-W01-${colony.code}-I01-P01',
        coordinates: Offset.zero,
        isVip: false,
        isPresident: false,
        tier: PlotDeedTier.standard,
        status: PlotStatus.occupied,
      );
      _userBirthPlots[userId] = plot;
      return plot;
    }

    // 2.5 Check if user has relocated to another planet/plot
    final prefs = await SharedPreferences.getInstance();
    final relPin = prefs.getString('cosmos_user_relocated_pin_$userId');
    if (relPin != null && relPin.isNotEmpty) {
      final relPlanet =
          prefs.getString('cosmos_user_relocated_planet_$userId') ?? 'EP';
      final relWave = prefs.getInt('cosmos_user_relocated_wave_$userId') ?? 1;
      final relPlot = prefs.getInt('cosmos_user_relocated_plot_$userId') ?? 1;
      final colony = getColonyByCode(relPlanet);
      final gNum = calculateGlobalPlotNumber(
          wave: relWave, planetCode: relPlanet, localPlotNumber: relPlot);
      final plot = CitizenPlot(
        plotNumber: gNum,
        userId: userId,
        userName: fallbackName ?? 'Citizen',
        userAvatar: fallbackAvatar ?? '🦁',
        day: 1,
        pocketScore: 100,
        streetName: colony.streetName,
        postOffice: colony.islandName,
        countryName: colony.islandName,
        planetName: colony.planetName,
        postalPinCode: relPin,
        coordinates: Offset.zero,
        tier: (relPlot <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
        status: PlotStatus.occupied,
      );
      _userBirthPlots[userId] = plot;
      return plot;
    }

    // 3. Check registered profiles list first for deterministic sequential assignment
    if (_allRegisteredProfiles.isEmpty) {
      await loadAllRegisteredProfiles();
    }

    final profIdx = _allRegisteredProfiles.indexWhere((p) {
      final id = p['id']?.toString();
      final uid = p['user_id']?.toString();
      return (id != null && id == userId) || (uid != null && uid == userId);
    });

    if (profIdx != -1) {
      final prof = _allRegisteredProfiles[profIdx];
      final bio = prof['bio']?.toString() ?? '';
      final pinMatch =
          RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(bio);
      if (pinMatch != null) {
        final planetCode = pinMatch.group(2) ?? 'EP';
        final waveNum = int.tryParse(pinMatch.group(1) ?? '1') ?? 1;
        final localPlotNum = int.tryParse(pinMatch.group(4) ?? '1') ?? 1;
        final globalPlotNum = calculateGlobalPlotNumber(
          planetCode: planetCode,
          localPlotNumber: localPlotNum,
          wave: waveNum,
        );
        final colony = getColonyByCode(planetCode);
        final plot = CitizenPlot(
          plotNumber: globalPlotNum,
          userId: userId,
          userName: prof['name']?.toString() ?? fallbackName ?? 'Citizen',
          userAvatar:
              prof['profile_image_url']?.toString() ?? fallbackAvatar ?? '🦁',
          day: 1,
          pocketScore: 100,
          streetName: colony.streetName,
          postOffice: colony.islandName,
          countryName: colony.islandName,
          planetName: colony.planetName,
          postalPinCode: pinMatch.group(0) ??
              'PKT-W01-$planetCode-I01-P${localPlotNum.toString().padLeft(2, '0')}',
          coordinates: Offset.zero,
          isVip: false,
          isPresident: false,
          tier: (localPlotNum <= 6
              ? PlotDeedTier.beachfront
              : PlotDeedTier.standard),
          status: PlotStatus.occupied,
        );
        _userBirthPlots[userId] = plot;
        return plot;
      }

      final gNum = profIdx + 1;
      final parsed = parseGlobalPlotNumber(gNum);
      final colony = parsed['colony'] as CelestialColonyInfo;
      final localPlot = parsed['localPlotNumber'] as int;
      final wave = parsed['wave'] as int;
      final pinStr =
          'PKT-W${wave.toString().padLeft(2, '0')}-${colony.code}-I${wave.toString().padLeft(2, '0')}-P${localPlot.toString().padLeft(2, '0')}';
      final plot = CitizenPlot(
        plotNumber: gNum,
        userId: userId,
        userName: prof['name']?.toString() ?? fallbackName ?? 'Citizen #$gNum',
        userAvatar:
            prof['profile_image_url']?.toString() ?? fallbackAvatar ?? '🦁',
        day: 1,
        pocketScore: prof['pocket_score'] as int? ?? 100,
        streetName:
            (wave == 1) ? colony.streetName : 'Wave $wave ${colony.streetName}',
        postOffice: (wave == 1)
            ? colony.islandName
            : generateInfiniteIslandName(colony.code, wave, wave),
        countryName: (wave == 1)
            ? colony.islandName
            : generateInfiniteIslandName(colony.code, wave, wave),
        planetName: colony.planetName,
        postalPinCode: pinStr,
        coordinates: Offset.zero,
        isVip: false,
        isPresident: false,
        tier: (localPlot == 1)
            ? PlotDeedTier.royalCitadel
            : (localPlot <= 6
                ? PlotDeedTier.beachfront
                : PlotDeedTier.standard),
        status: PlotStatus.occupied,
      );
      _userBirthPlots[userId] = plot;
      return plot;
    }

    // 4. Supabase direct profile query fallback
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, user_id, bio, country, city, name, profile_image_url')
          .or('id.eq.$userId,user_id.eq.$userId')
          .maybeSingle();

      if (res != null) {
        final bio = res['bio']?.toString() ?? '';
        final pinMatch =
            RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(bio);
        if (pinMatch != null) {
          final planetCode = pinMatch.group(2) ?? 'EP';
          final waveNum = int.tryParse(pinMatch.group(1) ?? '1') ?? 1;
          final localPlotNum = int.tryParse(pinMatch.group(4) ?? '1') ?? 1;
          final globalPlotNum = calculateGlobalPlotNumber(
            planetCode: planetCode,
            localPlotNumber: localPlotNum,
            wave: waveNum,
          );
          final colony = getColonyByCode(planetCode);
          final plot = CitizenPlot(
            plotNumber: globalPlotNum,
            userId: userId,
            userName: res['name']?.toString() ?? fallbackName ?? 'Citizen',
            userAvatar:
                res['profile_image_url']?.toString() ?? fallbackAvatar ?? '🦁',
            day: 1,
            pocketScore: 100,
            streetName: colony.streetName,
            postOffice: colony.islandName,
            countryName: colony.islandName,
            planetName: colony.planetName,
            postalPinCode: pinMatch.group(0) ??
                'PKT-W01-$planetCode-I01-P${localPlotNum.toString().padLeft(2, '0')}',
            coordinates: Offset.zero,
            isVip: false,
            isPresident: false,
            tier: (localPlotNum <= 6
                ? PlotDeedTier.beachfront
                : PlotDeedTier.standard),
            status: PlotStatus.occupied,
          );
          _userBirthPlots[userId] = plot;
          return plot;
        }
      }
    } catch (e) {
      debugPrint('⚠️ getUserPlot Supabase non-fatal: $e');
    }

    // 5. Stable deterministic plot calculation based on userId
    final colIndex = userId.hashCode.abs() % colonies.length;
    final targetColony = colonies[colIndex];
    final plotNumber = ((userId.hashCode.abs() ~/ 10) % maxPlotsPerIsland) + 1;
    final pinStr =
        'PKT-W01-${targetColony.code}-I01-P${plotNumber.toString().padLeft(2, '0')}';

    final plot = CitizenPlot(
      plotNumber: plotNumber,
      userId: userId,
      userName: fallbackName ?? 'Citizen',
      userAvatar: fallbackAvatar ?? '🦁',
      day: 1,
      pocketScore: 100,
      streetName: targetColony.streetName,
      postOffice: targetColony.islandName,
      countryName: targetColony.islandName,
      planetName: targetColony.planetName,
      postalPinCode: pinStr,
      coordinates: Offset.zero,
      isVip: false,
      isPresident: false,
      tier: (plotNumber <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
      status: PlotStatus.occupied,
    );

    _userBirthPlots[userId] = plot;
    return plot;
  }

  /// 📬 Allocates the user's permanent birthplace in Pocket Cosmos
  Future<CitizenPlot> allocateUserBirthplace({
    String? inviteCode,
    required String userName,
    required String avatar,
    String? targetPlanetName,
    bool forceReallocate = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = SupaFlow.client.auth.currentUser?.id;

    if (forceReallocate && uid != null) {
      _userBirthPlots.remove(uid);
      _cachedBirthPlot = null;
    }

    // 0. Check in-memory user cache (if not forceReallocate)
    if (!forceReallocate && uid != null && _userBirthPlots.containsKey(uid)) {
      return _userBirthPlots[uid]!;
    }

    // 1. Check if authenticated user already has an allocated plot in Supabase profile
    if (!forceReallocate && uid != null) {
      try {
        final profileRes = await SupaFlow.client
            .from('profile')
            .select('country, city, bio, name, profile_image_url')
            .or('id.eq.$uid,user_id.eq.$uid')
            .maybeSingle();

        if (profileRes != null) {
          final bio = profileRes['bio']?.toString() ?? '';
          final pinRegex = RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)');
          final match = pinRegex.firstMatch(bio);
          if (match != null) {
            final wave = int.tryParse(match.group(1) ?? '1') ?? 1;
            final planetCode = match.group(2) ?? 'EP';
            final plotNum = int.tryParse(match.group(4) ?? '1') ?? 1;
            final colony = getColonyByCode(planetCode);

            final globalPlotNum = (plotNum <= maxPlotsPerIsland)
                ? calculateGlobalPlotNumber(
                    wave: wave,
                    planetCode: colony.code,
                    localPlotNumber: plotNum,
                  )
                : plotNum;

            final plot = CitizenPlot(
              plotNumber: globalPlotNum,
              userId: uid,
              userName: userName.isNotEmpty
                  ? userName
                  : (profileRes['name']?.toString() ?? 'Citizen'),
              userAvatar: avatar.isNotEmpty ? avatar : '🦁',
              day: 1,
              pocketScore: 500,
              streetName: colony.streetName,
              postOffice: colony.islandName,
              countryName: colony.islandName,
              planetName: colony.planetName,
              coordinates: Offset.zero,
              postalPinCode: match.group(0)!,
              tier: (plotNum <= 6
                  ? PlotDeedTier.beachfront
                  : PlotDeedTier.standard),
              status: PlotStatus.occupied,
            );
            _userBirthPlots[uid] = plot;
            _cachedBirthPlot = plot;
            return plot;
          }
        }
      } catch (e) {
        debugPrint('Supabase profile check non-fatal: $e');
      }
    }

    // 2. Check user-scoped local SharedPreferences (if not forceReallocate)
    if (!forceReallocate) {
      final userDeedKey = _userKey(uid, _kDeedClaimed);
      if (prefs.getBool(userDeedKey) == true) {
        final existing =
            _readSavedPlotFromPrefs(prefs, userName, avatar, uid: uid);
        if (existing != null) {
          if (uid != null) _userBirthPlots[uid] = existing;
          _cachedBirthPlot = existing;
          return existing;
        }
      }
    }

    // 3. Case B: Friend's Neighbor Reservation / Invite Code
    if (inviteCode != null && inviteCode.trim().isNotEmpty) {
      final reservation = await validateNeighborInviteCode(inviteCode.trim());
      if (reservation != null) {
        final int globalPlotNum;
        final int localPlotNum;
        final int reservationWave;
        final CelestialColonyInfo colony;

        if (reservation.plotNumber > maxPlotsPerIsland) {
          globalPlotNum = reservation.plotNumber;
          final parsed = parseGlobalPlotNumber(globalPlotNum);
          localPlotNum = parsed['localPlotNumber'] as int;
          reservationWave = parsed['wave'] as int;
          colony = parsed['colony'] as CelestialColonyInfo;
        } else {
          reservationWave = await getActiveWaveIndex();
          localPlotNum = reservation.plotNumber;
          colony = getColonyByPlanetName(reservation.planetName);
          globalPlotNum = calculateGlobalPlotNumber(
            wave: reservationWave,
            planetCode: colony.code,
            localPlotNumber: localPlotNum,
          );
        }

        // Mark the reserved plot occupied in this wave & colony
        await _markPlotOccupied(
            reservationWave, colony.code, localPlotNum);

        final plot = CitizenPlot(
          plotNumber: globalPlotNum,
          userId: uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          userName: userName.isNotEmpty ? userName : 'Adventurer',
          userAvatar: avatar.isNotEmpty ? avatar : '🦁',
          day: 1,
          pocketScore: 500,
          streetName: reservation.streetName,
          postOffice: reservation.islandName,
          countryName: reservation.islandName,
          planetName: colony.planetName,
          coordinates: Offset.zero,
          postalPinCode: reservation.cosmosPin,
          tier: (localPlotNum <= 6
              ? PlotDeedTier.beachfront
              : PlotDeedTier.standard),
          status: PlotStatus.occupied,
        );
        await saveBirthplace(plot);
        if (uid != null) _userBirthPlots[uid] = plot;
        return plot;
      }
    }

    // 4. Case A: Universal "Destiny" Allocation across ALL 10 Celestial Colonies!
    // Fetch live registered profiles from Supabase to count real cloud occupants
    final registeredProfiles =
        await loadAllRegisteredProfiles(forceRefresh: true);
    int currentWave = await getActiveWaveIndex();

    // Map real occupied plots for each planet in currentWave
    final colonyOccupancy = <String, Set<int>>{};
    for (final col in colonies) {
      colonyOccupancy[col.code] = {};
    }

    for (final prof in registeredProfiles) {
      final profUid =
          prof['id']?.toString() ?? prof['user_id']?.toString() ?? '';
      if (forceReallocate && uid != null && profUid == uid) {
        continue; // Exclude previous plot of the user being reallocated
      }

      final bio = prof['bio']?.toString() ?? '';
      final match =
          RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(bio);
      if (match != null) {
        final w = int.tryParse(match.group(1) ?? '1') ?? 1;
        final pCode = match.group(2) ?? 'EP';
        final pNum = int.tryParse(match.group(4) ?? '1') ?? 1;
        if (w == currentWave && colonyOccupancy.containsKey(pCode)) {
          colonyOccupancy[pCode]!.add(pNum);
        }
      }
    }

    // Filter colonies that still have space (< maxPlotsPerIsland = 25 plots)
    final availableColonies = colonies
        .where(
            (c) => (colonyOccupancy[c.code]?.length ?? 0) < maxPlotsPerIsland)
        .toList();

    CelestialColonyInfo pickedColony;
    int pickedPlotNum = 1;

    if (targetPlanetName != null && targetPlanetName.isNotEmpty) {
      pickedColony = getColonyByPlanetName(targetPlanetName);
      final occ = colonyOccupancy[pickedColony.code] ?? {};
      final activeReservations = await getActiveReservationsForIsland(
          pickedColony.planetId * 100 + currentWave);
      final reservedPlots = activeReservations.map((r) => r.plotNumber).toSet();
      for (int p = 1; p <= maxPlotsPerIsland; p++) {
        if (!occ.contains(p) && !reservedPlots.contains(p)) {
          pickedPlotNum = p;
          break;
        }
      }
    } else if (availableColonies.isEmpty) {
      // 🎉 ALL 250 PLOTS FULL in currentWave! Advance to Next Wave!
      currentWave++;
      await prefs.setInt(_kActiveWaveIndexKey, currentWave);
      pickedColony = colonies.first;
      pickedPlotNum = 1;
    } else {
      // Find minimum occupied count to ensure balanced round-robin distribution across all 10 planets
      int minCount = maxPlotsPerIsland;
      for (final c in availableColonies) {
        final count = colonyOccupancy[c.code]?.length ?? 0;
        if (count < minCount) minCount = count;
      }

      final leastOccupiedColonies = availableColonies
          .where((c) => (colonyOccupancy[c.code]?.length ?? 0) == minCount)
          .toList();

      // Interleaved round-robin selection based on registered profiles count
      final roundRobinIndex =
          registeredProfiles.length % leastOccupiedColonies.length;
      pickedColony = leastOccupiedColonies[roundRobinIndex];

      final occupiedInPicked = colonyOccupancy[pickedColony.code] ?? {};
      final activeReservations = await getActiveReservationsForIsland(
          pickedColony.planetId * 100 + currentWave);
      final reservedPlots = activeReservations.map((r) => r.plotNumber).toSet();

      for (int p = 1; p <= maxPlotsPerIsland; p++) {
        if (!occupiedInPicked.contains(p) && !reservedPlots.contains(p)) {
          pickedPlotNum = p;
          break;
        }
      }

      // If all plots on pickedColony are occupied or reserved, check other available colonies
      if (occupiedInPicked.contains(pickedPlotNum) ||
          reservedPlots.contains(pickedPlotNum)) {
        for (final col in availableColonies) {
          final occ = colonyOccupancy[col.code] ?? {};
          final res = await getActiveReservationsForIsland(
              col.planetId * 100 + currentWave);
          final resSet = res.map((r) => r.plotNumber).toSet();
          for (int p = 1; p <= maxPlotsPerIsland; p++) {
            if (!occ.contains(p) && !resSet.contains(p)) {
              pickedColony = col;
              pickedPlotNum = p;
              break;
            }
          }
          if (!occ.contains(pickedPlotNum) && !resSet.contains(pickedPlotNum)) {
            break;
          }
        }
      }
    }

    // Effective Island & Street Name
    final effectiveIslandName = (currentWave == 1)
        ? pickedColony.islandName
        : generateInfiniteIslandName(
            pickedColony.code, currentWave, currentWave);
    final effectiveStreetName = (currentWave == 1)
        ? pickedColony.streetName
        : 'Wave $currentWave ${pickedColony.streetName}';

    final globalPlotNum = calculateGlobalPlotNumber(
      wave: currentWave,
      planetCode: pickedColony.code,
      localPlotNumber: pickedPlotNum,
    );

    // Mark plot occupied
    await _markPlotOccupied(currentWave, pickedColony.code, pickedPlotNum);

    // Format Immutable Born Address: PKT-W{Wave}-{PlanetCode}-I{IslandNum}-P{GlobalPlotNum}
    final waveStr = currentWave.toString().padLeft(2, '0');
    final plotStr = globalPlotNum.toString().padLeft(3, '0');
    final cosmosPin = 'PKT-W$waveStr-${pickedColony.code}-I$waveStr-P$plotStr';

    final plot = CitizenPlot(
      plotNumber: globalPlotNum,
      userId: uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName.isNotEmpty ? userName : 'Adventurer',
      userAvatar: avatar.isNotEmpty ? avatar : '🦁',
      day: 1,
      pocketScore: 500,
      streetName: effectiveStreetName,
      postOffice: effectiveIslandName,
      countryName: effectiveIslandName,
      planetName: pickedColony.planetName,
      coordinates: Offset.zero,
      postalPinCode: cosmosPin,
      tier: (pickedPlotNum <= 6
          ? PlotDeedTier.beachfront
          : PlotDeedTier.standard),
      status: PlotStatus.occupied,
    );

    await saveBirthplace(plot);
    if (uid != null) _userBirthPlots[uid] = plot;
    return plot;
  }

  /// 💾 Permanently saves the citizen birthplace to local storage and Supabase
  Future<void> saveBirthplace(CitizenPlot plot) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = SupaFlow.client.auth.currentUser?.id;

    // 1. User-scoped storage
    final userDeedKey = _userKey(uid, _kDeedClaimed);
    await prefs.setBool(userDeedKey, true);
    await prefs.setString(_userKey(uid, _kPlanetName), plot.planetName);
    await prefs.setInt(_userKey(uid, _kPlotNumber), plot.plotNumber);
    await prefs.setString(_userKey(uid, _kIslandName), plot.countryName);
    await prefs.setString(_userKey(uid, _kStreetName), plot.streetName);
    await prefs.setString(_userKey(uid, _kCosmosPin), plot.postalPinCode);

    // 2. Global fallback keys
    await prefs.setString(_kPlanetName, plot.planetName);
    await prefs.setInt(_kPlotNumber, plot.plotNumber);
    await prefs.setString(_kIslandName, plot.countryName);
    await prefs.setInt(_kIslandId, 301);
    await prefs.setString(_kStreetName, plot.streetName);
    await prefs.setString(_kCosmosPin, plot.postalPinCode);
    await prefs.setBool(_kDeedClaimed, true);

    // 3. Save to Supabase profile table if user is authenticated (preserving existing bio)
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        String existingBio = '';
        String? profileDocId;
        try {
          final res = await SupaFlow.client
              .from('profile')
              .select('id, bio')
              .or('id.eq.${user.id},user_id.eq.${user.id}')
              .maybeSingle();
          if (res != null) {
            profileDocId = res['id']?.toString();
            existingBio = res['bio']?.toString() ?? '';
          }
        } catch (_) {}

        final cleanBio = existingBio
            .replaceAll(
                RegExp(r'\s*(\n\n)?🏡\s*PKT-W\d+-[A-Z]+-I\d+-P\d+.*$'), '')
            .trim();
        final newBio = cleanBio.isEmpty
            ? '🏡 Citizen of ${plot.countryName}, ${plot.planetName} (${plot.postalPinCode})'
            : '$cleanBio\n\n🏡 ${plot.postalPinCode}';

        final payload = {
          'country': plot.countryName,
          'city': plot.streetName,
          'bio': newBio,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (profileDocId != null && profileDocId.isNotEmpty) {
          try {
            await SupaFlow.client
                .from('profile')
                .update(payload)
                .eq('id', profileDocId);
          } catch (_) {}
        }
        try {
          await SupaFlow.client
              .from('profile')
              .update(payload)
              .eq('user_id', user.id);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('⚠️ Supabase profile update non-fatal: $e');
    }

    // 🏝️ Automatically enroll user into their Island Neighbors Group
    if (uid != null && uid.isNotEmpty) {
      final colony = getColonyByPlanetName(plot.planetName);
      final waveMatch = RegExp(r'PKT-W(\d+)').firstMatch(plot.postalPinCode);
      final wave = int.tryParse(waveMatch?.group(1) ?? '1') ?? 1;
      unawaited(
        PocketIslandGroupService.instance.ensureIslandGroupAndMember(
          planetCode: colony.code,
          planetName: plot.planetName,
          wave: wave,
          userId: uid,
          islandName: plot.countryName,
        ),
      );
    }
  }

  /// 📖 Reads saved plot from SharedPreferences
  CitizenPlot? _readSavedPlotFromPrefs(
      SharedPreferences prefs, String userName, String avatar,
      {String? uid}) {
    final planet = prefs.getString(_userKey(uid, _kPlanetName)) ??
        prefs.getString(_kPlanetName);
    final island = prefs.getString(_userKey(uid, _kIslandName)) ??
        prefs.getString(_kIslandName);
    final plotNum =
        prefs.getInt(_userKey(uid, _kPlotNumber)) ?? prefs.getInt(_kPlotNumber);
    final street = prefs.getString(_userKey(uid, _kStreetName)) ??
        prefs.getString(_kStreetName);
    final pin = prefs.getString(_userKey(uid, _kCosmosPin)) ??
        prefs.getString(_kCosmosPin);

    if (planet != null && island != null && plotNum != null) {
      int effectivePlotNum = plotNum;
      if (pin != null) {
        final pinMatch =
            RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(pin);
        if (pinMatch != null) {
          final pCode = pinMatch.group(2) ?? 'EP';
          final wNum = int.tryParse(pinMatch.group(1) ?? '1') ?? 1;
          final localP = int.tryParse(pinMatch.group(4) ?? '1') ?? 1;
          effectivePlotNum = calculateGlobalPlotNumber(
            planetCode: pCode,
            localPlotNumber: localP,
            wave: wNum,
          );
        }
      }

      return CitizenPlot(
        plotNumber: effectivePlotNum,
        userId: uid ?? SupaFlow.client.auth.currentUser?.id ?? 'user_local',
        userName: userName.isNotEmpty ? userName : 'Adventurer',
        userAvatar: avatar.isNotEmpty ? avatar : '🦁',
        day: 1,
        pocketScore: 500,
        streetName: street ?? 'Reefway Avenue',
        postOffice: island,
        countryName: island,
        planetName: planet,
        coordinates: Offset.zero,
        postalPinCode: pin ??
            'PKT-W01-EP-I01-P${effectivePlotNum.toString().padLeft(2, '0')}',
      );
    }
    return null;
  }

  // =========================================================================
  // 🌊 100-CRORE WAVE OCCUPANCY & "HOUSE FULL" ENGINE
  // =========================================================================

  /// Gets the currently active Wave Index (calculated from total users + remote admin override)
  Future<int> getActiveWaveIndex() async {
    int userBasedWave = 1;
    try {
      final res = await SupaFlow.client.from('profile').select('id');
      final count = (res as List).length;
      if (count > 0) {
        userBasedWave = ((count - 1) ~/ waveCapacity) + 1;
      }
    } catch (_) {}

    int remoteWave = 1;
    try {
      final res = await SupaFlow.client
          .from('app_codes')
          .select('class_code')
          .eq('class_name', 'cosmos_waves')
          .maybeSingle();
      if (res != null && res['class_code'] != null) {
        remoteWave = int.tryParse(res['class_code'].toString()) ?? 1;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final localWave = prefs.getInt(_kActiveWaveIndexKey) ?? 1;

    final effectiveWave =
        math.max(1, math.max(userBasedWave, math.max(remoteWave, localWave)));
    return effectiveWave;
  }

  /// 🌌 Admin or System unlocks next 10 Islands (+250 Plots across all 10 Planets)
  Future<int> unlockNextWave() async {
    final currentWave = await getActiveWaveIndex();
    final nextWave = currentWave + 1;

    // 1. Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kActiveWaveIndexKey, nextWave);

    // 2. Persist to Supabase app_codes table for global sync across all devices
    try {
      final existing = await SupaFlow.client
          .from('app_codes')
          .select('id')
          .eq('class_name', 'cosmos_waves')
          .maybeSingle();

      if (existing != null) {
        await SupaFlow.client.from('app_codes').update({
          'class_code': nextWave.toString(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('class_name', 'cosmos_waves');
      } else {
        await SupaFlow.client.from('app_codes').insert({
          'class_name': 'cosmos_waves',
          'class_code': nextWave.toString(),
          'description':
              'Global Active Waves in Poket Cosmos (10 islands per wave, 250 plots)',
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('⚠️ Supabase sync for cosmos_waves: $e');
    }

    // 3. Clear in-memory caches
    _colonyPlotsCache.clear();

    return nextWave;
  }

  /// Clears in-memory caches for all colony plots
  void clearPlotCaches() {
    _colonyPlotsCache.clear();
  }

  /// Gets occupied plot numbers (1..18) for a planet in a given wave
  Future<List<int>> _getOccupiedPlotsForPlanet(
      int wave, String planetCode) async {
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
  Future<void> _markPlotOccupied(
      int wave, String planetCode, int plotNumber) async {
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
        debugPrint(
            '🎉 HOUSE FULL REACHED! Wave W$wave is 100% full. Wave W$nextWave unlocked!');
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
        if (existingBio != null &&
            (existingBio.contains('PKT-EP') || existingBio.contains('PKT-W'))) {
          alreadyAllocated++;
          continue;
        }

        // Determine wave, colony and plot number using round-robin distribution
        final gNum = i + 1;
        final parsed = parseGlobalPlotNumber(gNum);
        final targetColony = parsed['colony'] as CelestialColonyInfo;
        final waveIdx = parsed['wave'] as int;
        final plotNum = parsed['localPlotNumber'] as int;

        final waveStr = waveIdx.toString().padLeft(2, '0');
        final plotStr = plotNum.toString().padLeft(2, '0');
        final cosmosPin =
            'PKT-W$waveStr-${targetColony.code}-I$waveStr-P$plotStr';

        final effectiveIslandName = (waveIdx == 1)
            ? targetColony.islandName
            : generateInfiniteIslandName(targetColony.code, waveIdx, waveIdx);
        final effectiveStreetName = (waveIdx == 1)
            ? targetColony.streetName
            : 'Wave $waveIdx ${targetColony.streetName}';

        final cleanBio = (existingBio ?? '')
            .replaceAll(
                RegExp(r'\s*(\n\n)?🏡\s*PKT-W\d+-[A-Z]+-I\d+-P\d+.*$'), '')
            .trim();
        final newBio = cleanBio.isEmpty
            ? '🏡 Citizen of $effectiveIslandName, ${targetColony.planetName} ($cosmosPin)'
            : '$cleanBio\n\n🏡 $cosmosPin';

        // Update profile in Supabase
        await SupaFlow.client.from('profile').update({
          'country': effectiveIslandName,
          'city': effectiveStreetName,
          'bio': newBio,
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
    if (_colonyPlotsCache.containsKey(cacheKey) &&
        _colonyPlotsCache[cacheKey]!.isNotEmpty) {
      return _colonyPlotsCache[cacheKey]!;
    }

    final coords = IslandAerialPainter.get35PlotCoordinates(colony.shapeStyle);
    final Map<int, CitizenPlot> plotMap = {};

    // 1. Real database users from Supabase profile table
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select(
              'id, user_id, name, display_name, profile_image_url, learning_day, day, pocket_score, bio, country, created_at')
          .order('created_at', ascending: true)
          .limit(1000);

      final List<dynamic> profiles = res as List<dynamic>;
      final prefs = await SharedPreferences.getInstance();
      final relocatedUids =
          prefs.getStringList('cosmos_all_relocated_uids') ?? [];

      for (int i = 0; i < profiles.length; i++) {
        final item = profiles[i] as Map<String, dynamic>;
        final String uid = (item['user_id'] ?? item['id'] ?? '').toString();
        if (uid.isEmpty) continue;

        // Determine if this user belongs to this colony
        bool matchesColony = false;
        int targetPlot = 0;

        // 🚪 Check if user has relocated to another planet/colony
        if (relocatedUids.contains(uid)) {
          final relPlanet =
              prefs.getString('cosmos_user_relocated_planet_$uid');
          final relWave = prefs.getInt('cosmos_user_relocated_wave_$uid') ?? 1;
          final relPlot = prefs.getInt('cosmos_user_relocated_plot_$uid') ?? 1;
          if (relPlanet != colony.code || relWave != wave) {
            continue; // 🚪 User moved away from this island! Old plot is now completely VACANT with '+'!
          }
          matchesColony = true;
          targetPlot = relPlot;
        }

        final String rawName =
            (item['display_name'] ?? item['name'] ?? 'Citizen ${i + 1}')
                .toString();
        final String name = rawName.isNotEmpty ? rawName : 'Citizen ${i + 1}';
        final String? avatarUrl = item['profile_image_url'] as String?;
        final int day =
            (item['learning_day'] ?? item['day'] ?? (25 + (i * 7) % 65)) as int;
        final int score =
            (item['pocket_score'] as num?)?.toInt() ?? (600 + (i * 45) % 800);
        final String? bio = item['bio'] as String?;

        // Check if bio contains cosmic pin (e.g., PKT-W01-MAR-I01-P04 or PKT-W01-TTN-I01-P177)
        if (bio != null && bio.contains('PKT-W')) {
          final regex = RegExp(r'PKT-W(\d+)-([A-Z]+)-I\d+-P(\d+)');
          final match = regex.firstMatch(bio);
          if (match != null) {
            final pinWave = int.tryParse(match.group(1) ?? '1') ?? 1;
            final pinCode = match.group(2) ?? '';
            final pinPlot = int.tryParse(match.group(3) ?? '1') ?? 1;
            if (pinWave == wave && pinCode == colony.code) {
              matchesColony = true;
              targetPlot = (pinPlot <= maxPlotsPerIsland)
                  ? pinPlot
                  : (((pinPlot - 1) % waveCapacity) % maxPlotsPerIsland) + 1;
            }
          }
        }

        // If not matched by bio, use deterministic round-robin wave & colony distribution only if user hasn't relocated
        if (!matchesColony && (bio == null || !bio.contains('PKT-W'))) {
          final gNum = i + 1;
          final parsed = parseGlobalPlotNumber(gNum);
          final userWave = parsed['wave'] as int;
          final userColony = parsed['colony'] as CelestialColonyInfo;
          if (userWave == wave && userColony.code == colony.code) {
            matchesColony = true;
            targetPlot = parsed['localPlotNumber'] as int;
          }
        }

        if (matchesColony &&
            targetPlot >= 1 &&
            targetPlot <= maxPlotsPerIsland) {
          final coord = (targetPlot - 1 < coords.length)
              ? coords[targetPlot - 1]
              : Offset.zero;
          final globalPlot = calculateGlobalPlotNumber(
            wave: wave,
            planetCode: colony.code,
            localPlotNumber: targetPlot,
          );
          final waveStr = wave.toString().padLeft(2, '0');
          final plotStr = globalPlot.toString().padLeft(3, '0');
          final pin = 'PKT-W$waveStr-${colony.code}-I$waveStr-P$plotStr';

          plotMap[targetPlot] = CitizenPlot(
            plotNumber: globalPlot,
            userId: uid,
            userName: name,
            userAvatar:
                (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : '🦁',
            day: math.max(1, day),
            pocketScore: score,
            streetName: colony.streetName,
            postOffice: colony.islandName,
            countryName: colony.islandName,
            planetName: colony.planetName,
            coordinates: coord,
            postalPinCode: pin,
            tier: (targetPlot <= 6
                ? PlotDeedTier.beachfront
                : PlotDeedTier.standard),
            status: PlotStatus.occupied,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fetching Supabase profiles for colony non-fatal: $e');
    }

    // 2. Populate Iconic & Algorithmic Pioneers ONLY on Wave 1 (Genesis Islands)
    // On Wave 2 and above, plots are strictly for real users and remain vacant ('+') until claimed!
    if (wave == 1) {
      final pioneers = getColonyPioneers(colony);
      for (final p in pioneers) {
        final localPlot = (p.plotNumber <= maxPlotsPerIsland)
            ? p.plotNumber
            : (((p.plotNumber - 1) % waveCapacity) % maxPlotsPerIsland) + 1;
        if (!plotMap.containsKey(localPlot)) {
          final coord = (localPlot - 1 < coords.length)
              ? coords[localPlot - 1]
              : Offset.zero;
          final globalPlot = calculateGlobalPlotNumber(
            wave: wave,
            planetCode: colony.code,
            localPlotNumber: localPlot,
          );
          final waveStr = wave.toString().padLeft(2, '0');
          final plotStr = globalPlot.toString().padLeft(3, '0');
          plotMap[localPlot] = p.copyWith(
            plotNumber: globalPlot,
            coordinates: coord,
            postalPinCode: 'PKT-W$waveStr-${colony.code}-I$waveStr-P$plotStr',
          );
        }
      }

      // Fill remaining up to 12 slots with deterministic pioneers on Wave 1 so genesis islands feel alive
      const defaultCandidateSlots = [1, 2, 3, 4, 6, 7, 9, 10, 11, 12, 14, 15];
      final defaultPioneerNames = [
        'Commander ${colony.islandName.split(' ').first}',
        'Dr. ${colony.code} Horizon',
        'Pioneer Zephyr',
        'Solar Warden',
        'Astro Navigator',
        'Cosmic Sentinel',
        'Starlight Scholar',
        'Nebula Guardian',
        'Orbital Scout',
        'Deep Void Ranger',
        'Galaxy Pioneer',
        'Aero Veteran',
      ];
      final defaultAvatars = [
        '🧑‍🚀',
        '👨‍🚀',
        '👩‍🚀',
        '🦁',
        '🦅',
        '🐺',
        '🦊',
        '🐯',
        '⚡',
        '🌟',
        '🚀',
        '✨'
      ];

      for (int k = 0;
          k < defaultCandidateSlots.length && plotMap.length < 12;
          k++) {
        final slot = defaultCandidateSlots[k];
        if (!plotMap.containsKey(slot)) {
          final coord =
              (slot - 1 < coords.length) ? coords[slot - 1] : Offset.zero;
          final globalPlot = calculateGlobalPlotNumber(
            wave: wave,
            planetCode: colony.code,
            localPlotNumber: slot,
          );
          final waveStr = wave.toString().padLeft(2, '0');
          final plotStr = globalPlot.toString().padLeft(3, '0');
          plotMap[slot] = CitizenPlot(
            plotNumber: globalPlot,
            userId: 'pioneer_${colony.code}_$globalPlot',
            userName: defaultPioneerNames[k % defaultPioneerNames.length],
            userAvatar: defaultAvatars[k % defaultAvatars.length],
            day: 28 + (k * 5) % 60,
            pocketScore: 650 + (k * 45) % 550,
            streetName: (wave == 1)
                ? colony.streetName
                : 'Wave $wave ${colony.streetName}',
            postOffice: colony.islandName,
            countryName: colony.islandName,
            planetName: colony.planetName,
            coordinates: coord,
            postalPinCode: 'PKT-W$waveStr-${colony.code}-I$waveStr-P$plotStr',
            tier: (slot <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
            status: PlotStatus.occupied,
          );
        }
      }
    }

    // 3. Inject current user's local birthplace or purchased plot if on this island
    final currentPlot = currentUserBirthPlot;
    if (currentPlot != null) {
      final viewerPlanetCode = PoketCosmosDistanceService.instance
          .resolvePlanetCode(currentPlot.planetName);
      if (viewerPlanetCode == colony.code) {
        final localPlot = (currentPlot.plotNumber <= maxPlotsPerIsland)
            ? currentPlot.plotNumber
            : (((currentPlot.plotNumber - 1) % waveCapacity) %
                    maxPlotsPerIsland) +
                1;
        final globalPlot = (currentPlot.plotNumber <= maxPlotsPerIsland)
            ? calculateGlobalPlotNumber(
                wave: wave,
                planetCode: colony.code,
                localPlotNumber: currentPlot.plotNumber,
              )
            : currentPlot.plotNumber;
        final coord = (localPlot - 1 < coords.length)
            ? coords[localPlot - 1]
            : Offset.zero;
        plotMap[localPlot] = currentPlot.copyWith(
          plotNumber: globalPlot,
          coordinates: coord,
        );
      }
    }

    final result = plotMap.values.toList()
      ..sort((a, b) => a.plotNumber.compareTo(b.plotNumber));
    _colonyPlotsCache[cacheKey] = result;
    return result;
  }

  /// 🏛️ Iconic Community Pioneers across all 10 celestial bodies
  List<CitizenPlot> getColonyPioneers(CelestialColonyInfo colony) {
    switch (colony.code) {
      case 'EP':
        return [
          _createPioneer(colony, 1, 'Captain Gaia', '🌿', 90, 1250,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 3, 'Arjun Varma', '🏄', 68, 840, PlotDeedTier.beachfront),
          _createPioneer(
              colony, 5, 'Sophia Chen', '🌸', 52, 710, PlotDeedTier.beachfront),
          _createPioneer(
              colony, 8, 'Marcus Brody', '☕', 34, 490, PlotDeedTier.standard),
          _createPioneer(
              colony, 12, 'Ananya Nair', '🎨', 82, 990, PlotDeedTier.standard),
        ];
      case 'MAR':
        return [
          _createPioneer(colony, 1, 'Commander Ares', '🧑‍🚀', 88, 1180,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Dr. Ryan Stone', '🚀', 64, 830,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Elena Rostova', '👩‍🚀', 45, 650,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 9, 'Kenji Sato', '🛰️', 38, 540, PlotDeedTier.standard),
          _createPioneer(colony, 14, 'Maya Al-Mansoor', '🔭', 74, 920,
              PlotDeedTier.standard),
        ];
      case 'JUP':
        return [
          _createPioneer(colony, 1, 'Solaria Prime', '⚡', 92, 1310,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Galileo Vance', '🪐', 70, 880,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 7, 'Lyra Thorne', '✨', 55, 730, PlotDeedTier.standard),
          _createPioneer(
              colony, 10, 'Zephyr Cole', '🌌', 40, 580, PlotDeedTier.standard),
        ];
      case 'LUN':
        return [
          _createPioneer(colony, 1, 'Apollo Warden', '🌕', 85, 1150,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Luna Armstrong', '👩‍🚀', 62, 810,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 5, 'Viktor Cross', '👨‍🚀', 48, 670,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 11, 'Selene Zhao', '✨', 76, 930, PlotDeedTier.standard),
        ];
      case 'SAT':
        return [
          _createPioneer(colony, 1, 'Titan Overseer', '🪐', 89, 1220,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Cassini Drake', '🛰️', 66, 850,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 7, 'Rhea Sterling', '💍', 51, 690, PlotDeedTier.standard),
          _createPioneer(
              colony, 13, 'Hyperion Reed', '✨', 36, 510, PlotDeedTier.standard),
        ];
      case 'EUR':
        return [
          _createPioneer(colony, 1, 'Cryo Explorer', '❄️', 84, 1140,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Frost Voyager', '🧊', 58, 770,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Glacia North', '🔬', 44, 620,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 10, 'Boreas Vance', '🔭', 72, 900, PlotDeedTier.standard),
        ];
      case 'VEN':
        return [
          _createPioneer(colony, 1, 'Aphrodite Sentinel', '☀️', 87, 1190,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 4, 'Solar Flare', '🔥', 61, 800, PlotDeedTier.beachfront),
          _createPioneer(
              colony, 8, 'Aurelia Blaze', '✨', 47, 660, PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Helios Thorne', '🌟', 78, 940,
              PlotDeedTier.standard),
        ];
      case 'TTN':
        return [
          _createPioneer(colony, 1, 'Kraken Voyager', '🛶', 86, 1170,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Methane Drifter', '🌊', 59, 790,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Dune Navigator', '🪐', 43, 610,
              PlotDeedTier.standard),
          _createPioneer(
              colony, 11, 'Huygens Lee', '🔬', 75, 910, PlotDeedTier.standard),
        ];
      case 'PLT':
        return [
          _createPioneer(colony, 1, 'Tombaugh Warden', '🌌', 91, 1280,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Starlight Nomad', '✨', 65, 840,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 8, 'Charon Shade', '❄️', 50, 680, PlotDeedTier.standard),
          _createPioneer(colony, 13, 'Nyx Celestial', '💫', 79, 950,
              PlotDeedTier.standard),
        ];
      case 'NEP':
        return [
          _createPioneer(colony, 1, 'Triton Vanguard', '🌊', 88, 1200,
              PlotDeedTier.beachfront),
          _createPioneer(
              colony, 4, 'Azure Siren', '🐬', 63, 820, PlotDeedTier.beachfront),
          _createPioneer(
              colony, 7, 'Abyss Diver', '🌀', 49, 670, PlotDeedTier.standard),
          _createPioneer(
              colony, 12, 'Oceanic Prime', '✨', 77, 930, PlotDeedTier.standard),
        ];
      case 'MER':
        return [
          _createPioneer(colony, 1, 'Commander Caloris', '🧑‍🚀', 89, 1210,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Hermes Vance', '🚀', 66, 840,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Sol Vanguard', '☀️', 75, 960,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Scorched Nomad', '🔥', 48, 670,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Iron Ridge Scout', '🛡️', 55, 730,
              PlotDeedTier.standard),
          _createPioneer(colony, 9, 'Cinder Explorer', '🌋', 42, 590,
              PlotDeedTier.standard),
          _createPioneer(colony, 10, 'Zenith Sunfire', '✨', 61, 810,
              PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Apollo Mercury', '🌟', 82, 1050,
              PlotDeedTier.standard),
        ];
      case 'GAN':
        return [
          _createPioneer(colony, 1, 'Perrine Overseer', '🛡️', 90, 1260,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Magnetic Warden', '⚡', 67, 850,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Grooved Ice Nomad', '🛰️', 58, 770,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Jupiter Shield', '🪐', 72, 920,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Citadel Sentinel', '⚔️', 46, 640,
              PlotDeedTier.standard),
          _createPioneer(colony, 9, 'Galvanic Ranger', '🌌', 63, 820,
              PlotDeedTier.standard),
          _createPioneer(colony, 11, 'Perrine Pathfinder', '✨', 52, 710,
              PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Solar Dynamo', '🌟', 84, 1100,
              PlotDeedTier.standard),
        ];
      case 'URA':
        return [
          _createPioneer(colony, 1, 'Miranda Sentinel', '💎', 87, 1190,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Cyan Climber', '🧊', 63, 820,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Aquamarine Ranger', '🌌', 71, 910,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Ice Cliff Nomad', '❄️', 50, 690,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Methane Skywatcher', '🔭', 44, 620,
              PlotDeedTier.standard),
          _createPioneer(colony, 9, 'Turquoise Voyager', '✨', 59, 780,
              PlotDeedTier.standard),
          _createPioneer(colony, 11, 'Borealis Drift', '🌪️', 76, 970,
              PlotDeedTier.standard),
          _createPioneer(
              colony, 12, 'Frost Apex', '🌟', 85, 1120, PlotDeedTier.standard),
        ];
      case 'TRI':
        return [
          _createPioneer(colony, 1, 'Geyser Voyager', '🔱', 89, 1230,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Cantaloupe Drifter', '❄️', 65, 840,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Nitrogen Vanguard', '🌊', 74, 940,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Kuiper Outpost', '🪐', 47, 650,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Sub-Zero Nomad', '🧊', 53, 720,
              PlotDeedTier.standard),
          _createPioneer(colony, 9, 'Cryo Spout Scout', '🚀', 60, 790,
              PlotDeedTier.standard),
          _createPioneer(colony, 11, 'Retrograde Star', '✨', 78, 990,
              PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Triton Sovereign', '🌟', 86, 1140,
              PlotDeedTier.standard),
        ];
      case 'KEP':
        return [
          _createPioneer(colony, 1, 'Exoplanet Pioneer', '🌌', 92, 1350,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 3, 'Cygnus Botanist', '🌿', 70, 890,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Nebula Explorer', '✨', 80, 1020,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 6, 'Super-Earth Settler', '🪐', 56, 750,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 7, 'Biolum Sentinel', '🌸', 64, 830,
              PlotDeedTier.standard),
          _createPioneer(colony, 9, 'Interstellar Nomad', '🚀', 49, 680,
              PlotDeedTier.standard),
          _createPioneer(colony, 10, 'Alien Flora Warden', '🌺', 62, 810,
              PlotDeedTier.standard),
          _createPioneer(colony, 12, 'Cygnus Voyager', '🌟', 88, 1190,
              PlotDeedTier.standard),
        ];
      default:
        return [
          _createPioneer(colony, 1, 'Cosmic Pioneer', '🌟', 80, 1000,
              PlotDeedTier.beachfront),
          _createPioneer(colony, 4, 'Starlight Explorer', '🚀', 50, 700,
              PlotDeedTier.standard),
        ];
    }
  }

  CitizenPlot _createPioneer(
    CelestialColonyInfo colony,
    int localPlotNum,
    String name,
    String avatar,
    int day,
    int score,
    PlotDeedTier tier,
  ) {
    final globalPlotNum = calculateGlobalPlotNumber(
      wave: 1,
      planetCode: colony.code,
      localPlotNumber: localPlotNum,
    );
    final plotStr = globalPlotNum.toString().padLeft(3, '0');
    return CitizenPlot(
      plotNumber: globalPlotNum,
      userId: 'pioneer_${colony.code}_$globalPlotNum',
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
    final uid = SupaFlow.client.auth.currentUser?.id;

    // Clear global keys
    await prefs.remove(_kPlanetName);
    await prefs.remove(_kIslandId);
    await prefs.remove(_kIslandName);
    await prefs.remove(_kPlotNumber);
    await prefs.remove(_kStreetName);
    await prefs.remove(_kCosmosPin);
    await prefs.remove(_kDeedClaimed);

    // Clear user-scoped keys
    if (uid != null) {
      await prefs.remove(_userKey(uid, _kPlanetName));
      await prefs.remove(_userKey(uid, _kIslandId));
      await prefs.remove(_userKey(uid, _kIslandName));
      await prefs.remove(_userKey(uid, _kPlotNumber));
      await prefs.remove(_userKey(uid, _kStreetName));
      await prefs.remove(_userKey(uid, _kCosmosPin));
      await prefs.remove(_userKey(uid, _kDeedClaimed));
      _userBirthPlots.remove(uid);
    }
    _userBirthPlots.clear();
    _cachedBirthPlot = null;
  }

  // =========================================================================
  // 🤝 4-HOUR NEIGHBOR PRE-BOOKING & INVITATION SYSTEM
  // =========================================================================

  /// 🎟️ Generates a 4-hour Neighbor Pre-Booking Pass with unique PIN and short invite code
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
    // 6-digit numeric invite code for seamless sharing (e.g. 583921)
    final sixDigitCode = (100000 + math.Random().nextInt(900000)).toString();
    final code = sixDigitCode;

    final expiresAt = DateTime.now().add(const Duration(hours: 4));

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
    final Map<String, dynamic> store =
        rawJson != null ? jsonDecode(rawJson) : {};
    store[code] = pass.toJson();
    store['PKT-$code'] = pass.toJson();
    store[cosmosPin] = pass.toJson();
    await prefs.setString(_kReservationsKey, jsonEncode(store));

    // Cloud sync to Supabase app_codes table for seamless cross-device neighbor invite
    try {
      await SupaFlow.client.from('app_codes').insert({
        'class_name': 'neighbor_pass',
        'class_code': code,
        'description': jsonEncode(pass.toJson()),
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': expiresAt.toIso8601String(),
      });
    } catch (_) {}

    return pass;
  }

  /// 📋 Gets all active (unexpired) reservations for a specific island
  Future<List<NeighborReservationPass>> getActiveReservationsForIsland(
      int islandId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    final List<NeighborReservationPass> active = [];
    final now = DateTime.now();

    if (rawJson != null) {
      try {
        final Map<String, dynamic> store = jsonDecode(rawJson);
        final Map<String, dynamic> cleanedStore = {};
        bool storeModified = false;

        for (final entry in store.entries) {
          try {
            final pass = NeighborReservationPass.fromJson(
                entry.value as Map<String, dynamic>);
            if (!now.isAfter(pass.expiresAt)) {
              cleanedStore[entry.key] = entry.value;
              if (pass.islandId == islandId &&
                  !active.any((p) => p.plotNumber == pass.plotNumber)) {
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
      } catch (_) {}
    }

    // Also check cloud reservations from Supabase
    try {
      final res = await SupaFlow.client
          .from('app_codes')
          .select('description')
          .eq('class_name', 'neighbor_pass')
          .eq('is_active', true);
      for (final row in res) {
        final desc = row['description']?.toString();
        if (desc != null && desc.isNotEmpty) {
          try {
            final pass = NeighborReservationPass.fromJson(jsonDecode(desc));
            if (!now.isAfter(pass.expiresAt) && pass.islandId == islandId) {
              if (!active.any((p) => p.plotNumber == pass.plotNumber)) {
                active.add(pass);
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    return active;
  }

  /// 🗺️ Gets map of plotNumber -> NeighborReservationPass for O(1) map painter lookups
  Future<Map<int, NeighborReservationPass>> getActiveReservationsMap(
      int islandId) async {
    final list = await getActiveReservationsForIsland(islandId);
    return {for (final pass in list) pass.plotNumber: pass};
  }

  /// ❌ Cancels an active reservation
  Future<void> cancelReservation(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    if (rawJson != null) {
      try {
        final Map<String, dynamic> store = jsonDecode(rawJson);
        if (store.remove(code) != null) {
          await prefs.setString(_kReservationsKey, jsonEncode(store));
        }
      } catch (_) {}
    }
    try {
      await SupaFlow.client
          .from('app_codes')
          .delete()
          .eq('class_name', 'neighbor_pass')
          .eq('class_code', code);
    } catch (_) {}
  }

  /// 🎟️ Generates a quick test neighbor reservation pass (PKT-TEST)
  Future<NeighborReservationPass> generateQuickTestFriendPass(
      {int plotNumber = 12}) async {
    const testCode = 'PKT-TEST';
    final expiresAt = DateTime.now().add(const Duration(hours: 4));
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
    final Map<String, dynamic> store =
        rawJson != null ? jsonDecode(rawJson) : {};
    store[testCode] = pass.toJson();
    await prefs.setString(_kReservationsKey, jsonEncode(store));

    return pass;
  }

  /// 🔍 Validates a Neighbor Pre-Booking Code or Born Address
  Future<NeighborReservationPass?> validateNeighborInviteCode(
      String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    // 1. Check local registry of created passes in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kReservationsKey);
    if (rawJson != null) {
      try {
        final Map<String, dynamic> store = jsonDecode(rawJson);
        if (store.containsKey(cleanCode)) {
          final pass = NeighborReservationPass.fromJson(store[cleanCode]);
          if (!DateTime.now().isAfter(pass.expiresAt)) {
            return pass;
          }
        }
      } catch (_) {}
    }

    // 2. Check cloud Supabase app_codes for remote friend referral pass
    try {
      final res = await SupaFlow.client
          .from('app_codes')
          .select('description')
          .eq('class_name', 'neighbor_pass')
          .or('class_code.eq.$cleanCode,class_code.eq.${cleanCode.replaceFirst('PKT-', '')}')
          .eq('is_active', true)
          .maybeSingle();
      if (res != null && res['description'] != null) {
        final pass = NeighborReservationPass.fromJson(
            jsonDecode(res['description'].toString()));
        if (!DateTime.now().isAfter(pass.expiresAt)) {
          return pass;
        }
      }
    } catch (_) {}

    // 3. Check unique referral code format: PKT-{PlanetCode}-{PlotNum}-{Token} or PKT-{PlanetCode}-{PlotNum}
    final shortPassRegex = RegExp(r'^PKT-([A-Z]+)-(\d+)(?:-(\d+))?$');
    final shortMatch = shortPassRegex.firstMatch(cleanCode);
    if (shortMatch != null) {
      final planetCode = shortMatch.group(1)!;
      final hostPlot = int.tryParse(shortMatch.group(2)!) ?? 1;
      final colony = colonies.firstWhere(
        (c) => c.code == planetCode,
        orElse: () => colonies.first,
      );

      final activeWave = await getActiveWaveIndex();
      int neighborPlot = hostPlot + 1;
      if (neighborPlot > maxPlotsPerIsland) neighborPlot = hostPlot - 1;
      if (neighborPlot < 1) neighborPlot = 2;

      final waveStr = activeWave.toString().padLeft(2, '0');
      final neighborPlotStr = neighborPlot.toString().padLeft(2, '0');
      final pin = 'PKT-W$waveStr-$planetCode-I$waveStr-P$neighborPlotStr';

      return NeighborReservationPass(
        code: cleanCode,
        islandId: colony.planetId * 100 + activeWave,
        islandName: (activeWave == 1)
            ? colony.islandName
            : generateInfiniteIslandName(colony.code, activeWave, activeWave),
        planetName: colony.planetName,
        streetName: colony.streetName,
        plotNumber: neighborPlot,
        hostUserName: 'Neighbor Friend (Plot #$hostPlot)',
        cosmosPin: pin,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      );
    }

    // 4. Check dynamic Born Address format: PKT-W{wave}-{planetCode}-I{island}-P{plot}
    // e.g. PKT-W01-EP-I01-P07
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

      // Reserve adjacent neighbor plot (clamped within 1..25)
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
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      );
    }

    // 5. Graceful deterministic fallback for valid custom referral codes
    if (cleanCode.length >= 3) {
      final hash = cleanCode.hashCode.abs();
      final colony = colonies[hash % colonies.length];
      final plot =
          (hash % (maxPlotsPerIsland - 1)) + 2; // plot between 2 and 18

      return NeighborReservationPass(
        code: cleanCode,
        islandId: colony.planetId * 100 + 1,
        islandName: colony.islandName,
        planetName: colony.planetName,
        streetName: colony.streetName,
        plotNumber: plot,
        hostUserName: 'Cosmos Citizen (Host)',
        cosmosPin:
            'PKT-W01-${colony.code}-I01-P${plot.toString().padLeft(2, '0')}',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      );
    }

    return null;
  }
}

/// 🎟️ Model representing a 4-Hour Neighbor Reservation Pass
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
  int get minutesRemaining =>
      expiresAt.difference(DateTime.now()).inMinutes.clamp(0, 240);

  String get shareMessage => "🏡 POCKET WORLD (പോക്കറ്റ് വേൾഡ്)\n"
      "----------------------------------------\n"
      "Hey! I reserved Plot #$plotNumber for you right next to my house in Pocket Cosmos!\n\n"
      "📍 Location: $streetName, $islandName\n"
      "🪐 Celestial Body: $planetName\n"
      "🔑 Born PIN / Referral Code: $code\n\n"
      "Join as my neighbor using my exclusive Born Code before the 4-hour pass expires!\n\n"
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
