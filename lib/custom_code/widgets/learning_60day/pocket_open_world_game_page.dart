import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocket_robot_service.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_painter.dart';
import '../avatar/vector_avatar_widget.dart';
import '../chat/whatsapp_group_chat.dart';
import 'flame_english_house_game.dart';
import 'pocket_citadel_attack_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_world_street_page.dart';

/// 🌍 Pocket Open World: 2D Rolling-Hills Side-Scroller
/// Powered by Flame Engine (`FlameGame`)
///
/// Features:
/// 1. Complete 90-Level World: Houses for all 90 Pocket Robots and human Supabase learners!
/// 2. Authentic 2D Front-Facing English Houses rendered directly via [HouseMasterComponent].
/// 3. Character Avatar Portraits floating over each house roof (replaces empty circles).
/// 4. Minimal, non-intrusive Social HUD: compact action pill [ 💬 Chat | 🤝 Mate | ⚔️ Raid ] when near a gate.
/// 5. Locomotion Modes: 🚶 Walk/Run, 🚲 Sports Bicycle, 🏎️ Pocket Sports Buggy (Car) with full forward & reverse.
/// 6. Player's actual [VectorAvatar] head rendered on the character in all locomotion modes!
/// 7. Living World: Sparkling river with sailing boats, cruising motorboats, leaping fish, and gliding seagulls.
/// 8. Day & Night Cycle with Sun, Moon, Twinkling Stars, and glowing streetlamps.
/// 9. Smooth Camera Zoom: 1.0x (Action Close-Up), 0.65x (Street), 0.22x (Panoramic World Map) + pinch-to-zoom.
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
  double _currentZoom = 0.80;

  // Touch joystick / move state
  Offset? _joystickBase;
  double _joystickDeltaX = 0.0;
  bool _isSprinting = false;

  // Locomotion & Environment
  LocomotionMode _locomotion = LocomotionMode.walk;
  bool _isNightMode = false;

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
      // 1. Fetch Supabase neighbors
      final supaNeighbors = await PocketFortressDefenseService.fetchSupabaseNeighbors(limit: 50);

      // 2. Fetch all 90 procedural Pocket Robots (Levels 1 to 90)
      final allRobots = PocketRobotService.getAll90Robots();
      final List<PocketNeighbor> robotNeighbors = allRobots.map((robot) {
        return PocketNeighbor(
          id: robot.id,
          name: robot.name,
          day: robot.level,
          streak: (robot.level * 1.4).round().clamp(1, 120),
          rank: robot.cefrRank,
          paletteId: robot.housePalette,
          statusMessage: robot.bio,
          isPocketRobo: true,
          hasActiveShield: true,
          isDamaged: false,
          hp: 100,
          maxHp: 100,
        );
      }).toList();

      // 3. Dynamic target homes
      final dynamicTargets = PocketFortressDefenseService.generateDynamicTargetBracketHomes(
        widget.currentDay,
        count: 14,
      );

      // Combine all and deduplicate
      final Map<String, PocketNeighbor> combinedMap = {};
      for (final r in robotNeighbors) {
        combinedMap[r.id] = r;
      }
      for (final d in dynamicTargets) {
        combinedMap[d.id] = d;
      }
      for (final s in supaNeighbors) {
        combinedMap[s.id] = s;
      }

      final combined = combinedMap.values.toList()
        ..sort((a, b) => a.day.compareTo(b.day));

      if (mounted) {
        setState(() {
          _isLoadingNeighbors = false;
        });
        _game.setNeighbors(combined);
      }
    } catch (e) {
      debugPrint('OpenWorld load error: $e');
      if (mounted) {
        final allRobots = PocketRobotService.getAll90Robots();
        final fallback = allRobots.map((robot) {
          return PocketNeighbor(
            id: robot.id,
            name: robot.name,
            day: robot.level,
            streak: (robot.level * 1.4).round(),
            rank: robot.cefrRank,
            paletteId: robot.housePalette,
            statusMessage: robot.bio,
            isPocketRobo: true,
            hasActiveShield: true,
            isDamaged: false,
          );
        }).toList();

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
      _currentZoom = zoom.clamp(0.20, 1.25);
    });
    _game.setZoom(_currentZoom);
  }

  void _toggleDayNight() {
    HapticFeedback.lightImpact();
    setState(() {
      _isNightMode = !_isNightMode;
    });
    _game.setDayNight(_isNightMode);
  }

  void _setLocomotion(LocomotionMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      _locomotion = mode;
    });
    _game.setLocomotionMode(mode);
  }

  void _openChat(PocketNeighbor neighbor) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: neighbor.id,
          groupName: neighbor.name,
          groupImage: null,
        ),
      ),
    );
  }

  void _requestMate(PocketNeighbor neighbor) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🤝', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Learning Mate Request Sent!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Invited ${neighbor.name} (Lvl ${neighbor.day}) to practice English daily.',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
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
      backgroundColor: _isNightMode ? const Color(0xFF030712) : const Color(0xFF0284C7),
      body: GestureDetector(
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            final newZoom = (_currentZoom * details.scale).clamp(0.20, 1.25);
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

                    // Day / Night Toggle
                    GestureDetector(
                      onTap: _toggleDayNight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isNightMode ? const Color(0xFF1E1B4B) : const Color(0xFFFEF08A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isNightMode ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          _isNightMode ? '🌙' : '☀️',
                          style: const TextStyle(fontSize: 14),
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
                              'Street',
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
                    _buildZoomButton(
                      label: '🔍 1.0x',
                      isSelected: _currentZoom >= 0.90,
                      onTap: () => _setZoom(1.0),
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      label: '🏡 0.6x',
                      isSelected: _currentZoom >= 0.45 && _currentZoom < 0.90,
                      onTap: () => _setZoom(0.65),
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      label: '🌍 0.2x',
                      isSelected: _currentZoom < 0.45,
                      onTap: () => _setZoom(0.22),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Locomotion Mode Selector: Walk / Bike / Pocket Buggy (Car)
            Positioned(
              top: 75,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildVehicleButton(
                      icon: '🚶',
                      label: 'Walk',
                      isSelected: _locomotion == LocomotionMode.walk,
                      onTap: () => _setLocomotion(LocomotionMode.walk),
                    ),
                    const SizedBox(height: 4),
                    _buildVehicleButton(
                      icon: '🚲',
                      label: 'Bike',
                      isSelected: _locomotion == LocomotionMode.bike,
                      onTap: () => _setLocomotion(LocomotionMode.bike),
                    ),
                    const SizedBox(height: 4),
                    _buildVehicleButton(
                      icon: '🏎️',
                      label: 'Car',
                      isSelected: _locomotion == LocomotionMode.buggy,
                      onTap: () => _setLocomotion(LocomotionMode.buggy),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Minimal Social HUD Pill (Appears unobtrusively when near a House Gate)
            if (_proximityNeighbor != null)
              Positioned(
                top: 75,
                left: 90,
                right: 75,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  offset: Offset.zero,
                  curve: Curves.easeOutCubic,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _proximityNeighbor!.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Micro Avatar
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: VectorAvatarWidget(
                            config: VectorAvatarConfig.getEvolutionAvatarForStage(_proximityNeighbor!.day),
                            size: 26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Name & Level
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _proximityNeighbor!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Lvl ${_proximityNeighbor!.day} • ${_proximityNeighbor!.hasActiveShield ? "🛡️" : "⚔️"}',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Minimal Action Icons: Chat | Mate | Raid
                        _buildMicroAction(
                          icon: Icons.chat_bubble_rounded,
                          color: const Color(0xFF25D366),
                          tooltip: 'Chat',
                          onTap: () => _openChat(_proximityNeighbor!),
                        ),
                        const SizedBox(width: 5),
                        _buildMicroAction(
                          label: '🤝',
                          color: const Color(0xFF6366F1),
                          tooltip: 'Mate',
                          onTap: () => _requestMate(_proximityNeighbor!),
                        ),
                        const SizedBox(width: 5),
                        _buildMicroAction(
                          label: '⚔️',
                          color: const Color(0xFFFF2A55),
                          tooltip: 'Raid',
                          onTap: () => _launchRaid(_proximityNeighbor!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 6. Left/Right Horizontal Running & Reversing Controller (Bottom Left)
            Positioned(
              bottom: 24,
              left: 20,
              child: Listener(
                onPointerDown: (details) {
                  setState(() {
                    _joystickBase = details.localPosition;
                  });
                },
                onPointerMove: (details) {
                  if (_joystickBase != null) {
                    final dx = details.localPosition.dx - _joystickBase!.dx;
                    final clampedDx = dx.clamp(-55.0, 55.0);
                    setState(() {
                      _joystickDeltaX = clampedDx / 55.0;
                    });
                    _game.setHorizontalInput(_joystickDeltaX, _isSprinting);
                  }
                },
                onPointerUp: (_) {
                  setState(() {
                    _joystickBase = null;
                    _joystickDeltaX = 0.0;
                  });
                  _game.setHorizontalInput(0.0, _isSprinting);
                },
                child: Container(
                  width: 140,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Guide Arrows (Left / Reverse & Right / Forward)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white.withValues(alpha: 0.5), size: 24),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.5), size: 24),
                          ),
                        ],
                      ),
                      // Thumb Handle
                      Transform.translate(
                        offset: Offset(_joystickDeltaX * 36, 0),
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
                          child: Icon(
                            _locomotion == LocomotionMode.buggy
                                ? Icons.directions_car_rounded
                                : (_locomotion == LocomotionMode.bike ? Icons.pedal_bike_rounded : Icons.run_circle_outlined),
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 7. Parabolic JUMP & Sprint Buttons (Bottom Right)
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
                        color: _isSprinting ? const Color(0xFFFF2A55) : const Color(0xFF1E293B),
                        border: Border.all(
                          color: _isSprinting ? Colors.white : Colors.white24,
                          width: 2,
                        ),
                        boxShadow: [
                          if (_isSprinting)
                            BoxShadow(
                              color: const Color(0xFFFF2A55).withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '⚡',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // 🦘 PARABOLIC JUMP BUTTON
                  GestureDetector(
                    onTap: _triggerJump,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F0FF), Color(0xFF0284C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withValues(alpha: 0.55),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🦘', style: TextStyle(fontSize: 22)),
                            Text(
                              'JUMP',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildMicroAction({
    IconData? icon,
    String? label,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 16)
              : Text(label!, style: const TextStyle(fontSize: 14)),
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
          color: isSelected ? const Color(0xFF00F0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildVehicleButton({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFC00) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum LocomotionMode { walk, bike, buggy }

/// 🎮 Flame Game Engine Implementation for 2D Rolling-Hills Side-Scroller
class PocketOpenWorldGame extends FlameGame {
  final int playerDay;
  final int playerStreak;
  final ValueChanged<PocketNeighbor?> onProximityChanged;
  double initialZoom;

  PocketOpenWorldGame({
    required this.playerDay,
    required this.playerStreak,
    required this.onProximityChanged,
    this.initialZoom = 0.80,
  });

  // World Bounds
  double worldWidth = 18000.0;
  final double worldHeight = 1700.0;
  final double groundBaseY = 960.0;

  // Camera & Zoom
  double zoomScale = 0.80;
  double cameraX = 200.0;
  double cameraY = 600.0;

  // Player Physics
  double playerX = 240.0;
  double playerY = 960.0;
  double playerZ = 0.0; // Vertical leap height
  double jumpVelocity = 0.0;
  bool isJumping = false;
  double playerFacing = 1.0; // 1 = right (forward), -1 = left (reverse)
  bool isMoving = false;
  bool isSprinting = false;
  double runCycle = 0.0;
  double bikeWheelAngle = 0.0;
  double carWheelAngle = 0.0;
  double inputDx = 0.0;

  // Environment & Modes
  bool isNight = false;
  LocomotionMode locomotion = LocomotionMode.walk;
  double gameTime = 0.0;

  // District name notifier
  final ValueNotifier<String> districtNotifier = ValueNotifier('🔰 Rookie Village (Lvl 1 - 10)');
  String currentDistrictName = '🔰 Rookie Village (Lvl 1 - 10)';

  // House nodes on the hill
  final List<WorldHouseNode> houseNodes = [];

  // Roaming NPCs
  List<RoamingRobotNpc> robotNpcs = [];

  // Cruising Boats on the living river
  List<CruisingBoat> riverBoats = [];

  // Flying Seagulls
  List<FlyingBird> seagulls = [];

  // Dust & Jump Particle FX
  final List<JumpDustParticle> particles = [];

  // Player Avatar Config & Painter
  late final VectorAvatarPainter playerAvatarPainter;

  @override
  Color backgroundColor() => isNight ? const Color(0xFF030712) : const Color(0xFF0284C7);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    zoomScale = initialZoom;
    playerY = getGroundY(playerX);

    // Prepare player's avatar painter
    playerAvatarPainter = VectorAvatarPainter(
      config: VectorAvatarConfig.getEvolutionAvatarForStage(playerDay),
      showBackgroundAura: false,
    );

    _spawnRoamingRobots();
    _spawnRiverBoatsAndSeagulls();
  }

  void setZoom(double newZoom) {
    zoomScale = newZoom;
  }

  void setDayNight(bool night) {
    isNight = night;
    for (final node in houseNodes) {
      node.houseMaster.lightsOn = isNight || node.neighbor.day >= 20;
    }
  }

  void setLocomotionMode(LocomotionMode mode) {
    locomotion = mode;
  }

  /// ⛰️ Rolling Hills Mathematical Spline
  /// Generates natural curves with crests, gentle slopes, and valleys
  double getGroundY(double x) {
    final wave1 = math.sin(x * 0.0024) * 55.0;
    final wave2 = math.sin(x * 0.0012 + 1.2) * 95.0;
    final wave3 = math.sin(x * 0.0006) * 120.0;
    return groundBaseY - wave1 - wave2 - wave3;
  }

  void setNeighbors(List<PocketNeighbor> list) {
    houseNodes.clear();

    // Dynamically size world width based on count of all 90 robots & users
    worldWidth = math.max(16000.0, (list.length * 190.0) + 1200.0);

    for (int i = 0; i < list.length; i++) {
      final neighbor = list[i];
      // Distribute sequentially along the hills from Level 1 up to Level 90
      final progressRatio = (neighbor.day.clamp(1, 90) - 1) / 89.0;
      final baseX = 220.0 + (progressRatio * (worldWidth - 600.0)) + ((i % 3) * 35.0);
      final x = baseX.clamp(180.0, worldWidth - 250.0);
      final y = getGroundY(x);

      int sectorIndex = 0;
      if (neighbor.day > 60) {
        sectorIndex = 3;
      } else if (neighbor.day > 30) {
        sectorIndex = 2;
      } else if (neighbor.day > 10) {
        sectorIndex = 1;
      }

      houseNodes.add(
        WorldHouseNode(
          neighbor: neighbor,
          x: x,
          y: y,
          sectorIndex: sectorIndex,
          isNight: isNight,
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
        x: 2400,
        y: getGroundY(2400),
        patrolMinX: 1800,
        patrolMaxX: 2900,
        speechText: 'Climb the hills to reach Level 30! ⚡',
      ),
      RoamingRobotNpc(
        id: 'robo_titan',
        name: 'Iron Titan (Lvl 60)',
        x: 7500,
        y: getGroundY(7500),
        patrolMinX: 6800,
        patrolMaxX: 8200,
        speechText: 'Approaching Grandmaster territory! 🛡️',
      ),
      RoamingRobotNpc(
        id: 'robo_prime',
        name: 'Overlord Prime (Lvl 90)',
        x: 14500,
        y: getGroundY(14500),
        patrolMinX: 13500,
        patrolMaxX: 15500,
        speechText: 'The Apex Sovereign Citadel awaits! 👑',
      ),
    ];
  }

  void _spawnRiverBoatsAndSeagulls() {
    riverBoats = [
      CruisingBoat(x: 800, y: groundBaseY + 230, speed: 38, isSailboat: true),
      CruisingBoat(x: 2800, y: groundBaseY + 260, speed: 65, isSailboat: false),
      CruisingBoat(x: 5200, y: groundBaseY + 240, speed: 42, isSailboat: true),
      CruisingBoat(x: 8400, y: groundBaseY + 270, speed: 70, isSailboat: false),
      CruisingBoat(x: 12000, y: groundBaseY + 235, speed: 45, isSailboat: true),
    ];

    seagulls = [
      FlyingBird(x: 400, y: 180, speed: 40),
      FlyingBird(x: 1600, y: 150, speed: 52),
      FlyingBird(x: 3200, y: 210, speed: 35),
      FlyingBird(x: 6500, y: 170, speed: 48),
      FlyingBird(x: 10500, y: 190, speed: 42),
    ];
  }

  void setHorizontalInput(double dx, bool sprint) {
    inputDx = dx;
    isSprinting = sprint;
    isMoving = dx.abs() > 0.08;
    if (dx.abs() > 0.08) {
      // Faces direction of travel (1 = right, -1 = left / reverse)
      playerFacing = dx > 0 ? 1.0 : -1.0;
    }
  }

  void playerJump() {
    if (!isJumping) {
      isJumping = true;
      jumpVelocity = locomotion == LocomotionMode.buggy ? 22.0 : (locomotion == LocomotionMode.bike ? 21.0 : 18.0);

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
    gameTime += dt;

    // 1. Determine speed based on Locomotion Mode
    double baseSpeed = 220.0;
    if (locomotion == LocomotionMode.bike) {
      baseSpeed = 380.0;
    } else if (locomotion == LocomotionMode.buggy) {
      baseSpeed = 480.0;
    }
    final moveSpeed = (isSprinting ? baseSpeed * 1.55 : baseSpeed) * dt;

    // 2. Horizontal Movement (Forward & Reversing)
    if (inputDx.abs() > 0.05) {
      playerX += inputDx * moveSpeed;
      runCycle += dt * (isSprinting ? 18.0 : 12.0);
      bikeWheelAngle += dt * inputDx * 14.0;
      carWheelAngle += dt * inputDx * 18.0;

      // Buggy exhaust particles when driving
      if (locomotion == LocomotionMode.buggy && (gameTime % 0.08) < dt) {
        final groundY = getGroundY(playerX);
        particles.add(
          JumpDustParticle(
            x: playerX - (playerFacing * 28),
            y: groundY - playerZ - 6,
            vx: -playerFacing * 30,
            vy: -12,
          ),
        );
      }
    }
    playerX = playerX.clamp(100.0, worldWidth - 100.0);

    // Lock player to rolling ground curve
    final groundY = getGroundY(playerX);

    // 3. Vertical Jump Physics
    if (isJumping) {
      playerZ += jumpVelocity;
      jumpVelocity -= 0.88; // Gravity
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

    // 4. Update Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].isDead) {
        particles.removeAt(i);
      }
    }

    // 5. Update Roaming Robots
    for (final bot in robotNpcs) {
      bot.update(dt);
      bot.y = getGroundY(bot.x);
    }

    // 6. Update Cruising Boats & Flying Birds
    for (final boat in riverBoats) {
      boat.update(dt, worldWidth);
    }
    for (final bird in seagulls) {
      bird.update(dt, worldWidth);
    }

    // 7. Update Houses (Only nearby houses to guarantee 60fps)
    for (final node in houseNodes) {
      if ((node.x - playerX).abs() < 1800) {
        node.update(dt);
      }
    }

    // 8. Camera Tracking
    final viewportW = size.x / zoomScale;
    final viewportH = size.y / zoomScale;
    final targetCamX = playerX - (viewportW / 2);
    final targetCamY = playerY - (viewportH * 0.65);

    cameraX += (targetCamX - cameraX) * 0.12;
    cameraY += (targetCamY - cameraY) * 0.12;
    cameraX = cameraX.clamp(0.0, math.max(0.0, worldWidth - viewportW));
    cameraY = cameraY.clamp(0.0, math.max(0.0, worldHeight - viewportH));

    // 9. District Check across 90-Level map
    final currentProgress = (playerX / worldWidth).clamp(0.0, 1.0);
    if (currentProgress < 0.15) {
      currentDistrictName = '🔰 Rookie Village (Lvl 1 - 10)';
    } else if (currentProgress < 0.40) {
      currentDistrictName = '🏛️ Intermediate Town (Lvl 11 - 30)';
    } else if (currentProgress < 0.70) {
      currentDistrictName = '⚡ Scholar Heights (Lvl 31 - 60)';
    } else {
      currentDistrictName = '👑 Apex Citadel Peaks (Lvl 61 - 90)';
    }

    if (districtNotifier.value != currentDistrictName) {
      districtNotifier.value = currentDistrictName;
    }

    // 10. Proximity Detection to House Gates
    PocketNeighbor? closest;
    double minDistance = 150.0;

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

    // 1. Sky & Mountain Background
    _drawSkyAndMountains(canvas);

    // 2. Rolling Hills Terrain
    _drawRollingHills(canvas);

    // 3. Living River Water with Cruising Boats & Jumping Fish
    _drawLivingRiver(canvas);

    // 4. Authentic 2D Front-Facing English Houses (rendered directly with HouseMasterComponent)
    final viewportW = size.x / zoomScale;
    final leftBound = cameraX - 250;
    final rightBound = cameraX + viewportW + 250;

    for (final node in houseNodes) {
      if (node.x >= leftBound && node.x <= rightBound) {
        _drawAuthenticEnglishHouse(canvas, node);
      }
    }

    // 5. Roaming Robots
    for (final bot in robotNpcs) {
      if (bot.x >= leftBound && bot.x <= rightBound) {
        _drawRobotNpc(canvas, bot);
      }
    }

    // 6. Dust & Jump Particles
    for (final p in particles) {
      p.render(canvas);
    }

    // 7. 2D Avatar with Selected Locomotion (Walk / Bike / Pocket Buggy)
    _drawPlatformerAvatar(canvas);

    canvas.restore();
  }

  void _drawSkyAndMountains(Canvas canvas) {
    if (isNight) {
      // 🌌 NIGHT SKY
      final skyPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF030712), Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, worldWidth, worldHeight));
      canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), skyPaint);

      // Glowing Crescent Moon
      final moonX = cameraX + (size.x / zoomScale * 0.75);
      const moonY = 160.0;
      final moonPaint = Paint()..color = const Color(0xFFFEF08A);
      canvas.drawCircle(Offset(moonX, moonY), 36, moonPaint);
      canvas.drawCircle(
        Offset(moonX + 10, moonY - 6),
        30,
        Paint()..color = const Color(0xFF0F172A),
      );
      // Soft Moon Glow Halo
      canvas.drawCircle(
        Offset(moonX, moonY),
        55,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );

      // Twinkling Cosmic Stars
      for (double sx = 60; sx < worldWidth; sx += 140) {
        final sy = 80 + (math.sin(sx * 1.5) * 60);
        final twinkle = (math.sin(gameTime * 3.0 + sx) * 0.4) + 0.6;
        canvas.drawCircle(
          Offset(sx, sy),
          1.8 * twinkle,
          Paint()..color = Colors.white.withValues(alpha: 0.85 * twinkle),
        );
      }
    } else {
      // ☀️ DAY SKY
      final skyPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, worldWidth, worldHeight));
      canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), skyPaint);

      // Radiant Glowing Sun
      final sunX = cameraX + (size.x / zoomScale * 0.80);
      const sunY = 140.0;
      canvas.drawCircle(Offset(sunX, sunY), 42, Paint()..color = const Color(0xFFFDE047));
      canvas.drawCircle(
        Offset(sunX, sunY),
        70,
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );

      // Fluffy Cartoon Clouds
      for (double cx = 100; cx < worldWidth; cx += 520) {
        final cy = 120 + (math.sin(cx * 0.8) * 35);
        _drawFluffyCloud(canvas, cx + ((gameTime * 12) % 400), cy);
      }

      // Flying Seagulls
      for (final bird in seagulls) {
        bird.render(canvas);
      }
    }

    // Distant Mountain Ridges (Parallax 0.15x)
    final mountainPath = Path();
    mountainPath.moveTo(0, groundBaseY - 180);
    for (double x = 0; x <= worldWidth; x += 300) {
      final my = groundBaseY - 240 - (math.sin(x * 0.0015) * 140.0);
      mountainPath.lineTo(x, my);
    }
    mountainPath.lineTo(worldWidth, worldHeight);
    mountainPath.lineTo(0, worldHeight);
    mountainPath.close();

    final mountainPaint = Paint()
      ..color = isNight ? const Color(0xFF0B132B) : const Color(0xFF0D9488).withValues(alpha: 0.65);
    canvas.drawPath(mountainPath, mountainPaint);
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(Offset(cx, cy), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 20, cy - 8), 28, cloudPaint);
    canvas.drawCircle(Offset(cx + 45, cy - 4), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 60, cy), 16, cloudPaint);
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
      ..shader = LinearGradient(
        colors: isNight
            ? const [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF030712)]
            : const [Color(0xFF15803D), Color(0xFF166534), Color(0xFF14532D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 400, worldWidth, 1200));
    canvas.drawPath(hillPath, hillPaint);

    // Green Grass Ridge Outline
    final ridgePaint = Paint()
      ..color = isNight ? const Color(0xFF10B981).withValues(alpha: 0.8) : const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;
    canvas.drawPath(hillPath, ridgePaint);

    // Paved Cobblestone Footpath on top of hill curve
    final pathOutline = Paint()
      ..color = (isNight ? const Color(0xFF38BDF8) : const Color(0xFFFDE047)).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawPath(hillPath, pathOutline);

    // Lamp posts along the hills with lighting aura
    for (double x = 160; x < worldWidth; x += 320) {
      final y = getGroundY(x);
      // Pole
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y - 55),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 3.5,
      );
      // Lantern
      canvas.drawCircle(Offset(x, y - 55), 6, Paint()..color = const Color(0xFFFFFC00));
      // Light aura (brighter at night)
      canvas.drawCircle(
        Offset(x, y - 55),
        isNight ? 42 : 24,
        Paint()
          ..color = const Color(0xFFFFFC00).withValues(alpha: isNight ? 0.28 : 0.12)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isNight ? 12 : 6),
      );
    }
  }

  /// 🌊 Draws the Living Water / River with cruising boats & leaping fish
  void _drawLivingRiver(Canvas canvas) {
    final riverTopY = groundBaseY + 180.0;
    final riverRect = Rect.fromLTWH(0, riverTopY, worldWidth, worldHeight - riverTopY);

    // Water Gradient
    final waterPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [Color(0xFF0F2744), Color(0xFF081326), Color(0xFF020712)]
            : const [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(riverRect);
    canvas.drawRect(riverRect, waterPaint);

    // Animated Sinusoidal Water Wave Ripples
    final wavePath = Path();
    wavePath.moveTo(0, riverTopY);
    for (double wx = 0; wx <= worldWidth; wx += 30) {
      final wy = riverTopY + (math.sin((wx * 0.02) + (gameTime * 3.5)) * 4.5);
      wavePath.lineTo(wx, wy);
    }
    final ripplePaint = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: isNight ? 0.25 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(wavePath, ripplePaint);

    // Cruising Boats on the water
    for (final boat in riverBoats) {
      boat.render(canvas, isNight);
    }

    // Leaping Fish animation
    final fishCycle = (gameTime * 0.8) % 6.0;
    if (fishCycle < 1.4) {
      final fx = 1200.0 + ((gameTime * 40.0) % 8000.0);
      final leapHeight = math.sin(fishCycle * math.pi / 1.4) * 32.0;
      final fy = riverTopY - leapHeight;
      // Silver fish
      canvas.drawOval(
        Rect.fromCenter(center: Offset(fx, fy), width: 14, height: 6),
        Paint()..color = const Color(0xFFE2E8F0),
      );
      // Splash rings at base
      canvas.drawOval(
        Rect.fromCenter(center: Offset(fx, riverTopY), width: 18 * (fishCycle / 1.4), height: 4),
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.6),
      );
    }
  }

  /// 🏡 Draws the Authentic 2D Front-Facing English House directly via [HouseMasterComponent]
  /// and draws the character's VectorAvatar portrait directly over the roof!
  void _drawAuthenticEnglishHouse(Canvas canvas, WorldHouseNode node) {
    final x = node.x;
    final groundY = node.y;
    final neighbor = node.neighbor;

    canvas.save();
    // Scale factor so the full Victorian palace / cottage fits comfortably on the rolling hill
    const houseScale = 0.72;
    // HouseMasterComponent centers around cx=190, with base at groundY=320 - 34 = 286
    const cx = 190.0;
    const baseGroundY = 286.0;

    canvas.translate(x, groundY);
    canvas.scale(houseScale, houseScale);
    canvas.translate(-cx, -baseGroundY);

    // Render the real authentic HouseMasterComponent!
    node.houseMaster.render(canvas);

    canvas.restore();

    // --- Overlay Elements (Authentic VectorAvatar Portrait, Shield Bubble, Gate Aura) ---

    // 1. Shimmering Shield Bubble (if active)
    if (neighbor.hasActiveShield) {
      final shieldCenter = Offset(x, groundY - 110);
      canvas.drawCircle(
        shieldCenter,
        105,
        Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(
        shieldCenter,
        105,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 2. Interactive Gate Ring on the Road (when player approaches)
    final distToPlayer = (playerX - x).abs();
    if (distToPlayer < 150) {
      final gatePulse = (math.sin(gameTime * 5.0) * 4.0) + 26.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, groundY + 8), width: gatePulse * 2, height: 16),
        Paint()
          ..color = const Color(0xFFFFFC00).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 3. 👤 Authentic VectorAvatar Portrait Badge Floating Over the Roof
    final avatarCenterY = groundY - 220;
    const avatarRadius = 18.0;

    // Glowing Circular Frame
    canvas.drawCircle(
      Offset(x, avatarCenterY),
      avatarRadius + 3.0,
      Paint()
        ..color = (neighbor.hasActiveShield ? const Color(0xFF00F0FF) : const Color(0xFFFFFC00)).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      Offset(x, avatarCenterY),
      avatarRadius + 2.0,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(
      Offset(x, avatarCenterY),
      avatarRadius + 2.0,
      Paint()
        ..color = neighbor.hasActiveShield ? const Color(0xFF00F0FF) : const Color(0xFFFFFC00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Paint the authentic VectorAvatar
    canvas.save();
    canvas.translate(x - avatarRadius, avatarCenterY - avatarRadius);
    node.avatarPainter.paint(canvas, const Size(avatarRadius * 2, avatarRadius * 2));
    canvas.restore();

    // Tiny Level Badge Pill below avatar
    final levelPillY = avatarCenterY + avatarRadius + 9.0;
    final levelText = 'Lvl ${neighbor.day}';
    final tp = TextPainter(
      text: TextSpan(
        text: levelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pillWidth = tp.width + 12;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, levelPillY), width: pillWidth, height: 15),
      const Radius.circular(6),
    );
    canvas.drawRRect(pillRect, Paint()..color = Colors.black87);
    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    tp.paint(canvas, Offset(x - (tp.width / 2), levelPillY - (tp.height / 2)));
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

  /// 🏃 Draws the 2D Platformer Avatar running / cycling / driving in front of houses
  /// Renders player's actual VectorAvatar portrait on the character's head!
  void _drawPlatformerAvatar(Canvas canvas) {
    final x = playerX;
    final groundY = getGroundY(playerX);
    final avatarY = groundY - playerZ;

    // 1. Drop Shadow on the Ground (scales down as player jumps higher)
    final shadowScale = math.max(0.3, 1.0 - (playerZ / 95.0));
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45 * shadowScale);
    final shadowWidth = locomotion == LocomotionMode.buggy ? 64.0 : 48.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerX, groundY + 4),
        width: shadowWidth * shadowScale,
        height: 15 * shadowScale,
      ),
      shadowPaint,
    );

    canvas.save();
    canvas.translate(x, avatarY - 24);

    // Facing direction: 1 = right (forward), -1 = left (reverse)
    if (playerFacing < 0) {
      canvas.scale(-1.0, 1.0);
    }

    if (locomotion == LocomotionMode.buggy) {
      // 🏎️ POCKET SPORTS BUGGY (CAR)
      _drawSportsBuggy(canvas);
    } else if (locomotion == LocomotionMode.bike) {
      // 🚲 SPORTS BICYCLE
      _drawSportsBicycle(canvas);
    } else {
      // 🚶 ON FOOT RUNNER
      _drawOnFootRunner(canvas);
    }

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
    tp.paint(canvas, Offset(x - (tp.width / 2), avatarY - 78));
  }

  void _drawSportsBuggy(Canvas canvas) {
    // 1. Rotating Wheels & Chrome Rims (Forward & Backward)
    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()
      ..color = const Color(0xFFFFFC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Rear Wheel (-22, 14) & Front Wheel (24, 14)
    for (final wx in [-22.0, 24.0]) {
      canvas.drawCircle(Offset(wx, 14), 10, wheelPaint);
      canvas.drawCircle(Offset(wx, 14), 7, rimPaint);
      // Spokes
      for (int s = 0; s < 4; s++) {
        final a = carWheelAngle + (s * math.pi / 2);
        canvas.drawLine(
          Offset(wx, 14),
          Offset(wx + math.cos(a) * 7, 14 + math.sin(a) * 7),
          Paint()..color = Colors.white70..strokeWidth = 1,
        );
      }
    }

    // 2. Sleek Buggy Chassis (Aerodynamic Sports Body)
    final chassisPath = Path();
    chassisPath.moveTo(-32, 12);
    chassisPath.lineTo(-28, 0);
    chassisPath.lineTo(-12, -4);
    chassisPath.lineTo(16, -4);
    chassisPath.lineTo(34, 4);
    chassisPath.lineTo(36, 12);
    chassisPath.close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF2A55), Color(0xFFDC2626)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-32, -4, 68, 16));
    canvas.drawPath(chassisPath, bodyPaint);

    // Racing Stripe
    canvas.drawLine(const Offset(-30, 6), const Offset(34, 6), Paint()..color = const Color(0xFFFFFC00)..strokeWidth = 2);

    // Roll Cage / Windshield
    final cagePaint = Paint()..color = Colors.white70..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-10, -4), const Offset(-4, -18), cagePaint);
    canvas.drawLine(const Offset(-4, -18), const Offset(14, -6), cagePaint);

    // Glowing Headlight
    canvas.drawCircle(const Offset(34, 6), 3.5, Paint()..color = const Color(0xFFFEF08A));
    // Headlight Beam
    canvas.drawCircle(
      const Offset(42, 6),
      8,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Steering Wheel
    canvas.drawLine(const Offset(8, -4), const Offset(6, -11), Paint()..color = Colors.black..strokeWidth = 2.5);
    canvas.drawCircle(const Offset(6, -11), 3.5, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // 3. Driver's Torso & Player's Authentic VectorAvatar Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -12, 16, 12), const Radius.circular(4)),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Driver's Avatar Head
    const headRadius = 11.0;
    canvas.save();
    canvas.translate(-headRadius + 2, -26 - headRadius);
    playerAvatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();
  }

  void _drawSportsBicycle(Canvas canvas) {
    // 1. Wheels & Rotating Spokes (Forward & Backward)
    final wheelPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final rimPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Front & Rear Wheels
    canvas.drawCircle(const Offset(-18, 16), 11, wheelPaint);
    canvas.drawCircle(const Offset(-18, 16), 8, rimPaint);
    canvas.drawCircle(const Offset(18, 16), 11, wheelPaint);
    canvas.drawCircle(const Offset(18, 16), 8, rimPaint);

    // Rotating Spokes
    for (int s = 0; s < 4; s++) {
      final a = bikeWheelAngle + (s * (math.pi / 2));
      canvas.drawLine(
        const Offset(-18, 16),
        Offset(-18 + math.cos(a) * 8, 16 + math.sin(a) * 8),
        Paint()..color = Colors.white70..strokeWidth = 1,
      );
      canvas.drawLine(
        const Offset(18, 16),
        Offset(18 + math.cos(a) * 8, 16 + math.sin(a) * 8),
        Paint()..color = Colors.white70..strokeWidth = 1,
      );
    }

    // 2. Bike Frame
    final framePaint = Paint()
      ..color = const Color(0xFFFFFC00)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-18, 16), const Offset(-2, 14), framePaint);
    canvas.drawLine(const Offset(-18, 16), const Offset(-8, 2), framePaint);
    canvas.drawLine(const Offset(-2, 14), const Offset(-8, 2), framePaint);
    canvas.drawLine(const Offset(-2, 14), const Offset(12, 4), framePaint);
    canvas.drawLine(const Offset(-8, 2), const Offset(12, 4), framePaint);
    canvas.drawLine(const Offset(12, 4), const Offset(18, 16), framePaint);

    // Saddle & Handlebars
    canvas.drawLine(const Offset(-12, 0), const Offset(-4, 0), Paint()..color = Colors.black..strokeWidth = 4);
    canvas.drawLine(const Offset(12, 4), const Offset(14, -4), Paint()..color = Colors.white..strokeWidth = 3);
    canvas.drawLine(const Offset(10, -4), const Offset(18, -4), Paint()..color = const Color(0xFFFF2A55)..strokeWidth = 3);

    // 3. Rider Torso & Player's Authentic VectorAvatar Head
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-14, -18, 20, 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF0F172A));

    // Avatar Head
    const headRadius = 11.0;
    canvas.save();
    canvas.translate(-4 - headRadius, -24 - headRadius);
    playerAvatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();
  }

  void _drawOnFootRunner(Canvas canvas) {
    // 1. Running legs
    if (isMoving && !isJumping) {
      final legAngle = math.sin(runCycle) * 0.45;
      final legPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(-6, 12), Offset(-6 - (legAngle * 18), 24), legPaint);
      canvas.drawLine(const Offset(6, 12), Offset(6 + (legAngle * 18), 24), legPaint);
    } else {
      final legPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(-6, 12), const Offset(-6, 24), legPaint);
      canvas.drawLine(const Offset(6, 12), const Offset(6, 24), legPaint);
    }

    // 2. Torso
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 2), width: 28, height: 32),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFFC00));
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 3. Player's Authentic VectorAvatar Head
    const headRadius = 13.0;
    canvas.save();
    canvas.translate(-headRadius, -22 - headRadius);
    playerAvatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();
  }
}

