import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

class MainProfileWidget extends StatefulWidget {
  final String? userId;
  final double? width;
  final double? height;

  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const MainProfileWidget({
    Key? key,
    this.userId,
    this.width,
    this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  }) : super(key: key);

  @override
  _MainProfileWidgetState createState() => _MainProfileWidgetState();
}

class _MainProfileWidgetState extends State<MainProfileWidget>
    with TickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Data State
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];

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

  final double _profileImageSize = 90.0;

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
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData(); // Instant load strategy
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
    // Apply Colors
    _bgColor = _parseColor(data['bg_color_code']);
    _textColor = _parseColor(data['bg_text_color']);
    _btnColor = _parseColor(data['button_color_code']);
    _btnTextColor = _parseColor(data['button_text_color']);
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
        _fetchFollowCountsInt(), // Counts
        _checkFollowStatusBool(),
        _checkBlockStatusBool(),
      ]);

      if (!mounted) return;

      final profileRes = responses[0] as List;
      final galleryRes = responses[1] as List;

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
      for (var item in galleryRes) {
        if (item['gallery_id'] != null) {
          uniqueGallery[item['gallery_id'].toString()] = item;
        }
      }

      setState(() {
        _galleryItems = uniqueGallery.values.toList();
        _followersCount = responses[2] as int; // Follower count
        // _followingCount handle separately or in same query if precise
        _isFollowing = responses[3] as bool;
        _isBlocked = responses[4] as bool;
      });

      // Lazy load full lists in background
      _fetchFullLists();
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

  Future<int> _fetchFollowCountsInt() async {
    try {
      final res = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', userId);
      // Get base followers
      final userRow = await _supabase
          .from('profile')
          .select('followers')
          .eq('user_id', userId)
          .maybeSingle();

      int base = 0;
      if (userRow != null && userRow['followers'] != null) {
        base = (userRow['followers'] as num).toInt();
      }

      return res.length + base;
    } catch (_) {
      return 0;
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
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
        body: const Center(child: Text("You have blocked this user.")),
      );
    }

    // Defaults
    final bgColor = _bgColor ?? const Color(0xFF000000);
    final textColor = _textColor ?? const Color(0xFFFFFFFF);
    final btnColor = _btnColor ?? const Color(0xFFFFD700);
    final btnTextColor = _btnTextColor ?? const Color(0xFF000000);

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: 0,
              backgroundColor: bgColor,
              expandedHeight: 200, // Reduced from 280 for better UX
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textColor, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: innerBoxIsScrolled
                  ? Text(
                      _profileData?['shop_name'] ?? _profileData?['name'] ?? '',
                      style: GoogleFonts.outfit(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
              centerTitle: true,
              actions: [
                if (isMe)
                  IconButton(
                    icon: Icon(Icons.grid_view_rounded, color: textColor),
                    tooltip: 'Dashbaord',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerfiedSwitchPage(
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.share, color: textColor, size: 22),
                  onPressed: () => Share.share(
                      'Check out ${_profileData?['name']}\'s profile on PocketMates!'),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: textColor),
                  color: Colors.grey[900],
                  onSelected: (val) {
                    if (val == 'block') {
                      // Block logic
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'report',
                        child: Text('Report',
                            style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(
                        value: 'block',
                        child: Text('Block',
                            style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildBanner(),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildProfileHeader(textColor, btnColor, btnTextColor),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: textColor,
                  unselectedLabelColor: textColor.withOpacity(0.5),
                  indicatorColor: btnColor,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "Gallery"),
                    Tab(text: "Services"),
                  ],
                ),
                bgColor,
              ),
            ),
          ];
        },
        body: Container(
          color: bgColor,
          child: TabBarView(
            controller: _tabController,
            children: [
              _GalleryTab(items: _galleryItems, textColor: textColor),
              _ServicesTab(items: _serviceItems, textColor: textColor),
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
            colors: [Colors.grey[900]!, Colors.black],
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
      placeholder: (context, url) => Container(color: Colors.grey[900]),
    );
  }

  Widget _buildProfileHeader(
      Color textColor, Color btnColor, Color btnTextColor) {
    if (_isLoading && _profileData == null) {
      return _buildShimmerHeader();
    }

    final name = _profileData?['name'] ?? 'User';
    final shopName = _profileData?['shop_name'];
    final bio = _profileData?['bio'] ?? '';
    final profileUrl = _profileData?['profile_image_url'];
    final isVerified = _profileData?['verified'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Image + Stats
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: btnColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: _profileImageSize / 2,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(profileUrl)
                      : null,
                  child: (profileUrl == null || profileUrl.isEmpty)
                      ? Icon(Icons.person,
                          size: 40, color: Colors.white.withOpacity(0.5))
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Followers", _followersCount, textColor),
                    _buildStatItem("Following", _followingCount, textColor),
                    _buildStatItem("Posts", _galleryItems.length, textColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name & Bio
          Text(
            shopName != null && shopName.isNotEmpty ? shopName : name,
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Verified Account",
                  style: GoogleFonts.inter(
                      color: textColor.withOpacity(0.7), fontSize: 12),
                ),
              ],
            )
          ],
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bio,
              style: GoogleFonts.inter(
                color: textColor.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 20),
          // Action Buttons
          if (!isMe)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFollowing ? Colors.grey[800] : btnColor,
                      foregroundColor:
                          _isFollowing ? Colors.white : btnTextColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isFollowing ? "Unfollow" : "Follow",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Message Logic
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: textColor.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Message",
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color textColor) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Widget _buildShimmerHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 45),
                const SizedBox(width: 20),
                Expanded(
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)))),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 20, width: 150, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
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
  final List<Map<String, dynamic>> items;
  final Color textColor;
  const _GalleryTab({Key? key, required this.items, required this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_off, size: 48, color: textColor.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text("No posts yet",
                style: TextStyle(color: textColor.withOpacity(0.5))),
          ],
        ),
      );
    }
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = item['gallery_image_url'] ?? item['image_url'];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  memCacheWidth: 400,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[900],
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Container(height: 200, color: Colors.grey[900]),
        );
      },
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Color textColor;
  const _ServicesTab({Key? key, required this.items, required this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text("No services listed",
            style: TextStyle(color: textColor.withOpacity(0.5))),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final service = items[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work_outline, color: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['service_name'] ?? 'Service',
                      style: GoogleFonts.outfit(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    if (service['price'] != null)
                      Text(
                        '\$${service['price']}',
                        style: GoogleFonts.inter(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold),
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
}
