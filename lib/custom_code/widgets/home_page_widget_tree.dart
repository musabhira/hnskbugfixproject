import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/conversation_tile.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';

import '/custom_code/widgets/index.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAllUserData();
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
            : SafeArea(
                top: false,
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
                          currentUserId: supabase.auth.currentUser?.id ?? '',
                          currentProfileId: profileId.toString(),
                          onTapVideo: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WebRTCCallScreen(mode: 'Video'),
                            ),
                          ),
                          onTapFriends: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Strangers Friends coming soon!')),
                            );
                          },
                          onTapCall: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WebRTCCallScreen(mode: 'Voice'),
                            ),
                          ),
                          onTapText: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WebRTCCallScreen(mode: 'Text'),
                            ),
                          ),
                          onTapSettings: _handleSettings,
                        ),
                      ),

                      // Main Content Sliver - WhatsApp Chat List
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
        if (conversations.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final conversation = conversations[index];
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
            childCount: conversations.length,
          ),
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
            icon: Icons.add_rounded,
            label: 'Add',
            isCenter: true,
            isSelected: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Scaffold(
                      backgroundColor: HomePageWidgetTree.backgroundColor)),
            ),
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
}

class _UnifiedHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String currentUserId;
  final String currentProfileId;
  final VoidCallback onTapVideo;
  final VoidCallback onTapFriends;
  final VoidCallback onTapCall;
  final VoidCallback onTapText;
  final VoidCallback onTapSettings;

  _UnifiedHomeHeaderDelegate({
    required this.currentUserId,
    required this.currentProfileId,
    required this.onTapVideo,
    required this.onTapFriends,
    required this.onTapCall,
    required this.onTapText,
    required this.onTapSettings,
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
            bottom: 120, // Constant height for the fixed status widget
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
              height: 120,
              decoration: BoxDecoration(
                color: HomePageWidgetTree.backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05 * progress),
                    width: 1,
                  ),
                ),
              ),
              child: StatusDisplayWidget(
                currentUserId: currentUserId,
                currentProfileId: currentProfileId,
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
  double get maxExtent => 265;

  @override
  double get minExtent => 120;

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
