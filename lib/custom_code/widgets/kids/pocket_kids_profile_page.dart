import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_certificate_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_settings_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mates_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';

/// 👤 Dedicated Gamified Student Profile Page (Light Mode Anime/Cartoon Aesthetic)
///
/// Features:
/// 1. 🌈 Gamified Hero Level & Avatar Showcase with Star Coins & XP Bar.
/// 2. 🏰 4 Rich Light-Mode Tabs: Estate House, Badges/Trophies, Summit Diploma, Mates.
/// 3. ✏️ Edit Profile Bottom Sheet with Mascot Avatar Customizer.
/// 4. ⚙️ Top Settings & Parental Gate Zone.
class PocketKidsProfilePage extends StatefulWidget {
  const PocketKidsProfilePage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PocketKidsProfilePage()),
    );
  }

  @override
  State<PocketKidsProfilePage> createState() => _PocketKidsProfilePageState();
}

class _PocketKidsProfilePageState extends State<PocketKidsProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<KidMate> _mates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMates();
  }

  void _loadMates() {
    setState(() {
      _mates = PocketKidsService.mates;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openSettings() {
    HapticFeedback.lightImpact();
    PocketKidsSettingsPage.open(context).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openEditProfileDialog() {
    HapticFeedback.selectionClick();
    final nameController = TextEditingController(text: PocketKidsService.kidName);
    String selectedMascot = PocketKidsService.kidAvatar;
    final mascotOptions = [
      {'name': 'Lion', 'emoji': '🦁', 'day': 1},
      {'name': 'Fox', 'emoji': '🦊', 'day': 1},
      {'name': 'Cat', 'emoji': '🐱', 'day': 1},
      {'name': 'Dog', 'emoji': '🐶', 'day': 1},
      {'name': 'Panda', 'emoji': '🐼', 'day': 2},
      {'name': 'Tiger', 'emoji': '🐯', 'day': 5},
      {'name': 'Rabbit', 'emoji': '🐰', 'day': 8},
      {'name': 'Bear', 'emoji': '🐻', 'day': 12},
      {'name': 'Rocket', 'emoji': '🚀', 'day': 15},
      {'name': 'Unicorn', 'emoji': '🦄', 'day': 20},
      {'name': 'Dino', 'emoji': '🦖', 'day': 25},
      {'name': 'Dolphin', 'emoji': '🐬', 'day': 30},
      {'name': 'Owl', 'emoji': '🦉', 'day': 40},
      {'name': 'Koala', 'emoji': '🐨', 'day': 50},
      {'name': 'Eagle', 'emoji': '🦅', 'day': 60},
      {'name': 'Dragon', 'emoji': '🐉', 'day': 75},
      {'name': 'Star King', 'emoji': '👑', 'day': 100},
    ];
    final unlockedDay = PocketKidsService.currentUnlockedDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('✏️ 🎒 ', style: TextStyle(fontSize: 22)),
                      Text(
                        'EDIT HERO PROFILE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Student Name Input
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Student Hero Name',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      hintText: 'Enter student name',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF334155))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF334155))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                      prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFF59E0B)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'CHOOSE MASCOT COMPANION (Unlocked on Trail):',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Animal Mascot Grid
                  SizedBox(
                    height: 150,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: mascotOptions.length,
                      itemBuilder: (context, idx) {
                        final animal = mascotOptions[idx];
                        final dayReq = animal['day'] as int;
                        final isUnlocked = unlockedDay >= dayReq;
                        final isSelected = selectedMascot == animal['emoji'];

                        return GestureDetector(
                          onTap: () {
                            if (!isUnlocked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Unlocks at Day $dayReq on the Mountain Trail! 🏔️'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              return;
                            }
                            HapticFeedback.selectionClick();
                            setModalState(() {
                              selectedMascot = animal['emoji'] as String;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  animal['emoji'] as String,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.4),
                                  ),
                                ),
                                if (!isUnlocked)
                                  const Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Icon(Icons.lock_rounded, size: 10, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isNotEmpty) {
                          await PocketKidsService.updateProfile(
                            name: newName,
                            avatar: selectedMascot,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {});
                      },
                      child: Text(
                        'SAVE HERO PROFILE ⭐',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kidName = PocketKidsService.kidName;
    final unlockedDay = PocketKidsService.currentUnlockedDay;
    final kidStars = PocketKidsService.kidStars;
    final currentHouse = PocketKidsService.getCurrentHouse();
    final avatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(unlockedDay);

    return PocketKidsNatureSceneryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: const Color(0xFF082F49).withValues(alpha: 0.70),
              pinned: true,
              elevation: 0,
            title: Text(
              'HERO PROFILE 🎒',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Settings & Parent Zone',
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155), width: 1),
                  ),
                  child: const Icon(Icons.settings_rounded, color: Color(0xFF38BDF8), size: 18),
                ),
                onPressed: _openSettings,
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  // 🌟 Gamified Cartoon Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mascot Avatar with Golden Crown Ring
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFFFD700), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: VectorAvatarWidget(
                            config: avatarConfig,
                            size: 82,
                            showAura: true,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Student Name
                        Text(
                          kidName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Role / House Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Text(
                            'Day $unlockedDay Champion • ${currentHouse.title}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // XP Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TRAIL JOURNEY XP',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  '$unlockedDay / 100 Days',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (unlockedDay / 100).clamp(0.0, 1.0),
                                backgroundColor: Colors.white,
                                color: const Color(0xFFF59E0B),
                                minHeight: 7,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Edit Profile Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFF334155)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 15, color: Color(0xFF38BDF8)),
                          label: Text(
                            'EDIT PROFILE & MASCOT',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11.5),
                          ),
                          onPressed: _openEditProfileDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 📊 4 Quick Stat Cards
                  Row(
                    children: [
                      _buildStatCard('🎯', 'Trail Level', 'Day $unlockedDay', const Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      _buildStatCard('⭐', 'Star Coins', '$kidStars PTS', const Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      _buildStatCard('🏰', 'Estate Tier', currentHouse.title.split(' ').first, const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildStatCard('🤝', 'Buddies', '${_mates.length}', const Color(0xFF8B5CF6)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProfileTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF38BDF8),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF94A3B8),
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(text: '🏡 HOUSE'),
                  Tab(text: '🏆 BADGES'),
                  Tab(text: '📜 DIPLOMA'),
                  Tab(text: '🤝 MATES'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHouseTab(unlockedDay, currentHouse),
            _buildBadgesTab(unlockedDay),
            _buildDiplomaTab(context, unlockedDay),
            _buildMatesTab(context),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatCard(String emoji, String title, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseTab(int day, KidsHouse currentHouse) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(currentHouse.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        currentHouse.title,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ACTIVE ESTATE',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF15803D),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Center(
                child: PocketAvatarHouseWidget(
                  day: day,
                  width: 220,
                  height: 180,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentHouse.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 12),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHouseDetailPill('🛡️ Defense Slots', '$day / 100'),
                  _buildHouseDetailPill('🔥 Flame Power', 'Stage ${((day - 1) ~/ 15) + 1}'),
                  _buildHouseDetailPill('👑 Summit Boss', 'Day 100 Lion'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHouseDetailPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(int unlockedDay) {
    final badges = [
      {'day': 1, 'emoji': '🌱', 'title': 'Basecamp Sprout', 'desc': 'Started the 100-Day English odyssey'},
      {'day': 8, 'emoji': '🏡', 'title': 'Brick Mason', 'desc': 'Built a sturdy Foundation Villa'},
      {'day': 21, 'emoji': '⚓', 'title': 'Habit Anchor', 'desc': 'Conquered 3 weeks of daily English'},
      {'day': 45, 'emoji': '🏛️', 'title': 'Imperial Manor', 'desc': 'Mastered conversational confidence'},
      {'day': 70, 'emoji': '💎', 'title': 'Cyber Titan', 'desc': 'Reached advanced spoken fluency'},
      {'day': 90, 'emoji': '👑', 'title': 'Palace Master', 'desc': 'Stood before the Sovereign Summit'},
      {'day': 100, 'emoji': '🦁', 'title': 'King Lion Champion', 'desc': 'Earned the official Grade Certificate'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: badges.length,
      itemBuilder: (context, idx) {
        final b = badges[idx];
        final day = b['day'] as int;
        final isUnlocked = unlockedDay >= day;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
              width: isUnlocked ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  isUnlocked ? (b['emoji'] as String) : '🔒',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b['title'] as String,
                      style: GoogleFonts.outfit(
                        color: isUnlocked ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      b['desc'] as String,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUnlocked ? 'EARNED ✨' : 'DAY $day',
                  style: GoogleFonts.outfit(
                    color: isUnlocked ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiplomaTab(BuildContext context, int unlockedDay) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFDE68A), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('📜 🦁 🎓', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                '100-DAY SUMMIT CERTIFICATE',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF78350F),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Awarded upon conquering Day 100 at the Golden Summit Castle!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF92400E), fontSize: 12),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (unlockedDay / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white,
                  color: const Color(0xFFF59E0B),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$unlockedDay% Conquered • ${100 - unlockedDay} Days to Graduation',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF92400E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF78350F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                  label: Text(
                    'VIEW CERTIFICATE PREVIEW 🎓',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    PocketKidsCertificatePage.open(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatesTab(BuildContext context) {
    if (_mates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🦁 🤝 🐼', style: TextStyle(fontSize: 38)),
            const SizedBox(height: 10),
            Text(
              'No Student Mates Yet',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Connect with animal kingdom friends and study companions!',
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('FIND MATES'),
              onPressed: () {
                PocketKidsMatesPage.open(context).then((_) => _loadMates());
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _mates.length,
      itemBuilder: (context, idx) {
        final m = _mates[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(m.avatar, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              m.name,
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Day ${m.dayLevel} • ${m.isRobot ? 'AI Study Companion' : 'Student Mate'}',
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF0284C7), size: 20),
              onPressed: () {
                PocketKidsMateChatPage.open(context, mate: m);
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _ProfileTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF082F49).withValues(alpha: 0.90),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) => false;
}
