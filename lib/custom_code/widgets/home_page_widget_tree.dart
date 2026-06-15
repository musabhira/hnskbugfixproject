import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:async' as async;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart'
    as groups_provider;
import 'package:pocket_mates_app/custom_code/widgets/active_users_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';
import 'dart:io' as io;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/native_webrtc_call_screen.dart';
import 'package:pocket_mates_app/custom_code/widgets/conversation_tile.dart';

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
  static Color primaryColor = const Color(0xFFFFFC00);
  static Color secondaryColor = const Color(0xFFFFFC00);
  static Color accentColor = const Color(0xFFFFFC00);
  static const Color backgroundColor = material.Colors.black;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  ConsumerState<HomePageWidgetTree> createState() => _HomePageWidgetTreeState();
}

class _HomePageWidgetTreeState extends ConsumerState<HomePageWidgetTree> {
  final supabase = SupaFlow.client;
  // final scaffoldKey = GlobalKey<ScaffoldState>(); // Removed ScaffoldKey
  int _currentIndex = 1;
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
          .limit(20);

      safeSetState(() {
        _personSearchResults = List<Map<String, dynamic>>.from(peopleResponse);

        // Map gallery results for products (marking services appropriately)
        List<Map<String, dynamic>> products = [];
        for (var item in galleryResults) {
          final isService = item['is_service'] == true;
          products.add({...item, 'type': isService ? 'service' : 'gallery'});
        }
        _productSearchResults = products;

        _isSearchingPeople = false;
        _isSearchingProducts = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
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
      debugPrint('Cache error: $e');
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
      debugPrint('User data load error: $e');
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
      debugPrint('Update check error: $e');
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
              border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
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
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(material.Icons.system_update_rounded, color: const Color(0xFFFFFC00), size: 28),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
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
                      color: const Color(0xFFF59E0B),
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
                            const Text("•", style: TextStyle(color: const Color(0xFFFFFC00))),
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
                          backgroundColor: const Color(0xFFFFFC00),
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
                          if (!mounted) return;
                          if (!isMandatory) {
                            Navigator.pop(context);
                          }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [const Color(0xFF111B21), const Color(0xFF0B141A)]
        : [const Color(0xFFF4F4F9), const Color(0xFFFFFFFF)];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: material.Scaffold(
          backgroundColor: material.Colors.transparent,
          bottomNavigationBar: _buildBottomNavigationBar(context),
          body: material.ColoredBox(
            color: material.Colors.transparent,
            child: _isLoading
                ? Center(
                    child: material.CircularProgressIndicator(
                      color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                    ),
                  )
                : _currentIndex == 0
                    ? ToolsPage(onFavoriteToggled: _handleRefresh)
                    : _currentIndex == 2
                        ? const MainMarketPage()
                        : material.RefreshIndicator(
                                onRefresh: _handleRefresh,
                                color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                backgroundColor: isDark ? const Color(0xFF121218) : const Color(0xFFF4F4F9),
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
                                            material.ScaffoldMessenger.of(context).showSnackBar(
                                              material.SnackBar(
                                                content: const Text(
                                                    'Strangers Match feature is calibrating for your region.'),
                                                backgroundColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                              ),
                                            );
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
                                      color: material.Colors.transparent,
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
      debugPrint('Refresh error: $e');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                // People: Filtered Active Conversations first
                if (filteredConversations.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'Active Chats',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: material.Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
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
                                  debugPrint('Team error: $e');
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
                        );
                      },
                      childCount: filteredConversations.length,
                    ),
                  ),
                ],

                // Recommended registered user profiles horizontally at the bottom
                SliverToBoxAdapter(
                  child: _personSearchResults.isEmpty && !_isSearchingPeople
                      ? (filteredConversations.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 80),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    material.Icons.search_rounded,
                                    size: 64,
                                    color: material.Colors.white.withValues(alpha: 0.1),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No results for "$_searchQuery"',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: material.Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                              child: Row(
                                children: [
                                  Icon(material.Icons.people_rounded,
                                      size: 18, color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SUGGESTED PEOPLE',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _personSearchResults.length,
                                itemBuilder: (context, index) {
                                  final person = _personSearchResults[index];
                                  final name = person['name'] ?? 'Unknown';
                                  final avatarUrl = person['profile_image_url'];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        material.MaterialPageRoute(
                                          builder: (context) => WhatsAppGroupChat(
                                            groupId: 'p:${person['user_id']}',
                                            groupName: name,
                                            groupImage: avatarUrl,
                                          ),
                                        ),
                                      ).then((_) {
                                        ref.refresh(conversationsProvider.future);
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: (isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00)).withValues(alpha: 0.5),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 26,
                                              backgroundImage: avatarUrl != null
                                                  ? NetworkImage(avatarUrl)
                                                  : null,
                                              backgroundColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                              child: avatarUrl == null
                                                  ? Text(
                                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                                      style: const TextStyle(
                                                        color: material.Colors.black,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            name,
                                            style: GoogleFonts.outfit(
                                              color: material.Colors.white.withValues(alpha: 0.8),
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
            ] else ...[
              // Standard View (No Search Query)
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
                                debugPrint('Team error: $e');
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
                      );
                    },
                    childCount: filteredConversations.length,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          material.Icons.chat_bubble_rounded,
                          size: 64,
                          color: material.Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
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
          ],
        );
      },
      loading: () => const ChatListShimmer(),
      error: (error, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Chat error: $error',
              style: const material.TextStyle(color: material.Colors.red),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildBottomNavigationBar(BuildContext context) {
    final bottomPadding = material.MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF111B21) : const Color(0xFFFFFFFF);
    final borderColor = isDark 
        ? material.Colors.white.withValues(alpha: 0.08)
        : material.Colors.black.withValues(alpha: 0.08);
    final shadowColor = isDark 
        ? material.Colors.black.withValues(alpha: 0.4)
        : material.Colors.grey.withValues(alpha: 0.1);

    return Container(
      height: 65 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: navBgColor,
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
              icon: material.Icons.handyman_rounded,
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _buildNavItem(
              icon: material.Icons.chat_bubble_rounded,
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _buildNavItem(
              icon: material.Icons.storefront_rounded,
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _buildNavItem(
              icon: material.Icons.school_rounded,
              isSelected: false,
              onTap: () => _showElearningComingSoonDialog(context),
            ),
            _buildProfileNavItem(),
          ],
        ),
      ),
    );
  }

  void _showElearningComingSoonDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeYellow = isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00);
    showDialog(
      context: context,
      builder: (context) => material.Dialog(
        backgroundColor: material.Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? material.Colors.black.withOpacity(0.75) : material.Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: themeYellow.withOpacity(0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? material.Colors.black.withOpacity(0.6) : material.Colors.grey.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: themeYellow.withOpacity(0.08),
                    blurRadius: 45,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeYellow.withOpacity(0.15),
                          themeYellow.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: themeYellow.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(
                      material.Icons.school_rounded,
                      color: themeYellow,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Coming Soon!',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: isDark ? material.Colors.white : material.Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Handskill E-Learning Academy will be fully unlocked in the 2nd or 3rd build. Stay tuned for expert masterclasses, video tutorials, and interactive learning modules!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? material.Colors.white.withOpacity(0.8) : material.Colors.black.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeYellow,
                          themeYellow.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: themeYellow.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: material.ElevatedButton(
                      style: material.ElevatedButton.styleFrom(
                        backgroundColor: material.Colors.transparent,
                        foregroundColor: material.Colors.black,
                        shadowColor: material.Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Got It',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          ).then((_) {
            if (mounted) {
              _loadAllUserData();
            }
          });
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
            borderColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeYellow = isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00);
    return material.InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 55,
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? themeYellow.withValues(alpha: 0.15)
                    : material.Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? themeYellow
                    : (isDark ? material.Colors.white.withValues(alpha: 0.5) : material.Colors.black.withValues(alpha: 0.45)),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    material.showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121218) : const Color(0xFFF4F4F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Content',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? material.Colors.white : material.Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
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
                                const Icon(material.Icons.shopping_cart_rounded,
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
                                const Icon(material.Icons.lightbulb_rounded,
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
                ],
              ),
              if (_isVerified) ...[
                const SizedBox(height: 12),
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
                                  const Icon(material.Icons.calendar_month_rounded,
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
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              material.SizedBox(
                width: double.infinity,
                child: material.OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: material.OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? material.Colors.white.withValues(alpha: 0.2) : material.Colors.black.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel', style: TextStyle(color: isDark ? material.Colors.white70 : material.Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStrangerMatch(
    BuildContext context,
    WidgetRef ref,
    String mode,
    String currentProfileId,
  ) async {
    final activeUsersState = ref.read(activeUsersProvider(currentProfileId));

    if (!activeUsersState.hasValue) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
              content: Text('Connecting to active network...')),
      );
      return;
    }

    final activeFriends = activeUsersState.value!.activeFriends;

    // 2. Filter out self (already done in provider, but double check)
    // and potentially filter by interests if we had that data.
    // 3. Match Logic
    if (activeFriends.isEmpty) {
      final List<dynamic> allUsersData = await ref
          .read(groups_provider.supabaseClientProvider)
          .from('profile')
          .select('id, user_id, name, profile_image_url')
          .neq('id', currentProfileId)
          .limit(10);

      if (allUsersData.isEmpty) {
        if (mounted) {
          material.debugPrint('No users found in system.');
          material.ScaffoldMessenger.of(context).showSnackBar(
            const material.SnackBar(content: Text('No users found in system.')),
          );
        }
        return;
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.05) 
        : Colors.black.withValues(alpha: 0.05);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark 
        ? Colors.white.withValues(alpha: 0.4) 
        : Colors.black.withValues(alpha: 0.45);

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
            color: material.Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: borderColor,
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        material.Icons.notifications_rounded,
                        color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                        size: 26,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: material.Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF111B21) : const Color(0xFFFFFFFF),
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: material.Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.outfit(
                        color: primaryTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You have $count new notification${count > 1 ? 's' : ''}',
                      style: GoogleFonts.outfit(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: secondaryTextColor.withValues(alpha: 0.5),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return material.InkWell(
      onTap: () => safeSetState(() => _searchTabIndex = index),
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00))
              : material.Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00)).withValues(alpha: 0.3),
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
              builder: (context) => MainProfileWidget(
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
                Icons.chevron_right,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: () {
          Navigator.push(
            context,
            material.MaterialPageRoute(
              builder: (context) => MainProfileWidget(
                userId: product['user_id'] ?? '',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark 
                ? material.Colors.white.withValues(alpha: 0.02)
                : material.Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                  ? material.Colors.white.withValues(alpha: 0.05)
                  : material.Colors.black.withValues(alpha: 0.05),
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
                        color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
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
      builder: (context) => material.AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(material.Icons.notifications_active,
                color: const Color(0xFFFFFC00), size: 28),
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
            material.TextButton(
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
            material.ElevatedButton(
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
              style: material.ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: material.Colors.black,
              ),
              child: const Text('Accept',
                  style: material.TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            material.ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(conversationsProvider.notifier)
                    .dismissNotification(notification.id);
              },
              style: material.ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: material.Colors.black,
              ),
              child: const Text('Dismiss',
                  style: material.TextStyle(fontWeight: FontWeight.bold)),
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
      417.0; // 135 (Stranger Match) + 160 (Status) + 50 (Tabs) + 72 (Search)

  @override
  double get minExtent => 282.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const double strangerMatchHeight = 135.0;
    const double statusSectionHeight = 160.0;

    final double progress =
        (shrinkOffset / strangerMatchHeight).clamp(0.0, 1.0);
    final double topPadding = MediaQuery.of(context).padding.top;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? const Color(0xFF111B21) : const Color(0xFFF4F4F9);

    return material.Material(
      color: headerColor,
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
                      decoration: BoxDecoration(
                        color: headerColor,
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
                            color: isDark ? material.Colors.white : material.Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildMatchCard(
                              context,
                              label: 'Video',
                              icon: material.Icons.videocam_rounded,
                              color: material.Colors.blue,
                              onTap: onTapVideo,
                            ),
                            const SizedBox(width: 8),
                            _buildMatchCard(
                              context,
                              label: 'Voice',
                              icon: material.Icons.phone_rounded,
                              color: material.Colors.green,
                              onTap: onTapCall,
                            ),
                            const SizedBox(width: 8),
                            _buildMatchCard(
                              context,
                              label: 'Chat',
                              icon: material.Icons.chat_bubble_rounded,
                              color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
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
                          context,
                          icon: material.Icons.search_rounded,
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
                          context,
                          icon: material.Icons.settings_rounded,
                          onTap: onTapSettings,
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderIconButton(
                          context,
                          icon: material.Icons.refresh_rounded,
                          onTap: onRefresh,
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderIconButton(
                          context,
                          icon: material.Icons.person_add_rounded,
                          onTap: () async {
                            final auth =
                                await AuthAlertBox.checkAuthAndShowAlert(
                                    context: context);
                            if (auth && context.mounted) {
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
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                          color: isDark 
                              ? material.Colors.white.withValues(alpha: 0.12)
                              : material.Colors.black.withValues(alpha: 0.08),
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
                                      isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                      (isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00))
                                          .withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00))
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(material.Icons.add_rounded,
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
                              loading: () => SizedBox(
                                width: 14,
                                height: 14,
                                child: material.CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                ),
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
                  color: headerColor,
                  child: Row(
                    children: [
                      _buildTabItem(context, 'Chats', 0),
                      _buildTabItem(context, 'Vibes', 1),
                      _buildTabItem(context, 'Thoughts', 2),
                    ],
                  ),
                ),
                // Search Bar
                Container(
                  height: 72,
                  color: headerColor,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF202C33) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark 
                            ? material.Colors.white.withValues(alpha: 0.08)
                            : material.Colors.black.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: material.TextField(
                      controller: searchController,
                      style: GoogleFonts.outfit(
                        color: isDark ? material.Colors.white : material.Colors.black87,
                        fontSize: 14,
                      ),
                      cursorColor: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                      decoration: material.InputDecoration(
                        hintText: 'Search for people or conversations...',
                        hintStyle: GoogleFonts.outfit(
                          color: isDark 
                              ? material.Colors.white.withValues(alpha: 0.35)
                              : material.Colors.black.withValues(alpha: 0.35),
                          fontSize: 14,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                          child: Icon(
                            material.Icons.search_rounded,
                            color: isDark 
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.6)
                                : const Color(0xFFFFFC00).withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isSearching)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: material.CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00),
                                  ),
                                ),
                              ),
                            if (searchQuery.isNotEmpty)
                              material.Material(
                                color: material.Colors.transparent,
                                child: material.IconButton(
                                  icon: Icon(
                                    material.Icons.clear_rounded,
                                    color: isDark ? material.Colors.white30 : material.Colors.black38,
                                    size: 18,
                                  ),
                                  onPressed: () => searchController.clear(),
                                ),
                              ),
                          ],
                        ),
                        border: material.InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  Widget _buildTabItem(BuildContext context, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedIndex == index;
    final themeYellow = isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00);
    final textUnselected = isDark 
        ? material.Colors.white.withValues(alpha: 0.5) 
        : material.Colors.black.withValues(alpha: 0.5);

    return Expanded(
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          onTap: () => onTabTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border(
                      bottom: BorderSide(
                        color: themeYellow,
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
                    ? themeYellow
                    : textUnselected,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark 
        ? material.Colors.white.withValues(alpha: 0.05)
        : material.Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark
        ? material.Colors.white.withValues(alpha: 0.08)
        : material.Colors.black.withValues(alpha: 0.06);
    final textColor = isDark ? material.Colors.white : material.Colors.black87;

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
              color: cardBgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMatchIcon(icon, color),
                const SizedBox(width: 8),
                Text(label,
                    style: GoogleFonts.outfit(
                        color: textColor,
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
      BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark 
        ? material.Colors.white.withValues(alpha: 0.08)
        : material.Colors.black.withValues(alpha: 0.05);
    final borderColor = isDark 
        ? material.Colors.white.withValues(alpha: 0.05)
        : material.Colors.black.withValues(alpha: 0.05);
    final iconColor = isDark ? material.Colors.white : material.Colors.black87;

    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
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
    this.borderColor = const Color(0xFFFFFC00),
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
                    material.Icons.person_rounded,
                    color: material.Colors.grey,
                    size: radius),
              )
            : Icon(material.Icons.person_rounded,
                color: material.Colors.grey, size: radius),
      ),
    );
  }
}

// --- Original delegates removed, merged into _HomeMainHeaderDelegate ---

