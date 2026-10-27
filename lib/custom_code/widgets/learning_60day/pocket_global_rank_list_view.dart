import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

/// 🏅 Global Rank Leaderboard with Dedicated Humans vs Robots Tabs
/// User Audio Directives:
/// - "എല്ലാ ഹ്യൂമൻസും വേണം... നിലവിലുള്ള യൂസർ ടേബിളിലുള്ള, യൂസർ പ്രൊഫൈലിലുള്ള എല്ലാവരും Supabase സഹിതം കാണണം."
/// - "റോബോട്ടുകളേയും ഹ്യൂമൻസിനേയും സ്വിച്ച് ചെയ്യിപ്പിക്കാൻ അവിടെ ഒരു ടാബ് കൊടുക്കുക."
/// - "റോബോട്ടുകൾ വേറെ, റോബോട്ടുകളുടെ റാങ്കിങ് വേറെ, ഹ്യൂമൻസിന്റെ റാങ്കിങ് വേറെ. അത് രണ്ടും സെപ്പറേറ്റ് ചെയ്യുക."
/// - "അഡ്മിന് അത് ഒഴിവാക്കാനും (delete/hide from ranking) ഓപ്ഷൻ കൊടുക്കുക."
class PocketGlobalRankListView extends StatefulWidget {
  final String? currentUserId;
  final bool? isUnder17Only;
  final bool isMatesOnly;

  const PocketGlobalRankListView({
    super.key,
    this.currentUserId,
    this.isUnder17Only,
    this.isMatesOnly = false,
  });

  @override
  State<PocketGlobalRankListView> createState() =>
      _PocketGlobalRankListViewState();
}

