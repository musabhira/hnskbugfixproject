// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/custom_buttom.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_custom_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainProfileWidget extends StatefulWidget {
  final double width;
  final double height;
  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const MainProfileWidget({
    super.key,
    required this.width,
    required this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  });

  @override
  State<MainProfileWidget> createState() => _MainProfileWidgetState();
}

class _MainProfileWidgetState extends State<MainProfileWidget>
    with TickerProviderStateMixin {
  late TabController _tabBarController;
  final ScrollController _scrollController = ScrollController();
  final _supabase = SupaFlow.client;

  // Profile data
  String? _currentUserId;
  String? profileId;
  String? _imageUrl;
  String? _imageUrlBanner;
  bool isPremium = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _BioController = TextEditingController();

  // Aesthetics
  String? _colorCode;
  String? _colorCode1;
  String? _colorCode2;
  String? _colorCode3;

  // Premium Fallback Colors
  static const Color primaryColor = Colors.yellow;
  static const Color secondaryColor = Colors.yellow;
  static const Color accentColor = Colors.yellow;
  static const Color backgroundColor = Colors.black;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Stats
  String _followersCountFormatted = '0';
  String _followingCountFormatted = '0';

  // Threads, Services, Gallery
  List<Map<String, dynamic>> userThreads = [];
  List<Map<String, dynamic>> userServices = [];
  List<Map<String, dynamic>> userGallery = [];
  bool isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 3, vsync: this);

    if (widget.preloadedProfile != null) {
      _applyPreloadedData();
      _getCurrentUser(refresh: false);
    } else {
      _getCurrentUser();
    }
  }

  void _applyPreloadedData() {
    final profile = widget.preloadedProfile!;
    profileId = profile['id']?.toString();
    _nameController.text = profile['name'] ?? '';
    _imageUrl = profile['profile_image_url'];
    _BioController.text = profile['bio'] ?? '';
    _imageUrlBanner = profile['banner_image_url'];
    isPremium = profile['verified'] ?? false;
    _colorCode = profile['bg_color_code'];
    _colorCode1 = profile['bg_text_color'];
    _colorCode2 = profile['button_color_code'];
    _colorCode3 = profile['button_text_color'];

    _followersCountFormatted = widget.followersCount ?? '0';
    _followingCountFormatted = widget.followingCount ?? '0';
    userThreads = widget.userThreads != null
        ? List<Map<String, dynamic>>.from(widget.userThreads!)
        : [];
    isLoading = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabBarController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _BioController.dispose();
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  Future<void> _getCurrentUser({bool refresh = true}) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      if (refresh) {
        _loadInitialData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (widget.preloadedProfile == null) {
      safeSetState(() => isLoading = true);
    }
    await Future.wait([
      _loadProfileData(),
      fetchFollowCounts(),
      _loadProfilethreadsData(),
      _loadServicesData(),
      _loadGalleryData(),
    ]);
    safeSetState(() => isLoading = false);
  }

  Future<void> _loadProfileData() async {
    if (_currentUserId == null) return;
    try {
      final response = await _supabase
          .from('profile')
          .select()
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response != null && mounted) {
        safeSetState(() {
          profileId = response['id']?.toString();
          _nameController.text = response['name'] ?? '';
          _imageUrl = response['profile_image_url'];
          _BioController.text = response['bio'] ?? '';
          _imageUrlBanner = response['banner_image_url'];
          isPremium = response['verified'] ?? false;
          _colorCode = response['bg_color_code'];
          _colorCode1 = response['bg_text_color'];
          _colorCode2 = response['button_color_code'];
          _colorCode3 = response['button_text_color'];
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> fetchFollowCounts() async {
    if (_currentUserId == null) return;
    try {
      final followers = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', _currentUserId!);
      final following = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', _currentUserId!);
      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', _currentUserId!)
          .single();

      final int followersCount = followers.length +
          ((userResponse['followers'] as num?)?.toInt() ?? 0);
      final int followingCount = following.length;

      safeSetState(() {
        _followersCountFormatted = _formatCount(followersCount);
        _followingCountFormatted = _formatCount(followingCount);
      });
    } catch (e) {
      debugPrint('Error fetching follows: $e');
    }
  }

  Future<void> _loadServicesData() async {
    if (_currentUserId == null) return;
    try {
      final services = await _supabase
          .from('service')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      safeSetState(() {
        userServices = List<Map<String, dynamic>>.from(services);
      });
    } catch (e) {
      debugPrint('Error loading services: $e');
    }
  }

  Future<void> _loadGalleryData() async {
    if (_currentUserId == null) return;
    try {
      final gallery = await _supabase
          .from('gallery')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      safeSetState(() {
        userGallery = List<Map<String, dynamic>>.from(gallery);
      });
    } catch (e) {
      debugPrint('Error loading gallery: $e');
    }
  }

  Future<void> _loadProfilethreadsData() async {
    if (_currentUserId == null) return;
    try {
      final threads = await _supabase
          .from('threads_view')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      safeSetState(() {
        userThreads = List<Map<String, dynamic>>.from(threads);
      });
    } catch (e) {
      debugPrint('Error loading threads: $e');
    }
  }

  Future<void> _deleteThread(String threadId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread'),
        content: const Text('Are you sure you want to delete this thread?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('threads').delete().eq('id', threadId);
        safeSetState(() {
          userThreads.removeWhere((t) => t['id'] == threadId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Thread deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return count.toString();
  }

  Color _convertStringToColor(String? colorCode,
      {Color fallback = Colors.black}) {
    if (colorCode == null || colorCode.isEmpty) return fallback;
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgcolor =
        _convertStringToColor(_colorCode, fallback: backgroundColor);
    final textcolor = _convertStringToColor(_colorCode1, fallback: textPrimary);
    final btncolor = _convertStringToColor(_colorCode2, fallback: primaryColor);
    final btntextcolor =
        _convertStringToColor(_colorCode3, fallback: textPrimary);

    return Scaffold(
      backgroundColor: bgcolor,
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Banner & Profile Image
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 160,
                        width: double.infinity,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: (_imageUrlBanner != null &&
                                  _imageUrlBanner!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(_imageUrlBanner!),
                                  fit: BoxFit.cover)
                              : null,
                          color: Colors.grey[300],
                        ),
                        child: (_imageUrlBanner == null ||
                                _imageUrlBanner!.isEmpty)
                            ? const Icon(Icons.image,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: -40,
                        left: 24,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: bgcolor),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage:
                                (_imageUrl != null && _imageUrl!.isNotEmpty)
                                    ? NetworkImage(_imageUrl!)
                                    : null,
                            child: (_imageUrl == null || _imageUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Name and Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _nameController.text,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: textcolor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (isPremium)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(Icons.verified,
                                          color: accentColor, size: 18),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _BioController.text,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Montserrat',
                                      color: textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 36,
                          child: CustomButton(
                            textKey: 'Edit',
                            routeWidget: const ProfileCustomWidget(
                                width: double.infinity,
                                height: double.infinity),
                            buttonColor: btncolor,
                            textColor: btntextcolor,
                            width: 100,
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats Area
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: textcolor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Followers', _followersCountFormatted,
                            secondaryColor),
                        _buildStat(
                            'Friends', _followingCountFormatted, textcolor),
                        _buildStat('Threads', _formatCount(userThreads.length),
                            textcolor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabBarController,
                  indicatorColor: btncolor,
                  labelColor: textcolor,
                  unselectedLabelColor: textcolor.withOpacity(0.5),
                  tabs: const [
                    Tab(text: 'Threads'),
                    Tab(text: 'Services'),
                    Tab(text: 'Gallery'),
                  ],
                ),
                bgcolor,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabBarController,
            children: [
              _buildThreadsList(bgcolor, textcolor, btncolor, btntextcolor),
              _buildServicesList(bgcolor, textcolor, btncolor, btntextcolor),
              _buildGalleryGrid(bgcolor, textcolor, btncolor, btntextcolor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null || value is! String) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Widget _buildThreadsList(
      Color bgcolor, Color textcolor, Color btncolor, Color btntextcolor) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (userThreads.isEmpty) return const Center(child: Text('No threads yet'));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: userThreads.length,
      itemBuilder: (context, index) {
        final thread = userThreads[index];
        final createdAt = _parseDateTime(thread['created_at']);
        final threadId = thread['id']?.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: textcolor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textcolor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ? NetworkImage(_imageUrl!)
                            : null,
                    child: (_imageUrl == null || _imageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nameController.text,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (createdAt != null)
                          Text(timeago.format(createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ),
                  if (threadId != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: textSecondary),
                      onSelected: (val) => _deleteThread(threadId),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(thread['content']?.toString() ?? '',
                  style: TextStyle(color: textcolor, fontSize: 15)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _threadAction(Icons.favorite_border,
                      _formatCount(thread['like_count'] ?? 0), textcolor),
                  const SizedBox(width: 20),
                  if (threadId != null)
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThreadCommentsPage(
                                threadContent:
                                    thread['content']?.toString() ?? '',
                                threadId: threadId),
                          )),
                      child: _threadAction(Icons.chat_bubble_outline,
                          (thread['comment_count'] ?? 0).toString(), textcolor),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _threadAction(IconData icon, String label, Color textcolor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildServicesList(
      Color bgcolor, Color textcolor, Color btncolor, Color btntextcolor) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (userServices.isEmpty) {
      return const Center(
          child: Text('No services offered',
              style: TextStyle(color: textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: userServices.length,
      itemBuilder: (context, index) {
        final service = userServices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: textcolor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textcolor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service['title'] ?? 'Untitled Service',
                      style: TextStyle(
                        color: textcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (service['price'] != null)
                    Text(
                      '₹${service['price']}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
              if (service['category'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service['category'],
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                service['description'] ?? '',
                style: const TextStyle(color: textSecondary, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid(
      Color bgcolor, Color textcolor, Color btncolor, Color btntextcolor) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (userGallery.isEmpty) {
      return const Center(
          child:
              Text('No gallery items', style: TextStyle(color: textSecondary)));
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: userGallery.length,
      itemBuilder: (context, index) {
        final item = userGallery[index];
        return Container(
          decoration: BoxDecoration(
            color: textcolor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textcolor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['image_url'] != null)
                  CachedNetworkImage(
                    imageUrl: item['image_url'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                else
                  Container(
                    height: 150,
                    color: Colors.grey[900],
                    child:
                        const Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Untitled',
                        style: TextStyle(
                          color: textcolor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item['price'] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '₹${item['price']}',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.bgcolor);
  final TabBar _tabBar;
  final Color bgcolor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: bgcolor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
