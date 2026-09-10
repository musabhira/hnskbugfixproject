import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'flame_english_house_game.dart';
import 'pocket_citadel_attack_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_world_street_page.dart';

/// 🌍 Pocket Open World: 2D Side-Scrolling Rolling-Hills Adventure
/// Powered by Flame Engine (`FlameGame`)
///
/// Features:
/// 1. Curving rolling-hills terrain with gentle slopes, plateaus, and valleys
/// 2. Authentic 2D front-facing English Houses placed along hillsides
/// 3. Level-grouped neighborhoods: Rookie Village, Intermediate Town, Scholar Heights, Apex Peaks
/// 4. Avatar running & jumping along the street in front of houses
/// 5. Smooth Camera Zoom (1.0x close-up, 0.6x street, 0.32x panoramic world view + pinch-to-zoom)
/// 6. Walk-up Proximity Citadel Raids into Pocket Battle
class PocketOpenWorldGamePage extends StatefulWidget {
  final int currentDay;
  final int streak;

  const PocketOpenWorldGamePage({
    super.key,
    required this.currentDay,
    required this.streak,
  });

  @override
  State<PocketOpenWorldGamePage> createState() => _PocketOpenWorldGamePageState();
}

class _PocketOpenWorldGamePageState extends State<PocketOpenWorldGamePage> {
  late PocketOpenWorldGame _game;
  bool _isLoadingNeighbors = true;
  PocketNeighbor? _proximityNeighbor;

  // Zoom control
  double _currentZoom = 0.85;

  // Touch joystick / move state
  Offset? _joystickBase;
  Offset? _joystickThumb;
  double _joystickDeltaX = 0.0;
  bool _isSprinting = false;

  @override
  void initState() {
    super.initState();
    _initGame();
    _loadNeighbors();
  }

  void _initGame() {
    _game = PocketOpenWorldGame(
      playerDay: widget.currentDay,
      playerStreak: widget.streak,
      initialZoom: _currentZoom,
      onProximityChanged: (neighbor) {
        if (mounted && _proximityNeighbor != neighbor) {
          setState(() {
            _proximityNeighbor = neighbor;
          });
          if (neighbor != null) {
            HapticFeedback.lightImpact();
          }
        }
      },
    );
  }

  Future<void> _loadNeighbors() async {
    try {
      final dynamicTargets = PocketFortressDefenseService.generateDynamicTargetBracketHomes(
        widget.currentDay,
        count: 14,
      );
      final supaNeighbors = await PocketFortressDefenseService.fetchSupabaseNeighbors(limit: 25);
      final combined = [...dynamicTargets, ...supaNeighbors];

      if (mounted) {
        setState(() {
          _isLoadingNeighbors = false;
        });
        _game.setNeighbors(combined);
      }
    } catch (e) {
      debugPrint('OpenWorld load error: $e');
      if (mounted) {
        final fallback = PocketFortressDefenseService.generateDynamicTargetBracketHomes(
          widget.currentDay,
          count: 16,
        );
        setState(() {
          _isLoadingNeighbors = false;
        });
        _game.setNeighbors(fallback);
      }
    }
  }

  void _triggerJump() {
    HapticFeedback.mediumImpact();
    _game.playerJump();
  }

