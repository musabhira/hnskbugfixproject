import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'learning_models.dart';
import 'learning_service.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_defense_trap_modal.dart';
import 'pocket_daily_mission_page.dart';
import 'day90_master_certificate_dialog.dart';

/// Interactive Sheet & Dashboard for the 90-Day English Transformation & Profile Palette System
class Learning60DayDashboardSheet extends StatefulWidget {
  final String userId;
  final VoidCallback? onProgressUpdated;

  const Learning60DayDashboardSheet({
    super.key,
    required this.userId,
    this.onProgressUpdated,
  });

  static Future<void> show(BuildContext context, {required String userId, VoidCallback? onProgressUpdated}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Learning60DayDashboardSheet(
        userId: userId,
        onProgressUpdated: onProgressUpdated,
      ),
    );
  }

  @override
  State<Learning60DayDashboardSheet> createState() => _Learning60DayDashboardSheetState();
}

class _Learning60DayDashboardSheetState extends State<Learning60DayDashboardSheet> {
  UserLearningProgress? _progress;
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Overview & Tasks, 1: 30-Stage Palettes Roadmap

  String? _todayDateStr;
  String? _lastCompletedDate;
  int? _lastCompletedDay;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prog = await Learning60DayService().fetchProgress(widget.userId);
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    final lastCompDate = prefs.getString('learning_last_completed_date');
    final lastCompDay = prefs.getInt('learning_last_completed_day');

