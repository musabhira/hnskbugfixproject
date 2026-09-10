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

/// 🌍 Pocket Open World Adventure Page: 2D Free-Roam Exploration & Citadel Raids
/// Powered by Flame Engine (`FlameGame`)
///
/// Features:
/// 1. Free-roaming avatar with virtual joystick & tap-to-move
/// 2. Parabolic jump/hop mechanic (🦘) with dust puffs and shadow scaling
/// 3. Continuous themed districts: Rookie Haven, Grammar Plaza, Fluency Boulevard, Apex Valley
/// 4. Live Supabase neighbor citadels and dynamic robot fortresses
/// 5. Proximity detection: Walk up to any gate to launch full-screen Citadel Raid
/// 6. Roaming robot NPCs with dynamic speech dialogue bubbles
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

  // Joystick touch state
  Offset? _joystickBase;
  Offset? _joystickThumb;
  double _joystickDeltaX = 0.0;
  double _joystickDeltaY = 0.0;
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
        count: 10,
      );
      final supaNeighbors = await PocketFortressDefenseService.fetchSupabaseNeighbors(limit: 20);
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
          count: 12,
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
      body: Stack(
        children: [
          // 1. Full-Screen Flame Canvas
          GameWidget(game: _game),

          // 2. Top Navigation & District Status Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          const SizedBox(width: 6),
                          Text(
                            'Exit',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // District Location Badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧭', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: ValueListenableBuilder<String>(
                              valueListenable: _game.districtNotifier,
                              builder: (context, district, _) {
                                return Text(
                                  district,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFC00),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Street Mode Switcher
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          const SizedBox(width: 5),
                          Text(
                            'Street View',
                            style: GoogleFonts.outfit(color: Colors.black, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Mini-Map Radar (Top Right)
          if (!_isLoadingNeighbors)
            Positioned(
              top: 70,
              right: 16,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00F0FF).withValues(alpha: 0.15), blurRadius: 10),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: _MiniMapPainter(game: _game),
                  ),
                ),
              ),
            ),

          // 4. Proximity Action Card (Appears when near a Citadel)
          if (_proximityNeighbor != null)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
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
                        width: 46,
                        height: 46,
                        child: VectorAvatarWidget(
                          config: VectorAvatarConfig.getEvolutionAvatarForStage(_proximityNeighbor!.day),
                          size: 46,
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
                              const SizedBox(width: 6),
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

          // 5. Virtual Joystick (Bottom Left Touch Zone)
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
                  final dist = offset.distance;
                  final maxDist = 45.0;
                  final clampedOffset = dist > maxDist ? offset / dist * maxDist : offset;

                  setState(() {
                    _joystickThumb = _joystickBase! + clampedOffset;
                    _joystickDeltaX = clampedOffset.dx / maxDist;
                    _joystickDeltaY = clampedOffset.dy / maxDist;
                  });
                  _game.setJoystickInput(_joystickDeltaX, _joystickDeltaY, _isSprinting);
                }
              },
              onPointerUp: (_) {
                setState(() {
                  _joystickBase = null;
                  _joystickThumb = null;
                  _joystickDeltaX = 0;
                  _joystickDeltaY = 0;
                });
                _game.setJoystickInput(0, 0, false);
              },
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.35),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Direction Guide Ring
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
                        ),
                      ),
                      // Movable Knob
                      Transform.translate(
                        offset: _joystickBase != null && _joystickThumb != null
                            ? _joystickThumb! - _joystickBase!
                            : Offset.zero,
                        child: Container(
                          width: 48,
                          height: 48,
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
                          child: const Icon(Icons.gamepad_rounded, color: Colors.black87, size: 22),
                        ),
                      ),
                    ],
                  ),
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
                    _game.setJoystickInput(_joystickDeltaX, _joystickDeltaY, _isSprinting);
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
                    width: 70,
                    height: 70,
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
                        const Text('🦘', style: TextStyle(fontSize: 22)),
                        Text(
                          'JUMP',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 10,
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
    );
  }
}

