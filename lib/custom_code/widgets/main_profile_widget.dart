import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
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
import 'package:pocket_mates_app/custom_code/widgets/business_pos_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

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
  late material.TabController _tabController;
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
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isBlocked = false;
  bool _isExpanded = false;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  List<Map<String, dynamic>> _filteredGalleryItems = [];

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
    // Initialize controller with correct length if preloaded
    final initialLength = (widget.preloadedProfile?['verified'] == true) ? 3 : 2;
    _tabController = material.TabController(length: initialLength, vsync: this);
    _tabController.addListener(() { if (mounted) setState(() {}); });
    _loadInitialData(); // Instant load strategy
    _fetchThreads();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
  }

  void _applyProfileData(Map<String, dynamic> data) {
    _profileData = data;
    _bgColor = _parseColor(data['bg_color_code']);
    _textColor = _parseColor(data['bg_text_color']);
    _btnColor = _parseColor(data['button_color_code']);
    _btnTextColor = _parseColor(data['button_text_color']);

    // Sync TabController
    final isVerified = data['verified'] == true;
    final newLength = isVerified ? 3 : 2;
    if (_tabController.length != newLength) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = material.TabController(
        length: newLength,
        vsync: this,
        initialIndex: oldIndex < newLength ? oldIndex : 0,
      );
      _tabController.addListener(() { if (mounted) setState(() {}); });
    }
  }

  Future<void> _fetchFreshData() async {
    try {
      if (mounted && _profileData == null) setState(() => _isLoading = true);

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
      ]);

      if (!mounted) return;

      final profileRes = responses[0] as List;
      final galleryRes = responses[1] as List;
      final counts = responses[2] as Map<String, int>;

      if (profileRes.isNotEmpty) {
        final data = profileRes.first as Map<String, dynamic>;
        setState(() {
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
        _isFollowing = responses[3] as bool;
        _isBlocked = responses[4] as bool;
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
          .select('id')
          .eq('followed_id', userId);

      // Get following count - people this user follows
      final followingRes = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', userId);

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
        'followers': followersRes.length + baseFollowers,
        'following': followingRes.length,
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
    if ((rawBtnColor.value & 0xFFFFFF) == (rawBtnTextColor.value & 0xFFFFFF) ||
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
              expandedHeight: MediaQuery.of(context).size.width / 2.0,
              pinned: true,
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
                ],
                material.IconButton(
                  icon: const Icon(material.Icons.share, size: 22),
                  color: textColor,
                  onPressed: () => SharePlus.instance.share(
                      ShareParams(text: 'Check out ${_profileData?['name']}\'s profile on Handskill Friends!')),
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
            material.SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                material.TabBar(
                  controller: _tabController,
                  labelColor: textColor,
                  unselectedLabelColor: textColor.withValues(alpha: 0.5),
                  indicatorColor: btnColor,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  tabs: [
                    const material.Tab(text: "Gallery"),
                    const material.Tab(text: "Thoughts"),
                    if (_profileData?['verified'] == true)
                      const material.Tab(text: "Posters"),
                  ],
                ),
                bgColor,
              ),
            ),
          ];
        },
        body: Container(
          color: bgColor,
          child: Column(
            children: [
              // Category Selector — only shown on Gallery tab (index 0)
              if (_categories.length > 1 && _tabController.index == 0)
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
                  controller: _tabController,
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
                    if (_profileData?['verified'] == true)
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

  Widget _buildBanner() {
    final bannerUrl = _profileData?['banner_image_url'];
    if (bannerUrl == null || bannerUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _btnColor?.withValues(alpha: 0.15) ?? const Color(0xFF2B2B2B),
              _bgColor ?? const Color(0xFF131314)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: bannerUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
      width: double.infinity,
      placeholder: (context, url) => Container(color: const Color(0xFF1A1A1A)),
    );
  }

  Widget _buildProfileHeader(
      Color textColor, Color btnColor, Color btnTextColor, bool isMe) {
    if (_isLoading && _profileData == null) {
      return _buildShimmerHeader();
    }

    final name = _profileData?['name'] ?? 'User';
    final shopName = _profileData?['shop_name'];
    final bio = _profileData?['bio'] ?? '';
    final profileUrl = _profileData?['profile_image_url'];
    final isVerified = _profileData?['verified'] == true;
    final slug = _profileData?['slug'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? const Color(0xFFA8A8A8) : const Color(0xFF8E8E8E);
    final dividerColor = isDark ? const Color(0xFF262626) : const Color(0xFFDBDBDB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar and Stats Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: btnColor.withOpacity(0.3),
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: dividerColor,
                  backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(profileUrl)
                      : null,
                  child: (profileUrl == null || profileUrl.isEmpty)
                      ? Icon(Icons.person, size: 40, color: textColor.withOpacity(0.5))
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Followers", _followersCount, textColor),
                    _buildStatItem("Gallery", _galleryItems.length, textColor),
                    _buildStatItem("Thoughts", _threadItems.length, textColor),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Name, Bio, and Website Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    const Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Icon(
                        Icons.verified,
                        color: Color(0xFF0095F6),
                        size: 18,
                      ),
                    ),
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
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
              if (isVerified && slug != null && slug.toString().isNotEmpty) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse('https://handskillapp.web.app/$slug');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 18, color: btnColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'handskillapp.web.app/$slug',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: btnColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Actions Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isMe
              ? Row(
                  children: [
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
                                builder: (context) => ProfileCustomWidget(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                ),
                              ),
                            ).then((_) => _loadInitialData());
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Text(
                              "Edit Profile",
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
                              ? Border.all(color: textColor.withOpacity(0.1))
                              : null,
                        ),
                        child: InkWell(
                          onTap: _toggleFollow,
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Text(
                              _isFollowing ? "Following" : "Follow",
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
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    return oldDelegate.bgColor != bgColor;
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
                            ? btnColor.withOpacity(0.12)
                            : textColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isService ? material.Icons.handyman_outlined : material.Icons.shopping_bag_outlined,
                            size: 10,
                            color: isService ? btnColor : textColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isService ? 'Service' : 'Product',
                            style: GoogleFonts.outfit(
                              color: isService ? btnColor : textColor.withOpacity(0.7),
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
