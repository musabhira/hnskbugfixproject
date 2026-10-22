import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';

import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_world_ranking_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'pocket_global_rank_list_view.dart';

enum RankingTrailMode {
  world,
  mates,
}

/// 🌳 Flame-Powered Playable Mountain Canyon World Ranking Experience
///
/// Features:
/// 1. Flame Game Engine (`use flame`):
///    - Vertical mountain canyon with rocky cliffs, waterfalls, and sky vistas.
///    - Compact, congested terraces with unclipped architectural houses.
/// 2. Playable Arcade Bouncing Ball Game:
///    - On-screen steering controls (◀ / ▶) and touch steering.
///    - Bounces on ledges with impact sparks, combo multipliers, and "+10 PTS" bubbles.
/// 3. Presidential Protection Force for Ranks 1, 2, 3:
///    - Elite Presidential Sentries guarding top citadels.
///    - Challenging English defense questions must be solved to breach and attack!
/// 4. Altitude & Floor Metric (Audio requirement):
///    - Displays Mountain Altitude (`⛰️ ALT: X,XXXM • FLOOR #N`).
/// 5. Robots Simulation Toggle:
///    - Admin/HUD toggle to mix robots for testing or filter to pure humans.
/// 6. Minimal Bottom Floor Indicator:
///    - Tap to instantly glide camera to your own house!
class PocketWorldRankingTrailWidget extends StatefulWidget {
  final RankingTrailMode mode;
  final String? currentUserId;
  final VoidCallback? onClose;
  final bool? isUnder17Only;

  const PocketWorldRankingTrailWidget({
    super.key,
    this.mode = RankingTrailMode.world,
    this.currentUserId,
    this.onClose,
    this.isUnder17Only,
  });

  /// 👥 Open Mates Ranking in a premium bottom sheet modal with Global Ranking UI
  static Future<void> showMatesRankingModal(BuildContext context, {String? userId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.94,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 12, 8),
              child: Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mates Rank',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rankings of your connected mates',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: PocketGlobalRankListView(
                currentUserId: userId,
                isMatesOnly: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<PocketWorldRankingTrailWidget> createState() =>
      _PocketWorldRankingTrailWidgetState();
}

class _PocketWorldRankingTrailWidgetState
    extends State<PocketWorldRankingTrailWidget> {
  final TextEditingController _searchController = TextEditingController();

  FlameWorldRankingGame? _flameGame;
  List<PocketRankedUser> _rankedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _myUserIndex;
  String _searchQuery = '';
  bool _isUnder17League = false;
  int _communityFilter = 0; // 0 = All (Humans + Robots), 1 = Humans Only, 2 = Robots Only
  final bool _isPlayMode = true;
  final CanyonAtmosphere _currentAtmosphere = CanyonAtmosphere.auto;
  final bool _isFollowingBall = true;
  bool _isSearchOpen = false;

  String get _effectiveUserId =>
      widget.currentUserId ?? SupaFlow.client.auth.currentUser?.id ?? '';

  bool get _isWorldMode => widget.mode == RankingTrailMode.world;

  @override
  void initState() {
    super.initState();
    _isUnder17League = widget.isUnder17Only ?? PocketKidsService.isKidAccount;
    _loadRankingData();
  }

  @override
  void didUpdateWidget(covariant PocketWorldRankingTrailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _loadRankingData();
    }
  }

  Timer? _descentHoldTimer;

  void _startDescentHold() {
    HapticFeedback.mediumImpact();
    _flameGame?.driveDownhill();
    _descentHoldTimer?.cancel();
    _descentHoldTimer = Timer.periodic(const Duration(milliseconds: 140), (_) {
      _flameGame?.driveDownhill();
    });
  }

  void _stopDescentHold() {
    _descentHoldTimer?.cancel();
    _descentHoldTimer = null;
    _flameGame?.steerNeutral();
  }

  @override
  void dispose() {
    _descentHoldTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRankingData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<PocketRankedUser> list;
      if (_isWorldMode) {
        if (_communityFilter == 1) {
          // Pure Humans League from Supabase
          list = await PocketRankingService.fetchHumansOnlyLeaderboard(
            limit: 500,
            forceRefresh: forceRefresh,
            isUnder17: _isUnder17League,
          );
        } else if (_communityFilter == 2) {
          // Pure AI Robots League
          list = await PocketRankingService.fetchRobotsOnlyLeaderboard(
            forceRefresh: forceRefresh,
            isUnder17: _isUnder17League,
          );
        } else {
          // All Learners (Humans + Robots)
          list = await PocketRankingService.fetchGlobalLeaderboard(
            limit: 500,
            forceRefresh: forceRefresh,
            isUnder17: _isUnder17League,
            includeRobots: true,
          );
        }
      } else {
        list = await PocketRankingService.fetchMatesLeaderboard(
          _effectiveUserId,
          isUnder17: _isUnder17League,
        );
      }

      // Safe fallback: never let canyon be empty or have only 1 house
      if (list.length <= 1) {
        list = await PocketRankingService.fetchGlobalLeaderboard(
          limit: 300,
          forceRefresh: true,
          includeRobots: true,
        );
      }

      int? myIndex;
      for (int i = 0; i < list.length; i++) {
        if (list[i].userId == _effectiveUserId) {
          myIndex = i;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _rankedUsers = list;
          _myUserIndex = myIndex;
          _isLoading = false;
          _errorMessage = null;
        });

        _initOrUpdateFlameGame();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Ranking error, graceful fallback: $e');
      final fallbackList = await PocketRankingService.fetchGlobalLeaderboard(
        limit: 300,
        forceRefresh: true,
        includeRobots: true,
      );
      if (mounted) {
        setState(() {
          _rankedUsers = fallbackList;
          _isLoading = false;
          _errorMessage = null;
        });
        _initOrUpdateFlameGame();
      }
    }
  }