/// 🏰 Node representing a neighbor's house positioned on the hill
class WorldHouseNode {
  final PocketNeighbor neighbor;
  final double x;
  final double y;
  final int sectorIndex;
  late final HouseMasterComponent houseMaster;
  late final VectorAvatarPainter avatarPainter;

  WorldHouseNode({
    required this.neighbor,
    required this.x,
    required this.y,
    required this.sectorIndex,
    bool isNight = false,
  }) {
    // Instantiate authentic HouseMasterComponent with exact day/streak/palette/damage logic!
    houseMaster = HouseMasterComponent(
      day: neighbor.day.clamp(1, 90),
      streak: neighbor.hasActiveShield ? 7 : 1,
      palette: HousePalette.getById(neighbor.paletteId),
      isDamaged: neighbor.isDamaged,
    );
    houseMaster.lightsOn = isNight || neighbor.day >= 20;
    houseMaster.resize(Vector2(380, 320));

    // Vector avatar painter for floating roof portrait
    avatarPainter = VectorAvatarPainter(
      config: VectorAvatarConfig.getEvolutionAvatarForStage(neighbor.day),
      showBackgroundAura: false,
    );
  }

  void update(double dt) {
    houseMaster.update(dt);
  }
}

class RoamingRobotNpc {
  final String id;
  final String name;
  double x;
  double y;
  final double patrolMinX;
  final double patrolMaxX;
  double speed = 40.0;
  double facing = 1.0;
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
    x += speed * facing * dt;
    if (x >= patrolMaxX) {
      x = patrolMaxX;
      facing = -1.0;
    } else if (x <= patrolMinX) {
      x = patrolMinX;
      facing = 1.0;
    }
  }
}

