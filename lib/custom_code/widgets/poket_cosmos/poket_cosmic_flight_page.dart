import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_distance_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/flame_cosmic_rocket_flight_game.dart';

/// 🚀 Full-Screen Cosmic Rocket Flight Simulation Page
/// Provides interactive space travel from viewer's planet to searched user's planet.
class PoketCosmicFlightPage extends StatefulWidget {
  final CosmosFlightManifest manifest;
  final String targetUserId;
  final String targetName;
  final Map<String, dynamic>? preloadedProfile;
  final PocketNeighbor? neighbor;
  final bool isRobot;
  final Map<String, dynamic>? robotData;

  const PoketCosmicFlightPage({
    super.key,
    required this.manifest,
    required this.targetUserId,
    required this.targetName,
    this.preloadedProfile,
    this.neighbor,
    this.isRobot = false,
    this.robotData,
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

  late AnimationController _pulseController;

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
        if (mounted) {
          setState(() {
            _currentTraversedKm = km;
            _flightProgress = progress;
          });
        }
      },
      onArrival: _handleArrival,
    );
  }

  void _handleArrival() {
    if (_hasArrived) return;
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playVictorySfx();
    if (mounted) {
      setState(() {
        _hasArrived = true;
      });
    }
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

  void _skipFlight() {
    HapticFeedback.selectionClick();
    _handleArrival();
    _proceedToCitadel();
  }

  void _proceedToCitadel() {
    Navigator.of(context).pop(); // Dismiss flight simulation

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

    // Default open for user or robot
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

    final intermediateSlingshot =
        widget.manifest.intermediatePlanetCodes.isNotEmpty &&
        _flightProgress >= 0.35 &&
        _flightProgress <= 0.65;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Full-Screen Interactive Flame Game Viewport
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // 2. Top HUD Controls & Odometer
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Navigation bar: Back/Skip and Sound Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip / Cancel button
                    GestureDetector(
                      onTap: _skipFlight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fast_forward_rounded, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'SKIP ➔',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Destination indicator pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B).withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.4), width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            PoketCosmosDistanceService.instance.getPlanetEmoji(widget.manifest.destinationCode),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TARGET: ${widget.manifest.destinationName.toUpperCase()}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFC7D2FE),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sound Toggle Pill
                    const PocketSoundToggleWidget(compact: true),
                  ],
                ),

                const SizedBox(height: 14),

                // Live Astronomical Odometer Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A).withValues(alpha: 0.85),
                        const Color(0xFF1E1B4B).withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.explore_rounded, color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'ASTRONOMICAL DISTANCE',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _isBoosting ? 'WARP 4.8 • HYPERTHRUST' : 'CRUISE VELOCITY • 0.15c',
                            style: GoogleFonts.outfit(
                              color: _isBoosting ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formattedTraversed,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '/ $totalDist',
                            style: GoogleFonts.orbitron(
                              color: const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _flightProgress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isBoosting ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Slingshot Assist Dynamic Alert Banner
          if (intermediateSlingshot)
            Positioned(
              top: topPadding + 140,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA78BFA), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cyclone_rounded, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'GRAVITATIONAL SLINGSHOT INITIATED (+250% VELOCITY)',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
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

          // 4. Bottom Controls: Boost Button & Citizen Target Info
          if (!_hasArrived)
            Positioned(
              bottom: bottomPadding + 24,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Glowing Boost Button
                  GestureDetector(
                    onTap: _triggerBoost,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController),
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isBoosting
                                ? [const Color(0xFFFF9100), const Color(0xFFFFD700)]
                                : [const Color(0xFF00E5FF), const Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isBoosting ? const Color(0xFFFF9100) : const Color(0xFF00E5FF))
                                  .withValues(alpha: 0.55),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isBoosting ? Icons.local_fire_department_rounded : Icons.flash_on_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'BOOST',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Destination Citizen Card Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'En route to ${widget.targetName}\'s Citadel',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 5. Orbital Arrival Celebration Modal
          if (_hasArrived)
            Positioned(
              bottom: bottomPadding + 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            PoketCosmosDistanceService.instance.getPlanetEmoji(widget.manifest.destinationCode),
                            style: const TextStyle(fontSize: 26),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'ARRIVED AT ${widget.manifest.destinationName.toUpperCase()} CITADEL!',
                              style: GoogleFonts.orbitron(
                                color: const Color(0xFFFFD700),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Successfully traversed ${widget.manifest.formattedDistance} through deep space to reach ${widget.targetName}\'s planetary outpost.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      // Primary Navigation Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _proceedToCitadel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            elevation: 8,
                            shadowColor: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fort_rounded, color: Colors.black, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'ENTER CITADEL / VIEW PROFILE ➔',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
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
