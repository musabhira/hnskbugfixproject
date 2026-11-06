import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';

/// 🌌 The 4-Stage Pocket Cosmos Born Address Ceremony (ജനന സ്ഥലം)
/// Users discover their permanent birthplace in Pocket Cosmos, either through
/// destiny allocation ("God's Plan") or a 5-hour friend neighbor reservation code.
class PoketCosmosBornAddressPage extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final int? userAge;
  final String? initialInviteCode;

  const PoketCosmosBornAddressPage({
    super.key,
    required this.userName,
    this.userAvatar = '🦁',
    this.userAge,
    this.initialInviteCode,
  });

  static Future<void> launch(
    BuildContext context, {
    required String userName,
    String userAvatar = '🦁',
    int? userAge,
    String? initialInviteCode,
    String? inviteCode,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PoketCosmosBornAddressPage(
          userName: userName,
          userAvatar: userAvatar,
          userAge: userAge,
          initialInviteCode: initialInviteCode ?? inviteCode,
        ),
      ),
    );
  }

  @override
  State<PoketCosmosBornAddressPage> createState() => _PoketCosmosBornAddressPageState();
}

class _PoketCosmosBornAddressPageState extends State<PoketCosmosBornAddressPage>
    with TickerProviderStateMixin {
  // 4 Ceremony Stages:
  // 0 = Macro Island View (ഹൈ-ആൾട്ടിറ്റ്യൂഡ് ദ്വീപ് ദൃശ്യം)
  // 1 = Cinematic Zoom to Designated Plot (പ്ലോട്ടിലേക്ക് സൂം & ഗോൾഡൻ ബീക്കൺ)
  // 2 = 2D Ground-Level House Atmosphere (Day 1 Starter Cabin & അറ്റ്മോസ്ഫിയർ)
  // 3 = Official Digital Deed Certificate (ജനന സർട്ടിഫിക്കറ്റ് & PIN)
  int _currentStage = 0;

  bool _isLoading = true;
  late CitizenPlot _assignedPlot;
  late PoketCountryMap _assignedIsland;

  // Zoom and Pan Animation Controllers
  late AnimationController _cameraAnimController;
  late Animation<double> _zoomAnim;
  late Animation<Offset> _panAnim;

  // Beacon Pulse Animation
  late AnimationController _beaconController;
  late AnimationController _ambientBreatheController;

  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _cameraAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _ambientBreatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _initializeBirthplace();
  }

  @override
  void dispose() {
    _cameraAnimController.dispose();
    _beaconController.dispose();
    _ambientBreatheController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _initializeBirthplace({String? code}) async {
    setState(() => _isLoading = true);

    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (_) {}

    final inviteCode = code ?? widget.initialInviteCode;
    final plot = await PoketCosmosAllocationService.instance.allocateUserBirthplace(
      inviteCode: inviteCode,
      userName: widget.userName,
      avatar: widget.userAvatar,
    );

    // Build the country map representation for the aerial painter
    final island = PoketCountryMap(
      id: 301,
      name: plot.countryName,
      tag: 'Premier Habit Colony',
      landColor: const Color(0xFF16A34A),
      waterColor: const Color(0xFF0284C7),
      totalSlots: 35,
      filledSlots: 31,
      climate: 'Tropical Azure Breeze 🌊',
      climateIcon: Icons.water_drop_rounded,
      shapeSeed: plot.plotNumber * 13,
      shapeStyle: IslandShapeStyle.ringAtoll,
    );

    // Compute plot coordinates
    final coords = IslandAerialPainter.get35PlotCoordinates(island.shapeStyle);
    final targetPos = (plot.plotNumber >= 1 && plot.plotNumber <= coords.length)
        ? coords[plot.plotNumber - 1]
        : Offset.zero;

    final updatedPlot = plot.copyWith(coordinates: targetPos);

    // Setup Camera Zoom & Pan Interpolation
    _zoomAnim = Tween<double>(begin: 1.0, end: 4.8).animate(
      CurvedAnimation(parent: _cameraAnimController, curve: Curves.easeInOutCubic),
    );

    _panAnim = Tween<Offset>(begin: Offset.zero, end: -targetPos).animate(
      CurvedAnimation(parent: _cameraAnimController, curve: Curves.easeInOutCubic),
    );

    if (mounted) {
      setState(() {
        _assignedPlot = updatedPlot;
        _assignedIsland = island;
        _isLoading = false;
      });
    }
  }

  // Trigger Stage 1 -> Stage 2 (Cinematic Zoom into assigned plot)
  void _startCinematicZoomToParcel() {
    HapticFeedback.mediumImpact();
    setState(() => _currentStage = 1);
    _cameraAnimController.forward();
  }

  // Trigger Stage 2 -> Stage 3 (Tap on Parcel reveals 2D House Atmosphere)
  void _revealGroundAtmosphere() {
    HapticFeedback.heavyImpact();
    setState(() => _currentStage = 2);
  }

  // Trigger Stage 3 -> Stage 4 (View Official Born Deed Certificate)
  void _showDeedCertificate() {
    HapticFeedback.selectionClick();
    setState(() => _currentStage = 3);
  }

  // Final Action: Claim & Begin Day 1 Journey
  Future<void> _settleAndBeginJourney() async {
    HapticFeedback.heavyImpact();
    await PoketCosmosAllocationService.instance.saveBirthplace(_assignedPlot);

    if (!mounted) return;

    final age = widget.userAge ?? 20;
    if (age <= 8) {
      PocketPureKidsHomePage.launch(context);
    } else if (age <= 16) {
      PocketKidsHomePage.launch(context, promptProfileSetup: false);
    } else {
      context.goNamedAuth(HomePageWidget.routeName, context.mounted);
    }
  }

  // Dialog for entering a friend's neighbor reservation pass
  void _showInviteCodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
        ),
        title: Row(
          children: [
            const Text('🤝', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Neighbor Invite Code',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-character code your friend shared to be born right next to their house as neighbors!',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inviteCodeController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFDE047),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. PKT-74A9',
                hintStyle: GoogleFonts.outfit(color: Colors.white30, letterSpacing: 1),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              final code = _inviteCodeController.text.trim();
              Navigator.pop(ctx);
              if (code.isNotEmpty) {
                _initializeBirthplace(code: code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply Code'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF022B45),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: Color(0xFF38BDF8),
                  strokeWidth: 3.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seeking your destined birthplace in the Cosmos...',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF022B45),
      body: Stack(
        children: [
          // 🌌 1. The Interactive Aerial Map Viewport (Stages 0 & 1)
          if (_currentStage <= 1) _buildAerialViewport(),

          // 🏡 2. 2D Ground-Level House Atmosphere (Stage 2)
          if (_currentStage == 2) _buildGroundLevelAtmosphere(),

          // 📜 3. Official Digital Deed Certificate (Stage 3)
          if (_currentStage == 3) _buildDeedCertificateView(),

          // 🏷️ 4. Overhead Navigation Banner & Code Trigger (Stage 0 & 1)
          if (_currentStage <= 1) _buildTopHeaderBar(),

          // 🔘 5. Floating Bottom Stage Control Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🗺️ VIEWPORT 1: Island Aerial Viewport with Camera Zoom & Pan
  // =========================================================================
  Widget _buildAerialViewport() {
    return AnimatedBuilder(
      animation: _cameraAnimController,
      builder: (context, child) {
        final zoom = _cameraAnimController.isAnimating || _currentStage >= 1
            ? _zoomAnim.value
            : 1.0;
        final pan = _cameraAnimController.isAnimating || _currentStage >= 1
            ? _panAnim.value
            : Offset.zero;

        return Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scale: zoom,
                child: Transform.translate(
                  offset: pan,
                  child: CustomPaint(
                    painter: IslandAerialPainter(
                      island: _assignedIsland,
                      isInteractive: true,
                      selectedPlotNumber: _assignedPlot.plotNumber,
                      plots: [_assignedPlot],
                      animation: _ambientBreatheController,
                    ),
                  ),
                ),
              ),
            ),

            // Pulsing Golden Beacon on the Assigned Parcel Box
            if (_currentStage == 1)
              Center(
                child: GestureDetector(
                  onTap: _revealGroundAtmosphere,
                  child: AnimatedBuilder(
                    animation: _beaconController,
                    builder: (context, _) {
                      final pulse = _beaconController.value;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.45 * pulse),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  'YOUR DESTINED LAND: PLOT #${_assignedPlot.plotNumber}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFFFFD700),
                            size: 28 + 6 * pulse,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 🏡 VIEWPORT 2: 2D Ground-Level House Atmosphere (Attacking Profile Style)
  // =========================================================================
  Widget _buildGroundLevelAtmosphere() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF021B2F),
            Color(0xFF075985),
            Color(0xFF0284C7),
            Color(0xFF14532D),
          ],
          stops: [0.0, 0.45, 0.72, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cosmic Welcome Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_assignedPlot.userAvatar, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'DAY 1 • STARTER HOMESTEAD',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFEF08A),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // The Flame 2D Ground-Level House Component (Day 1 Starter Cabin)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    PocketAvatarHouseWidget(
                      day: 1,
                      width: 240,
                      height: 190,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Welcome to your personal cabin on ${_assignedPlot.streetName}!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'As you complete your daily learning habit, your cozy timber cabin will evolve into a majestic multi-storey manor and royal citadel palace.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Quick Location Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPillChip('🌍 ${_assignedPlot.planetName}'),
                  const SizedBox(width: 10),
                  _buildPillChip('🏝️ ${_assignedPlot.countryName}'),
                  const SizedBox(width: 10),
                  _buildPillChip('📍 Plot #${_assignedPlot.plotNumber}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 📜 VIEWPORT 3: Official Digital Deed & Born Certificate Card
  // =========================================================================
  Widget _buildDeedCertificateView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF022B45),
            Color(0xFF011422),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Deed Certificate Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Royal Header Seal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Text(
                            'POCKET COSMOS LAND REGISTRY',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('👑', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'OFFICIAL CITIZENSHIP DEED & BIRTHPLACE',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white60,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const Divider(color: Colors.white24, height: 28),

                      // User Identity
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
                        child: Text(_assignedPlot.userAvatar, style: const TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _assignedPlot.userName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Registered Sovereign Citizen #100${_assignedPlot.plotNumber}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Address Table
                      _buildDeedRow('🌍 Host Planet', _assignedPlot.planetName),
                      _buildDeedRow('🏝️ Island Territory', _assignedPlot.countryName),
                      _buildDeedRow('🛣️ Street Address', '${_assignedPlot.streetName}, Plot #${_assignedPlot.plotNumber}'),
                      _buildDeedRow('📮 Postal Pin Code', _assignedPlot.postalPinCode, isGold: true),

                      const SizedBox(height: 16),

                      // Exclusivity Guarantee
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Text('🛡️', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This plot belongs exclusively to you in the entire Pocket Cosmos universe. No other user can claim it.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 🏷️ HEADER: Top Glassmorphism Info & Code Trigger
  // =========================================================================
  Widget _buildTopHeaderBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 16)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _assignedPlot.planetName,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Colors.white38)),
                          const SizedBox(width: 8),
                          Text(
                            _assignedPlot.countryName,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentStage == 0
                            ? 'Destined birthplace assigned by the Cosmos'
                            : 'Camera focused on Plot #${_assignedPlot.plotNumber}',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Friend Invite Code Button
                GestureDetector(
                  onTap: _showInviteCodeDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔑', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          'Have Code?',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
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
        ],
      ),
    );
  }

  // =========================================================================
  // 🔘 BOTTOM ACTION BAR: Contextual Step Controls
  // =========================================================================
  Widget _buildBottomActionBar() {
    switch (_currentStage) {
      case 0:
        // Stage 0: Discover My Land (Triggers Camera Zoom)
        return ElevatedButton(
          onPressed: _startCinematicZoomToParcel,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                'Discover My Plot / സ്ഥലം കണ്ടെത്തുക',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 1:
        // Stage 1: Claim Land & Reveal House
        return ElevatedButton(
          onPressed: _revealGroundAtmosphere,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                'Claim Plot #${_assignedPlot.plotNumber} & Settle',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 2:
        // Stage 2: View Official Deed
        return ElevatedButton(
          onPressed: _showDeedCertificate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEAB308),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: const Color(0xFFEAB308).withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📜', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                'Issue Citizenship Deed Certificate',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 3:
      default:
        // Stage 3: Settle & Begin Day 1 Journey
        return ElevatedButton(
          onPressed: _settleAndBeginJourney,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚀', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                'Begin Day 1 Journey (പഠനം ആരംഭിക്കുക)',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildDeedRow(String label, String value, {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: isGold ? const Color(0xFFFFD700) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

