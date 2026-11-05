import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'poket_cosmos_models.dart';
import 'flame_solar_system_game.dart';

/// 🌌 Poket Cosmos Explorer:
/// - Screen 1: Fullscreen Poket Solar System (Minimal iOS top bar, Flame Engine 3D with Scientific Moons,
///   Right-side Floating Action Pill with Zoom +, Zoom -, 3D Tilt Bend Toggle, and Minimal Tab Toggle).
///   Tapping a planet in Solar System or Planet Cards navigates to that planet's Island Archipelago.
/// - Screen 2: Planet Archipelago PageView (Horizontal swipeable Island Cards with dynamic background
///   matching the island palette, 50 slots per island, minimal UI matching app theme).
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage> {
  // 0: Fullscreen Solar System Orbit (Flame), 1: Minimal Planet Directory Cards
  int _hubMode = 0;

  // View state: 0: Solar Hub, 1: Horizontal Island Archipelago View
  int _activeScreen = 0;

  double _tiltAngle = 0.42; // 3D bend perspective
  final TransformationController _orbitInteractiveController =
      TransformationController();

  PoketPlanet? _selectedPlanet;
  int _currentIslandIndex = 0;
  late PageController _islandPageController;

  // 🌌 8 Authentic Solar System Planets with Earth Prime at the Apex!
  late List<PoketPlanet> _planets;

  @override
  void initState() {
    super.initState();
    _islandPageController = PageController(viewportFraction: 0.82);

    // Initialize 8 authentic planets with scientific data and rich island archipelagos
    _planets = [
      // 🌍 APEX: Earth Prime (Poket World) with 30 Distinct Minimal Islands (50 slots each)
      PoketPlanet(
        id: 3,
        name: 'Earth Prime 🌍',
        theme: 'Cradle of Civilization & Apex Capital',
        tagLine: 'Day 1-90 Habit Pioneers • Apex World',
        primaryColor: const Color(0xFF38BDF8),
        glowColor: const Color(0xFF0284C7),
        radius: 17,
        orbitDistance: 175,
        orbitSpeed: 1.0,
        totalPlots: 1500, // 30 islands * 50 plots = 1500 citizens
        occupiedPlots: 940,
        countryMaps: _buildEarthArchipelago(),
      ),

      // ⚪ Mercury (Closest to Sun)
      PoketPlanet(
        id: 1,
        name: 'Mercury ⚪',
        theme: 'Swift Iron Frontier',
        tagLine: 'High Velocity Orbit • Sun Scorched Basins',
        primaryColor: const Color(0xFFCBD5E1),
        glowColor: const Color(0xFF94A3B8),
        radius: 10,
        orbitDistance: 85,
        orbitSpeed: 2.1,
        totalPlots: 400,
        occupiedPlots: 180,
        countryMaps: [
          const PoketCountryMap(
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
          const PoketCountryMap(
            id: 102,
            name: 'Hermes Ridge',
            tag: 'Iron Plains',
            landColor: Color(0xFF475569),
            waterColor: Color(0xFF0369A1),
            totalSlots: 50,
            filledSlots: 21,
            climate: 'Solar Wind ☀️',
            climateIcon: Icons.wb_sunny_rounded,
            islandEmoji: '🪨',
          ),
        ],
      ),

      // 🟡 Venus
      PoketPlanet(
        id: 2,
        name: 'Venus 🟡',
        theme: 'Golden Veil',
        tagLine: 'Amber Atmosphere & Golden Highlands',
        primaryColor: const Color(0xFFFDE047),
        glowColor: const Color(0xFFD97706),
        radius: 14,
        orbitDistance: 130,
        orbitSpeed: 1.5,
        totalPlots: 600,
        occupiedPlots: 310,
        countryMaps: [
          const PoketCountryMap(
            id: 201,
            name: 'Aphrodite Terra',
            tag: 'Golden Highlands',
            landColor: Color(0xFFB45309),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 45,
            climate: 'Dense Gold Cloud ⛅',
            climateIcon: Icons.wb_cloudy_rounded,
            islandEmoji: '🏺',
          ),
          const PoketCountryMap(
            id: 202,
            name: 'Ishtar Corona Isle',
            tag: 'Amber Coast',
            landColor: Color(0xFF92400E),
            waterColor: Color(0xFF0EA5E9),
            totalSlots: 50,
            filledSlots: 28,
            climate: 'Warm Glow ☀️',
            climateIcon: Icons.wb_sunny_rounded,
            islandEmoji: '✨',
          ),
        ],
      ),

      // 🔴 Mars
      PoketPlanet(
        id: 4,
        name: 'Mars 🔴',
        theme: 'Red Dunes Bastion',
        tagLine: 'Iron Oxide Canyons & High Altitude Bastions',
        primaryColor: const Color(0xFFF97316),
        glowColor: const Color(0xFFEA580C),
        radius: 13,
        orbitDistance: 220,
        orbitSpeed: 0.8,
        totalPlots: 750,
        occupiedPlots: 420,
        countryMaps: [
          const PoketCountryMap(
            id: 401,
            name: 'Olympus Mons Haven',
            tag: 'Volcano Oasis',
            landColor: Color(0xFF9A3412),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 49,
            climate: 'Rusty Breeze 🌪️',
            climateIcon: Icons.air_rounded,
            islandEmoji: '🏜️',
          ),
          const PoketCountryMap(
            id: 402,
            name: 'Valles Marineris Atoll',
            tag: 'Grand Canyon Shore',
            landColor: Color(0xFFC2410C),
            waterColor: Color(0xFF0EA5E9),
            totalSlots: 50,
            filledSlots: 35,
            climate: 'Cool Dune 🍂',
            climateIcon: Icons.terrain_rounded,
            islandEmoji: '🏕️',
          ),
        ],
      ),

      // 🟠 Jupiter (Giant with Moons)
      PoketPlanet(
        id: 5,
        name: 'Jupiter 🟠',
        theme: 'Great Storm Giant',
        tagLine: 'Colossal Gas Bands & Thunder Manors',
        primaryColor: const Color(0xFFFDBA74),
        glowColor: const Color(0xFFC2410C),
        radius: 26,
        orbitDistance: 275,
        orbitSpeed: 0.55,
        totalPlots: 1000,
        occupiedPlots: 620,
        countryMaps: [
          const PoketCountryMap(
            id: 501,
            name: 'Red Spot Sanctuary',
            tag: 'Storm Center',
            landColor: Color(0xFF7C2D12),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 48,
            climate: 'Thunder Storm ⚡',
            climateIcon: Icons.bolt_rounded,
            islandEmoji: '🌪️',
          ),
          const PoketCountryMap(
            id: 502,
            name: 'Europa Glacial Atoll',
            tag: 'Subsurface Ocean Isle',
            landColor: Color(0xFF0E7490),
            waterColor: Color(0xFF0284C7),
            totalSlots: 50,
            filledSlots: 39,
            climate: 'Crystal Chill 🧊',
            climateIcon: Icons.ac_unit_rounded,
            islandEmoji: '❄️',
          ),
        ],
      ),

      // 🪐 Saturn (Rings)
      PoketPlanet(
        id: 6,
        name: 'Saturn 🪐',
        theme: 'Ringed Majesty',
        tagLine: 'Golden Ice Dust Rings & Floating Palaces',
        primaryColor: const Color(0xFFFEF08A),
        glowColor: const Color(0xFFCA8A04),
        radius: 22,
        orbitDistance: 335,
        orbitSpeed: 0.42,
        totalPlots: 850,
        occupiedPlots: 490,
        countryMaps: [
          const PoketCountryMap(
            id: 601,
            name: 'Titan Atoll',
            tag: 'Golden Horizon',
            landColor: Color(0xFF854D0E),
            waterColor: Color(0xFF0EA5E9),
            totalSlots: 50,
            filledSlots: 46,
            climate: 'Ring Glow ✨',
            climateIcon: Icons.auto_awesome_rounded,
            islandEmoji: '💍',
          ),
          const PoketCountryMap(
            id: 602,
            name: 'Enceladus Bay',
            tag: 'Ice Geyser Coast',
            landColor: Color(0xFF0284C7),
            waterColor: Color(0xFF0369A1),
            totalSlots: 50,
            filledSlots: 30,
            climate: 'Geyser Mist 🌊',
            climateIcon: Icons.water_rounded,
            islandEmoji: '💎',
          ),
        ],
      ),

      // 💠 Uranus
      PoketPlanet(
        id: 7,
        name: 'Uranus 💠',
        theme: 'Cyan Ice Sanctuary',
        tagLine: 'Methane Cyan Mist & Crystalline Peaks',
        primaryColor: const Color(0xFF67E8F9),
        glowColor: const Color(0xFF0891B2),
        radius: 18,
        orbitDistance: 395,
        orbitSpeed: 0.32,
        totalPlots: 600,
        occupiedPlots: 240,
        countryMaps: [
          const PoketCountryMap(
            id: 701,
            name: 'Cyan Glacier Isle',
            tag: 'Ice Vault',
            landColor: Color(0xFF155E75),
            waterColor: Color(0xFF0369A1),
            totalSlots: 50,
            filledSlots: 26,
            climate: 'Cyan Frost ❄️',
            climateIcon: Icons.ac_unit_rounded,
            islandEmoji: '🧊',
          ),
        ],
      ),

      // 🔵 Neptune
      PoketPlanet(
        id: 8,
        name: 'Neptune 🔵',
        theme: 'Deep Azure Oceanic World',
        tagLine: 'Supersonic Azure Winds & Cosmic Seas',
        primaryColor: const Color(0xFF60A5FA),
        glowColor: const Color(0xFF1D4ED8),
        radius: 17,
        orbitDistance: 450,
        orbitSpeed: 0.25,
        totalPlots: 550,
        occupiedPlots: 190,
        countryMaps: [
          const PoketCountryMap(
            id: 801,
            name: 'Triton Abyss Atoll',
            tag: 'Deep Ocean Realm',
            landColor: Color(0xFF1E3A8A),
            waterColor: Color(0xFF172554),
            totalSlots: 50,
            filledSlots: 34,
            climate: 'Azure Tempest 🌊',
            climateIcon: Icons.waves_rounded,
            islandEmoji: '🔱',
          ),
        ],
      ),
    ];

    _selectedPlanet = _planets.first;
  }

  @override
  void dispose() {
    _islandPageController.dispose();
    _orbitInteractiveController.dispose();
    super.dispose();
  }

  // 🏝️ Generate 30 Distinct Minimal Islands for Earth Prime (50 slots per island)
  static List<PoketCountryMap> _buildEarthArchipelago() {
    final islandThemes = [
      (
        'Genesis Sanctuary 🏝️',
        'Capital Valley',
        const Color(0xFF15803D),
        const Color(0xFF0284C7),
        'Sunny & Lush ☀️',
        Icons.wb_sunny_rounded,
        49
      ),
      (
        'Emerald Haven 🌿',
        'River Delta',
        const Color(0xFF047857),
        const Color(0xFF0EA5E9),
        'Fresh Breeze 🍃',
        Icons.air_rounded,
        45
      ),
      (
        'Coral Palm Coast 🏖️',
        'Palm Shoreline',
        const Color(0xFF16A34A),
        const Color(0xFF06B6D4),
        'Tropical Coral 🌴',
        Icons.beach_access_rounded,
        42
      ),
      (
        'Starlight Cliff ⛰️',
        'Highland Ridge',
        const Color(0xFF1E3A8A),
        const Color(0xFF0369A1),
        'Misty Sky ✨',
        Icons.nights_stay_rounded,
        38
      ),
      (
        'Azure Lagoon Isle 🌊',
        'Atoll Reef',
        const Color(0xFF0D9488),
        const Color(0xFF0284C7),
        'Calm Ocean 🌊',
        Icons.waves_rounded,
        35
      ),
      (
        'Whispering Pines 🌲',
        'Forest Coast',
        const Color(0xFF065F46),
        const Color(0xFF075985),
        'Pine Forest 🌲',
        Icons.forest_rounded,
        30
      ),
      (
        'Golden Dunes Atoll 🌴',
        'Desert Oasis',
        const Color(0xFF854D0E),
        const Color(0xFF0284C7),
        'Warm Sunset 🌅',
        Icons.wb_twilight_rounded,
        28
      ),
      (
        'Crystal Springs 💧',
        'Spring Valley',
        const Color(0xFF0284C7),
        const Color(0xFF0EA5E9),
        'Pure Springs 💧',
        Icons.water_drop_rounded,
        41
      ),
      (
        'Amber Bay 🌅',
        'Golden Coast',
        const Color(0xFFB45309),
        const Color(0xFF0284C7),
        'Amber Light ☀️',
        Icons.wb_sunny_rounded,
        33
      ),
      (
        'Orchid Archipelago 🌸',
        'Flora Island',
        const Color(0xFF059669),
        const Color(0xFF06B6D4),
        'Orchid Blossom 🌸',
        Icons.local_florist_rounded,
        29
      ),
      (
        'Silver Lake Isle 🪙',
        'Inland Basin',
        const Color(0xFF334155),
        const Color(0xFF0369A1),
        'Mirror Lake 🪞',
        Icons.water_rounded,
        25
      ),
      (
        'Falcon Crest 🦅',
        'Avian Highlands',
        const Color(0xFF166534),
        const Color(0xFF0284C7),
        'Mountain Air 🦅',
        Icons.terrain_rounded,
        47
      ),
      (
        'Moonlit Cove 🌙',
        'Night Bay',
        const Color(0xFF1E1B4B),
        const Color(0xFF1E3A8A),
        'Moonlit Waves 🌙',
        Icons.bedtime_rounded,
        22
      ),
      (
        'Aurora Strand 🌌',
        'Luminous Reef',
        const Color(0xFF047857),
        const Color(0xFF0EA5E9),
        'Aurora Glow 🌌',
        Icons.auto_awesome_rounded,
        31
      ),
      (
        'Sunstone Isle ☀️',
        'Granite Cliffs',
        const Color(0xFF78350F),
        const Color(0xFF0284C7),
        'Sunlit Rock ☀️',
        Icons.wb_sunny_rounded,
        27
      ),
      (
        'Breeze Harbor ⛵',
        'Yacht Marina',
        const Color(0xFF0F766E),
        const Color(0xFF0EA5E9),
        'Coastal Wind ⛵',
        Icons.sailing_rounded,
        36
      ),
      (
        'Celeste Peninsula 🏰',
        'Citadel Shore',
        const Color(0xFF15803D),
        const Color(0xFF0284C7),
        'Royal Haven 👑',
        Icons.shield_rounded,
        44
      ),
      (
        'Rainforest Delta 🌴',
        'Jungle River',
        const Color(0xFF14532D),
        const Color(0xFF0891B2),
        'Tropical Rain 🌧️',
        Icons.umbrella_rounded,
        24
      ),
      (
        'Pearl Shoals 🦪',
        'Shallow Reef',
        const Color(0xFF0D9488),
        const Color(0xFF06B6D4),
        'Pearl Waters 🦪',
        Icons.circle_rounded,
        26
      ),
      (
        'Highland Plateau ⛰️',
        'Green Mesa',
        const Color(0xFF16A34A),
        const Color(0xFF0369A1),
        'Alpine Breeze 🍃',
        Icons.air_rounded,
        32
      ),
      (
        'Mystic Grove 🌳',
        'Ancient Trees',
        const Color(0xFF064E3B),
        const Color(0xFF075985),
        'Deep Forest 🌳',
        Icons.park_rounded,
        20
      ),
      (
        'Solarium Isle ☀️',
        'Solar Fields',
        const Color(0xFF65A30D),
        const Color(0xFF0284C7),
        'Golden Rays ☀️',
        Icons.wb_sunny_rounded,
        23
      ),
      (
        'Tidepool Haven 🦀',
        'Coastal Reef',
        const Color(0xFF047857),
        const Color(0xFF0EA5E9),
        'Tide Pools 🦀',
        Icons.waves_rounded,
        19
      ),
      (
        'Seafarer Coast ⚓',
        'Harbor Town',
        const Color(0xFF1E3A8A),
        const Color(0xFF0284C7),
        'Seaport ⚓',
        Icons.anchor_rounded,
        37
      ),
      (
        'Biolume Bay 💡',
        'Glowing Waters',
        const Color(0xFF0F766E),
        const Color(0xFF06B6D4),
        'Neon Plankton 💡',
        Icons.lightbulb_rounded,
        21
      ),
      (
        'Canyon Springs 🏜️',
        'River Gorge',
        const Color(0xFF854D0E),
        const Color(0xFF0284C7),
        'Canyon River 🏞️',
        Icons.landscape_rounded,
        25
      ),
      (
        'Echo Valley 🏔️',
        'Glacier Stream',
        const Color(0xFF334155),
        const Color(0xFF0369A1),
        'Crisp Air 🏔️',
        Icons.snowshoeing_rounded,
        18
      ),
      (
        'Garden Atoll 🌷',
        'Botanical Isles',
        const Color(0xFF15803D),
        const Color(0xFF0EA5E9),
        'Botanical Haven 🌷',
        Icons.yard_rounded,
        33
      ),
      (
        'Dragonfly Marsh 🌾',
        'Wetland Haven',
        const Color(0xFF065F46),
        const Color(0xFF075985),
        'Wetland Wind 🌾',
        Icons.grass_rounded,
        17
      ),
      (
        'Genesis Apex Isle 👑',
        'Presidential Rock',
        const Color(0xFF16A34A),
        const Color(0xFF0284C7),
        'Apex Sovereign 👑',
        Icons.military_tech_rounded,
        50
      ),
    ];

    return List.generate(islandThemes.length, (i) {
      final t = islandThemes[i];
      return PoketCountryMap(
        id: i + 1,
        name: t.$1,
        tag: t.$2,
        landColor: t.$3,
        waterColor: t.$4,
        totalSlots: 50,
        filledSlots: t.$7,
        climate: t.$5,
        climateIcon: t.$6,
        description: 'Lush coastal island inhabited by active habit builders.',
      );
    });
  }

  void _navigateToPlanetArchipelago(PoketPlanet planet) {
    setState(() {
      _selectedPlanet = planet;
      _activeScreen = 1;
      _currentIslandIndex = 0;
    });
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
      // Toggle between 3D Isometric (0.55), Edge (0.78), and Top-Down (0.0)
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
      backgroundColor: const Color(0xFF0D121D), // Dark space matching app theme
      body: SafeArea(
        top: false, // Fullscreen edge-to-edge
        child: _activeScreen == 0
            ? _buildSolarSystemHub()
            : _buildPlanetArchipelagoView(),
      ),
    );
  }

  // =========================================================================
  // 🪐 SCREEN 1: FULLSCREEN POKET SOLAR SYSTEM & PLANETS DIRECTORY
  // =========================================================================
  Widget _buildSolarSystemHub() {
    return Stack(
      children: [
        // 1. Main Content: Flame Solar System OR Minimal Planet Cards
        Positioned.fill(
          child: _hubMode == 0
              ? _buildFlameOrbitContent()
              : _buildMinimalPlanetsDirectoryContent(),
        ),

        // 2. Minimal iOS Top Bar
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
                // Minimal iOS Back Button
                _buildIosBackButton(
                    onTap: () => Navigator.of(context).maybePop()),
                const SizedBox(width: 10),

                // Title
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

                // Minimal Dual-Icon Segment Toggle (Orbit 🪐 / List 📋)
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

        // 3. Right-Side Compact Floating Controls Pill (Zoom +, Zoom -, 3D Tilt Bend)
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
                  // 3D Tilt Bend Button (Compact Pill!)
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

  // 📋 Minimal Cards Directory matching Poket Mates Theme
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
            color: const Color(0xFF14181B), // App theme secondary background
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isApex
                  ? const Color(0xFFFFD700)
                  : Colors.white.withValues(alpha: 0.08),
              width: isApex ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _navigateToPlanetArchipelago(p),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Planet sphere preview
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: p.glowColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isApex ? '🌍' : '${p.id}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.countryMaps.length} Islands • ${p.occupiedPlots}/${p.totalPlots} Slots',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11),
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
        );
      },
    );
  }

  // =========================================================================
  // 🏝️ SCREEN 2: PLANET ARCHIPELAGO HORIZONTAL SWIPEABLE ISLAND CARDS
  // =========================================================================
  Widget _buildPlanetArchipelagoView() {
    final planet = _selectedPlanet ?? _planets.first;
    final islands = planet.countryMaps;
    final currentIsland = islands.isNotEmpty
        ? islands[_currentIslandIndex.clamp(0, islands.length - 1)]
        : null;

    // Dynamic background transition matching current island land & sea colors
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
          // 1. Top Minimal Bar
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
                          '${islands.length} Distinct Islands • 50 Slots per Island',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
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

          // 2. Center: Horizontal Swipeable Island Cards (PageView)
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 55,
            bottom: 40,
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
                  child: _buildIslandDetailCard(island, planet, isCurrent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslandDetailCard(
      PoketCountryMap island, PoketPlanet planet, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF14181B), // App theme secondary background
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrent ? const Color(0xFFFFD700) : Colors.white12,
          width: isCurrent ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? island.landColor.withValues(alpha: 0.25)
                : Colors.black45,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Island Graphic Top Header
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0),
                radius: 1.0,
                colors: [
                  island.landColor.withValues(alpha: 0.7),
                  island.waterColor.withValues(alpha: 0.9),
                  const Color(0xFF0F172A),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ocean Wave Rings
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: island.landColor,
                    boxShadow: [
                      BoxShadow(
                        color: island.landColor.withValues(alpha: 0.6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      island.islandEmoji,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                // Top Tag
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      island.tag,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Island Details Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(island.climateIcon,
                          size: 14, color: const Color(0xFFFFD700)),
                      const SizedBox(width: 5),
                      Text(
                        island.climate,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    island.description,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // 50 Slots Capacity Bar (User Directive: 50 plots per island)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${island.filledSlots} / ${island.totalSlots} Citizens',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11.5),
                      ),
                      Text(
                        '${island.availableSlots} available',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: island.occupancyRatio,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(island.landColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Enter Island Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFFD700), // App primary gold
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Exploring ${island.name} on ${planet.name}... 🏝️'),
                            backgroundColor: const Color(0xFF0F172A),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.travel_explore_rounded, size: 17),
                      label: const Text(
                        'Explore Island Plots',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12.5),
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
  // 🔘 MINIMAL REUSABLE WIDGETS (iOS BACK BUTTON & CONTROLS)
  // =========================================================================
  Widget _buildIosBackButton({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
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
