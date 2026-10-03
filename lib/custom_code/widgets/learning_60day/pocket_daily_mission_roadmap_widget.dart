import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../admin_auth_service.dart';
import '../avatar/flame_avatar_widget.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'flame_english_house_game.dart';

/// 🗺️ Data Model for each Step Node along the Daily Mission Roadmap
class RoadmapStepItem {
  final int stepNumber;
  final String icon;
  final String title;
  final String category;
  final String subtitle;
  final Color accentColor;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isActive;
  final VoidCallback onAction;
  final VoidCallback onToggleComplete;

  const RoadmapStepItem({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.accentColor,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isActive,
    required this.onAction,
    required this.onToggleComplete,
  });
}

/// 🌄 Pocket Daily Mission Roadmap Widget
/// Modernized Gamified Path Architecture (Audio Directive):
/// - Clean, minimal serpentine path (Duolingo / Candy Crush / Target Master Hub style).
/// - Completely responsive without horizontal card overflow on mobile screens.
/// - Step-by-step sequential unlocking (Part 1 -> Part 2 -> Part 3).
/// - Master Admin Bypass (musabthonippadam@gmail.com): All steps instantly unlocked for rapid developer testing.
/// - Moving Avatar along the path: Day 1 features Cyber Cat moving to the active step as each part is cleared.
/// - Destination: Day 2 Level 2 Home rendered at the bottom using Flame (FlameEnglishHouseWidget).
/// - Stage Evolution: When all steps are cleared, Cyber Cat enters the Level 2 house and evolves into Cyber Fox using Flame!
class PocketDailyMissionRoadmapWidget extends StatefulWidget {
  final int day;
  final List<RoadmapStepItem> steps;
  final int completedCount;
  final int totalCount;
  final int points;
  final bool hasPassedToday;
  final bool isTimerCompleted;
  final String timerDisplay;
  final bool isTimerRunning;
  final VoidCallback onToggleTimer;
  final VoidCallback onClaimReward;
  final VoidCallback onSwitchToListView;

  const PocketDailyMissionRoadmapWidget({
    super.key,
    required this.day,
    required this.steps,
    required this.completedCount,
    required this.totalCount,
    required this.points,
    required this.hasPassedToday,
    required this.isTimerCompleted,
    required this.timerDisplay,
    required this.isTimerRunning,
    required this.onToggleTimer,
    required this.onClaimReward,
    required this.onSwitchToListView,
  });

  @override
  State<PocketDailyMissionRoadmapWidget> createState() =>
      _PocketDailyMissionRoadmapWidgetState();
}

