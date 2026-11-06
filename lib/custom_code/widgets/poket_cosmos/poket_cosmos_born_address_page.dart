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
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/planet_sphere_icon_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';

/// 🌌 The 4-Stage Pocket Cosmos Born Address Ceremony (ജനന സ്ഥലം)
///
/// Flow:
/// 1. STAGE 0: THIS IS YOUR PLANET (ഫുൾ സ്ക്രീൻ പ്ലാനറ്റ് - Jupiter, Saturn, Earth)
///    - Referral / Island code check (കൂട്ടുകാരന്റെ ഐലൻഡ് കോഡ് ഉണ്ടോ?)
///    - If friend's referral code entered (e.g. User A on Jupiter), switches to User A's planet and adjacent plot!
///    - If no code, automatically assigns planet.
/// 2. STAGE 1: THIS IS YOUR ISLAND (ഫുൾ സ്ക്രീൻ ഐലൻഡ് - Aerial view of 35 plots)
/// 3. STAGE 2: THIS IS YOUR PLOT (ദ്വീപിലെ സ്ഥലം - സൂം ഇൻ & പച്ച ടാപ്പ് ബട്ടൺ)
/// 4. STAGE 3: YOUR HOME & ATMOSPHERE (ഫുൾ സ്ക്രീൻ അമോസ്ഫിയറും വീടും & ഹോം അഡ്രസ്സ്)
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
  State<PoketCosmosBornAddressPage> createState() =>
      _PoketCosmosBornAddressPageState();
}

