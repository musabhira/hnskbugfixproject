import 'package:flutter/material.dart';

/// 🌌 Poket Planet Model with Slot Limits & Realistic Visual Features
class PoketPlanet {
  final int id;
  final String name;
  final String theme;
  final String tagLine;
  final Color primaryColor;
  final Color glowColor;
  final double radius;
  final double orbitDistance;
  final double orbitSpeed;
  final int totalPlots;
  final int occupiedPlots;
  final List<PoketCountryMap> countryMaps;

  const PoketPlanet({
    required this.id,
    required this.name,
    required this.theme,
    required this.tagLine,
    required this.primaryColor,
    required this.glowColor,
    required this.radius,
    required this.orbitDistance,
    required this.orbitSpeed,
    required this.totalPlots,
    required this.occupiedPlots,
    required this.countryMaps,
  });

  int get availablePlots => (totalPlots - occupiedPlots).clamp(0, totalPlots);
  bool get isFull => occupiedPlots >= totalPlots;
}

/// 🏝️ Distinct Architectural Island Geometry Styles
enum IslandShapeStyle {
  crescentLagoon,   // C-shaped crescent wrapping around turquoise lagoon
  sCurveArchipelago,// S-shaped winding dragon island
  starAtoll,        // 4/5-point tropical star island with deep sea inlets
  dualIsletBridge,  // Twin islands connected by sandbar/wooden bridge
  ringAtoll,        // Circular atoll with large interior turquoise lagoon
  hookPeninsula,    // J-shaped fishhook with elongated beach
  heartSanctuary,   // Heart-shaped paradise island
  cloverBays,       // 3-leaf clover with 3 deep lagoons
  fortressPlateau,  // Diamond/hexagonal coral plateau
  citadelApex,      // Royal octagonal palace island with golden domes
}

/// 🗺️ Country / Island Map inside a Planet
class PoketCountryMap {
  final int id;
  final String name;
  final String tag;
  final Color landColor;
  final Color waterColor;
  final int totalSlots;
  final int filledSlots;
  final String climate;
  final IconData climateIcon;
  final String description;
  final String islandEmoji;
  final List<IslandLandmark> landmarks;
  final bool isPresidential;
  final int shapeSeed;
  final IslandShapeStyle shapeStyle;

  const PoketCountryMap({
    required this.id,
    required this.name,
    required this.tag,
    required this.landColor,
    this.waterColor = const Color(0xFF0284C7),
    required this.totalSlots,
    required this.filledSlots,
    required this.climate,
    required this.climateIcon,
    this.description = 'Lush coastal island surrounded by oceanic waters',
    this.islandEmoji = '🏝️',
    this.landmarks = const [],
    this.isPresidential = false,
    this.shapeSeed = 1,
    this.shapeStyle = IslandShapeStyle.crescentLagoon,
  });

  int get availableSlots => (totalSlots - filledSlots).clamp(0, totalSlots);
  double get occupancyRatio =>
      totalSlots > 0 ? (filledSlots / totalSlots).clamp(0.0, 1.0) : 0.0;
}

/// 🏷️ Plot Deed Tier: Defines Prestige & Real Estate Value
enum PlotDeedTier {
  standard,
  beachfront,
  hilltop,
  presidential,
  royalCitadel,
}

extension PlotDeedTierExtension on PlotDeedTier {
  String get displayName {
    switch (this) {
      case PlotDeedTier.standard:
        return 'Standard Residential';
      case PlotDeedTier.beachfront:
        return 'Beachfront Coastal Manor';
      case PlotDeedTier.hilltop:
        return 'Hilltop Scenic Estate';
      case PlotDeedTier.presidential:
        return 'Presidential Apex Citadel';
      case PlotDeedTier.royalCitadel:
        return 'Royal Founder Sanctuary';
    }
  }

  int get baseValuationPS {
    switch (this) {
      case PlotDeedTier.standard:
        return 500;
      case PlotDeedTier.beachfront:
        return 1200;
      case PlotDeedTier.hilltop:
        return 1800;
      case PlotDeedTier.presidential:
        return 3500;
      case PlotDeedTier.royalCitadel:
        return 5000;
    }
  }
}

/// ⚡ Citizen Activity & Eviction Status for Land Registry
enum PlotStatus {
  occupied,
  forSale,
  reserved,
  evictionWarning, // Days inactive > 3
  evictedVacant, // Evicted to free slot for active players
}

