import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'index.dart';

import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart'
    hide MenuFlyoutItem;
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/avatar/jackie_chan_talisman_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/flame_profile_banner_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/nft_trading_card_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_challenge_generator.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/day90_master_certificate_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/settings_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_friendship_score_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pocket_defense_card_detail_sheet.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_fight_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_top_rank_theme.dart';

class MainProfileWidget extends StatefulWidget {
  final String? userId;
  final double? width;
  final double? height;

  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;
  final Map<String, dynamic>? incomingMateRequest;
  final bool hideAppBar;

  const MainProfileWidget({
    super.key,
    this.userId,
    this.width,
    this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
    this.incomingMateRequest,
    this.hideAppBar = false,
  });

  @override
  State<MainProfileWidget> createState() => _MainProfileWidgetState();
}

class _MainProfileWidgetState extends State<MainProfileWidget>
    with material.TickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  late material.TabController _profileTabController;
  final ScrollController _scrollController = ScrollController();

  // Data State
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _threadItems = [];

  // Theme Colors
  Color? _bgColor;
  Color? _textColor;
  Color? _btnColor;
  Color? _btnTextColor;

  // Follow/Block State
  bool _isFollowing = false;
  bool _isRequested = false;
  bool _isMate = false;
  bool _isMateRequested = false;
  Map<String, dynamic>? _incomingMateRequest;
  int _followersCount = 0;
  int _followingCount = 0;
  int _friendsCount = 0;
  bool _isBlocked = false;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  List<Map<String, dynamic>> _filteredGalleryItems = [];

  // English Hub Dashboard State
  int _englishHubPoints = 0;
  String _hubAnalysis = '';
  bool _isAnalyzingHub = false;

  // Avatar & State
  bool _showAvatarMode = true;
  bool _isPublicProfileView = false;
  bool _isTestingStage = false;
  String? _equippedTalismanId;
  int _localUserStage = 1;

  /// 🔐 Master Admin check for musabthonippadam@gmail.com / mussabira
  bool _isAdminUser() {
    final curUserEmail = _supabase.auth.currentUser?.email;
    if (AdminAuthService.isMasterAdminEmail(curUserEmail)) return true;
    final profEmail = _profileData?['email']?.toString();
    if (AdminAuthService.isMasterAdminEmail(profEmail)) return true;
    final username = (_profileData?['username'] ?? _profileData?['name'])
        ?.toString()
        .toLowerCase()
        .trim();
    if (username != null &&
        (username == 'mussabira' ||
            username == 'musabhira' ||
            username.contains('mussabira') ||
            username.contains('musabthonippadam'))) {
      return true;
    }
    return false;
  }

  int _getEffectiveDay() {
    // 🧪 ADMIN TESTING OVERRIDE: Active ONLY for Master Admin (musabthonippadam@gmail.com / mussabira) testing their own profile
    if (_isTestingStage && isMe && _isAdminUser()) {
      return _localUserStage.clamp(1, 90);
    }

    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      return PocketRobotService.getDynamicLevel(robot);
    }
    // 🪙 AUDIO DIRECTIVE: User Level / Stage is strictly and non-negotiably derived from Pocket Score!
    // A user with 0 Pocket Score can ONLY be Level 1 / Stage 1. Both house and profile must match this score.
    final profScore = _pocketScore > 0
        ? _pocketScore
        : ((_profileData?['pocket_score'] as num?)?.toInt() ?? 0);
    final scoreLvl = PocketScoreLevelEngine.getLevelFromScore(profScore);
    return scoreLvl.clamp(1, 90);
  }

  Future<void> _loadLocalUserStage() async {
    // Keep admin testing stage intact during active preview testing
    if (_isTestingStage && isMe && _isAdminUser()) return;

    try {
      final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
      final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
      if (isRobot) {
        final robot = PocketRobotService.getRobotById(userId) ??
            PocketRobotService.getRobotByLevel(1);
        final dynLvl = PocketRobotService.getDynamicLevel(robot);
        final robotScore =
            await PocketFortressDefenseService.getRobotScore(robot.id, dynLvl);
        if (mounted) {
          setState(() {
            _pocketScore = robotScore;
            _localUserStage = dynLvl;
          });
        }
        return;
      }
      final score = await PocketFortressDefenseService.getUnifiedScore(userId);
      final scoreLvl = PocketScoreLevelEngine.getLevelFromScore(score);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pocket_learning_user_stage_$userId', scoreLvl);
      await prefs.setInt('learning_day_$userId', scoreLvl);
      if (mounted) {
        setState(() {
          _pocketScore = score;
          _localUserStage = scoreLvl;
        });
      }
    } catch (_) {}
  }

  VectorAvatarConfig _getAvatarConfig() {
    int day = _getEffectiveDay();
    if (_isTestingStage) {
      return VectorAvatarConfig.getEvolutionAvatarForStage(day,
          talismanId: _equippedTalismanId);
    }
    // 🛡️ Progression Prestige: Only Day 90 Masters who graduated have unlocked the custom Avatar Studio sandbox!
    // Days 1–89 strictly and proudly wear their earned evolution stage avatar, prestige aura, and colors!
    if (day >= 90 &&
        _profileData != null &&
        _profileData!['avatar_config'] != null) {
      try {
        final map = Map<String, dynamic>.from(_profileData!['avatar_config']);
        final cfg = VectorAvatarConfig.fromMap(map);
        // If it's a legacy default 'human' with no custom drawing or photo, default to stage evolution:
        if (cfg.species == 'human' &&
            cfg.customDrawingImage == null &&
            cfg.networkImageUrl == null &&
            cfg.imageUrl == null) {
          return VectorAvatarConfig.getEvolutionAvatarForStage(day,
              talismanId: _equippedTalismanId);
        }
        return cfg;
      } catch (_) {}
    }
    return VectorAvatarConfig.getEvolutionAvatarForStage(day,
        talismanId: _equippedTalismanId);
  }

  String get userId {
    if (widget.userId != null) return widget.userId!;
    if (_profileData != null && _profileData!['user_id'] != null) {
      return _profileData!['user_id'].toString();
    }
    return _supabase.auth.currentUser?.id ?? '';
  }

  bool get isMe => userId == _supabase.auth.currentUser?.id;

  Color _ensureContrast(Color fg, Color bg, {bool isButton = true}) {
    double getLuminance(Color color) {
      double r = color.r;
      double g = color.g;
      double b = color.b;
      r = r <= 0.03928
          ? r / 12.92
          : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
      g = g <= 0.03928
          ? g / 12.92
          : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
      b = b <= 0.03928
          ? b / 12.92
          : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    double l1 = getLuminance(fg);
    double l2 = getLuminance(bg);
    double ratio = (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);

    if (ratio < 2.0) {
      bool bgIsDark = l2 < 0.2;
      if (bgIsDark) {
        return isButton ? const Color(0xFFFFD600) : material.Colors.white;
      } else {
        return isButton ? const Color(0xFF1E293B) : material.Colors.black87;
      }
    }
    return fg;
  }

  @override
  void initState() {
    super.initState();
    _incomingMateRequest = widget.incomingMateRequest;
    // 4 clean Instagram-style tabs: Cards, Thoughts, Citadel, Companions (Audio Directive)
    _profileTabController = material.TabController(length: 4, vsync: this);
    _profileTabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadInitialData(); // Instant load strategy
    _fetchThreads();
    _loadEquippedTalisman();
    _loadFortressDefenseData();
    _loadPocketScore();
    _loadGlobalRank();
  }

  @override
  void didUpdateWidget(MainProfileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // 🪙 Unified Pocket Score state (highest priority on user profile)
  int _pocketScore = 0;
  // 🎓 Student Score state (strictly separated from PS for student/kid profiles)
  int _studentScore = 0;
  // 🏆 PocketTalk Spoken Trophies (Earned through 4-Day Spoken Pacts)
  int _pocketTrophyCount = 0;
  // 🏆 Gold Trophies (Earned exclusively through Citadel Fight Duels)
  int _goldTrophies = 0;
  // 🥈 Silver Trophies (Earned through PocketTalk Spoken Pacts)
  int _silverTrophies = 0;
  // ⚔️ Successful Attacks (Raids won / gates breached)
  int _attacksWon = 0;
  // 🌐 Live user Global Rank (Computed directly via PocketRankingService)
  int? _fetchedGlobalRank;

  Future<void> _loadGlobalRank() async {
    try {
      final rank = await PocketRankingService.fetchUserGlobalRank(
        userId,
        _pocketScore > 0 ? _pocketScore : null,
      );
      if (mounted && rank > 0) {
        setState(() {
          _fetchedGlobalRank = rank;
        });
      }
    } catch (e) {
      debugPrint('Error loading user global rank: $e');
    }
  }

  // 🛡️ Student / Teen profile detection matching audio directive
  bool get _isStudentProfile {
    if (PocketKidsService.isStudentWorld) return true;
    final accType = _profileData?['account_type']?.toString().toLowerCase();
    if (accType == 'student' || accType == 'teen') return true;
    final age = _profileData?['age'];
    if (age is num && age > 0 && age <= 20) return true;
    return false;
  }

  Future<void> _loadPocketScore() async {
    try {
      final trophies = await PocketTrophyService.getTrophyCount(userId);
      final gold = await PocketTrophyService.getGoldTrophies(userId);
      final silver = await PocketTrophyService.getSilverTrophies(userId);
      final attacks = await PocketTrophyService.getSuccessfulAttacks(userId);
      if (mounted) {
        setState(() {
          _pocketTrophyCount = trophies;
          _goldTrophies = gold;
          _silverTrophies = silver;
          _attacksWon = attacks;
        });
      }

      // Load isolated Student Score
      final sScore = await PocketKidsService.getStudentScore(userId);
      if (mounted) setState(() => _studentScore = sScore);

      final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
      final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
      if (isRobot) {
        final robot = PocketRobotService.getRobotById(userId) ??
            PocketRobotService.getRobotByLevel(1);
        final dynLvl = PocketRobotService.getDynamicLevel(robot);
        final robotScore =
            await PocketFortressDefenseService.getRobotScore(robot.id, dynLvl);
        if (mounted) {
          setState(() {
            _pocketScore = robotScore;
            _localUserStage = dynLvl;
          });
        }
        return;
      }

      // Query real profile score directly from Supabase to prevent stale 215 cache
      final pRes = await _supabase
          .from('profile')
          .select('pocket_score, xp, learning_points')
          .eq('user_id', userId)
          .maybeSingle();
      int dbScore = 0;
      if (pRes != null) {
        final ps = (pRes['pocket_score'] as num?)?.toInt() ?? 0;
        final xp = (pRes['xp'] as num?)?.toInt() ?? 0;
        final lp = (pRes['learning_points'] as num?)?.toInt() ?? 0;
        dbScore = math.max(ps, math.max(xp, lp));
      }

      final unifiedScore = await PocketFortressDefenseService.getUnifiedScore(userId, true);
      final finalScore = math.max(dbScore, math.max(unifiedScore, _pocketScore));

      // Sync local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_pocket_score_$userId', finalScore);

      // Sync local mates
      final localMates = prefs.getStringList('pocket_mates_$userId') ?? [];
      final dynamicMates = math.max(_friendsCount, localMates.length);

      if (mounted) {
        setState(() {
          _pocketScore = finalScore;
          _friendsCount = dynamicMates;
          final scoreLvl = PocketScoreLevelEngine.getLevelFromScore(finalScore);
          _localUserStage = scoreLvl;
        });
      }
    } catch (_) {}
  }

  // Fortress Citadel & Defense Traps State (User audio: "നിലവിലുള്ള ഡിഫൻസ് എന്തൊക്കെയാണ് എന്നുള്ളത്, എന്തൊക്കെ ക്വസ്റ്റ്യൻസ് ഡിഫൻസ് ഉണ്ട് എന്നുള്ളത് അത് കാണാനും പറ്റണം. അത് നമ്മുടെ മൈ പ്രൊഫൈലില് കാണാൻ പറ്റണം")
  HouseDefenseStatus? _fortressStatus;
  List<HouseShieldQuestion> _shieldQuestions = [];
  List<CitadelRaidLogEntry> _recentRaids = [];
  bool _isLoadingDefense = false;
  bool _isHouseProtected = false;
  int _protectionMinutesLeft = 0;

  Future<void> _loadFortressDefenseData() async {
    final day = _getEffectiveDay();
    try {
      HouseDefenseStatus status =
          await PocketFortressDefenseService.getHouseStatus(day);
      if (!isMe && widget.userId != null) {
        final supaHome =
            await PocketFortressDefenseService.getSupabaseHouse(widget.userId!);
        if (supaHome != null) {
          status = HouseDefenseStatus(
            currentHp: (supaHome['hp'] as num?)?.toInt() ?? 100,
            maxHp: (supaHome['max_hp'] as num?)?.toInt() ?? 100,
            isDamaged: (supaHome['is_damaged'] as bool?) ?? false,
          );
        }
      } else if (isMe) {
        final streak = (_profileData?['daily_streak'] as num?)?.toInt() ?? 1;
        PocketFortressDefenseService.syncMyHouseToSupabase(
            day: day, streak: streak);
      }
      final questions = await PocketFortressDefenseService.loadShieldQuestions(
        day,
        isNeighbor: !isMe,
        targetUserId: !isMe ? widget.userId : null,
      );
      List<CitadelRaidLogEntry> raids =
          await PocketFortressDefenseService.getRecentRaids();
      if (raids.isEmpty && day >= 4) {
        final mockRaid = CitadelRaidLogEntry(
          id: 'mock_raid_${day}_1',
          attackerId: 'robot_citadel_6_0',
          attackerName: 'Cyber Valkyrie 🛡️ #01',
          attackerAvatar: '🤖',
          attackerWeapon: '⚡ Laser Broadsword',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          breached: true,
          coinsLooted: 15,
          ironDomeBlocked: false,
        );
        raids = [mockRaid];
      }

      final houseId = isMe ? 'me' : (widget.userId ?? '');
      final isProtected =
          await PocketFortressDefenseService.isUnderPresidentialProtection(
              houseId);
      final protectionMins = isProtected
          ? await PocketFortressDefenseService
              .getPresidentialProtectionMinutesRemaining(houseId)
          : 0;

      if (mounted) {
        setState(() {
          _fortressStatus = status;
          _shieldQuestions = questions;
          _recentRaids = raids;
          _isHouseProtected = isProtected;
          _protectionMinutesLeft = protectionMins;
          _isLoadingDefense = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading defense data in profile: $e');
    }
  }

  Future<void> _loadEquippedTalisman() async {
    try {
      final talisman = await JackieChanTalismanService.getEquippedTalisman();
      if (mounted) {
        setState(() {
          _equippedTalismanId = talisman.id;
        });
      }
    } catch (_) {}
  }

  void _setProfileViewMode(bool isPublic) {
    if (_isPublicProfileView == isPublic) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isPublicProfileView = isPublic;
    });
  }

  @override
  void dispose() {
    _profileTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Data Loading Logic ---

  Future<void> _loadInitialData() async {
    // 1. Use Props if available
    if (widget.preloadedProfile != null) {
      _applyProfileData(widget.preloadedProfile!);
      if (widget.followersCount != null) {
        _followersCount = _parseCount(widget.followersCount!);
      }
      if (widget.followingCount != null) {
        _followingCount = _parseCount(widget.followingCount!);
      }
      _isLoading = false;
    } else {
      // 2. Try Cache (Local Storage)
      final prefs = await SharedPreferences.getInstance();
      final cachedProfile = prefs.getString('profile_cache_$userId');
      if (cachedProfile != null) {
        try {
          final data = json.decode(cachedProfile);
          if (mounted) {
            setState(() {
              _applyProfileData(data);
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint('Error parsing cached profile: $e');
        }
      }
    }

    // 3. Fetch Fresh Data (Always)
    _loadLocalUserStage();
    _fetchFreshData();
    _fetchEnglishHubData();
    _loadGlobalRank();
  }

  Future<void> _handleProfileRefresh() async {
    try {
      await Future.wait([
        _fetchFreshData(),
        _loadLocalUserStage(),
        _loadFortressDefenseData(),
        _fetchThreads(),
        _loadEquippedTalisman(),
        _fetchEnglishHubData(),
        _loadPocketScore(),
        _loadGlobalRank(),
      ]);
    } catch (e) {
      debugPrint('Profile refresh error: $e');
    }
  }

  Future<void> _fetchEnglishHubData() async {
    if (!isMe) return;

    final prefs = await SharedPreferences.getInstance();
    final points = prefs.getInt('english_hub_points') ?? 0;
    final cachedAnalysis = prefs.getString('english_hub_analysis') ?? '';
    final lastPoints = prefs.getInt('english_hub_last_points') ?? -1;

    setState(() {
      _englishHubPoints = points;
      _hubAnalysis = cachedAnalysis;
    });

    // Re-analyze if points increased by 20 or more, or if it's the first time
    if (points - lastPoints >= 20 || _hubAnalysis.isEmpty) {
      setState(() {
        _isAnalyzingHub = true;
      });

      final prompt =
          'A user in the Poket Mates English Hub has $points points. '
          'Assume 0-100 points is Beginner, 100-500 is Intermediate, and 500+ is Advanced. '
          'Give a very short, encouraging 2-sentence analysis of their progress and tell them what to focus on next (e.g. Grammar, Interview Prep, Communication). Keep it friendly and concise.';

      final response = await AIService().generateText(prompt: prompt);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _hubAnalysis = response.data!;
          _isAnalyzingHub = false;
        });
        await prefs.setString('english_hub_analysis', _hubAnalysis);
        await prefs.setInt('english_hub_last_points', points);
      } else {
        setState(() {
          _isAnalyzingHub = false;
        });
      }
    }
  }

  int _testStageIndex = 0;

  Future<void> _jumpToStage(int targetStage) async {
    final stage = LearningMilestoneStage.getStageForDay(targetStage);
    _testStageIndex = stage.stageNumber - 1;

    setState(() {
      // User colors chosen in "Edit Profile" are never overridden!
      // Only learning stage, UI layout, and avatar evolution change.
      if (_profileData != null) {
        _profileData!['learning_day'] = stage.day;
        _profileData!['learning_stage'] = stage.stageNumber;
      }
      _bgColor = stage.bgColor;
      _textColor = stage.textColor;
      _btnColor = stage.buttonColor;
      _btnTextColor = stage.buttonTextColor;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎨 Stage ${stage.stageNumber}/90: ${stage.emoji} ${stage.stageName} • ${stage.fluencyTier}',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
        ),
        backgroundColor: stage.buttonColor,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Save only stage progression to Supabase, preserving custom theme colors
    try {
      await _supabase.from('profile').update({
        'learning_day': stage.day,
        'learning_stage': stage.stageNumber,
      }).eq('user_id', userId);
      _loadFortressDefenseData();
    } catch (e) {
      debugPrint('Error updating learning stage: $e');
    }
  }

  void _applyProfileData(Map<String, dynamic> data) {
    _profileData = data;
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
    int effectiveStage;
    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      effectiveStage = PocketRobotService.getDynamicLevel(robot);
    } else {
      final rawScore = (data['pocket_score'] as num?)?.toInt() ?? 0;
      final xpScore = (data['xp'] as num?)?.toInt() ?? 0;
      final score = math.max(_pocketScore, math.max(rawScore, xpScore));
      _pocketScore = score;
      effectiveStage = PocketScoreLevelEngine.getLevelFromScore(score);
    }
    if (!(_isTestingStage && isMe && _isAdminUser())) {
      _localUserStage = effectiveStage;
      final stage = LearningMilestoneStage.getStageForDay(effectiveStage);
      _testStageIndex = (stage.stageNumber - 1)
          .clamp(0, LearningMilestoneStage.allStages.length - 1);

      // Dynamic Level-Based Theme Colors
      _bgColor = stage.bgColor;
      _textColor = stage.textColor;
      _btnColor = stage.buttonColor;
      _btnTextColor = stage.buttonTextColor;
    }

    // Default to showing Vector Avatar profile for all users (Audio directive: "അവതാർ പ്രൊഫൈൽ ആണ് കൊടുക്കേണ്ടത്")
    _showAvatarMode = true;
  }

  Future<void> _fetchFreshData() async {
    try {
      if (mounted && _profileData == null) setState(() => _isLoading = true);

      final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
      final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;

      if (isRobot) {
        final robot = PocketRobotService.getRobotById(userId) ??
            PocketRobotService.getRobotByLevel(1);
        final dynamicLevel = PocketRobotService.getDynamicLevel(robot);
        final myId = _supabase.auth.currentUser?.id ?? '';
        final isMate = myId.isNotEmpty
            ? await PocketMateService.isMate(myId, robot.id)
            : false;
        final prefs = await SharedPreferences.getInstance();
        final blockedList = myId.isNotEmpty
            ? (prefs.getStringList('blocked_users_$myId') ?? [])
            : <String>[];
        final isBlocked = blockedList.contains(robot.id);

        final robotData = {
          'user_id': robot.id,
          'first_name': robot.name,
          'name': robot.name,
          'shop_name': robot.archetype.label,
          'bio': robot.bio,
          'profile_image_url': robot.avatarUrl,
          'learning_day': dynamicLevel,
          'streak': dynamicLevel,
          'rank': robot.cefrRank,
          'palette_id': robot.housePalette,
          'is_pocket_robo': true,
          'verified': true,
          'bg_color_code': '#0F111A',
          'bg_text_color': '#FFFFFF',
          'button_color_code': '#0095F6',
          'button_text_color': '#FFFFFF',
        };

        final robotGallery = PocketRobotService.getRobotGalleryItems(robot.id);
        final robotThreads = PocketRobotService.getRobotThreads(robot.id);

        if (mounted) {
          setState(() {
            _isFollowing = isMate;
            _isBlocked = isBlocked;
            _isRequested = false;
            _isMate = isMate;
            _isMateRequested = false;
            _followersCount = 100 + (dynamicLevel * 14);
            _followingCount = 15 + (dynamicLevel % 30);
            _friendsCount = dynamicLevel * 3;
            _applyProfileData(robotData);
            _galleryItems = robotGallery;
            _filteredGalleryItems = robotGallery;
            _threadItems = robotThreads;
            _isLoading = false;
          });
        }
        return;
      }

      final myId = _supabase.auth.currentUser?.id;
      final responses = await Future.wait<dynamic>([
        _supabase
            .from('profile')
            .select()
            .eq('user_id', userId)
            .limit(1), // Profile
        _supabase.from('gallery').select().eq('user_id', userId).order(
            'created_at',
            ascending: false), // Recent Gallery directly from gallery table
        _fetchFollowCountsMap(), // Counts Map
        _checkFollowStatusBool(),
        _checkBlockStatusBool(),
        (myId != null && myId != userId)
            ? _supabase
                .from('notifications')
                .select('id')
                .eq('sender_id', myId)
                .eq('user_id', userId)
                .eq('type', 'follow_request')
                .eq('status', 'pending')
                .maybeSingle()
            : Future.value(null),
        (myId != null && myId.isNotEmpty && myId != userId)
            ? PocketMateService.isMate(myId, userId)
            : Future.value(false),
        (myId != null && myId != userId)
            ? _supabase
                .from('notifications')
                .select('id')
                .eq('sender_id', myId)
                .eq('user_id', userId)
                .eq('type', 'mate_request')
                .eq('status', 'pending')
                .maybeSingle()
            : Future.value(null),
        (myId != null && myId != userId)
            ? _supabase
                .from('notifications')
                .select('*')
                .eq('sender_id', userId)
                .eq('user_id', myId)
                .inFilter('type', ['mate_request', 'pocket_talk'])
                .eq('status', 'pending')
                .maybeSingle()
            : Future.value(null),
      ]);

      if (!mounted) return;

      final profileRes = responses[0] as List;
      final galleryRes = responses[1] as List;
      final counts = responses[2] as Map<String, int>;
      final followStatus = responses[3] as bool;
      final blockStatus = responses[4] as bool;
      final requestRes = responses[5];
      final mateStatus = responses[6] as bool;
      final mateReqRes = responses[7];
      final incomingReqRes = responses.length > 8 ? responses[8] : null;

      final isRequested = requestRes != null;
      final isMateRequested = mateReqRes != null;

      if (incomingReqRes != null && _incomingMateRequest == null) {
        _incomingMateRequest = Map<String, dynamic>.from(incomingReqRes as Map);
      }

      if (profileRes.isNotEmpty) {
        final data = profileRes.first as Map<String, dynamic>;
        setState(() {
          _isFollowing = followStatus;
          _isBlocked = blockStatus;
          _isRequested = isRequested;
          _isMate = mateStatus;
          _isMateRequested = isMateRequested;
          _applyProfileData(data);
          _isLoading = false;
        });
        // Cache this fresh data
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('profile_cache_$userId', json.encode(data));
      } else {
        // Profile record does not exist yet!
        if (isMe) {
          try {
            final email = _supabase.auth.currentUser?.email ?? '';
            final fallbackName =
                email.contains('@') ? email.split('@').first : 'Pocket Mate';
            final cleanSlug =
                fallbackName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

            // Ensure public.users row exists
            await _supabase.from('users').upsert({
              'id': userId,
              'email': email,
            }, onConflict: 'id');

            final fallbackProfile = {
              'id': userId,
              'user_id': userId,
              'name': fallbackName,
              'shop_name': fallbackName.toLowerCase().replaceAll(' ', '-'),
              'slug': cleanSlug.isNotEmpty
                  ? cleanSlug
                  : 'mate${DateTime.now().millisecondsSinceEpoch % 10000}',
              'learning_day': 1,
              'learning_stage': 1,
              'learning_points': 0,
              'xp': 0,
              'native_language': PocketLanguageService.currentLanguage,
              'english_level': 'Beginner (A1-A2)',
              'learning_goal': 'Daily Fluency & Speaking',
            };

            await _supabase
                .from('profile')
                .upsert(fallbackProfile, onConflict: 'user_id');

            if (mounted) {
              setState(() {
                _isFollowing = followStatus;
                _isBlocked = blockStatus;
                _isRequested = isRequested;
                _isMate = mateStatus;
                _isMateRequested = isMateRequested;
                _applyProfileData(fallbackProfile);
                _isLoading = false;
              });
            }
          } catch (autoHealErr) {
            debugPrint(
                'Error auto-healing profile in MainProfileWidget: $autoHealErr');
            if (mounted) setState(() => _isLoading = false);
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      }

      // Process Gallery
      final Map<String, Map<String, dynamic>> uniqueGallery = {};
      Set<String> categorySet = {};

      for (var item in galleryRes) {
        final id = item['id']?.toString() ?? item['gallery_id']?.toString();
        if (id != null) {
          // Normalize view & table keys for legacy support
          final Map<String, dynamic> normalizedItem =
              Map<String, dynamic>.from(item);
          normalizedItem['gallery_id'] = item['id'] ?? item['gallery_id'];
          normalizedItem['gallery_image_url'] =
              item['image_url'] ?? item['gallery_image_url'];
          normalizedItem['gallery_title'] =
              item['title'] ?? item['gallery_title'];
          normalizedItem['gallery_price'] =
              item['price'] ?? item['gallery_price'];
          normalizedItem['gallery_description'] =
              item['description'] ?? item['gallery_description'];
          normalizedItem['gallery_category'] =
              item['category'] ?? item['gallery_category'];

          uniqueGallery[id] = normalizedItem;
          final category = normalizedItem['category']?.toString().trim() ??
              normalizedItem['gallery_category']?.toString().trim();
          if (category != null &&
              category.isNotEmpty &&
              category.toLowerCase() != 'all') {
            categorySet.add(category);
          }
        }
      }

      setState(() {
        _galleryItems = uniqueGallery.values.toList();
        List<String> sortedCategories = categorySet.toList()..sort();
        _categories = ['All', ...sortedCategories];
        _filteredGalleryItems = _galleryItems;
        _followersCount = counts['followers'] ?? 0;
        _followingCount = counts['following'] ?? 0;
        _friendsCount = counts['friends'] ?? 0;
        _isFollowing = followStatus;
        _isBlocked = blockStatus;
        _isRequested = isRequested;
      });

      // Lazy load full lists in background
      _fetchFullLists();
      _fetchThreads();
    } catch (e) {
      debugPrint('Error fetching fresh data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFullLists() async {
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    if (!isUuid || PocketRobotService.isRobotId(userId)) return;

    // Fetch remaining gallery
    try {
      final allGallery = await _supabase
          .from('gallery')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        final Map<String, Map<String, dynamic>> uniqueGallery = {};
        Set<String> categorySet = {};
        for (var item in allGallery) {
          final id = item['id']?.toString() ?? item['gallery_id']?.toString();
          if (id != null) {
            // Normalize view & table keys for legacy support
            final Map<String, dynamic> normalizedItem =
                Map<String, dynamic>.from(item);
            normalizedItem['gallery_id'] = item['id'] ?? item['gallery_id'];
            normalizedItem['gallery_image_url'] =
                item['image_url'] ?? item['gallery_image_url'];
            normalizedItem['gallery_title'] =
                item['title'] ?? item['gallery_title'];
            normalizedItem['gallery_price'] =
                item['price'] ?? item['gallery_price'];
            normalizedItem['gallery_description'] =
                item['description'] ?? item['gallery_description'];
            normalizedItem['gallery_category'] =
                item['category'] ?? item['gallery_category'];

            uniqueGallery[id] = normalizedItem;
            final cat = normalizedItem['category']?.toString().trim() ??
                normalizedItem['gallery_category']?.toString().trim();
            if (cat != null && cat.isNotEmpty && cat.toLowerCase() != 'all') {
              categorySet.add(cat);
            }
          }
        }
        setState(() {
          _galleryItems = uniqueGallery.values.toList();
          List<String> sortedCategories = categorySet.toList()..sort();
          _categories = ['All', ...sortedCategories];
          if (_selectedCategory == 'All') {
            _filteredGalleryItems = _galleryItems;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching gallery list: $e');
    }
  }

  Future<void> _fetchThreads() async {
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    if (!isUuid || PocketRobotService.isRobotId(userId)) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      if (mounted) {
        setState(() {
          _threadItems = robot.catchphrases
              .map((c) => {
                    'content': c,
                    'created_at': DateTime.now()
                        .subtract(const Duration(hours: 3))
                        .toIso8601String(),
                    'user_id': robot.id,
                    'user_name': robot.name,
                    'user_image_url': robot.avatarUrl,
                  })
              .toList();
        });
      }
      return;
    }

    try {
      final res = await _supabase
          .from('threads_view')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _threadItems = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error fetching threads: $e');
    }
  }

  Future<Map<String, int>> _fetchFollowCountsMap() async {
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    if (!isUuid || PocketRobotService.isRobotId(userId)) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      final dynLvl = PocketRobotService.getDynamicLevel(robot);
      return {
        'followers': 100 + (dynLvl * 14),
        'following': 15 + (dynLvl % 30),
        'friends': dynLvl * 3,
      };
    }

    try {
      // Get followers count - people who follow this user
      final followersRes = await _supabase
          .from('follows')
          .select('follower_id')
          .eq('followed_id', userId);

      // Get following count - people this user follows
      final followingRes = await _supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', userId);

      // Calculate mutual friends
      final followerIds = (followersRes as List)
          .map((e) => e['follower_id'].toString())
          .toSet();
      final followingIds = (followingRes as List)
          .map((e) => e['followed_id'].toString())
          .toSet();
      final mutualFriends = followerIds.intersection(followingIds);

      // Get base followers count from users table
      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', userId)
          .maybeSingle();

      int baseFollowers = 0;
      if (userResponse != null && userResponse['followers'] != null) {
        baseFollowers = (userResponse['followers'] as num).toInt();
      }

      // Also include accepted robot mates from local storage
      final prefs = await SharedPreferences.getInstance();
      final localMates = prefs.getStringList('pocket_mates_$userId') ?? [];
      final robotMatesCount =
          localMates.where((id) => PocketRobotService.isRobotId(id)).length;

      return {
        'followers': followerIds.length + baseFollowers + robotMatesCount,
        'following': followingIds.length + robotMatesCount,
        'friends': mutualFriends.length + robotMatesCount,
      };
    } catch (e) {
      debugPrint('Error fetching follow counts: $e');
      return {'followers': 0, 'following': 0};
    }
  }

  Future<bool> _checkFollowStatusBool() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return false;
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    if (!isUuid || PocketRobotService.isRobotId(userId)) {
      return await PocketMateService.isMate(myId, userId);
    }
    final res = await _supabase
        .from('follows')
        .select()
        .eq('follower_id', myId)
        .eq('followed_id', userId)
        .maybeSingle();
    return res != null;
  }

  Future<bool> _checkBlockStatusBool() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return false;
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    if (!isUuid || PocketRobotService.isRobotId(userId)) {
      final prefs = await SharedPreferences.getInstance();
      final blocked = prefs.getStringList('blocked_users_$myId') ?? [];
      return blocked.contains(userId);
    }
    final res = await _supabase
        .from('blocks')
        .select()
        .eq('blocker_id', myId)
        .eq('blocked_id', userId)
        .maybeSingle();
    return res != null;
  }

  void _filterGalleryByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredGalleryItems = _galleryItems;
      } else {
        _filteredGalleryItems = _galleryItems.where((item) {
          final cat = item['category']?.toString().trim() ??
              item['gallery_category']?.toString().trim();
          return cat == category;
        }).toList();
      }
    });
  }

  // --- Helpers ---

  Color? _parseColor(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return Color(int.parse(code.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  int _parseCount(String countStr) {
    return int.tryParse(countStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> _toggleFollow() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;

    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(1);
      final newFollow = !_isFollowing;
      setState(() {
        _isFollowing = newFollow;
        _followersCount += newFollow ? 1 : -1;
      });
      if (newFollow) {
        await PocketRobotService.acceptRobotRequest(
            myId: myId, robotId: robot.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Connected with ${robot.name}! You are now Poket Mates ✨'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList('pocket_mates_$myId') ?? [];
        list.remove(robot.id);
        await prefs.setStringList('pocket_mates_$myId', list);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed ${robot.name} from Poket Mates.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    final isPrivate = _profileData?['is_private'] == true;

    if (isPrivate && !_isFollowing) {
      final oldRequested = _isRequested;
      setState(() {
        _isRequested = !_isRequested;
      });

      try {
        if (_isRequested) {
          final myProfile = await _supabase
              .from('profile')
              .select('name')
              .eq('user_id', myId)
              .maybeSingle();
          final myName = myProfile?['name'] ?? 'Someone';
          await _supabase.from('notifications').insert({
            'user_id': userId,
            'sender_id': myId,
            'message': '$myName wants to follow you.',
            'type': 'follow_request',
            'status': 'pending',
          });
        } else {
          await _supabase
              .from('notifications')
              .delete()
              .eq('sender_id', myId)
              .eq('user_id', userId)
              .eq('type', 'follow_request')
              .eq('status', 'pending');
        }
      } catch (e) {
        setState(() {
          _isRequested = oldRequested;
        });
      }
      return;
    }

    setState(() {
      _isFollowing = !_isFollowing;
      _followersCount += _isFollowing ? 1 : -1;
    });

    try {
      if (_isFollowing) {
        await _supabase
            .from('follows')
            .insert({'follower_id': myId, 'followed_id': userId});
      } else {
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', myId)
            .eq('followed_id', userId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isFollowing = !_isFollowing;
        _followersCount += _isFollowing ? 1 : -1;
      });
    }
  }

  Widget _buildAirDropMateBanner(BuildContext context, Color textColor) {
    if (_incomingMateRequest == null) return const SizedBox.shrink();
    final req = _incomingMateRequest!;
    final senderName = _profileData?['name']?.toString() ??
        _profileData?['username']?.toString() ??
        req['sender_name']?.toString() ??
        'Pocket Mate';
    final senderAvatar = _profileData?['profile_picture_url']?.toString() ??
        _profileData?['avatar_url']?.toString() ??
        req['sender_profile_image']?.toString();
    final message = req['message']?.toString() ??
        'Wants to connect with you as your Pocket Mate!';

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xF20F172A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFFC00), width: 1.6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFFC00), width: 1.8),
                  ),
                  child: ClipOval(
                    child: (senderAvatar != null && senderAvatar.startsWith('http'))
                        ? CachedNetworkImage(
                            imageUrl: senderAvatar,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: Colors.white12),
                            errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                          )
                        : Container(
                            color: const Color(0xFF1E293B),
                            child: Center(
                              child: Text(
                                (senderAvatar != null && senderAvatar.isNotEmpty) ? senderAvatar : '👤',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
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
                          Flexible(
                            child: Text(
                              senderName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AirDrop Prompt',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFFC00),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final myUid = _supabase.auth.currentUser?.id ?? '';
                    final notifId = req['id']?.toString() ?? '';
                    final senderId = req['sender_id']?.toString() ?? userId;
                    if (notifId.isNotEmpty) {
                      await PocketMateService.declineMateRequest(
                        notificationId: notifId,
                        myId: myUid,
                        senderId: senderId,
                      );
                    }
                    if (mounted) {
                      setState(() => _incomingMateRequest = null);
                    }
                  },
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final myUid = _supabase.auth.currentUser?.id ?? '';
                    final notifId = req['id']?.toString() ?? '';
                    final senderId = req['sender_id']?.toString() ?? userId;
                    final ok = await PocketMateService.acceptMateRequest(
                      notificationId: notifId,
                      myId: myUid,
                      senderId: senderId,
                    );
                    if (ok && mounted) {
                      setState(() {
                        _incomingMateRequest = null;
                        _isMate = true;
                        _isMateRequested = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0F172A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                          ),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '🎉 Connected as Pocket Mates! Chat is ready in All.',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.handshake_rounded, size: 16, color: Colors.black),
                  label: Text(
                    'Accept 🤝',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSendMateRequestSheet(String targetName) {
    final messageController = TextEditingController(
      text: "Hi $targetName, let's connect and practice English together!",
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B26),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: Color(0xFFFFFC00), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect with $targetName',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Send a Mate Request to start 1-on-1 chatting',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 📜 4-Day Spoken Pact Agreement Terms Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'PocketTalk 4-Day Spoken Agreement',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Chat 15 minutes each day for 4 consecutive days (1 Hour Total)\n'
                    '• ⚠️ ' + PocketLanguageService.localize(
                      en: 'Skipping a day breaks the pact and deducts 1 Trophy\n',
                      ml: 'Skipping a day breaks the pact and deducts 1 Trophy (കമ്മിയാവും)\n',
                      ta: 'ஒரு நாளைத் தவறவிட்டால் உடன்படிக்கை முறிந்து 1 கோப்பை கழிக்கப்படும்\n',
                      hi: 'एक दिन छोड़ने पर समझौता टूट जाएगा और 1 ट्रॉफी कम हो जाएगी\n',
                    ) +
                    '• English only: Non-English can be reported & penalized\n'
                    '• Complete 4 days to earn +1 Spoken Trophy 🏆 & unlock full profile!',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 2,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add an intro note...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F121A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel',
                        style: GoogleFonts.outfit(color: Colors.white60)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final myId = _supabase.auth.currentUser?.id;
                      if (myId == null) return;
                      Navigator.pop(ctx);
                      final ok = await PocketMateService.sendMateRequest(
                        senderId: myId,
                        receiverId: userId,
                        message: messageController.text.trim(),
                        contextType: 'english_hub',
                      );
                      // ⚡ Ensure PocketTalk 4-Day Pact is immediately created and placed in the main chat list
                      await PocketTrophyService.ensurePact(
                          myId: myId, otherUserId: userId);
                      if (ok && mounted) {
                        setState(() => _isMateRequested = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF10B981), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pact Agreement sent! $targetName will see it in their Requests tab.',
                                    style:
                                        GoogleFonts.outfit(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1E293B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Agree & Connect 🤝',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPocketTalkChallengeFromProfile() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;
    final targetId = userId;
    if (targetId.isEmpty) return;
    final targetName = _profileData?['name']?.toString() ?? _profileData?['display_name']?.toString() ?? 'Mate';
    final targetAvatar = _profileData?['profile_picture_url']?.toString() ?? _profileData?['avatar_url']?.toString();

    HapticFeedback.heavyImpact();
    final ok = await PocketMateService.sendMateRequest(
      senderId: myId,
      receiverId: targetId,
      receiverName: targetName,
      receiverAvatarUrl: targetAvatar,
      message: 'Challenged you to a 4-Day Spoken English Pact ⚡ (15 mins/day). Check your Poketalk tab!',
      contextType: 'pocket_talk',
    );

    await PocketTrophyService.requestPact(
      myId: myId,
      otherUserId: targetId,
    );

    // Save to SharedPreferences sent cache so it appears instantly under Sent tab
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentKey = 'poket_talk_sent_candidates_$myId';
      final currentSentJson = prefs.getStringList(sentKey) ?? [];
      final candidateMap = {
        'id': targetId,
        'user_id': targetId,
        'receiver_id': targetId,
        'receiver_name': targetName,
        'receiver_avatar': targetAvatar,
        'context_type': 'pocket_talk',
        'message': '⚡ 4-Day Spoken English Pact Request (Pending)',
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      };
      currentSentJson.removeWhere((item) => item.contains(targetId));
      currentSentJson.insert(0, jsonEncode(candidateMap));
      await prefs.setStringList(sentKey, currentSentJson);
    } catch (_) {}

    if (mounted) {
      setState(() => _isMateRequested = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚡ 4-Day Pocket Talk Challenge sent to $targetName! Check Requests & Chats.',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1B4B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  int _getUserGlobalRank() {
    final targetId =
        widget.userId ?? SupaFlow.client.auth.currentUser?.id ?? '';
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(targetId);
    final isRobot = PocketRobotService.isRobotId(targetId) || !isUuid;
    final isPresident = _profileData?['is_president'] == true ||
        _profileData?['role'] == 'president';
    if (isPresident) return 1;
    if (isRobot) {
      final dynLvl = _getEffectiveDay();
      return dynLvl.clamp(1, 90);
    }
    if (_fetchedGlobalRank != null && _fetchedGlobalRank! > 0) {
      return _fetchedGlobalRank!;
    }
    final cachedRank = PocketRankingService.getCachedGlobalRank(targetId);
    if (cachedRank != null && cachedRank > 0) return cachedRank;
    return 0;
  }

  // --- UI Construction ---

  @override
  Widget build(BuildContext context) {
    if (_isBlocked) {
      return material.Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Center(
          child: Text(
            "You have blocked this user.",
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (_isLoading && _profileData == null) {
      return material.Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Center(
          child: material.CircularProgressIndicator(
            valueColor: material.AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary),
            strokeWidth: 3,
          ),
        ),
      );
    }

    final int userRank = _getUserGlobalRank();
    final bool isTop10 = userRank > 0 && userRank <= 10;
    final rankTheme = isTop10 ? PocketTopRankTheme.getThemeForRank(userRank) : null;

    final Color bgColor;
    final Color textColor;
    final Color secondaryTextColor;
    final Color dividerColor;
    final Color btnColor;
    final Color btnTextColor;
    final List<Color>? bgGradient;

    if (rankTheme != null) {
      bgGradient = rankTheme.gradientColors;
      bgColor = rankTheme.dominantBg;
      textColor = rankTheme.textColor;
      secondaryTextColor = rankTheme.secondaryTextColor;
      dividerColor = rankTheme.borderColor.withValues(alpha: 0.25);
      btnColor = rankTheme.btnColor;
      btnTextColor = rankTheme.btnTextColor;
    } else {
      bgGradient = null;
      bgColor = const Color(0xFF000000);
      textColor = const Color(0xFFFFFFFF);
      secondaryTextColor = const Color(0xFFA8A8A8);
      dividerColor = const Color(0xFF262626);
      btnColor = const Color(0xFF262626);
      btnTextColor = const Color(0xFFFFFFFF);
    }

    return material.Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: bgGradient != null
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: bgGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : null,
        child: material.Stack(
          children: [
            PocketSnapFlameRefresh(
              onRefresh: _handleProfileRefresh,
              primaryFlameColor: const Color(0xFFFFFC00),
              accentFlameColor: const Color(0xFFFF5722),
              pullText: 'Pull to refresh profile... 🔥',
              readyText: 'Release to update! ✨',
              refreshingText: 'Refreshing profile & citadel... 🔥',
              successText: 'Profile updated! ✨',
              child: material.NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    if (!widget.hideAppBar)
                      material.SliverAppBar(
                        elevation: 0,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        leading: material.IconButton(
                          icon: const Icon(material.Icons.arrow_back, size: 22),
                          color: textColor,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                title: Text(
                  _profileData?['username'] ??
                      _profileData?['shop_name'] ??
                      _profileData?['name'] ??
                      '',
                  style: GoogleFonts.outfit(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: false,
                actions: [
                  if (isMe) ...[
                    material.IconButton(
                      icon: const Icon(material.Icons.gps_fixed_rounded, size: 21),
                      color: const Color(0xFFFFD700),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        PocketCitadelAttackPage.openForUser(
                          context,
                          userId: userId,
                          isDefenseMode: true,
                          attackerDay: _getEffectiveDay(),
                        );
                      },
                      tooltip: 'Preview Attack Profile / Citadel Defense',
                    ),
                    material.IconButton(
                      icon:
                          const Icon(material.Icons.settings_rounded, size: 22),
                      color: textColor,
                      onPressed: () {
                        material.Navigator.push(
                          context,
                          material.MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      tooltip: 'Settings',
                    ),
                  ],
                  if (!isMe)
                    PopupMenuButton<String>(
                      icon: const Icon(material.Icons.more_vert),
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white24),
                      ),
                      iconColor: textColor,
                      onSelected: (value) async {
                        final authorName = _profileData?['name']?.toString() ??
                            _profileData?['display_name']?.toString() ??
                            'User';
                        final authorHandle =
                            _profileData?['username']?.toString() ?? authorName;
                        final targetUid = userId;
                        if (value == 'Report') {
                          ReportHelper.showReportDialog(
                            context: context,
                            contentType: 'user',
                            contentId: targetUid,
                            contentTitle: '$authorName (@$authorHandle)',
                            onReportSubmitted: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Report submitted. Thank you for keeping Poket Mates safe.'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          );
                        } else if (value == 'Block') {
                          final blocked = await ReportHelper.blockUser(
                            context: context,
                            targetUserId: targetUid,
                            targetUserName: authorName,
                            onBlocked: () {
                              if (mounted) {
                                setState(() {
                                  _isBlocked = true;
                                  _isFollowing = false;
                                });
                              }
                            },
                          );
                          if (blocked && mounted) {
                            setState(() {
                              _isBlocked = true;
                              _isFollowing = false;
                            });
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Report',
                          child: Row(
                            children: [
                              Icon(Icons.flag_rounded,
                                  color: Colors.orangeAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Report User',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Block',
                          child: Row(
                            children: [
                              Icon(Icons.block_rounded,
                                  color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Block User',
                                  style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              material.SliverToBoxAdapter(
                child: _buildProfileHeader(
                    textColor, btnColor, btnTextColor, isMe),
              ),
              if (!(_profileData?['is_private'] == true &&
                      !_isFollowing &&
                      !isMe))
                material.SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    material.TabBar(
                      key: ValueKey('tab_bar_profile_$isMe'),
                      controller: _profileTabController,
                      labelColor: textColor,
                      unselectedLabelColor: textColor.withValues(alpha: 0.4),
                      indicatorColor: isTop10 ? btnColor : textColor,
                      indicatorWeight: 1.5,
                      tabs: const [
                        material.Tab(
                          icon: Icon(material.Icons.grid_on_rounded, size: 22),
                        ),
                        material.Tab(
                          icon: Icon(material.Icons.forum_outlined, size: 22),
                        ),
                        material.Tab(
                          icon: Icon(material.Icons.fort_rounded, size: 22),
                        ),
                        material.Tab(
                          icon: Icon(material.Icons.face_retouching_natural_rounded, size: 22),
                        ),
                      ],
                    ),
                    bgColor,
                  ),
                ),
            ];
          },
          body: Container(
            color: bgColor,
            child: ((_profileData?['is_private'] == true || !_isMate) && !isMe)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B4B),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.4),
                                width: 1.5),
                          ),
                          child: const Text('🔒',
                              style: TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Profile Locked: PocketTalk in Progress",
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            "Full social bio, photos and updates unlock once you complete the 4-Day Spoken Pact and earn your Mates Trophy 🏆 together!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: textColor.withValues(alpha: 0.65),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isMateRequested
                              ? null
                              : () =>
                                  _sendPocketTalkChallengeFromProfile(),
                          icon: const Icon(Icons.bolt_rounded, size: 20),
                          label: Text(
                            _isMateRequested
                                ? 'Request Pending ⏳'
                                : 'Challenge to Pocket Talk ⚡',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : material.TabBarView(
                    key: ValueKey('tab_view_profile_$isMe'),
                    controller: _profileTabController,
                    children: [
                      _buildAdultCardsTab(textColor, bgColor),
                      _ThreadsTab(
                        items: _threadItems,
                        textColor: textColor,
                        btnColor: btnColor,
                        btnTextColor: btnTextColor,
                      ),
                      _buildCitadelHouseTab(textColor, btnColor, isMe),
                      _buildCompanionsMilestoneTab(textColor, btnColor, isMe),
                    ],
                  ),
            ),
          ),
        ),
      ],
    ),
      ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isMe ? _buildProfileCenterAddButton() : null,
    );
  }

  /// 🏰 Citadel, English House & Defense Tab (3rd Tab of Adult Profile)
  Widget _buildCitadelHouseTab(Color textColor, Color btnColor, bool isMe) {
    int day = _getEffectiveDay();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
                        if (_isHouseProtected) ...[
                          // 🚧 Yellow & Black Police Crime Scene Tape & Sentries (User Audio Directive)
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFCA8A04), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🚧',
                                        style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'CRIME SCENE • DO NOT CROSS • POLICE INVESTIGATION',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF78350F),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('🚧',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('👮‍♂️ 🚔 👮‍♀️',
                                          style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 8),
                                      Text(
                                        '24H PRESIDENTIAL POLICE SHIELD (${(_protectionMinutesLeft / 60).toStringAsFixed(1)}h remaining)',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF38BDF8),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        FlameEnglishHouseWidget(
                          key: ValueKey('house_${_getEffectiveDay()}'),
                          currentDay: _getEffectiveDay(),
                          streak: (_profileData?['daily_streak'] as num?)
                                  ?.toInt() ??
                              1,
                          isDamaged: _fortressStatus?.isDamaged ?? false,
                          houseId: isMe ? 'me' : (widget.userId ?? ''),
                          showTestingControls: false,
                          onDayChanged: (d) => _jumpToDay(d),
                        ),
                        if (!isMe) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  final day = _getEffectiveDay();
                                  final streak =
                                      (_profileData?['daily_streak'] as num?)
                                              ?.toInt() ??
                                          1;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PocketWorldStreetPage(
                                        currentDay: day,
                                        streak: streak,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.flash_on_rounded,
                                    size: 20),
                                label: Text(
                                  'VISIT ON STREET & RAID CITADEL ⚔️',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _isMateRequested
                                    ? null
                                    : () => _sendPocketTalkChallengeFromProfile(),
                                icon: const Icon(Icons.bolt_rounded,
                                    color: Color(0xFFFFD700), size: 22),
                                label: Text(
                                  _isMateRequested
                                      ? 'POCKET TALK REQUEST PENDING ⏳'
                                      : 'CHALLENGE TO POCKET TALK (4-DAY PACT) ⚡',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (_fortressStatus?.presidentNotice != null) ...[
                          _buildPresidentNoticeBanner(),
                          const SizedBox(height: 16),
                        ],
                        if (_fortressStatus?.isJailed == true) ...[
                          _buildJailSentenceBanner(),
                          const SizedBox(height: 16),
                        ],
                        if (isMe) ...[
                          const SizedBox(height: 16),
                          _buildMinimalAttackersSection(),
                          const SizedBox(height: 16),
                          _buildCitadelFightArenaDesk(),
                        ] else ...[
                          const SizedBox(height: 16),
                          _buildOtherUserCitadelSection(day, textColor, btnColor),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
  }

  /// 🎴 Collectible Milestone PopArt Cards Tab for Public Profiles (User Audio Directive!)
  Widget _buildAdultCardsTab(Color textColor, Color bgColor) {
    final effectiveDay = _getEffectiveDay().clamp(1, 90);
    final genderStr = _profileData?['gender']?.toString().toLowerCase() ?? '';
    final isMale = genderStr == 'male' ||
        genderStr == 'boy' ||
        (!genderStr.contains('female') && !genderStr.contains('girl'));

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.72,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 90,
          itemBuilder: (context, index) {
            final cardDay = index + 1;
            final isUnlocked = cardDay <= effectiveDay;
            final card =
                PopArtCardHelper.getCardForDay(cardDay, isMale: isMale);

            final gameInfo = PocketCitadelChallengeGenerator.getGameForUserCard(
                widget.userId ?? 'adult_hero', cardDay);
            final difficulty =
                PocketCitadelChallengeGenerator.getDifficultyForUserCard(
                    widget.userId ?? 'adult_hero', cardDay);

            if (!isUnlocked) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  PocketDefenseCardDetailSheet.show(
                    context,
                    card: card,
                    cardDay: cardDay,
                    gameInfo: gameInfo,
                    difficulty: difficulty,
                    isUnlocked: false,
                    isCardLost: false,
                    isKidMode: false,
                    defenderId: widget.userId ?? 'adult_hero',
                    defenderName: _profileData?['username'] ??
                        _profileData?['name'] ??
                        'Defender',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded,
                          color: Color(0xFF64748B), size: 22),
                      const SizedBox(height: 4),
                      Text(
                        'Day $cardDay',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'LOCKED',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF475569),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                PocketDefenseCardDetailSheet.show(
                  context,
                  card: card,
                  cardDay: cardDay,
                  gameInfo: gameInfo,
                  difficulty: difficulty,
                  isUnlocked: true,
                  isCardLost: false,
                  isKidMode: false,
                  defenderId: widget.userId ?? 'adult_hero',
                  defenderName: _profileData?['username'] ??
                      _profileData?['name'] ??
                      'Defender',
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(painter: PopArtCardCustomPainter(data: card)),
                      Positioned(
                        top: 3,
                        left: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Day $cardDay',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 3,
                        left: 3,
                        right: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 1.5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: const Color(0xFF38BDF8), width: 0.6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(gameInfo.icon,
                                  style: const TextStyle(fontSize: 7.5)),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  gameInfo.title,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

  // ➕ Center Floating Action Button (Audio Directive 3)
  Widget _buildProfileCenterAddButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFFFC00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.mediumImpact();
            _showAddActionSheet();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.black, size: 22),
                SizedBox(width: 6),
                Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddActionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2129) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create & Share',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: isDark ? Colors.white60 : Colors.black45,
                          size: 22),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // "Add Product" hidden per directive to align app strictly with English Learning ecosystem
                _buildAddSheetOption(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Add Thought',
                  subtitle: 'Post a quick quote, idea or note',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddThoughtModal();
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildAddSheetOption(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFFFB300),
                  title: 'Add Vibes',
                  subtitle: '10s auto-slicing video or photo story',
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SnapchatStoryCreatorPage(
                          userId: userId,
                          profileId: _profileData?['id']?.toString() ?? userId,
                          onStatusUploaded: () => _loadInitialData(),
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddSheetOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262A35) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white30 : Colors.black26,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddThoughtModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2129) : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Share a Thought 💭',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded,
                                color:
                                    isDark ? Colors.white60 : Colors.black45),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        maxLength: 300,
                        autofocus: true,
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15),
                        decoration: InputDecoration(
                          hintText:
                              "What's on your mind today? Write in English or Malayalam...",
                          hintStyle: GoogleFonts.outfit(
                              color: isDark ? Colors.white38 : Colors.black38),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF262A35)
                              : const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final text = controller.text.trim();
                                  if (text.isEmpty) return;

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _supabase.from('threads').insert({
                                      'user_id': userId,
                                      'content': text,
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Thought posted successfully! ✨',
                                            style: GoogleFonts.outfit(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor:
                                              const Color(0xFFFFFC00),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      Navigator.pop(ctx);
                                      _loadInitialData();
                                    }
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to post thought: $e')),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.black),
                                )
                              : Text(
                                  'Post Thought',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
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
      },
    );
  }

  Future<void> _pickAndUploadGalleryImage() async {
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading image to gallery...',
                  style: GoogleFonts.outfit(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      final bytes = await picked.readAsBytes();
      final fileName =
          'gallery_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('gallery').uploadBinary(
            fileName,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final imageUrl = _supabase.storage.from('gallery').getPublicUrl(fileName);

      await _supabase.from('gallery').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'title': 'My Gallery Photo',
        'category': 'General',
        'is_public': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  'Added to gallery! ✨',
                  style: GoogleFonts.outfit(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadInitialData();
      }
    } catch (e) {
      debugPrint('Error uploading to gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  // 🛡️ Minimal Defense Section (User directive: "ഡയറക്റ്റ് ഡിഫെൻസ്... ആഡ് ചെയ്തതുണ്ടെങ്കിൽ ലിസ്റ്റ് ആയിട്ട് കാണിക്കുക. 'Defense' എന്ന് പറഞ്ഞിട്ട് അതിൽ ടാപ്പ് ചെയ്താൽ ഡിഫെൻസ് ആഡ് ചെയ്തതുണ്ടാകും. മാക്സിമം മിനിമൽ ആക്കുക")
  Widget _buildMinimalDefenseSection(Color textColor, Color btnColor) {
    if (_isLoadingDefense && _fortressStatus == null) {
      return const SizedBox.shrink();
    }

    final hasQuestions = _shieldQuestions.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: hasQuestions,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_rounded,
                color: Color(0xFF38BDF8), size: 18),
          ),
          title: Row(
            children: [
              Text(
                'Defense',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: hasQuestions
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasQuestions ? '${_shieldQuestions.length} Armed' : '0 Armed',
                  style: TextStyle(
                    color:
                        hasQuestions ? const Color(0xFF34D399) : Colors.white54,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            hasQuestions
                ? (isMe
                    ? 'Active defense questions guarding your house'
                    : 'Active defense questions guarding this citadel')
                : (isMe
                    ? 'Defenses unlock as you advance in levels'
                    : 'No active defenses set yet'),
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
          children: [
            if (hasQuestions)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                itemCount: _shieldQuestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10, height: 12),
                itemBuilder: (context, index) {
                  final q = _shieldQuestions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D2D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final info =
                                PocketCitadelChallengeGenerator.getGameInfo(
                                    q.gameFormat);
                            final diffColor = q.difficulty == 'easy'
                                ? const Color(0xFF10B981)
                                : (q.difficulty == 'hard'
                                    ? const Color(0xFFF43F5E)
                                    : const Color(0xFFF59E0B));
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF0284C7),
                                            Color(0xFF0369A1)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Day ${index + 1}: ${info.icon} ${info.title}',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: diffColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: diffColor, width: 0.8),
                                      ),
                                      child: Text(
                                        q.difficulty.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          color: diffColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isMe)
                                  IconButton(
                                    icon: const Icon(Icons.edit_note_rounded,
                                        color: Color(0xFF38BDF8), size: 18),
                                    tooltip: 'Configure Defense',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      final day = _getEffectiveDay();
                                      await PocketDefenseTrapModal.show(
                                        context,
                                        day,
                                        editingQuestion: q,
                                        targetDay: index + 1,
                                      );
                                      _loadFortressDefenseData();
                                    },
                                  )
                                else
                                  const Text(
                                    '🛡️ Armed',
                                    style: TextStyle(
                                        color: Color(0xFF34D399),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isMe
                              ? q.question
                              : 'Guarded Defense Question #${index + 1} 🔒',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                isMe ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                        if (isMe &&
                            q.options.isNotEmpty &&
                            q.correctIndex < q.options.length) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Answer: ${q.options[q.correctIndex]}',
                            style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600),
                          ),
                        ] else if (!isMe) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.lock_rounded,
                                  color: Color(0xFFFFFC00), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Encrypted Defense • Revealed only during Citadel Raid',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFFFC00)
                                      .withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            if (hasQuestions)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      PocketCitadelAttackPage.openForUser(
                        context,
                        userId: userId,
                        isDefenseMode: true,
                        attackerDay: _getEffectiveDay(),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.gps_fixed_rounded,
                                size: 18, color: Color(0xFF0F172A)),
                            const SizedBox(width: 6),
                            Text(
                              PocketLanguageService.localize(
                                en: '🎯 TRIAL ATTACK',
                                ml: '🎯 ട്രയൽ അറ്റാക്ക് (TRIAL ATTACK)',
                                ta: '🎯 சோதனைத் தாக்குதல் (TRIAL ATTACK)',
                                hi: '🎯 ट्रायल अटैक (TRIAL ATTACK)',
                              ),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PocketLanguageService.localize(
                            en: 'Attack your own house to test defenses (no points lost)',
                            ml: 'സ്വന്തം വീട് അറ്റാക്ക് ചെയ്ത് ഡിഫൻസ് പരിശോധിക്കാം (പോയിന്റുകൾ നഷ്ടപ്പെടില്ല)',
                            ta: 'சொந்த வீட்டைத் தாக்கி பாதுகாப்பை சோதிக்கவும் (புள்ளிகள் இழக்கப்படாது)',
                            hi: 'सुरक्षा जाँचने के लिए अपने घर पर हमला करें (कोई अंक नहीं कटेगा)',
                          ),
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  'No defense questions set yet. Earn and arm defense questions by advancing in daily learning levels!',
                  style:
                      GoogleFonts.inter(color: Colors.white38, fontSize: 11.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 📜 President Notice Warning Banner
  Widget _buildPresidentNoticeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF78350F), Color(0xFF451A03)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'OFFICIAL PRESIDENTIAL NOTICE',
                  style: GoogleFonts.outfit(
                    color: Colors.amber.shade300,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 18),
                onPressed: () async {
                  await PocketFortressDefenseService.dismissPresidentNotice(
                      'me');
                  _loadFortressDefenseData();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _fortressStatus?.presidentNotice ??
                'A warning has been issued regarding your defense questions.',
            style:
                const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: Colors.black),
              label: Text(
                'I UNDERSTAND & WILL UPDATE DEFENSES',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
              onPressed: () async {
                await PocketFortressDefenseService.dismissPresidentNotice('me');
                _loadFortressDefenseData();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ⛓️ Jail Sentence Banner
  Widget _buildJailSentenceBanner() {
    final days = _fortressStatus?.jailDaysRemaining ?? 3;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.5)),
            ),
            child: const Text('⛓️', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOUSE IMPRISONED IN JAIL',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD8B4FE),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$days Days Remaining • Locked from raiding other citadels due to reported fake defense traps.',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🚨 POLICE CRIME REPORT: FIND THE THIEF (കള്ളനെ കണ്ടെത്തി!) & REVENGE ATTACK
  // (User Audio Directive: "ആരെങ്കിലും അറ്റാക്ക് ചെയ്തിട്ടുണ്ടെങ്കിൽ ആരാ അറ്റാക്ക് ചെയ്തത് എന്നുള്ളത് നമ്മുടെ മെയിൻ പ്രൊഫൈൽ വിജറ്റിൽ അടിയിൽ ഇങ്ങനെ കാണിക്കണം. അദ്ദേഹത്തിന് മാത്രം കണ്ടാൽ മതി (isMe). ഈ കേസ് പോലീസ് കണ്ടെത്തി എന്ന് പറയുമല്ലോ, 'Find the Thief' / 'കള്ളൻ ആരാണെന്ന് കണ്ടെത്തി'... ആ കള്ളൻ ആരാണെന്നുള്ളത് പോലീസ് കണ്ടുപിടിച്ച ഡീറ്റെയിൽസ് ലിസ്റ്റ് വ്യൂ ആയിട്ട് മെയിൻ പ്രൊഫൈൽ വിജറ്റിൽ കൊടുക്കുക. അവർക്ക് റിവഞ്ച് അറ്റാക്ക് ചെയ്യാൻ പറ്റും, ആ സ്പോട്ടിൽ തന്നെ!")
  Widget _buildMinimalAttackersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚨 Police Crime Header Banner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDC2626).withValues(alpha: 0.22),
                  const Color(0xFF1E3A8A).withValues(alpha: 0.20),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Text('🚨', style: TextStyle(fontSize: 20)),
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
                              'POLICE CRIME DESK: FIND THE THIEF',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.redAccent, width: 0.8),
                            ),
                            child: Text(
                              PocketLanguageService.localize(
                                en: 'Thief Identified!',
                                ml: 'കള്ളനെ കണ്ടെത്തി!',
                                ta: 'திருடன் கண்டுபிடிக்கப்பட்டான்!',
                                hi: 'चोर की पहचान हो गई!',
                              ),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFCA5A5),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        PocketLanguageService.localize(
                          en: 'Police Crime Report • Identified Attackers & Stolen Score',
                          ml: 'പോലീസ് അന്വേഷണ റിപ്പോർട്ട് • Identified Attackers & Stolen Score',
                          ta: 'காவல் அறிக்கை • அடையாளம் காணப்பட்ட தாக்குபவர்கள்',
                          hi: 'पुलिस जांच रिपोर्ट • पहचाने गए हमलावर',
                        ),
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: _recentRaids.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(18),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          'No intrusions recorded! Your citadel defense holds firm.',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          PocketLanguageService.localize(
                            en: 'No intrusions recorded yet • Attacker details will appear here',
                            ml: 'ഇതുവരെ ആരും വീട് ആക്രമിച്ചിട്ടില്ല • കള്ളന്മാരുടെ വിവരങ്ങൾ ഇവിടെ കാണാം',
                            ta: 'இதுவரை யாரும் வீட்டைத் தாக்கவில்லை • தாக்குபவர்களின் விவரங்கள் இங்கே தோன்றும்',
                            hi: 'अभी तक किसी ने हमला नहीं किया • हमलावरों का विवरण यहाँ दिखेगा',
                          ),
                          style: GoogleFonts.inter(
                              color: Colors.white54, fontSize: 10.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: _recentRaids.map((entry) {
                      final timeDiff =
                          DateTime.now().difference(entry.timestamp);
                      final timeText = timeDiff.inHours < 1
                          ? '${timeDiff.inMinutes.clamp(1, 60)}m ago'
                          : (timeDiff.inHours < 24
                              ? '${timeDiff.inHours}h ago'
                              : '${timeDiff.inDays}d ago');

                      final isInvalidOrSelf = entry.attackerId.isEmpty ||
                          entry.attackerId == userId ||
                          entry.attackerId == 'me' ||
                          entry.attackerName.trim().toLowerCase() == 'you' ||
                          entry.attackerName.trim().isEmpty;
                      final displayAttackerName = isInvalidOrSelf
                          ? 'Shadow Citadel Raider 🦹'
                          : entry.attackerName;
                      final displayAttackerAvatar = isInvalidOrSelf
                          ? '🦹'
                          : (entry.attackerAvatar.isNotEmpty
                              ? entry.attackerAvatar
                              : '⚔️');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: entry.breached
                                ? Colors.redAccent.withValues(alpha: 0.45)
                                : (entry.ironDomeBlocked
                                    ? const Color(0xFF00F0FF)
                                        .withValues(alpha: 0.35)
                                    : const Color(0xFF10B981)
                                        .withValues(alpha: 0.35)),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Attacker Avatar with Detective Badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: entry.breached
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF38BDF8),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayAttackerAvatar,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              displayAttackerName,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3B82F6)
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFF60A5FA),
                                                  width: 0.8),
                                            ),
                                            child: Text(
                                              PocketLanguageService.localize(
                                                en: '🕵️‍♂️ Suspect',
                                                ml: '🕵️‍♂️ കള്ളൻ',
                                                ta: '🕵️‍♂️ சந்தேக நபர்',
                                                hi: '🕵️‍♂️ संदिग्ध',
                                              ),
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFF93C5FD),
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.flash_on_rounded,
                                              size: 12, color: Colors.amber),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              'Weapon: ${entry.attackerWeapon}',
                                              style: GoogleFonts.inter(
                                                color: Colors.amber.shade300,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '• $timeText',
                                            style: GoogleFonts.inter(
                                              color: Colors.white54,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Loot & Revenge Action Bar
                            Row(
                              children: [
                                // Stolen / Defended Score pill
                                if (entry.breached)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.redAccent
                                              .withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('📉',
                                            style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Stole -${entry.coinsLooted} Pocket Score',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFF87171),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (entry.ironDomeBlocked)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00F0FF)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF00F0FF)
                                              .withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🛡️',
                                            style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Iron Dome Blocked (0 Lost)',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF00F0FF),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🛡️',
                                            style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Defense Held (0 Lost)',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF34D399),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Spacer(),
                                // ⚡ REVENGE ATTACK (പകരം വീട്ടുക) Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () async {
                                      HapticFeedback.heavyImpact();
                                      String targetId = entry.attackerId;
                                      String targetName = displayAttackerName;
                                      if (targetId.isEmpty ||
                                          targetId == userId ||
                                          targetId == 'me' ||
                                          entry.attackerName.trim().toLowerCase() == 'you') {
                                        final rival =
                                            await PocketFortressDefenseService
                                                .getRecommendedRivalTarget(
                                                    userDay: _getEffectiveDay());
                                        targetId = rival.id;
                                        targetName = rival.name;
                                      }
                                      final isProtected =
                                          await PocketFortressDefenseService
                                              .isUnderPresidentialProtection(
                                                  targetId);
                                      if (isProtected) {
                                        final remainingMinutes =
                                            await PocketFortressDefenseService
                                                .getPresidentialProtectionMinutesRemaining(
                                                    targetId);
                                        final hours = (remainingMinutes / 60.0)
                                            .toStringAsFixed(1);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Text('👮‍♂️',
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Attacker is under 24h Presidential Protection ($hours hrs left). Revenge temporarily blocked!',
                                                      style: GoogleFonts.outfit(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  const Color(0xFF1E3A8A),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                      final inCooldown =
                                          await PocketFortressDefenseService
                                              .isTargetInCooldown(targetId);
                                      if (inCooldown) {
                                        final cdMins =
                                            await PocketFortressDefenseService
                                                .getCooldownMinutesRemaining(
                                                    targetId);
                                        final timeStr = cdMins < 60
                                            ? '$cdMins mins'
                                            : '${(cdMins / 60.0).toStringAsFixed(1)} hrs';
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Revenge cooldown active on this house ($timeStr remaining).'),
                                              backgroundColor:
                                                  Colors.amber.shade900,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      if (mounted) {
                                        PocketCitadelAttackPage.openForUser(
                                          context,
                                          userId: targetId,
                                          targetName: targetName,
                                          attackerDay: _getEffectiveDay(),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFDC2626),
                                            Color(0xFFB91C1C)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFCA5A5),
                                            width: 1.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDC2626)
                                                .withValues(alpha: 0.45),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('⚔️',
                                              style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 5),
                                          Text(
                                            'REVENGE ATTACK',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ⚔️ CITADEL FIGHT ARENA: SPEED DUELS (User Audio Directive: "അവന്റെ മെയിൻ പ്രൊഫൈൽ വിഡ്ജറ്റിൽ ഫൈറ്റ് ചെയ്തത് കാണിക്കണം... തീഫ് ഡെസ്കിൽ കാണിക്കുമല്ലോ, അതേപോലെ അവിടെ കാണിക്കണം. ആരൊക്കെ ഫൈറ്റ് ചെയ്തു എന്ന് പറഞ്ഞിട്ട്.")
  Widget _buildCitadelFightArenaDesk() {
    final currentUserId = widget.userId ?? SupaFlow.client.auth.currentUser?.id ?? '';
    return FutureBuilder<List<CitadelFightChallenge>>(
      future: PocketCitadelFightService.getAllChallenges(currentUserId),
      builder: (context, snapshot) {
        final challenges = snapshot.data ?? [];
        final pendingForMe = challenges
            .where((c) =>
                c.opponentId == currentUserId &&
                (c.status == 'pending' || c.status == 'pending_opponent'))
            .toList();
        final recentFinished = challenges
            .where((c) => c.status == 'completed')
            .take(5)
            .toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.5),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                blurRadius: 14,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.35),
                      const Color(0xFFDC2626).withValues(alpha: 0.25),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C1D95).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text('⚔️', style: TextStyle(fontSize: 20)),
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
                                  'CITADEL FIGHT ARENA: SPEED DUELS',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700), width: 0.8),
                                ),
                                child: Text(
                                  PocketLanguageService.localize(
                                    en: 'Fight Desk',
                                    ml: 'ഫൈറ്റ് ഡെസ്ക്',
                                    ta: 'சண்டை மேசை',
                                    hi: 'फाइट डेस्क',
                                  ),
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '1-on-1 English Duels • Fastest Speed & Accuracy Wins Gold Trophy 🏆',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pending Challenges section
                    if (pendingForMe.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'INCOMING DUEL CHALLENGES (${pendingForMe.length})',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFCA5A5),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...pendingForMe.map((duel) {
                        final timeStr = duel.challengerTimeSeconds > 0
                            ? duel.challengerTimeSeconds.toStringAsFixed(1)
                            : '${duel.challengerSeconds}';
                        final correctStr = duel.challengerCorrect > 0
                            ? '${duel.challengerCorrect}/${duel.questionCount} hits'
                            : '${duel.challengerScore} pts';

                        final chalName = duel.challengerName.trim();
                        final safeChalName = (chalName.isNotEmpty && chalName.toLowerCase() != 'you')
                            ? chalName
                            : 'Arena Challenger ⚔️';
                        final safeChalAvatar = duel.challengerAvatar.isNotEmpty ? duel.challengerAvatar : '⚔️';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF0F172A),
                                      border: Border.all(
                                        color: const Color(0xFFEF4444),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(safeChalAvatar,
                                        style: const TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          safeChalName,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Finished ${duel.questionCount}Q duel in ${timeStr}s • $correctStr',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    elevation: 4,
                                  ),
                                  icon: const Text('⚔️', style: TextStyle(fontSize: 16)),
                                  label: Text(
                                    'FIGHT BACK NOW ⚔️',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.heavyImpact();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PocketCitadelFightArenaDialog(
                                          challenge: duel,
                                          opponentDay: 1,
                                          isOpponentRun: true,
                                        ),
                                      ),
                                    ).then((_) => setState(() {}));
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    // Recent Settled Duels
                    if (recentFinished.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'RECENT SPEED DUEL RESULTS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...recentFinished.map((duel) {
                        final isChallenger = duel.challengerId == currentUserId;
                        final myScore = isChallenger ? duel.challengerScore : duel.opponentScore;
                        final oppScore = isChallenger ? duel.opponentScore : duel.challengerScore;
                        final myTime = isChallenger ? duel.challengerTimeSeconds : duel.opponentTimeSeconds;
                        final oppTime = isChallenger ? duel.opponentTimeSeconds : duel.challengerTimeSeconds;
                        final rawOppName = (isChallenger ? duel.opponentName : duel.challengerName).trim();
                        final oppName = (rawOppName.isNotEmpty && rawOppName.toLowerCase() != 'you')
                            ? rawOppName
                            : 'Arena Rival ⚔️';
                        final rawOppAvatar = (isChallenger ? duel.opponentAvatar : duel.challengerAvatar).trim();
                        final oppAvatar = rawOppAvatar.isNotEmpty ? rawOppAvatar : '⚔️';
                        final won = duel.winnerId == currentUserId;
                        final isDraw = duel.winnerId == 'draw';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: won
                                  ? const Color(0xFFFFD700)
                                  : (isDraw ? Colors.white30 : Colors.redAccent.withValues(alpha: 0.4)),
                              width: won ? 1.4 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(won ? '🏆' : (isDraw ? '🤝' : '💥'), style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      won
                                          ? 'YOU WON (+1 Gold Trophy 🏆)'
                                          : (isDraw ? 'DRAW MATCH' : '$oppName Won'),
                                      style: GoogleFonts.outfit(
                                        color: won ? const Color(0xFFFFD700) : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    Text(
                                      'You: ${myTime.toStringAsFixed(1)}s ($myScore pts) • $oppAvatar $oppName: ${oppTime.toStringAsFixed(1)}s ($oppScore pts)',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!won && !isDraw)
                                GestureDetector(
                                  onTap: () {
                                    PocketCitadelFightModal.startDirectDuel(
                                      context,
                                      opponentId: isChallenger ? duel.opponentId : duel.challengerId,
                                      opponentName: oppName,
                                      opponentAvatar: oppAvatar,
                                      opponentDay: 1,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.redAccent, width: 0.8),
                                    ),
                                    child: const Text('REMATCH ⚔️',
                                        style: TextStyle(
                                            color: Color(0xFFFCA5A5),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ] else if (pendingForMe.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text('⚔️', style: TextStyle(fontSize: 26)),
                            const SizedBox(height: 6),
                            Text(
                              'No Active Speed Duels',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Challenge friends or robots to 20-Question speed duels! Fastest accuracy wins Gold Trophies.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    int day = _getEffectiveDay();
    final stage = LearningMilestoneStage.getStageForDay(day);
    final avatar = _getAvatarConfig();
    final bannerUrl =
        _profileData?['banner_image_url'] ?? _profileData?['banner_url'];

    // If viewing Public Profile and custom banner exists, display it:
    if (_isPublicProfileView &&
        bannerUrl != null &&
        bannerUrl.toString().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: bannerUrl.toString(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) =>
            Container(color: const Color(0xFF161E33)),
        errorWidget: (context, url, error) =>
            _buildStageFallbackBanner(day, stage, avatar),
      );
    }

    // In Account view (both for My Account and for searched user's Account), dynamically render the stage Flame animal avatar banner!
    return _buildStageFallbackBanner(day, stage, avatar);
  }

  Widget _buildStageFallbackBanner(
      int day, LearningMilestoneStage stage, VectorAvatarConfig avatar) {
    return FlameProfileBannerWidget(
      day: day,
      stage: stage,
      avatar: avatar,
      userId: userId,
      isMe: isMe,
      equippedTalismanId: _equippedTalismanId,
      onTalismanChanged: (talismanId) {
        if (mounted) setState(() => _equippedTalismanId = talismanId);
      },
      background: CustomPaint(
        painter: StageBannerArtPainter(
          stage: day,
          baseColor: stage.buttonColor,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      Color textColor, Color btnColor, Color btnTextColor, bool isMe) {
    if (_isLoading && _profileData == null) {
      return _buildShimmerHeader();
    }

    int day = _getEffectiveDay();
    final activeStage = LearningMilestoneStage.getStageForDay(day);

    final name = _profileData?['name'] ?? 'User';
    final shopName = _profileData?['shop_name'];
    final bio = _profileData?['bio'] ?? '';
    final profileUrl = _profileData?['profile_image_url'];
    final String currentEmail = SupaFlow.client.auth.currentUser?.email ?? '';
    final String targetName = (_profileData?['name'] ?? _profileData?['username'] ?? '').toString().toLowerCase();
    final isVerified = _profileData?['verified'] == true ||
        _profileData?['is_vip'] == true ||
        _profileData?['is_subscribed'] == true ||
        (isMe && (currentEmail.contains('musab') || currentEmail.contains('thonippadam') || currentEmail.contains('mussabira'))) ||
        targetName.contains('musab') ||
        targetName.contains('thonippadam') ||
        targetName.contains('mussabira');
    final slug = _profileData?['slug'];

    final rank = _getUserGlobalRank();
    final isTop10 = rank > 0 && rank <= 10;
    final isDark = !isTop10;
    final rankTheme = isTop10 ? PocketTopRankTheme.getThemeForRank(rank) : null;
    final secondaryTextColor = rankTheme?.secondaryTextColor ?? const Color(0xFFA8A8A8);
    final dividerColor = rankTheme?.borderColor.withValues(alpha: 0.25) ?? const Color(0xFF262626);

    // Layout 1: Unified Classic Instagram Layout (Left Avatar, Right Stats) across all 90 levels (Audio directive)
    final headerContent = _buildLayoutGenesis(
      name: name,
      shopName: shopName,
      bio: bio,
      profileUrl: profileUrl,
      isVerified: isVerified,
      slug: slug,
      activeStage: activeStage,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      dividerColor: dividerColor,
      btnColor: btnColor,
      btnTextColor: btnTextColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerContent,
        _buildActionButtons(
            textColor, btnColor, btnTextColor, isMe, isDark, name, profileUrl),
      ],
    );
  }

  /// 🏅 Global Rank / Robot Rank Badge placed directly underneath Stage & Name (Audio Directive)
  Widget _buildProfileGlobalRankBadge(LearningMilestoneStage activeStage) {
    final targetId =
        widget.userId ?? SupaFlow.client.auth.currentUser?.id ?? '';
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(targetId);
    final isRobot = PocketRobotService.isRobotId(targetId) || !isUuid;
    final isPresident = _profileData?['is_president'] == true ||
        _profileData?['role'] == 'president';
    final isStudent = _isStudentProfile;

    final int rank;
    final String label;
    final Color badgeColor;
    final Color borderColor;
    final Color textColor;

    if (isStudent) {
      // 🎓 Strictly Student Rank (Ages up to 17) - isolated from adult leaderboard
      rank = PocketKidsService.getStudentGlobalRank(
          _studentScore, activeStage.day, targetId);
      label = rank > 0 ? 'Student Rank #$rank' : 'Student Rank #--';
      badgeColor = const Color(0xFF10B981).withValues(alpha: 0.15);
      borderColor = const Color(0xFF34D399).withValues(alpha: 0.5);
      textColor = const Color(0xFF6EE7B7);
    } else if (isRobot) {
      rank = activeStage.day.clamp(1, 90);
      label = 'Robot Rank #$rank';
      badgeColor = const Color(0xFF10B981).withValues(alpha: 0.15);
      borderColor = const Color(0xFF34D399).withValues(alpha: 0.5);
      textColor = const Color(0xFF6EE7B7);
    } else {
      final activeRank = _getUserGlobalRank();
      if (activeRank > 0) {
        rank = activeRank;
        label = 'Rank #$rank';
      } else {
        rank = 0;
        label = 'Rank #--';
      }
      final isTop3 = (rank > 0 && rank <= 3) || isPresident;
      final isTop10 = (rank > 0 && rank <= 10) || isPresident;
      if (isTop3) {
        badgeColor = const Color(0xFFFFD700).withValues(alpha: 0.18);
        borderColor = const Color(0xFFFFD700).withValues(alpha: 0.65);
        textColor = const Color(0xFFFFD700);
      } else if (isTop10) {
        badgeColor = const Color(0xFF38BDF8).withValues(alpha: 0.15);
        borderColor = const Color(0xFF38BDF8).withValues(alpha: 0.50);
        textColor = const Color(0xFF7DD3FC);
      } else {
        badgeColor = const Color(0xFF262626);
        borderColor = const Color(0xFF383838);
        textColor = const Color(0xFFA8A8A8);
      }
    }

    final fScore = (!isMe && isStudent)
        ? PocketKidsService.getFriendshipScore(targetId)
        : null;
    final fBadge =
        fScore != null ? PocketKidsService.getFriendshipBadge(fScore) : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 0.9),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2235),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, width: 0.9),
          ),
          child: Text(
            'Stage ${activeStage.stageNumber}',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (fScore != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              PocketFriendshipScoreDialog.show(
                context,
                mateId: targetId,
                mateName: _profileData?['username'] ??
                    _profileData?['display_name'] ??
                    'Mate',
                mateAvatar: _profileData?['kid_avatar'] ??
                    _profileData?['avatar_emoji'] ??
                    '🦁',
                dayLevel: activeStage.day,
              );
            },
            child: Tooltip(
              message: fBadge ?? 'Friendship Score',
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFFF472B6).withValues(alpha: 0.65),
                      width: 0.9),
                ),
                child: Text(
                  '💖 $fScore% Friendship',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF9A8D4),
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOtherUserCitadelSection(
      int day, Color textColor, Color btnColor) {
    final gateCount = PocketScoreLevelEngine.getGatesCountForLevel(day);
    final streak = (_profileData?['daily_streak'] as num?)?.toInt() ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF311042),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🛡️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LEVEL $day CITADEL DEFENSE',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '$gateCount Armed Gate${gateCount > 1 ? "s" : ""} Active',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '$gateCount / 9 GATES',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Gate Tier Progress Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(gateCount, (idx) {
                    final gateNum = idx + 1;
                    final gateInfo =
                        PocketScoreLevelEngine.getGateInfo(gateNum);
                    final gateName = gateInfo['title'] ?? 'Gate $gateNum';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        'Gate $gateNum: $gateName',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                // Attack Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final targetId = widget.userId ?? '';
                      final isProtected = await PocketFortressDefenseService
                          .isUnderPresidentialProtection(targetId);
                      if (isProtected) {
                        final remainingMinutes =
                            await PocketFortressDefenseService
                                .getPresidentialProtectionMinutesRemaining(
                                    targetId);
                        final hours =
                            (remainingMinutes / 60.0).toStringAsFixed(1);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Text('👮‍♂️',
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Target Citadel is under 48h Presidential Police Protection ($hours hrs left). Raids blocked!',
                                      style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1E3A8A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }

                      final targetName = _profileData?['display_name'] ??
                          _profileData?['full_name'] ??
                          'Target Raider';
                      final targetNeighbor = PocketNeighbor(
                        id: targetId,
                        name: targetName,
                        day: day,
                        streak: streak,
                        rank: 'Citadel (Lvl $day)',
                        paletteId: 'royal_gold',
                        isMe: false,
                        hasActiveShield: true,
                        statusMessage:
                            '⚔️ Defend the Citadel with English prowess!',
                        hp: 100,
                        maxHp: 100,
                      );

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PocketCitadelAttackPage(
                              neighbor: targetNeighbor,
                              attackerDay: _getEffectiveDay(),
                            ),
                          ),
                        ).then((_) => _loadFortressDefenseData());
                      }
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 20),
                    label: Text(
                      'Attack',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualProfileSegmentSwitcher(
      Color textColor, Color btnColor, Color btnTextColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: btnColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _setProfileViewMode(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        !_isPublicProfileView ? btnColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: !_isPublicProfileView
                        ? [
                            BoxShadow(
                              color: btnColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('👤', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        isMe ? 'My Account' : 'Account',
                        style: GoogleFonts.outfit(
                          color: !_isPublicProfileView
                              ? btnTextColor
                              : textColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _setProfileViewMode(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _isPublicProfileView ? btnColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _isPublicProfileView
                        ? [
                            BoxShadow(
                              color: btnColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌐', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        'Public Profile',
                        style: GoogleFonts.outfit(
                          color: _isPublicProfileView
                              ? btnTextColor
                              : textColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
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
    );
  }

  // --- 4 PROGRESSIVE STANDARD PROFILE LAYOUTS ---

  /// Layout 1 (Days 1–15): Classic Clean Left Avatar, Right Stats
  Widget _buildLayoutGenesis({
    required String name,
    required String? shopName,
    required String bio,
    required String? profileUrl,
    required bool isVerified,
    required dynamic slug,
    required LearningMilestoneStage activeStage,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dividerColor,
    required Color btnColor,
    required Color btnTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              _buildAvatarWidget(
                profileUrl: profileUrl,
                dividerColor: dividerColor,
                textColor: textColor,
                activeStage: activeStage,
                size: 84,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildUnifiedStatsRow(
                  textColor: textColor,
                  activeStage: activeStage,
                ),
              ),
            ],
          ),
        ),
        _buildIdentityBioSection(
          name: name,
          shopName: shopName,
          bio: bio,
          isVerified: isVerified,
          slug: slug,
          activeStage: activeStage,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          btnColor: btnColor,
          btnTextColor: btnTextColor,
          alignment: CrossAxisAlignment.start,
        ),
      ],
    );
  }

  /// Layout 2 (Days 16–30): Modern Split Deck (Left Stats, Right Avatar)
  Widget _buildLayoutSplitRight({
    required String name,
    required String? shopName,
    required String bio,
    required String? profileUrl,
    required bool isVerified,
    required dynamic slug,
    required LearningMilestoneStage activeStage,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dividerColor,
    required Color btnColor,
    required Color btnTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _buildUnifiedStatsRow(
                  textColor: textColor,
                  activeStage: activeStage,
                ),
              ),
              const SizedBox(width: 14),
              _buildAvatarWidget(
                profileUrl: profileUrl,
                dividerColor: dividerColor,
                textColor: textColor,
                activeStage: activeStage,
                size: 84,
              ),
            ],
          ),
        ),
        _buildIdentityBioSection(
          name: name,
          shopName: shopName,
          bio: bio,
          isVerified: isVerified,
          slug: slug,
          activeStage: activeStage,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          btnColor: btnColor,
          btnTextColor: btnTextColor,
          alignment: CrossAxisAlignment.start,
        ),
      ],
    );
  }

  /// Layout 3 (Days 31–60): VIP Center Spotlight Hero (Centered Avatar, Centered Name, Floating Stats Pill Bar)
  Widget _buildLayoutCenterSpotlight({
    required String name,
    required String? shopName,
    required String bio,
    required String? profileUrl,
    required bool isVerified,
    required dynamic slug,
    required LearningMilestoneStage activeStage,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dividerColor,
    required Color btnColor,
    required Color btnTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Center(
          child: _buildAvatarWidget(
            profileUrl: profileUrl,
            dividerColor: dividerColor,
            textColor: textColor,
            activeStage: activeStage,
            size: 92,
          ),
        ),
        const SizedBox(height: 12),
        _buildIdentityBioSection(
          name: name,
          shopName: shopName,
          bio: bio,
          isVerified: isVerified,
          slug: slug,
          activeStage: activeStage,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          btnColor: btnColor,
          btnTextColor: btnTextColor,
          alignment: CrossAxisAlignment.center,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: activeStage.bgColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: activeStage.buttonColor.withValues(alpha: 0.4),
                  width: 1.2),
            ),
            child: _buildUnifiedStatsRow(
              textColor: textColor,
              activeStage: activeStage,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Layout 4 (Days 61–90): Grandmaster Celestial Showcase Deck (Ultra Clean, Prestigious & High Contrast)
  Widget _buildLayoutCelestialShowcase({
    required String name,
    required String? shopName,
    required String bio,
    required String? profileUrl,
    required bool isVerified,
    required dynamic slug,
    required LearningMilestoneStage activeStage,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dividerColor,
    required Color btnColor,
    required Color btnTextColor,
  }) {
    final isDay90 = activeStage.day == 90;
    final accentColor = activeStage.buttonColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: activeStage.bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDay90 ? 0.85 : 0.6),
          width: isDay90 ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDay90 ? 0.25 : 0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grandmaster Header Tag (Minimal, uncluttered layout)
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.6), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isDay90 ? '👑' : '💎',
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      'STAGE ${activeStage.stageNumber}/90',
                      style: GoogleFonts.outfit(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              () {
                final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
                final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
                if (!isRobot) return const SizedBox.shrink();
                final robot = PocketRobotService.getRobotById(userId) ??
                    PocketRobotService.getRobotByLevel(activeStage.day);
                final trophies = PocketRobotService.getTrophiesForRobot(robot) +
                    (isDay90 ? 1 : 0);
                if (trophies <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFFFFD700), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 4),
                        Text(
                          'x$trophies TROPHIES',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }(),
              if (isDay90 && !PocketRobotService.isRobotId(userId)) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Day90MasterCertificateDialog.show(
                      context,
                      userName: _profileData?['username'] ?? 'Learner',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFFFFD700), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 4),
                        Text(
                          'GRADUATE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Avatar & Stats Row (Clean Instagram-style Layout)
          Row(
            children: [
              _buildAvatarWidget(
                profileUrl: profileUrl,
                dividerColor: dividerColor,
                textColor: textColor,
                activeStage: activeStage,
                size: 80,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildUnifiedStatsRow(
                  textColor: textColor,
                  activeStage: activeStage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name & Bio Section
          _buildIdentityBioSection(
            name: name,
            shopName: shopName,
            bio: bio,
            isVerified: isVerified,
            slug: slug,
            activeStage: activeStage,
            textColor: Colors.white,
            secondaryTextColor: Colors.white70,
            btnColor: accentColor,
            btnTextColor: Colors.black,
            alignment: CrossAxisAlignment.start,
            hideStageBadge:
                true, // Stage badge is already prominent in the Grandmaster Header Tag
          ),
        ],
      ),
    );
  }

  /// Helper to build interactive avatar matching chat tile presentation (clean, borderless, organic glowing aura)
  Widget _buildAvatarWidget({
    required String? profileUrl,
    required Color dividerColor,
    required Color textColor,
    required LearningMilestoneStage activeStage,
    required double size,
  }) {
    final rank = _getUserGlobalRank();
    final isTop10 = rank > 0 && rank <= 10;

    Widget avatarCircle = SizedBox(
      width: size,
      height: size,
      child: _showAvatarMode
          ? VectorAvatarWidget(
              config: _getAvatarConfig(),
              size: size,
              showAura: true,
            )
          : (profileUrl != null && profileUrl.isNotEmpty)
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profileUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: dividerColor),
                    errorWidget: (_, __, ___) => Container(
                      color: dividerColor,
                      child: Icon(Icons.person,
                          size: size * 0.45,
                          color: textColor.withValues(alpha: 0.5)),
                    ),
                  ),
                )
              : ClipOval(
                  child: Container(
                    color: dividerColor,
                    child: Icon(Icons.person,
                        size: size * 0.45,
                        color: textColor.withValues(alpha: 0.5)),
                  ),
                ),
    );

    Widget displayAvatar = avatarCircle;
    if (isTop10) {
      final rankTheme = PocketTopRankTheme.getThemeForRank(rank);
      final Color baseRing = rankTheme?.ringColor ?? const Color(0xFFFFD700);
      final Color glowColor = rankTheme?.ringGlowColor ?? baseRing;
      final ringGradient = SweepGradient(
        colors: [
          baseRing,
          glowColor,
          Colors.white,
          baseRing.withValues(alpha: 0.8),
          baseRing,
        ],
      );

      displayAvatar = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ringGradient,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(2.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF000000),
          ),
          child: avatarCircle,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!_showAvatarMode && profileUrl != null && profileUrl.isNotEmpty) {
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: profileUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => Container(
                        padding: const EdgeInsets.all(20),
                        color: const Color(0xFF1E2235),
                        child: const Icon(Icons.broken_image,
                            color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Tap navigates directly to the Companions Milestone Cards Tab (Tab index 3)
          HapticFeedback.selectionClick();
          _profileTabController.animateTo(3);
        }
      },
      onDoubleTap: () {
        HapticFeedback.mediumImpact();
        if (profileUrl != null && profileUrl.isNotEmpty) {
          setState(() => _showAvatarMode = !_showAvatarMode);
          if (isMe) {
            SharedPreferences.getInstance().then((p) =>
                p.setBool('show_avatar_mode_$userId', _showAvatarMode));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_showAvatarMode
                  ? '🎨 Showing Pocket Mate Avatar'
                  : '📷 Showing Real Profile Photo'),
              duration: const Duration(milliseconds: 700),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎨 Showing Avatar • No real photo uploaded yet'),
              duration: Duration(milliseconds: 700),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onLongPress: () {
        if (profileUrl != null && profileUrl.isNotEmpty) {
          setState(() => _showAvatarMode = !_showAvatarMode);
          if (isMe) {
            SharedPreferences.getInstance().then(
                (p) => p.setBool('show_avatar_mode_$userId', _showAvatarMode));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_showAvatarMode
                  ? '🎨 Showing Pocket Mate Avatar'
                  : '📷 Showing Real Profile Photo'),
              duration: const Duration(milliseconds: 700),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: displayAvatar,
    );
  }

  /// 🐾 4th Tab: Pocket Mates Avatar Milestone Companions (Audio Directive: larger avatars, glowing aura, no top ribbon, tap opens 3D NFT Card Dialog)
  Widget _buildCompanionsMilestoneTab(Color textColor, Color btnColor, bool isMe) {
    final int userLevel = _getEffectiveDay();
    var currentCfg = _getAvatarConfig();
    final animals90 = VectorAvatarConfig.get90DayAnimals();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.69,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: animals90.length,
        itemBuilder: (context, index) {
          final companionDay = index + 1;
          final a = animals90[index];
          final isUnlocked = VectorAvatarConfig.isCompanionUnlocked(companionDay, userLevel);
          final isEquipped = currentCfg.species == a.species;

          final previewCfg = VectorAvatarConfig.getEvolutionAvatarForStage(
            companionDay,
            talismanId: _equippedTalismanId,
          ).copyWith(
            skinColor: isEquipped ? currentCfg.skinColor : null,
            hairColor: isEquipped ? currentCfg.hairColor : null,
          );

          return GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              // Open 3D Holographic NFT Card Dialog (User audio: "അതിൽ ടാപ്പ് ചെയ്യുന്ന സമയത്ത് എക്വിപ്ഡ് അവതാർ എന്ന് പറഞ്ഞിട്ട് ഒരു അലർട്ട് ബോക്സ് വരുക")
              await NftTradingCardDialog.show(
                context,
                day: companionDay,
                config: previewCfg,
                userId: userId,
                isOwner: isMe && isUnlocked,
              );

              if (isUnlocked && isMe) {
                final newCfg = userLevel >= 90
                    ? previewCfg
                    : VectorAvatarConfig.getEvolutionAvatarForStage(
                        userLevel,
                        talismanId: _equippedTalismanId,
                      ).copyWith(species: a.species);

                setState(() {
                  _profileData ??= {};
                  _profileData!['avatar_config'] = newCfg.toMap();
                  _showAvatarMode = true;
                });

                try {
                  final uid = _supabase.auth.currentUser?.id;
                  if (uid != null) {
                    await _supabase.from('profile').update({
                      'avatar_config': newCfg.toMap(),
                    }).eq('user_id', uid);
                  }
                } catch (_) {}
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isEquipped
                    ? const Color(0xFF1E2238)
                    : (isUnlocked ? const Color(0xFF141724) : const Color(0xFF0C0E17)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEquipped
                      ? const Color(0xFFFFD700)
                      : (isUnlocked ? Colors.white24 : Colors.white10),
                  width: isEquipped ? 2 : 1,
                ),
                boxShadow: isEquipped
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // 🌟 Larger Avatar with Active Animated Aura (Audio Directive: "കുറച്ചുകൂടി വലിപ്പത്തിൽ പ്ലേസ് ചെയ്യുക... ബാക്കിൽ ഒരു ആനിമേഷൻ ഉണ്ട്, അതേ ആനിമേഷൻ ഇവിടെയും കൊടുക്കുക")
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VectorAvatarWidget(
                            config: previewCfg,
                            size: 74,
                            showAura: isUnlocked,
                          ),
                          if (!isUnlocked)
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_rounded, size: 24, color: Colors.white54),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                    child: Column(
                      children: [
                        Text(
                          a.species.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
                          style: GoogleFonts.outfit(
                            color: isUnlocked ? Colors.white : Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isUnlocked
                              ? (isEquipped ? 'EQUIPPED ✨' : 'UNLOCKED 🌱')
                              : 'DAY $companionDay 🔒',
                          style: GoogleFonts.outfit(
                            color: isEquipped
                                ? const Color(0xFFFFD700)
                                : (isUnlocked ? const Color(0xFF10B981) : Colors.white38),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
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

  /// Interactive bottom sheet for switching unlocked companions and checking upcoming unlock levels
  /// Interactive bottom sheet for switching unlocked companions and checking upcoming unlock levels (Days 1–90)
  void _showAvatarQuickPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    final int userLevel = _getEffectiveDay();
    var currentCfg = _getAvatarConfig();
    final animals90 = VectorAvatarConfig.get90DayAnimals();

    int unlockedCount = 0;
    for (int i = 0; i < animals90.length; i++) {
      if (VectorAvatarConfig.isCompanionUnlocked(i + 1, userLevel)) {
        unlockedCount++;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131522),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PoketMates Progression Prestige',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Level $userLevel Mate • $unlockedCount/90 Unlocked 🌱',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFFC00),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      if (userLevel >= 90)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VectorAvatarStudioPage(
                                  initialConfig: currentCfg,
                                  onAvatarSaved: (newCfg) {
                                    setState(() {
                                      _profileData ??= {};
                                      _profileData!['avatar_config'] =
                                          newCfg.toMap();
                                      _showAvatarMode = true;
                                    });
                                  },
                                ),
                              ),
                            ).then((_) => _loadInitialData());
                          },
                          icon: const Icon(Icons.tune_rounded,
                              size: 15, color: Color(0xFFFFFC00)),
                          label: Text(
                            'Studio 👑',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.5),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded,
                                  size: 12, color: Colors.amberAccent),
                              const SizedBox(width: 4),
                              Text(
                                'Day 90 Studio',
                                style: GoogleFonts.outfit(
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 🛡️ Progression Prestige Status Ribbon (Guarantees earned rank pride)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2235),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userLevel >= 90
                                ? '👑 DAY 90 MASTER UNLOCKED: You have earned unrestricted Avatar Studio styling privileges!'
                                : 'Level $userLevel progression aura & armor are locked to your earned rank. Reach Day 90 to unlock freeform studio styling!',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: animals90.length,
                      itemBuilder: (context, index) {
                        final companionDay = index + 1;
                        final a = animals90[index];
                        final isUnlocked =
                            VectorAvatarConfig.isCompanionUnlocked(
                                companionDay, userLevel);
                        final isEquipped = currentCfg.species == a.species;

                        final previewCfg =
                            VectorAvatarConfig.getEvolutionAvatarForStage(
                          companionDay,
                          talismanId: _equippedTalismanId,
                        ).copyWith(
                          skinColor: isEquipped ? currentCfg.skinColor : null,
                          hairColor: isEquipped ? currentCfg.hairColor : null,
                        );

                        return GestureDetector(
                          onTap: () async {
                            if (!isUnlocked) {
                              HapticFeedback.heavyImpact();
                              // Open 3D Holographic NFT Card Dialog for locked companion
                              NftTradingCardDialog.show(
                                context,
                                day: companionDay,
                                config: previewCfg,
                                userId: userId,
                                isOwner: false,
                              );
                              return;
                            }

                            HapticFeedback.selectionClick();
                            final newCfg = userLevel >= 90
                                ? previewCfg
                                : VectorAvatarConfig.getEvolutionAvatarForStage(
                                    userLevel,
                                    talismanId: _equippedTalismanId,
                                  ).copyWith(species: a.species);

                            setModalState(() {
                              currentCfg = newCfg;
                            });

                            setState(() {
                              _profileData ??= {};
                              _profileData!['avatar_config'] = newCfg.toMap();
                              _showAvatarMode = true;
                            });

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Equipped ${a.rarityTier}!'),
                                backgroundColor: const Color(0xFFFFFC00),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 900),
                              ),
                            );

                            try {
                              final uid = _supabase.auth.currentUser?.id;
                              if (uid != null) {
                                await _supabase.from('profile').update({
                                  'avatar_config': newCfg.toMap()
                                }).eq('user_id', uid);
                              }
                            } catch (_) {}
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isEquipped
                                  ? const Color(0xFF1E2238)
                                  : (isUnlocked
                                      ? const Color(0xFF151824)
                                      : const Color(0xFF0F111A)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isEquipped
                                    ? const Color(0xFFFFFC00)
                                    : (isUnlocked
                                        ? Colors.white12
                                        : Colors.white.withValues(alpha: 0.04)),
                                width: isEquipped ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Opacity(
                                      opacity: isUnlocked ? 1.0 : 0.45,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: VectorAvatarWidget(
                                          config: previewCfg,
                                          size: 54,
                                          showAura: isUnlocked,
                                        ),
                                      ),
                                    ),
                                    if (!isUnlocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.82),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.amber, width: 0.8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.lock_rounded,
                                                size: 9, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              'DAY $companionDay',
                                              style: GoogleFonts.outfit(
                                                color: Colors.amber,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isEquipped)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFFC00),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check,
                                              size: 10, color: Colors.black),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a.species
                                      .replaceAll('_', ' ')
                                      .split(' ')
                                      .map((w) => w.isNotEmpty
                                          ? '${w[0].toUpperCase()}${w.substring(1)}'
                                          : '')
                                      .join(' '),
                                  style: GoogleFonts.outfit(
                                    color: isUnlocked
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  isUnlocked
                                      ? (isEquipped
                                          ? 'EQUIPPED'
                                          : (companionDay <= 5
                                              ? 'STARTER'
                                              : 'UNLOCKED'))
                                      : 'DAY $companionDay CARD 💎',
                                  style: GoogleFonts.outfit(
                                    color: isEquipped
                                        ? const Color(0xFFFFFC00)
                                        : (isUnlocked
                                            ? const Color(0xFF10B981)
                                            : Colors.amber),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Helper to build Identity and Bio block
  Widget _buildIdentityBioSection({
    required String name,
    required String? shopName,
    required String bio,
    required bool isVerified,
    required dynamic slug,
    required LearningMilestoneStage activeStage,
    required Color textColor,
    required Color secondaryTextColor,
    required Color btnColor,
    required Color btnTextColor,
    required CrossAxisAlignment alignment,
    bool hideStageBadge = false,
  }) {
    final int rank = _getUserGlobalRank();
    final bool isTop10 = rank > 0 && rank <= 10;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: alignment == CrossAxisAlignment.center
                ? WrapAlignment.center
                : WrapAlignment.start,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                shopName != null && shopName.isNotEmpty ? shopName : name,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (isVerified) _buildVerifiedGoldenTick(),
            ],
          ),
          const SizedBox(height: 5),
          _buildProfileGlobalRankBadge(activeStage),
          if (slug != null && slug.toString().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@$slug',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (activeStage.day >= 90 || activeStage.stageNumber >= 90) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                Day90MasterCertificateDialog.show(
                  context,
                  userName: shopName != null && shopName.isNotEmpty ? shopName : name,
                  userDay: activeStage.day >= 90 ? activeStage.day : 91,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: isTop10
                      ? Colors.black.withValues(alpha: 0.05)
                      : const Color(0xFF161922),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFFD4AF37), size: 13),
                    const SizedBox(width: 5),
                    Text(
                      'Day 90 Master Graduate',
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: textColor.withValues(alpha: 0.4),
                      size: 9,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bio,
              textAlign: alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor,
                height: 1.4,
              ),
            ),
          ],
          // Hand Skill 3D Web link hidden per user request
        ],
      ),
    );
  }

  Widget _buildVerifiedGoldenTick({double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFFFF176),
                Color(0xFFFFD700),
                Color(0xFFFFA000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Icon(
            Icons.verified_rounded,
            color: Colors.white,
            size: size,
          ),
        ),
        const SizedBox(width: 3),
        const Text(
          '👑',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    Color textColor,
    Color btnColor,
    Color btnTextColor,
    bool isMe,
    bool isDark,
    String name,
    String? profileUrl,
  ) {
    final userRank = _getUserGlobalRank();
    final rankTheme = (userRank > 0 && userRank <= 10) ? PocketTopRankTheme.getThemeForRank(userRank) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: isMe
          ? LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 390;

                Widget buildEditProfileBtn() => Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: rankTheme != null
                            ? rankTheme.btnColor.withValues(alpha: 0.16)
                            : const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: rankTheme != null
                              ? rankTheme.borderColor.withValues(alpha: 0.45)
                              : Colors.white12,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileCustomWidget(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ),
                            ),
                          ).then((_) => _loadInitialData());
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "Edit Profile",
                                style: GoogleFonts.outfit(
                                  color: rankTheme?.textColor ?? textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                Widget buildAvatarStudioBtn() => Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFFC00).withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VectorAvatarStudioPage(
                                initialConfig: _getAvatarConfig(),
                                onAvatarSaved: (newCfg) {
                                  setState(() {
                                    _profileData ??= {};
                                    _profileData!['avatar_config'] =
                                        newCfg.toMap();
                                    _showAvatarMode = true;
                                  });
                                },
                              ),
                            ),
                          ).then((_) => _loadInitialData());
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome,
                                      size: 15, color: Colors.black),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Master Studio 👑",
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                Widget buildVipBtn() => Container(
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFFFBEB),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionPage(),
                            ),
                          ).then((_) => _loadInitialData());
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded,
                                      size: 15, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Pocket VIP 👑",
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                final int currentLearningDay = _getEffectiveDay();
                final bool isDay90Master = currentLearningDay >= 90;

                if (isDay90Master) {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: buildEditProfileBtn()),
                      const SizedBox(width: 8),
                      Expanded(flex: 3, child: buildAvatarStudioBtn()),
                      const SizedBox(width: 8),
                      Expanded(flex: 3, child: buildVipBtn()),
                    ],
                  );
                }

                if (isCompact) {
                  return Row(
                    children: [
                      Expanded(child: buildEditProfileBtn()),
                      const SizedBox(width: 8),
                      Expanded(child: buildVipBtn()),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 5, child: buildEditProfileBtn()),
                    const SizedBox(width: 8),
                    Expanded(flex: 4, child: buildVipBtn()),
                  ],
                );
              },
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: _isFollowing
                          ? (rankTheme != null ? rankTheme.btnColor.withValues(alpha: 0.16) : const Color(0xFF262626))
                          : btnColor,
                      borderRadius: BorderRadius.circular(8),
                      border: _isFollowing
                          ? Border.all(color: (rankTheme?.borderColor ?? textColor).withValues(alpha: 0.3))
                          : null,
                    ),
                    child: InkWell(
                      onTap: _toggleFollow,
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          _isFollowing
                              ? "Following"
                              : (_isRequested ? "Requested" : "Follow"),
                          style: GoogleFonts.outfit(
                            color: _isFollowing ? (rankTheme?.textColor ?? textColor) : btnTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!(_profileData?['is_private'] == true &&
                    !_isFollowing)) ...[
                  const SizedBox(width: 8),
                  if (_isMate)
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: rankTheme != null
                              ? rankTheme.btnColor.withValues(alpha: 0.16)
                              : const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(8),
                          border: rankTheme != null
                              ? Border.all(color: rankTheme.borderColor.withValues(alpha: 0.45))
                              : null,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WhatsAppGroupChat(
                                  groupId: 'p:$userId',
                                  groupName: name,
                                  groupImage: profileUrl,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded,
                                    size: 15,
                                    color: rankTheme?.primaryColor ?? const Color(0xFF10B981)),
                                const SizedBox(width: 5),
                                Text(
                                  "Message",
                                  style: GoogleFonts.outfit(
                                    color: rankTheme?.textColor ?? textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: _isMateRequested
                              ? Colors.white10
                              : (rankTheme != null
                                  ? rankTheme.btnColor.withValues(alpha: 0.16)
                                  : const Color(0xFFFFFC00).withValues(alpha: 0.18)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isMateRequested
                                ? Colors.white24
                                : (rankTheme != null
                                    ? rankTheme.borderColor.withValues(alpha: 0.5)
                                    : const Color(0xFFFFFC00).withValues(alpha: 0.6)),
                          ),
                        ),
                        child: InkWell(
                          onTap: _isMateRequested
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Mate request already sent. Waiting for them to accept!'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Color(0xFF1E293B),
                                    ),
                                  );
                                }
                              : () async {
                                  final myId = _supabase.auth.currentUser?.id;
                                  if (myId == null) return;
                                  HapticFeedback.mediumImpact();
                                  setState(() => _isMateRequested = true);
                                  final ok = await PocketMateService.sendMateRequest(
                                    senderId: myId,
                                    receiverId: userId,
                                    message: "Hi $name, let's connect and practice English together!",
                                    contextType: 'english_hub',
                                  );
                                  await PocketTrophyService.ensurePact(
                                      myId: myId, otherUserId: userId);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded,
                                                color: Color(0xFF10B981), size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Requested! $name will see it in their Requests tab.',
                                                style: GoogleFonts.outfit(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF1E293B),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isMateRequested
                                      ? Icons.hourglass_top_rounded
                                      : Icons.person_add_alt_1_rounded,
                                  size: 15,
                                  color: _isMateRequested
                                      ? Colors.white70
                                      : (rankTheme?.primaryColor ?? const Color(0xFFFFFC00)),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isMateRequested
                                      ? "Requested"
                                      : "Mate",
                                  style: GoogleFonts.outfit(
                                    color: _isMateRequested
                                        ? Colors.white70
                                        : (rankTheme?.textColor ?? const Color(0xFFFFFC00)),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: rankTheme != null
                          ? rankTheme.btnColor.withValues(alpha: 0.22)
                          : const Color(0xFFDC2626).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rankTheme != null
                            ? rankTheme.borderColor.withValues(alpha: 0.6)
                            : const Color(0xFFDC2626).withValues(alpha: 0.5),
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final isProtected = await PocketFortressDefenseService
                            .isUnderPresidentialProtection(userId);
                        if (isProtected) {
                          final remainingMinutes =
                              await PocketFortressDefenseService
                                  .getPresidentialProtectionMinutesRemaining(
                                      userId);
                          final hours =
                              (remainingMinutes / 60.0).toStringAsFixed(1);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Text('👮‍♂️',
                                        style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Citadel is under 48h Presidential Police Protection ($hours hrs left). Raids temporarily blocked!',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF1E3A8A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                          return;
                        }

                        final day = _getEffectiveDay();
                        final streak =
                            (_profileData?['daily_streak'] as num?)?.toInt() ??
                                1;
                        final targetName = _profileData?['display_name'] ??
                            _profileData?['full_name'] ??
                            name;

                        final targetNeighbor = PocketNeighbor(
                          id: userId,
                          name: targetName,
                          day: day,
                          streak: streak,
                          rank: 'Citadel (Lvl $day)',
                          paletteId: 'royal_gold',
                          isMe: false,
                          hasActiveShield: true,
                          statusMessage:
                              '⚔️ Defend the Citadel with English prowess!',
                          hp: 100,
                          maxHp: 100,
                        );

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PocketCitadelAttackPage(
                                neighbor: targetNeighbor,
                                attackerDay: _localUserStage,
                                attackerStreak: 1,
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⚔️', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              "Attack",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF87171),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileStageBadge(LearningMilestoneStage stage) {
    final accent = stage.buttonColor;
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
    int trophyCount = 0;
    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(stage.day);
      trophyCount = PocketRobotService.getTrophiesForRobot(robot) +
          (stage.day >= 90 ? 1 : 0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent.withValues(alpha: 0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stage.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            trophyCount > 0
                ? 'STAGE ${stage.stageNumber}/90 🏆x$trophyCount'
                : 'STAGE ${stage.stageNumber}/90',
            style: GoogleFonts.outfit(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 👑 Instagram-Style Clean 3-Column Profile Stats Bar (Mates, PS, Trophies)
  /// User audio directive: "Pocket Score peruthu poyi. PS ennu churukki koduthal mathi. Ella levelukalilum Instagram pole same length aakkuka."
  Widget _buildUnifiedStatsRow({
    required Color textColor,
    required LearningMilestoneStage activeStage,
    Color? secondaryTextColor,
  }) {
    final effectiveLabelColor = secondaryTextColor ??
        (textColor == const Color(0xFF0F172A)
            ? const Color(0xFF475569)
            : Colors.white70);
    final psColor = (textColor == const Color(0xFF0F172A))
        ? const Color(0xFFB45309)
        : const Color(0xFFFFD700);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildInstagramStatColumn(
            label: 'Mates',
            count: _friendsCount > 0 ? _friendsCount : _followersCount,
            textColor: textColor,
            labelColor: effectiveLabelColor,
          ),
        ),
        Expanded(
          child: _buildInstagramStatColumn(
            label: 'PS',
            count: _pocketScore,
            textColor: psColor,
            labelColor: effectiveLabelColor,
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🪙 Pocket Score: $_pocketScore PTS • Level ${activeStage.stageNumber}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildInstagramStatColumn(
            label: '🏆',
            count: _goldTrophies,
            textColor: const Color(0xFFFFD700),
            labelColor: effectiveLabelColor,
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🏆 Gold Trophies: $_goldTrophies Won in Citadel Fight Duels!',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildInstagramStatColumn(
            label: '🥈',
            count: _silverTrophies > 0 ? _silverTrophies : _pocketTrophyCount,
            textColor: const Color(0xFFE2E8F0),
            labelColor: effectiveLabelColor,
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🥈 Silver Trophies: ${_silverTrophies > 0 ? _silverTrophies : _pocketTrophyCount} Earned in PocketTalk Spoken Pacts!',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildInstagramStatColumn(
            label: '⚔️',
            count: _attacksWon,
            textColor: const Color(0xFFEF4444),
            labelColor: effectiveLabelColor,
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⚔️ Attacks Won: $_attacksWon Citadel Raids Successfully Won!',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramStatColumn({
    required String label,
    required int count,
    required Color textColor,
    Color? labelColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Text(
                  _formatCount(val),
                  style: GoogleFonts.outfit(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: labelColor ??
                    (textColor == const Color(0xFF0F172A)
                        ? const Color(0xFF475569)
                        : Colors.white70),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, int count, Color textColor, LearningMilestoneStage stage) {
    final isStreak =
        label.toLowerCase().contains('streak') || label.contains('🔥');
    final isLevel = label.toLowerCase().contains('stage') ||
        label.toLowerCase().contains('level');

    Widget numberWidget = TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          _formatCount(val),
          style: GoogleFonts.outfit(
            color: isStreak
                ? const Color(0xFFFF8906)
                : (stage.uiThemeVariant == ProfileUIThemeVariant.goldSovereign
                    ? const Color(0xFFFFD700)
                    : stage.uiThemeVariant ==
                            ProfileUIThemeVariant.diamondCelestial
                        ? const Color(0xFF00F0FF)
                        : textColor),
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        );
      },
    );

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStreak) ...[
              const Text('🔥', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 3),
            ] else if (isLevel) ...[
              const Text('⭐', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 3),
            ],
            numberWidget,
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor.withValues(alpha: 0.65),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (stage.uiThemeVariant == ProfileUIThemeVariant.silverKnight) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212E),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.3)),
        ),
        child: content,
      );
    } else if (stage.uiThemeVariant == ProfileUIThemeVariant.goldSovereign) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1F05), Color(0xFF161103)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
        ),
        child: content,
      );
    } else if (stage.uiThemeVariant == ProfileUIThemeVariant.diamondCelestial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF080B1A),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.6)),
        ),
        child: content,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F131D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: content,
    );
  }

  /// 🪙 Pocket Score Stat Item (Highest Priority Hero Stat on User Profile)
  /// User audio directive: "പോക്കറ്റ് സ്കോർ വെച്ചിട്ടാണ് നമ്മുടെ അക്കൗണ്ടിൽ പോക്കറ്റ് സ്കോർ മേലെ തന്നെ വരണം... പോക്കറ്റ് സ്കോറിനാണ് ഇവിടെ ഹൈ പ്രയോറിറ്റി വരുന്നത്!"
  Widget _buildPocketScoreStatItem(int score, LearningMilestoneStage stage) {
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
    final currentLvl =
        isRobot ? stage.day : PocketScoreLevelEngine.getLevelFromScore(score);
    final remainingForNext = isRobot
        ? 0
        : PocketScoreLevelEngine.getRemainingScoreForNextLevel(score);
    final progressLabel = isRobot
        ? 'Pocket Robot • Level $currentLvl Fortress'
        : PocketScoreLevelEngine.getProgressLabel(score,
            trophies: _pocketTrophyCount);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    progressLabel,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF0F131D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: score),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return Text(
                      _formatCount(val),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              remainingForNext > 0
                  ? 'Lvl $currentLvl • $remainingForNext to next'
                  : 'Lvl $currentLvl • MAX',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFFC00),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsStatItem(
      Color textColor, LearningMilestoneStage stage, int day) {
    final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(userId);
    final isRobot = PocketRobotService.isRobotId(userId) || !isUuid;
    int unlockedCount;
    if (isRobot) {
      final robot = PocketRobotService.getRobotById(userId) ??
          PocketRobotService.getRobotByLevel(day);
      unlockedCount =
          PocketRobotService.getTrophiesForRobot(robot) + (day >= 90 ? 1 : 0);
      if (unlockedCount < 1 && day >= 90) unlockedCount = 1;
    } else {
      unlockedCount = day >= 90
          ? 6
          : (day >= 60
              ? 5
              : (day >= 30 ? 4 : (day >= 21 ? 3 : (day >= 15 ? 2 : 1))));
      unlockedCount += _pocketTrophyCount;
    }
    final score = _pocketScore;

    Widget content = GestureDetector(
      onTap: () => _showAchievementsModal(day, score),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 3),
              Text(
                '$unlockedCount',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFFC00),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Trophies',
            style: GoogleFonts.inter(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (stage.uiThemeVariant == ProfileUIThemeVariant.silverKnight) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212E),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.3)),
        ),
        child: content,
      );
    } else if (stage.uiThemeVariant == ProfileUIThemeVariant.goldSovereign) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1F05), Color(0xFF161103)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
        ),
        child: content,
      );
    } else if (stage.uiThemeVariant == ProfileUIThemeVariant.diamondCelestial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF080B1A),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.6)),
        ),
        child: content,
      );
    }

    return content;
  }

  void _showAchievementsModal(int day, int score) {
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Milestone Badges & Rewards',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pocket Score: 🪙 $score PTS',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFFFC00),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildAchievementRow(
                  '🏆',
                  'PocketTalk Spoken Trophies: $_pocketTrophyCount Earned',
                  '1 Trophy earned for every 4-Day Spoken Pact completed with active mates.',
                  _pocketTrophyCount > 0),
              _buildAchievementRow(
                  '🎓',
                  '90-Day Master Graduation (Target: 150 Trophies)',
                  'Required to unlock official global fluency certificate: $_pocketTrophyCount/150 completed (${((_pocketTrophyCount / 150.0) * 100).clamp(0, 100).toStringAsFixed(0)}%).',
                  _pocketTrophyCount >= 150),
              _buildAchievementRow('🌱', 'Day 1 Genesis Starter',
                  'Completed your first English foundation mission.', day >= 1),
              _buildAchievementRow('👑', 'Day 15 Royalty Unlock',
                  '15 days continuous practice milestone.', day >= 15),
              _buildAchievementRow('🎯', 'Day 21 Habit Anchor Lock',
                  '21 days permanent English habit loop formed.', day >= 21),
              _buildAchievementRow('🥈', 'Day 30 Silver Knight Shield',
                  'Phase 1 Speech Mechanics fully conquered.', day >= 30),
              _buildAchievementRow('🥇', 'Day 60 Gold Sovereign Crown',
                  'Phase 2 Real-World Fluency mastered.', day >= 60),
              _buildAchievementRow('💎', 'Day 90 Diamond Grandmaster',
                  'Capstone Graduation & Celestial Ring unlocked.', day >= 90),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementRow(
      String emoji, String title, String desc, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF161A29) : const Color(0xFF0E1018),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: isUnlocked ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    color: isUnlocked ? Colors.white60 : Colors.white24,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            color: isUnlocked ? const Color(0xFF10B981) : Colors.white24,
            size: 18,
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    } else {
      return count.toString();
    }
  }

  Widget _buildShimmerHeader() {
    final bgColor = FlutterFlowTheme.of(context).primaryBackground;
    final baseColor = FlutterFlowTheme.of(context).secondaryBackground;
    final highlightColor = FlutterFlowTheme.of(context).alternate;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 50, backgroundColor: material.Colors.white),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: material.Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 30,
              width: 200,
              decoration: BoxDecoration(
                color: material.Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: material.Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageHubDashboard(
      Color textColor, Color btnColor, bool isDark) {
    String rank = 'Beginner';
    Color rankColor = Colors.green;
    if (_englishHubPoints >= 500) {
      rank = 'Advanced';
      rankColor = const Color(0xFFFFD600);
    } else if (_englishHubPoints >= 100) {
      rank = 'Intermediate';
      rankColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: btnColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, size: 20, color: Color(0xFFFFD600)),
              const SizedBox(width: 8),
              Text(
                'English Hub Dashboard',
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rank,
                  style: GoogleFonts.outfit(
                    color: rankColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: btnColor),
              const SizedBox(width: 6),
              Text(
                '$_englishHubPoints Points',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isAnalyzingHub)
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: material.CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'AI is analyzing your progress...',
                  style: GoogleFonts.inter(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            )
          else if (_hubAnalysis.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: btnColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology,
                      size: 16, color: Color(0xFFFFD600)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hubAnalysis,
                      style: GoogleFonts.inter(
                        color: textColor.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _jumpToDay(int nextDay) async {
    final day = nextDay.clamp(1, 90);
    HapticFeedback.mediumImpact();
    final stage = LearningMilestoneStage.getStageForDay(day);
    final avatar = VectorAvatarConfig.getEvolutionAvatarForStage(day,
        talismanId: _equippedTalismanId);

    setState(() {
      _isTestingStage = true;
      final updated = Map<String, dynamic>.from(_profileData ?? {});
      updated['learning_day'] = day;
      updated['learning_stage'] = stage.stageNumber;
      updated['avatar_config'] = avatar.toMap();
      _profileData = updated;
      _localUserStage = day;
      _bgColor = stage.bgColor;
      _textColor = stage.textColor;
      _btnColor = stage.buttonColor;
      _btnTextColor = stage.buttonTextColor;
      _testStageIndex = (stage.stageNumber - 1)
          .clamp(0, LearningMilestoneStage.allStages.length - 1);
    });

    _loadFortressDefenseData();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '⚡ LEVEL $day/90: ${avatar.species.toUpperCase()} (${stage.stageName})',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: stage.buttonTextColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: stage.buttonColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pocket_learning_user_stage_$userId', day);
      await prefs.setInt('learning_day_$userId', day);
    } catch (_) {}

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid != null) {
        await _supabase.from('profile').update({
          'learning_day': day,
          'learning_stage': stage.stageNumber,
          'avatar_config': avatar.toMap(),
        }).eq('user_id', uid);
      }
    } catch (_) {}
  }

  /// ⚡ Interactive 90-Level Testing & Live Preview Switcher
  void _showStageTestingSwitcher(BuildContext context) {
    HapticFeedback.selectionClick();
    int activeDay = _getEffectiveDay();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚡ 90-Level Live Theme Switcher',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap any level (1–90) to preview live colors & companions',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close,
                            color: Colors.white70, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick Gate Shortcuts (1, 21, 30, 60, 90)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [1, 21, 30, 60, 90].map((d) {
                        final s = LearningMilestoneStage.getStageForDay(d);
                        final isCur = activeDay == d;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('Day $d ${s.emoji}'),
                            selected: isCur,
                            onSelected: (_) {
                              Navigator.pop(ctx);
                              _jumpToDay(d);
                            },
                            selectedColor: s.buttonColor,
                            backgroundColor: const Color(0xFF1E2235),
                            labelStyle: GoogleFonts.outfit(
                              color: isCur ? s.buttonTextColor : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 90,
                      itemBuilder: (context, i) {
                        final d = i + 1;
                        final s = LearningMilestoneStage.getStageForDay(d);
                        final av =
                            VectorAvatarConfig.getEvolutionAvatarForStage(d);
                        final isCur = activeDay == d;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isCur
                                ? s.buttonColor.withValues(alpha: 0.18)
                                : const Color(0xFF151824),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCur
                                  ? s.buttonColor
                                  : Colors.white.withValues(alpha: 0.06),
                              width: isCur ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s.bgColor,
                                border: Border.all(
                                    color: s.buttonColor, width: 1.5),
                              ),
                              child: Center(
                                child: Text(s.emoji,
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  'Level $d: ${s.stageName}',
                                  style: GoogleFonts.outfit(
                                    color: isCur ? s.buttonColor : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: s.buttonColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '🐾 ${av.species.replaceAll('_', ' ')} • ${s.fluencyTier}',
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 10.5,
                              ),
                            ),
                            trailing: isCur
                                ? Icon(Icons.check_circle_rounded,
                                    color: s.buttonColor, size: 18)
                                : const Icon(Icons.arrow_forward_ios_rounded,
                                    color: Colors.white24, size: 12),
                            onTap: () {
                              Navigator.pop(ctx);
                              _jumpToDay(d);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Rich Procedural Themed Banner Art for My Pocket / My Account
class StageBannerArtPainter extends CustomPainter {
  final int stage;
  final Color baseColor;

  StageBannerArtPainter({required this.stage, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final avatar = VectorAvatarConfig.getEvolutionAvatarForStage(stage);
    final species = avatar.species;
    final accent = VectorAvatarConfig.parseHex(avatar.outfitAccentColor,
        fallback: baseColor);

    // 1. Check for Oceanic / Marine Leviathans (12 Species)
    const marineSpecies = {
      'abyssal_shark',
      'abyssal_kraken',
      'electric_ray',
      'apex_orca',
      'colossal_walrus',
      'swordfish',
      'sea_otter',
      'oceanic_narwhal',
      'ghost_jellyfish',
      'reef_seahorse',
      'sea_dragon',
      'angler_leviathan'
    };

    // 2. Check for Felines & Savanna Predators (9 Species)
    const felineSpecies = {
      'cyber_cat',
      'royal_tiger',
      'golden_lion',
      'shadow_leopard',
      'golden_cheetah',
      'golden_jaguar',
      'black_panther',
      'snow_leopard',
      'solar_lion'
    };

    // 3. Check for Canines & Nocturnal Hunters (9 Species)
    const canineSpecies = {
      'cyber_fox',
      'shadow_wolf',
      'noble_bear',
      'celestial_hound',
      'mecha_wolf',
      'kitsune_emperor',
      'cerberus_hound',
      'fennec_fox',
      'spotted_hyena'
    };

    // 4. Check for Avians & Winged Sky Lords (13 Species)
    const avianSpecies = {
      'majestic_eagle',
      'solar_phoenix',
      'wisdom_owl',
      'pegasus_stallion',
      'royal_peacock',
      'peregrine_falcon',
      'emperor_penguin',
      'rainforest_toucan',
      'crimson_flamingo',
      'golden_griffin',
      'sky_thunderbird',
      'thunder_roc',
      'celestial_phoenix'
    };

    // 5. Check for Serpents & Reptiles (8 Species)
    const reptileSpecies = {
      'imperial_cobra',
      'mystic_croc',
      'tree_viper',
      'komodo_titan',
      'volcanic_salamander',
      'chameleon_king',
      'horned_lizard',
      'cyber_chameleon'
    };

    // 6. Check for Celestial Dragons & Astral Mythics (13 Species)
    const dragonCosmicSpecies = {
      'bored_ape',
      'cosmic_unicorn',
      'cosmic_dragon',
      'shadow_manticore',
      'cyber_chimera',
      'obsidian_basilisk',
      'cosmic_hydra',
      'chrono_dragon',
      'astral_titan',
      'cosmic_dragon_sovereign'
    };

    if (dragonCosmicSpecies.contains(species) || stage >= 85) {
      // ==========================================
      // 🐉 ASTRAL DRAGON REALM & COSMIC GRANDMASTER
      // ==========================================
      // 1. Cosmic Nebula Sky
      final nebulaRect = Rect.fromLTWH(0, 0, size.width, size.height);
      final nebulaShader = RadialGradient(
        center: const Alignment(0.65, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFFC026D3).withValues(alpha: 0.45),
          const Color(0xFF4F46E5).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(nebulaRect);
      canvas.drawRect(nebulaRect, Paint()..shader = nebulaShader);

      // 2. Twin Celestial Ringed Moons
      final moonCenter = Offset(size.width * 0.78, size.height * 0.32);
      canvas.drawCircle(
          moonCenter,
          28,
          Paint()
            ..color = (stage == 90 ? const Color(0xFFFFFC00) : accent)
                .withValues(alpha: 0.3));
      canvas.drawCircle(
          moonCenter,
          22,
          Paint()
            ..color = (stage == 90 ? const Color(0xFFFFFC00) : accent)
                .withValues(alpha: 0.6));
      // Ring
      canvas.drawOval(
        Rect.fromCenter(center: moonCenter, width: 70, height: 16),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // 3. Shimmering Star Field
      final starPaint = Paint()..color = Colors.white;
      for (int i = 0; i < 18; i++) {
        final sx = (size.width * (0.05 + ((i * 37) % 90) / 100));
        final sy = (size.height * (0.08 + ((i * 53) % 80) / 100));
        final sRadius = (i % 3 == 0) ? 2.5 : 1.2;
        canvas.drawCircle(Offset(sx, sy), sRadius,
            starPaint..color = Colors.white.withValues(alpha: 0.75));
        if (i % 4 == 0) {
          // 4-Point Star Flare
          canvas.drawLine(
              Offset(sx - 5, sy),
              Offset(sx + 5, sy),
              Paint()
                ..color = Colors.white.withValues(alpha: 0.8)
                ..strokeWidth = 1.0);
          canvas.drawLine(
              Offset(sx, sy - 5),
              Offset(sx, sy + 5),
              Paint()
                ..color = Colors.white.withValues(alpha: 0.8)
                ..strokeWidth = 1.0);
        }
      }

      // 4. Layered Jagged Astral Crystal Peaks
      final peakPaint = Paint()
        ..color = const Color(0xFF0F172A).withValues(alpha: 0.85);
      final peaks = Path()
        ..moveTo(size.width * 0.35, size.height)
        ..lineTo(size.width * 0.52, size.height * 0.45)
        ..lineTo(size.width * 0.68, size.height * 0.65)
        ..lineTo(size.width * 0.82, size.height * 0.38)
        ..lineTo(size.width * 0.94, size.height * 0.55)
        ..lineTo(size.width, size.height * 0.42)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(peaks, peakPaint);

      final peakEdgePaint = Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawPath(peaks, peakEdgePaint);
    } else if (marineSpecies.contains(species)) {
      // ==========================================
      // 🌊 ABYSSAL OCEAN CURRENTS & UNDERWATER BIOME
      // ==========================================
      // 1. Shimmering Sunbeams / Light Caustics from surface
      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.30),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      for (int b = 0; b < 5; b++) {
        final bx = size.width * (0.35 + b * 0.14);
        final beamPath = Path()
          ..moveTo(bx, 0)
          ..lineTo(bx + 30, 0)
          ..lineTo(bx - 20, size.height)
          ..lineTo(bx - 50, size.height)
          ..close();
        canvas.drawPath(beamPath, beamPaint);
      }

      // 2. Layered Seabed Trench & Coral Reef Silhouette
      final reefPath = Path()
        ..moveTo(size.width * 0.40, size.height)
        ..quadraticBezierTo(size.width * 0.55, size.height * 0.60,
            size.width * 0.70, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.85, size.height * 0.50, size.width,
            size.height * 0.65)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(reefPath,
          Paint()..color = const Color(0xFF031926).withValues(alpha: 0.85));

      // 3. Bioluminescent Floating Jellyfish
      final jellyCenter = Offset(size.width * 0.80, size.height * 0.36);
      canvas.drawArc(
        Rect.fromCenter(center: jellyCenter, width: 34, height: 26),
        math.pi,
        math.pi,
        true,
        Paint()..color = const Color(0xFF67E8F9).withValues(alpha: 0.6),
      );
      // Tentacles
      final tentaclePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      for (int t = -2; t <= 2; t++) {
        final tp = Path()
          ..moveTo(jellyCenter.dx + t * 6, jellyCenter.dy)
          ..quadraticBezierTo(jellyCenter.dx + t * 8, jellyCenter.dy + 15,
              jellyCenter.dx + t * 4, jellyCenter.dy + 26);
        canvas.drawPath(tp, tentaclePaint);
      }

      // Rising Bubbles
      for (int i = 0; i < 8; i++) {
        final bubX = size.width * (0.50 + (i * 17 % 45) / 100);
        final bubY = size.height * (0.2 + (i * 23 % 70) / 100);
        canvas.drawCircle(Offset(bubX, bubY), (i % 3 + 1.5) * 1.5,
            Paint()..color = Colors.white.withValues(alpha: 0.45));
      }
    } else if (felineSpecies.contains(species)) {
      // ==========================================
      // 🐆 SAVANNA SUNSET & GOLDEN TWILIGHT
      // ==========================================
      // 1. Radiant Glowing Golden Sun on Horizon
      final sunCenter = Offset(size.width * 0.78, size.height * 0.46);
      final sunShader = RadialGradient(
        colors: [
          const Color(0xFFFDE047),
          const Color(0xFFEA580C).withValues(alpha: 0.75),
          const Color(0xFF991B1B).withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 65));
      canvas.drawCircle(sunCenter, 65, Paint()..shader = sunShader);
      canvas.drawCircle(
          sunCenter, 22, Paint()..color = const Color(0xFFFEF08A));

      // 2. Layered Savanna Ridges
      final savannaBack = Path()
        ..moveTo(size.width * 0.30, size.height)
        ..quadraticBezierTo(size.width * 0.60, size.height * 0.60, size.width,
            size.height * 0.68)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(savannaBack,
          Paint()..color = const Color(0xFF451A03).withValues(alpha: 0.75));

      final savannaFore = Path()
        ..moveTo(size.width * 0.45, size.height)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.72, size.width,
            size.height * 0.58)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(savannaFore,
          Paint()..color = const Color(0xFF1C0A00).withValues(alpha: 0.90));

      // 3. Acacia Tree Silhouette
      final treeX = size.width * 0.65;
      final treeBase = size.height * 0.68;
      final treePath = Path()
        ..moveTo(treeX, treeBase)
        ..lineTo(treeX - 2, treeBase - 28)
        ..lineTo(treeX + 3, treeBase - 28)
        ..close();
      canvas.drawPath(
          treePath,
          Paint()
            ..color = const Color(0xFF1C0A00)
            ..strokeWidth = 3);
      // Flat Acacia Canopy
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(treeX, treeBase - 30), width: 36, height: 10),
        Paint()..color = const Color(0xFF1C0A00),
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(treeX + 10, treeBase - 34), width: 26, height: 8),
        Paint()..color = const Color(0xFF1C0A00),
      );

      // Warm Floating Embers
      for (int i = 0; i < 10; i++) {
        final ex = size.width * (0.50 + (i * 29 % 45) / 100);
        final ey = size.height * (0.15 + (i * 31 % 65) / 100);
        canvas.drawCircle(Offset(ex, ey), 1.8,
            Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.7));
      }
    } else if (canineSpecies.contains(species)) {
      // ==========================================
      // 🐺 MOONLIT MOUNTAINS & AURORA BOREALIS
      // ==========================================
      // 1. Waving Aurora Borealis Curtains
      final auroraShader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.35),
          const Color(0xFF06B6D4).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.6));
      final auroraPath = Path()
        ..moveTo(size.width * 0.40, 0)
        ..quadraticBezierTo(size.width * 0.65, size.height * 0.35, size.width,
            size.height * 0.15)
        ..lineTo(size.width, 0)
        ..close();
      canvas.drawPath(auroraPath, Paint()..shader = auroraShader);

      // 2. Glowing Full Moon with Halo
      final moonCenter = Offset(size.width * 0.82, size.height * 0.28);
      canvas.drawCircle(moonCenter, 32,
          Paint()..color = Colors.white.withValues(alpha: 0.18));
      canvas.drawCircle(
          moonCenter, 18, Paint()..color = const Color(0xFFF1F5F9));

      // 3. Layered Midnight Mountain Ridges
      final distantMtn = Path()
        ..moveTo(size.width * 0.35, size.height)
        ..lineTo(size.width * 0.58, size.height * 0.38)
        ..lineTo(size.width * 0.76, size.height * 0.58)
        ..lineTo(size.width * 0.90, size.height * 0.32)
        ..lineTo(size.width, size.height * 0.48)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(distantMtn,
          Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.8));

      final foreMtn = Path()
        ..moveTo(size.width * 0.48, size.height)
        ..lineTo(size.width * 0.70, size.height * 0.52)
        ..lineTo(size.width * 0.88, size.height * 0.70)
        ..lineTo(size.width, size.height * 0.56)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(foreMtn,
          Paint()..color = const Color(0xFF090D16).withValues(alpha: 0.95));

      // Pine Tree Silhouettes
      for (int i = 0; i < 5; i++) {
        final px = size.width * (0.62 + i * 0.08);
        final py = size.height * (0.60 + (i % 2) * 0.08);
        final pine = Path()
          ..moveTo(px, py - 14)
          ..lineTo(px - 6, py)
          ..lineTo(px + 6, py)
          ..close();
        canvas.drawPath(pine, Paint()..color = const Color(0xFF020617));
      }
    } else if (avianSpecies.contains(species)) {
      // ==========================================
      // 🦅 HEAVENLY CLOUD REALM & SUNBEAMS
      // ==========================================
      // 1. Radiant Golden Sunbeams
      final sunbeamCenter = Offset(size.width * 0.85, size.height * 0.15);
      final rayPaint = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi) / 4;
        canvas.drawLine(
            sunbeamCenter,
            Offset(sunbeamCenter.dx + math.cos(angle) * 75,
                sunbeamCenter.dy + math.sin(angle) * 75),
            rayPaint);
      }
      canvas.drawCircle(sunbeamCenter, 20,
          Paint()..color = const Color(0xFFFFFC00).withValues(alpha: 0.7));

      // 2. Soaring Cloud Banks
      void drawCloud(Offset c, double radius) {
        final cloudPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35);
        canvas.drawCircle(c, radius, cloudPaint);
        canvas.drawCircle(Offset(c.dx - radius * 0.6, c.dy + radius * 0.2),
            radius * 0.7, cloudPaint);
        canvas.drawCircle(Offset(c.dx + radius * 0.6, c.dy + radius * 0.2),
            radius * 0.7, cloudPaint);
      }

      drawCloud(Offset(size.width * 0.65, size.height * 0.55), 24);
      drawCloud(Offset(size.width * 0.88, size.height * 0.65), 30);

      // 3. Distant Flying Flock Silhouettes
      for (int i = 0; i < 3; i++) {
        final fx = size.width * (0.52 + i * 0.08);
        final fy = size.height * (0.25 + (i % 2) * 0.06);
        final bird = Path()
          ..moveTo(fx - 7, fy + 3)
          ..quadraticBezierTo(fx - 3, fy - 3, fx, fy)
          ..quadraticBezierTo(fx + 3, fy - 3, fx + 7, fy + 3);
        canvas.drawPath(
            bird,
            Paint()
              ..color = const Color(0xFF0F172A)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8);
      }
    } else if (reptileSpecies.contains(species)) {
      // ==========================================
      // 🐍 VOLCANIC REALM & PREHISTORIC JUNGLE
      // ==========================================
      // 1. Magma Fissure Glow
      final magmaRect = Rect.fromLTWH(size.width * 0.4, size.height * 0.5,
          size.width * 0.6, size.height * 0.5);
      final magmaShader = RadialGradient(
        colors: [
          const Color(0xFFEF4444).withValues(alpha: 0.5),
          Colors.transparent
        ],
      ).createShader(magmaRect);
      canvas.drawRect(magmaRect, Paint()..shader = magmaShader);

      // 2. Volcanic Crag
      final crag = Path()
        ..moveTo(size.width * 0.42, size.height)
        ..lineTo(size.width * 0.62, size.height * 0.48)
        ..lineTo(size.width * 0.78, size.height * 0.68)
        ..lineTo(size.width * 0.92, size.height * 0.40)
        ..lineTo(size.width, size.height * 0.55)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(crag,
          Paint()..color = const Color(0xFF18181B).withValues(alpha: 0.95));

      // Magma River
      final river = Path()
        ..moveTo(size.width * 0.62, size.height * 0.48)
        ..quadraticBezierTo(size.width * 0.70, size.height * 0.72,
            size.width * 0.85, size.height);
      canvas.drawPath(
          river,
          Paint()
            ..color = const Color(0xFFF97316)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5);
    } else {
      // ==========================================
      // 🌲 ENCHANTED WOODLAND & FOREST CANOPY
      // ==========================================
      // 1. Rolling Forest Hills
      final hill1 = Path()
        ..moveTo(size.width * 0.35, size.height)
        ..quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width,
            size.height * 0.62)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(hill1,
          Paint()..color = const Color(0xFF064E3B).withValues(alpha: 0.85));

      final hill2 = Path()
        ..moveTo(size.width * 0.50, size.height)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.68, size.width,
            size.height * 0.52)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(hill2,
          Paint()..color = const Color(0xFF022C22).withValues(alpha: 0.95));

      // 2. Ancient Tree Canopies
      canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.48), 28,
          Paint()..color = const Color(0xFF065F46));
      canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.42), 34,
          Paint()..color = const Color(0xFF047857));

      // 3. Magical Floating Fireflies
      for (int i = 0; i < 9; i++) {
        final fx = size.width * (0.50 + (i * 23 % 45) / 100);
        final fy = size.height * (0.20 + (i * 37 % 60) / 100);
        canvas.drawCircle(
            Offset(fx, fy), 2.2, Paint()..color = const Color(0xFF6EE7B7));
        canvas.drawCircle(Offset(fx, fy), 5.0,
            Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.25));
      }
    }
  }

  @override
  bool shouldRepaint(covariant StageBannerArtPainter oldDelegate) {
    return oldDelegate.stage != stage || oldDelegate.baseColor != baseColor;
  }
}

