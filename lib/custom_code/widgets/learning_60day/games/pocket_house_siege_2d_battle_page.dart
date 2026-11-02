import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flame_english_house_game.dart';

/// ⚔️ Tactical Deployable Siege Unit Definition
class SiegeDeployableUnit {
  final String id;
  final String name;
  final String icon;
  final int damage;
  final double speed;
  final Color themeColor;
  final String soundKey;
  final String weaponDesc;

  const SiegeDeployableUnit({
    required this.id,
    required this.name,
    required this.icon,
    required this.damage,
    required this.speed,
    required this.themeColor,
    required this.soundKey,
    required this.weaponDesc,
  });
}

/// Active unit on the 2D battlefield marching towards the defender's house
class ActiveSiegeUnit {
  final String id;
  final SiegeDeployableUnit def;
  double x; // 0.0 to 1.0 (relative canvas width)
  double y; // relative canvas height
  final double targetX;
  final double targetY;
  bool hasAttacked = false;
  double attackCooldown = 0.0;
  final double birthTime;

  ActiveSiegeUnit({
    required this.id,
    required this.def,
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.birthTime,
  });
}

/// Projectile fired by a siege unit or defense tower
class ActiveSiegeProjectile {
  final String id;
  double x;
  double y;
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final Color color;
  final double size;
  double progress = 0.0;
  final double speed;
  bool isImpacted = false;

  ActiveSiegeProjectile({
    required this.id,
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.color,
    required this.speed,
    this.size = 6.0,
  })  : x = startX,
        y = startY;
}

/// Particle for smoke, sparks, explosions & coin fountain
class SiegeParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  Color color;
  double size;
  bool isCoin;

  SiegeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
    this.isCoin = false,
  });
}

/// 🏰 POKET Full-Screen 2D Interactive House Attack Battle Arena
class PocketHouseSiege2dBattlePage extends StatefulWidget {
  final String defenderName;
  final int defenderLevel;
  final String defenderId;
  final String paletteId;
  final int attackerDay;
  final String attackerWeapon;
  final bool isKidMode;
  final int initialHouseHp;
  final VoidCallback? onVictoryComplete;

  const PocketHouseSiege2dBattlePage({
    super.key,
    required this.defenderName,
    required this.defenderLevel,
    required this.defenderId,
    required this.paletteId,
    required this.attackerDay,
    required this.attackerWeapon,
    this.isKidMode = false,
    this.initialHouseHp = 100,
    this.onVictoryComplete,
  });

  static Future<Map<String, dynamic>?> open(
    BuildContext context, {
    required String defenderName,
    required int defenderLevel,
    required String defenderId,
    required String paletteId,
    required int attackerDay,
    required String attackerWeapon,
    bool isKidMode = false,
  }) {
    return Navigator.of(context).push<Map<String, dynamic>>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => FadeTransition(
          opacity: anim,
          child: PocketHouseSiege2dBattlePage(
            defenderName: defenderName,
            defenderLevel: defenderLevel,
            defenderId: defenderId,
            paletteId: paletteId,
            attackerDay: attackerDay,
            attackerWeapon: attackerWeapon,
            isKidMode: isKidMode,
          ),
        ),
      ),
    );
  }

  @override
  State<PocketHouseSiege2dBattlePage> createState() =>
      _PocketHouseSiege2dBattlePageState();
}

