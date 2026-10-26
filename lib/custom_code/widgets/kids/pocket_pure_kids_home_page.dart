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
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/flame_letter_tracing_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/flame_junior_sentence_builder.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_profile_bottom_sheet.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_tense_drop_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_falling_word_blocks_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_art_studio_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_kumi_word_builder_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_match_it_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_picture_quiz_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/spoken/pocket_kids_spoken_dialogue_lab_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_hero_card_claim_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_profile_setup_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_balloon_pop_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_story_read_aloud_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/sentence_builder_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_essential_spelling_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/spoken/pocket_kids_cumulative_speech_arena_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/games/pocket_kids_interactive_learning_games.dart';

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

  int _arcadeCategoryFilter = 0; // 0 = All, 1 = Words & Spelling, 2 = Match & Puzzles, 3 = Quizzes, 4 = Creative
  int _villageBiomeFilter = 0; // 0 = All (100), 1 = My Mates, 2 = Meadow (1-30), 3 = Valley (31-60), 4 = Summit (61-100)
  String _villageSearchQuery = '';
  final TextEditingController _villageSearchController = TextEditingController();
  int _cardFilterTab = 0; // 0 = All (90), 1 = Achieved, 2 = Locked
  bool _expandAllCards = false;

  // Mates & Safe Talk State
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
      backgroundColor: const Color(0xFFE8F8F5), // Kumi Soft Mint
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopKidHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _buildKidWorldTab(),
                  _buildAnimalMatesTab(),
                  _buildCartoonTrailTab(),
                  _buildArcadePlaygroundTab(),
                  _buildKidProfileTab(),
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
  // 🌟 TOP KID HEADER (Kumi Pastel Mint Theme)
  // =========================================================================
  Widget _buildTopKidHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDFAF7),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFD4EFE6),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3E34).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    border: Border.all(color: const Color(0xFF8CD837), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8CD837).withValues(alpha: 0.3),
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
                    color: const Color(0xFF0F3E34),
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
                        color: const Color(0xFF8CD837),
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
                    colors: [Color(0xFFFFD700), Color(0xFFFFA726)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.35),
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

          const SizedBox(width: 8),

          // Parent Exit Button (Locked)
          GestureDetector(
            onTap: _exitWithParentGate,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4EFE6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3E34).withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0F3E34), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 0: 🏡 BUDDY VILLAGE & HOMES (കുട്ടികളുടെ സുഹൃദ് വീടുകളും റെയ്ഡുകളും)
  // =========================================================================
  Widget _buildKidWorldTab() {
    final allBuddies = PocketKidsRobotsData.robotsAndHomies;

    final List<KidMate> filteredBuddies;
    if (_villageBiomeFilter == 1) {
      // My Mates (friends)
      filteredBuddies = allBuddies
          .where((b) => PocketKidsService.friendIds.contains(b.id))
          .toList();
    } else if (_villageBiomeFilter == 2) {
      // Meadow (Days 1–30)
      filteredBuddies = allBuddies.where((b) => b.dayLevel <= 30).toList();
    } else if (_villageBiomeFilter == 3) {
      // Valley (Days 31–60)
      filteredBuddies =
          allBuddies.where((b) => b.dayLevel > 30 && b.dayLevel <= 60).toList();
    } else if (_villageBiomeFilter == 4) {
      // Summit (Days 61–100)
      filteredBuddies = allBuddies.where((b) => b.dayLevel > 60).toList();
    } else {
      // All
      filteredBuddies = allBuddies;
    }

    // Apply live search query
    List<KidMate> buddies = filteredBuddies;
    if (_villageSearchQuery.trim().isNotEmpty) {
      final q = _villageSearchQuery.toLowerCase().trim();
      buddies = buddies.where((b) {
        return b.name.toLowerCase().contains(q) ||
            b.avatar.contains(q) ||
            b.dayLevel.toString() == q ||
            'day ${b.dayLevel}'.toLowerCase().contains(q) ||
            b.bio.toLowerCase().contains(q);
      }).toList();
    }

    return Container(
      color: const Color(0xFFE8F8F5), // Kumi Soft Mint
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // 🏡 Top Open World & Village Banner (Kumi Pastel Rounded Card)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3E34).withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Mascot Circle
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    final dy = math.sin(_bounceController.value * math.pi) * 3.5;
                    return Transform.translate(
                      offset: Offset(0, -dy),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFAF7),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF8CD837), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8CD837).withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          PocketKidsService.kidAvatar.isNotEmpty
                              ? PocketKidsService.kidAvatar
                              : '🦁',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buddy Village & Homes 🏡',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F3E34),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visit cute animal houses & challenge their English defenses!',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B8B82),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 2D Open World Action Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          PocketGameAudioService.instance.playVictorySfx();
                          PocketKidsDayOpenWorldPage.open(
                            context,
                            PocketKidsService.currentUnlockedDay,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CD837),
                            borderRadius: BorderRadius.circular(16),
                            border: const Border(
                              bottom: BorderSide(color: Color(0xFF6FAF24), width: 3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8CD837).withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎮', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                'EXPLORE 2D OPEN WORLD',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
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
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🔍 Child-Friendly Mate & Robot Search Bar (User Audio Directive)
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3E34).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _villageSearchController,
              onChanged: (val) {
                setState(() => _villageSearchQuery = val);
              },
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F3E34),
              ),
              decoration: InputDecoration(
                hintText: '🔍 Search 90 animal mates, bots, or Day #...',
                hintStyle: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9EBEB6),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
                suffixIcon: _villageSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF6B8B82)),
                        onPressed: () {
                          _villageSearchController.clear();
                          setState(() => _villageSearchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 🏷️ Biome Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildVillageFilterChip(0, 'All 100 Houses 🌍'),
                const SizedBox(width: 8),
                _buildVillageFilterChip(1, 'My Mates 🤝 (${PocketKidsService.friendIds.length})'),
                const SizedBox(width: 8),
                _buildVillageFilterChip(2, 'Meadow (1–30) 🌱'),
                const SizedBox(width: 8),
                _buildVillageFilterChip(3, 'Valley (31–60) 🌄'),
                const SizedBox(width: 8),
                _buildVillageFilterChip(4, 'Summit (61–100) 🏔️'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🏡 Houses Grid / List
          if (buddies.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 42)),
                  const SizedBox(height: 10),
                  Text(
                    _villageSearchQuery.isNotEmpty
                        ? 'No mates found for "$_villageSearchQuery"!'
                        : 'No mates found in this filter!',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F3E34),
                    ),
                  ),
                  if (_villageSearchQuery.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Try searching "Lion", "Robo", or "Day 5"',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B8B82),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            ...buddies.map((buddy) => _buildBuddyHouseCard(buddy)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVillageFilterChip(int index, String label) {
    final isSel = _villageBiomeFilter == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        PocketGameAudioService.instance.playPopSound();
        setState(() => _villageBiomeFilter = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF8CD837) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSel ? const Color(0xFF6FAF24) : const Color(0xFFC7EDE3),
            width: 1.5,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: const Color(0xFF8CD837).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
            color: isSel ? Colors.white : const Color(0xFF0F3E34),
          ),
        ),
      ),
    );
  }

  Widget _buildBuddyHouseCard(KidMate buddy) {
    final house = PocketKidsService.getHouseForDay(buddy.dayLevel);
    final isFriend = PocketKidsService.friendIds.contains(buddy.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC7EDE3), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3E34).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Level badge, Friend toggle
          Row(
            children: [
              // Avatar circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFAF7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8CD837), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  buddy.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            buddy.name,
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F3E34),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFAF7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF8CD837), width: 1),
                          ),
                          child: Text(
                            'DAY ${buddy.dayLevel}',
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F3E34),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      buddy.bio,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: const Color(0xFF6B8B82),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Add / Remove Friend Star
              GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  PocketGameAudioService.instance.playPopSound();
                  await PocketKidsService.toggleMate(buddy.id);
                  if (mounted) setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isFriend ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFriend ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    isFriend ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFriend ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Center: House Graphic & House Details
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFAF7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD4EFE6), width: 1),
            ),
            child: Row(
              children: [
                // Flame Avatar House Widget
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(4),
                    child: PocketAvatarHouseWidget(
                      day: buddy.dayLevel,
                      width: 100,
                      height: 75,
                      lightsOn: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // House Name, Biome & Cookie Reward
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        house.title,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F3E34),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getKidsBiomeTitleForDay(buddy.dayLevel),
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B8B82),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('🍪', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            '+50 KS & Cookies on Raid',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Buttons: RAID HOUSE ⚔️ & CHAT 💬
          Row(
            children: [
              // ⚔️ RAID HOUSE BUTTON (Vibrant tactile 3D coral button)
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playPopSound();
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
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043), // Candy Coral
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFFE64A19), width: 3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7043).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚔️', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          'RAID HOUSE',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 💬 VISIT & CHAT BUTTON (Tactile mint button)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    PocketKidsMateChatPage.open(context, mate: buddy);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8CD837), // Kumi Candy Lime
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFF6FAF24), width: 3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8CD837).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          'CHAT',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
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
    );
  }

  // =========================================================================
  // TAB 1: 🐾 ANIMAL MATES (കൂട്ടുകാരും സംസാരിക്കുന്ന മൃഗങ്ങളും)
  // =========================================================================
  Widget _buildAnimalMatesTab() {
    final animalFriends = [
      {
        'id': 'leo_lion',
        'name': 'Leo the Lion',
        'emoji': '🦁',
        'role': 'King of the Savannah 👑',
        'color': const Color(0xFFF59E0B),
        'bg': const Color(0xFFFEF3C7),
        'speech': 'Roaaar! Reading makes you brave! Let\'s read a fun story together!',
        'tts': 'Roar! I am Leo the Lion! Reading makes you super brave! Let us explore together!',
        'level': 'Level 5 Best Friend',
        'cookies': 12,
      },
      {
        'id': 'pandy_panda',
        'name': 'Pandy the Panda',
        'emoji': '🐼',
        'role': 'Bamboo Forest Explorer 🎋',
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFD1FAE5),
        'speech': 'Crunch crunch! Fresh bamboo is yummy! Did you eat your fruits today?',
        'tts': 'Hello! I am Pandy the Panda! Bamboo is so yummy! Remember to eat healthy fruits today!',
        'level': 'Level 4 Best Friend',
        'cookies': 8,
      },
      {
        'id': 'sparky_fox',
        'name': 'Sparky the Fox',
        'emoji': '🦊',
        'role': 'Clever Meadow Riddle-Master 🧩',
        'color': const Color(0xFFEF4444),
        'bg': const Color(0xFFFEE2E2),
        'speech': 'Hey buddy! I know a clever riddle! Can you guess the secret word?',
        'tts': 'Hey there! I am Sparky the clever fox! Want to solve a fun riddle with me?',
        'level': 'Level 4 Best Friend',
        'cookies': 9,
      },
      {
        'id': 'bunny_rabbit',
        'name': 'Bunny the Rabbit',
        'emoji': '🐰',
        'role': 'Carrot Patch Hopper 🥕',
        'color': const Color(0xFFEC4899),
        'bg': const Color(0xFFFCE7F3),
        'speech': 'Hop, hop, hop! I love counting crunchy carrots! Count with me: 1, 2, 3!',
        'tts': 'Hop hop hop! I am Bunny! Let us count some crunchy carrots together! One, two, three!',
        'level': 'Level 5 Best Friend',
        'cookies': 15,
      },
      {
        'id': 'ellie_elephant',
        'name': 'Ellie the Elephant',
        'emoji': '🐘',
        'role': 'River Splash Master 💧',
        'color': const Color(0xFF3B82F6),
        'bg': const Color(0xFFDBEAFE),
        'speech': 'Toot toot! My big trunk sprays cool water! You are doing awesome today!',
        'tts': 'Toot toot! I am Ellie the Elephant! Keep learning and smiling today!',
        'level': 'Level 3 Best Friend',
        'cookies': 6,
      },
      {
        'id': 'pip_puppy',
        'name': 'Pip the Puppy',
        'emoji': '🐶',
        'role': 'Sunshine Yard Playmate 🎾',
        'color': const Color(0xFFF97316),
        'bg': const Color(0xFFFFEDD5),
        'speech': 'Woof woof! I love playing fetch! High five on keeping your learning streak!',
        'tts': 'Woof woof! I am Pip the Puppy! High five buddy, you are doing fantastic!',
        'level': 'Level 5 Best Friend',
        'cookies': 14,
      },
      {
        'id': 'gigi_giraffe',
        'name': 'Gigi the Giraffe',
        'emoji': '🦒',
        'role': 'Sunny Treetop Dreamer 🌟',
        'color': const Color(0xFF8B5CF6),
        'bg': const Color(0xFFEDE9FE),
        'speech': 'Look way up high! Reach for the stars! You are super smart and can do anything!',
        'tts': 'Hello little explorer! I am Gigi the Giraffe! Reach high for the stars!',
        'level': 'Level 4 Best Friend',
        'cookies': 11,
      },
    ];

    return Container(
      color: const Color(0xFFE8F8F5), // Kumi Soft Mint Background
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Cheerful Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐾', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animal Friends Sanctuary',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap 🔊 to hear them talk, gift 🍪 cookies & chat safely!',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Animal Cards List
          ...animalFriends.map((mate) {
            final mateColor = mate['color'] as Color;
            final mateBg = mate['bg'] as Color;
            final mateEmoji = mate['emoji'] as String;
            final mateName = mate['name'] as String;
            final mateRole = mate['role'] as String;
            final mateSpeech = mate['speech'] as String;
            final mateTts = mate['tts'] as String;
            final mateLevel = mate['level'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Name + Level Pill
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: mateBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: mateColor.withValues(alpha: 0.5), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(mateEmoji, style: const TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mateName,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              mateRole,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: mateBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          mateLevel,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: mateColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Speech Bubble (Tap to hear)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _tts.speak(mateTts);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.volume_up_rounded, color: mateColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"$mateSpeech"',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Interactive Actions: [ 🍪 Gift Cookie ] & [ 💬 Chat Now ]
                  Row(
                    children: [
                      // Cookie Gift Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            PocketGameAudioService.instance.playCoinSound();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🍪 You gave a Star Cookie to $mateName! ❤️ Friend Love +1!',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🍪', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  'Gift Cookie',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Chat Now Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            PocketGameAudioService.instance.playPopSound();
                            PocketKidsSpokenDialogueLabPage.show(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: mateColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: mateColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Chat Now',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
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
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }




  // --- SUB-TAB 1: 🏆 PAW CLAW LEADERBOARD PODIUM (Image 2 Reference) ---
  Widget _buildPawClawLeaderboardPodium() {
    final allMates = PocketKidsService.getKidMates(filterTab: 0);
    final sortedMates = List<KidMate>.from(allMates)
      ..sort((a, b) {
        final scoreA = (a.stars * 25) + (a.dayLevel * 60) + (a.friendshipScore * 5);
        final scoreB = (b.stars * 25) + (b.dayLevel * 60) + (b.friendshipScore * 5);
        return scoreB.compareTo(scoreA);
      });

    if (sortedMates.length < 3) {
      return Center(
        child: Text(
          'Loading Champions...',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final first = sortedMates[0];
    final second = sortedMates[1];
    final third = sortedMates[2];
    final runnersUp = sortedMates.skip(3).take(20).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Top Banner matching Paw Claw style
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🏆 🐾', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paw Claw Village Champions',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    Text(
                      'Tap any champ to inspect profile & cheer together!',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- 3-PILLAR PODIUM ---
        Container(
          padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 0),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.9),
                const Color(0xFF0F172A).withValues(alpha: 0.95),
              ],
              radius: 0.8,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 2nd Place Pillar (Silver) - Left
                  _buildPodiumPillar(
                    mate: second,
                    rank: 2,
                    height: 120,
                    badgeEmoji: '🥈',
                    pillarGradient: const [Color(0xFFCBD5E1), Color(0xFF64748B)],
                    glowColor: const Color(0xFF94A3B8),
                  ),

                  // 1st Place Pillar (Gold) - Center (Tallest)
                  _buildPodiumPillar(
                    mate: first,
                    rank: 1,
                    height: 155,
                    badgeEmoji: '👑',
                    pillarGradient: const [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFF57C00)],
                    glowColor: const Color(0xFFFFD700),
                    isCenter: true,
                  ),

                  // 3rd Place Pillar (Bronze) - Right
                  _buildPodiumPillar(
                    mate: third,
                    rank: 3,
                    height: 100,
                    badgeEmoji: '🥉',
                    pillarGradient: const [Color(0xFFFDBA74), Color(0xFFEA580C)],
                    glowColor: const Color(0xFFF97316),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Subheader for Ranked List
        Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Leaderboard Honor Roll',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Text(
              'Ranks #4 - #${3 + runnersUp.length}',
              style: GoogleFonts.outfit(
                color: const Color(0xFF38BDF8),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Ranked Runners-Up List
        ...runnersUp.asMap().entries.map((entry) {
          final idx = entry.key;
          final mate = entry.value;
          final rank = idx + 4;
          return _buildRankRowItem(mate, rank);
        }),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPodiumPillar({
    required KidMate mate,
    required int rank,
    required double height,
    required String badgeEmoji,
    required List<Color> pillarGradient,
    required Color glowColor,
    bool isCenter = false,
  }) {
    final score = (mate.stars * 25) + (mate.dayLevel * 60) + (mate.friendshipScore * 5);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          PocketKidsProfileBottomSheet.show(context, mate: mate).then((_) {
            if (mounted) setState(() {});
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Crown / Badge
            Text(badgeEmoji, style: TextStyle(fontSize: isCenter ? 26 : 20)),
            const SizedBox(height: 2),

            // Avatar with circular glow ring
            Container(
              width: isCenter ? 58 : 46,
              height: isCenter ? 58 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: pillarGradient),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.6),
                    blurRadius: isCenter ? 14 : 8,
                    spreadRadius: isCenter ? 2 : 0,
                  ),
                ],
                border: Border.all(color: Colors.white, width: isCenter ? 2.5 : 2),
              ),
              alignment: Alignment.center,
              child: Text(
                mate.avatar,
                style: TextStyle(fontSize: isCenter ? 30 : 22),
              ),
            ),
            const SizedBox(height: 4),

            // Kid Name
            Text(
              mate.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isCenter ? 13 : 11,
              ),
            ),

            // Score Badge pill
            Container(
              margin: const EdgeInsets.only(top: 3, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: glowColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🟡', style: TextStyle(fontSize: 9)),
                  const SizedBox(width: 3),
                  Text(
                    '$score',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Podium Solid Block
            Container(
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: pillarGradient,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$rank',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: isCenter ? 36 : 28,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    rank == 1 ? 'CHAMP' : rank == 2 ? 'SILVER' : 'BRONZE',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankRowItem(KidMate mate, int rank) {
    final score = (mate.stars * 25) + (mate.dayLevel * 60) + (mate.friendshipScore * 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: GoogleFonts.outfit(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(mate.avatar, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mate.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  'Lvl ${mate.dayLevel} • ${mate.ageGroup} Yrs',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🟡', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Profile View Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              PocketKidsProfileBottomSheet.show(context, mate: mate).then((_) {
                if (mounted) setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF84CC16), // Kumi candy green
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'View',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-TAB 2: VOICE ECHO ---
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
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      await PocketKidsService.setKidPremium(true);
                      if (!mounted) return;
                      setState(() {});
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Adventure Pass Activated! Day $day Unlocked! 🌟',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
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
  // =========================================================================
  // 🌟 KIDS LEVEL LEARNING HUB SHEET (10 Sequential Daily Games & Phonics)
  // =========================================================================
  void _showKidsLevelActivitySheet(BuildContext context, int day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            final biome = _getKidsBiomeTitleForDay(day);
            final traceItem = KidsTracingCurriculum.getItem(
              (day - 1) % KidsTracingCurriculum.letters.length,
            );

            // Count completed steps today (4 Bite-Sized Micro Steps for Peak Simplicity!)
            final totalDailySteps =
                PocketKidsService.getTotalDailyStepsForDay(day);
            int completedStepsCount = 0;
            for (int s = 1; s <= totalDailySteps; s++) {
              if (PocketKidsService.isDayStepCompleted(day, s)) {
                completedStepsCount++;
              }
            }

            Future<void> launchStep(
              int stepIndex,
              Future<void> Function() launchFn,
            ) async {
              final isUnlocked =
                  PocketKidsService.isDayStepUnlocked(day, stepIndex);
              if (!isUnlocked) {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Complete Step ${stepIndex - 1} first to unlock! 🔒',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              HapticFeedback.mediumImpact();
              // Await game execution so bottom sheet stays open and persists
              await launchFn();
              await PocketKidsService.markDayStepCompleted(day, stepIndex);

              // If all 14 steps are finished and day was not yet completed, mark day complete & auto-award Defense Card!
              final wasDayAlreadyCompleted = PocketKidsService.isDayCompleted(day);
              int updatedCount = 0;
              for (int s = 1; s <= totalDailySteps; s++) {
                if (PocketKidsService.isDayStepCompleted(day, s)) {
                  updatedCount++;
                }
              }
              if (!wasDayAlreadyCompleted && updatedCount >= totalDailySteps && stepIndex == totalDailySteps) {
                await PocketKidsService.markDayCompleted(day, 3);
                if (mounted && context.mounted) {
                  PocketKidsHeroCardClaimDialog.show(context, day: day);
                }
              }

              setSheetState(() {});
              if (mounted) setState(() {});
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                              border: Border.all(color: const Color(0xFF38BDF8), width: 2),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'DAY $day: $biome',
                                        style: GoogleFonts.fredoka(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFFFD700),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('⭐ ', style: TextStyle(fontSize: 12)),
                                          Text(
                                            '$completedStepsCount/$totalDailySteps',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFFD700),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Complete each step sequentially to earn +15 KS & 1 ⭐!',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (completedStepsCount / totalDailySteps.toDouble()).clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                          minHeight: 6,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =======================================================
                      // 🌟 PHASE 1: DAYS 1 TO 15 — THE ALPHABET & FIRST 50 WORDS
                      // 🌟 PEAK SIMPLICITY: Exactly 4 micro-steps (5 mins/day!)
                      // =======================================================
                      if (day <= 15) ...[
                        // Step 1: Phonics Tracing (A to Z)
                        _buildActivityOptionTile(
                          stepNumber: 1,
                          iconEmoji: '🎨',
                          title: 'Phonics & Letter Tracing (Day $day)',
                          subtitle: 'Trace letters with rainbow stardust & listen to phonics sound',
                          gradientColors: const [Color(0xFFFF2D55), Color(0xFFFF9500)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 1),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 1),
                          onTap: () => launchStep(
                            1,
                            () => PocketKidsLetterTracingPage.show(
                              context,
                              initialIndex: (day - 1) % KidsTracingCurriculum.letters.length,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 2: 1-Tap Picture Discovery (Listen & Tap)
                        _buildActivityOptionTile(
                          stepNumber: 2,
                          iconEmoji: '🍎',
                          title: 'Picture & Sound Magic (1-Tap Match)',
                          subtitle: 'Listen to the word and tap the cute cartoon card to win stars!',
                          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 2),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 2),
                          onTap: () => launchStep(
                            2,
                            () => PocketKidsPictureQuizPage.show(
                              context,
                              category: day % 2 == 0 ? 'Animals' : 'Fruits',
                              day: day,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 3: 3-Letter Magnet Word Snap (C-A-T)
                        _buildActivityOptionTile(
                          stepNumber: 3,
                          iconEmoji: '🔤',
                          title: 'Baby Word Snap & Spelling 🔤',
                          subtitle: 'Tap big letter tiles to build simple words with audio cheer',
                          gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 3),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 3),
                          onTap: () => launchStep(
                            3,
                            () => PocketEssentialSpellingPage.show(
                              context,
                              day: day,
                              isKidsMode: true,
                              onStepFinished: (_) => PocketKidsService.markDayStepCompleted(day, 3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 4: 1-Word Mic Magic (Echo Parrot)
                        _buildActivityOptionTile(
                          stepNumber: 4,
                          iconEmoji: '🎙️',
                          title: 'Echo Mascot (Say 1 Magic Word!) ⭐',
                          subtitle: 'Tap the mic, say 1 word with animal buddy & claim your Hero Card!',
                          gradientColors: const [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 4),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 4),
                          onTap: () => launchStep(
                            4,
                            () => PocketKidsSpokenDialogueLabPage.show(
                              context,
                              day: day,
                            ),
                          ),
                        ),
                      ]
                      // =======================================================
                      // 🌟 PHASE 2: DAYS 16 TO 30 — COLORS, NUMBERS & ACTION VERBS
                      // =======================================================
                      else if (day <= 30) ...[
                        // Step 1: Word Builder
                        _buildActivityOptionTile(
                          stepNumber: 1,
                          iconEmoji: '🐮',
                          title: 'Word Morph & Spelling 🐮',
                          subtitle: 'Assemble cartoon vocabulary words with native voice audio',
                          gradientColors: const [Color(0xFFFF2D55), Color(0xFFFF9500)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 1),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 1),
                          onTap: () => launchStep(
                            1,
                            () => PocketKidsKumiWordBuilderPage.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 2: Safari Animal Feeder or Fruit Market
                        _buildActivityOptionTile(
                          stepNumber: 2,
                          iconEmoji: day % 2 == 0 ? '🦁' : '🍎',
                          title: day % 2 == 0 ? 'Safari Animal Feeder 🦁' : 'Fruit & Bakery Market 🍎',
                          subtitle: 'Feed hungry animals or shop fruits with real voice sounds',
                          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 2),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 2),
                          onTap: () => launchStep(
                            2,
                            () => day % 2 == 0
                                ? PocketKidsSafariAnimalFeederGame.show(context, day: day)
                                : PocketKidsFruitBakeryMarketGame.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 3: Number Magic & Star Counting
                        _buildActivityOptionTile(
                          stepNumber: 3,
                          iconEmoji: '🔢',
                          title: 'Number Magic & Counting (1 to 20)',
                          subtitle: 'Count sparkling shooting stars and puppies with voice audio',
                          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 3),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 3),
                          onTap: () => launchStep(
                            3,
                            () => PocketKidsNumberMagicCountingGame.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 4: Superhero Action Verbs
                        _buildActivityOptionTile(
                          stepNumber: 4,
                          iconEmoji: '🦸',
                          title: 'Superhero Action Verbs & Speaking 🦸',
                          subtitle: 'Jump, run, fly, dance & sing with live mic scoring!',
                          gradientColors: const [Color(0xFFEC4899), Color(0xFFDB2777)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 4),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 4),
                          onTap: () => launchStep(
                            4,
                            () => PocketKidsActionSuperheroJumpGame.show(context, day: day),
                          ),
                        ),
                      ]
                      // =======================================================
                      // 🌟 PHASE 3: DAYS 31 TO 50 — SENTENCE TRAIN & OPPOSITES
                      // =======================================================
                      else if (day <= 50) ...[
                        // Step 1: Rhyme Time Frog
                        _buildActivityOptionTile(
                          stepNumber: 1,
                          iconEmoji: '🐸',
                          title: 'Rhyme Time Frog Lilypad Hopper 🐸',
                          subtitle: 'Leap across the river by hopping on rhyming word lilypads',
                          gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 1),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 1),
                          onTap: () => launchStep(
                            1,
                            () => PocketKidsRhymeFrogHopperGame.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 2: Opposites Seesaw
                        _buildActivityOptionTile(
                          stepNumber: 2,
                          iconEmoji: '⚖️',
                          title: 'Opposites Seesaw Balance Scale ⚖️',
                          subtitle: 'Big vs Small, Hot vs Cold! Balance the seesaw with opposite pairs',
                          gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 2),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 2),
                          onTap: () => launchStep(
                            2,
                            () => PocketKidsOppositesSeesawGame.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 3: Sentence Builder Train
                        _buildActivityOptionTile(
                          stepNumber: 3,
                          iconEmoji: '🚂',
                          title: 'Sentence Builder (Train & Runway) 🧩',
                          subtitle: 'Build 3-word sentences with Choo-Choo train blocks',
                          gradientColors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 3),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 3),
                          onTap: () => launchStep(
                            3,
                            () => _showSentenceBuilderChoiceDialog(context, day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 4: Safe Word-Bank Chat
                        _buildActivityOptionTile(
                          stepNumber: 4,
                          iconEmoji: '💬',
                          title: 'Safe English Chat with Buddy 💬',
                          subtitle: 'Tap word bank chips to chat with your buddy and finish day!',
                          gradientColors: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 4),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 4),
                          onTap: () => launchStep(
                            4,
                            () => PocketKidsMateChatPage.open(
                              context,
                              mate: PocketKidsRobotsData.robotsAndHomies.firstWhere(
                                (b) => b.dayLevel >= day,
                                orElse: () => PocketKidsRobotsData.robotsAndHomies.first,
                              ),
                            ),
                          ),
                        ),
                      ]
                      // =======================================================
                      // 🌟 PHASE 4: DAYS 51 TO 70 — DAILY ROUTINES & TENSES
                      // =======================================================
                      else if (day <= 70) ...[
                        // Step 1: Spelling Runway
                        _buildActivityOptionTile(
                          stepNumber: 1,
                          iconEmoji: '🔤',
                          title: 'Essential Spelling Challenge 🔤',
                          subtitle: 'Tap letter tiles into slots with voice feedback',
                          gradientColors: const [Color(0xFF10B981), Color(0xFF00C7BE)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 1),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 1),
                          onTap: () => launchStep(
                            1,
                            () => PocketEssentialSpellingPage.show(
                              context,
                              day: day,
                              isKidsMode: true,
                              onStepFinished: (_) => PocketKidsService.markDayStepCompleted(day, 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 2: Past, Present & Future Tenses
                        _buildActivityOptionTile(
                          stepNumber: 2,
                          iconEmoji: '⏳',
                          title: 'Past, Present & Future Tenses ⏳',
                          subtitle: 'Learn action tenses with falling blocks & hints',
                          gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 2),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 2),
                          onTap: () => launchStep(
                            2,
                            () => PocketKidsTenseDropGame.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 3: Spoken Dialogue Lab
                        _buildActivityOptionTile(
                          stepNumber: 3,
                          iconEmoji: '🗣️',
                          title: 'Spoken English & Dialogue Lab 🗣️',
                          subtitle: 'Interactive voice conversation with animal mascot',
                          gradientColors: const [Color(0xFF007AFF), Color(0xFF5856D6)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 3),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 3),
                          onTap: () => launchStep(
                            3,
                            () => PocketKidsSpokenDialogueLabPage.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 4: Safe Chat with Buddy
                        _buildActivityOptionTile(
                          stepNumber: 4,
                          iconEmoji: '💬',
                          title: 'Safe English Chat with Buddy 💬',
                          subtitle: 'Chat in English with your animal buddy and finish day!',
                          gradientColors: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 4),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 4),
                          onTap: () => launchStep(
                            4,
                            () => PocketKidsMateChatPage.open(
                              context,
                              mate: PocketKidsRobotsData.robotsAndHomies.firstWhere(
                                (b) => b.dayLevel >= day,
                                orElse: () => PocketKidsRobotsData.robotsAndHomies.first,
                              ),
                            ),
                          ),
                        ),
                      ]
                      // =======================================================
                      // 🌟 PHASE 5: DAYS 71 TO 90 — STORYTELLER & SPEECH CHAMPION
                      // =======================================================
                      else ...[
                        // Step 1: 2D Open World Driving Adventure
                        _buildActivityOptionTile(
                          stepNumber: 1,
                          iconEmoji: '🌍',
                          title: '2D Open World Driving Adventure 🚗',
                          subtitle: 'Drive your cartoon buggy across rolling hills & collect words',
                          gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 1),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 1),
                          onTap: () => launchStep(
                            1,
                            () => PocketKidsDayOpenWorldPage.open(context, day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 2: Cumulative Speech Arena
                        _buildActivityOptionTile(
                          stepNumber: 2,
                          iconEmoji: '🎙️',
                          title: 'Cumulative Speech Arena 🌟',
                          subtitle: 'Public speaking stage! Practice 1-4 lines with microphone scoring',
                          gradientColors: const [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 2),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 2),
                          onTap: () => launchStep(
                            2,
                            () => PocketKidsCumulativeSpeechArenaPage.show(context, day: day),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 3: House Raid & Defense Challenge
                        _buildActivityOptionTile(
                          stepNumber: 3,
                          iconEmoji: '⚔️',
                          title: 'Buddy House Defense Challenge ⚔️',
                          subtitle: 'Raid neighbor buddy houses & win gold trophy defenses!',
                          gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 3),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 3),
                          onTap: () => launchStep(
                            3,
                            () {
                              final defender = PocketKidsRobotsData.robotsAndHomies.firstWhere(
                                (b) => b.dayLevel >= day,
                                orElse: () => PocketKidsRobotsData.robotsAndHomies.first,
                              );
                              return Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PocketKidsHouseChallengePage(defender: defender),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Step 4: Safe Chat with Buddy & Hero Victory
                        _buildActivityOptionTile(
                          stepNumber: 4,
                          iconEmoji: '💬',
                          title: 'Safe English Chat with Buddy 💬',
                          subtitle: 'Complete final chat & claim Day $day Champion Hero Card!',
                          gradientColors: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
                          isCompleted: PocketKidsService.isDayStepCompleted(day, 4),
                          isUnlocked: PocketKidsService.isDayStepUnlocked(day, 4),
                          onTap: () => launchStep(
                            4,
                            () => PocketKidsMateChatPage.open(
                              context,
                              mate: PocketKidsRobotsData.robotsAndHomies.firstWhere(
                                (b) => b.dayLevel >= day,
                                orElse: () => PocketKidsRobotsData.robotsAndHomies.first,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityOptionTile({
    required int stepNumber,
    required String iconEmoji,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required bool isCompleted,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(colors: gradientColors)
              : const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4ADE80)
                : isUnlocked
                    ? Colors.white
                    : Colors.white12,
            width: isCompleted ? 2.5 : (isUnlocked ? 2.0 : 1.2),
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Leading Emoji Avatar
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.white : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Text(
                iconEmoji,
                style: TextStyle(
                  fontSize: 22,
                  color: isUnlocked ? null : Colors.white38,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Titles & Reward Badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF22C55E)
                              : (isUnlocked
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : Colors.white10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCompleted
                              ? 'DONE ✔️'
                              : (isUnlocked ? 'STEP $stepNumber' : 'STEP $stepNumber 🔒'),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCompleted
                            ? '+15 KS • 1 ⭐'
                            : (isUnlocked ? '+15 KS • 1 ⭐' : 'Locked'),
                        style: GoogleFonts.outfit(
                          color: isCompleted
                              ? const Color(0xFF86EFAC)
                              : (isUnlocked
                                  ? const Color(0xFFFFE082)
                                  : Colors.white38),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      color: isUnlocked ? Colors.white : Colors.white38,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.white24,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Trailing Status Indicator
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              )
            else if (isUnlocked)
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 30,
              )
            else
              const Icon(
                Icons.lock_rounded,
                color: Colors.white38,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSentenceBuilderChoiceDialog(
    BuildContext context,
    int day,
  ) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Color(0xFFF59E0B), width: 2.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sentence Builder Modes 🧩',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Play with the Choo-Choo Train or the Candy Runway!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Option 1: Choo-Choo Train Builder
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                await PocketKidsSentenceBuilderPage.show(
                  context,
                  day: day,
                  onCompleted: () => PocketKidsService.markDayStepCompleted(day, 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🚂', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choo-Choo Train Builder',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Snap words into train bogies with steam whistles & Flame smoke!',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Option 2: Candy Runway Builder
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                await PocketSentenceBuilderGamePage.show(
                  context,
                  day: day,
                  isKidsMode: true,
                  onStepFinished: (_) => PocketKidsService.markDayStepCompleted(day, 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🧩', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Candy Runway Builder (10 Rounds)',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Tap candy tiles on runway with Malayalam audio voice & sparkles!',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 3: 🎮 ARCADE & LEARNING PLAYGROUND (മിനി-ഗെയിമുകൾ & കാറ്റഗറി ഹബ്)
  // =========================================================================
  Widget _buildArcadePlaygroundTab() {
    final categories = [
      {
        'title': 'Balloon Pop',
        'sub': 'Floating ABC Pops',
        'emoji': '🎈',
        'color': const Color(0xFFEC4899),
        'bg': const Color(0xFFFDF2F8),
        'action': 'balloon_pop',
      },
      {
        'title': 'Animals World',
        'sub': 'Lion, Fox, Elephant',
        'emoji': '🦁',
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFECFDF5),
        'action': 'match_it',
      },
      {
        'title': 'Fruits & Food',
        'sub': 'Apple, Banana, Mango',
        'emoji': '🍎',
        'color': const Color(0xFFF59E0B),
        'bg': const Color(0xFFFFFBEB),
        'action': 'word_builder',
      },
      {
        'title': 'Numbers 1-10',
        'sub': 'Count & Match Stars',
        'emoji': '🔢',
        'color': const Color(0xFF3B82F6),
        'bg': const Color(0xFFEFF6FF),
        'action': 'picture_quiz',
      },
      {
        'title': 'ABC Phonics',
        'sub': 'A-Z Letter Tracing',
        'emoji': '🔤',
        'color': const Color(0xFF8B5CF6),
        'bg': const Color(0xFFF5F3FF),
        'action': 'tracing',
      },
      {
        'title': 'Magic Art Studio',
        'sub': 'Colors, Shapes & Badges',
        'emoji': '🎨',
        'color': const Color(0xFFEC4899),
        'bg': const Color(0xFFFDF2F8),
        'action': 'art_studio',
      },
      {
        'title': 'Daily Sentences',
        'sub': 'Train Builder & Speech',
        'emoji': '🚂',
        'color': const Color(0xFF06B6D4),
        'bg': const Color(0xFFECFEFF),
        'action': 'sentence_builder',
      },
    ];

    final allGames = [
      {
        'title': 'Balloon Pop Spelling Lab 🎈',
        'sub': 'Pop floating letter balloons to spell words with audio stars! Super addictive.',
        'color': const Color(0xFFEC4899),
        'emoji': '🎈',
        'tag': 'POPULAR • SPELLING',
        'ks': '+20 KS',
        'cat': 1,
        'type': 'balloon_pop',
      },
      {
        'title': 'Word Builder (Spelling Lab) 🐮',
        'sub': 'Look at the picture, tap scrambled letters & build words! Hints & voice included.',
        'color': const Color(0xFFF59E0B),
        'emoji': '🐮',
        'tag': 'SPELLING LAB',
        'ks': '+15 KS',
        'cat': 1,
        'type': 'word_builder',
      },
      {
        'title': 'Match It! Animals & Letters 🔗',
        'sub': 'Draw lines to connect animals to their names, plus 2x2 picture-to-letter grid!',
        'color': const Color(0xFF10B981),
        'emoji': '🦁',
        'tag': 'MATCH IT',
        'ks': '+20 KS',
        'cat': 2,
        'type': 'match_it',
      },
      {
        'title': 'Animals & Numbers Quiz 🐘',
        'sub': 'Which animal is this? How many items? 4 pastel buttons with cheerful audio rewards!',
        'color': const Color(0xFF8B5CF6),
        'emoji': '🐘',
        'tag': 'PICTURE QUIZ',
        'ks': '+15 KS',
        'cat': 2,
        'type': 'picture_quiz',
      },
      {
        'title': 'Little Artist Magic Studio 🎨',
        'sub': '6 progressive drawing challenges, rainbow glow brushes & polaroid trophies!',
        'color': const Color(0xFFEC4899),
        'emoji': '🎨',
        'tag': 'CREATIVE STUDIO',
        'ks': '+25 KS',
        'cat': 3,
        'type': 'art_studio',
      },
      {
        'title': 'Sentence Builder Game 🧩',
        'sub': 'Tap vibrant candy word tiles in order with Flame sparkles & native audio hints!',
        'color': const Color(0xFF06B6D4),
        'emoji': '🧩',
        'tag': 'FLAME BUILDER',
        'ks': '+15 KS',
        'cat': 4,
        'type': 'sentence_builder',
      },
      {
        'title': 'Essential Spelling Challenge 🔤',
        'sub': 'Practice spelling high-frequency kid vocabulary with interactive letter slots & TTS audio!',
        'color': const Color(0xFF10B981),
        'emoji': '🔤',
        'tag': 'SPELLING EXAM',
        'ks': '+15 KS',
        'cat': 1,
        'type': 'essential_spelling',
      },
      {
        'title': 'Past, Present & Future Tenses ⏳',
        'sub': 'Learn sleep ➔ slept with falling action blocks & native Malayalam tips!',
        'color': const Color(0xFF6366F1),
        'emoji': '⏳',
        'tag': 'GRAMMAR ARENA',
        'ks': '+15 KS',
        'cat': 4,
        'type': 'tenses',
      },
      {
        'title': 'Falling Blocks Spelling Rush 🧱',
        'sub': 'Catch falling alphabet blocks to complete today\'s syllabus words!',
        'color': const Color(0xFFF97316),
        'emoji': '🧱',
        'tag': 'SYLLABUS RUSH',
        'ks': '+15 KS',
        'cat': 1,
        'type': 'falling_blocks',
      },
      {
        'title': 'Rainbow Alphabet Tracing ✍️',
        'sub': 'Rainbow stardust finger tracing A-Z with phonics sounds & star celebrations!',
        'color': const Color(0xFF14B8A6),
        'emoji': '✍️',
        'tag': 'PHONICS A-Z',
        'ks': '+10 KS',
        'cat': 1,
        'type': 'tracing',
      },
      {
        'title': 'Spelling Animals Jungle 🐼',
        'sub': 'Explore cute wild animals, discover sounds, learn spelling & phonics!',
        'color': const Color(0xFF10B981),
        'emoji': '🐼',
        'tag': 'JUNGLE SAFARI',
        'ks': '+15 KS',
        'cat': 2,
        'type': 'match_it',
      },
      {
        'title': 'Vehicles & Speed Wheels 🚗',
        'sub': 'Zoom cars, buses, planes & rockets! Match engine sounds & spell vehicle words.',
        'color': const Color(0xFFEF4444),
        'emoji': '🚗',
        'tag': 'VEHICLES • SPELLING',
        'ks': '+20 KS',
        'cat': 1,
        'type': 'vehicles',
      },
      {
        'title': 'Safari Animal Feeder 🦁',
        'sub': 'Feed hungry lions, pandas & monkeys their favorite food with realistic wild sounds!',
        'color': const Color(0xFF10B981),
        'emoji': '🦁',
        'tag': 'WILD SAFARI',
        'ks': '+20 KS',
        'cat': 2,
        'type': 'safari_feeder',
      },
      {
        'title': 'Fruit, Veggie & Bakery Shop 🍎',
        'sub': 'Shop for fresh apples, bananas, cookies & cupcakes in the sunny market!',
        'color': const Color(0xFFF59E0B),
        'emoji': '🍎',
        'tag': 'MARKET STALL',
        'ks': '+20 KS',
        'cat': 2,
        'type': 'fruit_market',
      },
      {
        'title': 'Number Magic & Star Counting 🔢',
        'sub': 'Count twinkling stars, balloons and cute puppies from 1 to 20!',
        'color': const Color(0xFF8B5CF6),
        'emoji': '🔢',
        'tag': 'NUMBERS 1-20',
        'ks': '+20 KS',
        'cat': 1,
        'type': 'number_magic',
      },
      {
        'title': 'Superhero Action Verbs ⚡',
        'sub': 'Jump, run, fly, dance and sing! Master core action verbs that power up English.',
        'color': const Color(0xFFEC4899),
        'emoji': '🦸',
        'tag': 'ACTION VERBS',
        'ks': '+20 KS',
        'cat': 4,
        'type': 'action_verbs',
      },
      {
        'title': 'Rhyme Time Lilypad Hopper 🐸',
        'sub': 'Help the cute frog leap across the river by hopping on rhyming word lilypads!',
        'color': const Color(0xFF0284C7),
        'emoji': '🐸',
        'tag': 'PHONICS RHYMES',
        'ks': '+20 KS',
        'cat': 2,
        'type': 'rhyme_frog',
      },
      {
        'title': 'Opposites Seesaw Balance ⚖️',
        'sub': 'Big vs Small, Hot vs Cold, Fast vs Slow! Balance the seesaw with opposite pairs.',
        'color': const Color(0xFF6366F1),
        'emoji': '⚖️',
        'tag': 'OPPOSITES',
        'ks': '+20 KS',
        'cat': 2,
        'type': 'opposites',
      },
      {
        'title': 'Cumulative Speech Arena 🎙️',
        'sub': 'Public speaking snowball stage! Start with 1 line and build up to a grand speech!',
        'color': const Color(0xFFFFD700),
        'emoji': '🎙️',
        'tag': 'PUBLIC SPEAKING',
        'ks': '+25 KS',
        'cat': 4,
        'type': 'cumulative_speech',
      },
    ];

    final filteredGames = _arcadeCategoryFilter == 0
        ? allGames
        : allGames.where((g) => g['cat'] == _arcadeCategoryFilter).toList();

    return Container(
      color: const Color(0xFFE8F8F5), // Kumi Soft Mint Background
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Top Welcome Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Text('🎈', style: TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${PocketKidsService.kidName}! 👋',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF78350F),
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              'What do you want to learn & play today?',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF78350F).withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Badges Row (Clean, responsive, KS only)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildArcadeBadge('🔥', 'Day ${PocketKidsService.currentUnlockedDay}', const Color(0xFFEF4444)),
                      _buildArcadeBadge('⭐', '${PocketKidsService.kidsScore} KS', const Color(0xFF8B5CF6)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📚 Learn by Category',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Explore All',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  return GestureDetector(
                    onTap: () {
                      _launchArcadeGame({'type': cat['action']});
                    },
                    child: Container(
                      width: 132,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cat['bg'] as Color,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: (cat['color'] as Color).withValues(alpha: 0.35),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (cat['color'] as Color).withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat['emoji'] as String, style: const TextStyle(fontSize: 26)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (cat['color'] as Color),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'PLAY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            cat['title'] as String,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            cat['sub'] as String,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Section 2: Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildArcadeFilterPill(0, '🌟 All Games'),
                  _buildArcadeFilterPill(1, '🔤 Spelling & Words'),
                  _buildArcadeFilterPill(2, '🔗 Match & Quiz'),
                  _buildArcadeFilterPill(3, '🎨 Creative Art'),
                  _buildArcadeFilterPill(4, '🚂 Sentences & Tenses'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: Games List Header
            Row(
              children: [
                Text(
                  '🎮 Interactive Games',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredGames.length}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Games Items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredGames.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final g = filteredGames[idx];
                final col = g['color'] as Color;

                return GestureDetector(
                  onTap: () => _launchArcadeGame(g),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: col.withValues(alpha: 0.28),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: col.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            g['emoji'] as String,
                            style: const TextStyle(fontSize: 27),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: col.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      g['tag'] as String,
                                      style: GoogleFonts.inter(
                                        color: col,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                                      const SizedBox(width: 2),
                                      Text(
                                        g['ks'] as String,
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFF59E0B),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                g['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                g['sub'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11.5,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: col,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: col.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PLAY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.5,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildArcadeBadge(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArcadeFilterPill(int index, String label) {
    final isSel = _arcadeCategoryFilter == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _arcadeCategoryFilter = index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSel ? Colors.white : const Color(0xFF475569),
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _launchArcadeGame(Map<String, dynamic> g) {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();
    final type = g['type'] ?? g['action'];

    if (type == 'balloon_pop') {
      PocketKidsBalloonPopGame.show(context).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'word_builder') {
      PocketKidsKumiWordBuilderPage.show(context).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'match_it') {
      PocketKidsMatchItPage.show(context).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'picture_quiz') {
      PocketKidsPictureQuizPage.show(context).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'tracing') {
      PocketKidsLetterTracingPage.show(context).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'sentence_builder') {
      PocketSentenceBuilderGamePage.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
        isKidsMode: true,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'essential_spelling' || type == 'spelling') {
      PocketEssentialSpellingPage.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
        isKidsMode: true,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'tenses') {
      PocketKidsTenseDropGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'falling_blocks') {
      PocketKidsFallingWordBlocksGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'art_studio') {
      PocketKidsArtStudioPage.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'vehicles') {
      PocketKidsVehiclesAndWheelsGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'safari_feeder') {
      PocketKidsSafariAnimalFeederGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'fruit_market') {
      PocketKidsFruitBakeryMarketGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'number_magic') {
      PocketKidsNumberMagicCountingGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'action_verbs') {
      PocketKidsActionSuperheroJumpGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'rhyme_frog') {
      PocketKidsRhymeFrogHopperGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'opposites') {
      PocketKidsOppositesSeesawGame.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (type == 'cumulative_speech') {
      PocketKidsCumulativeSpeechArenaPage.show(
        context,
        day: PocketKidsService.currentUnlockedDay,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else {
      PocketKidsDayOpenWorldPage.open(context, (g['day'] as int?) ?? 1).then((_) {
        if (mounted) setState(() {});
      });
    }
  }


  // =========================================================================
  // =========================================================================
  // TAB 4: 👤 KID PROFILE (Kumi UI Design Profile Screen)
  // =========================================================================
  Widget _buildKidProfileTab() {
    final curDay = PocketKidsService.currentUnlockedDay;
    final house = PocketKidsService.getHouseForDay(curDay);

    return Container(
      color: const Color(0xFFE8F8F5), // Kumi Soft Mint
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Hero Avatar & Name Card (Matching Kumi Top-Right Screen)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3E34).withValues(alpha: 0.06),
                  blurRadius: 12,
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
                          color: const Color(0xFFEDFAF7),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF8CD837), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8CD837).withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          PocketKidsService.kidAvatar.isNotEmpty ? PocketKidsService.kidAvatar : '🦁',
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8CD837),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Kumi Level Pill: "Name - Lvl X"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CD837),
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF6FAF24), width: 3),
                    ),
                  ),
                  child: Text(
                    '${PocketKidsService.kidName} - Lvl $curDay',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Little English Explorer 🌟 • Ages 4–8',
                  style: GoogleFonts.outfit(color: const Color(0xFF6B8B82), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    PocketKidsProfileSetupDialog.show(
                      context,
                      isEditMode: true,
                      onCompleted: () {
                        if (mounted) setState(() {});
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDFAF7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC7EDE3), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded, color: Color(0xFF0F3E34), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Edit Profile & Level',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F3E34),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 📅 DAILY STREAK CARD (Direct Match to Kumi UI Design)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3E34).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily streak',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F3E34),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                      ),
                      child: Text(
                        '🔥 ${PocketKidsService.completedDaysCount} Days Active',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Mo', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].asMap().entries.map((e) {
                    final isDone = e.key < (PocketKidsService.completedDaysCount % 7 == 0 && PocketKidsService.completedDaysCount > 0 ? 7 : (PocketKidsService.completedDaysCount % 7));
                    final isToday = e.key == (DateTime.now().weekday - 1);

                    return Column(
                      children: [
                        Text(
                          e.value,
                          style: GoogleFonts.outfit(
                            color: isToday ? const Color(0xFF8CD837) : const Color(0xFF6B8B82),
                            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? const Color(0xFF8CD837) : const Color(0xFFEDFAF7),
                            border: Border.all(
                              color: isToday
                                  ? const Color(0xFF6FAF24)
                                  : (isDone ? const Color(0xFF6FAF24) : const Color(0xFFC7EDE3)),
                              width: isToday ? 2.2 : 1.5,
                            ),
                            boxShadow: [
                              if (isDone)
                                BoxShadow(
                                  color: const Color(0xFF8CD837).withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                              : Text(
                                  '${e.key + 1}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF6B8B82),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🏆 ACHIEVEMENTS CARD (Direct Match to Kumi UI Design)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3E34).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievements',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F3E34),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAchievementItem(
                  emoji: '🧱',
                  title: 'Falling Word Blocks',
                  progressStr: '${math.min(10, PocketKidsService.completedDaysCount)}/10',
                  progressVal: (PocketKidsService.completedDaysCount / 10).clamp(0.1, 1.0),
                  onPlay: () {
                    PocketKidsFallingWordBlocksGame.show(context, day: PocketKidsService.currentUnlockedDay);
                  },
                ),
                const SizedBox(height: 10),
                _buildAchievementItem(
                  emoji: '⏳',
                  title: 'Past / Present Tenses',
                  progressStr: '${math.min(10, (PocketKidsService.completedDaysCount * 0.8).ceil())}/10',
                  progressVal: ((PocketKidsService.completedDaysCount * 0.8) / 10).clamp(0.1, 1.0),
                  onPlay: () {
                    PocketKidsTenseDropGame.show(context, day: PocketKidsService.currentUnlockedDay);
                  },
                ),
                const SizedBox(height: 10),
                _buildAchievementItem(
                  emoji: '🚂',
                  title: 'Sentence Builder Train',
                  progressStr: '${math.min(10, (PocketKidsService.completedDaysCount * 0.6).ceil())}/10',
                  progressVal: ((PocketKidsService.completedDaysCount * 0.6) / 10).clamp(0.1, 1.0),
                  onPlay: () {
                    PocketKidsSentenceBuilderPage.show(context, day: PocketKidsService.currentUnlockedDay);
                  },
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

          // 🌟 MY HERO DEFENSE CARDS (1–90) COLLECTION GRID 🃏 (User Audio Directive)
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
            child: Builder(
              builder: (context) {
                final completedCount = PocketKidsService.completedDaysCount;
                final curUnlocked = PocketKidsService.currentUnlockedDay;

                // Collect days based on _cardFilterTab
                List<int> cardDays = [];
                for (int d = 1; d <= 90; d++) {
                  final isUnlocked = PocketKidsService.isDayCompleted(d) || d <= curUnlocked;
                  if (_cardFilterTab == 1 && !isUnlocked) continue;
                  if (_cardFilterTab == 2 && isUnlocked) continue;
                  cardDays.add(d);
                }

                final displayDays = _expandAllCards ? cardDays : cardDays.take(9).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
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
                                'Auto-earned on conquering each Day! (${math.min(completedCount, 90)}/90 Cards Achieved)',
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

                    const SizedBox(height: 12),

                    // Filter Chips: All (90), Achieved, Locked
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCardFilterChip(0, 'All (90)'),
                          const SizedBox(width: 8),
                          _buildCardFilterChip(1, 'Achieved 🏆 (${math.min(completedCount, 90)})'),
                          const SizedBox(width: 8),
                          _buildCardFilterChip(2, 'Locked 🔒 (${90 - math.min(completedCount, 90)})'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 🃏 3-Column Cards Grid Showcase
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.70,
                      ),
                      itemCount: displayDays.length,
                      itemBuilder: (context, idx) {
                        final day = displayDays[idx];
                        final isUnlocked = PocketKidsService.isDayCompleted(day) || day <= curUnlocked;
                        final isMale = day % 2 == 0;
                        final card = PopArtCardHelper.getCardForDay(day, isMale: isMale);

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if (isUnlocked) {
                              PocketGameAudioService.instance.playCoinSound();
                              _speakText('${card.title}! ${card.subtitle}');
                              PopArtAvatarCardsViewerPage.open(context, initialIndex: day - 1);
                            } else {
                              _speakText('Day $day is locked! Complete daily learning to auto-unlock this hero card!');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isUnlocked ? card.bgColor : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUnlocked ? const Color(0xFFFFD700) : Colors.white24,
                                width: isUnlocked ? 2.0 : 1.0,
                              ),
                              boxShadow: isUnlocked
                                  ? [
                                      BoxShadow(
                                        color: card.bgColor.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  if (isUnlocked) ...[
                                    // PopArt Card Graphic
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: PopArtCardCustomPainter(data: card),
                                      ),
                                    ),
                                    // Day Badge
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.75),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'DAY $day',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFD700),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Card Title Label
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
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
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    // Locked Card State
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.lock_rounded, color: Colors.white38, size: 24),
                                          const SizedBox(height: 4),
                                          Text(
                                            'DAY $day',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white60,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'LOCKED',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white38,
                                              fontSize: 8.5,
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

                    if (cardDays.length > 9) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _expandAllCards = !_expandAllCards);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _expandAllCards
                                ? 'COLLAPSE CARDS ⬆️'
                                : 'EXPAND ALL (${cardDays.length}) CARDS 👇',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Parental Gate Exit Button (Kumi Style)
          GestureDetector(
            onTap: _exitWithParentGate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3E34).withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: Color(0xFF0F3E34), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'EXIT TO ADULT MODE (PARENT LOCK 🔒)',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F3E34),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  Widget _buildCardFilterChip(int tab, String label) {
    final isSelected = _cardFilterTab == tab;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _cardFilterTab = tab);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildAchievementItem({
    required String emoji,
    required String title,
    required String progressStr,
    required double progressVal,
    required VoidCallback onPlay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressVal,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      progressStr,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              onPlay();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF84CC16), Color(0xFF65A30D)], // Lime Green Candy
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF65A30D).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Play',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    final avatars = ['🐻', '🦁', '🐥', '🦊', '🐼', '🐰', '🐯', '🦄', '🐶', '🐬'];
    String tempAvatar = PocketKidsService.kidAvatar.isNotEmpty ? PocketKidsService.kidAvatar : '🐻';
    String tempGender = PocketKidsService.kidGender;
    final nameCtrl = TextEditingController(text: PocketKidsService.kidName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            decoration: const BoxDecoration(
              color: Color(0xFFE6FFFA), // Soft mint background from Kumi reference
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green Pill Badge: "Select character" (Reference Image 1 Screen 5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF84CC16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Select character',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Big Sparkling Circular Avatar Display with Stars (Reference Image 1 Screen 5)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(tempAvatar, style: const TextStyle(fontSize: 62)),
                    ),
                    const Positioned(
                      top: 4,
                      right: 10,
                      child: Text('✨', style: TextStyle(fontSize: 20)),
                    ),
                    const Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text('⭐', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nickname Input Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
                  ),
                  child: TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF0284C7), size: 20),
                      hintText: 'Nickname',
                      hintStyle: GoogleFonts.inter(color: Colors.black38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Gender Toggle Pills: Female (Blue) vs Male (Green) (Reference Image 1 Screen 5)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => tempGender = 'female');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: tempGender == 'female' ? const Color(0xFFBAE6FD) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: tempGender == 'female' ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                              width: tempGender == 'female' ? 2.5 : 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('♀️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                'Female',
                                style: GoogleFonts.outfit(
                                  color: tempGender == 'female' ? const Color(0xFF0369A1) : Colors.black54,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => tempGender = 'male');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: tempGender == 'male' ? const Color(0xFFBBF7D0) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: tempGender == 'male' ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                              width: tempGender == 'male' ? 2.5 : 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('♂️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                'Male',
                                style: GoogleFonts.outfit(
                                  color: tempGender == 'male' ? const Color(0xFF15803D) : Colors.black54,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Horizontal Avatar Carousel with Circular Checkmark Badge
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: avatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final av = avatars[i];
                      final isSel = av == tempAvatar;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setModalState(() => tempAvatar = av);
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? const Color(0xFF84CC16) : Colors.white,
                                  width: isSel ? 3.5 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isSel ? 0.2 : 0.08),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(av, style: const TextStyle(fontSize: 32)),
                            ),
                            if (isSel)
                              Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF84CC16),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Big Candy Green "Choose character" Button (Reference Image 1 Screen 5)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    final newName = nameCtrl.text.trim();
                    await PocketKidsService.saveKidProfile(
                      name: newName.isNotEmpty ? newName : PocketKidsService.kidName,
                      avatar: tempAvatar,
                      gender: tempGender,
                    );
                    if (mounted) setState(() {});
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF84CC16), Color(0xFF65A30D)], // Lime Green Candy
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF65A30D).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Choose character',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 🕹️ BOTTOM KID NAV (ക്ലീൻ വൈറ്റ് ഗെയിമിഫൈഡ് ബാർ)
  // =========================================================================
  Widget _buildBottomKidNav() {
    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFD4EFE6), width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3E34).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildKidNavItem(0, '🏡', 'HOMES'),
            _buildKidNavItem(1, '🐾', 'MATES'),
            _buildKidNavItem(2, '🎯', 'TRAIL'),
            _buildKidNavItem(3, '🎮', 'ARCADE'),
            _buildKidNavItem(4, '👤', 'PROFILE'),
          ],
        ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFEDFAF7) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSel
                ? Border.all(color: const Color(0xFF8CD837), width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 19, height: 1.1),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    color: isSel ? const Color(0xFF0F3E34) : const Color(0xFF6B8B82),
                    fontSize: 10,
                    fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: 0.2,
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

class _KidsNodeAtmosphere {
  final List<Color> nodeGradient;
  final String tag;

  const _KidsNodeAtmosphere({
    required this.nodeGradient,
    required this.tag,
  });
}
