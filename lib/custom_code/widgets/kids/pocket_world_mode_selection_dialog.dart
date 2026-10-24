import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 🌐 Modal Dialog for seamlessly selecting between Kids World (KS), Student World (SS), and Adult Mode (PS)
class PocketWorldModeSelectionDialog extends StatelessWidget {
  const PocketWorldModeSelectionDialog({super.key});

  /// Opens the World Selection Modal immediately without blocking preliminary checks
  static Future<void> show(BuildContext context) async {
    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (_) => const PocketWorldModeSelectionDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKids = PocketKidsService.isKidsWorld;
    final isStudent = PocketKidsService.isStudentWorld;
    final isAdult = PocketKidsService.isAdultWorld;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
          maxWidth: 420,
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select your tailored English atmosphere and experience:',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // =============================================================
              // Card 1: 👶 KIDS WORLD (Ages 4–8)
              // =============================================================
              _buildWorldCard(
                context,
                emoji: '👶',
                title: 'KIDS WORLD',
                scoreBadge: 'KS SCORE',
                badgeColor: const Color(0xFFFFD700),
                badgeTextColor: const Color(0xFF78350F),
                gradientColors: const [Color(0xFF0369A1), Color(0xFF075985)],
                borderColor: const Color(0xFF38BDF8),
                description:
                    'Ages 4–8 • Phonics, Balloon Pop, Cartoon Village, Letter Train, Star Cookies & Mascot Playdates (Zero Text Chat)',
                isActive: isKids,
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                  if (isKids) return;

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
              ),

              const SizedBox(height: 12),

              // =============================================================
              // Card 2: 🎒 STUDENT WORLD (Ages 9–16)
              // =============================================================
              _buildWorldCard(
                context,
                emoji: '🎒',
                title: 'STUDENT WORLD',
                scoreBadge: 'SS SCORE',
                badgeColor: const Color(0xFF6366F1),
                badgeTextColor: Colors.white,
                gradientColors: const [Color(0xFF312E81), Color(0xFF1E1B4B)],
                borderColor: const Color(0xFF818CF8),
                description:
                    'Ages 9–16 • Student English Hub, 100-Day Mountain Trail, Assembly Speech, PopArt Hero Cards, Citadel Fights & Student Chat',
                isActive: isStudent,
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                  if (isStudent) return;

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
                    PocketKidsHomePage.launch(context,
                        promptProfileSetup: false);
                  }
                },
              ),

              const SizedBox(height: 12),

              // =============================================================
              // Card 3: 🛡️ ADULT MODE (17+)
              // =============================================================
              _buildWorldCard(
                context,
                emoji: '🛡️',
                title: 'ADULT MODE',
                scoreBadge: 'PS SCORE',
                badgeColor: const Color(0xFF10B981),
                badgeTextColor: const Color(0xFF064E3B),
                gradientColors: const [Color(0xFF1E293B), Color(0xFF0F172A)],
                borderColor: const Color(0xFF34D399),
                description:
                    '17+ • Real-World Mates Chat, Citadel Attack Raids, English Hub & Sovereign World Ranking',
                isActive: isAdult,
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  if (isAdult) {
                    Navigator.pop(context);
                    return;
                  }

                  // Switching from child mode to adult mode requires parental pattern lock
                  final unlocked = await PocketParentalPatternLock.verifyOrSetup(
                    context,
                    title: 'Parent Verification 🔒',
                    subtitle: 'Draw pattern lock to return to Adult Mode.',
                  );
                  if (unlocked && context.mounted) {
                    Navigator.pop(context);
                    await PocketKidsService.activateAdultAccount();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const HomePageWidget()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 14),

              // Parental Pattern Lock footer notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded,
                      color: Color(0xFF64748B), size: 14),
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
      ),
    );
  }

  Widget _buildWorldCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String scoreBadge,
    required Color badgeColor,
    required Color badgeTextColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required String description,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFFFD700) : borderColor,
            width: isActive ? 2.2 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? const Color(0xFFFFD700) : borderColor)
                  .withValues(alpha: isActive ? 0.35 : 0.20),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.4),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          scoreBadge,
                          style: GoogleFonts.outfit(
                            color: badgeTextColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF10B981), width: 1),
                          ),
                          child: Text(
                            'ACTIVE NOW',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF34D399),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: isActive ? const Color(0xFFFFD700) : borderColor,
              size: isActive ? 18 : 15,
            ),
          ],
        ),
      ),
    );
  }
}