/// ⛵ Cruising Boat Model on the Living River
class CruisingBoat {
  double x;
  final double y;
  final double speed;
  final bool isSailboat;

  CruisingBoat({
    required this.x,
    required this.y,
    required this.speed,
    required this.isSailboat,
  });

  void update(double dt, double worldWidth) {
    x += speed * dt;
    if (x > worldWidth + 200) {
      x = -200;
    }
  }

  void render(Canvas canvas, bool isNight) {
    canvas.save();
    canvas.translate(x, y);

    // Hull
    final hullPath = Path();
    hullPath.moveTo(-18, 0);
    hullPath.lineTo(-12, 6);
    hullPath.lineTo(16, 6);
    hullPath.lineTo(22, 0);
    hullPath.close();

    canvas.drawPath(hullPath, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(hullPath, Paint()..color = Colors.black45..style = PaintingStyle.stroke..strokeWidth = 1);

    if (isSailboat) {
      // Mast & Sail
      canvas.drawLine(const Offset(2, 0), const Offset(2, -18), Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.5);
      final sailPath = Path();
      sailPath.moveTo(2, -18);
      sailPath.lineTo(14, -4);
      sailPath.lineTo(2, -4);
      sailPath.close();
      canvas.drawPath(sailPath, Paint()..color = const Color(0xFFFEF08A));
    } else {
      // Cyber Motorboat Cabin & Lantern
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -6, 14, 6), const Radius.circular(2)),
        Paint()..color = const Color(0xFF00F0FF),
      );
    }

    // Wake foam
    canvas.drawOval(
      const Rect.fromLTWH(-28, 4, 14, 3),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    canvas.restore();
  }
}