class _PocketGlobalRankListViewState extends State<PocketGlobalRankListView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _humansScrollController = ScrollController();
  final ScrollController _robotsScrollController = ScrollController();

  late TabController _tabController;
  int _currentTabIndex = 0; // 0 = Humans, 1 = Robots

  List<PocketRankedUser> _humansList = [];
  List<PocketRankedUser> _robotsList = [];
  Set<String> _hiddenUserIds = {};

  bool _isLoading = true;
  String _searchQuery = '';
  int? _myHumanRank;
  bool _isAdmin = false;

  String get _effectiveUserId =>
      widget.currentUserId ?? SupaFlow.client.auth.currentUser?.id ?? '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    _checkAdminStatus();
    _loadAllRankings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _humansScrollController.dispose();
    _robotsScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final admin = AdminAuthService.isCurrentMasterAdmin() ||
        await AdminAuthService.canAccessAdmin();
    if (mounted) {
      setState(() => _isAdmin = admin);
    }
  }

  Future<void> _loadAllRankings({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final isKid = widget.isUnder17Only ?? PocketKidsService.isKidAccount;

      // 👥 If in Mates Only mode, strictly fetch connected mates and exclude all bots
      if (widget.isMatesOnly) {
        final mates = await PocketRankingService.fetchMatesLeaderboard(
          _effectiveUserId,
          isUnder17: isKid,
        );

        // Normalize ranks 1..N for Mates leaderboard
        for (int i = 0; i < mates.length; i++) {
          mates[i] = mates[i].copyWith(
            globalRank: i + 1,
            matesRank: i + 1,
          );
        }

        int? myRank;
        final myId = _effectiveUserId;
        for (final u in mates) {
          if (u.userId == myId) {
            myRank = u.globalRank;
            break;
          }
        }

        if (mounted) {
          setState(() {
            _humansList = mates;
            _robotsList = [];
            _hiddenUserIds = {};
            _myHumanRank = myRank;
            _isLoading = false;
          });
        }
        return;
      }

      // 1. Fetch ALL Real Human Users from Supabase profile table
      final humans = await PocketRankingService.fetchHumansOnlyLeaderboard(
        limit: 500,
        forceRefresh: forceRefresh,
        isUnder17: isKid,
      );

      // 2. Fetch AI Learner Robots
      final robots = await PocketRankingService.fetchRobotsOnlyLeaderboard(
        forceRefresh: forceRefresh,
        isUnder17: isKid,
      );

      // 3. Load hidden IDs
      final hidden = await PocketRankingService.getHiddenRankingUserIds();

      int? myRank;
      final myId = _effectiveUserId;
      for (final u in humans) {
        if (u.userId == myId) {
          myRank = u.globalRank;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _humansList = humans;
          _robotsList = robots;
          _hiddenUserIds = hidden;
          _myHumanRank = myRank;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<PocketRankedUser> get _activeList {
    return _currentTabIndex == 0 ? _humansList : _robotsList;
  }

  List<PocketRankedUser> get _filteredUsers {
    final list = _activeList;
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase().trim();
    return list.where((u) {
      final nameMatches = u.name.toLowerCase().contains(q);
      final rankStr = u.globalRank.toString();
      final rankMatches = rankStr == q || '#$rankStr' == q;
      final scoreMatches = u.pocketScore.toString().contains(q);
      return nameMatches || rankMatches || scoreMatches;
    }).toList();
  }

  void _scrollToMyRank() {
    if (_myHumanRank == null || _humansList.isEmpty) return;
    if (_currentTabIndex != 0) {
      _tabController.animateTo(0);
      setState(() => _currentTabIndex = 0);
    }
    final index = _humansList.indexWhere((u) => u.globalRank == _myHumanRank);
    if (index != -1) {
      HapticFeedback.mediumImpact();
      const double itemHeight = 68.0;
      final targetOffset = (index * itemHeight).clamp(
        0.0,
        _humansScrollController.position.maxScrollExtent,
      );
      _humansScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ADMIN DELETION / HIDING ACTIONS
  // ───────────────────────────────────────────────────────────────────────────


  void _promptAdminResetHidden() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unhide All Entries?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will restore all ${_hiddenUserIds.length} hidden users and robots back to the ranking tables.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await PocketRankingService.unhideAllFromRanking();
              await _loadAllRankings(forceRefresh: true);
            },
            child: Text('Restore All', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtered = _filteredUsers;

    return Container(
      color: const Color(0xFF070B0E),
      child: Stack(
        children: [
          Column(
            children: [
              // 1. Two-Tab Segmented Switcher (Humans vs Robots) - only in Global mode
              if (!widget.isMatesOnly)
                _buildTabsHeader(),

              // 2. Admin Hidden Alert Ribbon (if any hidden)
              if (_isAdmin && _hiddenUserIds.isNotEmpty)
                _buildAdminHiddenRibbon(),

              // 3. Search Bar Header
              _buildSearchBar(),

              // 4. Rankings Header Info Ribbon
              _buildRankingHeaderRibbon(),

              // 5. Lazy Loaded Minimal Leaderboard List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                          strokeWidth: 2.5,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadAllRankings(forceRefresh: true),
                        color: const Color(0xFFFFD700),
                        backgroundColor: const Color(0xFF0F172A),
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                controller: _currentTabIndex == 0
                                    ? _humansScrollController
                                    : _robotsScrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: filtered.length,
                                padding: const EdgeInsets.only(
                                  top: 6,
                                  bottom: 84, // Space for sticky bottom capsule
                                  left: 12,
                                  right: 12,
                                ),
                                itemBuilder: (context, index) {
                                  final user = filtered[index];
                                  return _buildRankTile(user);
                                },
                              ),
                      ),
              ),
            ],
          ),

          // 6. Sticky Bottom "Your Global Rank" Floating Capsule (Humans Tab)
          if (_currentTabIndex == 0 && _myHumanRank != null && !_isLoading)
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _buildMyGlobalRankBottomCapsule(),
            ),
        ],
      ),
    );
  }

  /// 👥 Segmented Tab Switcher: [ 👤 Humans (269) ] | [ 🤖 Robots (90) ]
  Widget _buildTabsHeader() {
    final humanCount = _humansList.length;
    final robotCount = _robotsList.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // 👤 Humans Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _tabController.animateTo(0);
                setState(() => _currentTabIndex = 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: _currentTabIndex == 0
                      ? const LinearGradient(
                          colors: [Color(0xFF047857), Color(0xFF065F46)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  border: _currentTabIndex == 0
                      ? Border.all(color: const Color(0xFF10B981), width: 1.2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👤', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Humans',
                      style: GoogleFonts.outfit(
                        color: _currentTabIndex == 0 ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _currentTabIndex == 0
                            ? const Color(0xFF10B981)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        humanCount > 0 ? '$humanCount' : '...',
                        style: GoogleFonts.outfit(
                          color: _currentTabIndex == 0 ? Colors.black : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 🤖 Robots Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _tabController.animateTo(1);
                setState(() => _currentTabIndex = 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: _currentTabIndex == 1
                      ? const LinearGradient(
                          colors: [Color(0xFF4338CA), Color(0xFF312E81)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  border: _currentTabIndex == 1
                      ? Border.all(color: const Color(0xFF818CF8), width: 1.2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Robots',
                      style: GoogleFonts.outfit(
                        color: _currentTabIndex == 1 ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _currentTabIndex == 1
                            ? const Color(0xFF818CF8)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        robotCount > 0 ? '$robotCount' : '90',
                        style: GoogleFonts.outfit(
                          color: _currentTabIndex == 1 ? Colors.black : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔒 Admin Banner showing hidden user count with Restore All button
  Widget _buildAdminHiddenRibbon() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF450A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, size: 14, color: Color(0xFFEF4444)),
          const SizedBox(width: 6),
          Text(
            'Master Admin: ${_hiddenUserIds.length} hidden from rankings',
            style: GoogleFonts.outfit(color: const Color(0xFFFCA5A5), fontSize: 11),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _promptAdminResetHidden,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Reset All',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Search Bar for looking up users or #rank
  Widget _buildSearchBar() {
    final isHumanTab = _currentTabIndex == 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? (isHumanTab ? const Color(0xFF10B981) : const Color(0xFF818CF8))
              : Colors.white12,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isHumanTab ? const Color(0xFF10B981) : const Color(0xFF818CF8),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: widget.isMatesOnly
                    ? 'Search mates by name or #rank...'
                    : (isHumanTab
                        ? 'Search real players by name or #rank...'
                        : 'Search AI robots by name or #rank...'),
                hintStyle: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
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

  /// 📊 Header Ribbon showing global rankings header
  Widget _buildRankingHeaderRibbon() {
    final isHumanTab = _currentTabIndex == 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131A26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(widget.isMatesOnly ? '👥' : (isHumanTab ? '👤' : '🤖'), style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            widget.isMatesOnly
                ? 'MATES LEADERBOARD'
                : (isHumanTab ? 'HUMAN GLOBAL RANKINGS' : 'AI ROBOT LEAGUE'),
            style: GoogleFonts.outfit(
              color: widget.isMatesOnly
                  ? const Color(0xFFFFD700)
                  : (isHumanTab ? const Color(0xFF34D399) : const Color(0xFFA5B4FC)),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            widget.isMatesOnly
                ? '${_humansList.length} Connected Mates'
                : 'Sorted by PocketScore 🪙',
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 📇 Minimal, High-Speed Leaderboard Tile
  Widget _buildRankTile(PocketRankedUser user) {
    final isRank1 = user.globalRank == 1;
    final isRank2 = user.globalRank == 2;
    final isRank3 = user.globalRank == 3;
    final isMe = user.isCurrentUser;

    Color rankColor;
    String rankText;

    if (isRank1) {
      rankColor = const Color(0xFFFFD700); // Pure radiant gold
      rankText = '1';
    } else if (isRank2) {
      rankColor = const Color(0xFFE2E8F0); // Polished silver
      rankText = '2';
    } else if (isRank3) {
      rankColor = const Color(0xFFCD7F32); // Warm bronze/copper
      rankText = '3';
    } else {
      rankColor = const Color(0xFF94A3B8); // Clean minimal slate
      rankText = '${user.globalRank}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF0F2618)
            : const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? const Color(0xFF10B981)
              : (isRank1
                  ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                  : Colors.white12),
          width: isMe || isRank1 ? 1.4 : 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            // Direct Citadel Attack Page navigation (Audio Directive)
            PocketCitadelAttackPage.openForUser(
              context,
              userId: user.userId,
              targetName: user.name,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                // 1. Minimal Rank Number
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      rankText,
                      style: GoogleFonts.outfit(
                        color: rankColor,
                        fontSize: (isRank1 || isRank2 || isRank3) ? 19.0 : 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRank1
                          ? const Color(0xFFFFD700)
                          : (isMe ? const Color(0xFF10B981) : Colors.white24),
                      width: 1.2,
                    ),
                    color: const Color(0xFF1E293B),
                  ),
                  child: ClipOval(
                    child: VectorAvatarWidget(
                      config: user.avatarConfig,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 3. User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: GoogleFonts.outfit(
                                color: isMe ? const Color(0xFF34D399) : Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'YOU',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                          if (user.isRobot) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4338CA),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BOT',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFA5B4FC),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lvl ${user.level}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. PocketScore Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        _formatScore(user.pocketScore),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron navigation indicator (Delete button removed per user audio directive)
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white24,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 Sticky Bottom Bar for Current User's Human Rank
  Widget _buildMyGlobalRankBottomCapsule() {
    final myUser = _humansList.firstWhere(
      (u) => u.globalRank == _myHumanRank,
      orElse: () => PocketRankedUser(
        userId: _effectiveUserId,
        name: 'You',
        pocketScore: 0,
        level: 1,
        globalRank: _myHumanRank ?? 1,
        avatarConfig: _humansList.isNotEmpty
            ? _humansList.first.avatarConfig
            : VectorAvatarConfig.defaultConfig,
        isCurrentUser: true,
      ),
    );

    return GestureDetector(
      onTap: _scrollToMyRank,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'YOUR RANK',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 9.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.isMatesOnly
                    ? 'Mate Rank #$_myHumanRank'
                    : 'Human Rank #$_myHumanRank',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '🪙 ${_formatScore(myUser.pocketScore)} PS',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location_rounded,
                  color: Color(0xFF34D399), size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            widget.isMatesOnly
                ? 'No mates found'
                : 'No matching ${_currentTabIndex == 0 ? "players" : "robots"} found',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching a different name or #rank number',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    }
    if (score >= 10000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}
