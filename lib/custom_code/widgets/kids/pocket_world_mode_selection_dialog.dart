import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_profile_setup_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/app_store_review_service.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 🌐 Modal Dialog for seamlessly selecting between Kids World (KS), Student World (SS), and Adult Mode (PS)
/// User Audio Directive:
/// "ഒരു മെയിലിൽ ആണ് അഡൽറ്റും കിഡ്സും അതുപോലെ സ്റ്റുഡന്റൊക്കെ വരുന്നത്...
/// ഒരു പാരൻ്റ് അക്കൗണ്ട് ക്രിയേറ്റ് ചെയ്തു കഴിഞ്ഞാൽ അവർക്ക് അഡൽറ്റിലേക്ക് സ്വിച്ച് ചെയ്യാം... കിഡ്സിലേക്ക് സ്വിച്ച് ചെയ്യാം.
/// പക്ഷെ കിഡ് ആയിട്ട് തുടങ്ങിയിട്ടുണ്ടെങ്കിൽ അവർക്ക് അഡൽറ്റിലേക്കോ സ്റ്റുഡന്റിലേക്കോ പോകാൻ പറ്റില്ല.
/// സ്റ്റുഡന്റ് ആയിട്ട് തുടങ്ങിയതാണെങ്കിൽ അഡൽറ്റിലേക്ക് പോകാൻ പറ്റില്ല പക്ഷെ കിഡ്സിലേക്ക് വരാൻ പറ്റും. അത് നോക്കണം."
class PocketWorldModeSelectionDialog extends StatelessWidget {
  const PocketWorldModeSelectionDialog({super.key});

  /// Opens the World Selection Modal immediately without blocking preliminary checks
  static Future<void> show(BuildContext context) async {
    if (!AppStoreReviewService.isWorldSwitchVisible) return;
    if (context.mounted) {
      return showDialog(
        context: context,
        builder: (_) => const PocketWorldModeSelectionDialog(),
      );
    }
  }

  void _showRestrictionToast(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKids = PocketKidsService.isKidsWorld;
    final isStudent = PocketKidsService.isStudentWorld;
    final isAdult = PocketKidsService.isAdultWorld;

    final canEnterStudent = PocketKidsService.canEnterStudentWorld;
    final canEnterAdult = PocketKidsService.canExitToAdultAccount;

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
              // Card 1: 👶 KIDS WORLD (Ages 4–8) - Accessible by all roles!
              // =============================================================
              _buildWorldCard(
                context,
                emoji: '👶',
                title: 'KIDS WORLD',
                subtitle: 'Ages 4–8',
                gradientColors: const [Color(0xFF0369A1), Color(0xFF075985)],
                borderColor: const Color(0xFF38BDF8),
                description:
                    'Phonics, Balloon Pop, Cartoon Village, Letter Tracing, Past/Present/Future & Falling Blocks',
                isActive: isKids,
                isLocked: false,
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  if (isKids) {
                    Navigator.pop(context);
                    return;
                  }

                  // 🔒 Parental Gate Lock Check:
                  // Switching from Adult Mode to Kids Mode REQUIRES configuring the pattern lock first!
                  final hasPattern = await PocketParentalPatternLock.hasPattern();
                  if (!hasPattern) {
                    if (!context.mounted) return;
                    final setupOk = await PocketParentalPatternLock.showSetupDialog(
                      context,
                      title: 'Set Parental Lock First 🔒',
                      subtitle: 'Create your 3x3 pattern lock now so only you can switch back to Adult Mode.',
                    );
                    if (!setupOk) {
                      if (context.mounted) {
                        _showRestrictionToast(context, 'Parental pattern lock is required to enter Kids Mode 🔒');
                      }
                      return;
                    }
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  if (PocketKidsService.kidName.isEmpty ||
                      PocketKidsService.kidName == 'Little Explorer') {
                    if (context.mounted) {
                      PocketKidsProfileSetupDialog.show(context);
                    }
                  } else {
                    await PocketKidsService.activateKidAccount(
                      name: PocketKidsService.kidName,
                      ageGroup: '4-6',
                      avatar: PocketKidsService.kidAvatar.isNotEmpty
                          ? PocketKidsService.kidAvatar
                          : '🦁',
                      isParentSwitched: true,
                    );
                    if (context.mounted) {
                      PocketPureKidsHomePage.launch(context);
                    }
                  }
                },
              ),

              const SizedBox(height: 10),

              // =============================================================
              // Card 2: 🎒 STUDENT WORLD (Ages 9–16) - Blocked for Pure Kids!
              // =============================================================
              _buildWorldCard(
                context,
                emoji: '🎒',
                title: 'STUDENT WORLD',
                subtitle: 'Ages 9–16',
                gradientColors: const [Color(0xFF312E81), Color(0xFF1E1B4B)],
                borderColor: const Color(0xFF818CF8),
                description:
                    'Student English Hub, 100-Day Mountain Trail, Assembly Speech, PopArt Cards & Citadel Fights',
                isActive: isStudent,
                isLocked: !canEnterStudent,
                onTap: () async {
                  if (!canEnterStudent) {
                    _showRestrictionToast(context,
                        'Kid accounts cannot switch to Student Mode 🔒');
                    return;
                  }

                  HapticFeedback.heavyImpact();
                  if (isStudent) {
                    Navigator.pop(context);
                    return;
                  }

                  // 🔒 Parental Gate Lock Check:
                  // Switching from Adult Mode to Student Mode REQUIRES configuring the pattern lock first!
                  final hasPattern = await PocketParentalPatternLock.hasPattern();
                  if (!hasPattern) {
                    if (!context.mounted) return;
                    final setupOk = await PocketParentalPatternLock.showSetupDialog(
                      context,
                      title: 'Set Parental Lock First 🔒',
                      subtitle: 'Create your 3x3 pattern lock now so only you can return to Adult Mode.',
                    );
                    if (!setupOk) {
                      if (context.mounted) {
                        _showRestrictionToast(context, 'Parental pattern lock is required to enter Student Mode 🔒');
                      }
                      return;
                    }
                  }

                  if (!context.mounted) return;
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
                    PocketKidsHomePage.launch(context,
                        promptProfileSetup: false);
                  }
                },
              ),

