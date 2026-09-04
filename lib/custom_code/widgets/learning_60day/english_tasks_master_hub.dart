import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/stage_peer_matchmaker.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_learning_hub_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/nft_trading_card_dialog.dart';
import 'pocket_battle_arena_page.dart';
import 'pocket_world_street_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_arsenal_store_modal.dart';
import 'day90_vip_master_card_dialog.dart';

/// 🎯 Model for Minimal Target Roadmaps (Audio Requirement)
class TargetMilestoneItem {
  final int stageNumber;
  final String title;
  final String rangeText;
  final int targetDay;
  final String houseStage;
  final String houseEmoji;
  final String rewardSummary;
  final String defenseSummary;
  final Color themeColor;

  const TargetMilestoneItem({
    required this.stageNumber,
    required this.title,
    required this.rangeText,
    required this.targetDay,
    required this.houseStage,
    required this.houseEmoji,
    required this.rewardSummary,
    required this.defenseSummary,
    required this.themeColor,
  });
}

final List<TargetMilestoneItem> kTargetMilestones = [
  const TargetMilestoneItem(
    stageNumber: 1,
    title: 'Target 1',
    rangeText: 'Days 1–7',
    targetDay: 7,
    houseStage: 'Wooden Cabin',
    houseEmoji: '🌱',
    rewardSummary: '+50 Coins • Beginner Pass',
    defenseSummary: '2 Shield Trap Qs',
    themeColor: Color(0xFF10B981),
  ),
  const TargetMilestoneItem(
    stageNumber: 2,
    title: 'Target 2',
    rangeText: 'Days 8–20',
    targetDay: 20,
    houseStage: 'Brick Villa',
    houseEmoji: '🏡',
    rewardSummary: '+150 Coins • Habit Anchor',
    defenseSummary: 'Army Knight Guard',
    themeColor: Color(0xFF38BDF8),
  ),
  const TargetMilestoneItem(
    stageNumber: 3,
    title: 'Target 3',
    rangeText: 'Days 21–45',
    targetDay: 45,
    houseStage: 'Stone Fortress',
    houseEmoji: '🏰',
    rewardSummary: '+300 Coins • Silver Knight',
    defenseSummary: 'Iron Dome Shield Core',
    themeColor: Color(0xFFA855F7),
  ),
  const TargetMilestoneItem(
    stageNumber: 4,
    title: 'Target 4',
    rangeText: 'Days 46–70',
    targetDay: 70,
    houseStage: 'Imperial Manor',
    houseEmoji: '🏛️',
    rewardSummary: '+600 Coins • Gold Sovereign',
    defenseSummary: '15 Question Shield Traps',
    themeColor: Color(0xFFF59E0B),
  ),
  const TargetMilestoneItem(
    stageNumber: 5,
    title: 'Target 5',
    rangeText: 'Days 71–89',
    targetDay: 89,
    houseStage: 'Cyber Citadel',
    houseEmoji: '💎',
    rewardSummary: '+1000 Coins • Royal Platoon',
    defenseSummary: 'Titanium Dome + 22 Qs',
    themeColor: Color(0xFFEC4899),
  ),
  const TargetMilestoneItem(
    stageNumber: 6,
    title: 'Target 6 (DAY 90)',
    rangeText: 'Day 90 Master',
    targetDay: 90,
    houseStage: 'Supreme Empire',
    houseEmoji: '👑',
    rewardSummary: 'VIP Limousine + 2 Armed Escorts + NFT Card',
    defenseSummary: 'Max 25 Q Shield + Citadel',
    themeColor: Color(0xFFFFD700),
  ),
];

/// 🎮 90-Day Full English Transformation Gamified Adventure Map
/// Super Mario World / Candy Crush / Duolingo style snaking level progression trail (Days 1–90)
class EnglishTasksMasterHubPage extends StatefulWidget {
  final String? userId;

  const EnglishTasksMasterHubPage({super.key, this.userId});

  @override
  State<EnglishTasksMasterHubPage> createState() =>
      _EnglishTasksMasterHubPageState();
}

