import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_interactive_teacher_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/english_tasks_master_hub.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_90day_vocab_curriculum.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fluency_gym_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_secret_code_grammar_card.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_sentence_builder_card.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_slang_smart_english_card.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_time_machine_practice_card.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_code_english_decoder_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_alphabet_phonics_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_curriculum_registry.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/cyber_vocab_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_level_exam_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';

/// 🏔️ Dedicated Open-World Level Adventure Page (User Audio Directive!)
///
/// Features:
/// 1. Open World Side-Scrolling Mountain Ascent:
///    - Starts on the left at House 1 (Day $day Estate) on the valley floor.
///    - Ascends diagonally up the mountain hill through 17 gamified stepping ledges.
///    - Concludes at House 2 (Day ${day + 1} Estate) perching on the summit ridge!
/// 2. Real-time Day / Night Atmosphere (Stars & Moon at night, Sun & Clouds in day).
/// 3. Zoom In / Zoom Out support (Pinch + HUD Vista toggle).
/// 4. Walking avatar that progresses along the mountain ledges as each step is mastered!
class PocketDayOpenWorldAdventurePage extends StatefulWidget {
  final int day;
  final String? userId;
  final VoidCallback? onCompleted;

  const PocketDayOpenWorldAdventurePage({
    super.key,
    required this.day,
    this.userId,
    this.onCompleted,
  });

  @override
  State<PocketDayOpenWorldAdventurePage> createState() =>
      _PocketDayOpenWorldAdventurePageState();
}

