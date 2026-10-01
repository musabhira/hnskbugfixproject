import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
/// Audio Directive Implementation:
/// - Replaces confusing 17-card vertical list with an intuitive gamified journey map!
/// - Top background: Sky with sun, clouds, birds.
/// - Middle: Layered mountains, rolling green hills, winding trail connecting step nodes.
/// - Bottom: Beautiful Level 1 English Cottage / House with chimney smoke, lit windows, picket fence.
/// - Strictly NO Flame game engine used — 100% smooth, lightweight Flutter Canvas CustomPainter.
/// - Step-by-step unlock: Step 1 is unlocked. Tapping opens reading/activity. On completion, Step 2 unlocks!
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
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }


  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepCount = widget.steps.length;
    // Calculate total height: top sky (260) + steps spacing (~135 per step) + bottom house section (460)
    final double mapTotalHeight = 300.0 + (stepCount * 140.0) + 480.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) {
          return SizedBox(
            height: mapTotalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Scenic 2D Landscape Background Canvas (Sky, Mountains, Rolling Hills, River & Trail)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MissionRoadmapLandscapePainter(
                      ambientProg: _ambientController.value,
                      stepCount: stepCount,
                      completedCount: widget.completedCount,
                      totalHeight: mapTotalHeight,
                      isAllCompleted: widget.hasPassedToday,
                      day: widget.day,
                    ),
                  ),
                ),

                // 2. Map Floating Header HUD (Timer, Progress, View Switcher)
                Positioned(
                  top: 10,
                  left: 14,
                  right: 14,
                  child: _buildFloatingMapHeader(),
                ),

                // 3. Step Milestone Nodes plotted down the winding trail
                ...List.generate(stepCount, (index) {
                  final step = widget.steps[index];
                  final nodeY = 320.0 + (index * 140.0);
                  // Alternating serpentine offset (left, center-left, center-right, right...)
                  final double horizontalOffsetRatio =
                      _getHorizontalOffsetRatio(index);

                  return Positioned(
                    top: nodeY,
                    left: 0,
                    right: 0,
                    child: _buildRoadmapStepNode(
                      step: step,
                      offsetRatio: horizontalOffsetRatio,
                      ambientProg: _ambientController.value,
                    ),
                  );
                }),

                // 4. Destination: Level 1 English House at bottom of path
                Positioned(
                  bottom: 24,
                  left: 14,
                  right: 14,
                  child: _buildBottomHouseDestinationCard(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Calculates a smooth meandering sinusoidal offset for the step nodes
  double _getHorizontalOffsetRatio(int index) {
    // Oscillates between -0.45 (left) and +0.45 (right)
    final cycle = index % 4;
    switch (cycle) {
      case 0:
        return -0.38; // Left
      case 1:
        return -0.05; // Center-left
      case 2:
        return 0.38; // Right
      case 3:
        return 0.05; // Center-right
      default:
        return 0.0;
    }
  }

  /// 🌟 Top Floating Header HUD
  Widget _buildFloatingMapHeader() {
    final progressPct = widget.totalCount > 0
        ? (widget.completedCount / widget.totalCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
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
              const SizedBox(width: 10),
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

              const SizedBox(width: 8),

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

  /// 🔘 Individual Step Milestone Node on the Winding Trail
  Widget _buildRoadmapStepNode({
    required RoadmapStepItem step,
    required double offsetRatio,
    required double ambientProg,
  }) {
    final isDone = step.isCompleted;
    final isUnlocked = step.isUnlocked;
    final isActive = step.isActive;

    // Pulse animation for the active step
    final pulseScale =
        isActive ? (1.0 + (math.sin(ambientProg * 2 * math.pi) * 0.06)) : 1.0;

    return Center(
      child: Transform.translate(
        offset: Offset(MediaQuery.of(context).size.width * offsetRatio * 0.7, 0),
        child: SizedBox(
          width: 250,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Milestone Orb
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
                                'Step ${step.stepNumber} is locked! Complete Step ${step.stepNumber - 1} first.',
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
                    width: 66,
                    height: 66,
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
                                    Color(0xFF0F172A)
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
                        width: (isActive || isDone) ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        if (isActive)
                          BoxShadow(
                            color: step.accentColor.withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        if (isDone)
                          BoxShadow(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.35),
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
                          top: -3,
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
                              isDone ? '✓ DONE' : 'STEP ${step.stepNumber}',
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

              const SizedBox(width: 10),

              // Description Info Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isUnlocked) {
                      HapticFeedback.lightImpact();
                      step.onAction();
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone
                            ? const Color(0xFF10B981).withValues(alpha: 0.5)
                            : (isActive
                                ? step.accentColor.withValues(alpha: 0.7)
                                : Colors.white12),
                        width: isActive ? 1.4 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: step.accentColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                step.category.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: step.accentColor,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Quick Manual Verify Checkbox
                            InkWell(
                              onTap: step.onToggleComplete,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  isDone
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isDone
                                      ? const Color(0xFF10B981)
                                      : Colors.white38,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.title,
                          style: GoogleFonts.outfit(
                            color: isUnlocked ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 10,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏰 Bottom Level 1 English House Destination Card
  Widget _buildBottomHouseDestinationCard() {
    final isDone = widget.hasPassedToday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? const Color(0xFF10B981)
              : const Color(0xFFFFD700).withValues(alpha: 0.5),
          width: isDone ? 2.0 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDone ? const Color(0xFF10B981) : const Color(0xFFFFD700))
                .withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFFFD700).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFD700),
                  ),
                ),
                child: Center(
                  child: Text(
                    isDone ? '👑' : '🏡',
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
                      isDone
                          ? 'DAY ${widget.day} COMPLETE • COTTAGE FORTIFIED!'
                          : 'LEVEL ${widget.day} COTTAGE DESTINATION',
                      style: GoogleFonts.outfit(
                        color: isDone
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFFD700),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDone
                          ? 'All foundational steps mastered! Claim your 200 PTS & unlock Day ${widget.day + 1}.'
                          : 'Complete each step along the roadmap to arm and fortify your Day ${widget.day} English Cottage!',
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
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: isDone ? widget.onClaimReward : null,
              icon: Icon(
                isDone ? Icons.celebration_rounded : Icons.lock_outline_rounded,
                color: isDone ? Colors.black : Colors.white38,
                size: 18,
              ),
              label: Text(
                isDone
                    ? 'CLAIM DAY ${widget.day} REWARD (+200 PTS & ADVANCE)'
                    : 'PASS 100 PTS TO ADVANCE (${widget.points}/100)',
                style: GoogleFonts.outfit(
                  color: isDone ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone
                    ? const Color(0xFFFFFC00)
                    : const Color(0xFF1E293B),
                disabledBackgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isDone ? 4 : 0,
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
/// - Winding Trail connecting all Step Nodes
/// - Beautiful Level 1 English House at bottom with Chimney Smoke & Garden Fence
class _MissionRoadmapLandscapePainter extends CustomPainter {
  final double ambientProg;
  final int stepCount;
  final int completedCount;
  final double totalHeight;
  final bool isAllCompleted;
  final int day;

  _MissionRoadmapLandscapePainter({
    required this.ambientProg,
    required this.stepCount,
    required this.completedCount,
    required this.totalHeight,
    required this.isAllCompleted,
    required this.day,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
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

    // 🏡 5. The Level 1 English House at bottom
    _drawLevel1House(canvas, w, h - 330);
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
    // Little trees on distant hills
    for (int i = 0; i < 12; i++) {
      final tx = (i % 2 == 0) ? (w * 0.08) + (i * 2) : w * 0.92 - (i * 2);
      final ty = 400.0 + (i * 220.0);
      if (ty < h - 400) {
        _drawMiniTree(canvas, tx, ty, scale: 0.85);
      }
    }

    // Little flower sprinkles
    final flowerPaint1 = Paint()..color = const Color(0xFFEF4444);
    final flowerPaint2 = Paint()..color = const Color(0xFFFACC15);
    final flowerPaint3 = Paint()..color = Colors.white;

    for (int i = 0; i < 30; i++) {
      final fx = (i * 67.0) % (w - 40) + 20;
      final fy = 480.0 + (i * 120.0);
      if (fy < h - 350) {
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

  /// Winding Cobblestone Adventure Road meandering between steps
  void _drawWindingTrail(Canvas canvas, double w, double h) {
    final trailPath = Path();
    trailPath.moveTo(w * 0.5, 270.0);

    for (int i = 0; i < stepCount; i++) {
      final nodeY = 320.0 + (i * 140.0) + 33.0;
      final cycle = i % 4;
      double nodeX = w * 0.5;
      if (cycle == 0) nodeX = w * 0.5 - 55;
      if (cycle == 1) nodeX = w * 0.5 - 15;
      if (cycle == 2) nodeX = w * 0.5 + 55;
      if (cycle == 3) nodeX = w * 0.5 + 15;

      final prevY = (i == 0) ? 270.0 : (320.0 + ((i - 1) * 140.0) + 33.0);
      final midY = (prevY + nodeY) / 2;

      trailPath.cubicTo(w * 0.5, midY, nodeX, midY, nodeX, nodeY);
    }

    // Connect from last step down to house
    final lastStepY = 320.0 + ((stepCount - 1) * 140.0) + 33.0;
    trailPath.cubicTo(w * 0.5, lastStepY + 60, w * 0.5, h - 350, w * 0.5, h - 330);

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

  /// 🏡 Draws Level 1 Authentic English Cottage at bottom of landscape
  void _drawLevel1House(Canvas canvas, double w, double groundY) {
    final cx = w * 0.5;
    const houseW = 160.0;
    const houseH = 110.0;
    final houseLeft = cx - (houseW / 2);
    final houseTop = groundY - houseH;

    // 1. Cobblestone Front Yard Pathway leading to door
    final path = Path();
    path.moveTo(cx - 18, groundY + 50);
    path.lineTo(cx - 12, groundY);
    path.lineTo(cx + 12, groundY);
    path.lineTo(cx + 18, groundY + 50);
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF94A3B8));

    // 2. House Base & Walls (Warm Storybook Cream/Stone)
    final wallRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(houseLeft, houseTop, houseW, houseH),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      wallRect,
      Paint()..color = const Color(0xFFF7E8D0), // Cream Stone
    );
    canvas.drawRRect(
      wallRect,
      Paint()
        ..color = const Color(0xFFDEC5A5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Timber corner posts
    canvas.drawRect(Rect.fromLTWH(houseLeft, houseTop, 10, houseH),
        Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(houseLeft + houseW - 10, houseTop, 10, houseH),
        Paint()..color = const Color(0xFF78350F));

    // 3. Red Terracotta Pitched Roof
    const roofOverhang = 18.0;
    const roofPeakHeight = 52.0;
    final roofPath = Path();
    roofPath.moveTo(houseLeft - roofOverhang, houseTop);
    roofPath.lineTo(cx, houseTop - roofPeakHeight);
    roofPath.lineTo(houseLeft + houseW + roofOverhang, houseTop);
    roofPath.close();

    canvas.drawPath(
      roofPath,
      Paint()..color = const Color(0xFFE04938), // Storybook Red Roof
    );
    canvas.drawPath(
      roofPath,
      Paint()
        ..color = const Color(0xFFBF3728)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Roof Trim Underhang
    canvas.drawLine(
      Offset(houseLeft - roofOverhang, houseTop),
      Offset(houseLeft + houseW + roofOverhang, houseTop),
      Paint()
        ..color = const Color(0xFFFFF7ED)
        ..strokeWidth = 3.5,
    );

    // 4. Stone Chimney with Puffing Smoke
    final chimneyLeft = cx + 32;
    final chimneyTop = houseTop - roofPeakHeight + 8;
    canvas.drawRect(
      Rect.fromLTWH(chimneyLeft, chimneyTop, 18, 34),
      Paint()..color = const Color(0xFF64748B),
    );
    // Chimney Rim
    canvas.drawRect(
      Rect.fromLTWH(chimneyLeft - 2, chimneyTop, 22, 5),
      Paint()..color = const Color(0xFF334155),
    );

    // 💨 Animated Smoke Puffs
    final smokeProg = (ambientProg * 2) % 1.0;
    final smokeAlpha = (1.0 - smokeProg).clamp(0.0, 0.7);
    final smokeP = Paint()..color = Colors.white.withValues(alpha: smokeAlpha);
    canvas.drawCircle(
      Offset(chimneyLeft + 9 + (smokeProg * 8), chimneyTop - 10 - (smokeProg * 24)),
      7 + (smokeProg * 6),
      smokeP,
    );
    canvas.drawCircle(
      Offset(chimneyLeft + 9 - (smokeProg * 6), chimneyTop - 25 - (smokeProg * 28)),
      9 + (smokeProg * 8),
      smokeP,
    );

    // 5. Arched Wooden Front Door
    const doorW = 28.0;
    const doorH = 46.0;
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - (doorW / 2), groundY - doorH, doorW, doorH),
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
    );
    canvas.drawRRect(doorRect, Paint()..color = const Color(0xFFD97706));
    canvas.drawRRect(
      doorRect,
      Paint()
        ..color = const Color(0xFF92400E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    // Door knob
    canvas.drawCircle(
      Offset(cx + 8, groundY - (doorH * 0.45)),
      2.5,
      Paint()..color = const Color(0xFFFFD700),
    );

    // 6. Cozy Glowing Front Windows
    for (final wx in [houseLeft + 22, houseLeft + houseW - 46]) {
      final winRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(wx, houseTop + 32, 24, 28),
        const Radius.circular(4),
      );
      // Warm yellow glow
      canvas.drawRRect(
        winRect,
        Paint()
          ..color = const Color(0xFFFEF08A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawRRect(winRect, Paint()..color = const Color(0xFFFFD700));
      // Window panes cross
      final winPaint = Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 1.6;
      canvas.drawLine(Offset(wx + 12, houseTop + 32), Offset(wx + 12, houseTop + 60), winPaint);
      canvas.drawLine(Offset(wx, houseTop + 46), Offset(wx + 24, houseTop + 46), winPaint);
    }

    // 7. White Picket Garden Fence
    _drawPicketFence(canvas, houseLeft - 30, houseLeft - 4, groundY);
    _drawPicketFence(canvas, houseLeft + houseW + 4, houseLeft + houseW + 30, groundY);

    // 8. Celebration Sparkles if all finished
    if (isAllCompleted) {
      final sparkleP = Paint()..color = const Color(0xFFFFD700);
      for (int i = 0; i < 8; i++) {
        final sx = cx + math.cos(ambientProg * 2 * math.pi + (i * 0.8)) * 80;
        final sy = houseTop - 20 + math.sin(ambientProg * 2 * math.pi + (i * 0.8)) * 30;
        canvas.drawCircle(Offset(sx, sy), 3.0, sparkleP);
      }
    }
  }

  void _drawPicketFence(Canvas canvas, double x1, double x2, double groundY) {
    final picketP = Paint()..color = Colors.white;
    final railP = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 2.0;

    // Cross rails
    canvas.drawLine(Offset(x1, groundY - 14), Offset(x2, groundY - 14), railP);
    canvas.drawLine(Offset(x1, groundY - 6), Offset(x2, groundY - 6), railP);

    for (double x = x1; x <= x2; x += 7.0) {
      final pPath = Path();
      pPath.moveTo(x - 2, groundY);
      pPath.lineTo(x - 2, groundY - 18);
      pPath.lineTo(x, groundY - 22); // Pointy tip
      pPath.lineTo(x + 2, groundY - 18);
      pPath.lineTo(x + 2, groundY);
      pPath.close();
      canvas.drawPath(pPath, picketP);
    }
  }

  @override
  bool shouldRepaint(covariant _MissionRoadmapLandscapePainter oldDelegate) {
    return oldDelegate.ambientProg != ambientProg ||
        oldDelegate.completedCount != completedCount ||
        oldDelegate.isAllCompleted != isAllCompleted;
  }
}
