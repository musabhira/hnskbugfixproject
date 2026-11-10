import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart' hide Matrix4;
import '/backend/supabase/supabase.dart';
import '../learning_60day/pocket_island_attack_page.dart';
import '../learning_60day/pocket_citadel_attack_page.dart';
import '../learning_60day/pocket_world_street_page.dart';
import '../../services/pocket_robot_service.dart';
import 'poket_cosmos_models.dart';
import 'flame_solar_system_game.dart';
import 'island_aerial_view.dart';
import 'planet_sphere_icon_widget.dart';
import '../../services/pocket_game_audio_service.dart';
import '../../services/poket_cosmos_allocation_service.dart';
import '../../services/pocket_island_group_service.dart';

/// 🌌 Poket Cosmos Explorer:
/// - Screen 0: Fullscreen Solar System & Scientific Moons (compact 3D tilt bend button & iOS back).
/// - Screen 1: Earth Prime's 30 English Learning Archipelago Islands (Horizontal Swipeable Cards
///   with Top 70% Aerial View matching reference photos, Title on Top, Slots underneath, distinct shapes & colors).
/// - Screen 2: Fullscreen Infinite Ocean Island Map (Edge-to-edge seamless ocean without square box breaks,
///   deep 6.5x zoom, 50 top-down 90-day habit house plots, and tap-to-inspect citizen profile sheet).
class PoketCosmosNavigatorPage extends StatefulWidget {
  final String? initialPlanetCode;
  final int initialScreen;

  const PoketCosmosNavigatorPage({
    super.key,
    this.initialPlanetCode,
    this.initialScreen = 0,
  });