class _PocketDailyMissionRoadmapWidgetState
    extends State<PocketDailyMissionRoadmapWidget>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _bobController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  /// Calculates safe, bounded X coordinate for step nodes along a smooth S-curve
  double _getNodeX(int index, double screenWidth) {
    final center = screenWidth / 2;
    // Safe amplitude that guarantees 0% overflow on any screen width (320px–500px+)
    final maxAmp = ((screenWidth - 140) / 2).clamp(36.0, 78.0);
    // Sinusoidal wave: alternating left (-1) and right (+1)
    final sign = (index % 2 == 0) ? -1.0 : 1.0;
    final variation = (index % 4 == 0 || index % 4 == 3) ? 0.78 : 0.98;
    return center + (sign * maxAmp * variation);
  }

  /// Calculates Y coordinate for step nodes
  double _getNodeY(int index) {
    return 190.0 + (index * 135.0);
  }

  @override
  Widget build(BuildContext context) {
    final stepCount = widget.steps.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMasterAdmin = AdminAuthService.isCurrentMasterAdmin();

    // Calculate total height: top HUD (190) + steps spacing (~135 per step) + bottom Flame house section (740)
    final double mapTotalHeight = 200.0 + (stepCount * 135.0) + 740.0;

    // Active player avatar for this day (Day 1: Cyber Cat)
    final currentAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(widget.day);
    // Next evolved avatar (Day 1 -> Day 2: Cyber Fox)
    final evolvedAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(widget.day + 1);

    // Determine the active step index for avatar positioning
    int activeIndex = widget.steps.indexWhere((s) => s.isActive);
    if (activeIndex == -1) {
      activeIndex = widget.steps.indexWhere((s) => !s.isCompleted);
    }
    final bool allDone = widget.hasPassedToday ||
        (widget.totalCount > 0 && widget.completedCount >= widget.totalCount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_ambientController, _bobController]),
        builder: (context, child) {
          return SizedBox(
            width: screenWidth,
            height: mapTotalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Scenic 2D Landscape Background Canvas (Sky, Sun, Mountains, River & Trail)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MissionRoadmapLandscapePainter(
                      ambientProg: _ambientController.value,
                      stepCount: stepCount,
                      completedCount: widget.completedCount,
                      totalHeight: mapTotalHeight,
                      isAllCompleted: allDone,
                      day: widget.day,
                      screenWidth: screenWidth,
                      getNodeX: (idx) => _getNodeX(idx, screenWidth),
                      getNodeY: _getNodeY,
                    ),
                  ),
                ),

                // 2. Top Floating Header HUD (Day, Progress, Timer, Admin badge, List view switcher)
                Positioned(
                  top: 10,
                  left: 14,
                  right: 14,
                  child: _buildFloatingMapHeader(isMasterAdmin),
                ),

                // 3. Step Milestone Nodes plotted down the serpentine trail
                ...List.generate(stepCount, (index) {
                  final step = widget.steps[index];
                  final nodeX = _getNodeX(index, screenWidth);
                  final nodeY = _getNodeY(index);
                  final isDone = step.isCompleted;
                  final isUnlocked = step.isUnlocked || isMasterAdmin;
                  final isActive = (index == activeIndex) && !allDone;

                  return Positioned(
                    top: nodeY - 32.0,
                    left: 0,
                    right: 0,
                    child: _buildRoadmapStepNode(
                      step: step,
                      nodeX: nodeX,
                      isDone: isDone,
                      isUnlocked: isUnlocked,
                      isActive: isActive,
                      isMasterAdmin: isMasterAdmin,
                      ambientProg: _ambientController.value,
                    ),
                  );
                }),

                // 4. Moving Character Avatar (Cyber Cat for Day 1) walking along the path
                if (!allDone && activeIndex >= 0 && activeIndex < stepCount)
                  _buildWalkingAvatar(
                    avatarConfig: currentAvatar,
                    nodeX: _getNodeX(activeIndex, screenWidth),
                    nodeY: _getNodeY(activeIndex),
                    activeStepNumber: activeIndex + 1,
                  ),

                // 5. Destination: Level 2 Home using Flame & Evolution Celebration at bottom
                Positioned(
                  bottom: 24,
                  left: 14,
                  right: 14,
                  child: _buildBottomHouseDestinationCard(
                    allDone: allDone,
                    currentAvatar: currentAvatar,
                    evolvedAvatar: evolvedAvatar,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🌟 Top Floating Header HUD
  Widget _buildFloatingMapHeader(bool isMasterAdmin) {
    final progressPct = widget.totalCount > 0
        ? (widget.completedCount / widget.totalCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Day Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFC00), Color(0xFFFFB703)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  'DAY ${widget.day} MAP',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive English Journey',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.completedCount} of ${widget.totalCount} Steps Cleared • ${widget.points} PTS',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF86EFAC),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Practice Timer Button
              InkWell(
                onTap: widget.onToggleTimer,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.isTimerRunning
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : (widget.isTimerCompleted
                            ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                            : Colors.white10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.isTimerRunning
                          ? const Color(0xFF10B981)
                          : (widget.isTimerCompleted
                              ? const Color(0xFF38BDF8)
                              : Colors.white24),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isTimerRunning
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: widget.isTimerRunning
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFFD700),
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.timerDisplay,
                        style: GoogleFonts.firaCode(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // View Switcher to Classic List
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.view_agenda_rounded,
                    color: Colors.white70, size: 20),
                tooltip: 'Switch to Classic List',
                onPressed: widget.onSwitchToListView,
              ),
            ],
          ),


          const SizedBox(height: 8),
          // Gradient Progress Line
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: progressPct,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressPct >= 1.0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 Individual Step Milestone Node along the Winding Trail (Duolingo / Candy Crush Style)
  Widget _buildRoadmapStepNode({
    required RoadmapStepItem step,
    required double nodeX,
    required bool isDone,
    required bool isUnlocked,
    required bool isActive,
    required bool isMasterAdmin,
    required double ambientProg,
  }) {
    // Pulse animation for the active step
    final pulseScale =
        isActive ? (1.0 + (math.sin(ambientProg * 2 * math.pi) * 0.08)) : 1.0;

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 110,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Circular Milestone Stepping Stone
            Positioned(
              left: nodeX - 32.0,
              top: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        HapticFeedback.mediumImpact();
                        step.onAction();
                      } else {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Text('🔒', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Part ${step.stepNumber} is locked! Complete Part ${step.stepNumber - 1} first.',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1E293B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Transform.scale(
                      scale: pulseScale,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDone
                              ? const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : (isActive
                                  ? LinearGradient(
                                      colors: [
                                        step.accentColor,
                                        step.accentColor.withValues(alpha: 0.75),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF1E293B),
                                        Color(0xFF0F172A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )),
                          border: Border.all(
                            color: isDone
                                ? const Color(0xFF34D399)
                                : (isActive
                                    ? const Color(0xFFFFFC00)
                                    : Colors.white24),
                            width: (isActive || isDone) ? 2.8 : 1.6,
                          ),
                          boxShadow: [
                            if (isActive)
                              BoxShadow(
                                color: step.accentColor.withValues(alpha: 0.55),
                                blurRadius: 18,
                                spreadRadius: 3,
                              ),
                            if (isDone)
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              isUnlocked ? step.icon : '🔒',
                              style: TextStyle(
                                fontSize: isUnlocked ? 28 : 22,
                              ),
                            ),
                            // Top step tag badge
                            Positioned(
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? const Color(0xFF047857)
                                      : (isActive
                                          ? Colors.black
                                          : const Color(0xFF334155)),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDone
                                        ? const Color(0xFF34D399)
                                        : (isActive
                                            ? const Color(0xFFFFFC00)
                                            : Colors.white24),
                                    width: 0.9,
                                  ),
                                ),
                                child: Text(
                                  isDone
                                      ? '✓ DONE'
                                      : 'PART ${step.stepNumber}',
                                  style: GoogleFonts.outfit(
                                    color: isDone
                                        ? Colors.white
                                        : (isActive
                                            ? const Color(0xFFFFFC00)
                                            : Colors.white70),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Minimal Label Pill below the orb (Responsive & clean)
                  GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        HapticFeedback.lightImpact();
                        step.onAction();
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 140),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDone
                              ? const Color(0xFF10B981).withValues(alpha: 0.6)
                              : (isActive
                                  ? step.accentColor.withValues(alpha: 0.8)
                                  : Colors.white12),
                          width: isActive ? 1.3 : 0.9,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              step.title,
                              style: GoogleFonts.outfit(
                                color: isUnlocked ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Quick toggle checkbox
                          InkWell(
                            onTap: step.onToggleComplete,
                            child: Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : Colors.white30,
                              size: 13,
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

  /// 🐾 Walking Animated Character Avatar indicator at the active step
  Widget _buildWalkingAvatar({
    required VectorAvatarConfig avatarConfig,
    required double nodeX,
    required double nodeY,
    required int activeStepNumber,
  }) {
    final bobY = math.sin(_bobController.value * math.pi) * 8.0;

    return Positioned(
      left: nodeX - 44.0,
      top: nodeY - 96.0,
      child: Transform.translate(
        offset: Offset(0, -bobY),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Speech bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    'Part $activeStepNumber • Cyber Cat',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Avatar Orb
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFFC00),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipOval(
                child: VectorAvatarWidget(
                  config: avatarConfig,
                  size: 46,
                  showAura: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏰 Bottom Level 2 English House Destination Card using Flame & Evolution Celebration
  Widget _buildBottomHouseDestinationCard({
    required bool allDone,
    required VectorAvatarConfig currentAvatar,
    required VectorAvatarConfig evolvedAvatar,
  }) {
    final targetDay = widget.day + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: allDone
              ? const Color(0xFF10B981)
              : const Color(0xFFFFD700).withValues(alpha: 0.55),
          width: allDone ? 2.2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (allDone ? const Color(0xFF10B981) : const Color(0xFFFFD700))
                .withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Destination Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: allDone
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFFFD700).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: allDone
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFD700),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    allDone ? '👑' : '🏡',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone
                          ? 'STAGE 1 COMPLETE • LEVEL $targetDay UNLOCKED!'
                          : 'DESTINATION: LEVEL $targetDay COTTAGE',
                      style: GoogleFonts.outfit(
                        color: allDone
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFFD700),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allDone
                          ? 'Cyber Cat arrived and evolved into Cyber Fox! Tap below to claim your rewards & enter Day $targetDay.'
                          : 'Complete Part 1, 2, 3... along the roadmap to march Cyber Cat into your Level $targetDay Home!',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 🏡 The Level 2 English House rendered using Flame!
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white12,
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlameEnglishHouseWidget(
                currentDay: targetDay,
                streak: 1,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 🧬 Flame Evolution Reveal Showcase when completed!
          if (allDone) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B0764), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'EVOLUTION UNLOCKED: CYBER FOX!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stage 1 Cyber Cat
                      Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                            child: ClipOval(
                              child: VectorAvatarWidget(
                                config: currentAvatar,
                                size: 54,
                                showAura: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stage 1: Cyber Cat',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Color(0xFFFFFC00), size: 22),
                      const SizedBox(width: 14),
                      // Stage 2 Cyber Fox (Flame powered!)
                      Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFFC00),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: FlameAvatarWidget(
                                config: evolvedAvatar,
                                size: 60,
                                showAura: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stage 2: Cyber Fox 🦊',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Claim & Advance Action Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: allDone ? widget.onClaimReward : null,
              icon: Icon(
                allDone ? Icons.celebration_rounded : Icons.lock_outline_rounded,
                color: allDone ? Colors.black : Colors.white38,
                size: 20,
              ),
              label: Text(
                allDone
                    ? 'CLAIM DAY ${widget.day} REWARDS (+200 PTS & ADVANCE)'
                    : 'COMPLETE ALL STEPS TO ADVANCE (${widget.completedCount}/${widget.totalCount})',
                style: GoogleFonts.outfit(
                  color: allDone ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: allDone
                    ? const Color(0xFFFFFC00)
                    : const Color(0xFF1E293B),
                disabledBackgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: allDone ? 6 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 CustomPainter for Scenic Background:
/// - Top Sky with Sun, Fluffy Clouds & Birds
/// - Distant Layered Mountains & Rolling Foothills
/// - Lush Green Meadow with Flowerbeds & Trees
/// - Winding Trail passing precisely through each Step Node
class _MissionRoadmapLandscapePainter extends CustomPainter {
  final double ambientProg;
  final int stepCount;
  final int completedCount;
  final double totalHeight;
  final bool isAllCompleted;
  final int day;
  final double screenWidth;
  final double Function(int) getNodeX;
  final double Function(int) getNodeY;

  _MissionRoadmapLandscapePainter({
    required this.ambientProg,
    required this.stepCount,
    required this.completedCount,
    required this.totalHeight,
    required this.isAllCompleted,
    required this.day,
    required this.screenWidth,
    required this.getNodeX,
    required this.getNodeY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = screenWidth;
    final h = totalHeight;

    // 1. SKY GRADIENT (Upper section down to mountains)
    final skyHeight = math.min(h * 0.28, 450.0);
    final skyShader = const LinearGradient(
      colors: [
        Color(0xFF0284C7), // Deep Azure
        Color(0xFF38BDF8), // Vibrant Sky Cyan
        Color(0xFFBAE6FD), // Horizon Mist
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, skyHeight));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, skyHeight), Paint()..shader = skyShader);

    // ☀️ Radiant Sun with Glowing Aura
    final sunCenter = Offset(w * 0.82, 110.0);
    canvas.drawCircle(
      sunCenter,
      50,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(
      sunCenter,
      32,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(sunCenter, 20, Paint()..color = const Color(0xFFFEF08A));

    // ☁️ Drifting Fluffy Clouds
    final cloudShift = math.sin(ambientProg * 2 * math.pi) * 14.0;
    _drawFluffyCloud(canvas, w * 0.18 + cloudShift, 120, 20);
    _drawFluffyCloud(canvas, w * 0.54 - cloudShift, 160, 16);
    _drawFluffyCloud(canvas, w * 0.88 + cloudShift, 200, 18);

    // 🕊️ Flying Birds in V-Formation
    _drawFlyingBird(canvas, w * 0.28, 140, 13, ambientProg: ambientProg, phase: 0.0);
    _drawFlyingBird(canvas, w * 0.35, 125, 10, ambientProg: ambientProg, phase: 0.25);
    _drawFlyingBird(canvas, w * 0.42, 135, 11, ambientProg: ambientProg, phase: 0.5);

    // 🏔️ 2. Distant Majestic Mountain Ranges
    final mountainBaseY = skyHeight - 40;
    final mPath = Path();
    mPath.moveTo(0, mountainBaseY);
    mPath.lineTo(w * 0.12, mountainBaseY - 60);
    mPath.lineTo(w * 0.28, mountainBaseY - 120); // Peak 1
    mPath.lineTo(w * 0.45, mountainBaseY - 55);
    mPath.lineTo(w * 0.62, mountainBaseY - 135); // Peak 2
    mPath.lineTo(w * 0.78, mountainBaseY - 65);
    mPath.lineTo(w * 0.90, mountainBaseY - 110); // Peak 3
    mPath.lineTo(w, mountainBaseY - 45);
    mPath.lineTo(w, h);
    mPath.lineTo(0, h);
    mPath.close();

    final mountainPaint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: 0.42);
    canvas.drawPath(mPath, mountainPaint);

    // 🌲 3. Rolling Lush Green Foothills & Pastures (Filling rest of map)
    final greenBaseY = skyHeight - 20;
    final hillPath = Path();
    hillPath.moveTo(0, greenBaseY);
    hillPath.quadraticBezierTo(w * 0.3, greenBaseY - 30, w * 0.6, greenBaseY - 10);
    hillPath.quadraticBezierTo(w * 0.85, greenBaseY + 15, w, greenBaseY);
    hillPath.lineTo(w, h);
    hillPath.lineTo(0, h);
    hillPath.close();

    final hillShader = const LinearGradient(
      colors: [
        Color(0xFF15803D), // Emerald Green
        Color(0xFF166534), // Forest Green
        Color(0xFF14532D), // Deep Woodland Green
        Color(0xFF052E16), // Dark Earth Green
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, greenBaseY - 30, w, h - greenBaseY + 30));

    canvas.drawPath(hillPath, Paint()..shader = hillShader);

    // 🌸 Wildflowers and Little Trees along edges
    _drawScenicFlora(canvas, w, h);

    // 🛤️ 4. Winding Adventure Cobblestone Trail connecting step nodes
    _drawWindingTrail(canvas, w, h);
  }

  /// Drifts fluffy white cumulus cloud
  void _drawFluffyCloud(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawCircle(Offset(cx - (r * 0.7), cy + (r * 0.2)), r * 0.75, p);
    canvas.drawCircle(Offset(cx + (r * 0.75), cy + (r * 0.15)), r * 0.8, p);
    canvas.drawCircle(Offset(cx + (r * 0.35), cy - (r * 0.4)), r * 0.65, p);
  }

  /// Little flapping bird
  void _drawFlyingBird(Canvas canvas, double x, double y, double span,
      {required double ambientProg, required double phase}) {
    final wingCycle = math.sin((ambientProg * 6 * math.pi) + (phase * 2 * math.pi));
    final wingY = y + (wingCycle * 3.5);

    final birdPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(x - span, wingY);
    path.quadraticBezierTo(x - (span * 0.5), y - 2, x, y);
    path.quadraticBezierTo(x + (span * 0.5), y - 2, x + span, wingY);
    canvas.drawPath(path, birdPaint);
  }

  /// Wildflowers and foliage decorating the hillsides
  void _drawScenicFlora(Canvas canvas, double w, double h) {
    for (int i = 0; i < 12; i++) {
      final tx = (i % 2 == 0) ? (w * 0.08) + (i * 2) : w * 0.92 - (i * 2);
      final ty = 340.0 + (i * 220.0);
      if (ty < h - 550) {
        _drawMiniTree(canvas, tx, ty, scale: 0.85);
      }
    }

    final flowerPaint1 = Paint()..color = const Color(0xFFEF4444);
    final flowerPaint2 = Paint()..color = const Color(0xFFFACC15);
    final flowerPaint3 = Paint()..color = Colors.white;

    for (int i = 0; i < 30; i++) {
      final fx = (i * 67.0) % (w - 40) + 20;
      final fy = 400.0 + (i * 120.0);
      if (fy < h - 550) {
        final fColor = (i % 3 == 0)
            ? flowerPaint1
            : (i % 3 == 1 ? flowerPaint2 : flowerPaint3);
        canvas.drawCircle(Offset(fx, fy), 2.2, fColor);
      }
    }
  }

  void _drawMiniTree(Canvas canvas, double x, double y, {double scale = 1.0}) {
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - (18 * scale)),
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 3.5 * scale,
    );
    canvas.drawCircle(
      Offset(x, y - (24 * scale)),
      11 * scale,
      Paint()..color = const Color(0xFF166534),
    );
    canvas.drawCircle(
      Offset(x, y - (28 * scale)),
      8 * scale,
      Paint()..color = const Color(0xFF22C55E),
    );
  }

  /// Winding Cobblestone Adventure Road passing precisely through each step node
  void _drawWindingTrail(Canvas canvas, double w, double h) {
    if (stepCount == 0) return;

    final trailPath = Path();
    final firstNodeX = getNodeX(0);
    final firstNodeY = getNodeY(0);

    // Trail starts from just beneath the header
    trailPath.moveTo(w * 0.5, 140.0);
    trailPath.cubicTo(w * 0.5, 160.0, firstNodeX, firstNodeY - 40, firstNodeX, firstNodeY);

    for (int i = 0; i < stepCount - 1; i++) {
      final p1X = getNodeX(i);
      final p1Y = getNodeY(i);
      final p2X = getNodeX(i + 1);
      final p2Y = getNodeY(i + 1);
      final midY = (p1Y + p2Y) / 2;

      trailPath.cubicTo(p1X, midY, p2X, midY, p2X, p2Y);
    }

    // Connect from last step down toward the destination house
    final lastNodeX = getNodeX(stepCount - 1);
    final lastNodeY = getNodeY(stepCount - 1);
    final houseTopY = h - 680.0;

    trailPath.cubicTo(lastNodeX, lastNodeY + 60, w * 0.5, houseTopY - 40, w * 0.5, houseTopY);

    // Trail base shadow
    canvas.drawPath(
      trailPath,
      Paint()
        ..color = const Color(0xFF78350F).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round,
    );

    // Cobblestone dirt path
    canvas.drawPath(
      trailPath,
      Paint()
        ..color = const Color(0xFFD97706).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );

    // Glowing waypoint center line (golden/cyan)
    canvas.drawPath(
      trailPath,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MissionRoadmapLandscapePainter oldDelegate) {
    return oldDelegate.ambientProg != ambientProg ||
        oldDelegate.completedCount != completedCount ||
        oldDelegate.isAllCompleted != isAllCompleted ||
        oldDelegate.screenWidth != screenWidth;
  }
}
