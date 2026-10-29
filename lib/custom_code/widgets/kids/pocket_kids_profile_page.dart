import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_settings_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mates_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_mate_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pocket_defense_card_detail_sheet.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_challenge_generator.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

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
  List<CitadelRaidLogEntry> _kidsRaids = [];
  bool _isKidsHouseProtected = false;
  int _kidsProtectionMinutes = 0;
  int _goldTrophies = 0;
  int _silverTrophies = 0;
  int _attacksWon = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMates();
    _loadDefenseAndRaids();
  }

  Future<void> _loadDefenseAndRaids() async {
    try {
      final raids = await PocketFortressDefenseService.getRecentRaids();
      final isProtected =
          await PocketFortressDefenseService.isUnderPresidentialProtection(
              'me');
      final protectionMins = isProtected
          ? await PocketFortressDefenseService
              .getPresidentialProtectionMinutesRemaining('me')
          : 0;
      final myId = SupaFlow.client.auth.currentUser?.id ?? 'me';
      final gold = await PocketTrophyService.getGoldTrophies(myId);
      final silver = await PocketTrophyService.getSilverTrophies(myId);
      final attacks = await PocketTrophyService.getSuccessfulAttacks(myId);
      if (mounted) {
        setState(() {
          _kidsRaids = raids;
          _isKidsHouseProtected = isProtected;
          _kidsProtectionMinutes = protectionMins;
          _goldTrophies = gold;
          _silverTrophies = silver;
          _attacksWon = attacks > 0 ? attacks : PocketKidsService.attackCount;
        });
      }
    } catch (_) {}
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
    final nameController =
        TextEditingController(text: PocketKidsService.kidName);
    String selectedMascot = PocketKidsService.kidAvatar;
    String selectedGender = PocketKidsService.kidGender;
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
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Student Hero Name',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      hintText: 'Enter student name',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFF334155))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFF334155))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF38BDF8), width: 1.5)),
                      prefixIcon: const Icon(Icons.person_rounded,
                          color: Color(0xFFF59E0B)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender Selector (Boy vs Girl)
                  Text(
                    'STUDENT GENDER / AVATAR STYLE:',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setGenderState) {
                      final isBoy = selectedGender == 'male';
                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => selectedGender = 'female');
                                setGenderState(() {});
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isBoy
                                      ? const Color(0xFFE11D48)
                                          .withValues(alpha: 0.25)
                                      : const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: !isBoy
                                        ? const Color(0xFFFB7185)
                                        : const Color(0xFF334155),
                                    width: !isBoy ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('👧',
                                        style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Girl / Female',
                                      style: GoogleFonts.outfit(
                                        color: !isBoy
                                            ? const Color(0xFFFDA4AF)
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
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
                                setModalState(() => selectedGender = 'male');
                                setGenderState(() {});
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isBoy
                                      ? const Color(0xFF0284C7)
                                          .withValues(alpha: 0.25)
                                      : const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isBoy
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF334155),
                                    width: isBoy ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('👦',
                                        style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Boy / Male',
                                      style: GoogleFonts.outfit(
                                        color: isBoy
                                            ? const Color(0xFF7DD3FC)
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  content: Text(
                                      'Unlocks at Day $dayReq on the Mountain Trail! 🏔️'),
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
                                color: isSelected
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF334155),
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
                                    color: isUnlocked
                                        ? null
                                        : Colors.grey.withValues(alpha: 0.4),
                                  ),
                                ),
                                if (!isUnlocked)
                                  const Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Icon(Icons.lock_rounded,
                                        size: 10, color: Colors.grey),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isNotEmpty) {
                          await PocketKidsService.updateProfile(
                            name: newName,
                            avatar: selectedMascot,
                            gender: selectedGender,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {});
                      },
                      child: Text(
                        'SAVE HERO PROFILE ⭐',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 14),
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
    final currentHouse = PocketKidsService.getCurrentHouse();
    final isMale = PocketKidsService.kidGender == 'male';

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
                      border:
                          Border.all(color: const Color(0xFF334155), width: 1),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                  ),
                  onPressed: _openSettings,
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  children: [
                    // 🌟 Instagram-Style Minimal Hero Profile Header (User Audio Directive!)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color:
                              const Color(0xFF38BDF8).withValues(alpha: 0.30),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 👤 Top Row: Avatar on Left + 3 Instagram Stat Columns on Right
                          Row(
                            children: [
                              // Avatar with Golden Story Ring
                              Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFF59E0B),
                                      Color(0xFF38BDF8)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0F172A),
                                  ),
                                  child: ClipOval(
                                    child: VectorAvatarWidget(
                                      config: PocketKidsAvatarSystem
                                          .getAvatarConfigForDay(unlockedDay),
                                      size: 68,
                                      showAura: false,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // 5 Instagram-style Stats: Mates, Score (SS), Gold, Silver, Attacks Won
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInstaStatColumn(
                                        '${_mates.length}', 'Mates'),
                                    _buildInstaStatColumn(
                                        '${PocketKidsService.studentScore}',
                                        'Score (SS)'),
                                    _buildInstaStatColumn(
                                        '$_goldTrophies', '🏆 Gold'),
                                    _buildInstaStatColumn(
                                        '$_silverTrophies', '🥈 Silver'),
                                    _buildInstaStatColumn(
                                        '$_attacksWon', '⚔️'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Student Name + Mascot Emoji
                          Row(
                            children: [
                              Text(
                                kidName,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                PocketKidsService.kidAvatar,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          // Instagram Bio-style Subtitle
                          Text(
                            'Day $unlockedDay Explorer • ${currentHouse.title} • 🛡️ $unlockedDay Defense Cards',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Instagram-style Action Row: Edit Profile & Settings
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 34,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF334155),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: Color(0xFF475569),
                                            width: 0.8),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: _openEditProfileDialog,
                                    child: Text(
                                      'Edit Profile',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 34,
                                width: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF334155),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Color(0xFF475569),
                                          width: 0.8),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: _openSettings,
                                  child: const Icon(Icons.settings_rounded,
                                      size: 16, color: Color(0xFF38BDF8)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                  labelStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 12),
                  tabs: const [
                    Tab(text: '🎴 CARDS'),
                    Tab(text: '🏡 HOUSE'),
                    Tab(text: '🤝 MATES'),
                    Tab(text: '🏆 BADGES'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildCardsTab(unlockedDay, isMale),
              _buildHouseTab(unlockedDay, currentHouse),
              _buildMatesTab(context),
              _buildBadgesTab(unlockedDay),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstaStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF94A3B8),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }



  /// 🎴 Instagram-Style 3-Column Cards Grid (Collectible Trophy Cards & Defense Shields)
  Widget _buildCardsTab(int unlockedDay, bool isMale) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
      children: [
        // 🛡️ Minimal Fortress Defense Cards Header Banner (User Audio Directive!)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$unlockedDay / 90 Defense Cards Unlocked • Fortress Shield Active',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 📱 Instagram-Style 3-Column Card Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 90,
          itemBuilder: (context, index) {
            final cardDay = index + 1;
            final isUnlocked = cardDay <= unlockedDay;
            final isCardLost = !isUnlocked &&
                PocketKidsService.completedDays.containsKey(cardDay);
            final card =
                PopArtCardHelper.getCardForDay(cardDay, isMale: isMale);
            final gameInfo = PocketCitadelChallengeGenerator.getGameForUserCard(
                'kid_hero', cardDay);
            final difficulty =
                PocketCitadelChallengeGenerator.getDifficultyForUserCard(
                    'kid_hero', cardDay);

            if (!isUnlocked) {
              // 🔒 Mystery Locked Card Silhouette or ⚠️ Card Lost to Raid
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  PocketDefenseCardDetailSheet.show(
                    context,
                    card: card,
                    cardDay: cardDay,
                    gameInfo: gameInfo,
                    difficulty: difficulty,
                    isUnlocked: false,
                    isCardLost: isCardLost,
                    isKidMode: true,
                    defenderId: 'kid_hero',
                    defenderName: PocketKidsService.kidName.isNotEmpty
                        ? PocketKidsService.kidName
                        : 'Kid Hero',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isCardLost
                        ? const Color(0xFF450A0A).withValues(alpha: 0.65)
                        : const Color(0xFF0F172A).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCardLost
                          ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                          : Colors.white12,
                      width: isCardLost ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCardLost
                            ? Icons.broken_image_rounded
                            : Icons.lock_rounded,
                        color: isCardLost
                            ? const Color(0xFFF87171)
                            : const Color(0xFF64748B),
                        size: 24,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Day $cardDay',
                        style: GoogleFonts.outfit(
                          color: isCardLost
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isCardLost ? 'LOST TO RAID' : 'LOCKED',
                        style: GoogleFonts.outfit(
                          color: isCardLost
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF475569),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✨ Unlocked Neo-Pop Art Collectible Card
            return GestureDetector(
              onTap: () {
                PocketDefenseCardDetailSheet.show(
                  context,
                  card: card,
                  cardDay: cardDay,
                  gameInfo: gameInfo,
                  difficulty: difficulty,
                  isUnlocked: true,
                  isCardLost: false,
                  isKidMode: true,
                  defenderId: 'kid_hero',
                  defenderName: PocketKidsService.kidName.isNotEmpty
                      ? PocketKidsService.kidName
                      : 'Kid Hero',
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: PopArtCardCustomPainter(data: card),
                      ),
                      // Top Day Pill
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.6),
                                width: 0.8),
                          ),
                          child: Text(
                            'Day $cardDay',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      // Bottom Defense Shield Pill with Shuffled Game Badge (User Audio Directive!)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF10B981), width: 0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(gameInfo.icon,
                                  style: const TextStyle(fontSize: 8.5)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  gameInfo.title,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF34D399),
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHouseTab(int day, KidsHouse currentHouse) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        if (_isKidsHouseProtected) ...[
          // 🚧 Police Crime Scene Tape & 24H Protection Sentries (User Audio Directive)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCA8A04), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🚧', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'CRIME SCENE • DO NOT CROSS • POLICE INVESTIGATION',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF78350F),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🚧', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👮‍♂️ 🚔 👮‍♀️',
                          style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      Text(
                        '24H PRESIDENTIAL POLICE SHIELD (${(_kidsProtectionMinutes / 60).toStringAsFixed(1)}h remaining)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      Text(currentHouse.emoji,
                          style: const TextStyle(fontSize: 24)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
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
                style: GoogleFonts.inter(
                    color: const Color(0xFF475569), fontSize: 12),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHouseDetailPill('🛡️ Defense Slots', '$day / 100'),
                  _buildHouseDetailPill(
                      '🔥 Flame Power', 'Stage ${((day - 1) ~/ 15) + 1}'),
                  _buildHouseDetailPill('👑 Summit Boss', 'Day 100 Lion'),
                ],
              ),
            ],
          ),
        ),
        if (_kidsRaids.isNotEmpty) ...[
          const SizedBox(height: 14),
          // 🚨 POLICE CRIME REPORT & REVENGE DOSSIER (Kids Student Score Version)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _kidsRaids.first.breached
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF38BDF8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_kidsRaids.first.breached
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF38BDF8))
                      .withValues(alpha: 0.25),
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🚨', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PocketLanguageService.localize(
                              en: 'POLICE CRIME DOSSIER',
                              ml: 'POLICE CRIME DOSSIER (കേസ് ഡയറി)',
                              ta: 'POLICE CRIME DOSSIER (வழக்கு நாட்குறிப்பு)',
                              hi: 'POLICE CRIME DOSSIER (केस डायरी)',
                            ),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _kidsRaids.first.breached
                                ? 'Crime Scene Secured • Suspect Identified'
                                : 'Defenses Held Firm • Suspect Repelled',
                            style: TextStyle(
                              color: _kidsRaids.first.breached
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF86EFAC),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kidsRaids.first.breached
                            ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                            : const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _kidsRaids.first.breached
                              ? const Color(0xFFF87171)
                              : const Color(0xFF34D399),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _kidsRaids.first.breached
                            ? '-${_kidsRaids.first.coinsLooted > 0 ? _kidsRaids.first.coinsLooted : 15} SS LOOTED'
                            : '0 SS LOST',
                        style: GoogleFonts.outfit(
                          color: _kidsRaids.first.breached
                              ? const Color(0xFFF87171)
                              : const Color(0xFF34D399),
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _kidsRaids.first.attackerAvatar,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raider: ${_kidsRaids.first.attackerName}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Weapon: ${_kidsRaids.first.attackerWeapon}',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // ⚔️ 1-Tap REVENGE BUTTON FOR KIDS
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Text('⚔️', style: TextStyle(fontSize: 15)),
                    label: Text(
                      PocketLanguageService.localize(
                        en: 'LAUNCH POLICE REVENGE RAID',
                        ml: 'LAUNCH POLICE REVENGE RAID / തിരിച്ച് അറ്റാക്ക് ചെയ്യുക',
                        ta: 'பதிலடித் தாக்குதல் தொடங்கவும் ⚔️',
                        hi: 'जवाबी हमला शुरू करें ⚔️',
                      ),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.heavyImpact();
                      final targetId = _kidsRaids.first.attackerId;
                      if (targetId.isNotEmpty && targetId != 'me') {
                        final isTargetProt = await PocketFortressDefenseService
                            .isUnderPresidentialProtection(targetId);
                        if (isTargetProt) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '👮‍♂️ Suspect is under 24-Hour Presidential Protection! You can launch Revenge once protection expires.'),
                                backgroundColor: Color(0xFF0284C7),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } else {
                          if (!mounted) return;
                          PocketCitadelAttackPage.openForUser(
                            context,
                            userId: targetId,
                            targetName: _kidsRaids.first.attackerName,
                            isKidMode: true,
                          ).then((_) => _loadDefenseAndRaids());
                        }
                      } else {
                        // Attack default kid robot rival
                        final rival = await PocketFortressDefenseService
                            .getRecommendedRivalTarget(
                                userDay: day, forceRobot: true);
                        if (mounted) {
                          PocketCitadelAttackPage.openForUser(
                            context,
                            userId: rival.id,
                            targetName: rival.name,
                            isKidMode: true,
                          ).then((_) => _loadDefenseAndRaids());
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
          Text(label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
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
      {
        'day': 1,
        'emoji': '🌱',
        'title': 'Basecamp Sprout',
        'desc': 'Started the 100-Day English odyssey'
      },
      {
        'day': 8,
        'emoji': '🏡',
        'title': 'Brick Mason',
        'desc': 'Built a sturdy Foundation Villa'
      },
      {
        'day': 21,
        'emoji': '⚓',
        'title': 'Habit Anchor',
        'desc': 'Conquered 3 weeks of daily English'
      },
      {
        'day': 45,
        'emoji': '🏛️',
        'title': 'Imperial Manor',
        'desc': 'Mastered conversational confidence'
      },
      {
        'day': 70,
        'emoji': '💎',
        'title': 'Cyber Titan',
        'desc': 'Reached advanced spoken fluency'
      },
      {
        'day': 90,
        'emoji': '👑',
        'title': 'Palace Master',
        'desc': 'Stood before the Sovereign Summit'
      },
      {
        'day': 100,
        'emoji': '🦁',
        'title': 'King Lion Champion',
        'desc': 'Earned the official Grade Certificate'
      },
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
              color: isUnlocked
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFE2E8F0),
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
                  color: isUnlocked
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFF1F5F9),
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
                        color: isUnlocked
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
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
                  color: isUnlocked
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUnlocked ? 'EARNED ✨' : 'DAY $day',
                  style: GoogleFonts.outfit(
                    color: isUnlocked
                        ? const Color(0xFF15803D)
                        : const Color(0xFF94A3B8),
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
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
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
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B), fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_rounded,
                  color: Color(0xFF0284C7), size: 20),
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF082F49).withValues(alpha: 0.90),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) => false;
}