/// 🎮 Flame Engine Game: Handles camera, world rendering, player physics, and citadels
class PocketOpenWorldGame extends FlameGame {
  final int playerDay;
  final int playerStreak;
  final ValueChanged<PocketNeighbor?> onProximityChanged;

  final ValueNotifier<String> districtNotifier =
      ValueNotifier<String>('🔰 Rookie Haven (Lvl 1 - 10)');

  // World dimensions
  static const double worldWidth = 3600.0;
  static const double worldHeight = 1200.0;
  static const double streetY = 600.0;
  static const double roadHeight = 220.0;

  // Player state
  double playerX = 250.0;
  double playerY = streetY;
  double playerZ = 0.0; // Jump height offset
  double jumpVelocity = 0.0;
  bool isJumping = false;
  double playerFacing = 1.0; // 1 = right, -1 = left
  double walkAnimPhase = 0.0;
  bool isMoving = false;

  // Input
  double inputDx = 0.0;
  double inputDy = 0.0;
  bool isSprinting = false;

  // Camera viewport
  double cameraX = 0.0;
  double cameraY = 0.0;

  // Data
  List<PocketNeighbor> neighbors = [];
  List<WorldHouseNode> houseNodes = [];
  List<RoamingRobotNpc> robotNpcs = [];

  // Particles
  final List<JumpDustParticle> particles = [];

  String currentDistrictName = '🔰 Rookie Haven (Lvl 1 - 10)';

