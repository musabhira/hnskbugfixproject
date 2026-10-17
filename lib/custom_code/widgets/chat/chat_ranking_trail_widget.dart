import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart' show HousePalette;
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/english_tasks_master_hub.dart' show HouseMasterPainter;
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';

/// 🏆 Member data model for the Chat Ranking Trail
class ChatTrailMember {
  final String userId;
  final String name;
  final String? profileImageUrl;
  final int pocketScore;
  final int level;
  final int globalRank;
  final VectorAvatarConfig avatarConfig;
  final bool isCurrentUser;
  final bool isRobot;

  ChatTrailMember({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.pocketScore,
    required this.level,
    this.globalRank = 1,
    required this.avatarConfig,
    this.isCurrentUser = false,
    this.isRobot = false,
  });
}

/// 🏰 Chat Ranking Trail Widget
/// A vertical route showing houses, avatars, names, and pocket scores of group
/// or personal chat members in rank order (Top 1 Leader with Golden Crown).
/// Tapping any house opens their Citadel Attack / Profile screen.
class ChatRankingTrailWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final List<Map<String, dynamic>>? initialMembers;

  const ChatRankingTrailWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    this.initialMembers,
  });

  @override
  State<ChatRankingTrailWidget> createState() => _ChatRankingTrailWidgetState();
}

