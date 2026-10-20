import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/english_tasks_master_hub.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day1_tutor_curriculum.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day1_step1_avatar_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day1_step4_avatar_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day1_step5_avatar_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day2_step1_avatar_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day2_step4_avatar_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_syllabus_repository.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_day_curriculum_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_learning_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_house_defense_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day_avatar_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/spoken/pocket_spoken_avatar_simulator_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_vocab_open_world_drive_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/pocket_talk_card_swiper_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_house_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_open_world_game_page.dart'
    show CruisingBoat, CruisingBoatType, FlyingBird, JumpDustParticle;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/sentence_builder_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_essential_spelling_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_90day_spoken_exam_curriculum.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_pronunciation_evaluator.dart';

/// 🏔️ Dedicated Open-World Level Adventure Page (Light Mode Hill-Climb Adventure!)
///
/// Features (Matches PocketOpenWorldGame fidelity exactly):
/// 1. 100% Sunny Daytime / Light Mode:
///    - Azure sky, glowing warm sun, soft drifting clouds, flying seagulls.
///    - NO dark night mode, NO waterfalls!
/// 2. Genuine Rolling Hills Mountain Ascent:
///    - House 1 (Day $day Estate) on valley floor at start.
///    - 17 Gamified Stepping Ledges along undulating rolling mountain slopes.
///    - House 2 (Day ${day + 1} Estate) perched on the summit ridge at the finish.
///    - Living ocean water at the base with cruising boats (Kettuvallam, sailboats) and leaping dolphins.
/// 3. Red & Gold Sports Buggy with Driver Avatar:
///    - Smoothly drives along the hills with rotating wheels and suspension bounce.
///    - Dynamic chassis tilt matching terrain slope.
///    - Automatically drives to the active step on arrival, and pulls up and stops!
/// 4. Camera & Zoom:
///    - Starts in close-up zoom (~1.05x) focused right on the vehicle and active step for instant clarity.
///    - Seamless InteractiveViewer zoom with enclosed terrain bounds.
///    - Quick HUD Vista Toggle & Focus button.
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
    with TickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  final TransformationController _transformController =
      TransformationController();

  late AnimationController _ambientAnimController;
  late AnimationController _driveAnimController;
  Animation<double>? _driveAnimation;
  AnimationController? _cameraPanAnimController;
  Animation<Matrix4>? _cameraPanAnimation;

  final Map<String, bool> _subStepFlags = {};
  bool _isLoading = true;
  static const double _zoomScale = 1.05; // Default close-up zoom for clear viewing!

  // World Canvas Geometry (Expanded width for breathing room and scenic mountain ascent)
  static const double _worldWidth = 5200.0;
  static const double _worldHeight = 1600.0;

  // Sports Buggy State
  double _playerX = 320.0;
  double _wheelAngle = 0.0;
  double _prevPlayerX = 320.0;
  // ignore: unused_field
  bool _isDriving = false;
  int _currentLedgeStep = 1;
  List<Map<String, dynamic>>? _runtimeSteps;

  // Collectibles / FX
  final List<JumpDustParticle> _dustParticles = [];
  late final List<CruisingBoat> _riverBoats;
  late final List<FlyingBird> _seagulls;
  late final VectorAvatarPainter _avatarPainter;

  bool get _isMasterAdmin {
    final email = _supabase.auth.currentUser?.email;
    return AdminAuthService.isMasterAdminEmail(email);
  }

  @override
  void initState() {
    super.initState();

    _avatarPainter = VectorAvatarPainter(
      config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.day),
      showBackgroundAura: false,
    );

    _riverBoats = [
      CruisingBoat(x: 400, y: 1380, speed: 28, boatType: CruisingBoatType.kettuvallam),
      CruisingBoat(x: 1600, y: 1410, speed: 45, boatType: CruisingBoatType.sailboat),
      CruisingBoat(x: 2900, y: 1390, speed: 36, boatType: CruisingBoatType.cruiseShip),
      CruisingBoat(x: 4200, y: 1420, speed: 60, boatType: CruisingBoatType.speedboat),
    ];

    _seagulls = [
      FlyingBird(x: 300, y: 160, speed: 38),
      FlyingBird(x: 1200, y: 130, speed: 44),
      FlyingBird(x: 2400, y: 180, speed: 35),
      FlyingBird(x: 3600, y: 140, speed: 48),
      FlyingBird(x: 4700, y: 170, speed: 40),
    ];

    _ambientAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _ambientAnimController.addListener(_onAmbientTick);

    _driveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _loadState();
    _loadRuntimeCurriculum();
  }

  Future<void> _loadRuntimeCurriculum() async {
    final data = await PocketDayCurriculumService.loadDayCurriculum(widget.day);
    final rawSteps = data?['steps'] as List<dynamic>?;
    if (rawSteps == null || !mounted) return;
    setState(() {
      _runtimeSteps = rawSteps
          .whereType<Map>()
          .map((step) => Map<String, dynamic>.from(step))
          .toList();
    });
  }

  void _onAmbientTick() {
    if (!mounted) return;
    const dt = 1.0 / 60.0;
    for (final b in _riverBoats) {
      b.update(dt, _worldWidth);
    }
    for (final s in _seagulls) {
      s.update(dt, _worldWidth);
    }

    // Update dust particles
    for (final p in _dustParticles) {
      p.update(dt);
    }
    _dustParticles.removeWhere((p) => p.isDead);
  }

  @override
  void dispose() {
    _ambientAnimController.removeListener(_onAmbientTick);
    _ambientAnimController.dispose();
    _driveAnimController.dispose();
    _transformController.dispose();
    _cameraPanAnimController?.dispose();
    super.dispose();
  }

  /// ⛰️ Rolling Hills Mountain Ascent Spline (Natural terrain with peaks & valleys)
  static double getGroundY(double x) {
    final progress = (x / _worldWidth).clamp(0.0, 1.0);
    // General elevation climb from valley (left ~ 1120) to summit ridge (right ~ 520)
    final linearY = 1140.0 - (progress * 620.0);
    // Rolling hills: undulating natural waves
    final wave1 = math.sin(progress * math.pi * 3.6) * 55.0;
    final wave2 = math.sin(progress * math.pi * 7.5 + 0.4) * 26.0;
    final wave3 = math.cos(progress * math.pi * 1.8) * 38.0;
    return linearY + wave1 + wave2 - wave3;
  }

  /// Slope angle of the ground at x (for vehicle chassis tilt)
  static double getGroundSlope(double x) {
    const delta = 14.0;
    final y1 = getGroundY(x - delta);
    final y2 = getGroundY(x + delta);
    return math.atan2(y2 - y1, delta * 2);
  }

  Day1Track _day1Track = Day1Track.middle;
  bool _isGateExamPassed = false;
  int get _totalSteps => 11;

  /// Exact coordinate of milestone step on the mountain slope (User Audio Directive: Ample gap after Today's Lesson billboard)
  static Offset getStepPosition(int stepIndex, {int totalSteps = 17}) {
    final denominator = (totalSteps > 1) ? (totalSteps - 1).toDouble() : 1.0;
    final progress = (stepIndex - 1) / denominator;
    const startX = 1040.0;
    const endX = 3960.0;
    final x = startX + (endX - startX) * progress;
    final y = getGroundY(x);
    return Offset(x, y);
  }

  bool _hasInitialPositioned = false;

  Future<void> _loadState({bool preserveCarPosition = false}) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    final currentLvl = await PocketSyllabusRepository.getSavedLevel();
    _day1Track = Day1Track.fromLearnerLevel(currentLvl);

    final gatePassedKey = 'pocket_day_${uid ?? "guest"}_${widget.day}_gate_exam_passed';
    final gatePassed = prefs.getBool(gatePassedKey) ?? false;

    final Map<String, bool> flags = {};
    for (int step = 1; step <= _totalSteps; step++) {
      final userKey = uid != null ? 'pocket_day_${uid}_${widget.day}_step_${step}_done' : null;
      final guestKey = 'pocket_day_guest_${widget.day}_step_${step}_done';
      final isDone = (userKey != null && prefs.getBool(userKey) == true) ||
          (prefs.getBool(guestKey) == true) ||
          (prefs.getBool('pocket_day_${uid ?? "guest"}_${widget.day}_step_${step}_done') == true) ||
          (step == 1 &&
              ((userKey != null &&
                      prefs.getBool('pocket_day_${uid}_${widget.day}_step_1_completed') == true) ||
                  prefs.getBool('pocket_day_guest_${widget.day}_step_1_completed') == true));
      flags['step_$step'] = isDone;
    }

    if (mounted) {
      final activeStep = _findFirstIncompleteStep(flags);

      setState(() {
        _subStepFlags.clear();
        _subStepFlags.addAll(flags);
        _isLoading = false;
        _currentLedgeStep = activeStep;
        _isGateExamPassed = gatePassed;
      });

      // User Audio Directive: Don't always reset car to House 1 start!
      // On page entry, position car directly at current active incomplete step!
      if (!preserveCarPosition && !_hasInitialPositioned) {
        _hasInitialPositioned = true;
        final targetPos = getStepPosition(activeStep, totalSteps: _totalSteps);
        final targetX = targetPos.dx - 48.0;
        _playerX = targetX;
        _prevPlayerX = targetX;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusOnPoint(targetX, getGroundY(targetX), scale: _zoomScale, animate: false);
        });
      }
    }
  }

  int _findFirstIncompleteStep(Map<String, bool> flags) {
    for (int s = 1; s <= _totalSteps; s++) {
      if (!(flags['step_$s'] ?? false)) return s;
    }
    return _totalSteps;
  }


  void _driveToStep(int stepIndex, {bool openActivityOnArrival = false}) {
    if (!mounted) return;
    final targetPos = getStepPosition(stepIndex, totalSteps: _totalSteps);
    // Park slightly in front of the milestone stone
    final targetX = targetPos.dx - 48.0;

    _driveAnimController.stop();
    final startX = _playerX;
    _driveAnimation = Tween<double>(begin: startX, end: targetX).animate(
      CurvedAnimation(parent: _driveAnimController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        if (!mounted) return;
        final currentX = _driveAnimation!.value;
        final dx = currentX - _prevPlayerX;
        _wheelAngle += dx * 0.14;
        _prevPlayerX = currentX;

        // Kick up dust particles while moving
        if (dx.abs() > 0.8 && math.Random().nextDouble() < 0.45) {
          final gy = getGroundY(currentX);
          _dustParticles.add(
            JumpDustParticle(
              x: currentX - (dx.sign * 24.0),
              y: gy + 4.0,
              vx: -dx.sign * (15.0 + math.Random().nextDouble() * 20.0),
              vy: -10.0 - math.Random().nextDouble() * 15.0,
            ),
          );
        }

        setState(() {
          _playerX = currentX;
          _isDriving = true;
        });

        // Smooth camera track while driving
        _focusOnPoint(currentX, getGroundY(currentX), scale: _zoomScale, animate: false);
      });

    _driveAnimController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _isDriving = false;
        _currentLedgeStep = stepIndex;
      });
      HapticFeedback.mediumImpact();
      if (openActivityOnArrival) {
        _launchStepActivity(stepIndex);
      }
    });
  }

  void _focusOnActiveStep({bool animate = true, double? targetScale}) {
    if (!mounted) return;
    final y = getGroundY(_playerX);
    _focusOnPoint(_playerX, y, scale: targetScale ?? _zoomScale, animate: animate);
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
      _animateTransformTo(targetMatrix);
    } else {
      _transformController.value = targetMatrix;
    }
  }

  void _animateTransformTo(Matrix4 targetMatrix) {
    _cameraPanAnimController?.dispose();
    _cameraPanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _cameraPanAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _cameraPanAnimController!,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
      if (mounted) {
        _transformController.value = _cameraPanAnimation!.value;
      }
    });
    _cameraPanAnimController!.forward();
  }

  void _scrubToFraction(double fraction, {bool animate = false}) {
    if (!mounted) return;
    final targetWorldX = (fraction * _worldWidth).clamp(0.0, _worldWidth);
    final targetWorldY = getGroundY(targetWorldX);
    final currentScale = _transformController.value.getMaxScaleOnAxis().clamp(0.52, 1.6);
    final size = MediaQuery.of(context).size;
    final targetTx = -(targetWorldX * currentScale) + (size.width / 2.0);
    final targetTy = -(targetWorldY * currentScale) + (size.height / 2.0);

    final targetMatrix = Matrix4.identity()
      ..setEntry(0, 0, currentScale)
      ..setEntry(1, 1, currentScale)
      ..setEntry(0, 3, targetTx)
      ..setEntry(1, 3, targetTy);

    if (animate) {
      _animateTransformTo(targetMatrix);
    } else {
      _transformController.value = targetMatrix;
    }
  }

  double _getCurrentWorldFraction(Size screenSize) {
    final currentScale = _transformController.value.getMaxScaleOnAxis().clamp(0.52, 1.6);
    final tx = _transformController.value.getTranslation().x;
    final centerWorldX = ((screenSize.width / 2.0) - tx) / currentScale;
    return (centerWorldX / _worldWidth).clamp(0.0, 1.0);
  }

  int _findStepClosestToFraction(double fraction) {
    final worldX = fraction * _worldWidth;
    int closestStep = 1;
    double minDistance = double.infinity;
    for (int s = 1; s <= _totalSteps; s++) {
      final pos = getStepPosition(s, totalSteps: _totalSteps);
      final dist = (pos.dx - worldX).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closestStep = s;
      }
    }
    return closestStep;
  }

  Future<void> _onStepCompleted(int stepIndex) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    int pointsAwarded = (stepIndex == _totalSteps) ? 120 : 30;

    final prefs = await SharedPreferences.getInstance();
    if (uid != null && uid.isNotEmpty) {
      final key = 'pocket_day_${uid}_${widget.day}_step_${stepIndex}_done';
      final alreadyDone = prefs.getBool(key) == true;
      await prefs.setBool(key, true);

      if (!alreadyDone) {
        await PocketFortressDefenseService.recordTrainingPoints(pointsAwarded, uid);
      }

      if (stepIndex == _totalSteps) {
        await prefs.setBool('pocket_day_${uid}_${widget.day}_completed', true);
        await prefs.setInt('learning_last_completed_day_$uid', widget.day);
        final now = DateTime.now();
        await prefs.setString('learning_day_${uid}_${widget.day}_completed_date',
            '${now.year}-${now.month}-${now.day}');
      }
    }

    // Always persist to fallback guest key as well
    await prefs.setBool('pocket_day_guest_${widget.day}_step_${stepIndex}_done', true);
    if (stepIndex == _totalSteps) {
      await prefs.setBool('pocket_day_guest_${widget.day}_completed', true);
    }

    HapticFeedback.heavyImpact();
    // Preserve car position during flag refresh!
    await _loadState(preserveCarPosition: true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stepIndex == _totalSteps
                      ? '🎉 Day ${widget.day} Mastered! +$pointsAwarded PS 🪙 • House ${widget.day + 1} Summit Unlocked!'
                      : 'Step $stepIndex / $_totalSteps Done! +$pointsAwarded PS 🪙 Driving to next step 🚀',
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

      // Auto-drive forward to next step from current location
      if (stepIndex < _totalSteps) {
        _driveToStep(stepIndex + 1, openActivityOnArrival: false);
      } else {
        if (!_isGateExamPassed) {
          _driveToGate(openExamOnArrival: true);
        } else {
          widget.onCompleted?.call();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0284C7),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    int completedCount = 0;
    for (int s = 1; s <= _totalSteps; s++) {
      if (_subStepFlags['step_$s'] ?? false) completedCount++;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: Stack(
        children: [
          // 1. Panoramic Open World Mountain Canvas (2D Panning & Pinch Zoom)
          InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: EdgeInsets.zero, // Keep contained within vibrant world bounds
            minScale: 0.52,
            maxScale: 1.6,
            child: SizedBox(
              width: _worldWidth,
              height: _worldHeight,
              child: Stack(
                children: [
                  // Scenic Painter (Sun, Clouds, Alpine Ridges, Rolling Hills, Cobblestone Highway & Living Sea)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _ambientAnimController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _DayOpenWorldMountainPainter(
                            gameTime: _ambientAnimController.value * 10.0,
                            boats: _riverBoats,
                            birds: _seagulls,
                            dustParticles: _dustParticles,
                          ),
                        );
                      },
                    ),
                  ),

                  // 🏡 START: House 1 (Day $day Estate on valley floor)
                  _buildStartHouse(widget.day),

                  // 🎯 TODAY'S TOPIC / LESSON BILLBOARD (User Audio Directive: Right after house, big title board before Step 1!)
                  _buildDayTopicBillboard(widget.day),

                  // 🚪 SUMMIT GATE: Day Exam Gate (Between Step 7 and Summit House)
                  _buildSummitGate(widget.day, _isGateExamPassed),

                  // 🏡 SUMMIT: House 2 (Day ${day + 1} Estate on mountain summit)
                  _buildSummitHouse(widget.day + 1, _isGateExamPassed),

                  // Stepping Ledges along the Rolling Mountain Highway
                  for (int s = 1; s <= _totalSteps; s++) _buildMountainStepNode(s),

                  // 🏎️ Player's Sports Buggy Driving Along the Rolling Slope
                  _buildSportsBuggyWidget(),
                ],
              ),
            ),
          ),

          // 2. Top HUD with Focus & Zoom Toggle
          _buildHUD(completedCount),

          // 3. Bottom Fast Scroller / Slider Bar (Quick Scrubbing through 11 Steps)
          _buildBottomFastScroller(completedCount),

          // 4. Stage Complete Bottom Floating Bar
          if (completedCount >= _totalSteps)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isGateExamPassed
                          ? [const Color(0xFF065F46), const Color(0xFF047857), const Color(0xFF10B981)]
                          : [const Color(0xFF78350F), const Color(0xFFB45309), const Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (_isGateExamPassed ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                            .withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(_isGateExamPassed ? '🏆' : '🔒', style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isGateExamPassed ? 'DAY ${widget.day} COMPLETE!' : 'DAY ${widget.day} STEPS COMPLETE!',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _isGateExamPassed
                                  ? 'Gate 1 Passed • House ${widget.day + 1} Unlocked 🎉'
                                  : 'Pass the 8-Question Spoken Gate Exam to unlock House 2!',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFEF08A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          if (!_isGateExamPassed) {
                            _driveToGate(openExamOnArrival: true);
                          } else {
                            widget.onCompleted?.call();
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          _isGateExamPassed ? 'ENTER HOUSE 2 ➔' : 'TAKE EXAM 🎙️',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
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

  /// 🏎️ Sports Buggy Widget with Animated Wheels, Avatar, Tilt, and Level Tag
  Widget _buildSportsBuggyWidget() {
    final groundY = getGroundY(_playerX);
    final slope = getGroundSlope(_playerX);

    return Positioned(
      left: _playerX - 44.0,
      top: groundY - 56.0,
      child: Transform.rotate(
        angle: slope,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Tag: "YOU (Day $day)"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFFC00), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                'YOU • STEP $_currentLedgeStep 🔥',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFFC00),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            SizedBox(
              width: 88,
              height: 52,
              child: CustomPaint(
                painter: _SportsBuggyPainter(
                  wheelAngle: _wheelAngle,
                  avatarPainter: _avatarPainter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD(int completedCount) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ◀️ Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

              const Spacer(),

              // 📍 Focus Button (Re-centers on vehicle / active step)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _focusOnActiveStep(animate: true);
                },
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'Focus',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 13,
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

  /// 🏎️ Bottom Horizontal Fast Scroller / Slider Bar
  ///
  /// User Audio Directive:
  /// Smooth horizontal scrubber allowing users to drag from end to end and quickly
  /// navigate between House 1, the 11 steps, and House 2 without cumbersome manual pinch-panning!
  Widget _buildBottomFastScroller(int completedCount) {
    final bottomOffset = (completedCount >= _totalSteps) ? 104.0 : 18.0;

    return Positioned(
      left: 14,
      right: 14,
      bottom: bottomOffset,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            const scrubberHeight = 44.0;
            const thumbWidth = 54.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                final localX = details.localPosition.dx.clamp(0.0, trackWidth);
                final newFraction = (localX / trackWidth).clamp(0.0, 1.0);
                _scrubToFraction(newFraction, animate: false);
              },
              onTapDown: (details) {
                final localX = details.localPosition.dx.clamp(0.0, trackWidth);
                final newFraction = (localX / trackWidth).clamp(0.0, 1.0);
                _scrubToFraction(newFraction, animate: true);
              },
              child: Container(
                height: scrubberHeight,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.55),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Subtle Background Track Line
                    Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Left Icon: Start House 1
                    Positioned(
                      left: 2,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _scrubToFraction(0.0, animate: true);
                        },
                        child: const Text('🏡', style: TextStyle(fontSize: 14)),
                      ),
                    ),

                    // 11 Step Milestone Dots along track
                    for (int s = 1; s <= _totalSteps; s++)
                      _buildScrollerStepDot(s, trackWidth),

                    // Right Icon: Summit House 2
                    Positioned(
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _scrubToFraction(1.0, animate: true);
                        },
                        child: Text(
                          _isGateExamPassed ? '🏰' : '🔒',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),

                    // Draggable Glowing Thumb with Live Step Badge
                    AnimatedBuilder(
                      animation: _transformController,
                      builder: (context, _) {
                        final size = MediaQuery.of(context).size;
                        final fraction = _getCurrentWorldFraction(size);
                        final maxThumbTravel = (trackWidth - thumbWidth - 20).clamp(0.0, trackWidth);
                        final thumbLeft = (fraction * maxThumbTravel) + 10;
                        final approxStep = _findStepClosestToFraction(fraction);

                        return Positioned(
                          left: thumbLeft.clamp(6.0, trackWidth - thumbWidth - 6.0),
                          child: IgnorePointer(
                            child: Container(
                              width: thumbWidth,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🏎️', style: TextStyle(fontSize: 11)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'S$approxStep',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScrollerStepDot(int step, double trackWidth) {
    final pos = getStepPosition(step, totalSteps: _totalSteps);
    final fraction = (pos.dx / _worldWidth).clamp(0.0, 1.0);
    final dotX = (fraction * (trackWidth - 36)) + 18;

    final isDone = _subStepFlags['step_$step'] ?? false;
    final isPrevDone = step == 1 || (_subStepFlags['step_${step - 1}'] ?? false);
    final isUnlocked = _isMasterAdmin || isPrevDone;
    final isCurrent = isUnlocked && !isDone;

    final dotColor = isDone
        ? const Color(0xFF10B981)
        : (isCurrent ? const Color(0xFFFFFC00) : Colors.white24);

    final dotSize = isCurrent ? 8.0 : 6.0;

    return Positioned(
      left: dotX - (dotSize / 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          final targetX = pos.dx - 48.0;
          _focusOnPoint(targetX, getGroundY(targetX), scale: _zoomScale, animate: true);
        },
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent || isDone
                ? [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.7),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStartHouse(int day) {
    const houseWidth = 240.0;
    const houseHeight = 145.0;
    const startX = 160.0;
    final groundY = getGroundY(startX);
    final palette = HousePalette.presets[(day - 1) % HousePalette.presets.length];
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(day);

    return Positioned(
      left: startX,
      top: groundY - houseHeight - 8.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(width: 8),
              // 🛡️ House Defense Signboard Button (User Audio Directive!)
              GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await PocketHouseDefenseChatPage.show(
                    context,
                    day: widget.day,
                    userId: widget.userId ?? _supabase.auth.currentUser?.id,
                    onStepFinished: (finishedStep) {
                      _onStepCompleted(finishedStep);
                    },
                  );
                  await _loadState(preserveCarPosition: true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        'House Defense Shield',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  /// 🎯 Futuristic High-Visibility Day Topic Billboard right after House 1 (User Audio Directive!)
  /// "Day 1 ന്റെ Today Lesson എന്ന് പറഞ്ഞിട്ട് ഒരു സാധനമുണ്ട്. അത് കുറച്ചു gap ഇട്ട് വെക്കണം.
  ///  ആ ground open world ന്റെ ground കുറച്ചുകൂടി width കൂട്ടി കഴിഞ്ഞാൽ Today Lesson എന്നുള്ളത്
  ///  correct place ചെയ്യാൻ പറ്റും. Correct അത് തിരിച്ച് place ചെയ്യേണ്ടി വരും കാരണം അത് ഇങ്ങനെ
  ///  hump പോലെ പോകുന്നുണ്ട്. എന്നിട്ട് അതിന്റെ അടിയിൽ just futuristic ആയിട്ട് കൊടുത്തോ.
  ///  അതിനുശേഷം ഇത് stack ആയി കിടക്കുന്നത് step 1."
  Widget _buildDayTopicBillboard(int day) {
    const boardWidth = 240.0;
    const boardHeight = 155.0;
    const boardX = 560.0; // Ample gap from House 1 (160..400) and before Step 1 (1040)

    // Left and right stilt ground intersection points to adapt cleanly to hillside wave/hump
    const leftStiltOffset = 42.0;
    const rightStiltOffset = boardWidth - 42.0;
    final leftGroundY = getGroundY(boardX + leftStiltOffset);
    final rightGroundY = getGroundY(boardX + rightStiltOffset);

    final cached = PocketDayCurriculumService.getCachedDay(day);
    final topicEn = PocketDayCurriculumService.getLocalizedText(
        cached?['course']?['topic'],
        lang: 'en',
        fallback: 'Day $day Mission');
    final topicMl = PocketDayCurriculumService.getLocalizedText(
        cached?['course']?['topic'],
        lang: 'ml');
    final grammar = cached?['grammarRule'] as Map<String, dynamic>? ?? {};
    final formula =
        grammar['formula']?.toString() ?? 'Daily Speaking Mastery';

    // Board bottom sits above highest ground point
    final boardTopY = math.min(leftGroundY, rightGroundY) - boardHeight - 34.0;
    final totalContainerHeight =
        (math.max(leftGroundY, rightGroundY) - boardTopY) + 16.0;

    return Positioned(
      left: boardX,
      top: boardTopY,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showTopicBoardDialog(day, topicEn, topicMl, formula, grammar);
        },
        child: SizedBox(
          width: boardWidth,
          height: totalContainerHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // 1. Futuristic Cyber Energy Stilts anchoring into hillside
              // Left Cyber Pillar
              Positioned(
                left: leftStiltOffset - 5,
                top: boardHeight - 4,
                height: (leftGroundY - boardTopY) - boardHeight + 10,
                width: 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F0FF), Color(0xFF0284C7), Color(0xFF0F172A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // Right Cyber Pillar
              Positioned(
                left: rightStiltOffset - 5,
                top: boardHeight - 4,
                height: (rightGroundY - boardTopY) - boardHeight + 10,
                width: 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFD97706), Color(0xFF0F172A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Futuristic Ground Stabilizer Base Pads on the hillside
              Positioned(
                left: leftStiltOffset - 16,
                top: (leftGroundY - boardTopY) - 4,
                child: Container(
                  width: 32,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFF00F0FF), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: rightStiltOffset - 16,
                top: (rightGroundY - boardTopY) - 4,
                child: Container(
                  width: 32,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Futuristic High-Visibility Holographic Billboard Card
              Container(
                width: boardWidth,
                height: boardHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E1B4B),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00F0FF), width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.20),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Header Hologram Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                'TODAY\'S LESSON',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF00F0FF), width: 0.8),
                          ),
                          child: Text(
                            'DAY $day',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF7DD3FC),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Topic Title EN
                    Text(
                      topicEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (topicMl.isNotEmpty && topicMl != topicEn) ...[
                      const SizedBox(height: 1),
                      Text(
                        topicMl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF93C5FD),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Futuristic Formula / Concept Energy Capsule
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF818CF8).withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              formula,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.robotoMono(
                                color: const Color(0xFFFFE066),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Bottom Tap Prompt & Step 1 Ahead
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tap for Details ℹ️',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 9),
                        ),
                        Row(
                          children: [
                            const Text('👉', style: TextStyle(fontSize: 9)),
                            const SizedBox(width: 3),
                            Text(
                              'Step 1 Ahead',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF10B981),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopicBoardDialog(int day, String topicEn, String topicMl, String formula, Map<String, dynamic> grammar) {
    final expEn = PocketDayCurriculumService.getLocalizedText(grammar['explanation'], lang: 'en');
    final expMl = PocketDayCurriculumService.getLocalizedText(grammar['explanation'], lang: 'ml');
    final goldenTipEn = PocketDayCurriculumService.getLocalizedText(grammar['goldenTip'], lang: 'en');
    final goldenTipMl = PocketDayCurriculumService.getLocalizedText(grammar['goldenTip'], lang: 'ml');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🎯', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DAY $day CURRICULUM BOARD',
                            style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(topicEn,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        if (topicMl.isNotEmpty && topicMl != topicEn)
                          Text(topicMl,
                              style: GoogleFonts.inter(color: const Color(0xFF93C5FD), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FORMULA / RULE:', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(formula, style: GoogleFonts.robotoMono(color: const Color(0xFFFFE066), fontSize: 15, fontWeight: FontWeight.bold)),
                    if (expMl.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(expMl, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5)),
                    ],
                    if (expEn.isNotEmpty && expEn != expMl) ...[
                      const SizedBox(height: 4),
                      Text(expEn, style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              if (goldenTipMl.isNotEmpty || goldenTipEn.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goldenTipMl.isNotEmpty ? goldenTipMl : goldenTipEn,
                          style: GoogleFonts.inter(color: const Color(0xFFFFE066), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _driveToStep(1);
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: Text('START STEP 1 NOW ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _driveToGate({bool openExamOnArrival = true}) {
    if (!mounted) return;
    const gateX = 4220.0;
    final targetX = gateX - 48.0;

    _driveAnimController.stop();
    final startX = _playerX;
    _driveAnimation = Tween<double>(begin: startX, end: targetX).animate(
      CurvedAnimation(parent: _driveAnimController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        if (!mounted) return;
        final currentX = _driveAnimation!.value;
        final dx = currentX - _prevPlayerX;
        _wheelAngle += dx * 0.14;
        _prevPlayerX = currentX;

        if (dx.abs() > 0.8 && math.Random().nextDouble() < 0.45) {
          final gy = getGroundY(currentX);
          _dustParticles.add(
            JumpDustParticle(
              x: currentX - (dx.sign * 24.0),
              y: gy + 4.0,
              vx: -dx.sign * (15.0 + math.Random().nextDouble() * 20.0),
              vy: -10.0 - math.Random().nextDouble() * 15.0,
            ),
          );
        }

        setState(() {
          _playerX = currentX;
          _isDriving = true;
        });

        _focusOnPoint(currentX, getGroundY(currentX), scale: _zoomScale, animate: false);
      });

    _driveAnimController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _isDriving = false;
      });
      HapticFeedback.mediumImpact();
      if (openExamOnArrival) {
        _showSpokenGateExamModal();
      }
    });
  }

  Widget _buildSummitGate(int day, bool isGatePassed) {
    const gateWidth = 140.0;
    const gateHeight = 160.0;
    const gateX = 4220.0;
    final groundY = getGroundY(gateX);

    return Positioned(
      left: gateX - (gateWidth / 2),
      top: groundY - gateHeight + 6.0,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _driveToGate(openExamOnArrival: true);
        },
        child: Column(
          children: [
            // Floating Status Pill
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isGatePassed ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isGatePassed ? const Color(0xFF34D399) : const Color(0xFFFFD700),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isGatePassed ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                        .withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGatePassed ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: isGatePassed ? const Color(0xFF34D399) : const Color(0xFFFFD700),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isGatePassed
                        ? '✨ GATE ${widget.day}: UNLOCKED (60%+ PASSED)'
                        : '🔒 GATE ${widget.day}: SPOKEN EXAM',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Arch Graphic
            Container(
              width: gateWidth,
              height: 125,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                border: Border.all(
                  color: isGatePassed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  width: 3.5,
                ),
                gradient: LinearGradient(
                  colors: isGatePassed
                      ? [
                          const Color(0xFF10B981).withValues(alpha: 0.35),
                          const Color(0xFF064E3B).withValues(alpha: 0.15),
                        ]
                      : [
                          const Color(0xFFEF4444).withValues(alpha: 0.35),
                          const Color(0xFF450A0A).withValues(alpha: 0.15),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isGatePassed ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isGatePassed
                            ? Icons.verified_rounded
                            : Icons.mic_external_on_rounded,
                        color: isGatePassed
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFFD700),
                        size: 32,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isGatePassed ? 'PASSED 🛡️' : 'TAP TO SPEAK',
                        style: GoogleFonts.outfit(
                          color: isGatePassed ? const Color(0xFF34D399) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isGatePassed)
                        Text(
                          'Retest Anytime',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 8.5,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpokenGateExamModal() {
    final allQuestions = Pocket90DaySpokenExamCurriculum.getExamForDay(widget.day);
    final questions = allQuestions.take(4).toList();

    if (questions.isEmpty) return;

    int currentIdx = 0;
    int correctCount = 0;
    bool isListening = false;
    String liveTranscript = '';
    bool? isCurrentCorrect;
    final stt.SpeechToText sttEngine = stt.SpeechToText();
    final FlutterTts ttsEngine = FlutterTts();
    bool sttReady = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isCompleted = currentIdx >= questions.length;

            if (isCompleted) {
              final scorePct = ((correctCount / questions.length) * 100).toInt();
              final isPassed = correctCount >= (questions.length >= 4 ? 3 : 1); // 75%+ pass threshold

              if (isPassed && !_isGateExamPassed) {
                // Award points & unlock
                final uid = widget.userId ?? _supabase.auth.currentUser?.id;
                SharedPreferences.getInstance().then((prefs) async {
                  await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_gate_exam_passed', true);
                  await PocketFortressDefenseService.recordTrainingPoints(100, uid);
                  if (mounted) {
                    setState(() {
                      _isGateExamPassed = true;
                    });
                  }
                });
              }

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isPassed ? '🏆' : '🔒', style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        isPassed ? 'GATE 1 CONQUERED!' : 'GATE 1 LOCKED',
                        style: GoogleFonts.outfit(
                          color: isPassed ? const Color(0xFFFFD700) : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPassed
                            ? 'Score: $correctCount / ${questions.length} ($scorePct%) • PASSED (60%+)'
                            : 'Score: $correctCount / ${questions.length} ($scorePct%) • NEED 60% (5/8)',
                        style: GoogleFonts.inter(
                          color: isPassed ? const Color(0xFF34D399) : const Color(0xFFF87171),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isPassed) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132238),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌟', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                '+100 POCKET SCORE AWARDED!',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'House 2 (Day 2) is officially unlocked on the Summit!',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          'Tap Retry to speak the questions again and conquer the gate!',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPassed ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            if (isPassed) {
                              Navigator.pop(dlgCtx);
                            } else {
                              setModalState(() {
                                currentIdx = 0;
                                correctCount = 0;
                                liveTranscript = '';
                                isCurrentCorrect = null;
                              });
                            }
                          },
                          child: Text(
                            isPassed ? 'CONTINUE TO ROAD ➔' : 'RETRY EXAM 🔄',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final q = questions[currentIdx];
            final qText = (q['question'] is Map)
                ? (q['question']['en']?.toString() ?? '')
                : (q['question']?.toString() ?? '');
            final qTextMl = (q['question'] is Map)
                ? (q['question']['ml']?.toString() ?? '')
                : '';
            final targetText = (q['targetText'] ?? '').toString();
            final voicePrompt = (q['voicePrompt'] ?? 'Say: $targetText').toString();
            final options = (q['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final correctIndex = q['correctIndex'] as int? ?? 0;

            void evaluateSpeech(String speechInput) {
              final spoken = speechInput.toLowerCase().trim();
              final target = targetText.toLowerCase().trim();
              if (spoken.isNotEmpty &&
                  (spoken.contains(target) ||
                   target.contains(spoken) ||
                   PocketPronunciationEvaluator.isMatch(
                       spokenText: spoken, targetSentence: target, thresholdPercentage: 45))) {
                setModalState(() {
                  isCurrentCorrect = true;
                  correctCount++;
                });
                try {
                  PocketGameAudioService.instance.playCorrectSound();
                } catch (_) {}
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Progress & Close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            '🎙️ GATE ${widget.day} SPOKEN EXAM: ${currentIdx + 1} / ${questions.length}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            sttEngine.stop();
                            ttsEngine.stop();
                            Navigator.pop(dlgCtx);
                          },
                          icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (currentIdx + 1) / questions.length,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Question Prompt
                    Text(
                      qText,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                    if (qTextMl.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        qTextMl,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF93C5FD),
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Target Box: Prompt to Speak
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D2D),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrentCorrect == true
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFD700).withValues(alpha: 0.6),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SPEAK ALOUD:',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  voicePrompt,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await ttsEngine.stop();
                              await ttsEngine.speak(voicePrompt);
                            },
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Big Microphone Button
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              if (isListening) {
                                await sttEngine.stop();
                                setModalState(() => isListening = false);
                                return;
                              }

                              if (!sttReady) {
                                sttReady = await sttEngine.initialize(
                                  onStatus: (status) {
                                    if (status == 'done' || status == 'notListening') {
                                      setModalState(() => isListening = false);
                                    }
                                  },
                                  onError: (_) => setModalState(() => isListening = false),
                                );
                              }

                              if (sttReady) {
                                setModalState(() {
                                  isListening = true;
                                  liveTranscript = '';
                                });
                                await sttEngine.listen(
                                  onResult: (result) {
                                    setModalState(() {
                                      liveTranscript = result.recognizedWords;
                                    });
                                    evaluateSpeech(liveTranscript);
                                  },
                                  listenOptions: stt.SpeechListenOptions(
                                    listenMode: stt.ListenMode.confirmation,
                                    cancelOnError: true,
                                  ),
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isListening
                                    ? const Color(0xFFEF4444)
                                    : (isCurrentCorrect == true
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF2563EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isListening ? const Color(0xFFEF4444) : const Color(0xFF2563EB))
                                        .withValues(alpha: 0.5),
                                    blurRadius: isListening ? 20 : 10,
                                    spreadRadius: isListening ? 4 : 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isListening
                                    ? Icons.mic_rounded
                                    : (isCurrentCorrect == true
                                        ? Icons.check_circle_rounded
                                        : Icons.mic_none_rounded),
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isListening
                                ? 'Listening... Speak now!'
                                : (isCurrentCorrect == true
                                    ? '✅ Correct Speech Recognized!'
                                    : 'Tap mic and speak aloud'),
                            style: GoogleFonts.inter(
                              color: isListening
                                  ? const Color(0xFFF87171)
                                  : (isCurrentCorrect == true
                                      ? const Color(0xFF34D399)
                                      : Colors.white70),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Or Tap Multiple Choice Options
                    Text(
                      'Or choose correct option:',
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final opt = entry.value;
                        final isCorrectOpt = idx == correctIndex;
                        final isChosen = isCurrentCorrect == true && isCorrectOpt;

                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 80) / 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isChosen
                                  ? const Color(0xFF064E3B)
                                  : const Color(0xFF1E293B),
                              foregroundColor: isChosen ? const Color(0xFF34D399) : Colors.white,
                              side: BorderSide(
                                color: isChosen ? const Color(0xFF10B981) : Colors.white12,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isCurrentCorrect == true
                                ? null
                                : () {
                                    HapticFeedback.selectionClick();
                                    if (isCorrectOpt) {
                                      setModalState(() {
                                        isCurrentCorrect = true;
                                        correctCount++;
                                      });
                                      try {
                                        PocketGameAudioService.instance.playCorrectSound();
                                      } catch (_) {}
                                      Future.delayed(const Duration(milliseconds: 550), () {
                                        if (!dlgCtx.mounted) return;
                                        sttEngine.stop();
                                        ttsEngine.stop();
                                        setModalState(() {
                                          currentIdx++;
                                          liveTranscript = '';
                                          isCurrentCorrect = null;
                                          isListening = false;
                                        });
                                      });
                                    } else {
                                      setModalState(() {
                                        isCurrentCorrect = false;
                                      });
                                      try {
                                        PocketGameAudioService.instance.playIncorrectSound();
                                      } catch (_) {}
                                    }
                                  },
                            child: Text(
                              opt,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Next Question Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          sttEngine.stop();
                          ttsEngine.stop();
                          setModalState(() {
                            currentIdx++;
                            liveTranscript = '';
                            isCurrentCorrect = null;
                            isListening = false;
                          });
                        },
                        child: Text(
                          currentIdx + 1 == questions.length
                              ? 'SUBMIT EXAM & SEE RESULT ➔'
                              : 'NEXT QUESTION ➔',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummitHouse(int targetDay, bool isUnlocked) {
    const houseWidth = 240.0;
    const houseHeight = 145.0;
    const summitX = 4480.0;
    final groundY = getGroundY(summitX);
    final palette =
        HousePalette.presets[(targetDay - 1) % HousePalette.presets.length];
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(targetDay);

    return Positioned(
      left: summitX,
      top: groundY - houseHeight - 8.0,
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
    final pos = getStepPosition(stepIndex, totalSteps: _totalSteps);
    final isDone = _subStepFlags['step_$stepIndex'] ?? false;
    final isPrevDone =
        stepIndex == 1 || (_subStepFlags['step_${stepIndex - 1}'] ?? false);
    // Strict sequential unlocking:
    // A step is ONLY visually unlocked if the immediate previous step is done.
    final isUnlocked = isPrevDone;
    final isCurrent = isUnlocked && !isDone;
    const nodeSize = 54.0;
    const containerWidth = 200.0;

    final stepInfo = _getStepDetails(stepIndex);

    return Positioned(
      left: pos.dx - (containerWidth / 2),
      top: pos.dy - nodeSize - 20.0,
      width: containerWidth,
      height: 120.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. 🔥 Animated Prominent Green Arrow hovering ABOVE node (User Audio Directive!)
          // Swaying back and forth ("ഇങ്ങനെ ഇങ്ങനെ ആടിക്കൊണ്ടിരിക്കുക") with gentle bounce and green glow
          if (isCurrent)
            Positioned(
              top: -44.0,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _ambientAnimController,
                  builder: (context, _) {
                    final t = _ambientAnimController.value;
                    // Bouncing up and down:
                    final bounce = math.sin(t * math.pi * 6) * 4.5;
                    // Oscillating / Swaying back and forth:
                    final sway = math.sin(t * math.pi * 4) * 0.22;
                    // Pulsing green glow:
                    final glow = 0.70 + (math.sin(t * math.pi * 6) * 0.30);

                    return Transform.translate(
                      offset: Offset(0, -bounce),
                      child: Transform.rotate(
                        angle: sway,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF34D399),
                                    Color(0xFF10B981),
                                    Color(0xFF047857),
                                  ],
                                ),
                                border: Border.all(color: Colors.white, width: 2.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: glow),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF34D399).withValues(alpha: 0.45),
                                    blurRadius: 24,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            // Downward pointing beacon tip
                            Transform.translate(
                              offset: const Offset(0, -3),
                              child: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: const Color(0xFF10B981),
                                size: 20,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF10B981).withValues(alpha: glow),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 2. The Main Milestone Pedestal & Title Pill (Exact uniform baseline for all 17 nodes!)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
              if (!isUnlocked) {
                if (_isMasterAdmin) {
                  // Master Admin testing bypass: allow opening any locked step directly for testing!
                  _driveToStep(stepIndex, openActivityOnArrival: false);
                  _launchStepActivity(stepIndex);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🔒 Step ${stepIndex - 1} പൂർത്തിയാക്കിയ ശേഷം മാത്രമേ Step $stepIndex അൺലോക്ക് ചെയ്യാനാകൂ! (Complete Step ${stepIndex - 1} first)',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF1E2438),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              // Immediately reposition buggy smoothly
              _driveToStep(stepIndex, openActivityOnArrival: false);
              // Immediately launch activity on tap (User Audio Directive: "ടാപ്പ് ചെയ്യുമ്പോൾ തന്നെ പേജ് വരണം")
              _launchStepActivity(stepIndex);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Step Title Pill (Safely bounded width)
                Container(
                  width: 194,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF10B981)
                          : (isCurrent ? const Color(0xFFFFFC00) : Colors.white24),
                      width: isDone ? 1.6 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDone
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(stepInfo.icon, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Step $stepIndex: ${stepInfo.title}',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: isDone
                                ? const Color(0xFF6EE7B7)
                                : (isCurrent ? const Color(0xFFFFFC00) : Colors.white70),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isDone) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Stepping Stone Node Milestone Pedestal
                SizedBox(
                  width: nodeSize,
                  height: nodeSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isCurrent)
                        AnimatedBuilder(
                          animation: _ambientAnimController,
                          builder: (context, _) {
                            final pulse = 1.0 + (math.sin(_ambientAnimController.value * math.pi * 4) * 0.12);
                            return Transform.scale(
                              scale: pulse,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFFC00).withValues(alpha: 0.7),
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
                            width: isDone ? 2.8 : 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDone
                                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                  : (isCurrent
                                      ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.4)),
                              blurRadius: (isDone || isCurrent) ? 14 : 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                              : (isUnlocked
                                  ? Text(
                                      stepInfo.icon,
                                      style: const TextStyle(fontSize: 22),
                                    )
                                  : const Icon(Icons.lock_rounded,
                                      color: Colors.white38, size: 18)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ⭐ 3-STAR LEVEL DISPLAY (User Audio Directive: "Tick-um athinte adiyil avinte 3 star-um koode build cheythaal better aavum alle?")
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFFFFD700).withValues(alpha: 0.7)
                          : Colors.white12,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDone
                            ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (starIdx) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Icon(
                          isDone ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 13,
                          color: isDone
                              ? const Color(0xFFFFD700)
                              : (isCurrent ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                          shadows: isDone
                              ? const [
                                  BoxShadow(
                                    color: Color(0xFFFFD700),
                                    blurRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StepInfo _getStepDetails(int s) {
    switch (s) {
      case 1:
        return const _StepInfo('Concept Room & Avatar Chat', '🏛️', Color(0xFF00F0FF));
      case 2:
        return const _StepInfo('Sentence Builder Game', '🧩', Color(0xFF00E5FF));
      case 3:
        return const _StepInfo('Essential Words & Spelling', '👂', Color(0xFF38BDF8));
      case 4:
        return const _StepInfo('Spoken English Chat', '🎙️', Color(0xFF10B981));
      case 5:
        return const _StepInfo('Reading Room', '📖', Color(0xFF60A5FA));
      case 6:
        return const _StepInfo('20-Turn Spoken Simulator', '🗣️', Color(0xFFEC4899));
      case 7:
        return const _StepInfo('Open-World Vocab Quest', '🚗', Color(0xFFFF8906));
      case 8:
        return const _StepInfo('English Hub Community Chat', '💬', Color(0xFFFFFC00));
      case 9:
        return const _StepInfo('House Defense Shield Command', '🛡️', Color(0xFF8B5CF6));
      case 10:
        return const _StepInfo('Poketalk: 4-Day Spoken Pact', '📞', Color(0xFFF59E0B));
      case 11:
        return const _StepInfo('House Attack Quest: Citadel Raid', '⚔️', Color(0xFFEF4444));
      default:
        return const _StepInfo('Practice Ledge', '⭐', Colors.white);
    }
  }

  Future<void> _syncStepCompletionIfDone(int s) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    final userKey = uid != null ? 'pocket_day_${uid}_${widget.day}_step_${s}_done' : null;
    final guestKey = 'pocket_day_guest_${widget.day}_step_${s}_done';
    final legacyCompletedKey = 'pocket_day_${uid ?? "guest"}_${widget.day}_step_${s}_completed';

    final isDone = (userKey != null && prefs.getBool(userKey) == true) ||
        (prefs.getBool(guestKey) == true) ||
        (prefs.getBool(legacyCompletedKey) == true);

    if (isDone) {
      await _onStepCompleted(s);
    }
  }

  Future<void> _launchStepActivity(int s) async {
    final day = widget.day;
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;

    // Step 1 on ALL DAYS (1 to 90): Concept Room & Avatar Chat
    if (s == 1) {
      if (day == 1) {
        await PocketDay1Step1AvatarChatPage.show(
          context,
          userId: uid,
          onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
        );
      } else if (day == 2) {
        await PocketDay2Step1AvatarChatPage.show(
          context,
          userId: uid,
          onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
        );
      } else {
        await PocketDayAvatarChatPage.show(
          context,
          day: day,
          userId: uid,
          onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
        );
      }
      await _syncStepCompletionIfDone(1);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 2 on ALL DAYS (1 to 90): Flame Sentence Builder Game
    if (s == 2) {
      await PocketSentenceBuilderGamePage.show(
        context,
        day: day,
        userId: uid,
        onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
      );
      await _syncStepCompletionIfDone(2);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 3 on ALL DAYS (1 to 90): Essential Words & Spelling Challenge Game
    if (s == 3) {
      await PocketEssentialSpellingPage.show(
        context,
        day: day,
        userId: uid,
        onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
      );
      await _syncStepCompletionIfDone(3);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 4 on ALL DAYS (1 to 90): Spoken English Conversational Chat (1-on-1 Voice Chat)
    if (s == 4) {
      if (day == 1) {
        await PocketDay1Step4AvatarChatPage.show(
          context,
          userId: uid,
          onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
        );
      } else if (day == 2) {
        await PocketDay2Step4AvatarChatPage.show(
          context,
          userId: uid,
          onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
        );
      } else {
        await PocketDay1Step4AvatarChatPage.show(
          context,
          day: day,
          userId: uid,
          onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
        );
      }
      await _syncStepCompletionIfDone(4);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 5 on ALL DAYS (1 to 90): Reading Room (Illustrated Storybook + Audio + Mic)
    if (s == 5) {
      await PocketDay1Step5AvatarChatPage.show(
        context,
        day: day,
        stepIndex: 5,
        userId: uid,
        onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
      );
      await _syncStepCompletionIfDone(5);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 6 on ALL DAYS (1 to 90): 20-Turn Spoken Conversational Simulator
    if (s == 6) {
      final res = await PocketSpokenAvatarSimulatorPage.launch(
        context,
        day: day,
        onCompleted: () => _onStepCompleted(6),
      );
      if (res == true) {
        await _onStepCompleted(6);
      }
      await _syncStepCompletionIfDone(6);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 7 on ALL DAYS (1 to 90): Open-World Vocab Quest (5-Ride Vehicle Vocab Drive)
    if (s == 7) {
      await PocketVocabOpenWorldDrivePage.show(
        context,
        day: day,
        stepIndex: 7,
        userId: uid,
        onCompleted: () => _onStepCompleted(7),
      );
      await _syncStepCompletionIfDone(7);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 8 on ALL DAYS (1 to 90): English Hub Community Chat
    if (s == 8) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Scaffold(
            backgroundColor: const Color(0xFF0A1118),
            body: SafeArea(
              child: EnglishLearningGroupChatWidget(
                onCancel: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      );
      await _onStepCompleted(8);
      await _syncStepCompletionIfDone(8);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 9 on ALL DAYS (1 to 90): House Defense Shield Command
    if (s == 9) {
      await PocketHouseDefenseChatPage.show(
        context,
        day: day,
        stepIndex: 9,
        userId: uid,
        onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
      );
      await _syncStepCompletionIfDone(9);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 10 on ALL DAYS (1 to 90): Poketalk: 4-Day Spoken Pact
    if (s == 10) {
      await PocketTalkCardSwiperDialog.show(context);
      await _onStepCompleted(10);
      await _syncStepCompletionIfDone(10);
      await _loadState(preserveCarPosition: true);
      return;
    }

    // Step 11 on ALL DAYS (1 to 90): House Attack Quest: Raid Rival Citadel
    if (s == 11) {
      await PocketHouseAttackPage.show(
        context,
        day: day,
        stepIndex: 11,
        userId: uid,
        onStepFinished: (finishedStep) => _onStepCompleted(finishedStep),
      );
      await _syncStepCompletionIfDone(11);
      await _loadState(preserveCarPosition: true);
      return;
    }

    _onStepCompleted(s);
    await _loadState(preserveCarPosition: true);
  }
}

class _StepInfo {
  final String title;
  final String icon;
  final Color color;

  const _StepInfo(this.title, this.icon, this.color);
}

/// 🎨 100% Daytime / Light Mode Open World Mountain & Living Ocean Painter
class _DayOpenWorldMountainPainter extends CustomPainter {
  final double gameTime;
  final List<CruisingBoat> boats;
  final List<FlyingBird> birds;
  final List<JumpDustParticle> dustParticles;

  _DayOpenWorldMountainPainter({
    required this.gameTime,
    required this.boats,
    required this.birds,
    required this.dustParticles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final worldW = size.width;
    final worldH = size.height;

    // 1. Sky Gradient (Light Mode sunny day)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldW, worldH));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldW, worldH), skyPaint);

    // 2. Radiant Warm Sun with Glowing Halos
    const sunCenter = Offset(3500.0, 150.0);
    canvas.drawCircle(
      sunCenter,
      80.0,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawCircle(sunCenter, 44.0, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(sunCenter, 28.0, Paint()..color = const Color(0xFFFFFBEB));

    // 3. Drifting Fluffy Clouds
    for (double cx = 80; cx < worldW; cx += 460) {
      final cy = 110.0 + (math.sin(cx * 0.7) * 35.0);
      _drawFluffyCloud(canvas, cx + ((gameTime * 14.0) % 380.0), cy);
    }

    // 4. Flying Seagulls
    for (final bird in birds) {
      bird.render(canvas);
    }

    // 5. Panoramic Distant Mountain Horizon (Atmospheric azure/teal haze gradient)
    final distantMountainPath = Path();
    distantMountainPath.moveTo(0, worldH);
    distantMountainPath.lineTo(0, 680);
    for (double x = 0; x <= worldW; x += 180) {
      final my = 560.0 - (math.sin(x * 0.0018) * 80.0) - (math.cos(x * 0.0032) * 45.0);
      distantMountainPath.lineTo(x, my);
    }
    distantMountainPath.lineTo(worldW, worldH);
    distantMountainPath.close();

    final distantMountainPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 480, worldW, 600));
    canvas.drawPath(
      distantMountainPath,
      distantMountainPaint..color = distantMountainPaint.color.withValues(alpha: 0.38),
    );

    // 6. Midground Rolling Foothills & Soft Evergreen Pine Ridge
    final foothillPath = Path();
    foothillPath.moveTo(0, worldH);
    foothillPath.lineTo(0, 840);
    for (double x = 0; x <= worldW; x += 140) {
      final fy = 780.0 - (math.sin(x * 0.0025 + 0.6) * 55.0);
      foothillPath.lineTo(x, fy);
    }
    foothillPath.lineTo(worldW, worldH);
    foothillPath.close();

    final foothillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF065F46)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 700, worldW, 500));
    canvas.drawPath(
      foothillPath,
      foothillPaint..color = foothillPaint.color.withValues(alpha: 0.55),
    );

    // 7. Layer 3: Rolling Green Hills (Ascending slope connecting House 1 to House 2)
    final hillPath = Path();
    hillPath.moveTo(0, _PocketDayOpenWorldAdventurePageState.getGroundY(0));
    for (double x = 0; x <= worldW; x += 15) {
      hillPath.lineTo(x, _PocketDayOpenWorldAdventurePageState.getGroundY(x));
    }
    hillPath.lineTo(worldW, worldH);
    hillPath.lineTo(0, worldH);
    hillPath.close();

    final hillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF15803D), Color(0xFF166534), Color(0xFF14532D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 400, worldW, 1200));
    canvas.drawPath(hillPath, hillPaint);

    // Highlighted Green Grassy Ridge
    final ridgePaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawPath(hillPath, ridgePaint);

    // Cobblestone Highway Path along the hills
    final highwayPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawPath(hillPath, highwayPaint);

    // Roadside Lantern Posts
    for (double x = 160; x < worldW; x += 280) {
      final y = _PocketDayOpenWorldAdventurePageState.getGroundY(x);
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y - 48),
        Paint()..color = const Color(0xFF334155)..strokeWidth = 3.5,
      );
      canvas.drawCircle(Offset(x, y - 48), 5.5, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawCircle(
        Offset(x, y - 48),
        22.0,
        Paint()
          ..color = const Color(0xFFFFFC00).withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // 8. Layer 4: Living Turquoise Ocean at the base of the world
    const oceanTopY = 1260.0;
    final oceanRect = Rect.fromLTWH(0, oceanTopY, worldW, worldH - oceanTopY);
    final oceanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(oceanRect);
    canvas.drawRect(oceanRect, oceanPaint);

    // Ocean Surface Wave Ripples
    final wavePath = Path();
    wavePath.moveTo(0, oceanTopY);
    for (double wx = 0; wx <= worldW; wx += 25) {
      final wy = oceanTopY + (math.sin((wx * 0.02) + (gameTime * 3.5)) * 4.5);
      wavePath.lineTo(wx, wy);
    }
    final waveRipple = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawPath(wavePath, waveRipple);

    // Cruising Boats on the ocean
    for (final boat in boats) {
      boat.render(canvas, false);
    }

    // Leaping Dolphins in the sea
    for (int d = 0; d < 3; d++) {
      final dolphinBaseX = 800.0 + (d * 1400.0);
      final dolphinCycle = ((gameTime * 0.9) + (d * 2.1)) % 5.0;
      if (dolphinCycle < 1.6) {
        final progress = dolphinCycle / 1.6;
        final dx = dolphinBaseX + (progress * 120.0);
        final dy = oceanTopY - (math.sin(progress * math.pi) * 38.0);
        final angle = math.cos(progress * math.pi) * 0.55;

        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(angle);
        _drawLeapingDolphin(canvas);
        canvas.restore();
      }
    }

    // Dust particles from wheels
    for (final p in dustParticles) {
      p.render(canvas);
    }
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(Offset(cx, cy), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 20, cy - 8), 28, cloudPaint);
    canvas.drawCircle(Offset(cx + 45, cy - 4), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 60, cy), 16, cloudPaint);
  }

  void _drawLeapingDolphin(Canvas canvas) {
    final body = Path();
    body.moveTo(-18, 0);
    body.quadraticBezierTo(-6, -10, 8, -6);
    body.quadraticBezierTo(18, 0, 24, 2);
    body.lineTo(26, 6);
    body.quadraticBezierTo(14, 4, 4, 3);
    body.quadraticBezierTo(-8, 3, -18, 0);
    body.close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF38BDF8));

    // Dorsal Fin
    final fin = Path();
    fin.moveTo(0, -8);
    fin.lineTo(4, -16);
    fin.lineTo(7, -8);
    fin.close();
    canvas.drawPath(fin, Paint()..color = const Color(0xFF0284C7));
  }

  @override
  bool shouldRepaint(covariant _DayOpenWorldMountainPainter oldDelegate) => true;
}

/// 🏎️ Red & Gold Sports Buggy Painter with Spinning Rims & Driver Avatar
class _SportsBuggyPainter extends CustomPainter {
  final double wheelAngle;
  final VectorAvatarPainter avatarPainter;

  _SportsBuggyPainter({
    required this.wheelAngle,
    required this.avatarPainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0 + 4.0);

    // 1. Suspension Springs
    final springPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.2;
    canvas.drawLine(const Offset(-22, 2), const Offset(-22, 14), springPaint);
    canvas.drawLine(const Offset(24, 2), const Offset(24, 14), springPaint);

    // 2. Wheels (Rubber Tires + Gold Spokes Rims)
    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()
      ..color = const Color(0xFFFFFC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final wx in [-22.0, 24.0]) {
      canvas.drawCircle(Offset(wx, 14), 10.5, wheelPaint);
      canvas.drawCircle(Offset(wx, 14), 7.5, rimPaint);
      for (int s = 0; s < 4; s++) {
        final a = wheelAngle + (s * math.pi / 2.0);
        canvas.drawLine(
          Offset(wx, 14),
          Offset(wx + math.cos(a) * 7.0, 14 + math.sin(a) * 7.0),
          Paint()..color = Colors.white70..strokeWidth = 1.2,
        );
      }
    }

    // 3. Sleek Red & Gold Chassis Body
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

    // Gold Racing Stripe
    canvas.drawLine(
      const Offset(-30, 6),
      const Offset(34, 6),
      Paint()..color = const Color(0xFFFFFC00)..strokeWidth = 2.2,
    );

    // 4. White Tubular Roll Cage
    final cagePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-10, -4), const Offset(-4, -18), cagePaint);
    canvas.drawLine(const Offset(-4, -18), const Offset(14, -6), cagePaint);

    // 5. Glowing Headlight
    canvas.drawCircle(const Offset(34, 6), 3.5, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(
      const Offset(42, 6),
      9.0,
      Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 6. Steering Wheel
    canvas.drawLine(const Offset(8, -4), const Offset(6, -11), Paint()..color = Colors.black..strokeWidth = 2.5);
    canvas.drawCircle(const Offset(6, -11), 3.5, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // 7. Driver Seat
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -12, 16, 12), const Radius.circular(4)),
      Paint()..color = const Color(0xFF0F172A),
    );

    // 8. Player's Avatar Seated in Driver Seat
    const headRadius = 11.0;
    canvas.save();
    canvas.translate(-headRadius + 2, -26 - headRadius);
    avatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SportsBuggyPainter oldDelegate) =>
      oldDelegate.wheelAngle != wheelAngle;
}