  PocketOpenWorldGame({
    required this.playerDay,
    required this.playerStreak,
    required this.onProximityChanged,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _spawnRobotNpcs();
  }

  void setNeighbors(List<PocketNeighbor> list) {
    neighbors = list;
    houseNodes.clear();

    // Place houses on both North (top) and South (bottom) sides of the boulevard
    for (int i = 0; i < list.length; i++) {
      final isNorth = i % 2 == 0;
      final x = 320.0 + (i * 260.0);
      final y = isNorth ? streetY - (roadHeight / 2) - 140 : streetY + (roadHeight / 2) + 140;

      houseNodes.add(
        WorldHouseNode(
          neighbor: list[i],
          x: x,
          y: y,
          isNorth: isNorth,
        ),
      );
    }
  }

  void _spawnRobotNpcs() {
    robotNpcs = [
      RoamingRobotNpc(
        id: 'robo_01',
        name: 'Pocket Robo #01',
        x: 450,
        y: streetY - 40,
        patrolMinX: 300,
        patrolMaxX: 650,
        speechText: 'Welcome to Pocket World! 🌟',
      ),
      RoamingRobotNpc(
        id: 'robo_valk',
        name: 'Cyber Valkyrie',
        x: 1200,
        y: streetY + 40,
        patrolMinX: 950,
        patrolMaxX: 1450,
        speechText: 'Crack grammar sentries to advance! ⚡',
      ),
      RoamingRobotNpc(
        id: 'robo_prime',
        name: 'Overlord Prime (Lvl 90)',
        x: 2750,
        y: streetY - 50,
        patrolMinX: 2500,
        patrolMaxX: 3100,
        speechText: 'The Apex Citadel welcomes worthy masters! 👑',
      ),
    ];
  }

  void setJoystickInput(double dx, double dy, bool sprint) {
    inputDx = dx;
    inputDy = dy;
    isSprinting = sprint;
    isMoving = dx.abs() > 0.1 || dy.abs() > 0.1;
    if (dx.abs() > 0.1) {
      playerFacing = dx > 0 ? 1.0 : -1.0;
    }
  }

  void playerJump() {
    if (!isJumping) {
      isJumping = true;
      jumpVelocity = 15.0;

      // Spawn dust puff particles
      for (int i = 0; i < 6; i++) {
        final angle = (i / 6) * math.pi * 2;
        particles.add(
          JumpDustParticle(
            x: playerX,
            y: playerY + 8,
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

    // 1. Move Player
    final speed = (isSprinting ? 280.0 : 180.0) * dt;
    if (inputDx.abs() > 0.05 || inputDy.abs() > 0.05) {
      playerX += inputDx * speed;
      playerY += inputDy * speed;
      walkAnimPhase += dt * (isSprinting ? 16.0 : 10.0);
    }

    // Clamp player to world bounds
    playerX = playerX.clamp(100.0, worldWidth - 100.0);
    playerY = playerY.clamp(streetY - 260.0, streetY + 260.0);

    // 2. Jump Physics (Parabolic arc)
    if (isJumping) {
      playerZ += jumpVelocity;
      jumpVelocity -= 0.85; // Gravity
      if (playerZ <= 0.0) {
        playerZ = 0.0;
        isJumping = false;
        jumpVelocity = 0.0;

        // Landing dust puff
        for (int i = 0; i < 5; i++) {
          final angle = (i / 5) * math.pi * 2;
          particles.add(
            JumpDustParticle(
              x: playerX,
              y: playerY + 8,
              vx: math.cos(angle) * 25,
              vy: math.sin(angle) * 12,
            ),
          );
        }
      }
    }

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
    }

    // 5. Smooth Camera Follow
    final targetCamX = playerX - (size.x / 2);
    final targetCamY = playerY - (size.y / 2);
    cameraX += (targetCamX - cameraX) * 0.12;
    cameraY += (targetCamY - cameraY) * 0.12;
    cameraX = cameraX.clamp(0.0, math.max(0.0, worldWidth - size.x));
    cameraY = cameraY.clamp(0.0, math.max(0.0, worldHeight - size.y));

    // 6. District Check
    if (playerX < 850) {
      currentDistrictName = '🔰 Rookie Haven (Lvl 1 - 10)';
    } else if (playerX < 1700) {
      currentDistrictName = '🏛️ Grammar Plaza (Lvl 11 - 30)';
    } else if (playerX < 2550) {
      currentDistrictName = '⚡ Fluency Boulevard (Lvl 31 - 60)';
    } else {
      currentDistrictName = '👑 Apex Citadel Valley (Lvl 61 - 90)';
    }

    if (districtNotifier.value != currentDistrictName) {
      districtNotifier.value = currentDistrictName;
    }

    // 7. Proximity Detection to Citadels
    PocketNeighbor? closest;
    double minDistance = 120.0; // Trigger radius

    for (final node in houseNodes) {
      final dist = math.sqrt(math.pow(playerX - node.x, 2) + math.pow(playerY - node.y, 2));
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
    // Apply camera translation
    canvas.translate(-cameraX, -cameraY);

    // 1. Draw Open World Background Terrain
    _drawWorldTerrain(canvas);

    // 2. Draw Citadels & Buildings
    for (final node in houseNodes) {
      _drawCitadelBuilding(canvas, node);
    }

    // 3. Draw Roaming Robots
    for (final bot in robotNpcs) {
      _drawRobotNpc(canvas, bot);
    }

    // 4. Draw Particles
    for (final p in particles) {
      p.render(canvas);
    }

    // 5. Draw Player Avatar with Jump & Shadow
    _drawPlayerAvatar(canvas);

    canvas.restore();
  }

  void _drawWorldTerrain(Canvas canvas) {
    // 1. Lush Green Ground
    final grassPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(const Rect.fromLTWH(0, 0, worldWidth, worldHeight), grassPaint);

    // Subtle lawn grid tiles
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (double x = 0; x < worldWidth; x += 120) {
      canvas.drawLine(Offset(x, 0), Offset(x, worldHeight), gridPaint);
    }

    // 2. Paved Main Boulevard
    final roadRect = Rect.fromLTWH(0, streetY - (roadHeight / 2), worldWidth, roadHeight);
    final roadPaint = Paint()..color = const Color(0xFF182234);
    canvas.drawRect(roadRect, roadPaint);

    // Road Sidewalk Borders
    final curbPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 5.0;
    canvas.drawLine(Offset(0, streetY - (roadHeight / 2)), Offset(worldWidth, streetY - (roadHeight / 2)), curbPaint);
    canvas.drawLine(Offset(0, streetY + (roadHeight / 2)), Offset(worldWidth, streetY + (roadHeight / 2)), curbPaint);

    // Glowing Neon Lane Dashes
    final lanePaint = Paint()
      ..color = const Color(0xFFFFFC00).withValues(alpha: 0.5)
      ..strokeWidth = 3.5;
    for (double x = 0; x < worldWidth; x += 60) {
      canvas.drawLine(Offset(x, streetY), Offset(x + 32, streetY), lanePaint);
    }

    // Sidewalk Stone Pathway Pattern
    final pathPaint = Paint()
      ..color = const Color(0xFF27354A)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, streetY - (roadHeight / 2) - 40, worldWidth, 40), pathPaint);
    canvas.drawRect(Rect.fromLTWH(0, streetY + (roadHeight / 2), worldWidth, 40), pathPaint);

    // District Boundary Markers & Streetlights
    for (double x = 850; x < worldWidth; x += 850) {
      final p = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.3)
        ..strokeWidth = 3;
      canvas.drawLine(Offset(x, 0), Offset(x, worldHeight), p);
    }
  }

  void _drawCitadelBuilding(Canvas canvas, WorldHouseNode node) {
    final x = node.x;
    final y = node.y;
    final neighbor = node.neighbor;
    final pal = HousePalette.getById(neighbor.paletteId);

    // 1. Drop Shadow under house
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + 55), width: 170, height: 40), shadowPaint);

