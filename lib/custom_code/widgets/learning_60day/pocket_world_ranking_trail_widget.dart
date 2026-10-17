import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart' show HousePalette;
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/english_tasks_master_hub.dart' show HouseMasterPainter;
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

enum RankingTrailMode {
  world,
  mates,
}

/// 🏆 App-Wide Dynamic World & Mates Ranking Trail Widget
/// Renders a minimal, beautiful climbing stepping route showing houses, avatars,
/// PocketScores, and rank badges from Rank 1 (Crown Leader) to the bottom.
class PocketWorldRankingTrailWidget extends StatefulWidget {
  final RankingTrailMode mode;
  final String? currentUserId;
  final VoidCallback? onClose;

  const PocketWorldRankingTrailWidget({
    super.key,
    this.mode = RankingTrailMode.world,
    this.currentUserId,
    this.onClose,
  });

  /// 👥 Open Mates Ranking Trail in a premium bottom sheet modal
  static Future<void> showMatesRankingModal(BuildContext context, {String? userId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Color(0xFF070B0E),
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
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
              child: Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mates Ranking Trail',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rankings among your followed friends & mates',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: PocketWorldRankingTrailWidget(
                mode: RankingTrailMode.mates,
                currentUserId: userId,
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
    extends State<PocketWorldRankingTrailWidget>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _pulseController;

  List<PocketRankedUser> _rankedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _myUserIndex;

  String get _effectiveUserId =>
      widget.currentUserId ?? SupaFlow.client.auth.currentUser?.id ?? '';

  bool get _isWorldMode => widget.mode == RankingTrailMode.world;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _loadRankingData();
  }

  @override
  void didUpdateWidget(covariant PocketWorldRankingTrailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _loadRankingData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
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
        list = await PocketRankingService.fetchGlobalLeaderboard(
          limit: 100,
          forceRefresh: forceRefresh,
        );
      } else {
        list = await PocketRankingService.fetchMatesLeaderboard(_effectiveUserId);
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load rankings. Please retry.';
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToMyRank() {
    if (_myUserIndex == null || !_scrollController.hasClients) return;
    HapticFeedback.mediumImpact();
    // Approximate node height is 220px
    final targetOffset = (_myUserIndex! * 220.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070B0E),
      child: Stack(
        children: [
          // 1. Ambient Background Layer
          Positioned.fill(
            child: CustomPaint(
              painter: _TrailAmbientNaturePainter(),
            ),
          ),

          // 2. Main Content
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          else if (_errorMessage != null)
            _buildErrorView()
          else if (_rankedUsers.isEmpty)
            _buildEmptyView()
          else
            RefreshIndicator(
              onRefresh: () => _loadRankingData(forceRefresh: true),
              color: const Color(0xFFFFD700),
              backgroundColor: const Color(0xFF121B22),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                itemCount: _rankedUsers.length + 1, // Header banner + nodes
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSummitHeaderCard();
                  }
                  final memberIndex = index - 1;
                  final member = _rankedUsers[memberIndex];
                  final displayRank = _isWorldMode
                      ? member.globalRank
                      : (member.matesRank ?? memberIndex + 1);

                  return _buildMemberTrailNode(
                    member: member,
                    rank: displayRank,
                    isLast: memberIndex == _rankedUsers.length - 1,
                  );
                },
              ),
            ),

          // 3. Floating User Status Pill (Jump to Me)
          if (!_isLoading && _rankedUsers.isNotEmpty && _myUserIndex != null)
            _buildFloatingUserRankPill(),
        ],
      ),
    );
  }

  Widget _buildSummitHeaderCard() {
    final leader = _rankedUsers.isNotEmpty ? _rankedUsers.first : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.16),
            const Color(0xFF1F2C34).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Crown Icon with pulsing aura
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.08);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFEA79), Color(0xFFFFB300)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700)
                            .withValues(alpha: 0.35 + (_pulseController.value * 0.25)),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isWorldMode ? '👑 GLOBAL RANK #1' : '👑 MATES LEADER #1',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_rankedUsers.length} Competitors',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  leader?.name ?? 'Sovereign Leader',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${leader?.pocketScore ?? 0} Pts',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      leader?.isPrestigeSovereign == true
                          ? '⭐ Sovereign P-${leader?.prestigeStars}'
                          : 'Level ${leader?.level ?? 1}',
                      style: GoogleFonts.inter(
                        color: leader?.isPrestigeSovereign == true
                            ? const Color(0xFFFFEA79)
                            : Colors.white70,
                        fontSize: 12,
                        fontWeight: leader?.isPrestigeSovereign == true
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTrailNode({
    required PocketRankedUser member,
    required int rank,
    required bool isLast,
  }) {
    final isRank1 = rank == 1;
    final screenWidth = MediaQuery.of(context).size.width;

    // Alternating horizontal shift for organic trail road
    final isEven = rank % 2 == 0;
    final double horizontalPadding = screenWidth > 380 ? 18.0 : 8.0;

    // Palette & dimensions
    final palette =
        HousePalette.presets[(member.level - 1) % HousePalette.presets.length];
    final double houseWidth = (screenWidth * 0.44).clamp(160.0, 200.0);
    const double houseHeight = 110.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isEven) ...[
                _buildRankBadge(member, rank),
                const SizedBox(width: 12),
              ],

              // 🏠 Interactive House & Citadel Target
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  PocketCitadelAttackPage.openForUser(
                    context,
                    userId: member.userId,
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Outer aura for Rank 1 or Prestige Sovereigns
                    if (isRank1 || member.isPrestigeSovereign)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: houseWidth + 24,
                            height: houseHeight + 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(
                                    alpha: 0.25 + (_pulseController.value * 0.2),
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    // Architectural House canvas
                    Container(
                      width: houseWidth,
                      height: houseHeight,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRank1
                              ? const Color(0xFFFFD700)
                              : member.isCurrentUser
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white.withValues(alpha: 0.1),
                          width: isRank1 || member.isCurrentUser ? 1.8 : 0.8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          painter: HouseMasterPainter(
                            day: member.level,
                            palette: palette,
                            isPresident: member.isPrestigeSovereign,
                            lightsOn: true,
                          ),
                        ),
                      ),
                    ),

                    // Floating Crown for Rank 1
                    if (isRank1)
                      Positioned(
                        top: -24,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final offsetY = math.sin(_pulseController.value * math.pi) * 4;
                            return Transform.translate(
                              offset: Offset(0, -offsetY),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('👑', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 4),
                                    Text(
                                      '#1 SOVEREIGN',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Resident Avatar stationed outside the house
                    Positioned(
                      bottom: -10,
                      left: isEven ? 8 : null,
                      right: !isEven ? 8 : null,
                      child: GestureDetector(
                        onTap: () {
                          PocketCitadelAttackPage.openForUser(
                            context,
                            userId: member.userId,
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isRank1
                                  ? const Color(0xFFFFD700)
                                  : Colors.white70,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: VectorAvatarWidget(
                              config: member.avatarConfig,
                              size: 44,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isEven) ...[
                const SizedBox(width: 12),
                _buildRankBadge(member, rank),
              ],
            ],
          ),

          // Stepping Trail connector stones
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomPaint(
                size: const Size(60, 36),
                painter: _SteppingPathPainter(isEven: isEven),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(PocketRankedUser member, int rank) {
    final isRank1 = rank == 1;
    final isRank2 = rank == 2;
    final isRank3 = rank == 3;

    Color badgeColor = const Color(0xFF64748B);
    String medal = '#$rank';
    if (isRank1) {
      badgeColor = const Color(0xFFFFD700);
      medal = '🥇 1st';
    } else if (isRank2) {
      badgeColor = const Color(0xFFE2E8F0);
      medal = '🥈 2nd';
    } else if (isRank3) {
      badgeColor = const Color(0xFFCD7F32);
      medal = '🥉 3rd';
    }

    return Column(
      crossAxisAlignment:
          rank % 2 == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // Primary Rank badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: badgeColor, width: 1.0),
          ),
          child: Text(
            medal,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ),

        // In Mates Mode: Display Global Rank Badge as well!
        if (!_isWorldMode)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                '🌐 #${member.globalRank}',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E5FF),
                ),
              ),
            ),
          ),

        const SizedBox(height: 6),
        // Name & Score
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Column(
            crossAxisAlignment: rank % 2 == 0
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: member.isCurrentUser
                      ? const Color(0xFFFFD700)
                      : Colors.white,
                  fontWeight: member.isCurrentUser
                      ? FontWeight.w900
                      : FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '⚡ ${member.pocketScore} Pts',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (member.isPrestigeSovereign)
                Text(
                  '⭐ P-${member.prestigeStars}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFEA79),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingUserRankPill() {
    final myUser = _myUserIndex != null ? _rankedUsers[_myUserIndex!] : null;
    final myRank = _isWorldMode
        ? (myUser?.globalRank ?? _myUserIndex! + 1)
        : (myUser?.matesRank ?? _myUserIndex! + 1);

    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: _scrollToMyRank,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$myRank',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isWorldMode ? 'Your World Rank' : 'Your Mates Rank',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '⚡ ${myUser?.pocketScore ?? 0} Pts • Level ${myUser?.level ?? 1}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.navigation_rounded,
                      size: 13,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Jump to Me',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏔️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            _isWorldMode ? 'Ranking Trail is Empty' : 'No Mates Yet',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isWorldMode
                ? 'Be the first pioneer to claim Rank 1!'
                : 'Connect with friends to challenge their rankings!',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.amber, size: 36),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
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
    );
  }
}

/// 🌿 Ambient Nature CustomPainter for subtle grassy route atmosphere
class _TrailAmbientNaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grassPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Scattered ambient hills/foliage
    for (double y = 80; y < size.height; y += 220) {
      final cx = (y % 440 == 80) ? size.width * 0.15 : size.width * 0.85;
      canvas.drawCircle(Offset(cx, y), 35, grassPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🛤️ Stepping Path Connector between Houses
class _SteppingPathPainter extends CustomPainter {
  final bool isEven;

  _SteppingPathPainter({required this.isEven});

  @override
  void paint(Canvas canvas, Size size) {
    final stonePaint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final startX = isEven ? size.width * 0.3 : size.width * 0.7;
    final endX = isEven ? size.width * 0.7 : size.width * 0.3;

    for (int i = 0; i < 4; i++) {
      final t = (i + 1) / 5;
      final x = startX + (endX - startX) * t;
      final y = size.height * t;
      canvas.drawCircle(Offset(x, y), 4.5, glowPaint);
      canvas.drawCircle(Offset(x, y), 3.5, stonePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteppingPathPainter oldDelegate) =>
      oldDelegate.isEven != isEven;
}
