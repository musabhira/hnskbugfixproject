import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_language_selection_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_game_session_page.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 🧸 Dedicated Kids Universe Home Page
///
/// Features:
/// 1. 100% Isolated Kids UI (No adult chat, no calls, no complex adult features).
/// 2. 100-Day Winding Adventure Mountain Trail with Day 1 - Day 100 targets.
/// 3. Achievable Homestead / Playhouse Showcase (Treehouse, Candy Cottage, Dino Den, Sky Castle).
/// 4. Tap-to-play interactive 2D Kids Games with TTS voiceover and balloon popping.
/// 5. Parental Gate (Math lock) for switching back to adult mode.
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
  late AnimationController _bounceController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Auto-scroll near the current unlocked day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final curDay = PocketKidsService.currentUnlockedDay;
      final targetScroll = (curDay - 1) * 85.0;
      if (_scrollController.hasClients && targetScroll > 200) {
        _scrollController.animateTo(
          (targetScroll - 150).clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scrollController.dispose();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$a + $b = ',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '?',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
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
                foregroundColor: const Color(0xFF0F172A),
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

  void _onTapDayNode(int day) {
    final unlockedDay = PocketKidsService.currentUnlockedDay;
    if (day > unlockedDay) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🔒 ', style: TextStyle(fontSize: 16)),
              Text(
                'Complete Day $unlockedDay first to unlock Day $day! 🌟',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsGameSessionPage(day: day),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final kidName = PocketKidsService.kidName;
    final kidAvatar = PocketKidsService.kidAvatar;
    final kidStars = PocketKidsService.kidStars;
    final lang = PocketLanguageService.currentLanguage;
    final currentHouse = PocketKidsService.currentHouse;
    final unlockedDay = PocketKidsService.currentUnlockedDay;
    final completedDays = PocketKidsService.completedDays;

    return Scaffold(
      backgroundColor: const Color(0xFF0369A1),
      body: Stack(
        children: [
          // Background Cartoon Mountain Sky Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF38BDF8), // Morning sky
                  Color(0xFF67E8F9), // Soft cyan
                  Color(0xFF86EFAC), // Green valley
                  Color(0xFF4ADE80), // Deep emerald hill
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),

          // Floating background clouds and balloons
          Positioned(
            top: 60,
            left: 20,
            child: Opacity(
              opacity: 0.3,
              child: const Text('☁️', style: TextStyle(fontSize: 80)),
            ),
          ),
          Positioned(
            top: 140,
            right: 25,
            child: Opacity(
              opacity: 0.25,
              child: const Text('🎈', style: TextStyle(fontSize: 60)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🌟 TOP HUD BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Mascot Avatar & Kid Name
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(kidAvatar,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              kidName,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Stars Counter Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 5),
                            Text(
                              '$kidStars',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Language Switcher
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showDialog(
                            context: context,
                            builder: (ctx) => PocketLanguageSelectionDialog(
                                currentLanguage: lang),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Text('🌐', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                lang,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Parental Gate
                      IconButton(
                        tooltip: 'Parent Zone',
                        icon: const Icon(Icons.settings_suggest_rounded,
                            color: Colors.white, size: 26),
                        onPressed: () => _showParentalGate(context),
                      ),
                    ],
                  ),
                ),

                // 🏡 ACHIEVED HOMESTEAD / PLAYHOUSE BANNER
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // House Mascot
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: currentHouse.themeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(currentHouse.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentHouse.title,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: currentHouse.themeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'TIER ${currentHouse.tier}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentHouse.description,
                              style: GoogleFonts.inter(
                                color: Colors.black54,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress to next house
                      Column(
                        children: [
                          Text(
                            'Day $unlockedDay/100',
                            style: GoogleFonts.outfit(
                              color: currentHouse.themeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Level Up!',
                            style: GoogleFonts.inter(
                              color: Colors.black45,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // 🗺️ 100-DAY TARGET ADVENTURE MOUNTAIN MAP
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      final dayNumber = index + 1;
                      final isUnlocked = dayNumber <= unlockedDay;
                      final isCurrent = dayNumber == unlockedDay;
                      final starsEarned = completedDays[dayNumber] ?? 0;

                      // Sine-wave offset for natural winding trail
                      final double horizontalShift =
                          math.sin(index * 0.7) * 75;

                      return Column(
                        children: [
                          // Zone Milestone Header at zone boundaries
                          if (dayNumber == 1)
                            _buildZoneHeader('🎈 ZONE 1: ABC BALLOON VALLEY',
                                'Learn letters, sounds & phonics (Days 1–15)'),
                          if (dayNumber == 16)
                            _buildZoneHeader('🐾 ZONE 2: ANIMAL SAFARI WORDS',
                                'Explore animal names & jungle sounds (Days 16–30)'),
                          if (dayNumber == 31)
                            _buildZoneHeader('🎨 ZONE 3: COLORS & NUMBERS CASTLE',
                                'Discover magical rainbow colors & counting (Days 31–45)'),
                          if (dayNumber == 46)
                            _buildZoneHeader('🍎 ZONE 4: YUMMY FOOD ORCHARD',
                                'Delicious fruits, veggies & treats (Days 46–60)'),
                          if (dayNumber == 61)
                            _buildZoneHeader('⚽ ZONE 5: ACTION & PLAYGROUND',
                                'Action verbs, sports & body parts (Days 61–75)'),
                          if (dayNumber == 76)
                            _buildZoneHeader('📖 ZONE 6: MAGICAL STORY PEAK',
                                'Champion mini-dialogues & sentences (Days 76–100)'),

                          // Winding connector stepping trail dots
                          if (dayNumber > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: Offset(horizontalShift * 0.5, 0),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isUnlocked
                                                ? const Color(0xFFFFD700)
                                                : Colors.white30,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isUnlocked
                                                ? const Color(0xFFFFD700)
                                                : Colors.white30,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Target Day Node
                          Transform.translate(
                            offset: Offset(horizontalShift, 0),
                            child: Center(
                              child: GestureDetector(
                                onTap: () => _onTapDayNode(dayNumber),
                                child: isCurrent
                                    ? AnimatedBuilder(
                                        animation: _bounceController,
                                        builder: (context, child) {
                                          final bounce = math.sin(
                                                  _bounceController.value *
                                                      math.pi) *
                                              6;
                                          return Transform.translate(
                                            offset: Offset(0, -bounce),
                                            child: child,
                                          );
                                        },
                                        child: _buildDayNodeWidget(
                                          dayNumber: dayNumber,
                                          isUnlocked: true,
                                          isCurrent: true,
                                          stars: starsEarned,
                                        ),
                                      )
                                    : _buildDayNodeWidget(
                                        dayNumber: dayNumber,
                                        isUnlocked: isUnlocked,
                                        isCurrent: false,
                                        stars: starsEarned,
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDayNodeWidget({
    required int dayNumber,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
  }) {
    if (isCurrent) {
      // Current active pulsing node
      return Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DAY $dayNumber',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Icon(Icons.play_arrow_rounded,
                color: Color(0xFF0F172A), size: 28),
            Text(
              'PLAY',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    if (isUnlocked) {
      // Completed node with stars
      return Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Text(
                  '⭐',
                  style: TextStyle(
                    fontSize: 9,
                    color: i < (stars > 0 ? stars : 3)
                        ? const Color(0xFFFFD700)
                        : Colors.white30,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Locked future node
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.75),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, color: Colors.white38, size: 18),
          const SizedBox(height: 2),
          Text(
            '$dayNumber',
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