class _ChatRankingTrailWidgetState extends State<ChatRankingTrailWidget>
    with SingleTickerProviderStateMixin {
  List<ChatTrailMember> _rankedMembers = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final AnimationController _pulseController;

  bool get _isPersonalChat => widget.groupId.startsWith('p:');

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadRankingData();
  }

  @override
  void didUpdateWidget(covariant ChatRankingTrailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      _loadRankingData();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadRankingData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isPersonalChat) {
        await _loadPersonalChatMembers();
      } else {
        await _loadGroupMembers();
      }
    } catch (e) {
      debugPrint('Error loading ranking trail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load ranking trail.';
        });
      }
    }
  }

  Future<void> _loadPersonalChatMembers() async {
    final mateUserId = widget.groupId.substring(2);
    final supabase = SupaFlow.client;

    final List<ChatTrailMember> members = [];

    // 1. Current user
    try {
      final myProfileRes = await supabase
          .from('profile')
          .select('id, name, profile_image_url, pocket_score, learning_points, xp, level, learning_day, avatar_config')
          .eq('user_id', widget.currentUserId)
          .maybeSingle();

      final myName = myProfileRes?['name']?.toString() ?? 'You';
      final myScore = (myProfileRes?['pocket_score'] as num?)?.toInt() ??
          (myProfileRes?['learning_points'] as num?)?.toInt() ??
          (myProfileRes?['xp'] as num?)?.toInt() ??
          25;
      final myLevel = (myProfileRes?['level'] as num?)?.toInt() ??
          (myProfileRes?['learning_day'] as num?)?.toInt() ??
          1;

      members.add(ChatTrailMember(
        userId: widget.currentUserId,
        name: myName,
        profileImageUrl: myProfileRes?['profile_image_url']?.toString(),
        pocketScore: myScore,
        level: myLevel.clamp(1, 90),
        avatarConfig: VectorAvatarConfig.getEvolutionAvatarForStage(myLevel.clamp(1, 90)),
        isCurrentUser: true,
      ));
    } catch (e) {
      debugPrint('Error loading current user profile: $e');
    }

    // 2. Mate user
    try {
      if (PocketPresidentService.isPresidentId(mateUserId)) {
        members.add(ChatTrailMember(
          userId: mateUserId,
          name: 'The President',
          pocketScore: 9999,
          level: 90,
          avatarConfig: VectorAvatarConfig.getEvolutionAvatarForStage(90),
          isRobot: true,
        ));
      } else if (PocketRobotService.isRobotId(mateUserId)) {
        final robot = PocketRobotService.getRobotById(mateUserId);
        final rLevel = robot?.level ?? 10;
        members.add(ChatTrailMember(
          userId: mateUserId,
          name: robot?.name ?? widget.groupName,
          pocketScore: rLevel * 30,
          level: rLevel.clamp(1, 90),
          avatarConfig: VectorAvatarConfig.getEvolutionAvatarForStage(rLevel.clamp(1, 90)),
          isRobot: true,
        ));
      } else {
        final mateProfileRes = await supabase
            .from('profile')
            .select('id, name, profile_image_url, pocket_score, learning_points, xp, level, learning_day, avatar_config')
            .eq('user_id', mateUserId)
            .maybeSingle();

        final mateName = mateProfileRes?['name']?.toString() ?? widget.groupName;
        final mateScore = (mateProfileRes?['pocket_score'] as num?)?.toInt() ??
            (mateProfileRes?['learning_points'] as num?)?.toInt() ??
            (mateProfileRes?['xp'] as num?)?.toInt() ??
            20;
        final mateLevel = (mateProfileRes?['level'] as num?)?.toInt() ??
            (mateProfileRes?['learning_day'] as num?)?.toInt() ??
            1;

        members.add(ChatTrailMember(
          userId: mateUserId,
          name: mateName,
          profileImageUrl: mateProfileRes?['profile_image_url']?.toString(),
          pocketScore: mateScore,
          level: mateLevel.clamp(1, 90),
          avatarConfig: VectorAvatarConfig.getEvolutionAvatarForStage(mateLevel.clamp(1, 90)),
        ));
      }
    } catch (e) {
      debugPrint('Error loading mate profile: $e');
    }

    // Sort descending by score
    members.sort((a, b) => b.pocketScore.compareTo(a.pocketScore));

    if (mounted) {
      setState(() {
        _rankedMembers = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGroupMembers() async {
    final supabase = SupaFlow.client;
    final List<ChatTrailMember> members = [];

    // Use initialMembers if provided and not empty
    List rawMembers = widget.initialMembers ?? [];
    if (rawMembers.isEmpty) {
      final response = await supabase.from('group_members').select('''
            *,
            profile:profile!profile_id(name, profile_image_url, pocket_score, learning_points, xp, learning_day, level, stage, avatar_config)
          ''').eq('group_id', widget.groupId).eq('is_active', true);
      rawMembers = response as List;
    }

    for (final m in rawMembers) {
      final uid = m['user_id']?.toString() ?? '';
      if (uid.isEmpty) continue;

      dynamic profileData = m['profile'];
      if (profileData is List && profileData.isNotEmpty) {
        profileData = profileData.first;
      }
      final Map<String, dynamic> p = (profileData is Map)
          ? Map<String, dynamic>.from(profileData)
          : {};

      final name = p['name']?.toString() ?? m['name']?.toString() ?? 'Mate';
      final score = (p['pocket_score'] as num?)?.toInt() ??
          (p['learning_points'] as num?)?.toInt() ??
          (p['xp'] as num?)?.toInt() ??
          0;
      final level = (p['level'] as num?)?.toInt() ??
          (p['learning_day'] as num?)?.toInt() ??
          1;

      members.add(ChatTrailMember(
        userId: uid,
        name: name,
        profileImageUrl: p['profile_image_url']?.toString(),
        pocketScore: score > 0 ? score : (level * 20),
        level: level.clamp(1, 90),
        avatarConfig: VectorAvatarConfig.getEvolutionAvatarForStage(level.clamp(1, 90)),
        isCurrentUser: uid == widget.currentUserId,
      ));
    }

    // If English Hub group has few members, complement with active learners from profile table
    final isHub = widget.groupId.toLowerCase().contains('english') ||
        widget.groupId.toLowerCase().contains('hub');
    if (members.length < 3 && isHub) {
      try {
        final topLearners = await supabase
            .from('profile')
            .select('user_id, name, profile_image_url, pocket_score, learning_points, xp, level, learning_day')
            .order('pocket_score', ascending: false)
            .limit(10);

        for (final row in (topLearners as List)) {
          final uid = row['user_id']?.toString() ?? '';
          if (uid.isEmpty || members.any((m) => m.userId == uid)) continue;
          final name = row['name']?.toString() ?? 'Learner';
          final score = (row['pocket_score'] as num?)?.toInt() ??
              (row['learning_points'] as num?)?.toInt() ??
              (row['xp'] as num?)?.toInt() ??
              50;
          final level = (row['level'] as num?)?.toInt() ??
              (row['learning_day'] as num?)?.toInt() ??
              1;

          members.add(ChatTrailMember(
            userId: uid,
            name: name,
            profileImageUrl: row['profile_image_url']?.toString(),
            pocketScore: score,
            level: level.clamp(1, 90),
            avatarConfig: VectorAvatarConfig.getEvolutionAvatarForStage(level.clamp(1, 90)),
            isCurrentUser: uid == widget.currentUserId,
          ));
        }
      } catch (e) {
        debugPrint('English Hub top learners fetch note: $e');
      }
    }

    // Sort descending by Pocket Score
    members.sort((a, b) => b.pocketScore.compareTo(a.pocketScore));

    // Resolve Global Rank for each member
    final finalized = <ChatTrailMember>[];
    for (int i = 0; i < members.length; i++) {
      final m = members[i];
      final gRank = await PocketRankingService.fetchUserGlobalRank(m.userId, m.pocketScore);
      finalized.add(ChatTrailMember(
        userId: m.userId,
        name: m.name,
        profileImageUrl: m.profileImageUrl,
        pocketScore: m.pocketScore,
        level: m.level,
        globalRank: gRank,
        avatarConfig: m.avatarConfig,
        isCurrentUser: m.isCurrentUser,
        isRobot: m.isRobot,
      ));
    }

    if (mounted) {
      setState(() {
        _rankedMembers = finalized;
        _isLoading = false;
      });
    }
  }

  void _onMemberTapped(ChatTrailMember member) {
    HapticFeedback.mediumImpact();
    PocketCitadelAttackPage.openForUser(
      context,
      userId: member.userId,
      targetName: member.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFFD700)),
            SizedBox(height: 12),
            Text(
              'Loading Mates Trail...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.amber, size: 38),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadRankingData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_rankedMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏰', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'No Mates Found Yet',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start chatting and completing English missions to populate the ranking trail!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      color: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF101720),
      onRefresh: _loadRankingData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Header Overview Banner
          SliverToBoxAdapter(
            child: _buildTrailTopBanner(),
          ),

          // 2. Stepping Trail List
          SliverPadding(
            padding: const EdgeInsets.only(top: 12, bottom: 64),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final member = _rankedMembers[index];
                  final rank = index + 1;
                  final isLast = index == _rankedMembers.length - 1;
                  return _buildMemberTrailNode(
                    member: member,
                    rank: rank,
                    isLast: isLast,
                    screenWidth: screenWidth,
                  );
                },
                childCount: _rankedMembers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌟 Top Banner showing leader stats & rules
  Widget _buildTrailTopBanner() {
    final leader = _rankedMembers.isNotEmpty ? _rankedMembers.first : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Leader Avatar with Crown
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: leader != null
                        ? leader.avatarConfig
                        : VectorAvatarConfig.getEvolutionAvatarForStage(1),
                    size: 48,
                    showAura: true,
                  ),
                ),
              ),
              const Positioned(
                top: -12,
                child: Text('👑', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Leader Details & Info
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
                        '#1 REIGNING KING',
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
                      '${_rankedMembers.length} Mates on Trail',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  leader != null ? leader.name : 'Leader',
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
                      '${leader?.pocketScore ?? 0} Pocket Pts',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                      'Level ${leader?.level ?? 1}',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
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

  /// 🛤️ Renders a single Member Node along the vertical trail
  Widget _buildMemberTrailNode({
    required ChatTrailMember member,
    required int rank,
    required bool isLast,
    required double screenWidth,
  }) {
    final isRank1 = rank == 1;
    final isRank2 = rank == 2;
    final isRank3 = rank == 3;

    // Alternating horizontal offset for natural winding road feel
    final bool isEven = rank % 2 == 0;
    final double horizontalPadding = screenWidth > 380 ? 20.0 : 12.0;

    // Palette & House dimensions
    final palette = HousePalette.presets[(member.level - 1) % HousePalette.presets.length];
    final double houseWidth = (screenWidth * 0.48).clamp(170.0, 210.0);
    const double houseHeight = 110.0;

    final rankColor = isRank1
        ? const Color(0xFFFFD700)
        : (isRank2
            ? const Color(0xFFE2E8F0)
            : (isRank3 ? const Color(0xFFF97316) : const Color(0xFF64748B)));

    final rankBadgeText = isRank1
        ? '👑 #1'
        : (isRank2 ? '🥈 #2' : (isRank3 ? '🥉 #3' : '#$rank'));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          child: Row(
            textDirection: isEven ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. The House & Resident Avatar
              GestureDetector(
                onTap: () => _onMemberTapped(member),
                child: SizedBox(
                  width: houseWidth,
                  height: houseHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // House Aura for Rank 1
                      if (isRank1)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(
                                        alpha: 0.25 + (_pulseController.value * 0.25),
                                      ),
                                      blurRadius: 20 + (_pulseController.value * 10),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // House Canvas
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size(houseWidth, houseHeight),
                            painter: HouseMasterPainter(
                              day: member.level,
                              palette: palette,
                              isPresident: (member.level >= 90),
                              lightsOn: true,
                            ),
                          ),
                        ),
                      ),

                      // Crown for Rank 1 on top of the house
                      if (isRank1)
                        Positioned(
                          top: -16,
                          left: (houseWidth / 2) - 15,
                          child: const Text('👑', style: TextStyle(fontSize: 24)),
                        ),

                      // Resident Avatar Guardian Chip (bottom-right of house)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            border: Border.all(
                              color: rankColor,
                              width: 1.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: VectorAvatarWidget(
                              config: member.avatarConfig,
                              size: 28,
                              showAura: false,
                            ),
                          ),
                        ),
                      ),

                      // Level Pill on top-left of house
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Text(
                            'Lvl ${member.level}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Member Info Pill & Attack Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _onMemberTapped(member),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRank1
                          ? const Color(0xFF1E2530)
                          : const Color(0xFF131C24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isRank1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                            : (member.isCurrentUser
                                ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
                                : Colors.white12),
                        width: isRank1 || member.isCurrentUser ? 1.4 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rank Badge & Current User Marker
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: rankColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: rankColor, width: 0.8),
                              ),
                              child: Text(
                                rankBadgeText,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: rankColor,
                                ),
                              ),
                            ),
                            // Global Rank Badge
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
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
                            if (member.isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'YOU',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Name
                        Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Pocket Score
                        Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              '${member.pocketScore} Pts',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tap to Attack / Inspect Action Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚔️', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                member.isCurrentUser ? 'My Citadel' : 'View Citadel',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
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
            ],
          ),
        ),

        // 3. Connector Path to Next Node
        if (!isLast)
          CustomPaint(
            size: const Size(double.infinity, 36),
            painter: _TrailConnectorPainter(isEven: isEven),
          ),
      ],
    );
  }
}

/// 🎨 Painter to draw a subtle curved dashed connector between nodes along the route
class _TrailConnectorPainter extends CustomPainter {
  final bool isEven;
  const _TrailConnectorPainter({required this.isEven});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final startX = isEven ? size.width * 0.70 : size.width * 0.30;
    final endX = isEven ? size.width * 0.30 : size.width * 0.70;

    final path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(
      startX,
      size.height * 0.5,
      endX,
      size.height * 0.5,
      endX,
      size.height,
    );

    // Draw dashed path
    _drawDashedPath(canvas, path, paint, 6.0, 4.0);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashWidth, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrailConnectorPainter oldDelegate) =>
      oldDelegate.isEven != isEven;
}
