import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 🔔 Gamified Kids Notifications & Adventure Alerts Screen
/// Displays:
/// - King Lion Daily Sovereign Missions & Practice Reminders
/// - Animal Mate & Peer Study Requests (Accept / Decline)
/// - House Tier & Fortress Level Star Rewards
/// - Midnight Countdown & Day Unlock Notifications
class PocketKidsNotificationsPage extends StatefulWidget {
  const PocketKidsNotificationsPage({super.key});

  @override
  State<PocketKidsNotificationsPage> createState() =>
      _PocketKidsNotificationsPageState();
}

class _PocketKidsNotificationsPageState
    extends State<PocketKidsNotificationsPage> {
  int _selectedFilter = 0; // 0: All, 1: Mates, 2: Missions, 3: Rewards

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = PocketKidsService.currentUnlockedDay;
    final stars = PocketKidsService.kidStars;
    final receivedRequestIds = PocketKidsService.receivedRequestIds;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔔', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Adventure Alerts',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '$stars',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (All, Mates, Missions, Rewards)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F172A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('All Alerts', 0, Icons.auto_awesome),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Animal Mates (${receivedRequestIds.length})',
                    1,
                    Icons.pets_rounded,
                    highlight: receivedRequestIds.isNotEmpty,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip('King Lion Missions', 2, Icons.military_tech_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('House Trophies', 3, Icons.castle_rounded),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. King Lion Daily Royal Mission Card
                if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                  _buildKingLionMissionCard(currentDay),
                  const SizedBox(height: 14),
                ],

                // 2. Pending Animal Mate Requests
                if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                  if (receivedRequestIds.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.pets_rounded,
                              size: 16, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 6),
                          Text(
                            'New Animal Buddies Want to Connect!',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final reqId in receivedRequestIds)
                      _buildMateRequestTile(reqId),
                    const SizedBox(height: 14),
                  ] else if (_selectedFilter == 1) ...[
                    _buildEmptyState(
                      'No New Mate Requests',
                      'Check the Discover tab to meet new animal friends and study peers!',
                      '🐾',
                    ),
                  ],
                ],

                // 3. Day Milestone & House Unlocks
                if (_selectedFilter == 0 || _selectedFilter == 3) ...[
                  _buildHouseMilestoneCard(currentDay),
                  const SizedBox(height: 14),
                  _buildStarAchievementCard(stars),
                  const SizedBox(height: 14),
                ],

                // 4. Midnight Timer Notification Info
                if (_selectedFilter == 0) ...[
                  _buildMidnightCountdownNotification(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, IconData icon,
      {bool highlight = false}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700)
              : (highlight
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.18)
                  : const Color(0xFF1E293B)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : (highlight
                    ? const Color(0xFF38BDF8)
                    : Colors.white.withValues(alpha: 0.08)),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.black
                  : (highlight ? const Color(0xFF38BDF8) : Colors.white70),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? Colors.black
                    : (highlight ? const Color(0xFF38BDF8) : Colors.white70),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKingLionMissionCard(int currentDay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF78350F).withValues(alpha: 0.8),
            const Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text('🦁', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'King Lion 👑 (Daily Mission)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Day $currentDay',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '“Courageous Explorer! Speak 3 English sentences out loud today to defend your homestead and earn +20 Bonus Stars!”',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Start Day $currentDay Game',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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

  Widget _buildMateRequestTile(String mateId) {
    final mate = PocketKidsService.getKidMateById(mateId);
    if (mate == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF38BDF8),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(mate.avatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mate.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  mate.isRobot
                      ? 'Animal Buddy ready to learn English!'
                      : 'Day ${mate.dayLevel} Explorer',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await PocketKidsService.acceptMateRequest(mate.id);
              if (mounted) setState(() {});
            },
            child: Text(
              'Accept',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await PocketKidsService.rejectMateRequest(mate.id);
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHouseMilestoneCard(int currentDay) {
    // Current tier
    final currentHouse = PocketKidsService.houses.lastWhere(
      (h) => h.unlockedAtDay <= currentDay,
      orElse: () => PocketKidsService.houses.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: currentHouse.themeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: currentHouse.themeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: currentHouse.themeColor, width: 2),
            ),
            child: Center(
              child: Text(currentHouse.emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Tier ${currentHouse.tier}: ${currentHouse.title}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Text('🏰', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  currentHouse.description,
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarAchievementCard(int stars) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Star Collector Badge',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'You have accumulated $stars Stars! Climb further to reach Day 100 Golden Lion King Palace.',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
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

  Widget _buildMidnightCountdownNotification() {
    final countdown = PocketKidsService.getFormattedMidnightCountdown();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.nightlight_round,
              color: Color(0xFFA855F7), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Day Midnight Unlock',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Time until new adventure opens: $countdown',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA855F7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
