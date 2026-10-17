import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

/// 🏅 Minimal High-Performance Global Rank Leaderboard
/// User Audio Directives:
/// - "ഒരു ടാബും കൂടി ആഡ് ചെയ്യുക... വേൾഡ് റാങ്ക് പോലെ ഒരു ടാബും കൂടി ആഡ് ചെയ്യുക,
///   ആ ടാബിൽ മിനിമൽ ടൈൽ ആയിട്ട് ഇങ്ങനെ അടിയിലേക്ക് അടിയിലേക്ക് ഇടുക.
///   ഫസ്റ്റ് റാങ്ക് ഉള്ള ആള് റാങ്ക് വൺ എന്ന് എഴുതിയിട്ട് ആ പേര്...
///   ഒരു ലക്ഷം യൂസേഴ്സിന് ഒരു ലക്ഷം റാങ്ക് ഉണ്ടാവും...
///   ലേസി ലോഡിങ് പ്രോപ്പർ ആയിട്ട് ഇംപ്ലിമെൻ്റ് ചെയ്തിരിക്കണം.
///   സെർച്ച് ചെയ്യാൻ പറ്റണം, ഡയറക്ട് അതിലേക്ക് കയറിപ്പോകാൻ പറ്റണം.
///   വേൾഡ് റാങ്ക് അല്ല, ഗ്ലോബൽ റാങ്ക്."
class PocketGlobalRankListView extends StatefulWidget {
  final String? currentUserId;
  final bool? isUnder17Only;

  const PocketGlobalRankListView({
    super.key,
    this.currentUserId,
    this.isUnder17Only,
  });

  @override
  State<PocketGlobalRankListView> createState() =>
      _PocketGlobalRankListViewState();
}

class _PocketGlobalRankListViewState extends State<PocketGlobalRankListView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PocketRankedUser> _allRankedUsers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  int? _myGlobalRank;
  int _currentLimit = 150;

  String get _effectiveUserId =>
      widget.currentUserId ?? SupaFlow.client.auth.currentUser?.id ?? '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialRankings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searchQuery.isNotEmpty) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_isLoading &&
        !_isLoadingMore) {
      _loadMoreRankings();
    }
  }

  Future<void> _loadInitialRankings({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final isKid = widget.isUnder17Only ?? PocketKidsService.isKidAccount;
      final robotsEnabled = await PocketRankingService.isRobotsEnabledInWorldRanking();

      final list = await PocketRankingService.fetchGlobalLeaderboard(
        limit: _currentLimit,
        forceRefresh: forceRefresh,
        isUnder17: isKid,
        includeRobots: robotsEnabled,
      );

      int? myRank;
      final myId = _effectiveUserId;
      for (final u in list) {
        if (u.userId == myId) {
          myRank = u.globalRank;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _allRankedUsers = list;
          _myGlobalRank = myRank;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreRankings() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      _currentLimit += 100;
      final isKid = widget.isUnder17Only ?? PocketKidsService.isKidAccount;
      final robotsEnabled = await PocketRankingService.isRobotsEnabledInWorldRanking();

      final list = await PocketRankingService.fetchGlobalLeaderboard(
        limit: _currentLimit,
        forceRefresh: false,
        isUnder17: isKid,
        includeRobots: robotsEnabled,
      );

      if (mounted) {
        setState(() {
          _allRankedUsers = list;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  List<PocketRankedUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allRankedUsers;
    final q = _searchQuery.toLowerCase().trim();
    return _allRankedUsers.where((u) {
      final nameMatches = u.name.toLowerCase().contains(q);
      final rankStr = u.globalRank.toString();
      final rankMatches = rankStr == q || '#$rankStr' == q;
      final scoreMatches = u.pocketScore.toString().contains(q);
      return nameMatches || rankMatches || scoreMatches;
    }).toList();
  }

  void _scrollToMyRank() {
    if (_myGlobalRank == null || _filteredUsers.isEmpty) return;
    final index = _filteredUsers.indexWhere((u) => u.globalRank == _myGlobalRank);
    if (index != -1) {
      HapticFeedback.mediumImpact();
      const double itemHeight = 68.0;
      final targetOffset = (index * itemHeight).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

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
              // 1. Search Bar Header
              _buildSearchBar(),

              // 2. Rankings Header Info Ribbon
              _buildRankingHeaderRibbon(),

              // 3. Lazy Loaded Minimal Leaderboard List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                          strokeWidth: 2.5,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadInitialRankings(forceRefresh: true),
                        color: const Color(0xFFFFD700),
                        backgroundColor: const Color(0xFF0F172A),
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: filtered.length + (_isLoadingMore ? 1 : 0),
                                padding: const EdgeInsets.only(
                                  top: 6,
                                  bottom: 84, // Space for sticky bottom card
                                  left: 12,
                                  right: 12,
                                ),
                                itemBuilder: (context, index) {
                                  if (index >= filtered.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFFFD700),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final user = filtered[index];
                                  return _buildRankTile(user);
                                },
                              ),
                      ),
              ),
            ],
          ),

          // 4. Sticky Bottom "My Global Rank" Floating Capsule
          if (_myGlobalRank != null && !_isLoading)
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

  /// 🔍 Sleek Search Bar for looking up users or #rank
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? const Color(0xFFFFD700)
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
          const Icon(Icons.search_rounded, color: Color(0xFFFFD700), size: 20),
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
                hintText: 'Search by player name or #rank (e.g. 1, 42)...',
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
                child: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  /// 📊 Header Ribbon showing global rankings header and sorting principle
  Widget _buildRankingHeaderRibbon() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131A26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text((widget.isUnder17Only ?? PocketKidsService.isKidAccount) ? '🎒' : '🏅', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            (widget.isUnder17Only ?? PocketKidsService.isKidAccount)
                ? 'JUNIOR GLOBAL RANK (UNDER 17)'
                : 'GLOBAL RANKINGS',
            style: GoogleFonts.outfit(
              color: (widget.isUnder17Only ?? PocketKidsService.isKidAccount)
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFFFFD700),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            'Sorted by PocketScore 🪙',
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

  /// 📇 Minimal, High-Speed Leaderboard Tile (Audio Directive: Minimal rank numbers, no box background, no subtitle clutter)
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
                // 1. Minimal Rank Number (No heavy background box, responsive)
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

                // 3. User Details (Minimal without overflowing subtitle)
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
                const SizedBox(width: 4),
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

  /// 🎯 Sticky Bottom Bar for Current User's Global Rank
  Widget _buildMyGlobalRankBottomCapsule() {
    final myUser = _allRankedUsers.firstWhere(
      (u) => u.globalRank == _myGlobalRank,
      orElse: () => PocketRankedUser(
        userId: _effectiveUserId,
        name: 'You',
        pocketScore: 0,
        level: 1,
        globalRank: _myGlobalRank ?? 1,
        avatarConfig: _allRankedUsers.isNotEmpty
            ? _allRankedUsers.first.avatarConfig
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'YOUR RANK',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Global Rank #$_myGlobalRank',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '🪙 ${_formatScore(myUser.pocketScore)} PS',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location_rounded,
                  color: Color(0xFF34D399), size: 15),
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
            'No matching players found',
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