  /// Static accessor to all scientific cosmos planets
  static List<PoketPlanet> buildCosmosPlanets({int activeWaves = 1}) =>
      _PoketCosmosNavigatorPageState._buildCosmosPlanets(activeWaves: activeWaves);

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage>
    with TickerProviderStateMixin {
  // Hub mode: 0 = Flame 3D Solar System, 1 = Minimal Planet Directory
  int _hubMode = 0;

  // Active Screen: 0 = Solar Hub, 1 = Archipelago Carousel, 2 = Fullscreen Aerial Map
  int _activeScreen = 0;

  double _tiltAngle = 0.42;
  final TransformationController _orbitInteractiveController =
      TransformationController();
  final TransformationController _aerialMapZoomController =
      TransformationController();

  PoketPlanet? _selectedPlanet;
  PoketCountryMap? _selectedIsland;
  int _currentIslandIndex = 0;
  late PageController _islandPageController;

  late List<PoketPlanet> _planets;
  List<CitizenPlot> _currentIslandPlots = [];
  CitizenPlot? _inspectedPlot;

  double _currentAerialZoom = 1.0;
  int _activeWaves = 1;
  late AnimationController _ambientOceanAnimController;

  @override
  void initState() {
    super.initState();
    // 🎵 Start pleasant ambient loop BGM using app's central audio engine
    PocketGameAudioService.instance.playAmbientAppTheme();
    _ambientOceanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _islandPageController = PageController(viewportFraction: 0.84);
    _planets = _buildCosmosPlanets();
    _refreshCosmosWaves();
    if (widget.initialPlanetCode != null && widget.initialPlanetCode!.isNotEmpty) {
      final code = widget.initialPlanetCode!.toUpperCase();
      PoketPlanet? matched;
      for (final p in _planets) {
        // Direct major/dwarf/exoplanet matches
        if (code == 'MER' && p.id == 1) { matched = p; break; }
        if (code == 'VEN' && p.id == 2) { matched = p; break; }
        if (code == 'EP' && p.id == 3) { matched = p; break; }
        if (code == 'MAR' && p.id == 4) { matched = p; break; }
        if (code == 'JUP' && p.id == 5) { matched = p; break; }
        if (code == 'SAT' && p.id == 6) { matched = p; break; }
        if (code == 'URA' && p.id == 7) { matched = p; break; }
        if (code == 'NEP' && p.id == 8) { matched = p; break; }
        if ((code == 'PLT' || code == 'PLU') && p.id == 9) { matched = p; break; }
        if (code == 'KEP' && p.id == 452) { matched = p; break; }

        // Satellite / Natural moon matches (MUST map to sat.toPlanet() to load the moon's own island!)
        for (final sat in p.satellites) {
          if ((code == 'LUN' && sat.id == 30) ||
              (code == 'EUR' && sat.id == 51) ||
              (code == 'GAN' && sat.id == 52) ||
              (code == 'TTN' && sat.id == 61) ||
              (code == 'TRI' && sat.id == 81) ||
              sat.name.toUpperCase().contains(code)) {
            matched = sat.toPlanet();
            break;
          }
        }
        if (matched != null) break;

        if (p.name.toUpperCase().contains(code)) {
          matched = p;
          break;
        }
      }
      if (matched != null) {
        _selectedPlanet = matched;
        _activeScreen = widget.initialScreen;
        _currentIslandIndex = 0;
        _loadIslandPlots(matched.countryMaps.first);
      } else {
        _loadIslandPlots(_planets.first.countryMaps.first);
      }
    } else {
      _loadIslandPlots(_planets.first.countryMaps.first);
    }
    _aerialMapZoomController.addListener(_onAerialZoomChanged);
  }

  void _onAerialZoomChanged() {
    final scale = _aerialMapZoomController.value.getMaxScaleOnAxis();
    if ((scale - _currentAerialZoom).abs() > 0.08) {
      if (mounted) {
        setState(() {
          _currentAerialZoom = scale;
        });
      }
    }
  }

  @override
  void dispose() {
    _ambientOceanAnimController.dispose();
    _islandPageController.dispose();
    _orbitInteractiveController.dispose();
    _aerialMapZoomController.removeListener(_onAerialZoomChanged);
    _aerialMapZoomController.dispose();
    super.dispose();
  }

  Future<void> _refreshCosmosWaves() async {
    final waves = await PoketCosmosAllocationService.instance.getActiveWaveIndex();
    if (mounted) {
      setState(() {
        _activeWaves = waves;
        _planets = _buildCosmosPlanets(activeWaves: waves);
        if (_selectedPlanet != null) {
          _selectedPlanet = _planets.firstWhere(
            (p) => p.id == _selectedPlanet!.id,
            orElse: () => _selectedPlanet!,
          );
        }
      });
    }
  }

  // =========================================================================
  // 👥 FETCH REAL USERS FOR THE PLOTS ON THE ACTIVE ISLAND
  // =========================================================================
  Future<void> _loadIslandPlots(PoketCountryMap island) async {
    try {
      if (island.isPresidential) {
        _currentIslandPlots = [
          const CitizenPlot(
            plotNumber: 1,
            userId: 'president_musab',
            userName: "Mus'ab (President 👑)",
            userAvatar: '👑',
            day: 90,
            pocketScore: 9999,
            streetName: 'Citadel Imperial Way',
            postOffice: 'Presidential Citadel',
            countryName: 'Presidential Citadel',
            planetName: 'Earth Prime 🌍',
            coordinates: Offset(0.5, 0.5),
            isPresident: true,
            tier: PlotDeedTier.presidential,
            postalPinCode: 'PK-PRES-01',
          ),
        ];
        if (mounted) setState(() {});
        return;
      }

      final colony = island.planetCode != null
          ? PoketCosmosAllocationService.instance.getColonyByCode(island.planetCode!)
          : PoketCosmosAllocationService.instance
              .getColonyByPlanetName(_selectedPlanet?.name ?? island.name);
      final targetWave = (island.id % 100 > 0) ? (island.id % 100) : 1;
      final plots = await PoketCosmosAllocationService.instance
          .getOccupiedPlotsForColony(colony, wave: targetWave);

      if (mounted) {
        setState(() {
          _currentIslandPlots = plots;
        });
      }
    } catch (e) {
      debugPrint('Error loading island plots: $e');
    }
  }

  static List<PoketCountryMap> _buildPlanetIslands({
    required int planetId,
    required String planetCode,
    required String baseIslandName,
    required String baseTag,
    required Color landColor,
    required Color waterColor,
    required String climate,
    required IconData climateIcon,
    required String islandEmoji,
    required IslandShapeStyle shapeStyle,
    int activeWaves = 1,
  }) {
    final colony =
        PoketCosmosAllocationService.instance.getColonyByCode(planetCode);
    final List<PoketCountryMap> list = [];
    for (int w = 1; w <= math.max(1, activeWaves); w++) {
      list.add(PoketCosmosAllocationService.generateProceduralIsland(
        colony: colony,
        wave: w,
        activeWave: activeWaves,
      ));
    }
    return list;
  }

  // =========================================================================
  // 🌍 SCIENTIFIC SOLAR SYSTEM: 8 MAJOR PLANETS, KUIPER DWARF, INTERSTELLAR EXOPLANET & MOONS
  // =========================================================================
  static List<PoketPlanet> _buildCosmosPlanets({int activeWaves = 1}) {
    return [
      // 1. Mercury ⚪ (Innermost Scorched World)
      PoketPlanet(
        id: 1,
        name: 'Mercury ⚪',
        theme: 'Innermost Scorched Iron World',
        tagLine: 'High Velocity Orbit • Caloris Basin',
        primaryColor: const Color(0xFFCBD5E1),
        glowColor: const Color(0xFF94A3B8),
        radius: 10,
        orbitDistance: 85,
        orbitSpeed: 2.1,
        totalPlots: activeWaves * 25,
        occupiedPlots: activeWaves >= 2 ? 50 : 25,
        countryMaps: _buildPlanetIslands(
          planetId: 1,
          planetCode: 'MER',
          baseIslandName: 'Caloris Basin',
          baseTag: 'Crater Ridge',
          landColor: const Color(0xFF64748B),
          waterColor: const Color(0xFF1E293B),
          climate: 'High Heat 🔥',
          climateIcon: Icons.local_fire_department_rounded,
          islandEmoji: '🌋',
          shapeStyle: IslandShapeStyle.fortressPlateau,
          activeWaves: activeWaves,
        ),
      ),

      // 2. Venus 🟡 (Amber Cloud Greenhouse)
      PoketPlanet(
        id: 2,
        name: 'Venus 🟡',
        theme: 'Golden Veil Greenhouse',
        tagLine: 'Dense Amber Clouds & Sulfuric Highlands',
        primaryColor: const Color(0xFFFDE047),
        glowColor: const Color(0xFFD97706),
        radius: 14,
        orbitDistance: 130,
        orbitSpeed: 1.5,
        totalPlots: activeWaves * 25,
        occupiedPlots: activeWaves >= 2 ? 27 : 25,
        countryMaps: _buildPlanetIslands(
          planetId: 2,
          planetCode: 'VEN',
          baseIslandName: 'Aphrodite Terra',
          baseTag: 'Golden Highlands',
          landColor: const Color(0xFFB45309),
          waterColor: const Color(0xFF78350F),
          climate: 'Gold Cloud ⛅',
          climateIcon: Icons.wb_cloudy_rounded,
          islandEmoji: '🏺',
          shapeStyle: IslandShapeStyle.crescentLagoon,
          activeWaves: activeWaves,
        ),
      ),

      // 3. Earth Prime 🌍 (Cradle of Habit Learning + Natural Satellite: The Moon 🌕)
      PoketPlanet(
        id: 3,
        name: 'Earth Prime 🌍',
        theme: 'Cradle of Habit Learning & Capital World',
        tagLine: 'Day 1-90 Habit Pioneers • Living Archipelago',
        primaryColor: const Color(0xFF38BDF8),
        glowColor: const Color(0xFF0284C7),
        radius: 17,
        orbitDistance: 180,
        orbitSpeed: 1.0,
        totalPlots: activeWaves * 25 + 1,
        occupiedPlots: activeWaves * 25,
        countryMaps: _buildEarth30EnglishIslands(activeWaves: activeWaves),
        satellites: [
          PoketSatellite(
            id: 30,
            name: 'The Moon 🌕',
            parentPlanetName: 'Earth Prime 🌍',
            satelliteType: 'Natural Moon of Earth',
            theme: 'Earth\'s Natural Satellite & Off-World Harbor',
            tagLine:
                'Tidally Locked • First Off-World Colony (Tranquility Base)',
            primaryColor: const Color(0xFFE2E8F0),
            glowColor: const Color(0xFFCBD5E1),
            radius: 8.5,
            orbitDistance: 25.0,
            orbitSpeed: 2.4,
            totalPlots: activeWaves * 25,
            occupiedPlots: activeWaves * 25,
            countryMaps: _buildPlanetIslands(
              planetId: 30,
              planetCode: 'LUN',
              baseIslandName: 'Tranquility Base',
              baseTag: 'First Lunar Colony',
              landColor: const Color(0xFF475569),
              waterColor: const Color(0xFF0F172A),
              climate: 'Lunar Glow 🌕',
              climateIcon: Icons.nightlight_round,
              islandEmoji: '🌕',
              shapeStyle: IslandShapeStyle.ringAtoll,
              activeWaves: activeWaves,
            ),
          ),
        ],
      ),

      // 4. Mars 🔴 (The Red Planet)
      PoketPlanet(
        id: 4,
        name: 'Mars 🔴',
        theme: 'Red Dunes Bastion',
        tagLine: 'Iron Oxide Canyons & Olympus Mons',
        primaryColor: const Color(0xFFF97316),
        glowColor: const Color(0xFFEA580C),
        radius: 13,
        orbitDistance: 240,
        orbitSpeed: 0.82,
        totalPlots: activeWaves * 25,
        occupiedPlots: 25,
        countryMaps: _buildPlanetIslands(
          planetId: 4,
          planetCode: 'MAR',
          baseIslandName: 'Olympus Haven',
          baseTag: 'Volcano Oasis',
          landColor: const Color(0xFF9A3412),
          waterColor: const Color(0xFF881337),
          climate: 'Rusty Breeze 🌪️',
          climateIcon: Icons.air_rounded,
          islandEmoji: '🏜️',
          shapeStyle: IslandShapeStyle.starAtoll,
          activeWaves: activeWaves,
        ),
      ),

      // 5. Jupiter 🟠 (The Gas Giant + Satellites: Europa 🧊 & Ganymede 🛡️)
      PoketPlanet(
        id: 5,
        name: 'Jupiter 🟠',
        theme: 'Great Storm Giant',
        tagLine: 'Colossal Gas Bands & Galilean Satellites',
        primaryColor: const Color(0xFFFDBA74),
        glowColor: const Color(0xFFC2410C),
        radius: 26,
        orbitDistance: 315,
        orbitSpeed: 0.55,
        totalPlots: activeWaves * 25,
        occupiedPlots: 25,
        countryMaps: _buildPlanetIslands(
          planetId: 5,
          planetCode: 'JUP',
          baseIslandName: 'Red Spot Atoll',
          baseTag: 'Storm Center',
          landColor: const Color(0xFF7C2D12),
          waterColor: const Color(0xFF451A03),
          climate: 'Thunder Storm ⚡',
          climateIcon: Icons.bolt_rounded,
          islandEmoji: '🌪️',
          shapeStyle: IslandShapeStyle.ringAtoll,
          activeWaves: activeWaves,
        ),
        satellites: [
          PoketSatellite(
            id: 51,
            name: 'Europa 🧊',
            parentPlanetName: 'Jupiter 🟠',
            satelliteType: 'Jupiter\'s Oceanic Moon',
            theme: 'Subsurface Liquid Ocean beneath Ice Shell',
            tagLine: 'Cryo Tide Vault • Conamara Chaos',
            primaryColor: const Color(0xFFBAE6FD),
            glowColor: const Color(0xFF38BDF8),
            radius: 8.0,
            orbitDistance: 27.0,
            orbitSpeed: 2.1,
            totalPlots: activeWaves * 25,
            occupiedPlots: activeWaves * 25,
            countryMaps: _buildPlanetIslands(
              planetId: 51,
              planetCode: 'EUR',
              baseIslandName: 'Conamara Chaos',
              baseTag: 'Liquid Ocean Vault',
              landColor: const Color(0xFF0284C7),
              waterColor: const Color(0xFF38BDF8),
              climate: 'Cryo Tide 🌊',
              climateIcon: Icons.water_drop_rounded,
              islandEmoji: '🧊',
              shapeStyle: IslandShapeStyle.crescentLagoon,
              activeWaves: activeWaves,
            ),
          ),
          PoketSatellite(
            id: 52,
            name: 'Ganymede 🛡️',
            parentPlanetName: 'Jupiter 🟠',
            satelliteType: 'Jupiter\'s Super-Moon',
            theme: 'Largest Satellite in Solar System (Bigger than Mercury)',
            tagLine: 'Internal Magnetic Dynamo • Silicate Highlands',
            primaryColor: const Color(0xFF94A3B8),
            glowColor: const Color(0xFF64748B),
            radius: 9.2,
            orbitDistance: 40.0,
            orbitSpeed: 1.5,
            totalPlots: activeWaves * 25,
            occupiedPlots: activeWaves * 25,
            countryMaps: _buildPlanetIslands(
              planetId: 52,
              planetCode: 'GAN',
              baseIslandName: 'Perrine Regio',
              baseTag: 'Magnetic Ocean Citadel',
              landColor: const Color(0xFF475569),
              waterColor: const Color(0xFF0284C7),
              climate: 'Magnetic Glow ⚡',
              climateIcon: Icons.shield_rounded,
              islandEmoji: '🛡️',
              shapeStyle: IslandShapeStyle.fortressPlateau,
              activeWaves: activeWaves,
            ),
          ),
        ],
      ),

      // 6. Saturn 🪐 (The Ringed Giant + Satellite: Titan 🪐)
      PoketPlanet(
        id: 6,
        name: 'Saturn 🪐',
        theme: 'Ringed Majesty',
        tagLine: 'Golden Ice Dust Rings & Methane Satellites',
        primaryColor: const Color(0xFFFEF08A),
        glowColor: const Color(0xFFCA8A04),
        radius: 22,
        orbitDistance: 405,
        orbitSpeed: 0.42,
        totalPlots: activeWaves * 25,
        occupiedPlots: 25,
        countryMaps: _buildPlanetIslands(
          planetId: 6,
          planetCode: 'SAT',
          baseIslandName: 'Cassini Glade',
          baseTag: 'Golden Ring Plateau',
          landColor: const Color(0xFF854D0E),
          waterColor: const Color(0xFF3B0764),
          climate: 'Cold Gold Mists ❄️',
          climateIcon: Icons.ac_unit_rounded,
          islandEmoji: '👑',
          shapeStyle: IslandShapeStyle.dualIsletBridge,
          activeWaves: activeWaves,
        ),
        satellites: [
          PoketSatellite(
            id: 61,
            name: 'Titan 🪐',
            parentPlanetName: 'Saturn 🪐',
            satelliteType: 'Saturn\'s Atmospheric Moon',
            theme: 'Dense Nitrogen Sky & Liquid Methane Seas',
            tagLine: 'Golden Clouds • Hydrocarbon Ocean Harbor (Kraken Mare)',
            primaryColor: const Color(0xFFFBBF24),
            glowColor: const Color(0xFFD97706),
            radius: 9.0,
            orbitDistance: 34.0,
            orbitSpeed: 1.8,
            totalPlots: activeWaves * 25,
            occupiedPlots: activeWaves * 25,
            countryMaps: _buildPlanetIslands(
              planetId: 61,
              planetCode: 'TTN',
              baseIslandName: 'Kraken Mare Bay',
              baseTag: 'Liquid Methane Sea',
              landColor: const Color(0xFF92400E),
              waterColor: const Color(0xFFD97706),
              climate: 'Golden Rain 🌧️',
              climateIcon: Icons.umbrella_rounded,
              islandEmoji: '🪐',
              shapeStyle: IslandShapeStyle.ringAtoll,
              activeWaves: activeWaves,
            ),
          ),
        ],
      ),

      // 7. Uranus 💎 (Cyan Ice Giant)
      PoketPlanet(
        id: 7,
        name: 'Uranus 💎',
        theme: 'Cyan Ice Vault',
        tagLine: 'Tilt 98° Orbit • Diamond Rain Cryo',
        primaryColor: const Color(0xFF67E8F9),
        glowColor: const Color(0xFF06B6D4),
        radius: 18,
        orbitDistance: 490,
        orbitSpeed: 0.32,
        totalPlots: activeWaves * 25,
        occupiedPlots: 25,
        countryMaps: _buildPlanetIslands(
          planetId: 7,
          planetCode: 'URA',
          baseIslandName: 'Miranda Glade',
          baseTag: 'Cyan Ice Cliffs',
          landColor: const Color(0xFF0E7490),
          waterColor: const Color(0xFF0891B2),
          climate: 'Cryo Chill 🧊',
          climateIcon: Icons.severe_cold_rounded,
          islandEmoji: '🧊',
          shapeStyle: IslandShapeStyle.hookPeninsula,
          activeWaves: activeWaves,
        ),
      ),

      // 8. Neptune 🌊 (Supersonic Blue Giant + Satellite: Triton 🔱)
      PoketPlanet(
        id: 8,
        name: 'Neptune 🌊',
        theme: 'Abyssal Trident Giant',
        tagLine: 'Supersonic Winds & Cryo Geyser Satellites',
        primaryColor: const Color(0xFF60A5FA),
        glowColor: const Color(0xFF2563EB),
        radius: 17,
        orbitDistance: 575,
        orbitSpeed: 0.22,
        totalPlots: activeWaves * 25,
        occupiedPlots: 25,
        countryMaps: _buildPlanetIslands(
          planetId: 8,
          planetCode: 'NEP',
          baseIslandName: 'Great Dark Haven',
          baseTag: 'Deep Ultramarine Rim',
          landColor: const Color(0xFF1E3A8A),
          waterColor: const Color(0xFF1D4ED8),
          climate: 'Deep Gale 💨',
          climateIcon: Icons.cyclone_rounded,
          islandEmoji: '🔱',
          shapeStyle: IslandShapeStyle.heartSanctuary,
          activeWaves: activeWaves,
        ),
        satellites: [
          PoketSatellite(
            id: 81,
            name: 'Triton 🔱',
            parentPlanetName: 'Neptune 🌊',
            satelliteType: 'Neptune\'s Cryo Moon',
            theme: 'Retrograde Nitrogen Geyser Satellite',
            tagLine: 'Sub-Zero Cryo Spouts • Kuiper Belt Capture',
            primaryColor: const Color(0xFF93C5FD),
            glowColor: const Color(0xFF3B82F6),
            radius: 7.8,
            orbitDistance: 27.0,
            orbitSpeed: -1.9, // Retrograde orbit!
            totalPlots: activeWaves * 25,
            occupiedPlots: activeWaves * 25,
            countryMaps: _buildPlanetIslands(
              planetId: 81,
              planetCode: 'TRI',
              baseIslandName: 'Triton Geyser',
              baseTag: 'Cryo Spout Basin',
              landColor: const Color(0xFF1E40AF),
              waterColor: const Color(0xFF60A5FA),
              climate: 'Cryo Plume ❄️',
              climateIcon: Icons.ac_unit_rounded,
              islandEmoji: '🔱',
              shapeStyle: IslandShapeStyle.crescentLagoon,
              activeWaves: activeWaves,
            ),
          ),
        ],
      ),

      // 9. Pluto ❄️ (Dwarf Planet • Kuiper Belt Outer Rim)
      PoketPlanet(
        id: 9,
        name: 'Pluto ❄️',
        theme: 'Kuiper Belt Outer Rim (Dwarf Planet)',
        tagLine: 'Nitrogen Ice Dunes & Heart of Sputnik Planitia',
        primaryColor: const Color(0xFFC084FC),
        glowColor: const Color(0xFFA855F7),
        radius: 9,
        orbitDistance: 660,
        orbitSpeed: 0.16,
        totalPlots: activeWaves * 25,
        occupiedPlots: 22,
        isDwarfPlanet: true,
        countryMaps: _buildPlanetIslands(
          planetId: 9,
          planetCode: 'PLT',
          baseIslandName: 'Sputnik Planitia',
          baseTag: 'Heart of Pluto',
          landColor: const Color(0xFF7C3AED),
          waterColor: const Color(0xFF3B0764),
          climate: 'Deep Cosmic Frost 🌌',
          climateIcon: Icons.ac_unit_rounded,
          islandEmoji: '🌌',
          shapeStyle: IslandShapeStyle.heartSanctuary,
          activeWaves: activeWaves,
        ),
      ),

      // 10. Kepler-452b 🌌 (Interstellar Exoplanet • Cygnus Constellation)
      PoketPlanet(
        id: 452,
        name: 'Kepler-452b 🌌',
        theme: 'Interstellar Alien Exosphere Frontier',
        tagLine: '1,400 Light-Years Away in Cygnus • Bioluminescent Exoplanet',
        primaryColor: const Color(0xFF6366F1),
        glowColor: const Color(0xFF4F46E5),
        radius: 20,
        orbitDistance: 765,
        orbitSpeed: 0.11,
        isExoplanet: true,
        totalPlots: activeWaves * 25,
        occupiedPlots: 12,
        countryMaps: _buildPlanetIslands(
          planetId: 452,
          planetCode: 'KEP',
          baseIslandName: 'Cygnus Haven',
          baseTag: 'Interstellar Exoplanet',
          landColor: const Color(0xFF065F46),
          waterColor: const Color(0xFF312E81),
          climate: 'Bioluminescent Exosphere 🌌',
          climateIcon: Icons.auto_awesome_rounded,
          islandEmoji: '🌌',
          shapeStyle: IslandShapeStyle.cloverBays,
          activeWaves: activeWaves,
        ),
      ),
    ];
  }

  /// 🏝️ Earth Prime Sovereign & Citizen Colony Islands
  static List<PoketCountryMap> _buildEarth30EnglishIslands({int activeWaves = 1}) {
    final list = <PoketCountryMap>[
      // 👑 Island #0: Presidential Citadel (President Mus'ab's Exclusive Sovereign Sanctuary - ONLY ON EARTH PRIME)
      const PoketCountryMap(
        id: 1,
        name: 'Presidential Citadel 👑',
        tag: 'Presidential Sanctuary • Earth Prime 🌍',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF0284C7),
        totalSlots: 1,
        filledSlots: 1,
        climate: 'Imperial Breeze 👑',
        climateIcon: Icons.military_tech_rounded,
        description:
            'Sovereign island sanctuary reserved solely for the Supreme President.',
        islandEmoji: '🏰',
        isPresidential: true,
        shapeStyle: IslandShapeStyle.citadelApex,
        wave: 1,
      ),
    ];

    final earthColony =
        PoketCosmosAllocationService.instance.getColonyByCode('EP');

    // Procedural Loop for all citizen islands on Earth Prime (Wave 1 to activeWaves)
    for (int w = 1; w <= math.max(1, activeWaves); w++) {
      list.add(PoketCosmosAllocationService.generateProceduralIsland(
        colony: earthColony,
        wave: w,
        activeWave: activeWaves,
      ));
    }

    return list;
  }

