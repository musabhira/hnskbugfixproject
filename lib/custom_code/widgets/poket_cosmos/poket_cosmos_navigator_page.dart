import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'poket_cosmos_models.dart';
import 'flame_solar_system_game.dart';
import 'island_aerial_view.dart';
import 'island_street_drive_view.dart';

/// 🌌 Poket Cosmos Explorer:
/// - Screen 0: Fullscreen Solar System & Scientific Moons (with compact 3D tilt bend button & iOS back).
/// - Screen 1: Earth Prime's 30 Islands Archipelago (Horizontal Swipeable Cards where top 70% is
///   the aerial bird's-eye view matching user's images, with President's Sanctuary Island 👑 and 50-150 slots).
/// - Screen 2: Fullscreen Aerial Island Map (InteractiveViewer smooth zoom in/out with ocean filling bounds).
/// - Screen 3: 2-Point Perspective Street Drive View (drive car along street, front-facing habit houses).
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage> {
  // Hub mode: 0 = Flame 3D Solar System, 1 = Minimal Planet Directory
  int _hubMode = 0;

  // Active Screen: 0 = Solar Hub, 1 = Archipelago Carousel, 2 = Fullscreen Aerial Map, 3 = Street Drive View
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

  @override
  void initState() {
    super.initState();
    _islandPageController = PageController(viewportFraction: 0.84);

    _planets = [
      // 🌍 APEX: Earth Prime (Poket World) with President's Island & 29 Diverse Islands
      PoketPlanet(
        id: 3,
        name: 'Earth Prime 🌍',
        theme: 'Cradle of Civilization & Apex Capital',
        tagLine: 'Day 1-90 Habit Pioneers • 30 Diverse Islands',
        primaryColor: const Color(0xFF38BDF8),
        glowColor: const Color(0xFF0284C7),
        radius: 17,
        orbitDistance: 175,
        orbitSpeed: 1.0,
        totalPlots: 2200,
        occupiedPlots: 1420,
        countryMaps: _buildEarth30Islands(),
      ),

      // ⚪ Mercury
      const PoketPlanet(
        id: 1,
        name: 'Mercury ⚪',
        theme: 'Swift Iron Frontier',
        tagLine: 'High Velocity Orbit • Sun Scorched Basins',
        primaryColor: Color(0xFFCBD5E1),
        glowColor: Color(0xFF94A3B8),
        radius: 10,
        orbitDistance: 85,
        orbitSpeed: 2.1,
        totalPlots: 100,
        occupiedPlots: 45,
        countryMaps: [
          PoketCountryMap(
            id: 101,
            name: 'Caloris Basin Atoll',
            tag: 'Crater Ridge',
            landColor: Color(0xFF64748B),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 32,
            climate: 'High Heat 🔥',
            climateIcon: Icons.local_fire_department_rounded,
            islandEmoji: '🌋',
          ),
        ],
      ),

      // 🟡 Venus
      const PoketPlanet(
        id: 2,
        name: 'Venus 🟡',
        theme: 'Golden Veil',
        tagLine: 'Amber Atmosphere & Golden Highlands',
        primaryColor: Color(0xFFFDE047),
        glowColor: Color(0xFFD97706),
        radius: 14,
        orbitDistance: 130,
        orbitSpeed: 1.5,
        totalPlots: 150,
        occupiedPlots: 85,
        countryMaps: [
          PoketCountryMap(
            id: 201,
            name: 'Aphrodite Terra',
            tag: 'Golden Highlands',
            landColor: Color(0xFFB45309),
            waterColor: Color(0xFF0284C7),
            totalSlots: 75,
            filledSlots: 45,
            climate: 'Gold Cloud ⛅',
            climateIcon: Icons.wb_cloudy_rounded,
            islandEmoji: '🏺',
          ),
        ],
      ),

      // 🔴 Mars
      const PoketPlanet(
        id: 4,
        name: 'Mars 🔴',
        theme: 'Red Dunes Bastion',
        tagLine: 'Iron Oxide Canyons & High Altitude Bastions',
        primaryColor: Color(0xFFF97316),
        glowColor: Color(0xFFEA580C),
        radius: 13,
        orbitDistance: 220,
        orbitSpeed: 0.8,
        totalPlots: 200,
        occupiedPlots: 110,
        countryMaps: [
          PoketCountryMap(
            id: 401,
            name: 'Olympus Mons Haven',
            tag: 'Volcano Oasis',
            landColor: Color(0xFF9A3412),
            waterColor: Color(0xFF0284C7),
            totalSlots: 100,
            filledSlots: 72,
            climate: 'Rusty Breeze 🌪️',
            climateIcon: Icons.air_rounded,
            islandEmoji: '🏜️',
          ),
        ],
      ),

      // 🟠 Jupiter
      const PoketPlanet(
        id: 5,
        name: 'Jupiter 🟠',
        theme: 'Great Storm Giant',
        tagLine: 'Colossal Gas Bands & Galilean Moons',
        primaryColor: Color(0xFFFDBA74),
        glowColor: Color(0xFFC2410C),
        radius: 26,
        orbitDistance: 275,
        orbitSpeed: 0.55,
        totalPlots: 300,
        occupiedPlots: 180,
        countryMaps: [
          PoketCountryMap(
            id: 501,
            name: 'Red Spot Sanctuary',
            tag: 'Storm Center',
            landColor: Color(0xFF7C2D12),
            waterColor: Color(0xFF0284C7),
            totalSlots: 150,
            filledSlots: 110,
            climate: 'Thunder Storm ⚡',
            climateIcon: Icons.bolt_rounded,
            islandEmoji: '🌪️',
          ),
        ],
      ),

      // 🪐 Saturn
      const PoketPlanet(
        id: 6,
        name: 'Saturn 🪐',
        theme: 'Ringed Majesty',
        tagLine: 'Golden Ice Dust Rings & Floating Palaces',
        primaryColor: Color(0xFFFEF08A),
        glowColor: Color(0xFFCA8A04),
        radius: 22,
        orbitDistance: 335,
        orbitSpeed: 0.42,
        totalPlots: 250,
        occupiedPlots: 140,
        countryMaps: [
          PoketCountryMap(
            id: 601,
            name: 'Titan Atoll',
            tag: 'Golden Horizon',
            landColor: Color(0xFF854D0E),
            waterColor: Color(0xFF0EA5E9),
            totalSlots: 100,
            filledSlots: 68,
            climate: 'Ring Glow ✨',
            climateIcon: Icons.auto_awesome_rounded,
            islandEmoji: '💍',
          ),
        ],
      ),

      // 💠 Uranus
      const PoketPlanet(
        id: 7,
        name: 'Uranus 💠',
        theme: 'Cyan Ice Sanctuary',
        tagLine: 'Methane Cyan Mist & Crystalline Peaks',
        primaryColor: Color(0xFF67E8F9),
        glowColor: Color(0xFF0891B2),
        radius: 18,
        orbitDistance: 395,
        orbitSpeed: 0.32,
        totalPlots: 150,
        occupiedPlots: 65,
        countryMaps: [
          PoketCountryMap(
            id: 701,
            name: 'Cyan Glacier Isle',
            tag: 'Ice Vault',
            landColor: Color(0xFF155E75),
            waterColor: Color(0xFF0369A1),
            totalSlots: 75,
            filledSlots: 36,
            climate: 'Cyan Frost ❄️',
            climateIcon: Icons.ac_unit_rounded,
            islandEmoji: '🧊',
          ),
        ],
      ),

      // 🔵 Neptune
      const PoketPlanet(
        id: 8,
        name: 'Neptune 🔵',
        theme: 'Deep Azure Oceanic World',
        tagLine: 'Supersonic Azure Winds & Cosmic Seas',
        primaryColor: Color(0xFF60A5FA),
        glowColor: Color(0xFF1D4ED8),
        radius: 17,
        orbitDistance: 450,
        orbitSpeed: 0.25,
        totalPlots: 100,
        occupiedPlots: 45,
        countryMaps: [
          PoketCountryMap(
            id: 801,
            name: 'Triton Abyss Atoll',
            tag: 'Deep Ocean Realm',
            landColor: Color(0xFF1E3A8A),
            waterColor: Color(0xFF172554),
            totalSlots: 50,
            filledSlots: 28,
            climate: 'Azure Tempest 🌊',
            climateIcon: Icons.waves_rounded,
            islandEmoji: '🔱',
          ),
        ],
      ),
    ];

    _selectedPlanet = _planets.first;
    _selectedIsland = _selectedPlanet!.countryMaps.first;
  }

  @override
  void dispose() {
    _islandPageController.dispose();
    _orbitInteractiveController.dispose();
    _aerialMapZoomController.dispose();
    super.dispose();
  }

  // 🏝️ Earth Prime: 30 Islands with President's Island & Varied Sizes (50, 75, 100, 150 slots)
  static List<PoketCountryMap> _buildEarth30Islands() {
    return [
      // 👑 Island #1: President's Exclusive Sanctuary
      const PoketCountryMap(
        id: 1,
        name: "President's Sanctuary Isle 👑",
        tag: 'Head of State Exclusive',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF0284C7),
        totalSlots: 1, // Exclusive to President
        filledSlots: 1,
        climate: 'Royal Breeze 👑',
        climateIcon: Icons.military_tech_rounded,
        description: 'Exclusive private tropical sanctuary reserved solely for the Supreme President of Poket World.',
        islandEmoji: '🏰',
        isPresidential: true,
      ),

      // Large Capital Islands (150 Slots)
      const PoketCountryMap(
        id: 2,
        name: 'Genesis Central Island 🏝️',
        tag: 'Grand Capital',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF0284C7),
        totalSlots: 150,
        filledSlots: 142,
        climate: 'Sunny & Lush ☀️',
        climateIcon: Icons.wb_sunny_rounded,
        description: 'The bustling metropolitan island of Poket Earth with winding avenues, central lagoon, and grand docks.',
      ),
      const PoketCountryMap(
        id: 3,
        name: 'Emerald Delta Bay 🌿',
        tag: 'Grand River Delta',
        landColor: Color(0xFF047857),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 150,
        filledSlots: 128,
        climate: 'Fresh Breeze 🍃',
        climateIcon: Icons.air_rounded,
        description: 'Vast delta archipelago with waterways connecting elite residential estates.',
      ),

      // Medium-Large Islands (100 Slots)
      const PoketCountryMap(
        id: 4,
        name: 'Palm Breeze Atoll 🏖️',
        tag: 'Beachfront Boulevard',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF06B6D4),
        totalSlots: 100,
        filledSlots: 92,
        climate: 'Tropical Sun 🌴',
        climateIcon: Icons.beach_access_rounded,
        description: 'White sandy beaches lined with sun loungers and crystal-clear swimming reefs.',
      ),
      const PoketCountryMap(
        id: 5,
        name: 'Starlight Highlands ⛰️',
        tag: 'Mountain Shoreline',
        landColor: Color(0xFF1E3A8A),
        waterColor: Color(0xFF0369A1),
        totalSlots: 100,
        filledSlots: 85,
        climate: 'Starry Mist ✨',
        climateIcon: Icons.nights_stay_rounded,
        description: 'Elevated coastal cliffs surrounded by oceanic azure waters and evening stars.',
      ),
      const PoketCountryMap(
        id: 6,
        name: 'Azure Lagoon Isle 🌊',
        tag: 'Turquoise Ring',
        landColor: Color(0xFF0D9488),
        waterColor: Color(0xFF0284C7),
        totalSlots: 100,
        filledSlots: 79,
        climate: 'Calm Waves 🌊',
        climateIcon: Icons.waves_rounded,
        description: 'Deep circular lagoon sheltered by lush protective coral barriers.',
      ),

      // Medium Islands (75 Slots)
      const PoketCountryMap(
        id: 7,
        name: 'Whispering Pines 🌲',
        tag: 'Forest Coast',
        landColor: Color(0xFF065F46),
        waterColor: Color(0xFF075985),
        totalSlots: 75,
        filledSlots: 64,
        climate: 'Pine Scent 🌲',
        climateIcon: Icons.forest_rounded,
        description: 'Cool evergreen tree canopies bordering quiet pebble shores.',
      ),
      const PoketCountryMap(
        id: 8,
        name: 'Golden Dunes Atoll 🌴',
        tag: 'Desert Oasis',
        landColor: Color(0xFF854D0E),
        waterColor: Color(0xFF0284C7),
        totalSlots: 75,
        filledSlots: 58,
        climate: 'Warm Sunset 🌅',
        climateIcon: Icons.wb_twilight_rounded,
        description: 'Sun-kissed golden sandbars surrounding a fresh spring oasis.',
      ),
      const PoketCountryMap(
        id: 9,
        name: 'Crystal Springs Bay 💧',
        tag: 'Spring Valley',
        landColor: Color(0xFF0284C7),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 75,
        filledSlots: 61,
        climate: 'Pure Springs 💧',
        climateIcon: Icons.water_drop_rounded,
        description: 'Freshwater rivulets flowing into calm turquoise ocean bays.',
      ),
      const PoketCountryMap(
        id: 10,
        name: 'Amber Coast 🌅',
        tag: 'Golden Coast',
        landColor: Color(0xFFB45309),
        waterColor: Color(0xFF0284C7),
        totalSlots: 75,
        filledSlots: 54,
        climate: 'Amber Light ☀️',
        climateIcon: Icons.wb_sunny_rounded,
        description: 'Sunset coast known for evening yacht regattas and beachside manors.',
      ),
      const PoketCountryMap(
        id: 11,
        name: 'Falcon Crest Isle 🦅',
        tag: 'High Ridge',
        landColor: Color(0xFF166534),
        waterColor: Color(0xFF0284C7),
        totalSlots: 75,
        filledSlots: 68,
        climate: 'Mountain Air 🦅',
        climateIcon: Icons.terrain_rounded,
        description: 'High vantage point overlooking the entire southern oceanic expanse.',
      ),
      const PoketCountryMap(
        id: 12,
        name: 'Breeze Harbor ⛵',
        tag: 'Yacht Marina',
        landColor: Color(0xFF0F766E),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 75,
        filledSlots: 56,
        climate: 'Coastal Wind ⛵',
        climateIcon: Icons.sailing_rounded,
        description: 'Full-service maritime harbor with wooden jetties and speedboats.',
      ),

      // Standard Community Islands (50 Slots)
      const PoketCountryMap(
        id: 13,
        name: 'Orchid Archipelago 🌸',
        tag: 'Flora Island',
        landColor: Color(0xFF059669),
        waterColor: Color(0xFF06B6D4),
        totalSlots: 50,
        filledSlots: 44,
        climate: 'Floral Bloom 🌸',
        climateIcon: Icons.local_florist_rounded,
        description: 'Vibrant flowering flora covering winding garden pathways.',
      ),
      const PoketCountryMap(
        id: 14,
        name: 'Silver Lake Isle 🪙',
        tag: 'Inland Basin',
        landColor: Color(0xFF334155),
        waterColor: Color(0xFF0369A1),
        totalSlots: 50,
        filledSlots: 38,
        climate: 'Mirror Water 🪞',
        climateIcon: Icons.water_rounded,
        description: 'Calm reflective water bodies surrounded by lush habit estates.',
      ),
      const PoketCountryMap(
        id: 15,
        name: 'Moonlit Cove 🌙',
        tag: 'Night Bay',
        landColor: Color(0xFF1E1B4B),
        waterColor: Color(0xFF1E3A8A),
        totalSlots: 50,
        filledSlots: 32,
        climate: 'Moonlit Waves 🌙',
        climateIcon: Icons.bedtime_rounded,
        description: 'Serene evening cove reflecting lunar glows on tranquil waters.',
      ),
      const PoketCountryMap(
        id: 16,
        name: 'Aurora Strand 🌌',
        tag: 'Luminous Reef',
        landColor: Color(0xFF047857),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 50,
        filledSlots: 41,
        climate: 'Aurora Glow 🌌',
        climateIcon: Icons.auto_awesome_rounded,
        description: 'Bioluminescent reef waters glowing gently during nighttime hours.',
      ),
      const PoketCountryMap(
        id: 17,
        name: 'Sunstone Haven ☀️',
        tag: 'Granite Cliffs',
        landColor: Color(0xFF78350F),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 37,
        climate: 'Sunlit Rock ☀️',
        climateIcon: Icons.wb_sunny_rounded,
        description: 'Solid granite cliffs offering unbreakable habit house foundations.',
      ),
      const PoketCountryMap(
        id: 18,
        name: 'Celeste Peninsula 🏰',
        tag: 'Citadel Shore',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 48,
        climate: 'Royal Haven 👑',
        climateIcon: Icons.shield_rounded,
        description: 'Historic peninsula adjacent to the presidential sea route.',
      ),
      const PoketCountryMap(
        id: 19,
        name: 'Rainforest Delta 🌴',
        tag: 'Jungle River',
        landColor: Color(0xFF14532D),
        waterColor: Color(0xFF0891B2),
        totalSlots: 50,
        filledSlots: 29,
        climate: 'Rain & Sun 🌧️',
        climateIcon: Icons.umbrella_rounded,
        description: 'Rich tropical greenery nourished by daily afternoon showers.',
      ),
      const PoketCountryMap(
        id: 20,
        name: 'Pearl Shoals 🦪',
        tag: 'Shallow Reef',
        landColor: Color(0xFF0D9488),
        waterColor: Color(0xFF06B6D4),
        totalSlots: 50,
        filledSlots: 36,
        climate: 'Pearl Waters 🦪',
        climateIcon: Icons.circle_rounded,
        description: 'Crystal shallow reef waters teeming with marine pearl banks.',
      ),
      const PoketCountryMap(
        id: 21,
        name: 'Highland Plateau ⛰️',
        tag: 'Green Mesa',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF0369A1),
        totalSlots: 50,
        filledSlots: 40,
        climate: 'Alpine Breeze 🍃',
        climateIcon: Icons.air_rounded,
        description: 'Flat elevated tabletop land offering uninterrupted 360-degree ocean views.',
      ),
      const PoketCountryMap(
        id: 22,
        name: 'Mystic Grove 🌳',
        tag: 'Ancient Trees',
        landColor: Color(0xFF064E3B),
        waterColor: Color(0xFF075985),
        totalSlots: 50,
        filledSlots: 31,
        climate: 'Deep Forest 🌳',
        climateIcon: Icons.park_rounded,
        description: 'Century-old banyan canopies providing soothing natural shade.',
      ),
      const PoketCountryMap(
        id: 23,
        name: 'Solarium Atoll ☀️',
        tag: 'Solar Fields',
        landColor: Color(0xFF65A30D),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 28,
        climate: 'Golden Rays ☀️',
        climateIcon: Icons.wb_sunny_rounded,
        description: 'Open sunlit atoll ideal for solar-powered smart habit manors.',
      ),
      const PoketCountryMap(
        id: 24,
        name: 'Tidepool Haven 🦀',
        tag: 'Coastal Reef',
        landColor: Color(0xFF047857),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 50,
        filledSlots: 33,
        climate: 'Tide Pools 🦀',
        climateIcon: Icons.waves_rounded,
        description: 'Natural rock pools refreshed daily with warm ocean tides.',
      ),
      const PoketCountryMap(
        id: 25,
        name: 'Seafarer Coast ⚓',
        tag: 'Harbor Town',
        landColor: Color(0xFF1E3A8A),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 45,
        climate: 'Seaport ⚓',
        climateIcon: Icons.anchor_rounded,
        description: 'Maritime community populated by veteran oceanic voyagers.',
      ),
      const PoketCountryMap(
        id: 26,
        name: 'Biolume Bay 💡',
        tag: 'Glowing Waters',
        landColor: Color(0xFF0F766E),
        waterColor: Color(0xFF06B6D4),
        totalSlots: 50,
        filledSlots: 27,
        climate: 'Neon Sea 💡',
        climateIcon: Icons.lightbulb_rounded,
        description: 'Enchanting bay where night waves glow with natural bioluminescence.',
      ),
      const PoketCountryMap(
        id: 27,
        name: 'Canyon Springs 🏜️',
        tag: 'River Gorge',
        landColor: Color(0xFF854D0E),
        waterColor: Color(0xFF0284C7),
        totalSlots: 50,
        filledSlots: 35,
        climate: 'Canyon Breeze 🏞️',
        climateIcon: Icons.landscape_rounded,
        description: 'Dramatic carved stone gorge opening onto an expansive sandy delta.',
      ),
      const PoketCountryMap(
        id: 28,
        name: 'Echo Valley 🏔️',
        tag: 'Glacier Stream',
        landColor: Color(0xFF334155),
        waterColor: Color(0xFF0369A1),
        totalSlots: 50,
        filledSlots: 26,
        climate: 'Crisp Air 🏔️',
        climateIcon: Icons.snowshoeing_rounded,
        description: 'Peaceful coastal valley with clear acoustic soundscapes and waterfalls.',
      ),
      const PoketCountryMap(
        id: 29,
        name: 'Garden Atoll 🌷',
        tag: 'Botanical Isles',
        landColor: Color(0xFF15803D),
        waterColor: Color(0xFF0EA5E9),
        totalSlots: 50,
        filledSlots: 42,
        climate: 'Botanical 🌷',
        climateIcon: Icons.yard_rounded,
        description: 'Lush manicured hedges, flower gardens, and stone fountains.',
      ),
      const PoketCountryMap(
        id: 30,
        name: 'Dragonfly Marsh 🌾',
        tag: 'Wetland Haven',
        landColor: Color(0xFF065F46),
        waterColor: Color(0xFF075985),
        totalSlots: 50,
        filledSlots: 24,
        climate: 'Warm Marsh 🌾',
        climateIcon: Icons.grass_rounded,
        description: 'Biodiverse wetland sanctuary with freshwater lily ponds and boardwalks.',
      ),
    ];
  }

  void _navigateToPlanetArchipelago(PoketPlanet planet) {
    setState(() {
      _selectedPlanet = planet;
      _activeScreen = 1;
      _currentIslandIndex = 0;
    });
  }

  void _navigateToFullscreenAerialMap(PoketCountryMap island) {
    setState(() {
      _selectedIsland = island;
      _activeScreen = 2;
    });
    _aerialMapZoomController.value = Matrix4.identity()..scale(1.0);
  }

  void _navigateToStreetDriveView() {
    setState(() => _activeScreen = 3);
  }

  void _zoomOrbit(double factor) {
    final currentScale = _orbitInteractiveController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.4, 3.2);
    _orbitInteractiveController.value = Matrix4.identity()..scale(newScale);
  }

  void _resetOrbitZoom() {
    _orbitInteractiveController.value = Matrix4.identity()..scale(1.0);
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
      case 3:
        return IslandStreetDriveView(
          island: _selectedIsland ?? _planets.first.countryMaps.first,
          onBackToAerial: () {
            setState(() => _activeScreen = 2);
          },
        );
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
                _buildIosBackButton(onTap: () => Navigator.of(context).maybePop()),
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
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
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
                  const Divider(color: Colors.white24, height: 14, indent: 4, endIndent: 4),
                  _buildFloatingActionBtn(
                    icon: Icons.screen_rotation_rounded,
                    tooltip: '3D Bend Perspective (${_tiltAngle < 0.2 ? 'Top' : _tiltAngle < 0.65 ? '3D' : 'Side'})',
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isApex ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.08),
              width: isApex ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _navigateToPlanetArchipelago(p),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.primaryColor,
                        boxShadow: [
                          BoxShadow(color: p.glowColor.withValues(alpha: 0.5), blurRadius: 8),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isApex ? '🌍' : '${p.id}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.countryMaps.length} Islands • ${p.occupiedPlots}/${p.totalPlots} Slots',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
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
  // 🏝️ SCREEN 1: PLANET ARCHIPELAGO HORIZONTAL CARDS (70% AERIAL VIEW)
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
        currentIsland?.waterColor.withValues(alpha: 0.35) ?? const Color(0xFF0D121D),
        currentIsland?.landColor.withValues(alpha: 0.18) ?? const Color(0xFF030712),
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
                          '${islands.length} Distinct Islands • 50-150 Slots per Island',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // Center Horizontal Swipeable Island Cards (PageView)
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 55,
            bottom: 30,
            child: PageView.builder(
              controller: _islandPageController,
              itemCount: islands.length,
              onPageChanged: (idx) {
                setState(() => _currentIslandIndex = idx);
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

  // 🏝️ The Card with Top 70% Aerial Island View matching user reference images!
  Widget _buildIslandAerialCard(PoketCountryMap island, PoketPlanet planet, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF14181B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent
              ? (island.isPresidential ? const Color(0xFFFFD700) : const Color(0xFF38BDF8))
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
          // 🏝️ TOP 70% (മുക്കാൽ ഭാഗം): AERIAL ISLAND VIEW FROM SKY!
          Expanded(
            flex: 7,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IslandAerialViewWidget(
                    island: island,
                    isInteractive: false,
                  ),
                  // Tag Badge (e.g. Presidential Sanctuary or Grand Capital)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: island.isPresidential ? const Color(0xFFFFD700) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (island.isPresidential) ...[
                            const Text('👑', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            island.tag,
                            style: TextStyle(
                              color: island.isPresidential ? const Color(0xFFFFD700) : Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
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

          // 📋 BOTTOM 30%: ISLAND DETAILS & EXPLORE ACTION
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF14181B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          island.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          island.isPresidential
                              ? '1 VIP Slot'
                              : '${island.filledSlots}/${island.totalSlots} Slots',
                          style: TextStyle(
                            color: island.isPresidential ? const Color(0xFFFFD700) : const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    island.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: island.isPresidential
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF0284C7),
                        foregroundColor: island.isPresidential ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                      ),
                      onPressed: () => _navigateToFullscreenAerialMap(island),
                      icon: const Icon(Icons.travel_explore_rounded, size: 17),
                      label: Text(
                        island.isPresidential ? 'Enter President Sanctuary 👑' : 'Explore Island 🏝️',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
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
  // 🗺️ SCREEN 2: FULLSCREEN AERIAL ISLAND MAP (INTERACTIVEVIEWER ZOOM)
  // =========================================================================
  Widget _buildFullscreenAerialMapView() {
    final island = _selectedIsland ?? _planets.first.countryMaps.first;

    return Stack(
      children: [
        // Fullscreen Aerial View with Filled Ocean Bounds
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _aerialMapZoomController,
            minScale: 0.6, // Bound so ocean fills the screen completely
            maxScale: 3.5, // Deep zoom into paths and villas
            boundaryMargin: const EdgeInsets.all(250),
            child: SizedBox(
              width: 1200,
              height: 1200,
              child: IslandAerialViewWidget(
                island: island,
                isInteractive: true,
              ),
            ),
          ),
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
                        'Pinch to Zoom • ${island.totalSlots} Slots • ${island.climate}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🛣️ Floating Bottom Bar: "View Street 🛣️" Button & Zoom Controls
        Positioned(
          left: 14,
          right: 14,
          bottom: 24,
          child: Row(
            children: [
              // Prominent "View Street 🛣️" Button (User Requirement!)
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                    onPressed: _navigateToStreetDriveView,
                    icon: const Icon(Icons.streetview_rounded, size: 22),
                    label: const Text(
                      'View Street 🛣️ (Drive Car)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Zoom Controls Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF14181B).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      tooltip: 'Zoom In',
                      onPressed: () {
                        final current = _aerialMapZoomController.value.getMaxScaleOnAxis();
                        _aerialMapZoomController.value = Matrix4.identity()..scale((current * 1.25).clamp(0.6, 3.5));
                      },
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, color: Colors.white, size: 20),
                      tooltip: 'Zoom Out',
                      onPressed: () {
                        final current = _aerialMapZoomController.value.getMaxScaleOnAxis();
                        _aerialMapZoomController.value = Matrix4.identity()..scale((current * 0.8).clamp(0.6, 3.5));
                      },
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFFFFD700), size: 19),
                      tooltip: 'Reset Zoom',
                      onPressed: () {
                        _aerialMapZoomController.value = Matrix4.identity()..scale(1.0);
                      },
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🔘 MINIMAL REUSABLE WIDGETS
  // =========================================================================
  Widget _buildIosBackButton({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
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
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.black : Colors.white70,
          ),
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
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: highlightColor ?? Colors.white, size: 18),
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
