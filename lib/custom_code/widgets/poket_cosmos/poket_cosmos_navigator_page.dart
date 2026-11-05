import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'poket_cosmos_models.dart';
import 'poket_map_travel_game.dart';

/// 🌌 Poket Cosmos Master Navigator: Google Maps & Solar System Explorer
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage>
    with SingleTickerProviderStateMixin {
  int _activeViewIndex = 0; // 0: Solar System, 1: Country Map & Navigation
  TravelMode _selectedTravelMode = TravelMode.car;
  late AnimationController _orbitController;

  final TextEditingController _searchController = TextEditingController();
  CitizenPlot? _selectedPlot;
  late CitizenPlot _myPlot;
  late List<CitizenPlot> _citizenPlots;

  final List<PoketPlanet> _planets = const [
    PoketPlanet(
      id: 1,
      name: 'Poket Earth Prime',
      theme: 'Capital & Citadel',
      tagLine: 'Presidential Residence & Pioneers',
      primaryColor: Color(0xFF38BDF8),
      radius: 34,
      orbitDistance: 110,
      orbitSpeed: 1.0,
      totalPlots: 10000,
      occupiedPlots: 8940,
    ),
    PoketPlanet(
      id: 2,
      name: 'Frost Alpha',
      theme: 'Snow Citadel',
      tagLine: 'High Altitude Defense Fortresses',
      primaryColor: Color(0xFFA5B4FC),
      radius: 26,
      orbitDistance: 165,
      orbitSpeed: 0.75,
      totalPlots: 8000,
      occupiedPlots: 4320,
    ),
    PoketPlanet(
      id: 3,
      name: 'Sol Oasis',
      theme: 'Desert Sun',
      tagLine: 'Ancient Stone Manors & Sun Temples',
      primaryColor: Color(0xFFFBBF24),
      radius: 28,
      orbitDistance: 220,
      orbitSpeed: 0.55,
      totalPlots: 7500,
      occupiedPlots: 2150,
    ),
    PoketPlanet(
      id: 4,
      name: 'Emerald Nova',
      theme: 'Rainforest Canopy',
      tagLine: 'Riverside Cabins & Tree Sanctuaries',
      primaryColor: Color(0xFF34D399),
      radius: 24,
      orbitDistance: 275,
      orbitSpeed: 0.40,
      totalPlots: 6000,
      occupiedPlots: 980,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // Mock initial pioneering citizens & plots for demo
    _myPlot = const CitizenPlot(
      plotNumber: 1,
      userId: 'user_me',
      userName: 'Mus\'ab (You)',
      userAvatar: '',
      day: 24,
      pocketScore: 3200,
      streetName: 'Genesis Boulevard',
      sector: 'Capital District',
      coordinates: Offset(80, 110),
      isPresident: true,
    );

    _citizenPlots = [
      _myPlot,
      const CitizenPlot(
        plotNumber: 2,
        userId: 'u_2',
        userName: 'Zayan Mate',
        userAvatar: '',
        day: 15,
        pocketScore: 1850,
        streetName: 'Genesis Boulevard',
        sector: 'Capital District',
        coordinates: Offset(180, 110),
      ),
      const CitizenPlot(
        plotNumber: 3,
        userId: 'u_3',
        userName: 'Aysha English',
        userAvatar: '',
        day: 35,
        pocketScore: 4200,
        streetName: 'Palm Avenue',
        sector: 'South Harbor',
        coordinates: Offset(280, 260),
        isVip: true,
      ),
      const CitizenPlot(
        plotNumber: 4,
        userId: 'u_4',
        userName: 'Rahul Explorer',
        userAvatar: '',
        day: 9,
        pocketScore: 890,
        streetName: 'Palm Avenue',
        sector: 'South Harbor',
        coordinates: Offset(110, 260),
      ),
      const CitizenPlot(
        plotNumber: 5,
        userId: 'u_5',
        userName: 'Farhan Scholar',
        userAvatar: '',
        day: 48,
        pocketScore: 5600,
        streetName: 'Royal Crescent',
        sector: 'North Ridge',
        coordinates: Offset(290, 110),
        isVip: true,
      ),
    ];

    _selectedPlot = _citizenPlots[2]; // Default demo target
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Main Interactive View (Solar Orbit or Google Maps View)
            Positioned.fill(
              child: _activeViewIndex == 0
                  ? _buildSolarSystemView()
                  : _buildGoogleMapsCanvas(),
            ),

            // 2. Top Google Maps Search Bar & View Switcher
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: _buildTopSearchBar(),
            ),

            // 3. Bottom Travel HUD (When viewing Map)
            if (_activeViewIndex == 1 && _selectedPlot != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildTravelBottomCard(),
              ),
          ],
        ),
      ),
    );
  }

  // 🌌 Layer 1: Solar System View with Rotating Planetary Orbits
  Widget _buildSolarSystemView() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Center Sun
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                    blurRadius: 36,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
              ),
            ),

            // Planetary Orbits
            for (final planet in _planets) _buildPlanetOrbit(planet),
          ],
        );
      },
    );
  }

  Widget _buildPlanetOrbit(PoketPlanet planet) {
    final angle =
        (_orbitController.value * 2 * math.pi * planet.orbitSpeed) % (2 * math.pi);
    final x = planet.orbitDistance * math.cos(angle);
    final y = planet.orbitDistance * math.sin(angle);

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
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),

        // Planet Body
        Transform.translate(
          offset: Offset(x, y),
          child: GestureDetector(
            onTap: () {
              setState(() => _activeViewIndex = 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Landing on ${planet.name}... 🚀'),
                  backgroundColor: planet.primaryColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: planet.radius * 2,
                  height: planet.radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: planet.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: planet.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${planet.id}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  planet.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🗺️ Layer 2: Interactive Flame Game Engine Canvas
  Widget _buildGoogleMapsCanvas() {
    return ClipRRect(
      child: GameWidget(
        game: PoketMapTravelGame(
          plots: _citizenPlots,
          currentOrigin: _myPlot,
          currentTarget: _selectedPlot ?? _citizenPlots[1],
          travelMode: _selectedTravelMode,
          onArrived: (target) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Arrived at ${target.fullAddress}! 🏁'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🔍 Top Google Maps Search Bar
  Widget _buildTopSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _activeViewIndex == 0
                  ? Icons.travel_explore_rounded
                  : Icons.public_rounded,
              color: const Color(0xFFFFD700),
            ),
            onPressed: () {
              setState(() {
                _activeViewIndex = _activeViewIndex == 0 ? 1 : 0;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search Mate, Plot #, or Street...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (query) {
                final match = _citizenPlots.firstWhere(
                  (p) =>
                      p.userName.toLowerCase().contains(query.toLowerCase()) ||
                      p.plotNumber.toString() == query,
                  orElse: () => _citizenPlots[1],
                );
                setState(() {
                  _selectedPlot = match;
                  _activeViewIndex = 1;
                });
              },
            ),
          ),
          if (_activeViewIndex == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF0284C7)),
              ),
              child: Text(
                'Plot #${_selectedPlot?.plotNumber ?? 1}',
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🚗✈️ Bottom Google Maps Travel & Navigation HUD
  Widget _buildTravelBottomCard() {
    final plot = _selectedPlot!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: plot.isVip
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF0284C7),
                child: Text(
                  plot.userName[0],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.userName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      plot.fullAddress,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day ${plot.day} 🏠',
                  style: const TextStyle(
                    color: Color(0xFFFCD34D),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Travel Mode Selectors (Car, Flight, Train)
          Row(
            children: [
              _buildTravelModeButton(
                icon: Icons.directions_car_rounded,
                label: 'Drive Car',
                mode: TravelMode.car,
              ),
              const SizedBox(width: 8),
              _buildTravelModeButton(
                icon: Icons.flight_takeoff_rounded,
                label: 'Fly Plane',
                mode: TravelMode.plane,
              ),
              const SizedBox(width: 8),
              _buildTravelModeButton(
                icon: Icons.train_rounded,
                label: 'Train Rail',
                mode: TravelMode.train,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelModeButton({
    required IconData icon,
    required String label,
    required TravelMode mode,
  }) {
    final isSelected = _selectedTravelMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTravelMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0284C7)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white10,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