  void _navigateToPlanetArchipelago(PoketPlanet planet) {
    setState(() {
      _selectedPlanet = planet;
      _activeScreen = 1;
      _currentIslandIndex = 0;
    });
    if (_islandPageController.hasClients) {
      _islandPageController.jumpToPage(0);
    }
    if (planet.countryMaps.isNotEmpty) {
      _loadIslandPlots(planet.countryMaps.first);
    }
  }

  void _navigateToFullscreenAerialMap(PoketCountryMap island) {
    setState(() {
      _selectedIsland = island;
      _activeScreen = 2;
    });
    _loadIslandPlots(island);
    _aerialMapZoomController.value = Matrix4.identity();
  }

  void _zoomOrbit(double factor) {
    final currentScale = _orbitInteractiveController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.4, 3.2);
    _orbitInteractiveController.value =
        Matrix4.diagonal3Values(newScale, newScale, 1.0);
  }

  void _resetOrbitZoom() {
    _orbitInteractiveController.value = Matrix4.identity();
  }

  void _toggleTiltAngle() {
    setState(() {
      if (_tiltAngle < 0.2) {
        _tiltAngle = 0.52;
      } else if (_tiltAngle < 0.65) {
        _tiltAngle = 0.80;
      } else {
        _tiltAngle = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D121D),
      body: SafeArea(
        top: false,
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_activeScreen) {
      case 0:
        return _buildSolarSystemHub();
      case 1:
        return _buildPlanetArchipelagoView();
      case 2:
        return _buildFullscreenAerialMapView();
      default:
        return _buildSolarSystemHub();
    }
  }

  // =========================================================================
  // 🪐 SCREEN 0: FULLSCREEN SOLAR SYSTEM & PLANETS DIRECTORY
  // =========================================================================
  Widget _buildSolarSystemHub() {
    return Stack(
      children: [
        Positioned.fill(
          child: _hubMode == 0
              ? _buildFlameOrbitContent()
              : _buildMinimalPlanetsDirectoryContent(),
        ),

        // Minimal iOS Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              right: 14,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D121D).withValues(alpha: 0.95),
                  const Color(0xFF0D121D).withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Row(
              children: [
                _buildIosBackButton(
                    onTap: () => Navigator.of(context).maybePop()),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Poket Solar System',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeaderIconTab(
                        icon: Icons.public_rounded,
                        tooltip: 'Solar System 🪐',
                        isSelected: _hubMode == 0,
                        onTap: () => setState(() => _hubMode = 0),
                      ),
                      _buildHeaderIconTab(
                        icon: Icons.format_list_bulleted_rounded,
                        tooltip: 'Planets Directory 📋',
                        isSelected: _hubMode == 1,
                        onTap: () => setState(() => _hubMode = 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right-Side Compact Floating Controls Pill (Zoom +, Zoom -, 3D Tilt Bend)
        if (_hubMode == 0)
          Positioned(
            right: 14,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF14181B).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 12)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFloatingActionBtn(
                    icon: Icons.add_rounded,
                    tooltip: 'Zoom In',
                    onTap: () => _zoomOrbit(1.25),
                  ),
                  const SizedBox(height: 6),
                  _buildFloatingActionBtn(
                    icon: Icons.remove_rounded,
                    tooltip: 'Zoom Out',
                    onTap: () => _zoomOrbit(0.8),
                  ),
                  const SizedBox(height: 6),
                  _buildFloatingActionBtn(
                    icon: Icons.restart_alt_rounded,
                    tooltip: 'Reset Orbit',
                    onTap: _resetOrbitZoom,
                  ),
                  const Divider(
                      color: Colors.white24,
                      height: 14,
                      indent: 4,
                      endIndent: 4),
                  _buildFloatingActionBtn(
                    icon: Icons.screen_rotation_rounded,
                    tooltip:
                        '3D Bend Perspective (${_tiltAngle < 0.2 ? 'Top' : _tiltAngle < 0.65 ? '3D' : 'Side'})',
                    highlightColor: const Color(0xFFFFD700),
                    onTap: _toggleTiltAngle,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFlameOrbitContent() {
    return InteractiveViewer(
      transformationController: _orbitInteractiveController,
      minScale:
          0.16, // Zoom all the way out to comfortably see Pluto and Kepler-452b
      maxScale: 4.0,
      boundaryMargin: const EdgeInsets.all(600),
      child: SizedBox(
        width: 1300,
        height: 1300,
        child: GameWidget(
          game: FlameSolarSystemGame(
            planets: _planets,
            selectedPlanet: _selectedPlanet,
            tiltAngle: _tiltAngle,
            onPlanetSelected: (planet) {
              _navigateToPlanetArchipelago(planet);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalPlanetsDirectoryContent() {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 58,
        left: 14,
        right: 14,
        bottom: 30,
      ),
      itemCount: _planets.length,
      itemBuilder: (context, i) {
        final p = _planets[i];
        final isApex = p.id == 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🪐 Primary Planet Card
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF14181B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isApex
                      ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                      : Colors.white12,
                  width: isApex ? 1.5 : 0.8,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToPlanetArchipelago(p),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // 3D Spherical Planetary Icon (with atmospheric shading & rings)
                        PlanetSphereIconWidget(
                          name: p.name,
                          primaryColor: p.primaryColor,
                          glowColor: p.glowColor,
                          size: 46,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  if (isApex) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'APEX',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ] else if (p.isExoplanet) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'EARTH 2.0',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ] else if (p.isDwarfPlanet) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF94A3B8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'DWARF',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.tagLine,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white30, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🌕 Dedicated Independent Sub-Tiles for Natural Moons / Satellites
            if (p.satellites.isNotEmpty)
              ...p.satellites.map((sat) {
                return Container(
                  margin: const EdgeInsets.only(left: 24, bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F141C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sat.primaryColor.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _navigateToPlanetArchipelago(sat.toPlanet()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        child: Row(
                          children: [
                            // 🌕 3D Lunar Shaded Sphere Icon
                            PlanetSphereIconWidget(
                              name: sat.name,
                              primaryColor: sat.primaryColor,
                              glowColor: sat.glowColor,
                              size: 34,
                              isMoon: true,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        sat.name,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: sat.primaryColor
                                              .withValues(alpha: 0.22),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: sat.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.6),
                                        ),
                                        child: Text(
                                          sat.satelliteType.toUpperCase(),
                                          style: TextStyle(
                                            color: sat.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sat.tagLine,
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 10.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white24, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 🏝️ SCREEN 1: ARCHIPELAGO CAROUSEL (70% AERIAL VIEW, REFINED CARD LAYOUT)
  // =========================================================================
  Widget _buildPlanetArchipelagoView() {
    final planet = _selectedPlanet ?? _planets.first;
    final islands = planet.countryMaps;
    final currentIsland = islands.isNotEmpty
        ? islands[_currentIslandIndex.clamp(0, islands.length - 1)]
        : null;

    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        currentIsland?.waterColor.withValues(alpha: 0.22) ??
            const Color(0xFF0D121D),
        const Color(0xFF0A111E),
        const Color(0xFF0D121D),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(gradient: bgGradient),
      child: Stack(
        children: [
          // Top Minimal Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 14,
                right: 14,
                bottom: 8,
              ),
              child: Row(
                children: [
                  _buildIosBackButton(onTap: () {
                    if (widget.initialPlanetCode != null && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      setState(() => _activeScreen = 0);
                    }
                  }),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planet.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                          ),
                        ),
                        Text(
                          '${islands.length} Distinct Islands • 25 Plots per Island',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showCosmosPlanetSearchSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded,
                              color: Color(0xFF38BDF8), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _activeScreen = 0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public_rounded,
                              color: Color(0xFF38BDF8), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Orbit',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showCosmosLoopDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.all_inclusive_rounded,
                              color: Color(0xFFFFD700), size: 14),
                          SizedBox(width: 4),
                          Text(
                            '1 Cr+ Loop',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIslandIndex + 1} / ${islands.length}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Horizontal Swipeable Island Cards
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 55,
            bottom: 25,
            child: PageView.builder(
              controller: _islandPageController,
              itemCount: islands.length,
              onPageChanged: (idx) {
                setState(() => _currentIslandIndex = idx);
                _loadIslandPlots(islands[idx]);
              },
              itemBuilder: (context, i) {
                final island = islands[i];
                final isCurrent = i == _currentIslandIndex;

                return AnimatedScale(
                  scale: isCurrent ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 250),
                  child: _buildIslandAerialCard(island, planet, isCurrent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🏝️ The Island Card: Top 70% Aerial View & Bottom Clean Vertical Layout
  Widget _buildIslandAerialCard(
      PoketCountryMap island, PoketPlanet planet, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14181B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent
              ? (island.isPresidential
                  ? const Color(0xFFFFD700)
                  : island.waterColor)
              : Colors.white12,
          width: isCurrent ? 2.0 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? (island.isPresidential
                    ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                    : island.waterColor.withValues(alpha: 0.3))
                : Colors.black54,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🏝️ TOP 70% (മുക്കാൽ ഭാഗം): AERIAL ISLAND VIEW
          Expanded(
            flex: 7,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IslandAerialViewWidget(
                    island: island,
                    isInteractive: false,
                    plots: _currentIslandPlots,
                  ),
                  // President 👑 Badge or English Tag
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: island.isPresidential
                            ? const Color(0xFFFFD700)
                            : Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: island.isPresidential
                              ? Colors.white
                              : Colors.white24,
                        ),
                      ),
                      child: Text(
                        island.isPresidential
                            ? 'President 👑'
                            : island.islandEmoji,
                        style: TextStyle(
                          color: island.isPresidential
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📋 BOTTOM 30%: REFINED CLEAN VERTICAL COLUMN LAYOUT
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF14181B),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title on Top
                  Text(
                    island.name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Slots underneath (cleanly aligned!)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            island.isPresidential
                                ? '1 VIP Slot (Supreme President)'
                                : 'Filled Slots: ${island.filledSlots} / ${island.totalSlots} Plots',
                            style: TextStyle(
                              color: island.isPresidential
                                  ? const Color(0xFFFFD700)
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                          if (!island.isPresidential)
                            Text(
                              '${(island.occupancyRatio * 100).toInt()}%',
                              style: TextStyle(
                                color: island.waterColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: island.isPresidential
                              ? 1.0
                              : island.occupancyRatio,
                          minHeight: 4.5,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            island.isPresidential
                                ? const Color(0xFFFFD700)
                                : island.waterColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Action Row: Explore Island & Attack / Mock Attack
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: island.isPresidential
                                  ? const Color(0xFFFFD700)
                                  : island.waterColor,
                              foregroundColor: island.isPresidential
                                  ? Colors.black
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            onPressed: () =>
                                _navigateToFullscreenAerialMap(island),
                            icon: const Icon(Icons.travel_explore_rounded,
                                size: 16),
                            label: Text(
                              island.isPresidential
                                  ? 'Crown Sanctuary 👑'
                                  : 'Explore 🏝️',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 💬 Island Neighbors Group Chat Button
                      SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            side: const BorderSide(
                              color: Color(0xFF38BDF8),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            final colony = PoketCosmosAllocationService.instance
                                .getColonyByPlanetName(
                                    _selectedPlanet?.name ?? island.name);
                            PocketIslandGroupService.instance.openIslandGroupChat(
                              context,
                              planetCode: colony.code,
                              planetName: colony.planetName,
                              wave: island.wave,
                              islandName: island.name,
                            );
                          },
                          icon: const Text('💬', style: TextStyle(fontSize: 13)),
                          label: const Text(
                            'Neighbors',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 4,
                        child: Builder(
                          builder: (context) {
                            final myId =
                                SupaFlow.client.auth.currentUser?.id ?? '';
                            final bool isOwn = _currentIslandPlots
                                .any((p) => p.userId == myId);
                            return SizedBox(
                              height: 38,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOwn
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  PocketIslandAttackPage.launch(
                                    context,
                                    island: island,
                                    colony: PoketCosmosAllocationService.instance
                                        .getColonyByPlanetName(_selectedPlanet?.name ?? island.name),
                                    plots: _currentIslandPlots,
                                    isMockAttack: isOwn,
                                  );
                                },
                                icon: Text(isOwn ? '🛡️' : '⚔️',
                                    style: const TextStyle(fontSize: 14)),
                                label: Text(
                                  isOwn ? 'Mock' : 'Attack',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🗺️ SCREEN 2: FULLSCREEN EDGE-TO-EDGE LIVING ATMOSPHERE (NO BOX BREAKS)
  // Unified living world: ocean, waves, reefs, island, houses & clouds scale together!
  // =========================================================================
  Widget _buildFullscreenAerialMapView() {
    final island = _selectedIsland ?? _planets.first.countryMaps.first;

    return Scaffold(
      backgroundColor: const Color(0xFF022B45),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🏝️ Fullscreen Unified Living Oceanic World Canvas
          // Height strictly locked to screen height (touching top & bottom); wide ocean pans horizontally!
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final worldHeight = screenHeight * 1.45;
                final worldWidth =
                    math.max(screenWidth * 2.8, screenHeight * 2.2);
                final minScale = screenHeight / worldHeight;
                const focusScale = 1.15;
                final focusX = -(worldWidth * focusScale - screenWidth) / 2;
                final focusY = -(worldHeight * focusScale - screenHeight) / 2;

                // Auto-center island on entry at focused scale (never starts uninitialized or void)
                if (_aerialMapZoomController.value == Matrix4.identity()) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted &&
                        _aerialMapZoomController.value == Matrix4.identity()) {
                      _aerialMapZoomController.value =
                          Matrix4.translationValues(focusX, focusY, 0.0)
                            ..scaleByDouble(focusScale, focusScale, 1.0, 1.0);
                    }
                  });
                }

                return InteractiveViewer(
                  transformationController: _aerialMapZoomController,
                  constrained: false,
                  boundaryMargin: EdgeInsets.zero,
                  minScale:
                      minScale, // Strictly locked to screen height! Never shrinks into a card box!
                  maxScale:
                      20.0, // Ultra-deep habit house, nameplate board, car & pool inspection
                  clipBehavior: Clip.none,
                  child: SizedBox(
                    width: worldWidth,
                    height: worldHeight,
                    child: IslandAerialViewWidget(
                      island: island,
                      isInteractive: true,
                      zoomScale: _currentAerialZoom,
                      plots: _currentIslandPlots,
                      selectedPlotNumber: _inspectedPlot?.plotNumber,
                      onPlotTapped: _showPlotDetailsSheet,
                      onPlotPurchased: () => _loadIslandPlots(island),
                    ),
                  ),
                );
              },
            ),
          ),

          // Minimal Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 14,
                right: 14,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D121D).withValues(alpha: 0.95),
                    const Color(0xFF0D121D).withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _buildIosBackButton(onTap: () {
                    setState(() => _activeScreen = 1);
                  }),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                island.name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (island.isPresidential) ...[
                              const SizedBox(width: 6),
                              const Text('👑', style: TextStyle(fontSize: 14)),
                            ],
                          ],
                        ),
                        Text(
                          island.isPresidential
                              ? 'Imperial Palace & Sovereign Grounds'
                              : '${island.totalSlots} Plots • Pinch to Zoom in & Inspect Houses',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // 🎵 Ambient Music / Audio Toggle Button (Central BGM Loop Engine)
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        PocketGameAudioService.instance.isMutedNotifier,
                    builder: (context, isMuted, _) {
                      final isPlaying = !isMuted;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          PocketGameAudioService.instance.toggleMute();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(!isMuted
                                  ? '🔇 BGM Audio Muted'
                                  : '🎵 Ambient Loop BGM Active'),
                              duration: const Duration(milliseconds: 1400),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPlaying
                                  ? const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.6)
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPlaying
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                color: isPlaying
                                    ? const Color(0xFF38BDF8)
                                    : Colors.white60,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isPlaying ? 'BGM' : 'Muted',
                                style: TextStyle(
                                  color: isPlaying
                                      ? const Color(0xFF38BDF8)
                                      : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Floating Controls Pill at Bottom Right (Zoom +, Zoom -, Reset)
          Positioned(
            right: 14,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF14181B).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Zoom In (+)
                  IconButton(
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Zoom In',
                    onPressed: () {
                      final size = MediaQuery.of(context).size;
                      final sW = size.width;
                      final sH = size.height;
                      final wH = sH * 1.45;
                      final wW = math.max(sW * 2.8, sH * 2.2);
                      final minS = sH / wH;
                      final current =
                          _aerialMapZoomController.value.getMaxScaleOnAxis();
                      final s = (current * 1.25).clamp(minS, 20.0);
                      final dx = -(wW * s - sW) / 2;
                      final dy = -(wH * s - sH) / 2;
                      _aerialMapZoomController.value =
                          Matrix4.translationValues(dx, dy, 0.0)
                            ..scaleByDouble(s, s, 1.0, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  // 2. Zoom Out (-)
                  IconButton(
                    icon: const Icon(Icons.remove_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Zoom Out',
                    onPressed: () {
                      final size = MediaQuery.of(context).size;
                      final sW = size.width;
                      final sH = size.height;
                      final wH = sH * 1.45;
                      final wW = math.max(sW * 2.8, sH * 2.2);
                      final minS = sH / wH;
                      final current =
                          _aerialMapZoomController.value.getMaxScaleOnAxis();
                      final s = (current * 0.80).clamp(minS, 20.0);
                      final dx = -(wW * s - sW) / 2;
                      final dy = -(wH * s - sH) / 2;
                      _aerialMapZoomController.value =
                          Matrix4.translationValues(dx, dy, 0.0)
                            ..scaleByDouble(s, s, 1.0, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  // 3. Focus Island 🎯 (centers island in clear view)
                  IconButton(
                    icon: const Icon(Icons.filter_center_focus_rounded,
                        color: Color(0xFF38BDF8), size: 19),
                    tooltip: 'Focus Island',
                    onPressed: () {
                      final size = MediaQuery.of(context).size;
                      final sW = size.width;
                      final sH = size.height;
                      final wH = sH * 1.45;
                      final wW = math.max(sW * 2.8, sH * 2.2);
                      const s = 1.15;
                      final dx = -(wW * s - sW) / 2;
                      final dy = -(wH * s - sH) / 2;
                      _aerialMapZoomController.value =
                          Matrix4.translationValues(dx, dy, 0.0)
                            ..scaleByDouble(s, s, 1.0, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  // 4. Ultra Focus Home 🏡 (zooms 14.0x directly onto selected plot or Plot #1 villa, car & pool)
                  IconButton(
                    icon: const Icon(Icons.home_work_rounded,
                        color: Color(0xFF4ADE80), size: 20),
                    tooltip: 'Ultra Focus Home',
                    onPressed: () {
                      final size = MediaQuery.of(context).size;
                      final sW = size.width;
                      final sH = size.height;
                      final wH = sH * 1.45;
                      final wW = math.max(sW * 2.8, sH * 2.2);
                      const targetScale = 14.0;

                      final coords = IslandAerialPainter.get35PlotCoordinates(
                          island.shapeStyle);
                      final targetPlotCoord = (_inspectedPlot != null &&
                              coords.isNotEmpty)
                          ? _inspectedPlot!.coordinates
                          : (coords.isNotEmpty ? coords.first : Offset.zero);

                      final painterScale =
                          ((wH / 850.0) * 1.15).clamp(0.95, 1.50);
                      final targetWorldX =
                          wW / 2 + targetPlotCoord.dx * painterScale;
                      final targetWorldY =
                          wH / 2 + targetPlotCoord.dy * painterScale;

                      final dx = -(targetWorldX * targetScale - sW / 2);
                      final dy = -(targetWorldY * targetScale - sH / 2);

                      _aerialMapZoomController.value =
                          Matrix4.translationValues(dx, dy, 0.0)
                            ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  // 5. Overview / Reset Zoom ↺ (snaps to locked height touching top & bottom)
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded,
                        color: Color(0xFFFFD700), size: 20),
                    tooltip: 'Full Overview',
                    onPressed: () {
                      final size = MediaQuery.of(context).size;
                      final sW = size.width;
                      final sH = size.height;
                      final wH = sH * 1.45;
                      final wW = math.max(sW * 2.8, sH * 2.2);
                      final minS = sH / wH;
                      final initX = -(wW * minS - sW) / 2;
                      _aerialMapZoomController.value =
                          Matrix4.translationValues(initX, 0.0, 0.0)
                            ..scaleByDouble(minS, minS, 1.0, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  // 6. Search 15 Worlds 🪐
                  IconButton(
                    icon: const Icon(Icons.search_rounded,
                        color: Color(0xFF38BDF8), size: 20),
                    tooltip: 'Search 15 Worlds',
                    onPressed: _showCosmosPlanetSearchSheet,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  // 7. Island Attack / Mock Attack ⚔️
                  IconButton(
                    icon: Builder(
                      builder: (context) {
                        final myId =
                            SupaFlow.client.auth.currentUser?.id ?? '';
                        final bool isOwn = _currentIslandPlots
                            .any((p) => p.userId == myId);
                        return Text(isOwn ? '🛡️' : '⚔️',
                            style: const TextStyle(fontSize: 16));
                      },
                    ),
                    tooltip: 'Launch Battle',
                    onPressed: () {
                      final myId =
                          SupaFlow.client.auth.currentUser?.id ?? '';
                      final bool isOwn = _currentIslandPlots
                          .any((p) => p.userId == myId);
                      HapticFeedback.mediumImpact();
                      PocketIslandAttackPage.launch(
                        context,
                        island: island,
                        colony: PoketCosmosAllocationService.instance
                            .getColonyByPlanetName(_selectedPlanet?.name ?? island.name),
                        plots: _currentIslandPlots,
                        isMockAttack: isOwn,
                      );
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏡 PLOT DETAILS MODAL BOTTOM SHEET
  // =========================================================================
  void _showPlotDetailsSheet(CitizenPlot plot) {
    setState(() => _inspectedPlot = plot);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF14181B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: plot.isPresident
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF0284C7),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        plot.isPresident ? '👑' : '🏡',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.userName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Plot #${plot.plotNumber} • ${plot.postalPinCode}',
                          style: const TextStyle(
                              color: Color(0xFFFFD700), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Habit Level & Streak Stats
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Habit Stage',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('Day ${plot.day} / 90',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Score & Streak',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${plot.pocketScore} PS • 🔥 ${plot.day}d',
                              style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Registered Postal Address
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  '📮 ${plot.formalPostalAddress}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF38BDF8),
                          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          if (plot.userId.isNotEmpty &&
                              !plot.userId.startsWith('empty') &&
                              !plot.userId.startsWith('vacant')) {
                            final colony = PoketCosmosAllocationService.instance
                                .getColonyByPlanetName(plot.planetName);
                            final neighbor = PocketNeighbor(
                              id: plot.userId,
                              name: plot.userName,
                              day: plot.day,
                              streak: plot.day,
                              rank: 'Cosmic Citizen',
                              paletteId: 'warm_cottage',
                              isMe: false,
                              hasActiveShield: true,
                              statusMessage: plot.postalPinCode,
                              isPocketRobo: PocketRobotService.isRobotId(plot.userId),
                              hp: 100,
                              maxHp: 100,
                              planetCode: colony.code,
                              planetName: colony.planetName,
                              islandName: plot.countryName,
                              streetName: plot.streetName,
                              plotNumber: plot.plotNumber,
                              cosmosPin: plot.postalPinCode,
                            );

                            PocketCitadelAttackPage.openForUser(
                              context,
                              userId: plot.userId,
                              targetName: plot.userName,
                              targetDay: plot.day,
                              neighbor: neighbor,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Plot #${plot.plotNumber} (${plot.postalPinCode}) is available for purchase!'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.person_pin_rounded, size: 18),
                        label: const Text(
                          'Profile 👤',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          final planet = _selectedPlanet ?? _planets.first;
                          final island = _selectedIsland ??
                              (planet.countryMaps.isNotEmpty
                                  ? planet.countryMaps[_currentIslandIndex.clamp(0, planet.countryMaps.length - 1)]
                                  : planet.countryMaps.first);
                          final colony = island.planetCode != null
                              ? PoketCosmosAllocationService.instance.getColonyByCode(island.planetCode!)
                              : PoketCosmosAllocationService.instance.getColonyByPlanetName(planet.name);

                          PocketIslandAttackPage.launch(
                            context,
                            island: island,
                            colony: colony,
                            plots: _currentIslandPlots,
                            isMockAttack: false,
                          );
                        },
                        icon: const Icon(Icons.flash_on_rounded, size: 18),
                        label: const Text(
                          'Challenge ⚔️',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🌐 Returns all 15 celestial bodies (10 planets + 5 moons/satellites)
  List<PoketPlanet> get _all15CelestialWorlds {
    final list = <PoketPlanet>[];
    for (final p in _planets) {
      list.add(p);
      for (final s in p.satellites) {
        list.add(s.toPlanet());
      }
    }
    return list;
  }

  // =========================================================================
  // 🔍 COSMOS 15 CELESTIAL WORLDS SEARCH & JUMP SHEET
  // =========================================================================
  void _showCosmosPlanetSearchSheet() {
    HapticFeedback.mediumImpact();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final allWorlds = _all15CelestialWorlds;
          final filtered = allWorlds.where((p) {
            if (searchQuery.trim().isEmpty) return true;
            final q = searchQuery.toLowerCase().trim();
            final islandNames =
                p.countryMaps.map((m) => m.name.toLowerCase()).join(' ');
            return p.name.toLowerCase().contains(q) ||
                p.theme.toLowerCase().contains(q) ||
                islandNames.contains(q);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border:
                  Border(top: BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, -6)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    const Text('🪐', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      'SEARCH 15 CELESTIAL WORLDS',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Instantly find and travel to any of the 15 celestial worlds and their 25-plot islands.',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 12),
                // 🔍 Live Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Color(0xFF38BDF8), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            hintText:
                                'Search Planets or Islands (e.g. Titan, Mars, Aphrodite)...',
                            hintStyle: TextStyle(
                                color: Color(0xFF64748B), fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              searchQuery = val;
                            });
                          },
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              searchQuery = '';
                            });
                          },
                          child: const Icon(Icons.cancel_rounded,
                              color: Colors.white54, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No planet found matching "$searchQuery"',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final p = filtered[idx];
                            final isCurrent = p.id == _selectedPlanet?.id;
                            final colonyIdx = PoketCosmosAllocationService.colonies.indexWhere((c) {
                              if (c.planetId == p.id) return true;
                              if (p.countryMaps.isNotEmpty && p.countryMaps.first.planetCode != null) {
                                if (c.code.toUpperCase() == p.countryMaps.first.planetCode!.toUpperCase()) return true;
                              }
                              final pClean = p.name.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '').trim();
                              final cClean = c.planetName.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '').trim();
                              return pClean.contains(cClean.split(' ').first) || cClean.contains(pClean.split(' ').first);
                            });
                            final safeColonyIdx = colonyIdx >= 0 ? colonyIdx : 0;
                            final startPlot = ((_activeWaves - 1) * 375) + (safeColonyIdx * 25) + 1;
                            final endPlot = startPlot + 24;

                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _navigateToPlanetArchipelago(p);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFF0284C7)
                                          .withValues(alpha: 0.22)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCurrent
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF334155),
                                    width: isCurrent ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            p.glowColor,
                                            p.primaryColor
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          p.name
                                              .split(' ')
                                              .last
                                              .replaceAll(')', ''),
                                          style:
                                              const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                p.name,
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (isCurrent) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF16A34A),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    'ACTIVE PLANET',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${p.countryMaps.first.name} • ${p.countryMaps.length} Islands (${p.totalPlots} Plots) • Active Wave $_activeWaves: #$startPlot-#$endPlot',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF94A3B8),
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Color(0xFF38BDF8),
                                        size: 14),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 🌌 COSMOS 1 CR+ LOOP SYSTEM ALLOCATION & RELOCATION DIALOG
  // =========================================================================
  void _showCosmosLoopDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF14181B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: const Icon(Icons.all_inclusive_rounded,
                        color: Color(0xFFFFD700), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cosmos 1 Cr+ Loop System',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const Text(
                          'Infinite Scaling: 25 Plots / Island across 15 Celestial Worlds (375 / Wave)',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Loop Architecture Explainer Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🪐 How Cosmic Loop Scaling Works:',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '1. Each island features exactly 25 plots. Wave 1 spans all 15 Celestial Worlds (Plots #1 to #375).\n'
                      '2. Sequential Progression:\n'
                      '   • Earth Prime (#1-#25) 🌍  • Mars (#26-#50) 🔴\n'
                      '   • Jupiter (#51-#75) 🟠      • Saturn (#76-#100) 🪐\n'
                      '   • The Moon (#101-#125) 🌕  • Europa (#126-#150) 🧊\n'
                      '   • Venus (#151-#175) 🟡     • Titan (#176-#200) 🪐\n'
                      '   • Pluto (#201-#225) ❄️      • Neptune (#226-#250) 🌊\n'
                      '   • Mercury (#251-#275) ⚪   • Ganymede (#276-#300) 🛰️\n'
                      '   • Uranus (#301-#325) 💎    • Triton (#326-#350) 🌀\n'
                      '   • Kepler-452b (#351-#375) 🌌\n'
                      '3. Once all 375 plots are claimed, the cosmic cycle opens Wave 2 on Earth Prime (#376)!\n'
                      '4. Every citizen is guaranteed a 100% unique, permanent global plot deed across 100 Crore+ citizens!',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // User's Assigned Cosmic Home
              Builder(
                builder: (context) {
                  final userPlot = PoketCosmosAllocationService
                          .instance.currentUserBirthPlot ??
                      PoketCosmosAllocationService.instance.currentBirthPlot;
                  final planetName = userPlot?.planetName ??
                      _selectedPlanet?.name ??
                      'Earth Prime 🌍';
                  final islandName = userPlot?.countryName ??
                      _selectedIsland?.name ??
                      'Vocabulary Bay';
                  final streetName = userPlot?.streetName ?? 'Reefway Avenue';
                  final plotNumber = userPlot?.plotNumber ?? 1;
                  final pinCode =
                      userPlot?.postalPinCode ?? 'PKT-W01-EP-I01-P01';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.2),
                          const Color(0xFF14181B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_rounded,
                            color: Color(0xFF38BDF8), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  '🌟 Birthplace (ജനിച്ച സ്ഥലം) & Residence',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '🌟 Birthplace: $planetName • $islandName',
                                style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              Text(
                                '🏡 Island: $islandName • $streetName',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5),
                              ),
                              Text(
                                'Deed: Plot #$plotNumber • PIN: $pinCode',
                                style: const TextStyle(
                                    color: Color(0xFFFFD700), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              // World Relocation Section
              const Text(
                '🔄 World Relocation (Switch Planet with Pocket Score):',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _planets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final p = _planets[i];
                    final isCurrent = p.id == _selectedPlanet?.id;

                    return ActionChip(
                      backgroundColor: isCurrent
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF1E293B),
                      label: Text(
                        p.name.split(' ').first,
                        style: TextStyle(
                          color: isCurrent ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      avatar: Text(p.name.split(' ').last.replaceAll(')', '')),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _confirmRelocationDialog(p);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRelocationDialog(PoketPlanet targetPlanet) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14181B),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white12)),
          title: Row(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 10),
              Text('Relocate to ${targetPlanet.name}?',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            'Transferring your habit manor to ${targetPlanet.name} costs 500 Pocket Score (PS).\n\n'
            'A new parcel deed will be issued on ${targetPlanet.countryMaps.first.name} in the cosmic registry.',
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedPlanet = targetPlanet;
                  _selectedIsland = targetPlanet.countryMaps.first;
                  _activeScreen = 1;
                });
                _loadIslandPlots(targetPlanet.countryMaps.first);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '🚀 Relocated to ${targetPlanet.name}! New deed registered.'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Confirm (500 PS)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
  Widget _buildIosBackButton({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 16),
        tooltip: 'Back',
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildHeaderIconTab({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 17,
          color: isSelected ? Colors.black : Colors.white60,
        ),
      ),
    );
  }

  Widget _buildFloatingActionBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    return IconButton(
      icon: Icon(icon, color: highlightColor ?? Colors.white, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
    );
  }
}