import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'poket_cosmos_models.dart';
import 'flame_solar_system_game.dart';

/// 🌌 Poket Cosmos Explorer:
/// Tab 1: 🪐 Solar System Orbit (Flame Engine 3D with InteractiveViewer, Zoom & 3D Tilt Bend Slider)
/// Tab 2: 📋 Planets Directory (Minimal, Beautiful Cards matching App Theme with Earth Prime at Apex)
/// View 2: 🏝️ Deep-Dive Oceanic Island Map (90-Day Habit Houses, Drive Car & Fly Airplane)
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage>
    with TickerProviderStateMixin {
  late TabController _orbitModeTabController; // Tab 1: Flame Orbit, Tab 2: Planets List
  final TransformationController _orbitInteractiveController =
      TransformationController();
  final TransformationController _mapZoomController =
      TransformationController();

  int _activeViewIndex = 0; // 0: Solar System & Planets Hub, 1: Island Deep-Dive Map
  double _tiltAngle = 0.45; // 3D side angle / bend perspective
  PoketPlanet? _selectedPlanet;
  PoketCountryMap? _selectedCountry;
  CitizenPlot? _focusedPlot;
  bool _isLoadingCitizens = false;

  List<CitizenPlot> _citizenPlots = [];

  // 🚗 Travel Simulation Modes & Vehicles
  TravelMode _travelMode = TravelMode.walk;
  late AnimationController _vehicleAnimController;
  Offset _vehicleStartPos = const Offset(200, 280);
  Offset _vehicleEndPos = const Offset(200, 280);
  double _vehicleHeading = 0.0;

  late PoketVehicle _car;
  late PoketVehicle _airplane;

  // 🌌 8 Authentic Solar System Planets with Earth Prime at the Apex!
  final List<PoketPlanet> _planets = const [
    // 🌍 APEX PLANET: Earth Prime / Poket World
    PoketPlanet(
      id: 3,
      name: 'Earth Prime 🌍 (Poket World)',
      theme: 'Cradle of Civilization & Presidential Apex',
      tagLine: 'Day 1-90 Habit Pioneers • Top Apex Capital',
      primaryColor: Color(0xFF38BDF8),
      glowColor: Color(0xFF0284C7),
      radius: 17,
      orbitDistance: 175,
      orbitSpeed: 1.0,
      totalPlots: 10000,
      occupiedPlots: 8840,
      countryMaps: [
        PoketCountryMap(
          id: 1,
          name: 'Genesis Valley Island',
          tag: 'Capital Sanctuary',
          landColor: Color(0xFF15803D),
          waterColor: Color(0xFF0284C7),
          totalSlots: 5000,
          filledSlots: 4920,
          climate: 'Lush & Sunny ☀️',
          climateIcon: Icons.wb_sunny_rounded,
          islandEmoji: '🏝️',
          description:
              'The founding island of Poket Cosmos. Features lush green coastal valleys and historic roads.',
        ),
        PoketCountryMap(
          id: 2,
          name: 'Emerald Archipelago',
          tag: 'River Delta',
          landColor: Color(0xFF047857),
          waterColor: Color(0xFF0EA5E9),
          totalSlots: 3000,
          filledSlots: 2600,
          climate: 'Rain & Breeze 🌧️',
          climateIcon: Icons.water_drop_rounded,
          islandEmoji: '🌊',
          description:
              'A collection of tropical green isles surrounded by serene turquoise coastal lagoons.',
        ),
        PoketCountryMap(
          id: 3,
          name: 'Coral Coast Sanctuary',
          tag: 'Palm Shoreline',
          landColor: Color(0xFF16A34A),
          waterColor: Color(0xFF06B6D4),
          totalSlots: 2000,
          filledSlots: 1320,
          climate: 'Tropical Breeze 🌴',
          climateIcon: Icons.beach_access_rounded,
          islandEmoji: '🏖️',
          description:
              'Sun-drenched golden beaches fringing bright emerald rainforest manors.',
        ),
      ],
    ),

    // ⚪ Mercury (Closest to Sun)
    PoketPlanet(
      id: 1,
      name: 'Mercury ⚪',
      theme: 'Swift Iron Frontier',
      tagLine: 'High Velocity Orbit • Sun Scorched Plains',
      primaryColor: Color(0xFFCBD5E1),
      glowColor: Color(0xFF94A3B8),
      radius: 10,
      orbitDistance: 85,
      orbitSpeed: 2.1,
      totalPlots: 4000,
      occupiedPlots: 1850,
      countryMaps: [
        PoketCountryMap(
          id: 4,
          name: 'Solar Basin Isle',
          tag: 'Crater Ridge',
          landColor: Color(0xFF64748B),
          waterColor: Color(0xFF0284C7),
          totalSlots: 4000,
          filledSlots: 1850,
          climate: 'Extreme Heat 🔥',
          climateIcon: Icons.local_fire_department_rounded,
          islandEmoji: '🌋',
        ),
      ],
    ),

    // 🟡 Venus
    PoketPlanet(
      id: 2,
      name: 'Venus 🟡',
      theme: 'Golden Veil',
      tagLine: 'Amber Atmosphere & Golden Dunes',
      primaryColor: Color(0xFFFDE047),
      glowColor: Color(0xFFD97706),
      radius: 14,
      orbitDistance: 130,
      orbitSpeed: 1.5,
      totalPlots: 6000,
      occupiedPlots: 3400,
      countryMaps: [
        PoketCountryMap(
          id: 5,
          name: 'Aphrodite Terra',
          tag: 'Golden Highlands',
          landColor: Color(0xFFB45309),
          waterColor: Color(0xFF0284C7),
          totalSlots: 6000,
          filledSlots: 3400,
          climate: 'Dense Gold Cloud ⛅',
          climateIcon: Icons.wb_cloudy_rounded,
          islandEmoji: '🏺',
        ),
      ],
    ),

    // 🔴 Mars
    PoketPlanet(
      id: 4,
      name: 'Mars 🔴',
      theme: 'Red Dunes Citadel',
      tagLine: 'Iron Oxide Canyons & High Altitude Bastions',
      primaryColor: Color(0xFFF97316),
      glowColor: Color(0xFFEA580C),
      radius: 13,
      orbitDistance: 220,
      orbitSpeed: 0.8,
      totalPlots: 7500,
      occupiedPlots: 4200,
      countryMaps: [
        PoketCountryMap(
          id: 6,
          name: 'Olympus Haven',
          tag: 'Volcano Oasis',
          landColor: Color(0xFF9A3412),
          waterColor: Color(0xFF0284C7),
          totalSlots: 7500,
          filledSlots: 4200,
          climate: 'Rusty Breeze 🌪️',
          climateIcon: Icons.air_rounded,
          islandEmoji: '🏜️',
        ),
      ],
    ),

    // 🟠 Jupiter (Giant)
    PoketPlanet(
      id: 5,
      name: 'Jupiter 🟠',
      theme: 'Great Storm Giant',
      tagLine: 'Colossal Gas Bands & Thunder Manors',
      primaryColor: Color(0xFFFDBA74),
      glowColor: Color(0xFFC2410C),
      radius: 26,
      orbitDistance: 275,
      orbitSpeed: 0.55,
      totalPlots: 12000,
      occupiedPlots: 8100,
      countryMaps: [
        PoketCountryMap(
          id: 7,
          name: 'Red Spot Citadel',
          tag: 'Storm Sanctuary',
          landColor: Color(0xFF7C2D12),
          waterColor: Color(0xFF0284C7),
          totalSlots: 12000,
          filledSlots: 8100,
          climate: 'Lightning Storm ⚡',
          climateIcon: Icons.bolt_rounded,
          islandEmoji: '🌪️',
        ),
      ],
    ),

    // 🪐 Saturn (Rings)
    PoketPlanet(
      id: 6,
      name: 'Saturn 🪐',
      theme: 'Ringed Majesty',
      tagLine: 'Golden Ice Dust Rings & Floating Palaces',
      primaryColor: Color(0xFFFEF08A),
      glowColor: Color(0xFFCA8A04),
      radius: 22,
      orbitDistance: 335,
      orbitSpeed: 0.42,
      totalPlots: 9500,
      occupiedPlots: 5600,
      countryMaps: [
        PoketCountryMap(
          id: 8,
          name: 'Titan Atoll',
          tag: 'Golden Rings View',
          landColor: Color(0xFF854D0E),
          waterColor: Color(0xFF0EA5E9),
          totalSlots: 9500,
          filledSlots: 5600,
          climate: 'Ring Horizon ✨',
          climateIcon: Icons.auto_awesome_rounded,
          islandEmoji: '💍',
        ),
      ],
    ),

    // 💠 Uranus
    PoketPlanet(
      id: 7,
      name: 'Uranus 💠',
      theme: 'Cyan Ice Sanctuary',
      tagLine: 'Methane Cyan Mist & Crystalline Peaks',
      primaryColor: Color(0xFF67E8F9),
      glowColor: Color(0xFF0891B2),
      radius: 18,
      orbitDistance: 395,
      orbitSpeed: 0.32,
      totalPlots: 7000,
      occupiedPlots: 2900,
      countryMaps: [
        PoketCountryMap(
          id: 9,
          name: 'Cyan Glacier Isle',
          tag: 'Ice Vault',
          landColor: Color(0xFF155E75),
          waterColor: Color(0xFF0369A1),
          totalSlots: 7000,
          filledSlots: 2900,
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
      primaryColor: Color(0xFF60A5FA),
      glowColor: Color(0xFF1D4ED8),
      radius: 17,
      orbitDistance: 450,
      orbitSpeed: 0.25,
      totalPlots: 6500,
      occupiedPlots: 1800,
      countryMaps: [
        PoketCountryMap(
          id: 10,
          name: 'Triton Abyss Atoll',
          tag: 'Deep Ocean Realm',
          landColor: Color(0xFF1E3A8A),
          waterColor: Color(0xFF172554),
          totalSlots: 6500,
          filledSlots: 1800,
          climate: 'Azure Tempest 🌊',
          climateIcon: Icons.waves_rounded,
          islandEmoji: '🔱',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitModeTabController = TabController(length: 2, vsync: this);
    _selectedPlanet = _planets.first; // Earth Prime
    _selectedCountry = _selectedPlanet!.countryMaps.first;

    _car = PoketVehicle(
      id: 'car_genesis',
      name: 'Falcon Cruiser 🚗',
      mode: TravelMode.car,
      icon: Icons.directions_car_rounded,
      speed: 2.5,
      currentPosition: const Offset(200, 280),
      headingAngle: 0.0,
    );

    _airplane = PoketVehicle(
      id: 'plane_genesis',
      name: 'Genesis Sky Hawk ✈️',
      mode: TravelMode.airplane,
      icon: Icons.flight_rounded,
      speed: 4.0,
      currentPosition: const Offset(220, 1500),
      headingAngle: -math.pi / 4,
    );

    _vehicleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() {
        setState(() {
          final t = Curves.easeInOutCubic.transform(_vehicleAnimController.value);
          final current = Offset.lerp(_vehicleStartPos, _vehicleEndPos, t)!;
          if (_travelMode == TravelMode.car) {
            _car.currentPosition = current;
          } else if (_travelMode == TravelMode.airplane || _travelMode == TravelMode.plane) {
            _airplane.currentPosition = current;
          }
        });
      });

    _loadRealCitizensIntoCountry();
  }

  @override
  void dispose() {
    _orbitModeTabController.dispose();
    _orbitInteractiveController.dispose();
    _mapZoomController.dispose();
    _vehicleAnimController.dispose();
    super.dispose();
  }

  /// 👥 Fetch real Supabase citizens and place them on sequential plots along island avenues
  Future<void> _loadRealCitizensIntoCountry() async {
    setState(() => _isLoadingCitizens = true);
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select(
              'id, user_id, name, profile_image_url, day, learning_day, pocket_score, is_vip, is_premium, created_at')
          .order('created_at', ascending: true)
          .limit(32);

      final List<CitizenPlot> plots = [];
      int plotIdx = 1;

      final streetNames = [
        "King's Coastal Highway",
        "Genesis Central Boulevard",
        "Palm Grove Avenue",
        "Emerald Bay Drive",
      ];

      for (var row in res) {
        final name = row['name']?.toString() ?? 'Citizen #$plotIdx';
        final day = (row['day'] as num?)?.toInt() ??
            (row['learning_day'] as num?)?.toInt() ??
            1;
        final score = (row['pocket_score'] as num?)?.toInt() ?? 0;
        final isVip = row['is_vip'] == true || row['is_premium'] == true;
        final avatar = row['profile_image_url']?.toString() ?? '';
        final uid = row['user_id']?.toString() ?? row['id']?.toString() ?? '';

        final int streetIdx = ((plotIdx - 1) ~/ 8).clamp(0, 3);
        final int colIdx = (plotIdx - 1) % 8;

        final double x = 240.0 + colIdx * 160.0;
        final double y = 280.0 + streetIdx * 360.0;

        final PlotDeedTier tier = plotIdx == 1
            ? PlotDeedTier.presidential
            : (streetIdx == 0 || streetIdx == 3)
                ? PlotDeedTier.beachfront
                : (streetIdx == 2)
                    ? PlotDeedTier.hilltop
                    : PlotDeedTier.standard;

        final int inactiveDays = (plotIdx % 7 == 0) ? 4 : 0;
        final PlotStatus status = CosmosInactivityPolicy.evaluatePlotStatus(
          score: score,
          inactiveDays: inactiveDays,
        );

        plots.add(
          CitizenPlot(
            plotNumber: plotIdx,
            userId: uid,
            userName: name,
            userAvatar: avatar,
            day: day,
            pocketScore: score,
            streetName: streetNames[streetIdx],
            postOffice: '${_selectedCountry?.name ?? 'Genesis'} Post',
            countryName: _selectedCountry?.name ?? 'Genesis Valley Island',
            planetName: _selectedPlanet?.name ?? 'Earth Prime 🌍',
            coordinates: Offset(x, y),
            isVip: isVip,
            isPresident: plotIdx == 1,
            tier: tier,
            status: status,
            inactivityDays: inactiveDays,
            deedValuePS: tier.baseValuationPS,
            postalPinCode: 'PK-${plotIdx.toString().padLeft(4, '0')}',
          ),
        );
        plotIdx++;
      }

      if (mounted) {
        setState(() {
          _citizenPlots = plots;
          _focusedPlot = plots.isNotEmpty ? plots.first : null;
          _isLoadingCitizens = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCitizens = false);
    }
  }

  void _navigateToIsland(PoketCountryMap country) {
    setState(() {
      _selectedCountry = country;
      _activeViewIndex = 1;
    });
    _loadRealCitizensIntoCountry();
    _mapZoomController.value = Matrix4.identity()..scale(0.75);
  }

  void _navigateToOrbit() {
    setState(() => _activeViewIndex = 0);
  }

  void _zoomOrbit(double factor) {
    final currentScale = _orbitInteractiveController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.4, 3.2);
    _orbitInteractiveController.value = Matrix4.identity()..scale(newScale);
  }

  void _resetOrbitZoom() {
    _orbitInteractiveController.value = Matrix4.identity()..scale(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        title: Text(
          _activeViewIndex == 0
              ? '🌌 Poket Solar System'
              : '🏝️ ${_selectedCountry?.name ?? 'Island Map'}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        leading: _activeViewIndex == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Back to Solar System',
                onPressed: _navigateToOrbit,
              )
            : null,
        bottom: _activeViewIndex == 0
            ? TabBar(
                controller: _orbitModeTabController,
                indicatorColor: const Color(0xFFFFD700),
                indicatorWeight: 3,
                labelColor: const Color(0xFFFFD700),
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.public_rounded), text: 'Solar System 🪐'),
                  Tab(icon: Icon(Icons.format_list_bulleted_rounded), text: 'Planets Directory 📋'),
                ],
              )
            : null,
      ),
      body: _activeViewIndex == 0
          ? TabBarView(
              controller: _orbitModeTabController,
              children: [
                // 🪐 TAB 1: FLAME 3D SOLAR SYSTEM WITH INTERACTIVEVIEWER & SIDE TILT
                _buildFlameSolarSystemTab(),

                // 📋 TAB 2: MINIMAL PLANET CARDS DIRECTORY WITH APEX AT TOP
                _buildPlanetsDirectoryTab(),
              ],
            )
          : _buildOceanicIslandMapView(),
    );
  }

  // =========================================================================
  // 🪐 TAB 1: FLAME ENGINE SOLAR SYSTEM WITH INTERACTIVEVIEWER & 3D TILT
  // =========================================================================
  Widget _buildFlameSolarSystemTab() {
    return Stack(
      children: [
        // Flame Game Engine Widget wrapped in InteractiveViewer for Smooth Zoom & Pan
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _orbitInteractiveController,
            minScale: 0.4,
            maxScale: 3.2,
            boundaryMargin: const EdgeInsets.all(350),
            child: SizedBox(
              width: 1050,
              height: 1050,
              child: GameWidget(
                game: FlameSolarSystemGame(
                  planets: _planets,
                  selectedPlanet: _selectedPlanet,
                  tiltAngle: _tiltAngle,
                  onPlanetSelected: (planet) {
                    setState(() {
                      _selectedPlanet = planet;
                      _selectedCountry = planet.countryMaps.first;
                    });
                  },
                  onPlanetDoubleTapped: (planet) {
                    setState(() {
                      _selectedPlanet = planet;
                      _selectedCountry = planet.countryMaps.first;
                    });
                    _navigateToIsland(planet.countryMaps.first);
                  },
                ),
              ),
            ),
          ),
        ),

        // Top 3D Tilt Bend & Perspective Slider Pill
        Positioned(
          top: 10,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
            ),
            child: Row(
              children: [
                const Icon(Icons.screen_rotation_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                Text(
                  '3D Tilt / Bend:',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      activeTrackColor: const Color(0xFFFFD700),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFFFD700),
                    ),
                    child: Slider(
                      value: _tiltAngle,
                      min: 0.0, // Top-down circular
                      max: 0.85, // Sharp side isometric view
                      onChanged: (val) {
                        setState(() => _tiltAngle = val);
                      },
                    ),
                  ),
                ),
                Text(
                  _tiltAngle < 0.2
                      ? 'Top-down'
                      : _tiltAngle < 0.6
                          ? '3D Isometric'
                          : 'Side Edge',
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // Floating Zoom (+ / - / Reset) Controls
        Positioned(
          right: 14,
          top: 70,
          child: Column(
            children: [
              _buildZoomButton(icon: Icons.add_rounded, tooltip: 'Zoom In', onTap: () => _zoomOrbit(1.25)),
              const SizedBox(height: 6),
              _buildZoomButton(icon: Icons.remove_rounded, tooltip: 'Zoom Out', onTap: () => _zoomOrbit(0.8)),
              const SizedBox(height: 6),
              _buildZoomButton(icon: Icons.restart_alt_rounded, tooltip: 'Reset View', onTap: _resetOrbitZoom),
            ],
          ),
        ),

        // Bottom Selected Planet Quick Info & Deep Dive Button
        if (_selectedPlanet != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _selectedPlanet!.primaryColor.withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _selectedPlanet!.primaryColor.withValues(alpha: 0.5), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 16)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedPlanet!.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: _selectedPlanet!.glowColor.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _selectedPlanet!.id == 3 ? '🌍' : '${_selectedPlanet!.id}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedPlanet!.name,
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          _selectedPlanet!.tagLine,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedPlanet!.availablePlots} Plots available • Double tap planet or explore',
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _navigateToIsland(_selectedPlanet!.countryMaps.first);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Enter 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // 📋 TAB 2: MINIMAL PLANET CARDS DIRECTORY
  // =========================================================================
  Widget _buildPlanetsDirectoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      itemCount: _planets.length,
      itemBuilder: (context, i) {
        final p = _planets[i];
        final isApexEarth = p.id == 3;
        final isSelected = p.id == _selectedPlanet?.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isApexEarth
                  ? const Color(0xFFFFD700)
                  : isSelected
                      ? p.primaryColor
                      : Colors.white12,
              width: isApexEarth || isSelected ? 1.8 : 1,
            ),
            boxShadow: [
              if (isApexEarth)
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _selectedPlanet = p;
                  _selectedCountry = p.countryMaps.first;
                });
                _navigateToIsland(p.countryMaps.first);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: p.glowColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isApexEarth ? '🌍' : '${p.id}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                  Flexible(
                                    child: Text(
                                      p.name,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (isApexEarth) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'APEX 👑',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                p.tagLine,
                                style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stats bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${p.occupiedPlots} / ${p.totalPlots} Occupied',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          '${p.availablePlots} free slots',
                          style: TextStyle(
                            color: p.availablePlots > 1000 ? const Color(0xFF10B981) : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: p.occupiedPlots / p.totalPlots,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(p.primaryColor),
                        minHeight: 4,
                      ),
                    ),
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
  // 🏝️ VIEW 2: OCEANIC ISLAND DEEP-DIVE MAP (Flame House Widgets, Drive & Fly)
  // =========================================================================
  Widget _buildOceanicIslandMapView() {
    final country = _selectedCountry ?? _planets.first.countryMaps.first;
    final planet = _selectedPlanet ?? _planets.first;

    return Stack(
      children: [
        // Main InteractiveViewer Canvas (Ocean + Island Landmass + Roads + Houses + Vehicles)
        Positioned.fill(
          child: _isLoadingCitizens
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                  transformationController: _mapZoomController,
                  minScale: 0.35,
                  maxScale: 3.5,
                  boundaryMargin: const EdgeInsets.all(500),
                  child: Container(
                    width: 1600,
                    height: 1700,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 0),
                        radius: 1.2,
                        colors: [
                          country.waterColor,
                          const Color(0xFF0369A1),
                          const Color(0xFF075985),
                          const Color(0xFF082F49),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _OceanicIslandPainter(
                              waterColor: country.waterColor,
                              landColor: country.landColor,
                            ),
                          ),
                        ),
                        _buildStreetLabels(),
                        for (final plot in _citizenPlots)
                          _buildCitizenPlotNode(plot),
                        _buildCarVehicleWidget(),
                        _buildAirplaneVehicleWidget(),
                      ],
                    ),
                  ),
                ),
        ),

        // Top Island Floating Info Strip
        Positioned(
          top: 10,
          left: 12,
          right: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Text(country.islandEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${country.name} (${planet.name})',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Pinch to Zoom • ${country.climate} • ${_citizenPlots.length} Plots placed',
                            style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _navigateToOrbit,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white10,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 14),
                      label: const Text('Orbit 🪐', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Drive & Fly Vehicle Modes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeChip(label: '🔍 Inspect Plots', mode: TravelMode.walk, icon: Icons.search_rounded),
                    const SizedBox(width: 4),
                    _buildModeChip(label: '🚗 Drive Car', mode: TravelMode.car, icon: Icons.directions_car_rounded),
                    const SizedBox(width: 4),
                    _buildModeChip(label: '✈️ Fly Airplane', mode: TravelMode.airplane, icon: Icons.flight_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Postal Deed Card
        if (_focusedPlot != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCitizenPostalCard(_focusedPlot!),
          ),
      ],
    );
  }

  Widget _buildModeChip({
    required String label,
    required TravelMode mode,
    required IconData icon,
  }) {
    final isSelected = _travelMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _travelMode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? Colors.black : Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStreetLabels() {
    return Stack(
      children: [
        _buildStreetSign("🛣️ King's Coastal Highway", 160, 245),
        _buildStreetSign("🛣️ Genesis Central Boulevard", 160, 605),
        _buildStreetSign("🛣️ Palm Grove Avenue", 160, 965),
        _buildStreetSign("🛣️ Emerald Bay Drive", 160, 1325),
      ],
    );
  }

  Widget _buildStreetSign(String name, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildCarVehicleWidget() {
    return Positioned(
      left: _car.currentPosition.dx - 22,
      top: _car.currentPosition.dy - 16,
      child: Transform.rotate(
        angle: _car.headingAngle,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car_rounded, color: Colors.white, size: 18),
              SizedBox(width: 2),
              Text('🚗', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirplaneVehicleWidget() {
    return Positioned(
      left: _airplane.currentPosition.dx - 30,
      top: _airplane.currentPosition.dy - 30,
      child: Transform.rotate(
        angle: _airplane.headingAngle,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(15, 20),
                blurRadius: 14,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: const Icon(Icons.flight_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }

  Widget _buildCitizenPlotNode(CitizenPlot plot) {
    final isFocused = plot.plotNumber == _focusedPlot?.plotNumber;

    return Positioned(
      left: plot.coordinates.dx - 65,
      top: plot.coordinates.dy - 60,
      child: GestureDetector(
        onTap: () {
          if (_travelMode == TravelMode.car || _travelMode == TravelMode.airplane) {
            _travelTo(plot.coordinates, label: 'Plot #${plot.plotNumber} (${plot.userName})');
          } else {
            setState(() => _focusedPlot = plot);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isFocused ? const Color(0xFFFFD700) : Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused ? Colors.white : Colors.white38,
                  width: isFocused ? 1.5 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Plot #${plot.plotNumber}',
                    style: TextStyle(
                      color: isFocused ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  if (plot.isPresident) ...[
                    const SizedBox(width: 4),
                    const Text('👑', style: TextStyle(fontSize: 10)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 130,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isFocused ? Border.all(color: const Color(0xFFFFD700), width: 2.5) : null,
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlameEnglishHouseWidget(
                  currentDay: plot.day,
                  streak: plot.day,
                  isPresident: plot.isPresident,
                  houseId: 'plot_${plot.plotNumber}',
                  showTestingControls: false,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                plot.userName,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _travelTo(Offset target, {String? label}) {
    if (_travelMode == TravelMode.car) {
      final avenues = [280.0, 640.0, 1000.0, 1360.0];
      double nearestAvenueY = avenues.first;
      double minDiff = (target.dy - nearestAvenueY).abs();
      for (final y in avenues) {
        if ((target.dy - y).abs() < minDiff) {
          minDiff = (target.dy - y).abs();
          nearestAvenueY = y;
        }
      }
      final adjustedTarget = Offset(target.dx, nearestAvenueY);

      setState(() {
        _vehicleStartPos = _car.currentPosition;
        _vehicleEndPos = adjustedTarget;
        _vehicleHeading = math.atan2(
            adjustedTarget.dy - _vehicleStartPos.dy, adjustedTarget.dx - _vehicleStartPos.dx);
        _car.headingAngle = _vehicleHeading;
      });
      _vehicleAnimController.forward(from: 0.0);
    } else if (_travelMode == TravelMode.airplane) {
      setState(() {
        _vehicleStartPos = _airplane.currentPosition;
        _vehicleEndPos = target;
        _vehicleHeading =
            math.atan2(target.dy - _vehicleStartPos.dy, target.dx - _vehicleStartPos.dx);
        _airplane.headingAngle = _vehicleHeading;
      });
      _vehicleAnimController.forward(from: 0.0);
    }
  }

  Widget _buildCitizenPostalCard(CitizenPlot plot) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 18, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: plot.isVip ? const Color(0xFFFFD700) : const Color(0xFF0284C7),
            child: Text(
              plot.userName.isNotEmpty ? plot.userName[0].toUpperCase() : 'C',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        plot.userName,
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Day ${plot.day} 🏠',
                        style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('⚡ ${plot.pocketScore} PS', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '📬 ${plot.formalPostalAddress}',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Visiting ${plot.userName}\'s Manor... 🚪'),
                  backgroundColor: const Color(0xFF0284C7),
                ),
              );
            },
            child: const Text('Visit 🚪', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
          ),
        ],
      ),
    );
  }
}

/// 🌊 Custom Painter for Realistic Oceanic Island & Roads
class _OceanicIslandPainter extends CustomPainter {
  final Color waterColor;
  final Color landColor;

  _OceanicIslandPainter({
    required this.waterColor,
    required this.landColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final islandPath = Path();
    islandPath.moveTo(200, 220);
    islandPath.quadraticBezierTo(750, 140, 1400, 220);
    islandPath.quadraticBezierTo(1520, 800, 1420, 1480);
    islandPath.quadraticBezierTo(850, 1620, 180, 1480);
    islandPath.quadraticBezierTo(100, 850, 200, 220);
    islandPath.close();

    final shallowWaterPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36;
    canvas.drawPath(islandPath, shallowWaterPaint);

    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    canvas.drawPath(islandPath, sandPaint);

    final landGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF22C55E),
        landColor,
        const Color(0xFF15803D),
      ],
    );
    final landPaint = Paint()
      ..shader = landGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(islandPath, landPaint);

    // Asphalt Roadways
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final List<double> avenues = [280, 640, 1000, 1360];
    for (final y in avenues) {
      canvas.drawLine(Offset(180, y), Offset(1400, y), roadPaint);
      for (double x = 190; x < 1390; x += 36) {
        canvas.drawLine(Offset(x, y), Offset(x + 18, y), dashPaint);
      }
    }

    final List<double> boulevards = [540, 1040];
    for (final x in boulevards) {
      canvas.drawLine(Offset(x, 260), Offset(x, 1380), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanicIslandPainter oldDelegate) {
    return oldDelegate.waterColor != waterColor ||
        oldDelegate.landColor != landColor;
  }
}
