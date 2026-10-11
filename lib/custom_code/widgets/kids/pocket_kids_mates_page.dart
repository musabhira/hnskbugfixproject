import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_house_challenge_page.dart';

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

  void _showKidProfileModal(BuildContext context, KidMate mate) {
    HapticFeedback.selectionClick();
    final house = PocketKidsService.getHouseForDay(mate.dayLevel);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isMate = mate.isFriend;

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Mascot Avatar & Kid Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mate.avatar, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mate.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Age ${mate.ageGroup}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Day ${mate.dayLevel} • ⭐ ${mate.stars}',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 🏡 Kid's Avatar House Preview (Same as Adult Home!)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: house.themeColor.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${house.title} (${house.emoji})',
                          style: GoogleFonts.outfit(
                            color: house.themeColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PocketAvatarHouseWidget(
                          day: mate.dayLevel,
                          width: 200,
                          height: 150,
                          lightsOn: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons: Mates 🤝 and Friendly Challenge ⚔️
                  Row(
                    children: [
                      // Toggle Mates Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isMate
                                  ? const Color(0xFF10B981)
                                  : Colors.white30,
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await PocketKidsService.toggleMate(mate.id);
                            setState(() {});
                            setSheetState(() {});
                          },
                          icon: Icon(
                            isMate ? Icons.favorite_rounded : Icons.person_add_rounded,
                            color: isMate
                                ? const Color(0xFF10B981)
                                : Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            isMate ? 'MATES 💖' : 'ADD MATE 🤝',
                            style: GoogleFonts.outfit(
                              color: isMate
                                  ? const Color(0xFF10B981)
                                  : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Friendly Challenge Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF78350F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PocketKidsHouseChallengePage(defender: mate),
                              ),
                            ).then((_) {
                              if (mounted) setState(() {});
                            });
                          },
                          icon: const Text('⚔️', style: TextStyle(fontSize: 16)),
                          label: Text(
                            'CHALLENGE 🏰',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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

                            const SizedBox(width: 14),

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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // View Profile Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38BDF8),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              onPressed: () =>
                                  _showKidProfileModal(context, mate),
                              child: Text(
                                'VIEW ➔',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
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
}
