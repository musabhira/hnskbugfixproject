import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import 'index.dart';

import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart' hide MenuFlyoutItem;
import 'package:pocket_mates_app/custom_code/widgets/posters_tab.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/jackie_chan_talisman_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/flame_profile_banner_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

class MainProfileWidget extends StatefulWidget {
  final String? userId;
  final double? width;
  final double? height;

  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const MainProfileWidget({
    super.key,
    this.userId,
    this.width,
    this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  });

  @override
  State<MainProfileWidget> createState() => _MainProfileWidgetState();
}

class _MainProfileWidgetState extends State<MainProfileWidget>
    with material.TickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  late material.TabController _myAccountTabController;
  late material.TabController _publicTabController;
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
  String? _equippedTalismanId;

  VectorAvatarConfig _getAvatarConfig() {
    final day = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
    // When in My Account / My Pocket view, show the systematic stage-evolved avatar
    if (!_isPublicProfileView) {
      return VectorAvatarConfig.getEvolutionAvatarForStage(day, talismanId: _equippedTalismanId);
    }
    // When in Public Profile view, show custom configured avatar if available
    if (_profileData != null && _profileData!['avatar_config'] != null) {
      try {
        final map = Map<String, dynamic>.from(_profileData!['avatar_config']);
        return VectorAvatarConfig.fromMap(map);
      } catch (_) {}
    }
    return VectorAvatarConfig.getEvolutionAvatarForStage(day, talismanId: _equippedTalismanId);
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
      r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
      g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
      b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
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
    // Independent tab controllers: My Account (1 tab) and Public Profile (3 tabs: Gallery, Thoughts, Posters)
    _myAccountTabController = material.TabController(length: 1, vsync: this);
    _publicTabController = material.TabController(length: 3, vsync: this);
    _myAccountTabController.addListener(() { if (mounted) setState(() {}); });
    _publicTabController.addListener(() { if (mounted) setState(() {}); });
    _loadInitialData(); // Instant load strategy
    _fetchThreads();
    _loadEquippedTalisman();
    _loadFortressDefenseData();
  }

  // Fortress Citadel & Defense Traps State (User audio: "നിലവിലുള്ള ഡിഫൻസ് എന്തൊക്കെയാണ് എന്നുള്ളത്, എന്തൊക്കെ ക്വസ്റ്റ്യൻസ് ഡിഫൻസ് ഉണ്ട് എന്നുള്ളത് അത് കാണാനും പറ്റണം. അത് നമ്മുടെ മൈ പ്രൊഫൈലില് കാണാൻ പറ്റണം")
  HouseDefenseStatus? _fortressStatus;
  List<HouseShieldQuestion> _shieldQuestions = [];
  bool _isLoadingDefense = false;

  Future<void> _loadFortressDefenseData() async {
    final day = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
    try {
      final status = await PocketFortressDefenseService.getHouseStatus(day);
      final questions = await PocketFortressDefenseService.loadShieldQuestions(day, isNeighbor: false);
      if (mounted) {
        setState(() {
          _fortressStatus = status;
          _shieldQuestions = questions;
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
    _myAccountTabController.dispose();
    _publicTabController.dispose();
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
    _fetchFreshData();
    _fetchEnglishHubData();
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
      
      final prompt = 'A user in the Pocket Mates English Hub has $points points. '
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
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎨 Stage ${stage.stageNumber}/90: ${stage.emoji} ${stage.stageName} • ${stage.fluencyTier}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
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

  Future<void> _testCycleNextStageColor() async {
    final stages = LearningMilestoneStage.allStages;
    _testStageIndex = (_testStageIndex + 1) % stages.length;
    final stage = stages[_testStageIndex];
    await _jumpToStage(stage.stageNumber);
  }

  void _showTestingJumpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_rounded, color: Color(0xFFFFFC00), size: 22),
                const SizedBox(width: 10),
                Text(
                  '🎨 90-Stage Fast-Forward Tester',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Select any major milestone to immediately preview the Profile UI Transformation:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildJumpButton(ctx, 1, '🌱 Day 1 (Genesis Slate)'),
                _buildJumpButton(ctx, 15, '🔮 Day 15 (Royal Lavender)'),
                _buildJumpButton(ctx, 21, '🎯 Day 21 (Habit Anchor)'),
                _buildJumpButton(ctx, 30, '🥈 Day 30 (Silver Gate UI)'),
                _buildJumpButton(ctx, 45, '🏰 Day 45 (Golden Citadel)'),
                _buildJumpButton(ctx, 60, '🥇 Day 60 (24K Gold Sovereign)'),
                _buildJumpButton(ctx, 75, '🖤 Day 75 (Phantom Onyx)'),
                _buildJumpButton(ctx, 90, '💎 Day 90 (Diamond Master Peak)'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _testCycleNextStageColor();
                },
                icon: const Icon(Icons.skip_next_rounded, color: Colors.black),
                label: Text(
                  'Cycle to Next Stage (+1)',
                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJumpButton(BuildContext ctx, int day, String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _jumpToStage(day);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _applyProfileData(Map<String, dynamic> data) {
    _profileData = data;
    final day = (data['learning_day'] as num?)?.toInt() ?? 1;
    final stage = LearningMilestoneStage.getStageForDay(day);
    _testStageIndex = (stage.stageNumber - 1).clamp(0, LearningMilestoneStage.allStages.length - 1);

    // Keep user's chosen custom colors configured in "Edit Profile" across both My Account and Public Profile
    _bgColor = _parseColor(data['bg_color_code']) ?? const Color(0xFF0F111A);
    _textColor = _parseColor(data['bg_text_color']) ?? Colors.white;
    _btnColor = _parseColor(data['button_color_code']) ?? const Color(0xFF0095F6);
    _btnTextColor = _parseColor(data['button_text_color']) ?? Colors.white;
  }

  Future<void> _fetchFreshData() async {
    try {
      if (mounted && _profileData == null) setState(() => _isLoading = true);

      final myId = _supabase.auth.currentUser?.id;
      final responses = await Future.wait<dynamic>([
        _supabase
            .from('profile')
            .select()
            .eq('user_id', userId)
            .limit(1), // Profile
        _supabase
            .from('gallery')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false), // Recent Gallery directly from gallery table
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
      ]);

      if (!mounted) return;

      final profileRes = responses[0] as List;
      final galleryRes = responses[1] as List;
      final counts = responses[2] as Map<String, int>;
      final followStatus = responses[3] as bool;
      final blockStatus = responses[4] as bool;
      final requestRes = responses[5];

      final isRequested = requestRes != null;

      if (profileRes.isNotEmpty) {
        final data = profileRes.first as Map<String, dynamic>;
        setState(() {
          _isFollowing = followStatus;
          _isBlocked = blockStatus;
          _isRequested = isRequested;
          _applyProfileData(data);
          _isLoading = false;
        });
        // Cache this fresh data
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('profile_cache_$userId', json.encode(data));
      }

      // Process Gallery
      final Map<String, Map<String, dynamic>> uniqueGallery = {};
      Set<String> categorySet = {};

      for (var item in galleryRes) {
        final id = item['id']?.toString() ?? item['gallery_id']?.toString();
        if (id != null) {
          // Normalize view & table keys for legacy support
          final Map<String, dynamic> normalizedItem = Map<String, dynamic>.from(item);
          normalizedItem['gallery_id'] = item['id'] ?? item['gallery_id'];
          normalizedItem['gallery_image_url'] = item['image_url'] ?? item['gallery_image_url'];
          normalizedItem['gallery_title'] = item['title'] ?? item['gallery_title'];
          normalizedItem['gallery_price'] = item['price'] ?? item['gallery_price'];
          normalizedItem['gallery_description'] = item['description'] ?? item['gallery_description'];
          normalizedItem['gallery_category'] = item['category'] ?? item['gallery_category'];

          uniqueGallery[id] = normalizedItem;
          final category = normalizedItem['category']?.toString().trim() ?? normalizedItem['gallery_category']?.toString().trim();
          if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
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
            final Map<String, dynamic> normalizedItem = Map<String, dynamic>.from(item);
            normalizedItem['gallery_id'] = item['id'] ?? item['gallery_id'];
            normalizedItem['gallery_image_url'] = item['image_url'] ?? item['gallery_image_url'];
            normalizedItem['gallery_title'] = item['title'] ?? item['gallery_title'];
            normalizedItem['gallery_price'] = item['price'] ?? item['gallery_price'];
            normalizedItem['gallery_description'] = item['description'] ?? item['gallery_description'];
            normalizedItem['gallery_category'] = item['category'] ?? item['gallery_category'];

            uniqueGallery[id] = normalizedItem;
            final cat = normalizedItem['category']?.toString().trim() ?? normalizedItem['gallery_category']?.toString().trim();
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
      final followerIds = (followersRes as List).map((e) => e['follower_id'].toString()).toSet();
      final followingIds = (followingRes as List).map((e) => e['followed_id'].toString()).toSet();
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

      return {
        'followers': followerIds.length + baseFollowers,
        'following': followingIds.length,
        'friends': mutualFriends.length,
      };
    } catch (e) {
      debugPrint('Error fetching follow counts: $e');
      return {'followers': 0, 'following': 0};
    }
  }

  Future<bool> _checkFollowStatusBool() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return false;
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
          final cat = item['category']?.toString().trim() ?? item['gallery_category']?.toString().trim();
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

    final isPrivate = _profileData?['is_private'] == true;

    if (isPrivate && !_isFollowing) {
      final oldRequested = _isRequested;
      setState(() {
        _isRequested = !_isRequested;
      });

      try {
        if (_isRequested) {
          final myProfile = await _supabase.from('profile').select('name').eq('user_id', myId).maybeSingle();
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

  // --- UI Construction ---

  @override
  Widget build(BuildContext context) {
    if (_isBlocked) {
      return material.Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: Text(
            "You have blocked this user.",
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
        ),
      );
    }

    if (_isLoading && _profileData == null) {
      return material.Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: material.CircularProgressIndicator(
            valueColor: material.AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary),
            strokeWidth: 3,
          ),
        ),
      );
    }

    // Instagram-style Light/Dark mode themes
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA);
    final defaultTextColor = isDark ? const Color(0xFFF5F5F5) : const Color(0xFF262626);
    final defaultBtnColor = isDark ? const Color(0xFF363636) : const Color(0xFFEFEFEF);
    final defaultBtnTextColor = isDark ? const Color(0xFFF5F5F5) : const Color(0xFF262626);

    final rawBgColor = _bgColor ?? defaultBgColor;
    final rawTextColor = _textColor ?? defaultTextColor;
    final rawBtnColor = _btnColor ?? (isMe ? defaultBtnColor : const Color(0xFF0095F6));
    final rawBtnTextColor = _btnTextColor ?? (isMe ? defaultBtnTextColor : const Color(0xFFFFFFFF));

    // Contrast check: if background and text colors are same or too close, override text color
    var finalBtnTextColor = rawBtnTextColor;
    if ((rawBtnColor.toARGB32() & 0xFFFFFF) == (rawBtnTextColor.toARGB32() & 0xFFFFFF) ||
        (rawBtnColor.computeLuminance() - rawBtnTextColor.computeLuminance()).abs() < 0.15) {
      finalBtnTextColor = rawBtnColor.computeLuminance() > 0.5 
          ? const Color(0xFF1E293B) 
          : const Color(0xFFFFFFFF);
    }

    final bgColor = rawBgColor;
    final btnColor = _ensureContrast(rawBtnColor, bgColor, isButton: true);
    final textColor = _ensureContrast(rawTextColor, bgColor, isButton: false);
    final btnTextColor = _ensureContrast(finalBtnTextColor, btnColor, isButton: false);

    return material.Scaffold(
      backgroundColor: bgColor,
      body: material.NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            material.SliverAppBar(
              elevation: 0,
              expandedHeight: 220.0,
              pinned: true,
              stretch: false,
              backgroundColor:
                  innerBoxIsScrolled ? bgColor : material.Colors.transparent,
              leading: material.IconButton(
                icon: const Icon(material.Icons.arrow_back, size: 22),
                color: textColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: innerBoxIsScrolled
                  ? Text(
                      _profileData?['shop_name'] ?? _profileData?['name'] ?? '',
                      style: GoogleFonts.outfit(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
              centerTitle: true,
              actions: [
                if (isMe) ...[
                  material.IconButton(
                    icon: const Icon(material.Icons.receipt_long_rounded, size: 22),
                    color: textColor,
                    tooltip: 'POS Terminal',
                    onPressed: () {
                      Navigator.push(
                        context,
                        material.MaterialPageRoute(
                          builder: (context) => const BusinessPOSPage(),
                        ),
                      );
                    },
                  ),
                  material.IconButton(
                    icon: const Icon(material.Icons.switch_account, size: 22),
                    color: textColor,
                    onPressed: () => AutoLoginBottomSheet.show(context),
                    tooltip: 'Switch Account',
                  ),
                  material.IconButton(
                    icon: const Icon(material.Icons.notifications_outlined, size: 22),
                    color: textColor,
                    tooltip: 'Notifications & Requests',
                    onPressed: () => material.Navigator.push(
                      context,
                      material.MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    ),
                  ),
                  material.Tooltip(
                    message: 'Tap: Next Stage (+1) | Long-Press: Select Milestone',
                    child: material.InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _fastForwardStage,
                      onLongPress: _showTestingJumpModal,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          material.Icons.palette_rounded,
                          size: 22,
                          color: Color(0xFFFFFC00),
                        ),
                      ),
                    ),
                  ),
                ],
                material.IconButton(
                  icon: const Icon(material.Icons.share, size: 22),
                  color: textColor,
                  onPressed: () => SharePlus.instance.share(
                      ShareParams(text: 'Check out ${_profileData?['name']}\'s profile on Pocketmates!')),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(material.Icons.more_vert),
                  color: bgColor,
                  iconColor: textColor,
                  onSelected: (value) {
                    if (value == 'Report') {
                      // Report logic
                    } else if (value == 'Block') {
                      // Block logic
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Report',
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      value: 'Block',
                      child: Text('Block', style: TextStyle(color: material.Colors.red)),
                    ),
                  ],
                ),
              ],
              flexibleSpace: material.FlexibleSpaceBar(
                background: _buildBanner(),
                collapseMode: material.CollapseMode.parallax,
              ),
            ),
            material.SliverToBoxAdapter(
              child:
                  _buildProfileHeader(textColor, btnColor, btnTextColor, isMe),
            ),
            if (!(_profileData?['is_private'] == true && !_isFollowing && !isMe) &&
                (_isPublicProfileView || !isMe))
              material.SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  material.TabBar(
                    key: ValueKey('tab_bar_public_$isMe'),
                    controller: _publicTabController,
                    labelColor: textColor,
                    unselectedLabelColor: textColor.withValues(alpha: 0.5),
                    indicatorColor: btnColor,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    tabs: const [
                      material.Tab(text: "🖼️ Gallery"),
                      material.Tab(text: "💭 Thoughts"),
                      material.Tab(text: "📜 Posters"),
                    ],
                  ),
                  bgColor,
                ),
              ),
          ];
        },
        body: Container(
          color: bgColor,
          child: (_profileData?['is_private'] == true && !_isFollowing && !isMe)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: btnColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          material.Icons.lock_outline_rounded,
                          size: 48,
                          color: btnColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "This account is private",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Follow this account to see their photos and updates.",
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : (isMe && !_isPublicProfileView)
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          FlameEnglishHouseWidget(
                            currentDay: (_profileData?['learning_day'] as num?)?.toInt() ?? 1,
                            streak: (_profileData?['daily_streak'] as num?)?.toInt() ?? 1,
                          ),
                          const SizedBox(height: 16),
                          _buildCitadelDefenseSection(textColor, btnColor, btnTextColor),
                          const SizedBox(height: 32),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Category Selector — only shown on Gallery tab of Public Profile (never in My Account)
                        if (_categories.length > 1 && _publicTabController.index == 0)
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _filterGalleryByCategory(cat),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? btnColor : material.Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? btnColor : textColor.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          color: isSelected ? btnTextColor : textColor,
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Expanded(
                          child: material.TabBarView(
                            key: ValueKey('tab_view_public_$isMe'),
                            controller: _publicTabController,
                            children: [
                              _GalleryTab(
                                userId: userId,
                                items: _filteredGalleryItems,
                                textColor: textColor,
                                bgColor: bgColor,
                                btnColor: btnColor,
                                btnTextColor: btnTextColor,
                              ),
                              _ThreadsTab(
                                items: _threadItems,
                                textColor: textColor,
                                btnColor: btnColor,
                                btnTextColor: btnTextColor,
                              ),
                              PostersTab(
                                profileData: _profileData,
                                galleryItems: _galleryItems,
                                services: const [],
                                thoughts: _threadItems,
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

  // 🛡️ House Citadel & Defense Traps Inspection Widget (User audio: "നിലവിലുള്ള ഡിഫൻസ് എന്തൊക്കെയാണ് എന്നുള്ളത്, എന്തൊക്കെ ക്വസ്റ്റ്യൻസ് ഡിഫൻസ് ഉണ്ട് എന്നുള്ളത് അത് കാണാനും പറ്റണം. അത് നമ്മുടെ മൈ പ്രൊഫൈലില് കാണാൻ പറ്റണം")
  Widget _buildCitadelDefenseSection(Color textColor, Color btnColor, Color btnTextColor) {
    if (_isLoadingDefense && _fortressStatus == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
        ),
      );
    }

    final currentDay = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
    final status = _fortressStatus ?? const HouseDefenseStatus();
    final maxSlots = PocketFortressDefenseService.getMaxQuestionsForStage(currentDay);
    final armedCount = _shieldQuestions.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0284C7).withValues(alpha: 0.15),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('🛡️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CITADEL DEFENSE & ARMED TRAPS',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Day $currentDay Fortress • $armedCount / $maxSlots Questions Armed',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    PocketDefenseTrapModal.show(context, currentDay);
                    await Future.delayed(const Duration(milliseconds: 300));
                    _loadFortressDefenseData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'MANAGE',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4-Tile Quick Metric Overview
                Row(
                  children: [
                    // HP Tile
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: status.isDamaged
                                ? Colors.redAccent.withValues(alpha: 0.5)
                                : const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(status.isDamaged ? '💔' : '❤️', style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'CITADEL HP',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white38,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${status.currentHp}/${status.maxHp}',
                              style: GoogleFonts.outfit(
                                color: status.isDamaged ? Colors.redAccent : const Color(0xFF34D399),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Iron Dome Tile
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: status.hasIronDome
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.5)
                                : Colors.white12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🛡️', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'IRON DOME',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white38,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              status.hasIronDome ? 'Tier ${status.ironDomeTier}' : 'Inactive',
                              style: GoogleFonts.outfit(
                                color: status.hasIronDome ? const Color(0xFF00F0FF) : Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Knights Garrison Tile
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('⚔️', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'GARRISON',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white38,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${status.armyKnightsCount} Knights',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Activity Credits Tile
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'CREDITS',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white38,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${status.activityPoints} FDC',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF38BDF8),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Gates & Defense Questions List (User audio specification!)
                Text(
                  'ACTIVE DEFENSE GATES & ARMED QUESTIONS',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),

                // List of active gates
                ...status.activeShieldTraps.map((trapId) {
                  final template = kDefenseTrapTemplates.firstWhere(
                    (t) => t.id == trapId,
                    orElse: () => kDefenseTrapTemplates[0],
                  );
                  final gateQuestions = _shieldQuestions.where((q) {
                    return q.trapType == template.id || q.category == template.category;
                  }).toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: template.themeColor.withValues(alpha: 0.35),
                        width: 1.1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gate Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          child: Row(
                            children: [
                              Text(template.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  template.title,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: template.themeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: template.themeColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  '${gateQuestions.length} Questions Armed',
                                  style: GoogleFonts.outfit(
                                    color: template.themeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Configured Questions or Empty Alert
                        if (gateQuestions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            child: Column(
                              children: gateQuestions.map((q) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Q: ',
                                            style: GoogleFonts.outfit(
                                              color: template.themeColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              q.question,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              '${DefenseGameFormat.getIcon(q.gameFormat)} ${DefenseGameFormat.getTitle(q.gameFormat)}',
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFF38BDF8),
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 11),
                                                const SizedBox(width: 4),
                                                Text(
                                                  q.options.isNotEmpty && q.correctIndex < q.options.length
                                                      ? q.options[q.correctIndex]
                                                      : 'Option 1',
                                                  style: GoogleFonts.inter(
                                                    color: const Color(0xFF34D399),
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          const Text(
                                            '🏅 Verified Authentic',
                                            style: TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF451A03).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gate Unarmed! Raiders can breach without answering. Arm a question now.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFDE68A),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () async {
                                      PocketDefenseTrapModal.show(context, currentDay);
                                      await Future.delayed(const Duration(milliseconds: 300));
                                      _loadFortressDefenseData();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '+ ARM',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Primary Management CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.heavyImpact();
                      PocketDefenseTrapModal.show(context, currentDay);
                      await Future.delayed(const Duration(milliseconds: 300));
                      _loadFortressDefenseData();
                    },
                    icon: const Icon(Icons.security_rounded, color: Colors.black, size: 18),
                    label: Text(
                      'CRAFT & DEPLOY DEFENSE QUESTIONS',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
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

  Widget _buildBanner() {
    final day = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
    final stage = LearningMilestoneStage.getStageForDay(day);
    final avatar = VectorAvatarConfig.getEvolutionAvatarForStage(day);
    final bannerUrl = _profileData?['banner_image_url'] ?? _profileData?['banner_url'];

    // 🐾 In My Accounts (isMe), dynamically render the current day's active animal avatar banner!
    // For other users' public profiles (!isMe), use uploaded custom banner if available.
    if (!isMe && bannerUrl != null && bannerUrl.toString().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: bannerUrl.toString(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(color: const Color(0xFF161E33)),
        errorWidget: (context, url, error) => _buildStageFallbackBanner(day, stage, avatar),
      );
    }

    return _buildStageFallbackBanner(day, stage, avatar);
  }

  Widget _buildStageFallbackBanner(int day, LearningMilestoneStage stage, VectorAvatarConfig avatar) {
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

    final day = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
    final activeStage = LearningMilestoneStage.getStageForDay(day);

    final name = _profileData?['name'] ?? 'User';
    final shopName = _profileData?['shop_name'];
    final bio = _profileData?['bio'] ?? '';
    final profileUrl = _profileData?['profile_image_url'];
    final isVerified = _profileData?['verified'] == true;
    final slug = _profileData?['slug'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? const Color(0xFFA8A8A8) : const Color(0xFF8E8E8E);
    final dividerColor = isDark ? const Color(0xFF262626) : const Color(0xFFDBDBDB);

    // Render one of 4 clean, progressive standard layouts based on learning day
    Widget headerContent;
    if (day <= 15) {
      // Layout 1: Classic Instagram Layout (Left Avatar, Right Stats)
      headerContent = _buildLayoutGenesis(
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
    } else if (day <= 30) {
      // Layout 2: Modern Split Deck (Left Stats Capsules, Right Avatar)
      headerContent = _buildLayoutSplitRight(
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
    } else if (day <= 60) {
      // Layout 3: Center Spotlight Hero (Centered Avatar, Centered Name & Stage Badge, Floating Stats Bar)
      headerContent = _buildLayoutCenterSpotlight(
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
    } else {
      // Layout 4: Celestial Grandmaster Deck (Grandmaster Obsidian Card, Left Holographic Avatar, Glowing Stats, Diamond Crown)
      headerContent = _buildLayoutCelestialShowcase(
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
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMe) _buildDualProfileSegmentSwitcher(textColor, btnColor, btnTextColor, isDark),
        headerContent,
        if (!_isPublicProfileView) ...[
          Learning60DayProfileCard(userId: userId),
          if (isMe) _buildLanguageHubDashboard(textColor, btnColor, isDark),
        ],
        _buildActionButtons(textColor, btnColor, btnTextColor, isMe, isDark, name, profileUrl),
      ],
    );
  }

  Widget _buildDualProfileSegmentSwitcher(
      Color textColor, Color btnColor, Color btnTextColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1E2D) : const Color(0xFFE2E8F0),
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
                    color: !_isPublicProfileView ? btnColor : Colors.transparent,
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
                        'My Account',
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Friends", _friendsCount, textColor, activeStage),
                    _buildStatItem("Followers", _followersCount, textColor, activeStage),
                    _buildStatItem("Following", _followingCount, textColor, activeStage),
                    _buildAchievementsStatItem(textColor, activeStage, activeStage.day),
                  ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Friends", _friendsCount, textColor, activeStage),
                    _buildStatItem("Followers", _followersCount, textColor, activeStage),
                    _buildStatItem("Following", _followingCount, textColor, activeStage),
                    _buildAchievementsStatItem(textColor, activeStage, activeStage.day),
                  ],
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
              color: const Color(0xFF161103).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("Friends", _friendsCount, textColor, activeStage),
                Container(width: 1, height: 28, color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                _buildStatItem("Followers", _followersCount, textColor, activeStage),
                Container(width: 1, height: 28, color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                _buildStatItem("Following", _followingCount, textColor, activeStage),
                Container(width: 1, height: 28, color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                _buildAchievementsStatItem(textColor, activeStage, activeStage.day),
              ],
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
    final accentColor = isDay90 ? const Color(0xFFFFFC00) : const Color(0xFF00F0FF);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF090D1A),
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
          // Grandmaster Header Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isDay90 ? '🐉' : '💎', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      isDay90 ? 'STAGE 90/90 • GRANDMASTER DRAGON' : 'STAGE ${activeStage.stageNumber}/90 • CELESTIAL',
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
              const Spacer(),
              Text(
                activeStage.fluencyTier,
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Avatar & Stats Row (Clean Split Layout)
          Row(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Friends", _friendsCount, textColor, activeStage),
                    _buildStatItem("Followers", _followersCount, textColor, activeStage),
                    _buildStatItem("Following", _followingCount, textColor, activeStage),
                    _buildAchievementsStatItem(textColor, activeStage, activeStage.day),
                  ],
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
            hideStageBadge: true, // Stage badge is already prominent in the Grandmaster Header Tag
          ),
        ],
      ),
    );
  }

  /// Helper to build interactive avatar with theme border
  Widget _buildAvatarWidget({
    required String? profileUrl,
    required Color dividerColor,
    required Color textColor,
    required LearningMilestoneStage activeStage,
    required double size,
  }) {
    Border avatarBorder;

    switch (activeStage.uiThemeVariant) {
      case ProfileUIThemeVariant.genesis:
        avatarBorder = Border.all(color: activeStage.buttonColor.withValues(alpha: 0.8), width: 2.0);
        break;
      case ProfileUIThemeVariant.silverKnight:
        avatarBorder = Border.all(color: const Color(0xFFE2E8F0), width: 2.5);
        break;
      case ProfileUIThemeVariant.goldSovereign:
        avatarBorder = Border.all(color: const Color(0xFFFFD700), width: 2.5);
        break;
      case ProfileUIThemeVariant.diamondCelestial:
        avatarBorder = Border.all(color: const Color(0xFF00F0FF), width: 3.0);
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() => _showAvatarMode = !_showAvatarMode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_showAvatarMode ? '🎨 Showing Pocket Mate Avatar' : '📷 Showing Real Profile Photo'),
            duration: const Duration(milliseconds: 700),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: avatarBorder,
              boxShadow: [
                BoxShadow(
                  color: activeStage.buttonColor.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _showAvatarMode
                  ? VectorAvatarWidget(
                      config: _getAvatarConfig(),
                      size: size,
                      borderRadius: BorderRadius.circular(20),
                      showAura: false,
                    )
                  : (profileUrl != null && profileUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: profileUrl,
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: dividerColor),
                          errorWidget: (_, __, ___) => Container(
                            color: dividerColor,
                            child: Icon(Icons.person, size: size * 0.45, color: textColor.withValues(alpha: 0.5)),
                          ),
                        )
                      : Container(
                          color: dividerColor,
                          child: Icon(Icons.person, size: size * 0.45, color: textColor.withValues(alpha: 0.5)),
                        ),
            ),
          ),
          Positioned(
            left: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final currentDay = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
                await JackieChanTalismanVaultModal.show(context, currentDay: currentDay);
                final talisman = await JackieChanTalismanService.getEquippedTalisman();
                if (mounted) setState(() => _equippedTalismanId = talisman.id);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  kJackieChanTalismans.firstWhere(
                    (t) => t.id == (_equippedTalismanId ?? 'rabbit'),
                    orElse: () => kJackieChanTalismans.first,
                  ).emoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: activeStage.buttonColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                size: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: alignment == CrossAxisAlignment.center ? WrapAlignment.center : WrapAlignment.start,
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
              if (isVerified)
                Icon(
                  Icons.verified,
                  color: activeStage.tickColor,
                  size: 18,
                ),
              if (!hideStageBadge) _buildProfileStageBadge(activeStage),
            ],
          ),
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
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bio,
              textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor,
                height: 1.4,
              ),
            ),
          ],
          if (slug != null && slug.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://handskillapp.web.app/$slug');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: btnColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: btnColor.withValues(alpha: 0.35), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language_rounded, size: 16, color: btnColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'handskillapp.web.app/$slug',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: btnColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '3D WEB',
                        style: GoogleFonts.outfit(
                          color: btnTextColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: isMe
          ? Row(
              children: [
                // Edit Profile Button
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(10),
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
                        child: Text(
                          "Edit Profile",
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Avatar Studio Button
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
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
                                  _profileData!['avatar_config'] = newCfg.toMap();
                                  _showAvatarMode = true;
                                });
                              },
                            ),
                          ),
                        ).then((_) => _loadInitialData());
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, size: 15, color: Colors.black),
                            const SizedBox(width: 6),
                            Text(
                              "Avatar Studio",
                              style: GoogleFonts.outfit(
                                color: Colors.black,
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
                const SizedBox(width: 8),

                // VIP Ad-Free Button (₹199)
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 8,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.workspace_premium_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "VIP ₹199",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Stickers Quick Button
                Container(
                  height: 38,
                  width: 42,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () => AvatarStickerPackSheet.show(context, _getAvatarConfig()),
                    borderRadius: BorderRadius.circular(10),
                    child: const Center(
                      child: Icon(Icons.auto_awesome_mosaic, size: 18, color: Color(0xFFFFFC00)),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: _isFollowing
                          ? (isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF))
                          : btnColor,
                      borderRadius: BorderRadius.circular(8),
                      border: _isFollowing
                          ? Border.all(color: textColor.withValues(alpha: 0.1))
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
                            color: _isFollowing ? textColor : btnTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!(_profileData?['is_private'] == true && !_isFollowing)) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(8),
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
                          child: Text(
                            "Message",
                            style: GoogleFonts.outfit(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildProfileStageBadge(LearningMilestoneStage stage) {
    BoxDecoration decoration;
    TextStyle style;

    switch (stage.uiThemeVariant) {
      case ProfileUIThemeVariant.genesis:
        decoration = BoxDecoration(
          color: stage.buttonColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: stage.buttonColor.withValues(alpha: 0.6), width: 1),
        );
        style = GoogleFonts.outfit(
          color: stage.buttonColor,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        );
        break;

      case ProfileUIThemeVariant.silverKnight:
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F3F46), Color(0xFF18181B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        );
        style = GoogleFonts.outfit(
          color: const Color(0xFFFAFAFA),
          fontWeight: FontWeight.w900,
          fontSize: 10,
        );
        break;

      case ProfileUIThemeVariant.goldSovereign:
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF854D0E), Color(0xFF422006)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        );
        style = GoogleFonts.outfit(
          color: const Color(0xFFFFD700),
          fontWeight: FontWeight.w900,
          fontSize: 10,
        );
        break;

      case ProfileUIThemeVariant.diamondCelestial:
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF00F0FF), width: 1.8),
        );
        style = GoogleFonts.outfit(
          color: const Color(0xFF00F0FF),
          fontWeight: FontWeight.w900,
          fontSize: 10.5,
          letterSpacing: 0.5,
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stage.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text('STAGE ${stage.stageNumber}/90', style: style),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color textColor, LearningMilestoneStage stage) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: GoogleFonts.outfit(
            color: stage.uiThemeVariant == ProfileUIThemeVariant.goldSovereign
                ? const Color(0xFFFFD700)
                : stage.uiThemeVariant == ProfileUIThemeVariant.diamondCelestial
                    ? const Color(0xFF00F0FF)
                    : textColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor.withValues(alpha: 0.6),
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
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.3)),
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
          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
        ),
        child: content,
      );
    } else if (stage.uiThemeVariant == ProfileUIThemeVariant.diamondCelestial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF080B1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.6)),
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildAchievementsStatItem(Color textColor, LearningMilestoneStage stage, int day) {
    final unlockedCount = day >= 90 ? 6 : (day >= 60 ? 5 : (day >= 30 ? 4 : (day >= 21 ? 3 : (day >= 15 ? 2 : 1))));
    final score = (_profileData?['learning_points'] as num?)?.toInt() ?? 0;

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
                '$unlockedCount/6',
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
            'Badges',
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
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.3)),
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
          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
        ),
        child: content,
      );
    } else if (stage.uiThemeVariant == ProfileUIThemeVariant.diamondCelestial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF080B1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.6)),
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
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Score: ⭐ $score XP (Active Streak Progression)',
                          style: GoogleFonts.inter(color: const Color(0xFFFFFC00), fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildAchievementRow('🌱', 'Day 1 Genesis Starter', 'Completed your first English foundation mission.', day >= 1),
              _buildAchievementRow('👑', 'Day 15 Royalty Unlock', '15 days continuous practice milestone.', day >= 15),
              _buildAchievementRow('🎯', 'Day 21 Habit Anchor Lock', '21 days permanent English habit loop formed.', day >= 21),
              _buildAchievementRow('🥈', 'Day 30 Silver Knight Shield', 'Phase 1 Speech Mechanics fully conquered.', day >= 30),
              _buildAchievementRow('🥇', 'Day 60 Gold Sovereign Crown', 'Phase 2 Real-World Fluency mastered.', day >= 60),
              _buildAchievementRow('💎', 'Day 90 Diamond Grandmaster', 'Capstone Graduation & Celestial Ring unlocked.', day >= 90),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementRow(String emoji, String title, String desc, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF161A29) : const Color(0xFF0E1018),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? const Color(0xFFFFFC00).withValues(alpha: 0.5) : Colors.white10,
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
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
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

  Widget _buildLanguageHubDashboard(Color textColor, Color btnColor, bool isDark) {
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
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
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
                  const Icon(Icons.psychology, size: 16, color: Color(0xFFFFD600)),
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

  void _fastForwardStage() {
    final currentDay = (_profileData?['learning_day'] as num?)?.toInt() ?? 1;
    final nextDay = currentDay >= 90 ? 1 : currentDay + 1;
    _jumpToDay(nextDay);
  }

  void _jumpToDay(int nextDay) {
    HapticFeedback.lightImpact();
    setState(() {
      final updated = Map<String, dynamic>.from(_profileData ?? {});
      updated['learning_day'] = nextDay;
      final stage = LearningMilestoneStage.getStageForDay(nextDay);
      _profileData = updated;
      _testStageIndex = (stage.stageNumber - 1).clamp(0, LearningMilestoneStage.allStages.length - 1);
    });

    final stage = LearningMilestoneStage.getStageForDay(nextDay);
    final avatar = VectorAvatarConfig.getEvolutionAvatarForStage(nextDay);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '⚡ DAY $nextDay/90: ${avatar.species.toUpperCase()} (${stage.fluencyTier})',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFFC00),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
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
    final accent = VectorAvatarConfig.parseHex(avatar.outfitAccentColor, fallback: baseColor);

    // 1. Check for Oceanic / Marine Leviathans (12 Species)
    const marineSpecies = {
      'abyssal_shark', 'abyssal_kraken', 'electric_ray', 'apex_orca',
      'colossal_walrus', 'swordfish', 'sea_otter', 'oceanic_narwhal',
      'ghost_jellyfish', 'reef_seahorse', 'sea_dragon', 'angler_leviathan'
    };

    // 2. Check for Felines & Savanna Predators (9 Species)
    const felineSpecies = {
      'cyber_cat', 'royal_tiger', 'golden_lion', 'shadow_leopard',
      'golden_cheetah', 'golden_jaguar', 'black_panther', 'snow_leopard', 'solar_lion'
    };

    // 3. Check for Canines & Nocturnal Hunters (9 Species)
    const canineSpecies = {
      'cyber_fox', 'shadow_wolf', 'noble_bear', 'celestial_hound',
      'mecha_wolf', 'kitsune_emperor', 'cerberus_hound', 'fennec_fox', 'spotted_hyena'
    };

    // 4. Check for Avians & Winged Sky Lords (13 Species)
    const avianSpecies = {
      'majestic_eagle', 'solar_phoenix', 'wisdom_owl', 'pegasus_stallion',
      'royal_peacock', 'peregrine_falcon', 'emperor_penguin', 'rainforest_toucan',
      'crimson_flamingo', 'golden_griffin', 'sky_thunderbird', 'thunder_roc', 'celestial_phoenix'
    };

    // 5. Check for Serpents & Reptiles (8 Species)
    const reptileSpecies = {
      'imperial_cobra', 'mystic_croc', 'tree_viper', 'komodo_titan',
      'volcanic_salamander', 'chameleon_king', 'horned_lizard', 'cyber_chameleon'
    };

    // 6. Check for Celestial Dragons & Astral Mythics (13 Species)
    const dragonCosmicSpecies = {
      'bored_ape', 'cosmic_unicorn', 'cosmic_dragon', 'shadow_manticore',
      'cyber_chimera', 'obsidian_basilisk', 'cosmic_hydra', 'chrono_dragon',
      'astral_titan', 'cosmic_dragon_sovereign'
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
      canvas.drawCircle(moonCenter, 28, Paint()..color = (stage == 90 ? const Color(0xFFFFFC00) : accent).withValues(alpha: 0.3));
      canvas.drawCircle(moonCenter, 22, Paint()..color = (stage == 90 ? const Color(0xFFFFFC00) : accent).withValues(alpha: 0.6));
      // Ring
      canvas.drawOval(
        Rect.fromCenter(center: moonCenter, width: 70, height: 16),
        Paint()..color = Colors.white.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 2.0,
      );

      // 3. Shimmering Star Field
      final starPaint = Paint()..color = Colors.white;
      for (int i = 0; i < 18; i++) {
        final sx = (size.width * (0.05 + ((i * 37) % 90) / 100));
        final sy = (size.height * (0.08 + ((i * 53) % 80) / 100));
        final sRadius = (i % 3 == 0) ? 2.5 : 1.2;
        canvas.drawCircle(Offset(sx, sy), sRadius, starPaint..color = Colors.white.withValues(alpha: 0.75));
        if (i % 4 == 0) {
          // 4-Point Star Flare
          canvas.drawLine(Offset(sx - 5, sy), Offset(sx + 5, sy), Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.0);
          canvas.drawLine(Offset(sx, sy - 5), Offset(sx, sy + 5), Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.0);
        }
      }

      // 4. Layered Jagged Astral Crystal Peaks
      final peakPaint = Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.85);
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
        ..quadraticBezierTo(size.width * 0.55, size.height * 0.60, size.width * 0.70, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.85, size.height * 0.50, size.width, size.height * 0.65)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(reefPath, Paint()..color = const Color(0xFF031926).withValues(alpha: 0.85));

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
      final tentaclePaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.4;
      for (int t = -2; t <= 2; t++) {
        final tp = Path()
          ..moveTo(jellyCenter.dx + t * 6, jellyCenter.dy)
          ..quadraticBezierTo(jellyCenter.dx + t * 8, jellyCenter.dy + 15, jellyCenter.dx + t * 4, jellyCenter.dy + 26);
        canvas.drawPath(tp, tentaclePaint);
      }

      // Rising Bubbles
      for (int i = 0; i < 8; i++) {
        final bubX = size.width * (0.50 + (i * 17 % 45) / 100);
        final bubY = size.height * (0.2 + (i * 23 % 70) / 100);
        canvas.drawCircle(Offset(bubX, bubY), (i % 3 + 1.5) * 1.5, Paint()..color = Colors.white.withValues(alpha: 0.45));
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
      canvas.drawCircle(sunCenter, 22, Paint()..color = const Color(0xFFFEF08A));

      // 2. Layered Savanna Ridges
      final savannaBack = Path()
        ..moveTo(size.width * 0.30, size.height)
        ..quadraticBezierTo(size.width * 0.60, size.height * 0.60, size.width, size.height * 0.68)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(savannaBack, Paint()..color = const Color(0xFF451A03).withValues(alpha: 0.75));

      final savannaFore = Path()
        ..moveTo(size.width * 0.45, size.height)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.72, size.width, size.height * 0.58)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(savannaFore, Paint()..color = const Color(0xFF1C0A00).withValues(alpha: 0.90));

      // 3. Acacia Tree Silhouette
      final treeX = size.width * 0.65;
      final treeBase = size.height * 0.68;
      final treePath = Path()
        ..moveTo(treeX, treeBase)
        ..lineTo(treeX - 2, treeBase - 28)
        ..lineTo(treeX + 3, treeBase - 28)
        ..close();
      canvas.drawPath(treePath, Paint()..color = const Color(0xFF1C0A00)..strokeWidth = 3);
      // Flat Acacia Canopy
      canvas.drawOval(
        Rect.fromCenter(center: Offset(treeX, treeBase - 30), width: 36, height: 10),
        Paint()..color = const Color(0xFF1C0A00),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(treeX + 10, treeBase - 34), width: 26, height: 8),
        Paint()..color = const Color(0xFF1C0A00),
      );

      // Warm Floating Embers
      for (int i = 0; i < 10; i++) {
        final ex = size.width * (0.50 + (i * 29 % 45) / 100);
        final ey = size.height * (0.15 + (i * 31 % 65) / 100);
        canvas.drawCircle(Offset(ex, ey), 1.8, Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.7));
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
        ..quadraticBezierTo(size.width * 0.65, size.height * 0.35, size.width, size.height * 0.15)
        ..lineTo(size.width, 0)
        ..close();
      canvas.drawPath(auroraPath, Paint()..shader = auroraShader);

      // 2. Glowing Full Moon with Halo
      final moonCenter = Offset(size.width * 0.82, size.height * 0.28);
      canvas.drawCircle(moonCenter, 32, Paint()..color = Colors.white.withValues(alpha: 0.18));
      canvas.drawCircle(moonCenter, 18, Paint()..color = const Color(0xFFF1F5F9));

      // 3. Layered Midnight Mountain Ridges
      final distantMtn = Path()
        ..moveTo(size.width * 0.35, size.height)
        ..lineTo(size.width * 0.58, size.height * 0.38)
        ..lineTo(size.width * 0.76, size.height * 0.58)
        ..lineTo(size.width * 0.90, size.height * 0.32)
        ..lineTo(size.width, size.height * 0.48)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(distantMtn, Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.8));

      final foreMtn = Path()
        ..moveTo(size.width * 0.48, size.height)
        ..lineTo(size.width * 0.70, size.height * 0.52)
        ..lineTo(size.width * 0.88, size.height * 0.70)
        ..lineTo(size.width, size.height * 0.56)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(foreMtn, Paint()..color = const Color(0xFF090D16).withValues(alpha: 0.95));

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
        canvas.drawLine(sunbeamCenter, Offset(sunbeamCenter.dx + math.cos(angle) * 75, sunbeamCenter.dy + math.sin(angle) * 75), rayPaint);
      }
      canvas.drawCircle(sunbeamCenter, 20, Paint()..color = const Color(0xFFFFFC00).withValues(alpha: 0.7));

      // 2. Soaring Cloud Banks
      void drawCloud(Offset c, double radius) {
        final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
        canvas.drawCircle(c, radius, cloudPaint);
        canvas.drawCircle(Offset(c.dx - radius * 0.6, c.dy + radius * 0.2), radius * 0.7, cloudPaint);
        canvas.drawCircle(Offset(c.dx + radius * 0.6, c.dy + radius * 0.2), radius * 0.7, cloudPaint);
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
        canvas.drawPath(bird, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 1.8);
      }

    } else if (reptileSpecies.contains(species)) {
      // ==========================================
      // 🐍 VOLCANIC REALM & PREHISTORIC JUNGLE
      // ==========================================
      // 1. Magma Fissure Glow
      final magmaRect = Rect.fromLTWH(size.width * 0.4, size.height * 0.5, size.width * 0.6, size.height * 0.5);
      final magmaShader = RadialGradient(
        colors: [const Color(0xFFEF4444).withValues(alpha: 0.5), Colors.transparent],
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
      canvas.drawPath(crag, Paint()..color = const Color(0xFF18181B).withValues(alpha: 0.95));

      // Magma River
      final river = Path()
        ..moveTo(size.width * 0.62, size.height * 0.48)
        ..quadraticBezierTo(size.width * 0.70, size.height * 0.72, size.width * 0.85, size.height);
      canvas.drawPath(river, Paint()..color = const Color(0xFFF97316)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    } else {
      // ==========================================
      // 🌲 ENCHANTED WOODLAND & FOREST CANOPY
      // ==========================================
      // 1. Rolling Forest Hills
      final hill1 = Path()
        ..moveTo(size.width * 0.35, size.height)
        ..quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width, size.height * 0.62)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(hill1, Paint()..color = const Color(0xFF064E3B).withValues(alpha: 0.85));

      final hill2 = Path()
        ..moveTo(size.width * 0.50, size.height)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.68, size.width, size.height * 0.52)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(hill2, Paint()..color = const Color(0xFF022C22).withValues(alpha: 0.95));

      // 2. Ancient Tree Canopies
      canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.48), 28, Paint()..color = const Color(0xFF065F46));
      canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.42), 34, Paint()..color = const Color(0xFF047857));

      // 3. Magical Floating Fireflies
      for (int i = 0; i < 9; i++) {
        final fx = size.width * (0.50 + (i * 23 % 45) / 100);
        final fy = size.height * (0.20 + (i * 37 % 60) / 100);
        canvas.drawCircle(Offset(fx, fy), 2.2, Paint()..color = const Color(0xFF6EE7B7));
        canvas.drawCircle(Offset(fx, fy), 5.0, Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.25));
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
                borderRadius: BorderRadius.circular(20),
                color: textColor.withValues(alpha: 0.04),
                border: Border.all(
                    color: textColor.withValues(alpha: 0.08), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: btnColor.withValues(alpha: 0.05),
                    blurRadius: 15,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                        child: imageUrl != null && imageUrl.toString().isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                memCacheWidth: 400,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 160,
                                  color: textColor.withValues(alpha: 0.03),
                                  child: Center(
                                    child: material.SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: material.CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: material
                                            .AlwaysStoppedAnimation<Color>(
                                                btnColor.withValues(alpha: 0.5)),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 160,
                                  color: textColor.withValues(alpha: 0.05),
                                  child: Icon(material.Icons.grid_view_rounded,
                                      color: textColor.withValues(alpha: 0.3), size: 40),
                                ),
                              )
                            : Container(
                                height: 160,
                                color: textColor.withValues(alpha: 0.05)),
                      ),
                      if (price != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  material.Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: material.Colors.white
                                      .withValues(alpha: 0.15)),
                            ),
                            child: Text(
                              '₹$price',
                              style: GoogleFonts.outfit(
                                color: material.Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (title != null && title.toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 12.0, bottom: 4.0),
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 0, 14.0, 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isService 
                            ? btnColor.withValues(alpha: 0.12)
                            : textColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isService ? material.Icons.handyman_outlined : material.Icons.shopping_bag_outlined,
                            size: 10,
                            color: isService ? btnColor : textColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isService ? 'Service' : 'Product',
                            style: GoogleFonts.outfit(
                              color: isService ? btnColor : textColor.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
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
                size: 48, color: textColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text("No thoughts shared yet",
                style: TextStyle(color: textColor.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final thread = items[idx];
        final content = thread['content'] ?? '';
        final createdAt = thread['created_at'];
        final timeStr =
            createdAt != null ? timeago.format(DateTime.parse(createdAt)) : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: btnColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(material.Icons.person, color: btnColor, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    timeStr,
                    style: GoogleFonts.inter(
                      color: textColor.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  material.IconButton(
                    icon: Icon(material.Icons.more_vert,
                        size: 16, color: textColor.withValues(alpha: 0.3)),
                    onPressed: () {},
                    padding: material.EdgeInsets.zero,
                    constraints: const material.BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                content,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 16,
                  height: 1.6,
                  letterSpacing: -0.2,
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
