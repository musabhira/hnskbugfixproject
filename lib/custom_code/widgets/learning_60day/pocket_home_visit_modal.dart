import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/vector_avatar_widget.dart';
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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PocketHomeVisitModal(
        day: day,
        userCurrentDay: userCurrentDay,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  State<PocketHomeVisitModal> createState() => _PocketHomeVisitModalState();
}

class _PocketHomeVisitModalState extends State<PocketHomeVisitModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<HomeOwnerEntry> _allOwners = [];
  List<HomeOwnerEntry> _filteredOwners = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadOwners();
  }

  @override
  void dispose() {
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

    // 1. Fetch robots stationed at or near this level
    final allRobots = PocketRobotService.getAllRobots();
    final stationRobots = allRobots.where((r) => r.level >= widget.day).take(15);
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

    // 2. Query real learners who have reached this level from Supabase
    try {
      final supa = Supabase.instance.client;
      final res = await supa
          .from('profile')
          .select('user_id, display_name, photo_url, learning_day, learning_points')
          .gte('learning_day', widget.day)
          .limit(25);

      if (res is List) {
        for (final row in res) {
          final uId = row['user_id']?.toString() ?? '';
          if (uId.isEmpty) continue;
          final dName = row['display_name']?.toString() ?? 'Adventurer';
          final pUrl = row['photo_url']?.toString();
          final lDay = (row['learning_day'] as num?)?.toInt() ?? widget.day;
          final lPts = (row['learning_points'] as num?)?.toInt() ?? 0;
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
    Navigator.of(context).pop(); // dismiss modal
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
    final screenH = MediaQuery.of(context).size.height;
    final modalH = (screenH * 0.88).clamp(520.0, 720.0);

    return Container(
      height: modalH,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 28,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
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

          // Header
          Padding(
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
                      Text(
                        estateTitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Pinch to Zoom & Pan Architecture • Duel Home Owners',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 16),

          // 1. Zoomable & Pannable Visual House Architecture Canvas
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12, width: 1),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.0,
                    boundaryMargin: const EdgeInsets.all(60),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(280, 160),
                        painter: HouseMasterPainter(
                          day: widget.day,
                          palette: palette,
                          isPresident: (widget.day >= 90),
                          lightsOn: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pinch_rounded,
                            size: 13, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 4),
                        Text(
                          'Pinch to Zoom / Drag to Pan',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Search Bar for Home Owners
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

          // Section Title: Home Owners
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Text(
                  'HOME OWNERS & GUARDIANS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
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
          ),

          // 3. Owners List with Attack Button
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
                                // Avatar
                                ClipOval(
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    color: const Color(0xFF0F172A),
                                    child: owner.avatarUrl != null &&
                                            owner.avatarUrl!.startsWith('http')
                                        ? Image.network(
                                            owner.avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                VectorAvatarWidget(
                                              config: avatarConfig,
                                              size: 38,
                                              showAura: false,
                                            ),
                                          )
                                        : VectorAvatarWidget(
                                            config: avatarConfig,
                                            size: 38,
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

                                // ⚔️ Attack Button
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
  }
}
