import 'dart:math' as math;

/// 🪐 Real Astronomical Mean Orbital Radii from the Sun (in Kilometers)
class AstronomicalBodies {
  static const double sun = 0.0;
  static const double mercury = 57910000.0;
  static const double venus = 108200000.0;
  static const double earth = 149600000.0;
  static const double moonOrbitOffset = 384400.0; // Distance from Earth
  static const double mars = 227940000.0;
  static const double jupiter = 778570000.0;
  static const double europaOrbitOffset = 670900.0; // Distance from Jupiter
  static const double saturn = 1433530000.0;
  static const double titanOrbitOffset = 1221870.0; // Distance from Saturn
  static const double uranus = 2872460000.0;
  static const double neptune = 4495060000.0;
  static const double pluto = 5906380000.0;

  // Same planet terrestrial journey default
  static const double samePlanetDistance = 12400.0; // km
}

/// 🚀 Flight manifest details between two celestial locations
class CosmosFlightManifest {
  final String originCode;
  final String originName;
  final String destinationCode;
  final String destinationName;
  final double distanceKm;
  final String formattedDistance;
  final List<String> intermediatePlanetCodes;
  final bool isSamePlanet;

  const CosmosFlightManifest({
    required this.originCode,
    required this.originName,
    required this.destinationCode,
    required this.destinationName,
    required this.distanceKm,
    required this.formattedDistance,
    required this.intermediatePlanetCodes,
    required this.isSamePlanet,
  });
}

/// 🔬 Scientific Interplanetary Distance Calculation & Flight Routing Engine
class PoketCosmosDistanceService {
  PoketCosmosDistanceService._();
  static final PoketCosmosDistanceService instance = PoketCosmosDistanceService._();

  // Ordered list of solar system celestial orbital stops from inside out
  static const List<String> solarSystemOrder = [
    'VEN', // Venus
    'EP',  // Earth Prime
    'LUN', // The Moon
    'MAR', // Mars
    'EUR', // Europa
    'JUP', // Jupiter
    'TTN', // Titan
    'SAT', // Saturn
    'NEP', // Neptune
    'PLT', // Pluto
  ];

  /// Mean heliocentric orbital distance in km for calculation
  double getOrbitalDistanceKm(String code) {
    switch (code.toUpperCase()) {
      case 'VEN':
        return AstronomicalBodies.venus;
      case 'EP':
        return AstronomicalBodies.earth;
      case 'LUN':
        return AstronomicalBodies.earth + AstronomicalBodies.moonOrbitOffset;
      case 'MAR':
        return AstronomicalBodies.mars;
      case 'EUR':
        return AstronomicalBodies.jupiter - AstronomicalBodies.europaOrbitOffset;
      case 'JUP':
        return AstronomicalBodies.jupiter;
      case 'TTN':
        return AstronomicalBodies.saturn - AstronomicalBodies.titanOrbitOffset;
      case 'SAT':
        return AstronomicalBodies.saturn;
      case 'NEP':
        return AstronomicalBodies.neptune;
      case 'PLT':
        return AstronomicalBodies.pluto;
      default:
        return AstronomicalBodies.earth;
    }
  }

  /// Single clean planet name
  String getCleanPlanetName(String code) {
    switch (code.toUpperCase()) {
      case 'EP':
        return 'Earth';
      case 'MAR':
        return 'Mars';
      case 'JUP':
        return 'Jupiter';
      case 'SAT':
        return 'Saturn';
      case 'LUN':
        return 'Moon';
      case 'EUR':
        return 'Europa';
      case 'VEN':
        return 'Venus';
      case 'TTN':
        return 'Titan';
      case 'PLT':
        return 'Pluto';
      case 'NEP':
        return 'Neptune';
      default:
        return 'Earth';
    }
  }