  List<PocketRankedUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return _rankedUsers;
    final q = _searchQuery.toLowerCase().trim();
    return _rankedUsers.where((u) {
      final nameMatch = u.name.toLowerCase().contains(q);
      final rankStr = _isWorldMode
          ? u.globalRank.toString()
          : (u.matesRank ?? u.globalRank).toString();
      final rankMatch = rankStr == q || '#$rankStr' == q;
      final levelMatch =
          'level ${u.level}'.contains(q) || u.level.toString() == q;
      return nameMatch || rankMatch || levelMatch;
    }).toList();
  }

  void _initOrUpdateFlameGame() {
    final filtered = _filteredUsers;
    if (_flameGame == null) {
      _flameGame = FlameWorldRankingGame(
        users: filtered,
        currentUserId: _effectiveUserId,
        onHouseTapped: (user) {
          PocketCitadelAttackPage.openForUser(
            context,
            userId: user.userId,
          );
        },
        onRankSelected: (rank, user) {
          PocketCitadelAttackPage.openForUser(
            context,
            userId: user.userId,
          );
        },
      );
      _flameGame!.setAtmosphere(_currentAtmosphere);
      _flameGame!.setPlayMode(_isPlayMode);
      _flameGame!.setFollowBall(_isFollowingBall);
    } else {
      _flameGame!.updateUsers(filtered, newCurrentUserId: _effectiveUserId);
    }
  }

  void _scrollToMyRank() {
    if (_flameGame == null) return;
    HapticFeedback.mediumImpact();
    _flameGame!.panToUser(_effectiveUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF071209),
      child: Stack(
        children: [
          // 1. 🏔️ Flame Game Engine Canyon Viewport
          Positioned.fill(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  )
                : (_rankedUsers.isEmpty && _errorMessage != null)
                    ? _buildErrorView()
                    : _filteredUsers.isEmpty
                        ? _buildEmptyView()
                        : GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragUpdate: (details) {
                              _flameGame?.steerBy(details.primaryDelta! * 1.4);
                            },
                            onVerticalDragUpdate: (details) {
                              _flameGame?.scrollBy(-details.primaryDelta!);
                            },
                            onVerticalDragEnd: (details) {
                              _flameGame?.fling(-details.primaryVelocity!);
                            },
                            child: GameWidget(game: _flameGame!),
                          ),
          ),

          // 2. 🎮 Top HUD Bar (Summit Lift, Community Filter Switcher & Search)
          if (!_isLoading)
            _buildTopHUDBar(),

          // 3. 🕹️ On-Screen Steering Arrow Controls (◀ / ▶) for Playable Game Feel (Audio directive)
          if (!_isLoading && _flameGame != null)
            _buildSteeringControls(),

          // 4. 🎯 Minimal Floor Status & Altitude Button at Bottom (Audio directive)
          if (!_isLoading && _myUserIndex != null && _rankedUsers.isNotEmpty)
            _buildMinimalFloorButton(),
        ],
      ),
    );
  }

  /// 🎮 Top HUD Bar with Summit Lift, Community Filter Switcher (All/Humans/Robots), and Search
  Widget _buildTopHUDBar() {
    return Positioned(
      top: 10,
      left: 12,
      right: 12,
      child: Row(
        children: [
          // ⛰️ Restart from Summit Button
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              _flameGame?.restartFromSummit();
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B12).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⛰️', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    'Summit',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Community Switcher Pills [ All | Humans | Bots ]
          if (_isWorldMode)
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24, width: 1.0),
                ),
                child: Row(
                  children: [
                    _buildPillTab(0, 'All'),
                    _buildPillTab(1, '👤 Humans'),
                    _buildPillTab(2, '🤖 Bots'),
                  ],
                ),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 6),

          // Search Button
          _buildFloatingSearch(),
        ],
      ),
    );
  }

  Widget _buildPillTab(int index, String label) {
    final isSelected = _communityFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_communityFilter == index) return;
          HapticFeedback.selectionClick();
          setState(() {
            _communityFilter = index;
          });
          _loadRankingData(forceRefresh: false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (index == 1
                    ? const Color(0xFF059669)
                    : (index == 2 ? const Color(0xFF4F46E5) : const Color(0xFFD97706)))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// 🔍 Sleek Minimal Expandable Search Bar (Audio Directive: "cheriya oru search bar venamenkil searchinte oru icon kodukka mele... athil tap cheythu kazhinjal search bar varuka")
  Widget _buildFloatingSearch() {
    if (!_isSearchOpen) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isSearchOpen = true);
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B12).withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.65),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.search_rounded, color: Color(0xFFFFD700), size: 20),
          ),
        ),
      );
    }

    return Container(
      width: 250,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B12).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFFFFD700), size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
                _flameGame?.updateUsers(_filteredUsers);
              },
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Search player or #rank...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_searchQuery.isNotEmpty) {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
                _flameGame?.updateUsers(_filteredUsers);
              } else {
                setState(() => _isSearchOpen = false);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 🕹️ On-Screen Dirt Bike Controls:
  /// - ◀ TURN / REVERSE
  /// - 🚀 DRIVE DOWN ⏩ (Continuous descent down canyon terraces, jumps and loops!)
  /// - TURN ▶ / FORWARD
  Widget _buildSteeringControls() {
    return Positioned(
      bottom: 74,
      left: 14,
      right: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ◀ Left Steer / Turn Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _flameGame?.tapDriveLeft();
            },
            onTapDown: (_) => _flameGame?.steerLeft(),
            onTapUp: (_) => _flameGame?.steerNeutral(),
            onTapCancel: () => _flameGame?.steerNeutral(),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'TURN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 🏍️ Large Golden "DRIVE DOWN" Button (User Audio Directive: "വണ്ടി ഡ്രൈവ് ചെയ്യുന്ന സമയത്ത് ഓട്ടോമാറ്റിക് അടിയിലേക്ക് എത്തണം")
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _flameGame?.driveDownhill();
              },
              onTapDown: (_) => _startDescentHold(),
              onTapUp: (_) => _stopDescentHold(),
              onTapCancel: () => _stopDescentHold(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.two_wheeler_rounded, color: Color(0xFF0F172A), size: 24),
                    const SizedBox(width: 7),
                    Text(
                      'DRIVE 🏍️',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ▶ Right Steer / Turn Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _flameGame?.tapDriveRight();
            },
            onTapDown: (_) => _flameGame?.steerRight(),
            onTapUp: (_) => _flameGame?.steerNeutral(),
            onTapCancel: () => _flameGame?.steerNeutral(),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TURN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Minimal "Where Am I?" / Floor Status Button at Bottom (Audio directive)
  Widget _buildMinimalFloorButton() {
    final myRank = _isWorldMode
        ? (_myUserIndex != null ? _rankedUsers[_myUserIndex!].globalRank : '?')
        : (_myUserIndex != null
            ? (_rankedUsers[_myUserIndex!].matesRank ?? _myUserIndex! + 1)
            : '?');

    final totalCount = _rankedUsers.length;
    final myFloor = _myUserIndex != null ? (totalCount - _myUserIndex!) : 1;
    final myAltitude = myFloor * 100;
    final myUser = _myUserIndex != null ? _rankedUsers[_myUserIndex!] : null;

    return Positioned(
      bottom: 16,
      left: 28,
      right: 28,
      child: GestureDetector(
        onTap: _scrollToMyRank,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF142C18), Color(0xFF0C1C0F)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.85),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Text(
                myUser != null
                    ? 'Floor #$myFloor (${myUser.name})'
                    : 'Floor #$myFloor (Rank #$myRank)',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ⛰️ ${myAltitude}m',
                style: GoogleFonts.sourceCodePro(
                  color: const Color(0xFF86EFAC),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Jump to Me ⚡',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.arrow_downward_rounded,
                color: Color(0xFFFFD700),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An error occurred.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadRankingData(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏰', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              _isWorldMode ? 'No Citadels Found' : 'No Mates Yet',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No citadels matching "$_searchQuery"'
                  : 'Start learning and chatting to claim your spot in the Open World Canyon!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
