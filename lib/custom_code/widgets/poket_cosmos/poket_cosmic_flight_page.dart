import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_distance_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/flame_cosmic_rocket_flight_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_resident_island_view.dart';

/// 🚀 / ✈️ Full-Screen Cosmic & Atmospheric Flight Simulation Page
/// Provides dual-mode travel:
/// - Intra-Planetary (same planet): Aeroplane archipelago flight over island maps
/// - Interplanetary (different planets): Cosmic rocket launch, orbital ascent & deep space void
class PoketCosmicFlightPage extends StatefulWidget {
  final CosmosFlightManifest manifest;
  final String targetUserId;
  final String targetName;
  final Map<String, dynamic>? preloadedProfile;
  final PocketNeighbor? neighbor;
  final bool isRobot;
  final Map<String, dynamic>? robotData;
  final String? destinationPlanetCode;
  final int? destinationPlotNumber;
  final int? destinationWave;

  const PoketCosmicFlightPage({
    super.key,
    required this.manifest,
    required this.targetUserId,
    required this.targetName,
    this.preloadedProfile,
    this.neighbor,
    this.isRobot = false,
    this.robotData,
    this.destinationPlanetCode,
    this.destinationPlotNumber,
    this.destinationWave,
  });

  @override
  State<PoketCosmicFlightPage> createState() => _PoketCosmicFlightPageState();
}

