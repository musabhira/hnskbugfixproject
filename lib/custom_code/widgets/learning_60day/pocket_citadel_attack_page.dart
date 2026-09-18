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
  late int _defenderHp;
  late bool _isDefenderDamaged;
  List<HouseShieldQuestion> _defenseQuestions = [];
  int _currentQIdx = 0;
  Map<String, dynamic>? _breachResult;
  Map<String, dynamic>? _pointsResult;

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

  // 🔍 Interactive Estate Zoom & Pan Controls
  late TransformationController _zoomController;
  double _currentZoom = 1.0;
  int _defenderScore = 0;

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
    _zoomController = TransformationController();

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
    _zoomController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _beamController.dispose();
    _particleController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final newZoom = (_currentZoom + 0.25).clamp(0.6, 2.5);
    setState(() {
      _currentZoom = newZoom;
      _zoomController.value = Matrix4.diagonal3Values(newZoom, newZoom, 1.0);
    });
    HapticFeedback.selectionClick();
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 0.25).clamp(0.6, 2.5);
    setState(() {
      _currentZoom = newZoom;
      _zoomController.value = Matrix4.diagonal3Values(newZoom, newZoom, 1.0);
    });
    HapticFeedback.selectionClick();
  }

  void _resetZoom() {
    setState(() {
      _currentZoom = 1.0;
      _zoomController.value = Matrix4.identity();
    });
    HapticFeedback.selectionClick();
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

    final pRes = await PocketFortressDefenseService.awardPoints(looted > 0 ? looted : 15);

    await Future.delayed(const Duration(milliseconds: 450));

    if (mounted) {
      _coinController.forward(from: 0.0);
      setState(() {
        _isStriking = false;
        _defenderHp = math.max(0, _defenderHp - 60);
        _defenderScore = math.max(0, _defenderScore - (looted > 0 ? looted : 15));
        _isDefenderDamaged = true;
        _breachResult = result;
        _pointsResult = pRes;
        _raidStep = 3; // Victory!
      });
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
    final cannotAttack = _inCooldown || _isTargetProtected || _isDailyLimitReached;
    final currentQ = _defenseQuestions.isNotEmpty
        ? _defenseQuestions[_currentQIdx % _defenseQuestions.length]
        : null;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: SafeArea(
          child: Column(
            children: [
              // --- TOP BATTLE ARENA BAR ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context, _raidStep == 3),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: VectorAvatarWidget(
                        config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                        size: 44,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.neighbor.name,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.neighbor.hasActiveShield
                                      ? const Color(0xFF065F46).withValues(alpha: 0.6)
                                      : const Color(0xFF7F1D1D).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: widget.neighbor.hasActiveShield
                                        ? const Color(0xFF10B981)
                                        : Colors.redAccent,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  widget.neighbor.hasActiveShield ? '🛡️ Shielded' : '⚠️ Unshielded',
                                  style: TextStyle(
                                    color: widget.neighbor.hasActiveShield
                                        ? const Color(0xFF34D399)
                                        : Colors.redAccent,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Level ${widget.neighbor.day} Citadel • 🔥 ${widget.neighbor.streak} Streak • ${widget.neighbor.rank}',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 👤 View Profile Button (Audio Directive)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.22),
                        foregroundColor: const Color(0xFF38BDF8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFF38BDF8), width: 0.9),
                        ),
                      ),
                      onPressed: _openDefenderProfile,
                      icon: const Icon(Icons.person_rounded, size: 14),
                      label: Text(
                        'View Profile',
                        style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isDailyLimitReached
                            ? Colors.red.withValues(alpha: 0.2)
                            : const Color(0xFF0284C7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDailyLimitReached ? Colors.redAccent : const Color(0xFF38BDF8),
                        ),
                      ),
                      child: Text(
                        '⚔️ $_attacksUsed / ${PocketFortressDefenseService.kDailyMaxAttacks}',
                        style: TextStyle(
                          color: _isDailyLimitReached ? Colors.redAccent : const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- CITADEL HP PROGRESS BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isDefenderDamaged
                              ? '💥 Breached Citadel Defense'
                              : '🏰 Citadel Fortification HP',
                          style: GoogleFonts.outfit(
                            color: _isDefenderDamaged ? const Color(0xFFF87171) : Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$_defenderHp / ${widget.neighbor.maxHp} HP',
                          style: GoogleFonts.outfit(
                            color: _defenderHp <= 40 ? Colors.redAccent : const Color(0xFF10B981),
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_defenderHp / widget.neighbor.maxHp).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _defenderHp <= 40
                              ? const Color(0xFFDC2626)
                              : (_defenderHp <= 70 ? Colors.amber : const Color(0xFF10B981)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // --- 🏡 2D OPEN WORLD HILL CLIMB SCENIC BATTLEGROUND ---
              // Audio Directive: Blue sky, rolling green hills, trees, street lamps, and house in center.
              // Strictly NO car controls (GAS/GO, JUMP, BRAKE/REV). Includes Zoom in/out controls.
              Expanded(
                flex: 5,
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final v = _shakeController.value;
                    final decay = 1.0 - v;
                    final dx = math.sin(v * math.pi * 18) * decay * 14.0;
                    final dy = math.cos(v * math.pi * 14) * decay * 10.0;
                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isDefenderDamaged
                            ? Colors.redAccent.withValues(alpha: 0.8)
                            : const Color(0xFF38BDF8).withValues(alpha: 0.5),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isDefenderDamaged
                              ? Colors.redAccent.withValues(alpha: 0.25)
                              : Colors.black45,
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // 1. 2D Open World Scenery: Sky, Radiant Sun, Clouds, Rolling Green Hills & Trees
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CitadelScenicLandscapePainter(
                                isDamaged: _isDefenderDamaged,
                              ),
                            ),
                          ),

                          // 2. Interactive Pinch & Drag Zoom Viewport for House Inspection
                          Positioned.fill(
                            child: InteractiveViewer(
                              transformationController: _zoomController,
                              minScale: 0.6,
                              maxScale: 2.5,
                              boundaryMargin: const EdgeInsets.all(120),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // The 2D Flame English House placed on the hillside
                                  Positioned(
                                    bottom: 12,
                                    child: SizedBox(
                                      width: 400,
                                      height: 380,
                                      child: FlameEnglishHouseWidget(
                                        currentDay: widget.neighbor.day,
                                        streak: widget.neighbor.streak,
                                        isDamaged: _isDefenderDamaged,
                                        houseId: widget.neighbor.id,
                                        paletteId: widget.neighbor.paletteId,
                                      ),
                                    ),
                                  ),

                                  // 🏷️ Prominent Defender Identity & Pocket Score Badges (Matching Screenshot)
                                  Positioned(
                                    top: 10,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 👑 Yellow Banner: DEFENDER CITADEL
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFC00),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '👑 DEFENDER CITADEL • ${widget.neighbor.name.toUpperCase()}',
                                            style: GoogleFonts.outfit(
                                              color: Colors.black,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        // 🪙 Pocket Score (PS) Badge: Highlighted above the House
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🪙', style: TextStyle(fontSize: 13)),
                                              const SizedBox(width: 5),
                                              Text(
                                                'PS ${_defenderScore > 0 ? _defenderScore : PocketScoreLevelEngine.getRequiredScoreForLevel(widget.neighbor.day)} PTS',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(0xFFFFD700),
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Defender Avatar Bubble with Halo
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: widget.neighbor.hasActiveShield
                                                  ? const Color(0xFF00F0FF)
                                                  : const Color(0xFFFFD700),
                                              width: 2.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (widget.neighbor.hasActiveShield
                                                        ? const Color(0xFF00F0FF)
                                                        : const Color(0xFFFFD700))
                                                    .withValues(alpha: 0.45),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: VectorAvatarWidget(
                                              config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                                              size: 44,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 🏡 Roadside Street Signpost Plaque (matching screenshot)
                                  Positioned(
                                    bottom: 24,
                                    right: 24,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFFFFC00), width: 1.2),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '🏡 Street ${widget.neighbor.day}',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFFFC00),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            widget.neighbor.name,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 10.5,
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

                          // 3. Floating Zoom Controls (+, -, Reset) on Top-Right Corner
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: _zoomIn,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const Divider(color: Colors.white24, height: 4),
                                  InkWell(
                                    onTap: _zoomOut,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(Icons.remove_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const Divider(color: Colors.white24, height: 4),
                                  InkWell(
                                    onTap: _resetZoom,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      child: Text(
                                        '${(_currentZoom * 100).toInt()}%',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFFFD700),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 4. High-powered laser cannon & explosive particle strike layer
                          AnimatedBuilder(
                            animation: Listenable.merge([_beamController, _particleController]),
                            builder: (context, _) {
                              return Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelLaserStrikePainter(
                                      beamProg: _beamController.value,
                                      particleProg: _particleController.value,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // 5. Victory Coin Shower Layer
                          AnimatedBuilder(
                            animation: _coinController,
                            builder: (context, _) {
                              if (_coinController.value <= 0.0 || _coinController.value >= 1.0) {
                                return const SizedBox.shrink();
                              }
                              return Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: CitadelCoinShowerPainter(
                                      progress: _coinController.value,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // 6. Attacker weapon discharge banner
                          if (_isStriking)
                            Positioned(
                              top: 14,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('⚡', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${VectorAvatarConfig.getAvatarPerkForDay(widget.attackerDay).combatWeaponName.toUpperCase()} FIRED!',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFFFD700),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5,
                                          letterSpacing: 0.6,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // 7. Attack strike visual impact overlay
                          if (_isStriking)
                            Positioned.fill(
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
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- ⚔️ INTERACTIVE RAID FLOW PANEL ---
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- STEP 0: INITIAL CHALLENGE PROMPT ---
                        if (_raidStep == 0) ...[
                          if (_isTargetProtected)
                            _buildNoticeCard(
                              '👮‍♂️ 26-Hour Presidential Police Protection Active!\nGuards stationed to allow resident recovery (${_protectionHoursLeft.toStringAsFixed(1)}h remaining). Attacks blocked.',
                            )
                          else if (_inCooldown)
                            _buildNoticeCard(
                              '⏳ Citadel Security Alert Active!\nThis citadel is on high alert after recent combat. Re-attack available in ${_cooldownHoursLeft.toStringAsFixed(1)} hours.',
                            )
                          else if (_isDailyLimitReached)
                            _buildNoticeCard('🔒 Daily limit reached! You have used 2/2 attacks today.')
                          else
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  const Text('⚔️', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Home Defense Challenge',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Crack ${widget.neighbor.name}\'s Home Defense question to breach the front gate, loot +15 Pocket Score (PS) points & level up!',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
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
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cannotAttack ? Colors.white12 : const Color(0xFFDC2626),
                                foregroundColor: cannotAttack ? Colors.white38 : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: cannotAttack ? 0 : 8,
                              ),
                              onPressed: cannotAttack
                                  ? null
                                  : () {
                                      if (widget.attackerDay < 4) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('🔒 Citadel attack warfare unlocks at Level 4!'),
                                            backgroundColor: Color(0xFFDC2626),
                                          ),
                                        );
                                        return;
                                      }
                                      HapticFeedback.heavyImpact();
                                      setState(() {
                                        _raidStep = 1; // Move to defense question
                                        _selectedOption = -1;
                                      });
                                      _startCombatTimer();
                                    },
                              icon: const Icon(Icons.flash_on_rounded, size: 20),
                              label: Text(
                                cannotAttack
                                    ? (_isDailyLimitReached
                                        ? 'DAILY LIMIT REACHED 🔒'
                                        : (_inCooldown ? 'CITADEL IN COOLDOWN ⏳' : 'ATTACK LOCKED 🔒'))
                                    : 'ATTACK CITADEL ⚔️',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP 1: DEFENSE QUESTION ---
                        // Audio: "അറ്റാക്ക് കൊടുക്കുന്ന സമയത്ത് ഡിഫൻസ് വരും. ഡിഫൻസ് അവര് ഉണ്ടാക്കിയ ക്വസ്റ്റ്യൻസ് വരും."
                        else if (_raidStep == 1 && currentQ != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _secondsLeft <= 5
                                    ? Colors.redAccent
                                    : const Color(0xFF38BDF8).withValues(alpha: 0.6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    // ❤️ Second Chance Lifeline Indicator
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
                                    const SizedBox(width: 8),
                                    // ⏱️ 25s Blitz Countdown Combat Timer Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _secondsLeft <= 5
                                            ? Colors.red.withValues(alpha: 0.3)
                                            : const Color(0xFFFFD700).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _secondsLeft <= 5
                                              ? Colors.redAccent
                                              : const Color(0xFFFFD700),
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
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentQ.question,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
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
                                            : const Color(0xFF0F172A),
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
                                                  color: isSelected ? Colors.black : Colors.white70,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              currentQ.options[optIdx],
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.white70,
                                                fontSize: 12.5,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 18),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                          // Intermediate Gate cleared! Move to next gate
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
                                          // All Gates Breached -> Ready to strike!
                                          setState(() => _raidStep = 2);
                                        }
                                      } else {
                                        // Mistake made: Check if 1 second chance remains
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
                                          // Trap triggered & exhausted retries -> Defense held!
                                          // Audio Directive: 6-hour failed attack cooldown enforced
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
                                    ? 'PASS GATE ${_currentQIdx + 1} ✓'
                                    : 'BREACH FINAL GATE ✓',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP 2: GATE BREACHED -> "ATTACK" BUTTON ENABLED ---
                        // Audio: "അത് കറക്റ്റ് കൊടുത്ത് ടിക്ക് ഒക്കെ കൊടുത്തു കഴിഞ്ഞുകഴിഞ്ഞാൽ ഇവർക്ക് 'അറ്റാക്ക്' എന്നൊരു ബട്ടൺ കൊടുക്കും.
                        // അറ്റാക്ക് എന്ന് പറയുമ്പോൾ ഇവര് അറ്റാക്ക് ചെയ്യുന്നു."
                        else if (_raidStep == 2 && currentQ != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🎯', style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'DEFENSE CODE CRACKED! GATE BREACHED!',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF34D399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '✓ Answer Correct: ${currentQ.options[currentQ.correctIndex]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (currentQ.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    currentQ.explanation,
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Big Glowing Pulsing ATTACK Button
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 10,
                                  shadowColor: Colors.redAccent.withValues(alpha: 0.6),
                                ),
                                onPressed: _isStriking ? null : _executeCitadelAttack,
                                icon: _isStriking
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.flash_on_rounded, size: 24),
                                label: Text(
                                  _isStriking ? 'STRIKING CITADEL...' : 'LAUNCH CITADEL ATTACK NOW! 💥⚔️',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.5,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP 3: ATTACK RESULT / VICTORY ---
                        else if (_raidStep == 3) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 28)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CITADEL BREACHED & LOOTED!',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF34D399),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            'Target: ${widget.neighbor.name} (Level ${widget.neighbor.day})',
                                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '💥 ${_breachResult?['damageDealt'] ?? 60} HP Damage Dealt to Citadel',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _breachResult?['ironDomeBlocked'] == true
                                      ? '🛡️ Iron Dome Absorbed Breach (0 PS Looted)'
                                      : '🪙 +${_breachResult?['lootedCoins'] ?? 15} PS Points Looted from Vault!',
                                  style: TextStyle(
                                    color: _breachResult?['ironDomeBlocked'] == true
                                        ? Colors.amber
                                        : const Color(0xFF34D399),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                if (_breachResult?['isLevelDowngraded'] == true) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.redAccent),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('📉', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'CITADEL DEMOTED! Defender lost critical Pocket Score and dropped from Level ${_breachResult?['previousLevel']} to Level ${_breachResult?['newLevel']}!',
                                            style: const TextStyle(
                                              color: Color(0xFFF87171),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFF59E0B)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Text('🌟', style: TextStyle(fontSize: 16)),
                                      SizedBox(width: 8),
                                      Text(
                                        '+15 PS POINTS EARNED & ADDED TO POCKET SCORE! (200 pts/level)',
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_pointsResult != null && _pointsResult!['didLevelUp'] == true) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF38BDF8)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('🎉', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'LEVEL UP! Promoted to Level ${_pointsResult?['newDay']}!',
                                          style: const TextStyle(
                                            color: Color(0xFF38BDF8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Text('👮‍♂️', style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '26h Presidential Police Guard Dispatched: Target is under protective peace treaty for 26 hours while recovering.',
                                          style: TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
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
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                'CLAIM REWARDS & RETURN 🏆',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP -1: TRAP TRIGGERED / ATTACK FAILED ---
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
                                      ? 'You switched apps or minimized during combat! AI assistance / Cheating is strictly prohibited during Citadel Raids.'
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
                                    '6-Hour Citadel Lockdown Enforced!\nYou exhausted your second chance on this defense. Security has tightened. Return after 6 hours to attack again.',
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
                                Navigator.pop(context, false);
                              },
                              child: const Text('ACKNOWLEDGE & RETREAT 🛡️', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
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

  Widget _buildNoticeCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
            ),
          ),
        ],
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

  CitadelScenicLandscapePainter({
    this.isDamaged = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sky Gradient (Vibrant blue matching user screenshot)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Radiant Golden Sun with glowing aura rings
    final sunCenter = Offset(w * 0.82, h * 0.16);
    canvas.drawCircle(
      sunCenter,
      52,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      sunCenter,
      38,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(sunCenter, 24, Paint()..color = const Color(0xFFFDE047));

    // 3. Drifting Fluffy Clouds
    _drawFluffyCloud(canvas, w * 0.16, h * 0.14, 16);
    _drawFluffyCloud(canvas, w * 0.50, h * 0.22, 13);
    _drawFluffyCloud(canvas, w * 0.88, h * 0.26, 12);

    // 4. Distant Mountain Silhouettes (Teal/Emerald haze)
    final mountainPath = Path();
    mountainPath.moveTo(0, h * 0.65);
    mountainPath.lineTo(w * 0.22, h * 0.55);
    mountainPath.lineTo(w * 0.52, h * 0.61);
    mountainPath.lineTo(w * 0.78, h * 0.53);
    mountainPath.lineTo(w, h * 0.59);
    mountainPath.lineTo(w, h);
    mountainPath.lineTo(0, h);
    mountainPath.close();

    final mountainPaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.38);
    canvas.drawPath(mountainPath, mountainPaint);

    // 5. Rolling Green Hills (The ground slope where house rests)
    final groundBaseY = h * 0.72;
    final hillPath = Path();
    hillPath.moveTo(0, groundBaseY - 26);
    hillPath.quadraticBezierTo(
      w * 0.46, groundBaseY - 42,
      w, groundBaseY - 14,
    );
    hillPath.lineTo(w, h);
    hillPath.lineTo(0, h);
    hillPath.close();

    final hillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF15803D), Color(0xFF166534), Color(0xFF14532D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, groundBaseY - 45, w, h - groundBaseY + 45));
    canvas.drawPath(hillPath, hillPaint);

    // 6. Vibrant Grass Ridge Edge
    final ridgePaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawPath(hillPath, ridgePaint);

    // Subtle golden road line along hill
    final roadLinePaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;
    canvas.drawPath(hillPath, roadLinePaint);

    // 7. Trees with Foliage & Little Red Apples (from screenshot)
    _drawTree(canvas, w * 0.12, groundBaseY - 24);
    _drawTree(canvas, w * 0.88, groundBaseY - 12);

    // 8. Street Lamps with Warm Golden Glowing Lanterns
    _drawStreetLamp(canvas, w * 0.05, groundBaseY - 28);
    _drawStreetLamp(canvas, w * 0.95, groundBaseY - 10);
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy, double r) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.80);
    canvas.drawCircle(Offset(cx, cy), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 0.9, cy - r * 0.35), r * 1.25, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 1.9, cy - r * 0.15), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 2.6, cy + r * 0.1), r * 0.75, cloudPaint);
  }

  void _drawTree(Canvas canvas, double x, double y) {
    // Tree Trunk
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - 28),
      Paint()..color = const Color(0xFF78350F)..strokeWidth = 5.0,
    );
    // Overlapping lush foliage balls
    final leafPaint1 = Paint()..color = const Color(0xFF15803D);
    final leafPaint2 = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(Offset(x, y - 38), 16, leafPaint1);
    canvas.drawCircle(Offset(x - 8, y - 32), 12, leafPaint2);
    canvas.drawCircle(Offset(x + 8, y - 32), 12, leafPaint2);
    canvas.drawCircle(Offset(x, y - 44), 11, leafPaint2);

    // Little red apples on branches
    final applePaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(x - 4, y - 36), 2.2, applePaint);
    canvas.drawCircle(Offset(x + 5, y - 40), 2.2, applePaint);
    canvas.drawCircle(Offset(x + 3, y - 30), 2.2, applePaint);
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
      oldDelegate.isDamaged != isDamaged;
}


