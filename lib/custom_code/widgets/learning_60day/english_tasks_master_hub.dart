import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/nft_trading_card_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/jackie_chan_talisman_service.dart';
import 'pocket_world_street_page.dart';
import 'pocket_open_world_game_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_defense_trap_modal.dart';
import 'pocket_arsenal_store_modal.dart';
import 'pocket_daily_mission_page.dart';
import 'pocket_score_level_engine.dart';
import 'pocket_world_game_rules_modal.dart';
import 'pocket_day1_diagnostic_sheet.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_ad_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'pocket_citadel_attack_page.dart';
import 'day90_master_certificate_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'pocket_syllabus_repository.dart';
import 'pocket_practice_speaking_card.dart';
import 'pocket_fluency_gym_detail_page.dart';
import 'pocket_level_exam_dialog.dart';
import 'pocket_alphabet_phonics_game_page.dart';
import 'zero_foundation_curriculum_db.dart';
import 'pocket_mission_curriculum_registry.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:flame/components.dart' show Vector2;
import 'flame_english_house_game.dart';
import 'pocket_90day_vocab_curriculum.dart';
import 'pocket_day_detail_overview_page.dart';
import 'pocket_day_open_world_adventure_page.dart';
import 'pocket_interactive_teacher_game.dart';
import 'pocket_secret_code_grammar_card.dart';
import 'pocket_sentence_builder_card.dart';
import 'pocket_slang_smart_english_card.dart';
import 'pocket_time_machine_practice_card.dart';
import 'pocket_code_english_decoder_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';
import 'career_adventure/cyber_vocab_game_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'pocket_day1_tutor_curriculum.dart';
import 'pocket_day1_interactive_flow_page.dart';
import 'pocket_home_visit_modal.dart';

/// 🗺️ Model for In-Path Syllabus Sub-Steps along the Climbing Trail (Audio Directive)
class InPathSubStep {
  final int stepIndex; // 1, 2, 3, 4
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback onAction;

  const InPathSubStep({
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.isUnlocked,
    required this.onAction,
  });
}

/// 🏡 High-Performance CustomPainter for Progressive 90-Day English Houses
/// Seamlessly invokes HouseMasterComponent's Flutter canvas rendering engine
class HouseMasterPainter extends CustomPainter {
  final int day;
  final HousePalette palette;
  final bool isDamaged;
  final bool isPresident;
  final bool lightsOn;
  late final HouseMasterComponent _comp;

  HouseMasterPainter({
    required this.day,
    HousePalette? palette,
    this.isDamaged = false,
    this.isPresident = false,
    this.lightsOn = true,
  }) : palette = palette ?? HousePalette.presets[0] {
    _comp = HouseMasterComponent(
      day: day,
      streak: 1,
      palette: this.palette,
      isDamaged: isDamaged,
      isPresident: isPresident,
    )..lightsOn = lightsOn;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _comp.resize(Vector2(size.width, size.height));
    _comp.render(canvas);
  }

  @override
  bool shouldRepaint(covariant HouseMasterPainter oldDelegate) {
    return oldDelegate.day != day ||
        oldDelegate.isDamaged != isDamaged ||
        oldDelegate.isPresident != isPresident ||
        oldDelegate.lightsOn != lightsOn ||
        oldDelegate.palette.id != palette.id;
  }
}

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
    stageNumber: 0,
    title: 'Rules',
    rangeText: 'Charter',
    targetDay: 0,
    houseStage: 'Rules & Pledge',
    houseEmoji: '📜',
    rewardSummary: 'Charter Badge • 12 Rules',
    defenseSummary: 'Complete Rule Guide',
    themeColor: Color(0xFF38BDF8),
  ),
  const TargetMilestoneItem(
    stageNumber: 1,
    title: 'Levels 1–7',
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
    title: 'Levels 8–20',
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
    title: 'Levels 21–45',
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
    title: 'Levels 46–70',
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
    title: 'Levels 71–89',
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
    title: 'Level 90 Master',
    rangeText: 'Day 90 Master',
    targetDay: 90,
    houseStage: 'Supreme Empire',
    houseEmoji: '👑',
    rewardSummary: 'VIP Limousine + 2 Armed Escorts + NFT Card',
    defenseSummary: 'Max 25 Q Shield + Citadel',
    themeColor: Color(0xFFFFD700),
  ),
  const TargetMilestoneItem(
    stageNumber: 7,
    title: 'Level 91 (Palace Raid ⚔️)',
    rangeText: 'Presidential Citadel',
    targetDay: 91,
    houseStage: 'Sovereign Citadel Raid',
    houseEmoji: '⚔️',
    rewardSummary: 'Official Fluency Diploma + Presidential Honors',
    defenseSummary: '250 Boss Trials • Sovereign Citadel Raid',
    themeColor: Color(0xFFFFD700),
  ),
];

