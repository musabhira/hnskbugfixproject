import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '/backend/supabase/supabase.dart';

class MainProfileWidget extends StatefulWidget {
  final String? userId; // Optional if preloaded
  final double? width;
  final double? height;

  // Preloaded data support
  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const MainProfileWidget({
    Key? key,
    this.userId, // Made optional
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

  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];

  // Follow system
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;

  // Block system
  bool _isBlocked = false;

  // Design constants
  final double _headerHeight = 280.0;
  final double _profileImageSize = 100.0;

  String get userId {
    if (widget.userId != null) return widget.userId!;
    if (_profileData != null && _profileData!['user_id'] != null)
      return _profileData!['user_id'].toString();
    return _supabase.auth.currentUser?.id ?? '';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize data from props if available
    if (widget.preloadedProfile != null) {
      _profileData = widget.preloadedProfile;
      _isLoading = false; // Show content immediately

      // Parse counts if they are strings (simplistic)
      if (widget.followersCount != null) {
        final clean = widget.followersCount!.replaceAll(RegExp(r'[^0-9]'), '');
        _followersCount = int.tryParse(clean) ?? 0;
      }
      if (widget.followingCount != null) {
        final clean = widget.followingCount!.replaceAll(RegExp(r'[^0-9]'), '');
        _followingCount = int.tryParse(clean) ?? 0;
      }
    }

    // Trigger fetch to ensure freshness or get data if not preloaded
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future.wait([
      _fetchProfileData(),
      _fetchFollowCounts(),
      _checkFollowStatus(),
      _checkBlockStatus(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      // Fetch profile
      final profileResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select()
          .eq('user_id', userId)
          .limit(1);

      if (profileResponse.isNotEmpty) {
        _profileData = profileResponse.first;
      }

      // Fetch Gallery
      final galleryResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select()
          .eq('user_id', userId)
          .not('gallery_id', 'is', null)
          .order('gallery_created_at', ascending: false);

      // Deduplicate gallery items
      final Map<String, Map<String, dynamic>> uniqueGallery = {};
      for (var item in galleryResponse) {
        if (item['gallery_id'] != null) {
          uniqueGallery[item['gallery_id'].toString()] = item;
        }
      }
      _galleryItems = uniqueGallery.values.toList();

      // Fetch Services
      final serviceResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select()
          .eq('user_id', userId)
          .not('service_id', 'is', null)
          .order('service_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueServices = {};
      for (var item in serviceResponse) {
        if (item['service_id'] != null) {
          uniqueServices[item['service_id'].toString()] = item;
        }
      }
      _serviceItems = uniqueServices.values.toList();
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> _fetchFollowCounts() async {
    try {
      final followers = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', userId);

      final following = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', userId);

      // Also get base followers from users table if any
      final userRow = await _supabase
          .from('users')
          .select('followers')
          .eq('id', userId)
          .maybeSingle();

      int baseFollowers = 0;
      if (userRow != null && userRow['followers'] != null) {
        baseFollowers = (userRow['followers'] as num).toInt();
      }

      if (mounted) {
        setState(() {
          _followersCount = followers.length + baseFollowers;
          _followingCount = following.length;
        });
      }
    } catch (e) {
      debugPrint('Follow count error: $e');
    }
  }

  Future<void> _checkFollowStatus() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final res = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', myId)
          .eq('followed_id', userId);
      if (mounted) setState(() => _isFollowing = res.isNotEmpty);
    } catch (e) {
      debugPrint('Check follow error: $e');
    }
  }

  Future<void> _checkBlockStatus() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final blockedByMe = await _supabase
          .from('blocks')
          .select()
          .eq('blocker_id', myId)
          .eq('blocked_id', userId)
          .limit(1);

      if (mounted && blockedByMe.isNotEmpty) {
        setState(() => _isBlocked = true);
      }
    } catch (e) {
      debugPrint('Check block error: $e');
    }
  }

  Future<void> _toggleFollow() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login required")));
      return;
    }

    try {
      if (_isFollowing) {
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', myId)
            .eq('followed_id', userId);
        setState(() {
          _isFollowing = false;
          _followersCount--;
        });
      } else {
        await _supabase
            .from('follows')
            .insert({'follower_id': myId, 'followed_id': widget.userId});
        setState(() {
          _isFollowing = true;
          _followersCount++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildShimmerLoading();
    if (_profileData == null)
      return const Center(child: Text("User not found"));

    // Check if blocked
    if (_isBlocked)
      return const Center(child: Text("You have blocked this user"));

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (ctx, innerBoxScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _headerHeight,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderContent(),
                collapseMode: CollapseMode.parallax,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // Simple share
                    Share.share(
                        'Check out ${_profileData?['name']}\'s profile!');
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    // Implement report/block logic if needed
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'report', child: Text('Report')),
                    const PopupMenuItem(value: 'block', child: Text('Block')),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildProfileInfo(),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: "Gallery"),
                    Tab(text: "Services"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _OptimizationWrapper(
              child: _GalleryTab(items: _galleryItems),
            ),
            _OptimizationWrapper(
              child: _ServicesTab(items: _serviceItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    final bannerUrl = _profileData?['banner_image_url'];
    final profileUrl = _profileData?['profile_image_url'];

    return Stack(
      children: [
        // Banner Image
        Positioned.fill(
          bottom: 40,
          child: bannerUrl != null && bannerUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: bannerUrl,
                  fit: BoxFit.cover,
                  memCacheHeight: 600, // Optimize memory usage
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[300]),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
        ),
        // Gradient overlay for better text visibility (optional)
        Positioned.fill(
          bottom: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3)
                ],
              ),
            ),
          ),
        ),
        // Rounded corners at bottom of banner area
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          height: 30,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        ),
        // Profile Image
        Positioned(
          bottom: 0,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: _profileImageSize / 2,
              backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                  ? CachedNetworkImageProvider(profileUrl,
                      maxHeight: 200) // Optimize
                  : null,
              backgroundColor: Colors.grey[200],
              child: (profileUrl == null || profileUrl.isEmpty)
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    final name = _profileData?['name'] ?? 'User';
    final bio = _profileData?['bio'] ?? '';
    final isVerified = _profileData?['verified'] == true;
    final city = _profileData?['city'];
    final state = _profileData?['state'];
    final location = (city != null && state != null)
        ? "$city, $state"
        : (city ?? state ?? "");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.verified,
                                color: Colors.blue, size: 22),
                          ),
                      ],
                    ),
                    if (location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              _buildActionsRow(),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildStatItem("Followers", _followersCount),
              const SizedBox(width: 24),
              _buildStatItem("Following", _followingCount),
              const SizedBox(width: 24),
              _buildStatItem("Posts", _galleryItems.length),
            ],
          ),
          const SizedBox(height: 16),
          if (bio.isNotEmpty) ...[
            Text(
              bio,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: Colors.black87),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    final isMe = userId == _supabase.auth.currentUser?.id;
    if (isMe) {
      return OutlinedButton(
        onPressed: () {
          // Edit profile or settings
        },
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: Colors.grey),
        ),
        child: const Text("Is Me", style: TextStyle(color: Colors.black)),
      );
    }

    return Row(
      children: [
        // Follow Button
        ElevatedButton(
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? Colors.grey[200] : Colors.black,
            foregroundColor: _isFollowing ? Colors.black : Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          ),
          child: Text(_isFollowing ? "Following" : "Follow"),
        ),
        const SizedBox(width: 8),
        // Message Button (Icon only to save space)
        InkWell(
          onTap: () {
            // Basic message action placeholder
            final phone = _profileData?['phone_no'];
            if (phone != null) {
              // _sendWhatsApp(phone);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
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

  // --- Shimmer Loading ---
  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Profile Image
            Stack(
              clipBehavior: Clip.none,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 200, color: Colors.white),
                ),
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child:
                        Container(height: 24, width: 200, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                        3,
                        (index) => Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                    height: 40, width: 60, color: Colors.white),
                              ),
                            )),
                  ),
                  const SizedBox(height: 24),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        Container(
                            height: 12,
                            width: double.infinity,
                            color: Colors.white),
                        const SizedBox(height: 8),
                        Container(
                            height: 12,
                            width: double.infinity,
                            color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 150, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Grid Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(
                          2,
                          (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                ),
                              )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: List.generate(
                          2,
                          (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                      height: 240,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                ),
                              )),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// --- Optimization Wrappers & Child Widgets ---

