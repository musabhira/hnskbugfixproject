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
  });

  int get availableSlots => (totalSlots - filledSlots).clamp(0, totalSlots);
  double get occupancyRatio => totalSlots > 0 ? (filledSlots / totalSlots).clamp(0.0, 1.0) : 0.0;
}

/// 🏡 Citizen Plot with Full Postal Identity Deed
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
  });

  String get formalPostalAddress =>
      '$userName House, Plot #$plotNumber, $streetName, P.O. $postOffice, $countryName, $planetName';
}
