import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'flame_english_house_game.dart';
import 'pocket_fortress_defense_service.dart';
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
    required this.attackerStreak,
  });

  @override
  State<PocketCitadelAttackPage> createState() => _PocketCitadelAttackPageState();
}

class _PocketCitadelAttackPageState extends State<PocketCitadelAttackPage>
    with TickerProviderStateMixin {
  int _raidStep = 0; // 0: Overview, 1: Defense Question, 2: Gate Breached (Attack button ready), 3: Victory, -1: Failed
  int _selectedOption = -1;
  bool _isStriking = false;
  late int _defenderHp;
  late bool _isDefenderDamaged;
  List<HouseShieldQuestion> _defenseQuestions = [];
  int _currentQIdx = 0;
  Map<String, dynamic>? _breachResult;
  Map<String, dynamic>? _pointsResult;

  bool _isTargetProtected = false;
  double _protectionHoursLeft = 0;
  bool _inCooldown = false;
  bool _isDailyLimitReached = false;
  int _attacksUsed = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;
  late AnimationController _beamController;
  late AnimationController _particleController;
  late AnimationController _coinController;

  @override
  void initState() {
    super.initState();
    _defenderHp = widget.neighbor.hp;
    _isDefenderDamaged = widget.neighbor.isDamaged;

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
    _pulseController.dispose();
    _shakeController.dispose();
    _beamController.dispose();
    _particleController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _loadBattleState() async {
    final targetId = widget.neighbor.id;
    final inCooldown = await PocketFortressDefenseService.isTargetInCooldown(targetId);
    final isProtected = await PocketFortressDefenseService.isUnderPresidentialProtection(targetId);
    final protectionMinutes = isProtected
        ? await PocketFortressDefenseService.getPresidentialProtectionMinutesRemaining(targetId)
        : 0;
    final attacksUsed = await PocketFortressDefenseService.getDailyAttacksUsedToday();
    final isDailyLimitReached = attacksUsed >= PocketFortressDefenseService.kDailyMaxAttacks;

    final questions = await PocketFortressDefenseService.loadShieldQuestions(
      widget.neighbor.day,
      isNeighbor: true,
    );

    if (mounted) {
      setState(() {
        _inCooldown = inCooldown;
        _isTargetProtected = isProtected;
        _protectionHoursLeft = protectionMinutes / 60.0;
        _attacksUsed = attacksUsed;
        _isDailyLimitReached = isDailyLimitReached;
        _defenseQuestions = questions;
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

    final looted = (result['lootedCoins'] as num? ?? 0).toInt();
    if (looted > 0) {
      await PocketFortressDefenseService.awardRaidLoot(looted);
    }

    // Award +150 BONUS POINTS for successful breach!
    final pRes = await PocketFortressDefenseService.awardPoints(150);

    await Future.delayed(const Duration(milliseconds: 450));

    if (mounted) {
      _coinController.forward(from: 0.0);
      setState(() {
        _isStriking = false;
        _defenderHp = math.max(0, _defenderHp - 60);
        _isDefenderDamaged = true;
        _breachResult = result;
        _pointsResult = pRes;
        _raidStep = 3; // Victory!
      });
    }
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        '⚔️ $_attacksUsed / ${PocketFortressDefenseService.kDailyMaxAttacks} Today',
                        style: TextStyle(
                          color: _isDailyLimitReached ? Colors.redAccent : const Color(0xFF38BDF8),
                          fontSize: 10.5,
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

              // --- 🏡 FULL SCREEN HOUSE CANVAS AT CENTER/BOTTOM ---
              // Audio Directive: "ആപ്പിന്റെ ഫുൾ സ്ക്രീൻ ആയിട്ട് പോവുക, അടിയിൽ വീടായിട്ട് നിൽക്കുക."
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
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isDefenderDamaged
                            ? Colors.redAccent.withValues(alpha: 0.6)
                            : const Color(0xFF38BDF8).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isDefenderDamaged
                              ? Colors.redAccent.withValues(alpha: 0.2)
                              : Colors.black54,
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // The animated 2D Flame English House
                          Positioned.fill(
                            child: FlameEnglishHouseWidget(
                              currentDay: widget.neighbor.day,
                              streak: widget.neighbor.streak,
                              isDamaged: _isDefenderDamaged,
                              houseId: widget.neighbor.id,
                              paletteId: widget.neighbor.paletteId,
                            ),
                          ),

                          // High-powered laser cannon & explosive particle strike layer
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

                          // Victory Coin Shower Layer
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

                          // Attacker weapon discharge banner
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

                          // Attack strike visual impact overlay
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

                          // Citadel Status Badge
                          Positioned(
                            top: 10,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isDefenderDamaged ? Colors.redAccent : Colors.white24,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isDefenderDamaged
                                        ? '💥 Breached Defense'
                                        : '🛡️ Level ${widget.neighbor.day} Architecture',
                                    style: GoogleFonts.outfit(
                                      color: _isDefenderDamaged ? const Color(0xFFF87171) : Colors.white,
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
                              '👮‍♂️ 48-Hour Presidential Police Protection Active!\nGuards stationed to allow resident recovery (${_protectionHoursLeft.toStringAsFixed(1)}h remaining). Raids blocked.',
                            )
                          else if (_inCooldown)
                            _buildNoticeCard('⏳ 24h Peace Treaty active! You attacked this citadel recently.')
                          else if (_isDailyLimitReached)
                            _buildNoticeCard('🔒 Daily limit reached! You have used 2/2 raids today.')
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
                                          'Crack ${widget.neighbor.name}\'s Home Defense question to breach the front gate, loot +45 study coins & earn +150 bonus combat points!',
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
                                            content: Text('🔒 Raid warfare unlocks at Level 4!'),
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
                                    },
                              icon: const Icon(Icons.flash_on_rounded, size: 20),
                              label: Text(
                                cannotAttack
                                    ? (_isDailyLimitReached
                                        ? 'DAILY LIMIT REACHED 🔒'
                                        : (_inCooldown ? 'PEACE TREATY IN EFFECT ⏳' : 'RAID LOCKED 🔒'))
                                    : 'ENGAGE DEFENSE GATE ⚔️',
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
                              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6)),
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
                                        '🛡️ DEFENSE GATE: ${currentQ.trapType.toUpperCase()}',
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Question ${_currentQIdx + 1} of ${_defenseQuestions.length}',
                                      style: const TextStyle(color: Colors.white54, fontSize: 10),
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
                                  : () {
                                      HapticFeedback.mediumImpact();
                                      if (_selectedOption == currentQ.correctIndex) {
                                        // Answer is correct -> Move to Step 2 to give the "ATTACK" button!
                                        setState(() => _raidStep = 2);
                                      } else {
                                        // Trap triggered -> Defense held!
                                        setState(() => _raidStep = -1);
                                      }
                                    },
                              child: Text(
                                'CONFIRM DEFENSE ANSWER ✓',
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
                                      ? '🛡️ Iron Dome Absorbed Breach (0 Coins Looted)'
                                      : '🪙 +${_breachResult?['lootedCoins'] ?? 45} Coins Looted from Vault!',
                                  style: TextStyle(
                                    color: _breachResult?['ironDomeBlocked'] == true
                                        ? Colors.amber
                                        : const Color(0xFF34D399),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
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
                                        '+150 BONUS POINTS EARNED! (100 pts/level)',
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
                                          '48h Presidential Police Guard Dispatched: Target is under protective peace treaty while recovering.',
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
                                        'TRAP TRIGGERED! ATTACK REPELLED!',
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
                                const Text(
                                  'You failed to crack the defender\'s English shield. Their house defense holds firm!',
                                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
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
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: const BorderSide(color: Colors.white24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('RETREAT 🛡️', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _raidStep = 1;
                                      _selectedOption = -1;
                                      _currentQIdx++;
                                    });
                                  },
                                  child: const Text('TRY AGAIN 🔄', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
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

