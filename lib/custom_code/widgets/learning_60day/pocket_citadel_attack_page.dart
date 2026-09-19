import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import '../main_profile_widget.dart';
import 'flame_english_house_game.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_score_level_engine.dart';
import 'pocket_world_street_page.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';

/// ⚔️ Pocket Citadel Attack Page: Full-Screen Battle & Defense Raid
/// Audio Directive:
/// "അറ്റാക്ക് ചെയ്യുന്നത് അതിൽ ടാപ്പ് ചെയ്യുമ്പോൾ തന്നെ ഫുൾ സ്ക്രീൻ ആയിട്ട് പോണം...
/// ആപ്പിന്റെ ഫുൾ സ്ക്രീൻ ആയിട്ട് പോവുക, അടിയിൽ വീടായിട്ട് നിൽക്കുക.
/// അപ്പോ അറ്റാക്ക് ചെയ്യുമ്പോൾ ഉള്ള അറ്റാക്ക് ക്വസ്റ്റ്യൻസ് കറക്റ്റ് ആക്കി കഴിഞ്ഞു കഴിഞ്ഞാൽ അറ്റാക്ക് ഉള്ളതിൽ കാണും.
/// കറക്റ്റ് അതിൽ പോയി ടാപ്പ് ചെയ്യുക എന്നിട്ട് അറ്റാക്ക് ചെയ്യാൻ പറ്റണം.
/// അറ്റാക്ക് ചെയ്തത് ആരാണെന്നുള്ളത് അതിന്റെ മെയിൻ പ്രൊഫൈലിൽ കാണണം. അറ്റാക്കിങ് ഒന്ന് പവർഫുൾ ആക്ക് ട്ടോ."
class PocketCitadelAttackPage extends StatefulWidget {
  final PocketNeighbor neighbor;
  final int attackerDay;
  final int attackerStreak;

  const PocketCitadelAttackPage({
    super.key,
    required this.neighbor,
    this.attackerDay = 1,
    this.attackerStreak = 0,
  });

  /// 🏰 Open Citadel / House Page for any user or robot from anywhere in the app
  static Future<void> openForUser(
    BuildContext context, {
    required String userId,
    PocketNeighbor? neighbor,
    Map<String, dynamic>? preloadedProfile,
    int attackerDay = 1,
  }) async {
    if (neighbor != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: neighbor,
            attackerDay: attackerDay,
          ),
        ),
      );
      return;
    }

    final isRobot = PocketRobotService.isRobotId(userId) ||
        !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);

    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      final dynamicLevel = PocketRobotService.getDynamicLevel(robot);
      final robotNeighbor = PocketNeighbor(
        id: robot.id,
        name: robot.name,
        day: dynamicLevel,
        streak: dynamicLevel,
        rank: robot.cefrRank,
        paletteId: robot.housePalette,
        isMe: false,
        hasActiveShield: true,
        statusMessage: robot.bio,
        isPocketRobo: true,
        hp: 100,
        maxHp: 100,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: robotNeighbor,
            attackerDay: attackerDay,
          ),
        ),
      );
      return;
    }

    Map<String, dynamic>? data = preloadedProfile;
    if (data == null || (data['first_name'] == null && data['name'] == null)) {
      try {
        final res = await SupaFlow.client
            .from('profile')
            .select('user_id, first_name, name, bio, learning_day, streak, rank, palette_id, is_pocket_robo')
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null) data = res;
      } catch (e) {
        debugPrint('PocketCitadelAttackPage.openForUser error: $e');
      }
    }

    final p = data ?? {};
    final userNeighbor = PocketNeighbor(
      id: userId,
      name: p['first_name'] ?? p['name'] ?? 'Citadel Defender',
      day: (p['learning_day'] as num?)?.toInt() ?? 1,
      streak: (p['streak'] as num?)?.toInt() ?? 1,
      rank: p['rank']?.toString() ?? 'Citizen',
      paletteId: p['palette_id']?.toString() ?? 'warm_cottage',
      isMe: false,
      hasActiveShield: true,
      statusMessage: p['bio']?.toString() ?? 'Learning English everyday!',
      isPocketRobo: p['is_pocket_robo'] == true,
      hp: 100,
      maxHp: 100,
    );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketCitadelAttackPage(
          neighbor: userNeighbor,
          attackerDay: attackerDay,
        ),
      ),
    );
  }

  @override
  State<PocketCitadelAttackPage> createState() => _PocketCitadelAttackPageState();
}

