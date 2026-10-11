import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_game_session_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mates_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_certificate_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_homes_showcase_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_study_tools_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_settings_page.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 🧸 Dedicated Kids Adventure Mountain Roadmap Page
///
/// Features:
/// 1. 100% Pure Kids Games & Cartoons (No futuristic UI, no adult theory, no chat).
/// 2. Ascending 100-Day Mountain Road:
///    - Day 1 begins at the bottom base camp (Flower Meadow).
///    - Kids climb upwards ("keri keri ponapole") to Day 100 at the Golden Summit Castle.
/// 3. S-curve winding cartoon stepping stone trail with candy-themed biomes.
/// 4. Kid's Mascot Avatar standing right on their active node with bouncing animations.
/// 5. Milestone playhouses positioned right along the climbing trail.
/// 6. Auto-positions directly at the active day node on initial launch.
/// 7. Tapping any active day node launches a full, delightful 2D cartoon mini-game session.
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
  int _currentTab = 0; // 0 = Trail, 1 = Homes, 2 = Tools, 3 = Settings

  static const int _totalDays = 100;
  static const double _nodeSpacingY = 115.0;
  static const double _topPadding = 360.0; // Day 100 Summit Golden Castle
  static const double _bottomPadding = 260.0; // Day 1 Basecamp

  double get _totalCanvasHeight =>
      _topPadding + ((_totalDays - 1) * _nodeSpacingY) + _bottomPadding;

  double _getNodeY(int day) {
    final int daysFromTop = _totalDays - day;
    return _topPadding + (daysFromTop * _nodeSpacingY);
  }

  double _getNodeX(int day, double screenWidth) {
    final center = screenWidth / 2;
    final maxAmp = ((screenWidth - 140) / 2).clamp(42.0, 110.0);
    // Smooth winding cartoon S-curve
    final wave = math.sin(day * 0.52) * maxAmp;
    return center + wave;
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Auto-scroll directly to the kid's current active day at the bottom / on mountain
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveDay(animate: false);
    });
  }

  void _scrollToActiveDay({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final curDay = PocketKidsService.currentUnlockedDay;
    final targetY = _getNodeY(curDay) - 300.0;
    final clampedY = targetY.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        clampedY,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedY);
    }
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
                PocketLanguageService.getParentZoneTitle(PocketLanguageService.currentLanguage),
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
                'To switch to adult account, solve this math problem:',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$a + $b = ?',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (int.tryParse(controller.text.trim()) == correctAnswer) {
                  Navigator.pop(ctx);
                  await PocketKidsService.activateAdultAccount();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePageWidget()),
                      (route) => false,
                    );
                  }
                } else {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect answer! Only parents can exit Kids Mode.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text('SWITCH TO ADULT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _onTapDayNode(int day) {
    if (!PocketKidsService.isDayUnlocked(day)) {
      final unlockedDay = PocketKidsService.currentUnlockedDay;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🔒 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  'Complete Day $unlockedDay first to climb to Day $day! 🌟',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final kidName = PocketKidsService.kidName;
    final kidAvatar = PocketKidsService.kidAvatar;
    final kidStars = PocketKidsService.kidStars;
    final currentHouse = PocketKidsService.currentHouse;
    final unlockedDay = PocketKidsService.currentUnlockedDay;
    final completedDays = PocketKidsService.completedDays;

    return Scaffold(
      backgroundColor: _currentTab == 0 ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildMountainTrailStack(
            screenWidth: screenWidth,
            kidName: kidName,
            kidAvatar: kidAvatar,
            kidStars: kidStars,
            currentHouse: currentHouse,
            unlockedDay: unlockedDay,
            completedDays: completedDays,
          ),
          const PocketKidsHomesShowcasePage(),
          const PocketKidsStudyToolsPage(),
          const PocketKidsSettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMountainTrailStack({
    required double screenWidth,
    required String kidName,
    required String kidAvatar,
    required int kidStars,
    required KidsHouse currentHouse,
    required int unlockedDay,
    required Map<int, int> completedDays,
  }) {
    return Stack(
      children: [
        // 🗺️ 100-DAY ASCENDING ADVENTURE MOUNTAIN WORLD
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: screenWidth,
              height: _totalCanvasHeight,
              child: Stack(
                children: [
                  // 1. Continuous Cartoon Mountain Road & Biome Painter
                  CustomPaint(
                    size: Size(screenWidth, _totalCanvasHeight),
                    painter: _KidsAdventureMountainRoadPainter(
                      totalDays: _totalDays,
                      unlockedDay: unlockedDay,
                      nodeSpacingY: _nodeSpacingY,
                      topPadding: _topPadding,
                      bottomPadding: _bottomPadding,
                      screenWidth: screenWidth,
                    ),
                  ),

                  // 2. Day 100 Summit Golden Castle Banner
                  Positioned(
                    top: 40,
                    left: 20,
                    right: 20,
                    child: _buildSummitCastleCard(screenWidth),
                  ),

                  // 3. Day 1 Basecamp Welcome Sign
                  Positioned(
                    top: _getNodeY(1) + 80,
                    left: 24,
                    right: 24,
                    child: _buildBasecampCard(),
                  ),

                  // 4. Milestone Playhouses along the path
                  ..._buildMilestonePlayhouses(screenWidth, unlockedDay),

                  // 5. Zone Banners across the Mountain Passes
                  ..._buildZoneMilestonePasses(screenWidth),

                  // 6. Interactive Day Nodes (Day 1 to 100)
                  ...List.generate(_totalDays, (index) {
                    final dayNumber = index + 1;
                    final nodeX = _getNodeX(dayNumber, screenWidth);
                    final nodeY = _getNodeY(dayNumber);
                    final isUnlocked = PocketKidsService.isDayUnlocked(dayNumber);
                    final isCurrent = dayNumber == unlockedDay;
                    final stars = completedDays[dayNumber] ?? (isUnlocked ? 3 : 0);

                    return Positioned(
                      left: nodeX - 44,
                      top: nodeY - 44,
                      child: GestureDetector(
                        onTap: () => _onTapDayNode(dayNumber),
                        child: _buildDayNode(
                          dayNumber: dayNumber,
                          isUnlocked: isUnlocked,
                          isCurrent: isCurrent,
                          stars: stars,
                          kidAvatar: kidAvatar,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 🌟 TOP HUD BAR (Minimal, Cartoonic, Super Clean)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Kid Mascot & Name Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(kidAvatar, style: const TextStyle(fontSize: 22)),
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

                  const SizedBox(width: 8),

                  // Playhouse Badge (Tappable to inspect Flame House)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                            side: BorderSide(
                                color: currentHouse.themeColor, width: 2),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${currentHouse.title} ${currentHouse.emoji}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tier ${currentHouse.tier} • Day $unlockedDay/100',
                                style: GoogleFonts.inter(
                                  color: currentHouse.themeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              PocketAvatarHouseWidget(
                                day: unlockedDay,
                                width: 220,
                                height: 160,
                                lightsOn: true,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentHouse.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentHouse.themeColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(currentHouse.emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Text(
                            currentHouse.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 🤝 Kids Mates Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      PocketKidsMatesPage.open(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🤝', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 4),
                          Text(
                            'MATES',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // ⚔️ Attack Citadel & Search Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      PocketKidsMatesPage.open(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚔️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'ATTACK 🔍',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 🎯 Pocket Score Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF08A), Color(0xFFFBBF24)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${PocketKidsService.pocketScore}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF78350F),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Stars Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$kidStars',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF78350F),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Parental Lock Button (Settings)
                  GestureDetector(
                    onTap: () => _showParentalGate(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📍 FLOATING "MY LEVEL" BUTTON (Instantly snaps to active day)
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.extended(
              onPressed: () => _scrollToActiveDay(animate: true),
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF78350F),
              elevation: 6,
              icon: const Icon(Icons.navigation_rounded, size: 20),
              label: Text(
                'DAY $unlockedDay',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavTabItem(0, '🎯', 'TRAIL', const Color(0xFF38BDF8)),
              _buildNavTabItem(1, '🏡', 'HOMES', const Color(0xFFF59E0B)),
              _buildNavTabItem(2, '📚', 'TOOLS', const Color(0xFF10B981)),
              _buildNavTabItem(3, '⚙️', 'SETTINGS', const Color(0xFFA855F7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTabItem(int index, String emoji, String label, Color activeColor) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (_currentTab == index && index == 0) {
          _scrollToActiveDay(animate: true);
        } else {
          setState(() => _currentTab = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: isSelected ? 20 : 18)),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: activeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Summit Golden Castle Card ---
  Widget _buildSummitCastleCard(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFF59E0B), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.45),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Column(
        children: [
          const Text('👑 🏰 🌟', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            'GRAND SUMMIT CASTLE (DAY 100)',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Climb every day to unlock the Legendary Crystal Star Throne!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF78350F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 4,
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              PocketKidsCertificatePage.open(context);
            },
            icon: const Text('🏆', style: TextStyle(fontSize: 16)),
            label: Text(
              'VIEW 100-DAY CERTIFICATE',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Basecamp Welcome Sign ---
  Widget _buildBasecampCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF4ADE80), width: 2.5),
      ),
      child: Row(
        children: [
          const Text('⛺ 🌻', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADVENTURE BASE CAMP (DAY 1)',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Your 100-Day English Game Journey starts here! Tap Day 1 to begin!',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Milestone Playhouses placed on the trail matching Adult Avatar Houses ---
  List<Widget> _buildMilestonePlayhouses(double screenWidth, int unlockedDay) {
    final houses = [
      {'day': 1, 'emoji': '🌱', 'title': 'Wooden Cabin', 'tier': 'Tier 1'},
      {'day': 8, 'emoji': '🏡', 'title': 'Brick Villa', 'tier': 'Tier 2'},
      {'day': 21, 'emoji': '🏰', 'title': 'Stone Fortress', 'tier': 'Tier 3'},
      {'day': 46, 'emoji': '🏛️', 'title': 'Imperial Manor', 'tier': 'Tier 4'},
      {'day': 71, 'emoji': '💎', 'title': 'Cyber Citadel', 'tier': 'Tier 5'},
      {'day': 90, 'emoji': '👑', 'title': 'Sovereign Palace', 'tier': 'Tier 6'},
    ];

    return houses.map((h) {
      final day = h['day'] as int;
      final y = _getNodeY(day) - 60;
      final x = _getNodeX(day, screenWidth);
      final isRightSide = x < screenWidth / 2;
      final isUnlocked = unlockedDay >= day;

      return Positioned(
        top: y,
        left: isRightSide ? x + 56 : null,
        right: !isRightSide ? (screenWidth - x) + 56 : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked ? const Color(0xFFFFD700) : Colors.white54,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(h['emoji'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h['title'] as String,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    isUnlocked ? 'Unlocked! 🏡' : 'Unlocks Day $day 🔒',
                    style: GoogleFonts.inter(
                      color: isUnlocked ? const Color(0xFF10B981) : Colors.black45,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // --- Zone Milestone Banners across Mountain Passes ---
  List<Widget> _buildZoneMilestonePasses(double screenWidth) {
    final zones = [
      {'day': 15, 'title': '🎈 ABC VALLEY ➔ ANIMAL SAFARI PASS', 'color': Color(0xFF0284C7)},
      {'day': 30, 'title': '🦁 SAFARI ➔ CANDY KINGDOM PASS', 'color': Color(0xFF10B981)},
      {'day': 50, 'title': '🍭 CANDY ➔ NUMBER STAR GROVE', 'color': Color(0xFFEC4899)},
      {'day': 70, 'title': '⭐ NUMBERS ➔ ACTION PLAYGROUND', 'color': Color(0xFFF59E0B)},
      {'day': 85, 'title': '🚀 PLAYGROUND ➔ SUMMIT PEAK', 'color': Color(0xFF8B5CF6)},
    ];

    return zones.map((z) {
      final day = z['day'] as int;
      final y = _getNodeY(day) - 95;

      return Positioned(
        top: y,
        left: 28,
        right: 28,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: (z['color'] as Color).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            z['title'] as String,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }).toList();
  }

  // --- Day Stepping Stone Node Widget ---
  Widget _buildDayNode({
    required int dayNumber,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required String kidAvatar,
  }) {
    if (isCurrent) {
      // Current Active Stepping Stone with Character Avatar
      return AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final bounce = math.sin(_bounceController.value * math.pi) * 8.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouncing Speech Bubble
              Transform.translate(
                offset: Offset(0, -bounce * 0.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TAP TO PLAY! 🎮',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // Bouncing Kid Mascot Character
              Transform.translate(
                offset: Offset(0, -bounce),
                child: Text(kidAvatar, style: const TextStyle(fontSize: 34)),
              ),

              const SizedBox(height: 3),

              // Glowing Stepping Stone
              Container(
                width: 78,
                height: 78,
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
                      color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                      blurRadius: 22,
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
                        color: const Color(0xFF78350F),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF78350F),
                      size: 26,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    if (isUnlocked) {
      // Completed Stepping Stone with Stars
      return Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34D399), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => const Text('⭐', style: TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      );
    }

    // Locked Stepping Stone
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
          Text(
            '$dayNumber',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 CustomPainter for the Ascending Cartoon Mountain Trail
class _KidsAdventureMountainRoadPainter extends CustomPainter {
  final int totalDays;
  final int unlockedDay;
  final double nodeSpacingY;
  final double topPadding;
  final double bottomPadding;
  final double screenWidth;

  _KidsAdventureMountainRoadPainter({
    required this.totalDays,
    required this.unlockedDay,
    required this.nodeSpacingY,
    required this.topPadding,
    required this.bottomPadding,
    required this.screenWidth,
  });

  double _getNodeY(int day) {
    final int daysFromTop = totalDays - day;
    return topPadding + (daysFromTop * nodeSpacingY);
  }

  double _getNodeX(int day) {
    final center = screenWidth / 2;
    final maxAmp = ((screenWidth - 140) / 2).clamp(42.0, 110.0);
    final wave = math.sin(day * 0.52) * maxAmp;
    return center + wave;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Biome Gradients (Inverted: Meadow at bottom, Cosmic Summit at top)
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF311042), // Top: Cosmic Star Summit (Day 100)
          Color(0xFF4C1D95), // High Sky Realm
          Color(0xFF38BDF8), // Sunny Cloud Kingdom
          Color(0xFFF472B6), // Candy Hills
          Color(0xFFFBBF24), // Safari Savannah
          Color(0xFF4ADE80), // Lush Green Meadow Base (Day 1)
        ],
        stops: [0.0, 0.18, 0.38, 0.58, 0.78, 1.0],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Draw Decorative Clouds & Stars
    _paintEnvironmentDecorations(canvas, size);

    // 3. Draw S-Curve Stepping Stone Road Climbing Upwards
    _paintCobblestoneRoad(canvas);
  }

  void _paintEnvironmentDecorations(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    for (int day = 3; day <= totalDays; day += 5) {
      final cy = _getNodeY(day);
      final cx = (day * 83.0) % (size.width - 100.0) + 50.0;
      canvas.drawCircle(Offset(cx, cy), 22, cloudPaint);
      canvas.drawCircle(Offset(cx + 18, cy - 6), 26, cloudPaint);
      canvas.drawCircle(Offset(cx + 34, cy), 20, cloudPaint);
    }
  }

  void _paintCobblestoneRoad(Canvas canvas) {
    // Background Road Ribbon (Thick friendly cartoon contour)
    final outerPath = Path();
    outerPath.moveTo(_getNodeX(1), _getNodeY(1));

    for (int day = 2; day <= totalDays; day++) {
      final prevX = _getNodeX(day - 1);
      final prevY = _getNodeY(day - 1);
      final curX = _getNodeX(day);
      final curY = _getNodeY(day);
      final midY = (prevY + curY) / 2;

      outerPath.cubicTo(prevX, midY, curX, midY, curX, curY);
    }

    final roadBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final roadInnerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(outerPath, roadBorderPaint);
    canvas.drawPath(outerPath, roadInnerPaint);

    // Completed Golden Progress Ribbon
    if (unlockedDay > 1) {
      final completedPath = Path();
      completedPath.moveTo(_getNodeX(1), _getNodeY(1));

      for (int day = 2; day <= unlockedDay; day++) {
        final prevX = _getNodeX(day - 1);
        final prevY = _getNodeY(day - 1);
        final curX = _getNodeX(day);
        final curY = _getNodeY(day);
        final midY = (prevY + curY) / 2;

        completedPath.cubicTo(prevX, midY, curX, midY, curX, curY);
      }

      final goldenProgressPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(completedPath, goldenProgressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KidsAdventureMountainRoadPainter oldDelegate) {
    return oldDelegate.unlockedDay != unlockedDay ||
        oldDelegate.screenWidth != screenWidth;
  }
}