  /// Emoji representation
  String getPlanetEmoji(String code) {
    switch (code.toUpperCase()) {
      case 'EP':
        return '🌍';
      case 'MAR':
        return '🔴';
      case 'JUP':
        return '🪐';
      case 'SAT':
        return '🪐';
      case 'LUN':
        return '🌕';
      case 'EUR':
        return '🧊';
      case 'VEN':
        return '☀️';
      case 'TTN':
        return '🪐';
      case 'PLT':
        return '🌌';
      case 'NEP':
        return '🌊';
      default:
        return '🪐';
    }
  }

  /// Robust parser to convert any planet name, code, pin, or bio text to a standard 2-3 char planet code
  String resolvePlanetCode(String? planetInput) {
    if (planetInput == null || planetInput.trim().isEmpty) return 'EP';
    final lower = planetInput.trim().toLowerCase();
    if (lower.contains('mars') || lower == 'mar' || lower.contains('ares')) return 'MAR';
    if (lower.contains('moon') || lower == 'lun' || lower.contains('lunar')) return 'LUN';
    if (lower.contains('jup') || lower == 'jupiter') return 'JUP';
    if (lower.contains('sat') || lower == 'saturn') return 'SAT';
    if (lower.contains('eur') || lower == 'europa') return 'EUR';
    if (lower.contains('ven') || lower == 'venus') return 'VEN';
    if (lower.contains('tit') || lower == 'titan') return 'TTN';
    if (lower.contains('plut') || lower == 'pluto') return 'PLT';
    if (lower.contains('nep') || lower == 'neptune') return 'NEP';
    return 'EP';
  }

  /// Calculates real scientific interplanetary distance between two colonies
  CosmosFlightManifest calculateFlightManifest({
    required String originCode,
    required String destinationCode,
  }) {
    final orig = originCode.trim().toUpperCase();
    final dest = destinationCode.trim().toUpperCase();

    if (orig == dest) {
      return CosmosFlightManifest(
        originCode: orig,
        originName: getCleanPlanetName(orig),
        destinationCode: dest,
        destinationName: getCleanPlanetName(dest),
        distanceKm: AstronomicalBodies.samePlanetDistance,
        formattedDistance: '12,400 km',
        intermediatePlanetCodes: [],
        isSamePlanet: true,
      );
    }

    final d1 = getOrbitalDistanceKm(orig);
    final d2 = getOrbitalDistanceKm(dest);
    final rawDist = (d1 - d2).abs();

    // Determine intermediate bodies along the path for gravitational slingshot loops
    final idx1 = solarSystemOrder.indexOf(orig);
    final idx2 = solarSystemOrder.indexOf(dest);
    final intermediate = <String>[];

    if (idx1 != -1 && idx2 != -1) {
      final start = math.min(idx1, idx2);
      final end = math.max(idx1, idx2);
      for (int i = start + 1; i < end; i++) {
        intermediate.add(solarSystemOrder[i]);
      }
      if (idx1 > idx2) {
        // Reverse direction
        intermediate.sort((a, b) => solarSystemOrder.indexOf(b).compareTo(solarSystemOrder.indexOf(a)));
      }
    }

    return CosmosFlightManifest(
      originCode: orig,
      originName: getCleanPlanetName(orig),
      destinationCode: dest,
      destinationName: getCleanPlanetName(dest),
      distanceKm: rawDist,
      formattedDistance: formatKilometers(rawDist),
      intermediatePlanetCodes: intermediate,
      isSamePlanet: false,
    );
  }

  /// Scientific human-readable km formatting
  String formatKilometers(double km) {
    if (km >= 1000000000.0) {
      return '${(km / 1000000000.0).toStringAsFixed(2)}B km';
    } else if (km >= 1000000.0) {
      return '${(km / 1000000.0).toStringAsFixed(1)}M km';
    } else if (km >= 1000.0) {
      final intKm = km.toInt();
      return '${intKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km';
    } else {
      return '${km.toStringAsFixed(0)} km';
    }
  }
}