/// 🏡 Citizen Plot with Full Postal Identity Deed & Real Estate Registry
class CitizenPlot {
  final int plotNumber;
  final String userId;
  final String userName;
  final String userAvatar;
  final int day;
  final int pocketScore;
  final String streetName;
  final String postOffice;
  final String countryName;
  final String planetName;
  final Offset coordinates; // Map location on the island
  final bool isVip;
  final bool isPresident;
  final PlotDeedTier tier;
  final PlotStatus status;
  final int inactivityDays;
  final int deedValuePS;
  final String postalPinCode;

  const CitizenPlot({
    required this.plotNumber,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.day,
    required this.pocketScore,
    required this.streetName,
    required this.postOffice,
    required this.countryName,
    required this.planetName,
    required this.coordinates,
    this.isVip = false,
    this.isPresident = false,
    this.tier = PlotDeedTier.standard,
    this.status = PlotStatus.occupied,
    this.inactivityDays = 0,
    this.deedValuePS = 500,
    this.postalPinCode = 'PK-100',
  });

  /// 📮 Official Registered Postal Address:
  /// e.g. "Mus'ab House, Plot #1 (Presidential Apex Citadel), King's Coastal Highway, P.O. Genesis Post, PIN: PK-100, Genesis Valley Island, Poket Earth Prime"
  String get formalPostalAddress =>
      '$userName House, Plot #$plotNumber (${tier.displayName}), $streetName, P.O. $postOffice, PIN: $postalPinCode, $countryName, $planetName';

  /// ⚠️ Inactivity & Eviction Rules (User Directive)
  /// If player score drops below 500 or remains inactive for days, they receive warnings
  bool get isEvictionRisk => inactivityDays >= 7 || pocketScore < 100;
  bool get isWarningNotice => inactivityDays >= 3 && inactivityDays < 7;

  CitizenPlot copyWith({
    int? plotNumber,
    String? userId,
    String? userName,
    String? userAvatar,
    int? day,
    int? pocketScore,
    String? streetName,
    String? postOffice,
    String? countryName,
    String? planetName,
    Offset? coordinates,
    bool? isVip,
    bool? isPresident,
    PlotDeedTier? tier,
    PlotStatus? status,
    int? inactivityDays,
    int? deedValuePS,
    String? postalPinCode,
  }) {
    return CitizenPlot(
      plotNumber: plotNumber ?? this.plotNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      day: day ?? this.day,
      pocketScore: pocketScore ?? this.pocketScore,
      streetName: streetName ?? this.streetName,
      postOffice: postOffice ?? this.postOffice,
      countryName: countryName ?? this.countryName,
      planetName: planetName ?? this.planetName,
      coordinates: coordinates ?? this.coordinates,
      isVip: isVip ?? this.isVip,
      isPresident: isPresident ?? this.isPresident,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      inactivityDays: inactivityDays ?? this.inactivityDays,
      deedValuePS: deedValuePS ?? this.deedValuePS,
      postalPinCode: postalPinCode ?? this.postalPinCode,
    );
  }
}

/// 🚗 Vehicle Travel Modes across Poket World
enum TravelMode {
  walk,
  car,
  airplane,
  plane,
  boat,
  train,
}

/// 🛩️ Interactive Travel Vehicle Simulation Model
class PoketVehicle {
  final String id;
  final String name;
  final TravelMode mode;
  final IconData icon;
  final double speed;
  Offset currentPosition;
  Offset? destination;
  double headingAngle; // Radians for vehicle rotation
  bool isMoving;

  PoketVehicle({
    required this.id,
    required this.name,
    required this.mode,
    required this.icon,
    this.speed = 1.0,
    required this.currentPosition,
    this.destination,
    this.headingAngle = 0.0,
    this.isMoving = false,
  });
}

/// 🏛️ Island Civic Landmark
enum LandmarkType {
  presidentialCitadel,
  airportTerminal,
  centralPostOffice,
  marinaHarbor,
  policeStation,
  academyLibrary,
}

class IslandLandmark {
  final String id;
  final String name;
  final LandmarkType type;
  final Offset coordinates;
  final IconData icon;
  final String description;
  final Color accentColor;

