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
