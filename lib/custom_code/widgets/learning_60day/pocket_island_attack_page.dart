import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_attack_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_group_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_citadel_runner_attack_page.dart';

/// ⚔️ Pocket Island Attack Page
/// Full-Screen Cosmic Island Siege & Mock Attack Engine.
/// Replicates the proven Subway-Surfers style 2D runner attack game from Citadel Attack,
/// where the character runs, jumps over obstacles, reaches gates, and breaks defenses!
/// Defense gates are calculated dynamically from the 25 residents' completed levels,
/// and full Army Defense Skills are displayed for all 25 plots!
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
  int _totalGates = 25;

  // Battle Animation Controllers
  late AnimationController _shieldPulseController;
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();

    _shieldPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _initIslandBattle();
  }

  @override
  void dispose() {
    _shieldPulseController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _initIslandBattle() async {
    setState(() => _isLoading = true);

    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';

    // 1. Calculate Island Defense Profile
    _defenseProfile =
        await PocketIslandAttackService.instance.calculateIslandDefense(
      island: widget.island,
      colony: widget.colony,
      plots: widget.plots,
      currentUserId: currentUserId,
    );

    // 2. Compute Total Defense Gates:
    // If 25 residents completed 1 day each -> exactly 25 gates!
    // Clamped between 5 (minimum) and 25 (maximum capacity of an island).
    int sumDays = 0;
    if (_defenseProfile.residents.isNotEmpty) {
      for (final r in _defenseProfile.residents) {
        sumDays += math.max(1, r.day);
      }
      _totalGates = math.max(5, math.min(25, sumDays));
    } else {
      _totalGates = 25;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // 🏃 2D RUNNER ISLAND ATTACK LAUNCHER
  // ---------------------------------------------------------------------------

  Future<void> _launchRunnerAttack() async {
    HapticFeedback.heavyImpact();

    // 1. Check 10-Hour Shield (Real attacks blocked if protected)
    if (!widget.isMockAttack && _defenseProfile.isUnderShield) {
      _showShieldBlockedDialog(_defenseProfile.shieldMinutesRemaining);
      return;
    }

    // 2. Broadcast Emergency Siren to resident chat if real attack
    if (!widget.isMockAttack) {
      final myName =
          SupaFlow.client.auth.currentUser?.email?.split('@').first ??
              'Enemy Raider';
      unawaited(
        PocketIslandAttackService.instance.broadcastIslandSirenAlert(
          islandId: widget.island.id.toString(),
          islandName: widget.island.name,
          planetCode: widget.colony.code,
          attackerName: myName,
          remainingHp: _totalGates,
          totalHp: _totalGates,
          isConquered: false,
        ),
      );
    }

    // 3. 🏃 Launch Subway-Surfers Style 2D Runner Island Attack Game!
    // Duplicating the exact battle flow of Citadel Attack with running, jumping, and opening gates!
    final result = await PocketCitadelRunnerAttackPage.open(
      context,
      defenderName: widget.isMockAttack
          ? '${widget.island.name} (Trial Mock Defense)'
          : '${widget.island.name} ($_totalGates-Gate Army Defense)',
      defenderLevel: _totalGates,
      defenderId: widget.island.id.toString(),
      isKidMode: false,
      isEscort: false,
    );

    if (!mounted || result == null) return;

    final bool passed = result['passed'] == true;
    final int scoreLooted = (result['score'] as num?)?.toInt() ?? 0;

    final currentUserId =
        SupaFlow.client.auth.currentUser?.id ?? 'guest_raider';
    final currentUserName =
        SupaFlow.client.auth.currentUser?.email?.split('@').first ?? 'Raider';

    if (passed) {
      if (widget.isMockAttack) {
        // Mock attack: zero penalty, bonus training points
        final totalBonus = 50 + scoreLooted;
        await PocketFortressDefenseService.recordTrainingPoints(totalBonus);
      } else {
        // Real attack victory: deploy 10-Hour Army Shield, record war log, award bounty
        await PocketIslandAttackService.instance
            .deployArmyShield(widget.island.id.toString());

        await PocketIslandAttackService.instance.recordWarLog(
          IslandWarLogEntry(
            id: 'war_${DateTime.now().millisecondsSinceEpoch}',
            attackerId: currentUserId,
            attackerName: currentUserName,
            attackerAvatar: '⚔️',
            targetIslandId: widget.island.id.toString(),
            targetIslandName: widget.island.name,
            targetPlanetCode: widget.colony.code,
            attackerPlanetCode: 'EP',
            totalHp: _totalGates,
            damageDealt: _totalGates,
            wasConquered: true,
            scoreLooted: _defenseProfile.bountyPool,
            timestamp: DateTime.now(),
            isMockAttack: false,
          ),
        );

        unawaited(
          PocketIslandAttackService.instance.broadcastIslandSirenAlert(
            islandId: widget.island.id.toString(),
            islandName: widget.island.name,
            planetCode: widget.colony.code,
            attackerName: currentUserName,
            remainingHp: 0,
            totalHp: _totalGates,
            isConquered: true,
          ),
        );
      }
    }

    // 4. Show the comprehensive Island Army Defense Skills & Raid Debrief Sheet!
    _showIslandArmySkillsSheet(
      isVictory: passed,
      gatesBreached: passed ? _totalGates : ((result['gatesCleared'] as num?)?.toInt() ?? 0),
      scoreLooted: passed ? (widget.isMockAttack ? 50 : _defenseProfile.bountyPool) : 0,
    );
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
          'This Island is under an impenetrable 10-Hour Army Defense Shield ($hours hrs left) following a previous battle.\n\nAll enemy raids are blocked until the shield expires!',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎖️ 25-PLOT ISLAND ARMY DEFENSE SKILLS SHEET
  // ---------------------------------------------------------------------------

  void _showIslandArmySkillsSheet({
    required bool isVictory,
    required int gatesBreached,
    required int scoreLooted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0B132B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Victory / Defeat Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVictory
                      ? [const Color(0xFF065F46), const Color(0xFF047857)]
                      : [const Color(0xFF7F1D1D), const Color(0xFF991B1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isVictory
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    isVictory ? '🏆' : '💀',
                    style: const TextStyle(fontSize: 34),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVictory
                              ? (widget.isMockAttack
                                  ? 'MOCK RAID COMPLETE!'
                                  : 'ISLAND DEFENSES CONQUERED!')
                              : 'ISLAND DEFENSE HELD!',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isVictory
                              ? 'Breached all $gatesBreached gates • Looted +$scoreLooted Pocket Score!'
                              : 'Deflected after breaching $gatesBreached / $_totalGates gates.',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Section Title: 25-Plot Army Roster & Skills
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '25-PLOT ISLAND ARMY DEFENSE SKILLS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '25 Pioneers',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // 25 Plots List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: 25,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final plotSlot = index + 1;
                  CitizenPlot? citizen;
                  if (index < widget.plots.length) {
                    citizen = widget.plots[index];
                  } else if (index < _defenseProfile.residents.length) {
                    citizen = _defenseProfile.residents[index];
                  }

                  final String name = citizen?.userName ?? 'Pioneer #$plotSlot';
                  final String avatar = citizen?.userAvatar ?? '🛡️';
                  final int day = citizen?.day ?? 1;
                  final int plotDeedNum = citizen?.plotNumber ?? plotSlot;

                  // Compute Army Skill Rank
                  String rankTitle;
                  int stars;
                  Color rankColor;
                  if (day >= 20) {
                    rankTitle = 'Arch-Defender General 👑';
                    stars = 5;
                    rankColor = const Color(0xFFFFD700);
                  } else if (day >= 10) {
                    rankTitle = 'Veteran Vanguard 🏹';
                    stars = 4;
                    rankColor = const Color(0xFF38BDF8);
                  } else if (day >= 4) {
                    rankTitle = 'Frontline Guard ⚔️';
                    stars = 3;
                    rankColor = const Color(0xFF34D399);
                  } else {
                    rankTitle = 'Pioneer Guard 🛡️';
                    stars = 2;
                    rankColor = Colors.white70;
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Plot Deed Badge
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            border: Border.all(
                              color: const Color(0xFF38BDF8),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#$plotDeedNum',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Avatar
                        Text(avatar, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),

                        // Name & Military Rank
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rankTitle,
                                style: GoogleFonts.inter(
                                  color: rankColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stars & Completed Day Level
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: List.generate(
                                stars,
                                (i) => const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Day $day Defense',
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Return to Island Map',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
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

    final bool isShieldActive = _defenseProfile.isUnderShield;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 1. 🌌 Deep Cosmos Background
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

          // 2. 🏝️ TOP PREVIEW: LIVING ISLAND AERIAL VIEW CANVAS!
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: media.size.height * 0.42,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IslandAerialViewWidget(
                    island: widget.island,
                    isInteractive: false,
                    zoomScale: 1.35,
                    plots: widget.plots,
                    planetName: widget.colony.planetName,
                  ),
                ),

                // Radial Vignette
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF030712).withValues(alpha: 0.85),
                          Colors.transparent,
                          const Color(0xFF030712),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // Pulsing Shield Energy Dome
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shieldPulseController,
                    builder: (context, child) {
                      final alpha = 0.15 + (_shieldPulseController.value * 0.20);
                      final shieldColor = widget.isMockAttack
                          ? const Color(0xFF10B981)
                          : (isShieldActive
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF38BDF8));
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: shieldColor.withValues(alpha: alpha),
                            width: 2.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. 🛡️ TOP HEADER: ISLAND & PLANET TITLE CAPSULE
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Row(
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

                // Island Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.island.name,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
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

                // Mode Badge
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
          ),

          // 4. 📝 LOWER PANEL: ARMY DEFENSE OVERVIEW & 25-PLOT SKILLS PREVIEW
          Positioned(
            top: media.size.height * 0.38,
            left: 16,
            right: 16,
            bottom: bottomPad + 84,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Island Defense Metrics Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricPill(
                        '🏰 DEFENSE GATES',
                        '$_totalGates Gates',
                        const Color(0xFF38BDF8),
                      ),
                      _metricPill(
                        '👥 GARRISON',
                        '${_defenseProfile.occupiedCount} / 25 Plots',
                        const Color(0xFF34D399),
                      ),
                      _metricPill(
                        '🪙 BOUNTY POOL',
                        '${_defenseProfile.bountyPool} PS',
                        const Color(0xFFFBBF24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 10-Hour Shield Warning banner if active
                  if (isShieldActive)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF78350F).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Row(
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '10-Hour Shield Active: ${_defenseProfile.shieldMinutesRemaining} mins remaining. Real raids locked!',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFDE68A),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Section Header: 25-Plot Army Roster
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '25-PLOT ISLAND ARMY DEFENSE ROSTER',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showIslandArmySkillsSheet(
                          isVictory: false,
                          gatesBreached: 0,
                          scoreLooted: 0,
                        ),
                        child: Text(
                          'View Full Skills ↗',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 25-Plot Roster List
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 25,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, idx) {
                        final plotNum = idx + 1;
                        CitizenPlot? c;
                        if (idx < widget.plots.length) {
                          c = widget.plots[idx];
                        } else if (idx < _defenseProfile.residents.length) {
                          c = _defenseProfile.residents[idx];
                        }

                        final String name = c?.userName ?? 'Pioneer #$plotNum';
                        final String avatar = c?.userAvatar ?? '🛡️';
                        final int day = c?.day ?? 1;
                        final int plotDeedNum = c?.plotNumber ?? plotNum;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0F172A),
                                  border: Border.all(
                                      color: const Color(0xFF38BDF8),
                                      width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '#$plotDeedNum',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(avatar, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Day $day Defense',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
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

          // 5. 🚀 BOTTOM FLOATING ACTION CONTROLS: RUNNER RAID & NEIGHBORS CHAT
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPad + 14,
            child: Row(
              children: [
                // 💬 Island Neighbors Chat Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Color(0xFF38BDF8),
                          width: 1.4,
                        ),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      PocketIslandGroupService.instance.openIslandGroupChat(
                        context,
                        planetCode: widget.colony.code,
                        planetName: widget.colony.planetName,
                        wave: widget.island.wave,
                        islandName: widget.island.name,
                      );
                    },
                    icon: const Text('💬', style: TextStyle(fontSize: 18)),
                    label: Text(
                      'NEIGHBORS',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 🏃 Big Runner Battle Button (Subway-Surfers 2D Runner)
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isMockAttack
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _launchRunnerAttack,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.isMockAttack ? '🛡️' : '🏃⚔️',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.isMockAttack
                                    ? 'LAUNCH RUNNER'
                                    : 'START 25-GATE RAID',
                                maxLines: 1,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
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
    );
  }

  Widget _metricPill(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
