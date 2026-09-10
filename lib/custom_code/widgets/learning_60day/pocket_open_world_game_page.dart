import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import '../chat/whatsapp_group_chat.dart';
import 'flame_english_house_game.dart';
import 'pocket_citadel_attack_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_world_street_page.dart';

/// 🌍 Pocket Open World: 2D Side-Scrolling Rolling-Hills Adventure
/// Powered by Flame Engine (`FlameGame`)
///
/// Features:
/// 1. 2D Rolling Hills Terrain with smooth slopes, crests, and valleys.
/// 2. Authentic 2D Front-Facing English Houses rendered directly by [HouseMasterComponent].
/// 3. Level-grouped neighborhoods: Rookie Village, Intermediate Town, Scholar Heights, Apex Citadel Peaks.
/// 4. Day & Night Cycle with Sun, Moon, Twinkling Stars, and glowing streetlamps.
/// 5. Fun Locomotion Modes: 🚶 Walk/Run, 🚲 Cyber Bicycle, 🛹 Neon Hoverboard.
/// 6. Parabolic Jumping physics with landing dust puffs (🦘 JUMP).
/// 7. Social Interaction: 💬 Chat in WhatsAppGroupChat, 🤝 Request Learning Mate, ⚔️ Raid Citadel.
/// 8. Smooth Camera Zoom: 1.0x (Action Close-Up), 0.65x (Street), 0.32x (World Panorama) + pinch-to-zoom.
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
                        child: Row(
                          children: [
                            Text(
                              _isNightMode ? '🌙' : '☀️',
                              style: const TextStyle(fontSize: 14),
                            ),
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
                      isSelected: _currentZoom >= 0.95,
                      onTap: () => _setZoom(1.0),
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      label: '🏡 0.6x',
                      isSelected: _currentZoom >= 0.55 && _currentZoom < 0.95,
                      onTap: () => _setZoom(0.65),
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      label: '🌍 World',
                      isSelected: _currentZoom < 0.55,
                      onTap: () => _setZoom(0.32),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Locomotion Mode Selector (Walk / Bike / Hoverboard)
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
                      icon: '🛹',
                      label: 'Hover',
                      isSelected: _locomotion == LocomotionMode.hoverboard,
                      onTap: () => _setLocomotion(LocomotionMode.hoverboard),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Proximity Social & Raid Card (When standing near a House Gate)
            if (_proximityNeighbor != null)
              Positioned(
                bottom: 125,
                left: 14,
                right: 14,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  offset: Offset.zero,
                  curve: Curves.easeOutCubic,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _proximityNeighbor!.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_proximityNeighbor!.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00))
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Row: Avatar, Name, Level, Shield
                        Row(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: VectorAvatarWidget(
                                config: VectorAvatarConfig.getEvolutionAvatarForStage(_proximityNeighbor!.day),
                                size: 44,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: _proximityNeighbor!.hasActiveShield
                                              ? const Color(0xFF0284C7).withValues(alpha: 0.35)
                                              : const Color(0xFFDC2626).withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _proximityNeighbor!.hasActiveShield ? '🛡️ SHIELDED' : '⚔️ VULNERABLE',
                                          style: GoogleFonts.outfit(
                                            color: _proximityNeighbor!.hasActiveShield
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFFF87171),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'HP: ${_proximityNeighbor!.hp}/100',
                                        style: GoogleFonts.outfit(
                                          color: _proximityNeighbor!.hp > 30
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Action Buttons: Chat | Request Mate | Raid
                        Row(
                          children: [
                            // 💬 Chat Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openChat(_proximityNeighbor!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF25D366).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.chat_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Chat',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 🤝 Request Mate Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _requestMate(_proximityNeighbor!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🤝', style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mate',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ⚔️ Raid Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _launchRaid(_proximityNeighbor!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF2A55), Color(0xFFDC2626)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF2A55).withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('⚔️', style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'RAID',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 13,
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
                      ],
                    ),
                  ),
                ),
              ),

            // 6. Left/Right Horizontal Running Controller (Bottom Left)
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
                      // Guide Arrows
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
                          child: const Icon(Icons.run_circle_outlined, color: Colors.black, size: 28),
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

enum LocomotionMode { walk, bike, hoverboard }

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
  final double worldWidth = 6200.0;
  final double worldHeight = 1600.0;
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
  double playerFacing = 1.0; // 1 = right, -1 = left
  bool isMoving = false;
  bool isSprinting = false;
  double runCycle = 0.0;
  double bikeWheelAngle = 0.0;
  double inputDx = 0.0;

  // Environment & Modes
  bool isNight = false;
  LocomotionMode locomotion = LocomotionMode.walk;
  double gameTime = 0.0;

  // District name notifier
  final ValueNotifier<String> districtNotifier = ValueNotifier('🔰 Rookie Village (Lvl 1 - 5)');
  String currentDistrictName = '🔰 Rookie Village (Lvl 1 - 5)';

  // House nodes on the hill
  final List<WorldHouseNode> houseNodes = [];

  // Roaming NPCs
  List<RoamingRobotNpc> robotNpcs = [];

  // Dust & Jump Particle FX
  final List<JumpDustParticle> particles = [];

  @override
  Color backgroundColor() => isNight ? const Color(0xFF030712) : const Color(0xFF0284C7);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    zoomScale = initialZoom;
    playerY = getGroundY(playerX);
    _spawnRoamingRobots();
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

    // Distribute houses along the rolling hills grouped by level sectors
    for (int i = 0; i < list.length; i++) {
      final neighbor = list[i];
      double x;
      int sectorIndex;
      if (neighbor.day <= 5) {
        // Rookie Village
        sectorIndex = 0;
        x = 220.0 + (i * 240.0).clamp(0.0, 1100.0);
      } else if (neighbor.day <= 11) {
        // Intermediate Town
        sectorIndex = 1;
        x = 1400.0 + ((i - 3).clamp(0, 20) * 260.0);
      } else if (neighbor.day <= 30) {
        // Scholar Heights
        sectorIndex = 2;
        x = 2700.0 + ((i - 6).clamp(0, 20) * 280.0);
      } else {
        // Apex Citadel Peaks
        sectorIndex = 3;
        x = 4200.0 + ((i - 10).clamp(0, 20) * 300.0);
      }
      x = x.clamp(180.0, worldWidth - 250.0);
      final y = getGroundY(x);

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
      jumpVelocity = locomotion == LocomotionMode.bike ? 21.0 : (locomotion == LocomotionMode.hoverboard ? 23.0 : 18.0);

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
    } else if (locomotion == LocomotionMode.hoverboard) {
      baseSpeed = 460.0;
    }
    final moveSpeed = (isSprinting ? baseSpeed * 1.55 : baseSpeed) * dt;

    // 2. Horizontal Movement
    if (inputDx.abs() > 0.05) {
      playerX += inputDx * moveSpeed;
      runCycle += dt * (isSprinting ? 18.0 : 12.0);
      bikeWheelAngle += dt * inputDx * 14.0;
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

    // 6. Update Houses (Only nearby houses to ensure 60fps)
    for (final node in houseNodes) {
      if ((node.x - playerX).abs() < 1800) {
        node.update(dt);
      }
    }

    // 7. Camera Tracking
    final viewportW = size.x / zoomScale;
    final viewportH = size.y / zoomScale;
    final targetCamX = playerX - (viewportW / 2);
    final targetCamY = playerY - (viewportH * 0.65);

    cameraX += (targetCamX - cameraX) * 0.12;
    cameraY += (targetCamY - cameraY) * 0.12;
    cameraX = cameraX.clamp(0.0, math.max(0.0, worldWidth - viewportW));
    cameraY = cameraY.clamp(0.0, math.max(0.0, worldHeight - viewportH));

    // 8. District Check
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

    // 9. Proximity Detection to House Gates
    PocketNeighbor? closest;
    double minDistance = 140.0;

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

    // 1. Draw Sky & Mountain Background with Day/Night cycle
    _drawSkyAndMountains(canvas);

    // 2. Draw Rolling Hills Terrain
    _drawRollingHills(canvas);

    // 3. Draw Authentic 2D Front-Facing English Houses (rendered directly with HouseMasterComponent)
    final viewportW = size.x / zoomScale;
    final leftBound = cameraX - 250;
    final rightBound = cameraX + viewportW + 250;

    for (final node in houseNodes) {
      if (node.x >= leftBound && node.x <= rightBound) {
        _drawAuthenticEnglishHouse(canvas, node);
      }
    }

    // 4. Draw Roaming Robots
    for (final bot in robotNpcs) {
      if (bot.x >= leftBound && bot.x <= rightBound) {
        _drawRobotNpc(canvas, bot);
      }
    }

    // 5. Draw Particles
    for (final p in particles) {
      p.render(canvas);
    }

    // 6. Draw 2D Avatar with Selected Locomotion (Walk / Bike / Hoverboard)
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

      // Glowing Crescent Moon (follows camera smoothly in parallax)
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
    }

    // Distant Mountain Ridges (Layer 1: Far Parallax 0.15x)
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

  /// 🏡 Draws the Authentic 2D Front-Facing English House directly via [HouseMasterComponent]
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

    // --- Overlay Elements (Level Badge, Owner Banner, Shield Bubble) ---

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
    if (distToPlayer < 140) {
      final gatePulse = (math.sin(gameTime * 5.0) * 4.0) + 26.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, groundY + 8), width: gatePulse * 2, height: 16),
        Paint()
          ..color = const Color(0xFFFFFC00).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 3. Floating Owner Name Banner
    final bannerY = groundY - 215;
    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, bannerY), width: 150, height: 26),
      const Radius.circular(8),
    );
    canvas.drawRRect(bannerRect, Paint()..color = Colors.black.withValues(alpha: 0.85));
    canvas.drawRRect(
      bannerRect,
      Paint()
        ..color = (neighbor.hasActiveShield ? const Color(0xFF00F0FF) : const Color(0xFFFFFC00)).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final title = '${neighbor.name} (Lvl ${neighbor.day})';
    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: 140);
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

  /// 🏃 Draws the 2D Platformer Avatar running/cycling/hovering in front of houses
  void _drawPlatformerAvatar(Canvas canvas) {
    final x = playerX;
    final groundY = getGroundY(playerX);
    final avatarY = groundY - playerZ;

    // 1. Drop Shadow on the Ground (scales down as player jumps higher)
    final shadowScale = math.max(0.3, 1.0 - (playerZ / 95.0));
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45 * shadowScale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerX, groundY + 4),
        width: 48 * shadowScale,
        height: 15 * shadowScale,
      ),
      shadowPaint,
    );

    canvas.save();
    canvas.translate(x, avatarY - 24);

    // Facing direction
    if (playerFacing < 0) {
      canvas.scale(-1.0, 1.0);
    }

    if (locomotion == LocomotionMode.bike) {
      // 🚲 BICYCLE MOUNT
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

      // Spokes (rotating with movement)
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

      // Bike Frame (Triangular Sports Frame)
      final framePaint = Paint()
        ..color = const Color(0xFFFFFC00)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-18, 16), const Offset(-2, 14), framePaint); // Bottom bracket
      canvas.drawLine(const Offset(-18, 16), const Offset(-8, 2), framePaint); // Seat stay
      canvas.drawLine(const Offset(-2, 14), const Offset(-8, 2), framePaint); // Seat tube
      canvas.drawLine(const Offset(-2, 14), const Offset(12, 4), framePaint); // Down tube
      canvas.drawLine(const Offset(-8, 2), const Offset(12, 4), framePaint); // Top tube
      canvas.drawLine(const Offset(12, 4), const Offset(18, 16), framePaint); // Fork

      // Saddle & Handlebars
      canvas.drawLine(const Offset(-12, 0), const Offset(-4, 0), Paint()..color = Colors.black..strokeWidth = 4);
      canvas.drawLine(const Offset(12, 4), const Offset(14, -4), Paint()..color = Colors.white..strokeWidth = 3);
      canvas.drawLine(const Offset(10, -4), const Offset(18, -4), Paint()..color = const Color(0xFFFF2A55)..strokeWidth = 3);

      // Rider Body on Saddle
      final bodyRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-16, -20, 24, 22),
        const Radius.circular(8),
      );
      canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawRRect(bodyRect, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2);

      // Head & Visor
      canvas.drawCircle(const Offset(-4, -28), 10, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, -32, 10, 6), const Radius.circular(3)),
        Paint()..color = const Color(0xFF00F0FF),
      );
    } else if (locomotion == LocomotionMode.hoverboard) {
      // 🛹 NEON HOVERBOARD MOUNT
      final boardY = 16.0 + (math.sin(gameTime * 7.0) * 3.0);

      // Neon Thruster Glow under board
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, boardY + 6), width: 54, height: 10),
        Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Deck
      final deckRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, boardY), width: 56, height: 8),
        const Radius.circular(4),
      );
      canvas.drawRRect(deckRect, Paint()..color = const Color(0xFF0F172A));
      canvas.drawRRect(
        deckRect,
        Paint()
          ..color = const Color(0xFF00F0FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Surfer Body
      final bodyRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, boardY - 24), width: 28, height: 36),
        const Radius.circular(10),
      );
      canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawRRect(bodyRect, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2);

      // Visor
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(2, boardY - 32, 12, 7), const Radius.circular(3)),
        Paint()..color = const Color(0xFF00F0FF),
      );
    } else {
      // 🚶 ON FOOT RUNNER
      // Running legs
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

      // Torso
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
    }

    // Floating Golden Level Star over Head
    canvas.drawCircle(const Offset(0, -42), 6, Paint()..color = const Color(0xFFFFD700));

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
}

/// 🏰 Node representing a neighbor's house positioned on the hill
class WorldHouseNode {
  final PocketNeighbor neighbor;
  final double x;
  final double y;
  final int sectorIndex;
  late final HouseMasterComponent houseMaster;

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
