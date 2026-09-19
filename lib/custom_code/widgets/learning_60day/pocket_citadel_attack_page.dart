import 'dart:async';
import 'dart:math' as math;
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
    required this.attackerDay,
    this.attackerStreak = 0,
  });

  @override
  State<PocketCitadelAttackPage> createState() => _PocketCitadelAttackPageState();
}

class _PocketCitadelAttackPageState extends State<PocketCitadelAttackPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _raidStep = 0; // 0: Overview, 1: Defense Question, 2: Gate Breached (Attack button ready), 3: Victory, -1: Failed
  int _selectedOption = -1;
  bool _isStriking = false;
  bool _isQuestionSheetOpen = false;
  late int _defenderHp;
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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;
  late AnimationController _beamController;
  late AnimationController _particleController;
  late AnimationController _coinController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _defenderHp = widget.neighbor.hp;
    _isDefenderDamaged = widget.neighbor.isDamaged;

    _transformationController = TransformationController();
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if ((scale - _zoomScaleNotifier.value).abs() > 0.005) {
        _zoomScaleNotifier.value = scale;
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
      duration: const Duration(milliseconds: 1200),
    );

    _loadBattleState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _combatTimer?.cancel();
    _transformationController.dispose();
    _zoomScaleNotifier.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _beamController.dispose();
    _particleController.dispose();
    _coinController.dispose();
    super.dispose();
  }


  void _openDefenderProfile() {
    HapticFeedback.selectionClick();
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.neighbor.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainProfileWidget(
          userId: isUuid ? widget.neighbor.id : null,
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
    );
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

    // Audio & acoustic haptic stage 1: Beam charge & targeting lock
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
    _beamController.forward(from: 0.0);

    await Future.delayed(const Duration(milliseconds: 250));

    // Audio & acoustic haptic stage 2: Impact blast, screen shake & particle burst
    _shakeController.forward(from: 0.0);
    _particleController.forward(from: 0.0);

    for (int i = 0; i < 4; i++) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 70));
    }
    HapticFeedback.vibrate();

    final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay);
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

    // ⚔️ Audio Directive: Raider earns 10 to 15 Pocket Score (PS) points globally
    final looted = (result['lootedCoins'] as num? ?? 15).toInt();
    if (looted > 0) {
      await PocketFortressDefenseService.awardRaidLoot(looted);
    }

    await PocketFortressDefenseService.awardPoints(looted > 0 ? looted : 15);

    await Future.delayed(const Duration(milliseconds: 450));

    if (mounted) {
      _coinController.forward(from: 0.0);
      setState(() {
        _isStriking = false;
        _defenderHp = math.max(0, _defenderHp - 60);
        _defenderScore = math.max(0, _defenderScore - (looted > 0 ? looted : 15));
        _isDefenderDamaged = true;
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
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: const Color(0xFF0284C7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // 🏡 Ground level where the green estate lawn and house foundation meet
            final groundY = h * 0.54;
            final houseW = math.min(w * 0.94, 390.0);
            const houseH = 370.0;
            // House foundation rests naturally on the courtyard grass slope
            final houseBottom = h - groundY - 28.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 🔍 Interactive Estate Canvas with Smooth Pinch-to-Zoom & Pan (User Audio: "കൈകൊണ്ട് ഇങ്ങനെ ആക്കുമ്പോൾ സൂം ആവും, പിന്നെ സൂം ലെസ് ആവും")
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.75,
                    maxScale: 2.5,
                    boundaryMargin: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
                    clipBehavior: Clip.none,
                    child: SizedBox(
                      width: w,
                      height: h,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Full-Screen 2D Open World Scenery: Sky, Radiant Sun, Flying Birds, Clouds, Mountains, Rolling Hills, Courtyard Lawn, Trees
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CitadelScenicLandscapePainter(
                                isDamaged: _isDefenderDamaged,
                                groundBaseY: groundY,
                              ),
                            ),
                          ),

                          // 2. The 2D Flame English House seated firmly on the courtyard lawn
                          Positioned(
                            bottom: houseBottom,
                            left: (w - houseW) / 2,
                            width: houseW,
                            height: houseH,
                            child: FlameEnglishHouseWidget(
                              currentDay: widget.neighbor.day,
                              streak: widget.neighbor.streak,
                              isDamaged: _isDefenderDamaged,
                              houseId: widget.neighbor.id,
                              paletteId: widget.neighbor.paletteId,
                            ),
                          ),

                          // Chimney Smoke Puffs floating above the roof
                          Positioned(
                            bottom: houseBottom + houseH - 24,
                            left: (w / 2) - 86,
                            child: _buildChimneySmoke(),
                          ),
                          Positioned(
                            bottom: houseBottom + houseH - 24,
                            right: (w / 2) - 86,
                            child: _buildChimneySmoke(),
                          ),

                          // 3. Badges directly above the house roof (Avatar + Level + Pocket Score)
                          // User Audio Directive: "പിന്നെ അതിന്റെ മേലെ ചെറുതായിട്ട് എന്ത് ചെയ്യുക ഇവരുടെ അവതാർ കാണിക്കുക അത്രതന്നെ. പിന്നെ അവർ ഏതാ ലെവൽ എന്നുള്ളത് കാണിക്കുക, ഇവരുടെ പോക്കറ്റ് സ്കോറും കാണിക്കുക അത്രതന്നെ. വേറെ ഒന്നുമില്ല."
                          Positioned(
                            bottom: houseBottom + houseH - 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Defender Avatar Bubble
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1E293B),
                                      ),
                                      child: ClipOval(
                                        child: VectorAvatarWidget(
                                          config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    // Level Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Lvl ${widget.neighbor.day}',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    // Pocket Score
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🪙', style: TextStyle(fontSize: 12)),
                                        const SizedBox(width: 3),
                                        Text(
                                          'PS ${_defenderScore > 0 ? _defenderScore : PocketScoreLevelEngine.getRequiredScoreForLevel(widget.neighbor.day)} PTS',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFD700),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 4. Weapon Discharge & Particle Strike Layer
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_beamController, _particleController]),
                              builder: (context, _) {
                                if (_beamController.value <= 0 && _particleController.value <= 0) {
                                  return const SizedBox.shrink();
                                }
                                return IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelLaserStrikePainter(
                                      beamProg: _beamController.value,
                                      particleProg: _particleController.value,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // 5. Victory Coin Shower Layer
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
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. Attack strike visual impact overlay
                if (_isStriking) _buildStrikeOverlay(),

                // 7. Floating Top Capsule Header (Back button + View Profile + Info)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopHeaderCapsule(),
                ),

                // 8. Bottom Stacked Small Red "Attack" Button (when challenge sheet is closed)
                if (!_isQuestionSheetOpen)
                  Positioned(
                    bottom: 26,
                    left: 0,
                    right: 0,
                    child: _buildBottomAttackButton(),
                  ),

                // 9. Stacked Expanded Question / Challenge Sheet (when opened)
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

  /// 🌟 Top Floating Header: Back button on left, "View Profile" + minimal (i) info button on right
  Widget _buildTopHeaderCapsule() {
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

            // Right group: "View Profile" button + minimal (i) info button (User Directive: "ഒരു വ്യൂ പ്രൊഫൈൽ എന്ന് പറഞ്ഞിട്ട് ഒരു സാധനം കൊടുക്കണം. ജസ്റ്റ് അത് മാത്രം മതി വേറെ ഒന്നും വേണ്ട മേലെ")
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _openDefenderProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'View Profile',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Minimal (i) info button (User Directive: "വേണമെങ്കിൽ ഒരു ഐ ബട്ടൺ ഇവിടെ ചെറുതായി മിനിമൽ ഇട്ടാൽ മതി")
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
    return Positioned.fill(
      child: Container(
        color: Colors.red.withValues(alpha: 0.35),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💥 CITADEL STRIKE! ⚔️',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '-60 HP CRITICAL DAMAGE!',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ⚔️ Small Stacked Red Button at Bottom (User Directive: "ഈ Attack എന്നുള്ളത് ചെറിയ ബട്ടൺ ആക്കിയാൽ മതി")
  Widget _buildBottomAttackButton() {
    return Center(
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: GestureDetector(
          onTap: _onTapBottomAttack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
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
                  'Attack',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
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
            _buildStatRow('Defense HP', '$_defenderHp / 100 HP'),
            _buildStatRow('Pocket Score', '$_defenderScore PTS'),
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
                          '-60 Defender Citadel HP inflicted',
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
      _showNoticeDialog(
        '👮‍♂️ 26-Hour Presidential Protection Active!',
        'Guards stationed to allow resident recovery (${_protectionHoursLeft.toStringAsFixed(1)}h remaining). Attacks blocked.',
      );
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

class CitadelLaserStrikePainter extends CustomPainter {
  final double beamProg;
  final double particleProg;
  CitadelLaserStrikePainter({required this.beamProg, required this.particleProg});

  @override
  void paint(Canvas canvas, Size size) {
    if (beamProg <= 0 && particleProg <= 0) return;
    if (beamProg > 0 && beamProg < 1) {
      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 1.0 - beamProg)
        ..strokeWidth = 3.0 * (1.0 - beamProg)
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.5, size.height);
      path.lineTo(size.width * 0.5, size.height * (1.0 - beamProg));
      canvas.drawPath(path, paint);

      final glowPaint = Paint()
        ..color = Colors.amberAccent.withValues(alpha: (1.0 - beamProg) * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * (1.0 - beamProg)), 12.0 * beamProg, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CitadelLaserStrikePainter oldDelegate) =>
      oldDelegate.beamProg != beamProg || oldDelegate.particleProg != particleProg;
}

class CitadelCoinShowerPainter extends CustomPainter {
  final double progress;
  CitadelCoinShowerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final startX = size.width * (0.2 + random.nextDouble() * 0.6);
      final y = size.height * progress * (0.5 + random.nextDouble() * 0.5);
      final x = startX + math.sin(progress * math.pi * 2 + i) * 20;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = (i % 2 == 0 ? Colors.amber : Colors.yellowAccent).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), 4.0 + (i % 3), paint);
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

/// 🌄 2D Open World Hill Climb Scenery Painter (Screenshot Aesthetics)
/// Features vibrant sky blue gradient, glowing sun, drifting fluffy clouds, distant mountain ridges,
/// lush rolling green hills, foliage trees with red berries/apples, and glowing street lamps.
class CitadelScenicLandscapePainter extends CustomPainter {
  final bool isDamaged;
  final double groundBaseY;

  CitadelScenicLandscapePainter({
    this.isDamaged = false,
    this.groundBaseY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final gy = groundBaseY > 0 ? groundBaseY : h * 0.54;

    // 1. Sky Gradient (Vibrant blue matching user screenshot)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Radiant Golden Sun with glowing aura rings
    final sunCenter = Offset(w * 0.82, gy * 0.28);
    canvas.drawCircle(
      sunCenter,
      50,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      sunCenter,
      36,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(sunCenter, 22, Paint()..color = const Color(0xFFFDE047));

    // 3. Drifting Fluffy Clouds
    _drawFluffyCloud(canvas, w * 0.16, gy * 0.22, 16);
    _drawFluffyCloud(canvas, w * 0.50, gy * 0.35, 13);
    _drawFluffyCloud(canvas, w * 0.86, gy * 0.44, 12);

    // 4. Flying Birds Soaring Across the Sky (User Audio: "പക്ഷികൾ മേലെ പറന്നു പോവുന്നതും")
    _drawFlyingBird(canvas, w * 0.28, gy * 0.18, 13);
    _drawFlyingBird(canvas, w * 0.36, gy * 0.13, 10);
    _drawFlyingBird(canvas, w * 0.43, gy * 0.21, 9);

    // 4. Distant Mountain Silhouettes (Teal/Emerald haze)
    final mountainPath = Path();
    mountainPath.moveTo(0, gy - 16);
    mountainPath.lineTo(w * 0.22, gy - 70);
    mountainPath.lineTo(w * 0.50, gy - 38);
    mountainPath.lineTo(w * 0.76, gy - 75);
    mountainPath.lineTo(w, gy - 26);
    mountainPath.lineTo(w, h);
    mountainPath.lineTo(0, h);
    mountainPath.close();

    final mountainPaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.35);
    canvas.drawPath(mountainPath, mountainPaint);

    // 5. Rolling Green Estate Courtyard / Hills (where the house and yard sit)
    final hillPath = Path();
    hillPath.moveTo(0, gy - 16);
    hillPath.quadraticBezierTo(
      w * 0.48, gy - 26,
      w, gy - 8,
    );
    hillPath.lineTo(w, h);
    hillPath.lineTo(0, h);
    hillPath.close();

    final hillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF22C55E),
          const Color(0xFF16A34A),
          const Color(0xFF15803D),
          const Color(0xFF14532D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy - 32, w, h - gy + 32));
    canvas.drawPath(hillPath, hillPaint);

    // 6. Vibrant Grass Ridge Edge (Highlight on the crest)
    final ridgePaint = Paint()
      ..color = const Color(0xFF86EFAC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawPath(hillPath, ridgePaint);

    // 7. Cobblestone Garden Walkway from the house steps towards street
    final walkPath = Path();
    walkPath.moveTo(w * 0.44, gy + 10);
    walkPath.quadraticBezierTo(w * 0.45, gy + 70, w * 0.40, h);
    walkPath.lineTo(w * 0.58, h);
    walkPath.quadraticBezierTo(w * 0.55, gy + 70, w * 0.56, gy + 10);
    walkPath.close();

    final walkPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.35);
    canvas.drawPath(walkPath, walkPaint);

    // Stepping stones along the path
    final stonePaint = Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.4);
    for (int i = 0; i < 6; i++) {
      final stoneY = gy + 20 + (i * 24);
      final stoneX = w * 0.49 + math.sin(i * 1.5) * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(stoneX, stoneY), width: 34 - (i * 2.0), height: 10),
          const Radius.circular(5),
        ),
        stonePaint,
      );
    }

    // 8. White Picket Fences along the property line
    _drawPicketFence(canvas, w * 0.04, gy - 6, 4);
    _drawPicketFence(canvas, w * 0.78, gy + 2, 4);

    // 9. Colorful Flowerbeds (Yellow, Pink, Red blossoms)
    _drawFlowerbed(canvas, w * 0.22, gy - 2);
    _drawFlowerbed(canvas, w * 0.72, gy + 4);

    // 10. Lush Apple Trees on Left and Right flanks
    _drawTree(canvas, w * 0.08, gy - 6, scale: 1.15);
    _drawTree(canvas, w * 0.22, gy - 14, scale: 0.9);
    _drawTree(canvas, w * 0.82, gy - 4, scale: 0.95);
    _drawTree(canvas, w * 0.93, gy + 6, scale: 1.1);

    // 11. Street Lamps with Warm Golden Glowing Lanterns
    _drawStreetLamp(canvas, w * 0.04, gy + 12);
    _drawStreetLamp(canvas, w * 0.95, gy + 20);
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy, double r) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.80);
    canvas.drawCircle(Offset(cx, cy), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 0.9, cy - r * 0.35), r * 1.25, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 1.9, cy - r * 0.15), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 2.6, cy + r * 0.1), r * 0.75, cloudPaint);
  }

  void _drawFlyingBird(Canvas canvas, double x, double y, double span) {
    final birdPaint = Paint()
      ..color = const Color(0xFF0369A1).withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final birdPath = Path();
    birdPath.moveTo(x - span, y + (span * 0.28));
    birdPath.quadraticBezierTo(x - (span * 0.45), y - (span * 0.45), x, y);
    birdPath.quadraticBezierTo(x + (span * 0.45), y - (span * 0.45), x + span, y + (span * 0.28));

    canvas.drawPath(birdPath, birdPaint);
  }

  void _drawPicketFence(Canvas canvas, double startX, double groundY, int pickets) {
    final fencePaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final shadowPaint = Paint()..color = Colors.black26;

    // Cross rails
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(startX, groundY - 18, pickets * 12.0 + 4, 3), const Radius.circular(1.5)),
      fencePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(startX, groundY - 8, pickets * 12.0 + 4, 3), const Radius.circular(1.5)),
      fencePaint,
    );

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
    final colors = [const Color(0xFFEF4444), const Color(0xFFFBBF24), const Color(0xFFEC4899), const Color(0xFF38BDF8)];
    for (int i = 0; i < 5; i++) {
      final fx = x + (i * 7) - 14;
      final fy = y + math.sin(i * 1.8) * 3;
      final stemPaint = Paint()..color = const Color(0xFF15803D)..strokeWidth = 1.5;
      canvas.drawLine(Offset(fx, fy), Offset(fx, fy - 6), stemPaint);
      final petalPaint = Paint()..color = colors[i % colors.length];
      canvas.drawCircle(Offset(fx, fy - 7), 3, petalPaint);
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

  void _drawStreetLamp(Canvas canvas, double x, double y) {
    // Post
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - 46),
      Paint()..color = const Color(0xFF475569)..strokeWidth = 3.2,
    );
    // Glowing warm lantern orb
    canvas.drawCircle(
      Offset(x, y - 46),
      20,
      Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(Offset(x, y - 46), 5.5, Paint()..color = const Color(0xFFFFFC00));
  }

  @override
  bool shouldRepaint(covariant CitadelScenicLandscapePainter oldDelegate) =>
      oldDelegate.isDamaged != isDamaged || oldDelegate.groundBaseY != groundBaseY;
}


