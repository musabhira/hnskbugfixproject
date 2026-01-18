import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verfied_swtich_page.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';

import '/custom_code/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePageWidgetTree extends StatefulWidget {
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
  State<HomePageWidgetTree> createState() => _HomePageWidgetTreeState();
}

class _HomePageWidgetTreeState extends State<HomePageWidgetTree> {
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
    if (count >= 1000000)
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    if (count >= 1000)
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HomePageWidgetTree.backgroundColor,
        appBar: AppBar(
          backgroundColor: HomePageWidgetTree.backgroundColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Pocket Mates',
            style: GoogleFonts.interTight(
              color: HomePageWidgetTree.textPrimary,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              height: 1,
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                top: true,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (supabase.auth.currentUser?.id != null)
                        StatusDisplayWidget(
                          currentUserId: supabase.auth.currentUser!.id,
                          currentProfileId: profileId.toString(),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back! 👋',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: HomePageWidgetTree.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'What would you like to do today?',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: HomePageWidgetTree.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PocketMates Entry Card
                      _buildEntryPointCard(
                        context,
                        title: 'PocketMates',
                        subtitle: 'Meet strangers. Instantly.',
                        icon: FontAwesomeIcons.userGroup,
                        colors: [
                          HomePageWidgetTree.primaryColor,
                          const Color(0xFF357ABD)
                        ],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PocketMatesDashboard(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Quick Anonymous Chat Card
                      _buildEntryPointCard(
                        context,
                        title: 'Quick Chat 🗨️',
                        subtitle: 'Anonymous chatting. Instantly.',
                        icon: FontAwesomeIcons.solidCommentDots,
                        colors: [
                          HomePageWidgetTree.secondaryColor,
                          const Color(0xFFE04A76)
                        ],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebRTCCallScreen(
                                mode: 'Text',
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // AI Buddy Card (Placeholder using Accent Color)
                      _buildEntryPointCard(
                        context,
                        title: 'AI Companion',
                        subtitle: 'Talk to your virtual friend.',
                        icon: FontAwesomeIcons.robot,
                        colors: [
                          HomePageWidgetTree.accentColor,
                          const Color(0xFFE5A500)
                        ],
                        onTap: () {},
                      ),

                      const SizedBox(height: 40),
                    ],
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
              ;
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