  const IslandLandmark({
    required this.id,
    required this.name,
    required this.type,
    required this.coordinates,
    required this.icon,
    required this.description,
    this.accentColor = const Color(0xFFFFD700),
  });
}

/// ⚖️ Cosmos Inactivity & Downgrade Policy Logic
class CosmosInactivityPolicy {
  static const int safeThresholdPS = 500;
  static const int dailyDecayPS = 25;
  static const int maxInactiveDaysWarning = 3;
  static const int maxInactiveDaysEviction = 10;

  /// Calculates decayed score when a citizen is inactive
  static int calculateDecayedScore({
    required int currentScore,
    required int inactiveDays,
  }) {
    if (inactiveDays < maxInactiveDaysWarning) return currentScore;
    final decay = (inactiveDays - maxInactiveDaysWarning + 1) * dailyDecayPS;
    return (currentScore - decay).clamp(0, currentScore);
  }

  /// Determines plot status based on score and inactive days
  static PlotStatus evaluatePlotStatus({
    required int score,
    required int inactiveDays,
  }) {
    if (score == 0 && inactiveDays >= maxInactiveDaysEviction) {
      return PlotStatus.evictedVacant;
    }
    if (inactiveDays >= maxInactiveDaysWarning || score < 100) {
      return PlotStatus.evictionWarning;
    }
    return PlotStatus.occupied;
  }
}

/// 📮 Immutable Cosmos Address Record for any user in the 1 Crore+ Galaxy
class CosmosAddress {
  final int planetId;
  final String planetName;
  final int islandId;
  final String islandName;
  final int slotNumber;
  final int cycle; // Loop iteration count (0 for initial cycle)
  final String postalPinCode;
  final bool isPresidential;

  const CosmosAddress({
    required this.planetId,
    required this.planetName,
    required this.islandId,
    required this.islandName,
    required this.slotNumber,
    required this.cycle,
    required this.postalPinCode,
    this.isPresidential = false,
  });

  String get formattedLocation =>
      '$islandName • Slot #$slotNumber ($planetName)';
}

/// 🌌 Infinite Cosmos Loop Allocation Engine
/// Scales seamlessly from 1 user to 1 Crore (10 Million+) and 50 Crore+ users:
/// - Each island holds strictly 50 habit plots.
/// - The universe loops systematically across 16 major celestial spheres
///   (8 Planets + Major Habitable Moons & Dwarf Planets):
///   Earth Prime 🌍 -> The Moon 🌕 -> Mercury ⚪ -> Venus 🟡 -> Mars 🔴 -> Ceres 🥔 ->
///   Jupiter 🟠 -> Europa 🧊 -> Ganymede 🪐 -> Callisto ☄️ -> Saturn 🪐 -> Titan 🪐 ->
///   Enceladus ❄️ -> Uranus 💎 -> Neptune 🌊 -> Triton 🔱 -> Pluto ❄️.
/// - Once Pluto's current island fills up with 50 users, the loop cycles back to Earth Prime
///   generating Island Cycle N+1 with CEFR linguistic progression tiers (Genesis -> Nova -> Apex -> Elite -> Mastery)!
/// - Users are assigned a permanent initial home upon account creation.
/// - Users can spend Pocket Score (e.g. 500 PS) to relocate to their dream planet or moon!
class CosmosLoopAllocationService {
  static const int slotsPerIsland = 50;

  static const List<String> planetOrderNames = [
    'Earth Prime 🌍',
    'The Moon 🌕',
    'Mercury ⚪',
    'Venus 🟡',
    'Mars 🔴',
    'Ceres (Asteroid Belt) 🥔',
    'Jupiter 🟠',
    'Europa (Jovian Ocean) 🧊',
    'Ganymede 🪐',
    'Callisto ☄️',
    'Saturn 🪐',
    'Titan 🪐',
    'Enceladus ❄️',
    'Uranus 💎',
    'Neptune 🌊',
    'Triton 🔱',
    'Pluto ❄️',
  ];

  static const List<int> planetOrderIds = [
    3,   // Earth
    30,  // The Moon
    1,   // Mercury
    2,   // Venus
    4,   // Mars
    45,  // Ceres
    5,   // Jupiter
    51,  // Europa
    52,  // Ganymede
    53,  // Callisto
    6,   // Saturn
    61,  // Titan
    62,  // Enceladus
    7,   // Uranus
    8,   // Neptune
    81,  // Triton
    9,   // Pluto
  ];