class _PoketCosmosBornAddressPageState extends State<PoketCosmosBornAddressPage>
    with TickerProviderStateMixin {
  // 4 Ceremony Stages:
  // 0 = THIS IS YOUR PLANET (ഫുൾ സ്ക്രീൻ പ്ലാനറ്റ്)
  // 1 = THIS IS YOUR ISLAND (ഫുൾ സ്ക്രീൻ ഐലൻഡ്)
  // 2 = THIS IS YOUR PLOT (ദ്വീപിലെ സ്ഥലം - സൂം ഇൻ & പച്ച ടാപ്പ് ബട്ടൺ)
  // 3 = YOUR HOME & ATMOSPHERE (ഫുൾ സ്ക്രീൻ അമോസ്ഫിയറും വീടും & ഹോം അഡ്രസ്)
  int _currentStage = 0;

  bool _isLoading = true;
  late CitizenPlot _assignedPlot;
  late PoketCountryMap _assignedIsland;
  String? _activeReferralCode;
  String? _referralFeedback;

  // Zoom and Pan Animation Controllers
  late AnimationController _cameraAnimController;
  late Animation<double> _zoomAnim;
  late Animation<Offset> _panAnim;

  // Beacon Pulse Animation & Cosmic Breathe
  late AnimationController _beaconController;
  late AnimationController _ambientBreatheController;
  late AnimationController _planetSpinController;

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

    _planetSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _initializeBirthplace();
  }

  @override
  void dispose() {
    _cameraAnimController.dispose();
    _beaconController.dispose();
    _ambientBreatheController.dispose();
    _planetSpinController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _initializeBirthplace({String? code}) async {
    setState(() => _isLoading = true);

    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (_) {}

    final inviteCode = code ?? widget.initialInviteCode;
    _activeReferralCode = inviteCode;

    final plot =
        await PoketCosmosAllocationService.instance.allocateUserBirthplace(
      inviteCode: inviteCode,
      userName: widget.userName,
      avatar: widget.userAvatar,
    );

    // Build the country map representation for the aerial painter
    final isJupiter = plot.planetName.toLowerCase().contains('jup');
    final island = PoketCountryMap(
      id: isJupiter ? 401 : 301,
      name: plot.countryName,
      tag: isJupiter ? 'Jupiter Living Colony' : 'Premier Habit Colony',
      landColor: isJupiter ? const Color(0xFF059669) : const Color(0xFF16A34A),
      waterColor: isJupiter ? const Color(0xFF0369A1) : const Color(0xFF0284C7),
      totalSlots: 35,
      filledSlots: 31,
      climate: isJupiter
          ? 'Stormy Cosmic Azure 🪐'
          : 'Tropical Azure Breeze 🌊',
      climateIcon: Icons.water_drop_rounded,
      shapeSeed: plot.plotNumber * 13,
      shapeStyle: isJupiter ? IslandShapeStyle.crescentLagoon : IslandShapeStyle.ringAtoll,
    );

    // Compute plot coordinates
    final coords = IslandAerialPainter.get35PlotCoordinates(island.shapeStyle);
    final targetPos = (plot.plotNumber >= 1 && plot.plotNumber <= coords.length)
        ? coords[plot.plotNumber - 1]
        : Offset.zero;

    final updatedPlot = plot.copyWith(coordinates: targetPos);

    // Setup Camera Zoom & Pan Interpolation
    _zoomAnim = Tween<double>(begin: 1.0, end: 4.8).animate(
      CurvedAnimation(
          parent: _cameraAnimController, curve: Curves.easeInOutCubic),
    );

    _panAnim = Tween<Offset>(begin: Offset.zero, end: -targetPos).animate(
      CurvedAnimation(
          parent: _cameraAnimController, curve: Curves.easeInOutCubic),
    );

    if (mounted) {
      setState(() {
        _assignedPlot = updatedPlot;
        _assignedIsland = island;
        _isLoading = false;
        if (inviteCode != null && inviteCode.isNotEmpty) {
          _referralFeedback = '🤝 Friend pass applied! Reserving adjacent plot on ${_assignedPlot.planetName}!';
        }
      });
    }
  }

  // Trigger Stage 0 -> Stage 1 (Planet -> Full Island View)
  void _goToIslandOverview() {
    HapticFeedback.mediumImpact();
    setState(() => _currentStage = 1);
  }

  // Trigger Stage 1 -> Stage 2 (Island -> Cinematic Zoom into designated plot)
  void _startCinematicZoomToPlot() {
    HapticFeedback.mediumImpact();
    setState(() => _currentStage = 2);
    _cameraAnimController.forward(from: 0.0);
  }

  // Trigger Stage 2 -> Stage 3 (Green Tap on Plot -> Reveal Fullscreen Attacking House Atmosphere)
  void _revealGroundAtmosphere() {
    HapticFeedback.heavyImpact();
    try {
      PocketGameAudioService.instance.playVictorySfx();
    } catch (_) {}
    setState(() => _currentStage = 3);
  }

  // Final Action: Claim & Begin Day 1 Journey
  Future<void> _settleAndBeginJourney() async {
    HapticFeedback.heavyImpact();
    await PoketCosmosAllocationService.instance.saveBirthplace(_assignedPlot);

    if (!mounted) return;

    final age = widget.userAge ?? 20;
    if (age <= 9) {
      PocketPureKidsHomePage.launch(context);
    } else {
      context.goNamedAuth(HomePageWidget.routeName, context.mounted);
    }
  }

  // Dialog for entering a friend's neighbor / referral code
  void _showInviteCodeDialog() {
    _inviteCodeController.text = _activeReferralCode ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🤝', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Island / Referral Code',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'കൂട്ടുകാരന്റെ ഐലൻഡ് കോഡോ റെഫറൽ കോഡോ നൽകിയാൽ അവരുടെ വീടിനടുത്തുള്ള പ്ലോട്ടിലേക്ക് നിങ്ങളുടെ ഗ്രഹം ഓട്ടോമാറ്റിക്കായി സ്വിച്ച് ചെയ്യപ്പെടും!',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70, fontSize: 13, height: 1.4),
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
                hintText: 'e.g. PKT-JUPITER',
                hintStyle:
                    GoogleFonts.outfit(color: Colors.white30, letterSpacing: 1),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF38BDF8), width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Try PKT-JUPITER 🪐',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFDE047))),
                  backgroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  onPressed: () {
                    _inviteCodeController.text = 'PKT-JUPITER';
                  },
                ),
                ActionChip(
                  label: const Text('Try PKT-TEST 🌍',
                      style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                  backgroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  onPressed: () {
                    _inviteCodeController.text = 'PKT-TEST';
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.outfit(color: Colors.white60)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply Code'),
          ),
        ],
      ),
    );
  }

  Color _getPlanetPrimaryColor(String planetName) {
    final p = planetName.toLowerCase();
    if (p.contains('jup')) return const Color(0xFFD97706);
    if (p.contains('sat')) return const Color(0xFFEAB308);
    if (p.contains('mars')) return const Color(0xFFDC2626);
    return const Color(0xFF0284C7);
  }

  Color _getPlanetGlowColor(String planetName) {
    final p = planetName.toLowerCase();
    if (p.contains('jup')) return const Color(0xFFFDE047);
    if (p.contains('sat')) return const Color(0xFFFEF08A);
    if (p.contains('mars')) return const Color(0xFFFCA5A5);
    return const Color(0xFF38BDF8);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF050B14),
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
                'Seeking your destined planet & birthplace in Cosmos...',
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
      backgroundColor: const Color(0xFF050B14),
      body: Stack(
        children: [
          // 🪐 STAGE 0: Fullscreen Planet Presentation
          if (_currentStage == 0) _buildPlanetStageView(),

          // 🏝️ STAGE 1 & 2: Island Aerial Viewport (Overview or Zoomed to Plot)
          if (_currentStage == 1 || _currentStage == 2) _buildAerialViewport(),

          // 🏡 STAGE 3: Fullscreen Attacking Profile Atmosphere (House + Address)
          if (_currentStage == 3) _buildGroundLevelAtmosphere(),

          // 🏷️ Overhead Header Bar
          _buildTopHeaderBar(),

          // 🔘 Floating Bottom Action Bar (Stages 0, 1, 3)
          if (_currentStage != 2)
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
  // 🪐 STAGE 0: THIS IS YOUR PLANET (ഫുൾ സ്ക്രീൻ പ്ലാനറ്റ്)
  // =========================================================================
  Widget _buildPlanetStageView() {
    final planetName = _assignedPlot.planetName;
    final primaryColor = _getPlanetPrimaryColor(planetName);
    final glowColor = _getPlanetGlowColor(planetName);

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF050B14),
            Color(0xFF020617),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 70),

            // Top Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withValues(alpha: 0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'POKET COSMOS DESTINY',
                    style: GoogleFonts.outfit(
                      color: glowColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Title: THIS IS YOUR PLANET
            Text(
              'THIS IS YOUR PLANET',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              planetName.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: glowColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),

            if (_referralFeedback != null) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  _referralFeedback!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFA7F3D0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Grand Floating Planet Sphere
            AnimatedBuilder(
              animation: _ambientBreatheController,
              builder: (context, child) {
                final breathe = math.sin(_ambientBreatheController.value * 2 * math.pi) * 8;
                return Transform.translate(
                  offset: Offset(0, breathe),
                  child: Center(
                    child: PlanetSphereIconWidget(
                      name: planetName.toLowerCase(),
                      primaryColor: primaryColor,
                      glowColor: glowColor,
                      size: 260.0,
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Planet Description Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                'A magnificent celestial realm hosting 35-plot sovereign islands floating above cosmic atmospheric currents. Your journey begins here!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🗺️ STAGE 1 & 2: Island Aerial Viewport (Overview or Zoomed to Plot)
  // =========================================================================
  Widget _buildAerialViewport() {
    return AnimatedBuilder(
      animation: _cameraAnimController,
      builder: (context, child) {
        final zoom = _currentStage == 2 ? _zoomAnim.value : 1.0;
        final pan = _currentStage == 2 ? _panAnim.value : Offset.zero;

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

            // Pulsing Neon-Green "TAP HERE" on the plot in Stage 2
            if (_currentStage == 2)
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF052E16).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF22C55E), width: 2.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.50 * pulse + 0.3),
                                  blurRadius: 22,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🟢', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'TAP HERE TO CLAIM PLOT #${_assignedPlot.plotNumber} 🎯',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF86EFAC),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            Icons.touch_app_rounded,
                            color: const Color(0xFF22C55E),
                            size: 32 + 6 * pulse,
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
  // 🏡 STAGE 3: Fullscreen Attacking Profile Atmosphere (House + Address)
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
          stops: [0.0, 0.40, 0.70, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 55),

              // Title: THIS IS YOUR HOME & ADDRESS
              Text(
                'THIS IS YOUR HOME & ADDRESS',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'പോക്കറ്റ് വേൾഡിലെ നിങ്ങളുടെ ജനന സ്ഥലം',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFFEF08A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Fullscreen Attacking Profile House Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar & Level Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(_assignedPlot.userAvatar,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              _assignedPlot.userName.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF10B981), width: 1.2),
                          ),
                          child: Text(
                            '🌱 DAY 1 STARTER HOME',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF86EFAC),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Level 1 Flame Architectural Starter House
                    PocketAvatarHouseWidget(
                      day: 1,
                      width: 230,
                      height: 175,
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Cozy Day 1 Homestead on ${_assignedPlot.streetName}',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 📮 Official Unique Born Address Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'OFFICIAL POKET COSMOS ADDRESS',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),

                    _buildAddressRow('👤 Citizen Name', _assignedPlot.userName),
                    const SizedBox(height: 8),
                    _buildAddressRow('📍 Plot & Street',
                        'Plot #${_assignedPlot.plotNumber}, ${_assignedPlot.streetName}'),
                    const SizedBox(height: 8),
                    _buildAddressRow('🏝️ Island Name', _assignedPlot.countryName),
                    const SizedBox(height: 8),
                    _buildAddressRow('🪐 Planet', _assignedPlot.planetName),
                    const SizedBox(height: 8),
                    _buildAddressRow('📮 Postal Pin', _assignedPlot.postalPinCode),

                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '🔒 100% Unique to this Plot • Permanent Birthplace',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFA7F3D0),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white54,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🏷️ Top Header Navigation Bar
  // =========================================================================
  Widget _buildTopHeaderBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Back button if past Stage 0
          if (_currentStage > 0)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _currentStage--);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            )
          else
            const SizedBox(width: 36),

          const Spacer(),

          // Referral Code Chip
          GestureDetector(
            onTap: _showInviteCodeDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _activeReferralCode != null
                      ? const Color(0xFF10B981)
                      : const Color(0xFF38BDF8),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _activeReferralCode != null ? '🤝 Code Applied' : '🎟️ Referral Code?',
                    style: GoogleFonts.outfit(
                      color: _activeReferralCode != null
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
  // 🔘 Floating Bottom Action Bar
  // =========================================================================
  Widget _buildBottomActionBar() {
    String buttonText = 'NEXT ➔';
    VoidCallback? onTap;

    if (_currentStage == 0) {
      buttonText = 'NEXT: EXPLORE ISLAND ➔';
      onTap = _goToIslandOverview;
    } else if (_currentStage == 1) {
      buttonText = 'NEXT: ZOOM TO YOUR PLOT ➔';
      onTap = _startCinematicZoomToPlot;
    } else if (_currentStage == 3) {
      buttonText = 'START JOURNEY 🚀 (ഹോം പേജിലേക്ക്)';
      onTap = _settleAndBeginJourney;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x660284C7),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
