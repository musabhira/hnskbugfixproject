import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_day_open_world_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_attacking_profile_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/flame_letter_tracing_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/flame_junior_sentence_builder.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';

/// 👶 Pure Kids World Platform (Ages 4–8)
///
/// Master Architectural Features:
/// 1. 🏡 Buddy Village & House Raids (വീടുകൾ അറ്റാക്ക് ചെയ്യുക):
///    - Flame-rendered vector houses with animated chimney smoke.
///    - Full-Screen Spoken English defense challenges & raid victories (+50 KS, Star Cookies).
/// 2. 🤝 Kids Mates & Safe Spoken Comms:
///    - Child-safe interactions without open keyboards or COPPA risks.
///    - Pre-approved English phrase chips with cheerful TTS voice read-aloud.
///    - Friendship Score tracking (❤️) & Star Cookie gifting (🍪).
/// 3. 🏔️ 90-Day Adventure Road (3 Worlds & 3 Atmospheres):
///    - World 1 (Days 1–30): Sunny Meadow Basecamp 🌸☀️ (Phonics, ABC, Animals).
///    - World 2 (Days 31–60): Enchanted Sunset Valley 🌲🌅 (Words, Sentences, Manners).
///    - World 3 (Days 61–90): Starry Cosmic Summit 🏔️🌌 (Storytelling, Fluency, Speech).
///    - Day 91: King Lion Golden Summit Citadel 👑🏰!
/// 4. 🎮 Arcade Mini-Games Playground:
///    - Balloon Pop, Letter Train, Safari Memory, Animal Feeder, Lilypad Hopper.
/// 5. 🦁 Little Hero & Castle Profile:
///    - Mascot customization, personal house showcase, KS stats, Parental Pattern Lock 🔒.
class PocketPureKidsHomePage extends StatefulWidget {
  const PocketPureKidsHomePage({super.key});

  static const String routeName = 'PocketPureKidsHome';
  static const String routePath = '/pocket_pure_kids_home';

  static Future<void> launch(BuildContext context) {
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PocketPureKidsHomePage()),
      (route) => false,
    );
  }

  @override
  State<PocketPureKidsHomePage> createState() => _PocketPureKidsHomePageState();
}

