import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_language_selection_dialog.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 🧸 Dedicated Kids Universe Home Foundation
///
/// Features:
/// 1. 100% Isolated from Adult universe (no adult chats, calls, or complex grammar).
/// 2. Cheerful, high-dopamine, bright sky cartoon atmosphere.
/// 3. Profile header with kid's chosen mascot avatar & stars count.
/// 4. Clean blank-canvas playground ready for upcoming 2D kids games & islands.
/// 5. Parental Gate (math challenge) for switching back to adult mode.
class PocketKidsHomePage extends StatefulWidget {
  const PocketKidsHomePage({super.key});

  static const String routeName = 'PocketKidsHome';
  static const String routePath = '/pocket_kids_home';

  static Future<void> launch(BuildContext context) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PocketKidsHomePage()),
    );
  }

  @override
  State<PocketKidsHomePage> createState() => _PocketKidsHomePageState();
}

class _PocketKidsHomePageState extends State<PocketKidsHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _showParentalGate(BuildContext context) {
    final rand = math.Random();
    final a = rand.nextInt(5) + 3; // 3 to 7
    final b = rand.nextInt(5) + 2; // 2 to 6
    final correctAnswer = a + b;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🔒 ', style: TextStyle(fontSize: 22)),
              Text(
                'Parental Gate',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For parents only. Please solve this question to switch to Adult Mode:',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$a + $b = ?',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter answer',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'CANCEL',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final ans = int.tryParse(controller.text.trim());
                if (ans == correctAnswer) {
                  Navigator.pop(ctx);
                  await PocketKidsService.activateAdultAccount();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePageWidget()),
                    );
                  }
                } else {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect answer. Try again!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(
                'SWITCH TO ADULT ➔',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kidName = PocketKidsService.kidName;
    final kidAvatar = PocketKidsService.kidAvatar;
    final kidStars = PocketKidsService.kidStars;
    final lang = PocketLanguageService.currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFF0C192E),
      body: Stack(
        children: [
          // Background Gradient (Playful Sky)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0369A1), // Bright sky deep
                  Color(0xFF0F172A), // Dark galaxy navy
                ],
              ),
            ),
          ),

          // Floating Cartoon Stars & Cloud Bubbles
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: 0.15,
              child: Text('☁️', style: TextStyle(fontSize: 80)),
            ),
          ),
          Positioned(
            top: 120,
            right: 30,
            child: Opacity(
              opacity: 0.2,
              child: Text('⭐', style: TextStyle(fontSize: 45)),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 40,
            child: Opacity(
              opacity: 0.15,
              child: Text('🎈', style: TextStyle(fontSize: 60)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🌟 TOP HUD BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Kid Avatar & Name Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Text(kidAvatar, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              kidName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Stars Counter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '$kidStars',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Language Switcher Badge
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showDialog(
                            context: context,
                            builder: (ctx) => PocketLanguageSelectionDialog(currentLanguage: lang),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Row(
                            children: [
                              const Text('🌐', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                lang,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Parental Gate Button
                      IconButton(
                        tooltip: 'Parent Zone',
                        icon: const Icon(Icons.settings_suggest_rounded, color: Colors.white70),
                        onPressed: () => _showParentalGate(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🧸 MAIN KIDS PLAYGROUND CANVAS
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        // Cheerful Mascot Welcome Card
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            final dy = math.sin(_floatController.value * math.pi) * 6;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF38BDF8),
                                  Color(0xFF6366F1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  kidAvatar,
                                  style: const TextStyle(fontSize: 64),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'POCKET KIDS UNIVERSE',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Welcome, $kidName! 🌟',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Your 100% Fun 2D Learning World is Ready to Build!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Blank Canvas Placeholder for Upcoming Kids Games
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                              width: 1.8,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text('🏝️', style: TextStyle(fontSize: 28)),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Kids 2D Playground Canvas',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ഇവിടെ കുട്ടികൾക്ക് അനുയോജ്യമായ 2D ഗെയിമുകളും അഡ്വഞ്ചർ ഐലൻഡുകളും നിർമ്മിക്കാം.\n\nReady for research & custom game planning!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildKidsFeaturePill('🔤 Phonics Island'),
                                  _buildKidsFeaturePill('🦁 Animal Safari'),
                                  _buildKidsFeaturePill('🎨 Color Magic'),
                                  _buildKidsFeaturePill('🍎 Yummy Vocab'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Switch Mode Info Pill
                        GestureDetector(
                          onTap: () => _showParentalGate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Parent Zone • Switch to Adult Track',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKidsFeaturePill(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: const Color(0xFFE2E8F0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