class _SliverAppBarDelegate extends material.SliverPersistentHeaderDelegate {
  final material.TabBar _tabBar;
  final Color bgColor;

  _SliverAppBarDelegate(this._tabBar, this.bgColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

class _GalleryTab extends StatelessWidget {
  final String userId;
  final List<Map<String, dynamic>> items;
  final Color textColor;
  final Color bgColor;
  final Color btnColor;
  final Color btnTextColor;

  const _GalleryTab({
    required this.userId,
    required this.items,
    required this.textColor,
    required this.bgColor,
    required this.btnColor,
    required this.btnTextColor,
  });
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(material.Icons.grid_view,
                size: 48, color: textColor.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text("No posts found",
                style: TextStyle(color: textColor.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
      return MasonryGridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final imageUrl = item['gallery_image_url'] ?? item['image_url'];
          final title = item['gallery_title'] ?? item['title'];
          final price = item['gallery_price'] ?? item['price'];
          final isService = item['is_service'] == true;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                material.MaterialPageRoute(
                  builder: (context) => GalleryDetailsprofilePage(
                    userid: userId,
                    item: item,
                    allItems: items,
                    initialIndex: index,
                    bgColor: bgColor,
                    bgtextcolor: textColor,
                    buttoncolorcode: btnColor,
                    buttontextcolor: btnTextColor,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: textColor.withValues(alpha: 0.03),
                border: Border.all(
                    color: textColor.withValues(alpha: 0.08), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: imageUrl != null &&
                                imageUrl.toString().isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                memCacheWidth: 400,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 150,
                                  color: textColor.withValues(alpha: 0.03),
                                  child: Center(
                                    child: material.SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: material.CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: material
                                            .AlwaysStoppedAnimation<Color>(
                                                btnColor.withValues(
                                                    alpha: 0.5)),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 150,
                                  color: textColor.withValues(alpha: 0.05),
                                  child: Icon(material.Icons.grid_view_rounded,
                                      color: textColor.withValues(alpha: 0.3),
                                      size: 36),
                                ),
                              )
                            : Container(
                                height: 150,
                                color: textColor.withValues(alpha: 0.05)),
                      ),
                      if (price != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  material.Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: material.Colors.white
                                      .withValues(alpha: 0.12)),
                            ),
                            child: Text(
                              '₹$price',
                              style: GoogleFonts.inter(
                                color: material.Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (title != null && title.toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 8.0, bottom: 2.0),
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isService
                            ? btnColor.withValues(alpha: 0.1)
                            : textColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isService
                                ? material.Icons.handyman_outlined
                                : material.Icons.shopping_bag_outlined,
                            size: 10,
                            color: isService
                                ? btnColor
                                : textColor.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isService ? 'Service' : 'Product',
                            style: GoogleFonts.inter(
                              color: isService
                                  ? btnColor
                                  : textColor.withValues(alpha: 0.6),
                              fontSize: 9.5,
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
          );
        },
      );
    });
  }
}

class _ThreadsTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Color textColor;
  final Color btnColor;
  final Color btnTextColor;

  const _ThreadsTab({
    required this.items,
    required this.textColor,
    required this.btnColor,
    required this.btnTextColor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(material.Icons.chat,
                size: 40, color: textColor.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text("No thoughts shared yet",
                style: TextStyle(
                    color: textColor.withValues(alpha: 0.5), fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final thread = items[idx];
        final content = thread['content'] ?? '';
        final createdAt = thread['created_at'];
        final timeStr =
            createdAt != null ? timeago.format(DateTime.parse(createdAt)) : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textColor.withValues(alpha: 0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: btnColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(material.Icons.person, color: btnColor, size: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeStr,
                    style: GoogleFonts.inter(
                      color: textColor.withValues(alpha: 0.4),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  material.IconButton(
                    icon: Icon(material.Icons.more_vert,
                        size: 15, color: textColor.withValues(alpha: 0.3)),
                    onPressed: () {},
                    padding: material.EdgeInsets.zero,
                    constraints: const material.BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 14.5,
                  height: 1.45,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildThreadStat(
                    material.Icons.favorite,
                    ((thread['like_count'] ?? 0) + (thread['fake_likes'] ?? 0))
                        .toString(),
                    btnColor,
                  ),
                  const SizedBox(width: 24),
                  _buildThreadStat(
                    material.Icons.comment,
                    (thread['comment_count'] ?? 0).toString(),
                    textColor.withValues(alpha: 0.5),
                  ),
                  const Spacer(),
                  Icon(material.Icons.share,
                      size: 16, color: textColor.withValues(alpha: 0.4)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThreadStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