class _PocketHouseSiege2dBattlePageState
    extends State<PocketHouseSiege2dBattlePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  double _lastTick = 0.0;
  double _elapsed = 0.0;

  // Battle State
  late int _maxHp;
  late int _currentHp;
  bool _isVictory = false;
  bool _isHouseDamaged = false;
  int _lootedCoins = 0;
  int totalDamageDealt = 0;
  String _selectedUnitId = 'ram';
  int _energy = 100; // Battle energy replenished over time
  double _energyAccumulator = 0.0;

  // Troops & Projectiles
  final List<ActiveSiegeUnit> _units = [];
  final List<ActiveSiegeProjectile> _projectiles = [];
  final List<SiegeParticle> _particles = [];
  final math.Random _rnd = math.Random();

  // Deployable Arsenal
  static const List<SiegeDeployableUnit> arsenal = [
    SiegeDeployableUnit(
      id: 'ram',
      name: 'Battering Ram',
      icon: '🛡️',
      damage: 18,
      speed: 0.12,
      themeColor: Color(0xFFF59E0B),
      soundKey: 'heavy_ram',
      weaponDesc: 'Crushes outer gates with brute force',
    ),
    SiegeDeployableUnit(
      id: 'blaster',
      name: 'Sonic Blaster',
      icon: '🔊',
      damage: 14,
      speed: 0.18,
      themeColor: Color(0xFF38BDF8),
      soundKey: 'sonic_blast',
      weaponDesc: 'Vibrational pulse that shatters defenses',
    ),
    SiegeDeployableUnit(
      id: 'cannon',
      name: 'Laser Turret',
      icon: '⚡',
      damage: 25,
      speed: 0.10,
      themeColor: Color(0xFFEF4444),
      soundKey: 'laser_cannon',
      weaponDesc: 'High-energy beam dealing critical damage',
    ),
    SiegeDeployableUnit(
      id: 'drone',
      name: 'Energy Drone',
      icon: '🛸',
      damage: 12,
      speed: 0.25,
      themeColor: Color(0xFF10B981),
      soundKey: 'drone_strike',
      weaponDesc: 'Swift aerial assault circumventing shields',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _maxHp = widget.initialHouseHp > 0 ? widget.initialHouseHp : 100;
    _currentHp = _maxHp;

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onUpdate);
    _ticker.repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (_lastTick == 0.0) _lastTick = now;
    final dt = (now - _lastTick).clamp(0.001, 0.05);
    _lastTick = now;
    _elapsed += dt;

    // Slowly recharge tactical energy
    _energyAccumulator += dt * 14.0;
    if (_energyAccumulator >= 1.0) {
      final add = _energyAccumulator.toInt();
      _energy = (_energy + add).clamp(0, 100);
      _energyAccumulator -= add;
    }

    // Target House position in normalized space (center upper-mid)
    const houseTargetX = 0.50;
    const houseTargetY = 0.40;

    // Update Units
    for (int i = _units.length - 1; i >= 0; i--) {
      final unit = _units[i];
      final dx = houseTargetX - unit.x;
      final dy = houseTargetY - unit.y;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist > 0.08) {
        // March toward target house
        final angle = math.atan2(dy, dx);
        unit.x += math.cos(angle) * unit.def.speed * dt;
        unit.y += math.sin(angle) * unit.def.speed * dt;
      } else {
        // In striking range! Attack periodic cooldown
        unit.attackCooldown += dt;
        if (unit.attackCooldown >= 0.85 && !_isVictory) {
          unit.attackCooldown = 0.0;
          _fireProjectile(
            fromX: unit.x,
            fromY: unit.y,
            toX: houseTargetX + (_rnd.nextDouble() * 0.1 - 0.05),
            toY: houseTargetY + (_rnd.nextDouble() * 0.08 - 0.04),
            unit: unit.def,
          );
        }
      }
    }

    // Update Projectiles
    for (int i = _projectiles.length - 1; i >= 0; i--) {
      final p = _projectiles[i];
      p.progress += p.speed * dt;
      p.x = p.startX + (p.targetX - p.startX) * p.progress;
      p.y = p.startY + (p.targetY - p.startY) * p.progress;

      if (p.progress >= 1.0) {
        _applyHitToHouse(p.targetX, p.targetY, p.color);
        _projectiles.removeAt(i);
      }
    }

    // Update Particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final pt = _particles[i];
      pt.x += pt.vx * dt;
      pt.y += pt.vy * dt;
      pt.life -= dt;
      if (pt.isCoin) {
        pt.vy += 0.8 * dt; // gravity for coins
      }
      if (pt.life <= 0) {
        _particles.removeAt(i);
      }
    }

    setState(() {});
  }

  void _deploySelectedUnit() {
    if (_isVictory) return;
    if (_energy < 20) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Recharging siege energy... Wait a moment!'),
          duration: Duration(milliseconds: 700),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
      return;
    }

    final def = arsenal.firstWhere(
      (u) => u.id == _selectedUnitId,
      orElse: () => arsenal.first,
    );

    setState(() {
      _energy = (_energy - 20).clamp(0, 100);
      final spawnX = 0.15 + (_rnd.nextDouble() * 0.70);
      const spawnY = 0.80;
      _units.add(ActiveSiegeUnit(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}_${_rnd.nextInt(999)}',
        def: def,
        x: spawnX,
        y: spawnY,
        targetX: 0.50,
        targetY: 0.40,
        birthTime: _elapsed,
      ));
    });

    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _fireProjectile({
    required double fromX,
    required double fromY,
    required double toX,
    required double toY,
    required SiegeDeployableUnit unit,
  }) {
    _projectiles.add(ActiveSiegeProjectile(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      startX: fromX,
      startY: fromY,
      targetX: toX,
      targetY: toY,
      color: unit.themeColor,
      speed: 2.2,
      size: unit.id == 'cannon' ? 9.0 : 6.0,
    ));
    HapticFeedback.selectionClick();
  }

  void _applyHitToHouse(double hx, double hy, Color impactColor) {
    if (_isVictory) return;

    final def = arsenal.firstWhere(
      (u) => u.themeColor == impactColor,
      orElse: () => arsenal.first,
    );
    final dmg = def.damage;

    // Spawn Impact Particles (sparks and rubble)
    for (int k = 0; k < 12; k++) {
      final ang = _rnd.nextDouble() * 2 * math.pi;
      final spd = 0.15 + _rnd.nextDouble() * 0.35;
      _particles.add(SiegeParticle(
        x: hx,
        y: hy,
        vx: math.cos(ang) * spd,
        vy: math.sin(ang) * spd,
        life: 0.4 + _rnd.nextDouble() * 0.3,
        maxLife: 0.7,
        color: _rnd.nextBool() ? impactColor : const Color(0xFFFFD700),
        size: 3.5 + _rnd.nextDouble() * 4.0,
      ));
    }

    HapticFeedback.heavyImpact();

    setState(() {
      _currentHp = (_currentHp - dmg).clamp(0, _maxHp);
      totalDamageDealt += dmg;
      if (_currentHp <= 40) {
        _isHouseDamaged = true;
      }
      if (_currentHp <= 0 && !_isVictory) {
        _triggerVictory();
      }
    });
  }

  void _triggerVictory() {
    _isVictory = true;
    _lootedCoins = 15;
    HapticFeedback.heavyImpact();

    // Spawn massive coin fountain and victory fireworks
    for (int k = 0; k < 50; k++) {
      final ang = -math.pi * 0.8 + (_rnd.nextDouble() * math.pi * 0.6);
      final spd = 0.25 + _rnd.nextDouble() * 0.55;
      _particles.add(SiegeParticle(
        x: 0.50,
        y: 0.40,
        vx: math.cos(ang) * spd,
        vy: math.sin(ang) * spd,
        life: 1.2 + _rnd.nextDouble() * 0.8,
        maxLife: 2.0,
        color: const Color(0xFFFFD700),
        size: 6.0 + _rnd.nextDouble() * 4.0,
        isCoin: true,
      ));
    }
  }

  void _finishAndPopVictory() {
    HapticFeedback.heavyImpact();
    final result = {
      'passed': true,
      'lootedCoins': _lootedCoins > 0 ? _lootedCoins : 15,
      'damageDealt': totalDamageDealt > 0 ? totalDamageDealt : 100,
      'weapon': widget.attackerWeapon,
    };
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hpRatio = (_currentHp / _maxHp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF030A16),
      body: Stack(
        children: [
          // 1. Dynamic 2D Atmospheric Battle Sky & Terrain
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Ground Battle Grid
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0B132B).withValues(alpha: 0.3),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: const Border(
                  top: BorderSide(color: Color(0xFF334155), width: 1.5),
                ),
              ),
            ),
          ),

          // 2. The Target User's Living House Structure (Reusing FlameEnglishHouseWidget)
          Positioned(
            top: size.height * 0.16,
            left: 0,
            right: 0,
            height: size.height * 0.34,
            child: Center(
              child: AnimatedScale(
                scale: _isVictory ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: size.width * 0.85,
                  child: FlameEnglishHouseWidget(
                    currentDay: widget.defenderLevel > 0
                        ? widget.defenderLevel
                        : 1,
                    streak: widget.defenderLevel > 0
                        ? widget.defenderLevel
                        : 1,
                    isDamaged: _isHouseDamaged || _isVictory,
                    houseId: widget.defenderId,
                    paletteId: widget.paletteId,
                    showTestingControls: false,
                  ),
                ),
              ),
            ),
          ),

          // 3. Custom Painter for Units, Projectiles, Particles & Beams
          Positioned.fill(
            child: CustomPaint(
              painter: _SiegeFieldPainter(
                units: _units,
                projectiles: _projectiles,
                particles: _particles,
                isVictory: _isVictory,
              ),
            ),
          ),

          // 4. Top HUD Header: Defender Name, House Level & Health Bar
          Positioned(
            top: topPad + 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back / Abort
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Retreat',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Target User Title & Level Badge
                    Column(
                      children: [
                        Text(
                          widget.defenderName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              const Shadow(
                                  blurRadius: 10, color: Colors.black87)
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFEF4444), width: 1),
                          ),
                          child: Text(
                            'Day ${widget.defenderLevel} Citadel Defense',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFCA5A5),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Energy Meter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF0284C7).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF38BDF8), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: Color(0xFFFFD700), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_energy',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Citadel Structure HP Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_rounded,
                                  color: Color(0xFFEF4444), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'CITADEL INTEGRITY',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_currentHp / $_maxHp HP',
                            style: GoogleFonts.outfit(
                              color: hpRatio > 0.3
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: hpRatio,
                          minHeight: 9,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hpRatio > 0.5
                                ? const Color(0xFF10B981)
                                : (hpRatio > 0.25
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. Bottom Controls Bar: Arsenal Unit Select & Big Deploy Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPad + 14),
              decoration: BoxDecoration(
                color: const Color(0xFF090D16).withValues(alpha: 0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Unit Selection Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: arsenal.map((u) {
                      final isSelected = _selectedUnitId == u.id;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedUnitId = u.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? u.themeColor.withValues(alpha: 0.25)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? u.themeColor
                                  : Colors.white12,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(u.icon,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                u.name,
                                style: GoogleFonts.outfit(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white60,
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                ),
                              ),
                              Text(
                                '⚡ ${u.damage} DMG',
                                style: GoogleFonts.inter(
                                  color: u.themeColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Deploy Button
                  GestureDetector(
                    onTap: _deploySelectedUnit,
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _energy >= 20
                              ? [
                                  const Color(0xFFDC2626),
                                  const Color(0xFFEF4444),
                                ]
                              : [
                                  const Color(0xFF475569),
                                  const Color(0xFF334155),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _energy >= 20
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFDC2626)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on_rounded,
                                color: Color(0xFFFFD700), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'DEPLOY SIEGE STRIKE (-20 ⚡)',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
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

          // 6. Victory Overlay Modal when Citadel is Breached!
          if (_isVictory)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.3),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          'CITADEL BREACHED!',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You successfully conquered ${widget.defenderName}\'s house defenses!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFFFD700), width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on_rounded,
                                  color: Color(0xFFFFD700), size: 26),
                              const SizedBox(width: 8),
                              Text(
                                '+15 POKET SCORE & LOOT',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _finishAndPopVictory,
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF10B981),
                                  Color(0xFF059669),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                'CLAIM VICTORY ⚔️',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
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
        ],
      ),
    );
  }
}

/// Custom Canvas Painter rendering units, lasers, and effects
class _SiegeFieldPainter extends CustomPainter {
  final List<ActiveSiegeUnit> units;
  final List<ActiveSiegeProjectile> projectiles;
  final List<SiegeParticle> particles;
  final bool isVictory;

  _SiegeFieldPainter({
    required this.units,
    required this.projectiles,
    required this.particles,
    required this.isVictory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Projectiles
    final projPaint = Paint()..style = PaintingStyle.fill;
    for (final p in projectiles) {
      projPaint.color = p.color;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        projPaint,
      );

      // Trailing glow
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * 2,
        glowPaint,
      );
    }

    // 2. Draw Particles
    final ptPaint = Paint()..style = PaintingStyle.fill;
    for (final pt in particles) {
      final alpha = (pt.life / pt.maxLife).clamp(0.0, 1.0);
      ptPaint.color = pt.color.withValues(alpha: alpha);
      if (pt.isCoin) {
        // Draw gold coin
        canvas.drawCircle(
          Offset(pt.x * size.width, pt.y * size.height),
          pt.size,
          ptPaint,
        );
      } else {
        canvas.drawCircle(
          Offset(pt.x * size.width, pt.y * size.height),
          pt.size * alpha,
          ptPaint,
        );
      }
    }

    // 3. Draw Units on Battlefield
    for (final u in units) {
      final px = u.x * size.width;
      final py = u.y * size.height;

      // Shadow under unit
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py + 12), width: 32, height: 10),
        Paint()..color = Colors.black45,
      );

      // Unit Icon / Badge
      final badgePaint = Paint()
        ..color = u.def.themeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), 16, badgePaint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(px, py), 16, borderPaint);

      // Text painter for emoji
      final tp = TextPainter(
        text: TextSpan(
          text: u.def.icon,
          style: const TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _SiegeFieldPainter oldDelegate) => true;
}

