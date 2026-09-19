import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🪖 Army Soldier Guard ("പട്ടാളക്കാർ")
/// Elite Armed Forces guarding the Presidential Sovereign Citadel
class ArmySoldierGuardWidget extends StatelessWidget {
  final bool isLeft;
  final String? vocalText;

  const ArmySoldierGuardWidget({
    super.key,
    this.isLeft = false,
    this.vocalText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Military Radio / Alert Dialogue
        if (vocalText != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF142414).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4ADE80), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪖', style: TextStyle(fontSize: 9)),
                const SizedBox(width: 4),
                Text(
                  vocalText!,
                  style: GoogleFonts.sourceCodePro(
                    color: const Color(0xFF86EFAC),
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Camouflage Military Ballistic Helmet
        Container(
          width: 22,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF2D4A22),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: const Color(0xFF1E3316), width: 1.0),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              height: 2.5,
              color: const Color(0xFF142414),
            ),
          ),
        ),

        // Soldier Face & Tactical Goggles
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 14,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDFBA),
                shape: BoxShape.circle,
              ),
            ),
            // Tactical Smoke Goggles
            Container(
              width: 13,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF475569), width: 0.6),
              ),
            ),
          ],
        ),

        // Combat Uniform Torso + Webbing Harness + Assault Rifle
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLeft) ...[
              // Assault Rifle held at Low Ready
              _buildAssaultRifle(),
              const SizedBox(width: 2),
            ],

            // Olive Combat Fatigue Torso
            Container(
              width: 24,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFF3F6212),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF2D4A22), width: 0.8),
              ),
              child: Stack(
                children: [
                  // Tactical Chest Rig Straps
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 3, color: const Color(0xFF1E3316)),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 3, color: const Color(0xFF1E3316)),
                  ),
                  // Ammo Magazine Pouches
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 4, height: 6, color: const Color(0xFF142414)),
                          const SizedBox(width: 2),
                          Container(width: 4, height: 6, color: const Color(0xFF142414)),
                          const SizedBox(width: 2),
                          Container(width: 4, height: 6, color: const Color(0xFF142414)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isLeft) ...[
              const SizedBox(width: 2),
              // Assault Rifle
              _buildAssaultRifle(),
            ],
          ],
        ),

        // Camo Combat Pants
        Container(width: 18, height: 16, color: const Color(0xFF2D4A22)),

        // Heavy Combat Boots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 6, color: const Color(0xFF0A0F1D)),
            const SizedBox(width: 2),
            Container(width: 8, height: 6, color: const Color(0xFF0A0F1D)),
          ],
        ),
      ],
    );
  }

  Widget _buildAssaultRifle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flash Hider / Barrel
        Container(width: 2, height: 12, color: const Color(0xFF64748B)),
        // Handguard & Receiver
        Container(width: 4, height: 16, color: const Color(0xFF0F172A)),
        // Curved 30-round Magazine
        Container(width: 5, height: 8, color: const Color(0xFF334155)),
        // Tactical Stock
        Container(width: 3.5, height: 8, color: const Color(0xFF1E293B)),
      ],
    );
  }
}

/// 👮 Police Officer Guard ("പോലീസുകാർ")
/// Official Police Law Enforcement Guarding the Citadel Perimeter
class PoliceOfficerGuardWidget extends StatelessWidget {
  final bool isLeft;
  final String? vocalText;

