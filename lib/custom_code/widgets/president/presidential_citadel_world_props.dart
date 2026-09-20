import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🚁 Presidential Security Helicopter (Marine One / Air Escort)
/// Hovering / patrolling in the sky with spinning rotor blades, tail rotor,
/// flashing beacon strobes, and sweeping searchlight beam.
class PresidentialHelicopterWidget extends StatelessWidget {
  final double animProg;

  const PresidentialHelicopterWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    // High-speed rotor blade spinning angle
    final rotorAngle = animProg * 36 * math.pi;
    final tailRotorAngle = animProg * 48 * math.pi;
    final beaconFlash = math.sin(animProg * 12 * math.pi) > 0;
    // Gentle hovering bob
    final hoverBob = math.sin(animProg * 4 * math.pi) * 6.0;
    final searchlightSweep = math.sin(animProg * 2.5 * math.pi) * 0.35;

    return Transform.translate(
      offset: Offset(0, hoverBob),
      child: SizedBox(
        width: 130,
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Searchlight Cone Beam Sweeping Downward
            Positioned(
              left: 45,
              top: 36,
              child: Transform.rotate(
                angle: searchlightSweep,
                alignment: Alignment.topCenter,
                child: CustomPaint(
                  size: const Size(60, 90),
                  painter: _SearchlightConePainter(),
                ),
              ),
            ),

            // 2. Spinning Main Rotor Blades
            Positioned(
              left: 10,
              top: 4,
              child: Transform.rotate(
                angle: rotorAngle,
                alignment: Alignment.center,
                child: Container(
                  width: 90,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Rotor Mast
            Positioned(
              left: 52,
              top: 6,
              child: Container(width: 4, height: 8, color: const Color(0xFF334155)),
            ),

            // 3. Helicopter Fuselage (Olive Green & White VIP Roof)
            Positioned(
              left: 20,
              top: 14,
              child: Container(
                width: 68,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A1E), Color(0xFF2D4A22)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF475569), width: 0.8),
                ),
                child: Stack(
                  children: [
                    // White VIP Upper Cabin Roof
                    Positioned(
                      left: 12,
                      top: 0,
                      width: 44,
                      height: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                    ),
                    // Cockpit Windshield
                    Positioned(
                      left: 3,
                      top: 4,
                      child: Container(
                        width: 14,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        ),
                      ),
                    ),
                    // Presidential Seal Star
                    Positioned(
                      right: 18,
                      top: 7,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Tail Boom & Spinning Tail Rotor
            Positioned(
              left: 86,
              top: 20,
              child: Container(
                width: 32,
                height: 5,
                color: const Color(0xFF1E3A1E),
              ),
            ),
            // Tail Fin
            Positioned(
              left: 114,
              top: 12,
              child: Container(
                width: 5,
                height: 16,
                color: const Color(0xFF2D4A22),
              ),
            ),
            // Tail Rotor
            Positioned(
              left: 112,
              top: 10,
              child: Transform.rotate(
                angle: tailRotorAngle,
                alignment: Alignment.center,
                child: Container(
                  width: 18,
                  height: 2.5,
                  color: Colors.white,
                ),
              ),
            ),

            // 5. Landing Skids
            Positioned(
              left: 26,
              top: 38,
              child: Container(
                width: 54,
                height: 2.5,
                color: const Color(0xFF475569),
              ),
            ),
            Positioned(
              left: 38,
              top: 34,
              child: Container(width: 2, height: 5, color: const Color(0xFF475569)),
            ),
            Positioned(
              left: 64,
              top: 34,
              child: Container(width: 2, height: 5, color: const Color(0xFF475569)),
            ),

            // 6. Anti-Collision Flashing Strobe Beacon
            Positioned(
              left: 53,
              top: 12,
              child: Container(
                width: 3.5,
                height: 3.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: beaconFlash ? const Color(0xFFFF2222) : const Color(0xFF7F1D1D),
                  boxShadow: beaconFlash
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF2222).withValues(alpha: 0.9),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchlightConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.65),
          const Color(0xFFFEF08A).withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ✈️ Supersonic Presidential Jet (Air Force One & Escort Jet)
/// Gliding high in the sky with long dual white contrail vapor plumes
class PresidentialSupersonicJetWidget extends StatelessWidget {
  final double animProg;

  const PresidentialSupersonicJetWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    // Dynamic flight glide
    final jetXOffset = math.sin(animProg * 2 * math.pi) * 18.0;

    return Transform.translate(
      offset: Offset(jetXOffset, 0),
      child: SizedBox(
        width: 190,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Dual White Vapor Contrail Plumes
            Positioned(
              left: 0,
              top: 18,
              child: Container(
                width: 95,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 26,
              child: Container(
                width: 95,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 2. Supersonic Delta-Wing Jet Fuselage
            Positioned(
              left: 90,
              top: 12,
              child: SizedBox(
                width: 80,
                height: 24,
                child: Stack(
                  children: [
                    // Main Needle Body
                    Positioned(
                      left: 0,
                      top: 8,
                      width: 78,
                      height: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFFF8FAFC), Color(0xFF0284C7)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Swept-back Delta Wings
                    Positioned(
                      left: 18,
                      top: 0,
                      width: 38,
                      height: 24,
                      child: CustomPaint(
                        painter: _DeltaWingPainter(),
                      ),
                    ),
                    // Vertical Tail Stabilizer
                    Positioned(
                      left: 4,
                      top: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
                        ),
                      ),
                    ),
                    // Cockpit Canister Glass
                    Positioned(
                      right: 12,
                      top: 7,
                      child: Container(
                        width: 14,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(2),
                        ),
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
}

class _DeltaWingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(0, 0)
      ..lineTo(8, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(path, Paint()..color = const Color(0xFF1E3A8A) ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🚀 Aerospace Defense Rocket & Missile Launch Gantry Tower
/// Fortified Surface-to-Air defense rocket stationed near the perimeter
class PresidentialDefenseRocketWidget extends StatelessWidget {
  final double animProg;

  const PresidentialDefenseRocketWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    final statusBlink = math.sin(animProg * 8 * math.pi) > 0;

    return SizedBox(
      width: 58,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Launch Concrete Blast Pad Base
          Positioned(
            bottom: 0,
            child: Container(
              width: 54,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF64748B), width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 4, height: 4, color: statusBlink ? const Color(0xFF22C55E) : Colors.black),
                  Container(width: 4, height: 4, color: statusBlink ? const Color(0xFF22C55E) : Colors.black),
                ],
              ),
            ),
          ),

          // Steel Truss Launch Gantry Tower (Left side)
          Positioned(
            left: 4,
            bottom: 14,
            width: 14,
            height: 105,
            child: CustomPaint(
              painter: _RocketTrussPainter(),
            ),
          ),

          // Umbilical Support Arms
          Positioned(
            left: 16,
            bottom: 60,
            child: Container(width: 14, height: 3, color: const Color(0xFFEF4444)),
          ),
          Positioned(
            left: 16,
            bottom: 95,
            child: Container(width: 12, height: 3, color: const Color(0xFFEF4444)),
          ),

          // 🚀 Orbital Defense Interceptor Rocket
          Positioned(
            left: 24,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Aerodynamic Nose Cone
                Container(
                  width: 12,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                ),
                // Rocket Stage 2 & Payload Section
                Container(
                  width: 14,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF94A3B8), width: 0.6),
                  ),
                  child: Center(
                    child: Container(width: 4, height: 4, color: const Color(0xFFFFD700)),
                  ),
                ),
                // Gold Separation Ring
                Container(width: 15, height: 3, color: const Color(0xFFFFD700)),
                // Rocket Booster Stage 1
                Container(
                  width: 15,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(color: const Color(0xFF94A3B8), width: 0.6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 3, height: 18, color: const Color(0xFF1E3A8A)),
                    ],
                  ),
                ),
                // Delta Steering Fins
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 5, height: 10, color: const Color(0xFF334155)),
                    Container(width: 10, height: 4, color: const Color(0xFF0F172A)),
                    Container(width: 5, height: 10, color: const Color(0xFF334155)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RocketTrussPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 1.4;

    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);

    // Cross Braces
    for (double y = 0; y < size.height - 12; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 14), paint);
      canvas.drawLine(Offset(size.width, y), Offset(0, y + 14), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🚢 Naval Gunboat / Armed Patrol Cutter / Royal Flagship ("ബോട്ട്, ഷിപ്പ്, കപ്പൽ")
/// Cruising on the river in front of the citadel with rotating radar, deck cannon,
/// searchlight, naval ensign flag, and animated water foam wake.
class PresidentialNavalPatrolShipWidget extends StatelessWidget {
  final double animProg;

  const PresidentialNavalPatrolShipWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    // Water Bobbing & Cruising Translation
    final waterBob = math.sin(animProg * 6 * math.pi) * 2.5;
    final shipRoll = math.sin(animProg * 4 * math.pi) * 0.03;
    final radarAngle = animProg * 14 * math.pi;

    return Transform.translate(
      offset: Offset(0, waterBob),
      child: Transform.rotate(
        angle: shipRoll,
        child: SizedBox(
          width: 210,
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Foaming Water Wake Trails at Stern
              Positioned(
                left: -35,
                bottom: 4,
                child: CustomPaint(
                  size: const Size(60, 20),
                  painter: _WaterWakeFoamPainter(animProg: animProg),
                ),
              ),

              // 2. Armored Naval Hull (Steel Grey with Red Waterline)
              Positioned(
                left: 10,
                bottom: 8,
                child: CustomPaint(
                  size: const Size(185, 26),
                  painter: _NavalHullPainter(),
                ),
              ),

              // 3. Superstructure Bridge Deck
              Positioned(
                left: 50,
                bottom: 28,
                child: Container(
                  width: 76,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    border: Border.all(color: const Color(0xFF64748B), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      // Bridge Windows
                      for (int i = 0; i < 4; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Container(
                            width: 12,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 4. Upper Wheelhouse & Rotating Radar Mast
              Positioned(
                left: 70,
                bottom: 50,
                child: Container(
                  width: 36,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    border: Border.all(color: const Color(0xFF64748B), width: 0.6),
                  ),
                ),
              ),
              // Radar Mast & Rotating Radar Dish
              Positioned(
                left: 86,
                bottom: 62,
                child: Container(width: 3, height: 14, color: const Color(0xFF334155)),
              ),
              Positioned(
                left: 77,
                bottom: 74,
                child: Transform.rotate(
                  angle: radarAngle,
                  alignment: Alignment.center,
                  child: Container(
                    width: 22,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // 5. Forward Deck Naval Cannon Gun Turret
              Positioned(
                left: 140,
                bottom: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gun Turret Housing
                    Container(
                      width: 18,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF334155),
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                      ),
                    ),
                    // Long Gun Barrel
                    Container(
                      width: 20,
                      height: 3,
                      color: const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),

              // 6. Naval Ensign & Presidential Flag at Mast
              Positioned(
                left: 42,
                bottom: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 1.5, height: 26, color: const Color(0xFFFFD700)),
                    Container(
                      width: 14,
                      height: 9,
                      color: const Color(0xFF1E3A8A),
                      child: const Center(
                        child: Text('⚓', style: TextStyle(fontSize: 5, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              // 7. Bow Wave Foam Splash
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 16,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavalHullPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Steel Grey Hull Path
    final hullPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w - 24, 0)
      ..quadraticBezierTo(w - 8, h * 0.4, w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(hullPath, Paint()..color = const Color(0xFF475569));
    canvas.drawPath(hullPath, Paint()..color = const Color(0xFF1E293B) ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

    // Red Waterline Stripe at Keel
    final redStrip = Rect.fromLTWH(0, h - 5, w, 5);
    canvas.drawRect(redStrip, Paint()..color = const Color(0xFFDC2626));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaterWakeFoamPainter extends CustomPainter {
  final double animProg;

  _WaterWakeFoamPainter({required this.animProg});

  @override
  void paint(Canvas canvas, Size size) {
    final wave = math.sin(animProg * 10 * math.pi);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 + (wave * 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..quadraticBezierTo(size.width * 0.5, 0, 0, size.height * 0.3)
      ..moveTo(size.width, size.height / 2)
      ..quadraticBezierTo(size.width * 0.5, size.height, 0, size.height * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterWakeFoamPainter oldDelegate) => oldDelegate.animProg != animProg;
}

/// 🛡️ Iron Dome Missile Interceptor Battery ("Iron Dome System")
/// Multi-cell Tamir interceptor missile launcher on concrete blast pad
/// with elevation hydraulics, targeting telemetry, and active launch capability.
class PresidentialIronDomeBatteryWidget extends StatelessWidget {
  final double animProg;
  final bool isLaunching;
  final VoidCallback? onTap;

  const PresidentialIronDomeBatteryWidget({
    super.key,
    required this.animProg,
    this.isLaunching = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final flamePulse = math.sin(animProg * 12 * math.pi);
    final statusBlink = math.sin(animProg * 6 * math.pi) > 0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Reinforced Concrete Blast Pad with Hazard Stripes
            Positioned(
              left: 10,
              bottom: 0,
              width: 120,
              height: 18,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF64748B), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _HazardStripePainter(),
                ),
              ),
            ),

            // 2. Heavy Steel Turntable & Hydraulic Elevation Pistons
            Positioned(
              left: 45,
              bottom: 14,
              width: 50,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  border: Border.all(color: const Color(0xFF475569), width: 1.0),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),

            // 3. Angled 20-Cell Tamir Missile Canister Array (Elevated at 60 degrees)
            Positioned(
              left: 28,
              bottom: 26,
              child: Transform.rotate(
                angle: -0.32, // Angled toward incoming aerial threats
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 76,
                  height: 58,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A1E), Color(0xFF2D4A22), Color(0xFF142414)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF4ADE80), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Header with Military Decal & Status LED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'TAMIR-20',
                              style: TextStyle(
                                color: Color(0xFF4ADE80),
                                fontSize: 6.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusBlink ? const Color(0xFF22C55E) : const Color(0xFF15803D),
                              boxShadow: statusBlink
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withValues(alpha: 0.9),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      // 4x3 Grid of Missile Launch Tube Faces with Red Protective Caps
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (col) {
                          return Column(
                            children: List.generate(3, (row) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 1.2),
                                width: 10,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF090D1A),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: const Color(0xFF334155), width: 0.6),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 4.5,
                                    height: 4.5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isLaunching && col == 1 && row == 0
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Missile Launch Exhaust Plume & Rocket Flame (When firing)
            if (isLaunching)
              Positioned(
                left: 70,
                bottom: 60,
                child: CustomPaint(
                  size: const Size(40, 60),
                  painter: _IronDomeLaunchBlastPainter(flamePulse: flamePulse),
                ),
              ),

            // 5. Tactical Identification Badge / Interactive Touch Target
            Positioned(
              left: 18,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🛡️', style: TextStyle(fontSize: 8)),
                    SizedBox(width: 3),
                    Text(
                      'IRON DOME BATTERY',
                      style: TextStyle(
                        color: Color(0xFF7DD3FC),
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
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
}

class _HazardStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = const Color(0xFFEAB308).withValues(alpha: 0.8)
      ..strokeWidth = 3.5;
    for (double x = -10; x < size.width + 10; x += 10) {
      canvas.drawLine(Offset(x, size.height), Offset(x + 8, 0), stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IronDomeLaunchBlastPainter extends CustomPainter {
  final double flamePulse;

  _IronDomeLaunchBlastPainter({required this.flamePulse});

  @override
  void paint(Canvas canvas, Size size) {
    // Blazing rocket exhaust thrust
    final flamePath = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width, 0)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.6, 0, size.height)
      ..close();

    final flameShader = const LinearGradient(
      colors: [Color(0xFFFEF08A), Color(0xFFF97316), Color(0xFFEF4444)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(flamePath, Paint()..shader = flameShader);

    // Billowing white missile exhaust smoke
    final smokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75 + (flamePulse * 0.15))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 12, smokePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 9, smokePaint);
  }

  @override
  bool shouldRepaint(covariant _IronDomeLaunchBlastPainter oldDelegate) => true;
}

/// 📡 Phased Array Air Defense Radar Station (Iron Dome EL/M-2084 Radar)
/// Rotating active radar antenna tracking incoming rocket, drone, and mortar trajectories.
class PresidentialRadarDomeWidget extends StatelessWidget {
  final double animProg;
  final VoidCallback? onTap;

  const PresidentialRadarDomeWidget({
    super.key,
    required this.animProg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radarAngle = animProg * 6 * math.pi;
    final wavePulse = math.sin(animProg * 8 * math.pi);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 125,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Mobile Operations Trailer / Command Shelter
            Positioned(
              left: 15,
              bottom: 0,
              width: 90,
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF475569), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Equipment Ventilation Grille
                    Positioned(
                      left: 8,
                      top: 10,
                      child: Column(
                        children: List.generate(4, (i) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            width: 22,
                            height: 2,
                            color: const Color(0xFF0F172A),
                          );
                        }),
                      ),
                    ),
                    // Live Radar Server Blinkers
                    Positioned(
                      right: 10,
                      top: 8,
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF22C55E),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF22C55E).withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF38BDF8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Heavy Steel Mast & Hydraulic Turret
            Positioned(
              left: 54,
              bottom: 36,
              width: 12,
              height: 26,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  border: Border.all(color: const Color(0xFF64748B), width: 0.8),
                ),
              ),
            ),

            // 3. Rotating Phased Array Radar Plate (Rotating 3D Perspective)
            Positioned(
              left: 20,
              bottom: 58,
              width: 80,
              height: 48,
              child: AnimatedBuilder(
                animation: AlwaysStoppedAnimation(radarAngle),
                builder: (context, _) {
                  final scaleX = math.cos(radarAngle);
                  return Transform.scale(
                    scaleX: scaleX.abs().clamp(0.18, 1.0),
                    scaleY: 1.0,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF64748B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.35 + (wavePulse * 0.1)),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Phased Array Grid Sensors
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (r) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (c) {
                                  return Container(
                                    width: 4,
                                    height: 3,
                                    color: const Color(0xFF334155),
                                  );
                                }),
                              );
                            }),
                          ),
                          // Center Transmitter Feed Horn
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0F172A),
                              border: Border.all(color: const Color(0xFF0284C7), width: 1.2),
                            ),
                            child: Center(
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. Sweeping Electromagnetic Radar Wave Rings
            Positioned(
              left: 10,
              top: 0,
              width: 100,
              height: 45,
              child: CustomPaint(
                painter: _RadarWavePainter(animProg: animProg),
              ),
            ),

            // 5. Tactical Identification Label
            Positioned(
              left: 12,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('📡', style: TextStyle(fontSize: 8)),
                    SizedBox(width: 3),
                    Text(
                      'EL/M-2084 RADAR',
                      style: TextStyle(
                        color: Color(0xFF7DD3FC),
                        fontSize: 7.5,
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
    );
  }
}

class _RadarWavePainter extends CustomPainter {
  final double animProg;

  _RadarWavePainter({required this.animProg});

  @override
  void paint(Canvas canvas, Size size) {
    final waveProg = (animProg * 3) % 1.0;
    final r = size.width * 0.45 * waveProg;
    final alpha = (1.0 - waveProg).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: r),
      math.pi,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarWavePainter oldDelegate) => true;
}

/// 🧱 Fortress Security Perimeter Blast Wall ("Madhilukal")
/// Heavy ashlar limestone blast wall with steel battlements, concertina razor wire,
/// searchlights, and armed sentry observation posts.
class PresidentialPerimeterWallWidget extends StatelessWidget {
  final double width;
  final double height;
  final double animProg;
  final bool hasWatchtower;

  const PresidentialPerimeterWallWidget({
    super.key,
    required this.width,
    required this.height,
    required this.animProg,
    this.hasWatchtower = true,
  });

  @override
  Widget build(BuildContext context) {
    final searchlightSweep = math.sin(animProg * 3 * math.pi) * 0.30;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Heavy Stone Blast Wall Base & Courses
          Positioned(
            left: 0,
            bottom: 0,
            width: width,
            height: height - 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF475569), Color(0xFF64748B)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _StoneWallCoursePainter(),
              ),
            ),
          ),

          // 2. Iron Crest Battlements / Crenellations along Wall Top
          Positioned(
            left: 0,
            bottom: height - 16,
            width: width,
            height: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate((width / 24).floor(), (i) {
                return Container(
                  width: 14,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    border: Border.all(color: const Color(0xFF0F172A), width: 0.8),
                  ),
                );
              }),
            ),
          ),

          // 3. Razor Wire Coils (Concertina Wire) Glinting on Top
          Positioned(
            left: 4,
            bottom: height - 6,
            width: width - 8,
            height: 10,
            child: CustomPaint(
              painter: _RazorWirePainter(animProg: animProg),
            ),
          ),

          // 4. Watchtower & High-Power Automated Searchlight
          if (hasWatchtower) ...[
            Positioned(
              left: width * 0.5 - 18,
              top: 0,
              width: 36,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  border: Border.all(color: const Color(0xFF64748B), width: 1.2),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    // Sentry Observation Slit
                    Container(
                      width: 22,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D1A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    // Warning Stencil
                    const Text(
                      'POST-1',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // Sweeping Searchlight Beam
            Positioned(
              left: width * 0.5 - 25,
              top: 8,
              child: Transform.rotate(
                angle: searchlightSweep,
                alignment: Alignment.topCenter,
                child: CustomPaint(
                  size: const Size(50, 110),
                  painter: _SearchlightConePainter(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StoneWallCoursePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mortarPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (double y = 14; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), mortarPaint);
      final offset = (y / 14).floor() % 2 == 0 ? 0.0 : 16.0;
      for (double x = offset; x < size.width; x += 32) {
        canvas.drawLine(Offset(x, y - 14), Offset(x, y), mortarPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RazorWirePainter extends CustomPainter {
  final double animProg;

  _RazorWirePainter({required this.animProg});

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double x = 6; x < size.width; x += 14) {
      canvas.drawCircle(Offset(x, size.height / 2), 4.5, wirePaint);
      // Sharp barb glints
      canvas.drawLine(Offset(x - 2, size.height / 2 - 4), Offset(x + 2, size.height / 2 + 4), wirePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🚧 High-Visibility Heavy Police Barricade ("Barricadukal")
/// Diagonal yellow/black chevron warning stripes with dual alternating red & blue strobes
class PresidentialPoliceBarricadeWidget extends StatelessWidget {
  final double animProg;
  final double width;
  final String label;

  const PresidentialPoliceBarricadeWidget({
    super.key,
    required this.animProg,
    this.width = 110,
    this.label = 'POLICE LINE - DO NOT CROSS',
  });

  @override
  Widget build(BuildContext context) {
    final isRedFlash = math.sin(animProg * 12 * math.pi) > 0;

    return SizedBox(
      width: width,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Dual A-Frame Steel Legs
          Positioned(
            left: 8,
            bottom: 0,
            child: Container(width: 4, height: 26, color: const Color(0xFF1E293B)),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            child: Container(width: 4, height: 26, color: const Color(0xFF1E293B)),
          ),

          // 2. Main Barricade Beam with Reflective Chevron Stripes
          Positioned(
            left: 0,
            top: 10,
            width: width,
            height: 26,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFACC15),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF0F172A), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PoliceChevronPainter(),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D1A).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 6.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Left Strobe Beacon (Red)
          Positioned(
            left: 10,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRedFlash ? const Color(0xFFEF4444) : const Color(0xFF7F1D1D),
                boxShadow: isRedFlash
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 4. Right Strobe Beacon (Blue)
          Positioned(
            right: 10,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !isRedFlash ? const Color(0xFF3B82F6) : const Color(0xFF1E3A8A),
                boxShadow: !isRedFlash
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.9),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
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

class _PoliceChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()..color = const Color(0xFF0F172A);
    for (double x = -10; x < size.width + 10; x += 14) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 7, 0)
        ..lineTo(x, size.height)
        ..lineTo(x - 7, size.height)
        ..close();
      canvas.drawPath(path, blackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🚔 SWAT Armored Tactical BearCat / Stryker Carrier
/// Heavy ballistic armor with roof turret gunner, ramming bumper, and strobe lights
class PresidentialSwatArmoredCarWidget extends StatelessWidget {
  final double animProg;

  const PresidentialSwatArmoredCarWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    final isStrobe = math.sin(animProg * 14 * math.pi) > 0;

    return SizedBox(
      width: 130,
      height: 65,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Heavy Off-road Combat Tyres (Front & Rear)
          Positioned(
            left: 18,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F172A),
                border: Border.all(color: const Color(0xFF334155), width: 3.5),
              ),
              child: Center(
                child: Container(width: 6, height: 6, color: const Color(0xFF64748B)),
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F172A),
                border: Border.all(color: const Color(0xFF334155), width: 3.5),
              ),
              child: Center(
                child: Container(width: 6, height: 6, color: const Color(0xFF64748B)),
              ),
            ),
          ),

          // 2. Armored Ballistic Hull Body
          Positioned(
            left: 8,
            bottom: 10,
            width: 114,
            height: 38,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF1E293B)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(10), right: Radius.circular(6)),
                border: Border.all(color: const Color(0xFF475569), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Tactical Side Markings
                  Positioned(
                    left: 28,
                    top: 14,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'POLICE SWAT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('QRT-9', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // Ballistic View Slits / Armored Glass
                  Positioned(
                    left: 12,
                    top: 6,
                    width: 24,
                    height: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Heavy Rammer Bull-Bar Bumper at Front
          Positioned(
            left: 0,
            bottom: 8,
            width: 10,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF64748B), width: 1.0),
              ),
            ),
          ),

          // 4. Roof Turret Hatch with Tactical Searchlight & Strobe Lightbar
          Positioned(
            left: 45,
            top: 4,
            width: 40,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                border: Border.all(color: const Color(0xFF475569), width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 12,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isStrobe ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: (isStrobe ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withValues(alpha: 0.9),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 5,
                    decoration: BoxDecoration(
                      color: !isStrobe ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: (!isStrobe ? const Color(0xFF3B82F6) : const Color(0xFFEF4444)).withValues(alpha: 0.9),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🐕 Police K9 Unit (Tactical Handler + German Shepherd)
class PresidentialK9PoliceUnitWidget extends StatelessWidget {
  final double animProg;

  const PresidentialK9PoliceUnitWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    final dogPant = math.sin(animProg * 8 * math.pi) * 1.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Police K9 Officer
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tactical Cap
            Container(
              width: 14,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
            // Face
            Container(
              width: 10,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDFBA),
                shape: BoxShape.circle,
              ),
            ),
            // Tactical Vest & Uniform
            Container(
              width: 16,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
              ),
              child: const Center(
                child: Text('K9', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),

        const SizedBox(width: 4),

        // Tactical Leash
        CustomPaint(
          size: const Size(12, 16),
          painter: _LeashPainter(),
        ),

        // Police Dog (German Shepherd / Malinois)
        Transform.translate(
          offset: Offset(0, dogPant),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dog Ears & Head
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 3, height: 6, color: const Color(0xFF78350F)),
                  Container(
                    width: 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF92400E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Container(width: 3, height: 3, color: Colors.black),
                    ),
                  ),
                  Container(width: 3, height: 6, color: const Color(0xFF78350F)),
                ],
              ),
              // Body in Tactical Harness
              Container(
                width: 18,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Black tactical harness
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFEAB308), width: 0.8),
                ),
                child: const Center(
                  child: Text('POLICE', style: TextStyle(color: Color(0xFFFDE047), fontSize: 4.5, fontWeight: FontWeight.bold)),
                ),
              ),
              // Paws
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 3, height: 6, color: const Color(0xFF78350F)),
                  const SizedBox(width: 8),
                  Container(width: 3, height: 6, color: const Color(0xFF78350F)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAB308)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path()
      ..moveTo(0, 4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.8, size.width, size.height - 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ⚡ Luminous Hexagonal Iron Dome Forcefield Shield Canopy
/// Expansive holographic protective shield arcing across the sky over the palace
class PresidentialIronDomeShieldCanopyWidget extends StatelessWidget {
  final double width;
  final double height;
  final double animProg;
  final bool isShieldActive;

  const PresidentialIronDomeShieldCanopyWidget({
    super.key,
    required this.width,
    required this.height,
    required this.animProg,
    this.isShieldActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isShieldActive) return const SizedBox.shrink();

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _IronDomeHexCanopyPainter(animProg: animProg),
      ),
    );
  }
}

class _IronDomeHexCanopyPainter extends CustomPainter {
  final double animProg;

  _IronDomeHexCanopyPainter({required this.animProg});

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = math.sin(animProg * 4 * math.pi);
    final glowAlpha = 0.35 + (pulse * 0.12);

    final domePath = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, -size.height * 0.15, size.width, size.height)
      ..close();

    // 1. Soft Energy Shield Glow Fill
    final glowShader = LinearGradient(
      colors: [
        const Color(0xFF38BDF8).withValues(alpha: glowAlpha * 0.3),
        const Color(0xFFFFD700).withValues(alpha: glowAlpha * 0.18),
        Colors.transparent,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(domePath, Paint()..shader = glowShader);

    // 2. Glowing Shield Outer Rim Arc
    final rimPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.2),
          const Color(0xFF38BDF8).withValues(alpha: glowAlpha * 0.9),
          const Color(0xFFFFD700).withValues(alpha: glowAlpha * 0.9),
          const Color(0xFF38BDF8).withValues(alpha: 0.2),
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final arcPath = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, -size.height * 0.15, size.width, size.height);
    canvas.drawPath(arcPath, rimPaint);

    // 3. Hexagonal Grid Shield Pattern
    final hexPaint = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: glowAlpha * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const hexR = 24.0;
    final rowH = hexR * 1.5;
    final colW = hexR * math.sqrt(3);

    for (double y = 20; y < size.height - 10; y += rowH) {
      final rowIdx = (y / rowH).floor();
      final xOffset = rowIdx % 2 == 0 ? 0.0 : colW / 2;

      for (double x = xOffset; x < size.width; x += colW) {
        // Only draw if inside dome arc
        final normX = (x - size.width * 0.5) / (size.width * 0.5);
        final maxAllowedY = (1.0 - (normX * normX)) * size.height;

        if (y < maxAllowedY + 20 && y > 10) {
          _drawHex(canvas, Offset(x, y), hexR * 0.6, hexPaint);
        }
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final pt = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IronDomeHexCanopyPainter oldDelegate) => true;
}

/// 🚢 Massive Guided-Missile Destroyer / Sovereign Naval Warship ("Yudha Kappal")
/// Stationed in the sovereign waters surrounding the island with rotating radar,
/// deck gun turret, missile silos, bridge command deck, and churning wake wash.
class PresidentialNavalWarshipWidget extends StatelessWidget {
  final double animProg;
  final bool isNight;
  final double width;
  final double height;

  const PresidentialNavalWarshipWidget({
    super.key,
    required this.animProg,
    this.isNight = false,
    this.width = 280,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    final shipBob = math.sin(animProg * 3 * math.pi) * 3.0;
    final radarAngle = animProg * 8 * math.pi;
    final navFlash = math.sin(animProg * 6 * math.pi) > 0;

    return Transform.translate(
      offset: Offset(0, shipBob),
      child: SizedBox(
        width: width,
        height: height + 24,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Water churn & foam wake trails beneath hull
            Positioned(
              left: -18,
              bottom: 4,
              right: -18,
              height: 18,
              child: CustomPaint(
                painter: _ShipWakePainter(
                  prog: animProg,
                  isNight: isNight,
                ),
              ),
            ),

            // 2. Main Steel Warship Hull
            Positioned(
              left: 12,
              bottom: 12,
              width: width - 24,
              height: 34,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isNight
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A), const Color(0xFF020617)]
                        : [const Color(0xFF64748B), const Color(0xFF475569), const Color(0xFF334155)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(22),
                    topLeft: Radius.circular(2),
                  ),
                  border: Border.all(
                    color: isNight ? const Color(0xFF38BDF8).withValues(alpha: 0.4) : const Color(0xFF94A3B8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    if (isNight)
                      BoxShadow(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Red Waterline Striping
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Hull Pennant Number "DDG-01 NAVY"
                    Positioned(
                      left: 20,
                      top: 8,
                      child: Text(
                        'DDG-01 NAVY ⚓',
                        style: TextStyle(
                          color: isNight ? const Color(0xFF38BDF8) : Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    // Starboard / Port Navigation Strobe
                    Positioned(
                      right: 14,
                      top: 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: navFlash ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: navFlash ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Superstructure Command Bridge
            Positioned(
              left: 78,
              bottom: 44,
              width: 90,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isNight
                        ? [const Color(0xFF334155), const Color(0xFF1E293B)]
                        : [const Color(0xFF94A3B8), const Color(0xFF64748B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(10),
                  ),
                  border: Border.all(color: const Color(0xFF475569), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: 9,
                      height: 5,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: isNight ? const Color(0xFFFDE047) : const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(1.5),
                        boxShadow: [
                          if (isNight)
                            BoxShadow(
                              color: const Color(0xFFFDE047).withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Main Phased-Array Radar Mast & Rotating Radar Dish
            Positioned(
              left: 114,
              bottom: 70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rotating radar antenna
                  Transform.rotate(
                    angle: math.sin(radarAngle) * 0.4,
                    child: Container(
                      width: 22,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.white70, width: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Radar Mast Tower
                  Container(
                    width: 5,
                    height: 16,
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),

            // 5. Foredeck 5-Inch Naval Cannon Turret (Angled forward)
            Positioned(
              left: 36,
              bottom: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gun barrel
                  Positioned(
                    left: -14,
                    top: 5,
                    child: Transform.rotate(
                      angle: -0.22,
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 18,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                  // Turret housing dome
                  Container(
                    width: 20,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(6),
                      ),
                      border: Border.all(color: const Color(0xFF64748B), width: 1),
                    ),
                  ),
                ],
              ),
            ),

            // 6. VLS Missile Launch Deck Behind Bridge
            Positioned(
              left: 174,
              bottom: 44,
              width: 38,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF64748B), width: 0.8),
                ),
                child: GridView.count(
                  crossAxisCount: 4,
                  padding: const EdgeInsets.all(2),
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    8,
                    (i) => Container(
                      margin: const EdgeInsets.all(1),
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ),

            // 7. Stern Flight Deck Helipad with "H" & National Flag
            Positioned(
              right: 18,
              bottom: 44,
              width: 44,
              height: 12,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFF64748B), width: 0.8),
                    ),
                    child: const Center(
                      child: Text(
                        'Ⓗ',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Flagpole at Stern
                  Positioned(
                    right: 2,
                    top: -12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 1.5, height: 14, color: const Color(0xFFCBD5E1)),
                        Container(
                          width: 8,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(1),
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
      ),
    );
  }
}

class _ShipWakePainter extends CustomPainter {
  final double prog;
  final bool isNight;

  _ShipWakePainter({required this.prog, required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final waveOffset = math.sin(prog * 4 * math.pi) * 6.0;
    final paint = Paint()
      ..color = (isNight ? const Color(0xFF00F0FF) : Colors.white).withValues(alpha: isNight ? 0.45 : 0.65)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8 + waveOffset, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.2 - waveOffset, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);

    // Secondary foam line
    final subPaint = Paint()
      ..color = (isNight ? const Color(0xFF2DD4BF) : Colors.white70).withValues(alpha: isNight ? 0.3 : 0.4)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(10, size.height * 0.7), Offset(size.width - 20, size.height * 0.7), subPaint);
  }

  @override
  bool shouldRepaint(covariant _ShipWakePainter oldDelegate) => true;
}

/// 🏮 Coastal Lighthouse Tower on Island Edge ("Dweepu Kaaval")
/// Features stone ashlar brick body, catwalk gallery, and rotating 360° sweeping
/// searchlight beam penetrating the nighttime ocean mist.
class PresidentialCoastalLighthouseWidget extends StatelessWidget {
  final double animProg;
  final bool isNight;

  const PresidentialCoastalLighthouseWidget({
    super.key,
    required this.animProg,
    this.isNight = false,
  });

  @override
  Widget build(BuildContext context) {
    final beamAngle = animProg * 2 * math.pi;

    return SizedBox(
      width: 80,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Sweeping Searchlight Beam (Rotates across the ocean)
          Positioned(
            bottom: 96,
            child: Transform.rotate(
              angle: beamAngle,
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: const Size(180, 120),
                painter: _LighthouseBeamPainter(isNight: isNight),
              ),
            ),
          ),

          // 2. Rocky Island Cliff Outcrop Base
          Positioned(
            bottom: 0,
            child: Container(
              width: 76,
              height: 26,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF475569), width: 1.2),
              ),
            ),
          ),

          // 3. Tapered Lighthouse Tower
          Positioned(
            bottom: 22,
            child: Container(
              width: 44,
              height: 78,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                    Color(0xFFDC2626), // Classic Red Striping
                    Color(0xFFDC2626),
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                  ],
                  stops: [0.0, 0.32, 0.33, 0.65, 0.66, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border.all(color: const Color(0xFF94A3B8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),

          // 4. Lantern Room with Golden Lamp & Catwalk
          Positioned(
            bottom: 98,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cupola Roof Dome
                Container(
                  width: 32,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                ),
                // Glowing Glass Lantern Room
                Container(
                  width: 36,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE047).withValues(alpha: isNight ? 0.95 : 0.7),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: isNight ? 0.9 : 0.5),
                        blurRadius: isNight ? 22 : 10,
                        spreadRadius: isNight ? 5 : 2,
                      ),
                    ],
                  ),
                ),
                // Catwalk Railing
                Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LighthouseBeamPainter extends CustomPainter {
  final bool isNight;
  _LighthouseBeamPainter({required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, 0);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          (isNight ? const Color(0xFFFEF08A) : Colors.white).withValues(alpha: isNight ? 0.85 : 0.4),
          const Color(0xFFFACC15).withValues(alpha: isNight ? 0.4 : 0.15),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LighthouseBeamPainter oldDelegate) => false;
}

/// 🐬 Playful Leaping Ocean Dolphin ("Meenukal / Dolphins")
/// Smoothly arcs in and out of the water creating animated water droplets & splash rings.
class PresidentialLeapingDolphinWidget extends StatelessWidget {
  final double animProg;
  final bool isNight;

  const PresidentialLeapingDolphinWidget({
    super.key,
    required this.animProg,
    this.isNight = false,
  });

  @override
  Widget build(BuildContext context) {
    // Parabolic leap height (0 to 1 and back)
    final leapPhase = animProg % 1.0;
    final isJumping = leapPhase < 0.65;
    final normalizedT = isJumping ? (leapPhase / 0.65) : 0.0;
    final leapY = isJumping ? -math.sin(normalizedT * math.pi) * 38.0 : 0.0;
    final leapRot = isJumping ? (normalizedT - 0.5) * 1.4 : 0.0;

    return SizedBox(
      width: 70,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Water Splash Foam Ring
          if (isJumping && (normalizedT < 0.2 || normalizedT > 0.8))
            Positioned(
              bottom: 2,
              child: Container(
                width: 32,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (isNight ? const Color(0xFF00F0FF) : Colors.white).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isNight ? const Color(0xFF00F0FF) : const Color(0xFF38BDF8)).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

          // Animated Leaping Dolphin Body
          if (isJumping)
            Transform.translate(
              offset: Offset(0, leapY),
              child: Transform.rotate(
                angle: leapRot,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 44,
                  height: 22,
                  child: CustomPaint(
                    painter: _DolphinPainter(isNight: isNight),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DolphinPainter extends CustomPainter {
  final bool isNight;
  _DolphinPainter({required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.95, h * 0.5); // Snout
    bodyPath.quadraticBezierTo(w * 0.65, 0, w * 0.25, h * 0.35); // Arched back
    bodyPath.lineTo(0, h * 0.25); // Tail fluke upper
    bodyPath.lineTo(w * 0.08, h * 0.5); // Tail notch
    bodyPath.lineTo(0, h * 0.75); // Tail fluke lower
    bodyPath.quadraticBezierTo(w * 0.45, h * 0.95, w * 0.85, h * 0.7); // Belly
    bodyPath.close();

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? [const Color(0xFF38BDF8), const Color(0xFF0284C7), const Color(0xFF0369A1)]
            : [const Color(0xFF67E8F9), const Color(0xFF0EA5E9), const Color(0xFF0369A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(bodyPath, bodyPaint);

    // Glowing Eye
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.45),
      1.8,
      Paint()..color = isNight ? const Color(0xFF00F0FF) : Colors.white,
    );
    // Dorsal Fin
    final finPath = Path();
    finPath.moveTo(w * 0.50, h * 0.12);
    finPath.quadraticBezierTo(w * 0.42, -h * 0.25, w * 0.38, -h * 0.25);
    finPath.quadraticBezierTo(w * 0.40, 0, w * 0.36, h * 0.22);
    finPath.close();
    canvas.drawPath(finPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant _DolphinPainter oldDelegate) => false;
}

/// ✈️ Air Force Supersonic Escort Fighter Squadron ("Air Force")
/// 3 Stealth Delta-Wing Jets in tight V-Formation with twin blue afterburner plumes.
class PresidentialAirForceFighterSquadronWidget extends StatelessWidget {
  final double animProg;
  final bool isNight;

  const PresidentialAirForceFighterSquadronWidget({
    super.key,
    required this.animProg,
    this.isNight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lead Fighter Jet
          Positioned(
            left: 55,
            top: 0,
            child: _buildFighterJet(scale: 1.0),
          ),
          // Left Wingman
          Positioned(
            left: 10,
            top: 26,
            child: _buildFighterJet(scale: 0.85),
          ),
          // Right Wingman
          Positioned(
            left: 95,
            top: 26,
            child: _buildFighterJet(scale: 0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildFighterJet({double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 38,
        height: 34,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Twin Neon Blue Afterburner Exhaust Plumes
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3.5,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 3.5,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            // Delta Wing Jet Body
            CustomPaint(
              size: const Size(36, 26),
              painter: _JetPainter(isNight: isNight),
            ),
          ],
        ),
      ),
    );
  }
}

class _JetPainter extends CustomPainter {
  final bool isNight;
  _JetPainter({required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, 0); // Needle nose
    path.lineTo(w * 0.6, h * 0.45);
    path.lineTo(w, h * 0.85); // Right wingtip
    path.lineTo(w * 0.65, h * 0.82);
    path.lineTo(w * 0.58, h);
    path.lineTo(w * 0.42, h);
    path.lineTo(w * 0.35, h * 0.82);
    path.lineTo(0, h * 0.85); // Left wingtip
    path.lineTo(w * 0.4, h * 0.45);
    path.close();

    final paint = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF64748B)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Jet Outline & Cockpit Glass
    final stroke = Paint()
      ..color = isNight ? const Color(0xFF38BDF8).withValues(alpha: 0.6) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, stroke);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.35), width: 4.5, height: 9),
      Paint()..color = const Color(0xFF38BDF8),
    );
  }

  @override
  bool shouldRepaint(covariant _JetPainter oldDelegate) => false;
}
