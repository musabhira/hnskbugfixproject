import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'poket_cosmos_models.dart';

/// 🌌 Poket Cosmos Explorer:
/// Tab 1: Solar Orbit 3D Universe & Planet Directory
/// Tab 2: Country Map with InteractiveViewer Zoom & Front-facing Habit Manors
class PoketCosmosNavigatorPage extends StatefulWidget {
  const PoketCosmosNavigatorPage({super.key});

  @override
  State<PoketCosmosNavigatorPage> createState() =>
      _PoketCosmosNavigatorPageState();
}

class _PoketCosmosNavigatorPageState extends State<PoketCosmosNavigatorPage>
    with TickerProviderStateMixin {
  late TabController _modeTabController;
  late AnimationController _solarOrbitController;
  final TransformationController _mapZoomController =
      TransformationController();

  PoketPlanet? _selectedPlanet;
  PoketCountryMap? _selectedCountry;
  CitizenPlot? _focusedPlot;
  bool _isLoadingCitizens = false;

  List<CitizenPlot> _citizenPlots = [];

  final List<PoketPlanet> _planets = const [
    PoketPlanet(
      id: 1,
      name: 'Poket Earth Prime 🌍',
      theme: 'Cradle of Civilization',
      tagLine: 'Presidential Citadel & Genesis Citizens',
      primaryColor: Color(0xFF38BDF8),
      glowColor: Color(0xFF0284C7),
      radius: 42,
      orbitDistance: 125,
      orbitSpeed: 1.0,
      totalPlots: 10000,
      occupiedPlots: 8840,
      countryMaps: [
        PoketCountryMap(
          id: 1,
          name: 'Poket Central Republic',
          tag: 'Genesis Valley',
          landColor: Color(0xFF065F46),
          totalSlots: 5000,
          filledSlots: 4920,
          climate: 'Lush & Sunny ☀️',
          climateIcon: Icons.wb_sunny_rounded,
        ),
        PoketCountryMap(
          id: 2,
          name: 'Emerald Haven',
          tag: 'River Delta',
          landColor: Color(0xFF047857),
          totalSlots: 3000,
          filledSlots: 2600,
          climate: 'Rain & Breeze 🌧️',
          climateIcon: Icons.water_drop_rounded,
        ),
        PoketCountryMap(
          id: 3,
          name: 'Starlight Highlands',
          tag: 'Mountain Ridge',
          landColor: Color(0xFF1E3A8A),
          totalSlots: 2000,
          filledSlots: 1320,
          climate: 'Starry Mist ✨',
          climateIcon: Icons.nights_stay_rounded,
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
          name: 'Blizzard Peak',
          tag: 'Glacier Frontier',
          landColor: Color(0xFF312E81),
          totalSlots: 4000,
          filledSlots: 2800,
          climate: 'Snow Blizzard ❄️',
          climateIcon: Icons.ac_unit_rounded,
        ),
        PoketCountryMap(
          id: 5,
          name: 'Crystal Cavern',
          tag: 'Ice Shelf',
          landColor: Color(0xFF1E1B4B),
          totalSlots: 4000,
          filledSlots: 1520,
          climate: 'Deep Frost 🧊',
          climateIcon: Icons.severe_cold_rounded,
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
          name: 'Golden Dunes',
          tag: 'Oasis Capital',
          landColor: Color(0xFF78350F),
          totalSlots: 4500,
          filledSlots: 1500,
          climate: 'Warm Oasis 🌴',
          climateIcon: Icons.wb_sunny_rounded,
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
          id: 7,
          name: 'Neo Metropolis',
          tag: 'Cyber Grid',
          landColor: Color(0xFF164E63),
          totalSlots: 6000,
          filledSlots: 980,
          climate: 'Neon Rain ⚡',
          climateIcon: Icons.bolt_rounded,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _modeTabController = TabController(length: 2, vsync: this);
    _solarOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();

    _selectedPlanet = _planets.first;
    _selectedCountry = _selectedPlanet!.countryMaps.first;

    _loadRealCitizensIntoCountry();
  }

  @override
  void dispose() {
    _modeTabController.dispose();
    _solarOrbitController.dispose();
    _mapZoomController.dispose();
    super.dispose();
  }

  /// 👥 Fetch real Supabase citizens and place them on sequential plots
  Future<void> _loadRealCitizensIntoCountry() async {
    setState(() => _isLoadingCitizens = true);
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, user_id, name, profile_image_url, day, learning_day, pocket_score, is_vip, is_premium, created_at')
          .order('created_at', ascending: true)
          .limit(30);

      final List<CitizenPlot> plots = [];
      int plotIdx = 1;

      for (var row in res) {
        final name = row['name']?.toString() ?? 'Citizen #$plotIdx';
        final day = (row['day'] as num?)?.toInt() ??
            (row['learning_day'] as num?)?.toInt() ??
            1;
        final score = (row['pocket_score'] as num?)?.toInt() ?? 0;
        final isVip = row['is_vip'] == true || row['is_premium'] == true;
        final avatar = row['profile_image_url']?.toString() ?? '';
        final uid = row['user_id']?.toString() ?? row['id']?.toString() ?? '';

        // Generate coordinate on country map
        final int col = (plotIdx - 1) % 4;
        final int r = (plotIdx - 1) ~/ 4;
        final double x = 80.0 + col * 180.0;
        final double y = 90.0 + r * 220.0;

        plots.add(
          CitizenPlot(
            plotNumber: plotIdx,
            userId: uid,
            userName: name,
            userAvatar: avatar,
            day: day,
            pocketScore: score,
            streetName: 'Falcon Street',
            postOffice: 'Genesis Central',
            countryName: _selectedCountry?.name ?? 'Poket Central Republic',
            planetName: _selectedPlanet?.name ?? 'Poket Earth Prime',
            coordinates: Offset(x, y),
            isVip: isVip,
            isPresident: plotIdx == 1,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: Text(
          '🌌 Poket Cosmos Universe',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _modeTabController,
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFFFFD700),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.public_rounded), text: 'Planets & Orbit 🪐'),
            Tab(icon: Icon(Icons.map_rounded), text: 'Country Street Map 🗺️'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _modeTabController,
        children: [
          // 🪐 TAB 1: Dual Panel (List on one side + Flame/Canvas Orbit on the other)
          _buildPlanetsHubTab(),

          // 🗺️ TAB 2: Country Map with InteractiveViewer Zoom & Front-facing Houses
          _buildCountryMapViewTab(),
        ],
      ),
    );
  }

  // =========================================================================
  // 🪐 TAB 1: PLANETS HUB (List View on Left + 3D Solar Orbit on Right)
  // =========================================================================
  Widget _buildPlanetsHubTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return Column(
          children: [
            // Top Highlights Banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD700), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pioneering citizens occupy Planet 1. As plots fill up, new planets unlock in the solar system!',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area: Split List & Interactive Solar Orbit
            Expanded(
              child: isWide
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
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanetsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? p.primaryColor.withValues(alpha: 0.15)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? p.primaryColor : Colors.white10,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Planet orb icon
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
                      'P${p.id}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${p.availablePlots} slots left',
                            style: TextStyle(
                              color: p.availablePlots > 1000
                                  ? const Color(0xFF10B981)
                                  : Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p.tagLine,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Progress bar showing occupancy
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
            // Center Fiery Sun
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFEA580C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.65),
                    blurRadius: 38,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 26),
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
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
        ),

        // Planet body
        Transform.translate(
          offset: Offset(x, y),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlanet = planet;
                _selectedCountry = planet.countryMaps.first;
              });
              _modeTabController.animateTo(1); // Jump to Country Map
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
                    blurRadius: isSelected ? 18 : 10,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: isSelected ? 2 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  '${planet.id}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🗺️ TAB 2: COUNTRY STREET MAP WITH INTERACTIVEVIEWER ZOOM & FRONT HOUSES
  // =========================================================================
  Widget _buildCountryMapViewTab() {
    return Column(
      children: [
        // Horizontal Country Selector Chips
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _selectedPlanet?.countryMaps.length ?? 0,
            itemBuilder: (context, idx) {
              final c = _selectedPlanet!.countryMaps[idx];
              final isSel = c.id == _selectedCountry?.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.climateIcon, size: 14, color: isSel ? Colors.black : Colors.white70),
                      const SizedBox(width: 5),
                      Text(c.name),
                    ],
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedCountry = c);
                      _loadRealCitizensIntoCountry();
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Zoom & Pan Instructions Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pinch_rounded, color: Color(0xFFFFD700), size: 15),
              SizedBox(width: 6),
              Text(
                'Pinch to Zoom In & Pan Street • Tap any house to inspect resident',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),

        // 🗺️ InteractiveViewer Map Canvas (Front-facing 90-Day Habit Houses)
        Expanded(
          child: _isLoadingCitizens
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                  child: InteractiveViewer(
                    transformationController: _mapZoomController,
                    minScale: 0.6,
                    maxScale: 2.8,
                    boundaryMargin: const EdgeInsets.all(200),
                    child: Container(
                      width: 900,
                      height: 1400,
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B), // Lush Green Country Grass
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Stack(
                        children: [
                          // 🛣️ Draw Road Grid across Country
                          _buildCountryRoadNetwork(),

                          // 🏡 Render Front-Facing Habit Houses for each Citizen
                          for (final plot in _citizenPlots)
                            _buildFrontFacingHouse(plot),
                        ],
                      ),
                    ),
                  ),
                ),
        ),

        // Bottom Selected Citizen Address Deed Card
        if (_focusedPlot != null) _buildCitizenPostalCard(_focusedPlot!),
      ],
    );
  }

  Widget _buildCountryRoadNetwork() {
    return CustomPaint(
      size: const Size(900, 1400),
      painter: _CountryRoadsPainter(),
    );
  }

  Widget _buildFrontFacingHouse(CitizenPlot plot) {
    final isFocused = plot.plotNumber == _focusedPlot?.plotNumber;

    return Positioned(
      left: plot.coordinates.dx - 65,
      top: plot.coordinates.dy - 60,
      child: GestureDetector(
        onTap: () {
          setState(() => _focusedPlot = plot);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // House Plot Marker Label
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
            const SizedBox(height: 4),

            // 🏡 Front View Habit House (Flame English House Widget)
            Container(
              width: 130,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isFocused
                    ? Border.all(color: const Color(0xFFFFD700), width: 2)
                    : null,
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlameEnglishHouseWidget(
                  currentDay: plot.day,
                  streak: plot.day,
                  isTargetMode: false,
                  customScore: plot.pocketScore,
                  isMe: false,
                ),
              ),
            ),

            // Citizen Name Tag
            Text(
              plot.userName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
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
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
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
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  plot.formalPostalAddress,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Visiting ${plot.userName}\'s Manor... 🚀'),
                  backgroundColor: const Color(0xFF0284C7),
                ),
              );
            },
            child: const Text('Visit 🚪',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
          ),
        ],
      ),
    );
  }
}

/// 🛣️ Custom Painter to render country roads and pathways
class _CountryRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    final dashPaint = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Horizontal Avenues
    for (double y = 140; y < size.height; y += 220) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
      for (double x = 15; x < size.width; x += 35) {
        canvas.drawLine(Offset(x, y), Offset(x + 18, y), dashPaint);
      }
    }

    // Vertical Connecting Boulevards
    for (double x = 140; x < size.width; x += 360) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
