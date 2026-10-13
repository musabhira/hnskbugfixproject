import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_day_open_world_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mates_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_certificate_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_study_tools_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_student_chat_hub_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_profile_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kid_avatar_card_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_homes_reels_feed_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_level_exam_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
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
  final bool promptProfileSetup;
  const PocketKidsHomePage({super.key, this.promptProfileSetup = false});

  static const String routeName = 'PocketKidsHome';
  static const String routePath = '/pocket_kids_home';

  static Future<void> launch(BuildContext context, {bool promptProfileSetup = false}) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PocketKidsHomePage(promptProfileSetup: promptProfileSetup)),
    );
  }

  @override
  State<PocketKidsHomePage> createState() => _PocketKidsHomePageState();
}

class _PocketKidsHomePageState extends State<PocketKidsHomePage>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late final AnimationController _earthRotationController;
  late final TransformationController _mapTransformController;
  AnimationController? _cameraAnimationController;
  final ScrollController _scrollController = ScrollController();
  int _currentTab = 2; // 0 = Homes, 1 = Chat, 2 = Target (Center Trail), 3 = Tools, 4 = Profile
  bool _isGlobeMode = false;

  static const int _totalDays = 100;
  static const double _nodeSpacingY = 540.0;
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

    _earthRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _mapTransformController = TransformationController();

    PocketKidsService.kidPremiumNotifier.addListener(_onPremiumChanged);

    // Auto-focus directly on the kid's current active level on the 2D mountain map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final curDay = PocketKidsService.currentUnlockedDay;
      _focusOnNode(curDay, scale: 1.0, animate: false);
      if (widget.promptProfileSetup || !PocketKidsService.isProfileConfigured) {
        _showInitialProfileSetupDialog();
      }
    });

    // 🎵 Start Kids Ambient Background Music
    PocketGameAudioService.instance.playAmbientBgm();
  }

  void _showInitialProfileSetupDialog() {
    final nameController = TextEditingController(
      text: PocketKidsService.isProfileConfigured ? PocketKidsService.kidName : '',
    );
    String selectedAvatar = PocketKidsService.kidAvatar.isNotEmpty ? PocketKidsService.kidAvatar : '🦁';
    final mascotOptions = ['🦁', '🐯', '🐼', '🦊', '🦄', '🦅', '🐻', '🐰', '🐶'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
          title: Row(
            children: [
              const Text('✏️ 🎒 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  'Set Up Student Profile',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your child\'s explorer name & choose their starting animal buddy:',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Explorer Name',
                    labelStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                    hintText: 'e.g. Leo, Maya, Aarav',
                    hintStyle: GoogleFonts.outfit(color: const Color(0xFF475569)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Choose Starting Mascot:',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mascotOptions.map((m) {
                    final isSel = selectedAvatar == m;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setDialogState(() => selectedAvatar = m);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFFD700).withValues(alpha: 0.25) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? const Color(0xFFFFD700) : const Color(0xFF334155),
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Text(m, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Skip', style: GoogleFonts.outfit(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF78350F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () async {
                final chosenName = nameController.text.trim();
                final finalName = chosenName.isNotEmpty ? chosenName : 'Little Explorer';
                await PocketKidsService.activateKidAccount(
                  name: finalName,
                  avatar: selectedAvatar,
                  ageGroup: '6-8',
                  isParentSwitched: true,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(
                'Save Profile 🚀',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPremiumChanged() {
    if (mounted) setState(() {});
  }

  void _focusOnNode(int day, {double scale = 1.0, bool animate = true}) {
    if (!mounted) return;
    final screenSize = MediaQuery.of(context).size;
    final double worldWidth = math.max(screenSize.width, 680.0);
    final nodeX = _getNodeX(day, worldWidth);
    final nodeY = _getNodeY(day);

    final targetX = -(nodeX * scale) + (screenSize.width / 2.0);
    final targetY = -(nodeY * scale) + (screenSize.height / 2.0);

    final targetMatrix = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, targetX)
      ..setEntry(1, 3, targetY);

    if (_isGlobeMode) {
      setState(() => _isGlobeMode = false);
    }

    if (animate) {
      _cameraAnimationController?.dispose();
      _cameraAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
      final startMatrix = _mapTransformController.value;
      final anim = Matrix4Tween(begin: startMatrix, end: targetMatrix).animate(
        CurvedAnimation(parent: _cameraAnimationController!, curve: Curves.easeInOutCubic),
      );
      anim.addListener(() {
        _mapTransformController.value = anim.value;
      });
      _cameraAnimationController!.forward();
    } else {
      _mapTransformController.value = targetMatrix;
    }
  }

  void _zoomBy(double factor) {
    if (!mounted) return;
    final screenSize = MediaQuery.of(context).size;
    final curMatrix = _mapTransformController.value;
    final curScale = curMatrix.getMaxScaleOnAxis();
    final targetScale = (curScale * factor).clamp(0.20, 2.2);

    if (targetScale <= 0.32) {
      HapticFeedback.mediumImpact();
      setState(() => _isGlobeMode = true);
      return;
    } else if (_isGlobeMode) {
      setState(() => _isGlobeMode = false);
    }

    final curTranslation = curMatrix.getTranslation();
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final worldCenterX = (centerX - curTranslation.x) / curScale;
    final worldCenterY = (centerY - curTranslation.y) / curScale;

    final newX = -(worldCenterX * targetScale) + centerX;
    final newY = -(worldCenterY * targetScale) + centerY;

    final targetMatrix = Matrix4.identity()
      ..setEntry(0, 0, targetScale)
      ..setEntry(1, 1, targetScale)
      ..setEntry(0, 3, newX)
      ..setEntry(1, 3, newY);

    _cameraAnimationController?.dispose();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final anim = Matrix4Tween(begin: curMatrix, end: targetMatrix).animate(
      CurvedAnimation(parent: _cameraAnimationController!, curve: Curves.easeOutCubic),
    );
    anim.addListener(() {
      _mapTransformController.value = anim.value;
    });
    _cameraAnimationController!.forward();
  }

  void _toggleGlobeMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isGlobeMode = !_isGlobeMode;
    });
    if (!_isGlobeMode) {
      final unlockedDay = PocketKidsService.currentUnlockedDay;
      _focusOnNode(unlockedDay, scale: 1.0, animate: true);
    }
  }

  void _scrollToActiveDay({bool animate = true}) {
    final curDay = PocketKidsService.currentUnlockedDay;
    _focusOnNode(curDay, scale: 1.0, animate: animate);
  }

  @override
  void dispose() {
    PocketKidsService.kidPremiumNotifier.removeListener(_onPremiumChanged);
    _bounceController.dispose();
    _earthRotationController.dispose();
    _cameraAnimationController?.dispose();
    _mapTransformController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showParentalGate(BuildContext context) async {
    HapticFeedback.lightImpact();
    final unlocked = await PocketParentalPatternLock.verifyOrSetup(
      context,
      title: 'Parent Verification 🔒',
      subtitle: 'Draw your pattern lock to switch back to Adult Mode.',
    );

    if (unlocked) {
      await PocketKidsService.activateAdultAccount();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePageWidget()),
          (route) => false,
        );
      }
    }
  }

  void _onTapDayNode(int day) {
    if (PocketKidsService.isDayLockedByMidnightTimer(day)) {
      HapticFeedback.mediumImpact();
      _showMidnightCooldownDialog(day);
      return;
    }

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

    // Direct launch of the Day Open World Adventure! Zero bottom sheet, zero delay!
    HapticFeedback.heavyImpact();
    PocketKidsDayOpenWorldPage.open(context, day).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showMidnightCooldownDialog(int day) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Timer? ticker;
            ticker = Timer.periodic(const Duration(seconds: 1), (_) {
              if (ctx.mounted) {
                setDialogState(() {});
              } else {
                ticker?.cancel();
              }
            });

            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: Color(0xFF818CF8), width: 2),
              ),
              contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌙 💤 ⏰', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    'Day $day Unlocks at 12:00 AM!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Great job completing today\'s Spoken English adventure! In Free mode, Day $day unlocks at 12:00 AM midnight.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B4B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TIME UNTIL 12:00 AM MIDNIGHT',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFA5B4FC),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          PocketKidsService.getFormattedMidnightCountdown(),
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFFDE047),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF78350F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 4,
                    ),
                    onPressed: () {
                      ticker?.cancel();
                      Navigator.pop(ctx);
                      _showAdventurePassSheet(context, targetDay: day);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚡ ', style: TextStyle(fontSize: 15)),
                        Text(
                          'UNLOCK WITH VIP PASS',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      ticker?.cancel();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'I\'ll Wait Until Midnight 🌙',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAdventurePassSheet(BuildContext context, {int? targetDay}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isPrem = PocketKidsService.isKidPremium;
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2.5)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              const Text('👑 ⚡ 🚀', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                'VIP ADVENTURE PASS',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Master Spoken English at your own pace with instant access to all 100 days!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              _buildPerkRow('⚡', 'Zero Midnight Wait Time', 'Play next levels instantly without waiting for 12:00 AM.'),
              const SizedBox(height: 8),
              _buildPerkRow('🎮', '100 Non-Repeating Games', '10 alternating formats (Balloons, Scramble, Feeders, Echo).'),
              const SizedBox(height: 8),
              _buildPerkRow('🦁', 'King Lion Summit Boss Battle', 'Direct access to Day 100 Golden Palace Challenge.'),
              const SizedBox(height: 8),
              _buildPerkRow('🏡', 'All 10 Architectural Playhouses', 'Flame House, Crystal Igloo, Candy Villa & more.'),
              const SizedBox(height: 20),
              if (isPrem) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'VIP Adventure Pass is ACTIVE! All levels unlock as you play.',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('CONTINUE ADVENTURE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF78350F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    await PocketKidsService.setKidPremium(true);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted && context.mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Text('🎉 ', style: TextStyle(fontSize: 20)),
                              Expanded(
                                child: Text(
                                  'VIP Adventure Pass Activated! Midnight lock removed! 🚀',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                      if (targetDay != null) {
                        PocketKidsDayOpenWorldPage.open(context, targetDay).then((_) {
                          if (mounted) setState(() {});
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('👑 ', style: TextStyle(fontSize: 18)),
                      Text(
                        'ACTIVATE VIP PASS NOW (₹199)',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Maybe Later',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerkRow(String emoji, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 15)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

    return ScaffoldMessenger(
      child: Material(
        color: const Color(0xFF0284C7),
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  PocketHomesReelsFeedWidget(
                    isActive: _currentTab == 0,
                    userLevel: unlockedDay,
                  ),
                  const PocketStudentChatHubWidget(),
                  _buildMountainTrailStack(
                    screenWidth: screenWidth,
                    kidName: kidName,
                    kidAvatar: kidAvatar,
                    kidStars: kidStars,
                    currentHouse: currentHouse,
                    unlockedDay: unlockedDay,
                    completedDays: completedDays,
                  ),
                  const PocketKidsStudyToolsPage(),
                  const PocketKidsProfilePage(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
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
    final double worldWidth = math.max(screenWidth, 680.0);

    return Stack(
      children: [
        // 🗺️ 100-DAY GOOGLE MAP-LIKE 2D INTERACTIVE PAN & ZOOM CANVAS
        InteractiveViewer(
          transformationController: _mapTransformController,
          minScale: 0.20,
          maxScale: 2.2,
          boundaryMargin: const EdgeInsets.all(800),
          constrained: false,
          onInteractionUpdate: (details) {
            final currentScale = _mapTransformController.value.getMaxScaleOnAxis();
            if (currentScale <= 0.32 && !_isGlobeMode) {
              setState(() => _isGlobeMode = true);
            } else if (currentScale > 0.35 && _isGlobeMode) {
              setState(() => _isGlobeMode = false);
            }
          },
          child: SizedBox(
            width: worldWidth,
            height: _totalCanvasHeight,
            child: Stack(
              children: [
                // 1. Continuous Cartoon Mountain Road & Biome Painter
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(worldWidth, _totalCanvasHeight),
                    painter: _KidsAdventureMountainRoadPainter(
                      totalDays: _totalDays,
                      unlockedDay: unlockedDay,
                      nodeSpacingY: _nodeSpacingY,
                      topPadding: _topPadding,
                      bottomPadding: _bottomPadding,
                      screenWidth: worldWidth,
                    ),
                  ),
                ),

                // 2. Day 100 Summit Golden Castle Banner
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: _buildSummitCastleCard(worldWidth),
                ),

                // 3. Day 1 Basecamp Welcome Sign
                Positioned(
                  top: _getNodeY(1) + 80,
                  left: 24,
                  right: 24,
                  child: _buildBasecampCard(),
                ),

                // 4. Architectural English Houses along the path (All 100 Days)
                ...List.generate(_totalDays, (index) {
                  final day = index + 1;
                  return _buildRoadmapHouse(day, worldWidth, unlockedDay);
                }),

                // 5. Fortress Exam Gates between Day N and Day N+1 (Days 1 to 99)
                ...List.generate(_totalDays - 1, (index) {
                  final day = index + 1;
                  return _buildRoadmapGate(day, worldWidth, unlockedDay);
                }),

                // 6. Zone Banners across the Mountain Passes
                ..._buildZoneMilestonePasses(worldWidth),

                // 7. Interactive Day Nodes (Day 1 to 100)
                ...List.generate(_totalDays, (index) {
                  final dayNumber = index + 1;
                  final nodeX = _getNodeX(dayNumber, worldWidth);
                  final nodeY = _getNodeY(dayNumber);
                  final isMidnightLocked = PocketKidsService.isDayLockedByMidnightTimer(dayNumber);
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
                        isMidnightLocked: isMidnightLocked,
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

        // 🌍 3D-STYLED ROTATING CARTOON EARTH GLOBE OVERLAY (Visible when zoomed out or toggled)
        if (_isGlobeMode)
          Positioned.fill(
            child: _buildRotatingEarthGlobe(unlockedDay),
          ),

          // 🌟 TOP HUD BAR (Minimal, Cartoonic, Super Clean)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
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

                  const SizedBox(width: 8),

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
                          '$kidStars Star Score',
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

                  // 👑 VIP Adventure Pass Button
                  GestureDetector(
                    onTap: () => _showAdventurePassSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: PocketKidsService.isKidPremium
                              ? const [Color(0xFF8B5CF6), Color(0xFF6366F1)]
                              : const [Color(0xFFFFD700), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (PocketKidsService.isKidPremium ? const Color(0xFF8B5CF6) : const Color(0xFFFFD700)).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(PocketKidsService.isKidPremium ? '👑' : '⚡', style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            PocketKidsService.isKidPremium ? 'VIP ACTIVE' : 'VIP PASS',
                            style: GoogleFonts.outfit(
                              color: PocketKidsService.isKidPremium ? Colors.white : const Color(0xFF78350F),
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (PocketKidsService.isAdminAccount) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, color: Colors.black, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            'ADMIN',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 👨‍👩‍👧 Switch to Adult Mode Button (Parental Gate Protected)
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showParentalGate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF38BDF8),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: Color(0xFF38BDF8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ADULT',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
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
        ),
        // 📍 GOOGLE MAP-STYLE FLOATING QUICK HUD CONTROLLER
          Positioned(
            right: 14,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Zoom In (+)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _zoomBy(1.30);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                ),

                // Zoom Out (-)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _zoomBy(0.75);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.remove_rounded, color: Colors.white, size: 20),
                  ),
                ),

                // 🌍 Globe Orbit Toggle Button
                GestureDetector(
                  onTap: _toggleGlobeMode,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isGlobeMode
                            ? [const Color(0xFF38BDF8), const Color(0xFF0284C7)]
                            : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isGlobeMode ? Colors.white : const Color(0xFF38BDF8),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌍', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          _isGlobeMode ? 'MAP VIEW' : 'GLOBE',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🏰 Jump to Summit (Day 100)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _focusOnNode(100, scale: 1.0, animate: true);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏰', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'SUMMIT',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🎯 FOCUS BUTTON (Centers directly onto student's active level)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _focusOnNode(unlockedDay, scale: 1.0, animate: true);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF78350F)),
                        const SizedBox(width: 5),
                        Text(
                          '🎯 FOCUS (DAY $unlockedDay)',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF78350F),
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ⛺ Jump to Basecamp (Day 1)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _focusOnNode(1, scale: 1.0, animate: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⛺', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'BASECAMP',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
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
      );
  }

  // --- 🕹️ Open World Arcade Console Bottom Navigation Bar ---
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildNavTabItem(
                  index: 0,
                  emoji: '🏰',
                  label: 'HOMES',
                  activeColor: const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildNavTabItem(
                  index: 1,
                  emoji: '💬',
                  label: 'CHATS',
                  activeColor: const Color(0xFF38BDF8),
                ),
              ),
              Expanded(
                child: _buildNavTabItem(
                  index: 2,
                  emoji: '🎯',
                  label: 'TRAIL',
                  activeColor: const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildNavTabItem(
                  index: 3,
                  emoji: '🎮',
                  label: 'GAMES',
                  activeColor: const Color(0xFFA855F7),
                ),
              ),
              Expanded(
                child: _buildNavTabItem(
                  index: 4,
                  emoji: '👤',
                  label: 'HERO',
                  activeColor: const Color(0xFFF43F5E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTabItem({
    required int index,
    required String emoji,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.mediumImpact();
        PocketGameAudioService.instance.playCoinSound();
        if (index == 2 && _currentTab == 2) {
          _scrollToActiveDay(animate: true);
        } else {
          setState(() => _currentTab = index);
        }
      },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.18 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSelected ? activeColor : const Color(0xFF94A3B8),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 9.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
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
          const Text('👑 🦁 🏰', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            'KING LION PALACE (DAY 100 BOSS)',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const PocketAvatarHouseWidget(
            day: 90,
            isPresident: true,
            width: 200,
            height: 140,
            lightsOn: true,
          ),
          const SizedBox(height: 8),
          Text(
            'Climb to the summit to challenge King Lion in the Royal Spoken English Boss Battle!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 4,
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  PocketCitadelAttackPage.openForUser(
                    context,
                    userId: PocketKidsService.lionId,
                    targetName: PocketKidsService.lionName,
                  );
                },
                icon: const Text('⚔️', style: TextStyle(fontSize: 16)),
                label: Text(
                  'ATTACK KING LION',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF78350F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 4,
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  PocketKidsCertificatePage.open(context);
                },
                icon: const Text('🏆', style: TextStyle(fontSize: 16)),
                label: Text(
                  'CERTIFICATE',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Basecamp Welcome Sign ---
  Widget _buildBasecampCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        PocketKidsDayOpenWorldPage.open(context, 1).then((_) {
          if (mounted) setState(() {});
        });
      },
      child: Container(
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
                    'ADVENTURE BASE CAMP (DAY 1) 🚀',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Tap here to begin your Day 1 Open World Journey!',
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF10B981), size: 16),
          ],
        ),
      ),
    );
  }

  // --- 🏡 Architectural English Houses placed along the trail (All 100 Days) ---
  // Mirrors the Adult 60/90-Day Target Roadmap architecture:
  // Full, prominent standing house centered directly above the stepping stone node with ground footing and glow!
  Widget _buildRoadmapHouse(int day, double screenWidth, int currentDay) {
    final nodeX = _getNodeX(day, screenWidth);
    final nodeY = _getNodeY(day);
    final isUnlocked = day <= currentDay;
    final isCompleted = day < currentDay;
    final isCurrent = day == currentDay;

    final double houseWidth = (screenWidth * 0.64).clamp(210.0, 260.0);
    const double houseHeight = 142.0;

    // Centered directly on nodeX with safe bounds
    final double houseLeft =
        (nodeX - (houseWidth / 2.0)).clamp(8.0, screenWidth - houseWidth - 8.0);
    // Placed above the stepping stone node with clear breathing room
    final double houseTop = nodeY - houseHeight - 74.0;

    final mate = (day - 1 < PocketKidsRobotsData.robotsAndHomies.length)
        ? PocketKidsRobotsData.robotsAndHomies[day - 1]
        : null;

    return Positioned(
      left: houseLeft,
      top: houseTop,
      child: GestureDetector(
        onTap: () => _showHouseDetailDialog(day, isUnlocked),
        child: SizedBox(
          width: houseWidth,
          height: houseHeight + 36.0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // 1. Terrain Ground Shadow Footing (Gives the house a solid physical standing on the mountain)
              Positioned(
                bottom: 28,
                left: 12,
                right: 12,
                height: 18,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: 4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Warm Flame Glow behind the house when Unlocked or Completed
              if (isUnlocked)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  height: houseHeight - 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isCompleted
                              ? const Color(0xFFFF5722).withValues(alpha: 0.35)
                              : const Color(0xFFFFD700).withValues(alpha: 0.28),
                          blurRadius: 26,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Direct Architectural House on Mountain Ground (NO BOX/PETTI CONTAINER!)
              SizedBox(
                width: houseWidth,
                height: houseHeight,
                child: PocketAvatarHouseWidget(
                  day: day,
                  width: houseWidth,
                  height: houseHeight,
                  lightsOn: isUnlocked,
                ),
              ),

              // 4. Resident Vector Avatar Buddy Badge (Tappable Collectible Card!)
              if (mate != null)
                Positioned(
                  top: -8,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      PocketKidAvatarCardDialog.show(
                        context,
                        day: day,
                        mateId: mate.id,
                        mateName: mate.name,
                        mateBio: mate.bio,
                      );
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFFFFD700) : Colors.white24,
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: VectorAvatarWidget(
                              config: PocketKidsAvatarSystem.getAvatarConfigForDay(day),
                              size: 20,
                              showAura: false,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DAY $day',
                            style: GoogleFonts.outfit(
                              color: isUnlocked
                                  ? const Color(0xFFFFD700)
                                  : Colors.white70,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 5. Standing House Label Banner
              Positioned(
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFFFFC00)
                          : (isCompleted
                              ? const Color(0xFF10B981)
                              : (isUnlocked
                                  ? const Color(0xFFFFD700)
                                  : Colors.white24)),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCompleted ? '🔥' : (isUnlocked ? '🏡' : '🔒'),
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted
                            ? 'HOUSE $day • MASTERED'
                            : (isUnlocked
                                ? 'HOUSE $day RESIDENCE'
                                : 'HOUSE $day LOCKED'),
                        style: GoogleFonts.outfit(
                          color: isCompleted
                              ? const Color(0xFF34D399)
                              : (isUnlocked
                                  ? const Color(0xFFFFD700)
                                  : Colors.white60),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
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
      ),
    );
  }

  void _showHouseDetailDialog(int day, bool isUnlocked) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: isUnlocked ? const Color(0xFFFFD700) : Colors.white24,
            width: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'English Architectural House $day',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUnlocked ? 'Level $day Residence • Unlocked 🌟' : 'Level $day Residence • Locked 🔒',
              style: GoogleFonts.inter(
                color: isUnlocked ? const Color(0xFFFFD700) : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            PocketAvatarHouseWidget(
              day: day,
              width: 220,
              height: 150,
              lightsOn: isUnlocked,
            ),
            const SizedBox(height: 12),
            Text(
              isUnlocked
                  ? 'Welcome to House $day! Master English words and clear the gate exam to reach higher estates.'
                  : 'Pass previous houses and gates to move into this residence.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  // --- 🏰 Fortress Exam Gates between Day N and Day N+1 (Parity with Adult Mode) ---
  Widget _buildRoadmapGate(int day, double screenWidth, int currentDay) {
    if (day >= _totalDays) return const SizedBox.shrink();

    final isCompleted = day < currentDay;
    final isExamReady = (day == currentDay);

    final gateY = (_getNodeY(day) + _getNodeY(day + 1)) / 2.0;
    final gateX = (_getNodeX(day, screenWidth) + _getNodeX(day + 1, screenWidth)) / 2.0;
    final double gateWidth = (screenWidth * 0.74).clamp(240.0, 280.0);
    const double gateHeight = 58.0;
    final double gateLeft = (gateX - (gateWidth / 2.0)).clamp(8.0, screenWidth - gateWidth - 8.0);
    final double gateTop = gateY - (gateHeight / 2.0);

    return Positioned(
      left: gateLeft,
      top: gateTop,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          HapticFeedback.heavyImpact();
          if (isCompleted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                    const SizedBox(width: 8),
                    Text('Gate $day Cleared! 🏰', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Text(
                  'You passed the Gate $day Exam! Would you like to re-take this exam for practice and review?',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Close', style: GoogleFonts.outfit(color: Colors.white54)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      PocketLevelExamDialog.show(context, level: day);
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Re-test Exam', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            return;
          }

          if (day > currentDay) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF0F172A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
                content: Row(
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gate $day is locked! Clear Day $currentDay game & exam first.',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          // Launch Level Mastery Exam Dialog!
          final passed = await PocketLevelExamDialog.show(
            context,
            level: day,
            onExamPassed: () async {
              await PocketKidsService.completeDayGame(day, 3);
              if (mounted) setState(() {});
            },
          );
          if (passed == true) {
            await PocketKidsService.completeDayGame(day, 3);
            if (mounted) setState(() {});
          }
        },
        child: SizedBox(
          width: gateWidth,
          height: gateHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Flanking Stone Walls
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF475569)],
                        ),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        border: Border.all(color: Colors.white24, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 5,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 84),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF475569), Color(0xFF334155), Color(0xFF1E293B)],
                        ),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        border: Border.all(color: Colors.white24, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 5,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Central Fortress Arch
              Container(
                width: 84,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isCompleted
                        ? [const Color(0xFF047857), const Color(0xFF064E3B)]
                        : (isExamReady
                            ? [const Color(0xFFD97706), const Color(0xFF78350F)]
                            : [const Color(0xFF1E293B), const Color(0xFF0F172A)]),
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(8)),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isExamReady ? const Color(0xFFFFD700) : Colors.white24),
                    width: isExamReady || isCompleted ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCompleted
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : (isExamReady
                              ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4)),
                      blurRadius: isExamReady ? 12 : 8,
                      spreadRadius: isExamReady ? 2 : 1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Iron bars pattern
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (i) => Container(
                          width: 1.5,
                          height: 32,
                          color: isCompleted
                              ? const Color(0xFF34D399)
                              : (isExamReady ? const Color(0xFFFFD700).withValues(alpha: 0.5) : Colors.white12),
                        ),
                      ),
                    ),
                    Icon(
                      isCompleted
                          ? Icons.lock_open_rounded
                          : (isExamReady ? Icons.edit_note_rounded : Icons.lock_rounded),
                      color: isCompleted
                          ? const Color(0xFF6EE7B7)
                          : (isExamReady ? const Color(0xFFFFFC00) : Colors.white38),
                      size: isExamReady ? 22 : 18,
                    ),
                    Positioned(
                      bottom: 2,
                      child: Text(
                        'GATE $day',
                        style: GoogleFonts.outfit(
                          color: isCompleted
                              ? const Color(0xFFA7F3D0)
                              : (isExamReady ? const Color(0xFFFEF08A) : Colors.white54),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    required bool isMidnightLocked,
    required int stars,
    required String kidAvatar,
  }) {
    if (isMidnightLocked) {
      // 🌙 Sleeping until 12:00 AM Midnight Lock
      return AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final bounce = math.sin(_bounceController.value * math.pi) * 5.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, -bounce * 0.4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5B4FC), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌙 ', style: TextStyle(fontSize: 10)),
                      Text(
                        '12:00 AM LOCK ⏳',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFC7D2FE),
                          fontWeight: FontWeight.w900,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Transform.translate(
                offset: Offset(0, -bounce),
                child: const Text('😴', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 3),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF312E81)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA5B4FC), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DAY $dayNumber',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Icon(
                      Icons.lock_clock_rounded,
                      color: Color(0xFFFDE047),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

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

              // 🌟 Bouncing Adult Evolution Vector Avatar (Replaces tiger emoji mascot)
              Transform.translate(
                offset: Offset(0, -bounce),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: VectorAvatarWidget(
                      config: PocketKidsAvatarSystem.getAvatarConfigForDay(dayNumber),
                      size: 42,
                      showAura: false,
                    ),
                  ),
                ),
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
      // Completed Stepping Stone with Vector Avatar & Star Badge
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
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: VectorAvatarWidget(
                config: PocketKidsAvatarSystem.getAvatarConfigForDay(dayNumber),
                size: 44,
                showAura: false,
              ),
            ),
            Positioned(
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$dayNumber',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text('⭐', style: TextStyle(fontSize: 7)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Locked Stepping Stone with Silhouette Vector Avatar
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.28,
            child: ClipOval(
              child: VectorAvatarWidget(
                config: PocketKidsAvatarSystem.getAvatarConfigForDay(dayNumber),
                size: 38,
                showAura: false,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white, size: 14),
              Text(
                '$dayNumber',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 🌍 3D-Styled Rotating Cartoon Earth Globe (Orbit View) ---
  Widget _buildRotatingEarthGlobe(int unlockedDay) {
    return Container(
      color: const Color(0xFF050814),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Cosmic Nebulae & Twinkling Stars
          Positioned.fill(
            child: CustomPaint(
              painter: _SpaceNebulaStarsPainter(),
            ),
          ),

          // 2. Rotating Earth Sphere
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                _toggleGlobeMode();
              },
              child: AnimatedBuilder(
                animation: _earthRotationController,
                builder: (context, _) {
                  return _buildEarthSphere(unlockedDay);
                },
              ),
            ),
          ),

          // 3. Top Space Banner & Instructions
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌍 🛰️ ', style: TextStyle(fontSize: 18)),
                  Text(
                    'ORBITAL VIEW • POCKET KINGDOM PLANET',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating "DIVE TO TRAIL" CTA Button
          Positioned(
            bottom: 34,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF78350F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 8,
                shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.5),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _toggleGlobeMode();
              },
              icon: const Icon(Icons.travel_explore_rounded, size: 22),
              label: Text(
                'ENTER MOUNTAIN TRAIL (DAY $unlockedDay) 🚀',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarthSphere(int unlockedDay) {
    const double sphereSize = 270.0;
    return Container(
      width: sphereSize,
      height: sphereSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.65),
            blurRadius: 40,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.40),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(sphereSize, sphereSize),
            painter: _RotatingEarthGlobePainter(
              rotation: _earthRotationController.value,
              unlockedDay: unlockedDay,
            ),
          ),
          // Pulsing Continent Pin Tag
          Positioned(
            top: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📍', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'KINGDOM • DAY $unlockedDay 🦁',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
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

/// 🌌 CustomPainter for Twinkling Deep Space & Nebulae in Globe View
class _SpaceNebulaStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cosmic Nebulae
    final nebula1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.28),
          const Color(0xFF3B82F6).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.25, size.height * 0.28), radius: 240));
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.28), 240, nebula1);

    final nebula2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEC4899).withValues(alpha: 0.22),
          const Color(0xFF06B6D4).withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.75, size.height * 0.72), radius: 280));
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.72), 280, nebula2);

    // 2. Twinkling Stars
    final rand = math.Random(1337);
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 95; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = 0.8 + rand.nextDouble() * 1.8;
      final opacity = 0.35 + rand.nextDouble() * 0.65;
      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🌍 CustomPainter for Rotating 3D Cartoon Earth Globe with Continents & Clouds
class _RotatingEarthGlobePainter extends CustomPainter {
  final double rotation; // 0.0 to 1.0 from AnimationController
  final int unlockedDay;

  _RotatingEarthGlobePainter({required this.rotation, required this.unlockedDay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Clip all globe elements to spherical disc
    final globePath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(globePath);

    // 1. Deep Oceanic Gradient with Spherical Light
    final oceanPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.95,
        colors: const [
          Color(0xFF38BDF8), // Sunny highlight rim
          Color(0xFF0284C7), // Azure cartoon ocean
          Color(0xFF0369A1), // Deep blue
          Color(0xFF0F172A), // Shadowed ocean horizon
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, oceanPaint);

    // 2. Seamless Rotating Green Continents
    final continentPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;
    final mountainPaint = Paint()
      ..color = const Color(0xFF15803D)
      ..style = PaintingStyle.fill;

    final double globeCircumference = radius * 2.8;
    final double shiftX = (rotation * globeCircumference) % globeCircumference;

    for (int rep = -1; rep <= 2; rep++) {
      final baseX = center.dx - (radius * 1.2) + (rep * globeCircumference) - shiftX;

      // Continent 1: Pocket Kingdom Mountain Island
      final island1 = Path();
      island1.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX + 20, center.dy - 55, 95, 80),
        const Radius.circular(38),
      ));
      canvas.drawPath(island1, continentPaint);

      // Mountain ridge on Continent 1
      final ridge1 = Path();
      ridge1.moveTo(baseX + 45, center.dy - 10);
      ridge1.lineTo(baseX + 65, center.dy - 35);
      ridge1.lineTo(baseX + 85, center.dy - 10);
      ridge1.close();
      canvas.drawPath(ridge1, mountainPaint);

      // Continent 2: Safari Savannah Continent
      final island2 = Path();
      island2.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX + 130, center.dy + 5, 80, 65),
        const Radius.circular(30),
      ));
      canvas.drawPath(island2, continentPaint);

      // Continent 3: Polar Arctic Cap
      final island3 = Path();
      island3.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX + 70, center.dy - 95, 75, 30),
        const Radius.circular(16),
      ));
      canvas.drawPath(island3, Paint()..color = const Color(0xFFE0F2FE));
    }

    // 3. Drifting White Cloud Swirls
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final double cloudShift = ((rotation * 1.35) * globeCircumference) % globeCircumference;
    for (int rep = -1; rep <= 2; rep++) {
      final cx = center.dx - radius + (rep * globeCircumference) - cloudShift;
      canvas.drawOval(Rect.fromLTWH(cx + 30, center.dy - 40, 70, 16), cloudPaint);
      canvas.drawOval(Rect.fromLTWH(cx + 120, center.dy + 30, 85, 20), cloudPaint);
      canvas.drawOval(Rect.fromLTWH(cx + 80, center.dy - 80, 50, 12), cloudPaint);
    }

    // 4. Spherical 3D Volume Shadow
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, 0.4),
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.40),
          Colors.black.withValues(alpha: 0.70),
        ],
        stops: const [0.55, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shadowPaint);

    canvas.restore();

    // 5. Outer Atmospheric Cyan Glow Ring
    final atmoPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(center, radius + 1.5, atmoPaint);
  }

  @override
  bool shouldRepaint(covariant _RotatingEarthGlobePainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.unlockedDay != unlockedDay;
}
