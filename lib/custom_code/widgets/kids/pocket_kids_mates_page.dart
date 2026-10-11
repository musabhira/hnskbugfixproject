import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_attacking_profile_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';

/// 🤝 Dedicated Kids Mates & Adventure Friends Page
/// Kids can search other kid users, view their avatar homes,
/// add them as mates, and play friendly house challenges!
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
  int _selectedTab = 0; // 0 = Discover, 1 = My Mates

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMates = PocketKidsService.getKidMates(query: _searchQuery);
    final displayedMates = _selectedTab == 1
        ? allMates.where((m) => m.isFriend).toList()
        : allMates;

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
          'KIDS MATES 🤝',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Kids Nickname... 🔍',
                hintStyle: const TextStyle(color: Colors.white54),
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

          // Tabs: Discover / My Mates
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTab = 0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'DISCOVER KIDS 🌍',
                        style: GoogleFonts.outfit(
                          color: _selectedTab == 0
                              ? const Color(0xFF78350F)
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTab = 1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'MY MATES 💖',
                        style: GoogleFonts.outfit(
                          color: _selectedTab == 1
                              ? const Color(0xFF78350F)
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Mates List
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
                              ? 'No mates added yet!\nTap DISCOVER to find friends.'
                              : 'No kids found matching "$_searchQuery"',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: displayedMates.length,
                    itemBuilder: (context, index) {
                      final mate = displayedMates[index];
                      final house =
                          PocketKidsService.getHouseForDay(mate.dayLevel);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PocketKidsAttackingProfilePage(mate: mate),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
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
                              // Mascot Avatar
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(mate.avatar,
                                    style: const TextStyle(fontSize: 28)),
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        if (mate.isFriend) ...[
                                          const SizedBox(width: 6),
                                          const Text('💖',
                                              style: TextStyle(fontSize: 12)),
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

                              // Quick Chat for friends
                              if (mate.isFriend) ...[
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
                                        builder: (_) =>
                                            PocketKidsMateChatPage(mate: mate),
                                      ),
                                    ).then((_) {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                ),
                              ],

                              // Attack Citadel Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                ),
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PocketKidsAttackingProfilePage(mate: mate),
                                    ),
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
}
