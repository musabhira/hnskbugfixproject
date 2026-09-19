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
