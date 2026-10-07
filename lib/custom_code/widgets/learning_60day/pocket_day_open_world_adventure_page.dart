import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_painter.dart';
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
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_practice_speaking_card.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_reading_library_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day1_tutor_curriculum.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day1_interactive_flow_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_open_world_game_page.dart'
    show CruisingBoat, CruisingBoatType, FlyingBird, JumpDustParticle;

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

  final Map<String, bool> _subStepFlags = {};
  bool _isLoading = true;
  static const double _zoomScale = 1.05; // Default close-up zoom for clear viewing!

  // World Canvas Geometry
  static const double _worldWidth = 4600.0;
  static const double _worldHeight = 1600.0;

  // Sports Buggy State
  double _playerX = 320.0;
  double _wheelAngle = 0.0;
  double _prevPlayerX = 320.0;
  // ignore: unused_field
  bool _isDriving = false;
  int _currentLedgeStep = 1;

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
      CruisingBoat(x: 1500, y: 1410, speed: 45, boatType: CruisingBoatType.sailboat),
      CruisingBoat(x: 2600, y: 1390, speed: 36, boatType: CruisingBoatType.cruiseShip),
      CruisingBoat(x: 3700, y: 1420, speed: 60, boatType: CruisingBoatType.speedboat),
    ];

    _seagulls = [
      FlyingBird(x: 300, y: 160, speed: 38),
      FlyingBird(x: 1100, y: 130, speed: 44),
      FlyingBird(x: 2200, y: 180, speed: 35),
      FlyingBird(x: 3200, y: 140, speed: 48),
      FlyingBird(x: 4100, y: 170, speed: 40),
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

  Day1Track _day1Track = Day1Track.zero;
  int get _totalSteps => widget.day == 1 ? 8 : 17;

  /// Exact coordinate of milestone step on the mountain slope
  static Offset getStepPosition(int stepIndex, {int totalSteps = 17}) {
    final denominator = (totalSteps > 1) ? (totalSteps - 1).toDouble() : 1.0;
    final progress = (stepIndex - 1) / denominator;
    const startX = 520.0;
    const endX = 3560.0;
    final x = startX + (endX - startX) * progress;
    final y = getGroundY(x);
    return Offset(x, y);
  }

  bool _hasInitialPositioned = false;

  Future<void> _loadState({bool preserveCarPosition = false}) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    if (widget.day == 1) {
      final trackKey = 'pocket_day1_selected_track_${uid ?? "guest"}';
      final savedTrackStr = prefs.getString(trackKey);
      if (savedTrackStr != null) {
        for (final t in Day1Track.values) {
          if (t.name == savedTrackStr) {
            _day1Track = t;
            break;
          }
        }
      }
    }

    final Map<String, bool> flags = {};
    for (int step = 1; step <= _totalSteps; step++) {
      final key = 'pocket_day_${uid ?? "guest"}_${widget.day}_step_${step}_done';
      flags['step_$step'] = prefs.getBool(key) ?? false;
    }

    // 🛡️ Sequential integrity sanitization:
    // Ensure genuine step progression (Step 1 -> Step 2 -> Step 3...).
    // If an earlier step is incomplete, clean up any orphaned future step ticks!
    bool hadIncomplete = false;
    for (int step = 1; step <= _totalSteps; step++) {
      if (!hadIncomplete) {
        if (!(flags['step_$step'] ?? false)) {
          hadIncomplete = true;
        }
      } else {
        if (flags['step_$step'] == true) {
          flags['step_$step'] = false;
          final key = 'pocket_day_${uid ?? "guest"}_${widget.day}_step_${step}_done';
          await prefs.remove(key);
        }
      }
    }

    if (mounted) {
      final activeStep = _findFirstIncompleteStep(flags);

      setState(() {
        _subStepFlags.clear();
        _subStepFlags.addAll(flags);
        _isLoading = false;
        _currentLedgeStep = activeStep;
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

  int get _firstIncompleteStep => _findFirstIncompleteStep(_subStepFlags);

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
      _transformController.value = targetMatrix;
    } else {
      _transformController.value = targetMatrix;
    }
  }

  Future<void> _onStepCompleted(int stepIndex) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    int pointsAwarded = (stepIndex == _totalSteps) ? 120 : 30;

    if (uid != null && uid.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
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
        widget.onCompleted?.call();
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

                  // 🏡 SUMMIT: House 2 (Day ${day + 1} Estate on mountain summit)
                  _buildSummitHouse(widget.day + 1, completedCount >= _totalSteps),

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

          // 3. Stage Complete Bottom Floating Bar
          if (completedCount >= _totalSteps)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAY ${widget.day} COMPLETE!',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'House ${widget.day + 1} & Stage Avatar Unlocked 🎉',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFEF08A),
                                fontSize: 11.5,
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          widget.onCompleted?.call();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ENTER DAY ${widget.day + 1}',
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.day == 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _day1Track.color, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: _day1Track.color.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: Day1Track.values.map((t) {
                      final isSelected = t == _day1Track;
                      return GestureDetector(
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          final uid = widget.userId ?? _supabase.auth.currentUser?.id;
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('pocket_day1_selected_track_${uid ?? "guest"}', t.name);
                          setState(() => _day1Track = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? t.color : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.badge,
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 17),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Level Title & Progress Capsule
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
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
                        children: [
                          const Text('🏔️', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.day == 1
                                  ? 'DAY 1: ME + BASIC ENGLISH'
                                  : 'Day ${widget.day} Mountain Trail',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                            ),
                            child: Text(
                              '$completedCount / $_totalSteps Done',
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

                  // 📍 Focus Button (Re-centers on vehicle / active step)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _focusOnActiveStep(animate: true);
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.75),
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
                          const Text('📍', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            'Focus',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartHouse(int day) {
    const houseWidth = 240.0;
    const houseHeight = 145.0;
    const startX = 180.0;
    final groundY = getGroundY(startX);
    final palette = HousePalette.presets[(day - 1) % HousePalette.presets.length];
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(day);

    return Positioned(
      left: startX,
      top: groundY - houseHeight - 8.0,
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
    const houseWidth = 240.0;
    const houseHeight = 145.0;
    const summitX = 3820.0;
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
    // A step is ONLY unlocked if the immediate previous step is done.
    final isUnlocked = isPrevDone;
    final isCurrent = isUnlocked && !isDone;
    const nodeSize = 54.0;
    const containerWidth = 140.0;

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
                  width: 130,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFFFFC00)
                          : (isDone ? const Color(0xFF10B981) : Colors.white24),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: isCurrent
                                ? const Color(0xFFFFFC00)
                                : (isDone ? const Color(0xFF6EE7B7) : Colors.white70),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StepInfo _getStepDetails(int s) {
    if (widget.day == 1) {
      final steps = Day1Curriculum.getSteps(_day1Track);
      if (s >= 1 && s <= steps.length) {
        final st = steps[s - 1];
        return _StepInfo(st.titleEn, st.icon, _day1Track.color);
      }
    }
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
        return const _StepInfo('AI Speech Lab', '🗣️', Color(0xFF38BDF8));
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
    if (day == 1) {
      await PocketDay1InteractiveFlowPage.show(
        context,
        initialStep: s,
        initialTrack: _day1Track,
        userId: widget.userId ?? _supabase.auth.currentUser?.id,
        onStepFinished: (finishedStep) {
          _onStepCompleted(finishedStep);
        },
        onCompleted: () {
          _onStepCompleted(8);
        },
      );
      await _loadState(preserveCarPosition: true);
      return;
    }
    switch (s) {
      case 1:
        await PocketInteractiveTeacherGameModal.show(
          context,
          day: day,
          userId: widget.userId ?? _supabase.auth.currentUser?.id,
          onCompleted: () => _onStepCompleted(1),
        );
        break;

      case 2:
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
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: PocketPracticeSpeakingCard(
              day: day,
              isCompleted: _subStepFlags['step_8'] ?? false,
              onCompleted: (val) {
                if (val) {
                  Navigator.pop(ctx);
                  _onStepCompleted(8);
                }
              },
            ),
          ),
        );
        break;

      case 9:
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
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('Community Chat Practice',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Engage with your fellow English learners in the Community Group. Share today\'s vocabulary word or greeting!',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('LATER', style: GoogleFonts.outfit(color: Colors.white54)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _onStepCompleted(10);
                },
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                label: Text('I PARTICIPATED ✓', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
        break;

      case 11:
        // User Audio Directive: 1-on-1 English phone call replaced with AI Speech Lab!
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: PocketPracticeSpeakingCard(
              day: day,
              isCompleted: _subStepFlags['step_11'] ?? false,
              onCompleted: (val) {
                if (val) {
                  Navigator.pop(ctx);
                  _onStepCompleted(11);
                }
              },
            ),
          ),
        );
        break;

      case 12:
        final res = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const CyberVocabGamePage()),
        );
        if (res == true) _onStepCompleted(12);
        break;

      case 13:
        await PocketReadingLibraryModal.show(context, currentDay: day);
        _onStepCompleted(13);
        break;

      case 14:
        await PocketCodeEnglishDecoderModal.show(
          context,
          currentDay: day,
        );
        _onStepCompleted(14);
        break;

      case 15:
        final res = await PocketFluencyGymDetailPage.open(
          context,
          day: day,
          selectedLanguage: 'Malayalam',
          isInitiallyCompleted: _subStepFlags['step_15'] ?? false,
          onCompleted: (val) {
            if (val) _onStepCompleted(15);
          },
        );
        if (res == true) _onStepCompleted(15);
        break;

      case 16:
        PocketDefenseTrapModal.show(
          context,
          day,
          isLevelComplete: true,
        );
        _onStepCompleted(16);
        break;

      case 17:
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