/// 🕊️ Flying Seagull in the Sky
class FlyingBird {
  double x;
  double y;
  final double speed;
  double wingAngle = 0.0;

  FlyingBird({
    required this.x,
    required this.y,
    required this.speed,
  });

  void update(double dt, double worldWidth) {
    x += speed * dt;
    wingAngle += dt * 8.0;
    if (x > worldWidth + 100) {
      x = -100;
    }
  }

  void render(Canvas canvas) {
    final wingY = math.sin(wingAngle) * 3.5;
    final birdPaint = Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(x - 8, y + wingY);
    path.quadraticBezierTo(x - 4, y - 4, x, y);
    path.quadraticBezierTo(x + 4, y - 4, x + 8, y + wingY);
    canvas.drawPath(path, birdPaint);
  }
}

class JumpDustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life = 0.0;
  final double maxLife = 0.45;

  JumpDustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  bool get isDead => life >= maxLife;

  void update(double dt) {
    life += dt;
    x += vx * dt;
    y += vy * dt;
    vx *= 0.92;
    vy *= 0.92;
  }

  void render(Canvas canvas) {
    final progress = life / maxLife;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final size = 4.5 + (progress * 6.0);
    final paint = Paint()..color = const Color(0xFFFDE047).withValues(alpha: alpha * 0.7);
    canvas.drawCircle(Offset(x, y), size, paint);
  }
}