class _PocketDayOpenWorldAdventurePageState
    extends State<PocketDayOpenWorldAdventurePage>
    with SingleTickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  final TransformationController _transformController =
      TransformationController();
  late AnimationController _animController;

  final Map<String, bool> _subStepFlags = {};
  bool _isLoading = true;
  double _zoomScale = 0.85;

  // World Canvas Geometry
  static const double _worldWidth = 3600.0;
  static const double _worldHeight = 1500.0;

  bool get _isMasterAdmin {
    final email = _supabase.auth.currentUser?.email;
    return AdminAuthService.isMasterAdminEmail(email);
  }

  bool get _isNightTime {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _loadState();
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    final Map<String, bool> flags = {};
    for (int step = 1; step <= 17; step++) {
      final key = 'pocket_day_${uid ?? "guest"}_${widget.day}_step_${step}_done';
      flags['step_$step'] = prefs.getBool(key) ?? false;
    }

    if (mounted) {
      setState(() {
        _subStepFlags.clear();
        _subStepFlags.addAll(flags);
        _isLoading = false;
      });

      // Focus camera on player's active step
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnActiveStep(animate: false);
      });
    }
  }

  int get _firstIncompleteStep {
    for (int s = 1; s <= 17; s++) {
      if (!(_subStepFlags['step_$s'] ?? false)) return s;
    }
    return 17;
  }

  Offset _getStepPosition(int stepIndex) {
    // 17 steps distributed along a scenic diagonal mountain slope
    // from x = 460 (just outside House 1) to x = 3080 (just before House 2)
    final progress = (stepIndex - 1) / 16.0;
    final startX = 480.0;
    final endX = 3050.0;
    final startY = 1120.0;
    final endY = 460.0;

    final x = startX + (endX - startX) * progress;
    final linearY = startY + (endY - startY) * progress;
    // Gentle natural mountain terrace undulation
    final wave = math.sin(progress * math.pi * 3.2) * 36.0;
    return Offset(x, linearY + wave);
  }

  void _focusOnActiveStep({bool animate = true, double? targetScale}) {
    if (!mounted) return;
    final activeStep = _firstIncompleteStep;
    final pos = _getStepPosition(activeStep);
    _focusOnPoint(pos.dx, pos.dy, scale: targetScale ?? _zoomScale, animate: animate);
  }

  void _focusOnPoint(double worldX, double worldY,
      {required double scale, bool animate = true}) {
    final size = MediaQuery.of(context).size;
    final targetX = -(worldX * scale) + (size.width / 2.0);
    final targetY = -(worldY * scale) + (size.height / 2.0);

    final targetMatrix = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, targetX)
      ..setEntry(1, 3, targetY);

    if (animate) {
      _transformController.value = targetMatrix;
    } else {
      _transformController.value = targetMatrix;
    }
  }

  Future<void> _onStepCompleted(int stepIndex) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    int pointsAwarded = (stepIndex == 17) ? 120 : 30;

    if (uid != null && uid.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pocket_day_${uid}_${widget.day}_step_${stepIndex}_done';
      final alreadyDone = prefs.getBool(key) == true;
      await prefs.setBool(key, true);

      if (!alreadyDone) {
        await PocketFortressDefenseService.recordTrainingPoints(pointsAwarded, uid);
      }

      if (stepIndex == 17) {
        await prefs.setBool('pocket_day_${uid}_${widget.day}_completed', true);
        await prefs.setInt('learning_last_completed_day_$uid', widget.day);
        final now = DateTime.now();
        await prefs.setString('learning_day_${uid}_${widget.day}_completed_date',
            '${now.year}-${now.month}-${now.day}');
      }
    }

    HapticFeedback.heavyImpact();
    await _loadState();

    if (stepIndex < 17) {
      _focusOnActiveStep(animate: true);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stepIndex == 17
                      ? '🎉 Day ${widget.day} Mastered! +$pointsAwarded PS 🪙 • House ${widget.day + 1} Summit Unlocked!'
                      : 'Step $stepIndex / 17 Done! +$pointsAwarded PS 🪙 Next step unlocked 🚀',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      if (stepIndex == 17) {
        widget.onCompleted?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    final isNight = _isNightTime;
    final activeStep = _firstIncompleteStep;
    final avatarPos = _getStepPosition(activeStep);
    final avatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(widget.day);

    int completedCount = 0;
    for (int s = 1; s <= 17; s++) {
      if (_subStepFlags['step_$s'] ?? false) completedCount++;
    }

    return Scaffold(
      backgroundColor: isNight ? const Color(0xFF030712) : const Color(0xFF0284C7),
      body: Stack(
        children: [
          // 1. Panoramic Open World Mountain Canvas with 2D Panning & Pinch-to-Zoom
          InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(500),
            minScale: 0.35,
            maxScale: 1.5,
            child: SizedBox(
              width: _worldWidth,
              height: _worldHeight,
              child: Stack(
                children: [
                  // Scenic Painter (Sky, Stars, Moon/Sun, Mountain Silhouettes, Waterfall & Trail)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _OpenWorldMountainPainter(
                            isNight: isNight,
                            animationValue: _animController.value,
                            completedStepCount: completedCount,
                            stepPositions: [
                              for (int s = 1; s <= 17; s++) _getStepPosition(s)
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 🏡 START: House 1 (Day $day Estate at bottom-left valley)
                  _buildStartHouse(widget.day),

                  // 🏡 SUMMIT: House 2 (Day ${day + 1} Estate at top-right peak)
                  _buildSummitHouse(widget.day + 1, completedCount >= 17),

                  // 17 Stepping Ledges along the Mountain Trail
                  for (int s = 1; s <= 17; s++) _buildMountainStepNode(s),

                  // Walking Avatar Character at Current Active Ledge
                  Positioned(
                    left: avatarPos.dx - 28,
                    top: avatarPos.dy - 76,
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        final bounce = math.sin(_animController.value * math.pi) * 6.0;
                        return Transform.translate(
                          offset: Offset(0, -bounce),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFFFC00), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'YOU ARE HERE 🔥',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFC00),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: VectorAvatarWidget(
                                    config: avatarConfig,
                                    size: 48,
                                    showAura: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Sticky Minimal Top HUD
          _buildHUD(completedCount, isNight),
        ],
      ),
    );
  }

  Widget _buildHUD(int completedCount, bool isNight) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 8),

              // Level Title & Progress Capsule
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🏔️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Day ${widget.day} Mountain Trail',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                        ),
                        child: Text(
                          '$completedCount / 17 Done',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 📍 Focus Button (Re-center on active step)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _focusOnActiveStep(animate: true);
                },
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 3),
                      Text(
                        'Focus',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 🔍 Vista Zoom Toggle (0.65x / 1.0x)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _zoomScale = (_zoomScale > 0.75) ? 0.60 : 0.95;
                  });
                  _focusOnActiveStep(animate: true, targetScale: _zoomScale);
                },
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: _zoomScale < 0.75
                        ? const Color(0xFF0284C7).withValues(alpha: 0.35)
                        : const Color(0xFF0F172A).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: _zoomScale < 0.75
                          ? const Color(0xFF38BDF8)
                          : Colors.white24,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        _zoomScale < 0.75 ? '0.6x' : '1.0x',
                        style: GoogleFonts.outfit(
                          color: _zoomScale < 0.75
                              ? const Color(0xFF38BDF8)
                              : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildStartHouse(int day) {
    const houseWidth = 230.0;
    const houseHeight = 140.0;
    final palette = HousePalette.presets[(day - 1) % HousePalette.presets.length];
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(day);

    return Positioned(
      left: 140.0,
      top: 1040.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981), width: 1.2),
            ),
            child: Text(
              '🏠 START: DAY $day ($estateTitle)',
              style: GoogleFonts.outfit(
                color: const Color(0xFF10B981),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: houseWidth,
            height: houseHeight,
            child: CustomPaint(
              size: const Size(houseWidth, houseHeight),
              painter: HouseMasterPainter(
                day: day,
                palette: palette,
                isPresident: false,
                lightsOn: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummitHouse(int targetDay, bool isUnlocked) {
    const houseWidth = 230.0;
    const houseHeight = 140.0;
    final palette =
        HousePalette.presets[(targetDay - 1) % HousePalette.presets.length];
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(targetDay);

    return Positioned(
      left: 3100.0,
      top: 360.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFFFFD700)
                    : Colors.white24,
                width: 1.2,
              ),
            ),
            child: Text(
              isUnlocked
                  ? '👑 SUMMIT REACHED: DAY $targetDay UNLOCKED!'
                  : '🔒 SUMMIT DESTINATION: DAY $targetDay ($estateTitle)',
              style: GoogleFonts.outfit(
                color: isUnlocked ? const Color(0xFFFFD700) : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: houseWidth,
            height: houseHeight,
            child: CustomPaint(
              size: const Size(houseWidth, houseHeight),
              painter: HouseMasterPainter(
                day: targetDay,
                palette: palette,
                isPresident: false,
                lightsOn: isUnlocked,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMountainStepNode(int stepIndex) {
    final pos = _getStepPosition(stepIndex);
    final isDone = _subStepFlags['step_$stepIndex'] ?? false;
    final isPrevDone =
        stepIndex == 1 || (_subStepFlags['step_${stepIndex - 1}'] ?? false);
    final isUnlocked = isPrevDone || _isMasterAdmin;
    final isCurrent = isUnlocked && !isDone;
    const nodeSize = 52.0;

    final stepInfo = _getStepDetails(stepIndex);

    return Positioned(
      left: pos.dx - (nodeSize / 2),
      top: pos.dy - (nodeSize / 2),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          if (!isUnlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🔒 Complete Step ${stepIndex - 1} first to unlock!'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          _launchStepActivity(stepIndex);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Step Title Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFFFFFC00)
                      : (isDone ? const Color(0xFF10B981) : Colors.white24),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stepInfo.icon, style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    'Step $stepIndex: ${stepInfo.title}',
                    style: GoogleFonts.outfit(
                      color: isCurrent
                          ? const Color(0xFFFFFC00)
                          : (isDone ? const Color(0xFF6EE7B7) : Colors.white70),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Stepping Stone Node
            SizedBox(
              width: nodeSize,
              height: nodeSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isCurrent)
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        final pulse = 1.0 + (_animController.value * 0.22);
                        return Transform.scale(
                          scale: pulse,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFFC00).withValues(
                                    alpha: 0.7 - (_animController.value * 0.35)),
                                width: 3.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDone
                            ? [const Color(0xFF10B981), const Color(0xFF047857)]
                            : (isCurrent
                                ? [const Color(0xFFFFFC00), const Color(0xFFFF8906)]
                                : [const Color(0xFF334155), const Color(0xFF1E293B)]),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isDone
                            ? const Color(0xFF6EE7B7)
                            : (isCurrent ? Colors.white : Colors.white24),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrent
                              ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.4),
                          blurRadius: isCurrent ? 12 : 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                          : (isUnlocked
                              ? Text(
                                  stepInfo.icon,
                                  style: const TextStyle(fontSize: 20),
                                )
                              : const Icon(Icons.lock_rounded,
                                  color: Colors.white38, size: 18)),
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

  _StepInfo _getStepDetails(int s) {
    switch (s) {
      case 1:
        return const _StepInfo('AI Interactive Tutor', '🎙️', Color(0xFF00F0FF));
      case 2:
        return const _StepInfo('10 Core Words', '📚', Color(0xFFFF8906));
      case 3:
        return const _StepInfo('Phonics Drills', '🔤', Color(0xFF38BDF8));
      case 4:
        return const _StepInfo('Fluency Gym', '🗣️', Color(0xFF10B981));
      case 5:
        return const _StepInfo('Secret Code Matrix', '⚡', Color(0xFFFFD700));
      case 6:
        return const _StepInfo('Sentence Builder', '🧩', Color(0xFF00E5FF));
      case 7:
        return const _StepInfo('Slang & Idioms', '💡', Color(0xFFA855F7));
      case 8:
        return const _StepInfo('Spoken Gym', '🎙️', Color(0xFFEC4899));
      case 9:
        return const _StepInfo('Time Machine', '⏳', Color(0xFFF59E0B));
      case 10:
        return const _StepInfo('Community Chat', '💬', Color(0xFFFFFC00));
      case 11:
        return const _StepInfo('1-on-1 English Call', '📞', Color(0xFF38BDF8));
      case 12:
        return const _StepInfo('Cyber Vocab Quest', '🎮', Color(0xFFE11D48));
      case 13:
        return const _StepInfo('Story Reading', '📖', Color(0xFF60A5FA));
      case 14:
        return const _StepInfo('Code English Decoder', '⚡', Color(0xFF00FFCC));
      case 15:
        return const _StepInfo('Fluency Shortcut', '⚡', Color(0xFFFFB300));
      case 16:
        return const _StepInfo('Arm Defense Shield', '🛡️', Color(0xFF8B5CF6));
      case 17:
        return const _StepInfo('Mastery Exam', '🎓', Color(0xFF10B981));
      default:
        return const _StepInfo('Practice Ledge', '⭐', Colors.white);
    }
  }

  Future<void> _launchStepActivity(int s) async {
    final day = widget.day;
    switch (s) {
      case 1:
        // Step 1: Interactive Teacher Game (Speech recognition & sentence builder)
        await PocketInteractiveTeacherGameModal.show(
          context,
          day: day,
          userId: widget.userId ?? _supabase.auth.currentUser?.id,
          onCompleted: () => _onStepCompleted(1),
        );
        break;

      case 2:
        // Step 2: 10 Core Vocabulary Words
        final vocabList = Pocket90DayVocabCurriculum.getVocabForDay(day);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => Scaffold(
              backgroundColor: const Color(0xFF0A1118),
              appBar: AppBar(
                backgroundColor: const Color(0xFF131722),
                title: Text('Day $day • 10 Core Vocabulary Words',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              body: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vocabList.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (c, i) {
                  if (i == vocabList.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 24),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _onStepCompleted(2);
                        },
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                        label: Text('I MASTERED ALL 10 WORDS ✓',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    );
                  }
                  final item = vocabList[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text('${i + 1}.', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.word,
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(item.malayalamMeaning,
                                  style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
        break;

      case 3:
        // Step 3: Phonics Drills
        final phonics = PocketMissionCurriculumRegistry.getAlphabetPhonics(day);
        final res = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PocketAlphabetPhonicsGamePage(
              day: day,
              selectedLanguage: 'Malayalam',
              phonicsList: phonics,
            ),
          ),
        );
        if (res == true) _onStepCompleted(3);
        break;

      case 4:
        // Step 4: Fluency Gym
        final res = await PocketFluencyGymDetailPage.open(
          context,
          day: day,
          selectedLanguage: 'Malayalam',
          isInitiallyCompleted: _subStepFlags['step_4'] ?? false,
          onCompleted: (val) {
            if (val) _onStepCompleted(4);
          },
        );
        if (res == true) _onStepCompleted(4);
        break;

      case 5:
        // Step 5: Secret Code Grammar
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: PocketSecretCodeGrammarCard(
              day: day,
              selectedLanguage: 'Malayalam',
              isCompleted: _subStepFlags['step_5'] ?? false,
              onSpeak: (_) {},
              onCompleted: (val) {
                if (val) {
                  Navigator.pop(ctx);
                  _onStepCompleted(5);
                }
              },
            ),
          ),
        );
        break;

      case 6:
        // Step 6: Sentence Builder Gym
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: PocketSentenceBuilderCard(
              day: day,
              isCompleted: _subStepFlags['step_6'] ?? false,
              onSpeak: (_) {},
              onCompleted: (val) {
                if (val) {
                  Navigator.pop(ctx);
                  _onStepCompleted(6);
                }
              },
            ),
          ),
        );
        break;

      case 7:
        // Step 7: Slang & Idioms
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: PocketSlangSmartEnglishCard(
              day: day,
              selectedLanguage: 'Malayalam',
              isCompleted: _subStepFlags['step_7'] ?? false,
              onSpeak: (_) {},
              onCompleted: (val) {
                if (val) {
                  Navigator.pop(ctx);
                  _onStepCompleted(7);
                }
              },
            ),
          ),
        );
        break;

      case 8:
        // Step 8: Spoken Gym
        _onStepCompleted(8);
        break;

      case 9:
        // Step 9: Time Machine Practice
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: PocketTimeMachinePracticeCard(
              day: day,
              selectedLanguage: 'Malayalam',
              isCompleted: _subStepFlags['step_9'] ?? false,
              onSpeak: (_) {},
              onCompleted: (val) {
                if (val) {
                  Navigator.pop(ctx);
                  _onStepCompleted(9);
                }
              },
            ),
          ),
        );
        break;

      case 10:
        // Step 10: Community Chat
        _onStepCompleted(10);
        break;

      case 11:
        // Step 11: Peer Call
        _onStepCompleted(11);
        break;

      case 12:
        // Step 12: Cyber Vocab Quest
        final res = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const CyberVocabGamePage()),
        );
        if (res == true) _onStepCompleted(12);
        break;

      case 13:
        // Step 13: Story Reading
        _onStepCompleted(13);
        break;

      case 14:
        // Step 14: Code English Decoder
        await PocketCodeEnglishDecoderModal.show(
          context,
          currentDay: day,
        );
        _onStepCompleted(14);
        break;

      case 15:
        // Step 15: Fluency Shortcut
        _onStepCompleted(15);
        break;

      case 16:
        // Step 16: Arm Defense Shield
        PocketDefenseTrapModal.show(
          context,
          day,
          isLevelComplete: true,
        );
        _onStepCompleted(16);
        break;

      case 17:
        // Step 17: Mastery Exam
        final examRes = await PocketLevelExamDialog.show(
          context,
          level: day,
        );
        if (examRes == true) {
          _onStepCompleted(17);
        }
        break;

      default:
        _onStepCompleted(s);
        break;
    }
  }
}

class _StepInfo {
  final String title;
  final String icon;
  final Color color;

  const _StepInfo(this.title, this.icon, this.color);
}

/// 🎨 Custom Painter for the Open-World Mountain Ascent
class _OpenWorldMountainPainter extends CustomPainter {
  final bool isNight;
  final double animationValue;
  final int completedStepCount;
  final List<Offset> stepPositions;

  _OpenWorldMountainPainter({
    required this.isNight,
    required this.animationValue,
    required this.completedStepCount,
    required this.stepPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? [
                const Color(0xFF030712),
                const Color(0xFF0F172A),
                const Color(0xFF1E1B4B),
              ]
            : [
                const Color(0xFF0284C7),
                const Color(0xFF38BDF8),
                const Color(0xFFBAE6FD),
              ],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Stars & Moon (Night) or Sun & Clouds (Day)
    if (isNight) {
      _paintNightSky(canvas, size);
    } else {
      _paintDaySky(canvas, size);
    }

    // 3. Parallax Mountain Ridges (Ascending from bottom-left to top-right)
    _paintMountainRidges(canvas, size);

    // 4. Cascading Waterfall
    _paintWaterfall(canvas);

    // 5. Cobblestone Stepping Mountain Trail Connecting the Steps
    _paintMountainTrail(canvas);
  }

  void _paintNightSky(Canvas canvas, Size size) {
    // Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (int i = 0; i < 90; i++) {
      final sx = (i * 137.5) % size.width;
      final sy = ((i * 83.3) % (size.height * 0.55));
      final twinkle = math.sin((animationValue * math.pi * 3) + i) * 0.8;
      canvas.drawCircle(Offset(sx, sy), 1.2 + twinkle, starPaint);
    }

    // Glowing Silver Crescent Moon
    const moonCenter = Offset(2800.0, 180.0);
    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE2E8F0).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 80));
    canvas.drawCircle(moonCenter, 80, moonGlow);

    final moonPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawCircle(moonCenter, 34, moonPaint);
    final moonCutout = Paint()..color = const Color(0xFF030712);
    canvas.drawCircle(moonCenter + const Offset(12, -8), 28, moonCutout);
  }

  void _paintDaySky(Canvas canvas, Size size) {
    // Radiant Sun
    const sunCenter = Offset(2900.0, 160.0);
    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 90));
    canvas.drawCircle(sunCenter, 90, sunGlow);

    final sunCore = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawCircle(sunCenter, 36, sunCore);

    // Drifting Fluffy Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    for (int i = 0; i < 12; i++) {
      final cx = (i * 320.0 + animationValue * 40.0) % size.width;
      final cy = 120.0 + (i % 4) * 60.0;
      canvas.drawCircle(Offset(cx, cy), 32, cloudPaint);
      canvas.drawCircle(Offset(cx + 26, cy - 10), 40, cloudPaint);
      canvas.drawCircle(Offset(cx + 54, cy), 28, cloudPaint);
    }
  }

  void _paintMountainRidges(Canvas canvas, Size size) {
    // Distant Blue Alpine Ridge
    final distantRidge = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 850)
      ..lineTo(800, 720)
      ..lineTo(1600, 560)
      ..lineTo(2400, 420)
      ..lineTo(3200, 220)
      ..lineTo(size.width, 180)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      distantRidge,
      Paint()
        ..color = isNight
            ? const Color(0xFF0F172A).withValues(alpha: 0.6)
            : const Color(0xFF0284C7).withValues(alpha: 0.45),
    );

    // Midground Rocky Mountain Ridge
    final midRidge = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 1050)
      ..lineTo(600, 940)
      ..lineTo(1400, 780)
      ..lineTo(2200, 620)
      ..lineTo(3000, 390)
      ..lineTo(size.width, 320)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      midRidge,
      Paint()
        ..color = isNight
            ? const Color(0xFF064E3B).withValues(alpha: 0.75)
            : const Color(0xFF0D9488).withValues(alpha: 0.65),
    );

    // Foreground Emerald Mountain Slope (Diagonal from Bottom-Left to Top-Right)
    final foreRidge = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 1180)
      ..lineTo(520, 1120)
      ..lineTo(1200, 960)
      ..lineTo(1900, 800)
      ..lineTo(2600, 620)
      ..lineTo(3200, 450)
      ..lineTo(size.width, 420)
      ..lineTo(size.width, size.height)
      ..close();

    final forePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isNight
            ? [const Color(0xFF064E3B), const Color(0xFF022C22)]
            : [const Color(0xFF16A34A), const Color(0xFF14532D)],
      ).createShader(Rect.fromLTWH(0, 420, size.width, size.height - 420));
    canvas.drawPath(foreRidge, forePaint);
  }

  void _paintWaterfall(Canvas canvas) {
    // Cascades down near x = 1100 from mid-cliff into a lower lake
    const fallX = 1080.0;
    const startY = 820.0;
    const endY = 1260.0;

    final fallPath = Path()
      ..moveTo(fallX - 8, startY)
      ..quadraticBezierTo(fallX + 6, (startY + endY) / 2, fallX - 14, endY)
      ..lineTo(fallX + 16, endY)
      ..quadraticBezierTo(fallX + 18, (startY + endY) / 2, fallX + 10, startY)
      ..close();

    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE0F2FE), Color(0xFF38BDF8), Color(0xFF00E5FF)],
      ).createShader(const Rect.fromLTWH(fallX - 14, startY, 30, endY - startY));
    canvas.drawPath(fallPath, waterPaint);

    // Base splash pool
    canvas.drawOval(
      const Rect.fromLTWH(fallX - 35, endY - 6, 70, 26),
      Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.8),
    );
  }

  void _paintMountainTrail(Canvas canvas) {
    if (stepPositions.length < 2) return;

    final trailPath = Path();
    trailPath.moveTo(stepPositions.first.dx, stepPositions.first.dy);

    for (int i = 1; i < stepPositions.length; i++) {
      final p1 = stepPositions[i - 1];
      final p2 = stepPositions[i];
      final midX = (p1.dx + p2.dx) / 2;
      final midY = (p1.dy + p2.dy) / 2;
      trailPath.quadraticBezierTo(midX, midY, p2.dx, p2.dy);
    }

    // Cobblestone Trail Base
    final roadBase = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 28.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trailPath, roadBase);

    // Inner Trail Line
    final roadInner = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trailPath, roadInner);

    // Completed Golden Trail
    if (completedStepCount > 1) {
      final completedPath = Path();
      completedPath.moveTo(stepPositions.first.dx, stepPositions.first.dy);
      final maxI = math.min(completedStepCount, stepPositions.length);
      for (int i = 1; i < maxI; i++) {
        final p1 = stepPositions[i - 1];
        final p2 = stepPositions[i];
        final midX = (p1.dx + p2.dx) / 2;
        final midY = (p1.dy + p2.dy) / 2;
        completedPath.quadraticBezierTo(midX, midY, p2.dx, p2.dy);
      }
      final goldPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(completedPath, goldPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OpenWorldMountainPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.completedStepCount != completedStepCount ||
        oldDelegate.isNight != isNight;
  }
}
