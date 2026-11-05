import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart' hide Matrix4;
import '/backend/supabase/supabase.dart';
import 'poket_cosmos_models.dart';
import 'flame_solar_system_game.dart';
import 'island_aerial_view.dart';
import '../verified_switch_page.dart';

/// 🌌 Poket Cosmos Explorer:
/// - Screen 0: Fullscreen Solar System & Scientific Moons (compact 3D tilt bend button & iOS back).
/// - Screen 1: Earth Prime's 30 English Learning Archipelago Islands (Horizontal Swipeable Cards
///   with Top 70% Aerial View matching reference photos, Title on Top, Slots underneath, distinct shapes & colors).
/// - Screen 2: Fullscreen Infinite Ocean Island Map (Edge-to-edge seamless ocean without square box breaks,
///   deep 6.5x zoom, 50 top-down 90-day habit house plots, and tap-to-inspect citizen profile sheet).
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage> {
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

  @override
  void initState() {
    super.initState();
    _islandPageController = PageController(viewportFraction: 0.84);
    _planets = _buildCosmosPlanets();
    _loadIslandPlots(_planets.first.countryMaps.first);
  }

  @override
  void dispose() {
    _islandPageController.dispose();
    _orbitInteractiveController.dispose();
    _aerialMapZoomController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 👥 FETCH REAL USERS FOR THE 50 PLOTS ON THE ACTIVE ISLAND
  // =========================================================================
  Future<void> _loadIslandPlots(PoketCountryMap island) async {
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select(
              'id, user_id, name, day, learning_day, pocket_score, is_vip, is_premium, created_at')
          .order('pocket_score', ascending: false)
          .limit(island.totalSlots.clamp(1, 50));

      final List<CitizenPlot> plots = [];
      final coords =
          IslandAerialPainter.get50PlotCoordinates(island.shapeStyle);

      if (res.isNotEmpty) {
        int idx = 0;
        for (final map in res) {
          if (idx >= 50) break;
          final userName = (map['name'] as String?)?.trim().isNotEmpty == true
              ? (map['name'] as String).trim()
              : 'Citizen #${idx + 1}';
          final day = (map['day'] as num?)?.toInt() ??
              (map['learning_day'] as num?)?.toInt() ??
              1;
          final score = (map['pocket_score'] as num?)?.toInt() ?? 500;
          final isVip = (map['is_vip'] as bool?) ?? false;
          final isPres = island.isPresidential || idx == 0;

          plots.add(
            CitizenPlot(
              plotNumber: idx + 1,
              userId: (map['user_id'] as String?) ??
                  (map['id'] as String?) ??
                  'user_$idx',
              userName: userName,
              userAvatar: '',
              day: day.clamp(1, 90),
              pocketScore: score,
              streetName: '${island.name} Boulevard',
              postOffice: island.name,
              countryName: island.name,
              planetName: 'Earth Prime',
              coordinates: coords[idx % coords.length],
              isVip: isVip,
              isPresident: isPres,
              tier: island.isPresidential
                  ? PlotDeedTier.presidential
                  : (idx <= 10
                      ? PlotDeedTier.beachfront
                      : PlotDeedTier.standard),
              postalPinCode:
                  'PK-${island.id.toString().padLeft(2, '0')}${(idx + 1).toString().padLeft(3, '0')}',
            ),
          );
          idx++;
        }
      }

      // Fill remaining plots up to island.totalSlots (default 50)
      final currentCount = plots.length;
      for (int i = currentCount; i < island.totalSlots && i < 50; i++) {
        plots.add(
          CitizenPlot(
            plotNumber: i + 1,
            userId: 'vacant_${i + 1}',
            userName: 'Plot #${i + 1}',
            userAvatar: '',
            day: ((i + 1) * 3) % 90 + 1,
            pocketScore: 300,
            streetName: '${island.name} Avenue',
            postOffice: island.name,
            countryName: island.name,
            planetName: 'Earth Prime',
            coordinates: coords[i % coords.length],
            status: PlotStatus.forSale,
            postalPinCode:
                'PK-${island.id.toString().padLeft(2, '0')}${(i + 1).toString().padLeft(3, '0')}',
          ),
        );
      }

      if (mounted) {
        setState(() {
          _currentIslandPlots = plots;
        });
      }
    } catch (e) {
      debugPrint('Error loading island plots: $e');
    }
  }

  // =========================================================================
  // 🌍 SCIENTIFIC SOLAR SYSTEM: 8 MAJOR PLANETS, KUIPER DWARF, INTERSTELLAR EXOPLANET & MOONS
  // =========================================================================
  static List<PoketPlanet> _buildCosmosPlanets() {
    return [
      // 1. Mercury ⚪ (Innermost Scorched World)
      const PoketPlanet(
        id: 1,
        name: 'Mercury ⚪',
        theme: 'Innermost Scorched Iron World',
        tagLine: 'High Velocity Orbit • Caloris Basin',
        primaryColor: Color(0xFFCBD5E1),
        glowColor: Color(0xFF94A3B8),
        radius: 10,
        orbitDistance: 85,
        orbitSpeed: 2.1,
        totalPlots: 50,
        occupiedPlots: 32,
        countryMaps: [
          PoketCountryMap(
            id: 101,
            name: 'Caloris Basin',
            tag: 'Crater Ridge',
            landColor: Color(0xFF64748B),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 32,
            climate: 'High Heat 🔥',
            climateIcon: Icons.local_fire_department_rounded,
            islandEmoji: '🌋',
            shapeStyle: IslandShapeStyle.fortressPlateau,
          ),
        ],
      ),

      // 2. Venus 🟡 (Amber Cloud Greenhouse)
      const PoketPlanet(
        id: 2,
        name: 'Venus 🟡',
        theme: 'Golden Veil Greenhouse',
        tagLine: 'Dense Amber Clouds & Sulfuric Highlands',
        primaryColor: Color(0xFFFDE047),
        glowColor: Color(0xFFD97706),
        radius: 14,
        orbitDistance: 130,
        orbitSpeed: 1.5,
        totalPlots: 50,
        occupiedPlots: 40,
        countryMaps: [
          PoketCountryMap(
            id: 201,
            name: 'Aphrodite Terra',
            tag: 'Golden Highlands',
            landColor: Color(0xFFB45309),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 40,
            climate: 'Gold Cloud ⛅',
            climateIcon: Icons.wb_cloudy_rounded,
            islandEmoji: '🏺',
            shapeStyle: IslandShapeStyle.crescentLagoon,
          ),
        ],
      ),

      // 3. Earth Prime 🌍 (Cradle of Habit Learning + Natural Satellite: The Moon 🌕)
      PoketPlanet(
        id: 3,
        name: 'Earth Prime 🌍',
        theme: 'Cradle of Habit Learning & Capital World',
        tagLine: 'Day 1-90 Habit Pioneers • 30 English Learning Islands',
        primaryColor: const Color(0xFF38BDF8),
        glowColor: const Color(0xFF0284C7),
        radius: 17,
        orbitDistance: 180,
        orbitSpeed: 1.0,
        totalPlots: 1451,
        occupiedPlots: 950,
        countryMaps: _buildEarth30EnglishIslands(),
        satellites: const [
          PoketSatellite(
            id: 30,
            name: 'The Moon 🌕',
            parentPlanetName: 'Earth Prime 🌍',
            satelliteType: 'Natural Moon of Earth',
            theme: 'Earth\'s Natural Satellite & Off-World Harbor',
            tagLine: 'Tidally Locked • First Off-World Colony (Tranquility Base)',
            primaryColor: Color(0xFFE2E8F0),
            glowColor: Color(0xFFCBD5E1),
            radius: 8.5,
            orbitDistance: 25.0,
            orbitSpeed: 2.4,
            totalPlots: 50,
            occupiedPlots: 36,
            countryMaps: [
              PoketCountryMap(
                id: 3001,
                name: 'Tranquility Base',
                tag: 'First Lunar Colony',
                landColor: Color(0xFF475569),
                waterColor: Color(0xFF0284C7),
                totalSlots: 50,
                filledSlots: 36,
                climate: 'Lunar Glow 🌕',
                climateIcon: Icons.nightlight_round,
                islandEmoji: '🌕',
                shapeStyle: IslandShapeStyle.ringAtoll,
              ),
            ],
          ),
        ],
      ),

      // 4. Mars 🔴 (The Red Planet)
      const PoketPlanet(
        id: 4,
        name: 'Mars 🔴',
        theme: 'Red Dunes Bastion',
        tagLine: 'Iron Oxide Canyons & Olympus Mons',
        primaryColor: Color(0xFFF97316),
        glowColor: Color(0xFFEA580C),
        radius: 13,
        orbitDistance: 240,
        orbitSpeed: 0.82,
        totalPlots: 50,
        occupiedPlots: 38,
        countryMaps: [
          PoketCountryMap(
            id: 401,
            name: 'Olympus Haven',
            tag: 'Volcano Oasis',
            landColor: Color(0xFF9A3412),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 38,
            climate: 'Rusty Breeze 🌪️',
            climateIcon: Icons.air_rounded,
            islandEmoji: '🏜️',
            shapeStyle: IslandShapeStyle.starAtoll,
          ),
        ],
      ),

      // 5. Jupiter 🟠 (The Gas Giant + Satellites: Europa 🧊 & Ganymede 🛡️)
      const PoketPlanet(
        id: 5,
        name: 'Jupiter 🟠',
        theme: 'Great Storm Giant',
        tagLine: 'Colossal Gas Bands & Galilean Satellites',
        primaryColor: Color(0xFFFDBA74),
        glowColor: Color(0xFFC2410C),
        radius: 26,
        orbitDistance: 315,
        orbitSpeed: 0.55,
        totalPlots: 50,
        occupiedPlots: 42,
        countryMaps: [
          PoketCountryMap(
            id: 501,
            name: 'Red Spot Atoll',
            tag: 'Storm Center',
            landColor: Color(0xFF7C2D12),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 42,
            climate: 'Thunder Storm ⚡',
            climateIcon: Icons.bolt_rounded,
            islandEmoji: '🌪️',
            shapeStyle: IslandShapeStyle.ringAtoll,
          ),
        ],
        satellites: [
          PoketSatellite(
            id: 51,
            name: 'Europa 🧊',
            parentPlanetName: 'Jupiter 🟠',
            satelliteType: 'Jupiter\'s Oceanic Moon',
            theme: 'Subsurface Liquid Ocean beneath Ice Shell',
            tagLine: 'Cryo Tide Vault • Conamara Chaos',
            primaryColor: Color(0xFFBAE6FD),
            glowColor: Color(0xFF38BDF8),
            radius: 8.0,
            orbitDistance: 27.0,
            orbitSpeed: 2.1,
            totalPlots: 50,
            occupiedPlots: 31,
            countryMaps: [
              PoketCountryMap(
                id: 5101,
                name: 'Conamara Chaos',
                tag: 'Liquid Ocean Vault',
                landColor: Color(0xFF0284C7),
                waterColor: Color(0xFF38BDF8),
                totalSlots: 50,
                filledSlots: 31,
                climate: 'Cryo Tide 🌊',
                climateIcon: Icons.water_drop_rounded,
                islandEmoji: '🧊',
                shapeStyle: IslandShapeStyle.crescentLagoon,
              ),
            ],
          ),
          PoketSatellite(
            id: 52,
            name: 'Ganymede 🛡️',
            parentPlanetName: 'Jupiter 🟠',
            satelliteType: 'Jupiter\'s Super-Moon',
            theme: 'Largest Satellite in Solar System (Bigger than Mercury)',
            tagLine: 'Internal Magnetic Dynamo • Silicate Highlands',
            primaryColor: Color(0xFF94A3B8),
            glowColor: Color(0xFF64748B),
            radius: 9.2,
            orbitDistance: 40.0,
            orbitSpeed: 1.5,
            totalPlots: 50,
            occupiedPlots: 26,
            countryMaps: [
              PoketCountryMap(
                id: 5201,
                name: 'Perrine Regio',
                tag: 'Magnetic Ocean Citadel',
                landColor: Color(0xFF475569),
                waterColor: Color(0xFF0284C7),
                totalSlots: 50,
                filledSlots: 26,
                climate: 'Magnetic Glow ⚡',
                climateIcon: Icons.shield_rounded,
                islandEmoji: '🛡️',
                shapeStyle: IslandShapeStyle.fortressPlateau,
              ),
            ],
          ),
        ],
      ),

      // 6. Saturn 🪐 (The Ringed Giant + Satellite: Titan 🪐)
      const PoketPlanet(
        id: 6,
        name: 'Saturn 🪐',
        theme: 'Ringed Majesty',
        tagLine: 'Golden Ice Dust Rings & Methane Satellites',
        primaryColor: Color(0xFFFEF08A),
        glowColor: Color(0xFFCA8A04),
        radius: 22,
        orbitDistance: 405,
        orbitSpeed: 0.42,
        totalPlots: 50,
        occupiedPlots: 35,
        countryMaps: [
          PoketCountryMap(
            id: 601,
            name: 'Cassini Glade',
            tag: 'Golden Ring Plateau',
            landColor: Color(0xFF854D0E),
            waterColor: Color(0xFF0EA5E9),
            totalSlots: 50,
            filledSlots: 35,
            climate: 'Cold Gold Mists ❄️',
            climateIcon: Icons.ac_unit_rounded,
            islandEmoji: '👑',
            shapeStyle: IslandShapeStyle.dualIsletBridge,
          ),
        ],
        satellites: [
          PoketSatellite(
            id: 61,
            name: 'Titan 🪐',
            parentPlanetName: 'Saturn 🪐',
            satelliteType: 'Saturn\'s Atmospheric Moon',
            theme: 'Dense Nitrogen Sky & Liquid Methane Seas',
            tagLine: 'Golden Clouds • Hydrocarbon Ocean Harbor (Kraken Mare)',
            primaryColor: Color(0xFFFBBF24),
            glowColor: Color(0xFFD97706),
            radius: 9.0,
            orbitDistance: 34.0,
            orbitSpeed: 1.8,
            totalPlots: 50,
            occupiedPlots: 38,
            countryMaps: [
              PoketCountryMap(
                id: 6101,
                name: 'Kraken Mare Bay',
                tag: 'Liquid Methane Sea',
                landColor: Color(0xFF92400E),
                waterColor: Color(0xFFD97706),
                totalSlots: 50,
                filledSlots: 38,
                climate: 'Golden Rain 🌧️',
                climateIcon: Icons.umbrella_rounded,
                islandEmoji: '🪐',
                shapeStyle: IslandShapeStyle.ringAtoll,
              ),
            ],
          ),
        ],
      ),

      // 7. Uranus 💎 (Cyan Ice Giant)
      const PoketPlanet(
        id: 7,
        name: 'Uranus 💎',
        theme: 'Cyan Ice Vault',
        tagLine: 'Tilt 98° Orbit • Diamond Rain Cryo',
        primaryColor: Color(0xFF67E8F9),
        glowColor: Color(0xFF06B6D4),
        radius: 18,
        orbitDistance: 490,
        orbitSpeed: 0.32,
        totalPlots: 50,
        occupiedPlots: 28,
        countryMaps: [
          PoketCountryMap(
            id: 701,
            name: 'Miranda Glade',
            tag: 'Cyan Ice Cliffs',
            landColor: Color(0xFF0E7490),
            waterColor: Color(0xFF0891B2),
            totalSlots: 50,
            filledSlots: 28,
            climate: 'Cryo Chill 🧊',
            climateIcon: Icons.severe_cold_rounded,
            islandEmoji: '🧊',
            shapeStyle: IslandShapeStyle.hookPeninsula,
          ),
        ],
      ),

      // 8. Neptune 🌊 (Supersonic Blue Giant + Satellite: Triton 🔱)
      const PoketPlanet(
        id: 8,
        name: 'Neptune 🌊',
        theme: 'Abyssal Trident Giant',
        tagLine: 'Supersonic Winds & Cryo Geyser Satellites',
        primaryColor: Color(0xFF60A5FA),
        glowColor: Color(0xFF2563EB),
        radius: 17,
        orbitDistance: 575,
        orbitSpeed: 0.22,
        totalPlots: 50,
        occupiedPlots: 30,
        countryMaps: [
          PoketCountryMap(
            id: 801,
            name: 'Great Dark Haven',
            tag: 'Deep Ultramarine Rim',
            landColor: Color(0xFF1E3A8A),
            waterColor: Color(0xFF1D4ED8),
            totalSlots: 50,
            filledSlots: 30,
            climate: 'Deep Gale 💨',
            climateIcon: Icons.cyclone_rounded,
            islandEmoji: '🔱',
            shapeStyle: IslandShapeStyle.heartSanctuary,
          ),
        ],
        satellites: [
          PoketSatellite(
            id: 81,
            name: 'Triton 🔱',
            parentPlanetName: 'Neptune 🌊',
            satelliteType: 'Neptune\'s Cryo Moon',
            theme: 'Retrograde Nitrogen Geyser Satellite',
            tagLine: 'Sub-Zero Cryo Spouts • Kuiper Belt Capture',
            primaryColor: Color(0xFF93C5FD),
            glowColor: Color(0xFF3B82F6),
            radius: 7.8,
            orbitDistance: 27.0,
            orbitSpeed: -1.9, // Retrograde orbit!
            totalPlots: 50,
            occupiedPlots: 24,
            countryMaps: [
              PoketCountryMap(
                id: 8101,
                name: 'Triton Geyser',
                tag: 'Cryo Spout Basin',
                landColor: Color(0xFF1E40AF),
                waterColor: Color(0xFF60A5FA),
                totalSlots: 50,
                filledSlots: 24,
                climate: 'Cryo Plume ❄️',
                climateIcon: Icons.ac_unit_rounded,
                islandEmoji: '🔱',
                shapeStyle: IslandShapeStyle.crescentLagoon,
              ),
            ],
          ),
        ],
      ),

      // 9. Pluto ❄️ (Dwarf Planet • Kuiper Belt Outer Rim)
      const PoketPlanet(
        id: 9,
        name: 'Pluto ❄️',
        theme: 'Kuiper Belt Outer Rim (Dwarf Planet)',
        tagLine: 'Nitrogen Ice Dunes & Heart of Sputnik Planitia',
        primaryColor: Color(0xFFE2E8F0),
        glowColor: Color(0xFF94A3B8),
        radius: 9,
        orbitDistance: 660,
        orbitSpeed: 0.16,
        totalPlots: 50,
        occupiedPlots: 22,
        isDwarfPlanet: true,
        countryMaps: [
          PoketCountryMap(
            id: 901,
            name: 'Sputnik Planitia',
            tag: 'Heart of Pluto',
            landColor: Color(0xFF475569),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 22,
            climate: 'Glacial Calm ❄️',
            climateIcon: Icons.ac_unit_rounded,
            islandEmoji: '🤍',
            shapeStyle: IslandShapeStyle.heartSanctuary,
          ),
        ],
      ),

      // 10. Kepler-452b 🌿 (Interstellar Earth 2.0 • Cygnus Constellation)
      const PoketPlanet(
        id: 452,
        name: 'Kepler-452b 🌿',
        theme: 'Interstellar Habitable Frontier (Earth 2.0)',
        tagLine: '1,400 Light-Years Away in Cygnus • Super-Earth Biosphere',
        primaryColor: Color(0xFF10B981),
        glowColor: Color(0xFF059669),
        radius: 20,
        orbitDistance: 765,
        orbitSpeed: 0.11,
        isExoplanet: true,
        totalPlots: 50,
        occupiedPlots: 15,
        countryMaps: [
          PoketCountryMap(
            id: 45201,
            name: 'Cygnus Haven',
            tag: 'Interstellar Earth 2.0',
            landColor: Color(0xFF15803D),
            waterColor: Color(0xFF0D9488),
            totalSlots: 50,
            filledSlots: 15,
            climate: 'Eternal Spring 🌸',
            climateIcon: Icons.eco_rounded,
            islandEmoji: '🌿',
            shapeStyle: IslandShapeStyle.crescentLagoon,
          ),
        ],
      ),
    ];
  }

  /// 🏝️ 30 English Learning Islands with Distinct Shapes & 50 Plots
  static List<PoketCountryMap> _buildEarth30EnglishIslands() {
    return [
      // 👑 Island #0: President Mus'ab's Exclusive Sanctuary
      const PoketCountryMap(
        id: 1,
        name: 'Crown Apex 👑',
        tag: 'Presidential Sanctuary',
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
      ),

      // 1. Vocabulary Bay
      const PoketCountryMap(
        id: 2,
        name: 'Vocabulary Bay',
        tag: 'Word Builders',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF06B6D4), // Coral turquoise
        totalSlots: 50,
        filledSlots: 44,
        climate: 'Warm Coastal 🌊',
        climateIcon: Icons.waves_rounded,
        description:
            'Curved turquoise crescent bay where daily vocabulary words are mastered.',
        islandEmoji: '📖',
        shapeStyle: IslandShapeStyle.crescentLagoon,
      ),

      // 2. Sentence Reef
      const PoketCountryMap(
        id: 3,
        name: 'Sentence Reef',
        tag: 'Grammar Flow',
        landColor: Color(0xFF0D9488),
        waterColor: Color(0xFF0EA5E9), // Aquamarine
        totalSlots: 50,
        filledSlots: 41,
        climate: 'Tropical Breeze 🍃',
        climateIcon: Icons.air_rounded,
        description:
            'Winding dragon reef connecting clauses into powerful English sentences.',
        islandEmoji: '✍️',
        shapeStyle: IslandShapeStyle.sCurveArchipelago,
      ),

      // 3. Grammar Isle
      const PoketCountryMap(
        id: 4,
        name: 'Grammar Isle',
        tag: 'Core Rules',
        landColor: Color(0xFF059669),
        waterColor: Color(0xFF10B981), // Emerald Mint
        totalSlots: 50,
        filledSlots: 48,
        climate: 'Clear Skies ☀️',
        climateIcon: Icons.wb_sunny_rounded,
        description:
            '5-pointed coral star island forming the foundation of English grammar.',
        islandEmoji: '⭐',
        shapeStyle: IslandShapeStyle.starAtoll,
      ),

      // 4. Idiom Atoll
      const PoketCountryMap(
        id: 5,
        name: 'Idiom Atoll',
        tag: 'Native Expressions',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF3B82F6), // Azure Sapphire
        totalSlots: 50,
        filledSlots: 39,
        climate: 'Ocean Mist 🌫️',
        climateIcon: Icons.cloud_rounded,
        description:
            'Circular ring atoll enclosing a tranquil inner saltwater lagoon.',
        islandEmoji: '💡',
        shapeStyle: IslandShapeStyle.ringAtoll,
      ),

      // 5. Phonics Cay
      const PoketCountryMap(
        id: 6,
        name: 'Phonics Cay',
        tag: 'Sound Mastery',
        landColor: Color(0xFF166534),
        waterColor: Color(0xFF14B8A6), // Sunlit turquoise
        totalSlots: 50,
        filledSlots: 36,
        climate: 'Sunny Sand 🏖️',
        climateIcon: Icons.beach_access_rounded,
        description:
            'Hook-shaped peninsula with white sand beaches for pronunciation clarity.',
        islandEmoji: '🔊',
        shapeStyle: IslandShapeStyle.hookPeninsula,
      ),

      // 6. Fluency Haven
      const PoketCountryMap(
        id: 7,
        name: 'Fluency Haven',
        tag: 'Continuous Speech',
        landColor: Color(0xFF14532D),
        waterColor: Color(0xFF0284C7), // Deep lagoon
        totalSlots: 50,
        filledSlots: 47,
        climate: 'Lush Mists 🌿',
        climateIcon: Icons.forest_rounded,
        description:
            'Twin islets linked by a wooden footbridge celebrating seamless speech.',
        islandEmoji: '🗣️',
        shapeStyle: IslandShapeStyle.dualIsletBridge,
      ),

      // 7. Syntax Strand
      const PoketCountryMap(
        id: 8,
        name: 'Syntax Strand',
        tag: 'Structure Order',
        landColor: Color(0xFF047857),
        waterColor: Color(0xFF06B6D4),
        totalSlots: 50,
        filledSlots: 42,
        climate: 'Mild Tropical 🌴',
        climateIcon: Icons.eco_rounded,
        description:
            'Heart-shaped tropical haven where word order and sentence syntax thrive.',
        islandEmoji: '💖',
        shapeStyle: IslandShapeStyle.heartSanctuary,
      ),

      // 8. Lexicon Oasis
      const PoketCountryMap(
        id: 9,
        name: 'Lexicon Oasis',
        tag: 'Advanced Diction',
        landColor: Color(0xFF0F766E),
        waterColor: Color(0xFF0D9488),
        totalSlots: 50,
        filledSlots: 45,
        climate: 'Fresh Palms 🌴',
        climateIcon: Icons.park_rounded,
        description:
            '3-leaf clover island rich with advanced vocabulary and synonym reserves.',
        islandEmoji: '🍀',
        shapeStyle: IslandShapeStyle.cloverBays,
      ),

      // 9. Verb Vista
      const PoketCountryMap(
        id: 10,
        name: 'Verb Vista',
        tag: 'Action Hub',
        landColor: Color(0xFF115E59),
        waterColor: Color(0xFF6366F1), // Royal Indigo
        totalSlots: 50,
        filledSlots: 49,
        climate: 'Energizing Wind ⚡',
        climateIcon: Icons.bolt_rounded,
        description:
            'High coral plateau commanding dynamic active verb formulations.',
        islandEmoji: '🏃',
        shapeStyle: IslandShapeStyle.fortressPlateau,
      ),

      // 10. Pronoun Peninsula
      const PoketCountryMap(
        id: 11,
        name: 'Pronoun Peninsula',
        tag: 'Identity & Reference',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF059669),
        totalSlots: 50,
        filledSlots: 35,
        climate: 'Gentle Bay ⛵',
        climateIcon: Icons.sailing_rounded,
        description:
            'Curved sandy peninsula with calm anchorages for subject/object pronouns.',
        islandEmoji: '👥',
        shapeStyle: IslandShapeStyle.crescentLagoon,
      ),

      // 11. Tense Territory
      const PoketCountryMap(
        id: 12,
        name: 'Tense Territory',
        tag: 'Past Present Future',
        landColor: Color(0xFF0D9488),
        waterColor: Color(0xFF2563EB),
        totalSlots: 50,
        filledSlots: 43,
        climate: 'Time Currents ⏳',
        climateIcon: Icons.hourglass_bottom_rounded,
        description:
            'Meandering S-curve spanning past, present, and continuous tense habit mastery.',
        islandEmoji: '⏳',
        shapeStyle: IslandShapeStyle.sCurveArchipelago,
      ),

      // 12. Adverb Archipelago
      const PoketCountryMap(
        id: 13,
        name: 'Adverb Atoll',
        tag: 'Modifying Nuance',
        landColor: Color(0xFF059669),
        waterColor: Color(0xFF0891B2),
        totalSlots: 50,
        filledSlots: 37,
        climate: 'Speed Breeze 💨',
        climateIcon: Icons.speed_rounded,
        description:
            'Star-shaped coral reef refining how, when, and where actions take place.',
        islandEmoji: '🚀',
        shapeStyle: IslandShapeStyle.starAtoll,
      ),

      // 13. Echo Lagoon
      const PoketCountryMap(
        id: 14,
        name: 'Echo Lagoon',
        tag: 'Active Listening',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF4F46E5),
        totalSlots: 50,
        filledSlots: 40,
        climate: 'Harmonic Waters 🎵',
        climateIcon: Icons.surround_sound_rounded,
        description:
            'Ring atoll whose crystalline inner waters echo conversational dialogue.',
        islandEmoji: '🎧',
        shapeStyle: IslandShapeStyle.ringAtoll,
      ),

      // 14. Diction Dune
      const PoketCountryMap(
        id: 15,
        name: 'Diction Dune',
        tag: 'Crisp Enunciation',
        landColor: Color(0xFF166534),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 38,
        climate: 'Coastal Sun ☀️',
        climateIcon: Icons.wb_sunny_rounded,
        description:
            'Hook peninsula of golden sand dunes shaping clear verbal expression.',
        islandEmoji: '🗣️',
        shapeStyle: IslandShapeStyle.hookPeninsula,
      ),

      // 15. Rhythm Reach
      const PoketCountryMap(
        id: 16,
        name: 'Rhythm Reach',
        tag: 'Cadence & Stress',
        landColor: Color(0xFF14532D),
        waterColor: Color(0xFF00BCD4),
        totalSlots: 50,
        filledSlots: 41,
        climate: 'Warm Tide 🌊',
        climateIcon: Icons.waves_rounded,
        description:
            'Connected twin islets practicing natural English sentence melody and beat.',
        islandEmoji: '🥁',
        shapeStyle: IslandShapeStyle.dualIsletBridge,
      ),

      // 16. Accent Isle
      const PoketCountryMap(
        id: 17,
        name: 'Accent Isle',
        tag: 'Intonation & Vibe',
        landColor: Color(0xFF047857),
        waterColor: Color(0xFF38BDF8),
        totalSlots: 50,
        filledSlots: 46,
        climate: 'Vibrant Light ✨',
        climateIcon: Icons.auto_awesome_rounded,
        description:
            'Heart sanctuary tuned for smooth international English phonetics.',
        islandEmoji: '🎙️',
        shapeStyle: IslandShapeStyle.heartSanctuary,
      ),

      // 17. Clause Cove
      const PoketCountryMap(
        id: 18,
        name: 'Clause Cove',
        tag: 'Complex Conjunctions',
        landColor: Color(0xFF0F766E),
        waterColor: Color(0xFF1D4ED8),
        totalSlots: 50,
        filledSlots: 39,
        climate: 'Deep Ocean Blue 🌊',
        climateIcon: Icons.water_rounded,
        description:
            '3-leaf clover bay uniting independent and dependent clauses.',
        islandEmoji: '⚓',
        shapeStyle: IslandShapeStyle.cloverBays,
      ),

      // 18. Metaphor Marina
      const PoketCountryMap(
        id: 19,
        name: 'Metaphor Marina',
        tag: 'Poetic Figurative',
        landColor: Color(0xFF115E59),
        waterColor: Color(0xFF0F766E),
        totalSlots: 50,
        filledSlots: 44,
        climate: 'Scenic Marina ⛵',
        climateIcon: Icons.anchor_rounded,
        description:
            'Fortress harbor where idioms and figurative English expressions anchor.',
        islandEmoji: '🎨',
        shapeStyle: IslandShapeStyle.fortressPlateau,
      ),

      // 19. Dialogue Drift
      const PoketCountryMap(
        id: 20,
        name: 'Dialogue Drift',
        tag: 'Casual Chat',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 48,
        climate: 'Warm Current 🌊',
        climateIcon: Icons.chat_bubble_rounded,
        description:
            'Crescent beach where daily 2-person habit conversations take root.',
        islandEmoji: '💬',
        shapeStyle: IslandShapeStyle.crescentLagoon,
      ),

      // 20. Proverb Port
      const PoketCountryMap(
        id: 21,
        name: 'Proverb Port',
        tag: 'Timeless Wisdom',
        landColor: Color(0xFF0D9488),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 50,
        filledSlots: 42,
        climate: 'Sunny Trade Winds ⛵',
        climateIcon: Icons.explore_rounded,
        description:
            'S-curve trading port embodying classical English proverbs.',
        islandEmoji: '📜',
        shapeStyle: IslandShapeStyle.sCurveArchipelago,
      ),

      // 21. Synonym Shoal
      const PoketCountryMap(
        id: 22,
        name: 'Synonym Shoal',
        tag: 'Varied Vocabulary',
        landColor: Color(0xFF059669),
        waterColor: Color(0xFF10B981),
        totalSlots: 50,
        filledSlots: 38,
        climate: 'Emerald Waters 💎',
        climateIcon: Icons.diamond_rounded,
        description:
            'Star-shaped shoal expanding diverse alternative word choices.',
        islandEmoji: '💎',
        shapeStyle: IslandShapeStyle.starAtoll,
      ),

      // 22. Antonym Atoll
      const PoketCountryMap(
        id: 23,
        name: 'Antonym Atoll',
        tag: 'Opposites & Contrast',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF1E40AF),
        totalSlots: 50,
        filledSlots: 36,
        climate: 'Contrasting Winds 🌓',
        climateIcon: Icons.contrast_rounded,
        description:
            'Ring atoll contrasting antonym pairs in clear conversational contexts.',
        islandEmoji: '🌓',
        shapeStyle: IslandShapeStyle.ringAtoll,
      ),

      // 23. Jargon Jungle
      const PoketCountryMap(
        id: 24,
        name: 'Jargon Jungle',
        tag: 'Tech & Professional',
        landColor: Color(0xFF166534),
        waterColor: Color(0xFF047857),
        totalSlots: 50,
        filledSlots: 43,
        climate: 'Rich Forest 🌲',
        climateIcon: Icons.nature_rounded,
        description:
            'Hook peninsula reserved for professional, workplace, and tech vocabulary.',
        islandEmoji: '💼',
        shapeStyle: IslandShapeStyle.hookPeninsula,
      ),

      // 24. Poetry Point
      const PoketCountryMap(
        id: 25,
        name: 'Poetry Point',
        tag: 'Rhyme & Meter',
        landColor: Color(0xFF14532D),
        waterColor: Color(0xFF7C3AED),
        totalSlots: 50,
        filledSlots: 41,
        climate: 'Sunset Violet 🌅',
        climateIcon: Icons.wb_twilight_rounded,
        description:
            'Twin islets honoring rhythm, rhyme, and lyrical English expression.',
        islandEmoji: '🎭',
        shapeStyle: IslandShapeStyle.dualIsletBridge,
      ),

      // 25. Vowel Valley
      const PoketCountryMap(
        id: 26,
        name: 'Vowel Valley',
        tag: 'A-E-I-O-U Clarity',
        landColor: Color(0xFF047857),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 45,
        climate: 'Clear Resonant Bay 🌿',
        climateIcon: Icons.hearing_rounded,
        description:
            'Heart-shaped valley perfecting short, long, and diphthong vowel sounds.',
        islandEmoji: '🔤',
        shapeStyle: IslandShapeStyle.heartSanctuary,
      ),

      // 26. Consonant Coast
      const PoketCountryMap(
        id: 27,
        name: 'Consonant Coast',
        tag: 'Sharp Articulation',
        landColor: Color(0xFF0F766E),
        waterColor: Color(0xFF0E7490),
        totalSlots: 50,
        filledSlots: 39,
        climate: 'Brisk Sea Air 🌊',
        climateIcon: Icons.air_rounded,
        description:
            '3-leaf clover coastline training tongue, teeth, and lip articulation.',
        islandEmoji: '🔠',
        shapeStyle: IslandShapeStyle.cloverBays,
      ),

      // 27. Slang Sound
      const PoketCountryMap(
        id: 28,
        name: 'Slang Sound',
        tag: 'Modern Idiomatic',
        landColor: Color(0xFF115E59),
        waterColor: Color(0xFF2563EB),
        totalSlots: 50,
        filledSlots: 47,
        climate: 'Vibrant Beats ⚡',
        climateIcon: Icons.flash_on_rounded,
        description:
            'Coral plateau decoding contemporary colloquial idioms and native speech.',
        islandEmoji: '🔥',
        shapeStyle: IslandShapeStyle.fortressPlateau,
      ),

      // 28. Spelling Sand
      const PoketCountryMap(
        id: 29,
        name: 'Spelling Sand',
        tag: 'Orthography & Roots',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF0D9488),
        totalSlots: 50,
        filledSlots: 40,
        climate: 'Golden Sun 🏖️',
        climateIcon: Icons.spellcheck_rounded,
        description:
            'Crescent sandbar mastering Latin/Greek prefixes, roots, and silent letters.',
        islandEmoji: '📝',
        shapeStyle: IslandShapeStyle.crescentLagoon,
      ),

      // 29. Rhetoric Ridge
      const PoketCountryMap(
        id: 30,
        name: 'Rhetoric Ridge',
        tag: 'Persuasion & Debate',
        landColor: Color(0xFF0D9488),
        waterColor: Color(0xFF1E3A8A),
        totalSlots: 50,
        filledSlots: 50,
        climate: 'High Ridge Wind 🦅',
        climateIcon: Icons.campaign_rounded,
        description:
            'Majestic S-curve ridge where masterful English debates and speeches echo.',
        islandEmoji: '🏛️',
        shapeStyle: IslandShapeStyle.sCurveArchipelago,
      ),
    ];
  }

  void _navigateToPlanetArchipelago(PoketPlanet planet) {
    setState(() {
      _selectedPlanet = planet;
      _activeScreen = 1;
      _currentIslandIndex = 0;
    });
    _loadIslandPlots(planet.countryMaps.first);
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
    _orbitInteractiveController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
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
      minScale: 0.4,
      maxScale: 3.5,
      boundaryMargin: const EdgeInsets.all(400),
      child: SizedBox(
        width: 1100,
        height: 1100,
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

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.primaryColor.withValues(alpha: 0.2),
                        border: Border.all(color: p.primaryColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          isApex
                              ? '👑'
                              : p.name.split(' ').last.replaceAll(')', ''),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
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
                          if (p.satellites.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: p.satellites.map((sat) {
                                return InkWell(
                                  onTap: () => _navigateToPlanetArchipelago(sat.toPlanet()),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: sat.primaryColor.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: sat.primaryColor.withValues(alpha: 0.4), width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${sat.name} • ${sat.satelliteType}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Icon(Icons.arrow_forward_rounded, size: 9, color: Colors.white70),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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
        currentIsland?.waterColor.withValues(alpha: 0.35) ??
            const Color(0xFF0D121D),
        currentIsland?.landColor.withValues(alpha: 0.18) ??
            const Color(0xFF030712),
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
                    setState(() => _activeScreen = 0);
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
                          '${islands.length} Distinct Islands • 50 Plots per Island',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showCosmosLoopDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.all_inclusive_rounded, color: Color(0xFFFFD700), size: 14),
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
                                : 'Filled Slots: ${island.filledSlots} / 50 Plots',
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

                  // Explore Island Button (Full Width)
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: island.isPresidential
                            ? const Color(0xFFFFD700)
                            : island.waterColor,
                        foregroundColor:
                            island.isPresidential ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: () => _navigateToFullscreenAerialMap(island),
                      icon: const Icon(Icons.travel_explore_rounded, size: 18),
                      label: Text(
                        island.isPresidential
                            ? 'Enter Crown Sanctuary 👑'
                            : 'Explore Island 🏝️',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
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
  // =========================================================================
  Widget _buildFullscreenAerialMapView() {
    final island = _selectedIsland ?? _planets.first.countryMaps.first;

    return Scaffold(
      backgroundColor: island.waterColor, // Infinite matching ocean background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌊 Fullscreen Living Atmosphere & Oceanic Real Estate Canvas
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final worldDim = math.max(constraints.maxWidth, constraints.maxHeight) * 1.85;

                return InteractiveViewer(
                  transformationController: _aerialMapZoomController,
                  minScale: 0.55, // Allows pulling back to see the majestic island in the vast ocean
                  maxScale: 3.2,  // Deep habit house zoom
                  boundaryMargin: EdgeInsets.all(worldDim * 0.4),
                  clipBehavior: Clip.none,
                  child: SizedBox(
                    width: worldDim,
                    height: worldDim,
                    child: IslandAerialViewWidget(
                      island: island,
                      isInteractive: true,
                      plots: _currentIslandPlots,
                      selectedPlotNumber: _inspectedPlot?.plotNumber,
                      onPlotTapped: _showPlotDetailsSheet,
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
                              : '50 Plots • Pinch to Zoom in & Inspect Houses',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showCosmosLoopDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.all_inclusive_rounded, color: Color(0xFFFFD700), size: 14),
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
                  IconButton(
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Zoom In',
                    onPressed: () {
                      final current =
                          _aerialMapZoomController.value.getMaxScaleOnAxis();
                      final s = (current * 1.3).clamp(0.85, 3.5);
                      _aerialMapZoomController.value = Matrix4.diagonal3Values(s, s, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Zoom Out',
                    onPressed: () {
                      final current =
                          _aerialMapZoomController.value.getMaxScaleOnAxis();
                      final s = (current * 0.77).clamp(0.85, 3.5);
                      _aerialMapZoomController.value = Matrix4.diagonal3Values(s, s, 1.0);
                    },
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded,
                        color: Color(0xFFFFD700), size: 20),
                    tooltip: 'Reset Zoom',
                    onPressed: () {
                      _aerialMapZoomController.value = Matrix4.identity();
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
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (plot.userId.isNotEmpty &&
                        !plot.userId.startsWith('empty') &&
                        !plot.userId.startsWith('vacant')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerfiedSwitchPage(userId: plot.userId),
                        ),
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
                  icon: const Icon(Icons.person_pin_rounded, size: 20),
                  label: const Text(
                    'View Profile 👤',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                      border:
                          Border.all(color: const Color(0xFFFFD700), width: 1.5),
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
                          'Infinite Scaling: 50 Users / Island across 9 Planets',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
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
                      '1. As new citizens join, they fill 50 plots on Island 1 of Earth Prime.\n'
                      '2. The loop moves across: Mercury ⚪ -> Venus 🟡 -> Mars 🔴 -> Jupiter 🟠 -> Saturn 🪐 -> Uranus 💎 -> Neptune 🌊 -> Pluto ❄️.\n'
                      '3. Once Pluto fills up, the cosmic cycle wraps back to Earth Prime generating Island Cycle II!\n'
                      '4. This algorithm guarantees unique, permanent real estate for 1 Crore (10 Million+) to 10 Crore+ citizens!',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // User's Assigned Cosmic Home
              Container(
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
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
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
                          const Text('🌟 Birthplace (ജനിച്ച സ്ഥലം) & Residence',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '🌟 Birthplace: The Moon 🌕 • Tranquility Base',
                            style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          Text(
                            '🏡 Current: ${_selectedPlanet?.name ?? "Earth Prime 🌍"} • ${_selectedIsland?.name ?? "Vocabulary Bay"}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5),
                          ),
                          const Text('Deed: Plot #14 • PIN: PK-P3-IS002-SL14',
                              style: TextStyle(
                                  color: Color(0xFFFFD700), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
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
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
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