class _PocketCitadelAttackPageState extends State<PocketCitadelAttackPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _raidStep = 0; // 0: Overview, 1: Defense Question, 2: Gate Breached (Attack button ready), 3: Victory, -1: Failed
  int _selectedOption = -1;
  bool _isStriking = false;
  bool _isQuestionSheetOpen = false;
  late bool _isDefenderDamaged;
  List<HouseShieldQuestion> _defenseQuestions = [];
  int _currentQIdx = 0;

  // ⏱️ 25s Blitz Combat & Anti-Cheat System
  Timer? _combatTimer;
  int _secondsLeft = 25;
  static const int kMaxCombatSeconds = 25;
  bool _isAntiCheatTriggered = false;
  bool _isTimeoutTriggered = false;

  bool _isTargetProtected = false;
  double _protectionHoursLeft = 0;
  bool _inCooldown = false;
  double _cooldownHoursLeft = 0;
  int _retriesRemaining = 1; // User Audio Directive: Exactly 1 retry chance before 6h cooldown
  bool _isDailyLimitReached = false;
  int _attacksUsed = 0;

  // 🔍 Interactive Estate Zoom & Pan Controls: Spherical World / Rolling Hills
  int _defenderScore = 0;
  late final TransformationController _transformationController;
  final ValueNotifier<double> _zoomScaleNotifier = ValueNotifier<double>(1.0);
  bool _hasInitializedTransform = false;
  bool? _manualNightOverride;

  late AnimationController _shakeController;
  late AnimationController _beamController;
  late AnimationController _particleController;
  late AnimationController _coinController;
  late AnimationController _heroChargeController;
  late AnimationController _ambientController;
  late AnimationController _profileDrawerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isDefenderDamaged = widget.neighbor.isDamaged;

    _transformationController = TransformationController();
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if ((scale - _zoomScaleNotifier.value).abs() > 0.005) {
        _zoomScaleNotifier.value = scale;
      }
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _heroChargeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _profileDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _loadBattleState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _combatTimer?.cancel();
    _transformationController.dispose();
    _zoomScaleNotifier.dispose();
    _shakeController.dispose();
    _beamController.dispose();
    _particleController.dispose();
    _coinController.dispose();
    _heroChargeController.dispose();
    _ambientController.dispose();
    _profileDrawerController.dispose();
    super.dispose();
  }


  void _openDefenderProfile() {
    HapticFeedback.selectionClick();
    if (_profileDrawerController.value > 0.5) {
      _profileDrawerController.reverse();
    } else {
      _profileDrawerController.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Anti-Cheat: If user minimizes the app, switches to AI/Google Lens, or leaves screen during battle
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_raidStep == 1 && mounted) {
        _combatTimer?.cancel();
        PocketFortressDefenseService.recordFailedAttackCooldown(widget.neighbor.id, hours: 6);
        setState(() {
          _isAntiCheatTriggered = true;
          _raidStep = -1; // Raid Failed!
        });
      }
    }
  }

  void _startCombatTimer() {
    _combatTimer?.cancel();
    setState(() {
      _secondsLeft = kMaxCombatSeconds;
      _isTimeoutTriggered = false;
      _isAntiCheatTriggered = false;
    });

    _combatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
        if (_secondsLeft <= 5) {
          HapticFeedback.lightImpact(); // Audible ticking warning
        }
      } else {
        timer.cancel();
        _handleCombatTimeout();
      }
    });
  }

  void _handleCombatTimeout() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    if (_retriesRemaining > 0) {
      setState(() {
        _retriesRemaining--;
        _selectedOption = -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Blitz timer expired! 1 Second Chance remaining. Hurry!'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 3),
        ),
      );
      _startCombatTimer();
    } else {
      PocketFortressDefenseService.recordFailedAttackCooldown(widget.neighbor.id, hours: 6);
      setState(() {
        _secondsLeft = 0;
        _isTimeoutTriggered = true;
        _raidStep = -1; // Time expired -> Defeat!
      });
    }
  }

  Future<void> _loadBattleState() async {
    final targetId = widget.neighbor.id;
    final inCooldown = await PocketFortressDefenseService.isTargetInCooldown(targetId);
    final cooldownMinutes = inCooldown
        ? await PocketFortressDefenseService.getCooldownMinutesRemaining(targetId)
        : 0;
    final isProtected = await PocketFortressDefenseService.isUnderPresidentialProtection(targetId);
    final protectionMinutes = isProtected
        ? await PocketFortressDefenseService.getPresidentialProtectionMinutesRemaining(targetId)
        : 0;
    final attacksUsed = await PocketFortressDefenseService.getDailyAttacksUsedToday();
    final isDailyLimitReached = attacksUsed >= PocketFortressDefenseService.kDailyMaxAttacks;

    final questions = await PocketFortressDefenseService.loadGauntletQuestionsForStage(
      widget.neighbor.day,
      isNeighbor: true,
    );

    // Randomize option order dynamically across A, B, C, D
    final randomizedQuestions = questions.map((q) {
      if (q.options.length <= 1) return q;
      final indexedOptions = q.options.asMap().entries.toList();
      indexedOptions.shuffle();
      final newOptions = indexedOptions.map((e) => e.value).toList();
      final newCorrectIndex = indexedOptions.indexWhere((e) => e.key == q.correctIndex);
      return HouseShieldQuestion(
        id: q.id,
        question: q.question,
        options: newOptions,
        correctIndex: newCorrectIndex >= 0 ? newCorrectIndex : 0,
        explanation: q.explanation,
        category: q.category,
        trapType: q.trapType,
        gameFormat: q.gameFormat,
      );
    }).toList();

    int defenderScore = PocketScoreLevelEngine.getRequiredScoreForLevel(widget.neighbor.day) + (widget.neighbor.streak * 15);
    try {
      if (!widget.neighbor.id.startsWith('pocket_robo') && !widget.neighbor.id.startsWith('rival_citadel')) {
        final res = await SupaFlow.client.from('pocket_homes').select('points, hp, stage').eq('user_id', widget.neighbor.id).maybeSingle();
        if (res != null && res['points'] != null) {
          defenderScore = (res['points'] as num).toInt();
        }
      } else {
        final roboScore = await PocketFortressDefenseService.getRobotScore(widget.neighbor.id, widget.neighbor.day);
        defenderScore = roboScore;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _inCooldown = inCooldown;
        _cooldownHoursLeft = cooldownMinutes / 60.0;
        _isTargetProtected = isProtected;
        _protectionHoursLeft = protectionMinutes / 60.0;
        if (isProtected) {
          _isDefenderDamaged = true;
        }
        _attacksUsed = attacksUsed;
        _isDailyLimitReached = isDailyLimitReached;
        _defenseQuestions = randomizedQuestions;
        _defenderScore = defenderScore;
      });
    }
  }

  Future<void> _executeCitadelAttack() async {
    if (_isStriking) return;
    setState(() => _isStriking = true);

    final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay);

    // Phase 1: Hero rushes forward with charging battle sprint up to citadel steps (y=1100 -> 730)
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
    _heroChargeController.forward(from: 0.0);

    // Wait for hero sprint to reach mansion front steps (~600ms)
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 2: Hero leaps & unleashes avatar-specific weapon strike
    HapticFeedback.heavyImpact();
    _beamController.forward(from: 0.0);

    // Strike travels and hits citadel mansion gates (~350ms)
    await Future.delayed(const Duration(milliseconds: 350));

    // Phase 3: Blast impact, screen shake & explosion debris
    _shakeController.forward(from: 0.0);
    _particleController.forward(from: 0.0);

    for (int i = 0; i < 4; i++) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 70));
    }
    HapticFeedback.vibrate();

    final result = await PocketFortressDefenseService.processRaidBreach(
      defenderHouseId: widget.neighbor.id,
      attackerId: 'me',
      damageHp: 60,
      attackerName: 'You (Level ${widget.attackerDay})',
      attackerWeapon: perk.combatWeaponName,
      defenderHasIronDome: widget.neighbor.hasActiveShield,
    );

    await PocketFortressDefenseService.recordTargetAttacked(widget.neighbor.id);
    await PocketFortressDefenseService.recordAttackLaunchedToday();
    // 🛡️ User Audio Directive: 24-Hour Presidential Protection activated after raid
    await PocketFortressDefenseService.placeUnderPresidentialProtection(widget.neighbor.id, hours: 24);
    await PocketPresidentService.notifyPresidentialProtection(widget.neighbor.id, hours: 24);

    // ⚔️ Audio Directive: Raider earns 10 to 15 Pocket Score (PS) points globally
    final looted = (result['lootedCoins'] as num? ?? 15).toInt();
    if (looted > 0) {
      await PocketFortressDefenseService.awardRaidLoot(looted);
    }
    await PocketFortressDefenseService.awardPoints(looted > 0 ? looted : 15);

    // Phase 4: Fountain of looted coins exploding from citadel into player's grasp
    _coinController.forward(from: 0.0);
    setState(() {
      _defenderScore = math.max(0, _defenderScore - (looted > 0 ? looted : 15));
      _isDefenderDamaged = true;
      _isTargetProtected = true;
      _protectionHoursLeft = 24.0;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      setState(() {
        _isStriking = false;
        _raidStep = 3; // Victory!
      });
      _showVictoryDialog();
    }
  }

  void _showReportDialog(HouseShieldQuestion currentQ) {
    String selectedReason = 'fake_english';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent),
          ),
          title: Row(
            children: const [
              Text('🚨', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Report Fake Defense',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The President\'s Court and Admin investigate fraudulent defense shields. False questions result in Citadel Penalties.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Violation Type',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'fake_english', child: Text('Fake / Gibberish English')),
                    DropdownMenuItem(value: 'impossible_puzzle', child: Text('Unfair / Impossible Puzzle')),
                    DropdownMenuItem(value: 'abusive_language', child: Text('Inappropriate Language')),
                    DropdownMenuItem(value: 'unrelated_content', child: Text('Not English Learning')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedReason = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(ctx);
                _showPresidentialDispatchOverlay(
                  currentQ: currentQ,
                  reason: selectedReason,
                );
              },
              child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPresidentialDispatchOverlay({
    required HouseShieldQuestion currentQ,
    required String reason,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PresidentialDispatchDialog(
        targetName: widget.neighbor.name,
        targetId: widget.neighbor.id,
        currentQ: currentQ,
        reason: reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⏱️ 6-Hour Atmospheric Day/Night Cycle
    // 06:00 - 12:00: Morning Sun (Day)
    // 12:00 - 18:00: Golden Afternoon (Day)
    // 18:00 - 24:00: Twilight & Starlit Evening (Night)
    // 00:00 - 06:00: Deep Space Midnight (Night)
    final currentHour = DateTime.now().hour;
    final isNightByDefault = currentHour >= 18 || currentHour < 6;
    final isNight = _manualNightOverride ?? isNightByDefault;
    final hoursLeftIn6hBlock = 6 - (currentHour % 6);
    final cycleLabel = isNight ? '🌙 Night (${hoursLeftIn6hBlock}h left)' : '☀️ Day (${hoursLeftIn6hBlock}h left)';
    final isDay90 = widget.neighbor.day >= 90;

    // 🌍 Virtual World Dimensions (1800 x 1600): A vast, living open landscape
    const double worldW = 1800.0;
    const double worldH = 1600.0;
    const double groundY = 920.0;
    const double houseW = 420.0;
    const double houseH = 380.0;
    const double houseLeft = (worldW - houseW) / 2; // 690.0
    const double houseTop = groundY - 14.0 - houseH; // 526.0

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_profileDrawerController.value > 0.1) {
          _profileDrawerController.reverse();
          return;
        }
        if (_isQuestionSheetOpen) {
          setState(() => _isQuestionSheetOpen = false);
          return;
        }
        Navigator.of(context).pop(_raidStep == 3);
      },
      child: Scaffold(
        backgroundColor: isNight ? const Color(0xFF030712) : const Color(0xFF0284C7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final bottomPad = MediaQuery.of(context).padding.bottom;
            final collapsedH = 76.0 + bottomPad;
            final drawerMaxH = h * 0.92;
            final drawerCurrentH = ui.lerpDouble(collapsedH, drawerMaxH, _profileDrawerController.value)!;

            // 🛡️ Mathematically guaranteed to cover 100% of the screen (Zero blue borders / letterbox):
            final minScale = math.max(w / worldW, h / worldH);
            const maxScale = 2.5;

            // 🏠 Default View: Camera smoothly focuses on the House and its front courtyard
            if (!_hasInitializedTransform && w > 0 && h > 0) {
              _hasInitializedTransform = true;
              final defaultScale = math.min(maxScale, math.max(minScale, w / (houseW * 1.05)));
              final houseCenterX = worldW / 2;
              final houseCenterY = houseTop + (houseH * 0.52);
              final tx = ((w / 2) - (houseCenterX * defaultScale)).clamp(-(worldW * defaultScale - w), 0.0);
              final ty = ((h * 0.40) - (houseCenterY * defaultScale)).clamp(-(worldH * defaultScale - h), 0.0);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final initialMatrix = Matrix4.identity();
                  initialMatrix.setEntry(0, 0, defaultScale);
                  initialMatrix.setEntry(1, 1, defaultScale);
                  initialMatrix.setEntry(0, 3, tx);
                  initialMatrix.setEntry(1, 3, ty);
                  _transformationController.value = initialMatrix;
                }
              });
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 🔍 Interactive Estate Canvas with Smooth Pinch-to-Zoom & Pan
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: minScale,
                    maxScale: maxScale,
                    boundaryMargin: EdgeInsets.zero,
                    constrained: false,
                    clipBehavior: Clip.none,
                    child: SizedBox(
                      width: worldW,
                      height: worldH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Full-Screen 2D Open World Living Scenery (Animated with _ambientController)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _ambientController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: CitadelScenicLandscapePainter(
                                    isDamaged: _isDefenderDamaged,
                                    groundBaseY: groundY,
                                    isNight: isNight,
                                    isDay90: isDay90,
                                    ambientProg: _ambientController.value,
                                  ),
                                );
                              },
                            ),
                          ),

                          // 2. The 2D Flame English House seated firmly on the courtyard lawn
                          Positioned(
                            left: houseLeft,
                            top: houseTop,
                            width: houseW,
                            height: houseH,
                            child: FlameEnglishHouseWidget(
                              currentDay: widget.neighbor.day,
                              streak: widget.neighbor.streak,
                              isDamaged: _isDefenderDamaged,
                              houseId: widget.neighbor.id,
                              paletteId: widget.neighbor.paletteId,
                              showTestingControls: false,
                            ),
                          ),

                          // Chimney Smoke Puffs floating above the roof
                          Positioned(
                            top: houseTop - 28,
                            left: 900.0 - 88,
                            child: _buildChimneySmoke(),
                          ),
                          Positioned(
                            top: houseTop - 28,
                            left: 900.0 + 88 - 18,
                            child: _buildChimneySmoke(),
                          ),

                          // 3. Post-Attack Battle Damage (Billowing dark smoke columns & fiery embers)
                          if (_isDefenderDamaged || _isTargetProtected)
                            _buildPostAttackDamageEffects(houseLeft, houseTop, houseW, houseH),

                          // 3B. Presidential Police & Military Guard Cordon with Barricade & Notice Board
                          if (_isDefenderDamaged || _isTargetProtected)
                            _buildPresidentialSecurityLayer(houseLeft, houseTop, houseW, houseH, groundY),

                          // 4. Avatar-Specific Weapon Discharge & Particle Strike Layer
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_beamController, _particleController]),
                              builder: (context, _) {
                                if (_beamController.value <= 0 && _particleController.value <= 0) {
                                  return const SizedBox.shrink();
                                }
                                return IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelAvatarStrikePainter(
                                      beamProg: _beamController.value,
                                      particleProg: _particleController.value,
                                      attackerDay: widget.attackerDay,
                                      perk: VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 5. Victory Coin Shower & Magnetic Loot Attraction Layer
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _coinController,
                              builder: (context, _) {
                                if (_coinController.value <= 0.0 || _coinController.value >= 1.0) {
                                  return const SizedBox.shrink();
                                }
                                return IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelCoinShowerPainter(
                                      progress: _coinController.value,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 6. 🥋 Attacking Hero Avatar Sprint & Leap Sprite during battle
                          if (_isStriking)
                            AnimatedBuilder(
                              animation: Listenable.merge([_heroChargeController, _coinController]),
                              builder: (context, _) {
                                final prog = _heroChargeController.value;
                                // Running up the stone path towards the citadel steps (y: 1100 -> 730)
                                final runY = ui.lerpDouble(1100.0, 730.0, (prog / 0.55).clamp(0.0, 1.0))!;
                                // Parabolic leap during weapon strike
                                final leapY = (prog > 0.50 && prog < 0.88)
                                    ? -math.sin((prog - 0.50) / 0.38 * math.pi) * 48.0
                                    : 0.0;
                                final heroY = runY + leapY;
                                const heroX = 900.0;

                                final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay);
                                final isRunning = prog < 0.50;
                                final isStrikingAtGate = prog >= 0.50 && prog < 0.88;
                                final isCollectingLoot = _coinController.value > 0.15;

                                return Positioned(
                                  left: heroX - 42,
                                  top: heroY - 42,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Floating weapon badge with glowing aura
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isStrikingAtGate ? Colors.redAccent : const Color(0xFFFFD700),
                                            width: 1.3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isStrikingAtGate ? Colors.redAccent : Colors.amber).withValues(alpha: 0.75),
                                              blurRadius: 14,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(perk.combatWeaponIcon, style: const TextStyle(fontSize: 14)),
                                            const SizedBox(width: 4),
                                            Text(
                                              perk.combatWeaponName,
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFFFD700),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Attacking Avatar with Radiant Pulsing Aura & Running tilt
                                      Transform.rotate(
                                        angle: isRunning ? math.sin(prog * 36) * 0.12 : (isStrikingAtGate ? -0.18 : 0.0),
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isStrikingAtGate
                                                        ? const Color(0xFFEF4444)
                                                        : (isCollectingLoot ? const Color(0xFFFFD700) : const Color(0xFF38BDF8)))
                                                    .withValues(alpha: 0.75),
                                                blurRadius: 18,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: VectorAvatarWidget(
                                              config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.attackerDay),
                                              size: 64,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Running dust puff animation under feet
                                      if (isRunning) ...[
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(width: 8, height: 4, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2))),
                                            const SizedBox(width: 5),
                                            Container(width: 14, height: 5, decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(3))),
                                            const SizedBox(width: 5),
                                            Container(width: 8, height: 4, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2))),
                                          ],
                                        ),
                                      ],
                                      // Open Treasure Chest when collecting coins
                                      if (isCollectingLoot) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFFFD700), width: 1.4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                                                blurRadius: 12,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🪙', style: TextStyle(fontSize: 14)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+15 PS LOOTED!',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(0xFFFFD700),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 7. Attack strike visual impact overlay
                if (_isStriking) _buildStrikeOverlay(),

                // 8. Floating Top Capsule Header (Back button + 6h Day/Night Cycle + Profile + Info)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopHeaderCapsule(isNight: isNight, cycleLabel: cycleLabel),
                ),

                // 9. Dimmed backdrop behind Profile Drawer
                if (!_isQuestionSheetOpen && _profileDrawerController.value > 0.02)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _profileDrawerController.reverse(),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.65 * _profileDrawerController.value),
                      ),
                    ),
                  ),

                // 10. Bottom Stacked Small Red "Attack" Button with Level & PS Pill (sitting right above peek bar)
                if (!_isQuestionSheetOpen)
                  Positioned(
                    bottom: collapsedH + 10.0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: (1.0 - _profileDrawerController.value * 2.5).clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: _profileDrawerController.value > 0.1,
                        child: _buildBottomAttackSection(),
                      ),
                    ),
                  ),

                // 11. Draggable & Tappable Profile Bottom Sheet Drawer
                if (!_isQuestionSheetOpen)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: drawerCurrentH,
                    child: _buildProfileDrawer(drawerMaxH, collapsedH, bottomPad),
                  ),

                // 12. Stacked Expanded Question / Challenge Sheet (when opened)
                if (_isQuestionSheetOpen)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildQuestionSheet(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }



  /// 💣 Battle Aftermath: Billowing dark combat smoke columns & fiery embers rising from damaged citadel
  Widget _buildPostAttackDamageEffects(double houseLeft, double houseTop, double houseW, double houseH) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final prog = _ambientController.value;
        return Positioned(
          left: houseLeft - 40,
          top: houseTop - 90,
          width: houseW + 80,
          height: houseH + 90,
          child: IgnorePointer(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Smoke plume 1: Left roof breach
                Positioned(
                  left: 70,
                  top: 30,
                  child: _buildBillowingSmokeColumn(prog, phase: 0.0, width: 62),
                ),
                // Smoke plume 2: Center gate blast point
                Positioned(
                  left: (houseW + 80) / 2 - 25,
                  top: 110,
                  child: _buildBillowingSmokeColumn(prog, phase: 0.35, width: 78),
                ),
                // Smoke plume 3: Right tower / roof breach
                Positioned(
                  right: 70,
                  top: 40,
                  child: _buildBillowingSmokeColumn(prog, phase: 0.70, width: 58),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillowingSmokeColumn(double prog, {double phase = 0.0, double width = 60}) {
    final t = (prog + phase) % 1.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final puffProg = (t + (index * 0.25)) % 1.0;
        final size = 16.0 + (puffProg * width * 0.55);
        final opacity = (1.0 - puffProg) * 0.65;
        final driftX = math.sin((puffProg + phase) * 2 * math.pi) * 14.0;
        return Transform.translate(
          offset: Offset(driftX, -puffProg * 45.0),
          child: Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B).withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: opacity * 0.5),
                  blurRadius: 10,
                ),
                if (index == 3)
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: opacity * 0.5),
                    blurRadius: 14,
                  ),
              ],
            ),
            child: (index == 3)
                ? Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFB74D).withValues(alpha: opacity),
                      ),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }

  /// 🛡️ Presidential Protection Layer: Police Officers, Army Guards, Emergency Strobes, Hazard Barricade & Warning Sign
  Widget _buildPresidentialSecurityLayer(double houseLeft, double houseTop, double houseW, double houseH, double groundY) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final prog = _ambientController.value;
        final isRedFlash = math.sin(prog * 10 * math.pi) > 0;

        return Positioned(
          left: 900.0 - 240.0,
          top: houseTop + houseH - 95.0,
          width: 480.0,
          height: 190.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Flashing Red and Blue Police Emergency Beacon Halos on Ground
              Positioned(
                left: 35,
                top: 30,
                child: Container(
                  width: 90,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isRedFlash ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withValues(alpha: 0.30),
                    boxShadow: [
                      BoxShadow(
                        color: (isRedFlash ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 35,
                top: 30,
                child: Container(
                  width: 90,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isRedFlash ? const Color(0xFF3B82F6) : const Color(0xFFEF4444)).withValues(alpha: 0.30),
                    boxShadow: [
                      BoxShadow(
                        color: (isRedFlash ? const Color(0xFF3B82F6) : const Color(0xFFEF4444)).withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Police Officers Standing Guard
              Positioned(
                left: 36,
                top: 12,
                child: _buildPoliceOfficerSprite(isLeft: true),
              ),
              Positioned(
                right: 36,
                top: 12,
                child: _buildPoliceOfficerSprite(isLeft: false),
              ),

              // 3. Presidential Military Defense Soldiers
              Positioned(
                left: 114,
                top: 24,
                child: _buildMilitarySoldierSprite(hasShield: true),
              ),
              Positioned(
                right: 114,
                top: 24,
                child: _buildMilitarySoldierSprite(hasShield: false),
              ),

              // 4. Yellow & Black Hazard Barricade with Official Presidential Protection Notice Board
              Positioned(
                left: 80,
                right: 80,
                bottom: 6,
                child: GestureDetector(
                  onTap: _showPresidentialProtectionInfoDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: (isRedFlash ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Striped Hazard Caution Bar
                        Container(
                          height: 7,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFACC15),
                                Colors.black,
                                Color(0xFFFACC15),
                                Colors.black,
                                Color(0xFFFACC15),
                                Colors.black,
                                Color(0xFFFACC15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏛️', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'PRESIDENTIAL PROTECTION',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'RESTRICTED SECURITY ZONE • ⏱️ ${_protectionHoursLeft.toStringAsFixed(1)}h COOLDOWN',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Guarded by Police & Army • Tap for Details',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 9,
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
      },
    );
  }

  /// 👮‍♂️ Detailed Police Officer Sprite
  Widget _buildPoliceOfficerSprite({required bool isLeft}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Peaked Police Cap with Gold Badge
        Container(
          width: 22,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
          ),
          child: Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Head / Face
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDFBA),
            shape: BoxShape.circle,
          ),
        ),
        // Torso with High-Vis Safety Vest & Radio
        Container(
          width: 26,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // High-vis yellow safety vest
              Center(
                child: Container(
                  width: 16,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Center(
                    child: Text(
                      'POLICE',
                      style: TextStyle(
                        fontSize: 4.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Shoulder Radio / Badge
              Positioned(
                right: isLeft ? 1 : null,
                left: isLeft ? null : 1,
                top: 2,
                child: Container(
                  width: 4,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Dark Pants
        Container(
          width: 18,
          height: 20,
          color: const Color(0xFF0F172A),
        ),
        // Polished Black Boots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 6, color: Colors.black),
            const SizedBox(width: 2),
            Container(width: 8, height: 6, color: Colors.black),
          ],
        ),
      ],
    );
  }

  /// 🪖 Detailed Presidential Defense Soldier Sprite
  Widget _buildMilitarySoldierSprite({required bool hasShield}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasShield)
          Container(
            width: 18,
            height: 48,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🛡️', style: TextStyle(fontSize: 10)),
                Text(
                  'GUARD',
                  style: TextStyle(
                    fontSize: 4,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Black Tactical Beret with Gold Badge
            Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF022C22),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Head
            Container(
              width: 14,
              height: 13,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDFBA),
                shape: BoxShape.circle,
              ),
            ),
            // Tactical Camo Armor Torso
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.shield, size: 12, color: Colors.white70),
              ),
            ),
            // Camo Combat Trousers
            Container(
              width: 18,
              height: 20,
              color: const Color(0xFF022C22),
            ),
            // Combat Boots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 6, color: const Color(0xFF1E293B)),
                const SizedBox(width: 2),
                Container(width: 8, height: 6, color: const Color(0xFF1E293B)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showPresidentialProtectionInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🏛️', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'PRESIDENTIAL PROTECTION',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'PERIMETER SECURED BY FEDERAL POLICE & DEFENSE GUARDS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Following a recent combat raid, this citadel has been placed under Federal & Presidential Protection to secure the resident and allow structural rebuilding.',
              style: GoogleFonts.outfit(color: const Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Active Protection: ${_protectionHoursLeft.toStringAsFixed(1)} hours remaining',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Raids are strictly prohibited during the 24-hour protection period. Armed guards remain on duty until the decree concludes.',
              style: TextStyle(color: Colors.white60, fontSize: 11.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Acknowledge Decree 📜'),
          ),
        ],
      ),
    );
  }

  /// ☁️ Soft translucent smoke puffs floating from chimneys
  Widget _buildChimneySmoke() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  /// 🌟 Top Floating Header: Back button, 6h Day/Night Cycle indicator & Toggle, Profile Icon + (i) info button
  Widget _buildTopHeaderCapsule({bool isNight = false, String cycleLabel = ''}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            InkWell(
              onTap: () => Navigator.pop(context, _raidStep == 3),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),

            // Right group: 6-Hour Cycle Badge + Day/Night Toggle + Defender Profile + info
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ⏱️ 6-Hour Cycle Badge & Toggle
                InkWell(
                  onTap: () {
                    setState(() {
                      _manualNightOverride = !isNight;
                    });
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isNight
                            ? const Color(0xFFFDE047).withValues(alpha: 0.7)
                            : const Color(0xFF38BDF8).withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isNight ? const Color(0xFFFDE047) : const Color(0xFF38BDF8)).withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          color: isNight ? const Color(0xFFFDE047) : const Color(0xFF38BDF8),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cycleLabel.isNotEmpty ? cycleLabel : (isNight ? 'Night' : 'Day'),
                          style: GoogleFonts.outfit(
                            color: isNight ? const Color(0xFFFDE047) : const Color(0xFFBAE6FD),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Defender Profile Button
                InkWell(
                  onTap: _openDefenderProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF8B5CF6), width: 1.2),
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFFA78BFA), size: 18),
                  ),
                ),
                const SizedBox(width: 8),

                // Minimal (i) info button
                InkWell(
                  onTap: _showCitadelStatsSheet,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Color(0xFFFFD700), size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 💥 Attack Strike Visual Impact Overlay
  Widget _buildStrikeOverlay() {
    final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay);
    return Positioned(
      top: 88,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(perk.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${perk.combatWeaponName.toUpperCase()} STRIKE! 💥',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '+15 PS LOOTED! • CITADEL BREACHED',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD700),
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

  /// ⚔️ Minimal Unified Rectangular Attack Pod: Level + PS header row directly joined with red Attack button
  Widget _buildBottomAttackSection() {
    final psValue = _defenderScore > 0
        ? _defenderScore
        : PocketScoreLevelEngine.getRequiredScoreForLevel(widget.neighbor.day);

    if (_isTargetProtected) {
      return Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showPresidentialProtectionInfoDialog();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.85),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Level ${widget.neighbor.day}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '$psValue PS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0369A1), Color(0xFF0C4A6E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏛️', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        'PRESIDENTIAL PROTECTION (${_protectionHoursLeft.toStringAsFixed(1)}h)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFBAE6FD),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
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

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.25),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level & PS Minimal Row (User Directive: No "You Level 7" or "VS", just Level & PS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Level ${widget.neighbor.day}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '$psValue PS',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Minimal Red Attack Button (Solid & Stable: scale animation removed per user request)
            GestureDetector(
              onTap: _onTapBottomAttack,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚔️', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      'ATTACK',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13.5,
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
    );
  }

  /// 📇 Draggable & Tappable Bottom Sheet Drawer for Citadel Defender Profile
  Widget _buildProfileDrawer(double maxHeight, double collapsedH, double bottomPad) {
    final prog = _profileDrawerController.value;
    final isExpanded = prog > 0.5;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.45 + (prog * 0.35)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          if (prog > 0.15)
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.22 * prog),
              blurRadius: 24,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          children: [
            // Grab Header Bar (handles dragging and tapping)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                final delta = details.primaryDelta ?? 0;
                final range = maxHeight - collapsedH;
                if (range > 0) {
                  _profileDrawerController.value -= delta / range;
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -250) {
                  _profileDrawerController.forward();
                } else if (velocity > 250) {
                  _profileDrawerController.reverse();
                } else if (_profileDrawerController.value > 0.35) {
                  _profileDrawerController.forward();
                } else {
                  _profileDrawerController.reverse();
                }
              },
              onTap: () {
                if (_profileDrawerController.value > 0.5) {
                  _profileDrawerController.reverse();
                } else {
                  _profileDrawerController.forward();
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 6, 16, prog < 0.1 ? (8 + bottomPad) : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: prog * 0.12),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pull Handle Pill (User Directive: Slightly larger and easier to grab)
                    Container(
                      width: 44,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Row(
                      children: [
                        // Defender Avatar Bubble
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFA78BFA), width: 1.4),
                            color: const Color(0xFF0F172A),
                          ),
                          child: ClipOval(
                            child: VectorAvatarWidget(
                              config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                              size: 32,
                            ),
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
                                      '${widget.neighbor.name}\'s Profile',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFFA78BFA).withValues(alpha: 0.5),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      'Lvl ${widget.neighbor.day}',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFDDD6FE),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                prog > 0.5 ? 'Citadel Defender Profile' : 'Swipe up or tap to explore profile',
                                style: GoogleFonts.outfit(
                                  color: prog > 0.5 ? const Color(0xFFA78BFA) : Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expand / Collapse Capsule Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFA78BFA).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Text(
                                    'Profile',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFDDD6FE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                                color: const Color(0xFFA78BFA),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Profile View Body (Mounted only when drawer opens)
            if (prog > 0.05)
              Expanded(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: MainProfileWidget(
                    userId: widget.neighbor.id,
                    preloadedProfile: {
                      'user_id': widget.neighbor.id,
                      'first_name': widget.neighbor.name,
                      'bio': widget.neighbor.statusMessage,
                      'learning_day': widget.neighbor.day,
                      'streak': widget.neighbor.streak,
                      'rank': widget.neighbor.rank,
                      'palette_id': widget.neighbor.paletteId,
                      'is_pocket_robo': widget.neighbor.isPocketRobo,
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNoticeDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCitadelStatsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
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
                const Text('🏰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.neighbor.name}\'s Citadel Info',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Citadel Level', 'Level ${widget.neighbor.day}'),
            _buildStatRow('Pocket Score', 'PS $_defenderScore'),
            _buildStatRow('Study Streak', '🔥 ${widget.neighbor.streak} Days'),
            _buildStatRow(
              'Shield Status',
              widget.neighbor.hasActiveShield ? '🛡️ Active Iron Dome' : '🔓 Unshielded',
            ),
            _buildStatRow('Daily Attacks', '$_attacksUsed / 2 used'),
            if (_isTargetProtected)
              _buildStatRow(
                'Presidential Guard',
                '👮‍♂️ ${_protectionHoursLeft.toStringAsFixed(1)}h remaining',
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'CITADEL BREACHED!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You successfully attacked ${widget.neighbor.name}\'s citadel!',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+15 POCKET SCORE LOOTED!',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Defender Citadel Breached & Plundered!',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Text('👮‍♂️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '26h Presidential Protection Activated for target to recover.',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: Text(
                'CLAIM REWARDS & RETURN 🏆',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _onTapBottomAttack() {
    HapticFeedback.heavyImpact();
    if (_isTargetProtected) {
      _showPresidentialProtectionInfoDialog();
      return;
    }
    if (_inCooldown) {
      _showNoticeDialog(
        '⏳ Citadel Security Alert Active!',
        'This citadel is on high alert after recent combat. Re-attack available in ${_cooldownHoursLeft.toStringAsFixed(1)} hours.',
      );
      return;
    }
    if (_isDailyLimitReached) {
      _showNoticeDialog(
        '🔒 Daily Limit Reached!',
        'You have used 2/2 attacks today. Return tomorrow!',
      );
      return;
    }

    // Open the challenge questions container
    setState(() {
      _isQuestionSheetOpen = true;
      if (_raidStep == 0) {
        _raidStep = 1;
        _selectedOption = -1;
        _startCombatTimer();
      }
    });
  }

  /// 📦 Stacked Expanded Question / Challenge Sheet (User Directive: "സ്റ്റാക്ക് ചെയ്തിട്ട് വലിയൊരു കണ്ടെയ്നർ ഇട്ടിട്ട് എക്സ്പാൻഡഡ് ആയിട്ട് അതിൽ ക്വസ്റ്റ്യൻസ് വന്നു...")
  Widget _buildQuestionSheet() {
    final currentQ = _defenseQuestions.isNotEmpty
        ? _defenseQuestions[_currentQIdx % _defenseQuestions.length]
        : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.74,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(
          color: _raidStep == 2
              ? const Color(0xFFFFD700)
              : (_raidStep == -1 ? Colors.redAccent : const Color(0xFF38BDF8).withValues(alpha: 0.6)),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title bar with close button & timer
              Row(
                children: [
                  Text(
                    'Gate Defense Challenge',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_raidStep == 1) ...[
                    // ⏱️ 25s Blitz Countdown Combat Timer Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _secondsLeft <= 5
                            ? Colors.red.withValues(alpha: 0.3)
                            : const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _secondsLeft <= 5 ? Colors.redAccent : const Color(0xFFFFD700),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 13,
                            color: _secondsLeft <= 5 ? Colors.redAccent : const Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_secondsLeft}s',
                            style: GoogleFonts.outfit(
                              color: _secondsLeft <= 5 ? Colors.redAccent : const Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Close button to dismiss container and return to open world
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () => setState(() => _isQuestionSheetOpen = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step 1: Answering Questions
              if (_raidStep == 1 && currentQ != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🛡️ GATE ${_currentQIdx + 1} OF ${_defenseQuestions.length}: ${currentQ.trapType.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 18),
                      tooltip: 'Report Fake Shield',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showReportDialog(currentQ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _retriesRemaining > 0
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _retriesRemaining > 0 ? const Color(0xFF34D399) : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            size: 12,
                            color: _retriesRemaining > 0 ? const Color(0xFF34D399) : Colors.redAccent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _retriesRemaining > 0 ? '1 Retry' : '0 Retries',
                            style: GoogleFonts.outfit(
                              color: _retriesRemaining > 0 ? const Color(0xFF34D399) : Colors.redAccent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currentQ.question,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(currentQ.options.length, (optIdx) {
                  final letter = String.fromCharCode(65 + optIdx);
                  final isSelected = _selectedOption == optIdx;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedOption = optIdx);
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFF38BDF8) : Colors.white10,
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: GoogleFonts.outfit(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentQ.options[optIdx],
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption == -1 ? Colors.white12 : const Color(0xFF0284C7),
                      foregroundColor: _selectedOption == -1 ? Colors.white38 : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _selectedOption == -1
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            _combatTimer?.cancel();
                            if (_selectedOption == currentQ.correctIndex) {
                              if (_currentQIdx + 1 < _defenseQuestions.length) {
                                final nextGate = _currentQIdx + 2;
                                final totalGates = _defenseQuestions.length;
                                setState(() {
                                  _currentQIdx++;
                                  _selectedOption = -1;
                                });
                                HapticFeedback.heavyImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🛡️ Gate $_currentQIdx Cleared! Engaging Gate $nextGate of $totalGates...'),
                                    backgroundColor: const Color(0xFF10B981),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                _startCombatTimer();
                              } else {
                                setState(() => _raidStep = 2);
                              }
                            } else {
                              if (_retriesRemaining > 0) {
                                setState(() {
                                  _retriesRemaining--;
                                  _selectedOption = -1;
                                });
                                HapticFeedback.heavyImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ Incorrect! You have 1 Second Chance remaining. Think carefully!'),
                                    backgroundColor: Colors.amber,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                _startCombatTimer();
                              } else {
                                await PocketFortressDefenseService.recordFailedAttackCooldown(
                                  widget.neighbor.id,
                                  hours: 6,
                                );
                                if (mounted) {
                                  setState(() => _raidStep = -1);
                                }
                              }
                            }
                          },
                    child: Text(
                      _currentQIdx + 1 < _defenseQuestions.length
                          ? 'VERIFY GATE CODE 🛡️'
                          : 'BREACH DEFENSE PERIMETER ⚡',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ]

              // Step 2: All Gates Breached -> Attack button ready
              else if (_raidStep == 2) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔓', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEFENSE SHIELDS OFFLINE!',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF34D399),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'All security gate codes solved. Strike now to breach the citadel and claim the loot!',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => _isQuestionSheetOpen = false);
                      _executeCitadelAttack();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 20, color: Color(0xFFFFD700)),
                        const SizedBox(width: 8),
                        Text(
                          'ATTACK',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]

              // Step -1: Trap Triggered / Failed
              else if (_raidStep == -1) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDC2626)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💥', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isAntiCheatTriggered
                                  ? '🚨 ANTI-CHEAT TRIGGERED! RAID FAILED!'
                                  : (_isTimeoutTriggered
                                      ? '⌛ TIME EXPIRED! RAID DEFEATED!'
                                      : 'TRAP TRIGGERED! ATTACK REPELLED!'),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF87171),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isAntiCheatTriggered
                            ? 'You switched apps or minimized during combat! Cheating is strictly prohibited during Citadel Raids.'
                            : (_isTimeoutTriggered
                                ? 'The 25-second rapid combat blitz timer ran out! The defender\'s automated shock traps were triggered.'
                                : 'You failed to crack the defender\'s English shield. Their house defense holds firm!'),
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                      if (currentQ != null && currentQ.explanation.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Grammar Rule: ${currentQ.explanation}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: const [
                      Text('⏳', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '6-Hour Citadel Lockdown Enforced!\nYou exhausted your second chance. Return after 6 hours to attack again.',
                          style: TextStyle(
                            color: Color(0xFFFCD34D),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isQuestionSheetOpen = false);
                      Navigator.pop(context, false);
                    },
                    child: const Text('ACKNOWLEDGE & RETREAT 🛡️', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ⚡ Avatar-Specific Elemental Combat Strike Painter
/// Renders unique weapon effects based on Attacker Perk & Weapon:
/// - Cannon / Mortar (SiegeDamage): Blazing artillery shells & fiery blast
/// - Plasma Blaster / Crossbow (VaultLoot): Dual rapid laser bolts & electric plasma
/// - Mystic Wand / Sonic Disruptor (FdcBoost): Runic magic spiral & cosmic lightning
/// - Chrono Katana / Blades (TimeFreeze): Supersonic X-blade slash & diamond glints
/// - Paladin Broadsword (ArmyKnights): Holy golden celestial light pillar from heaven
/// - Aegis Ram / Titanium Shield (IronDome/FortressShield): Ramming sonic shockwaves
class CitadelAvatarStrikePainter extends CustomPainter {
  final double beamProg;
  final double particleProg;
  final int attackerDay;
  final AvatarGamePerk perk;

  CitadelAvatarStrikePainter({
    required this.beamProg,
    required this.particleProg,
    required this.attackerDay,
    required this.perk,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (beamProg <= 0 && particleProg <= 0) return;

    final target = Offset(size.width * 0.5, 680.0); // Mansion entrance doors
    final source = Offset(size.width * 0.5, 740.0); // Hero leap position at steps

    // ⚡ 1. Active Strike Trajectory / Projectile (beamProg > 0)
    if (beamProg > 0 && beamProg <= 1.0) {
      final fade = (1.0 - beamProg).clamp(0.0, 1.0);

      switch (perk.perkType) {
        // 💥 Cannon / Mortar: Heavy explosive shells launched in arc
        case PerkType.siegeDamage:
          // Heavy Cannon Muzzle Flash
          canvas.drawCircle(
            source,
            18.0 * fade,
            Paint()
              ..color = const Color(0xFFF59E0B).withValues(alpha: fade)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          );
          // Blazing projectile shell flying
          final projY = ui.lerpDouble(source.dy, target.dy, beamProg)!;
          final projX = source.dx + math.sin(beamProg * math.pi) * 24.0;
          final projPos = Offset(projX, projY);
          // Smoke and flame trail behind shell
          canvas.drawLine(
            source,
            projPos,
            Paint()
              ..color = const Color(0xFFEF4444).withValues(alpha: fade * 0.7)
              ..strokeWidth = 6.0 * fade
              ..strokeCap = StrokeCap.round,
          );
          // Glowing Artillery Shell
          canvas.drawCircle(
            projPos,
            9.0,
            Paint()
              ..color = const Color(0xFFFFB703)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
          canvas.drawCircle(projPos, 5.5, Paint()..color = Colors.white);
          break;

        // 🔫 Plasma Blaster / Crossbow: Twin high-energy laser blaster bolts
        case PerkType.vaultLoot:
          // Left & right twin laser beams
          for (final ox in [-12.0, 12.0]) {
            final s = Offset(source.dx + ox, source.dy);
            final t = Offset(target.dx + (ox * 0.6), target.dy);
            // Neon cyan outer plasma glow
            canvas.drawLine(
              s,
              t,
              Paint()
                ..color = const Color(0xFF00F0FF).withValues(alpha: fade * 0.7)
                ..strokeWidth = 10.0 * fade
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
            );
            // Core laser beam
            canvas.drawLine(
              s,
              t,
              Paint()
                ..color = Colors.white.withValues(alpha: fade)
                ..strokeWidth = 3.5 * fade
                ..strokeCap = StrokeCap.round,
            );
          }
          break;

        // ⚡ Mystic Wand / Sonic Disruptor: Spiral arcane cosmic runes & lightning
        case PerkType.fdcBoost:
          final auraPaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFFFACC15), Color(0xFF38BDF8)],
            ).createShader(Rect.fromPoints(target, source))
            ..strokeWidth = 14.0 * fade
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
          canvas.drawLine(source, target, auraPaint);
          // Double helix twisting magic arcs
          for (int h = 0; h < 2; h++) {
            final sign = h == 0 ? 1.0 : -1.0;
            final arcPath = Path()..moveTo(source.dx, source.dy);
            for (int i = 1; i <= 6; i++) {
              final t = i / 6.0;
              final lx = source.dx + math.sin(t * math.pi * 3 + beamProg * 8) * (18.0 * sign);
              final ly = ui.lerpDouble(source.dy, target.dy, t)!;
              arcPath.lineTo(lx, ly);
            }
            canvas.drawPath(
              arcPath,
              Paint()
                ..color = (h == 0 ? const Color(0xFFFDE047) : const Color(0xFFE879F9)).withValues(alpha: fade * 0.85)
                ..strokeWidth = 2.2
                ..style = PaintingStyle.stroke,
            );
          }
          break;

        // 🗡️ Chrono Katana / Blades: Sonic speed cross-slash lines
        case PerkType.timeFreeze:
          // X-Slash 1
          canvas.drawLine(
            Offset(target.dx - 36, target.dy - 36),
            Offset(target.dx + 36, target.dy + 36),
            Paint()
              ..color = const Color(0xFF38BDF8).withValues(alpha: fade)
              ..strokeWidth = 4.5 * fade
              ..strokeCap = StrokeCap.round,
          );
          // X-Slash 2
          canvas.drawLine(
            Offset(target.dx + 36, target.dy - 36),
            Offset(target.dx - 36, target.dy + 36),
            Paint()
              ..color = Colors.white.withValues(alpha: fade)
              ..strokeWidth = 4.5 * fade
              ..strokeCap = StrokeCap.round,
          );
          // Blade glint diamond at center
          canvas.drawCircle(
            target,
            12.0 * fade,
            Paint()
              ..color = const Color(0xFF93C5FD).withValues(alpha: fade * 0.6)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          );
          break;

        // ⚔️ Paladin Broadsword: Golden Holy Light Pillar from the sky
        case PerkType.armyKnights:
          final skyOrigin = Offset(target.dx, target.dy - 320);
          canvas.drawLine(
            skyOrigin,
            target,
            Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFEF08A), Color(0xFFFFD700), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(Rect.fromPoints(skyOrigin, target))
              ..strokeWidth = 22.0 * fade
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
          );
          canvas.drawLine(
            skyOrigin,
            target,
            Paint()
              ..color = Colors.white.withValues(alpha: fade)
              ..strokeWidth = 6.0 * fade,
          );
          break;

        // 🛡️ Aegis Ram / Titanium Shield: Concentric sonic force ramming forward
        default:
          for (int r = 1; r <= 3; r++) {
            canvas.drawCircle(
              Offset(target.dx, target.dy + (20 * (1.0 - beamProg))),
              (18.0 * r) * beamProg,
              Paint()
                ..color = const Color(0xFF10B981).withValues(alpha: fade * 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.0 * fade,
            );
          }
          break;
      }
    }

    // 💥 2. Citadel Impact Explosion & Expanding Shockwave (particleProg > 0)
    if (particleProg > 0 && particleProg <= 1.0) {
      final pFade = (1.0 - particleProg).clamp(0.0, 1.0);

      // Expanding Shockwave Ring
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: pFade * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * pFade;
      canvas.drawCircle(target, 68.0 * particleProg, ringPaint);

      // Blinding Impact Core Flash
      canvas.drawCircle(
        target,
        34.0 * (1.0 - particleProg),
        Paint()
          ..color = Colors.white.withValues(alpha: pFade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Flying Explosion Sparks (28 directional particles)
      final sparkPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 28; i++) {
        final angle = (i / 28.0) * math.pi * 2;
        final speed = 45.0 + (i % 6) * 16.0;
        final px = target.dx + math.cos(angle) * speed * particleProg;
        final py = target.dy + math.sin(angle) * speed * particleProg - (12.0 * particleProg);

        sparkPaint.color = (i % 2 == 0 ? const Color(0xFFFFB703) : const Color(0xFFEF4444)).withValues(alpha: pFade);
        canvas.drawCircle(Offset(px, py), (3.8 - (particleProg * 1.6)).clamp(1.0, 4.0), sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CitadelAvatarStrikePainter oldDelegate) =>
      oldDelegate.beamProg != beamProg || oldDelegate.particleProg != particleProg;
}

/// 🪙 Magnetic Coin Looting Shower Painter
/// Coins fountain out of the breached citadel doors and fly down directly into
/// the attacking hero's treasure chest/grasp!
class CitadelCoinShowerPainter extends CustomPainter {
  final double progress;
  CitadelCoinShowerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final origin = Offset(size.width * 0.5, 680.0); // Breached mansion doors
    final heroChest = Offset(size.width * 0.5, 760.0); // Hero collection chest
    final coinPaint = Paint()..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFB45309);
    final fade = (1.0 - progress).clamp(0.0, 1.0);

    // 🪙 24 Shimmering Gold Coins in Magnetic Trajectories
    for (int i = 0; i < 24; i++) {
      // Phase 1 (prog 0.0 -> 0.35): Erupting upward & outward fountain
      // Phase 2 (prog 0.35 -> 1.0): Pulled magnetically into heroChest!
      final burstSpreadX = math.sin(i * 1.5) * 160.0;
      final burstSpreadY = -80.0 - ((i % 5) * 22.0);
      final apex = Offset(origin.dx + burstSpreadX, origin.dy + burstSpreadY);

      double cx, cy;
      if (progress < 0.35) {
        final t = progress / 0.35;
        cx = ui.lerpDouble(origin.dx, apex.dx, t)!;
        cy = ui.lerpDouble(origin.dy, apex.dy, t)!;
      } else {
        final t = (progress - 0.35) / 0.65;
        // Curved cubic pull towards hero's chest
        final curvedT = Curves.easeInCubic.transform(t);
        cx = ui.lerpDouble(apex.dx, heroChest.dx, curvedT)!;
        cy = ui.lerpDouble(apex.dy, heroChest.dy, curvedT)!;
      }

      // Outer coin glow glint
      canvas.drawCircle(
        Offset(cx, cy),
        7.5,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: fade * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Gold Coin Face
      coinPaint.color = const Color(0xFFFFD700).withValues(alpha: fade);
      canvas.drawCircle(Offset(cx, cy), 5.5, coinPaint);
      canvas.drawCircle(Offset(cx, cy), 5.5, rimPaint..color = const Color(0xFFB45309).withValues(alpha: fade));

      // Shimmer highlight
      canvas.drawCircle(
        Offset(cx - 1.5, cy - 1.5),
        1.5,
        Paint()..color = Colors.white.withValues(alpha: fade * 0.9),
      );
    }

    // Chest Collection Sparkle Glints
    if (progress > 0.45) {
      final glintFade = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      canvas.drawCircle(
        heroChest,
        18.0 * (1.0 - glintFade),
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: (1.0 - glintFade) * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CitadelCoinShowerPainter oldDelegate) => oldDelegate.progress != progress;
}

/// 🏛️ Animated Presidential Court Case Filing Dialog
class _PresidentialDispatchDialog extends StatefulWidget {
  final String targetName;
  final String targetId;
  final HouseShieldQuestion currentQ;
  final String reason;

  const _PresidentialDispatchDialog({
    required this.targetName,
    required this.targetId,
    required this.currentQ,
    required this.reason,
  });

  @override
  State<_PresidentialDispatchDialog> createState() => _PresidentialDispatchDialogState();
}

class _PresidentialDispatchDialogState extends State<_PresidentialDispatchDialog> {
  bool _isDispatched = false;
  String _caseNumber = '';

  @override
  void initState() {
    super.initState();
    _caseNumber = 'DEC-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';
    _performDispatch();
  }

  Future<void> _performDispatch() async {
    HapticFeedback.heavyImpact();
    // 1. File to Presidential Service and Supabase
    await PocketFortressDefenseService.fileDefenseReport(
      houseId: widget.targetId,
      houseOwnerName: widget.targetName,
      questionId: widget.currentQ.id,
      questionText: widget.currentQ.question,
      options: widget.currentQ.options,
      correctIndex: widget.currentQ.correctIndex,
      reporterId: 'attacker_me',
      reporterName: 'Citadel Raider',
      reason: widget.reason,
      details: 'Reported during live raid blitz combat.',
    );

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      HapticFeedback.lightImpact();
      setState(() => _isDispatched = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isDispatched ? const Color(0xFF10B981) : const Color(0xFFFFD700),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isDispatched ? const Color(0xFF10B981) : const Color(0xFFFFD700)).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_isDispatched ? const Color(0xFF10B981) : const Color(0xFFFFD700)).withValues(alpha: 0.15),
                border: Border.all(
                  color: _isDispatched ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _isDispatched ? '⚖️' : '🏛️',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isDispatched
                  ? 'CASE FILED WITH PRESIDENT & ADMIN!'
                  : 'DISPATCHING TO PRESIDENTIAL COURT...',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Dossier #$_caseNumber • Target: ${widget.targetName}',
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            if (!_isDispatched) ...[
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Submitting encrypted fraud evidence to the Presidency...\nTarget citadel faces Pocket Score wipeout if confirmed guilty.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '✓ Formal Investigation Opened',
                      style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The Supreme Presidential Court & Admin inspect all fraudulent defense questions. Confirmed violations result in immediate Pocket Score deduction & citadel demotion to Level 1.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'RETURN TO COMBAT ⚔️',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🌄 2D Open World Living Scenery Painter (1800 x 1600 Cinematic Landscape)
/// Features infinite cosmic night sky (or azure daytime), passing space rocket / satellite,
/// glowing crescent moon, Aurora Borealis, rotating Dutch windmill, arched stone footbridge,
/// rotating waterwheel, swimming white swans, fluttering butterflies (day) / fireflies (night),
/// floating hot air balloon, festive celebration bunting, flowerbeds, and lush orchard trees.
class CitadelScenicLandscapePainter extends CustomPainter {
  final bool isDamaged;
  final double groundBaseY;
  final bool isNight;
  final bool isDay90;
  final double ambientProg;

  CitadelScenicLandscapePainter({
    this.isDamaged = false,
    this.groundBaseY = 920.0,
    this.isNight = false,
    this.isDay90 = false,
    this.ambientProg = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final gy = groundBaseY > 0 ? groundBaseY : 920.0;

    // 1. Sky & Cosmic Atmosphere (Covers full 1800 width down to ground)
    final skyShader = isNight
        ? const LinearGradient(
            colors: [
              Color(0xFF030712), // Deep Space Obsidian
              Color(0xFF090D1A),
              Color(0xFF0F172A),
              Color(0xFF1E293B), // Horizon Twilight
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, gy + 30))
        : const LinearGradient(
            colors: [
              Color(0xFF0284C7), // Deep Azure
              Color(0xFF38BDF8), // Vibrant Cyan
              Color(0xFFBAE6FD), // Horizon Mist
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, gy + 30));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, gy + 30), Paint()..shader = skyShader);

    if (isNight) {
      // 🌌 Faint Celestial Nebula Dust Band Across Upper Sky
      final nebulaPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF6366F1).withValues(alpha: 0.09),
            const Color(0xFFA855F7).withValues(alpha: 0.08),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, gy * 0.7))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, gy * 0.7), nebulaPaint);

      // 🌌 Shimmering Aurora Borealis (Northern Lights Ribbon)
      final auroraPath = Path();
      final auroraWave = math.sin(ambientProg * 2 * math.pi) * 18.0;
      auroraPath.moveTo(0, gy * 0.35 + auroraWave);
      auroraPath.cubicTo(w * 0.28, gy * 0.22 - auroraWave, w * 0.62, gy * 0.44 + auroraWave, w, gy * 0.28);
      auroraPath.lineTo(w, gy * 0.46);
      auroraPath.cubicTo(w * 0.62, gy * 0.60 + auroraWave, w * 0.28, gy * 0.38 - auroraWave, 0, gy * 0.52);
      auroraPath.close();

      final auroraShader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF10B981).withValues(alpha: 0.18),
          const Color(0xFF38BDF8).withValues(alpha: 0.16),
          const Color(0xFFC084FC).withValues(alpha: 0.14),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy * 0.20, w, gy * 0.40));
      canvas.drawPath(auroraPath, Paint()..shader = auroraShader..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));

      // 🌙 Glowing Crescent Moon
      final moonCenter = Offset(w * 0.82, gy * 0.22);
      canvas.drawCircle(
        moonCenter,
        52,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawCircle(
        moonCenter,
        34,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(moonCenter, 22, Paint()..color = const Color(0xFFFEF08A));
      canvas.drawCircle(Offset(moonCenter.dx + 8, moonCenter.dy - 5), 20, Paint()..color = const Color(0xFF090D1A));

      // ✨ Expansive Twinkling Starfield across width
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
      final starGlowPaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      final starPoints = [
        Offset(w * 0.04, gy * 0.08), Offset(w * 0.08, gy * 0.24), Offset(w * 0.12, gy * 0.14),
        Offset(w * 0.16, gy * 0.32), Offset(w * 0.20, gy * 0.06), Offset(w * 0.24, gy * 0.20),
        Offset(w * 0.28, gy * 0.10), Offset(w * 0.32, gy * 0.28), Offset(w * 0.36, gy * 0.15),
        Offset(w * 0.40, gy * 0.05), Offset(w * 0.44, gy * 0.22), Offset(w * 0.48, gy * 0.12),
        Offset(w * 0.52, gy * 0.30), Offset(w * 0.56, gy * 0.08), Offset(w * 0.60, gy * 0.25),
        Offset(w * 0.64, gy * 0.16), Offset(w * 0.68, gy * 0.07), Offset(w * 0.72, gy * 0.28),
        Offset(w * 0.76, gy * 0.14), Offset(w * 0.80, gy * 0.05), Offset(w * 0.84, gy * 0.34),
        Offset(w * 0.88, gy * 0.18), Offset(w * 0.92, gy * 0.09), Offset(w * 0.96, gy * 0.26),
        Offset(w * 0.06, gy * 0.42), Offset(w * 0.15, gy * 0.46), Offset(w * 0.22, gy * 0.38),
        Offset(w * 0.35, gy * 0.42), Offset(w * 0.42, gy * 0.36), Offset(w * 0.58, gy * 0.44),
        Offset(w * 0.67, gy * 0.38), Offset(w * 0.75, gy * 0.46), Offset(w * 0.89, gy * 0.40),
        Offset(w * 0.95, gy * 0.48), Offset(w * 0.10, gy * 0.04), Offset(w * 0.50, gy * 0.03),
        Offset(w * 0.70, gy * 0.03), Offset(w * 0.90, gy * 0.04),
      ];

      for (int i = 0; i < starPoints.length; i++) {
        final pt = starPoints[i];
        final twinkle = 0.75 + math.sin(ambientProg * 8 * math.pi + i) * 0.25;
        final size = ((i % 4 == 0) ? 2.5 : ((i % 2 == 0) ? 1.8 : 1.2)) * twinkle;
        if (size >= 1.6) {
          canvas.drawCircle(pt, size + 1.2, starGlowPaint);
        }
        canvas.drawCircle(pt, size, starPaint);
      }

      // ☄️ Shooting Stars (Meteors)
      _drawShootingStar(canvas, w * 0.28, gy * 0.14, 68);
      _drawShootingStar(canvas, w * 0.72, gy * 0.08, 85);

      // 🚀 Cosmic Space Rocket with pulsating plasma flame
      _drawCosmicRocket(canvas, w * 0.24, gy * 0.20, ambientProg: ambientProg);
    } else {
      // ☀️ Radiant Golden Sun with glowing aura rings
      final sunCenter = Offset(w * 0.82, gy * 0.26);
      canvas.drawCircle(
        sunCenter,
        64,
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
      canvas.drawCircle(
        sunCenter,
        42,
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: 0.38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(sunCenter, 26, Paint()..color = const Color(0xFFFDE047));

      // 🎈 Floating Striped Hot Air Balloon
      final balloonX = w * 0.38 + math.sin(ambientProg * 2 * math.pi) * 28.0;
      final balloonY = gy * 0.16 + math.cos(ambientProg * 2 * math.pi) * 8.0;
      _drawHotAirBalloon(canvas, balloonX, balloonY);

      // ☁️ Drifting Fluffy Clouds
      final cloudFloat = math.sin(ambientProg * 2 * math.pi) * 14.0;
      _drawFluffyCloud(canvas, w * 0.12 + cloudFloat, gy * 0.18, 22);
      _drawFluffyCloud(canvas, w * 0.44 - cloudFloat, gy * 0.28, 18);
      _drawFluffyCloud(canvas, w * 0.62 + cloudFloat, gy * 0.22, 20);
      _drawFluffyCloud(canvas, w * 0.88 - cloudFloat, gy * 0.38, 16);

      // 🕊️ Flying Birds Soaring Across the Sky with Flapping Wings & Migrating Flock
      _drawFlyingBird(canvas, w * 0.24, gy * 0.16, 15, ambientProg: ambientProg, phase: 0.0);
      _drawFlyingBird(canvas, w * 0.30, gy * 0.12, 11, ambientProg: ambientProg, phase: 0.25);
      _drawFlyingBird(canvas, w * 0.54, gy * 0.14, 13, ambientProg: ambientProg, phase: 0.5);
      _drawFlyingBird(canvas, w * 0.70, gy * 0.10, 10, ambientProg: ambientProg, phase: 0.75);
      _drawFlyingBirdsFlock(canvas, w, gy, ambientProg);
    }

    // 🏔️ 2. Distant Majestic Mountain Ranges
    final mountainPath = Path();
    mountainPath.moveTo(0, gy - 20);
    mountainPath.lineTo(w * 0.10, gy - 95);
    mountainPath.lineTo(w * 0.24, gy - 160); // High Peak 1
    mountainPath.lineTo(w * 0.38, gy - 85);
    mountainPath.lineTo(w * 0.52, gy - 145); // High Peak 2
    mountainPath.lineTo(w * 0.68, gy - 80);
    mountainPath.lineTo(w * 0.82, gy - 175); // High Peak 3
    mountainPath.lineTo(w * 0.92, gy - 90);
    mountainPath.lineTo(w, gy - 35);
    mountainPath.lineTo(w, h);
    mountainPath.lineTo(0, h);
    mountainPath.close();

    final mountainPaint = Paint()
      ..color = isNight
          ? const Color(0xFF1E1B4B).withValues(alpha: 0.65)
          : const Color(0xFF0D9488).withValues(alpha: 0.40);
    canvas.drawPath(mountainPath, mountainPaint);

    // Mountain Peak highlights
    final peakHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.20 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.24, gy - 160), Offset(w * 0.28, gy - 120), peakHighlight);
    canvas.drawLine(Offset(w * 0.52, gy - 145), Offset(w * 0.56, gy - 110), peakHighlight);
    canvas.drawLine(Offset(w * 0.82, gy - 175), Offset(w * 0.86, gy - 130), peakHighlight);

    // 🌊 Cascading Mountain Waterfall on High Peak
    _drawMountainWaterfall(
      canvas,
      w * 0.24,
      gy - 160,
      gy - 20,
      ambientProg: ambientProg,
      isNight: isNight,
    );

    // 🌲 3. Midground Rolling Green Foothills
    final foothillPath = Path();
    foothillPath.moveTo(0, gy - 10);
    foothillPath.quadraticBezierTo(w * 0.22, gy - 55, w * 0.48, gy - 25);
    foothillPath.quadraticBezierTo(w * 0.74, gy - 60, w, gy - 15);
    foothillPath.lineTo(w, h);
    foothillPath.lineTo(0, h);
    foothillPath.close();

    final foothillPaint = Paint()
      ..color = isNight
          ? const Color(0xFF064E3B).withValues(alpha: 0.70)
          : const Color(0xFF15803D).withValues(alpha: 0.65);
    canvas.drawPath(foothillPath, foothillPaint);

    // 💨 4. Traditional Dutch Windmill with Rotating Sails on Hilltop
    _drawDutchWindmill(canvas, w * 0.18, gy - 32, ambientProg: ambientProg, isNight: isNight);

    // 🏡 5. Citadel Courtyard Hill Plateau (Where house stands)
    final hillPath = Path();
    hillPath.moveTo(0, gy);
    hillPath.quadraticBezierTo(w * 0.25, gy - 22, w * 0.50, gy - 14);
    hillPath.quadraticBezierTo(w * 0.75, gy - 4, w, gy + 12);
    hillPath.lineTo(w, h);
    hillPath.lineTo(0, h);
    hillPath.close();

    final hillColors = isNight
        ? [const Color(0xFF064E3B), const Color(0xFF065F46), const Color(0xFF022C22), const Color(0xFF022C22)]
        : [const Color(0xFF22C55E), const Color(0xFF16A34A), const Color(0xFF15803D), const Color(0xFF14532D)];

    final hillPaint = Paint()
      ..shader = LinearGradient(
        colors: hillColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy - 32, w, h - gy + 32));
    canvas.drawPath(hillPath, hillPaint);

    // Vibrant Grass Ridge Edge
    final ridgePaint = Paint()
      ..color = isNight ? const Color(0xFF059669).withValues(alpha: 0.6) : const Color(0xFF86EFAC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawPath(hillPath, ridgePaint);

    // 🌊 6. Curving Flowing River Across Valley
    final riverPath = Path();
    final ry = gy + 190.0;
    riverPath.moveTo(0, ry + 15);
    riverPath.cubicTo(w * 0.25, ry - 35, w * 0.55, ry + 55, w * 0.82, ry - 15);
    riverPath.cubicTo(w * 0.90, ry - 25, w * 0.96, ry, w, ry + 25);
    riverPath.lineTo(w, ry + 115);
    riverPath.cubicTo(w * 0.96, ry + 95, w * 0.90, ry + 75, w * 0.82, ry + 85);
    riverPath.cubicTo(w * 0.55, ry + 155, w * 0.25, ry + 65, 0, ry + 115);
    riverPath.close();

    final riverColors = isNight
        ? [const Color(0xFF0C4A6E), const Color(0xFF075985), const Color(0xFF0369A1)]
        : [const Color(0xFF0284C7), const Color(0xFF38BDF8), const Color(0xFF0EA5E9)];
    final riverPaint = Paint()
      ..shader = LinearGradient(
        colors: riverColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, ry - 35, w, 150));
    canvas.drawPath(riverPath, riverPaint);

    // Sparkling River Water Ripples (Animated with ambientProg)
    final rippleOffset = math.sin(ambientProg * 2 * math.pi) * 8.0;
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.35 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.12 + rippleOffset, ry + 22), Offset(w * 0.22 + rippleOffset, ry + 16), wavePaint);
    canvas.drawLine(Offset(w * 0.36 - rippleOffset, ry + 36), Offset(w * 0.48 - rippleOffset, ry + 46), wavePaint);
    canvas.drawLine(Offset(w * 0.65 + rippleOffset, ry + 50), Offset(w * 0.76 + rippleOffset, ry + 40), wavePaint);
    canvas.drawLine(Offset(w * 0.86 - rippleOffset, ry + 24), Offset(w * 0.94 - rippleOffset, ry + 32), wavePaint);

    // 🪷 Floating Pink Lotus Water Lilies on River
    _drawWaterLily(canvas, w * 0.28, ry + 38);
    _drawWaterLily(canvas, w * 0.78, ry + 68);

    // 🦢 Swimming White Swans with water ripple wake
    final swanX1 = w * 0.42 + math.sin(ambientProg * 2 * math.pi) * 16.0;
    final swanY1 = ry + 46.0;
    _drawSwan(canvas, swanX1, swanY1);

    final swanX2 = w * 0.46 + math.sin(ambientProg * 2 * math.pi + 0.5) * 12.0;
    final swanY2 = ry + 56.0;
    _drawSwan(canvas, swanX2, swanY2);

    // 🛶 Floating Wooden Rowboat
    final boatBob = math.sin(ambientProg * 2 * math.pi) * 2.5;
    final boatX = w * 0.66;
    final boatY = ry + 46.0 + boatBob;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(boatX, boatY + 9), width: 44, height: 7),
      Paint()..color = Colors.black.withValues(alpha: 0.30),
    );
    final boatPath = Path();
    boatPath.moveTo(boatX - 20, boatY);
    boatPath.quadraticBezierTo(boatX - 14, boatY + 10, boatX, boatY + 10);
    boatPath.quadraticBezierTo(boatX + 14, boatY + 10, boatX + 20, boatY);
    boatPath.lineTo(boatX + 15, boatY - 1.5);
    boatPath.quadraticBezierTo(boatX, boatY + 2.5, boatX - 15, boatY - 1.5);
    boatPath.close();
    canvas.drawPath(boatPath, Paint()..color = const Color(0xFF78350F));
    canvas.drawLine(Offset(boatX - 4, boatY + 2), Offset(boatX + 4, boatY + 2), Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.4);
    canvas.drawLine(Offset(boatX - 8, boatY - 5), Offset(boatX + 10, boatY + 12), Paint()..color = const Color(0xFFFDE68A)..strokeWidth = 1.6);

    // ⚙️ Rotating Wooden Waterwheel on Riverbank
    _drawWaterWheel(canvas, w * 0.88, ry + 18, ambientProg: ambientProg);

    // 🌉 7. Handsome Stone Arched Footbridge Spanning Across River
    _drawStoneBridge(canvas, w * 0.50, ry + 40, isNight: isNight);

    // 🏡 8. Cobblestone Courtyard Walkway from house entrance towards bridge
    final walkPath = Path();
    walkPath.moveTo(w * 0.47, gy + 10);
    walkPath.quadraticBezierTo(w * 0.48, gy + 80, w * 0.44, ry - 10);
    walkPath.lineTo(w * 0.56, ry - 10);
    walkPath.quadraticBezierTo(w * 0.52, gy + 80, w * 0.53, gy + 10);
    walkPath.close();

    final walkPaint = Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: isNight ? 0.20 : 0.35);
    canvas.drawPath(walkPath, walkPaint);

    final stonePaint = Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: isNight ? 0.25 : 0.40);
    for (int i = 0; i < 7; i++) {
      final stoneY = gy + 18 + (i * 22);
      final stoneX = w * 0.50 + math.sin(i * 1.4) * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(stoneX, stoneY), width: 34 - (i * 1.5), height: 9), const Radius.circular(4.5)),
        stonePaint,
      );
    }

    // 🚩 9. Festive Celebration Bunting Flags (Triangle party flags)
    _drawPartyBunting(canvas, w * 0.24, gy - 16, w * 0.36, gy - 12);
    _drawPartyBunting(canvas, w * 0.64, gy - 12, w * 0.76, gy - 16);

    // 10. White Picket Fences along property bounds
    _drawPicketFence(canvas, w * 0.24, gy - 6, 5);
    _drawPicketFence(canvas, w * 0.68, gy - 2, 5);

    // 11. Colorful Flowerbeds (Tulips, Roses, Blossoms)
    _drawFlowerbed(canvas, w * 0.34, gy + 2);
    _drawFlowerbed(canvas, w * 0.64, gy + 4);

    // 🦋 12. Fluttering Butterflies in Day / ✨ Glowing Fireflies at Night
    if (!isNight) {
      _drawButterfly(canvas, w * 0.33, gy - 8, ambientProg: ambientProg, color: const Color(0xFFFB923C));
      _drawButterfly(canvas, w * 0.36, gy + 6, ambientProg: ambientProg + 0.3, color: const Color(0xFF38BDF8));
      _drawButterfly(canvas, w * 0.63, gy - 4, ambientProg: ambientProg + 0.6, color: const Color(0xFFFACC15));
      _drawButterfly(canvas, w * 0.66, gy + 8, ambientProg: ambientProg + 0.2, color: const Color(0xFFF43F5E));
      _drawButterfly(canvas, w * 0.26, gy - 22, ambientProg: ambientProg + 0.8, color: const Color(0xFFA855F7));
    } else {
      _drawFirefly(canvas, w * 0.28, gy - 14, ambientProg: ambientProg, phase: 0.1);
      _drawFirefly(canvas, w * 0.32, gy + 8, ambientProg: ambientProg, phase: 0.4);
      _drawFirefly(canvas, w * 0.65, gy - 10, ambientProg: ambientProg, phase: 0.7);
      _drawFirefly(canvas, w * 0.72, gy + 12, ambientProg: ambientProg, phase: 0.2);
      _drawFirefly(canvas, w * 0.48, ry + 20, ambientProg: ambientProg, phase: 0.5);
      _drawFirefly(canvas, w * 0.54, ry + 35, ambientProg: ambientProg, phase: 0.8);
      _drawFirefly(canvas, w * 0.80, gy - 25, ambientProg: ambientProg, phase: 0.3);
      _drawFirefly(canvas, w * 0.15, gy - 18, ambientProg: ambientProg, phase: 0.9);
    }

    // 13. Lush Trees: Orchard Apples & Japanese Cherry Blossom (Sakura)
    _drawTree(canvas, w * 0.12, gy - 8, scale: 1.3);
    _drawCherryBlossomTree(canvas, w * 0.22, gy - 16, scale: 1.1, ambientProg: ambientProg);
    _drawCherryBlossomTree(canvas, w * 0.78, gy - 4, scale: 1.15, ambientProg: ambientProg);
    _drawTree(canvas, w * 0.88, gy + 6, scale: 1.35);

    // Riverbank shade trees
    _drawTree(canvas, w * 0.08, ry + 10, scale: 1.1);
    _drawTree(canvas, w * 0.92, ry + 20, scale: 1.15);

    // 14. Street Lamps with Warm Golden Glowing Lanterns
    _drawStreetLamp(canvas, w * 0.30, gy + 12, isNight: isNight);
    _drawStreetLamp(canvas, w * 0.70, gy + 16, isNight: isNight);

    // 15. Lower Valley Rolling Meadows
    final lowerMeadowPath = Path();
    lowerMeadowPath.moveTo(0, ry + 115);
    lowerMeadowPath.quadraticBezierTo(w * 0.40, ry + 130, w * 0.75, ry + 110);
    lowerMeadowPath.quadraticBezierTo(w * 0.90, ry + 100, w, ry + 115);
    lowerMeadowPath.lineTo(w, h);
    lowerMeadowPath.lineTo(0, h);
    lowerMeadowPath.close();

    final meadowPaint = Paint()..color = isNight ? const Color(0xFF022C22) : const Color(0xFF15803D);
    canvas.drawPath(lowerMeadowPath, meadowPaint);

    // Trees in the lower valley
    _drawTree(canvas, w * 0.18, ry + 180, scale: 1.1);
    _drawCherryBlossomTree(canvas, w * 0.42, ry + 220, scale: 1.05, ambientProg: ambientProg);
    _drawTree(canvas, w * 0.68, ry + 200, scale: 1.2);
    _drawTree(canvas, w * 0.84, ry + 240, scale: 1.05);

    // 👑 Day 90 Sovereign Citadel Special: Majestic Celestial Grandeur & Floating Crown
    if (isDay90) {
      _drawDay90CelestialGrandeur(canvas, w, gy, ambientProg);

      final crownCenter = Offset(w * 0.5, gy - 430);
      canvas.drawCircle(
        crownCenter,
        44,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      final crownPath = Path();
      crownPath.moveTo(crownCenter.dx - 26, crownCenter.dy + 10);
      crownPath.lineTo(crownCenter.dx + 26, crownCenter.dy + 10);
      crownPath.lineTo(crownCenter.dx + 24, crownCenter.dy - 14);
      crownPath.lineTo(crownCenter.dx + 12, crownCenter.dy - 3);
      crownPath.lineTo(crownCenter.dx, crownCenter.dy - 18);
      crownPath.lineTo(crownCenter.dx - 12, crownCenter.dy - 3);
      crownPath.lineTo(crownCenter.dx - 24, crownCenter.dy - 14);
      crownPath.close();
      canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(crownCenter.dx - 24, crownCenter.dy - 14), 2.8, Paint()..color = const Color(0xFFEF4444));
      canvas.drawCircle(Offset(crownCenter.dx, crownCenter.dy - 18), 3.4, Paint()..color = const Color(0xFF38BDF8));
      canvas.drawCircle(Offset(crownCenter.dx + 24, crownCenter.dy - 14), 2.8, Paint()..color = const Color(0xFF10B981));
    }
  }

  /// 💨 Traditional Dutch Windmill with Rotating Timber Sails
  void _drawDutchWindmill(Canvas canvas, double x, double y, {double ambientProg = 0.0, bool isNight = false}) {
    // Stone base
    final basePath = Path();
    basePath.moveTo(x - 18, y);
    basePath.lineTo(x - 14, y - 48);
    basePath.lineTo(x + 14, y - 48);
    basePath.lineTo(x + 18, y);
    basePath.close();
    canvas.drawPath(basePath, Paint()..color = isNight ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    // Wooden dome cap
    final capPath = Path();
    capPath.moveTo(x - 16, y - 48);
    capPath.quadraticBezierTo(x, y - 62, x + 16, y - 48);
    capPath.close();
    canvas.drawPath(capPath, Paint()..color = const Color(0xFF78350F));

    // Warm round window
    canvas.drawCircle(
      Offset(x, y - 28),
      4.5,
      Paint()..color = isNight ? const Color(0xFFFFB703) : const Color(0xFF38BDF8),
    );

    // Center hub for rotating sails
    final hub = Offset(x, y - 46);
    final angle = ambientProg * 2 * math.pi;

    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.rotate(angle);

    final sailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final sparPaint = Paint()
      ..color = const Color(0xFF92400E)
      ..strokeWidth = 2.0;

    // 4 lattice sails
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * (math.pi / 2));
      // Spar
      canvas.drawLine(Offset.zero, const Offset(0, -38), sparPaint);
      // Sail canvas
      final sail = Path();
      sail.moveTo(1.5, -12);
      sail.lineTo(9.5, -14);
      sail.lineTo(9.5, -36);
      sail.lineTo(1.5, -36);
      sail.close();
      canvas.drawPath(sail, sailPaint);
      canvas.restore();
    }

    // Hub cap
    canvas.drawCircle(Offset.zero, 3.5, Paint()..color = const Color(0xFF451A03));
    canvas.restore();
  }

  /// 🎈 Striped Hot Air Balloon Floating Across Sky
  void _drawHotAirBalloon(Canvas canvas, double x, double y) {
    // Balloon envelope
    final envPath = Path();
    envPath.moveTo(x - 18, y - 10);
    envPath.cubicTo(x - 24, y - 38, x + 24, y - 38, x + 18, y - 10);
    envPath.lineTo(x + 7, y + 10);
    envPath.lineTo(x - 7, y + 10);
    envPath.close();

    canvas.drawPath(
      envPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFFBBF24), Color(0xFF06B6D4), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCenter(center: Offset(x, y - 14), width: 48, height: 48)),
    );

    // Ropes to basket
    final ropePaint = Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.0;
    canvas.drawLine(Offset(x - 6, y + 10), Offset(x - 4, y + 18), ropePaint);
    canvas.drawLine(Offset(x + 6, y + 10), Offset(x + 4, y + 18), ropePaint);

    // Wicker basket
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y + 21), width: 9, height: 6), const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF92400E),
    );
  }

  /// 🌉 Classical Stone Arched Footbridge Spanning River
  void _drawStoneBridge(Canvas canvas, double x, double y, {bool isNight = false}) {
    // Arch Path
    final bridgePath = Path();
    bridgePath.moveTo(x - 46, y - 40);
    bridgePath.lineTo(x + 46, y - 40);
    bridgePath.lineTo(x + 46, y + 42);
    bridgePath.lineTo(x - 46, y + 42);
    bridgePath.close();

    // Stone bridge body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 90, height: 80), const Radius.circular(8)),
      Paint()..color = isNight ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );

    // Under-arch cutout for water
    final archCut = Path();
    archCut.moveTo(x - 30, y + 42);
    archCut.quadraticBezierTo(x, y - 4, x + 30, y + 42);
    archCut.close();
    canvas.drawPath(archCut, Paint()..color = isNight ? const Color(0xFF0369A1) : const Color(0xFF0284C7));

    // Bridge Balustrade Rails
    final railPaint = Paint()..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF94A3B8)..strokeWidth = 2.4;
    canvas.drawLine(Offset(x - 44, y - 36), Offset(x + 44, y - 36), railPaint);
    canvas.drawLine(Offset(x - 44, y + 36), Offset(x + 44, y + 36), railPaint);

    // 4 Coach Lanterns at bridge corners
    for (final ox in [-40.0, 40.0]) {
      for (final oy in [-38.0, 38.0]) {
        canvas.drawCircle(
          Offset(x + ox, y + oy),
          isNight ? 9.0 : 6.0,
          Paint()..color = const Color(0xFFFFD700).withValues(alpha: isNight ? 0.45 : 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(Offset(x + ox, y + oy), 2.5, Paint()..color = const Color(0xFFFFD700));
      }
    }
  }

  /// ⚙️ Rotating Wooden Waterwheel
  void _drawWaterWheel(Canvas canvas, double x, double y, {double ambientProg = 0.0}) {
    canvas.save();
    canvas.translate(x, y);
    final angle = ambientProg * 2 * math.pi;
    canvas.rotate(angle);

    final timberPaint = Paint()..color = const Color(0xFF78350F)..strokeWidth = 2.5;
    // Outer Rim
    canvas.drawCircle(Offset.zero, 18, Paint()..color = const Color(0xFF92400E)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    // Inner Hub
    canvas.drawCircle(Offset.zero, 5, Paint()..color = const Color(0xFF451A03));

    // 8 Paddles
    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(i * (math.pi / 4));
      canvas.drawLine(Offset.zero, const Offset(0, -18), timberPaint);
      canvas.drawLine(const Offset(-4, -18), const Offset(4, -18), Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.0);
      canvas.restore();
    }
    canvas.restore();
  }

  /// 🦢 Elegant White Swan Swimming in River
  void _drawSwan(Canvas canvas, double x, double y) {
    // Water ripple under swan
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 3), width: 22, height: 5),
      Paint()..color = Colors.white.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 1.0,
    );

    // Swan Body
    final body = Path();
    body.moveTo(x - 9, y);
    body.quadraticBezierTo(x - 5, y + 4, x + 4, y + 4);
    body.quadraticBezierTo(x + 9, y + 2, x + 8, y - 2);
    body.quadraticBezierTo(x + 2, y, x - 7, y - 2);
    body.close();
    canvas.drawPath(body, Paint()..color = Colors.white);

    // Swan S-Curved Neck & Head
    final neck = Path();
    neck.moveTo(x + 6, y);
    neck.cubicTo(x + 10, y - 6, x + 8, y - 12, x + 5, y - 11);
    neck.close();
    canvas.drawPath(neck, Paint()..color = Colors.white);

    // Orange Beak
    canvas.drawCircle(Offset(x + 4, y - 11), 1.2, Paint()..color = const Color(0xFFF97316));
  }

  /// 🪷 Floating Pink Lotus Water Lily
  void _drawWaterLily(Canvas canvas, double x, double y) {
    // Lily Pad
    canvas.drawCircle(Offset(x, y), 6.5, Paint()..color = const Color(0xFF059669));
    // Pink Lotus Blossom
    canvas.drawCircle(Offset(x - 1, y - 1), 3.0, Paint()..color = const Color(0xFFF472B6));
    canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = const Color(0xFFFEF08A));
  }

  /// 🚩 Festive Party Bunting (Triangle celebration flags)
  void _drawPartyBunting(Canvas canvas, double x1, double y1, double x2, double y2) {
    // String wire
    final stringPath = Path();
    stringPath.moveTo(x1, y1);
    stringPath.quadraticBezierTo((x1 + x2) / 2, ((y1 + y2) / 2) + 8, x2, y2);
    canvas.drawPath(stringPath, Paint()..color = Colors.white70..strokeWidth = 1.2..style = PaintingStyle.stroke);

    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFFBBF24),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
    ];

    // Triangle Pennant Flags hanging
    const flagCount = 6;
    for (int i = 0; i < flagCount; i++) {
      final t = (i + 0.5) / flagCount;
      final fx = ui.lerpDouble(x1, x2, t)!;
      final fy = ui.lerpDouble(y1, y2, t)! + math.sin(t * math.pi) * 8.0;

      final flag = Path();
      flag.moveTo(fx - 4, fy);
      flag.lineTo(fx + 4, fy);
      flag.lineTo(fx, fy + 7);
      flag.close();
      canvas.drawPath(flag, Paint()..color = colors[i % colors.length]);
    }
  }

  /// 🦋 Fluttering Butterfly (Daytime)
  void _drawButterfly(Canvas canvas, double x, double y, {double ambientProg = 0.0, Color color = const Color(0xFFFB923C)}) {
    final wingScale = math.sin(ambientProg * 18 * math.pi).abs();
    canvas.save();
    canvas.translate(x, y);

    final wingPaint = Paint()..color = color;
    // Left wing
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-3.5 * wingScale, -2), width: 7 * wingScale, height: 6),
      wingPaint,
    );
    // Right wing
    canvas.drawOval(
      Rect.fromCenter(center: Offset(3.5 * wingScale, -2), width: 7 * wingScale, height: 6),
      wingPaint,
    );
    // Body
    canvas.drawLine(const Offset(0, -3), const Offset(0, 3), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.2);
    canvas.restore();
  }

  /// ✨ Pulsing Firefly (Nighttime)
  void _drawFirefly(Canvas canvas, double x, double y, {double ambientProg = 0.0, double phase = 0.0}) {
    final pulse = 0.4 + (math.sin((ambientProg + phase) * 8 * math.pi) * 0.6).abs();
    canvas.drawCircle(
      Offset(x, y),
      8.0 * pulse,
      Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.45 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = const Color(0xFFFEF08A));
  }

  /// 🌸 Japanese Cherry Blossom (Sakura) Tree with Falling Petals
  void _drawCherryBlossomTree(Canvas canvas, double x, double y, {double scale = 1.0, double ambientProg = 0.0}) {
    // Tree Trunk
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - (28 * scale)),
      Paint()..color = const Color(0xFF5B3417)..strokeWidth = 5.0 * scale,
    );
    // Soft pink blossom foliage
    final p1 = Paint()..color = const Color(0xFFF472B6);
    final p2 = Paint()..color = const Color(0xFFFBCFE8);
    canvas.drawCircle(Offset(x, y - (38 * scale)), 17 * scale, p1);
    canvas.drawCircle(Offset(x - (8 * scale), y - (32 * scale)), 13 * scale, p2);
    canvas.drawCircle(Offset(x + (8 * scale), y - (32 * scale)), 13 * scale, p2);
    canvas.drawCircle(Offset(x, y - (46 * scale)), 12 * scale, p2);

    // Drifting flower petals
    for (int i = 0; i < 3; i++) {
      final t = (ambientProg + (i * 0.33)) % 1.0;
      final px = x - 12 + (t * 26) + math.sin(t * 8) * 4;
      final py = y - 25 + (t * 30);
      canvas.drawCircle(Offset(px, py), 1.6, Paint()..color = const Color(0xFFF472B6).withValues(alpha: 1.0 - t));
    }
  }

  /// 🚀 Cosmic Space Rocket / Satellite soaring through upper atmosphere
  void _drawCosmicRocket(Canvas canvas, double x, double y, {double ambientProg = 0.0}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-0.38);

    // 1. Plasma exhaust flame trail (pulsing with ambientProg)
    final pulse = 0.85 + math.sin(ambientProg * 14 * math.pi) * 0.15;
    final flameLen = 75.0 * pulse;
    final flamePath = Path();
    flamePath.moveTo(-24, -5);
    flamePath.lineTo(-flameLen, 0);
    flamePath.lineTo(-24, 5);
    flamePath.close();

    final flameShader = const LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFFFB923C), Color(0xFFEF4444), Colors.transparent],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    ).createShader(Rect.fromLTWH(-flameLen, -5, flameLen - 24, 10));
    canvas.drawPath(flamePath, Paint()..shader = flameShader);

    // Inner bright hot core flame
    final innerFlame = Path();
    innerFlame.moveTo(-24, -2.5);
    innerFlame.lineTo(-44 * pulse, 0);
    innerFlame.lineTo(-24, 2.5);
    innerFlame.close();
    canvas.drawPath(innerFlame, Paint()..color = const Color(0xFFFEF08A));

    // 2. Rocket Fuselage
    final bodyPath = Path();
    bodyPath.moveTo(-24, -7);
    bodyPath.lineTo(12, -7);
    bodyPath.quadraticBezierTo(26, -5, 34, 0);
    bodyPath.quadraticBezierTo(26, 5, 12, 7);
    bodyPath.lineTo(-24, 7);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFFF1F5F9));

    // Red Nose Cone tip
    final nosePath = Path();
    nosePath.moveTo(14, -6.5);
    nosePath.quadraticBezierTo(26, -5, 34, 0);
    nosePath.quadraticBezierTo(26, 5, 14, 6.5);
    nosePath.close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFEF4444));

    // Delta stabilization fins
    final topFin = Path()..moveTo(-18, -7)..lineTo(-28, -18)..lineTo(-10, -7)..close();
    canvas.drawPath(topFin, Paint()..color = const Color(0xFFDC2626));
    final btmFin = Path()..moveTo(-18, 7)..lineTo(-28, 18)..lineTo(-10, 7)..close();
    canvas.drawPath(btmFin, Paint()..color = const Color(0xFFDC2626));

    // Glowing cyan cockpit porthole window
    canvas.drawCircle(
      const Offset(2, 0),
      4.5,
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.40)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(const Offset(2, 0), 3.0, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(const Offset(1, -1), 1.0, Paint()..color = Colors.white);

    // Blinking beacon light on top fin tip
    canvas.drawCircle(const Offset(-28, -18), 2.2, Paint()..color = const Color(0xFFF43F5E));

    canvas.restore();
  }

  /// ☄️ Luminous shooting star with tapering tail
  void _drawShootingStar(Canvas canvas, double startX, double startY, double length) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, const Color(0xFF38BDF8).withValues(alpha: 0.6), Colors.transparent],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(startX - length, startY, length, length * 0.4))
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, startY), Offset(startX - length, startY + (length * 0.35)), paint);
    canvas.drawCircle(Offset(startX, startY), 2.2, Paint()..color = Colors.white);
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy, double r) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.80);
    canvas.drawCircle(Offset(cx, cy), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 0.9, cy - r * 0.35), r * 1.25, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 1.9, cy - r * 0.15), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 2.6, cy + r * 0.1), r * 0.75, cloudPaint);
  }

  /// 🕊️ Flying Bird with Organic Wing Flapping
  void _drawFlyingBird(
    Canvas canvas,
    double x,
    double y,
    double span, {
    double ambientProg = 0.0,
    double phase = 0.0,
    Color color = const Color(0xFF0369A1),
  }) {
    final wingFlap = math.sin((ambientProg + phase) * 12 * math.pi) * (span * 0.42);
    final birdPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final birdPath = Path();
    birdPath.moveTo(x - span, y + wingFlap);
    birdPath.quadraticBezierTo(x - (span * 0.45), y - (span * 0.35) - wingFlap * 0.35, x, y);
    birdPath.quadraticBezierTo(x + (span * 0.45), y - (span * 0.35) - wingFlap * 0.35, x + span, y + wingFlap);
    canvas.drawPath(birdPath, birdPaint);
  }

  /// 🕊️ Flock of Birds soaring gracefully in formation across the sky
  void _drawFlyingBirdsFlock(Canvas canvas, double w, double gy, double ambientProg) {
    // Flock travels horizontally across screen
    final baseOffset = (ambientProg * (w + 200)) - 100.0;
    final flockY = gy * 0.14 + math.sin(ambientProg * 4 * math.pi) * 8.0;

    final birdPositions = [
      Offset(baseOffset, flockY),
      Offset(baseOffset - 20, flockY + 11),
      Offset(baseOffset - 40, flockY + 22),
      Offset(baseOffset - 60, flockY + 33),
      Offset(baseOffset - 24, flockY - 11),
      Offset(baseOffset - 48, flockY - 20),
    ];

    for (int i = 0; i < birdPositions.length; i++) {
      final pos = birdPositions[i];
      if (pos.dx >= -40 && pos.dx <= w + 40) {
        _drawFlyingBird(
          canvas,
          pos.dx,
          pos.dy,
          9.0 + (i == 0 ? 3.5 : 0.0),
          ambientProg: ambientProg,
          phase: i * 0.16,
          color: const Color(0xFF0284C7),
        );
      }
    }
  }

  /// 🌊 Cascading Mountain Waterfall with Shimmering Rapids and White Foam
  void _drawMountainWaterfall(
    Canvas canvas,
    double x,
    double topY,
    double btmY, {
    double ambientProg = 0.0,
    bool isNight = false,
  }) {
    final waterHeight = btmY - topY;
    if (waterHeight <= 0) return;

    // Waterfall stream path
    final fallPath = Path();
    fallPath.moveTo(x - 3, topY);
    fallPath.cubicTo(x - 5, topY + waterHeight * 0.35, x - 7, topY + waterHeight * 0.7, x - 10, btmY);
    fallPath.lineTo(x + 10, btmY);
    fallPath.cubicTo(x + 7, topY + waterHeight * 0.7, x + 5, topY + waterHeight * 0.35, x + 3, topY);
    fallPath.close();

    final fallShader = LinearGradient(
      colors: isNight
          ? [
              const Color(0xFF38BDF8).withValues(alpha: 0.35),
              const Color(0xFF67E8F9).withValues(alpha: 0.65),
              Colors.white.withValues(alpha: 0.8),
            ]
          : [
              const Color(0xFF0284C7).withValues(alpha: 0.50),
              const Color(0xFF38BDF8).withValues(alpha: 0.80),
              Colors.white.withValues(alpha: 0.95),
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(x - 12, topY, 24, waterHeight));

    canvas.drawPath(fallPath, Paint()..shader = fallShader);

    // Animated shimmering water streaks flowing down
    for (int i = 0; i < 4; i++) {
      final t = (ambientProg * 2.2 + (i * 0.25)) % 1.0;
      final streakY = topY + (t * waterHeight);
      final streakW = 2.0 + (t * 4.0);
      final streakX = x + math.sin(t * math.pi) * 3;
      canvas.drawLine(
        Offset(streakX - streakW / 2, streakY),
        Offset(streakX + streakW / 2, streakY + 8),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Splash mist & foam pool at bottom
    final splashPulse = 0.85 + math.sin(ambientProg * 8 * math.pi) * 0.15;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, btmY), width: 28 * splashPulse, height: 9 * splashPulse),
      Paint()
        ..color = Colors.white.withValues(alpha: isNight ? 0.45 : 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, btmY + 2), width: 34 * splashPulse, height: 6),
      Paint()..color = (isNight ? const Color(0xFF38BDF8) : const Color(0xFFBAE6FD)).withValues(alpha: 0.55),
    );
  }

  /// 👑 Day 90 Celestial Sovereign Grandeur: Golden Aura, Ascending Light Pillars & Soaring Golden Eagle
  void _drawDay90CelestialGrandeur(
    Canvas canvas,
    double w,
    double gy,
    double ambientProg,
  ) {
    final centerX = w * 0.5;
    final crownCenter = Offset(centerX, gy - 430);

    // 1. Divine Radiant Sunburst Rays rotating slowly behind crown
    const rayCount = 16;
    const rayRadius = 140.0;
    final rotAngle = ambientProg * 2 * math.pi;
    for (int i = 0; i < rayCount; i++) {
      final angle = rotAngle + (i * (2 * math.pi / rayCount));
      final rayPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.28),
            const Color(0xFFF59E0B).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: crownCenter, radius: rayRadius))
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final startPt = Offset(
        crownCenter.dx + math.cos(angle) * 35,
        crownCenter.dy + math.sin(angle) * 35,
      );
      final endPt = Offset(
        crownCenter.dx + math.cos(angle) * rayRadius,
        crownCenter.dy + math.sin(angle) * rayRadius,
      );
      canvas.drawLine(startPt, endPt, rayPaint);
    }

    // 2. Twin Ascending Divine Light Pillars flanking the citadel
    final pillarLeftX = w * 0.22;
    final pillarRightX = w * 0.78;
    final pillarTopY = gy - 480;
    final pillarBtmY = gy + 20;
    const pillarWidth = 22.0;

    final pillarShader = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFFFFD700).withValues(alpha: 0.22),
        const Color(0xFFFDE047).withValues(alpha: 0.35),
        const Color(0xFFFFD700).withValues(alpha: 0.10),
        Colors.transparent,
      ],
      stops: const [0.0, 0.25, 0.5, 0.85, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawRect(
      Rect.fromLTWH(pillarLeftX - pillarWidth / 2, pillarTopY, pillarWidth, pillarBtmY - pillarTopY),
      Paint()
        ..shader = pillarShader.createShader(Rect.fromLTWH(pillarLeftX - pillarWidth / 2, pillarTopY, pillarWidth, pillarBtmY - pillarTopY))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRect(
      Rect.fromLTWH(pillarRightX - pillarWidth / 2, pillarTopY, pillarWidth, pillarBtmY - pillarTopY),
      Paint()
        ..shader = pillarShader.createShader(Rect.fromLTWH(pillarRightX - pillarWidth / 2, pillarTopY, pillarWidth, pillarBtmY - pillarTopY))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // 3. Soaring Majestic Golden Eagle circling above citadel
    final eagleOrbitX = centerX + math.cos(ambientProg * 2 * math.pi) * (w * 0.32);
    final eagleOrbitY = gy - 360 + math.sin(ambientProg * 4 * math.pi) * 25;
    _drawGoldenEagle(canvas, eagleOrbitX, eagleOrbitY, ambientProg);

    // 4. Shimmering Golden Dust particles ascending
    for (int i = 0; i < 14; i++) {
      final t = (ambientProg + (i * 0.071)) % 1.0;
      final px = centerX - (w * 0.35) + ((i * 47) % (w * 0.70));
      final py = gy + 10 - (t * 460);
      final sparkleAlpha = math.sin(t * math.pi);
      canvas.drawCircle(
        Offset(px, py),
        2.2 * sparkleAlpha,
        Paint()
          ..color = const Color(0xFFFFE066).withValues(alpha: 0.75 * sparkleAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(
        Offset(px, py),
        1.2 * sparkleAlpha,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * sparkleAlpha),
      );
    }
  }

  /// 🦅 Majestic Golden Eagle with broad outstretched wings soaring
  void _drawGoldenEagle(Canvas canvas, double x, double y, double ambientProg) {
    canvas.save();
    canvas.translate(x, y);

    final wingFlap = math.sin(ambientProg * 8 * math.pi) * 7.0;

    // Outer Golden Glow
    canvas.drawCircle(
      Offset.zero,
      28,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Left Wing
    final leftWing = Path();
    leftWing.moveTo(0, 0);
    leftWing.cubicTo(-14, -8 + wingFlap, -30, -18 + wingFlap, -44, -12 + wingFlap);
    leftWing.cubicTo(-34, -2 + wingFlap, -18, 2, 0, 4);
    leftWing.close();
    canvas.drawPath(leftWing, Paint()..color = const Color(0xFFD97706));

    // Right Wing
    final rightWing = Path();
    rightWing.moveTo(0, 0);
    rightWing.cubicTo(14, -8 + wingFlap, 30, -18 + wingFlap, 44, -12 + wingFlap);
    rightWing.cubicTo(34, -2 + wingFlap, 18, 2, 0, 4);
    rightWing.close();
    canvas.drawPath(rightWing, Paint()..color = const Color(0xFFD97706));

    // Feather Highlights
    final featherPaint = Paint()..color = const Color(0xFFFFD700)..strokeWidth = 1.4..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), Offset(-40, -10 + wingFlap), featherPaint);
    canvas.drawLine(const Offset(0, 0), Offset(40, -10 + wingFlap), featherPaint);

    // Eagle Body & Tail
    final body = Path();
    body.moveTo(-4, -6);
    body.lineTo(4, -6);
    body.lineTo(3, 10);
    body.lineTo(6, 18);
    body.lineTo(-6, 18);
    body.lineTo(-3, 10);
    body.close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF92400E));

    // Golden Head & Beak
    canvas.drawCircle(const Offset(0, -9), 4.5, Paint()..color = Colors.white);
    final beak = Path()..moveTo(-2, -9)..lineTo(2, -9)..lineTo(0, -14)..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFBBF24));

    canvas.restore();
  }

  void _drawPicketFence(Canvas canvas, double startX, double groundY, int pickets) {
    final fencePaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final shadowPaint = Paint()..color = Colors.black26;

    // Cross rails
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(startX, groundY - 18, pickets * 12.0 + 4, 3), const Radius.circular(1.5)), fencePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(startX, groundY - 8, pickets * 12.0 + 4, 3), const Radius.circular(1.5)), fencePaint);

    // Vertical pickets with pointed tops
    for (int i = 0; i < pickets; i++) {
      final px = startX + (i * 12.0) + 2;
      final path = Path();
      path.moveTo(px, groundY);
      path.lineTo(px, groundY - 22);
      path.lineTo(px + 3, groundY - 26);
      path.lineTo(px + 6, groundY - 22);
      path.lineTo(px + 6, groundY);
      path.close();
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, fencePaint);
    }
  }

  void _drawFlowerbed(Canvas canvas, double x, double y) {
    final colors = [const Color(0xFFEF4444), const Color(0xFFFBBF24), const Color(0xFFEC4899), const Color(0xFF38BDF8), const Color(0xFFA855F7)];
    for (int i = 0; i < 6; i++) {
      final fx = x + (i * 7) - 17;
      final fy = y + math.sin(i * 1.8) * 3;
      final stemPaint = Paint()..color = const Color(0xFF15803D)..strokeWidth = 1.5;
      canvas.drawLine(Offset(fx, fy), Offset(fx, fy - 7), stemPaint);
      final petalPaint = Paint()..color = colors[i % colors.length];
      canvas.drawCircle(Offset(fx, fy - 8), 3.2, petalPaint);
    }
  }

  void _drawTree(Canvas canvas, double x, double y, {double scale = 1.0}) {
    // Tree Trunk
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - (28 * scale)),
      Paint()..color = const Color(0xFF78350F)..strokeWidth = 5.0 * scale,
    );
    // Overlapping lush foliage balls
    final leafPaint1 = Paint()..color = const Color(0xFF15803D);
    final leafPaint2 = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(Offset(x, y - (38 * scale)), 16 * scale, leafPaint1);
    canvas.drawCircle(Offset(x - (8 * scale), y - (32 * scale)), 12 * scale, leafPaint2);
    canvas.drawCircle(Offset(x + (8 * scale), y - (32 * scale)), 12 * scale, leafPaint2);
    canvas.drawCircle(Offset(x, y - (44 * scale)), 11 * scale, leafPaint2);

    // Little red apples on branches
    final applePaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(x - (4 * scale), y - (36 * scale)), 2.4 * scale, applePaint);
    canvas.drawCircle(Offset(x + (5 * scale), y - (40 * scale)), 2.4 * scale, applePaint);
    canvas.drawCircle(Offset(x + (3 * scale), y - (30 * scale)), 2.4 * scale, applePaint);
  }

  void _drawStreetLamp(Canvas canvas, double x, double y, {bool isNight = false}) {
    // Post
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - 46),
      Paint()..color = const Color(0xFF475569)..strokeWidth = 3.2,
    );
    // Glowing warm lantern orb
    final glowRadius = isNight ? 28.0 : 20.0;
    canvas.drawCircle(
      Offset(x, y - 46),
      glowRadius,
      Paint()
        ..color = (isNight ? const Color(0xFFFFB703) : const Color(0xFFFFFC00)).withValues(alpha: isNight ? 0.45 : 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(Offset(x, y - 46), 5.5, Paint()..color = const Color(0xFFFFFC00));
  }

  @override
  bool shouldRepaint(covariant CitadelScenicLandscapePainter oldDelegate) =>
      oldDelegate.isDamaged != isDamaged ||
      oldDelegate.groundBaseY != groundBaseY ||
      oldDelegate.isNight != isNight ||
      oldDelegate.isDay90 != isDay90 ||
      oldDelegate.ambientProg != ambientProg;
}


