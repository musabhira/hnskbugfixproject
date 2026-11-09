import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_attack_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

/// ⚔️ Pocket Island Attack Page
/// Full-Screen Cosmic Island Siege & Mock Attack Engine
/// Replicates the proven battle & question logic of Citadel Attack,
/// replacing the individual house at the bottom with the 3D Island Aerial View!
class PocketIslandAttackPage extends StatefulWidget {
  final PoketCountryMap island;
  final CelestialColonyInfo colony;
  final List<CitizenPlot> plots;
  final bool isMockAttack;
  final String? raidCode;

  const PocketIslandAttackPage({
    super.key,
    required this.island,
    required this.colony,
    this.plots = const [],
    this.isMockAttack = false,
    this.raidCode,
  });

  /// Static helper to launch Island Attack or Mock Attack from any page
  static void launch(
    BuildContext context, {
    required PoketCountryMap island,
    required CelestialColonyInfo colony,
    List<CitizenPlot>? plots,
    bool isMockAttack = false,
    String? raidCode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketIslandAttackPage(
          island: island,
          colony: colony,
          plots: plots ?? [],
          isMockAttack: isMockAttack,
          raidCode: raidCode,
        ),
      ),
    );
  }

  @override
  State<PocketIslandAttackPage> createState() => _PocketIslandAttackPageState();
}

