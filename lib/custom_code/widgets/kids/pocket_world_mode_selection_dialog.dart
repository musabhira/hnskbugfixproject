import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';

/// 🌐 Modal Dialog for selecting between Student World (SS) and Kids World (KS)
class PocketWorldModeSelectionDialog extends StatelessWidget {
  const PocketWorldModeSelectionDialog({super.key});

  static Future<void> show(BuildContext context) async {
    // 1. Ensure Parental Pattern Lock is established before entering child modes
    final hasPattern = await PocketParentalPatternLock.hasPattern();
    if (!hasPattern && context.mounted) {
      final setSuccess = await PocketParentalPatternLock.showSetupDialog(
        context,
        title: 'Set Parental Pattern Lock 🔒',
        subtitle: 'Draw a 3x3 pattern. You will need this to return to Adult Mode.',
      );
      if (!setSuccess) return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => const PocketWorldModeSelectionDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🌐', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Choose Your World',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select the tailored English experience for your child:',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 18),

            // Card 1: 🎒 STUDENT WORLD (Ages 9–16)
            GestureDetector(
              onTap: () async {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                await PocketKidsService.activateStudentAccount(
                  name: PocketKidsService.kidName.isNotEmpty
                      ? PocketKidsService.kidName
                      : 'Student Explorer',
                  ageGroup: '9-12',
                  avatar: PocketKidsService.kidAvatar.isNotEmpty
                      ? PocketKidsService.kidAvatar
                      : '🦁',
                  isParentSwitched: true,
                );
                if (context.mounted) {
                  PocketKidsHomePage.launch(context, promptProfileSetup: false);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF818CF8), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF818CF8).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF818CF8), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🎒', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'STUDENT WORLD',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SS SCORE',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Ages 9–16 • PopArt Hero Cards, Citadel Fights, Assembly Speech & Student Chat',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFC7D2FE),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF818CF8), size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Card 2: 👶 KIDS WORLD (Ages 4–8)
            GestureDetector(
              onTap: () async {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                await PocketKidsService.activateKidAccount(
                  name: PocketKidsService.kidName.isNotEmpty
                      ? PocketKidsService.kidName
                      : 'Little Explorer',
                  ageGroup: '4-6',
                  avatar: PocketKidsService.kidAvatar.isNotEmpty
                      ? PocketKidsService.kidAvatar
                      : '🦁',
                  isParentSwitched: true,
                );
                if (context.mounted) {
                  PocketPureKidsHomePage.launch(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF075985), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text('👶', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'KIDS WORLD',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'KS SCORE',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF78350F),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Ages 4–8 • Phonics, Balloon Pop, Letter Train, Mascot Playdates & Star Cookies',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFBAE6FD),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Parental Lock Notice
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 5),
                Text(
                  'Protected by Parental Pattern Lock',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
