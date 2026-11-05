import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'poket_cosmos_models.dart';

/// 🌌 Poket Cosmos Explorer:
/// 1. Orbit & Planets Hub: 3D Solar Orbit + Planet Directory + Horizontal Country Maps Carousel
/// 2. Oceanic Island Map: Vast Blue Sea with Bright Lush Green Island, InteractiveViewer Zoom,
///    Road Network, Front-Facing 90-Day Habit Manors, Postal Identity Deeds,
///    Interactive Vehicles (Drive Car 🚗 & Fly Airplane ✈️), and Civic Landmarks.
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage>
    with TickerProviderStateMixin {
  int _activeViewIndex = 0; // 0: Solar Orbit & Countries, 1: Oceanic Island Map
  late AnimationController _solarOrbitController;
  final TransformationController _mapZoomController =
      TransformationController();

  PoketPlanet? _selectedPlanet;
  PoketCountryMap? _selectedCountry;
  CitizenPlot? _focusedPlot;
  IslandLandmark? _focusedLandmark;
  bool _isLoadingCitizens = false;

  List<CitizenPlot> _citizenPlots = [];

  // 🚗 Travel Simulation Modes & Vehicles
  TravelMode _travelMode = TravelMode.walk;
  late AnimationController _vehicleAnimController;
  Offset _vehicleStartPos = const Offset(200, 280);
  Offset _vehicleEndPos = const Offset(200, 280);
  double _vehicleHeading = 0.0;
  bool _isVehicleInFlight = false;

  late PoketVehicle _car;
  late PoketVehicle _airplane;

  final List<IslandLandmark> _landmarks = const [
    IslandLandmark(
      id: 'lm_citadel',
      name: 'Presidential Citadel 👑',
      type: LandmarkType.presidentialCitadel,
      coordinates: Offset(180, 180),
      icon: Icons.account_balance_rounded,
      description: 'Supreme Council & Presidential Residence',
      accentColor: Color(0xFFFFD700),
    ),
    IslandLandmark(
      id: 'lm_airport',
      name: 'Genesis Airport Terminal ✈️',
      type: LandmarkType.airportTerminal,
      coordinates: Offset(220, 1500),
      icon: Icons.local_airport_rounded,
      description: 'Interplanetary Flight Hangar & Runway',
      accentColor: Color(0xFF38BDF8),
    ),
    IslandLandmark(
      id: 'lm_post',
      name: 'Central Post Office 📬',
      type: LandmarkType.centralPostOffice,
      coordinates: Offset(750, 640),
      icon: Icons.markunread_mailbox_rounded,
      description: 'Deed Registration & Postal Sorting Hub',
      accentColor: Color(0xFFF59E0B),
    ),
    IslandLandmark(
      id: 'lm_marina',
      name: 'Azure Marina Harbor 🛥️',
      type: LandmarkType.marinaHarbor,
      coordinates: Offset(1380, 840),
      icon: Icons.directions_boat_rounded,
      description: 'Oceanic Yacht Docks & Coastal Ferry',
      accentColor: Color(0xFF06B6D4),
    ),
  ];

  final List<PoketPlanet> _planets = const [
    PoketPlanet(
      id: 1,
      name: 'Poket Earth Prime 🌍',
      theme: 'Cradle of Civilization',
      tagLine: 'Presidential Citadel & Genesis Citizens',
      primaryColor: Color(0xFF38BDF8),
      glowColor: Color(0xFF0284C7),
      radius: 40,
      orbitDistance: 125,
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
    PoketPlanet(
      id: 2,
      name: 'Frost Alpha ❄️',
      theme: 'Snow Citadel',
      tagLine: 'High Altitude Defense Fortresses',
      primaryColor: Color(0xFFA5B4FC),
      glowColor: Color(0xFF6366F1),
      radius: 34,
      orbitDistance: 185,
      orbitSpeed: 0.75,
      totalPlots: 8000,
      occupiedPlots: 4320,
      countryMaps: [
        PoketCountryMap(
          id: 4,
          name: 'Glacier Isle',
          tag: 'Ice Shelf Capital',
          landColor: Color(0xFF0D9488),
          waterColor: Color(0xFF0369A1),
          totalSlots: 4000,
          filledSlots: 2800,
          climate: 'Snow Blizzard ❄️',
          climateIcon: Icons.ac_unit_rounded,
          islandEmoji: '🧊',
          description:
              'Crystalline coastal island with evergreen pine borders and frozen sea walls.',
        ),
        PoketCountryMap(
          id: 5,
          name: 'Aurora Fjord',
          tag: 'Northern Waters',
          landColor: Color(0xFF047857),
          waterColor: Color(0xFF1E3A8A),
          totalSlots: 4000,
          filledSlots: 1520,
          climate: 'Aurora Glow 🌌',
          climateIcon: Icons.nights_stay_rounded,
          islandEmoji: '✨',
          description:
              'Majestic green fjords dancing under northern celestial auroras.',
        ),
      ],
    ),
    PoketPlanet(
      id: 3,
      name: 'Sol Oasis ☀️',
      theme: 'Sun Manors',
      tagLine: 'Ancient Stone Temples & Sun Palaces',
      primaryColor: Color(0xFFFBBF24),
      glowColor: Color(0xFFD97706),
      radius: 36,
      orbitDistance: 245,
      orbitSpeed: 0.55,
      totalPlots: 7500,
      occupiedPlots: 2150,
      countryMaps: [
        PoketCountryMap(
          id: 6,
          name: 'Golden Atoll',
          tag: 'Sun Capital',
          landColor: Color(0xFF65A30D),
          waterColor: Color(0xFF0284C7),
          totalSlots: 4500,
          filledSlots: 1500,
          climate: 'Warm Oasis 🌴',
          climateIcon: Icons.wb_sunny_rounded,
          islandEmoji: '🏝️',
          description:
              'A sun-kissed emerald atoll surrounded by crystalline oceanic reefs.',
        ),
        PoketCountryMap(
          id: 7,
          name: 'Mirage Haven',
          tag: 'Coral Peninsula',
          landColor: Color(0xFF15803D),
          waterColor: Color(0xFF0EA5E9),
          totalSlots: 3000,
          filledSlots: 650,
          climate: 'Crystal Sea ☀️',
          climateIcon: Icons.waves_rounded,
          islandEmoji: '⛵',
          description:
              'Emerald palms jutting into calm tropical oceanic waters.',
        ),
      ],
    ),
    PoketPlanet(
      id: 4,
      name: 'Cyber Nova 🤖',
      theme: 'Robotic Frontier',
      tagLine: 'Neon Skillets & Autonomous AI Hubs',
      primaryColor: Color(0xFF06B6D4),
      glowColor: Color(0xFF0891B2),
      radius: 30,
      orbitDistance: 305,
      orbitSpeed: 0.40,
      totalPlots: 6000,
      occupiedPlots: 980,
      countryMaps: [
        PoketCountryMap(
          id: 8,
          name: 'Neo Metropolis Isle',
          tag: 'Cyber Grid',
          landColor: Color(0xFF059669),
          waterColor: Color(0xFF0F766E),
          totalSlots: 6000,
          filledSlots: 980,
          climate: 'Neon Breeze ⚡',
          climateIcon: Icons.bolt_rounded,
          islandEmoji: '🏙️',
          description:
              'Techno-green coastal metropolis where automated habit manors thrive.',
        ),
      ],
    ),
    PoketPlanet(
      id: 5,
      name: 'Astral Crown 👑',
      theme: 'Sanctuary of Masters',
      tagLine: 'Day 90+ Legends & Presidential Council',
      primaryColor: Color(0xFFEC4899),
      glowColor: Color(0xFFDB2777),
      radius: 32,
      orbitDistance: 360,
      orbitSpeed: 0.30,
      totalPlots: 5000,
      occupiedPlots: 450,
      countryMaps: [
        PoketCountryMap(
          id: 9,
          name: 'Valhalla Sanctuary Isle',
          tag: 'Legend Summit',
          landColor: Color(0xFF16A34A),
          waterColor: Color(0xFF0284C7),
          totalSlots: 5000,
          filledSlots: 450,
          climate: 'Starlight Glow ✨',
          climateIcon: Icons.military_tech_rounded,
          islandEmoji: '🏰',
          description:
              'Legendary floating garden island reserved for master habit builders.',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _solarOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _selectedPlanet = _planets.first;
    _selectedCountry = _selectedPlanet!.countryMaps.first;

    // Initialize Vehicles
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
          } else if (_travelMode == TravelMode.airplane) {
            _airplane.currentPosition = current;
          }
        });
      });

    _loadRealCitizensIntoCountry();
  }

  @override
  void dispose() {
    _solarOrbitController.dispose();
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

      // 4 Avenues across the lush green island (canvas size: 1600 x 1700)
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

        // Assign Deed Tier based on location and prestige
        final PlotDeedTier tier = plotIdx == 1
            ? PlotDeedTier.presidential
            : (streetIdx == 0 || streetIdx == 3)
                ? PlotDeedTier.beachfront
                : (streetIdx == 2)
                    ? PlotDeedTier.hilltop
                    : PlotDeedTier.standard;

        // Compute simulated activity status
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
            planetName: _selectedPlanet?.name ?? 'Poket Earth Prime',
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

  void _zoomMap(double factor) {
    final currentScale = _mapZoomController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.35, 3.5);
    _mapZoomController.value = Matrix4.identity()..scale(newScale);
  }

  void _resetZoom() {
    _mapZoomController.value = Matrix4.identity()..scale(0.8);
  }

  /// 🚗 / ✈️ Travel Navigation Trigger
  void _travelToDestination(Offset target, {String? label}) {
    if (_travelMode == TravelMode.car) {
      // Find nearest avenue Y
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
            adjustedTarget.dy - _vehicleStartPos.dy,
            adjustedTarget.dx - _vehicleStartPos.dx);
        _car.headingAngle = _vehicleHeading;
      });
      _vehicleAnimController.forward(from: 0.0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚗 Cruising to ${label ?? 'destination'} along avenue...'),
          backgroundColor: const Color(0xFF1E293B),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_travelMode == TravelMode.airplane) {
      setState(() {
        _vehicleStartPos = _airplane.currentPosition;
        _vehicleEndPos = target;
        _vehicleHeading = math.atan2(
            target.dy - _vehicleStartPos.dy, target.dx - _vehicleStartPos.dx);
        _airplane.headingAngle = _vehicleHeading;
      });
      _vehicleAnimController.forward(from: 0.0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✈️ Flying high altitude over island to ${label ?? 'destination'}...'),
          backgroundColor: const Color(0xFF0284C7),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: Text(
          _activeViewIndex == 0
              ? '🌌 Poket Cosmos Solar System'
              : '🏝️ ${_selectedCountry?.name ?? 'Island Map'}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        leading: _activeViewIndex == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Back to Planets & Orbit',
                onPressed: _navigateToOrbit,
              )
            : null,
        actions: [
          if (_activeViewIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.map_rounded,
                    color: Color(0xFFFFD700), size: 18),
                label: const Text('Go to Island',
                    style: TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (_selectedCountry != null) {
                    _navigateToIsland(_selectedCountry!);
                  }
                },
              ),
            ),
        ],
      ),
      body: _activeViewIndex == 0
          ? _buildOrbitAndCountriesHub()
          : _buildOceanicIslandMapView(),
    );
  }

  // =========================================================================
  // 🪐 VIEW 1: SOLAR ORBIT & HORIZONTAL COUNTRY MAPS CAROUSEL
  // =========================================================================
  Widget _buildOrbitAndCountriesHub() {
    return Column(
      children: [
        // Top Innovation Header
        Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.public_rounded,
                  color: Color(0xFFFFD700), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Select a Planet to view its territories. Scroll horizontally to pick an Island Country surrounded by ocean!',
                  style:
                      GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),

        // Solar Orbit Animation + Planet Cards
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 750;
              return isWide
                  ? Row(
                      children: [
                        Expanded(flex: 4, child: _buildPlanetsList()),
                        const VerticalDivider(color: Colors.white10, width: 1),
                        Expanded(flex: 5, child: _buildSolarOrbitCanvas()),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(flex: 5, child: _buildSolarOrbitCanvas()),
                        const Divider(color: Colors.white10, height: 1),
                        Expanded(flex: 4, child: _buildPlanetsList()),
                      ],
                    );
            },
          ),
        ),

        // 🗺️ HORIZONTAL COUNTRY MAPS CAROUSEL (User Request)
        _buildHorizontalCountryCardsCarousel(),
      ],
    );
  }

  Widget _buildPlanetsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: _planets.length,
      itemBuilder: (context, i) {
        final p = _planets[i];
        final isSelected = p.id == _selectedPlanet?.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedPlanet = p;
              _selectedCountry = p.countryMaps.first;
            });
            _loadRealCitizensIntoCountry();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? p.primaryColor.withValues(alpha: 0.15)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? p.primaryColor : Colors.white10,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: p.glowColor.withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'P${p.id}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${p.availablePlots} left',
                            style: TextStyle(
                              color: p.availablePlots > 1000
                                  ? const Color(0xFF10B981)
                                  : Colors.orange,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${p.countryMaps.length} Island Countries • ${p.occupiedPlots}/${p.totalPlots} filled',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10.5),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.occupiedPlots / p.totalPlots,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(p.primaryColor),
                          minHeight: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isSelected ? p.primaryColor : Colors.white38,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolarOrbitCanvas() {
    return AnimatedBuilder(
      animation: _solarOrbitController,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glowing Core Sun
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFEA580C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child:
                    Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 24),
              ),
            ),

            // Planet orbits
            for (final planet in _planets) _buildSinglePlanetOrb(planet),
          ],
        );
      },
    );
  }

  Widget _buildSinglePlanetOrb(PoketPlanet planet) {
    final angle =
        (_solarOrbitController.value * 2 * math.pi * planet.orbitSpeed) %
            (2 * math.pi);
    final x = planet.orbitDistance * math.cos(angle);
    final y = planet.orbitDistance * math.sin(angle);
    final isSelected = planet.id == _selectedPlanet?.id;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Orbit ring
        Container(
          width: planet.orbitDistance * 2,
          height: planet.orbitDistance * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? planet.primaryColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
        ),

        // Orbiting Planet
        Transform.translate(
          offset: Offset(x, y),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlanet = planet;
                _selectedCountry = planet.countryMaps.first;
              });
              _loadRealCitizensIntoCountry();
            },
            child: Container(
              width: planet.radius * 2,
              height: planet.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [planet.primaryColor, planet.glowColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: planet.glowColor.withValues(alpha: 0.6),
                    blurRadius: isSelected ? 16 : 8,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: isSelected ? 2 : 0.6,
                ),
              ),
              child: Center(
                child: Text(
                  '${planet.id}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🗺️ Horizontal Scrolling Container for Country Maps
  Widget _buildHorizontalCountryCardsCarousel() {
    final planet = _selectedPlanet ?? _planets.first;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(top: BorderSide(color: Colors.white12, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.travel_explore_rounded,
                    color: planet.primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${planet.name} • Island Territories',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Text(
                  'Scroll Horizontally 👉',
                  style: TextStyle(
                    color: planet.primaryColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal ListView of Country Cards
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: planet.countryMaps.length,
              itemBuilder: (context, idx) {
                final c = planet.countryMaps[idx];
                final isCurrent = c.id == _selectedCountry?.id;

                return Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.landColor.withValues(alpha: 0.35),
                        const Color(0xFF1E293B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent ? const Color(0xFFFFD700) : Colors.white12,
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent
                            ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                            : Colors.black38,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _navigateToIsland(c),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(c.islandEmoji,
                                    style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        c.tag,
                                        style: TextStyle(
                                          color: planet.primaryColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Climate badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(c.climateIcon,
                                      size: 13,
                                      color: const Color(0xFFFFD700)),
                                  const SizedBox(width: 5),
                                  Text(
                                    c.climate,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Slots progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${c.filledSlots} / ${c.totalSlots} Slots',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 10.5),
                                ),
                                Text(
                                  '${c.availableSlots} free',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCurrent
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFF0284C7),
                                  foregroundColor:
                                      isCurrent ? Colors.black : Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _navigateToIsland(c),
                                icon: const Icon(Icons.zoom_in_rounded,
                                    size: 16),
                                label: const Text('Enter Island 🏝️',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🗺️ VIEW 2: OCEANIC ISLAND MAP WITH LUSH GREEN COUNTRY & HOUSES
  // =========================================================================
  Widget _buildOceanicIslandMapView() {
    final country = _selectedCountry ?? _planets.first.countryMaps.first;
    final planet = _selectedPlanet ?? _planets.first;

    return Stack(
      children: [
        // 🌊 Main InteractiveViewer Canvas (Ocean + Island Landmass + Roads + Houses + Vehicles)
        Positioned.fill(
          child: _isLoadingCitizens
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                  transformationController: _mapZoomController,
                  minScale: 0.35, // Fully zoomed out orbit perspective
                  maxScale: 3.5, // Crisp street-level view of habit houses
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
                        // 🏝️ Painted Island (Ocean Wave Rims, Golden Beaches, Lush Green Land, Roads, Runway)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _OceanicIslandPainter(
                              waterColor: country.waterColor,
                              landColor: country.landColor,
                            ),
                          ),
                        ),

                        // 🏛️ Civic Landmarks (Citadel, Airport, Marina, Post Office)
                        for (final landmark in _landmarks)
                          _buildLandmarkNode(landmark),

                        // 🏷️ Painted Street Name Plaques
                        _buildStreetLabels(),

                        // 🏡 Citizen Front-Facing Habit Houses (Flame English House Widget)
                        for (final plot in _citizenPlots)
                          _buildCitizenPlotNode(plot),

                        // 🚗 Interactive Car Driving along Avenues
                        _buildCarVehicleWidget(),

                        // ✈️ Interactive Airplane Flying High Over Island
                        _buildAirplaneVehicleWidget(),
                      ],
                    ),
                  ),
                ),
        ),

        // 🧭 Top Island Floating Info Strip & Mode Selector
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(country.islandEmoji,
                        style: const TextStyle(fontSize: 20)),
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
                            'Pinch to Zoom • ${country.climate} • ${_citizenPlots.length} Plots',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToOrbit,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                      child: const Text('🪐 Orbit',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 🚗 ✈️ Travel Mode Toggle Strip (User Directive)
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
                    _buildModeChip(
                      label: '🔍 Inspect Plots',
                      mode: TravelMode.walk,
                      icon: Icons.search_rounded,
                    ),
                    const SizedBox(width: 4),
                    _buildModeChip(
                      label: '🚗 Drive Car',
                      mode: TravelMode.car,
                      icon: Icons.directions_car_rounded,
                    ),
                    const SizedBox(width: 4),
                    _buildModeChip(
                      label: '✈️ Fly Airplane',
                      mode: TravelMode.airplane,
                      icon: Icons.flight_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🔍 Floating Zoom Control Buttons (+ / - / Reset)
        Positioned(
          right: 14,
          top: 115,
          child: Column(
            children: [
              _buildZoomButton(
                icon: Icons.add_rounded,
                tooltip: 'Zoom In',
                onTap: () => _zoomMap(1.25),
              ),
              const SizedBox(height: 6),
              _buildZoomButton(
                icon: Icons.remove_rounded,
                tooltip: 'Zoom Out',
                onTap: () => _zoomMap(0.8),
              ),
              const SizedBox(height: 6),
              _buildZoomButton(
                icon: Icons.restart_alt_rounded,
                tooltip: 'Reset Orbit View',
                onTap: _resetZoom,
              ),
            ],
          ),
        ),

        // 📜 Bottom Citizen Postal Deed Card
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mode == TravelMode.car
                  ? '🚗 Drive Mode Active! Tap any plot or road to cruise there.'
                  : mode == TravelMode.airplane
                      ? '✈️ Flight Mode Active! Tap any landmark or house to fly over.'
                      : '🔍 Inspection Mode Active! Tap houses to inspect Postal Deeds.',
            ),
            duration: const Duration(milliseconds: 1400),
            backgroundColor: isSelected
                ? const Color(0xFFFFD700)
                : const Color(0xFF0284C7),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.black : Colors.white70,
            ),
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

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
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

  Widget _buildLandmarkNode(IslandLandmark lm) {
    return Positioned(
      left: lm.coordinates.dx - 45,
      top: lm.coordinates.dy - 40,
      child: GestureDetector(
        onTap: () {
          if (_travelMode != TravelMode.walk) {
            _travelToDestination(lm.coordinates, label: lm.name);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🏛️ ${lm.name} • ${lm.description}'),
                backgroundColor: lm.accentColor,
              ),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: lm.accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: lm.accentColor.withValues(alpha: 0.6),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(lm.icon, color: lm.accentColor, size: 24),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: lm.accentColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                lm.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
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
                offset: Offset(15, 20), // High altitude ground shadow
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
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
          if (_travelMode != TravelMode.walk) {
            _travelToDestination(plot.coordinates,
                label: 'Plot #${plot.plotNumber} (${plot.userName})');
          } else {
            setState(() => _focusedPlot = plot);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plot Badge Label with Deed Tier Tag
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

            // 🏡 Front View Habit House (Flame English House Widget)
            Container(
              width: 130,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isFocused
                    ? Border.all(color: const Color(0xFFFFD700), width: 2.5)
                    : null,
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

            // Citizen Name & Status Tag
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

  Widget _buildCitizenPostalCard(CitizenPlot plot) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: plot.isVip
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF0284C7),
                child: Text(
                  plot.userName.isNotEmpty ? plot.userName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Day ${plot.day} 🏠',
                            style: const TextStyle(
                              color: Color(0xFFFCD34D),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '⚡ ${plot.pocketScore} PS',
                          style: const TextStyle(
                              color: Color(0xFF38BDF8), fontSize: 10.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Deed Tier & Valuation Pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            plot.tier.displayName,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Valuation: ⚡${plot.tier.baseValuationPS} PS',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📬 ${plot.formalPostalAddress}',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _travelToDestination(plot.coordinates,
                          label: '${plot.userName}\'s Manor');
                    },
                    child: Text(
                      _travelMode == TravelMode.car
                          ? 'Drive 🚗'
                          : _travelMode == TravelMode.airplane
                              ? 'Fly ✈️'
                              : 'Visit 🚪',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🌊 Custom Painter to render realistic ocean waters, sandy beaches, lush green island, and road network
class _OceanicIslandPainter extends CustomPainter {
  final Color waterColor;
  final Color landColor;

  _OceanicIslandPainter({
    required this.waterColor,
    required this.landColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Organic Island Outline
    final islandPath = Path();
    islandPath.moveTo(200, 220);
    islandPath.quadraticBezierTo(750, 140, 1400, 220);
    islandPath.quadraticBezierTo(1520, 800, 1420, 1480);
    islandPath.quadraticBezierTo(850, 1620, 180, 1480);
    islandPath.quadraticBezierTo(100, 850, 200, 220);
    islandPath.close();

    // 2. Coastal Shallow Water / Reef Glow
    final shallowWaterPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36;
    canvas.drawPath(islandPath, shallowWaterPaint);

    // 3. Sandy Shoreline Beach
    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    canvas.drawPath(islandPath, sandPaint);

    // 4. Lush Bright Green Island Body
    final landGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF22C55E), // Fresh bright light green
        landColor, // Lush deep emerald green
        const Color(0xFF15803D), // Rich forest green
      ],
    );
    final landPaint = Paint()
      ..shader = landGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(islandPath, landPaint);

    // 5. Scenic Inner Lagoon / River inlet
    final lagoonPath = Path();
    lagoonPath.moveTo(1400, 850);
    lagoonPath.quadraticBezierTo(1050, 820, 880, 860);
    lagoonPath.quadraticBezierTo(720, 900, 620, 860);

    final lagoonPaint = Paint()
      ..color = waterColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 28;
    canvas.drawPath(lagoonPath, lagoonPaint);

    // 6. Asphalt Road Network
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 4 Main Horizontal Avenues
    final List<double> avenues = [280, 640, 1000, 1360];
    for (final y in avenues) {
      canvas.drawLine(Offset(180, y), Offset(1400, y), roadPaint);
      for (double x = 190; x < 1390; x += 36) {
        canvas.drawLine(Offset(x, y), Offset(x + 18, y), dashPaint);
      }
    }

    // 2 Vertical Connecting Boulevards
    final List<double> boulevards = [540, 1040];
    for (final x in boulevards) {
      canvas.drawLine(Offset(x, 260), Offset(x, 1380), roadPaint);
    }

    // 7. ✈️ Airport Runway at bottom left
    final runwayPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final rwyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(180, 1460, 240, 48),
      const Radius.circular(8),
    );
    canvas.drawRRect(rwyRect, runwayPaint);

    // Runway center markings
    final rwyDash = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3;
    for (double rx = 195; rx < 400; rx += 25) {
      canvas.drawLine(Offset(rx, 1484), Offset(rx + 14, 1484), rwyDash);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanicIslandPainter oldDelegate) {
    return oldDelegate.waterColor != waterColor ||
        oldDelegate.landColor != landColor;
  }
}
