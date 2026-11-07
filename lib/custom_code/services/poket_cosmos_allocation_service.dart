import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

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

  // Scaling Constants (25 plots per island, 250 citizens per wave across 10 planets)
  static const int maxPlotsPerIsland = 25;
  static const int totalPlanetsCount = 10;
  static const int waveCapacity = 250; // 10 planets * 25 plots

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

  /// Finds colony info matching a planet code (e.g. 'EP', 'MAR', 'JUP')
  CelestialColonyInfo getColonyByCode(String code) {
    final upper = code.trim().toUpperCase();
    for (final c in colonies) {
      if (c.code.toUpperCase() == upper) return c;
    }
    return getColonyByPlanetName(code);
  }

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

  /// 🌐 Computes the unique global sequential plot number (1 to 250 in Wave 1, 251 to 500 in Wave 2, etc.)
  static int calculateGlobalPlotNumber({
    int wave = 1,
    required String planetCode,
    required int localPlotNumber,
  }) {
    final cleanCode = planetCode.trim().toUpperCase();
    int planetIndex = colonies.indexWhere((c) => c.code.toUpperCase() == cleanCode);
    if (planetIndex == -1) planetIndex = 0; // Default to Earth
    final clampedLocal = localPlotNumber.clamp(1, maxPlotsPerIsland);
    final clampedWave = math.max(1, wave);
    return ((clampedWave - 1) * waveCapacity) + (planetIndex * maxPlotsPerIsland) + clampedLocal;
  }

  /// 🌐 Parses a global sequential plot number back into wave, planet colony, and local plot number
  static Map<String, dynamic> parseGlobalPlotNumber(int globalPlotNumber) {
    final gNum = math.max(1, globalPlotNumber);
    final wave = ((gNum - 1) ~/ waveCapacity) + 1;
    final withinWave = (gNum - 1) % waveCapacity;
    final planetIndex = (withinWave ~/ maxPlotsPerIsland).clamp(0, colonies.length - 1);
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

  /// 🌐 Returns all islands generated across planets for the given active wave count
  static List<Map<String, dynamic>> getAllIslandsCatalog({int maxWaves = 1}) {
    final List<Map<String, dynamic>> list = [];
    for (int w = 1; w <= math.max(1, maxWaves); w++) {
      for (final colony in colonies) {
        final islandName = (w == 1)
            ? colony.islandName
            : generateInfiniteIslandName(colony.code, w, w);
        list.add({
          'wave': w,
          'colony': colony,
          'planetCode': colony.code,
          'planetName': colony.planetName,
          'islandName': islandName,
          'streetName': colony.streetName,
          'climate': colony.climate,
          'shapeStyle': colony.shapeStyle,
          'totalPlots': maxPlotsPerIsland,
          'occupiedCount': math.min(maxPlotsPerIsland, 8 + (w * 3) + (colony.planetId % 9)),
        });
      }
    }
    return list;
  }

  /// 🌐 Returns all plots across waves for Search Page Plots Grid with real owner info
  static List<Map<String, dynamic>> getWavePlotsCatalog({int maxWaves = 2}) {
    final List<Map<String, dynamic>> list = [];
    final int endPlot = math.max(1, maxWaves) * waveCapacity;

    // Iconic community pioneers directory
    final Map<String, String> pioneerMap = {
      'EP_1': 'Captain Gaia',
      'EP_3': 'Arjun Varma',
      'EP_5': 'Sophia Chen',
      'EP_8': 'Marcus Brody',
      'EP_12': 'Ananya Nair',
      'MAR_1': 'Commander Ares',
      'MAR_3': 'Dr. Ryan Stone',
      'MAR_6': 'Elena Rostova',
      'MAR_9': 'Kenji Sato',
      'MAR_14': 'Maya Al-Mansoor',
      'JUP_1': 'Solaria Prime',
      'JUP_4': 'Zephyr Vance',
      'JUP_7': 'Lyra Thorne',
      'JUP_11': 'Orion Reed',
      'SAT_1': 'Kronos Sovereign',
      'SAT_4': 'Cassini Drake',
      'SAT_8': 'Amber Vale',
      'LUN_1': 'Selene Apex',
      'LUN_3': 'Neil Armstrong Jr.',
      'LUN_6': 'Luna Starlight',
      'EUR_1': 'Frost Voyager',
      'EUR_4': 'Glacia North',
      'EUR_8': 'Boreas Vance',
      'VEN_1': 'Cytherean Queen',
      'VEN_4': 'Solaris Pyre',
      'VEN_7': 'Ignis Drake',
      'TTN_1': 'Titan Overseer',
      'TTN_4': 'Methane Ranger',
      'TTN_7': 'Aero Swift',
      'PLT_1': 'Hades Sovereign',
      'PLT_4': 'Nyx Shadow',
      'PLT_8': 'Charon Pilot',
      'NEP_1': 'Triton Vanguard',
      'NEP_4': 'Azure Siren',
      'NEP_7': 'Abyss Diver',
    };

    final allRobots = PocketRobotService.getAllRobots();

    for (int gNum = 1; gNum <= endPlot; gNum++) {
      final parsed = parseGlobalPlotNumber(gNum);
      final colony = parsed['colony'] as CelestialColonyInfo;
      final int lNum = parsed['localPlotNumber'] as int;
      final int wave = parsed['wave'] as int;
      final key = '${colony.code}_$lNum';

      String ownerName = 'Available';
      String avatar = '🟢';
      bool isOccupied = false;

      if (wave == 1) {
        // 1. Check pioneer in wave 1
        if (pioneerMap.containsKey(key)) {
          ownerName = pioneerMap[key]!;
          avatar = (lNum == 1) ? '👑' : '🏡';
          isOccupied = true;
        }
        // 2. Check robot citizens on specific plots (10, 15, 18, 22)
        else if ((lNum == 10 || lNum == 15 || lNum == 18 || lNum == 22) && allRobots.isNotEmpty) {
          final robot = allRobots[(gNum * 7) % allRobots.length];
          ownerName = robot.name;
          avatar = '🤖';
          isOccupied = true;
        }
      }

      // 3. Check registered user in-memory cache
      for (final plot in instance._userBirthPlots.values) {
        if (plot.planetName == colony.planetName && plot.plotNumber == lNum) {
          ownerName = plot.userName;
          avatar = plot.userAvatar;
          isOccupied = true;
          break;
        }
      }

      parsed['ownerName'] = ownerName;
      parsed['ownerAvatar'] = avatar;
      parsed['isOccupied'] = isOccupied;
      list.add(parsed);
    }
    return list;
  }

  /// 🌟 Cached Result of a Birthplace Allocation
  CitizenPlot? _cachedBirthPlot;
  CitizenPlot? get currentBirthPlot => _cachedBirthPlot;

  // User-scoped in-memory cache
  final Map<String, CitizenPlot> _userBirthPlots = {};

  String _userKey(String? uid, String key) =>
      (uid != null && uid.isNotEmpty) ? '${uid}_$key' : key;

  /// 🌍 Ensures the current user (new or existing) has a permanent Cosmos Born Address allocated
  Future<CitizenPlot> ensureUserHasAllocatedPlot({String? defaultName, String? defaultAvatar}) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    String name = defaultName ?? '';
    String avatar = defaultAvatar ?? '🦁';

    if (uid != null && name.isEmpty) {
      try {
        final res = await SupaFlow.client.from('profile').select('name, profile_image_url').eq('id', uid).maybeSingle();
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

    // 3. Supabase profile query
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, user_id, bio, country, city, name, profile_image_url')
          .or('id.eq.$userId,user_id.eq.$userId')
          .maybeSingle();

      if (res != null) {
        final bio = res['bio']?.toString() ?? '';
        final pinMatch = RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)').firstMatch(bio);
        if (pinMatch != null) {
          final planetCode = pinMatch.group(2) ?? 'EP';
          final plotNum = int.tryParse(pinMatch.group(4) ?? '1') ?? 1;
          final colony = getColonyByCode(planetCode);
          final plot = CitizenPlot(
            plotNumber: plotNum,
            userId: userId,
            userName: res['name']?.toString() ?? fallbackName ?? 'Citizen',
            userAvatar: res['profile_image_url']?.toString() ?? fallbackAvatar ?? '🦁',
            day: 1,
            pocketScore: 100,
            streetName: colony.streetName,
            postOffice: colony.islandName,
            countryName: colony.islandName,
            planetName: colony.planetName,
            postalPinCode: pinMatch.group(0) ?? 'PKT-W01-$planetCode-I01-P${plotNum.toString().padLeft(2, '0')}',
            coordinates: Offset.zero,
            isVip: false,
            isPresident: false,
            tier: (plotNum == 1) ? PlotDeedTier.royalCitadel : (plotNum <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
            status: PlotStatus.occupied,
          );
          _userBirthPlots[userId] = plot;
          return plot;
        }
      }
    } catch (e) {
      debugPrint('⚠️ getUserPlot Supabase non-fatal: $e');
    }

    // 4. Stable deterministic plot calculation based on userId
    final colIndex = userId.hashCode.abs() % colonies.length;
    final targetColony = colonies[colIndex];
    final plotNumber = ((userId.hashCode.abs() ~/ 10) % maxPlotsPerIsland) + 1;
    final pinStr = 'PKT-W01-${targetColony.code}-I01-P${plotNumber.toString().padLeft(2, '0')}';

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
      tier: (plotNumber == 1) ? PlotDeedTier.royalCitadel : (plotNumber <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = SupaFlow.client.auth.currentUser?.id;

    // 0. Check in-memory user cache
    if (uid != null && _userBirthPlots.containsKey(uid)) {
      return _userBirthPlots[uid]!;
    }

    // 1. Check if authenticated user already has an allocated plot in Supabase profile
    if (uid != null) {
      try {
        final profileRes = await SupaFlow.client
            .from('profile')
            .select('country, city, bio, name, profile_image_url')
            .eq('id', uid)
            .maybeSingle();

        if (profileRes != null) {
          final bio = profileRes['bio']?.toString() ?? '';
          final pinRegex = RegExp(r'PKT-W(\d+)-([A-Z]+)-I(\d+)-P(\d+)');
          final match = pinRegex.firstMatch(bio);
          if (match != null) {
            final planetCode = match.group(2) ?? 'EP';
            final plotNum = int.tryParse(match.group(4) ?? '1') ?? 1;
            final colony = getColonyByCode(planetCode);

            final plot = CitizenPlot(
              plotNumber: plotNum,
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
              tier: (plotNum == 1)
                  ? PlotDeedTier.presidential
                  : (plotNum <= 6
                      ? PlotDeedTier.beachfront
                      : PlotDeedTier.standard),
              status: PlotStatus.occupied,
            );
            _userBirthPlots[uid] = plot;
            return plot;
          }
        }
      } catch (e) {
        debugPrint('Supabase profile check non-fatal: $e');
      }
    }

    // 2. Check user-scoped local SharedPreferences
    final userDeedKey = _userKey(uid, _kDeedClaimed);
    if (prefs.getBool(userDeedKey) == true) {
      final existing = _readSavedPlotFromPrefs(prefs, userName, avatar, uid: uid);
      if (existing != null) {
        if (uid != null) _userBirthPlots[uid] = existing;
        return existing;
      }
    }

    // 3. Case B: Friend's Neighbor Reservation / Invite Code
    if (inviteCode != null && inviteCode.trim().isNotEmpty) {
      final reservation = await validateNeighborInviteCode(inviteCode.trim());
      if (reservation != null) {
        final colony = getColonyByPlanetName(reservation.planetName);
        final activeWave = await getActiveWaveIndex();

        // Mark the reserved plot occupied in this wave & colony
        await _markPlotOccupied(activeWave, colony.code, reservation.plotNumber);

        final plot = CitizenPlot(
          plotNumber: reservation.plotNumber,
          userId: uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
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
        if (uid != null) _userBirthPlots[uid] = plot;
        return plot;
      }
    }

    // 4. Case A: Universal "Destiny" Allocation across ALL 10 Celestial Colonies!
    int currentWave = await getActiveWaveIndex();

    // Check all 10 colonies occupancy
    final colonyOccupancy = <CelestialColonyInfo, List<int>>{};
    for (final col in colonies) {
      final occ = await _getOccupiedPlotsForPlanet(currentWave, col.code);
      colonyOccupancy[col] = occ;
    }

    // Filter colonies that still have space (< 20 plots)
    final availableColonies = colonies
        .where((c) => (colonyOccupancy[c]?.length ?? 0) < maxPlotsPerIsland)
        .toList();

    CelestialColonyInfo pickedColony;
    int pickedPlotNum = 1;

    if (targetPlanetName != null && targetPlanetName.isNotEmpty) {
      pickedColony = getColonyByPlanetName(targetPlanetName);
      final occ = colonyOccupancy[pickedColony] ?? [];
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
      // 🎉 ALL 200 PLOTS FULL! Advance to Next Wave!
      currentWave++;
      await prefs.setInt(_kActiveWaveIndexKey, currentWave);
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

      // Truly randomize / distribute among least occupied colonies
      final randIdx = math.Random().nextInt(leastOccupiedColonies.length);
      pickedColony = leastOccupiedColonies[randIdx];

      final occupiedInPicked = colonyOccupancy[pickedColony] ?? [];
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
      userId: uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
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

    // 3. Save to Supabase profile table if user is authenticated
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
  CitizenPlot? _readSavedPlotFromPrefs(
      SharedPreferences prefs, String userName, String avatar,
      {String? uid}) {
    final planet = prefs.getString(_userKey(uid, _kPlanetName)) ??
        prefs.getString(_kPlanetName);
    final island = prefs.getString(_userKey(uid, _kIslandName)) ??
        prefs.getString(_kIslandName);
    final plotNum = prefs.getInt(_userKey(uid, _kPlotNumber)) ??
        prefs.getInt(_kPlotNumber);
    final street = prefs.getString(_userKey(uid, _kStreetName)) ??
        prefs.getString(_kStreetName);
    final pin = prefs.getString(_userKey(uid, _kCosmosPin)) ??
        prefs.getString(_kCosmosPin);

    if (planet != null && island != null && plotNum != null) {
      return CitizenPlot(
        plotNumber: plotNum,
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
            'PKT-W01-EP-I01-P${plotNum.toString().padLeft(2, '0')}',
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
          .limit(500);

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