/// 🎮 91-Day Full English Transformation Gamified Adventure Map
/// Super Mario World / Candy Crush / Duolingo style snaking level progression trail (Days 1–91)
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
  // Initialize with large offset so Flutter clamps to maxScrollExtent on frame 1 without flashing the summit top!
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 999999.0);
  late AnimationController _bobController;

  bool _isLoading = true;
  bool _isRefreshing = false;
  int _unifiedPocketScore = 0;
  int _unifiedTrophies = 0;
  UserLearningProgress? _progress;
  String? _equippedTalismanId;
  bool _hasAcceptedRules = false;
  LearnerLevel _currentLearnerLevel = LearnerLevel.zero;
  final int _totalDays = 91;
  bool _hasConqueredCitadel = false;
  bool _isSubscribed = false;
  bool _hasCustomSelectedSyllabus = false;

  // ⏱️ Midnight Daily Unlock Ticker
  Timer? _midnightTicker;
  Duration _timeUntilMidnight = Learning60DayService.getRemainingTimeUntilMidnight();
  int _lastCompletedDay = 0;
  String? _lastCompletedDateStr;
  final Set<int> _completedDays = {};
  final Map<int, String> _completedDates = {};
  int _levelRivalShuffleSeed = 0;

  // Spacing & node dimensions for upward climbing roadmap with 90 English Houses
  // User audio directive: "ഒരു വീട് കഴിഞ്ഞ് ഒരു ഗ്യാപ്പ് ഇട്ടിട്ട് ഗേറ്റ്. ഇപ്പോൾ ഭയങ്കര congested ആയി കിടക്കുന്നുണ്ട്. Distance double/triple ആക്കുക."
  static const double _nodeSpacingY = 560.0;
  static const double _expandedActiveGap = 0.0;
  static const double _topPadding = 480.0; // Summit apex spacing with Citadel Palace
  static const double _bottomPadding = 320.0;
  double get _ruleNodeY => _getNodeY(1) + 200.0; // Positioned below Day 1 at the bottom
  final Map<String, bool> _subStepFlags = {};
  bool _hasInitiallyScrolled = false;
  int? _adminSelectedDay;

  /// 🔐 Master Admin check for musabthonippadam@gmail.com (Audio Directive: all days & steps unlocked)
  bool get _isMasterAdmin {
    final email = _supabase.auth.currentUser?.email;
    return AdminAuthService.isMasterAdminEmail(email);
  }

  bool get _effectiveRulesAccepted => _hasAcceptedRules || _isMasterAdmin;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    // Live countdown to Midnight 12:00 AM
    _midnightTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final remaining = Learning60DayService.getRemainingTimeUntilMidnight();
      setState(() {
        _timeUntilMidnight = remaining;
      });
      // If midnight just passed, refresh progress to unlock the next level
      if (remaining.inSeconds <= 0 && _lastCompletedDay > 0) {
        _loadData();
      }
    });

    _loadData();
    // 🎵 Play gentle ambient target roadmap loop music
    PocketGameAudioService.instance.playTargetTheme();
    PocketSyllabusRepository.getSavedLevel().then((lvl) {
      if (mounted) setState(() => _currentLearnerLevel = lvl);
    });
  }

  @override
  void dispose() {
    PocketGameAudioService.instance.pause();
    _midnightTicker?.cancel();
    _bobController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isDayWaitingForMidnight(int day) {
    if (_isMasterAdmin) return false; // 🔐 Master Admin bypasses all midnight locks
    if (_isSubscribed) return false; // VIP Subscribers bypass the 24-hour midnight wait lock!
    if (day <= 1) return false;
    if (_isDayCompleted(day)) return false; // Completed days never wait for midnight!
    if (!_isDayCompleted(day - 1)) return false;
    final lastCompDate = _completedDates[day - 1] ?? _lastCompletedDateStr;
    if (lastCompDate == null || lastCompDate.isEmpty) return false;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    return lastCompDate == todayStr;
  }

  /// Strictly checks if a day has actually been completed
  bool _isDayCompleted(int day) {
    if (day < 1) return true;
    return _completedDays.contains(day);
  }

  /// Level N can ONLY be unlocked if:
  /// 1. Rules accepted (if Level 1)
  /// 2. Level N-1 has been COMPLETED with exam passed
  /// 3. Pocket Score >= getRequiredScoreForLevel(N)
  /// 4. Not waiting for midnight digestion interval (bypassed by VIP subscription or admin)
  /// 🔐 Note: musabthonippadam@gmail.com (Master Admin) bypasses all locks instantly!
  bool _isDayUnlocked(int day, int currentDay) {
    if (_isMasterAdmin) return true; // 🔐 Master admin bypass: All 90 days unlocked!
    if (day == 1) return _hasAcceptedRules;
    // Sequential prerequisite check: previous level MUST be completed!
    if (!_isDayCompleted(day - 1)) return false;
    // Pocket Score threshold check (Audio Directive: pocket score base cheythu level unlock)
    final reqScore = PocketScoreLevelEngine.getRequiredScoreForLevel(day);
    if (_unifiedPocketScore < reqScore) return false;
    // Audio Directive: "Trophy restriction illa tto. Trophy restriction illa."
    // If waiting for midnight countdown (waits until 12:00 AM next day unless subscribed)
    if (_isDayWaitingForMidnight(day)) return false;
    return true;
  }

  Future<void> _loadData() async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final progRaw = await Learning60DayService().fetchProgress(uid);
    final score = await PocketFortressDefenseService.getUnifiedScore(uid);
    final trophies = await PocketTrophyService.getTrophyCount(uid);

    final prefs = await SharedPreferences.getInstance();
    final lastCompDay = prefs.getInt('learning_last_completed_day_$uid') ?? 0;

    // Collect all actually completed days and completion dates for this user
    final Set<int> completed = {};
    final Map<int, String> compDates = {};
    for (int d = 1; d <= _totalDays; d++) {
      if (prefs.getBool('pocket_day_${uid}_${d}_completed') == true) {
        completed.add(d);
        final dDate = prefs.getString('learning_day_${uid}_${d}_completed_date');
        if (dDate != null && dDate.isNotEmpty) {
          compDates[d] = dDate;
        }
      }
    }

    final int effectiveLastCompDay = completed.isNotEmpty
        ? completed.reduce(math.max)
        : lastCompDay;
    final String? effectiveLastCompDate = compDates[effectiveLastCompDay] ??
        prefs.getString('learning_day_${uid}_${effectiveLastCompDay}_completed_date');

    // 🪙 Find the current active incomplete level sequentially
    int activeDay = 1;
    for (int d = 1; d <= _totalDays; d++) {
      if (!completed.contains(d)) {
        activeDay = d;
        break;
      }
    }

    int calculatedCurrentDay = activeDay.clamp(1, _totalDays);

    // Sync persisted state with active level
    await prefs.setInt('pocket_learning_user_stage_$uid', calculatedCurrentDay);
    await prefs.setInt('learning_day_$uid', calculatedCurrentDay);

    final effectiveDay = calculatedCurrentDay;
    final prog = progRaw.copyWith(currentDay: effectiveDay);

    String? talismanId;
    try {
      final talisman = await JackieChanTalismanService.getEquippedTalisman();
      talismanId = talisman.id;
    } catch (_) {}

    final rulesAccepted = (prog.currentDay > 1) ||
        (prefs.getBool('pocket_world_rules_accepted_${uid}_v1') ??
         prefs.getBool('pocket_world_rules_accepted_v1') ?? false);

    final isVip = await PocketAdService().isUserSubscribed();
    final isCitadelConquered = await PocketPresidentService.hasConqueredPresidentialCitadel(uid);
    final savedLevel = await PocketSyllabusRepository.getSavedLevel();
    final hasCustomSyllabus = prefs.getBool('pocket_has_custom_syllabus_selection_$uid') ?? false;

    final Map<String, bool> subFlags = {};
    for (int step = 1; step <= 17; step++) {
      final flagKey = 'pocket_day_${uid}_${calculatedCurrentDay}_step_${step}_done';
      subFlags['step_$step'] = prefs.getBool(flagKey) ?? false;
    }

    if (mounted) {
      setState(() {
        _isSubscribed = isVip;
        _hasConqueredCitadel = isCitadelConquered;
        _currentLearnerLevel = savedLevel;
        _hasCustomSelectedSyllabus = hasCustomSyllabus;
        _progress = prog;
        _unifiedPocketScore = score;
        _unifiedTrophies = trophies;
        _completedDays
          ..clear()
          ..addAll(completed);
        _completedDates
          ..clear()
          ..addAll(compDates);
        _subStepFlags
          ..clear()
          ..addAll(subFlags);
        _equippedTalismanId = talismanId;
        _hasAcceptedRules = rulesAccepted;
        _lastCompletedDay = effectiveLastCompDay;
        _lastCompletedDateStr = effectiveLastCompDate;
        _isLoading = false;
        _isRefreshing = false;
      });

      // Instant initial positioning to current active day or Rules node without animated downward scroll
      // User Audio Directive: "keri varumbol thanne ... scroll cheythu adiyil pokunna feeling undu, athu venda. Starting thanne scrollingil ninnu thudangiyaal mathi... speed-il athu venda"
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!_hasInitiallyScrolled) {
          _hasInitiallyScrolled = true;
          if (!rulesAccepted) {
            _scrollToRule(animate: false);
          } else {
            _scrollToDay(prog.currentDay, animate: false);
          }
        }

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

  /// Returns the systematic stage-evolved avatar for the day, matching the Main Profile view exactly!
  VectorAvatarConfig _getAvatarForDay(int day) {
    return VectorAvatarConfig.getEvolutionAvatarForStage(day, talismanId: _equippedTalismanId);
  }

  double _getNodeXFractional(double dayFraction, double screenWidth) {
    final center = screenWidth / 2;
    if (dayFraction >= 33) {
      // 🎯 Audio Directive: From Day 33 onwards, track goes straight through center with subtle micro-bends!
      // This prevents big estates and castles (Day 33, 51, 52, 55, 56, 64 etc.) from clipping on screen edges.
      final subtleWave = math.sin((dayFraction - 33) * 0.55) * 14.0;
      return center + subtleWave;
    }
    // Days 1 to 32: Gentle pleasant bends, safely bounded so houses never clip
    final maxAmp = ((screenWidth - 250) / 2).clamp(16.0, 36.0);
    final wave = math.sin((dayFraction - 1) * 0.65);
    return center + (wave * maxAmp);
  }

  double _getNodeX(int day, double screenWidth) {
    return _getNodeXFractional(day.toDouble(), screenWidth);
  }

  /// Inverted coordinate system:
  /// Day 91 is at the summit apex (_topPadding = 480).
  /// Day 1 is at the bottom.
  /// Rules node is placed below Day 1 (_ruleNodeY).
  double _getNodeY(int day) {
    final int daysFromTop = _totalDays - day;
    return _topPadding + (daysFromTop * _nodeSpacingY);
  }

  double _getSubStepY(int activeDay, int stepNumber, {int totalSteps = 17}) {
    final denom = (totalSteps + 1).toDouble();
    final fraction = stepNumber / denom;
    return _getNodeY(activeDay) - (fraction * (_nodeSpacingY + _expandedActiveGap));
  }

  double _getSubStepX(int activeDay, int stepNumber, double screenWidth, {int totalSteps = 17}) {
    final denom = (totalSteps + 1).toDouble();
    final fraction = stepNumber / denom;
    final startX = _getNodeX(activeDay, screenWidth);
    final endX = _getNodeX(activeDay + 1, screenWidth);
    final linearX = startX + (endX - startX) * fraction;
    final amplitude = (screenWidth - 150) / 2;
    // Winding mountain switchback S-curves along the steps
    final wave = math.sin(fraction * math.pi * 3.0) * (amplitude * 0.72);
    return (linearX + wave).clamp(65.0, screenWidth - 65.0);
  }

  /// Lightweight Viewport Culling Check (User Audio Directive: "hang aavaruthu... lightweight aayirikkanam... lazy loading okke koduthittu")
  bool _isDayInViewport(int day, double minY, double maxY) {
    final y = _getNodeY(day);
    return (y >= minY - 320.0) && (y <= maxY + 320.0);
  }

  void _scrollToRule({bool animate = false}) {
    if (!_scrollController.hasClients) return;
    final targetY = _ruleNodeY - 280.0;
    final clampedY = targetY.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    if (animate) {
      _scrollController.animateTo(
        clampedY,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedY);
    }
  }

  void _scrollToDay(int day, {bool animate = false}) {
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

  /// Handler when an in-path sub-step is completed
  Future<void> _onSubStepFinished(int day, int stepIndex) async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    int pointsAwarded = (stepIndex == 17) ? 120 : 30;
    if (uid != null && uid.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final alreadyDone = prefs.getBool('pocket_day_${uid}_${day}_step_${stepIndex}_done') == true;
      await prefs.setBool('pocket_day_${uid}_${day}_step_${stepIndex}_done', true);

      // Award marks / Pocket Score for each step (User audio directive: 500-600 PS per day)
      // Steps 1 to 16 = 30 PS each, Step 17 Mastery Exam = 120 PS bonus (Total: 600 PS/day)
      if (!alreadyDone) {
        await PocketFortressDefenseService.recordTrainingPoints(pointsAwarded, uid);
      }

      // Passing the 17th step (Mastery Exam) certifies Day and unlocks the next house gate!
      if (stepIndex == 17) {
        await prefs.setBool('pocket_day_${uid}_${day}_completed', true);
        await prefs.setInt('learning_last_completed_day_$uid', day);
        final now = DateTime.now();
        await prefs.setString('learning_day_${uid}_${day}_completed_date', '${now.year}-${now.month}-${now.day}');
      }
    }
    HapticFeedback.heavyImpact();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stepIndex == 17
                      ? '🎉 Day $day Mastered! +$pointsAwarded PS 🪙 • House ${day + 1} Gate Unlocked!'
                      : 'Step $stepIndex / 17 Done! +$pointsAwarded PS 🪙 Keep climbing up the trail 🚀',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Helper to open any practice card cleanly in a dedicated full-width modal page
  Future<void> _openCardPage({
    required String title,
    required String stepTag,
    required Color accentColor,
    required Widget Function(BuildContext ctx, void Function(bool) markDone) childBuilder,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (pageCtx) => Scaffold(
          backgroundColor: const Color(0xFF0A1118),
          appBar: AppBar(
            backgroundColor: const Color(0xFF131722),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(pageCtx),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    stepTag,
                    style: GoogleFonts.outfit(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: childBuilder(pageCtx, (completed) {
                if (completed) {
                  Navigator.pop(pageCtx);
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  // --- 17 DEDICATED IN-PATH SUB-STEP LAUNCHERS ---

  // 1: Interactive Teacher Game (Replaced static theory page!)
  Future<void> _launchStep1_Theory(int day) async {
    HapticFeedback.lightImpact();
    await PocketInteractiveTeacherGameModal.show(
      context,
      day: day,
      userId: widget.userId ?? _supabase.auth.currentUser?.id,
      initialLevel: _currentLearnerLevel,
      onCompleted: () async {
        await _onSubStepFinished(day, 1);
      },
    );
  }

  // 2: 10 Core Vocabulary Words
  Future<void> _launchStep2_Vocab(int day) async {
    HapticFeedback.lightImpact();
    final vocabList = Pocket90DayVocabCurriculum.getVocabForDay(day);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (pageCtx) => Scaffold(
          backgroundColor: const Color(0xFF0A1118),
          appBar: AppBar(
            backgroundColor: const Color(0xFF131722),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(pageCtx),
            ),
            title: Text(
              'Day $day • 10 Core Vocabulary Words',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          body: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vocabList.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                if (i == vocabList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(pageCtx);
                        await _onSubStepFinished(day, 2);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        'I MEMORIZED ALL 10 WORDS ✓',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  );
                }
                final item = vocabList[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131728),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8906),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.word,
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.partOfSpeech.toUpperCase(),
                                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 8.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.malayalamMeaning,
                              style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.definition,
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 3: Alphabet & 44 Phonics
  Future<void> _launchStep3_Phonics(int day, LearnerLevel level) async {
    HapticFeedback.lightImpact();
    List<AlphabetPhonicItem> phonicsList = [];
    try {
      if (level == LearnerLevel.zero) {
        final zeroPlan = ZeroFoundationCurriculumDB.getDayPlan(day);
        if (zeroPlan.phonicsDrills.isNotEmpty) {
          phonicsList = zeroPlan.phonicsDrills;
        }
      }
      if (phonicsList.isEmpty) {
        phonicsList = PocketMissionCurriculumRegistry.getAlphabetPhonics(day);
      }
    } catch (_) {}

    if (phonicsList.isNotEmpty) {
      final res = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PocketAlphabetPhonicsGamePage(
            day: day,
            selectedLanguage: 'Malayalam',
            phonicsList: phonicsList,
          ),
        ),
      );
      if (res == true) {
        await _onSubStepFinished(day, 3);
      }
    } else {
      await _onSubStepFinished(day, 3);
    }
  }

  // 4: Fluency Gym
  Future<void> _launchStep4_FluencyGym(int day, LearnerLevel level) async {
    HapticFeedback.lightImpact();
    final res = await PocketFluencyGymDetailPage.open(
      context,
      day: day,
      selectedLanguage: 'Malayalam',
      isInitiallyCompleted: _subStepFlags['step_4'] ?? false,
      onCompleted: (val) {
        if (val) _onSubStepFinished(day, 4);
      },
    );
    if (res == true) {
      await _onSubStepFinished(day, 4);
    }
  }

  // 5: Secret Code Grammar
  Future<void> _launchStep5_SecretCode(int day) async {
    HapticFeedback.lightImpact();
    await _openCardPage(
      title: 'Secret Code Grammar Matrix',
      stepTag: 'STEP 5',
      accentColor: const Color(0xFFFFD700),
      childBuilder: (ctx, markDone) => PocketSecretCodeGrammarCard(
        day: day,
        selectedLanguage: 'Malayalam',
        isCompleted: _subStepFlags['step_5'] ?? false,
        onSpeak: (text) {},
        onCompleted: (val) async {
          if (val) {
            await _onSubStepFinished(day, 5);
            markDone(true);
          }
        },
      ),
    );
  }

  // 6: Sentence Builder Puzzle
  Future<void> _launchStep6_SentenceBuilder(int day) async {
    HapticFeedback.lightImpact();
    await _openCardPage(
      title: 'Sentence Builder Gym',
      stepTag: 'STEP 6',
      accentColor: const Color(0xFF00E5FF),
      childBuilder: (ctx, markDone) => PocketSentenceBuilderCard(
        day: day,
        isCompleted: _subStepFlags['step_6'] ?? false,
        onSpeak: (text) {},
        onCompleted: (val) async {
          if (val) {
            await _onSubStepFinished(day, 6);
            markDone(true);
          }
        },
      ),
    );
  }

  // 7: Daily Slang to Smart English
  Future<void> _launchStep7_Slang(int day) async {
    HapticFeedback.lightImpact();
    await _openCardPage(
      title: 'Daily Slang to Smart English',
      stepTag: 'STEP 7',
      accentColor: const Color(0xFFFF6D00),
      childBuilder: (ctx, markDone) => PocketSlangSmartEnglishCard(
        day: day,
        selectedLanguage: 'Malayalam',
        isCompleted: _subStepFlags['step_7'] ?? false,
        onSpeak: (text) {},
        onCompleted: (val) async {
          if (val) {
            await _onSubStepFinished(day, 7);
            markDone(true);
          }
        },
      ),
    );
  }

  // 8: Practice Speaking Aloud
  Future<void> _launchStep8_Speaking(int day) async {
    HapticFeedback.lightImpact();
    await _openCardPage(
      title: 'Practice Speaking Aloud',
      stepTag: 'STEP 8',
      accentColor: const Color(0xFFE040FB),
      childBuilder: (ctx, markDone) => PocketPracticeSpeakingCard(
        day: day,
        isCompleted: _subStepFlags['step_8'] ?? false,
        onCompleted: (val) async {
          if (val) {
            await _onSubStepFinished(day, 8);
            markDone(true);
          }
        },
      ),
    );
  }

  // 9: Time Machine Verbs Trainer
  Future<void> _launchStep9_TimeMachine(int day) async {
    HapticFeedback.lightImpact();
    await _openCardPage(
      title: 'Time Machine Verbs Trainer',
      stepTag: 'STEP 9',
      accentColor: const Color(0xFFFFC107),
      childBuilder: (ctx, markDone) => PocketTimeMachinePracticeCard(
        day: day,
        selectedLanguage: 'Malayalam',
        isCompleted: _subStepFlags['step_9'] ?? false,
        onCompleted: (val) async {
          if (val) {
            await _onSubStepFinished(day, 9);
            markDone(true);
          }
        },
      ),
    );
  }

  // 10: English Hub Community Chat
  Future<void> _launchStep10_CommunityChat(int day) async {
    HapticFeedback.lightImpact();
    final currentUserId = _supabase.auth.currentUser?.id;
    EnglishHubLevelGroup levelGroup;
    if (currentUserId != null) {
      levelGroup = await EnglishHubLevelGroupService.ensureUserInLevelGroup(
        userLevel: day,
        userId: currentUserId,
      );
    } else {
      levelGroup = await EnglishHubLevelGroupService.getGroupByLevel(day);
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WhatsAppGroupChat(
          groupId: levelGroup.groupId,
          groupName: levelGroup.groupName,
        ),
      ),
    );
    await _onSubStepFinished(day, 10);
  }

  // 11: AI Speech Practice Lab (Replaced broken phone call!)
  Future<void> _launchStep11_PeerCall(int day) async {
    HapticFeedback.lightImpact();
    await _openCardPage(
      title: 'AI Speech Practice Lab',
      stepTag: 'STEP 11',
      accentColor: const Color(0xFF38BDF8),
      childBuilder: (ctx, markDone) => PocketPracticeSpeakingCard(
        day: day,
        isCompleted: _subStepFlags['step_11'] ?? false,
        onCompleted: (val) async {
          if (val) {
            await _onSubStepFinished(day, 11);
            markDone(true);
          }
        },
      ),
    );
  }

  // 12: Daily 2D Adventure Quest
  Future<void> _launchStep12_AdventureQuest(int day) async {
    HapticFeedback.lightImpact();
    if (day == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CyberVocabGamePage(
            onCompleted: (_) => _onSubStepFinished(day, 12),
          ),
        ),
      );
    } else {
      await _onSubStepFinished(day, 12);
    }
  }

  // 13: Core Reading Notes & Story Aloud
  Future<void> _launchStep13_ReadingStory(int day) async {
    HapticFeedback.lightImpact();
    await PocketDayDetailOverviewPage.show(context, day);
    await _onSubStepFinished(day, 13);
  }

  // 14: Code English Decoder
  Future<void> _launchStep14_CodeEnglish(int day) async {
    HapticFeedback.lightImpact();
    await PocketCodeEnglishDecoderModal.show(context, currentDay: day);
    await _onSubStepFinished(day, 14);
  }

  // 15: Sovereign Fluency Shortcut
  Future<void> _launchStep15_Shortcut(int day) async {
    HapticFeedback.lightImpact();
    await PocketDayDetailOverviewPage.show(context, day);
    await _onSubStepFinished(day, 15);
  }

  // 16: Arm Home Defense Shield
  Future<void> _launchStep16_DefenseShield(int day) async {
    HapticFeedback.lightImpact();
    final myId = _supabase.auth.currentUser?.id;
    if (myId != null && myId.isNotEmpty) {
      await PocketCitadelAttackPage.openForUser(
        context,
        userId: myId,
        attackerDay: day,
        isDefenseMode: true,
      );
    } else {
      await PocketDefenseTrapModal.show(context, day, isLevelComplete: true);
    }
    await _onSubStepFinished(day, 16);
  }

  // 17: Level Mastery Boss Exam
  Future<void> _launchStep17_MasteryExam(int day, LearnerLevel level) async {
    HapticFeedback.heavyImpact();
    final passed = await PocketLevelExamDialog.show(
      context,
      level: day,
      trackLevel: level,
      onExamPassed: () async {
        await _onSubStepFinished(day, 17);
      },
    );
    if (passed == true) {
      await _onSubStepFinished(day, 17);
    }
  }

  /// Returns the sequential sub-steps along the climbing mountain trail (User Audio Directive!)
  List<InPathSubStep> _getSubStepsForDay(int day, LearnerLevel level) {
    final bool admin = _isMasterAdmin;
    if (day == 1) {
      final track = Day1Track.fromLearnerLevel(level);
      return Day1Curriculum.getSteps(track).map((step) {
        final flagKey = 'step_${step.stepNumber}';
        final isComp = _subStepFlags[flagKey] ?? false;
        final isUnlocked = admin ||
            step.stepNumber == 1 ||
            (_subStepFlags['step_${step.stepNumber - 1}'] ?? false);
        return InPathSubStep(
          stepIndex: step.stepNumber,
          title: step.title,
          subtitle: step.description,
          icon: step.icon,
          color: step.color,
          isCompleted: isComp,
          isUnlocked: isUnlocked,
          onAction: () async {
            int targetStepNumber = step.stepNumber;
            if (step.stepNumber == 1 && !isComp) {
              final prefs = await SharedPreferences.getInstance();
              final uid = widget.userId ?? 'guest';
              final diagDone = prefs.getBool('pm_day1_diagnostic_done_$uid') ?? false;
              if (!diagDone && mounted) {
                final diag = await PocketDay1DiagnosticSheet.show(context, userId: widget.userId);
                if (diag != null) {
                  final skip1 = diag['skipStep1'] ?? false;
                  final skip2 = diag['skipStep2'] ?? false;
                  if (skip1 && skip2) {
                    await _onSubStepFinished(1, 1);
                    await _onSubStepFinished(1, 2);
                    targetStepNumber = 3;
                  } else if (skip1) {
                    await _onSubStepFinished(1, 1);
                    targetStepNumber = 2;
                  }
                }
              }
            }
            if (!mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PocketDay1InteractiveFlowPage(
                  initialTrack: track,
                  initialStep: targetStepNumber,
                  onStepFinished: (s) => _onSubStepFinished(1, s),
                  onCompleted: () => _completeTodayTasks(),
                ),
              ),
            );
            await _loadData();
          },
        );
      }).toList();
    }
    return [
      InPathSubStep(
        stepIndex: 1,
        title: 'Interactive Teacher Class',
        subtitle: '1-on-1 Avatar game & sentence builder',
        icon: '🎮',
        color: const Color(0xFF3B82F6),
        isCompleted: _subStepFlags['step_1'] ?? false,
        isUnlocked: admin || _effectiveRulesAccepted,
        onAction: () => _launchStep1_Theory(day),
      ),
      InPathSubStep(
        stepIndex: 2,
        title: '10 Core Vocabulary Words',
        subtitle: 'Definitions, audio & native meanings',
        icon: '🧠',
        color: const Color(0xFFFF8906),
        isCompleted: _subStepFlags['step_2'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_1'] ?? false),
        onAction: () => _launchStep2_Vocab(day),
      ),
      InPathSubStep(
        stepIndex: 3,
        title: 'Alphabet & 44 Phonics',
        subtitle: 'Acoustic mouth placement frequencies',
        icon: '🔤',
        color: const Color(0xFFFF9100),
        isCompleted: _subStepFlags['step_3'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_2'] ?? false),
        onAction: () => _launchStep3_Phonics(day, level),
      ),
      InPathSubStep(
        stepIndex: 4,
        title: 'Fluency Gym Workout',
        subtitle: '8 vocal stations & speech reflexes',
        icon: '🎙️',
        color: const Color(0xFF10B981),
        isCompleted: _subStepFlags['step_4'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_3'] ?? false),
        onAction: () => _launchStep4_FluencyGym(day, level),
      ),
      InPathSubStep(
        stepIndex: 5,
        title: 'Secret Code Grammar',
        subtitle: 'Formula-based sentence codes',
        icon: '⚡',
        color: const Color(0xFFFFD700),
        isCompleted: _subStepFlags['step_5'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_4'] ?? false),
        onAction: () => _launchStep5_SecretCode(day),
      ),
      InPathSubStep(
        stepIndex: 6,
        title: 'Sentence Builder Puzzle',
        subtitle: 'Scrambled word block assembly',
        icon: '🏗️',
        color: const Color(0xFF00E5FF),
        isCompleted: _subStepFlags['step_6'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_5'] ?? false),
        onAction: () => _launchStep6_SentenceBuilder(day),
      ),
      InPathSubStep(
        stepIndex: 7,
        title: 'Slang to Smart English',
        subtitle: 'Professional native idioms',
        icon: '💬',
        color: const Color(0xFFFF6D00),
        isCompleted: _subStepFlags['step_7'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_6'] ?? false),
        onAction: () => _launchStep7_Slang(day),
      ),
      InPathSubStep(
        stepIndex: 8,
        title: 'Practice Speaking Aloud',
        subtitle: 'Speech tone & voice accuracy',
        icon: '🎤',
        color: const Color(0xFFE040FB),
        isCompleted: _subStepFlags['step_8'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_7'] ?? false),
        onAction: () => _launchStep8_Speaking(day),
      ),
      InPathSubStep(
        stepIndex: 9,
        title: 'Time Machine Verbs Trainer',
        subtitle: 'Past, present & future reflex drills',
        icon: '⏳',
        color: const Color(0xFFFFC107),
        isCompleted: _subStepFlags['step_9'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_8'] ?? false),
        onAction: () => _launchStep9_TimeMachine(day),
      ),
      InPathSubStep(
        stepIndex: 10,
        title: 'English Hub Community Chat',
        subtitle: 'Send 15 English peer messages',
        icon: '💬',
        color: const Color(0xFFFFFC00),
        isCompleted: _subStepFlags['step_10'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_9'] ?? false),
        onAction: () => _launchStep10_CommunityChat(day),
      ),
      InPathSubStep(
        stepIndex: 11,
        title: 'AI Speech Practice Lab',
        subtitle: 'Listen, repeat & AI pronunciation scoring',
        icon: '🗣️',
        color: const Color(0xFF38BDF8),
        isCompleted: _subStepFlags['step_11'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_10'] ?? false),
        onAction: () => _launchStep11_PeerCall(day),
      ),
      InPathSubStep(
        stepIndex: 12,
        title: 'Daily Adventure Quest',
        subtitle: 'Cyber vocab & career challenges',
        icon: '🎮',
        color: const Color(0xFFE11D48),
        isCompleted: _subStepFlags['step_12'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_11'] ?? false),
        onAction: () => _launchStep12_AdventureQuest(day),
      ),
      InPathSubStep(
        stepIndex: 13,
        title: 'Grammar Notes & Story Aloud',
        subtitle: 'Authentic multi-page story reading',
        icon: '📖',
        color: const Color(0xFF60A5FA),
        isCompleted: _subStepFlags['step_13'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_12'] ?? false),
        onAction: () => _launchStep13_ReadingStory(day),
      ),
      InPathSubStep(
        stepIndex: 14,
        title: 'Code English Decoder',
        subtitle: 'Mnemonic syntax algorithms',
        icon: '⚡',
        color: const Color(0xFF00FFCC),
        isCompleted: _subStepFlags['step_14'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_13'] ?? false),
        onAction: () => _launchStep14_CodeEnglish(day),
      ),
      InPathSubStep(
        stepIndex: 15,
        title: 'Sovereign Fluency Shortcut',
        subtitle: 'Colloquial speech contractions (കുറുക്കുവഴി)',
        icon: '⚡',
        color: const Color(0xFFFFB300),
        isCompleted: _subStepFlags['step_15'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_14'] ?? false),
        onAction: () => _launchStep15_Shortcut(day),
      ),
      InPathSubStep(
        stepIndex: 16,
        title: 'Arm Home Defense Shield',
        subtitle: 'Fortify front gate with grammar trap',
        icon: '🛡️',
        color: const Color(0xFF8B5CF6),
        isCompleted: _subStepFlags['step_16'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_15'] ?? false),
        onAction: () => _launchStep16_DefenseShield(day),
      ),
      InPathSubStep(
        stepIndex: 17,
        title: 'Level $day Mastery Exam',
        subtitle: 'Pass exam to certify & unlock House ${day + 1}',
        icon: '🎓',
        color: const Color(0xFF10B981),
        isCompleted: _subStepFlags['step_17'] ?? false,
        isUnlocked: admin || (_subStepFlags['step_16'] ?? false),
        onAction: () => _launchStep17_MasteryExam(day, level),
      ),
    ];
  }

  void _openAvatarCard(int day) {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      AuthAlertBox.checkAuthAndShowAlert(context: context);
      return;
    }
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
    if (uid == null || uid.isEmpty) {
      AuthAlertBox.checkAuthAndShowAlert(context: context);
      return;
    }
    if (_progress == null) return;

    HapticFeedback.heavyImpact();
    for (var task in _progress!.todayTasks) {
      await Learning60DayService().completeTask(userId: uid, taskId: task.id);
    }
    await PocketFortressDefenseService.recordActivityPoints('daily_mission');

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
                  'Today\'s English Missions Complete! +70 Score • +30 FDC Awarded.',
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

      // Prompt to craft Day's Defense Shield immediately in Citadel View
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          final myId = _supabase.auth.currentUser?.id;
          if (myId != null && myId.isNotEmpty) {
            PocketCitadelAttackPage.openForUser(
              context,
              userId: myId,
              attackerDay: _progress?.currentDay ?? 1,
              isDefenseMode: true,
            );
          } else {
            PocketDefenseTrapModal.show(
              context,
              _progress?.currentDay ?? 1,
              isLevelComplete: true,
            );
          }
        }
      });
    }
  }

  /// 🎯 Opens the dedicated Open World Level Adventure Page for the Day!
  /// User Audio Directive: "ഡീറ്റെയിൽ പേജ് ഇപ്പോഴത്തെ തന്നെ മതി, ഓരോ ദിവസത്തിലും കാർ ഡ്രൈവ് ചെയ്തു പോയി ടാസ്കുകളിൽ പോകുന്ന സാധനം!"
  void _startActiveSubStep(int day) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDayOpenWorldAdventurePage(
          day: day,
          userId: widget.userId ?? _supabase.auth.currentUser?.id,
          onCompleted: () => _loadData(),
        ),
      ),
    );
  }

  void _navigateToMissionPage(int day) {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      AuthAlertBox.checkAuthAndShowAlert(context: context);
      return;
    }
    HapticFeedback.selectionClick();
    // User Audio Directive: "DETAIL PAGE ILLA ennaanu njan parayaan ponathu. Onnum detail page-ilekku pondaaa!"
    // Directly launch the active in-path sub-step on the climbing trail!
    _startActiveSubStep(day);
  }

  // ignore: unused_element
  void _showLevelMissionDialog(int day) {
    HapticFeedback.lightImpact();
    final prog =
        _progress ?? UserLearningProgress(lastActiveDate: DateTime.now());
    final isCompleted = _isDayCompleted(day);
    final isUnlocked = _isDayUnlocked(day, prog.currentDay);
    final isCurrent = (day == prog.currentDay) && isUnlocked && !isCompleted;
    final lesson = EnglishCurriculumLesson.getLessonForDay(day);
    final stage = LearningMilestoneStage.getStageForDay(day);
    final avatarConfig = _getAvatarForDay(day);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131722),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Top Header: Level & Tier & Close
                Row(
                  children: [
                    Text(
                      'Level $day',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        stage.fluencyTier.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: PocketSyllabusRepository.getTrack(_currentLearnerLevel).primaryColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: PocketSyllabusRepository.getTrack(_currentLearnerLevel).primaryColor.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PocketSyllabusRepository.getTrack(_currentLearnerLevel).icon,
                            size: 10,
                            color: PocketSyllabusRepository.getTrack(_currentLearnerLevel).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            PocketSyllabusRepository.getTrack(_currentLearnerLevel).nameEn,
                            style: GoogleFonts.inter(
                              color: PocketSyllabusRepository.getTrack(_currentLearnerLevel).primaryColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lesson Title & Avatar Row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _openAvatarCard(day);
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: VectorAvatarWidget(
                            config: avatarConfig,
                            size: 36,
                            showAura: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            lesson.focusArea,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w500,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Clean Minimal Tasks List
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMissionRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: const Color(0xFF10B981),
                        title: 'Peer Chat',
                        subtitle: lesson.peerChatMission,
                        isDone: isCompleted,
                      ),
                      const SizedBox(height: 6),
                      _buildMissionRow(
                        icon: Icons.mic_none_rounded,
                        color: const Color(0xFF38BDF8),
                        title: 'Speaking Drill',
                        subtitle: lesson.speakingDrill,
                        isDone: isCompleted,
                      ),
                      const SizedBox(height: 6),
                      _buildMissionRow(
                        icon: Icons.psychology_outlined,
                        color: const Color(0xFFFFD700),
                        title: 'Grammar',
                        subtitle: lesson.grammarConcept,
                        isDone: isCompleted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Minimal Rewards Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'PS ${PocketScoreLevelEngine.getRequiredScoreForLevel(day)}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.white30, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(
                      '+${lesson.xpReward} XP',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFC00),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.white30, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(
                      '${lesson.targetMinutes}m Practice',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ⚔️ Direct Citadel Attack Action (User Audio Directive: House 4+ Attack Arena)
                if (day >= 4) ...[
                  StatefulBuilder(
                    builder: (context, setModalState) {
                      return FutureBuilder<PocketNeighbor>(
                        future: PocketFortressDefenseService.getRecommendedRivalTarget(
                          userDay: day,
                          shuffleOffset: _levelRivalShuffleSeed,
                        ),
                        builder: (context, snapshot) {
                          final rival = snapshot.data;
                          final targetLevel = rival?.day ?? PocketFortressDefenseService.getRecommendedTargetLevel(day);
                          final rivalName = rival?.name ?? 'Challenger Lvl $targetLevel';
                          final isRobo = rival?.isPocketRobo ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF881337).withValues(alpha: 0.35),
                                  const Color(0xFF4C0519).withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFB7185).withValues(alpha: 0.4), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(isRobo ? '🤖' : '⚔️', style: const TextStyle(fontSize: 18)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'CITADEL RAID CHALLENGE',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFECDD3),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              setModalState(() {
                                                _levelRivalShuffleSeed++;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(6),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.shuffle_rounded, size: 10, color: Color(0xFFFDA4AF)),
                                                  SizedBox(width: 2),
                                                  Text('Reroll 🎲', style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$rivalName (Lvl $targetLevel)',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        isRobo ? '🤖 AI Robot Citadel • Balanced Fair Defense' : '👤 Real Human House • Higher Loot',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final hubContext = context;
                                    Navigator.pop(ctx);
                                    HapticFeedback.heavyImpact();
                                    final activeRival = rival ?? await PocketFortressDefenseService.getRecommendedRivalTarget(userDay: day);
                                    if (!mounted || !hubContext.mounted) return;
                                    PocketCitadelAttackPage.openForUser(
                                      hubContext,
                                      userId: activeRival.id,
                                      neighbor: activeRival,
                                      attackerDay: day,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE11D48),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'ATTACK ⚔️',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ] else ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🔒', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HOUSE RAIDS UNLOCK AT HOUSE 4',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFBBF24),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Master foundational grammar in Houses 1–3 first. Level 4–10+ student fortresses unlock at Day 4!',
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Buttons
                if (isCurrent || isUnlocked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _navigateToMissionPage(day);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrent ? const Color(0xFFFFFC00) : const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            isCurrent ? 'START MISSION' : 'ENTER LEVEL $day',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _completeTodayTasks();
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 24),
                          tooltip: 'Complete tasks',
                        ),
                      ],
                    ],
                  ),
                ] else if (isCompleted) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PocketDailyMissionPage(
                              day: day,
                              onMissionCompleted: () => _loadData(),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'REVIEW LEVEL $day (COMPLETED ✓)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // 1. Check if previous level is not completed
                  if (day > 1 && !_isDayCompleted(day - 1)) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Level $day is locked! You must complete Level ${day - 1} and pass its exam first.',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF87171),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],



                  // 2. Check if waiting for midnight
                  if (_isDayWaitingForMidnight(day)) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⏳', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                'House $day Unlocks At Midnight',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Learning60DayService.formatRemainingCountdown(_timeUntilMidnight),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Free learners pace at 1 House per day to build retention.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 👑 Poket VIP: Instant Binge Mode
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium_rounded, size: 18, color: Colors.black),
                        label: Text(
                          '👑 UNLOCK INSTANT BINGE MODE • Poket VIP',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _navigateToMissionPage(day);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Preview Level $day',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
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

  /// ⚔️ Citadel Matchmaking Modal (User Audio Directive: House 4+ Attack Arena)
  /// Features target rival matchmaking (Levels 4 to 10+), profile details, 🎲 Reroll/Shuffle, and direct attack launcher.
  // ignore: unused_element
  void _showCitadelMatchmakingModal(int userDay) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E112A), Color(0xFF0F0B18)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: const Color(0xFFFB7185).withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('⚔️', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CITADEL RAID ARENA',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFDA4AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Attack Rival Student Fortresses (Lvl 4–10+)',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalCtx),
                          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rival Card Builder
                    FutureBuilder<PocketNeighbor>(
                      future: PocketFortressDefenseService.getRecommendedRivalTarget(
                        userDay: userDay,
                        shuffleOffset: _levelRivalShuffleSeed,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 140,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFB7185),
                            ),
                          );
                        }

                        final rival = snapshot.data;
                        final targetLevel = rival?.day ?? PocketFortressDefenseService.getRecommendedTargetLevel(userDay);
                        final rivalName = rival?.name ?? 'Challenger Lvl $targetLevel';
                        final isRobo = rival?.isPocketRobo ?? false;
                        final bio = (rival != null && rival.statusMessage.isNotEmpty)
                            ? rival.statusMessage
                            : (isRobo ? 'Pocket AI Sentinel • Automated 4-Defense Trap System' : 'Dedicated English Learner');

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF881337).withValues(alpha: 0.4),
                                const Color(0xFF4C0519).withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFB7185).withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFFDA4AF),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: VectorAvatarWidget(
                                        config: _getAvatarForDay(targetLevel),
                                        size: 52,
                                        showAura: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              isRobo ? '🤖 AI ROBOT CITADEL' : '👤 RIVAL LEARNER',
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFFECDD3),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'House Lvl $targetLevel',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(0xFFFDA4AF),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          rivalName,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          bio,
                                          style: GoogleFonts.inter(
                                            color: Colors.white60,
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
                              const SizedBox(height: 14),

                              // Matchmaking Stats / Loot Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('🪙 ', style: TextStyle(fontSize: 12)),
                                        Text('+50 Coins', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Container(width: 1, height: 14, color: Colors.white12),
                                    Row(
                                      children: [
                                        const Text('🏆 ', style: TextStyle(fontSize: 12)),
                                        Text('+30 Trophies', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Container(width: 1, height: 14, color: Colors.white12),
                                    Row(
                                      children: [
                                        const Text('🛡️ ', style: TextStyle(fontSize: 12)),
                                        Text('4 Trap Shields', style: GoogleFonts.outfit(color: const Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Actions: Shuffle / Launch
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      setModalState(() {
                                        _levelRivalShuffleSeed++;
                                      });
                                    },
                                    icon: const Icon(Icons.shuffle_rounded, size: 14, color: Color(0xFFFDA4AF)),
                                    label: Text(
                                      'Reroll 🎲',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFDA4AF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFFDA4AF)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final hubContext = context;
                                        Navigator.pop(modalCtx);
                                        HapticFeedback.heavyImpact();
                                        final activeRival = rival ?? await PocketFortressDefenseService.getRecommendedRivalTarget(userDay: userDay);
                                        if (!mounted || !hubContext.mounted) return;
                                        PocketCitadelAttackPage.openForUser(
                                          hubContext,
                                          userId: activeRival.id,
                                          neighbor: activeRival,
                                          attackerDay: userDay,
                                        );
                                      },
                                      icon: const Icon(Icons.flash_on_rounded, size: 16),
                                      label: Text(
                                        'LAUNCH RAID ⚔️',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE11D48),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 10.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isDone)
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 15),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prog =
        _progress ?? UserLearningProgress(lastActiveDate: DateTime.now());
    final screenWidth = MediaQuery.of(context).size.width;
    final totalMapHeight = _ruleNodeY + _bottomPadding;
    final targetActiveDay = _adminSelectedDay ?? prog.currentDay;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      body: Stack(
        children: [
          // 1. The Scrollable Game World Map with Pull-to-Refresh
          RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFFFD700),
            backgroundColor: const Color(0xFF13172A),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                          currentDay: targetActiveDay,
                          screenWidth: screenWidth,
                          nodeSpacingY: _nodeSpacingY,
                          topPadding: _topPadding,
                          ruleNodeY: _ruleNodeY,
                          hasAcceptedRules: _effectiveRulesAccepted,
                        ),
                      ),
                    ),

                    // Biome Zone Banners & Scenery Props
                    ..._buildBiomeProps(screenWidth),

                    // 🏡 Viewport-Culled 90 Progressive Architectural English Houses & 3D Level Nodes
                    // User Audio Directive: "hang aavaruthu... lightweight aayirikkanam... lazy loading okke koduthittu"
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, _) {
                          final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 999999.0;
                          final screenH = MediaQuery.of(context).size.height;
                          final minY = scrollOffset;
                          final maxY = scrollOffset + screenH;

                          return Stack(
                            children: [
                              // 🏡 90 Progressive Architectural English Houses (Viewport Culled)
                              for (int day = 1; day <= _totalDays; day++)
                                if (_isDayInViewport(day, minY, maxY))
                                  _buildRoadmapHouse(day, screenWidth, targetActiveDay),

                              // 🏰 Fortress Exam Gates & Stone Walls between Houses (User Audio Directive!)
                              for (int day = 1; day < _totalDays; day++)
                                if (_isDayInViewport(day, minY, maxY))
                                  _buildRoadmapGate(day, screenWidth, targetActiveDay),

                              // Interactive 3D Level Nodes (Days 1 to 90) (Viewport Culled)
                              for (int day = 1; day <= _totalDays; day++)
                                if (_isDayInViewport(day, minY, maxY))
                                  _buildLevelNode(day, screenWidth, targetActiveDay),
                            ],
                          );
                        },
                      ),
                    ),

                    // 📚 Minimal Syllabus Track Selector Menu directly above Rules / Level 1 Node (Audio Directive!)
                    _buildSyllabusSelectorMenu(screenWidth),

                    // 📜 Special "Rule" Level Node (Audio Directive: Before Level 1, show Rule level)
                    _buildRuleLevelNode(screenWidth),

                    // Bouncing Animated Character Avatar at Current Level or Rules Node
                    _buildAnimatedAvatar(screenWidth, targetActiveDay),
                  ],
                ),
              ),
            ),
          ),

              // Subtle non-blocking loading shimmer beneath top HUD
              if (_isLoading || _isRefreshing)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70,
                  left: 0,
                  right: 0,
                  child: const LinearProgressIndicator(
                    minHeight: 2.5,
                    color: Color(0xFFFFD700),
                    backgroundColor: Colors.transparent,
                  ),
                ),

              // 2. Sticky Glassmorphism Top HUD (Without Back button on tab navigation!)
              _buildTopHUD(prog),

                // 3. ⚔️ & 🌐 & ⏳ Minimal Floating Actions Dock + Mission Button
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: Row(
                    children: [
                      // Left actions: Battle, Open World, Time Machine
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMinimalFloatingPill(
                                icon: '🌐',
                                label: 'Open World',
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PocketOpenWorldGamePage(
                                        currentDay: prog.currentDay,
                                        streak: prog.streakDays,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right: 🎯 Minimal Today Mission Button
                      InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (!_effectiveRulesAccepted) {
                            PocketWorldGameRulesModal.show(
                              context,
                              currentDay: targetActiveDay,
                              onPledgeAccepted: () {
                                setState(() => _hasAcceptedRules = true);
                                _loadData();
                              },
                            );
                            return;
                          }
                          _scrollToDay(targetActiveDay, animate: true);
                          _navigateToMissionPage(targetActiveDay);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFC00),
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
                              Icon(
                                !_effectiveRulesAccepted ? Icons.menu_book_rounded : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                !_effectiveRulesAccepted ? 'Rules 📜' : 'Mission $targetActiveDay',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. 🚀 Mobile Fast Scroll Scrubber Bar on right side (User Audio Directive!)
                _buildFastScrollScrubber(screenWidth, MediaQuery.of(context).size.height),
              ],
            ),
    );
  }

  /// 🚀 Vertical Fast Scroll Scrubber Bar on right side
  /// User Audio Directive: "Scroll cheyyan vendittu side-il oru scrolling bar vekkuka. Mobile-il ullavarkkum speed-il mele scroll cheythu ariyaan vendittu."
  Widget _buildFastScrollScrubber(double screenWidth, double screenHeight) {
    final topPadding = MediaQuery.of(context).padding.top;
    final scrubberTop = topPadding + 65.0; // Moved upwards per User Audio directive!
    final scrubberBottom = 90.0;
    final scrubberHeight = (screenHeight - scrubberTop - scrubberBottom).clamp(160.0, 720.0);

    return Positioned(
      right: 5,
      top: scrubberTop,
      width: 34,
      height: scrubberHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          if (!_scrollController.hasClients) return;
          final localY = details.localPosition.dy.clamp(0.0, scrubberHeight);
          final newFraction = (localY / scrubberHeight).clamp(0.0, 1.0);
          final targetOffset = newFraction * _scrollController.position.maxScrollExtent;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(targetOffset);
            }
          });
        },
        onTapDown: (details) {
          if (!_scrollController.hasClients) return;
          final localY = details.localPosition.dy.clamp(0.0, scrubberHeight);
          final newFraction = (localY / scrubberHeight).clamp(0.0, 1.0);
          final targetOffset = newFraction * _scrollController.position.maxScrollExtent;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                targetOffset,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              );
            }
          });
        },
        child: Container(
          width: 34,
          height: scrubberHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1524).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Top milestone: Summit Citadel
              const Positioned(
                top: 6,
                child: Text('🏰', style: TextStyle(fontSize: 10)),
              ),
              Positioned(
                top: scrubberHeight * 0.33,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white30,
                  ),
                ),
              ),
              Positioned(
                top: scrubberHeight * 0.66,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white30,
                  ),
                ),
              ),
              // Bottom milestone: Valley House 1
              const Positioned(
                bottom: 6,
                child: Text('🏡', style: TextStyle(fontSize: 10)),
              ),

              // Draggable Glowing Thumb with Live Day Badge (Rebuilt smoothly on scroll)
              AnimatedBuilder(
                animation: _scrollController,
                builder: (context, _) {
                  double fraction = 1.0;
                  if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
                    fraction = (_scrollController.offset / _scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
                  }
                  // Inverted map: offset 0 is Day 90 (summit), offset max is Day 1 (valley)
                  final approximateDay = ((1.0 - fraction) * 89 + 1).round().clamp(1, 90);

                  return Positioned(
                    top: (fraction * (scrubberHeight - 34)).clamp(0.0, scrubberHeight - 34),
                    child: Container(
                      width: 28,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.drag_indicator_rounded, size: 10, color: Colors.black),
                          Text(
                            '$approximateDay',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalFloatingPill({
    required String icon,
    required String label,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: highlightColor != null
              ? highlightColor.withValues(alpha: 0.18)
              : const Color(0xFF131722).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlightColor?.withValues(alpha: 0.6) ?? Colors.white12,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: highlightColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHUD(UserLearningProgress prog) {
    final canPop = Navigator.of(context).canPop();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 4,
          bottom: 6,
          left: 10,
          right: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1524).withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Compact 90-Day Mission Badge + Stats + Actions
            Row(
              children: [
                    if (canPop) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 16),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                    ],

                // Minimal Day Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: Text(
                    _isMasterAdmin && _adminSelectedDay != null
                        ? 'Day $_adminSelectedDay'
                        : 'Day ${prog.currentDay}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 🪙 Pocket Score (PS) & 🏆 Trophies Capsule (Audio Directive: Show PS, Coins, and Trophies count)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'PS',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '🪙 $_unifiedPocketScore',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 1,
                        height: 12,
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '🏆 $_unifiedTrophies',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 🔄 Refresh Button (User Audio Directive: "ഒരു റീഫ്രഷ് ചെയ്യാനുള്ള ബട്ടൺ കൊടുക്കണം കേട്ടോ അവിടെ")
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    setState(() => _isRefreshing = true);
                    await _loadData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Roadmap Refreshed! Day ${prog.currentDay} • 🪙 $_unifiedPocketScore PTS • 🏆 $_unifiedTrophies',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          duration: const Duration(milliseconds: 1200),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: _isRefreshing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
                          )
                        : const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 8),

                // 🏪 Minimal Store Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    PocketArsenalStoreModal.show(
                      context,
                      currentDay: prog.currentDay,
                      onPurchased: () async {
                        await _loadData();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏪', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          'Store',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 🔊 Minimal BGM Speaker Toggle (Audio Directive)
                ValueListenableBuilder<bool>(
                  valueListenable: PocketGameAudioService.instance.isMutedNotifier,
                  builder: (context, isMuted, _) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        PocketGameAudioService.instance.toggleMute();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMuted ? Colors.white24 : const Color(0xFFFFFC00).withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: isMuted ? Colors.white54 : const Color(0xFFFFFC00),
                          size: 15,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 🎯 Minimal Horizontal Level Milestones Strip
            _buildMilestonesStrip(prog),
          ],
        ),
      ),
    );
  }

  /// 🎯 Minimal Horizontal Level Milestones Strip (Audio Requirement!)
  Widget _buildMilestonesStrip(UserLearningProgress prog) {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kTargetMilestones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final item = kTargetMilestones[index];
          final isRule = item.stageNumber == 0;
          final isUnlocked =
              isRule ? _hasAcceptedRules : prog.currentDay >= item.targetDay;
          final isCurrentTarget = isRule
              ? !_hasAcceptedRules
              : (prog.currentDay <= item.targetDay &&
                  (index <= 1 ||
                      prog.currentDay >
                          kTargetMilestones[index - 1].targetDay));

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (item.stageNumber == 0) {
                PocketWorldGameRulesModal.show(
                  context,
                  currentDay: prog.currentDay,
                  onPledgeAccepted: () {
                    setState(() => _hasAcceptedRules = true);
                  },
                );
              } else if (item.stageNumber == 6 || item.stageNumber == 7) {
                if (!_hasConqueredCitadel) {
                  _showCitadelRequiredForCertificateDialog();
                } else {
                  Day90MasterCertificateDialog.show(
                    context,
                    userName: 'Sovereign Grandmaster',
                    userDay: 91,
                  );
                }
              } else {
                _showTargetStagePreviewDialog(item, prog.currentDay);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isCurrentTarget
                    ? item.themeColor.withValues(alpha: 0.20)
                    : (isUnlocked
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrentTarget
                      ? item.themeColor
                      : (isUnlocked ? const Color(0xFF10B981) : Colors.white12),
                  width: isCurrentTarget ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.houseEmoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    isRule
                        ? item.title
                        : '${item.title} (PS ${PocketScoreLevelEngine.getRequiredScoreForLevel(item.targetDay)}${PocketScoreLevelEngine.getRequiredTrophiesForLevel(item.targetDay) > 0 ? " & 🏆${PocketScoreLevelEngine.getRequiredTrophiesForLevel(item.targetDay)} Trophy" : ""})',
                    style: GoogleFonts.outfit(
                      color: isCurrentTarget
                          ? item.themeColor
                          : (isUnlocked
                              ? const Color(0xFF10B981)
                              : Colors.white70),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    isRule
                        ? (_hasAcceptedRules ? '✓' : '📜')
                        : (isUnlocked ? '✓' : (isCurrentTarget ? '🔥' : '🔒')),
                    style: const TextStyle(fontSize: 8.5),
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
        backgroundColor: const Color(0xFF131722),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isUnlocked
                                ? 'Pocket Score Target: PS ${PocketScoreLevelEngine.getRequiredScoreForLevel(item.targetDay)} (Achieved ✓)'
                                : 'Pocket Score Target: PS ${PocketScoreLevelEngine.getRequiredScoreForLevel(item.targetDay)} (${math.max(0, PocketScoreLevelEngine.getRequiredScoreForLevel(item.targetDay) - _unifiedPocketScore)} PS needed)',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (PocketScoreLevelEngine.getRequiredTrophiesForLevel(item.targetDay) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Required Pocket Talk Trophies: 🏆 ${PocketScoreLevelEngine.getRequiredTrophiesForLevel(item.targetDay)}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF00E5FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Earned through 4-Day Pocket Talk Spoken Pacts in Mates Chat. Complete spoken pacts to cross this milestone!',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
              'Completing this daily target upgrades your house architecture, evolves your learning avatar, and unlocks advanced fortress defense traps.',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Text('⚔️', style: TextStyle(fontSize: 14)),
            label: Text('ATTACK TARGET CITADEL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              final rival = await PocketFortressDefenseService.getRecommendedRivalTarget(userDay: item.targetDay);
              if (!mounted) return;
              PocketCitadelAttackPage.openForUser(
                context,
                userId: rival.id,
                neighbor: rival,
                attackerDay: currentDay,
              );
            },
          ),
        ],
      ),
    );
  }

  /// 📝 Open CEFR Syllabus Interactive Examination
  // ignore: unused_element
  void _openSyllabusExamination(SyllabusTrack track) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SyllabusExamDialog(
        track: track,
        currentDay: _progress?.currentDay ?? 1,
        onExamCompleted: (score) {
          setState(() {
            _unifiedPocketScore += (score * 30);
          });
          _loadData();
        },
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
        backgroundColor: const Color(0xFF131722),
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


  /// 📚 Minimal Syllabus Track Selector Menu directly above the Rules / Level 1 Node (User Audio Directive!)
  /// Displays "YOUR SYLLABUS" initially as generated during onboarding.
  /// Tapping opens the 6-track switcher without any bottomsheet.
  Widget _buildSyllabusSelectorMenu(double screenWidth) {
    final track = PocketSyllabusRepository.getTrack(_currentLearnerLevel);
    final x = screenWidth / 2;
    // Positioned cleanly right above the Rules node (_ruleNodeY is 240, top of sphere is 203)
    final y = _ruleNodeY - 54.0;
    final pillWidth = _hasCustomSelectedSyllabus ? 188.0 : 164.0;

    return Positioned(
      left: x - (pillWidth / 2),
      top: y,
      width: pillWidth,
      child: PopupMenuButton<LearnerLevel?>(
        tooltip: 'Your Syllabus',
        color: const Color(0xFF131722),
        elevation: 14,
        offset: const Offset(0, 34),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: (_hasCustomSelectedSyllabus ? track.primaryColor : const Color(0xFFFFD700)).withValues(alpha: 0.8),
            width: 1.3,
          ),
        ),
        onSelected: (level) async {
          if (level == null) return;
          HapticFeedback.selectionClick();
          await PocketSyllabusRepository.saveLevel(level);
          final uid = widget.userId ?? _supabase.auth.currentUser?.id;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('pocket_has_custom_syllabus_selection_${uid ?? "guest"}', true);
          setState(() {
            _hasCustomSelectedSyllabus = true;
            _currentLearnerLevel = level;
          });

          // Sync to Supabase profile so the selected level persists globally
          if (uid != null) {
            try {
              await _supabase.from('profile').update({
                'english_level': level.name,
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('user_id', uid);
            } catch (e) {
              debugPrint('Notice: Error updating profile english_level on syllabus switch: $e');
            }
          }

          // Dynamically refresh learning hub and missions to immediately reflect switched track
          await _loadData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(PocketSyllabusRepository.getTrack(level).icon,
                        color: const Color(0xFFFFFC00), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Syllabus Track switched to ${PocketSyllabusRepository.getTrack(level).nameEn}! 🎯',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E2438),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        itemBuilder: (context) {
          return LearnerLevel.values.map((lvl) {
            final t = PocketSyllabusRepository.getTrack(lvl);
            final isSelected = lvl == _currentLearnerLevel;
            return PopupMenuItem<LearnerLevel?>(
              value: lvl,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: t.primaryColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(t.icon, color: t.primaryColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.nameEn,
                          style: GoogleFonts.outfit(
                            color: isSelected ? const Color(0xFFFFFC00) : Colors.white,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          t.badgeText,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 9.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFFFFFC00), size: 16),
                  ],
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          width: pillWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1424).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (_hasCustomSelectedSyllabus ? track.primaryColor : const Color(0xFFFFD700)).withValues(alpha: 0.7),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (_hasCustomSelectedSyllabus ? track.primaryColor : const Color(0xFFFFD700)).withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_hasCustomSelectedSyllabus) ...[
                const Text('📘', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'YOUR SYLLABUS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFFFD700), size: 16),
              ] else ...[
                Icon(track.icon, color: track.primaryColor, size: 12),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'SYLLABUS: ${track.nameEn.replaceAll(' Track', '').toUpperCase()}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 9.5,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down_rounded, color: track.primaryColor, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 📜 Special "Rule" Level Node (Audio Directive: Before Level 1, show Rule level)
  Widget _buildRuleLevelNode(double screenWidth) {
    final x = screenWidth / 2;
    final y = _ruleNodeY;
    const nodeSize = 74.0;

    return Positioned(
      left: x - (nodeSize / 2),
      top: y - (nodeSize / 2),
      width: nodeSize,
      height: nodeSize + 24,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          PocketWorldGameRulesModal.show(
            context,
            currentDay: _progress?.currentDay ?? 1,
            onPledgeAccepted: () {
              setState(() => _hasAcceptedRules = true);
              _loadData();
            },
          );
        },
        child: SizedBox(
          width: nodeSize,
          height: nodeSize + 24,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Pulsing glow if not accepted yet
              if (!_hasAcceptedRules)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _bobController,
                    builder: (context, child) {
                      final scale = 1.0 + (_bobController.value * 0.24);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFFC00).withValues(
                                  alpha: 0.75 - (_bobController.value * 0.4)),
                              width: 3.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 3D Stepping Stone
              Container(
                width: nodeSize,
                height: nodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _hasAcceptedRules
                        ? [const Color(0xFF10B981), const Color(0xFF047857)]
                        : [const Color(0xFFFF8906), const Color(0xFFE53E3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _hasAcceptedRules
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFFFFFC00),
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_hasAcceptedRules
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFF8906))
                          .withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📜', style: TextStyle(fontSize: 24)),
                      Text(
                        _hasAcceptedRules ? 'RULES' : 'GET STARTED',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: _hasAcceptedRules ? 10 : 8.5,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Verification badge
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: _hasAcceptedRules
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFFC00),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _hasAcceptedRules ? Colors.white38 : Colors.black26,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _hasAcceptedRules ? '✓ VERIFIED' : 'START HERE 🔥',
                    style: GoogleFonts.outfit(
                      color: _hasAcceptedRules ? Colors.white : Colors.black,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
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

  Widget _buildLevelNode(int day, double screenWidth, int currentDay) {
    if (day == 91) {
      return _buildLevel91ApexNode(screenWidth, currentDay);
    }
    final x = _getNodeX(day, screenWidth);
    final y = _getNodeY(day);
    // User audio requirement: Before Get Started rules are accepted, Day 1 must stay LOCKED!
    final isLockedByRules = (day == 1 && !_hasAcceptedRules);
    final isWaitingForMidnight = _isDayWaitingForMidnight(day);
    final isCompleted = _isDayCompleted(day) && _hasAcceptedRules && !isWaitingForMidnight;
    final isUnlocked = _isDayUnlocked(day, currentDay) && !isLockedByRules && !isWaitingForMidnight;
    final isCurrent = (day == currentDay) && isUnlocked && !isCompleted;
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
        onTap: () {
          HapticFeedback.lightImpact();
          if (!_effectiveRulesAccepted && day == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF131722),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                ),
                content: Row(
                  children: [
                    const Text('📜', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Read and accept all 12 Rules first to unlock Day 1!',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
            PocketWorldGameRulesModal.show(
              context,
              currentDay: currentDay,
              onPledgeAccepted: () {
                setState(() => _hasAcceptedRules = true);
                _loadData();
              },
            );
            return;
          }
          if (_isMasterAdmin) {
            setState(() {
              _adminSelectedDay = day;
            });
            _startActiveSubStep(day);
            return;
          }
          if (isCompleted) {
            _startActiveSubStep(day);
            return;
          }
          if (isWaitingForMidnight) {
            _showMidnightLockedToast(day);
            return;
          }
          if (isUnlocked || isCurrent) {
            _startActiveSubStep(day);
            return;
          }
          _showLevelLockedToast(day);
        },
        child: SizedBox(
          width: nodeSize,
          height: nodeSize + (isWaitingForMidnight ? 24 : 20),
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
                    colors: isWaitingForMidnight
                        ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                        : (isCurrent
                            ? [const Color(0xFFFFFC00), const Color(0xFFFF8906)]
                            : (isCompleted
                                ? [const Color(0xFF10B981), const Color(0xFF047857)]
                                : (isUnlocked
                                    ? [const Color(0xFF00E5FF), const Color(0xFF0284C7)]
                                    : (isBossMilestone
                                        ? [const Color(0xFF475569), const Color(0xFF1E293B)]
                                        : [const Color(0xFF2A314A), const Color(0xFF181C2E)])))),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isWaitingForMidnight
                        ? const Color(0xFFFFD700)
                        : (isCurrent
                            ? Colors.white
                            : (isCompleted
                                ? const Color(0xFF6EE7B7)
                                : (isUnlocked
                                    ? const Color(0xFF38BDF8)
                                    : (isBossMilestone
                                        ? const Color(0xFFFFD700)
                                        : Colors.white.withValues(alpha: 0.22))))),
                    width: (isCurrent || isWaitingForMidnight) ? 3.0 : 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isWaitingForMidnight
                          ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                          : (isCurrent
                              ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
                              : (isCompleted
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : (isUnlocked
                                      ? const Color(0xFF00E5FF).withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.5)))),
                      blurRadius: (isCurrent || isUnlocked || isWaitingForMidnight) ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isWaitingForMidnight
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⏳', style: TextStyle(fontSize: 15)),
                            Text(
                              '$day',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: isBossMilestone ? 18 : 14,
                              ),
                            ),
                          ],
                        )
                      : (isCompleted
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
                              : (isUnlocked
                                  ? Text(
                                      '$day',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
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
                                        ))))),
                ),
              ),

              // 🪙 Pocket Score (PS) Target Badge Under Each Level Node (Audio Directive: Significantly larger & prominent!)
              if (!isWaitingForMidnight)
                Positioned(
                  top: nodeSize - 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFFFFC00)
                          : (isCompleted
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.black38
                            : (isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFFD700).withValues(alpha: 0.6)),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrent
                              ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.6),
                          blurRadius: isCurrent ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Builder(
                      builder: (context) {
                        final reqScore = PocketScoreLevelEngine.getRequiredScoreForLevel(day);
                        final reqTrophies = PocketScoreLevelEngine.getRequiredTrophiesForLevel(day);
                        final label = reqTrophies > 0
                            ? 'PS $reqScore • 🏆$reqTrophies'
                            : 'PS $reqScore';
                        return Text(
                          label,
                          style: GoogleFonts.outfit(
                            color: isCurrent
                                ? Colors.black
                                : (isCompleted
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFFD700)),
                            fontWeight: FontWeight.w900,
                            fontSize: 11.0,
                            letterSpacing: 0.3,
                          ),
                        );
                      },
                    ),
                    ),
                  ),
                ),

              // ⏳ Live Midnight Countdown Pill under waiting node
              if (isWaitingForMidnight)
                Positioned(
                  top: nodeSize + 3,
                  left: -35,
                  right: -35,
                  child: Center(
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B4B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700), width: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 8)),
                        const SizedBox(width: 3),
                        Text(
                          Learning60DayService.formatRemainingCountdown(_timeUntilMidnight),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),

              // 3 Shiny Stars over completed nodes
              if (isCompleted)
                Positioned(
                  top: -12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                ),
            ],

          ),
        ),
      ),
    );
  }

  /// 🏡 90 Progressive Architectural English Houses along the Climbing Mountain Trail (User Audio Directive!)
  /// Renders the progressive English architectural house at each level.
  /// The road climbs directly to the front entrance / doorstep of each house.
  /// When completed, the house glows with warm windows and flame effects.
  Widget _buildRoadmapHouse(int day, double screenWidth, int currentDay) {
    if (day == 91) {
      return _buildLevel91MiniCard(screenWidth, currentDay);
    }
    final nodeX = _getNodeX(day, screenWidth);
    final nodeY = _getNodeY(day);
    final isWaitingForMidnight = _isDayWaitingForMidnight(day);
    final isUnlocked = _isDayUnlocked(day, currentDay) && (day > 1 || _hasAcceptedRules) && !isWaitingForMidnight;
    final isCompleted = _isDayCompleted(day);
    final isCurrent = (day == currentDay) && isUnlocked && !isCompleted;

    // Responsive dimensions for the architectural house along the mountain path
    final double houseWidth = (screenWidth * 0.56).clamp(200.0, 250.0);
    const double houseHeight = 138.0;

    // Center the house on nodeX, but keep safely within screen margins
    final double houseLeft = (nodeX - (houseWidth / 2.0)).clamp(8.0, screenWidth - houseWidth - 8.0);
    // Align house so its doorstep sits right behind/under the level stepping stone (nodeY)
    final double houseTop = nodeY - houseHeight + 24.0;

    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(day);
    final palette = HousePalette.presets[(day - 1) % HousePalette.presets.length];
    final avatarConfig = _getAvatarForDay(day);

    return Positioned(
      left: houseLeft,
      top: houseTop,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (!_effectiveRulesAccepted && day == 1) {
            PocketWorldGameRulesModal.show(
              context,
              currentDay: currentDay,
              onPledgeAccepted: () {
                setState(() => _hasAcceptedRules = true);
                _loadData();
              },
            );
            return;
          }
          if (_isMasterAdmin) {
            setState(() {
              _adminSelectedDay = day;
            });
            _startActiveSubStep(day);
            return;
          }
          if (isCompleted) {
            _startActiveSubStep(day);
            return;
          }
          if (isWaitingForMidnight) {
            _showMidnightLockedToast(day);
            return;
          }
          if (isUnlocked || isCurrent) {
            _startActiveSubStep(day);
            return;
          }
          _showLevelLockedToast(day);
        },
        child: SizedBox(
          width: houseWidth,
          height: houseHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Warm Flame Aura / Glow Behind the House when Completed or Current (Audio Directive: "athinu kazhinja udane flame okke kodukkaam")
              if (isCompleted || isCurrent)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isCompleted
                              ? const Color(0xFFFF5722).withValues(alpha: 0.28)
                              : const Color(0xFFFFFC00).withValues(alpha: 0.22),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

              // 2. High-performance RepaintBoundary wrapping HouseMasterPainter
              // User Audio Directive: "disabled aavunna pole color kalanjittu nilkkande. Ella veedukalukkum color vecho, pakshe lock aakki vechaal mathi"
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size(houseWidth, houseHeight),
                    painter: HouseMasterPainter(
                      day: day,
                      palette: palette,
                      isPresident: (day >= 90),
                      lightsOn: isCompleted || isCurrent,
                    ),
                  ),
                ),
              ),

              // 3. Estate Title & Stage Pill at the Top of the House
              Positioned(
                top: 2,
                left: 6,
                right: 36, // space for avatar guardian chip
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFFFFC00)
                          : (isCompleted
                              ? const Color(0xFFFF7043)
                              : (isUnlocked ? Colors.white24 : Colors.white10)),
                      width: isCurrent || isCompleted ? 1.2 : 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCompleted
                            ? '🔥'
                            : (isCurrent
                                ? '📍'
                                : (isWaitingForMidnight
                                    ? '⏳'
                                    : (isUnlocked ? '🏡' : '🔒'))),
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          estateTitle,
                          style: GoogleFonts.outfit(
                            color: isCurrent
                                ? const Color(0xFFFFFC00)
                                : (isCompleted
                                    ? const Color(0xFFFFB74D)
                                    : (isUnlocked ? Colors.white : Colors.white60)),
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Resident Avatar Guardian Chip (Click to open collectible card)
              Positioned(
                top: 2,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _openAvatarCard(day);
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F172A),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFFFFC00)
                            : (isCompleted
                                ? const Color(0xFF10B981)
                                : (isUnlocked ? Colors.white54 : Colors.white24)),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: VectorAvatarWidget(
                        config: avatarConfig,
                        size: 24,
                        showAura: false,
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Flame Badge when Level is Completed (Audio Directive: "athinu kazhinja udane flame okke kodukkaam")
              if (isCompleted)
                Positioned(
                  bottom: 24,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5722).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 8)),
                        const SizedBox(width: 2),
                        Text(
                          'MASTERED',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 6. Gate Locked Badge when not unlocked (Audio Directive: "Ella veedukalukkum color vecho, pakshe lock aakki vechaal mathi")
              if (!isUnlocked && !isWaitingForMidnight)
                Positioned(
                  bottom: 24,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 9),
                        const SizedBox(width: 3),
                        Text(
                          'GATE LOCKED',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 7. 🏰 Home Visit Button (Visual house tour + Home Owners + Attack arena)
              Positioned(
                bottom: 4,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    PocketHomeVisitModal.show(
                      context,
                      day: day,
                      userCurrentDay: currentDay,
                      currentUserId: widget.userId ?? _supabase.auth.currentUser?.id,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏰', style: TextStyle(fontSize: 8)),
                        const SizedBox(width: 3),
                        Text(
                          'HOME VISIT',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
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
      ),
    );
  }

  /// 🏰 Stone Wall Barrier & Fortress Exam Gate between House $day and House ${day + 1}
  /// User Audio Directive:
  /// "ടാർഗറ്റ് പേജിൽ ഒന്നാമത്തെ വീടിന്റെ അപ്പുറത്ത് എന്ത് ചെയ്യുക? ഒരു മതില്... മതിലല്ല, ഒരു ഗേറ്റ് വയ്ക്കുക.
  /// ചെറിയ മതിലുപോലെ ഇങ്ങനെ ഇതാക്കി വയ്ക്കുക. ഗേറ്റ് വയ്ക്കുക. ആ ഗേറ്റ് അൺലോക്ക് ആവണം എന്നുണ്ടെങ്കിൽ ചെറിയൊരു സ്റ്റെപ്പ് കൊടുക്കുക.
  /// അത് എക്സാം ആയിരിക്കും. എക്സാം സ്റ്റെപ്പ് ആണ്! ഒന്നാമത്തെ ഡേയിൽ പഠിച്ച കാര്യങ്ങളായിരിക്കും എക്സാമിൽ ഉണ്ടാവുക.
  /// എക്സാം സെറ്റ് ആക്കുക. അതിനുശേഷമായിരിക്കും രണ്ടാമത്തേത് അൺലോക്ക് ആയിട്ട് കാണിക്കേണ്ടത്."
  Widget _buildRoadmapGate(int day, double screenWidth, int currentDay) {
    if (day >= _totalDays) return const SizedBox.shrink();

    final isCompleted = _isDayCompleted(day);
    final isCurrent = (day == currentDay);

    int completedTasks = 0;
    if (isCurrent) {
      for (int s = 1; s <= 16; s++) {
        if (_subStepFlags['step_$s'] == true) completedTasks++;
      }
    }
    final bool areHouseTasksDone = _isMasterAdmin || isCompleted || (isCurrent && (_subStepFlags['step_16'] == true || completedTasks >= 16));
    final bool isExamReady = !isCompleted && isCurrent && areHouseTasksDone;

    // Exact midpoint along the mountain trail between house day and house day + 1
    final gateY = _getNodeY(day) - (_nodeSpacingY * 0.50);
    final gateX = _getNodeXFractional(day + 0.50, screenWidth);

    final double gateWidth = (screenWidth * 0.72).clamp(240.0, 280.0);
    const double gateHeight = 64.0;
    final double gateLeft = (gateX - (gateWidth / 2.0)).clamp(8.0, screenWidth - gateWidth - 8.0);
    final double gateTop = gateY - (gateHeight / 2.0);

    return Positioned(
      left: gateLeft,
      top: gateTop,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.heavyImpact();
          if (isCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🔓 Day $day Mastery Exam Passed! House ${day + 1} Gate is open!',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
            return;
          }

          // Strict Locking: Gate N requires completing all prior houses and current house tasks
          if (day > currentDay) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1E293B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Row(
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gate $day is locked! Complete House $currentDay & pass previous gates first.',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          if (!areHouseTasksDone) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1E293B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Row(
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete all House $day tasks first to unlock Gate $day Exam! ($completedTasks/16 done)',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          // Open the Level Mastery Exam Dialog!
          _launchStep17_MasteryExam(day, _currentLearnerLevel);
        },
        child: SizedBox(
          width: gateWidth,
          height: gateHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Left & Right Flanking Stone Fortress Walls with Battlements
              Row(
                children: [
                  // Left Stone Wall Segment
                  Expanded(
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E293B),
                            Color(0xFF334155),
                            Color(0xFF475569),
                          ],
                        ),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        border: Border.all(color: Colors.white24, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 6,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center Gate Gap (where the arched gateway sits)
                  const SizedBox(width: 80),

                  // Right Stone Wall Segment
                  Expanded(
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF475569),
                            Color(0xFF334155),
                            Color(0xFF1E293B),
                          ],
                        ),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        border: Border.all(color: Colors.white24, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 6,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Central Arched Gate Structure
              Container(
                width: 82,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isCompleted
                        ? [const Color(0xFF047857), const Color(0xFF064E3B)]
                        : (isExamReady
                            ? [const Color(0xFFB45309), const Color(0xFF78350F)]
                            : [const Color(0xFF1E293B), const Color(0xFF0F172A)]),
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26), bottom: Radius.circular(8)),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isExamReady ? const Color(0xFFFFD700) : Colors.white24),
                    width: isExamReady || isCompleted ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCompleted
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : (isExamReady
                              ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4)),
                      blurRadius: isExamReady ? 14 : 10,
                      spreadRadius: isExamReady ? 2 : 1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Iron bars pattern
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (i) => Container(
                          width: 1.5,
                          height: 38,
                          color: isCompleted
                              ? const Color(0xFF34D399)
                              : (isExamReady ? const Color(0xFFFFD700).withValues(alpha: 0.5) : Colors.white12),
                        ),
                      ),
                    ),

                    // Central Lock or Unlock Emblem
                    Icon(
                      isCompleted
                          ? Icons.lock_open_rounded
                          : (isExamReady ? Icons.edit_note_rounded : Icons.lock_rounded),
                      color: isCompleted
                          ? const Color(0xFF6EE7B7)
                          : (isExamReady ? const Color(0xFFFFFC00) : Colors.white38),
                      size: isExamReady ? 26 : 24,
                    ),
                  ],
                ),
              ),

              // 3. Floating Interactive Exam Badge above Gate
              Positioned(
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : (isExamReady ? const Color(0xFFFFD700) : Colors.white24),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCompleted ? '✨' : (isExamReady ? '📝' : '🔒'),
                        style: const TextStyle(fontSize: 9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted
                            ? 'GATE OPEN • DAY $day ✓'
                            : (isExamReady
                                ? 'GATE $day EXAM READY • TAP TO START'
                                : (day == currentDay
                                    ? 'GATE $day LOCKED • $completedTasks/16 TASKS'
                                    : 'GATE $day LOCKED')),
                        style: GoogleFonts.outfit(
                          color: isCompleted
                              ? const Color(0xFF34D399)
                              : (isExamReady ? const Color(0xFFFFD700) : Colors.white54),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
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
    );
  }

  /// 🏡 Shows rich details sheet for the English Architectural House along the mountain path
  // ignore: unused_element
  void _showHouseDetailsSheet(int day) {
    HapticFeedback.mediumImpact();
    final isCompleted = _isDayCompleted(day);
    final isWaitingForMidnight = _isDayWaitingForMidnight(day);
    final currentDay = _progress?.currentDay ?? 1;
    final isUnlocked = _isDayUnlocked(day, currentDay) && (day > 1 || _hasAcceptedRules);
    final isCurrent = (day == currentDay);
    final estateTitle = FlameEnglishHouseWidget.getEstateStageTitle(day);
    final palette = HousePalette.presets[(day - 1) % HousePalette.presets.length];
    final config = _getAvatarForDay(day);
    final reqScore = PocketScoreLevelEngine.getRequiredScoreForLevel(day);
    final reqTrophies = PocketScoreLevelEngine.getRequiredTrophiesForLevel(day);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFFFFFC00)
                  : (isCompleted ? const Color(0xFFFF5722) : Colors.white24),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCurrent
                        ? const Color(0xFFFFFC00)
                        : (isCompleted ? const Color(0xFFFF5722) : Colors.black))
                    .withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Architectural House Canvas Preview
              Container(
                height: 160,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.6),
                      const Color(0xFF0B0F19),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: HouseMasterPainter(
                      day: day,
                      palette: palette,
                      isPresident: (day >= 90),
                      lightsOn: isCompleted || isCurrent,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                estateTitle,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCompleted
                                    ? '🔥 Mastered Estate • Hearth & Windows Glowing'
                                    : (isCurrent
                                        ? '📍 Current Level • Doorstep Entrance'
                                        : (isUnlocked ? '⚡ Unlocked Estate' : '🔒 Locked Estate')),
                                style: GoogleFonts.inter(
                                  color: isCompleted
                                      ? const Color(0xFFFF9800)
                                      : (isCurrent
                                          ? const Color(0xFFFFFC00)
                                          : (isUnlocked ? const Color(0xFF38BDF8) : Colors.white54)),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar Chip
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _openAvatarCard(day);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            ),
                            child: ClipOval(
                              child: VectorAvatarWidget(
                                config: config,
                                size: 36,
                                showAura: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Level Requirement info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Required Pocket Score: $reqScore${reqTrophies > 0 ? ' • 🏆 $reqTrophies Trophies' : ''}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openAvatarCard(day);
                            },
                            icon: const Icon(Icons.style_rounded, size: 16, color: Color(0xFFFFD700)),
                            label: Text(
                              'Guardian Card',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isCurrent
                                      ? const Color(0xFFFFFC00)
                                      : const Color(0xFF38BDF8)),
                              foregroundColor: (isCurrent) ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              if (!_hasAcceptedRules && day == 1) {
                                PocketWorldGameRulesModal.show(
                                  context,
                                  currentDay: currentDay,
                                  onPledgeAccepted: () {
                                    setState(() => _hasAcceptedRules = true);
                                    _loadData();
                                  },
                                );
                                return;
                              }
                              if (isCurrent) {
                                _startActiveSubStep(day);
                              } else if (isCompleted) {
                                _startActiveSubStep(day);
                              } else if (isWaitingForMidnight) {
                                _showMidnightLockedToast(day);
                              } else {
                                _showLevelLockedToast(day);
                              }
                            },
                            icon: Icon(
                              isCompleted
                                  ? Icons.replay_rounded
                                  : (isCurrent ? Icons.play_arrow_rounded : Icons.lock_rounded),
                              size: 18,
                            ),
                            label: Text(
                              isCompleted
                                  ? 'Replay Sub-Steps'
                                  : (isCurrent ? 'Start Trail Step' : 'Gate Locked'),
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
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
      },
    );
  }

  void _showMidnightLockedToast(int day) {
    HapticFeedback.selectionClick();
    final countdownStr = Learning60DayService.formatRemainingCountdown(_timeUntilMidnight);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
        ),
        content: Row(
          children: [
            const Text('⏳', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Day $day unlocks at 12:00 AM midnight ($countdownStr)\n⚡ Subscribe to VIP to skip wait and unlock instantly!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'GO VIP ⚡',
          textColor: const Color(0xFFFFFC00),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionPage()),
            );
          },
        ),
      ),
    );
  }

  void _showLevelLockedToast(int day) {
    HapticFeedback.selectionClick();
    final reqScore = PocketScoreLevelEngine.getRequiredScoreForLevel(day);
    String message = 'House $day is locked!';
    bool canTakeGateExam = false;

    if (day > 1 && !_isDayCompleted(day - 1)) {
      message = '🔒 House $day is locked! You must pass the Gate ${day - 1} Exam (Pass Mark: 60%) to unlock House $day!';
      canTakeGateExam = true;
    } else if (_unifiedPocketScore < reqScore) {
      final missing = reqScore - _unifiedPocketScore;
      message = '🪙 Requires $reqScore Pocket Score (Need $missing more PS). Complete previous missions to earn PS!';
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.0),
        ),
        action: canTakeGateExam
            ? SnackBarAction(
                label: 'GATE ${day - 1} EXAM 📝',
                textColor: const Color(0xFFFFD700),
                onPressed: () => _launchStep17_MasteryExam(day - 1, _currentLearnerLevel),
              )
            : null,
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 👑 Stage Character Evolution Node right before Step 1 along the mountain trail (User Audio Directive!)
  /// "Aa 1-mthe steppinu munne cheriya oru card ittittu, aa cardil tap cheythu kazhinju kazhinja aa avatar-ukal kaanum. 'Achieve - aa avatar achieve cheythu' ennullathu."
  Widget _buildAvatarEvolutionNode({
    required int day,
    required double x,
    required double y,
    required double screenWidth,
  }) {
    const nodeSize = 52.0;
    final isRightSide = x >= screenWidth / 2;
    final labelWidth = 142.0;
    final avatarConfig = _getAvatarForDay(day);

    return Positioned(
      left: x - (nodeSize / 2),
      top: y - (nodeSize / 2),
      child: SizedBox(
        width: nodeSize,
        height: nodeSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Side Label Card
            Positioned(
              left: isRightSide ? (-labelWidth - 10.0) : (nodeSize + 10.0),
              top: 0.0,
              width: labelWidth,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showAvatarAchievementDialog(day);
                },
                child: Container(
                  width: labelWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Day $day Hero Avatar',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Achieved! Tap to View 🔥',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pulsing Flame Aura around the Avatar Stone
            AnimatedBuilder(
              animation: _bobController,
              builder: (context, _) {
                final scale = 1.0 + (_bobController.value * 0.18);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: nodeSize + 8,
                    height: nodeSize + 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF8906).withValues(alpha: 0.7 - (_bobController.value * 0.3)),
                        width: 2.0,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Avatar Stone Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showAvatarAchievementDialog(day);
              },
              child: Container(
                width: nodeSize,
                height: nodeSize,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8906).withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: avatarConfig,
                    size: nodeSize - 6,
                    showAura: false,
                  ),
                ),
              ),
            ),

            // Bottom "EVO" Badge
            Positioned(
              bottom: -7,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                ),
                child: Text(
                  'EVO ⚡',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Celebratory Hero Avatar Achievement & Stage Showcase Modal (User Audio Directive!)
  void _showAvatarAchievementDialog(int day) {
    HapticFeedback.heavyImpact();
    final avatarConfig = _getAvatarForDay(day);
    final stage = LearningMilestoneStage.getStageForDay(day);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF131728),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8906).withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 16,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8906).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'DAY $day HERO AVATAR ACHIEVED',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Avatar Showcase with Flaming Ring
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFFC00), Color(0xFFFF6D00)],
                      ),
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8906).withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: VectorAvatarWidget(
                        config: avatarConfig,
                        size: 98,
                        showAura: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stage Title & Evolution Tier
                  Text(
                    stage.stageName,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stage.fluencyTier.toUpperCase()} • STAGE ${((day - 1) ~/ 10) + 1} ARCHITECTURE',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feature Cards
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('🏡', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'House Stage: ${((day - 1) ~/ 10) + 1} of 9 Progressive Estates',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Day Reward Target: ~600 Pocket Score across 17 steps',
                                style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Level Mastery Exam: Step 17 unlocks House ${day + 1} Gate',
                                style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Continue to Step 1 Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startActiveSubStep(day);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'START STEP 1 • CLIMB THE TRAIL',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.5,
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
        );
      },
    );
  }

  /// 🎯 In-Path Sub-Step Node rendered directly on the climbing road (User Audio Directive!)
  Widget _buildSubStepNode({
    required InPathSubStep step,
    required double x,
    required double y,
    required double screenWidth,
    required bool isActiveCurrent,
  }) {
    const nodeSize = 44.0;
    final isRightSide = x >= screenWidth / 2;
    final labelWidth = 115.0;

    return Positioned(
      left: x - (nodeSize / 2),
      top: y - (nodeSize / 2),
      child: SizedBox(
        width: nodeSize,
        height: nodeSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Side Label Card
            Positioned(
              left: isRightSide ? (-labelWidth - 8.0) : (nodeSize + 8.0),
              top: 2.0,
              width: labelWidth,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!step.isUnlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔒 Complete step ${step.stepIndex - 1} first!'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  step.onAction();
                },
                child: Container(
                  width: labelWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131728).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: step.isCompleted
                          ? const Color(0xFF10B981).withValues(alpha: 0.6)
                          : (step.isUnlocked
                              ? step.color.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.12)),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(step.icon, style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              step.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        step.subtitle,
                        style: GoogleFonts.inter(
                          color: step.isCompleted
                              ? const Color(0xFF10B981)
                              : (step.isUnlocked ? const Color(0xFFFFD700) : Colors.white38),
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pulsing highlight if currently active
            if (isActiveCurrent)
              AnimatedBuilder(
                animation: _bobController,
                builder: (context, child) {
                  final scale = 1.0 + (_bobController.value * 0.22);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: nodeSize + 8,
                      height: nodeSize + 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.color.withValues(alpha: 0.6 - (_bobController.value * 0.3)),
                          width: 2.2,
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Node Circle Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (!step.isUnlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔒 Complete step ${step.stepIndex - 1} first!'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                step.onAction();
              },
              child: Container(
                width: nodeSize,
                height: nodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: step.isCompleted
                        ? [const Color(0xFF10B981), const Color(0xFF047857)]
                        : (step.isUnlocked
                            ? [step.color.withValues(alpha: 0.9), step.color.withValues(alpha: 0.6)]
                            : [const Color(0xFF1F2438), const Color(0xFF121624)]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: step.isCompleted
                        ? const Color(0xFF6EE7B7)
                        : (step.isUnlocked ? step.color : Colors.white24),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (step.isCompleted ? const Color(0xFF10B981) : (step.isUnlocked ? step.color : Colors.black))
                          .withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: step.isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                      : (step.isUnlocked
                          ? Text(
                              step.icon,
                              style: const TextStyle(fontSize: 18),
                            )
                          : const Icon(Icons.lock_rounded, color: Colors.white30, size: 16)),
                ),
              ),
            ),

            // Stepping Stone Number Badge
            Positioned(
              bottom: -7,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: step.isCompleted
                        ? const Color(0xFF10B981)
                        : (step.isUnlocked ? step.color : Colors.white24),
                    width: 0.9,
                  ),
                ),
                child: Text(
                  '#${step.stepIndex}',
                  style: GoogleFonts.outfit(
                    color: step.isCompleted
                        ? const Color(0xFF6EE7B7)
                        : (step.isUnlocked ? Colors.white : Colors.white54),
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 17 in-path sub-step milestone nodes for the active day along the climbing path (User Audio Directive!)
  // ignore: unused_element
  List<Widget> _buildActiveSubStepNodes(double screenWidth, int activeDay) {
    if (activeDay >= _totalDays || !_effectiveRulesAccepted) return [];

    final subSteps = _getSubStepsForDay(activeDay, _currentLearnerLevel);
    final List<Widget> widgets = [];

    // 👑 Stage Character Evolution Node right before Step 1 (User Audio Directive!)
    // "Aa 1-mthe steppinu munne cheriya oru card ittittu, aa cardil tap cheythu kazhinju kazhinja aa avatar-ukal kaanum. 'Achieve - aa avatar achieve cheythu' ennullathu."
    final avatarNodeY = _getNodeY(activeDay) - ((0.45 / 18.0) * (_nodeSpacingY + _expandedActiveGap));
    final avatarNodeX = _getSubStepX(activeDay, 0, screenWidth);
    widgets.add(
      _buildAvatarEvolutionNode(
        day: activeDay,
        x: avatarNodeX,
        y: avatarNodeY,
        screenWidth: screenWidth,
      ),
    );

    // Find the first unlocked but incomplete step
    int currentActiveStepIndex = -1;
    for (var s in subSteps) {
      if (s.isUnlocked && !s.isCompleted) {
        currentActiveStepIndex = s.stepIndex;
        break;
      }
    }

    final totalStepsCount = subSteps.length;
    for (int k = 1; k <= totalStepsCount; k++) {
      final step = subSteps[k - 1];
      final y = _getSubStepY(activeDay, k, totalSteps: totalStepsCount);
      final x = _getSubStepX(activeDay, k, screenWidth, totalSteps: totalStepsCount);
      final isActiveCurrent = (step.stepIndex == currentActiveStepIndex);

      widgets.add(
        _buildSubStepNode(
          step: step,
          x: x,
          y: y,
          screenWidth: screenWidth,
          isActiveCurrent: isActiveCurrent,
        ),
      );
    }

    // 🚗 Animated Vehicle Moving along the trail (User Audio Directive!)
    // "Vandi neengi step 2-lekku povanam... Defence add cheythu kazhinjaal vandi animated aayi aa puthiya veetinte munnil poi nilkkum (House 2-nte munnil)."
    widgets.add(
      _buildAnimatedVehicle(
        screenWidth: screenWidth,
        activeDay: activeDay,
        currentActiveStepIndex: currentActiveStepIndex,
        totalStepsCount: totalStepsCount,
        subSteps: subSteps,
      ),
    );

    return widgets;
  }

  /// 🚗 Animated Vehicle moving along the sub-step trail and parking at House 2 when complete
  Widget _buildAnimatedVehicle({
    required double screenWidth,
    required int activeDay,
    required int currentActiveStepIndex,
    required int totalStepsCount,
    required List<InPathSubStep> subSteps,
  }) {
    final bool allDone = currentActiveStepIndex == -1;
    final double targetX;
    final double targetY;

    if (allDone) {
      // Parked right in front of the next house (House 2 for Day 1)!
      final nextDay = (activeDay + 1).clamp(1, _totalDays);
      targetX = _getNodeX(nextDay, screenWidth);
      targetY = _getNodeY(nextDay) + 48.0;
    } else {
      targetX = _getSubStepX(activeDay, currentActiveStepIndex, screenWidth, totalSteps: totalStepsCount);
      targetY = _getSubStepY(activeDay, currentActiveStepIndex, totalSteps: totalStepsCount) - 34.0;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeInOutCubic,
      left: targetX - 26,
      top: targetY - 12,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          if (allDone) {
            final nextDay = (activeDay + 1).clamp(1, _totalDays);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '🚗 Vehicle parked in front of House $nextDay! Tap House $nextDay to continue!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            subSteps[currentActiveStepIndex - 1].onAction();
          }
        },
        child: AnimatedBuilder(
          animation: _bobController,
          builder: (context, child) {
            final bob = math.sin(_bobController.value * math.pi) * 3.5;
            return Transform.translate(
              offset: Offset(0, bob),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status badge above the car
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: allDone ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (allDone ? const Color(0xFF10B981) : const Color(0xFFFFD700)).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      allDone ? 'House 2 Reached! 🏡' : 'Car at Step $currentActiveStepIndex',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Animated Vehicle Icon & Glow
                  Container(
                    width: 52,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: allDone
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFFFF9800), const Color(0xFFE65100)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          '🚗',
                          style: TextStyle(fontSize: 22),
                        ),
                        // Headlight glow
                        Positioned(
                          right: 2,
                          top: 12,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEB3B),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFEB3B),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// The active character avatar standing on today's house node (or Rules node before start).
  /// User audio requirement: Every house has its avatar, standing right at the active estate front door!
  Widget _buildAnimatedAvatar(double screenWidth, int currentDay) {
    final bool atRuleNode = !_effectiveRulesAccepted;
    double x;
    double y;

    // Strict Waiting-Pacing Guard (User Audio Directive):
    // When Day 1 is finished and waiting for midnight, the avatar MUST sit at Day 2 (the waiting house), NOT jump ahead!
    int effectiveAvatarDay = currentDay;
    if (!atRuleNode && !_isMasterAdmin) {
      for (int d = 1; d <= _totalDays; d++) {
        if (!_isDayCompleted(d)) {
          effectiveAvatarDay = d;
          break;
        }
      }
    }

    if (atRuleNode) {
      x = (screenWidth / 2) + 54;
      y = _ruleNodeY + 12;
    } else {
      x = _getNodeX(effectiveAvatarDay, screenWidth);
      y = _getNodeY(effectiveAvatarDay);
    }
    final avatarConfig = _getAvatarForDay(atRuleNode ? 1 : effectiveAvatarDay);

    return Positioned(
      left: x - 54,
      top: y - 128,
      child: AnimatedBuilder(
        animation: _bobController,
        builder: (context, child) {
          final bobY = math.sin(_bobController.value * math.pi) * 11.0;
          final shadowScale = 1.0 - (_bobController.value * 0.28);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speech bubble - Tap to view Rules or Enter Estate!
              GestureDetector(
                onTap: () {
                  if (atRuleNode) {
                    PocketWorldGameRulesModal.show(
                      context,
                      currentDay: effectiveAvatarDay,
                      onPledgeAccepted: () {
                        setState(() => _hasAcceptedRules = true);
                        _loadData();
                      },
                    );
                  } else {
                    final isWaitingForMidnight = _isDayWaitingForMidnight(effectiveAvatarDay);
                    final isUnlocked = _isDayUnlocked(effectiveAvatarDay, effectiveAvatarDay);
                    final isCompleted = _isDayCompleted(effectiveAvatarDay);
                    if (_isMasterAdmin || isCompleted || isUnlocked) {
                      _startActiveSubStep(effectiveAvatarDay);
                    } else if (isWaitingForMidnight) {
                      _showMidnightLockedToast(effectiveAvatarDay);
                    } else {
                      _showLevelLockedToast(effectiveAvatarDay);
                    }
                  }
                },
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
                      Text(atRuleNode ? '📜' : '🏡',
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        atRuleNode
                            ? 'Rules & Pledge • Tap to Start 📜'
                            : 'Day $currentDay • Enter Estate 🚀',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Bobbing Avatar Character (Heroic 76px size with dual fiery glow as requested in audio)
              Transform.translate(
                offset: Offset(0, -bobY),
                child: GestureDetector(
                  onTap: () {
                    if (atRuleNode) {
                      PocketWorldGameRulesModal.show(
                        context,
                        currentDay: currentDay,
                        onPledgeAccepted: () {
                          setState(() => _hasAcceptedRules = true);
                          _loadData();
                        },
                      );
                    } else {
                      _showAvatarAchievementDialog(currentDay);
                    }
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFFFC00), width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.65),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF5722).withValues(alpha: 0.45),
                          blurRadius: 26,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: VectorAvatarWidget(
                        config: avatarConfig,
                        size: 70,
                        showAura: true,
                      ),
                    ),
                  ),
                ),
              ),

              // Dynamic Shadow under avatar
              Transform.scale(
                scale: shadowScale,
                child: Container(
                  width: 46,
                  height: 9,
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
      // ☁️ Atmospheric Drifting Clouds across Mountain Passes (User Audio Directive: "meghangal ponathu... weather effects")
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _bobController,
            builder: (context, _) {
              final drift1 = (_bobController.value * 65.0);
              final drift2 = ((1.0 - _bobController.value) * 75.0);

              return Stack(
                children: [
                  // Cloud 1: Zone 1 & 2
                  Positioned(
                    left: 20 + drift1,
                    top: _getNodeY(12) - 40,
                    child: Opacity(
                      opacity: 0.20,
                      child: const Text('☁️', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  // Cloud 2: Zone 3
                  Positioned(
                    right: 25 + drift2,
                    top: _getNodeY(35) - 30,
                    child: Opacity(
                      opacity: 0.22,
                      child: const Text('☁️', style: TextStyle(fontSize: 54)),
                    ),
                  ),
                  // Cloud 3: Zone 4 (Cloud Realm)
                  Positioned(
                    left: 15 + drift2,
                    top: _getNodeY(64) - 50,
                    child: Opacity(
                      opacity: 0.28,
                      child: const Text('☁️', style: TextStyle(fontSize: 66)),
                    ),
                  ),
                  // Cloud 4: Dragon Castle
                  Positioned(
                    right: 40 + drift1,
                    top: _getNodeY(84) - 40,
                    child: Opacity(
                      opacity: 0.24,
                      child: const Text('☁️', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      // Zone 1: Forest & Valley (Day 1 Header at the bottom)
      Positioned(
        left: 20,
        top: _getNodeY(1) + 40,
        child: _buildZoneBanner(
          title: '🌲 ZONE 1: EMERALD FOREST & VALLEY',
          subtitle: 'MTI Reduction, Phonetics & Habit Foundations (Days 1–20)',
          color: const Color(0xFF10B981),
        ),
      ),

      // Zone 2: Desert Dunes (Day 21 Header)
      Positioned(
        left: 20,
        top: _getNodeY(21) + 55,
        child: _buildZoneBanner(
          title: '🏜️ ZONE 2: DESERT DUNES & OASIS',
          subtitle: 'Day 21 Habit Anchor, Spoken Confidence & Idioms (Days 21–40)',
          color: const Color(0xFFFFB700),
        ),
      ),

      // Zone 3: Cyberpunk City (Day 41 Header)
      Positioned(
        left: 20,
        top: _getNodeY(41) + 55,
        child: _buildZoneBanner(
          title: '⚡ ZONE 3: CYBER NEON HIGHWAY',
          subtitle: 'Fast Peer Debates & Professional Expressions (Days 41–60)',
          color: const Color(0xFF8B5CF6),
        ),
      ),

      // Zone 4: Cloud Kingdom (Day 61 Header)
      Positioned(
        left: 20,
        top: _getNodeY(61) + 55,
        child: _buildZoneBanner(
          title: '☁️ ZONE 4: MYSTIC CLOUD KINGDOM',
          subtitle: 'Impromptu Thinking & Global Dialect Mastery (Days 61–80)',
          color: const Color(0xFF00E5FF),
        ),
      ),

      // Zone 5: Dragon Castle (Day 81 Header)
      Positioned(
        left: 20,
        top: _getNodeY(81) + 55,
        child: _buildZoneBanner(
          title: '🌋 ZONE 5: DRAGON\'S LAIR & GRANDMASTER THRONE',
          subtitle: 'Day 90 Supreme Cosmic Dragon Graduation 👑 (Days 81–90)',
          color: const Color(0xFFFF0055),
        ),
      ),

      // Level 91 Sovereign Citadel Grand Master Trophy Pinnacle (Apex Summit Top)
      Positioned(
        left: (screenWidth / 2) - 85,
        top: _getNodeY(91) - 160,
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

  /// 🏛️ LEVEL 91: Grand Presidential Sovereign Citadel Apex Node
  /// Audio Requirement:
  /// "പ്രസിഡന്റിന്റെ കൊട്ടാരത്തെ അറ്റാക്ക് ചെയ്യാൻ 90 ലെവൽ കംപ്ലീറ്റ് ആയിട്ട് 91-ാമത്തെ ലെവലിലാണ് വരുക.
  /// അപ്പൊ ടാർഗറ്റ് പേജിൽ 91-ാമത്തെ ലെവൽ എഴുതണം. അത് അറ്റാക്ക് പ്രത്യേകം ഗോൾഡൻ കളറിലോ കൊടുക്കണം.
  /// ആ അറ്റാക്കും കൂടി കഴിഞ്ഞിട്ടായിരിക്കണം ഇതിന് സർട്ടിഫിക്കറ്റ് കൊടുക്കുകയുള്ളൂ."
  Widget _buildLevel91ApexNode(double screenWidth, int currentDay) {
    final x = _getNodeX(91, screenWidth);
    final y = _getNodeY(91);
    final isUnlocked = (currentDay >= 91) || (_completedDays.contains(90));
    final isConquered = _hasConqueredCitadel;
    const nodeSize = 88.0;

    return Positioned(
      left: x - (nodeSize / 2),
      top: y - (nodeSize / 2),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.heavyImpact();
          if (!isUnlocked) {
            _showPresidentialLevelLockDialog();
            return;
          }
          await PocketCitadelAttackPage.openForUser(
            context,
            userId: PocketPresidentService.presidentId,
            attackerDay: 91,
          );
          _loadData();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Radiant Golden / Fiery Aura Ring
                if (isUnlocked)
                  AnimatedBuilder(
                    animation: _bobController,
                    builder: (context, _) {
                      final pulse = _bobController.value;
                      return Container(
                        width: nodeSize + 16 + (pulse * 8),
                        height: nodeSize + 16 + (pulse * 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.55 + (pulse * 0.25)),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFF8906).withValues(alpha: 0.40),
                              blurRadius: 38,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // 2. Main 3D Stepping Sphere (Imperial Gold)
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isConquered
                          ? [const Color(0xFFFFD700), const Color(0xFF10B981), const Color(0xFF047857)]
                          : (isUnlocked
                              ? [const Color(0xFFFFFC00), const Color(0xFFFFD700), const Color(0xFFFF8906)]
                              : [const Color(0xFF334155), const Color(0xFF1E293B), const Color(0xFF0F172A)]),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: isConquered
                          ? const Color(0xFF6EE7B7)
                          : (isUnlocked ? Colors.white : const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      width: isUnlocked ? 3.5 : 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUnlocked
                            ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.5),
                        blurRadius: isUnlocked ? 22 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isConquered ? '👑' : (isUnlocked ? '⚔️' : '🔒'),
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '91: ATTACK',
                          style: GoogleFonts.outfit(
                            color: isUnlocked ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Floating Bottom Pill
                Positioned(
                  bottom: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isConquered
                          ? const Color(0xFF10B981)
                          : (isUnlocked ? const Color(0xFFDC2626) : const Color(0xFF0F172A)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isConquered ? Colors.white : const Color(0xFFFFD700),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      isConquered
                          ? '✓ CONQUERED'
                          : (isUnlocked ? 'RAID PALACE ⚔️' : 'LEVEL 91 🔒'),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Sovereign Citadel Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🏛️ LEVEL 91: PRESIDENTIAL RAID',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Conquer to Claim Fluency Certificate 📜',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏛️ Mini card beside Level 91 Apex Node
  Widget _buildLevel91MiniCard(double screenWidth, int currentDay) {
    final nodeX = _getNodeX(91, screenWidth);
    final nodeY = _getNodeY(91);
    final isRightSide = nodeX >= screenWidth / 2;
    final double cardWidth = ((screenWidth / 2) - 42.0).clamp(100.0, 140.0);
    final double cardLeft = isRightSide ? 12.0 : (screenWidth - cardWidth - 12.0);
    final double cardTop = nodeY - 21.0;
    final isUnlocked = (currentDay >= 91) || (_completedDays.contains(90));

    return Positioned(
      left: cardLeft,
      top: cardTop,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (!isUnlocked) {
            _showPresidentialLevelLockDialog();
          } else {
            PocketCitadelAttackPage.openForUser(
              context,
              userId: PocketPresidentService.presidentId,
              attackerDay: 91,
            );
          }
        },
        child: Container(
          width: cardWidth,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🏛️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _hasConqueredCitadel ? 'CITADEL CONQUERED' : 'PALACE RAID',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _hasConqueredCitadel ? '✓ C2 Master' : 'Level 91 Boss',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
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

  void _showPresidentialLevelLockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🏛️', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LEVEL 91: PRESIDENTIAL RAID',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
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
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SOVEREIGN CITADEL RESTRICTED ACCESS\nComplete all 90 Days of English Transformation first to unlock Level 91!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFF87171),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once you complete Day 90, you will face The President of Pocket World in a 250-question boss battle. Conquering the citadel awards the Official Day 90 Fluency Certificate!',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'UNDERSTOOD 🫡',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCitadelRequiredForCertificateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.8),
        ),
        title: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LEVEL 91 ATTACK REQUIRED',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
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
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'CONQUER LEVEL 91 TO GRADUATE!\nThe Sovereign Fluency Certificate is strictly awarded after conquering The President\'s Citadel in Level 91.',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Face 250 sequential boss trial questions and breach the Presidential Palace to prove complete C2 English Fluency!',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('LATER', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PocketCitadelAttackPage.openForUser(
                context,
                userId: PocketPresidentService.presidentId,
                attackerDay: 91,
              );
            },
            child: Text(
              'START ATTACK ⚔️',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
            ),
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
  final double ruleNodeY;
  final bool hasAcceptedRules;
  _AdventureMapRoadPainter({
    required this.totalDays,
    required this.currentDay,
    required this.screenWidth,
    required this.nodeSpacingY,
    required this.topPadding,
    required this.ruleNodeY,
    required this.hasAcceptedRules,
  });

  double _getNodeXFractional(double dayFraction) {
    final center = screenWidth / 2;
    if (dayFraction >= 33) {
      // 🎯 Audio Directive: From Day 33 onwards, track goes straight through center with subtle micro-bends!
      // This prevents big estates and castles (Day 33, 51, 52, 55, 56, 64 etc.) from clipping on screen edges.
      final subtleWave = math.sin((dayFraction - 33) * 0.55) * 14.0;
      return center + subtleWave;
    }
    // Days 1 to 32: Gentle pleasant bends, safely bounded so houses never clip
    final maxAmp = ((screenWidth - 250) / 2).clamp(16.0, 36.0);
    final wave = math.sin((dayFraction - 1) * 0.65);
    return center + (wave * maxAmp);
  }

  double _getNodeX(int day) => _getNodeXFractional(day.toDouble());

  double _getNodeY(int day) {
    final int daysFromTop = totalDays - day;
    return topPadding + (daysFromTop * nodeSpacingY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Biome Background Gradients (Inverted: Forest at bottom, Volcano/Citadel at top)
    _paintBiomeGradients(canvas, size);

    // 2. Draw Decorative Trees / Rocks / Clouds / Crystals / Wildlife (മാൻ, കരടി, പുലി, Flames)
    _paintWorldDecorations(canvas, size);

    // 3. Draw Soft Drifting Ambient Clouds across Mountain Passes
    _paintClouds(canvas, size);

    // 4. Draw S-Curve Stepping Stone Road Climbing Upwards
    _paintCobblestoneRoad(canvas);
  }

  void _paintClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final cloudPaintBright = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    for (int day = 4; day <= totalDays; day += 6) {
      final cy = _getNodeY(day) - 50.0;
      final cx = (day * 137.0) % (size.width - 140.0) + 70.0;
      canvas.drawCircle(Offset(cx, cy), 28, cloudPaint);
      canvas.drawCircle(Offset(cx + 22, cy - 8), 34, cloudPaintBright);
      canvas.drawCircle(Offset(cx + 44, cy), 26, cloudPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(cx - 20, cy + 4, 84, 22), const Radius.circular(11)),
        cloudPaint,
      );
    }
  }

  void _paintBiomeGradients(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF4A0E18), // Top 0.0 - 0.12: Zone 5: Volcanic Magma Crimson & Citadel Apex
          Color(0xFF1B386E), // 0.35: Zone 4: Sky Blue Cloud Realm
          Color(0xFF26144A), // 0.58: Zone 3: Cyberpunk Electric Violet
          Color(0xFF4A2B0F), // 0.80: Zone 2: Warm Desert Golden Amber
          Color(0xFF0F3822), // Bottom 1.0: Zone 1: Lush Forest Green (Day 1 starts here)
        ],
        stops: [0.12, 0.35, 0.58, 0.80, 1.0],
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

    // Rich wildlife & natural scenery along the trail (User Audio Directive: Deer, Bear, Leopard/Tiger, Flames, Plants)
    for (int day = 1; day <= totalDays; day++) {
      final y = _getNodeY(day);
      final isEven = day % 2 == 0;
      final xLeft = 14.0 + (day % 3) * 8.0;
      final xRight = size.width - 56.0 - (day % 3) * 8.0;

      // Primary decor element on left or right
      final x = isEven ? xLeft : xRight;
      final xOpposite = isEven ? xRight : xLeft;

      // 1. Specific Wildlife as requested in Audio:
      // മാൻ (Deer: 🦌)
      if (day == 3 || day == 9 || day == 17 || day == 29) {
        drawEmoji('🦌', x, y - 20, 26);
      }
      // കരടി (Bear: 🐻)
      else if (day == 7 || day == 21 || day == 35 || day == 49) {
        drawEmoji('🐻', x, y - 20, 26);
      }
      // പുലി / കടുവ (Leopard / Tiger: 🐆 / 🐅)
      else if (day == 13 || day == 27 || day == 45 || day == 63) {
        drawEmoji(day % 2 == 0 ? '🐆' : '🐅', x, y - 20, 26);
      }
      // Fox / Wolf / Lion / Eagle
      else if (day == 5 || day == 15 || day == 55) {
        drawEmoji('🦊', x, y - 18, 22);
      } else if (day == 75 || day == 87) {
        drawEmoji('🦁', x, y - 22, 28);
      } else if (day == 67 || day == 81) {
        drawEmoji('🦅', x, y - 28, 26);
      }

      // 2. Plants, Trees & Natural Flora (User Audio: "flames/plants add cheythu ground super aakkuka")
      if (day % 2 == 1) {
        if (day <= 25) {
          // Lush Forest Zone
          drawEmoji(day % 3 == 0 ? '🌲' : (day % 3 == 1 ? '🌿' : '🌸'), xOpposite, y - 10, 22);
        } else if (day <= 45) {
          // Desert & Mountain Savannah
          drawEmoji(day % 3 == 0 ? '🌴' : (day % 3 == 1 ? '🌵' : '🪨'), xOpposite, y - 10, 22);
        } else if (day <= 70) {
          // Mystic Highland & Crystals
          drawEmoji(day % 3 == 0 ? '💎' : (day % 3 == 1 ? '🔮' : '⚡'), xOpposite, y - 10, 22);
        } else {
          // Volcanic Summit
          drawEmoji(day % 3 == 0 ? '🌋' : (day % 3 == 1 ? '🔥' : '🪙'), xOpposite, y - 10, 24);
        }
      }

      // 3. Trailside Campfires & Lantern Torches (Audio: flames & extraordinary ground touches)
      if (day == 4 || day == 12 || day == 24 || day == 38 || day == 52 || day == 72) {
        drawEmoji('🔥', xOpposite, y + 25, 20);
        drawEmoji('🪵', xOpposite + 16, y + 28, 16);
      } else if (day % 6 == 0) {
        drawEmoji('🏮', xLeft, y + 15, 18);
        drawEmoji('🏮', xRight, y + 15, 18);
      } else if (day == 8 || day == 32 || day == 58) {
        drawEmoji('⛺', xOpposite, y - 15, 24);
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

    // Connect from Rule node at the bottom up to Day 1
    final pRule = Offset(screenWidth / 2, ruleNodeY);
    final pFirst = Offset(_getNodeX(1), _getNodeY(1));
    fullPath.moveTo(pRule.dx, pRule.dy);
    fullPath.quadraticBezierTo(
        pRule.dx, (pRule.dy + pFirst.dy) / 2, pFirst.dx, pFirst.dy);

    if (hasAcceptedRules) {
      completedPath.moveTo(pRule.dx, pRule.dy);
      completedPath.quadraticBezierTo(
          pRule.dx, (pRule.dy + pFirst.dy) / 2, pFirst.dx, pFirst.dy);
    }

    for (int day = 1; day < totalDays; day++) {
      final p1 = Offset(_getNodeX(day), _getNodeY(day));
      final p2 = Offset(_getNodeX(day + 1), _getNodeY(day + 1));

      if (day == 1) {
        fullPath.moveTo(p1.dx, p1.dy);
        if (day < currentDay && hasAcceptedRules) completedPath.moveTo(p1.dx, p1.dy);
      }

      // Natural mountain switchback curve
      final midY = (p1.dy + p2.dy) / 2;
      final curveDir = (day >= 33)
          ? ((day % 2 == 0) ? -7.0 : 7.0)
          : ((day % 2 == 0) ? -18.0 : 18.0);
      final midX = ((p1.dx + p2.dx) / 2) + curveDir;
      fullPath.quadraticBezierTo(midX, midY, p2.dx, p2.dy);
      if (day < currentDay && hasAcceptedRules) {
        completedPath.quadraticBezierTo(midX, midY, p2.dx, p2.dy);
      }
    }

    // Draw road layers
    canvas.drawPath(fullPath, roadShadowPaint);
    canvas.drawPath(fullPath, outerRoadPaint);
    canvas.drawPath(fullPath, innerRoadPaint);

    // Draw center trail lines
    canvas.drawPath(fullPath, lockedTrailPaint);
    if (hasAcceptedRules) {
      canvas.drawPath(completedPath, completedGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdventureMapRoadPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.screenWidth != screenWidth ||
        oldDelegate.hasAcceptedRules != hasAcceptedRules ||
        oldDelegate.ruleNodeY != ruleNodeY;
  }
}

/// 📝 Interactive CEFR Syllabus Examination Dialog
class _SyllabusExamDialog extends StatefulWidget {
  final SyllabusTrack track;
  final int currentDay;
  final Function(int score)? onExamCompleted;

  const _SyllabusExamDialog({
    required this.track,
    required this.currentDay,
    this.onExamCompleted,
  });

  @override
  State<_SyllabusExamDialog> createState() => _SyllabusExamDialogState();
}

class _SyllabusExamDialogState extends State<_SyllabusExamDialog> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _finished = false;

  late final List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _getQuestionsForLevel(widget.track.level);
  }

  List<Map<String, dynamic>> _getQuestionsForLevel(LearnerLevel level) {
    switch (level) {
      case LearnerLevel.zero:
        return [
          {
            'q': 'Which alphabet letter comes after "B"?',
            'options': ['A', 'C', 'D', 'E'],
            'correct': 1,
            'exp': 'A -> B -> C is the alphabetical sequence.',
          },
          {
            'q': 'How do you greet someone in the morning?',
            'options': ['Good Night', 'Good Morning', 'Good Evening', 'Goodbye'],
            'correct': 1,
            'exp': '"Good Morning" is the polite greeting for the morning.',
          },
          {
            'q': 'Choose the correct word: "I ___ a student."',
            'options': ['is', 'are', 'am', 'be'],
            'correct': 2,
            'exp': '"I" pairs with "am" in present simple tense.',
          },
          {
            'q': 'Which of these is an animal?',
            'options': ['Table', 'Dog', 'Pencil', 'River'],
            'correct': 1,
            'exp': 'A dog is a domestic animal.',
          },
          {
            'q': 'What color is the clear sky on a sunny day?',
            'options': ['Green', 'Blue', 'Red', 'Yellow'],
            'correct': 1,
            'exp': 'The sky appears blue during the day.',
          },
        ];
      case LearnerLevel.beginner:
        return [
          {
            'q': 'Complete the sentence: "Yesterday, she ___ to the market."',
            'options': ['goes', 'went', 'gone', 'going'],
            'correct': 1,
            'exp': '"Went" is the past simple tense of "go".',
          },
          {
            'q': 'Fill in the blank: "Where ___ you live?"',
            'options': ['do', 'does', 'is', 'are'],
            'correct': 0,
            'exp': 'With subject "you", we use the auxiliary verb "do".',
          },
          {
            'q': 'Complete the sentence: "They ___ playing football right now."',
            'options': ['is', 'are', 'was', 'am'],
            'correct': 1,
            'exp': 'Present continuous with "They" takes "are".',
          },
          {
            'q': 'Choose the correct possessive pronoun: "This book belongs to John. It is ___."',
            'options': ['her', 'hers', 'his', 'him'],
            'correct': 2,
            'exp': '"His" is the possessive pronoun for John (he).',
          },
          {
            'q': 'Negative form: "I don\'t have ___ money."',
            'options': ['some', 'any', 'many', 'much of'],
            'correct': 1,
            'exp': 'In negative sentences, "any" is typically used with uncountable nouns.',
          },
        ];
      case LearnerLevel.elementary:
        return [
          {
            'q': 'Conditional clause: "If it rains tomorrow, we ___ at home."',
            'options': ['stayed', 'will stay', 'would stay', 'staying'],
            'correct': 1,
            'exp': 'First conditional takes Present Simple in "if" clause and "will + verb" in main clause.',
          },
          {
            'q': 'Preposition of time: "She has been working here ___ three years."',
            'options': ['since', 'for', 'during', 'from'],
            'correct': 1,
            'exp': '"For" is used for periods/durations of time (3 years).',
          },
          {
            'q': 'Conjunction: "The meal was tasty, ___ it was rather expensive."',
            'options': ['because', 'although', 'so', 'therefore'],
            'correct': 1,
            'exp': '"Although" introduces a contrast or concession.',
          },
          {
            'q': 'Indirect question: "Could you tell me where the station ___?"',
            'options': ['is', 'is it', 'it is located at', 'does it be'],
            'correct': 0,
            'exp': 'In indirect questions, the word order is statement order (subject + verb).',
          },
          {
            'q': 'Gerund phrase: "I look forward to ___ you soon."',
            'options': ['meet', 'meeting', 'met', 'be meeting'],
            'correct': 1,
            'exp': '"Look forward to" is followed by a gerund (-ing form).',
          },
        ];
      case LearnerLevel.middle:
        return [
          {
            'q': 'Third conditional: "Had I known about the storm, I ___ earlier."',
            'options': ['left', 'would leave', 'would have left', 'will have left'],
            'correct': 2,
            'exp': 'Inverted third conditional requires "would have + past participle".',
          },
          {
            'q': 'Prepositional phrase: "The flight was delayed ___ inclement weather."',
            'options': ['due to', 'because', 'owing', 'despite of'],
            'correct': 0,
            'exp': '"Due to" acts as an adjectival/adverbial preposition phrase followed by a noun phrase.',
          },
          {
            'q': 'Subject-verb agreement: "Neither the manager nor the assistants ___ in the hall."',
            'options': ['was', 'were', 'is', 'has been'],
            'correct': 1,
            'exp': 'With "neither... nor", the verb agrees with the closer subject ("assistants" -> were).',
          },
          {
            'q': 'Collocation: "She delivered her keynote with tremendous poise and ___."',
            'options': ['eloquence', 'reluctance', 'negligence', 'ambivalence'],
            'correct': 0,
            'exp': '"Eloquence" signifies fluent and persuasive expressive speaking.',
          },
          {
            'q': 'Phrasal verb: "The council must come up ___ a viable alternative."',
            'options': ['with', 'to', 'for', 'about'],
            'correct': 0,
            'exp': '"Come up with" means to produce or formulate an idea/plan.',
          },
        ];
      case LearnerLevel.advanced:
        return [
          {
            'q': 'Vocabulary: "His analysis was so ___ that even sceptics accepted his conclusions."',
            'options': ['cogent', 'spurious', 'superfluous', 'tenuous'],
            'correct': 0,
            'exp': '"Cogent" means clear, logical, and convincing.',
          },
          {
            'q': 'Inversion: "Scarcely had the session begun ___ the microphone malfunctioned."',
            'options': ['than', 'when', 'then', 'that'],
            'correct': 1,
            'exp': '"Scarcely... when" is the standard correlative inversion pair.',
          },
          {
            'q': 'Collocation: "The committee reached a unanimous ___ after prolonged debate."',
            'options': ['consensus', 'contention', 'dissent', 'ambiguity'],
            'correct': 0,
            'exp': '"Unanimous consensus" indicates complete agreement across all parties.',
          },
          {
            'q': 'Subjunctive mood: "It is imperative that the CEO ___ present at the hearing."',
            'options': ['is', 'be', 'was', 'would be'],
            'correct': 1,
            'exp': 'Formal mandative subjunctive uses the bare base form "be".',
          },
          {
            'q': 'Idiomatic discourse: "To mitigate geopolitical risk, supply chain agility is of ___ importance."',
            'options': ['paramount', 'nominal', 'trivial', 'ancillary'],
            'correct': 0,
            'exp': '"Paramount" means more important than anything else; supreme.',
          },
        ];
      case LearnerLevel.expert:
        return [
          {
            'q': 'Elite Lexicon: "Her diplomatic discourse exhibited rare perspicacity and ___."',
            'options': ['finesse', 'obloquy', 'solipsism', 'vacillation'],
            'correct': 0,
            'exp': '"Finesse" denotes intricate and refined skill or diplomacy.',
          },
          {
            'q': 'Nuance: "His critique was commended for its incisive and ___ reasoning."',
            'options': ['trenchant', 'specious', 'platitudinous', 'insipid'],
            'correct': 0,
            'exp': '"Trenchant" describes expression that is vigorous, incisive, and keenly effective.',
          },
          {
            'q': 'Adverbial phrasing: "Notwithstanding strenuous opposition, the motion was ___ approved."',
            'options': ['summarily', 'tentatively', 'feebly', 'gratuitously'],
            'correct': 0,
            'exp': '"Summarily" means expeditiously and without delay or formal hesitation.',
          },
          {
            'q': 'Philosophical rhetoric: "The lecturer warned against conflating temporal fame with ___ value."',
            'options': ['ephemeral', 'intrinsic', 'circumstantial', 'utilitarian'],
            'correct': 1,
            'exp': '"Intrinsic" denotes belonging naturally; essential and timeless.',
          },
          {
            'q': 'Stylistic mastery: "He spoke with such erudition that the audience was held in ___ silence."',
            'options': ['rapt', 'lukewarm', 'flippant', 'perfunctory'],
            'correct': 0,
            'exp': '"Rapt" describes intense and completely absorbed fascination.',
          },
        ];
    }
  }

  void _handleOptionSelect(int index) {
    if (_answered) return;
    final isCorrect = index == _questions[_currentIndex]['correct'];
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isCorrect) _score++;
    });
    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      setState(() {
        _finished = true;
      });
      widget.onExamCompleted?.call(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final themeColor = widget.track.primaryColor;

    return Dialog(
      backgroundColor: const Color(0xFF131722),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: themeColor.withValues(alpha: 0.6), width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(18),
        child: _finished ? _buildCertificateView(themeColor) : _buildExamContent(q, themeColor),
      ),
    );
  }

  Widget _buildExamContent(Map<String, dynamic> q, Color themeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.track.icon, color: themeColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.track.code} • ${widget.track.nameEn}',
                    style: GoogleFonts.outfit(
                      color: themeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'CEFR Syllabus Level Assessment',
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        Row(
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Score: $_score',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _questions.length,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          minHeight: 4,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 16),

        // Question
        Text(
          q['q'] as String,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // Options
        ...List.generate((q['options'] as List).length, (idx) {
          final opt = q['options'][idx] as String;
          Color cardBorder = Colors.white12;
          Color cardBg = Colors.white.withValues(alpha: 0.04);
          Color textColor = Colors.white;

          if (_answered) {
            if (idx == q['correct']) {
              cardBorder = const Color(0xFF10B981);
              cardBg = const Color(0xFF10B981).withValues(alpha: 0.18);
              textColor = const Color(0xFF10B981);
            } else if (idx == _selectedIndex) {
              cardBorder = const Color(0xFFEF4444);
              cardBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
              textColor = const Color(0xFFEF4444);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _handleOptionSelect(idx),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _answered && idx == q['correct']
                            ? const Color(0xFF10B981)
                            : (_answered && idx == _selectedIndex
                                ? const Color(0xFFEF4444)
                                : Colors.white10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        String.fromCharCode(65 + idx),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_answered && idx == q['correct'])
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                    if (_answered && idx == _selectedIndex && idx != q['correct'])
                      const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                  ],
                ),
              ),
            ),
          );
        }),

        if (_answered) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    q['exp'] as String,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _next,
              child: Text(
                _currentIndex < _questions.length - 1 ? 'NEXT QUESTION →' : 'VIEW CERTIFICATE 🏆',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificateView(Color themeColor) {
    final pct = (_score / _questions.length * 100).round();
    final isPassed = pct >= 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                themeColor.withValues(alpha: 0.25),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Text('🎓', style: TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 6),
        Text(
          isPassed ? 'LEVEL ASSESSMENT PASSED!' : 'ASSESSMENT COMPLETED',
          style: GoogleFonts.outfit(
            color: isPassed ? const Color(0xFF10B981) : Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track: ${widget.track.nameEn} (${widget.track.code})',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),

        // Score Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('SCORE', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('$_score / ${_questions.length}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(width: 1, height: 28, color: Colors.white12),
              Column(
                children: [
                  Text('ACCURACY', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('$pct%', style: GoogleFonts.outfit(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(width: 1, height: 28, color: Colors.white12),
              Column(
                children: [
                  Text('BONUS', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('+${_score * 30} PS', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isPassed
                      ? 'Congratulations! You demonstrated proficiency for ${widget.track.nameEn}. Keep building your daily streak!'
                      : 'Good effort! Review today\'s syllabus milestones to strengthen your foundations and retake anytime.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'CLAIM & RETURN TO MAP',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

