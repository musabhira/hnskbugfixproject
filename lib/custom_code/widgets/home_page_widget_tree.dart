import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/conversation_tile.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';

import '/custom_code/widgets/index.dart';
import '/custom_code/widgets/tools_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/create_group_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/active_users_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/create_gallery_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/create_service_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/event_create_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/thread_feed_page.dart';

class HomePageWidgetTree extends ConsumerStatefulWidget {
  const HomePageWidgetTree({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  // Hardcoded Color Palette
  static const Color primaryColor = Colors.yellow;
  static const Color secondaryColor = Colors.yellow;
  static const Color accentColor = Colors.yellow;
  static const Color backgroundColor = Colors.black;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  ConsumerState<HomePageWidgetTree> createState() => _HomePageWidgetTreeState();
}

class _HomePageWidgetTreeState extends ConsumerState<HomePageWidgetTree> {
  final supabase = SupaFlow.client;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String? profileId;
  String? _profileImageUrl;
  bool _isVerified = false;
  bool _isLoading = true;

  String? _currentUserId;
  // Preloaded Data for Profile
  Map<String, dynamic>? _preloadedProfile;
  String _followersCount = '0';
  String _followingCount = '0';
  List<Map<String, dynamic>> _userThreads = [];

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadAllUserData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cachedProfile = prefs.getString('cached_profile_$userId');
      final cachedStats = prefs.getString('cached_stats_$userId');

      if (cachedProfile != null) {
        final profileMap = jsonDecode(cachedProfile);
        safeSetState(() {
          _preloadedProfile = profileMap;
          profileId = profileMap['id']?.toString();
          _profileImageUrl = profileMap['profile_image_url'];
          _isVerified = profileMap['verified'] ?? false;
          _isLoading = false; // Show UI immediately from cache
        });
      }

      if (cachedStats != null) {
        final statsMap = jsonDecode(cachedStats);
        safeSetState(() {
          _followersCount = statsMap['followers'] ?? '0';
          _followingCount = statsMap['following'] ?? '0';
        });
      }
    } catch (e) {
      debugPrint('Error loading cached home data: $e');
    }
  }