class _PocketPureKidsHomePageState extends State<PocketPureKidsHomePage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _bounceController;
  late AnimationController _sunRotationController;
  late AnimationController _pulseController;
  final ScrollController _trailScrollController = ScrollController();

  int _currentTab = 2; // 0 = Homes, 1 = Talk/Mates, 2 = Trail (Center), 3 = Arcade, 4 = Hero

  // Village / Homes State
  final TextEditingController _villageSearchController = TextEditingController();
  String _villageSearchQuery = '';
  int _villageFilterIndex = 0; // 0 = All, 1 = My Mates, 2 = Meadow (1-30), 3 = Valley (31-60), 4 = Summit (61-100)

  // Mates & Safe Talk State
  int _matesSubTab = 0; // 0 = My Mates, 1 = Voice Echo, 2 = Requests
  int _selectedMascotEchoIdx = 0;
  bool _isSpeakingEcho = false;
  String _echoStatusText = 'Tap the Magic Mic and say "Hello"! 🎙️✨';

  final List<String> _mascotEchoOptions = [
    '🐯 Sparky Tiger',
    '🐼 Pandy Panda',
    '🐰 Bouncy Bunny',
    '🐶 Pip Puppy',
    '🦁 Leo King',
  ];

  static const List<Map<String, String>> _quickSpokenPhrases = [
    {'text': 'Hello Mate! 👋', 'desc': 'Friendly Greeting'},
    {'text': 'High five! ✋', 'desc': 'Celebration'},
    {'text': 'Great house defense! 🛡️', 'desc': 'Praise Defense'},
    {'text': 'You are a superstar! 🌟', 'desc': 'Encouragement'},
    {'text': 'Let us climb together! 🚀', 'desc': 'Adventure'},
    {'text': 'Here is a Star Cookie! 🍪', 'desc': 'Cookie Gift'},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _sunRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _initTts();
    PocketKidsService.loadAttackCount();
    PocketGameAudioService.instance.playAmbientBgm();

    // Auto-scroll to active day after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveDay(animate: false);
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.35); // Cheerful cartoon voice pitch
    } catch (_) {}
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _sunRotationController.dispose();
    _pulseController.dispose();
    _trailScrollController.dispose();
    _villageSearchController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _scrollToActiveDay({bool animate = true}) {
    if (!_trailScrollController.hasClients) return;
    final unlocked = PocketKidsService.currentUnlockedDay.clamp(1, 90);
    // Trail is reversed (Day 1 at index 0, climbing to Day 90 at index 89)
    // Approximate item height ~ 110.0
    final targetOffset = ((unlocked - 1) * 110.0).clamp(
      0.0,
      _trailScrollController.position.maxScrollExtent,
    );

    if (animate) {
      _trailScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    } else {
      _trailScrollController.jumpTo(targetOffset);
    }
  }

  Future<void> _speakText(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _exitWithParentGate() async {
    HapticFeedback.mediumImpact();
    final unlocked = await PocketParentalPatternLock.verifyOrSetup(
      context,
      title: 'Parent Verification 🔒',
      subtitle: 'Draw pattern lock to exit Kids World.',
    );

    if (unlocked && mounted) {
      await PocketKidsService.activateAdultAccount();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePageWidget()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopKidHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _buildBuddyVillageTab(),
                  _buildMatesAndSafeTalkTab(),
                  _buildCartoonTrailTab(),
                  _buildArcadePlaygroundTab(),
                  _buildLittleHeroTab(),
                ],
              ),
            ),
            _buildBottomKidNav(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🌟 TOP KID HEADER
  // =========================================================================
  Widget _buildTopKidHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Kid Mascot Avatar
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              final dy = math.sin(_bounceController.value * math.pi) * 3.0;
              return Transform.translate(
                offset: Offset(0, -dy),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    PocketKidsService.kidAvatar.isNotEmpty
                        ? PocketKidsService.kidAvatar
                        : '🦁',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Kid Name & World Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PocketKidsService.kidName,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '👶 KIDS WORLD (4–8)',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // KS (Kids Score) Badge
          ValueListenableBuilder<int>(
            valueListenable: PocketKidsService.kidsScoreNotifier,
            builder: (context, ks, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 3),
                    Text(
                      '$ks KS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF78350F),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(width: 6),

          // Star Cookies Jar
          ValueListenableBuilder<int>(
            valueListenable: PocketKidsService.kidStarsNotifier,
            builder: (context, stars, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white38, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🍪', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 3),
                    Text(
                      '$stars',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(width: 6),

          // Parent Exit Button (Locked)
          GestureDetector(
            onTap: _exitWithParentGate,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 0: 🏡 BUDDY VILLAGE & CITADEL RAIDS (വീടുകളുടെ അറ്റാക്കിങ്ങും വില്ലേജും)
  // =========================================================================
  Widget _buildBuddyVillageTab() {
    final allBuddies = PocketKidsRobotsData.robotsAndHomies;

    // Apply category filters
    List<KidMate> displayed = allBuddies.where((b) {
      if (_villageFilterIndex == 1) {
        return PocketKidsService.getMateRequestStatus(b.id) == KidMateRequestStatus.accepted;
      } else if (_villageFilterIndex == 2) {
        return b.dayLevel <= 30; // Meadow Cabins
      } else if (_villageFilterIndex == 3) {
        return b.dayLevel > 30 && b.dayLevel <= 60; // Valley Castles
      } else if (_villageFilterIndex == 4) {
        return b.dayLevel > 60; // Summit Citadels
      }
      return true;
    }).toList();

    // Apply search query
    if (_villageSearchQuery.trim().isNotEmpty) {
      final q = _villageSearchQuery.trim().toLowerCase();
      displayed = displayed.where((b) => b.name.toLowerCase().contains(q)).toList();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        children: [
          // Banner & Raid Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🏡 ⚔️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Animal Buddy Village',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Raid buddy houses, break spoken shields & earn +50 KS!',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        const Text('⚔️ RAIDS', style: TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold)),
                        Text(
                          '${PocketKidsService.attackCount}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _villageSearchController,
              onChanged: (val) => setState(() => _villageSearchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search 100 Animal Companions & Castles... 🔍',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F172A).withValues(alpha: 0.75),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 20),
                suffixIcon: _villageSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                        onPressed: () {
                          _villageSearchController.clear();
                          setState(() => _villageSearchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildVillageFilterChip(0, 'All (100) 🐾'),
                _buildVillageFilterChip(1, 'My Mates 🤝'),
                _buildVillageFilterChip(2, 'Meadow (1-30) 🌸'),
                _buildVillageFilterChip(3, 'Valley (31-60) 🌲'),
                _buildVillageFilterChip(4, 'Summit (61-100) 👑'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Houses Grid
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏰', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          _villageFilterIndex == 1
                              ? 'No Mates added yet!\nRaid a house to make friends! 🤝'
                              : 'No companions found matching "$_villageSearchQuery"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: displayed.length,
                    itemBuilder: (context, idx) {
                      final buddy = displayed[idx];
                      final house = PocketKidsService.getHouseForDay(buddy.dayLevel);
                      final isMate = PocketKidsService.getMateRequestStatus(buddy.id) ==
                          KidMateRequestStatus.accepted;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isMate ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 🏡 Live Flame Vector House Widget
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 110,
                                height: 95,
                                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                alignment: Alignment.center,
                                child: PocketAvatarHouseWidget(
                                  day: buddy.dayLevel,
                                  width: 105,
                                  height: 90,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Companion Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        buddy.avatar,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          buddy.name,
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF1E293B),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isMate)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '🤝 MATE',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF059669),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    house.title,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '🛡️ Day ${buddy.dayLevel}',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF0284C7),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '+50 KS ⭐',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFB45309),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Action Buttons: RAID & VISIT
                                  Row(
                                    children: [
                                      // RAID HOUSE BUTTON
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            HapticFeedback.heavyImpact();
                                            PocketGameAudioService.instance.playAttackTheme(
                                              targetId: buddy.id,
                                              targetDay: buddy.dayLevel,
                                            );
                                            PocketKidsService.incrementAttackCount();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PocketKidsHouseChallengePage(defender: buddy),
                                              ),
                                            ).then((_) {
                                              if (mounted) setState(() {});
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Text('⚔️', style: TextStyle(fontSize: 12)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'RAID',
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white,
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // VISIT / TALK BUTTON
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PocketKidsAttackingProfilePage(mate: buddy),
                                              ),
                                            ).then((_) {
                                              if (mounted) setState(() {});
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Text('💬', style: TextStyle(fontSize: 12)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'VISIT',
                                                  style: GoogleFonts.outfit(
                                                    color: const Color(0xFF0284C7),
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVillageFilterChip(int idx, String label) {
    final isSel = _villageFilterIndex == idx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _villageFilterIndex = idx);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFFFD700) : const Color(0xFF0F172A).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSel ? Colors.white : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSel ? const Color(0xFF78350F) : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 1: 🤝 KIDS MATES & SAFE TALK (സേഫ് സോഷ്യൽ & വോയ്സ് എക്കോ)
  // =========================================================================
  Widget _buildMatesAndSafeTalkTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        children: [
          // Sub-Tab Switcher: [ My Mates 🤝 ] | [ Voice Echo 🎙️ ] | [ Requests 💌 ]
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
              ),
              child: Row(
                children: [
                  _buildMatesSubTabButton(0, '🤝 My Mates'),
                  _buildMatesSubTabButton(1, '🎙️ Voice Echo'),
                  _buildMatesSubTabButton(2, '💌 Requests'),
                ],
              ),
            ),
          ),

          // Sub-Tab Content
          Expanded(
            child: _matesSubTab == 0
                ? _buildMyMatesList()
                : _matesSubTab == 1
                    ? _buildVoiceEchoSection()
                    : _buildMateRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatesSubTabButton(int idx, String title) {
    final isSel = _matesSubTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _matesSubTab = idx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFFFD700) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: isSel ? const Color(0xFF78350F) : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // --- SUB-TAB 0: MY MATES ---
  Widget _buildMyMatesList() {
    final mates = PocketKidsService.getKidMates(filterTab: 1);

    if (mates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🤝 🐾', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'No Mates Added Yet!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Visit the Buddy Village or Discover Buddies to raid houses and make lifelong mates!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF78350F),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => setState(() => _currentTab = 0),
                icon: const Text('🏡'),
                label: Text('Visit Buddy Village', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: mates.length,
      itemBuilder: (context, idx) {
        final mate = mates[idx];
        final fScore = PocketKidsService.getFriendshipScore(mate.id);
        final badge = PocketKidsService.getFriendshipBadge(fScore);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mate Header Row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(mate.avatar, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mate.name,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '❤️ $fScore% • $badge',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE11D48),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Open full chat
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PocketKidsMateChatPage(mate: mate)),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OPEN CHAT 💬',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                'Send Quick Spoken English: 👇',
                style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // Horizontal Quick Spoken Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickSpokenPhrases.map((phrase) {
                    return GestureDetector(
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        HapticFeedback.mediumImpact();
                        PocketGameAudioService.instance.playCoinSound();
                        await _speakText(phrase['text']!);
                        await PocketKidsService.boostFriendship(mate.id, 8);
                        await PocketKidsService.sendMessageToMate(
                          mateId: mate.id,
                          text: phrase['text']!,
                          isStarGift: phrase['text']!.contains('Cookie'),
                        );
                        if (mounted) {
                          setState(() {});
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Spoke "${phrase['text']}" to ${mate.name}! +8 ❤️'),
                              backgroundColor: const Color(0xFF10B981),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          phrase['text']!,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1E293B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- SUB-TAB 1: VOICE ECHO ---
  Widget _buildVoiceEchoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Companion selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_mascotEchoOptions.length, (idx) {
                final isSel = _selectedMascotEchoIdx == idx;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMascotEchoIdx = idx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? Colors.white : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _mascotEchoOptions[idx],
                      style: GoogleFonts.outfit(
                        color: isSel ? const Color(0xFF78350F) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const Spacer(),

          // Mascot animated character
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              final dy = math.sin(_bounceController.value * math.pi) * 12.0;
              return Transform.translate(
                offset: Offset(0, -dy),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isSpeakingEcho ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                      width: _isSpeakingEcho ? 5 : 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _mascotEchoOptions[_selectedMascotEchoIdx].split(' ').first,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Speech bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF38BDF8), width: 3),
            ),
            child: Text(
              _echoStatusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Spacer(),

          // Big Magic Mic Button
          GestureDetector(
            onTap: () async {
              HapticFeedback.heavyImpact();
              PocketGameAudioService.instance.playCoinSound();
              final companion = _mascotEchoOptions[_selectedMascotEchoIdx].split(' ')[1];
              setState(() {
                _isSpeakingEcho = true;
                _echoStatusText = 'Listening to your great voice! 🌟';
              });

              await _speakText('Hello little explorer! I am $companion. You speak wonderful English!');
              await PocketKidsService.addKidsScore(15);
              await PocketKidsService.addStars(1);

              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() {
                  _isSpeakingEcho = false;
                  _echoStatusText = 'Great English! +15 KS & +1 Cookie! 🌟🍪';
                });
              }
            },
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Color(0xFF78350F), size: 42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TAP TO TALK (VOICE ECHO)',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // --- SUB-TAB 2: MATE REQUESTS ---
  Widget _buildMateRequestsList() {
    final requests = PocketKidsService.getKidMates(filterTab: 2);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Action to Discover More
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
          ),
          child: Row(
            children: [
              const Text('🤝 🐾', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Explore the 100 Animal Companions in Buddy Village to send more requests!',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF78350F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () => setState(() => _currentTab = 0),
                child: Text('Explore 🐾', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (requests.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No pending mate requests!\nRaid houses to challenge friends! 💌',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
            ),
          )
        else
          ...requests.map((r) {
            final isReceived = r.requestStatus == KidMateRequestStatus.received;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(r.avatar, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          isReceived ? 'Wants to be your Mate! 💌' : 'Request sent ⏳',
                          style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isReceived)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        await PocketKidsService.acceptMateRequest(r.id);
                        setState(() {});
                      },
                      child: const Text('Accept 🤝'),
                    )
                  else
                    TextButton(
                      onPressed: () async {
                        await PocketKidsService.cancelMateRequest(r.id);
                        setState(() {});
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // =========================================================================
  // TAB 2: 🏔️ 90-DAY ADVENTURE ROAD (3 WORLDS & 3 ATMOSPHERES)
  // =========================================================================
  Widget _buildCartoonTrailTab() {
    final unlockedDay = PocketKidsService.currentUnlockedDay;

    return Stack(
      children: [
        // 🌄 Dynamic Living Cartoon Nature Scenery Background (Azure Sky, Radiant Sun, Drifting Clouds & Hills)
        const Positioned.fill(
          child: PocketKidsNatureSceneryBackground(
            showSun: true,
            showTrees: true,
          ),
        ),

        // Continuous Mountain Trail List (Climbing bottom-up from Day 1 Basecamp to Day 90 Summit)
        ListView.builder(
          controller: _trailScrollController,
          reverse: true,
          padding: const EdgeInsets.only(top: 140, bottom: 90),
          itemCount: 91, // Days 1 to 90 + Day 91 King Lion Golden Castle
          itemBuilder: (context, idx) {
            final day = idx + 1;
            final isMidnightLocked = PocketKidsService.isDayLockedByMidnightTimer(day);
            final isUnlocked = PocketKidsService.isDayUnlocked(day);
            final isCompleted = PocketKidsService.completedDays.containsKey(day) || day < unlockedDay;
            final isCurrent = day == unlockedDay;
            final isBossNode = day == 91;

            // Calculate alternating horizontal alignment for cartoon S-curve
            final wave = math.sin(day * 0.55);
            final alignX = isBossNode ? 0.0 : (wave * 0.65).clamp(-0.75, 0.75);

            // Determine Atmosphere Theme for this specific node
            final atmosphere = _getNodeAtmosphere(day);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment(alignX, 0),
                child: GestureDetector(
                  onTap: () {
                    if (isMidnightLocked) {
                      HapticFeedback.mediumImpact();
                      _showMidnightCooldownDialog(day);
                      return;
                    }

                    if (!isUnlocked) {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Complete Day $unlockedDay first! 🌟',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF0F172A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                      return;
                    }

                    HapticFeedback.heavyImpact();
                    if (isBossNode) {
                      // Launch King Lion Boss Battle
                      final lion = PocketKidsRobotsData.robotsAndHomies.firstWhere(
                        (b) => b.dayLevel >= 90,
                        orElse: () => PocketKidsRobotsData.robotsAndHomies.last,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PocketKidsHouseChallengePage(defender: lion),
                        ),
                      );
                    } else {
                      // Open interactive Flame learning & challenge sheet
                      _showKidsLevelActivitySheet(context, day);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active Bouncing Mascot Indicator
                      if (isCurrent && !isMidnightLocked) ...[
                        AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) {
                            final dy = math.sin(_bounceController.value * math.pi) * 8.0;
                            return Transform.translate(
                              offset: Offset(0, -dy),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      PocketKidsService.kidAvatar.isNotEmpty
                                          ? PocketKidsService.kidAvatar
                                          : '🦁',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isBossNode ? '👑 BOSS' : 'START DAY $day',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF78350F),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Midnight Timer Pill for Cooldown Day
                      if (isMidnightLocked) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B4B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF818CF8), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌙', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                'UNLOCKS AT 12:00 AM',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFDE047),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Stepping Stone Node & Living House Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Stepping Stone Circle
                          Container(
                            width: isBossNode ? 96 : (isCurrent ? 76 : 64),
                            height: isBossNode ? 96 : (isCurrent ? 76 : 64),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isBossNode
                                    ? const [Color(0xFFFFD700), Color(0xFFEA580C)]
                                    : (isMidnightLocked
                                        ? const [Color(0xFF312E81), Color(0xFF1E1B4B)]
                                        : (isCurrent
                                            ? const [Color(0xFFFFD700), Color(0xFFF59E0B)]
                                            : (isUnlocked
                                                ? atmosphere.nodeGradient
                                                : const [Color(0xFF64748B), Color(0xFF334155)]))),
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isBossNode
                                    ? const Color(0xFFFFD700)
                                    : (isCurrent
                                        ? Colors.white
                                        : (isMidnightLocked ? const Color(0xFF818CF8) : Colors.white70)),
                                width: isBossNode || isCurrent ? 3.5 : 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isCurrent || isBossNode
                                          ? const Color(0xFFFFD700)
                                          : (isMidnightLocked ? const Color(0xFF6366F1) : Colors.black))
                                      .withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isBossNode
                                  ? '👑'
                                  : (isMidnightLocked
                                      ? '🌙'
                                      : (isUnlocked ? '$day' : '🔒')),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: isBossNode ? 36 : (isCurrent ? 22 : 18),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Living Cartoon House for this Day Milestone
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFF10B981)
                                      : (isMidnightLocked
                                          ? const Color(0xFF6366F1)
                                          : (isCurrent ? const Color(0xFFFFD700) : const Color(0xFF0F172A).withValues(alpha: 0.65))),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (isCompleted || isCurrent) ? const Color(0xFFFFD700) : Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isCompleted
                                      ? '🏡 DAY $day • WON'
                                      : (isMidnightLocked
                                          ? '⏰ 12:00 AM'
                                          : (isCurrent ? '🏡 DAY $day • PLAY' : '🏡 HOUSE $day')),
                                  style: GoogleFonts.outfit(
                                    color: isCurrent && !isCompleted ? const Color(0xFF78350F) : Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.16),
                                  padding: const EdgeInsets.all(2),
                                  child: PocketAvatarHouseWidget(
                                    day: day,
                                    width: isBossNode ? 88 : 72,
                                    height: isBossNode ? 68 : 54,
                                    lightsOn: isCompleted || isUnlocked,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        isBossNode ? '👑 King Lion Castle' : _getKidsBiomeTitleForDay(day),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // TOP ATMOSPHERE BANNER OVERLAY
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildWorldAtmosphereHeader(unlockedDay),
        ),

        // RECENTER FLOATING BUTTON
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => _scrollToActiveDay(animate: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📍', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'FIND MY LEVEL',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF78350F),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- TOP ATMOSPHERE STATUS HEADER ---
  Widget _buildWorldAtmosphereHeader(int currentDay) {
    String worldTitle;
    String worldDesc;
    String emoji;
    List<Color> gradientColors;

    if (currentDay <= 30) {
      worldTitle = 'WORLD 1: SUNNY MEADOW 🌸';
      worldDesc = 'Days 1–30 • Morning Sunshine, Phonics & ABC Basecamp';
      emoji = '☀️';
      gradientColors = const [Color(0xFF38BDF8), Color(0xFF10B981)];
    } else if (currentDay <= 60) {
      worldTitle = 'WORLD 2: SUNSET VALLEY 🌲';
      worldDesc = 'Days 31–60 • Golden Sunset, Pine Woods, Action Verbs & Manners';
      emoji = '🌅';
      gradientColors = const [Color(0xFFF59E0B), Color(0xFFE11D48)];
    } else {
      worldTitle = 'WORLD 3: COSMIC SUMMIT 🏔️';
      worldDesc = 'Days 61–90 • Starlight Peaks, Fluency, Grand Lion Citadel';
      emoji = '🌌';
      gradientColors = const [Color(0xFF6366F1), Color(0xFF1E1B4B)];
    }

    final progress = (currentDay / 90.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worldTitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      worldDesc,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(progress * 100).toInt()}% Done',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
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
                side: const BorderSide(color: Color(0xFF38BDF8), width: 2),
              ),
              contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌙 💤 ⏰', style: TextStyle(fontSize: 40)),
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
                    'Great job completing today\'s English adventure! In Free mode, Day $day unlocks at 12:00 AM midnight. Unlock now with Adventure Pass (Premium)!',
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
                      color: const Color(0xFF0369A1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TIME UNTIL 12:00 AM MIDNIGHT',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFBAE6FD),
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
                    onPressed: () async {
                      ticker?.cancel();
                      Navigator.pop(ctx);
                      await PocketKidsService.setKidPremium(true);
                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Adventure Pass Activated! Day $day Unlocked! 🌟',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
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
                        color: const Color(0xFF94A3B8),
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

  _KidsNodeAtmosphere _getNodeAtmosphere(int day) {
    if (day <= 30) {
      return _KidsNodeAtmosphere(
        nodeGradient: const [Color(0xFF34D399), Color(0xFF059669)],
        tag: '🌸 Meadow',
      );
    } else if (day <= 60) {
      return _KidsNodeAtmosphere(
        nodeGradient: const [Color(0xFFFB923C), Color(0xFFEA580C)],
        tag: '🌲 Valley',
      );
    } else {
      return _KidsNodeAtmosphere(
        nodeGradient: const [Color(0xFF818CF8), Color(0xFF4338CA)],
        tag: '🏔️ Summit',
      );
    }
  }

  String _getKidsBiomeTitleForDay(int day) {
    if (day == 1) return '🌸 Basecamp';
    if (day == 10) return '🪵 Wooden Cabin';
    if (day == 20) return '🏡 Red Brick Villa';
    if (day == 30) return '🏰 Stone Fort';
    if (day == 40) return '🌳 Treehouse';
    if (day == 50) return '🏛️ Royal Manor';
    if (day == 60) return '💎 Crystal Citadel';
    if (day == 70) return '🏔️ Mountain Peak';
    if (day == 80) return '🛡️ Titanium Fort';
    if (day == 90) return '👑 King Lion Castle';
    return 'Level $day';
  }

  // =========================================================================
  // 🌟 KIDS LEVEL LEARNING HUB SHEET (Tracing, Sentence Builder, 2D Adventure)
  // =========================================================================
  void _showKidsLevelActivitySheet(BuildContext context, int day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final biome = _getKidsBiomeTitleForDay(day);
        final traceItem = KidsTracingCurriculum.getItem(
          (day - 1) % KidsTracingCurriculum.letters.length,
        );

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: Color(0xFF38BDF8), width: 2),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // Level Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF38BDF8)),
                    ),
                    child: Text(
                      traceItem.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAY $day: $biome',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Choose an activity to practice & earn +30 KS! 🌟',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Activity Option 1: 🎨 Letter & Word Tracing
              _buildActivityOptionTile(
                iconEmoji: '🎨',
                title: 'Finger Tracing Lab (${traceItem.char} for ${traceItem.word})',
                subtitle: 'Trace letters with rainbow stardust & phonics',
                gradientColors: [const Color(0xFFFF2D55), const Color(0xFFFF9500)],
                onTap: () {
                  Navigator.pop(ctx);
                  PocketKidsLetterTracingPage.show(
                    context,
                    initialIndex: (day - 1) % KidsTracingCurriculum.letters.length,
                    onCompleted: () => setState(() {}),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Activity Option 2: 🚂 Toy Train Sentence Builder
              _buildActivityOptionTile(
                iconEmoji: '🚂',
                title: 'Toy Train Sentence Builder',
                subtitle: 'Snap words in order & speak English karaoke',
                gradientColors: [const Color(0xFF10B981), const Color(0xFF00C7BE)],
                onTap: () {
                  Navigator.pop(ctx);
                  PocketKidsSentenceBuilderPage.show(
                    context,
                    day: day,
                    onCompleted: () => setState(() {}),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Activity Option 3: 🎮 2D Adventure Mini-Game
              _buildActivityOptionTile(
                iconEmoji: '🎮',
                title: 'Adventure Playground Game',
                subtitle: 'Play Day $day mini-game with mascot buddy',
                gradientColors: [const Color(0xFF007AFF), const Color(0xFF5856D6)],
                onTap: () {
                  Navigator.pop(ctx);
                  PocketKidsDayOpenWorldPage.open(context, day).then((_) {
                    if (mounted) setState(() {});
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityOptionTile({
    required String iconEmoji,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 3: 🎮 ARCADE PLAYGROUND (മിനി-ഗെയിമുകൾ)
  // =========================================================================
  Widget _buildArcadePlaygroundTab() {
    final games = [
      {
        'title': '🎨 Letter & Word Tracing',
        'sub': 'Rainbow stardust finger tracing A-Z with phonics',
        'color': const Color(0xFFFF2D55),
        'type': 'tracing',
        'day': 1,
      },
      {
        'title': '🚂 Toy Train Sentence Builder',
        'sub': 'Snap magnetic train cars & karaoke English speech',
        'color': const Color(0xFF10B981),
        'type': 'sentence_builder',
        'day': 1,
      },
      {'title': '🎈 Balloon Pop Phonics', 'sub': 'Phonics & ABC balloon catch', 'color': const Color(0xFFEC4899), 'day': 1, 'type': 'open_world'},
      {'title': '🚂 Letter Train Speller', 'sub': 'Spelling locomotive puzzle', 'color': const Color(0xFF3B82F6), 'day': 2, 'type': 'open_world'},
      {'title': '🍎 Animal Feeder Feast', 'sub': 'Mascot food & fruit feast', 'color': const Color(0xFFF59E0B), 'day': 3, 'type': 'open_world'},
      {'title': '🃏 Safari Memory Flip', 'sub': 'Pair flip & word recall', 'color': const Color(0xFF8B5CF6), 'day': 4, 'type': 'open_world'},
      {'title': '🐸 Lilypad Rhyme Hopper', 'sub': 'River leap & sound rhythm', 'color': const Color(0xFF06B6D4), 'day': 6, 'type': 'open_world'},
      {'title': '🏎️ Vocab Speed Catcher', 'sub': 'Highway racer vocabulary catch', 'color': const Color(0xFFEF4444), 'day': 5, 'type': 'open_world'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF1E1B4B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF59E0B)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🎮 ✨', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kids Mini-Game Arcade',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF78350F),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Play anytime to practice words & earn extra KS stars!',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF78350F).withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView.separated(
              itemCount: games.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final g = games[idx];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    final type = g['type'];
                    if (type == 'tracing') {
                      PocketKidsLetterTracingPage.show(context).then((_) {
                        if (mounted) setState(() {});
                      });
                    } else if (type == 'sentence_builder') {
                      PocketKidsSentenceBuilderPage.show(
                        context,
                        day: PocketKidsService.currentUnlockedDay,
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    } else {
                      PocketKidsDayOpenWorldPage.open(context, g['day'] as int).then((_) {
                        if (mounted) setState(() {});
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: g['color'] as Color, width: 2.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (g['color'] as Color).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            g['title']!.toString().split(' ').first,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g['title'] as String,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                g['sub'] as String,
                                style: GoogleFonts.inter(
                                  color: Colors.black54,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF10B981), size: 34),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 4: 🦁 LITTLE HERO & CASTLE PROFILE (എന്റെ പ്രൊഫൈലും സ്വന്തം വീടും)
  // =========================================================================
  Widget _buildLittleHeroTab() {
    final curDay = PocketKidsService.currentUnlockedDay;
    final house = PocketKidsService.getHouseForDay(curDay);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Hero Avatar & Name Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFFFD700), width: 3),
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
                GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          PocketKidsService.kidAvatar.isNotEmpty ? PocketKidsService.kidAvatar : '🦁',
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  PocketKidsService.kidName,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Little English Explorer 🌟 • Ages 4–8',
                  style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // MY CURRENT HOUSE DISPLAY (Flame Vector Widget)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY AVATAR HOUSE 🏡',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: house.themeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        house.title,
                        style: GoogleFonts.outfit(
                          color: house.themeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Live House Graphic
                Container(
                  width: double.infinity,
                  height: 130,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PocketAvatarHouseWidget(
                    day: curDay,
                    width: 150,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  house.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.black54, fontSize: 11.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats Grid: KS, Cookies, Raids, Mates
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '⭐ KIDS SCORE',
                  '${PocketKidsService.kidsScore}',
                  const Color(0xFFFFD700),
                  const Color(0xFF78350F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '🍪 COOKIES',
                  '${PocketKidsService.kidStars}',
                  const Color(0xFF38BDF8),
                  const Color(0xFF0C4A6E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '⚔️ RAIDS WON',
                  '${PocketKidsService.attackCount}',
                  const Color(0xFFF97316),
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '🤝 MY MATES',
                  '${PocketKidsService.friendIds.length}',
                  const Color(0xFF10B981),
                  Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 🌟 MY HERO DEFENSE CARDS (1–90) COLLECTION 🃏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🌟', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                'HERO DEFENSE CARDS 🃏',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Earn 1 PopArt Card every day you conquer! (${math.min(PocketKidsService.completedDaysCount, 90)}/90)',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        PopArtAvatarCardsViewerPage.open(context, initialIndex: 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'VIEW ALL 🚀',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Horizontal Cards Carousel
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 90,
                    itemBuilder: (context, idx) {
                      final day = idx + 1;
                      final isUnlocked = PocketKidsService.isDayCompleted(day) || day <= PocketKidsService.currentUnlockedDay;
                      final isMale = day % 2 == 0;
                      final card = PopArtCardHelper.getCardForDay(day, isMale: isMale);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (isUnlocked) {
                            PocketGameAudioService.instance.playCoinSound();
                            _speakText('${card.title}! ${card.subtitle}');
                            PopArtAvatarCardsViewerPage.open(context, initialIndex: idx);
                          } else {
                            _speakText('Day $day is locked! Complete daily games to unlock this hero card!');
                          }
                        },
                        child: Container(
                          width: 130,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isUnlocked ? card.bgColor : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isUnlocked ? const Color(0xFFFFD700) : Colors.white24,
                              width: isUnlocked ? 2.2 : 1.2,
                            ),
                            boxShadow: isUnlocked
                                ? [
                                    BoxShadow(
                                      color: card.bgColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                if (isUnlocked) ...[
                                  // Live PopArt Hero Graphic
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: PopArtCardCustomPainter(data: card),
                                    ),
                                  ),
                                  // Day Badge at top
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'DAY $day',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFFFD700),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bottom Title Label
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.8),
                                      ),
                                      child: Text(
                                        card.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // Locked State
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_rounded, color: Colors.white38, size: 28),
                                        const SizedBox(height: 6),
                                        Text(
                                          'DAY $day',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white60,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'LOCKED',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white38,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Parental Gate Exit Button
          GestureDetector(
            onTap: _exitWithParentGate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'EXIT TO ADULT MODE (PARENT LOCK 🔒)',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
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

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    final avatars = ['🦁', '🐯', '🐼', '🦊', '🦄', '🐰', '🐶', '🐻', '🦅', '🐬', '🦛', '🐨'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        title: Text(
          'Choose Your Hero Avatar! 🦁',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: avatars.map((av) {
              return GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  PocketGameAudioService.instance.playCoinSound();
                  await PocketKidsService.saveKidProfile(
                    name: PocketKidsService.kidName,
                    avatar: av,
                  );
                  if (mounted) setState(() {});
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(av, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 🕹️ BOTTOM KID NAV
  // =========================================================================
  Widget _buildBottomKidNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(top: BorderSide(color: Color(0xFF38BDF8), width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildKidNavItem(0, '🏡', 'HOMES'),
          _buildKidNavItem(1, '🤝', 'MATES'),
          _buildKidNavItem(2, '🎯', 'TRAIL'),
          _buildKidNavItem(3, '🎮', 'ARCADE'),
          _buildKidNavItem(4, '👤', 'HERO'),
        ],
      ),
    );
  }

  Widget _buildKidNavItem(int idx, String emoji, String label) {
    final isSel = _currentTab == idx;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          PocketGameAudioService.instance.playCoinSound();
          setState(() => _currentTab = idx);
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isSel ? 22 : 18)),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSel ? const Color(0xFFFFD700) : Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KidsNodeAtmosphere {
  final List<Color> nodeGradient;
  final String tag;

  const _KidsNodeAtmosphere({
    required this.nodeGradient,
    required this.tag,
  });
}