  const PoliceOfficerGuardWidget({
    super.key,
    this.isLeft = false,
    this.vocalText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Police Vocal Alert
        if (vocalText != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF081C3D).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚔', style: TextStyle(fontSize: 9)),
                const SizedBox(width: 4),
                Text(
                  vocalText!,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFBAE6FD),
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Peaked Police Officer Cap with Gold Crest Badge
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Crown of Cap
            Container(
              width: 22,
              height: 11,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            // Visor
            Positioned(
              bottom: -1.5,
              child: Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Gold Police Badge Star
            Positioned(
              top: 2,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        // Face
        Container(
          width: 14,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDFBA),
            shape: BoxShape.circle,
          ),
        ),

        // Dark Navy Police Service Tunic + Yellow High-Vis Sash + Shoulder Radio
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLeft) ...[
              // Nightstick / Baton
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 2.5, height: 18, color: Colors.black),
                  Container(width: 4, height: 4, color: const Color(0xFF475569)),
                ],
              ),
              const SizedBox(width: 2),
            ],

            Container(
              width: 23,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Gold Police Chest Shield Badge
                  Positioned(
                    left: 3,
                    top: 3,
                    child: Container(
                      width: 4,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                  // Yellow High-Vis Reflective Cross-Strap
                  Positioned(
                    right: 4,
                    top: 2,
                    bottom: 2,
                    child: Container(
                      width: 3.5,
                      color: const Color(0xFFFACC15),
                    ),
                  ),
                  // Duty Belt
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 23,
                      height: 4,
                      color: Colors.black,
                      child: Center(
                        child: Container(width: 4, height: 3, color: const Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isLeft) ...[
              const SizedBox(width: 2),
              // Nightstick
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 2.5, height: 18, color: Colors.black),
                  Container(width: 4, height: 4, color: const Color(0xFF475569)),
                ],
              ),
            ],
          ],
        ),

        // Navy Blue Uniform Trousers
        Container(width: 17, height: 16, color: const Color(0xFF0F172A)),

        // Polished Black Duty Shoes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 5, color: Colors.black),
            const SizedBox(width: 2),
            Container(width: 8, height: 5, color: Colors.black),
          ],
        ),
      ],
    );
  }
}

/// 🚓 Police Interceptor Patrol Car ("പോലീസ് വാഹനം")
/// High-Speed Escort Patrol Cruiser with Flashing Blue/Red Emergency Lightbar
class PoliceInterceptorCarWidget extends StatelessWidget {
  final double animProg;

  const PoliceInterceptorCarWidget({super.key, required this.animProg});

  @override
  Widget build(BuildContext context) {
    // Alternating High-Frequency Police Strobes
    final strobe = math.sin(animProg * 16 * math.pi);
    final isBlueFlash = strobe > 0;

    return SizedBox(
      width: 126,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ground Shadow
          Positioned(
            left: 6,
            right: 6,
            bottom: 0,
            height: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // 🚨 High-Intensity Alternating Blue & Red Police Roof Lightbar
          Positioned(
            left: 48,
            top: 0,
            child: Container(
              width: 30,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF475569), width: 0.8),
              ),
              child: Row(
                children: [
                  // Blue LED Strobe
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isBlueFlash ? const Color(0xFF00BFFF) : const Color(0xFF0369A1),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                        boxShadow: isBlueFlash
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00BFFF).withValues(alpha: 0.9),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  // Siren Center
                  Container(width: 4, color: Colors.white70),
                  // Red LED Strobe
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isBlueFlash ? const Color(0xFFFF2222) : const Color(0xFF991B1B),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                        boxShadow: !isBlueFlash
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF2222).withValues(alpha: 0.9),
                                  blurRadius: 10,
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
          ),

          // Police Cruiser Body: Black & White Livery
          Positioned(
            left: 6,
            top: 14,
            width: 114,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B1120),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFF334155), width: 1.0),
              ),
              child: Stack(
                children: [
                  // White Police Door Center Panel
                  Positioned(
                    left: 28,
                    width: 58,
                    top: 1,
                    bottom: 1,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 6)),
                            const SizedBox(width: 2),
                            Text(
                              'POLICE',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Headlights
                  Positioned(
                    left: 2,
                    top: 6,
                    child: Container(
                      width: 5,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFEF08A).withValues(alpha: 0.8),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tail Lights
                  Positioned(
                    right: 2,
                    top: 6,
                    child: Container(
                      width: 4,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cabin Roof & Windshields
          Positioned(
            left: 26,
            top: 5,
            width: 74,
            height: 12,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  // Windshield
                  Container(
                    width: 14,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // Side Windows
                  Expanded(
                    child: Container(
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // Front Steel Push Bumper (Bull-Bar)
          Positioned(
            left: 2,
            top: 15,
            child: Container(
              width: 5,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Wheels
          Positioned(
            left: 18,
            bottom: 0,
            child: _buildPoliceWheel(),
          ),
          Positioned(
            right: 18,
            bottom: 0,
            child: _buildPoliceWheel(),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliceWheel() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF64748B), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