class _PoketCosmicFlightPageState extends State<PoketCosmicFlightPage>
    with SingleTickerProviderStateMixin {
  late FlameCosmicRocketFlightGame _game;
  double _currentTraversedKm = 0.0;
  double _flightProgress = 0.0;
  bool _hasArrived = false;
  bool _isBoosting = false;
  bool _isPaused = false;
  double _baseScale = 1.0;

  late AnimationController _pulseController;

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPaused = !_isPaused;
      _game.isPaused = _isPaused;
    });
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    setState(() {
      _game.zoomIn();
    });
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    setState(() {
      _game.zoomOut();
    });
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    setState(() {
      _game.resetZoom();
    });
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _game = FlameCosmicRocketFlightGame(
      manifest: widget.manifest,
      onDistanceProgress: (km, progress) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentTraversedKm = km;
              _flightProgress = progress;
            });
          }
        });
      },
      onArrival: _handleArrival,
    );
  }

  void _handleArrival() {
    if (_hasArrived) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasArrived) {
        HapticFeedback.mediumImpact();
        PocketGameAudioService.instance.playVictorySfx();
        setState(() {
          _hasArrived = true;
        });
      }
    });
  }

  void _triggerBoost() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();
    _game.applyThrustBoost();
    setState(() {
      _isBoosting = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isBoosting = false;
        });
      }
    });
  }

  void _startContinuousThrust() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();
    _game.startContinuousThrust();
    setState(() => _isBoosting = true);
  }

  void _stopContinuousThrust() {
    _game.stopContinuousThrust();
    if (mounted) {
      setState(() => _isBoosting = false);
    }
  }

  void _skipFlight() {
    HapticFeedback.selectionClick();
    _handleArrival();
    _proceedToCitadel();
  }

  void _proceedToCitadel() {
    Navigator.of(context).pop(); // Dismiss flight simulation

    if (widget.destinationPlotNumber != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoketCosmosResidentIslandView(
            targetPlanetCode: widget.destinationPlanetCode ?? widget.manifest.destinationCode,
            targetPlotNumber: widget.destinationPlotNumber,
            targetWave: widget.destinationWave,
          ),
        ),
      );
      return;
    }

    if (widget.neighbor != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: widget.neighbor!,
            attackerDay: 1,
          ),
        ),
      );
      return;
    }

    PocketCitadelAttackPage.openForUser(
      context,
      userId: widget.targetUserId,
      targetName: widget.targetName,
      preloadedProfile: widget.preloadedProfile,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    final formattedTraversed =
        PoketCosmosDistanceService.instance.formatKilometers(_currentTraversedKm);
    final totalDist = widget.manifest.formattedDistance;

    final isSamePlanet = widget.manifest.isSamePlanet;

    final intermediateSlingshot =
        !isSamePlanet &&
        widget.manifest.intermediatePlanetCodes.isNotEmpty &&
        _flightProgress >= 0.35 &&
        _flightProgress <= 0.65;

    return Scaffold(
      backgroundColor: isSamePlanet ? const Color(0xFF0369A1) : const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Full-Screen Interactive Flame Game Viewport (Tap/Hold anywhere boosts thrust; pinch-to-zoom)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _triggerBoost,
              onLongPressStart: (_) => _startContinuousThrust(),
              onLongPressEnd: (_) => _stopContinuousThrust(),
              onLongPressCancel: _stopContinuousThrust,
              onScaleStart: (details) {
                _baseScale = _game.zoomLevel;
              },
              onScaleUpdate: (details) {
                if (details.pointerCount > 1) {
                  setState(() {
                    _game.setZoom(_baseScale * details.scale);
                  });
                }
              },
              child: GameWidget(game: _game),
            ),
          ),

          // 2. Flight Navigation Header HUD
          Positioned(
            top: topPadding + 10,
            left: 14,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Action Bar
                Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Origin -> Destination Minimal Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSamePlanet
                                ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
                                : const Color(0xFF818CF8).withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isSamePlanet
                                  ? '🏝️ ${widget.manifest.originName}'
                                  : '${PoketCosmosDistanceService.instance.getPlanetEmoji(widget.manifest.originCode)} ${widget.manifest.originName}',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                isSamePlanet ? '✈️' : '➔',
                                style: TextStyle(
                                  color: isSamePlanet ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                isSamePlanet
                                    ? '🏝️ ${widget.manifest.destinationName}'
                                    : '${PoketCosmosDistanceService.instance.getPlanetEmoji(widget.manifest.destinationCode)} ${widget.manifest.destinationName}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pause / Resume Toggle Button
                    GestureDetector(
                      onTap: _togglePause,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                        decoration: BoxDecoration(
                          color: _isPaused
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPaused ? const Color(0xFFF59E0B) : Colors.white24,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              color: _isPaused ? const Color(0xFFFFD700) : Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isPaused ? 'RESUME' : 'PAUSE',
                              style: GoogleFonts.outfit(
                                color: _isPaused ? const Color(0xFFFFD700) : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Skip Button
                    GestureDetector(
                      onTap: _skipFlight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Distance Progress Tracker Strip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B132B).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Text(isSamePlanet ? '🛬' : '📍', style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '$formattedTraversed / $totalDist',
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isBoosting
                                ? (isSamePlanet ? '⚡ JET BOOST' : '🔥 WARP')
                                : '${((1.0 - _flightProgress) * 100).toInt()}% left',
                            style: GoogleFonts.outfit(
                              color: _isBoosting ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _flightProgress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isBoosting ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Zoom Controls Floating Dock on Right Edge
          Positioned(
            top: topPadding + 115,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom In (+)
                  GestureDetector(
                    onTap: _zoomIn,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Current Zoom Level Indicator / Reset
                  GestureDetector(
                    onTap: _resetZoom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Text(
                        '${(_game.zoomLevel * 100).toInt()}%',
                        style: GoogleFonts.orbitron(
                          color: const Color(0xFF38BDF8),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Zoom Out (-)
                  GestureDetector(
                    onTap: _zoomOut,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Slingshot Assist Dynamic Alert Banner (Interplanetary)
          if (intermediateSlingshot)
            Positioned(
              top: topPadding + 115,
              left: 24,
              right: 68,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA78BFA), width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cyclone_rounded, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'GRAVITATIONAL ASSIST (+250% SPEED)',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Centered Pause Notification Banner
          if (_isPaused)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFFFD700), size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'FLIGHT PAUSED',
                      style: GoogleFonts.orbitron(
                        color: const Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'യാത്ര താൽക്കാലികമായി നിർത്തിയിരിക്കുന്നു',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                      label: Text(
                        'RESUME FLIGHT / തുടരുക',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 6. Bottom Controls: Target Label & Right Floating Launch/Boost Button
          if (!_hasArrived) ...[
            // Target Citizen Pill on Bottom-Left
            Positioned(
              bottom: bottomPadding + 22,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSamePlanet ? Icons.location_city_rounded : Icons.person_pin_circle_rounded,
                      color: const Color(0xFF38BDF8),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.targetName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Launch / Boost FAB on Bottom-Right
            Positioned(
              bottom: bottomPadding + 16,
              right: 18,
              child: GestureDetector(
                onTap: _triggerBoost,
                onLongPressStart: (_) => _startContinuousThrust(),
                onLongPressEnd: (_) => _stopContinuousThrust(),
                onLongPressCancel: _stopContinuousThrust,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isBoosting
                            ? [const Color(0xFFFF9100), const Color(0xFFFFD700)]
                            : (isSamePlanet
                                ? [const Color(0xFF0284C7), const Color(0xFF38BDF8)]
                                : [const Color(0xFF00E5FF), const Color(0xFF2563EB)]),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isBoosting ? const Color(0xFFFF9100) : const Color(0xFF00E5FF))
                              .withValues(alpha: 0.55),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2.2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isBoosting
                              ? Icons.local_fire_department_rounded
                              : (isSamePlanet
                                  ? Icons.airplanemode_active_rounded
                                  : Icons.rocket_launch_rounded),
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _isBoosting
                              ? (isSamePlanet ? 'AFTERBURN' : 'WARP')
                              : (isSamePlanet ? 'JET' : 'BOOST'),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 7. Arrival Celebration Modal (Dual-mode adaptive)
          if (_hasArrived)
            Positioned(
              bottom: bottomPadding + 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.22),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSamePlanet
                                ? '🏝️'
                                : PoketCosmosDistanceService.instance.getPlanetEmoji(widget.manifest.destinationCode),
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isSamePlanet
                                  ? 'TOUCHDOWN AT ${widget.manifest.destinationName.toUpperCase()} ISLAND 🛬'
                                  : 'ARRIVED AT ${widget.manifest.destinationName.toUpperCase()} 🪐',
                              style: GoogleFonts.orbitron(
                                color: const Color(0xFFFFD700),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSamePlanet
                            ? 'Traversed ${widget.manifest.formattedDistance} across atmospheric airways to ${widget.targetName}\'s island residence.'
                            : 'Traversed ${widget.manifest.formattedDistance} to ${widget.targetName}\'s planetary dwelling.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _proceedToCitadel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            elevation: 6,
                            shadowColor: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSamePlanet
                                    ? Icons.flight_land_rounded
                                    : (widget.destinationPlotNumber != null
                                        ? Icons.location_on_rounded
                                        : Icons.fort_rounded),
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isSamePlanet
                                    ? 'VISIT LANDING 🛬 / വിസിറ്റ് ലാൻഡിംഗ്'
                                    : (widget.destinationPlotNumber != null
                                        ? 'LAND AT PLOT #${widget.destinationPlotNumber} ➔'
                                        : 'VISIT HOUSE / CITADEL ➔'),
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
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
            ),
        ],
      ),
    );
  }
}