class _OptimizationWrapper extends StatefulWidget {
  final Widget child;
  const _OptimizationWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<_OptimizationWrapper> createState() => _OptimizationWrapperState();
}

class _OptimizationWrapperState extends State<_OptimizationWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _GalleryTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _GalleryTab({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text("No posts yet", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Using MasonryGridView inside NestedScrollView requires careful physics
    // But since it's a tab view, we should technically use CustomScrollView with Sliver types
    // However, the simple fix for MasonryGridView inside NestedScrollView is ClampingScrollPhysics.
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const ClampingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _GalleryItem(item: items[index]);
      },
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _GalleryItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['gallery_image_url'] ?? item['image_url'];
    final title = item['gallery_title'] ?? item['title'];

    return GestureDetector(
      onTap: () {
        // Show details
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400, // Memory optimization for thumbnails
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error)),
              )
            else
              Container(height: 150, color: Colors.grey[300]),
            if (title != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _ServicesTab({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
          child:
              Text("No services listed", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(), // Matches parent
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        return _ServiceItem(service: items[idx]);
      },
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final Map<String, dynamic> service;
  const _ServiceItem({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.work_outline, color: Colors.blueAccent),
        ),
        title: Text(service['service_title'] ?? 'Service',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          service['service_description'] ?? 'No description',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: service['service_price'] != null
            ? Text('\$${service['service_price']}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green))
            : null,
      ),
    );
  }
}
