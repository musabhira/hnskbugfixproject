import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';

/// 🤝 Kids Mates, Robots & Attack Profile Search Page
/// Displays 90 Kids AI Robots & Peer Friends with Kids Homes,
/// Mate Requests lifecycle, and 1-on-1 friendly talk/messaging.
/// 100% separated from adult chats, profiles, and vibes.
class PocketKidsMatesPage extends StatefulWidget {
  const PocketKidsMatesPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PocketKidsMatesPage()),
    );
  }

  @override
  State<PocketKidsMatesPage> createState() => _PocketKidsMatesPageState();
}

class _PocketKidsMatesPageState extends State<PocketKidsMatesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Discover (90 Bots & Peers), 1 = Mates, 2 = Requests

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedMates = PocketKidsService.getKidMates(
      query: _searchQuery,
      filterTab: _selectedTab,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KIDS MATES & CITADELS 🤝',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Top Search Bar (Search Attack Profiles & Buddies)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search 100 Animal Companions & Citadels... 🔍',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // 🏷️ 3 Tabs: Discover (100 Animal Mates) / My Mates / Requests
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                _buildTabButton(0, 'ANIMALS 🐾'),
                const SizedBox(width: 8),
                _buildTabButton(1, 'MY MATES 🤝'),
                const SizedBox(width: 8),
                _buildTabButton(2, 'REQUESTS 💌'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Mates / Robots List
          Expanded(
            child: displayedMates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎈', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 1
                              ? 'No mates added yet!\nTap DISCOVER to send requests.'
                              : _selectedTab == 2
                                  ? 'No pending mate requests!'
                                  : 'No buddies found matching "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: displayedMates.length,
                    itemBuilder: (context, index) {
                      final mate = displayedMates[index];
                      final house = PocketKidsService.getHouseForDay(mate.dayLevel);
                      final isMate = mate.requestStatus == KidMateRequestStatus.accepted;

                      return Dismissible(
                        key: ValueKey('mate_${mate.id}'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          HapticFeedback.heavyImpact();
                          PocketCitadelAttackPage.openForUser(
                            context,
                            userId: mate.id,
                            targetName: mate.name,
                            targetDay: mate.dayLevel,
                            isKidMode: true,
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                          return false; // Launch attack without deleting from list
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF97316)]),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Text('⚔️', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                'SWIPE TO ATTACK! ⚔️',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'SWIPE TO ATTACK! ⚔️',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              const Text('⚔️', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                        ),
                        child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          PocketCitadelAttackPage.openForUser(
                            context,
                            userId: mate.id,
                            targetName: mate.name,
                            targetDay: mate.dayLevel,
                            isKidMode: true,
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar Badge
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(mate.avatar, style: const TextStyle(fontSize: 26)),
                              ),

                              const SizedBox(width: 12),

                              // Name & Level
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          mate.name,
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF0F172A),
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        if (isMate) ...[
                                          const SizedBox(width: 4),
                                          const Text('💖', style: TextStyle(fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Day ${mate.dayLevel} • ${house.title} ${house.emoji}',
                                      style: GoogleFonts.inter(
                                        color: Colors.black54,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Action Buttons based on Request Status
                              if (isMate) ...[
                                // 1-on-1 Friendly Talk Chat Button
                                IconButton(
                                  icon: const Icon(
                                    Icons.chat_bubble_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 22,
                                  ),
                                  tooltip: 'Talk with Mate',
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PocketKidsMateChatPage(mate: mate),
                                      ),
                                    ).then((_) {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                ),
                              ],

                              if (mate.requestStatus == KidMateRequestStatus.received) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF59E0B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    await PocketKidsService.acceptMateRequest(mate.id);
                                    if (mounted) setState(() {});
                                  },
                                  child: Text(
                                    'ACCEPT ✨',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                // Attack Citadel Button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.heavyImpact();
                                    PocketCitadelAttackPage.openForUser(
                                      context,
                                      userId: mate.id,
                                      targetName: mate.name,
                                      targetDay: mate.dayLevel,
                                      isKidMode: true,
                                    ).then((_) {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                  child: Text(
                                    '⚔️ RAID',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11.5,
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: isSelected ? const Color(0xFF78350F) : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }
}
