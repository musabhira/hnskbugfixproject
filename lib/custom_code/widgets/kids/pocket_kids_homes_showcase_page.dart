import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mates_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';

/// 🏡 Kids Homes Showcase & Educational Gaming Hub
/// Enriched with interactive learning mini-games, student curriculum reels,
/// architectural parts quiz, and citadel defense challenges!
class PocketKidsHomesShowcasePage extends StatefulWidget {
  const PocketKidsHomesShowcasePage({super.key});

  @override
  State<PocketKidsHomesShowcasePage> createState() =>
      _PocketKidsHomesShowcasePageState();
}

class _PocketKidsHomesShowcasePageState
    extends State<PocketKidsHomesShowcasePage> {
  final FlutterTts _tts = FlutterTts();
  int _selectedDay = 1;
  KidMate? _selectedMate;

  // Sub-Navigation Tabs
  // 0: ⚔️ Raid Citadel, 1: 🎮 House Mini-Games (3 Games), 2: 📚 Day Syllabus & Reels
  int _homesSubTab = 0;

  // Mini-Games State
  int _activeMiniGame = 0; // 0: House Parts Quiz, 1: Defense Blitz, 2: Brick Speller
  int _partsQuizScore = 0;
  String? _selectedPartName;

  // Defense Blitz Game State
  int _blitzRoundIdx = 0;
  int? _blitzSelectedOption;
  bool? _blitzIsCorrect;
  int _blitzScore = 0;

  // Brick Speller Game State
  List<String> _spellingTappedLetters = [];
  bool _spellingCompleted = false;
  int _sessionStars = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = PocketKidsService.currentUnlockedDay;
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  KidMate get _activeTarget {
    if (_selectedMate != null) return _selectedMate!;
    if (_selectedDay == 100) {
      return KidMate(
        id: 'king_lion',
        name: 'King Lion',
        avatar: '🦁',
        isRobot: true,
        dayLevel: 100,
        houseTier: 'Sovereign Golden Castle',
        bio: 'The Supreme Sovereign of Pocket Kingdom. Defeat his castle to win your 100-Day Graduation Certificate!',
        challengeSentence: 'Stand tall with courage and speak with the voice of a lion!',
      );
    }
    return KidMate(
      id: 'mate_day_$_selectedDay',
      name: 'Day $_selectedDay Defender',
      avatar: '🦁',
      isRobot: true,
      dayLevel: _selectedDay,
      houseTier: 'Tier ${((_selectedDay - 1) ~/ 15) + 1} Citadel',
      bio: 'Practicing spoken English along the mountain road.',
      challengeSentence: 'Practice makes progress! Ready to challenge my house defense?',
    );
  }

  KidDaySyllabus get _currentSyllabus =>
      PocketKids100DaySyllabusDB.getSyllabusForDay(_selectedDay);

  KidsHouse get _currentHouse =>
      PocketKidsService.getHouseForDay(_selectedDay);

  void _awardStars(int count, String reason) {
    HapticFeedback.heavyImpact();
    PocketKidsService.addStars(count);
    setState(() {
      _sessionStars += count;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '+$count Stars! $reason',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _launchAttack() {
    HapticFeedback.heavyImpact();
    final target = _activeTarget;
    _speak("Entering ${target.name}'s Castle defense challenge! Ready to speak English?");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsHouseChallengePage(defender: target),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = _activeTarget;
    final isKingLion = _selectedDay == 100 || target.id == 'king_lion';
    final userUnlockedDay = PocketKidsService.currentUnlockedDay;
    final house = _currentHouse;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isKingLion
                            ? [const Color(0xFFFFD700), const Color(0xFFF59E0B)]
                            : [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(isKingLion ? '👑' : house.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isKingLion ? 'KING LION SOVEREIGN PALACE' : 'KIDS HOMES & CITADEL',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Tier ${house.tier} ${house.title} • Level $_selectedDay',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stars Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD700)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${PocketKidsService.kidStars + _sessionStars}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Find Peer Citadels',
                    icon: const Icon(Icons.people_alt_rounded, color: Color(0xFF38BDF8), size: 22),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      PocketKidsMatesPage.open(context);
                    },
                  ),
                ],
              ),
            ),

            // Horizontal Day Scrubber (Days 1 to 100)
            SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: 100,
                itemBuilder: (context, idx) {
                  final day = idx + 1;
                  final isSelected = _selectedDay == day;
                  final isUnlocked = day <= userUnlockedDay;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedDay = day;
                        _selectedMate = null;
                        _blitzRoundIdx = 0;
                        _blitzSelectedOption = null;
                        _blitzIsCorrect = null;
                        _spellingTappedLetters = [];
                        _spellingCompleted = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (day == 100 ? const Color(0xFFFFD700) : const Color(0xFF38BDF8))
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : (isUnlocked ? Colors.white24 : Colors.transparent),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day == 100 ? '👑 LION 100' : 'DAY $day',
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.black : (isUnlocked ? Colors.white : Colors.white38),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // Living Flame English House Graphic
            SizedBox(
              height: 180,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isKingLion
                        ? [const Color(0xFF451A03), const Color(0xFF0F172A)]
                        : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isKingLion ? const Color(0xFFFFD700) : Colors.white12,
                    width: isKingLion ? 2 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isKingLion ? const Color(0xFFFFD700) : const Color(0xFF38BDF8)).withValues(alpha: 0.15),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Flame House Component
                    PocketAvatarHouseWidget(
                      day: _selectedDay,
                      width: 220,
                      height: 160,
                      isPresident: isKingLion,
                      lightsOn: true,
                    ),

                    // Top Day Badge Overlay
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Text(isKingLion ? '👑 ' : '${house.emoji} ', style: const TextStyle(fontSize: 13)),
                            Text(
                              isKingLion ? 'ROYAL PALACE' : 'DAY $_selectedDay CITADEL',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right Defense Status
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: Text(
                          '🛡️ CITADEL ACTIVE',
                          style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Mode Selector Bar (3 Tabs requested by user)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    _buildSubNavTab(
                      label: '⚔️ Raid Citadel',
                      index: 0,
                    ),
                    _buildSubNavTab(
                      label: '🎮 House Games',
                      index: 1,
                    ),
                    _buildSubNavTab(
                      label: '📚 Learn & Reels',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Lower Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: _homesSubTab == 0
                    ? _buildRaidCitadelTab(target, isKingLion)
                    : _homesSubTab == 1
                        ? _buildHouseMiniGamesTab()
                        : _buildSyllabusAndReelsTab(),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSubNavTab({required String label, required int index}) {
    final isSelected = _homesSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _homesSubTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 0: RAID CITADEL & SPOKEN CHALLENGE
  Widget _buildRaidCitadelTab(KidMate target, bool isKingLion) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: Center(child: Text(target.avatar, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          target.name,
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (isKingLion) ...[
                          const SizedBox(width: 6),
                          const Text('👑', style: TextStyle(fontSize: 15)),
                        ],
                      ],
                    ),
                    Text(
                      target.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Defense Challenge Sentence Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Text('🗣️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Defense Question / Password:',
                        style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        target.challengeSentence,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 20),
                  onPressed: () => _speak(target.challengeSentence),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Action: ATTACK / CHALLENGE CITADEL
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isKingLion ? const Color(0xFFFFD700) : const Color(0xFFEF4444),
                foregroundColor: isKingLion ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              icon: Text(isKingLion ? '👑' : '⚔️', style: const TextStyle(fontSize: 18)),
              label: Text(
                isKingLion ? 'CHALLENGE KING LION (DAY 100 BOSS)' : 'RAID CITADEL & SPEAK ENGLISH ⚔️',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              ),
              onPressed: _launchAttack,
            ),
          ),
          const SizedBox(height: 8),

          // Secondary Action: Direct Chat
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF38BDF8)),
                foregroundColor: const Color(0xFF38BDF8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: Text(
                'CHAT WITH ${target.name.toUpperCase()}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
              onPressed: () {
                PocketKidsMateChatPage.open(context, mate: target);
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: HOUSE MINI-GAMES (EDUCATIONAL GAMES REQUESTED BY USER)
  Widget _buildHouseMiniGamesTab() {
    return Column(
      children: [
        // Mini-game Selector Chips
        Row(
          children: [
            _buildGameChip('🏠 Parts Quiz', 0),
            const SizedBox(width: 6),
            _buildGameChip('⚡ Defense Blitz', 1),
            const SizedBox(width: 6),
            _buildGameChip('🧱 Brick Builder', 2),
          ],
        ),
        const SizedBox(height: 12),

        Expanded(
          child: _activeMiniGame == 0
              ? _buildHousePartsQuizGame()
              : _activeMiniGame == 1
                  ? _buildCitadelDefenseBlitzGame()
                  : _buildBrickSpellerGame(),
        ),
      ],
    );
  }

  Widget _buildGameChip(String title, int idx) {
    final isSel = _activeMiniGame == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _activeMiniGame = idx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFFFD700) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? const Color(0xFFFFD700) : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: isSel ? Colors.black : Colors.white70,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Game 1: House Architectural Parts Quiz
  Widget _buildHousePartsQuizGame() {
    final parts = [
      {'name': 'Roof', 'emoji': '🏠', 'hint': 'Keeps rain and snow off our head!'},
      {'name': 'Tower', 'emoji': '🏰', 'hint': 'High watch tower guarding the citadel!'},
      {'name': 'Gate', 'emoji': '🚪', 'hint': 'Front entrance where friends knock!'},
      {'name': 'Garden', 'emoji': '🪴', 'hint': 'Courtyard with beautiful blooming flowers!'},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Identify Architectural Parts 🏠',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Score: $_partsQuizScore ⭐',
                style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any architectural part to listen and practice English pronunciation:',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: parts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, i) {
              final p = parts[i];
              final isTapped = _selectedPartName == p['name'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedPartName = p['name']!;
                    _partsQuizScore += 5;
                  });
                  _speak('${p['name']}! ${p['hint']}');
                  _awardStars(5, 'Identified ${p['name']}!');
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isTapped ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isTapped ? const Color(0xFF10B981) : Colors.white12,
                      width: isTapped ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p['emoji']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        p['name']!,
                        style: GoogleFonts.outfit(
                          color: isTapped ? const Color(0xFF10B981) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Tap to speak',
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Game 2: 30-Second Citadel Defense Blitz
  Widget _buildCitadelDefenseBlitzGame() {
    final syllabus = _currentSyllabus;
    final rounds = syllabus.rounds;
    if (rounds.isEmpty) {
      return Center(
        child: Text('Citadel peaceful! No raid questions today.', style: GoogleFonts.outfit(color: Colors.white70)),
      );
    }

    final currentRound = rounds[_blitzRoundIdx % rounds.length];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Citadel Defense Blitz ⚡',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Round ${_blitzRoundIdx + 1}/${rounds.length}',
                    style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(currentRound.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  currentRound.prompt,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Options
          ...List.generate(currentRound.options.length, (optIdx) {
            final opt = currentRound.options[optIdx];
            final isChosen = _blitzSelectedOption == optIdx;
            final isCorrect = optIdx == currentRound.correctIndex;
            Color btnColor = const Color(0xFF0F172A);
            if (isChosen) {
              btnColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isChosen ? Colors.white : Colors.white12,
                      ),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _blitzSelectedOption = optIdx;
                      _blitzIsCorrect = isCorrect;
                    });

                    if (isCorrect) {
                      _speak(currentRound.cheerPhrase);
                      _awardStars(3, 'Defense Cannon Fired!');
                      Future.delayed(const Duration(milliseconds: 900), () {
                        if (mounted) {
                          setState(() {
                            _blitzRoundIdx = (_blitzRoundIdx + 1) % rounds.length;
                            _blitzSelectedOption = null;
                            _blitzIsCorrect = null;
                          });
                        }
                      });
                    } else {
                      _speak('Try again, little adventurer!');
                    }
                  },
                  child: Text(
                    opt,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Game 3: Brick Speller Game
  Widget _buildBrickSpellerGame() {
    final word = _currentSyllabus.rounds.isNotEmpty
        ? _currentSyllabus.rounds.first.targetWord.toUpperCase()
        : 'CASTLE';
    final letters = word.split('');
    final targetSpell = _spellingTappedLetters.join('');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brick Speller Game 🧱',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFD700), size: 20),
                onPressed: () {
                  setState(() {
                    _spellingTappedLetters.clear();
                    _spellingCompleted = false;
                  });
                },
              ),
            ],
          ),
          Text(
            'Tap letter bricks in order to build the citadel wall:',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 10),

          // Wall Built Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _spellingCompleted ? const Color(0xFF10B981) : const Color(0xFFFFD700).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                targetSpell.isEmpty ? 'TAP LETTERS TO SPELL' : targetSpell,
                style: GoogleFonts.outfit(
                  color: _spellingCompleted ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Scrambled Letter Bricks
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: letters.map((letter) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _speak(letter);
                  setState(() {
                    _spellingTappedLetters.add(letter);
                    if (_spellingTappedLetters.join('') == word) {
                      _spellingCompleted = true;
                      _awardStars(5, 'Wall Built! Word completed!');
                      _speak('Brilliant! You built the wall for $word!');
                    }
                  });
                },
                child: Text(
                  letter,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // TAB 2: DAY SYLLABUS & REELS
  Widget _buildSyllabusAndReelsTab() {
    final syllabus = _currentSyllabus;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(syllabus.mascot, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $_selectedDay: ${syllabus.title}',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      syllabus.category,
                      style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Daily Dialogue Sentence
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Spoken Dialogue:',
                        style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        syllabus.dialogueSentence,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 18),
                  onPressed: () => _speak(syllabus.dialogueSentence),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Phonics Sound Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🔤', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Phonics Sound: ',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  syllabus.phonicsSound,
                  style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981), size: 18),
                  onPressed: () => _speak(syllabus.phonicsSound),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Watch House Reel Action
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.ondemand_video_rounded, size: 18),
              label: Text(
                'WATCH HOUSE REEL & STORY 🎬',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              onPressed: () {
                _showHouseReelModal(syllabus);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showHouseReelModal(KidDaySyllabus syllabus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('🎬', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Day $_selectedDay Citadel Reel Story',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Reel Player Mock Card
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF38BDF8)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(syllabus.mascot, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      '"${syllabus.dialogueSentence}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Listen & Practice Reel Audio 🔊'),
              onPressed: () {
                _speak('${syllabus.title}. ${syllabus.dialogueSentence}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
