import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';

/// 🏡 Dedicated Kids Homes & Citadels Showcase Page
/// Lets kids scroll through the 6 Avatar Houses, inspect their defense power,
/// and play interactive Spoken English defense challenges for each house tier.
/// 100% separated from adult homes and adult profiles.
class PocketKidsHomesShowcasePage extends StatefulWidget {
  const PocketKidsHomesShowcasePage({super.key});

  @override
  State<PocketKidsHomesShowcasePage> createState() => _PocketKidsHomesShowcasePageState();
}

class _PocketKidsHomesShowcasePageState extends State<PocketKidsHomesShowcasePage> {
  int _selectedHouseIndex = 0;

  @override
  Widget build(BuildContext context) {
    final houses = PocketKidsService.houses;
    final currentUnlockedDay = PocketKidsService.currentUnlockedDay;
    final activeHouse = houses[_selectedHouseIndex];
    final isUnlocked = currentUnlockedDay >= activeHouse.unlockedAtDay;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: activeHouse.themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(activeHouse.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KIDS AVATAR HOMES & GAMES',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Explore 6 Architectural Citadel Stages',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal House Selector
            SizedBox(
              height: 70,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: houses.length,
                itemBuilder: (context, idx) {
                  final h = houses[idx];
                  final isSelected = _selectedHouseIndex == idx;
                  final unlocked = currentUnlockedDay >= h.unlockedAtDay;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedHouseIndex = idx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? h.themeColor
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : h.themeColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: h.themeColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(h.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            h.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: isSelected
                                  ? (h.tier == 6 ? const Color(0xFF78350F) : Colors.white)
                                  : Colors.white70,
                            ),
                          ),
                          if (!unlocked) ...[
                            const SizedBox(width: 4),
                            const Text('🔒', style: TextStyle(fontSize: 10)),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main House Showcase Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  children: [
                    // Stage Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E293B),
                            const Color(0xFF0F172A),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: activeHouse.themeColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activeHouse.themeColor.withValues(alpha: 0.18),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: activeHouse.themeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: activeHouse.themeColor),
                                ),
                                child: Text(
                                  'STAGE ${activeHouse.tier} • DAY ${activeHouse.unlockedAtDay}+',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: activeHouse.themeColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isUnlocked ? 'UNLOCKED ✅' : 'LOCKED 🔒',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked ? const Color(0xFF4ADE80) : Colors.white60,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Live Flame Animated House Component
                          PocketAvatarHouseWidget(
                            day: activeHouse.unlockedAtDay,
                            width: 240,
                            height: 190,
                            lightsOn: true,
                          ),

                          const SizedBox(height: 14),

                          Text(
                            activeHouse.title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            activeHouse.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade300,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Interactive Defense Mini-Game Launcher
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text('🛡️', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                '3-LAYER DEFENSE MINI-GAME',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Play the automated Spoken English defense trial for this citadel stage. Answer polite dialogue questions to break 3 shield layers!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                final dummyDefender = KidMate(
                                  id: 'house_trial_${activeHouse.tier}',
                                  name: '${activeHouse.title} Guardian',
                                  avatar: activeHouse.emoji,
                                  ageGroup: 'All',
                                  dayLevel: activeHouse.unlockedAtDay,
                                  stars: activeHouse.unlockedAtDay * 3,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PocketKidsHouseChallengePage(defender: dummyDefender),
                                  ),
                                );
                              },
                              icon: const Text('⚔️', style: TextStyle(fontSize: 18)),
                              label: Text(
                                'PLAY DEFENSE TRIAL',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1,
                                ),
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
          ],
        ),
      ),
    );
  }
}
