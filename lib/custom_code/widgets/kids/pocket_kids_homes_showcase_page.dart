import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mates_page.dart';

/// 🏡 Kids Homes & Attacking Profile Page
/// Completely duplicates the adult Attacking Profile / Citadel experience for students:
/// 1. Living Architectural Citadel & House (Days 1–100)
/// 2. Day 100 is King Lion's Sovereign Palace ("100-ാമത്തെ ലെവലിൽ ലയന്റെ വീട് അറ്റാക്ക് ചെയ്യുക")
/// 3. Draggable Attacking Profile card with defense questions, mate status, and raid actions
/// 4. Direct "⚔️ RAID CITADEL" launching spoken English battle challenges!
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
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
                    child: Text(isKingLion ? '👑' : '🏡', style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKingLion ? 'KING LION SOVEREIGN PALACE' : 'KIDS ATTACKING PROFILE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Level $_selectedDay Citadel • Spoken English Raid',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
              height: 48,
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
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
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
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Living Flame English House Graphic
            Expanded(
              flex: 4,
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
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isKingLion ? const Color(0xFFFFD700) : Colors.white12,
                    width: isKingLion ? 2 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isKingLion ? const Color(0xFFFFD700) : const Color(0xFF38BDF8)).withValues(alpha: 0.15),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Flame House Component
                    PocketAvatarHouseWidget(
                      day: _selectedDay,
                      width: 250,
                      height: 200,
                      isPresident: isKingLion,
                      lightsOn: true,
                    ),

                    // Top Day Badge Overlay
                    Positioned(
                      top: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Text(isKingLion ? '👑 ' : '🏰 ', style: const TextStyle(fontSize: 14)),
                            Text(
                              isKingLion ? 'ROYAL PALACE' : 'DAY $_selectedDay CITADEL',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right Defense Status
                    Positioned(
                      top: 12,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: Text(
                          '🛡️ 3 DEFENSE SLOTS',
                          style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 10.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Attacking Profile Card & Action Bar
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Profile Details
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            ),
                            child: Center(child: Text(target.avatar, style: const TextStyle(fontSize: 26))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      target.name,
                                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (isKingLion) ...[
                                      const SizedBox(width: 6),
                                      const Text('👑', style: TextStyle(fontSize: 16)),
                                    ],
                                  ],
                                ),
                                Text(
                                  target.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

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
                            const Text('🗣️', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Defense Question / Password:',
                                    style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10.5, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    target.challengeSentence,
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
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

                      const SizedBox(height: 16),

                      // Primary Action: ATTACK / CHALLENGE CITADEL
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isKingLion ? const Color(0xFFFFD700) : const Color(0xFFEF4444),
                            foregroundColor: isKingLion ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 4,
                          ),
                          icon: Text(isKingLion ? '👑' : '⚔️', style: const TextStyle(fontSize: 20)),
                          label: Text(
                            isKingLion ? 'CHALLENGE KING LION (DAY 100 BOSS)' : 'RAID & CHALLENGE CITADEL ⚔️',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: 0.5),
                          ),
                          onPressed: _launchAttack,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Secondary Action: Direct Chat
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF38BDF8)),
                            foregroundColor: const Color(0xFF38BDF8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: Text(
                            'CHAT WITH ${target.name.toUpperCase()}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          onPressed: () {
                            PocketKidsMateChatPage.open(context, mate: target);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
