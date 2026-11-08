import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';

/// 🧭 Geographic Scales / Tiers of Travel across Poket Cosmos
enum CosmosTravelTier {
  interplanetary, // Planet to Planet (e.g. Earth to Jupiter)
  islandToIsland,  // Same Planet, Different Island (e.g. Earth Atoll to Earth Bay)
  plotToPlot,      // Same Island, Different Plot (e.g. Plot #02 to Plot #19)
}

/// 🚗 Vehicle Catalog for Poket Cosmos Transit
class CosmosVehicle {
  final String id;
  final String name;
  final String malName;
  final CosmosTravelTier tier;
  final String emoji;
  final IconData iconData;
  final double speedMultiplier;
  final int baseDurationSeconds;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;
  final String speedLabel;

  const CosmosVehicle({
    required this.id,
    required this.name,
    required this.malName,
    required this.tier,
    required this.emoji,
    required this.iconData,
    required this.speedMultiplier,
    required this.baseDurationSeconds,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    required this.speedLabel,
  });

  int calculateEtaSeconds(double distanceKm) {
    return (baseDurationSeconds / speedMultiplier).round().clamp(3, 18);
  }
}

/// 🌟 Standard Vehicle Catalogs across All 3 Travel Tiers
class CosmosVehicleCatalog {
  // Tier 1: Interplanetary Spaceships
  static const starship = CosmosVehicle(
    id: 'starship',
    name: 'Starship Apex',
    malName: 'സ്റ്റാർഷിപ്പ്',
    tier: CosmosTravelTier.interplanetary,
    emoji: '🚀',
    iconData: Icons.rocket_launch_rounded,
    speedMultiplier: 1.0,
    baseDurationSeconds: 10,
    primaryColor: Color(0xFF38BDF8),
    secondaryColor: Color(0xFF0284C7),
    description: 'Balanced celestial spacecraft with dual plasma thrust.',
    speedLabel: 'Standard • 10s',
  );

  static const warpShuttle = CosmosVehicle(
    id: 'warp_shuttle',
    name: 'Hyper Warp Shuttle',
    malName: 'ഹൈപ്പർ വാർപ്പ് ഷട്ടിൽ',
    tier: CosmosTravelTier.interplanetary,
    emoji: '⚡',
    iconData: Icons.flash_on_rounded,
    speedMultiplier: 1.6,
    baseDurationSeconds: 6,
    primaryColor: Color(0xFFFFD700),
    secondaryColor: Color(0xFFFF9100),
    description: 'High-speed orbital interceptor with triple afterburner trail.',
    speedLabel: 'Hyper Warp • 6s',
  );

  static const ionCruiser = CosmosVehicle(
    id: 'ion_cruiser',
    name: 'Ion Deep-Space Cruiser',
    malName: 'അയോൺ ക്രൂയിസർ',
    tier: CosmosTravelTier.interplanetary,
    emoji: '🛰️',
    iconData: Icons.satellite_alt_rounded,
    speedMultiplier: 0.8,
    baseDurationSeconds: 13,
    primaryColor: Color(0xFFA855F7),
    secondaryColor: Color(0xFF6B21A8),
    description: 'Heavy exploration vessel with pulsating ion ring engines.',
    speedLabel: 'Cruiser • 13s',
  );

  static const List<CosmosVehicle> interplanetaryVehicles = [
    starship,
    warpShuttle,
    ionCruiser,
  ];

  // Tier 2: Island to Island Water/Air Voyagers
  static const aeroplane = CosmosVehicle(
    id: 'aeroplane',
    name: 'Aeroplane Cruiser',
    malName: 'ഏറോപ്ലെയിൻ',
    tier: CosmosTravelTier.islandToIsland,
    emoji: '✈️',
    iconData: Icons.airplanemode_active_rounded,
    speedMultiplier: 1.4,
    baseDurationSeconds: 7,
    primaryColor: Color(0xFF38BDF8),
    secondaryColor: Color(0xFF0284C7),
    description: 'High-altitude passenger jet with dual contrails.',
    speedLabel: 'Airway • 7s',
  );

  static const speedboat = CosmosVehicle(
    id: 'speedboat',
    name: 'Hydrofoil Speedboat',
    malName: 'സ്പീഡ് ബോട്ട്',
    tier: CosmosTravelTier.islandToIsland,
    emoji: '🚤',
    iconData: Icons.directions_boat_filled_rounded,
    speedMultiplier: 1.0,
    baseDurationSeconds: 10,
    primaryColor: Color(0xFF00E5FF),
    secondaryColor: Color(0xFF00B0FF),
    description: 'Fast ocean boat cutting water with foamy spray wakes.',
    speedLabel: 'Fast Sea • 10s',
  );