    // 2. Outer Building Wall
    final wallPaint = Paint()..color = pal.wallColor;
    final wallRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: 140, height: 110),
      const Radius.circular(16),
    );
    canvas.drawRRect(wallRect, wallPaint);

    // Wall Border
    final borderPaint = Paint()
      ..color = pal.foundationColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(wallRect, borderPaint);

    // 3. Roof Gable
    final roofPath = Path();
    roofPath.moveTo(x - 80, y - 55);
    roofPath.lineTo(x, y - 115);
    roofPath.lineTo(x + 80, y - 55);
    roofPath.close();

    final roofPaint = Paint()..color = pal.roofColor;
    canvas.drawPath(roofPath, roofPaint);

    final roofTrimPaint = Paint()
      ..color = pal.roofTrim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(roofPath, roofTrimPaint);

    // 4. Citadel Gate Door
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(x, y + 25), width: 44, height: 60),
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
    );
    final doorPaint = Paint()..color = pal.doorColor;
    canvas.drawRRect(doorRect, doorPaint);

    // 5. Windows
    final windowPaint = Paint()..color = pal.windowColor;
    canvas.drawCircle(Offset(x - 42, y - 10), 14, windowPaint);
    canvas.drawCircle(Offset(x + 42, y - 10), 14, windowPaint);

    // 6. Shield Dome Aura
    if (neighbor.hasActiveShield) {
      final shieldPaint = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y - 20), 105, shieldPaint);

      final shieldRing = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(x, y - 20), 105, shieldRing);
    }

    // 7. Damage Smoke
    if (neighbor.isDamaged) {
      final smokePaint = Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.5);
      canvas.drawCircle(Offset(x - 20, y - 70), 16, smokePaint);
      canvas.drawCircle(Offset(x - 30, y - 90), 22, smokePaint);
    }

    // 8. Nameplate Banner
    final bannerPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y - 130), width: 140, height: 26),
      const Radius.circular(8),
    );
    canvas.drawRRect(bannerRect, bannerPaint);

    // Border
    final bannerBorder = Paint()
      ..color = const Color(0xFFFFFC00).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(bannerRect, bannerBorder);

    // Text Painter for Name
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Lvl ${neighbor.day} • ${neighbor.name}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: 130);

    textPainter.paint(
      canvas,
      Offset(x - (textPainter.width / 2), y - 130 - (textPainter.height / 2)),
    );
  }

  void _drawRobotNpc(Canvas canvas, RoamingRobotNpc bot) {
    final x = bot.x;
    final y = bot.y;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 20), width: 44, height: 16),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 36, height: 38), const Radius.circular(10)),
      bodyPaint,
    );

    // Visor / Eyes
    final eyePaint = Paint()..color = const Color(0xFF00F0FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y - 5), width: 24, height: 10), const Radius.circular(4)),
      eyePaint,
    );

    // Antenna
    canvas.drawLine(
      Offset(x, y - 19),
      Offset(x, y - 28),
      Paint()..color = const Color(0xFFFFFC00)..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(x, y - 30), 4, Paint()..color = const Color(0xFFFF2A55));

    // Speech Bubble (If player is within 180px)
    final distToPlayer = math.sqrt(math.pow(playerX - x, 2) + math.pow(playerY - y, 2));
    if (distToPlayer < 200) {
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y - 60), width: 170, height: 32),
        const Radius.circular(10),
      );
      canvas.drawRRect(bubbleRect, Paint()..color = Colors.black.withValues(alpha: 0.85));
      canvas.drawRRect(
        bubbleRect,
        Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: bot.speechText,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: 160);
      tp.paint(canvas, Offset(x - (tp.width / 2), y - 60 - (tp.height / 2)));
    }
  }

  void _drawPlayerAvatar(Canvas canvas) {
    final x = playerX;
    final y = playerY - playerZ; // Apply jump height offset

    // 1. Dynamic Drop Shadow (scales with jump height)
    final shadowScale = math.max(0.4, 1.0 - (playerZ / 80.0));
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35 * shadowScale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerX, playerY + 22),
        width: 46 * shadowScale,
        height: 18 * shadowScale,
      ),
      shadowPaint,
    );

    // 2. Walking Bob & Jump Scale
    final bobY = isMoving && !isJumping ? math.sin(walkAnimPhase) * 3.5 : 0.0;

    canvas.save();
    canvas.translate(x, y + bobY);

    // Direction Flip (facing left / right)
    if (playerFacing < 0) {
      canvas.scale(-1.0, 1.0);
    }

    // Avatar Body (Pencil / Vector Style Capsule)
    final bodyPaint = Paint()..color = const Color(0xFFFFFC00);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -36, 36, 48),
        const Radius.circular(18),
      ),
      bodyPaint,
    );

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -36, 36, 48),
        const Radius.circular(18),
      ),
      outlinePaint,
    );

    // Visor / Glasses
    final glassPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2, -26, 18, 12),
        const Radius.circular(6),
      ),
      glassPaint,
    );
    canvas.drawCircle(const Offset(8, -20), 3, Paint()..color = const Color(0xFF00F0FF));

    // Player Level Badge over Head
    final crownPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(const Offset(0, -44), 6, crownPaint);

    canvas.restore();

    // Player "YOU" Label
    final youPainter = TextPainter(
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
    youPainter.paint(canvas, Offset(x - (youPainter.width / 2), y - 62));
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

/// Mini-Map Painter for Top Right Radar
class _MiniMapPainter extends CustomPainter {
  final PocketOpenWorldGame game;

  _MiniMapPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / PocketOpenWorldGame.worldWidth;
    final scaleY = size.height / PocketOpenWorldGame.worldHeight;

    // Road strip
    final roadTop = (PocketOpenWorldGame.streetY - (PocketOpenWorldGame.roadHeight / 2)) * scaleY;
    final roadH = PocketOpenWorldGame.roadHeight * scaleY;
    canvas.drawRect(Rect.fromLTWH(0, roadTop, size.width, roadH), Paint()..color = const Color(0xFF334155));

    // House dots
    for (final node in game.houseNodes) {
      final hx = node.x * scaleX;
      final hy = node.y * scaleY;
      canvas.drawCircle(
        Offset(hx, hy),
        2.5,
        Paint()..color = node.neighbor.hasActiveShield ? const Color(0xFF00F0FF) : const Color(0xFFFF2A55),
      );
    }

    // Player dot (glowing yellow)
    final px = game.playerX * scaleX;
    final py = game.playerY * scaleY;
    canvas.drawCircle(Offset(px, py), 4.5, Paint()..color = const Color(0xFFFFFC00));
    canvas.drawCircle(
      Offset(px, py),
      7.0,
      Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
