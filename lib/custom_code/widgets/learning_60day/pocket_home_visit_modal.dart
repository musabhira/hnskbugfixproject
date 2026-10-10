import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';

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
  late final TransformationController _transformationController;
  bool _hasInitializedTransform = false;

  List<HomeOwnerEntry> _allOwners = [];
  List<HomeOwnerEntry> _filteredOwners = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
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
    _transformationController.dispose();
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

    // 1. Fetch robots stationed at this EXACT level
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

  void _openOwnerChat(HomeOwnerEntry owner) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WhatsAppGroupChat(
          groupId: owner.id,
          groupName: owner.name,
          groupImage: owner.avatarUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(widget.day);
    final palette =
        HousePalette.presets[(widget.day - 1) % HousePalette.presets.length];
    final currentHour = DateTime.now().hour;
    final isNight = currentHour >= 18 || currentHour < 6;
    final isDay90 = widget.day >= 90;
    final bool isPresident = widget.day >= 90;

    const double worldW = 1200.0;
    const double worldH = 1600.0;
    const double groundY = 920.0;
    const double houseW = 420.0;
    const double houseH = 380.0;
    final double houseLeft = (worldW - houseW) / 2;
    final double houseTop = groundY - 14.0 - houseH;

    final double palaceW = 540.0;
    final double palaceH = 410.0;
    final double palaceLeft = (worldW - palaceW) / 2;
    final double palaceTop = groundY - 10.0 - palaceH;

    return Scaffold(
      backgroundColor: isNight ? const Color(0xFF031024) : const Color(0xFF0284C7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final isLandscape = w > h;

          final double houseZoomScale = isPresident
              ? (isLandscape
                  ? math.min(w / (palaceW * 1.15), h / (palaceH * 1.25))
                  : (w / (palaceW * 1.08)))
              : (w / (houseW * 1.05));

          final double baseMinScale = math.max(w / worldW, h / worldH);
          final minScale = (w <= 0) ? 0.30 : baseMinScale;
          const maxScale = 3.5;
          final defaultScale = (w <= 0)
              ? 1.0
              : math.min(maxScale, math.max(minScale, houseZoomScale));

          if (!_hasInitializedTransform && w > 0 && h > 0) {
            _hasInitializedTransform = true;
            final houseCenterX = worldW / 2;
            final houseCenterY = isPresident
                ? (palaceTop + (palaceH * 0.48))
                : (houseTop + (houseH * 0.52));

            final maxTx = 0.0;
            final minTx = -((worldW * defaultScale) - w);
            final safeMinTx = minTx < maxTx ? minTx : maxTx;
            final tx = ((w / 2) - (houseCenterX * defaultScale)).clamp(safeMinTx, maxTx);

            final maxTy = 0.0;
            final minTy = -((worldH * defaultScale) - h);
            final safeMinTy = minTy < maxTy ? minTy : maxTy;
            final targetTy = ((h * 0.42) - (houseCenterY * defaultScale));
            final ty = targetTy.clamp(safeMinTy, maxTy);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final initialMatrix = Matrix4.identity();
                initialMatrix.setEntry(0, 0, defaultScale);
                initialMatrix.setEntry(1, 1, defaultScale);
                initialMatrix.setEntry(0, 3, tx);
                initialMatrix.setEntry(1, 3, ty);
                _transformationController.value = initialMatrix;
              }
            });
          }

          return Stack(
            children: [
              // 1. Unified Zoomable Virtual World Architecture (Landscape + Flame House)
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: minScale,
                  maxScale: maxScale,
                  boundaryMargin: EdgeInsets.zero,
                  constrained: false,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: worldW,
                    height: worldH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Scenic Animated Landscape
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _ambientController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: CitadelScenicLandscapePainter(
                                  isDamaged: false,
                                  groundBaseY: groundY,
                                  isNight: isNight,
                                  isDay90: isDay90,
                                  ambientProg: _ambientController.value,
                                  isPresident: isPresident,
                                ),
                              );
                            },
                          ),
                        ),

                        // Central Flame House Architecture
                        if (isPresident)
                          Positioned(
                            left: palaceLeft,
                            top: palaceTop,
                            width: palaceW,
                            height: palaceH,
                            child: FlameEnglishHouseWidget(
                              currentDay: 90,
                              streak: 90,
                              isDamaged: false,
                              houseId: 'home_visit_president',
                              paletteId: palette.id,
                              isPresident: true,
                              showTestingControls: false,
                            ),
                          )
                        else
                          Positioned(
                            left: houseLeft,
                            top: houseTop,
                            width: houseW,
                            height: houseH,
                            child: FlameEnglishHouseWidget(
                              currentDay: widget.day,
                              streak: widget.day,
                              isDamaged: false,
                              houseId: 'home_visit_${widget.day}',
                              paletteId: palette.id,
                              isPresident: false,
                              showTestingControls: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Pinch guidance pill
              Positioned(
                top: 105,
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
                        'Pinch to Zoom • Drag to Explore',
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

              // 3. Top Glassmorphic Navigation Bar
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

              // 4. Draggable Bottom Drawer: Owner of Homes
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.28,
                minChildSize: 0.20,
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

                        // Sheet Header (Owner of Homes)
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
                                  child: const Text('🏡', style: TextStyle(fontSize: 18)),
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
                                              'Owner of Homes',
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
                                        'Stationed robots & fellow learners residing at Day ${widget.day}',
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

                        // Owners List with Vector Avatar and Chat / Connect Button
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

                                              // 💬 Chat / Connect Button (No Attack Button in Home Visit)
                                              ElevatedButton.icon(
                                                onPressed: () => _openOwnerChat(owner),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF0284C7),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 7),
                                                  minimumSize: Size.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.chat_bubble_rounded, size: 12),
                                                label: Text(
                                                  'Chat',
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
          );
        },
      ),
    );
  }
}