  Future<void> _loadAllUserData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        safeSetState(() => _isLoading = false);
        return;
      }
      _currentUserId = userId;

      // Fetch everything in parallel
      final results = await Future.wait<dynamic>([
        supabase.from('profile').select().eq('user_id', userId).maybeSingle(),
        supabase.from('follows').select('id').eq('followed_id', userId),
        supabase.from('follows').select('id').eq('follower_id', userId),
        supabase.from('users').select('followers').eq('id', userId).single(),
        supabase
            .from('threads_view')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false),
      ]);

      final profileResponse = results[0] as Map<String, dynamic>?;
      final followers = results[1] as List;
      final following = results[2] as List;
      final userResponse = results[3] as Map<String, dynamic>;
      final threads = results[4] as List;

      safeSetState(() {
        _preloadedProfile = profileResponse;
        if (profileResponse != null) {
          profileId = profileResponse['id']?.toString();
          _profileImageUrl = profileResponse['profile_image_url'];
          _isVerified = profileResponse['verified'] ?? false;
        }

        final int followersCount = followers.length +
            ((userResponse['followers'] as num?)?.toInt() ?? 0);
        _followersCount = _formatCount(followersCount);
        _followingCount = _formatCount(following.length);

        _userThreads = List<Map<String, dynamic>>.from(threads);

        _isLoading = false;
      });

      // Cache the fresh data
      final prefs = await SharedPreferences.getInstance();
      if (profileResponse != null) {
        await prefs.setString(
            'cached_profile_$userId', jsonEncode(profileResponse));
      }

      final statsMap = {
        'followers': _followersCount,
        'following': _followingCount
      };
      await prefs.setString('cached_stats_$userId', jsonEncode(statsMap));
    } catch (e) {
      debugPrint('Error loading all user data: $e');
      safeSetState(() => _isLoading = false);
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

  void _handleSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await supabase.auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      'LandingPage',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  // Fallback if named route fails or generic error
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HomePageWidgetTree.backgroundColor,
        bottomNavigationBar: _buildBottomNavigationBar(context),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentIndex == 1
                ? const MainMarketPage()
                : _currentIndex == 2
                    ? const ToolsPage()
                    : SafeArea(
                        top: true,
                        child: RefreshIndicator(
                          onRefresh: _loadAllUserData,
                          color: HomePageWidgetTree.primaryColor,
                          backgroundColor: Colors.grey[900],
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // Unified Dynamic Header (Stranger Rows + Status)
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _UnifiedHomeHeaderDelegate(
                                  currentUserId:
                                      supabase.auth.currentUser?.id ?? '',
                                  currentProfileId: profileId.toString(),
                                  activeUsersRef: ref.watch(activeUsersProvider(
                                      profileId
                                          .toString())), // Pass the provider reference
                                  onTapVideo: () => _handleStrangerMatch(
                                    context,
                                    ref,
                                    'Video',
                                    profileId.toString(),
                                  ),
                                  onTapFriends: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Strangers Friends coming soon!')),
                                    );
                                  },
                                  onTapCall: () => _handleStrangerMatch(
                                    context,
                                    ref,
                                    'Voice',
                                    profileId.toString(),
                                  ),
                                  onTapText: () => _handleStrangerChat(
                                      context, ref, profileId.toString()),
                                  onTapSettings: _handleSettings,
                                  onTapAdd: () => _showAddBottomSheet(context),
                                  onRefresh: () =>
                                      ref.refresh(conversationsProvider),
                                ),
                              ),

                              _buildChatListSliver(conversationsAsync),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildChatListSliver(
      AsyncValue<List<ChatConversation>> conversationsAsync) {
    return conversationsAsync.when(
      data: (conversations) {
        final filteredConversations = conversations.where((conversation) {
          if (_searchQuery.isEmpty) return true;
          return conversation.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.white.withOpacity(0.3),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withOpacity(0.3),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (filteredConversations.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No conversations yet'
                            : 'No chats found for "$_searchQuery"',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conversation = filteredConversations[index];
                    return ConversationTile(
                      key: ValueKey(conversation.id),
                      conversation: conversation,
                      currentUserId: _currentUserId ?? '',
                      onTap: () {
                        if (conversation.isGroup) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WhatsAppGroupChat(
                                groupId: conversation.id,
                                groupName: conversation.name,
                                groupImage: conversation.imageUrl,
                              ),
                            ),
                          );
                        } else {
                          // Mark as read for personal chat
                          ref
                              .read(conversationsProvider.notifier)
                              .markAsRead(conversation.id, false);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageScreen(
                                receiverId: conversation.id,
                                receiverName: conversation.name,
                                receiverProfileImage: conversation.imageUrl,
                              ),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        // Optional: Show options
                      },
                    );
                  },
                  childCount: filteredConversations.length,
                ),
              ),
          ],
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Center(
            child: CircularProgressIndicator(
              color: HomePageWidgetTree.primaryColor,
            ),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Error loading chats',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryPointCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 140,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .moveY(
              begin: 20, end: 0, duration: 600.ms, curve: Curves.easeOutQuart)
          .fadeIn(),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slightly lighter than background
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            isSelected: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          _buildNavItem(
            icon: Icons.store_mall_directory_rounded,
            label: 'Market',
            isSelected: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _buildNavItem(
            icon: Icons.handyman_rounded,
            label: 'Tools',
            isSelected: _currentIndex == 2,
            onTap: () => setState(() => _currentIndex = 2),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              final isAuthenticated = await AuthAlertBox.checkAuthAndShowAlert(
                context: context,
                customMessage: "Please login to view your profile",
              );
              if (isAuthenticated) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProfileSwitchPage(
                      width: double.infinity,
                      height: double.infinity,
                      preloadedProfile: _preloadedProfile,
                      followersCount: _followersCount,
                      followingCount: _followingCount,
                      userThreads: _userThreads,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // Start from right
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            onLongPress: () async {
              final isAuthenticated = await AuthAlertBox.checkAuthAndShowAlert(
                context: context,
                customMessage: "Please login to view your profile",
              );
              if (isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerfiedSwitchPage(
                        userId: _currentUserId.toString()), // your target page
                  ),
                );
              }
            },
            child: CircularProfileImage(
              profileImageUrl: _profileImageUrl,
              isVerified: _isVerified,
              radius: 23.0,
              borderColor: Colors.yellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCenter = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isCenter ? 14 : 8),
            decoration: BoxDecoration(
              color: isCenter
                  ? HomePageWidgetTree.accentColor
                  : (isSelected
                      ? HomePageWidgetTree.primaryColor.withOpacity(0.15)
                      : Colors.transparent),
              shape: BoxShape.circle,
              boxShadow: isCenter
                  ? [
                      BoxShadow(
                        color: HomePageWidgetTree.accentColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isCenter
                  ? Colors.black
                  : (isSelected
                      ? HomePageWidgetTree.primaryColor
                      : HomePageWidgetTree.textSecondary),
              size: isCenter ? 32 : 26,
            ),
          ),
          if (!isCenter) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? HomePageWidgetTree.primaryColor
                    : HomePageWidgetTree.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
  // Methods being added here

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        // Use a StatefulBuilder if dynamic rebuilding is needed inside the sheet
        return StatefulBuilder(builder: (context, setState) {
          bool isExpanded = true;
          return Container(
            height: 400, // Adjust as needed
            decoration: const BoxDecoration(
              color: Color(0xFF111111), // Match theme
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700, // Set your desired max width
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TOP ROW: ADD GALLERY (Full Width)
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context); // Close sheet
                                final isAuthenticated =
                                    await AuthAlertBox.checkAuthAndShowAlert(
                                  context: context,
                                  customMessage:
                                      "Please login to add to Gallery",
                                );
                                if (isAuthenticated) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateGalleryWidget(
                                                width: double.infinity,
                                                height: double.infinity)),
                                  );
                                }
                              },
                              child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.8),
                                        FlutterFlowTheme.of(context)
                                            .secondary
                                            .withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.shopping_basket_sharp,
                                          color: Colors.white, size: 30),
                                      const SizedBox(height: 8),
                                      Text('Add\nGallery',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // BOTTOM ROW: SERVICE, THOUGHT, EVENT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ADD SERVICE
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context); // Close sheet
                                final isAuthenticated =
                                    await AuthAlertBox.checkAuthAndShowAlert(
                                  context: context,
                                  customMessage: "Please login to add Service",
                                );
                                if (isAuthenticated) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CreateServiceWidget(
                                                  width: double.infinity,
                                                  height: double.infinity)));
                                }
                              },
                              child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.8),
                                        FlutterFlowTheme.of(context)
                                            .secondary
                                            .withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                          Icons.miscellaneous_services_sharp,
                                          color: Colors.white,
                                          size: 30),
                                      const SizedBox(height: 8),
                                      Text('Add\nService',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ],
                                  )),
                            ),
                          ),
                        ),

                        // ADD THOUGHT
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                final isAuthenticated =
                                    await AuthAlertBox.checkAuthAndShowAlert(
                                  context: context,
                                  customMessage: "Please login to add Thought",
                                );
                                if (isAuthenticated) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => CreateThreadPage(
                                              userId: _currentUserId ?? '')));
                                }
                              },
                              child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.8),
                                        FlutterFlowTheme.of(context)
                                            .secondary
                                            .withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.psychology_alt_outlined,
                                          color: Colors.white, size: 30),
                                      const SizedBox(height: 8),
                                      Text('Add\nThought',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ],
                                  )),
                            ),
                          ),
                        ),

                        // ADD EVENT (Verified Only)
                        if (_isVerified)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  final isAuthenticated =
                                      await AuthAlertBox.checkAuthAndShowAlert(
                                    context: context,
                                    customMessage: "Please login to add Event",
                                  );
                                  if (isAuthenticated) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const EventCreatePage()));
                                  }
                                },
                                child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.8),
                                          FlutterFlowTheme.of(context)
                                              .secondary
                                              .withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.event,
                                            color: Colors.white, size: 30),
                                        const SizedBox(height: 8),
                                        Text('Add\nEvent',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _handleStrangerMatch(
    BuildContext context,
    WidgetRef ref,
    String mode,
    String currentProfileId,
  ) async {
    // 1. Get Active Users
    final activeUsersState = ref.read(activeUsersProvider(currentProfileId));

    if (!activeUsersState.hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to active network...')),
      );
      return;
    }

    final activeFriends = activeUsersState.value!.activeFriends;

    // 2. Filter out self (already done in provider, but double check)
    // and potentially filter by interests if we had that data.
    if (activeFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No active users nearby to match with right now.')),
      );
      return;
    }

    // 3. Simple Random Match
    final randomUser = (activeFriends..shuffle()).first;

    // 4. Initiate Call
    // Here we navigate to WebRTCCallScreen but passing the target user ID
    // Note: WebRTCCallScreen might need updates to accept targetUserId if it was "Room" based before.
    // Assuming WebRTCCallScreen can handle a direct call setup or we pass the target info.
    // For now, I'll pass it as arguments or modify WebRTCCallScreen if needed.
    // But since the user said "not go to room connect delete",
    // it implies we call them directly.
    // Let's assume WebRTCCallScreen has a 'targetUserId' parameter or similar.
    // If not, we might need to use the MessageScreen for "Text" and a CallScreen for "Voice/Video".

    if (mode == 'Text') {
      _handleStrangerChat(context, ref, currentProfileId);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Matching with ${randomUser['name']}...')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          mode: mode,
          targetUserId: randomUser['user_id'], // Pass matched user
        ),
      ),
    );
  }

  void _handleStrangerChat(
      BuildContext context, WidgetRef ref, String currentProfileId) {
    final activeUsersState = ref.read(activeUsersProvider(currentProfileId));
    final activeFriends = activeUsersState.value?.activeFriends ?? [];

    if (activeFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active users to chat with.')),
      );
      return;
    }

    final randomUser = (activeFriends..shuffle()).first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          mode: 'Text',
          targetUserId: randomUser['user_id'], // Pass matched user
        ),
      ),
    );
  }
}

