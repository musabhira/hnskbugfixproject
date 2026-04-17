import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/conversation_tile.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/native_webrtc_call_screen.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart';
import '/custom_code/widgets/tools_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/drawing_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poster_designer/template_gallery_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/bulk_sender/bulk_sender_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poki_games_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/nearby_users_page.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:async' as async;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/verfied_search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat_list_shimmer.dart';
import 'package:pocket_mates_app/custom_code/widgets/settings_page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart'
    as groups_provider;
import 'package:pocket_mates_app/custom_code/widgets/chat/create_group_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/active_users_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/notifications_list_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/drawing_academy_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/thoughts_feed_section.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/team_detail_page.dart';
import 'dart:io' as io;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:pocket_mates_app/custom_code/widgets/eula_compliance_dialog.dart';

// Aliases for WhatsApp Groups Provider to avoid naming conflicts
typedef ChatConversation = groups_provider.ChatConversation;
final conversationsProvider = groups_provider.conversationsProvider;

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
  int _refreshKeyCount = 0;
  late PageController _pageController;
  int _searchTabIndex = 0; // 0 for People, 1 for Products
  List<Map<String, dynamic>> _personSearchResults = [];
  List<Map<String, dynamic>> _productSearchResults = [];
  bool _isSearchingPeople = false;
  bool _isSearchingProducts = false;
  async.Timer? _searchDebounce;
  final ValueNotifier<String> _vibesFilterNotifier = ValueNotifier<String>('Public');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _chatTabIndex);
    _loadCachedData();
    _loadAllUserData();
    _searchController.addListener(_onSearchChanged);
    
    // Add post frame callback to check for updates after initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppUpdate();
      _checkEulaAndRedirect();
      _loadVibesFilterInitial();
    });
  }

  Future<void> _loadVibesFilterInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('vibes_filter_selection') ?? 'Public';
    _vibesFilterNotifier.value = saved;
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
    });

    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = async.Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  Future<void> _checkEulaAndRedirect() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenEulaLocally = prefs.getBool('eula_accepted_${user.id}') ?? false;

        if (!hasSeenEulaLocally) {
          // If not seen locally, we MUST show it
          _showEulaDialog();
          return;
        }

        // Optional: Also check DB as a secondary verification
        final profile = await supabase
            .from('profile')
            .select('eula_accepted')
            .eq('user_id', user.id)
            .single();

        if (profile['eula_accepted'] != true) {
          _showEulaDialog();
        }
      } catch (e) {
        // If error, ignore for now
      }
    }
  }

  void _showEulaDialog() {
    if (!mounted) return;
    material.showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EulaComplianceDialog(
        onAccepted: () {
          material.Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      safeSetState(() {
        _personSearchResults = [];
        _productSearchResults = [];
        _isSearchingPeople = false;
        _isSearchingProducts = false;
      });
      return;
    }

    safeSetState(() {
      _isSearchingPeople = true;
      _isSearchingProducts = true;
    });

    try {
      // 1. Search People
      final peopleResponse = await supabase
          .from('profile')
          .select()
          .or('name.ilike.%$query%,slug.ilike.%$query%')
          .limit(15);

      // 2. Search Products (Gallery & Services)
      final galleryResults = await supabase
          .from('gallery')
          .select('*, profile(name, verified, profile_image_url)')
          .ilike('title', '%$query%')
          .limit(10);

      final serviceResults = await supabase
          .from('service')
          .select('*, profile(name, verified, profile_image_url)')
          .ilike('title', '%$query%')
          .limit(10);

      safeSetState(() {
        _personSearchResults = List<Map<String, dynamic>>.from(peopleResponse);

        // Merge gallery and services for products
        List<Map<String, dynamic>> products = [];
        for (var item in galleryResults) {
          products.add({...item, 'type': 'gallery'});
        }
        for (var item in serviceResults) {
          products.add({...item, 'type': 'service'});
        }
        _productSearchResults = products;

        _isSearchingPeople = false;
        _isSearchingProducts = false;
      });
    } catch (e) {
      debugPrint('Error performing search: $e');
      safeSetState(() {
        _isSearchingPeople = false;
        _isSearchingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _vibesFilterNotifier.dispose();
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _chatTabIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

  Future<void> _checkAppUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final updateData = await supabase
          .from('app_updates')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (updateData == null) return;

      final bool isAndroid = io.Platform.isAndroid;
      final bool isIOS = io.Platform.isIOS;
      
      final String? storeVersion = isAndroid 
          ? updateData['android_version'] 
          : (isIOS ? updateData['ios_version'] : null);
      
      final bool isActive = isAndroid 
          ? (updateData['android_active'] ?? false) 
          : (isIOS ? (updateData['ios_active'] ?? false) : false);
          
      final String? storeLink = isAndroid 
          ? updateData['android_link'] 
          : (isIOS ? updateData['ios_link'] : null);

      if (storeVersion != null && isActive) {
        if (_shouldUpdate(currentVersion, storeVersion)) {
          _showUpdateDialog(updateData, storeLink, storeVersion);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  bool _shouldUpdate(String current, String store) {
    try {
      final currentParts = current.split('.');
      final storeParts = store.split('.');
      for (var i = 0; i < math.min(currentParts.length, storeParts.length); i++) {
        final currentPart = int.parse(currentParts[i]);
        final storePart = int.parse(storeParts[i]);
        if (storePart > currentPart) return true;
        if (storePart < currentPart) return false;
      }
      return storeParts.length > currentParts.length;
    } catch (_) {
      return false;
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateData, String? appStoreLink, String storeVersion) {
    final title = updateData['title'] ?? 'New Update Available';
    final description = updateData['description'] ?? 'A new version with exciting features is available now.';
    final features = List<String>.from(updateData['features'] ?? []);
    final isMandatory = updateData['is_mandatory'] ?? false;

    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) => material.BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: material.Dialog(
          backgroundColor: material.Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: material.Colors.yellow.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: material.Colors.yellow.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: material.Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: material.Colors.yellow.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(material.Icons.system_update_rounded, color: material.Colors.yellow, size: 28),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: material.Colors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v$storeVersion',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: material.Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    color: material.Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
                if (features.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "What's New:",
                    style: TextStyle(
                      color: material.Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: material.ListView.builder(
                      shrinkWrap: true,
                      itemCount: features.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•", style: TextStyle(color: material.Colors.yellow)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                features[i],
                                style: TextStyle(color: material.Colors.white.withValues(alpha: 0.8), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    if (!isMandatory)
                      Expanded(
                        child: material.TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: material.TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Later',
                            style: TextStyle(color: material.Colors.white.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    if (!isMandatory) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: material.ElevatedButton(
                        style: material.ElevatedButton.styleFrom(
                          backgroundColor: material.Colors.yellow,
                          foregroundColor: material.Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (appStoreLink != null) {
                            final url = Uri.parse(appStoreLink);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          }
                          if (mounted && !isMandatory) Navigator.pop(context);
                        },
                        child: const Text(
                          'Update Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSettings() {
    Navigator.of(context).push(
      material.MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _navigateToTool(String title) {
    material.Widget? page;
    int? initialTab;

    switch (title) {
      case 'Drawing Tool':
        page = const DrawingPage();
        break;
      case 'Schedule':
        initialTab = 0;
        break;
      case 'Tasks':
        initialTab = 1;
        break;
      case 'Challenges':
        initialTab = 2;
        break;
      case 'Diagrams':
        initialTab = 3;
        break;
      case 'Teams':
        initialTab = 4;
        break;
      case 'AI Tools':
        initialTab = 5;
        break;
      case 'Poster Maker':
        page = const TemplateGalleryPage();
        break;
      case 'Bulk Sender':
        page = const BulkSenderPage();
        break;
      case 'Poki Games':
        page = const PokiGamesPage();
        break;
      case 'Travel Radar':
        page = const NearbyUsersPage();
        break;
    }

    if (initialTab != null) {
      page = ToolsPage(
        onFavoriteToggled: _handleRefresh,
        initialTab: initialTab,
      );
    }

    if (page != null) {
      Navigator.push(
          context, material.MaterialPageRoute(builder: (_) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        color: material.Colors.black,
        child: ScaffoldPage(
          padding: EdgeInsets.zero,
          bottomBar: _buildBottomNavigationBar(context),
          content: material.ColoredBox(
            color: material.Colors.black,
            child: _isLoading
                ? const Center(child: ProgressRing())
                : _currentIndex == 1
                    ? const MainMarketPage()
                    : _currentIndex == 2
                        ? ToolsPage(onFavoriteToggled: _handleRefresh)
                        : _currentIndex == 3
                            ? const DrawingAcademyHomePage()
                            : material.RefreshIndicator(
                                onRefresh: _handleRefresh,
                                color: material.Colors.yellow,
                                backgroundColor: material.Colors.black,
                                child: material.NestedScrollView(
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  headerSliverBuilder:
                                      (context, innerBoxIsScrolled) {
                                    return [
                                      // Unified Coordinated Header
                                      SliverPersistentHeader(
                                        pinned: false,
                                        delegate: _HomeMainHeaderDelegate(
                                          currentUserId:
                                              supabase.auth.currentUser?.id ??
                                                  '',
                                          currentProfileId: profileId ?? '',
                                          statusRefreshKey: _refreshKeyCount,
                                          activeUsersRef: ref.watch(
                                              activeUsersProvider(
                                                  profileId ?? '')),
                                          onTapVideo: () =>
                                              _handleStrangerMatch(
                                            context,
                                            ref,
                                            'Video',
                                            profileId ?? '',
                                          ),
                                          onTapFriends: () {
                                            displayInfoBar(context,
                                                builder: (context, close) {
                                              return const InfoBar(
                                                title:
                                                    Text('Friends Match'),
                                                content: Text(
                                                    'Strangers Match feature is calibrating for your region.'),
                                                severity: InfoBarSeverity.info,
                                              );
                                            });
                                          },
                                          onTapCall: () => _handleStrangerMatch(
                                            context,
                                            ref,
                                            'Voice',
                                            profileId ?? '',
                                          ),
                                          onTapText: () => _handleStrangerMatch(
                                            context,
                                            ref,
                                            'Text',
                                            profileId ?? '',
                                          ),
                                          onTapSettings: _handleSettings,
                                          onTapAdd: () =>
                                              _showAddBottomSheet(context),
                                          onRefresh: _handleRefresh,
                                          // Tab Bar params
                                          selectedIndex: _chatTabIndex,
                                          onTabTap: _onTabTapped,
                                          // Search params
                                          searchController: _searchController,
                                          searchQuery: _searchQuery,
                                          isSearching: _isSearchingPeople,
                                          vibesFilterNotifier: _vibesFilterNotifier,
                                        ),
                                      ),
                                    ];
                                  },
                                  body: material.Builder(
                                    builder: (context) => material.Material(
                                      color: material.Colors.black,
                                      child: PageView(
                                        controller: _pageController,
                                        onPageChanged: _onPageChanged,
                                        children: [
                                          material.CustomScrollView(
                                            physics: const BouncingScrollPhysics(
                                                parent:
                                                    AlwaysScrollableScrollPhysics()),
                                            slivers: [
                                              _buildChatListSliver(
                                                  conversationsAsync),
                                            ],
                                          ),
                                          _buildVibesSection(),
                                          ThoughtsFeedSection(
                                            currentUserId: _currentUserId ?? '',
                                            currentProfileId: profileId ?? '',
                                            onStatusShared: _handleRefresh,
                                            searchQuery: _chatTabIndex == 2
                                                ? _searchQuery
                                                : '',
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
    );
  }

  Future<void> _handleRefresh() async {
    // Refresh all main data providers
    try {
      setState(() {
        _refreshKeyCount++;
      });
      await Future.wait([
        ref.refresh(conversationsProvider.future),
        ref.refresh(activeUsersProvider(profileId.toString()).future),
      ]);
    } catch (e) {
      debugPrint('Error refreshing home page: $e');
    }
  }

  Widget _buildVibesSection() {
    return StatusDisplayWidget(
      key: ValueKey('vibes_list_$_refreshKeyCount'),
      currentUserId: _currentUserId ?? '',
      currentProfileId: profileId ?? '',
      searchQuery: _chatTabIndex == 1 ? _searchQuery : '',
      filterNotifier: _vibesFilterNotifier,
      isVertical: true,
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

        // Sort by pinned status then last message time
        combined.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;

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
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (_searchQuery.isNotEmpty) ...[
              // Search Tabs (People / Products)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildSearchTabItem('People', 0),
                      const SizedBox(width: 12),
                      _buildSearchTabItem('Products', 1),
                    ],
                  ),
                ),
              ),

              if (_searchTabIndex == 0) ...[
                // People Search Results
                if (_personSearchResults.isEmpty && !_isSearchingPeople)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: Text('No people found',
                              style:
                                  TextStyle(color: material.Colors.white70))),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final person = _personSearchResults[index];
                        return _buildPersonResultTile(person);
                      },
                      childCount: _personSearchResults.length,
                    ),
                  ),
              ] else ...[
                // Products Search Results
                if (_productSearchResults.isEmpty && !_isSearchingProducts)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: Text('No products found',
                              style:
                                  TextStyle(color: material.Colors.white70))),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _productSearchResults[index];
                        return _buildProductResultTile(product);
                      },
                      childCount: _productSearchResults.length,
                    ),
                  ),
              ],
            ],
            if (_searchQuery.isNotEmpty && filteredConversations.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.chat,
                          size: 18, color: material.Colors.yellow),
                      const SizedBox(width: 8),
                      Text(
                        'Conversations',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: material.Colors.yellow,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (filteredConversations.isNotEmpty)
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
                        if (conversation.isTool) {
                          _navigateToTool(conversation.toolTitle ?? '');
                          return;
                        }

                        if (conversation.isNotification) {
                          _showNotificationDetails(context, conversation);
                        } else if (conversation.isActiveTimer) {
                          if (conversation.teamData != null) {
                            try {
                              final team = Team.fromJson(conversation.teamData!);
                              Navigator.push(
                                context,
                                material.MaterialPageRoute(
                                  builder: (context) => TeamDetailPage(team: team),
                                ),
                              );
                            } catch (e) {
                              debugPrint('Error parsing team from timer: $e');
                            }
                          }
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
                          // Mark as read
                          ref
                              .read(conversationsProvider.notifier)
                              .markAsRead(conversation.id, false);

                          Navigator.push(
                            context,
                            material.MaterialPageRoute(
                              builder: (context) => WhatsAppGroupChat(
                                groupId: 'p:${conversation.id}',
                                groupName: conversation.name,
                                groupImage: conversation.imageUrl,
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
            if (combined.isEmpty ||
                (_searchQuery.isNotEmpty &&
                    filteredConversations.isEmpty &&
                    _personSearchResults.isEmpty))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty
                            ? FluentIcons.chat
                            : FluentIcons.search,
                        size: 64,
                        color: material.Colors.white.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No conversations yet'
                            : 'No results for "$_searchQuery"',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: material.Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const ChatListShimmer(),
      error: (error, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Error loading chats: $error',
              style: const material.TextStyle(color: material.Colors.red),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildBottomNavigationBar(BuildContext context) {
    final bottomPadding = material.MediaQuery.of(context).padding.bottom;
    return Container(
      height: 95 + bottomPadding, // Increased height for premium feel
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: material.Colors.black, // Pure black background
        border: Border(
          top: BorderSide(
            color: material.Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: material.Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
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
            _buildNavItem(
              icon: FluentIcons.education,
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
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
        if (isAuthenticated && mounted) {
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
        if (isAuthenticated && mounted) {
          final loggedInUser = supabase.auth.currentUser;
          if (loggedInUser != null) {
            Navigator.push(
              context,
              material.MaterialPageRoute(
                builder: (context) =>
                    VerfiedSwitchPage(userId: loggedInUser.id),
              ),
            );
          }
        }
      },
      child: material.SizedBox(
        height: 70,
        child: material.Center(
          child: CircularProfileImage(
            profileImageUrl: _profileImageUrl,
            radius: 22.0,
            borderColor: FlutterFlowTheme.of(context).primary,
          ),
        ),
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
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
                    : material.Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryText,
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
                          if (isAuthenticated && mounted) {
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
                                      .withValues(alpha: 0.8),
                                  FlutterFlowTheme.of(context)
                                      .secondary
                                      .withValues(alpha: 0.8),
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
                                      .withValues(alpha: 0.8),
                                  FlutterFlowTheme.of(context)
                                      .secondary
                                      .withValues(alpha: 0.8),
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
                          if (isAuthenticated && mounted) {
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
                                      .withValues(alpha: 0.8),
                                  FlutterFlowTheme.of(context)
                                      .secondary
                                      .withValues(alpha: 0.8),
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
                            if (isAuthenticated && mounted) {
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
                                        .withValues(alpha: 0.8),
                                    FlutterFlowTheme.of(context)
                                        .secondary
                                        .withValues(alpha: 0.8),
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
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          const material.SnackBar(
              content: Text('Connecting to active network...')),
        );
      }
      return;
    }

    final activeFriends = activeUsersState.value!.activeFriends;

    // 2. Filter out self (already done in provider, but double check)
    // and potentially filter by interests if we had that data.
    // 3. Match Logic
    Map<String, dynamic> randomUser;
    if (activeFriends.isNotEmpty) {
      randomUser = (activeFriends..shuffle()).first;
    } else {
      final List<dynamic> allUsersData = await ref
          .read(groups_provider.supabaseClientProvider)
          .from('profile')
          .select('id, user_id, name, profile_image_url')
          .neq('id', currentProfileId)
          .limit(10);

      if (allUsersData.isEmpty) {
        if (mounted) {
          material.ScaffoldMessenger.of(context).showSnackBar(
            const material.SnackBar(content: Text('No users found in system.')),
          );
        }
        return;
      }
      final users = List.from(allUsersData);
      users.shuffle();
      // randomUser = users.first as Map<String, dynamic>; // Unused
    }

    // 4. Initiate Call Directly
    if (mode == 'Text') {
      if (mounted) {
        Navigator.push(
          context,
          material.MaterialPageRoute(
            builder: (context) => const NativeWebRTCCallScreen(
              mode: 'Text',
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Finding a stranger...')),
      );
    }

    if (mounted) {
      Navigator.push(
        context,
        material.MaterialPageRoute(
          builder: (context) => NativeWebRTCCallScreen(
            mode: mode,
          ),
        ),
      );
    }
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
            color: material.Colors.black,
            border: Border(
              bottom: BorderSide(
                color: material.Colors.white.withValues(alpha: 0.08),
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
                        color: material.Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.chevron_right,
                color: material.Colors.white.withValues(alpha: 0.2),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTabItem(String label, int index) {
    final isSelected = _searchTabIndex == index;
    return material.InkWell(
      onTap: () => safeSetState(() => _searchTabIndex = index),
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? material.Colors.yellow
              : material.Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: material.Colors.yellow.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? material.Colors.black : material.Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonResultTile(Map<String, dynamic> person) {
    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: () {
          Navigator.push(
            context,
            material.MaterialPageRoute(
              builder: (context) => VerfiedSearchProfileDetailPage(
                userId: person['user_id'] ?? '',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: material.Colors.white.withValues(alpha: 0.03),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircularProfileImage(
                profileImageUrl: person['profile_image_url'],
                radius: 28,
                isVerified: person['verified'] ?? false,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person['name'] ?? person['shop_name'] ?? 'Unknown',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: material.Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      person['bio'] != null &&
                              person['bio'].toString().isNotEmpty
                          ? person['bio']
                          : 'Hey there! I am using Handskill Friends.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: material.Colors.white.withValues(alpha: 0.5),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.chevron_right,
                size: 12,
                color: material.Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductResultTile(Map<String, dynamic> product) {
    final profile = product['profile'] as Map<String, dynamic>?;
    final bool isService = product['type'] == 'service';

    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: () {
          Navigator.push(
            context,
            material.MaterialPageRoute(
              builder: (context) => VerfiedSearchProfileDetailPage(
                userId: product['user_id'] ?? '',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: material.Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: material.Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'search_result_${product['id']}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: product['image_url'] != null
                          ? CachedNetworkImageProvider(product['image_url'])
                          : const material.AssetImage(
                                  'assets/images/placeholder.png')
                              as material.ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: material.Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isService
                                ? material.Colors.blue
                                : material.Colors.purple)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isService ? 'SERVICE' : 'GALLERY',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isService
                              ? material.Colors.blue.shade300
                              : material.Colors.purple.shade300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product['title'] ?? 'Product',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: material.Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'by ${profile?['name'] ?? 'Unknown'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: material.Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (product['price'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${product['price']}',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: material.Colors.yellow,
                      ),
                    ),
                    Text(
                      'Best Price',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: material.Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
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
            const Icon(material.Icons.notifications_active,
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
                color: material.Colors.white.withValues(alpha: 0.9),
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
              child: const Text('Decline',
                  style: material.TextStyle(color: material.Colors.red)),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await TeamsService().acceptInvite(notification.sourceId!);
                await ref
                    .read(conversationsProvider.notifier)
                    .dismissNotification(notification.id);
                if (mounted) {
                  material.ScaffoldMessenger.of(context).showSnackBar(
                    const material.SnackBar(content: Text('Invitation accepted!')),
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(material.Colors.yellow),
              ),
              child: const Text('Accept',
                  style: material.TextStyle(color: material.Colors.black)),
            ),
          ] else ...[
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(conversationsProvider.notifier)
                    .dismissNotification(notification.id);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(material.Colors.yellow),
              ),
              child: const Text('Dismiss',
                  style: material.TextStyle(color: material.Colors.black)),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeMainHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String currentUserId;
  final String currentProfileId;
  final AsyncValue<ActiveUsersData> activeUsersRef;
  final VoidCallback onTapVideo;
  final VoidCallback onTapFriends;
  final VoidCallback onTapCall;
  final VoidCallback onTapText;
  final VoidCallback onTapSettings;
  final VoidCallback onTapAdd;
  final int statusRefreshKey;
  final VoidCallback onRefresh;

  // Tab Bar fields
  final int selectedIndex;
  final ValueChanged<int> onTabTap;

  // Search fields
  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearching;
  final ValueNotifier<String> vibesFilterNotifier;

  _HomeMainHeaderDelegate({
    required this.currentUserId,
    required this.currentProfileId,
    required this.activeUsersRef,
    required this.onTapVideo,
    required this.onTapFriends,
    required this.onTapCall,
    required this.onTapText,
    required this.onTapSettings,
    required this.onTapAdd,
    required this.statusRefreshKey,
    required this.onRefresh,
    required this.selectedIndex,
    required this.onTabTap,
    required this.searchController,
    required this.searchQuery,
    required this.isSearching,
    required this.vibesFilterNotifier,
  });

  @override
  double get maxExtent =>
      452.0; // 160 (Stranger Match) + 170 (Status) + 50 (Tabs) + 72 (Search)

  @override
  double get minExtent => 282.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const double strangerMatchHeight = 160.0;
    const double statusSectionHeight = 170.0;

    final double progress =
        (shrinkOffset / strangerMatchHeight).clamp(0.0, 1.0);
    final double topPadding = MediaQuery.of(context).padding.top;

    return material.Material(
      color: material.Colors.black,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Sliding Stranger Match Cards
          Positioned(
            top: -shrinkOffset * 0.8,
            left: 0,
            right: 0,
            height: strangerMatchHeight,
            child: Opacity(
              opacity: (1 - progress * 1.2).clamp(0.0, 1.0),
              child: Stack(
                children: [
                  // Gradient Background
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            material.Colors.black,
                            material.Colors.black
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Match Cards
                  Positioned(
                    top: topPadding + 10,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Handskill',
                          style: GoogleFonts.outfit(
                            color: material.Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildMatchCard(
                              label: 'Video',
                              icon: FluentIcons.video,
                              color: material.Colors.blue,
                              onTap: onTapVideo,
                            ),
                            const SizedBox(width: 8),
                            _buildMatchCard(
                              label: 'Voice',
                              icon: FluentIcons.phone,
                              color: material.Colors.green,
                              onTap: onTapCall,
                            ),
                            const SizedBox(width: 8),
                            _buildMatchCard(
                              label: 'Chat',
                              icon: FluentIcons.chat,
                              color: material.Colors.yellow,
                              onTap: onTapText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Top Header with Search, Settings
                  Positioned(
                    top: topPadding + 10,
                    right: 16,
                    child: Row(
                      children: [
                        _buildHeaderIconButton(
                          icon: FluentIcons.search,
                          onTap: () {
                            Navigator.push(
                              context,
                              material.MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderIconButton(
                          icon: FluentIcons.settings,
                          onTap: onTapSettings,
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderIconButton(
                          icon: FluentIcons.refresh,
                          onTap: onRefresh,
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderIconButton(
                          icon: FluentIcons.add_friend,
                          onTap: () async {
                            final auth =
                                await AuthAlertBox.checkAuthAndShowAlert(
                                    context: context);
                            if (auth) {
                              showDialog(
                                  context: context,
                                  builder: (context) => CreateGroupDialog(
                                      onGroupCreated: onRefresh));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Sticky Section (Status + Tabs + Search)
          Positioned(
            top: (strangerMatchHeight - shrinkOffset).clamp(0.0, 400.0),
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Horizontal Status Row (Always Sticky)
                Container(
                  height: statusSectionHeight,
                  decoration: BoxDecoration(
                    color: material.Colors.black,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                          color: material.Colors.white.withValues(alpha: 0.12),
                          width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          children: [
                            material.InkWell(
                              onTap: onTapAdd,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      material.Colors.yellow,
                                      material.Colors.yellow
                                          .withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: material.Colors.yellow
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(FluentIcons.add,
                                        size: 14, color: material.Colors.black),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Add',
                                      style: GoogleFonts.outfit(
                                        color: material.Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            activeUsersRef.when(
                              data: (data) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActiveCounter(data.activeFriends.length),
                                ],
                              ),
                              loading: () => const SizedBox(
                                width: 14,
                                height: 14,
                                child: ProgressRing(),
                              ),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                      StatusDisplayWidget(
                        key: ValueKey('status_display_$statusRefreshKey'),
                        currentUserId: currentUserId,
                        currentProfileId: currentProfileId,
                        onStatusUploaded: onRefresh,
                        filterNotifier: vibesFilterNotifier,
                      ),
                    ],
                  ),
                ),
                // Tab Bar
                Container(
                  height: 50,
                  color: material.Colors.black,
                  child: Row(
                    children: [
                      _buildTabItem('Chats', 0),
                      _buildTabItem('Vibes', 1),
                      _buildTabItem('Thoughts', 2),
                    ],
                  ),
                ),
                // Search Bar
                Container(
                  height: 72,
                  color: material.Colors.black,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: material.Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: material.Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: TextBox(
                      controller: searchController,
                      placeholder: 'Search for people or conversations...',
                      placeholderStyle: GoogleFonts.outfit(
                        color: material.Colors.white.withValues(alpha: 0.35),
                        fontSize: 14,
                      ),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: Icon(
                          FluentIcons.search,
                          color: material.Colors.yellow.withValues(alpha: 0.6),
                          size: 18,
                        ),
                      ),
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSearching)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: ProgressRing(),
                              ),
                            ),
                          if (searchQuery.isNotEmpty)
                            material.Material(
                              color: material.Colors.transparent,
                              child: material.IconButton(
                                icon: Icon(
                                  FluentIcons.clear,
                                  color: material.Colors.white
                                      .withValues(alpha: 0.3),
                                  size: 16,
                                ),
                                onPressed: () => searchController.clear(),
                              ),
                            ),
                        ],
                      ),
                      decoration: WidgetStateProperty.all(BoxDecoration(
                        color: material.Colors.transparent,
                        border: Border.all(style: BorderStyle.none),
                      )),
                      style: GoogleFonts.outfit(
                        color: material.Colors.white,
                        fontSize: 14,
                      ),
                      cursorColor: material.Colors.yellow,
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

  Widget _buildTabItem(String label, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          onTap: () => onTabTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: isSelected
                  ? const Border(
                      bottom: BorderSide(
                        color: material.Colors.yellow,
                        width: 2.5,
                      ),
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? material.Colors.yellow
                    : material.Colors.white.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: material.Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: material.Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMatchIcon(icon, color),
                const SizedBox(width: 8),
                Text(label,
                    style: GoogleFonts.outfit(
                        color: material.Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }



  Widget _buildActiveCounter(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF10B981), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$count Active',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: material.Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: material.Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Icon(icon, color: material.Colors.white, size: 20),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeMainHeaderDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.searchQuery != searchQuery ||
        oldDelegate.isSearching != isSearching ||
        oldDelegate.statusRefreshKey != statusRefreshKey ||
        oldDelegate.activeUsersRef != activeUsersRef ||
        oldDelegate.vibesFilterNotifier != vibesFilterNotifier;
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
    this.borderColor = material.Colors.yellow,
    this.borderWidth = 1.0,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: material.Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: profileImageUrl != null
            ? CachedNetworkImage(
                imageUrl: profileImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: material.Colors.grey.withValues(alpha: 0.1),
                ),
                errorWidget: (context, url, error) => Icon(
                    FluentIcons.contact,
                    color: material.Colors.grey,
                    size: radius),
              )
            : Icon(FluentIcons.contact,
                color: material.Colors.grey, size: radius),
      ),
    );
  }
}

// --- Original delegates removed, merged into _HomeMainHeaderDelegate ---