  static const cruiseShip = CosmosVehicle(
    id: 'cruise_ship',
    name: 'Oceanic Cruise Ship',
    malName: 'സമുദ്ര കപ്പൽ',
    tier: CosmosTravelTier.islandToIsland,
    emoji: '🚢',
    iconData: Icons.directions_boat_rounded,
    speedMultiplier: 0.7,
    baseDurationSeconds: 14,
    primaryColor: Color(0xFFF59E0B),
    secondaryColor: Color(0xFFD97706),
    description: 'Grand luxury liner cruising smoothly across the open ocean.',
    speedLabel: 'Scenic Sea • 14s',
  );

  static const List<CosmosVehicle> islandVehicles = [
    aeroplane,
    speedboat,
    cruiseShip,
  ];

  // Tier 3: Plot to Plot Street Vehicles (Same Island)
  static const motorbike = CosmosVehicle(
    id: 'motorbike',
    name: 'Cyber Motorbike',
    malName: 'മോട്ടോർ ബൈക്ക്',
    tier: CosmosTravelTier.plotToPlot,
    emoji: '🏍️',
    iconData: Icons.two_wheeler_rounded,
    speedMultiplier: 1.5,
    baseDurationSeconds: 4,
    primaryColor: Color(0xFFFF9100),
    secondaryColor: Color(0xFFFF3D00),
    description: 'Zippy two-wheeler with bright headlight beam.',
    speedLabel: 'Express • 4s',
  );

  static const islandBuggy = CosmosVehicle(
    id: 'island_buggy',
    name: 'Island Buggy Rover',
    malName: 'ഐലൻഡ് ബഗ്ഗി',
    tier: CosmosTravelTier.plotToPlot,
    emoji: '🚗',
    iconData: Icons.electric_car_rounded,
    speedMultiplier: 1.0,
    baseDurationSeconds: 6,
    primaryColor: Color(0xFF22C55E),
    secondaryColor: Color(0xFF16A34A),
    description: 'Electric 4-wheel rover navigating island avenues.',
    speedLabel: 'Electric • 6s',
  );

  static const bicycle = CosmosVehicle(
    id: 'bicycle',
    name: 'Island Bicycle',
    malName: 'സൈക്കിൾ',
    tier: CosmosTravelTier.plotToPlot,
    emoji: '🚲',
    iconData: Icons.pedal_bike_rounded,
    speedMultiplier: 0.7,
    baseDurationSeconds: 9,
    primaryColor: Color(0xFFFBBF24),
    secondaryColor: Color(0xFFD97706),
    description: 'Relaxing pedal cycle strolling past neighborhood gardens.',
    speedLabel: 'Stroll • 9s',
  );

  static const List<CosmosVehicle> plotVehicles = [
    motorbike,
    islandBuggy,
    bicycle,
  ];

  static List<CosmosVehicle> getVehiclesForTier(CosmosTravelTier tier) {
    switch (tier) {
      case CosmosTravelTier.interplanetary:
        return interplanetaryVehicles;
      case CosmosTravelTier.islandToIsland:
        return islandVehicles;
      case CosmosTravelTier.plotToPlot:
        return plotVehicles;
    }
  }

  static CosmosVehicle getDefaultVehicleForTier(CosmosTravelTier tier) {
    return getVehiclesForTier(tier).first;
  }
}

/// 🗺️ Complete Multi-Tier Transit Navigation Request Model
class CosmosTransitRoute {
  final CosmosTravelTier tier;
  final String originPlanetCode;
  final String originPlanetName;
  final String originIslandName;
  final int originPlotNumber;
  final String destPlanetCode;
  final String destPlanetName;
  final String destIslandName;
  final int destPlotNumber;
  final double distanceKm;
  final String formattedDistance;
  final String targetUserId;
  final String targetName;
  final Map<String, dynamic>? preloadedProfile;
  final PocketNeighbor? neighbor;
  final bool isRobot;
  final Map<String, dynamic>? robotData;
  CosmosVehicle selectedVehicle;

  CosmosTransitRoute({
    required this.tier,
    required this.originPlanetCode,
    required this.originPlanetName,
    required this.originIslandName,
    required this.originPlotNumber,
    required this.destPlanetCode,
    required this.destPlanetName,
    required this.destIslandName,
    required this.destPlotNumber,
    required this.distanceKm,
    required this.formattedDistance,
    required this.targetUserId,
    required this.targetName,
    this.preloadedProfile,
    this.neighbor,
    this.isRobot = false,
    this.robotData,
    CosmosVehicle? selectedVehicle,
  }) : selectedVehicle = selectedVehicle ?? CosmosVehicleCatalog.getDefaultVehicleForTier(tier);
}