              const SizedBox(height: 10),

              // =============================================================
              // Card 3: 🛡️ ADULT MODE (17+) - Blocked for Pure Kids & Students!
              // =============================================================
              _buildWorldCard(
                context,
                emoji: '🛡️',
                title: 'ADULT MODE',
                subtitle: '17+',
                gradientColors: const [Color(0xFF1E293B), Color(0xFF0F172A)],
                borderColor: const Color(0xFF34D399),
                description:
                    'Real-World Mates Chat, Citadel Attack Raids, English Hub & Sovereign World Ranking',
                isActive: isAdult,
                isLocked: !canEnterAdult,
                onTap: () async {
                  if (!canEnterAdult) {
                    _showRestrictionToast(
                      context,
                      PocketKidsService.isPureKidAccount
                          ? 'Kid accounts cannot switch to Adult Mode 🔒'
                          : 'Student accounts cannot switch to Adult Mode 🔒',
                    );
                    return;
                  }

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
                    'Protected by Parental Security Locks',
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
    required String subtitle,
    required List<Color> gradientColors,
    required Color borderColor,
    required String description,
    required bool isActive,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFFD700)
                : (isLocked
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : borderColor.withValues(alpha: 0.6)),
            width: isActive ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? const Color(0xFFFFD700) : borderColor)
                  .withValues(alpha: isActive ? 0.30 : 0.15),
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Opacity(
          opacity: isLocked ? 0.65 : 1.0,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.redAccent.withValues(alpha: 0.22)
                      : borderColor.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isLocked ? Colors.redAccent : borderColor,
                      width: 1.2),
                ),
                alignment: Alignment.center,
                child: Text(isLocked ? '🔒' : emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? Colors.redAccent.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLocked ? 'LOCKED 🔒' : subtitle,
                              style: GoogleFonts.outfit(
                                color: isLocked
                                    ? const Color(0xFFFCA5A5)
                                    : Colors.white70,
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 10.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isActive
                    ? Icons.check_circle_rounded
                    : (isLocked
                        ? Icons.lock_outline_rounded
                        : Icons.arrow_forward_ios_rounded),
                color: isActive
                    ? const Color(0xFFFFD700)
                    : (isLocked ? Colors.redAccent : Colors.white38),
                size: isActive ? 20 : 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
