import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart' hide Colors, IconButton, Tooltip;
import 'package:flutter/material.dart' as material;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_custom_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import 'index.dart';

import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/posters_tab.dart';
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
  _MainProfileWidgetState createState() => _MainProfileWidgetState();
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
  List<Map<String, dynamic>> _serviceItems = [];
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

  @override
  void initState() {
    // Initialize controller with correct length if preloaded
    final initialLength = (widget.preloadedProfile?['verified'] == true) ? 4 : 3;
    _tabController = material.TabController(length: initialLength, vsync: this);
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
    final newLength = isVerified ? 4 : 3;
    if (_tabController.length != newLength) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = material.TabController(
        length: newLength,
        vsync: this,
        initialIndex: oldIndex < newLength ? oldIndex : 0,
      );
    }
  }

  Future<void> _fetchFreshData() async {
    try {
      if (mounted && _profileData == null) setState(() => _isLoading = true);

      final responses = await Future.wait<dynamic>([
        _supabase
            .from('profile_gallery_service_likes_comments_view')
            .select()
            .eq('user_id', userId)
            .limit(1), // Profile
        _supabase
            .from('profile_gallery_service_likes_comments_view')
            .select()
            .eq('user_id', userId)
            .not('gallery_id', 'is', null)
            .order('gallery_created_at', ascending: false)
            .limit(20), // Recent Gallery (Limit for perf)
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
      Set<String> categorySet = {'All'};

      for (var item in galleryRes) {
        if (item['gallery_id'] != null) {
          uniqueGallery[item['gallery_id'].toString()] = item;
          if (item['gallery_category'] != null &&
              item['gallery_category'].toString().trim().isNotEmpty) {
            categorySet.add(item['gallery_category'].toString().trim());
          }
        }
      }

      setState(() {
        _galleryItems = uniqueGallery.values.toList();
        _categories = categorySet.toList();
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
    // Fetch remaining gallery and services
    try {
      final serviceRes = await _supabase
          .from('services') // Query services table directly for better perf
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _serviceItems = List<Map<String, dynamic>>.from(serviceRes);
        });
      }
    } catch (e) {
      debugPrint('Error fetching full lists: $e');
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
          return item['gallery_category']?.toString().trim() == category;
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

    // Defaults based on Theme if not customized
    final bgColor = _bgColor ?? FlutterFlowTheme.of(context).primaryBackground;
    final textColor = _textColor ?? FlutterFlowTheme.of(context).primaryText;
    final btnColor = _btnColor ?? FlutterFlowTheme.of(context).primary;
    final btnTextColor = _btnTextColor ?? FlutterFlowTheme.of(context).info;

    return material.Scaffold(
      backgroundColor: bgColor,
      body: material.NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            material.SliverAppBar(
              elevation: 0,
              expandedHeight: 220,
              pinned: true,
              backgroundColor:
                  innerBoxIsScrolled ? bgColor : material.Colors.transparent,
              leading: material.IconButton(
                icon: Icon(FluentIcons.back,
                    color: textColor, size: 22),
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
                    icon: Icon(FluentIcons.view_dashboard,
                        color: textColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        material.MaterialPageRoute(
                          builder: (context) => VerfiedSwitchPage(
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  material.IconButton(
                    icon: Icon(FluentIcons.contact_list,
                        color: textColor, size: 22),
                    onPressed: () => AutoLoginBottomSheet.show(context),
                    tooltip: 'Switch Account',
                  ),
                ],
                material.IconButton(
                  icon: Icon(FluentIcons.share,
                      color: textColor, size: 22),
                  onPressed: () => Share.share(
                      'Check out ${_profileData?['name']}\'s profile on Handskill Friends!'),
                ),
                material.Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropDownButton(
                    leading: Icon(FluentIcons.more,
                        color: textColor),
                    items: [
                      MenuFlyoutItem(
                        text: const Text('Report'),
                        onPressed: () {
                          // Report logic
                        },
                      ),
                      MenuFlyoutItem(
                        text: const Text('Block',
                            style: TextStyle(color: material.Colors.red)),
                        onPressed: () {
                          // Block logic
                        },
                      ),
                    ],
                  ),
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
                    const material.Tab(text: "Services"),
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
              // Category Selector
              if (_categories.length > 1)
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
                        child: Button(
                          onPressed: () => _filterGalleryByCategory(cat),
                          style: ButtonStyle(
                            backgroundColor: ButtonState.all(
                              isSelected
                                  ? btnColor
                                  : material.Colors.transparent,
                            ),
                            shape: ButtonState.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? btnColor
                                    : textColor.withValues(alpha: 0.2),
                              ),
                            )),
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
                    _ServicesTab(
                      items: _serviceItems,
                      textColor: textColor,
                      btnColor: btnColor,
                      btnTextColor: btnTextColor,
                      userId: userId,
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
      fit: BoxFit.cover,
      width: double.infinity,
      memCacheHeight: 600,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Image + Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: btnColor, width: 3.0),
                  boxShadow: [
                    BoxShadow(
                        color: btnColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2C2C2E),
                  backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(profileUrl)
                      : null,
                  child: (profileUrl == null || profileUrl.isNotEmpty == false)
                      ? Icon(FluentIcons.contact,
                          size: 45,
                          color: material.Colors.white.withValues(alpha: 0.5))
                      : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: material.Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: textColor.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("Followers", _followersCount, textColor),
                      _buildStatItem("Following", _followingCount, textColor),
                      _buildStatItem("Posts", _galleryItems.length, textColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Name Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  shopName != null && shopName.isNotEmpty ? shopName : name,
                  style: GoogleFonts.outfit(
                    color: textColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0078D4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF0078D4).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.verified_brand,
                          color: Color(0xFF0078D4), size: 16),
                      const SizedBox(width: 6),
                      Text("Verified",
                          style: GoogleFonts.inter(
                              color: const Color(0xFF0078D4),
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            material.Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: textColor.withValues(alpha: 0.08)),
              ),
              child: Text(
                bio,
                style: GoogleFonts.inter(
                  color: textColor.withValues(alpha: 0.85),
                  fontSize: 15,
                  height: 1.6,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (isVerified && slug != null && slug.toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://handskillapp.web.app/$slug');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: btnColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: btnColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.globe, color: btnColor, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      "handskillapp.web.app/$slug",
                      style: GoogleFonts.inter(
                        color: btnColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Action Buttons
          if (!isMe)
            Row(
              children: [
                Expanded(
                  child: material.Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: !_isFollowing
                          ? LinearGradient(
                              colors: [
                                btnColor,
                                btnColor.withValues(alpha: 0.8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _isFollowing
                          ? textColor.withValues(alpha: 0.05)
                          : null,
                      border: _isFollowing
                          ? Border.all(
                              color: textColor.withValues(alpha: 0.15),
                              width: 1.5)
                          : null,
                      boxShadow: _isFollowing
                          ? null
                          : [
                              BoxShadow(
                                color: btnColor.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                    ),
                    child: material.InkWell(
                      onTap: _toggleFollow,
                      borderRadius: BorderRadius.circular(20),
                      child: material.Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          _isFollowing ? "Following" : "Follow",
                          style: GoogleFonts.outfit(
                            color: _isFollowing ? textColor : btnTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: material.Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: textColor.withValues(alpha: 0.06),
                      border: Border.all(
                          color: textColor.withValues(alpha: 0.1), width: 1.5),
                    ),
                    child: material.InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          material.MaterialPageRoute(
                            builder: (context) => WhatsAppGroupChat(
                              groupId: 'p:$userId',
                              groupName: name,
                              groupImage: profileUrl,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: material.Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          "Message",
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (isMe)
            material.Padding(
              padding: const EdgeInsets.only(top: 8),
              child: material.Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [btnColor, btnColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: btnColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: material.InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      material.MaterialPageRoute(
                        builder: (context) => ProfileCustomWidget(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                    ).then((_) => _loadInitialData());
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: material.Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        material.Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                material.Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(FluentIcons.edit,
                              color: material.Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Edit Profile",
                          style: GoogleFonts.outfit(
                            color: material.Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_profileData != null &&
              _profileData!['phone_no'] != null &&
              _profileData!['phone_no'].toString().isNotEmpty) ...[
            const SizedBox(height: 20),
            material.Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.phone,
                      color: textColor.withValues(alpha: 0.6), size: 16),
                  const SizedBox(width: 12),
                  Text(
                    _profileData!['phone_no'],
                    style: GoogleFonts.inter(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color textColor) {
    return material.Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: textColor.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
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

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.grid_view_medium,
                size: 48, color: textColor.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text("No posts found",
                style: TextStyle(color: textColor.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = item['gallery_image_url'] ?? item['image_url'];
        final title = item['gallery_title'] ?? item['title'];
        final price = item['gallery_price'] ?? item['price'];

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
                                child: Icon(FluentIcons.error,
                                    color: textColor.withValues(alpha: 0.3)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 12.0),
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Color textColor;
  final Color btnColor;
  final Color btnTextColor;
  final String userId;

  const _ServicesTab({
    required this.items,
    required this.textColor,
    required this.btnColor,
    required this.btnTextColor,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.toolbox,
                size: 48, color: textColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text("No services listed",
                style: TextStyle(color: textColor.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final service = items[idx];
        final title =
            service['service_title'] ?? service['service_name'] ?? 'Service';
        final price = service['service_price'] ?? service['price'];
        final desc = service['service_description'] ?? service['description'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: textColor.withValues(alpha: 0.08), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: material.Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: btnColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: btnColor.withValues(alpha: 0.2)),
                    ),
                    child: Icon(FluentIcons.toolbox, color: btnColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (desc != null && desc.toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              desc,
                              style: GoogleFonts.inter(
                                color: textColor.withValues(alpha: 0.7),
                                fontSize: 13,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (price != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting from',
                          style: GoogleFonts.inter(
                            color: textColor.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹$price',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF00CC6A),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  material.ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        material.MaterialPageRoute(
                          builder: (context) => WhatsAppGroupChat(
                            groupId: 'p:$userId',
                            groupName: title,
                          ),
                        ),
                      );
                    },
                    style: material.ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: btnTextColor,
                      elevation: 4,
                      shadowColor: btnColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: Text(
                      "Enquire",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
            Icon(FluentIcons.chat,
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
                    child: Icon(FluentIcons.contact, color: btnColor, size: 14),
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
                    icon: Icon(FluentIcons.more,
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
                    FluentIcons.heart,
                    ((thread['like_count'] ?? 0) + (thread['fake_likes'] ?? 0))
                        .toString(),
                    btnColor,
                  ),
                  const SizedBox(width: 24),
                  _buildThreadStat(
                    FluentIcons.comment,
                    (thread['comment_count'] ?? 0).toString(),
                    textColor.withValues(alpha: 0.5),
                  ),
                  const Spacer(),
                  Icon(FluentIcons.share,
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