  void _setZoom(double zoom) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentZoom = zoom.clamp(0.3, 1.2);
    });
    _game.setZoom(_currentZoom);
  }

  void _launchRaid(PocketNeighbor neighbor) {
    HapticFeedback.heavyImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketCitadelAttackPage(
          neighbor: neighbor,
          attackerDay: widget.currentDay,
          attackerStreak: widget.streak,
        ),
      ),
    ).then((won) {
      if (won == true) {
        _loadNeighbors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: GestureDetector(
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            final newZoom = (_currentZoom * details.scale).clamp(0.3, 1.2);
            _setZoom(newZoom);
          }
        },
        child: Stack(
          children: [
            // 1. Full-Screen Flame Canvas
            GameWidget(game: _game),

            // 2. Top Navigation & District Status Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Back / Return Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24, width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              'Exit',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // District Location Badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⛰️', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: ValueListenableBuilder<String>(
                                valueListenable: _game.districtNotifier,
                                builder: (context, district, _) {
                                  return Text(
                                    district,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFFC00),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                            if (_isLoadingNeighbors) ...[
                              const SizedBox(width: 6),
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFFFFC00),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Street View Mode Switcher
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.view_carousel_rounded, color: Colors.black, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              'Street View',
                              style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Quick Zoom Bar (Right Edge)
            Positioned(
              top: 75,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4), width: 1.2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00F0FF).withValues(alpha: 0.15), blurRadius: 8),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In (1.0x)
                    _buildZoomButton(
                      label: '🔍 1.0x',
                      isSelected: _currentZoom >= 0.95,
                      onTap: () => _setZoom(1.0),
                    ),
                    const SizedBox(height: 6),
                    // Street View (0.65x)
                    _buildZoomButton(
                      label: '🏡 0.6x',
                      isSelected: _currentZoom >= 0.55 && _currentZoom < 0.95,
                      onTap: () => _setZoom(0.65),
                    ),
                    const SizedBox(height: 6),
                    // World Panorama (0.35x)
                    _buildZoomButton(
                      label: '🌍 World',
                      isSelected: _currentZoom < 0.55,
                      onTap: () => _setZoom(0.35),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Proximity Action Card (Appears when near a Citadel Gate)
            if (_proximityNeighbor != null)
              Positioned(
                bottom: 120,
                left: 16,
                right: 16,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  offset: Offset.zero,
                  curve: Curves.easeOutCubic,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Neighbor Avatar
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: VectorAvatarWidget(
                            config: VectorAvatarConfig.getEvolutionAvatarForStage(_proximityNeighbor!.day),
                            size: 48,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _proximityNeighbor!.name,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Lvl ${_proximityNeighbor!.day}',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFFC00),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'HP: ${_proximityNeighbor!.hp}/100',
                                    style: GoogleFonts.outfit(
                                      color: _proximityNeighbor!.hp > 30 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_proximityNeighbor!.isDamaged) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '• Breached 💥',
                                      style: GoogleFonts.outfit(color: const Color(0xFFF59E0B), fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Raid Button
                        GestureDetector(
                          onTap: () => _launchRaid(_proximityNeighbor!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF2A55), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF2A55).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⚔️', style: TextStyle(fontSize: 15)),
                                const SizedBox(width: 5),
                                Text(
                                  'RAID',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
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

            // 5. Left/Right Horizontal Running Controller (Bottom Left)
            Positioned(
              bottom: 24,
              left: 20,
              child: Listener(
                onPointerDown: (details) {
                  setState(() {
                    _joystickBase = details.localPosition;
                    _joystickThumb = details.localPosition;
                  });
                },
                onPointerMove: (details) {
                  if (_joystickBase != null) {
                    final offset = details.localPosition - _joystickBase!;
                    final dist = offset.dx;
                    final maxDist = 45.0;
                    final clampedX = dist.clamp(-maxDist, maxDist);

                    setState(() {
                      _joystickThumb = Offset(_joystickBase!.dx + clampedX, _joystickBase!.dy);
                      _joystickDeltaX = clampedX / maxDist;
                    });
                    _game.setHorizontalInput(_joystickDeltaX, _isSprinting);
                  }
                },
                onPointerUp: (_) {
                  setState(() {
                    _joystickBase = null;
                    _joystickThumb = null;
                    _joystickDeltaX = 0;
                  });
                  _game.setHorizontalInput(0, false);
                },
                child: Container(
                  width: 140,
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Direction Arrows Background
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.arrow_back_ios_rounded, color: Colors.white38, size: 18),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 18),
                        ],
                      ),
                      // Movable Slider Knob
                      Transform.translate(
                        offset: _joystickBase != null && _joystickThumb != null
                            ? Offset(_joystickThumb!.dx - _joystickBase!.dx, 0)
                            : Offset.zero,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFC00), Color(0xFFF59E0B)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.directions_run_rounded, color: Colors.black87, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Action Buttons: Jump (🦘) & Sprint (⚡) (Bottom Right)
            Positioned(
              bottom: 24,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sprint Toggle Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isSprinting = !_isSprinting;
                      });
                      _game.setHorizontalInput(_joystickDeltaX, _isSprinting);
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSprinting ? const Color(0xFF00F0FF) : Colors.black.withValues(alpha: 0.6),
                        border: Border.all(
                          color: _isSprinting ? Colors.white : const Color(0xFF00F0FF).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (_isSprinting)
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: _isSprinting ? Colors.black : const Color(0xFF00F0FF),
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Big Jump Button
                  GestureDetector(
                    onTap: _triggerJump,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFC00), Color(0xFFEAB308)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🦘', style: TextStyle(fontSize: 24)),
                          Text(
                            'JUMP',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
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
      ),
    );
  }

  Widget _buildZoomButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F0FF) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 🎮 Flame Game Engine: 2D Rolling Hills World, Front-Facing Houses & Platformer Avatar
class PocketOpenWorldGame extends FlameGame {
  final int playerDay;
  final int playerStreak;
  final ValueChanged<PocketNeighbor?> onProximityChanged;
  double zoomScale;

  final ValueNotifier<String> districtNotifier =
      ValueNotifier<String>('🔰 Rookie Village (Lvl 1 - 5)');

  // World dimensions (6000px rolling mountain range)
  static const double worldWidth = 6000.0;
  static const double worldHeight = 1600.0;
  static const double groundBaseY = 880.0;

  // Player physics
  double playerX = 350.0;
  double playerY = groundBaseY;
  double playerZ = 0.0; // Jump altitude
  double jumpVelocity = 0.0;
  bool isJumping = false;
  double playerFacing = 1.0;
  double runCycle = 0.0;
  bool isMoving = false;

  // Input
  double inputDx = 0.0;
  bool isSprinting = false;

  // Camera
  double cameraX = 0.0;
  double cameraY = 0.0;

  // Citadels along the rolling hills
  List<WorldHouseNode> houseNodes = [];
  List<RoamingRobotNpc> robotNpcs = [];
  final List<JumpDustParticle> particles = [];

  String currentDistrictName = '🔰 Rookie Village (Lvl 1 - 5)';

  PocketOpenWorldGame({
    required this.playerDay,
    required this.playerStreak,
    required this.onProximityChanged,
    double initialZoom = 0.85,
  }) : zoomScale = initialZoom;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _spawnRoamingRobots();
  }

  void setZoom(double z) {
    zoomScale = z;
  }

  /// ⛰️ Rolling Hills Terrain Spline Function
  /// Returns ground Y coordinate at any X position in the world
  static double getGroundY(double x) {
    final wave1 = math.sin(x * 0.0028) * 65.0;
    final wave2 = math.sin(x * 0.0012 + 1.2) * 95.0;
    final wave3 = math.sin(x * 0.0006) * 120.0;
    return groundBaseY - wave1 - wave2 - wave3;
  }

  void setNeighbors(List<PocketNeighbor> list) {
    houseNodes.clear();

    // Distribute houses along the rolling hills by level sectors
    for (int i = 0; i < list.length; i++) {
      final neighbor = list[i];
      // Sector calculation
      double x;
      if (neighbor.day <= 5) {
        // Rookie Village
        x = 220.0 + (i * 240.0).clamp(0.0, 1100.0);
      } else if (neighbor.day <= 11) {
        // Intermediate Town
        x = 1400.0 + ((i - 3).clamp(0, 20) * 260.0);
      } else if (neighbor.day <= 30) {
        // Scholar Heights
        x = 2700.0 + ((i - 6).clamp(0, 20) * 280.0);
      } else {
        // Apex Citadel Peaks
        x = 4200.0 + ((i - 10).clamp(0, 20) * 300.0);
      }
      x = x.clamp(180.0, worldWidth - 250.0);
      final y = getGroundY(x);

      houseNodes.add(
        WorldHouseNode(
          neighbor: neighbor,
          x: x,
          y: y,
          isNorth: false,
        ),
      );
    }
  }

  void _spawnRoamingRobots() {
    robotNpcs = [
      RoamingRobotNpc(
        id: 'robo_01',
        name: 'Pocket Robo #01',
        x: 600,
        y: getGroundY(600),
        patrolMinX: 350,
        patrolMaxX: 900,
        speechText: 'Welcome to the 2D Open World! 🌟',
      ),
      RoamingRobotNpc(
        id: 'robo_valk',
        name: 'Cyber Valkyrie',
        x: 2000,
        y: getGroundY(2000),
        patrolMinX: 1600,
        patrolMaxX: 2400,
        speechText: 'Climb the hills to reach Level 30! ⚡',
      ),
      RoamingRobotNpc(
        id: 'robo_prime',
        name: 'Overlord Prime (Lvl 90)',
        x: 4800,
        y: getGroundY(4800),
        patrolMinX: 4300,
        patrolMaxX: 5500,
        speechText: 'The Apex Citadel Valley awaits! 👑',
      ),
    ];
  }

  void setHorizontalInput(double dx, bool sprint) {
    inputDx = dx;
    isSprinting = sprint;
    isMoving = dx.abs() > 0.08;
    if (dx.abs() > 0.08) {
      playerFacing = dx > 0 ? 1.0 : -1.0;
    }
  }

  void playerJump() {
    if (!isJumping) {
      isJumping = true;
      jumpVelocity = 18.0;

      // Jump dust particles
      final groundY = getGroundY(playerX);
      for (int i = 0; i < 6; i++) {
        final angle = (i / 6) * math.pi * 2;
        particles.add(
          JumpDustParticle(
            x: playerX,
            y: groundY,
            vx: math.cos(angle) * 35,
            vy: math.sin(angle) * 18,
          ),
        );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Horizontal Movement
    final speed = (isSprinting ? 320.0 : 200.0) * dt;
    if (inputDx.abs() > 0.05) {
      playerX += inputDx * speed;
      runCycle += dt * (isSprinting ? 18.0 : 12.0);
    }
    playerX = playerX.clamp(100.0, worldWidth - 100.0);

    // Lock player to rolling ground curve
    final groundY = getGroundY(playerX);

    // 2. Vertical Jump Physics
    if (isJumping) {
      playerZ += jumpVelocity;
      jumpVelocity -= 0.85; // Gravity
      if (playerZ <= 0.0) {
        playerZ = 0.0;
        isJumping = false;
        jumpVelocity = 0.0;

        // Landing dust particles
        for (int i = 0; i < 5; i++) {
          final angle = (i / 5) * math.pi * 2;
          particles.add(
            JumpDustParticle(
              x: playerX,
              y: groundY,
              vx: math.cos(angle) * 24,
              vy: math.sin(angle) * 12,
            ),
          );
        }
      }
    }
    playerY = groundY - playerZ;

    // 3. Update Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].life <= 0) {
        particles.removeAt(i);
      }
    }

    // 4. Update Roaming Robots
    for (final bot in robotNpcs) {
      bot.update(dt);
      bot.y = getGroundY(bot.x);
    }

    // 5. Camera Tracking
    final viewportW = size.x / zoomScale;
    final viewportH = size.y / zoomScale;
    final targetCamX = playerX - (viewportW / 2);
    final targetCamY = playerY - (viewportH * 0.65);

    cameraX += (targetCamX - cameraX) * 0.12;
    cameraY += (targetCamY - cameraY) * 0.12;
    cameraX = cameraX.clamp(0.0, math.max(0.0, worldWidth - viewportW));
    cameraY = cameraY.clamp(0.0, math.max(0.0, worldHeight - viewportH));

    // 6. District Check
    if (playerX < 1350) {
      currentDistrictName = '🔰 Rookie Village (Lvl 1 - 5)';
    } else if (playerX < 2750) {
      currentDistrictName = '🏛️ Intermediate Town (Lvl 6 - 11)';
    } else if (playerX < 4150) {
      currentDistrictName = '⚡ Scholar Heights (Lvl 12 - 30)';
    } else {
      currentDistrictName = '👑 Apex Citadel Peaks (Lvl 31 - 90)';
    }

    if (districtNotifier.value != currentDistrictName) {
      districtNotifier.value = currentDistrictName;
    }

    // 7. Proximity Detection to House Gates
    PocketNeighbor? closest;
    double minDistance = 110.0;

    for (final node in houseNodes) {
      final dist = (playerX - node.x).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closest = node.neighbor;
      }
    }

    onProximityChanged(closest);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    // Apply zoom & camera translation
    canvas.scale(zoomScale, zoomScale);
    canvas.translate(-cameraX, -cameraY);

    // 1. Draw Sky & Mountain Background
    _drawSkyAndMountains(canvas);

    // 2. Draw Rolling Hills Terrain
    _drawRollingHills(canvas);

    // 3. Draw Authentic 2D Front-Facing English Houses on the Hills
    for (final node in houseNodes) {
      _drawAuthenticEnglishHouse(canvas, node);
    }

    // 4. Draw Roaming Robots
    for (final bot in robotNpcs) {
      _drawRobotNpc(canvas, bot);
    }

    // 5. Draw Particles
    for (final p in particles) {
      p.render(canvas);
    }

    // 6. Draw 2D Side-Scroller Player Avatar
    _drawPlatformerAvatar(canvas);

    canvas.restore();
  }

  void _drawSkyAndMountains(Canvas canvas) {
    // Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF050B14), Color(0xFF0F1E36), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, worldWidth, worldHeight));
    canvas.drawRect(const Rect.fromLTWH(0, 0, worldWidth, worldHeight), skyPaint);

    // Distant Stars & Moon
    final moonPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(const Offset(900, 240), 45, moonPaint);
    canvas.drawCircle(
      const Offset(900, 240),
      60,
      Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );

    // Distant Mountain Ridges (Parallax Silhouettes)
    final mountainPath = Path();
    mountainPath.moveTo(0, groundBaseY - 180);
    for (double x = 0; x <= worldWidth; x += 300) {
      final my = groundBaseY - 240 - (math.sin(x * 0.0015) * 140.0);
      mountainPath.lineTo(x, my);
    }
    mountainPath.lineTo(worldWidth, worldHeight);
    mountainPath.lineTo(0, worldHeight);
    mountainPath.close();

    final mountainPaint = Paint()..color = const Color(0xFF131F37);
    canvas.drawPath(mountainPath, mountainPaint);
  }

  void _drawRollingHills(Canvas canvas) {
    // Rolling Hills Path
    final hillPath = Path();
    hillPath.moveTo(0, getGroundY(0));
    for (double x = 0; x <= worldWidth; x += 15) {
      hillPath.lineTo(x, getGroundY(x));
    }
    hillPath.lineTo(worldWidth, worldHeight);
    hillPath.lineTo(0, worldHeight);
    hillPath.close();

    // Lush Earth / Hill Shader
    final hillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E3A5F), Color(0xFF0F172A), Color(0xFF080D1A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 400, worldWidth, 1200));
    canvas.drawPath(hillPath, hillPaint);

    // Green Grass Ridge Outline
    final ridgePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;
    canvas.drawPath(hillPath, ridgePaint);

    // Paved Cobblestone Footpath on top of hill curve
    final pathOutline = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawPath(hillPath, pathOutline);

    // Lamp posts along the hills
    for (double x = 150; x < worldWidth; x += 320) {
      final y = getGroundY(x);
      // Pole
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y - 55),
        Paint()..color = const Color(0xFF475569)..strokeWidth = 3.5,
      );
      // Lantern
      canvas.drawCircle(Offset(x, y - 55), 6, Paint()..color = const Color(0xFFFFFC00));
      // Light aura
      canvas.drawCircle(
        Offset(x, y - 55),
        24,
        Paint()..color = const Color(0xFFFFFC00).withValues(alpha: 0.15),
      );
    }
  }

  /// 🏡 Draws the Authentic 2D Front-Facing English House on the Hill
  void _drawAuthenticEnglishHouse(Canvas canvas, WorldHouseNode node) {
    final x = node.x;
    final groundY = node.y;
    final neighbor = node.neighbor;
    final pal = HousePalette.getById(neighbor.paletteId);

    // Scale house dimensions
    const houseW = 160.0;
    const houseH = 135.0;
    final houseBottom = groundY - 2;

    // 1. Stone Foundation
    final foundationRect = Rect.fromLTWH(x - (houseW / 2) - 6, houseBottom - 18, houseW + 12, 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(foundationRect, const Radius.circular(4)),
      Paint()..color = pal.foundationColor,
    );

    // 2. Main Building Front Wall
    final wallRect = Rect.fromLTWH(x - (houseW / 2), houseBottom - houseH, houseW, houseH - 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallRect, const Radius.circular(8)),
      Paint()..color = pal.wallColor,
    );

    // Brick mortar lines
    final mortarPaint = Paint()
      ..color = pal.mortarColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    for (double ly = wallRect.top + 16; ly < wallRect.bottom; ly += 18) {
      canvas.drawLine(Offset(wallRect.left, ly), Offset(wallRect.right, ly), mortarPaint);
    }

    // 3. Pitched Victorian Roof & Gables
    final roofPeakY = wallRect.top - 65;
    final roofPath = Path();
    roofPath.moveTo(x - (houseW / 2) - 16, wallRect.top + 4);
    roofPath.lineTo(x, roofPeakY);
    roofPath.lineTo(x + (houseW / 2) + 16, wallRect.top + 4);
    roofPath.close();

    canvas.drawPath(roofPath, Paint()..color = pal.roofColor);

    // Roof Trim
    canvas.drawPath(
      roofPath,
      Paint()
        ..color = pal.roofTrim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );

    // 4. Chimney & Smoke
    final chimneyRect = Rect.fromLTWH(x + 36, roofPeakY + 8, 20, 42);
    canvas.drawRect(chimneyRect, Paint()..color = pal.foundationColor);
    // Smoke puffs
    canvas.drawCircle(Offset(x + 46, roofPeakY - 4), 6, Paint()..color = Colors.white24);
    canvas.drawCircle(Offset(x + 52, roofPeakY - 14), 9, Paint()..color = Colors.white12);

    // 5. Grand Front Entrance Door
    final doorRect = Rect.fromLTWH(x - 18, houseBottom - 58, 36, 42);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect,
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
      ),
      Paint()..color = pal.doorColor,
    );
    // Doorknob
    canvas.drawCircle(Offset(x + 10, houseBottom - 36), 3, Paint()..color = const Color(0xFFFFD700));

    // 6. Glowing Windows
    final windowPaint = Paint()..color = pal.windowColor;
    final winFrame = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Left window
    final lWin = Rect.fromCenter(center: Offset(x - 48, houseBottom - 75), width: 28, height: 32);
    canvas.drawRRect(RRect.fromRectAndRadius(lWin, const Radius.circular(6)), windowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(lWin, const Radius.circular(6)), winFrame);

    // Right window
    final rWin = Rect.fromCenter(center: Offset(x + 48, houseBottom - 75), width: 28, height: 32);
    canvas.drawRRect(RRect.fromRectAndRadius(rWin, const Radius.circular(6)), windowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rWin, const Radius.circular(6)), winFrame);

    // Attic circular rosette window
    canvas.drawCircle(Offset(x, wallRect.top - 20), 12, windowPaint);
    canvas.drawCircle(Offset(x, wallRect.top - 20), 12, winFrame);

    // 7. Active Iron Dome Forcefield Bubble
    if (neighbor.hasActiveShield) {
      final shieldPaint = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, houseBottom - 70), 115, shieldPaint);

      final shieldRing = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(x, houseBottom - 70), 115, shieldRing);
    }

    // 8. Charred Breach Damage
    if (neighbor.isDamaged) {
      final crackPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset(x - 30, wallRect.top + 20), Offset(x - 10, wallRect.top + 45), crackPaint);
      canvas.drawLine(Offset(x - 10, wallRect.top + 45), Offset(x - 22, wallRect.top + 70), crackPaint);
    }

    // 9. Floating Owner Nameplate Banner
    final bannerY = roofPeakY - 26;
    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, bannerY), width: 140, height: 26),
      const Radius.circular(8),
    );
    canvas.drawRRect(bannerRect, Paint()..color = Colors.black.withValues(alpha: 0.85));
    canvas.drawRRect(
      bannerRect,
      Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: 'Lvl ${neighbor.day} • ${neighbor.name}',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: 130);
    tp.paint(canvas, Offset(x - (tp.width / 2), bannerY - (tp.height / 2)));
  }

  void _drawRobotNpc(Canvas canvas, RoamingRobotNpc bot) {
    final x = bot.x;
    final y = bot.y - 20;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, bot.y), width: 38, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    // Robot Body
    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 32, height: 36), const Radius.circular(8)),
      bodyPaint,
    );

    // Visor
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y - 5), width: 22, height: 9), const Radius.circular(3)),
      Paint()..color = const Color(0xFF00F0FF),
    );

    // Antenna
    canvas.drawLine(Offset(x, y - 18), Offset(x, y - 26), Paint()..color = const Color(0xFFFFFC00)..strokeWidth = 2);
    canvas.drawCircle(Offset(x, y - 28), 3.5, Paint()..color = const Color(0xFFFF2A55));

    // Speech bubble if avatar is nearby
    if ((playerX - x).abs() < 160) {
      final bRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y - 55), width: 160, height: 28),
        const Radius.circular(8),
      );
      canvas.drawRRect(bRect, Paint()..color = Colors.black.withValues(alpha: 0.85));
      canvas.drawRRect(
        bRect,
        Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: bot.speechText,
          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: 150);
      tp.paint(canvas, Offset(x - (tp.width / 2), y - 55 - (tp.height / 2)));
    }
  }

  /// 🏃 Draws the 2D Platformer Avatar running and jumping in front of houses
  void _drawPlatformerAvatar(Canvas canvas) {
    final x = playerX;
    final groundY = getGroundY(playerX);
    final avatarY = groundY - playerZ;

    // 1. Drop Shadow on the Ground (scales down as player jumps higher)
    final shadowScale = math.max(0.3, 1.0 - (playerZ / 90.0));
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45 * shadowScale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerX, groundY + 4),
        width: 44 * shadowScale,
        height: 14 * shadowScale,
      ),
      shadowPaint,
    );

    // 2. Avatar Character
    canvas.save();
    canvas.translate(x, avatarY - 24);

    // Facing direction
    if (playerFacing < 0) {
      canvas.scale(-1.0, 1.0);
    }

    // Running leg animation
    if (isMoving && !isJumping) {
      final legAngle = math.sin(runCycle) * 0.45;
      final legPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(-6, 12), Offset(-6 - (legAngle * 18), 24), legPaint);
      canvas.drawLine(const Offset(6, 12), Offset(6 + (legAngle * 18), 24), legPaint);
    } else {
      // Standing legs
      final legPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(-6, 12), const Offset(-6, 24), legPaint);
      canvas.drawLine(const Offset(6, 12), const Offset(6, 24), legPaint);
    }

    // Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: 34, height: 42),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFFC00));
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Visor Glasses
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-2, -12, 16, 10), const Radius.circular(5)),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(const Offset(6, -7), 2.5, Paint()..color = const Color(0xFF00F0FF));

    // Floating Golden Level Star over Head
    canvas.drawCircle(const Offset(0, -32), 6, Paint()..color = const Color(0xFFFFD700));

    canvas.restore();

    // "YOU (Lvl X)" Text Tag
    final tp = TextPainter(
      text: TextSpan(
        text: 'YOU (Lvl $playerDay)',
        style: const TextStyle(
          color: Color(0xFFFFFC00),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - (tp.width / 2), avatarY - 65));
  }
}

class WorldHouseNode {
  final PocketNeighbor neighbor;
  final double x;
  final double y;
  final bool isNorth;

  WorldHouseNode({
    required this.neighbor,
    required this.x,
    required this.y,
    required this.isNorth,
  });
}

class RoamingRobotNpc {
  final String id;
  final String name;
  double x;
  double y;
  final double patrolMinX;
  final double patrolMaxX;
  double direction = 1.0;
  final String speechText;

  RoamingRobotNpc({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.patrolMinX,
    required this.patrolMaxX,
    required this.speechText,
  });

  void update(double dt) {
    x += direction * 35.0 * dt;
    if (x >= patrolMaxX) {
      x = patrolMaxX;
      direction = -1.0;
    } else if (x <= patrolMinX) {
      x = patrolMinX;
      direction = 1.0;
    }
  }
}

class JumpDustParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  double life = 1.0;

  JumpDustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt * 2.5;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final paint = Paint()..color = Colors.white.withValues(alpha: life * 0.4);
    canvas.drawCircle(Offset(x, y), 3.5 * life, paint);
  }
}
