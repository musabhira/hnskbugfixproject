import 'package:flutter/material.dart';

/// 🌌 Model representing a Planet within the Poket Solar System
class PoketPlanet {
  final int id;
  final String name;
  final String theme;
  final String tagLine;
  final Color primaryColor;
  final double radius;
  final double orbitDistance;
  final double orbitSpeed;
  final int totalPlots;
  final int occupiedPlots;

  const PoketPlanet({
    required this.id,
    required this.name,
    required this.theme,
    required this.tagLine,
    required this.primaryColor,
    required this.radius,
    required this.orbitDistance,
    required this.orbitSpeed,
    required this.totalPlots,
    required this.occupiedPlots,
  });

  bool get isFull => occupiedPlots >= totalPlots;
}

/// 🏡 Model representing an individual Citizen Plot on a Street Map
class CitizenPlot {
  final int plotNumber;
  final String userId;
  final String userName;
  final String userAvatar;
  final int day;
  final int pocketScore;
  final String streetName;
  final String sector;
  final Offset coordinates;
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
    required this.sector,
    required this.coordinates,
    this.isVip = false,
    this.isPresident = false,
  });

  String get fullAddress => 'Plot #$plotNumber, $streetName, $sector';
}

/// 🚗 Vehicle Travel Modes
enum TravelMode { car, plane, train }
