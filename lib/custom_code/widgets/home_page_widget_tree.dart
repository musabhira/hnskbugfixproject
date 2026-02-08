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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/create_group_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/active_users_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/create_gallery_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/create_service_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/event_create_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/thread_feed_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/notifications_list_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';

class HomePageWidgetTree extends ConsumerStatefulWidget {
  const HomePageWidgetTree({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  // Hardcoded Color Palette
  static Color primaryColor = material.Colors.yellow;
  static Color secondaryColor = material.Colors.yellow;
  static Color accentColor = material.Colors.yellow;
  static const Color backgroundColor = material.Colors.black;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  ConsumerState<HomePageWidgetTree> createState() => _HomePageWidgetTreeState();
}

class _HomePageWidgetTreeState extends ConsumerState<HomePageWidgetTree> {
  final supabase = SupaFlow.client;
  // final scaffoldKey = GlobalKey<ScaffoldState>(); // Removed ScaffoldKey
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
  int _chatTabIndex = 0;

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
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Settings'),
        content: material.Material(
          color: material.Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              material.ListTile(
                leading: Icon(FluentIcons.sign_out, color: material.Colors.red),
                title: const Text('Logout',
                    style: TextStyle(color: material.Colors.red)),
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
                    if (mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
      child: ScaffoldPage(
        // key: scaffoldKey, // No key in ScaffoldPage
        // backgroundColor: HomePageWidgetTree.backgroundColor, // Use padding or background implies by theme
        bottomBar: _buildBottomNavigationBar(context),
        content: _isLoading
            ? const Center(child: ProgressRing())
            : _currentIndex == 1
                ? const MainMarketPage()
                : _currentIndex == 2
                    ? const ToolsPage()
                    : SafeArea(
                        top: true,
                        child: CustomScrollView(
                          // Removed RefreshIndicator
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
                                  // ScaffoldMessenger.of(context).showSnackBar( // No ScaffoldMessenger
                                  //   const SnackBar(
                                  //       content: Text(
                                  //           'Strangers Friends coming soon!')),
                                  // );
                                  displayInfoBar(context,
                                      builder: (context, close) {
                                    return InfoBar(
                                      title: const Text('Coming Soon'),
                                      content: const Text(
                                          'Strangers Friends coming soon!'),
                                      severity: InfoBarSeverity.info,
                                    );
                                  });
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

                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _ChatTabBarDelegate(
                                selectedIndex: _chatTabIndex,
                                onTap: (index) =>
                                    setState(() => _chatTabIndex = index),
                              ),
                            ),

                            if (_chatTabIndex == 0)
                              _buildChatListSliver(conversationsAsync)
                            else if (_chatTabIndex == 1)
                              _buildVibesListSliver()
                            else
                              _buildAIListSliver(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildVibesListSliver() {
    return SliverToBoxAdapter(
      child: StatusDisplayWidget(
        currentUserId: supabase.auth.currentUser?.id ?? '',
        currentProfileId: profileId ?? '',
        isVertical: true,
      ),
    );
  }

  Widget _buildAIListSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              material.Icons.smart_toy_outlined,
              size: 80,
              color: Colors.yellow.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'AI Assistant',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your intelligent companion for creative tasks, image generation, and more.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: material.Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.yellow.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coming Soon',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• AI-powered chat conversations\n• Image generation & editing\n• Smart recommendations\n• Voice interactions',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: material.Colors.grey[300],
                      height: 1.6,
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

  Widget _buildChatListSliver(
      AsyncValue<List<ChatConversation>> conversationsAsync) {
    return conversationsAsync.when(
      data: (conversations) {
        final allNotifications =
            conversations.where((c) => c.isNotification).toList();
        final chatConversations =
            conversations.where((c) => !c.isNotification).toList();

        List<ChatConversation> combined = [...chatConversations];
        if (allNotifications.isNotEmpty && _searchQuery.isEmpty) {
          final latestNotif = allNotifications.reduce((a, b) =>
              (a.lastMessageTime?.isAfter(b.lastMessageTime ?? DateTime(0)) ??
                      false)
                  ? a
                  : b);
          combined.add(ChatConversation(
            id: 'notifications_aggregator',
            name: 'Notifications',
            lastMessage:
                'You have ${allNotifications.length} new notification${allNotifications.length > 1 ? 's' : ''}',
            lastMessageTime: latestNotif.lastMessageTime,
            unreadCount: allNotifications.length,
            isGroup: false,
            isNotification: true,
          ));
        }

        // Sort by last message time
        combined.sort((a, b) {
          final aTime = a.lastMessageTime ?? DateTime(0);
          final bTime = b.lastMessageTime ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

        final filteredConversations = combined.where((conversation) {
          if (_searchQuery.isEmpty) return true;
          return conversation.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextBox(
                        controller: _searchController,
                        placeholder: 'Search for conversations...',
                        placeholderStyle: GoogleFonts.outfit(
                          color: material.Colors.white.withOpacity(0.35),
                          fontSize: 14,
                        ),
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Icon(
                            FluentIcons.search,
                            color: material.Colors.yellow.withOpacity(0.6),
                            size: 18,
                          ),
                        ),
                        suffix: _searchQuery.isNotEmpty
                            ? material.Material(
                                color: material.Colors.transparent,
                                child: material.IconButton(
                                  icon: Icon(
                                    FluentIcons.clear,
                                    color:
                                        material.Colors.white.withOpacity(0.3),
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                ),
                              )
                            : null,
                        decoration: ButtonState.all(BoxDecoration(
                          border: Border.all(style: BorderStyle.none),
                        )),
                        style: GoogleFonts.outfit(
                          color: material.Colors.white,
                          fontSize: 14,
                        ),
                        cursorColor: material.Colors.yellow,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
                        FluentIcons.search,
                        size: 64,
                        color: material.Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No conversations yet'
                            : 'No chats found for "$_searchQuery"',
                        style: GoogleFonts.inter(
                          color: material.Colors.white.withOpacity(0.4),
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
                    if (conversation.id == 'notifications_aggregator') {
                      return _buildNotificationsTile(allNotifications.length);
                    }
                    return ConversationTile(
                      key: ValueKey(conversation.id),
                      conversation: conversation,
                      currentUserId: _currentUserId ?? '',
                      onTap: () {
                        if (conversation.isNotification) {
                          _showNotificationDetails(context, conversation);
                        } else if (conversation.isGroup) {
                          Navigator.push(
                            context,
                            material.MaterialPageRoute(
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
                            material.MaterialPageRoute(
                              builder: (context) => MessageScreen(
                                receiverId: conversation.id,
                                receiverName: conversation.name,
                                receiverProfileImage: conversation.imageUrl,
                              ),
                            ),
                          );
                        }
                      },
                      onStatusTap: () {
                        if (conversation.hasStatus &&
                            conversation.statusData != null) {
                          Navigator.push(
                            context,
                            material.MaterialPageRoute(
                              builder: (context) => StatusViewerWrapper(
                                allStatusGroups: [
                                  {
                                    'profile': {
                                      'id': conversation.id,
                                      'name': conversation.name,
                                      'profile_image_url':
                                          conversation.imageUrl,
                                    },
                                    'statuses': conversation.statusData,
                                    'is_own': false,
                                  }
                                ],
                                initialGroupIndex: 0,
                                currentUserId: _currentUserId ?? '',
                                currentProfileId: profileId ?? '',
                                isFromGroup: true,
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
            child: ProgressRing(
              activeColor: HomePageWidgetTree.primaryColor,
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
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: material.Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: FluentIcons.view_dashboard,
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _buildNavItem(
              icon: FluentIcons.market,
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _buildNavItem(
              icon: FluentIcons.toolbox,
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _buildProfileNavItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    return GestureDetector(
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
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
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
            material.MaterialPageRoute(
              builder: (context) =>
                  VerfiedSwitchPage(userId: _currentUserId.toString()),
            ),
          );
        }
      },
      child: CircularProfileImage(
        profileImageUrl: _profileImageUrl,
        isVerified: _isVerified,
        radius: 20.0,
        borderColor: Colors.yellow,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? material.Colors.yellow.withOpacity(0.12)
                    : material.Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? material.Colors.yellow
                    : HomePageWidgetTree.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Methods being added here

  void _showAddBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Add New Content'),
        content: material.Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP ROW: ADD GALLERY (Full Width)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: material.InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          final isAuthenticated =
                              await AuthAlertBox.checkAuthAndShowAlert(
                            context: context,
                            customMessage: "Please login to add to Gallery",
                          );
                          if (isAuthenticated) {
                            Navigator.push(
                              context,
                              material.MaterialPageRoute(
                                  builder: (_) => const CreateGalleryWidget(
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
                                const Icon(FluentIcons.shopping_cart,
                                    color: Colors.white, size: 30),
                                const SizedBox(height: 8),
                                Text('Add\nGallery',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 12)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: material.InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          final isAuthenticated =
                              await AuthAlertBox.checkAuthAndShowAlert(
                            context: context,
                            customMessage: "Please login to add Service",
                          );
                          if (isAuthenticated) {
                            Navigator.push(
                                context,
                                material.MaterialPageRoute(
                                    builder: (_) => const CreateServiceWidget(
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
                                const Icon(FluentIcons.repair,
                                    color: Colors.white, size: 30),
                                const SizedBox(height: 8),
                                Text('Add\nService',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            )),
                      ),
                    ),
                  ),

                  // ADD THOUGHT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: material.InkWell(
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
                                material.MaterialPageRoute(
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
                                const Icon(FluentIcons.lightbulb,
                                    color: Colors.white, size: 30),
                                const SizedBox(height: 8),
                                Text('Add\nThought',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            )),
                      ),
                    ),
                  ),

                  // ADD EVENT (Verified Only)
                  if (_isVerified)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: material.InkWell(
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
                                  material.MaterialPageRoute(
                                      builder: (_) => const EventCreatePage()));
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
                                  const Icon(FluentIcons.calendar_reply,
                                      color: Colors.white, size: 30),
                                  const SizedBox(height: 8),
                                  Text('Add\nEvent',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 12)),
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
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
            content: Text('Connecting to active network...')),
      );
      return;
    }

    final activeFriends = activeUsersState.value!.activeFriends;

    // 2. Filter out self (already done in provider, but double check)
    // and potentially filter by interests if we had that data.
    if (activeFriends.isEmpty) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
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

    material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(
          content: Text('Matching with ${randomUser['name']}...')),
    );

    Navigator.push(
      context,
      material.MaterialPageRoute(
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
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(content: Text('No active users to chat with.')),
      );
      return;
    }

    final randomUser = (activeFriends..shuffle()).first;

    Navigator.push(
      context,
      material.MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          mode: 'Text',
          targetUserId: randomUser['user_id'], // Pass matched user
        ),
      ),
    );
  }

  Widget _buildNotificationsTile(int count) {
    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: () => Navigator.push(
          context,
          material.MaterialPageRoute(
            builder: (context) => const NotificationsListPage(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: material.Colors.yellow.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: material.Colors.yellow.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          material.Colors.yellow,
                          Color(0xFFFFA000),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FluentIcons.ringer,
                      color: material.Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: material.Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: material.Colors.black,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: material.Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.outfit(
                        color: material.Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You have $count new notification${count > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        color: material.Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.chevron_right,
                color: material.Colors.white.withOpacity(0.2),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(
      BuildContext context, ChatConversation notification) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(material.Icons.notifications_active,
                color: material.Colors.yellow, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Notification',
                style: GoogleFonts.outfit(
                  color: material.Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: material.MainAxisSize.min,
          crossAxisAlignment: material.CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              notification.lastMessage ?? 'No details',
              style: GoogleFonts.inter(
                color: material.Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        actions: [
          if (notification.notificationType == 'project_invite' &&
              notification.sourceId != null) ...[
            Button(
              onPressed: () async {
                Navigator.pop(context);
                await TeamsService().declineInvite(notification.sourceId!);
                await ref
                    .read(conversationsProvider.notifier)
                    .dismissNotification(notification.id);
              },
              child: Text('Decline',
                  style: material.TextStyle(color: material.Colors.red)),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await TeamsService().acceptInvite(notification.sourceId!);
                await ref
                    .read(conversationsProvider.notifier)
                    .dismissNotification(notification.id);
                material.ScaffoldMessenger.of(context).showSnackBar(
                  material.SnackBar(content: Text('Invitation accepted!')),
                );
              },
              child: Text('Accept',
                  style: material.TextStyle(color: material.Colors.black)),
              style: ButtonStyle(
                backgroundColor: ButtonState.all(material.Colors.yellow),
              ),
            ),
          ] else ...[
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(conversationsProvider.notifier)
                    .dismissNotification(notification.id);
              },
              child: Text('Dismiss',
                  style: material.TextStyle(color: material.Colors.black)),
              style: ButtonStyle(
                backgroundColor: ButtonState.all(material.Colors.yellow),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnifiedHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String currentUserId;
  final String currentProfileId;
  final AsyncValue<ActiveUsersData> activeUsersRef;
  final VoidCallback onTapVideo;
  final VoidCallback onTapFriends;
  final VoidCallback onTapCall;
  final VoidCallback onTapText;
  final VoidCallback onTapSettings;
  final VoidCallback onTapAdd;
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
    required this.onTapAdd,
    required this.onRefresh,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double maxShrink = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);
    final double overscroll = shrinkOffset < 0 ? -shrinkOffset : 0;
    final double overscrollScale = 1.0 + (overscroll / 300);
    final double topPadding = MediaQuery.of(context).padding.top;

    return material.Material(
      color: material.Colors.transparent,
      child: Stack(
        children: [
          // 1. Background
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF0F0F0F), material.Colors.black],
              ),
            ),
          )),

          // 2. Stranger Match Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 140,
            child: ClipRect(
              child: Transform.scale(
                scale: overscrollScale,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, -shrinkOffset * 0.6),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stranger Match',
                            style: GoogleFonts.outfit(
                              color: material.Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildMatchCard(
                                label: 'Video Call',
                                icon: FluentIcons.video,
                                color: material.Colors.blue,
                                onTap: onTapVideo,
                              ),
                              const SizedBox(width: 16),
                              _buildMatchCard(
                                label: 'Voice Call',
                                icon: FluentIcons.phone,
                                color: material.Colors.green,
                                onTap: onTapCall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildMatchCard(
                            label: 'Quick Anonymous Chat',
                            icon: FluentIcons.chat,
                            color: material.Colors.yellow,
                            isFullWidth: true,
                            onTap: onTapText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Status Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xFF141414).withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border(
                  top: BorderSide(
                      color: material.Colors.white.withOpacity(0.08), width: 1),
                ),
              ),
              child: material.Material(
                color: material.Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          material.InkWell(
                            onTap: onTapAdd,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: material.Colors.yellow.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        material.Colors.yellow.withOpacity(0.3),
                                    width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(FluentIcons.add,
                                      size: 14, color: material.Colors.yellow),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Add',
                                    style: GoogleFonts.outfit(
                                      color: material.Colors.yellow,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          activeUsersRef.when(
                            data: (data) =>
                                _buildActiveCounter(data.activeFriends.length),
                            loading: () => const SizedBox(
                              width: 16,
                              height: 16,
                              child: ProgressRing(),
                            ),
                            error: (_, __) => const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    StatusDisplayWidget(
                      currentUserId: currentUserId,
                      currentProfileId: currentProfileId,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Utility Buttons
          Positioned(
            top: topPadding + 10,
            right: 16,
            child: Opacity(
              opacity: (1 - progress * 2).clamp(0.0, 1.0),
              child: Row(
                children: [
                  _buildHeaderIconButton(
                      icon: FluentIcons.settings, onTap: onTapSettings),
                  const SizedBox(width: 10),
                  _buildHeaderIconButton(
                    icon: FluentIcons.add_friend,
                    onTap: () async {
                      final auth = await AuthAlertBox.checkAuthAndShowAlert(
                          context: context);
                      if (auth) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                CreateGroupDialog(onGroupCreated: onRefresh));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    final card = Container(
      width: isFullWidth ? double.infinity : null,
      height: isFullWidth ? 80 : 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: isFullWidth
          ? Row(
              children: [
                _buildMatchIcon(icon, color),
                const SizedBox(width: 16),
                Text(label,
                    style: GoogleFonts.outfit(
                        color: material.Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(FluentIcons.chevron_right,
                    color: material.Colors.white.withOpacity(0.3), size: 14),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMatchIcon(icon, color),
                const SizedBox(height: 12),
                Text(label,
                    style: GoogleFonts.outfit(
                        color: material.Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
    );

    return isFullWidth
        ? material.Material(
            color: material.Colors.transparent,
            child: material.InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: card))
        : Expanded(
            child: material.Material(
                color: material.Colors.transparent,
                child: material.InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(24),
                    child: card)));
  }

  Widget _buildMatchIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.2), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildActiveCounter(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0xFF10B981), blurRadius: 8, spreadRadius: 2),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count Active',
            style: GoogleFonts.outfit(
              color: const Color(0xFF10B981),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: material.Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border:
            Border.all(color: material.Colors.white.withOpacity(0.1), width: 1),
      ),
      child: material.Material(
        color: material.Colors.transparent,
        child: material.IconButton(
          icon: Icon(icon, color: material.Colors.white, size: 20),
          onPressed: onTap,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 500.0;
  @override
  double get minExtent => 210.0;
  @override
  bool shouldRebuild(covariant _UnifiedHomeHeaderDelegate oldDelegate) => true;
}

class CircularProfileImage extends StatelessWidget {
  final String? profileImageUrl;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final bool isVerified;

  CircularProfileImage({
    super.key,
    required this.profileImageUrl,
    this.radius = 16.0,
    this.borderColor = material.Colors.yellow,
    this.borderWidth = 1.0,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: borderWidth),
            image: profileImageUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(profileImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: profileImageUrl == null
              ? Icon(FluentIcons.contact,
                  color: material.Colors.grey, size: radius)
              : null,
        ),
        if (isVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: material.Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.verified_brand,
                color: Color(0xFFFFB703),
                size: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChatTabBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  _ChatTabBarDelegate({required this.selectedIndex, required this.onTap});

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: HomePageWidgetTree.backgroundColor,
      child: Row(
        children: [
          _buildTab('Chats', 0),
          _buildTab('Vibes', 1),
          _buildTab('AI', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? material.Colors.yellow.withOpacity(0.05)
                  : material.Colors.transparent,
              border: isSelected
                  ? Border(
                      bottom: BorderSide(
                        color: material.Colors.yellow,
                        width: 2.5,
                      ),
                    )
                  : null,
            ),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? material.Colors.yellow
                    : material.Colors.white.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ChatTabBarDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}