  static int get totalCelestialSpheres => planetOrderNames.length;

  static const List<String> englishThemes = [
    'Vocabulary Bay',
    'Sentence Reef',
    'Grammar Isle',
    'Idiom Atoll',
    'Phonics Cay',
    'Fluency Haven',
    'Syntax Strand',
    'Lexicon Oasis',
    'Verb Vista',
    'Pronoun Peninsula',
    'Tense Territory',
    'Adverb Atoll',
    'Echo Lagoon',
    'Diction Dune',
    'Rhythm Reach',
    'Accent Isle',
    'Clause Cove',
    'Metaphor Marina',
    'Dialogue Drift',
    'Proverb Port',
    'Synonym Shoal',
    'Antonym Atoll',
    'Jargon Jungle',
    'Poetry Point',
    'Vowel Valley',
    'Consonant Coast',
    'Slang Sound',
    'Spelling Sand',
    'Rhetoric Ridge',
    'Mastery Cay',
  ];

  /// CEFR Epoch Progression Prefixes & Suffixes for Infinite Cycles
  static const List<String> cycleTierPrefixes = [
    '',               // Cycle 1: Classic (A1 Genesis)
    'Upper ',         // Cycle 2: A2 Ascendant
    'Nova ',          // Cycle 3: B1 Intermediate
    'Grand ',         // Cycle 4: B2 Fluency
    'Apex ',          // Cycle 5: C1 Advanced
    'Mastery ',       // Cycle 6: C2 Mastery
  ];

  /// 📍 Deterministic algorithm: Maps any user index (0 to 100,000,000+) to their exact celestial sphere, island, and slot
  static CosmosAddress allocateUser({required int userIndex, String? userName}) {
    if (userIndex == 0) {
      // User #0 is Supreme President Mus'ab on Crown Apex
      return const CosmosAddress(
        planetId: 3,
        planetName: 'Earth Prime 🌍',
        islandId: 1,
        islandName: 'Crown Apex 👑',
        slotNumber: 1,
        cycle: 0,
        postalPinCode: 'PK-EP-CR01-001',
        isPresidential: true,
      );
    }

    final int effectiveIndex = userIndex - 1; // 0-based for all regular citizens
    final int islandBatch = effectiveIndex ~/ slotsPerIsland;
    final int slotNumber = (effectiveIndex % slotsPerIsland) + 1;
    final int celestialIndex = islandBatch % totalCelestialSpheres;
    final int cycle = islandBatch ~/ totalCelestialSpheres;

    final planetId = planetOrderIds[celestialIndex];
    final planetName = planetOrderNames[celestialIndex];

    final islandId = islandBatch + 2; // Island #1 is reserved for Crown Apex
    final themeIndex = islandBatch % englishThemes.length;
    final baseTheme = englishThemes[themeIndex];

    // Compute linguistic CEFR tier name for infinite scaling without collision
    final prefixIndex = cycle.clamp(0, cycleTierPrefixes.length - 1);
    final prefix = cycleTierPrefixes[prefixIndex];
    final islandName = cycle < cycleTierPrefixes.length
        ? '$prefix$baseTheme'
        : '$baseTheme (Epoch ${_toRoman(cycle + 1)})';

    final pinCode =
        'PK-C$planetId-IS${islandId.toString().padLeft(3, '0')}-SL${slotNumber.toString().padLeft(2, '0')}';

    return CosmosAddress(
      planetId: planetId,
      planetName: planetName,
      islandId: islandId,
      islandName: islandName,
      slotNumber: slotNumber,
      cycle: cycle,
      postalPinCode: pinCode,
      isPresidential: false,
    );
  }

  /// 🔄 Check if a citizen has sufficient Pocket Score to switch worlds
  static bool canRelocate({required int userScore, int costPS = 500}) {
    return userScore >= costPS;
  }

  static String _toRoman(int number) {
    if (number <= 1) return 'I';
    if (number == 2) return 'II';
    if (number == 3) return 'III';
    if (number == 4) return 'IV';
    if (number == 5) return 'V';
    if (number == 6) return 'VI';
    if (number == 7) return 'VII';
    if (number == 8) return 'VIII';
    if (number == 9) return 'IX';
    if (number == 10) return 'X';
    return number.toString();
  }
}
