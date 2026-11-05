import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'poket_cosmos_models.dart';

/// 🛣️ 2-Point Perspective Front-View Street Drive View
/// Features a paved avenue with front-facing 90-day habit houses, moving car with headlights & wheels,
/// real-time speedometer, auto-cruise, manual steering, and postal identity deed inspection.
class IslandStreetDriveView extends StatefulWidget {
  final PoketCountryMap island;
  final VoidCallback onBackToAerial;

  const IslandStreetDriveView({
    super.key,
    required this.island,
    required this.onBackToAerial,
  });

  @override
  State<IslandStreetDriveView> createState() => _IslandStreetDriveViewState();
}

class _IslandStreetDriveViewState extends State<IslandStreetDriveView>
    with SingleTickerProviderStateMixin {
  final ScrollController _streetScrollController = ScrollController();
  late AnimationController _driveAnimController;
  bool _isAutoDriving = false;
  double _carSpeed = 0.0;
  CitizenPlot? _inspectedPlot;
  List<CitizenPlot> _plots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _driveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onDriveTick);

    _loadCitizensForStreet();
  }

  @override
  void dispose() {
    _driveAnimController.dispose();
    _streetScrollController.dispose();
    super.dispose();
  }

  void _onDriveTick() {
    if (_isAutoDriving && _streetScrollController.hasClients) {
      final max = _streetScrollController.position.maxScrollExtent;
      final next = _streetScrollController.offset + 4.2;
      if (next >= max) {
        _streetScrollController.jumpTo(0.0);
      } else {
        _streetScrollController.jumpTo(next);
      }
    }
  }

  Future<void> _loadCitizensForStreet() async {
    setState(() => _isLoading = true);
    try {
      final res = await SupaFlow.client
          .from('profile')
          .select('id, user_id, name, day, learning_day, pocket_score, is_vip, is_premium, created_at')
          .order('created_at', ascending: true)
          .limit(widget.island.totalSlots.clamp(1, 50));

      final List<CitizenPlot> list = [];
      int idx = 1;
      for (var row in res) {
        final name = row['name']?.toString() ?? 'Citizen #$idx';
        final day = (row['day'] as num?)?.toInt() ??
            (row['learning_day'] as num?)?.toInt() ??
            1;
        final score = (row['pocket_score'] as num?)?.toInt() ?? 0;
        final isVip = row['is_vip'] == true || row['is_premium'] == true;
        final uid = row['user_id']?.toString() ?? row['id']?.toString() ?? '';

        list.add(
          CitizenPlot(
            plotNumber: idx,
            userId: uid,
            userName: name,
            userAvatar: '',
            day: day,
            pocketScore: score,
            streetName: "${widget.island.name} Boulevard",
            postOffice: "${widget.island.name} Post",
            countryName: widget.island.name,
            planetName: 'Earth Prime 🌍',
            coordinates: Offset(idx * 240.0, 300),
            isVip: isVip,
            isPresident: widget.island.isPresidential || idx == 1,
            tier: widget.island.isPresidential
                ? PlotDeedTier.presidential
                : (idx <= 10 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
            postalPinCode: 'PK-${widget.island.id.toString().padLeft(2, '0')}${idx.toString().padLeft(3, '0')}',
          ),
        );
        idx++;
      }

      if (mounted) {
        setState(() {
          _plots = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleAutoDrive() {
    setState(() {
      _isAutoDriving = !_isAutoDriving;
      if (_isAutoDriving) {
        _carSpeed = 52.0;
        _driveAnimController.repeat();
      } else {
        _carSpeed = 0.0;
        _driveAnimController.stop();
      }
    });
  }

  void _accelerateManual(double delta) {
    if (_streetScrollController.hasClients) {
      final next = (_streetScrollController.offset + delta)
          .clamp(0.0, _streetScrollController.position.maxScrollExtent);
      _streetScrollController.animateTo(
        next,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 🛣️ Horizontal Perspective Street with Front-Facing Houses
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                : _buildStreetCanvas(),
          ),

          // 1. Top Minimal iOS Bar
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
                    const Color(0xFF0F172A).withValues(alpha: 0.95),
                    const Color(0xFF0F172A).withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      tooltip: 'Back to Aerial Map',
                      onPressed: widget.onBackToAerial,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${widget.island.name} • Street View',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.island.isPresidential) ...[
                              const SizedBox(width: 6),
                              const Text('👑', style: TextStyle(fontSize: 14)),
                            ],
                          ],
                        ),
                        Text(
                          '${_plots.length} Front-View Habit Manors • Tap house for Postal Deed',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // Drive Cruise Speed Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed_rounded, color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_carSpeed.toInt()} km/h',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Fixed Driving Car in Forefront with Headlights & Wheels
          Positioned(
            left: 30,
            bottom: _inspectedPlot != null ? 150 : 85,
            child: _buildSportsCarWidget(),
          ),

          // 3. Bottom Car Control Strip (Cruise & Drive button + Manual Gas/Reverse)
          Positioned(
            left: 14,
            right: 14,
            bottom: _inspectedPlot != null ? 140 : 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reverse
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  tooltip: 'Reverse Car',
                  onPressed: () => _accelerateManual(-150.0),
                ),
                const SizedBox(width: 12),
                // Auto Cruise Toggle Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAutoDriving ? const Color(0xFFEF4444) : const Color(0xFFFFD700),
                    foregroundColor: _isAutoDriving ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                  ),
                  onPressed: _toggleAutoDrive,
                  icon: Icon(_isAutoDriving ? Icons.pause_rounded : Icons.directions_car_rounded, size: 20),
                  label: Text(
                    _isAutoDriving ? 'Stop Cruise 🛑' : 'Drive Along Street 🚗💨',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                // Forward Gas
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFD700)),
                  tooltip: 'Drive Forward',
                  onPressed: () => _accelerateManual(150.0),
                ),
              ],
            ),
          ),

          // 4. Bottom Postal Identity Deed Card
          if (_inspectedPlot != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _buildPostalDeedCard(_inspectedPlot!),
            ),
        ],
      ),
    );
  }

  Widget _buildSportsCarWidget() {
    return Container(
      width: 85,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626), // Flame Red Sports Car
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.6),
            blurRadius: 14,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black87,
            offset: Offset(0, 10),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Car windshield
          Positioned(
            left: 20,
            top: 4,
            right: 20,
            height: 18,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Headlights beam
          Positioned(
            right: 2,
            top: 12,
            child: Container(
              width: 16,
              height: 24,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFEF08A),
                    const Color(0xFFFEF08A).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Car icon label
          const Center(
            child: Text('🚗', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }

  Widget _buildStreetCanvas() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0284C7), // Sky blue
            Color(0xFF38BDF8),
            Color(0xFF047857), // Lush green lawn
            Color(0xFF1E293B), // Asphalt road
          ],
          stops: [0.0, 0.35, 0.45, 0.75],
        ),
      ),
      child: Stack(
        children: [
          // Road Yellow Dashes line
          Positioned(
            left: 0,
            right: 0,
            bottom: 70,
            height: 4,
            child: CustomPaint(
              painter: _StreetLanePainter(),
            ),
          ),

          // Houses along avenue
          ListView.builder(
            controller: _streetScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: _plots.length,
            itemBuilder: (context, i) {
              final plot = _plots[i];
              final isSel = plot.plotNumber == _inspectedPlot?.plotNumber;

              return Container(
                width: 240,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Plot Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFFFD700) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? Colors.white : Colors.white24,
                          width: isSel ? 1.8 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Plot #${plot.plotNumber}',
                            style: TextStyle(
                              color: isSel ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          if (plot.isPresident) ...[
                            const SizedBox(width: 4),
                            const Text('👑', style: TextStyle(fontSize: 10)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Front-Facing 90-Day Habit House
                    GestureDetector(
                      onTap: () {
                        setState(() => _inspectedPlot = plot);
                      },
                      child: Container(
                        width: 170,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: isSel
                              ? Border.all(color: const Color(0xFFFFD700), width: 2.5)
                              : null,
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                    blurRadius: 18,
                                    spreadRadius: 3,
                                  ),
                                ]
                              : [
                                  const BoxShadow(color: Colors.black45, blurRadius: 10),
                                ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: FlameEnglishHouseWidget(
                            currentDay: plot.day,
                            streak: plot.day,
                            isPresident: plot.isPresident,
                            houseId: 'plot_${plot.plotNumber}',
                            showTestingControls: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Citizen Name & Day Badge
                    Text(
                      plot.userName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day ${plot.day} • ${plot.pocketScore} PS',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                    ),
                    const SizedBox(height: 14),

                    // Paved Asphalt Driveway connecting to Street
                    Container(
                      width: 50,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Color(0xFF334155),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostalDeedCard(CitizenPlot plot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 16)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: plot.isVip ? const Color(0xFFFFD700) : const Color(0xFF0284C7),
            child: Text(
              plot.userName.isNotEmpty ? plot.userName[0].toUpperCase() : 'C',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plot.userName,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '📬 ${plot.formalPostalAddress}',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            onPressed: () => setState(() => _inspectedPlot = null),
          ),
        ],
      ),
    );
  }
}

class _StreetLanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..strokeWidth = 3.0;

    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x + 18, 0), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