class _EnglishTasksMasterHubPageState extends State<EnglishTasksMasterHubPage>
    with SingleTickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bobController;

  bool _isLoading = true;
  UserLearningProgress? _progress;
  VectorAvatarConfig? _customUserAvatar;
  final int _totalDays = 90;

  // Spacing & node dimensions
  static const double _nodeSpacingY = 135.0;
  static const double _topPadding = 200.0;
  static const double _bottomPadding = 320.0;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _loadData();
  }

  @override
  void dispose() {
    _bobController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final prog = await Learning60DayService().fetchProgress(uid);
    Map<String, dynamic>? profileData;
    try {
      profileData = await _supabase
          .from('profiles')
          .select('avatar_config')
          .eq('id', uid)
          .maybeSingle();
    } catch (_) {}

    VectorAvatarConfig? customConfig;
    if (profileData != null && profileData['avatar_config'] != null) {
      try {
        final map = Map<String, dynamic>.from(profileData['avatar_config']);
        customConfig = VectorAvatarConfig.fromMap(map);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _progress = prog;
        _customUserAvatar = customConfig;
        _isLoading = false;
      });

      // Auto-scroll to current active day & check daily consistency
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _scrollToDay(prog.currentDay, animate: true);

        // 🚨 Check Daily Consistency (User Audio Directive: Consistency loss / focus loss downgrade)
        final consistencyRes = await PocketFortressDefenseService.checkDailyConsistency(
          prog.currentDay,
          prog.streakDays,
        );
        if (consistencyRes.didDowngrade && mounted) {
          _showConsistencyLossDialog(consistencyRes);
        }
      });
    }
  }

  /// Returns the avatar configuration tailored to the user's progress:
  /// Day 1 uses their personal chosen avatar (if customized) or beginner avatar,
  /// and subsequent days evolve along the 90-day master progression!
  VectorAvatarConfig _getAvatarForDay(int day) {
    if (day == 1 && _customUserAvatar != null) {
      return _customUserAvatar!;
    }
    return VectorAvatarConfig.getEvolutionAvatarForStage(day);
  }

  double _getNodeX(int day, double screenWidth) {
    final center = screenWidth / 2;
    final amplitude = (screenWidth - 140) / 2;
    // S-curve oscillation
    final wave = math.sin((day - 1) * 0.72);
    return center + (wave * amplitude);
  }

  double _getNodeY(int day) {
    return _topPadding + ((day - 1) * _nodeSpacingY);
  }

  void _scrollToDay(int day, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final targetY = _getNodeY(day) - 280.0;
    final clampedY = targetY.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        clampedY,
        duration: const Duration(milliseconds: 950),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedY);
    }
  }

  void _openAvatarCard(int day) {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final config = _getAvatarForDay(day);
    NftTradingCardDialog.show(
      context,
      day: day,
      config: config,
      userId: uid,
      isOwner: true,
    );
  }

  Future<void> _completeTodayTasks() async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid == null || _progress == null) return;

    HapticFeedback.heavyImpact();
    for (var task in _progress!.todayTasks) {
      await Learning60DayService().completeTask(userId: uid, taskId: task.id);
    }

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Today\'s English Missions Complete! +70 Pocket Score Awarded.',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMilestoneRewardsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    '90-Day Milestone Rewards Showcase',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Exclusive trophies, visual unlocks & certificates earned along your English journey:',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 18),
              _buildRewardTile(
                emoji: '🎯',
                title: 'Day 21 Habit Anchor Lock',
                desc:
                    'Unlocks permanent English habit status, Red Anchor Verified Tick, and Shadow Wolf Cyber-Visor NFT Avatar (#MATE-DAY21).',
                borderCol: const Color(0xFFFF5252),
                avatarConfig:
                    LearningMilestoneStage.getStageForDay(21).avatarReward,
              ),
              const SizedBox(height: 10),
              _buildRewardTile(
                emoji: '🥈',
                title: 'Day 30 Silver Knight Shield',
                desc:
                    'Unlocks Metallic Silver Profile Theme, Silver Platinum Verified Tick, and Retro Arcade Ape Crown NFT (#MATE-DAY30).',
                borderCol: const Color(0xFFE2E8F0),
                avatarConfig:
                    LearningMilestoneStage.getStageForDay(30).avatarReward,
              ),
              const SizedBox(height: 10),
              _buildRewardTile(
                emoji: '👑',
                title: 'Day 60 Gold Sovereign Crown',
                desc:
                    'Unlocks 24K Gold Sovereign Profile Theme, Pure Gold Verified Tick, and Celestial Lion Emperor NFT (#MATE-DAY60).',
                borderCol: const Color(0xFFFFD700),
                avatarConfig:
                    LearningMilestoneStage.getStageForDay(60).avatarReward,
              ),
              const SizedBox(height: 10),
              _buildRewardTile(
                emoji: '💎',
                title: 'Day 90 Supreme Grand Master',
                desc:
                    'The highest English honor. Unlocks Obsidian Holographic Diamond Theme, Cyan Radiant Tick, and Supreme Astral Cosmic Dragon NFT (#MATE-DAY90-DRAGON).',
                borderCol: const Color(0xFF00E5FF),
                avatarConfig:
                    LearningMilestoneStage.getStageForDay(90).avatarReward,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardTile({
    required String emoji,
    required String title,
    required String desc,
    required Color borderCol,
    VectorAvatarConfig? avatarConfig,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161928),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Row(
        children: [
          if (avatarConfig != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderCol, width: 1.5),
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: avatarConfig,
                    size: 44,
                    showAura: false,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style:
                      GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelMissionDialog(int day) {
    HapticFeedback.lightImpact();
    final prog =
        _progress ?? UserLearningProgress(lastActiveDate: DateTime.now());
    final isCurrent = day == prog.currentDay;
    final isCompleted = day < prog.currentDay;
    final lesson = EnglishCurriculumLesson.getLessonForDay(day);
    final stage = LearningMilestoneStage.getStageForDay(day);
    final avatarConfig = _getAvatarForDay(day);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13172A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFFFFFC00)
                  : (isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.18)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCurrent
                        ? const Color(0xFFFFFC00)
                        : const Color(0xFF10B981))
                    .withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Header Deck with Badge & Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: stage.gradientColors),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'LEVEL $day • ${stage.fluencyTier.toUpperCase()}',
                        style: GoogleFonts.outfit(
                          color: stage.buttonTextColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(3, (i) {
                        return Icon(
                          Icons.star_rounded,
                          size: 22,
                          color: isCompleted
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Lesson Title & Avatar Preview
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _openAvatarCard(day);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.7),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: VectorAvatarWidget(
                            config: avatarConfig,
                            size: 48,
                            showAura: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            lesson.focusArea,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFFC00),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mission Tasks Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F36),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _buildMissionRow(
                        icon: Icons.record_voice_over_rounded,
                        color: const Color(0xFF10B981),
                        title: '4-Mate Peer Voice Chat',
                        subtitle: lesson.peerChatMission,
                        isDone: isCompleted,
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      _buildMissionRow(
                        icon: Icons.mic_rounded,
                        color: const Color(0xFF38BDF8),
                        title: 'Daily Speaking Drill',
                        subtitle: lesson.speakingDrill,
                        isDone: isCompleted,
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      _buildMissionRow(
                        icon: Icons.psychology_rounded,
                        color: const Color(0xFFFFD700),
                        title: 'Grammar & Thought Mechanics',
                        subtitle: lesson.grammarConcept,
                        isDone: isCompleted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Rewards Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded,
                              color: Color(0xFFFFFC00), size: 16),
                          const SizedBox(width: 4),
                          Text('+${lesson.xpReward} XP',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_rounded,
                              color: Color(0xFF38BDF8), size: 16),
                          const SizedBox(width: 4),
                          Text('${lesson.targetMinutes} Mins',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Color(0xFFFF007A), size: 16),
                          const SizedBox(width: 4),
                          Text('Evolved NFT',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                if (isCurrent) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const StagePeerMatchmakerPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded,
                              color: Colors.black, size: 20),
                          label: Text(
                            'START MISSION 🎮',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _completeTodayTasks();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ] else if (isCompleted) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EnglishLearningHubPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.replay_rounded,
                          color: Color(0xFF10B981), size: 18),
                      label: Text(
                        'Replay Mission Review (Completed ⭐⭐⭐)',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded,
                            color: Colors.white54, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Locked • Complete Day ${prog.currentDay} to Unlock',
                          style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissionRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isDone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isDone)
          const Padding(
            padding: EdgeInsets.only(left: 6, top: 4),
            child: Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 18),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prog =
        _progress ?? UserLearningProgress(lastActiveDate: DateTime.now());
    final screenWidth = MediaQuery.of(context).size.width;
    final totalMapHeight =
        _topPadding + (_totalDays * _nodeSpacingY) + _bottomPadding;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
          : Stack(
              children: [
                // 1. The Scrollable Game World Map
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: screenWidth,
                    height: totalMapHeight,
                    child: Stack(
                      children: [
                        // Background Biomes & Curved Trail Road
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _AdventureMapRoadPainter(
                              totalDays: _totalDays,
                              currentDay: prog.currentDay,
                              screenWidth: screenWidth,
                              nodeSpacingY: _nodeSpacingY,
                              topPadding: _topPadding,
                            ),
                          ),
                        ),

                        // Biome Zone Banners & Scenery Props
                        ..._buildBiomeProps(screenWidth),

                        // 🐾 Minimal Flame Animal Cards in Map Space (Audio Directive!)
                        for (int day = 1; day <= _totalDays; day++)
                          _buildMapMiniAnimalCard(day, screenWidth, prog.currentDay),

                        // Interactive 3D Level Nodes (Days 1 to 90)
                        for (int day = 1; day <= _totalDays; day++)
                          _buildLevelNode(day, screenWidth, prog.currentDay),

                        // Bouncing Animated Character Avatar at Current Level
                        _buildAnimatedAvatar(screenWidth, prog.currentDay),
                      ],
                    ),
                  ),
                ),

                // 2. Sticky Glassmorphism Top HUD (Without Back button on tab navigation!)
                _buildTopHUD(prog),

                // 3. ⚔️ Floating Action Buttons (Attack Arena & Day Target)
                // Left: ⚔️ Attack / 10 Games Arena Launcher
                Positioned(
                  left: 18,
                  bottom: 24,
                  child: FloatingActionButton.extended(
                    heroTag: 'target_page_attack_button',
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      final rival = PocketNeighbor(
                        id: 'rival_fortress',
                        name: 'Lord Sterling',
                        day: prog.currentDay,
                        streak: prog.streakDays + 3,
                        rank: 'Rival Fortress',
                        paletteId: 'regal_amethyst',
                        statusMessage: 'Can you breach my English gates?',
                        hasActiveShield: true,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PocketBattleArenaPage(
                            neighbor: rival,
                            userDay: prog.currentDay,
                            userStreak: prog.streakDays,
                          ),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFFDC2626),
                    elevation: 8,
                    icon: const Text('⚔️', style: TextStyle(fontSize: 18)),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ATTACK',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                          ),
                          child: const Text(
                            '10 GAMES',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: 🎯 Jump to Today Button (Clean, no broken Lottie)
                Positioned(
                  right: 18,
                  bottom: 24,
                  child: FloatingActionButton.extended(
                    heroTag: 'target_page_jump_today_button',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _scrollToDay(prog.currentDay, animate: true);
                    },
                    backgroundColor: const Color(0xFFFFFC00),
                    elevation: 6,
                    icon: const Icon(Icons.gps_fixed_rounded,
                        color: Colors.black, size: 20),
                    label: Text(
                      'DAY ${prog.currentDay}',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopHUD(UserLearningProgress prog) {
    final completedCount = (prog.currentDay - 1).clamp(0, 90);
    final totalStars = completedCount * 3;
    final canPop = Navigator.of(context).canPop();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 6,
          bottom: 10,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1524).withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Only show back button if pushed onto navigator stack, NOT on root bottom tab!
                if (canPop) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 2),
                ],

                // Streak Capsule
                _buildHudCapsule(
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF5722),
                  label: '${prog.streakDays}d',
                ),
                const SizedBox(width: 6),

                // Stars Capsule
                _buildHudCapsule(
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFD700),
                  label: '$totalStars ⭐',
                ),
                const SizedBox(width: 6),

                // Score Capsule
                _buildHudCapsule(
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF00E5FF),
                  label: '${prog.totalPoints} XP',
                ),

                const Spacer(),

                // 🏪 Arsenal Store Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    PocketArsenalStoreModal.show(
                      context,
                      currentDay: prog.currentDay,
                      onPurchased: () => setState(() {}),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏪', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'Store',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Rewards Trophy Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showMilestoneRewardsModal();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        Text(
                          'Trophies',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFC00),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🎯 Minimal Horizontal Target Milestones Bar (Audio Requirement!)
            _buildTargetMilestonesStrip(prog),
          ],
        ),
      ),
    );
  }

  /// 🎯 Minimal Horizontal Target Milestones Strip (Audio Requirement!)
  Widget _buildTargetMilestonesStrip(UserLearningProgress prog) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kTargetMilestones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final item = kTargetMilestones[index];
          final isUnlocked = prog.currentDay >= item.targetDay;
          final isCurrentTarget = prog.currentDay <= item.targetDay &&
              (index == 0 || prog.currentDay > kTargetMilestones[index - 1].targetDay);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (item.stageNumber == 6) {
                Day90VipMasterCardDialog.show(
                  context,
                  userDay: prog.currentDay,
                  isPreview: prog.currentDay < 90,
                );
              } else {
                _showTargetStagePreviewDialog(item, prog.currentDay);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentTarget
                    ? item.themeColor.withValues(alpha: 0.20)
                    : (isUnlocked
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrentTarget
                      ? item.themeColor
                      : (isUnlocked ? const Color(0xFF10B981) : Colors.white12),
                  width: isCurrentTarget ? 1.4 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.houseEmoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.outfit(
                              color: isCurrentTarget
                                  ? item.themeColor
                                  : (isUnlocked ? const Color(0xFF10B981) : Colors.white70),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUnlocked ? '✓' : (isCurrentTarget ? '🔥' : '🔒'),
                            style: const TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      Text(
                        '${item.houseStage} • ${item.defenseSummary}',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🎯 Milestone Target Detail & House Growth Preview Dialog
  void _showTargetStagePreviewDialog(TargetMilestoneItem item, int currentDay) {
    final isUnlocked = currentDay >= item.targetDay;
    final stageAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(item.targetDay);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: item.themeColor, width: 1.5),
        ),
        title: Row(
          children: [
            Text(item.houseEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.title.toUpperCase()} (${item.rangeText})',
                    style: GoogleFonts.outfit(
                      color: item.themeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    isUnlocked ? '✅ Milestone Achieved' : '🎯 Target In Progress',
                    style: TextStyle(
                      color: isUnlocked ? const Color(0xFF10B981) : Colors.amber,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: item.themeColor, width: 2),
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(config: stageAvatar, size: 68),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏡 House Stage: ${item.houseStage}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('🛡️ Defense Unlock: ${item.defenseSummary}', style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  Text('🪙 Rewards: ${item.rewardSummary}', style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ഈ ടാർഗറ്റ് പൂർത്തിയാക്കുമ്പോൾ നിങ്ങളുടെ വീടിന്റെ ഘടനയും ലേണിങ് അവതാറും വളരുകയും കൂടുതൽ ഡിഫൻസ് ട്രാപ്പുകൾ അൺലോക്ക് ആവുകയും ചെയ്യും.',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: item.themeColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('GOT IT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 🚨 Consistency / Focus Loss Dialog (Audio Requirement!)
  void _showConsistencyLossDialog(ConsistencyCheckResult res) {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        title: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'CONSISTENCY DROPPED!',
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${res.previousDay} ➔ Day ${res.newDay}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    res.message,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              res.messageMalayalam,
              style: GoogleFonts.inter(
                color: const Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFC00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'REGAIN FOCUS 🎯',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudCapsule({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(int day, double screenWidth, int currentDay) {
    final x = _getNodeX(day, screenWidth);
    final y = _getNodeY(day);
    final isCurrent = day == currentDay;
    final isCompleted = day < currentDay;
    final isBossMilestone = day == 7 ||
        day == 14 ||
        day == 21 ||
        day == 30 ||
        day == 45 ||
        day == 60 ||
        day == 75 ||
        day == 90;

    final nodeSize = isBossMilestone ? 76.0 : 64.0;
    final stage = LearningMilestoneStage.getStageForDay(day);

    return Positioned(
      left: x - (nodeSize / 2),
      top: y - (nodeSize / 2),
      child: GestureDetector(
        onTap: () => _showLevelMissionDialog(day),
        child: SizedBox(
          width: nodeSize,
          height: nodeSize + (isCompleted ? 18 : 0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Current Day Glowing Pulse Wave
              if (isCurrent)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _bobController,
                    builder: (context, child) {
                      final scale = 1.0 + (_bobController.value * 0.25);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFFC00)
                                  .withValues(alpha: 0.7 - (_bobController.value * 0.4)),
                              width: 3.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // The 3D Stepping Stone Button
              Container(
                width: nodeSize,
                height: nodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isCurrent
                        ? [const Color(0xFFFFFC00), const Color(0xFFFF8906)]
                        : (isCompleted
                            ? [const Color(0xFF10B981), const Color(0xFF047857)]
                            : (isBossMilestone
                                ? [const Color(0xFF475569), const Color(0xFF1E293B)]
                                : [const Color(0xFF2A314A), const Color(0xFF181C2E)])),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isCurrent
                        ? Colors.white
                        : (isCompleted
                            ? const Color(0xFF6EE7B7)
                            : (isBossMilestone
                                ? const Color(0xFFFFD700)
                                : Colors.white.withValues(alpha: 0.22))),
                    width: isCurrent ? 3.2 : 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent
                          ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
                          : (isCompleted
                              ? const Color(0xFF10B981).withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.5)),
                      blurRadius: isCurrent ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 28)
                      : (isCurrent
                          ? Text(
                              '$day',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: isBossMilestone ? 24 : 20,
                              ),
                            )
                          : (isBossMilestone
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      stage.emoji,
                                      style: TextStyle(
                                          fontSize: isBossMilestone ? 19 : 16),
                                    ),
                                    Text(
                                      '$day',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_rounded,
                                        color: Colors.white54, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$day',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ))),
                ),
              ),

              // 3 Shiny Stars over completed nodes
              if (isCompleted)
                Positioned(
                  top: -12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star_rounded,
                          color: Color(0xFFFFD700), size: 14),
                      Icon(Icons.star_rounded,
                          color: Color(0xFFFFD700), size: 19),
                      Icon(Icons.star_rounded,
                          color: Color(0xFFFFD700), size: 14),
                    ],
                  ),
                ),

              // Boss Crown on Milestones
              if (isBossMilestone && !isCompleted)
                Positioned(
                  top: -14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'CHEST',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🐾 Minimal Flame Animal Card in the Open Space Beside Level Nodes (Audio Requirement!)
  /// Shows the animal avatar, species title, day, and lock/unlock status.
  /// Tapping opens the deep, holographic NftTradingCardDialog with all traits & achievements!
  Widget _buildMapMiniAnimalCard(int day, double screenWidth, int currentDay) {
    final nodeX = _getNodeX(day, screenWidth);
    final nodeY = _getNodeY(day);
    final isRightSide = nodeX >= screenWidth / 2;
    final isUnlocked = day <= currentDay;
    final config = _getAvatarForDay(day);

    // Position in wide empty space on opposite side of node
    final double cardWidth = ((screenWidth / 2) - 34.0).clamp(120.0, 165.0);
    final double cardLeft = isRightSide ? 14.0 : (screenWidth - cardWidth - 14.0);
    final double cardTop = nodeY - 26.0;

    final speciesTitle = config.species
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    // Color by rarity
    final tier = config.rarityTier.toLowerCase();
    Color rarityColor;
    if (tier.contains('mythic')) {
      rarityColor = const Color(0xFF00E5FF);
    } else if (tier.contains('legendary')) {
      rarityColor = const Color(0xFFFFD700);
    } else if (tier.contains('epic')) {
      rarityColor = const Color(0xFFD946EF);
    } else if (tier.contains('rare')) {
      rarityColor = const Color(0xFF38BDF8);
    } else {
      rarityColor = const Color(0xFF10B981);
    }

    return Positioned(
      left: cardLeft,
      top: cardTop,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _openAvatarCard(day);
        },
        child: Container(
          width: cardWidth,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1322).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnlocked
                  ? rarityColor.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.12),
              width: isUnlocked ? 1.2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnlocked
                    ? rarityColor.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Mini Avatar Preview Circle
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rarityColor.withValues(alpha: 0.18),
                  border: Border.all(
                    color: isUnlocked ? rarityColor : Colors.white24,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: config,
                    size: 36,
                    showAura: false,
                  ),
                ),
              ),
              const SizedBox(width: 7),

              // Title & Day & Rarity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      speciesTitle,
                      style: GoogleFonts.outfit(
                        color: isUnlocked ? Colors.white : Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Day $day',
                          style: GoogleFonts.inter(
                            color: isUnlocked ? const Color(0xFFFFFC00) : Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUnlocked ? '• 🔓 Claim' : '• 🔒 Target',
                          style: GoogleFonts.inter(
                            color: isUnlocked ? const Color(0xFF10B981) : Colors.white38,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isUnlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                color: isUnlocked ? rarityColor : Colors.white30,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The active character avatar standing on today's node.
  /// Tapping the avatar navigates to their personal profile (MainProfileWidget)!
  Widget _buildAnimatedAvatar(double screenWidth, int currentDay) {
    final x = _getNodeX(currentDay, screenWidth);
    final y = _getNodeY(currentDay);
    final avatarConfig = _getAvatarForDay(currentDay);

    return Positioned(
      left: x - 48,
      top: y - 114,
      child: AnimatedBuilder(
        animation: _bobController,
        builder: (context, child) {
          final bobY = math.sin(_bobController.value * math.pi) * 11.0;
          final shadowScale = 1.0 - (_bobController.value * 0.28);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speech bubble - Tap to view NFT Collectible Card!
              GestureDetector(
                onTap: () => _openAvatarCard(currentDay),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🃏', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        'Day $currentDay • View NFT Card',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Bobbing Avatar Character: Tapping opens the NFT Trading Card!
              Transform.translate(
                offset: Offset(0, -bobY),
                child: GestureDetector(
                  onTap: () => _openAvatarCard(currentDay),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFFFC00), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: VectorAvatarWidget(
                        config: avatarConfig,
                        size: 56,
                        showAura: false,
                      ),
                    ),
                  ),
                ),
              ),

              // Dynamic Shadow under avatar
              Transform.scale(
                scale: shadowScale,
                child: Container(
                  width: 36,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildBiomeProps(double screenWidth) {
    return [
      // Zone 1: Forest & Valley (Day 1 Header)
      Positioned(
        left: 20,
        top: 85,
        child: _buildZoneBanner(
          title: '🌲 ZONE 1: EMERALD FOREST & VALLEY',
          subtitle: 'MTI Reduction, Phonetics & Habit Foundations (Days 1–20)',
          color: const Color(0xFF10B981),
        ),
      ),

      // Zone 2: Desert Dunes (Day 21 Header)
      Positioned(
        left: 20,
        top: _getNodeY(21) - 65,
        child: _buildZoneBanner(
          title: '🏜️ ZONE 2: DESERT DUNES & OASIS',
          subtitle: 'Day 21 Habit Anchor, Spoken Confidence & Idioms (Days 21–40)',
          color: const Color(0xFFFFB700),
        ),
      ),

      // Zone 3: Cyberpunk City (Day 41 Header)
      Positioned(
        left: 20,
        top: _getNodeY(41) - 65,
        child: _buildZoneBanner(
          title: '⚡ ZONE 3: CYBER NEON HIGHWAY',
          subtitle: 'Fast Peer Debates & Professional Expressions (Days 41–60)',
          color: const Color(0xFF8B5CF6),
        ),
      ),

      // Zone 4: Cloud Kingdom (Day 61 Header)
      Positioned(
        left: 20,
        top: _getNodeY(61) - 65,
        child: _buildZoneBanner(
          title: '☁️ ZONE 4: MYSTIC CLOUD KINGDOM',
          subtitle: 'Impromptu Thinking & Global Dialect Mastery (Days 61–80)',
          color: const Color(0xFF00E5FF),
        ),
      ),

      // Zone 5: Dragon Castle (Day 81 Header)
      Positioned(
        left: 20,
        top: _getNodeY(81) - 65,
        child: _buildZoneBanner(
          title: '🌋 ZONE 5: DRAGON\'S LAIR & GRANDMASTER THRONE',
          subtitle: 'Day 90 Supreme Cosmic Dragon Graduation 👑 (Days 81–90)',
          color: const Color(0xFFFF0055),
        ),
      ),

      // Day 90 Grand Master Trophy Castle at the very end
      Positioned(
        left: (screenWidth / 2) - 85,
        top: _getNodeY(90) + 65,
        child: Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8906)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('🏰 👑 🐉', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                'GRAND MASTER',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '90-Day Transformation',
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildZoneBanner({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13182A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rendering the continuous serpentine adventure road
class _AdventureMapRoadPainter extends CustomPainter {
  final int totalDays;
  final int currentDay;
  final double screenWidth;
  final double nodeSpacingY;
  final double topPadding;

  _AdventureMapRoadPainter({
    required this.totalDays,
    required this.currentDay,
    required this.screenWidth,
    required this.nodeSpacingY,
    required this.topPadding,
  });

  double _getNodeX(int day) {
    final center = screenWidth / 2;
    final amplitude = (screenWidth - 140) / 2;
    final wave = math.sin((day - 1) * 0.72);
    return center + (wave * amplitude);
  }

  double _getNodeY(int day) {
    return topPadding + ((day - 1) * nodeSpacingY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Biome Background Gradients
    _paintBiomeGradients(canvas, size);

    // 2. Draw Decorative Trees / Rocks / Clouds / Crystals
    _paintWorldDecorations(canvas, size);

    // 3. Draw S-Curve Stepping Stone Road
    _paintCobblestoneRoad(canvas);
  }

  void _paintBiomeGradients(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0F3822), // Zone 1: Lush Forest Green
          Color(0xFF4A2B0F), // Zone 2: Warm Desert Golden Amber
          Color(0xFF26144A), // Zone 3: Cyberpunk Electric Violet
          Color(0xFF1B386E), // Zone 4: Sky Blue Cloud Realm
          Color(0xFF4A0E18), // Zone 5: Volcanic Magma Crimson
        ],
        stops: [0.15, 0.38, 0.60, 0.82, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintWorldDecorations(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawEmoji(String emoji, double x, double y, double fontSize) {
      textPainter.text = TextSpan(
        text: emoji,
        style: TextStyle(fontSize: fontSize),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }

    // Place rich scenery decorative elements on both sides of the path
    for (int day = 1; day <= totalDays; day += 2) {
      final y = _getNodeY(day);
      final isLeftSide = day % 4 == 0;
      final x = isLeftSide ? 18.0 : size.width - 50.0;

      if (day <= 20) {
        drawEmoji(day % 3 == 0 ? '🌲' : (day % 3 == 1 ? '🍄' : '⛺'), x, y, 24);
      } else if (day <= 40) {
        drawEmoji(day % 3 == 0 ? '🌴' : (day % 3 == 1 ? '🏛️' : '🌵'), x, y, 24);
      } else if (day <= 60) {
        drawEmoji(day % 3 == 0 ? '🏙️' : (day % 3 == 1 ? '⚡' : '🔮'), x, y, 24);
      } else if (day <= 80) {
        drawEmoji(day % 3 == 0 ? '☁️' : (day % 3 == 1 ? '💎' : '🌈'), x, y, 24);
      } else {
        drawEmoji(day % 3 == 0 ? '🌋' : (day % 3 == 1 ? '🔥' : '🪙'), x, y, 24);
      }
    }
  }

  void _paintCobblestoneRoad(Canvas canvas) {
    // Drop shadow under the entire road
    final roadShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final outerRoadPaint = Paint()
      ..color = const Color(0xFF22283E)
      ..strokeWidth = 28.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final innerRoadPaint = Paint()
      ..color = const Color(0xFF333B5C)
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final completedGlowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final lockedTrailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fullPath = Path();
    final completedPath = Path();

    for (int day = 1; day < totalDays; day++) {
      final p1 = Offset(_getNodeX(day), _getNodeY(day));
      final p2 = Offset(_getNodeX(day + 1), _getNodeY(day + 1));
      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

      if (day == 1) {
        fullPath.moveTo(p1.dx, p1.dy);
        if (day < currentDay) completedPath.moveTo(p1.dx, p1.dy);
      }

      fullPath.quadraticBezierTo(p1.dx, midPoint.dy, p2.dx, p2.dy);

      if (day < currentDay) {
        completedPath.quadraticBezierTo(p1.dx, midPoint.dy, p2.dx, p2.dy);
      }
    }

    // Draw road layers
    canvas.drawPath(fullPath, roadShadowPaint);
    canvas.drawPath(fullPath, outerRoadPaint);
    canvas.drawPath(fullPath, innerRoadPaint);

    // Draw center trail lines
    canvas.drawPath(fullPath, lockedTrailPaint);
    if (currentDay > 1) {
      canvas.drawPath(completedPath, completedGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdventureMapRoadPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.screenWidth != screenWidth;
  }
}