    if (mounted) {
      setState(() {
        _progress = prog;
        _isLoading = false;
        _todayDateStr = todayStr;
        _lastCompletedDate = lastCompDate;
        _lastCompletedDay = lastCompDay;
      });
    }
  }

  Future<void> _handleTaskTap(DailyEnglishTask task) async {
    if (task.isCompleted) return;
    HapticFeedback.mediumImpact();
    final updated = await Learning60DayService().completeTask(
      userId: widget.userId,
      taskId: task.id,
    );
    PocketFortressDefenseService.recordActivityPoints('daily_mission');
    if (mounted) {
      setState(() {
        _progress = updated;
      });
      widget.onProgressUpdated?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Completed "${task.title}"! +${task.points} Points • +30 FDC 🎉',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Prompt to craft Defense Shield immediately upon completing challenge
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          PocketDefenseTrapModal.show(
            context,
            updated.currentDay,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F111A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFFFFFC00), width: 1.5)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
          : Column(
              children: [
                // Top Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                '90-DAY ENGLISH MASTERY',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Daily 1.5–2h practice • 30/60/90 Day Major Milestones',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Inactivity Warning Banner (if user missed previous days)
                if (_progress?.hasInactivityWarning == true)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Inactivity Alert: You missed practice recently! Complete today\'s tasks to rebuild your streak.',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFECDD3),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Segmented Tab Toggle
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D2D),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? const Color(0xFFFFFC00) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '📋 Daily Target & Missions',
                                style: GoogleFonts.outfit(
                                  color: _selectedTab == 0 ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? const Color(0xFFFFFC00) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '🎨 30-Stage Roadmap',
                                style: GoogleFonts.outfit(
                                  color: _selectedTab == 1 ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: _selectedTab == 0 ? _buildTodayTab() : _buildPalettesRoadmapTab(),
                ),
              ],
            ),
    );
  }

  Widget _buildTodayTab() {
    final prog = _progress!;
    final activeStage = prog.activeStage;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // 90-Day Hero Progress Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: activeStage.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: activeStage.buttonColor.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: activeStage.buttonColor.withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'STAGE ${activeStage.stageNumber} / 30',
                      style: GoogleFonts.outfit(
                        color: activeStage.buttonColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${prog.streakDays} Day Streak',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Day ${prog.currentDay} of 90 Days',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${activeStage.emoji} ${activeStage.stageName} • ${activeStage.fluencyTier}',
                style: GoogleFonts.outfit(
                  color: activeStage.buttonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 12),

              // 90-Day Full Journey Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: prog.progressPercentage,
                  minHeight: 10,
                  backgroundColor: Colors.black45,
                  valueColor: AlwaysStoppedAnimation<Color>(activeStage.buttonColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(prog.progressPercentage * 100).toInt()}% Total Transformation',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    '${90 - prog.currentDay} Days to Diamond Tier',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),

              // Daily 1.5 - 2 Hours Investment Tracker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Today\'s Practice Time:',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '${prog.minutesPracticedToday}m / ${prog.targetDailyMinutes}m Target',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: prog.dailyTimePercentage,
                  minHeight: 6,
                  backgroundColor: Colors.black45,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Major Milestone Roadmap Summary Badges
        Row(
          children: [
            _buildMajorMilestoneChip('Day 21', 'Habit Anchor', prog.currentDay >= 21),
            const SizedBox(width: 8),
            _buildMajorMilestoneChip('Day 30', 'Silver B1', prog.currentDay >= 30),
            const SizedBox(width: 8),
            _buildMajorMilestoneChip('Day 60', 'Gold C1', prog.currentDay >= 60),
            const SizedBox(width: 8),
            _buildMajorMilestoneChip('Day 90', 'Diamond C2', prog.currentDay >= 90),
          ],
        ),
        const SizedBox(height: 20),

        // Today's English Missions Header
        Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFFFFFC00), size: 18),
            const SizedBox(width: 6),
            Text(
              'TODAY\'S PRACTICE MISSIONS (1.5h - 2h)',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Task Items
        ...prog.todayTasks.map((task) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: task.isCompleted ? const Color(0xFF141F1A) : const Color(0xFF161824),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted ? const Color(0xFF10B981).withValues(alpha: 0.6) : Colors.white12,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(task.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: GoogleFonts.outfit(
                                color: task.isCompleted ? Colors.white70 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${task.targetMinutes}m',
                              style: GoogleFonts.inter(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _handleTaskTap(task),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFFFC00),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.isCompleted ? '✓ Done' : '+${task.points} XP',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMajorMilestoneChip(String day, String title, bool isAchieved) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isAchieved ? const Color(0xFFFFD700).withValues(alpha: 0.15) : const Color(0xFF161824),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAchieved ? const Color(0xFFFFD700) : Colors.white12,
            width: isAchieved ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              isAchieved ? '✓ $day' : day,
              style: GoogleFonts.outfit(
                color: isAchieved ? const Color(0xFFFFD700) : Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isAchieved ? Colors.white : Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPalettesRoadmapTab() {
    final currentDay = _progress?.currentDay ?? 1;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: LearningMilestoneStage.allStages.length,
      itemBuilder: (context, index) {
        final stage = LearningMilestoneStage.allStages[index];
        final isUnlocked = currentDay >= stage.day;
        final isCurrent = currentDay == stage.day;
        final isCompletedToday = _lastCompletedDate == _todayDateStr && _lastCompletedDay == stage.day;

        return InkWell(
          onTap: () {
            if (isUnlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PocketDailyMissionPage(
                    day: stage.day,
                    onMissionCompleted: _loadProgress,
                  ),
                ),
              );
            } else {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    stage.day == currentDay + 1
                        ? (isCompletedToday
                            ? '⏳ Day ${stage.day} unlocks tomorrow at midnight! Great job completing Day $currentDay today.'
                            : '🔒 Day ${stage.day} unlocks tomorrow! Complete today\'s 60-min practice & subtasks first.')
                        : '🔒 Day ${stage.day} is locked. Complete Day ${stage.day - 1} to proceed.',
                  ),
                  backgroundColor: const Color(0xFF1E293B),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUnlocked ? stage.gradientColors : [const Color(0xFF14151F), const Color(0xFF0E0F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isCurrent
                    ? const Color(0xFFFFD700)
                    : stage.isMajorGate
                        ? const Color(0xFFFFD700).withValues(alpha: 0.8)
                        : isUnlocked
                            ? stage.buttonColor.withValues(alpha: 0.5)
                            : Colors.white10,
                width: (isCurrent || stage.isMajorGate) ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Stage badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isUnlocked ? stage.buttonColor : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isUnlocked ? stage.emoji : '🔒',
                      style: TextStyle(fontSize: isUnlocked ? 20 : 16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Stage ${stage.stageNumber}: ${stage.stageName}',
                              style: GoogleFonts.outfit(
                                color: isUnlocked ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCompletedToday
                            ? '✅ DAY ${stage.day} COMPLETED TODAY • Day ${stage.day + 1} Unlocks Tomorrow'
                            : (isUnlocked
                                ? 'Day ${stage.day} of 90 • ${stage.fluencyTier}'
                                : (stage.day == currentDay + 1
                                    ? '🔒 UNLOCKS TOMORROW • Day ${stage.day}'
                                    : '🔒 Locked • Complete Day ${stage.day - 1}')),
                        style: GoogleFonts.inter(
                          color: isCompletedToday
                              ? const Color(0xFF10B981)
                              : (isUnlocked
                                  ? stage.buttonColor
                                  : (stage.day == currentDay + 1 ? const Color(0xFFFFD700) : Colors.white38)),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              // Verified Tick Badge Preview for this Stage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: stage.tickColor, size: 14),
                    const SizedBox(width: 6),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: stage.bgColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: stage.buttonColor, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }
}

/// 🌳 Helper Model for Progressive English Tree Growth Stages (Audio Requirement!)
class EnglishTreeGrowthStage {
  final String emoji;
  final String treeName;
  final String growthPhase;
  final String taskFocus;
  final Color accentColor;

  const EnglishTreeGrowthStage({
    required this.emoji,
    required this.treeName,
    required this.growthPhase,
    required this.taskFocus,
    required this.accentColor,
  });

  static EnglishTreeGrowthStage forDay(int day) {
    if (day >= 90) {
      return const EnglishTreeGrowthStage(
        emoji: '🌟👑',
        treeName: 'Golden Imperial Bodhi Tree',
        growthPhase: 'C2 Grandmaster Eloquence • Full Bloom',
        taskFocus: 'Sovereign Oratory & Jurisprudence',
        accentColor: Color(0xFFFFD700),
      );
    } else if (day >= 71) {
      return const EnglishTreeGrowthStage(
        emoji: '🌴',
        treeName: 'Mighty Royal Oak',
        growthPhase: 'Imperial Canopy & Fruit Blooming',
        taskFocus: 'Cross-Cultural High Diplomacy',
        accentColor: Color(0xFFEC4899),
      );
    } else if (day >= 46) {
      return const EnglishTreeGrowthStage(
        emoji: '🌲',
        treeName: 'Majestic Evergreen Pine',
        growthPhase: 'Leadership Foliage Expansion',
        taskFocus: 'Executive Oratory & Debate Cadence',
        accentColor: Color(0xFFF59E0B),
      );
    } else if (day >= 21) {
      return const EnglishTreeGrowthStage(
        emoji: '🌳',
        treeName: 'Young Flourishing Tree',
        growthPhase: 'Firm Trunk & Branching Canopy',
        taskFocus: 'Diplomatic Softeners & Registers',
        accentColor: Color(0xFFA855F7),
      );
    } else if (day >= 8) {
      return const EnglishTreeGrowthStage(
        emoji: '🌿',
        treeName: 'Branching Sapling',
        growthPhase: 'Early Stems & Fresh Foliage',
        taskFocus: 'Habit Anchor & Conversational Fluency',
        accentColor: Color(0xFF38BDF8),
      );
    } else {
      return const EnglishTreeGrowthStage(
        emoji: '🌱',
        treeName: 'Sprouting Seedling',
        growthPhase: 'Root Formation & Native-Tongue Detachment',
        taskFocus: 'Hesitation Elimination & Daily Drills',
        accentColor: Color(0xFF10B981),
      );
    }
  }
}

/// 📈 Mini Smooth Sparkline Curve showing English Growth across 90 Days
class EnglishGrowthSparklinePainter extends CustomPainter {
  final int currentDay;
  final Color accentColor;

  EnglishGrowthSparklinePainter({required this.currentDay, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [accentColor.withValues(alpha: 0.22), accentColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    double getProgressY(double dayRatio) {
      // Smooth S-curve trajectory
      final curve = (dayRatio * dayRatio * (3 - 2 * dayRatio));
      return size.height - (curve * (size.height - 6)) - 3;
    }

    final path = Path();
    final fillPath = Path();

    path.moveTo(0, getProgressY(0.01));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getProgressY(0.01));

    const steps = 30;
    for (int i = 1; i <= steps; i++) {
      final ratio = i / steps.toDouble();
      final x = ratio * size.width;
      final y = getProgressY(ratio);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, basePaint);

    // Active progress line up to current day
    final curRatio = (currentDay / 90.0).clamp(0.01, 1.0);
    final curX = curRatio * size.width;
    final curY = getProgressY(curRatio);

    final activePath = Path();
    activePath.moveTo(0, getProgressY(0.01));
    for (int i = 1; i <= steps; i++) {
      final ratio = i / steps.toDouble();
      if (ratio > curRatio) break;
      final x = ratio * size.width;
      final y = getProgressY(ratio);
      activePath.lineTo(x, y);
    }
    activePath.lineTo(curX, curY);
    canvas.drawPath(activePath, progressPaint);

    // Glowing position marker dot
    canvas.drawCircle(Offset(curX, curY), 5.0, Paint()..color = accentColor.withValues(alpha: 0.35));
    canvas.drawCircle(Offset(curX, curY), 2.8, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(curX, curY), 1.6, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant EnglishGrowthSparklinePainter oldDelegate) {
    return oldDelegate.currentDay != currentDay || oldDelegate.accentColor != accentColor;
  }
}

/// Compact Banner Card embedded directly inside MainProfileWidget
class Learning60DayProfileCard extends StatefulWidget {
  final String userId;
  final int? currentDay;
  final String? userName;
  final VoidCallback? onProgressUpdated;

  const Learning60DayProfileCard({
    super.key,
    required this.userId,
    this.currentDay,
    this.userName,
    this.onProgressUpdated,
  });

  @override
  State<Learning60DayProfileCard> createState() => _Learning60DayProfileCardState();
}

class _Learning60DayProfileCardState extends State<Learning60DayProfileCard> {
  UserLearningProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(Learning60DayProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay && widget.currentDay != null) {
      if (_progress != null) {
        setState(() {
          _progress = _createOverriddenProgress(_progress!, widget.currentDay!);
        });
      }
    }
  }

  UserLearningProgress _createOverriddenProgress(UserLearningProgress base, int day) {
    return UserLearningProgress(
      currentDay: day,
      currentStage: day,
      streakDays: base.streakDays,
      totalPoints: base.totalPoints,
      minutesPracticedToday: base.minutesPracticedToday,
      targetDailyMinutes: base.targetDailyMinutes,
      missedDaysCount: base.missedDaysCount,
      hasInactivityWarning: base.hasInactivityWarning,
      lastActiveDate: base.lastActiveDate,
      todayTasks: base.todayTasks,
    );
  }

  Future<void> _fetch() async {
    final p = await Learning60DayService().fetchProgress(widget.userId);
    if (mounted) {
      final effectiveProgress = widget.currentDay != null
          ? _createOverriddenProgress(p, widget.currentDay!)
          : p;
      setState(() {
        _progress = effectiveProgress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _progress == null) {
      return const SizedBox.shrink();
    }

    final p = _progress!;
    final effectiveDay = widget.currentDay ?? p.currentDay;
    final stage = LearningMilestoneStage.getStageForDay(effectiveDay);
    final treeStage = EnglishTreeGrowthStage.forDay(effectiveDay);
    final progressPct = (effectiveDay / 90.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => Learning60DayDashboardSheet.show(
        context,
        userId: widget.userId,
        onProgressUpdated: _fetch,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              stage.bgColor.withValues(alpha: 0.95),
              const Color(0xFF111422),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: stage.buttonColor.withValues(alpha: 0.6), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: stage.buttonColor.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Tree Growth & Stage Info
            Row(
              children: [
                // 🌳 Dynamic Growing Tree Stage Emblem
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: treeStage.accentColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: treeStage.accentColor.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Text(treeStage.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Day $effectiveDay/90 • ${treeStage.treeName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: stage.buttonColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: stage.buttonColor.withValues(alpha: 0.5), width: 0.8),
                            ),
                            child: Text(
                              'Stage ${stage.stageNumber}',
                              style: GoogleFonts.outfit(
                                color: stage.buttonColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🌱 ${treeStage.growthPhase} • Focus: ${treeStage.taskFocus}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 13),
              ],
            ),

            const SizedBox(height: 10),

            // 📈 Mini English Growth Sparkline Graph
            Container(
              height: 38,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: CustomPaint(
                painter: EnglishGrowthSparklinePainter(
                  currentDay: effectiveDay,
                  accentColor: treeStage.accentColor,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Row 3: Progress Bar & Percentage Marker
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPct,
                      minHeight: 5,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(treeStage.accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progressPct * 100).toInt()}% Fluency Curve',
                  style: GoogleFonts.outfit(
                    color: treeStage.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            // 🎓 Day 90 Official Certificate Launcher (Visible when at Day 90)
            if (effectiveDay >= 90) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Day90MasterCertificateDialog.show(
                      context,
                      userName: widget.userName ?? 'Sovereign Grandmaster',
                      userDay: effectiveDay,
                    );
                  },
                  icon: const Text('🎓', style: TextStyle(fontSize: 14)),
                  label: Text(
                    'VIEW & DOWNLOAD OFFICIAL C2 CERTIFICATE',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
