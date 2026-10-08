import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/english_tasks_master_hub.dart'
    show HouseMasterPainter;
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

class HomeOwnerEntry {
  final String id;
  final String name;
  final String? avatarUrl;
  final int day;
  final int score;
  final bool isRobot;

  const HomeOwnerEntry({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.day,
    required this.score,
    this.isRobot = false,
  });
}

class PocketHomeVisitModal extends StatefulWidget {
  final int day;
  final int userCurrentDay;
  final String? currentUserId;

  const PocketHomeVisitModal({
    super.key,
    required this.day,
    this.userCurrentDay = 1,
    this.currentUserId,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    int userCurrentDay = 1,
    String? currentUserId,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketHomeVisitModal(
          day: day,
          userCurrentDay: userCurrentDay,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  @override
  State<PocketHomeVisitModal> createState() => _PocketHomeVisitModalState();
}

class _PocketHomeVisitModalState extends State<PocketHomeVisitModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  late AnimationController _ambientController;
  List<HomeOwnerEntry> _allOwners = [];
  List<HomeOwnerEntry> _filteredOwners = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _searchController.addListener(_onSearchChanged);
    _loadOwners();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _sheetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query == _searchQuery) return;
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredOwners = List.from(_allOwners);
      } else {
        _filteredOwners = _allOwners
            .where((o) => o.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadOwners() async {
    final List<HomeOwnerEntry> owners = [];

    // 1. Fetch robots stationed at this EXACT level (Strict Peer Filtering: Audio Directive)
    final allRobots = PocketRobotService.getAllRobots();
    final stationRobots = allRobots.where((r) => r.level == widget.day).toList();
    if (stationRobots.isEmpty) {
      final robot = PocketRobotService.getRobotByLevel(widget.day);
      stationRobots.add(robot);
    }
    for (final r in stationRobots) {
      owners.add(
        HomeOwnerEntry(
          id: r.id,
          name: r.name,
          avatarUrl: r.avatarUrl,
          day: r.level,
          score: r.level * 180 + 300,
          isRobot: true,
        ),
      );
    }

    // 2. Query real learners who are at this EXACT level from Supabase
    try {
      final supa = Supabase.instance.client;
      final res = await supa
          .from('profile')
          .select('user_id, display_name, name, photo_url, profile_image_url, learning_day, learning_points, pocket_score')
          .eq('learning_day', widget.day)
          .limit(25);

      for (final row in res) {
        final uId = row['user_id']?.toString() ?? '';
        if (uId.isEmpty) continue;
        final dName = row['display_name']?.toString() ?? row['name']?.toString() ?? 'Adventurer';
        final pUrl = (row['photo_url'] ?? row['profile_image_url'])?.toString();
        final lDay = (row['learning_day'] as num?)?.toInt() ?? widget.day;
        final lPts = (row['learning_points'] ?? row['pocket_score'] as num?)?.toInt() ?? (widget.day * 150);
        owners.add(
          HomeOwnerEntry(
            id: uId,
            name: dName,
            avatarUrl: pUrl,
            day: lDay,
            score: lPts,
            isRobot: false,
          ),
        );
      }
    } catch (_) {}

    // Sort owners by house level descending, then score
    owners.sort((a, b) {
      final dComp = b.day.compareTo(a.day);
      if (dComp != 0) return dComp;
      return b.score.compareTo(a.score);
    });

    if (mounted) {
      setState(() {
        _allOwners = owners;
        _filteredOwners = owners;
        _isLoading = false;
      });
    }
  }

  void _attackOwner(HomeOwnerEntry owner) {
    HapticFeedback.heavyImpact();
    PocketCitadelAttackPage.openForUser(
      context,
      userId: owner.id,
      targetName: owner.name,
      attackerDay: widget.userCurrentDay,
      isDefenseMode: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(widget.day);
    final palette =
        HousePalette.presets[(widget.day - 1) % HousePalette.presets.length];
    final currentHour = DateTime.now().hour;
    final isNight = currentHour >= 18 || currentHour < 6;

    return Scaffold(
      backgroundColor: isNight ? const Color(0xFF031024) : const Color(0xFF0284C7),
      body: Stack(
        children: [
          // 1. Full Citadel Living Atmosphere (Animated Sky, Ambient Shimmer, Scenic Landscape)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                return CustomPaint(
                  painter: CitadelScenicLandscapePainter(
                    isDamaged: false,
                    groundBaseY: MediaQuery.of(context).size.height * 0.65,
                    isNight: isNight,
                    isDay90: widget.day >= 90,
                    ambientProg: _ambientController.value,
                    isPresident: widget.day >= 90,
                  ),
                );
              },
            ),
          ),

          // 2. Interactive Zoomable & Pannable House Architecture Canvas
          Positioned.fill(
            bottom: 140, // Space above collapsed bottom drawer
            child: InteractiveViewer(
              minScale: 0.7,
              maxScale: 2.8,
              boundaryMargin: const EdgeInsets.all(120),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_sheetController.isAttached) {
                          _sheetController.animateTo(
                            0.75,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: CustomPaint(
                        size: const Size(320, 230),
                        painter: HouseMasterPainter(
                          day: widget.day,
                          palette: palette,
                          isPresident: (widget.day >= 90),
                          lightsOn: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Estate Stage Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            estateTitle,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DAY ${widget.day}',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
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
          ),

          // Pinch guidance pill
          Positioned(
            top: 110,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pinch_rounded, size: 14, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 4),
                  Text(
                    'Pinch to Zoom • Drag to Pan',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Top Glassmorphic Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Text('🏡', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'HOME VISIT • DAY ${widget.day}',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    estateTitle,
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
            ),
          ),

          // 7. Draggable Sliding Drawer: Citadel Owners & Guardians
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.28,
            minChildSize: 0.22,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.28, 0.65, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 30,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_sheetController.isAttached) {
                          final target = _sheetController.size < 0.5 ? 0.75 : 0.28;
                          _sheetController.animateTo(
                            target,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 8),
                          width: 44,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    // Sheet Header (Tap to expand/collapse)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_sheetController.isAttached) {
                          final target = _sheetController.size < 0.5 ? 0.75 : 0.28;
                          _sheetController.animateTo(
                            target,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                            ),
                            child: const Text('🏰', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Owners of Homes',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${_filteredOwners.length}',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF60A5FA),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Swipe up to duel home owners • Challenge citadels',
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                    const Divider(color: Colors.white12, height: 16),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search Home Owners & Guardians...',
                            hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFF38BDF8), size: 18),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        color: Colors.white54, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Owners List with Vector Avatar and Citadel Attack Button
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD700),
                                strokeWidth: 2,
                              ),
                            )
                          : _filteredOwners.isEmpty
                              ? Center(
                                  child: Text(
                                    'No home owners found matching "$_searchQuery"',
                                    style: GoogleFonts.inter(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                  itemCount: _filteredOwners.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final owner = _filteredOwners[index];
                                    final avatarConfig =
                                        VectorAvatarConfig.getEvolutionAvatarForStage(owner.day);

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: owner.isRobot
                                              ? Colors.white10
                                              : const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                          width: 0.9,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Stage Vector Avatar
                                          ClipOval(
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              color: const Color(0xFF0F172A),
                                              child: owner.avatarUrl != null &&
                                                      owner.avatarUrl!.startsWith('http')
                                                  ? Image.network(
                                                      owner.avatarUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          VectorAvatarWidget(
                                                        config: avatarConfig,
                                                        size: 40,
                                                        showAura: false,
                                                      ),
                                                    )
                                                  : VectorAvatarWidget(
                                                      config: avatarConfig,
                                                      size: 40,
                                                      showAura: false,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        owner.name,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (owner.isRobot) ...[
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blueGrey.withValues(alpha: 0.3),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: const Text('BOT',
                                                            style: TextStyle(
                                                                color: Colors.white54,
                                                                fontSize: 8,
                                                                fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'House ${owner.day} • ${owner.score} PS 🪙',
                                                  style: GoogleFonts.inter(
                                                    color: const Color(0xFFFFD700),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // ⚔️ Attack Citadel Button
                                          ElevatedButton.icon(
                                            onPressed: () => _attackOwner(owner),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFDC2626),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 7),
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Text('⚔️', style: TextStyle(fontSize: 11)),
                                            label: Text(
                                              'Attack',
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 11.5,
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
            },
          ),
        ],
      ),
    );
  }
}