class _PocketIslandAttackPageState extends State<PocketIslandAttackPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late IslandDefenseProfile _defenseProfile;
  List<HouseShieldQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _currentHp = 25;
  int _totalHp = 25;
  int _scoreEarned = 0;
  int _comboStreak = 0;
  int _consecutiveCorrect = 0;

  // Question interaction state
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;
  bool? _isLastAnswerCorrect;
  String? _feedbackText;

  // Battle Animation Controllers
  late AnimationController _laserAnimController;
  late AnimationController _shieldPulseController;
  late AnimationController _shakeAnimController;

  // Laser blast targeting
  Offset _blastTarget = const Offset(0.5, 0.5);
  bool _showBlastFx = false;

  // Active Team Raid session (if applicable)
  IslandTeamRaidSession? _raidSession;
  String? _activeRaidCode;

  @override
  void initState() {
    super.initState();
    _activeRaidCode = widget.raidCode;

    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shieldPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initIslandBattle();
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    _shieldPulseController.dispose();
    _shakeAnimController.dispose();
    super.dispose();
  }

  Future<void> _initIslandBattle() async {
    setState(() => _isLoading = true);

    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';

    // 1. Calculate Island Defense & HP Profile
    _defenseProfile =
        await PocketIslandAttackService.instance.calculateIslandDefense(
      island: widget.island,
      colony: widget.colony,
      plots: widget.plots,
      currentUserId: currentUserId,
    );

    _totalHp = math.max(5, _defenseProfile.totalHp);
    _currentHp = _totalHp;

    // 2. Check 10-Hour Shield (Real attacks blocked if protected)
    if (!widget.isMockAttack && _defenseProfile.isUnderShield) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showShieldBlockedDialog(_defenseProfile.shieldMinutesRemaining);
      }
      return;
    }

    // 3. Team Raid Session Setup (if code passed or requested)
    if (_activeRaidCode != null && _activeRaidCode!.isNotEmpty) {
      final user = SupaFlow.client.auth.currentUser;
      _raidSession =
          await PocketIslandAttackService.instance.joinTeamRaidSession(
        raidCode: _activeRaidCode!,
        userId: user?.id ?? 'guest_raider',
        userName: user?.email?.split('@').first ?? 'Raider',
      );
      if (_raidSession != null) {
        _totalHp = _raidSession!.totalHp;
        _currentHp = _raidSession!.currentHp;
      }
    }

    // 4. Generate sequenced questions from island residents
    _questions =
        await PocketIslandAttackService.instance.generateQuestionsForIsland(
      residents: _defenseProfile.residents,
      targetTotalQuestions: _totalHp,
    );

    // 5. Broadcast Emergency Siren to resident chat if real attack
    if (!widget.isMockAttack) {
      final myName = SupaFlow.client.auth.currentUser?.email?.split('@').first ??
          'Enemy Raider';
      unawaited(
        PocketIslandAttackService.instance.broadcastIslandSirenAlert(
          islandId: widget.island.id.toString(),
          islandName: widget.island.name,
          planetCode: widget.colony.code,
          attackerName: myName,
          remainingHp: _currentHp,
          totalHp: _totalHp,
          isConquered: false,
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showShieldBlockedDialog(int minutesRemaining) {
    final hours = (minutesRemaining / 60.0).toStringAsFixed(1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Text(
              'ARMY SHIELD ACTIVE',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'This Island is under an impenetrable 10-Hour Army Defense Shield ($hours hrs left) following a previous conquest.\n\nAll enemy raids are blocked until the shield expires!',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Return to Cosmos',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COMBAT & QUESTION ANSWER HANDLING
  // ---------------------------------------------------------------------------

  void _handleOptionSelected(int index) {
    if (_isAnswerSubmitted || _isLoading || _questions.isEmpty) return;

    final q = _questions[_currentQuestionIndex];
    final bool isCorrect = (index == q.correctIndex);

    HapticFeedback.heavyImpact();

    setState(() {
      _selectedOptionIndex = index;
      _isAnswerSubmitted = true;
      _isLastAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _handleCorrectAnswer() {
    _consecutiveCorrect++;
    _comboStreak++;
    final damageDealt = 1;
    final int bountyPerHit = widget.isMockAttack ? 5 : 10;
    _scoreEarned += bountyPerHit * (_comboStreak > 2 ? 2 : 1);

    // Fire laser artillery barrage down into island
    final random = math.Random();
    _blastTarget = Offset(0.3 + (random.nextDouble() * 0.4),
        0.3 + (random.nextDouble() * 0.4));
    _showBlastFx = true;

    _laserAnimController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _showBlastFx = false);
      }
    });

    setState(() {
      _currentHp = math.max(0, _currentHp - damageDealt);
      _feedbackText = '💥 DIRECT HIT! Defense Line Breached!';
    });

    // Check victory
    if (_currentHp <= 0) {
      Future.delayed(const Duration(milliseconds: 700), _handleIslandVictory);
    } else {
      Future.delayed(const Duration(milliseconds: 1000), _advanceNextQuestion);
    }
  }

  void _handleIncorrectAnswer() {
    _comboStreak = 0;
    _shakeAnimController.forward(from: 0.0);
    HapticFeedback.vibrate();

    setState(() {
      _feedbackText = '⚡ DEFENSE SHIELD DEFLECTED! Counter-battery fired!';
    });

    Future.delayed(const Duration(milliseconds: 1200), _advanceNextQuestion);
  }

  void _advanceNextQuestion() {
    if (!mounted) return;
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerSubmitted = false;
        _isLastAnswerCorrect = null;
        _feedbackText = null;
      });
    } else {
      // Loop or conclude if out of questions
      if (_currentHp <= 0) {
        _handleIslandVictory();
      } else {
        setState(() {
          _currentQuestionIndex = 0; // restart loop
          _selectedOptionIndex = null;
          _isAnswerSubmitted = false;
          _isLastAnswerCorrect = null;
          _feedbackText = null;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // VICTORY CONQUEST & REWARD CEREMONY
  // ---------------------------------------------------------------------------

  Future<void> _handleIslandVictory() async {
    HapticFeedback.vibrate();

    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? 'guest_raider';
    final currentUserName =
        SupaFlow.client.auth.currentUser?.email?.split('@').first ?? 'Raider';

    if (widget.isMockAttack) {
      // Mock attack victory: zero damage, bonus practice score
      final totalBonus = 50 + _scoreEarned;
      await PocketFortressDefenseService.recordTrainingPoints(totalBonus);
      if (mounted) {
        _showVictoryDialog(
          title: 'SPARRING COMPLETE! 🛡️',
          subtitle:
              'Great practice session with your island defense squad! You answered all questions with zero damage to your home island.',
          scoreAwarded: totalBonus,
          isMock: true,
        );
      }
      return;
    }

    // Real attack victory: Conquered!
    final int finalBounty = math.max(_defenseProfile.bountyPool, _scoreEarned);
    await PocketFortressDefenseService.recordTrainingPoints(finalBounty);

    // Deploy 10-Hour Army Protection Shield
    await PocketIslandAttackService.instance
        .deployArmyShield(widget.island.id.toString());

    // Broadcast emergency defeat siren alert to island group
    await PocketIslandAttackService.instance.broadcastIslandSirenAlert(
      islandId: widget.island.id.toString(),
      islandName: widget.island.name,
      planetCode: widget.colony.code,
      attackerName: currentUserName,
      remainingHp: 0,
      totalHp: _totalHp,
      isConquered: true,
    );

    // Record War Log for Army Desk
    final logEntry = IslandWarLogEntry(
      id: 'war_${DateTime.now().millisecondsSinceEpoch}',
      attackerId: currentUserId,
      attackerName: currentUserName,
      attackerAvatar: '⚔️',
      targetIslandId: widget.island.id.toString(),
      targetIslandName: widget.island.name,
      targetPlanetCode: widget.colony.code,
      attackerPlanetCode: 'EP',
      totalHp: _totalHp,
      damageDealt: _totalHp,
      wasConquered: true,
      scoreLooted: finalBounty,
      timestamp: DateTime.now(),
      isMockAttack: false,
      isTeamRaid: _raidSession != null,
      teamParticipantsCount: _raidSession?.participantDamage.length ?? 1,
    );
    await PocketIslandAttackService.instance.recordWarLog(logEntry);

    if (mounted) {
      _showVictoryDialog(
        title: '💥 ISLAND CONQUERED!',
        subtitle:
            'All ${widget.island.name} defenses have fallen! A 10-Hour Army Defense Shield has been deployed. Pocket Score bounty looted!',
        scoreAwarded: finalBounty,
        isMock: false,
      );
    }
  }

  void _showVictoryDialog({
    required String title,
    required String subtitle,
    required int scoreAwarded,
    required bool isMock,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isMock ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            width: 2,
          ),
        ),
        title: Column(
          children: [
            Text(isMock ? '🛡️' : '🏆', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMock
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    '+$scoreAwarded POCKET SCORE',
                    style: GoogleFonts.outfit(
                      color: isMock
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFBBF24),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMock) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: Color(0xFF38BDF8), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '10-Hour Army Defense Shield Active',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isMock ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'CONTINUE TO COSMOS 🪐',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN SCAFFOLD & UI BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPad = media.padding.top;
    final bottomPad = media.padding.bottom;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF030712),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF38BDF8)),
              const SizedBox(height: 16),
              Text(
                'Locking onto Island Orbital Defenses...',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final double hpPercent = (_totalHp > 0) ? (_currentHp / _totalHp).clamp(0.0, 1.0) : 0.0;
    final currentQ = _questions.isNotEmpty
        ? _questions[_currentQuestionIndex.clamp(0, _questions.length - 1)]
        : null;

    // Defending plot citizen attribution
    CitizenPlot? defendingCitizen;
    if (_defenseProfile.residents.isNotEmpty) {
      final residentIdx = _currentQuestionIndex % _defenseProfile.residents.length;
      defendingCitizen = _defenseProfile.residents[residentIdx];
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 1. 🌌 Deep Cosmos Space Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.4,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF030712),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),

          // 2. 🏝️ BOTTOM BATTLEFIELD: THE LIVING ISLAND AERIAL VIEW CANVAS!
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: media.size.height * 0.48,
            child: ClipRect(
              child: Stack(
                children: [
                  // Island Aerial View
                  Positioned.fill(
                    child: IslandAerialViewWidget(
                      island: widget.island,
                      isInteractive: false,
                      zoomScale: 1.35,
                      plots: widget.plots,
                      planetName: widget.colony.planetName,
                    ),
                  ),

                  // Atmospheric Fog / Darkening Tint
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF030712).withValues(alpha: 0.95),
                            const Color(0xFF030712).withValues(alpha: 0.40),
                            Colors.transparent,
                            const Color(0xFF030712).withValues(alpha: 0.85),
                          ],
                          stops: const [0.0, 0.25, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 🛡️ Pulsing Defense Energy Dome
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shieldPulseController,
                      builder: (context, child) {
                        final pulseAlpha =
                            0.15 + (_shieldPulseController.value * 0.20);
                        final shieldColor = widget.isMockAttack
                            ? const Color(0xFF10B981)
                            : (hpPercent > 0.3
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFFEF4444));
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: shieldColor.withValues(alpha: pulseAlpha),
                              width: 3,
                            ),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.85,
                              colors: [
                                Colors.transparent,
                                shieldColor.withValues(alpha: pulseAlpha * 0.3),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ⚡ Laser Artillery Blast Strike Effect
                  if (_showBlastFx)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _laserAnimController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _LaserBlastPainter(
                              progress: _laserAnimController.value,
                              target: _blastTarget,
                              isMock: widget.isMockAttack,
                            ),
                          );
                        },
                      ),
                    ),

                  // Bottom Island Label Overlay
                  Positioned(
                    left: 16,
                    bottom: bottomPad + 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.island.islandEmoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.island.name} Aerial Defense Grid',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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

          // 3. 🛡️ TOP HEADER: ISLAND HP BAR & MODE CAPSULE
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Nav Bar Row
                Row(
                  children: [
                    // Back Button
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Island & Planet Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.island.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.colony.planetName} • Wave ${widget.island.wave}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mode Badge (Mock vs Raid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isMockAttack
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isMockAttack
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF87171),
                        ),
                      ),
                      child: Text(
                        widget.isMockAttack ? 'MOCK ATTACK 🛡️' : 'ISLAND RAID ⚔️',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Island Total Defense HP Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isMockAttack
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : const Color(0xFFEF4444).withValues(alpha: 0.4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.isMockAttack ? '🛡️' : '🏰',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ISLAND DEFENSE HP',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_currentHp / $_totalHp HP (${(hpPercent * 100).toInt()}%)',
                            style: GoogleFonts.outfit(
                              color: hpPercent > 0.4
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFF87171),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: hpPercent,
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isMockAttack
                                ? const Color(0xFF10B981)
                                : (hpPercent > 0.4
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFFDC2626)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Stats Row: Question Count & Bounty
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 10.5,
                            ),
                          ),
                          Row(
                            children: [
                              const Text('🪙 ',
                                  style: TextStyle(fontSize: 11)),
                              Text(
                                'Bounty: ${_defenseProfile.bountyPool} PS',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFBBF24),
                                  fontSize: 11,
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

          // 4. 📝 MIDDLE CARD: CURRENT QUESTION & DEFENDING CITIZEN
          Positioned(
            top: topPad + 165,
            left: 16,
            right: 16,
            bottom: media.size.height * 0.46,
            child: currentQ != null
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Defending Citizen Badge
                        if (defendingCitizen != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B)
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  defendingCitizen.userAvatar.isNotEmpty
                                      ? defendingCitizen.userAvatar
                                      : '👤',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Defending Plot #${defendingCitizen.plotNumber} • ${defendingCitizen.userName} (Day ${defendingCitizen.day})',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Question Prompt Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentQ.question,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                              if (_feedbackText != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _feedbackText!,
                                  style: GoogleFonts.outfit(
                                    color: (_isLastAnswerCorrect == true)
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFFF87171),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Options List
                        ...List.generate(currentQ.options.length, (optIdx) {
                          final optText = currentQ.options[optIdx];
                          Color btnBg =
                              const Color(0xFF1E293B).withValues(alpha: 0.85);
                          Color borderCol =
                              Colors.white.withValues(alpha: 0.10);
                          Color textCol = Colors.white;

                          if (_isAnswerSubmitted) {
                            if (optIdx == currentQ.correctIndex) {
                              btnBg = const Color(0xFF065F46);
                              borderCol = const Color(0xFF34D399);
                              textCol = Colors.white;
                            } else if (optIdx == _selectedOptionIndex) {
                              btnBg = const Color(0xFF991B1B);
                              borderCol = const Color(0xFFF87171);
                              textCol = Colors.white;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _handleOptionSelected(optIdx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: btnBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderCol, width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        String.fromCharCode(65 + optIdx),
                                        style: GoogleFonts.outfit(
                                          color: textCol,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        optText,
                                        style: GoogleFonts.inter(
                                          color: textCol,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Laser Artillery Strike Painter
class _LaserBlastPainter extends CustomPainter {
  final double progress;
  final Offset target;
  final bool isMock;

  _LaserBlastPainter({
    required this.progress,
    required this.target,
    required this.isMock,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final targetPoint = Offset(
      size.width * target.dx,
      size.height * target.dy,
    );
    final originPoint = Offset(targetPoint.dx, 0);

    // Laser Beam
    final laserPaint = Paint()
      ..color = isMock
          ? const Color(0xFF34D399).withValues(alpha: (1.0 - progress))
          : const Color(0xFF38BDF8).withValues(alpha: (1.0 - progress))
      ..strokeWidth = 4.0 * (1.0 - progress)
      ..style = PaintingStyle.stroke;

    canvas.drawLine(originPoint, targetPoint, laserPaint);

    // Impact Blast Ring
    final blastRadius = progress * 60.0;
    final blastPaint = Paint()
      ..color = isMock
          ? const Color(0xFF10B981).withValues(alpha: (1.0 - progress) * 0.8)
          : const Color(0xFFEF4444).withValues(alpha: (1.0 - progress) * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1.0 - progress);

    canvas.drawCircle(targetPoint, blastRadius, blastPaint);
  }

  @override
  bool shouldRepaint(covariant _LaserBlastPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