class _UnifiedHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String currentUserId;
  final String currentProfileId;
  final AsyncValue<ActiveUsersData> activeUsersRef; // Added param
  final VoidCallback onTapVideo;
  final VoidCallback onTapFriends;
  final VoidCallback onTapCall;
  final VoidCallback onTapText;
  final VoidCallback onTapSettings;
  final VoidCallback onTapAdd; // Added for Add Button
  final VoidCallback onRefresh;

  _UnifiedHomeHeaderDelegate({
    required this.currentUserId,
    required this.currentProfileId,
    required this.activeUsersRef,
    required this.onTapVideo,
    required this.onTapFriends,
    required this.onTapCall,
    required this.onTapText,
    required this.onTapSettings,
    required this.onTapAdd, // Added param
    required this.onRefresh,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate progress (0.0 = fully open, 1.0 = fully closed)
    final double maxShrink = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);

    // Handle overscroll (pull down to expand)
    final double overscroll = shrinkOffset < 0 ? -shrinkOffset : 0;
    final double overscrollScale = 1.0 + (overscroll / 300);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: HomePageWidgetTree.backgroundColor,
      child: Stack(
        children: [
          // 1. Collapsible Container (Stranger Rows)
          // Using ClipRect + Transform for a structural "open/close" effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 150, // Constant height for the fixed status widget
            child: ClipRect(
              child: Transform.scale(
                scale: overscrollScale,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  // Parallax slide effect for "open/close" feel
                  offset: Offset(0, -shrinkOffset * 0.4),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    context,
                                    icon: FontAwesomeIcons.video,
                                    label: 'Strangers Video Call',
                                    color: Colors.yellow,
                                    onTap: onTapVideo,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    context,
                                    icon: FontAwesomeIcons.userGroup,
                                    label: 'Strangers Friends',
                                    color: Colors.yellow,
                                    onTap: onTapFriends,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    context,
                                    icon: FontAwesomeIcons.phone,
                                    label: 'Call Stranger',
                                    color: Colors.yellow,
                                    onTap: onTapCall,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    context,
                                    icon: FontAwesomeIcons.solidCommentDots,
                                    label: 'Text Stranger',
                                    color: Colors.yellow,
                                    onTap: onTapText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Status Widget - STAYS AT TOP (PINNED logic via minExtent)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: HomePageWidgetTree.backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05 * progress),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 12.0, bottom: 4.0),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final asyncData =
                            ref.watch(activeUsersProvider(currentProfileId));
                        return asyncData.when(
                          data: (data) => Row(
                            children: [
                              InkWell(
                                onTap: onTapAdd,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${data.activeFriends.length} Online',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          loading: () => const SizedBox(height: 16),
                          error: (_, __) => const SizedBox(),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StatusDisplayWidget(
                      currentUserId: currentUserId,
                      currentProfileId: currentProfileId,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subtle Bottom Shadow when pinned
          if (progress > 0.9)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Settings Button (Fades out when scrolled)
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: Opacity(
              opacity: (1.0 - progress * 3).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.settings, color: Colors.white, size: 20),
                  onPressed: onTapSettings,
                ),
              ),
            ),
          ),

          // Create Group Button (Top Left or Left of Settings)
          Positioned(
            top: topPadding + 8,
            right: 64, // Spaced from settings
            child: Opacity(
              opacity: (1.0 - progress * 3).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.group_add,
                      color: Colors.yellow, size: 20),
                  onPressed: () async {
                    final isAuthenticated =
                        await AuthAlertBox.checkAuthAndShowAlert(
                      context: context,
                      customMessage: "Please login to create a group",
                    );
                    if (isAuthenticated) {
                      showDialog(
                        context: context,
                        builder: (context) => CreateGroupDialog(
                          onGroupCreated: onRefresh,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 295;

  @override
  double get minExtent => 150;

  @override
  bool shouldRebuild(covariant _UnifiedHomeHeaderDelegate oldDelegate) => true;
}

class CircularProfileImage extends StatelessWidget {
  final String? profileImageUrl;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final bool isVerified;

  const CircularProfileImage({
    super.key,
    required this.profileImageUrl,
    this.radius = 16.0,
    this.borderColor = Colors.yellow,
    this.borderWidth = 1.0,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: ClipOval(
            child: profileImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: profileImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                  )
                : Image.network(
                    'https://static.vecteezy.com/system/resources/previews/021/719/635/non_2x/portrait-of-a-rabbit-head-cute-bunny-isolated-on-yellow-background-suitable-for-profile-social-media-picture-web-print-sticker-and-more-cartoon-style-illustration-vector.jpg'),
          ),
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: Color(0xFFFFB703),
                size: 10,
              ),
            ),
          ),
      ],
    );
  }
}
