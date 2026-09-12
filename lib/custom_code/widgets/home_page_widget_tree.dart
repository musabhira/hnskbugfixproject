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
import 'package:pocket_mates_app/custom_code/widgets/contacts_sync_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart'
    as groups_provider;
import 'package:pocket_mates_app/custom_code/widgets/active_users_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_login_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_ai_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';
import 'dart:io' as io;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:pocket_mates_app/custom_code/widgets/conversation_tile.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_learning_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_timer_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_daily_mission_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_snap_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/snap/snap_view_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';

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
  int _currentIndex = 2;
  String? profileId;
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
  final ValueNotifier<String> _vibesFilterNotifier =
      ValueNotifier<String>('Public');

  int _chatCategoryFilterIndex = 0; // 0: All, 1: Unread, 2: Requests, 3: Mates, 4: Groups
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoadingRequests = false;

  Future<void> _loadPendingRequests() async {
    final uid = _currentUserId ?? supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    if (mounted) setState(() => _isLoadingRequests = true);
    try {
      await PocketRobotService.checkAndTriggerOccasionalRobotSnaps(uid);
      await PocketRobotService.checkAndTriggerProactiveMatesMessages(uid);
      final reqs = await PocketMateService.getPendingRequests(uid);
      if (mounted) {
        setState(() {
          _pendingRequests = reqs;
          _isLoadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRequests = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _chatTabIndex);
    ContactsNameService().initialize();
    _loadCachedData();
    _loadAllUserData();
    _loadPendingRequests();
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
        final hasSeenEulaLocally =
            prefs.getBool('eula_accepted_${user.id}') ?? false;

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
        final day = (profileResponse['learning_day'] as num?)?.toInt() ??
            (profileResponse['learning_stage'] as num?)?.toInt() ??
            1;
        PocketMissionTimerService.instance.initForDay(day);
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
      for (var i = 0;
          i < math.min(currentParts.length, storeParts.length);
          i++) {
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

  void _showUpdateDialog(Map<String, dynamic> updateData, String? appStoreLink,
      String storeVersion) {
    final title = updateData['title'] ?? 'New Update Available';
    final description = updateData['description'] ??
        'A new version with exciting features is available now.';
    final features = List<String>.from(updateData['features'] ?? []);
    final isMandatory = updateData['is_mandatory'] ?? false;

    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) => material.BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: material.Dialog(
          backgroundColor: material.Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                  width: 1.5),
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
                      child: const Icon(material.Icons.system_update_rounded,
                          color: Color(0xFFFFFC00), size: 28),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                      color: Color(0xFFF59E0B),
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
                            const Text("•",
                                style:
                                    TextStyle(color: Color(0xFFFFFC00))),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                features[i],
                                style: TextStyle(
                                    color: material.Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 13),
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
                            style: TextStyle(
                                color: material.Colors.white
                                    .withValues(alpha: 0.5)),
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
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
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
      case 'Admin Panel':
      case 'Admin Studio':
      case 'Admin Dashboard':
        AdminAuthService.authenticateAndOpen(context);
        return;
      case 'Zoyrax POS Admin': // Legacy spelling fallback
      case 'Zoyarex POS Admin':
      case 'Zoyarex Super Admin':
        page = const ZoyarexLoginPage();
        break;
      case 'Zoyarex AI':
        page = const ZoyarexAiPage();
        break;
      case 'Drawing Tool':
        page = const DrawingPage();
        break;
      case 'Dual Recorder':
        page = const DualVideoRecorderWidget();
        break;
      case 'Schedule':
        initialTab = 0;
        break;
      case 'Tasks':
        initialTab = 1;
        break;
      case 'Challenges':
      case 'Habit Tracker':
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
      case 'Crazy Games':
        page = const CrazyGamesPage();
        break;
      case 'Travel Radar':
        page = const NearbyUsersPage();
        break;
      case 'Chess Match':
        page = const ChessMatchmakingPage();
        break;
      case 'Password Pro':
        page = const PasswordGeneratorPage();
        break;
      case 'WhatsApp Web':
        page = const DynamicWebViewPage(title: 'WhatsApp Web', url: 'https://web.whatsapp.com');
        break;
      case 'English Hub':
      case 'Voice Speaking Sprint':
        page = const EnglishLearningHubPage();
        break;
      case '90-Day English Tasks':
      case 'English Tasks':
      case 'English Learning Tasks':
      case '90-Day Tasks':
        page = EnglishTasksMasterHubPage(userId: _currentUserId);
        break;
      case '1-on-1 English Match':
      case 'Stage Match':
        page = const StagePeerMatchmakerPage();
        break;
      case 'Pocket Library':
        page = const PocketLibraryPage();
        break;
      case 'Avatar Studio & NFT':
        page = const VectorAvatarStudioPage();
        break;
      case 'Avatar Network':
        page = const AvatarNetworkExplorerPage();
        break;
      case 'POS Tool':
      case 'POS & Billing':
        page = const BusinessPOSPage();
        break;
      case 'Test Feature':
        page = const TestFeaturePage();
        break;
      case 'Dynamic Web App':
      case 'QR & Barcode':
      case 'World Clock':
      case 'Web Search':
        page = ToolsPage(onFavoriteToggled: _handleRefresh);
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
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: PocketDoodleBackgroundPainter(
                  color: const Color(0xFFFFFC00),
                  isDark: isDark,
                  opacityMultiplier: 0.5,
                ),
              ),
            ),
            material.Scaffold(
              backgroundColor: material.Colors.transparent,
              bottomNavigationBar: _buildBottomNavigationBar(context),
              floatingActionButton: _currentIndex == 1
                  ? Container(
                      height: 36,
                      margin: const EdgeInsets.only(bottom: 6),
                      child: material.FloatingActionButton.extended(
                        onPressed: () {
                          material.Navigator.push(
                            context,
                            material.MaterialPageRoute(
                              builder: (context) => const AnonymousEnglishChatPage(),
                            ),
                          );
                        },
                        backgroundColor: const Color(0xFFFFFC00),
                        foregroundColor: material.Colors.black,
                        elevation: 4,
                        highlightElevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎭', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        label: Text(
                          'Random',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: material.Colors.black,
                          ),
                        ),
                      ),
                    )
                  : null,
              body: material.ColoredBox(
                color: material.Colors.transparent,
                child: _isLoading
                ? Center(
                    child: material.CircularProgressIndicator(
                      color: isDark
                          ? const Color(0xFFFFFC00)
                          : const Color(0xFFFFFC00),
                    ),
                  )
                : _currentIndex == 0
                    ? const MainMarketPage()
                    : _currentIndex == 2
                        ? EnglishLearningGroupChatWidget(
                            onCancel: () => setState(() => _currentIndex = 1),
                          )
                        : _currentIndex == 3
                            ? EnglishTasksMasterHubPage(userId: _currentUserId)
                            : PocketSnapFlameRefresh(
                                onRefresh: _handleRefresh,
                                triggerDistance: 85.0,
                                maxPullDistance: 210.0,
                                restingHeight: 150.0,
                                child: material.NestedScrollView(
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) {
                                return [
                                  // Unified Coordinated Header
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: _HomeMainHeaderDelegate(
                                      topPadding: MediaQuery.of(context).padding.top,
                                      currentUserId:
                                          supabase.auth.currentUser?.id ?? '',
                                      currentProfileId: profileId ?? '',
                                      statusRefreshKey: _refreshKeyCount,
                                      activeUsersRef: ref.watch(
                                          activeUsersProvider(profileId ?? '')),
                                      onTapVideo: () => _handleStrangerMatch(
                                        context,
                                        ref,
                                        'Video',
                                        profileId ?? '',
                                      ),
                                      onTapFriends: () {
                                        material.ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          material.SnackBar(
                                            content: const Text(
                                                'Founder Match feature is calibrating for your region.'),
                                            backgroundColor: isDark
                                                ? const Color(0xFFFFFC00)
                                                : const Color(0xFFFFFC00),
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
                                      pendingRequestsCount: _pendingRequests.length,
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
                                      ToolsPage(
                                        onFavoriteToggled: _handleRefresh,
                                        externalSearchQuery: _chatTabIndex == 3 ? _searchQuery : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
          ),
        ),
      ],
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
        _loadPendingRequests(),
        _loadAllUserData(),
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

  Future<void> _acceptMateRequest(Map<String, dynamic> req) async {
    HapticFeedback.mediumImpact();
    final uid = _currentUserId ?? supabase.auth.currentUser?.id ?? '';
    final senderId = req['sender_id']?.toString() ?? req['source_id']?.toString() ?? '';
    final notifId = req['id']?.toString() ?? '';

    final success = await PocketMateService.acceptMateRequest(
      notificationId: notifId,
      myId: uid,
      senderId: senderId,
    );

    if (success) {
      setState(() {
        _pendingRequests.removeWhere((r) => r['id'] == notifId);
      });
      _handleRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✨ ${req['sender_name'] ?? 'User'} is now your Pocket Mate! Added to active chats.',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _declineMateRequest(Map<String, dynamic> req) async {
    HapticFeedback.lightImpact();
    final uid = _currentUserId ?? supabase.auth.currentUser?.id ?? '';
    final notifId = req['id']?.toString() ?? '';
    final senderId = req['sender_id']?.toString() ?? req['source_id']?.toString() ?? '';

    await PocketMateService.declineMateRequest(
      notificationId: notifId,
      myId: uid,
      senderId: senderId,
    );

    setState(() {
      _pendingRequests.removeWhere((r) => r['id'] == notifId);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request declined',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF334155),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showConversationActionSheet(ChatConversation conversation) {
    HapticFeedback.heavyImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                  backgroundImage: conversation.imageUrl != null
                      ? NetworkImage(conversation.imageUrl!)
                      : null,
                  child: conversation.imageUrl == null
                      ? Text(
                          conversation.name.isNotEmpty
                              ? conversation.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(0xFFFFFC00),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name,
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        conversation.isPinned ? 'Pinned Chat 📌' : 'Pocket Mate Chat',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Pin / Unpin
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                  color: const Color(0xFFFFFC00),
                  size: 20,
                ),
              ),
              title: Text(
                conversation.isPinned ? 'Unpin from Top' : 'Pin to Top',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                conversation.isPinned
                    ? 'Remove from top of chats list'
                    : 'Keep this chat at the very top of your inbox',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final uid = _currentUserId ?? supabase.auth.currentUser?.id ?? '';
                final isNowPinned = await PocketMateService.togglePinConversation(uid, conversation.id);
                ref.read(conversationsProvider.notifier).togglePin(conversation.id);
                _handleRefresh();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isNowPinned ? '📌 Pinned to top' : 'Chat unpinned',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF1E293B),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            // Send Snap
            if (!conversation.isGroup && !conversation.isTool && !conversation.isNotification)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Send Pocket Snap ⚡',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Instantly shoot a quick photo/video snap',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  PocketSnapService.launchSnapWorkflow(
                    context,
                    userId: _currentUserId ?? '',
                    profileId: _currentUserId ?? '',
                    preselectedRecipientId: conversation.id,
                    onUploaded: _handleRefresh,
                  );
                },
              ),
            // Mark as Read / Unread
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  conversation.unreadCount > 0 ? Icons.mark_chat_read_rounded : Icons.mark_chat_unread_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              title: Text(
                conversation.unreadCount > 0 ? 'Mark as Read' : 'Mark as Unread',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(conversationsProvider.notifier).markAsRead(conversation.id, conversation.isGroup);
                _handleRefresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCategoryFilterChips(List<ChatConversation> conversations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final robotsCount = conversations.where((c) => PocketRobotService.isRobotId(c.id)).length;
    final humansCount = conversations
        .where((c) => !PocketRobotService.isRobotId(c.id) && !c.isGroup && !c.isTool && !c.isNotification && !c.isActiveTimer)
        .length;
    final unreadCount = conversations.where((c) => c.unreadCount > 0).length;
    final groupsCount = conversations.where((c) => c.isGroup).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildCategoryChipItem(
              title: 'All',
              index: 0,
              icon: Icons.all_inbox_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: 'Robots',
              index: 1,
              count: robotsCount,
              icon: Icons.smart_toy_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: 'Humans',
              index: 2,
              count: humansCount,
              icon: Icons.person_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: 'Requests',
              index: 3,
              count: _pendingRequests.length,
              icon: Icons.person_add_alt_1_rounded,
              highlightBadge: _pendingRequests.isNotEmpty,
              isDark: isDark,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: 'Unread',
              index: 4,
              count: unreadCount,
              icon: Icons.mark_chat_unread_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: 'Groups',
              index: 5,
              count: groupsCount,
              icon: Icons.groups_rounded,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChipItem({
    required String title,
    required int index,
    int? count,
    required IconData icon,
    bool highlightBadge = false,
    required bool isDark,
  }) {
    final isSelected = _chatCategoryFilterIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _chatCategoryFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFFC00)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFFC00)
                : (isDark ? Colors.white10 : Colors.black12),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 1.5),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? Colors.black
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? Colors.black
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black
                      : (highlightBadge
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFFFFC00)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    color: isSelected
                        ? const Color(0xFFFFFC00)
                        : (highlightBadge ? Colors.white : Colors.black),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousLiveMatchBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnonymousEnglishChatPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E2235), const Color(0xFF141724)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFFFC00), width: 1),
                ),
                child: const Center(
                  child: Text('🎭', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Random Match',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'LIVE',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF10B981),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 12, color: Colors.black),
                    const SizedBox(width: 2),
                    Text(
                      'Connect',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
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

  Widget _buildPendingRequestsSliver() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingRequests) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
          ),
        ),
      );
    }

    if (_pendingRequests.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_search_rounded, size: 32, color: Color(0xFFFFFC00)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Requests',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When someone inquires about your marketplace items or requests to connect from Anonymous English Chat, they appear here safely.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 13,
                  height: 1.4,
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
          final req = _pendingRequests[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                  backgroundImage: req['sender_profile_image'] != null
                      ? NetworkImage(req['sender_profile_image'])
                      : null,
                  child: req['sender_profile_image'] == null
                      ? Text(
                          (req['sender_name'] ?? 'M')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFFC00),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req['sender_name'] ?? 'Pocket Mate',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        req['message'] ?? 'Wants to become your Pocket Mate',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _acceptMateRequest(req),
                      child: Text(
                        'Accept',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Decline button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () => _declineMateRequest(req),
                      tooltip: 'Decline',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: _pendingRequests.length,
      ),
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
          if (_searchQuery.isNotEmpty &&
              !conversation.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) {
            return false;
          }
          return true;
        }).toList();

        return SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                          return _buildNotificationsTile(
                              allNotifications.length);
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
                                  final team =
                                      Team.fromJson(conversation.teamData!);
                                  Navigator.push(
                                    context,
                                    material.MaterialPageRoute(
                                      builder: (context) =>
                                          TeamDetailPage(team: team),
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
                          onLongPress: () => _showConversationActionSheet(conversation),
                          onSnapCameraTap: () {
                            PocketSnapService.launchSnapWorkflow(
                              context,
                              userId: _currentUserId ?? '',
                              profileId: _currentUserId ?? '',
                              preselectedRecipientId: conversation.id,
                              onUploaded: _handleRefresh,
                            );
                          },
                          onSnapViewTap: () {
                            SnapViewDialog.show(
                              context: context,
                              mediaUrl: conversation.snapMediaUrl ?? conversation.imageUrl ?? '',
                              caption: conversation.snapCaption,
                              senderName: conversation.name,
                              isMe: false,
                              onBurned: () {
                                ref.read(conversationsProvider.notifier).markAsRead(conversation.id, false);
                                if (PocketRobotService.isRobotId(conversation.id)) {
                                  PocketRobotService.markRobotSnapAsRead(_currentUserId ?? '', conversation.id);
                                }
                                _handleRefresh();
                              },
                            );
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
                                    color: material.Colors.white
                                        .withValues(alpha: 0.1),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No results for "$_searchQuery"',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: material.Colors.white
                                          .withValues(alpha: 0.3),
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
                              padding:
                                  const EdgeInsets.fromLTRB(20, 24, 20, 12),
                              child: Row(
                                children: [
                                  Icon(material.Icons.people_rounded,
                                      size: 18,
                                      color: isDark
                                          ? const Color(0xFFFFFC00)
                                          : const Color(0xFFFFFC00)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SUGGESTED PEOPLE',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFFFFFC00)
                                          : const Color(0xFFFFFC00),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                                          builder: (context) =>
                                              WhatsAppGroupChat(
                                            groupId: 'p:${person['user_id']}',
                                            groupName: name,
                                            groupImage: avatarUrl,
                                          ),
                                        ),
                                      ).then((_) {
                                        ref.invalidate(conversationsProvider);
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: (isDark
                                                        ? const Color(
                                                            0xFFFFFC00)
                                                        : const Color(
                                                            0xFFFFFC00))
                                                    .withValues(alpha: 0.5),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 26,
                                              backgroundImage: avatarUrl != null
                                                  ? NetworkImage(avatarUrl)
                                                  : null,
                                              backgroundColor: isDark
                                                  ? const Color(0xFFFFFC00)
                                                  : const Color(0xFFFFFC00),
                                              child: avatarUrl == null
                                                  ? Text(
                                                      name.isNotEmpty
                                                          ? name[0]
                                                              .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                        color: material
                                                            .Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            name,
                                            style: GoogleFonts.outfit(
                                              color: material.Colors.white
                                                  .withValues(alpha: 0.8),
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
              // Category Filter Chips (All, Unread, Requests, Mates)
              SliverToBoxAdapter(
                child: _buildChatCategoryFilterChips(combined),
              ),

              if (_chatCategoryFilterIndex == 0)
                SliverToBoxAdapter(
                  child: _buildAnonymousLiveMatchBanner(isDark),
                ),

              if (_chatCategoryFilterIndex == 3) ...[
                // Requests View (Strangers, Marketplace inquiries, Anonymous chat requests)
                _buildPendingRequestsSliver(),
              ] else ...[
                if (_pendingRequests.isNotEmpty && _chatCategoryFilterIndex == 0)
                  _buildPendingRequestsSliver(),
                // Active Conversations List
                Builder(
                  builder: (context) {
                    List<ChatConversation> activeFiltered = filteredConversations;
                    if (_chatCategoryFilterIndex == 1) {
                      activeFiltered = filteredConversations.where((c) => PocketRobotService.isRobotId(c.id)).toList();
                    } else if (_chatCategoryFilterIndex == 2) {
                      activeFiltered = filteredConversations.where((c) =>
                          !PocketRobotService.isRobotId(c.id) && !c.isGroup && !c.isTool && !c.isNotification && !c.isActiveTimer).toList();
                    } else if (_chatCategoryFilterIndex == 4) {
                      activeFiltered = filteredConversations.where((c) => c.unreadCount > 0).toList();
                    } else if (_chatCategoryFilterIndex == 5) {
                      activeFiltered = filteredConversations.where((c) => c.isGroup).toList();
                    }

                    if (activeFiltered.isNotEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final conversation = activeFiltered[index];
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
                                  ref.read(conversationsProvider.notifier).markAsRead(conversation.id, false);

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
                              onLongPress: () => _showConversationActionSheet(conversation),
                              onSnapCameraTap: () {
                                PocketSnapService.launchSnapWorkflow(
                                  context,
                                  userId: _currentUserId ?? '',
                                  profileId: _currentUserId ?? '',
                                  preselectedRecipientId: conversation.id,
                                  onUploaded: _handleRefresh,
                                );
                              },
                              onSnapViewTap: () {
                                SnapViewDialog.show(
                                  context: context,
                                  mediaUrl: conversation.snapMediaUrl ?? conversation.imageUrl ?? '',
                                  caption: conversation.snapCaption,
                                  senderName: conversation.name,
                                  isMe: false,
                                  onBurned: () {
                                    ref.read(conversationsProvider.notifier).markAsRead(conversation.id, false);
                                    if (PocketRobotService.isRobotId(conversation.id)) {
                                      PocketRobotService.markRobotSnapAsRead(_currentUserId ?? '', conversation.id);
                                    }
                                    _handleRefresh();
                                  },
                                );
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
                                              'profile_image_url': conversation.imageUrl,
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
                          childCount: activeFiltered.length,
                        ),
                      );
                    }

                    return SliverToBoxAdapter(
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
                              _chatCategoryFilterIndex == 1
                                  ? 'No Pocket Robots yet'
                                  : (_chatCategoryFilterIndex == 2
                                      ? 'No human mates yet. Connect from Anonymous Chat!'
                                      : (_chatCategoryFilterIndex == 4
                                          ? 'No unread messages'
                                          : (_chatCategoryFilterIndex == 5
                                              ? 'No groups joined yet'
                                              : 'No conversations yet'))),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: material.Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
            if (_currentUserId != null && _searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: ContactsSyncWidget(currentUserId: _currentUserId!),
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
    final navBgColor =
        isDark ? const Color(0xFF111B21) : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? material.Colors.white.withValues(alpha: 0.08)
        : material.Colors.black.withValues(alpha: 0.08);
    final shadowColor = isDark
        ? material.Colors.black.withValues(alpha: 0.4)
        : material.Colors.grey.withValues(alpha: 0.1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDailyPracticeTimerStrip(context),
        Container(
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
                  icon: material.Icons.storefront_rounded,
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _buildNavItem(
                  icon: material.Icons.chat_bubble_rounded,
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _buildNavItem(
                  icon: material.Icons.group_rounded,
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _buildNavItem(
                  icon: material.Icons.track_changes_rounded,
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _buildProfileNavItem(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ⏱️ Persistent In-App Daily Practice Timer Strip
  /// Allows learners to see their 60-min practice progress while using chats, calls, or games.
  Widget _buildDailyPracticeTimerStrip(BuildContext context) {
    return ListenableBuilder(
      listenable: PocketMissionTimerService.instance,
      builder: (context, _) {
        final timer = PocketMissionTimerService.instance;
        if (timer.elapsedSeconds == 0 && !timer.isRunning) {
          return const SizedBox.shrink();
        }

        final isRunning = timer.isRunning;
        final isTargetMet = timer.hasReachedTarget;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              material.MaterialPageRoute(
                builder: (_) => PocketDailyMissionPage(day: timer.day),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTargetMet
                    ? const [Color(0xFF064E3B), Color(0xFF0F172A)]
                    : (isRunning
                        ? const [Color(0xFF1E1B4B), Color(0xFF0F172A)]
                        : const [Color(0xFF1E293B), Color(0xFF0F172A)]),
              ),
              border: Border(
                top: BorderSide(
                  color: isTargetMet
                      ? const Color(0xFF10B981)
                      : (isRunning ? const Color(0xFFFFD700) : Colors.white24),
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: isTargetMet
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : (isRunning
                          ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                          : Colors.white12),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  isTargetMet ? '🏆' : (isRunning ? '🔥' : '⏸️'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Day ${timer.day}: ',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timer.formatTime(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        ' / ${timer.formatTime(timer.targetSeconds)}',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isRunning
                              ? Colors.green.withValues(alpha: 0.25)
                              : (isTargetMet
                                  ? const Color(0xFF10B981).withValues(alpha: 0.25)
                                  : Colors.white10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isRunning
                              ? 'RECORDING'
                              : (isTargetMet ? 'GOAL MET' : 'PAUSED'),
                          style: TextStyle(
                            color: isRunning
                                ? Colors.greenAccent
                                : (isTargetMet ? const Color(0xFF10B981) : Colors.white60),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: Icon(
                    isRunning
                        ? Icons.pause_circle_filled_rounded
                        : (isTargetMet
                            ? Icons.check_circle_rounded
                            : Icons.play_circle_fill_rounded),
                    color: isTargetMet
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFFC00),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (isTargetMet) {
                      Navigator.push(
                        context,
                        material.MaterialPageRoute(
                          builder: (_) => PocketDailyMissionPage(day: timer.day),
                        ),
                      );
                    } else {
                      timer.toggleTimer();
                    }
                  },
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'MISSION ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  VectorAvatarConfig _getNavAvatarConfig() {
    final day = (_preloadedProfile?['learning_day'] as num?)?.toInt() ??
        (_preloadedProfile?['learning_stage'] as num?)?.toInt() ??
        1;
    final talismanId = _preloadedProfile?['equipped_talisman']?.toString() ??
        _preloadedProfile?['talisman_id']?.toString();
    return VectorAvatarConfig.getEvolutionAvatarForStage(day, talismanId: talismanId);
  }

  Widget _buildProfileNavItem() {
    final day = (_preloadedProfile?['learning_day'] as num?)?.toInt() ??
        (_preloadedProfile?['learning_stage'] as num?)?.toInt() ??
        1;
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
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: day >= 80
                        ? const [Color(0xFFFFD700), Color(0xFFEF4444), Color(0xFFA855F7)]
                        : (day >= 40
                            ? const [Color(0xFFFF8906), Color(0xFFFFD700)]
                            : const [Color(0xFFFFFC00), Color(0xFFFFD700)]),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8906).withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: _getNavAvatarConfig(),
                    size: 34.0,
                    showAura: false,
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'D$day',
                    style: const TextStyle(
                      color: Color(0xFFFFFC00),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
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
    final themeYellow =
        isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00);
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
                    : (isDark
                        ? material.Colors.white.withValues(alpha: 0.5)
                        : material.Colors.black.withValues(alpha: 0.45)),
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
      backgroundColor:
          isDark ? const Color(0xFF121218) : const Color(0xFFF4F4F9),
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
                  color:
                      isDark ? material.Colors.white : material.Colors.black87,
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
                                  const Icon(
                                      material.Icons.calendar_month_rounded,
                                      color: Colors.white,
                                      size: 30),
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
                    side: BorderSide(
                        color: isDark
                            ? material.Colors.white.withValues(alpha: 0.2)
                            : material.Colors.black.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: isDark
                              ? material.Colors.white70
                              : material.Colors.black87)),
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
            content: Text('Finding a founder...')),
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
                      color: isDark
                          ? const Color(0xFF262626)
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        material.Icons.notifications_rounded,
                        color: isDark
                            ? const Color(0xFFFFFC00)
                            : const Color(0xFFFFFC00),
                        size: 26,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: material.Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF111B21)
                              : const Color(0xFFFFFFFF),
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
                    color: (isDark
                            ? const Color(0xFFFFFC00)
                            : const Color(0xFFFFFC00))
                        .withValues(alpha: 0.3),
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
                        color: isDark
                            ? const Color(0xFFFFFC00)
                            : const Color(0xFFFFFC00),
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
                color: Color(0xFFFFFC00), size: 28),
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
                    const material.SnackBar(
                        content: Text('Invitation accepted!')),
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
  final double topPadding;
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
  final int pendingRequestsCount;

  _HomeMainHeaderDelegate({
    required this.topPadding,
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
    required this.pendingRequestsCount,
  });

  static const double topBarHeight = 42.0;
  static const double vibesHeaderHeight = 28.0;
  static const double statusWidgetHeight = 104.0;
  static const double tabBarHeight = 36.0;
  static const double searchBarHeight = 46.0;

  double get scrollableHeight => topBarHeight + vibesHeaderHeight + statusWidgetHeight;
  double get stickyHeight => tabBarHeight + searchBarHeight;

  @override
  double get maxExtent => topPadding + scrollableHeight + stickyHeight;

  @override
  double get minExtent => topPadding + stickyHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double scrollProgress = (shrinkOffset / scrollableHeight).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDark ? const Color(0xFF111B21) : const Color(0xFFF4F4F9);

    return material.Material(
      color: headerColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Scrollable Section (Top App Bar + Minimal Vibes Row + Status Circles)
          Positioned(
            top: topPadding - shrinkOffset,
            left: 0,
            right: 0,
            height: scrollableHeight,
            child: IgnorePointer(
              ignoring: scrollProgress >= 0.85,
              child: Opacity(
                opacity: (1.0 - scrollProgress * 1.3).clamp(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top App Bar (Pocket Mates title + Action Icons)
                    Container(
                      height: topBarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Pocket Mates',
                            style: GoogleFonts.outfit(
                              color: isDark
                                  ? material.Colors.white
                                  : material.Colors.black87,
                              fontSize: 18.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search
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
                              const SizedBox(width: 6),
                              // Notifications (Consolidated, single bell icon with badge)
                              _buildHeaderIconButton(
                                context,
                                icon: material.Icons.notifications_outlined,
                                badgeCount: pendingRequestsCount,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    material.MaterialPageRoute(
                                      builder: (context) => const NotificationsPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              // Create Group
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
                              const SizedBox(width: 6),
                              // Settings
                              _buildHeaderIconButton(
                                context,
                                icon: material.Icons.settings_rounded,
                                onTap: onTapSettings,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Minimal Vibes Header: ONLY the 'Add Vibe' button!
                    Container(
                      height: vibesHeaderHeight,
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                      alignment: Alignment.centerLeft,
                      child: material.InkWell(
                        onTap: onTapAdd,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFC00),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(material.Icons.add_rounded,
                                  size: 13, color: material.Colors.black),
                              const SizedBox(width: 3),
                              Text(
                                'Add Vibe',
                                style: GoogleFonts.outfit(
                                  color: material.Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Status Story Row (Compact)
                    SizedBox(
                      height: statusWidgetHeight,
                      child: StatusDisplayWidget(
                        key: ValueKey('status_display_$statusRefreshKey'),
                        currentUserId: currentUserId,
                        currentProfileId: currentProfileId,
                        onStatusUploaded: onRefresh,
                        filterNotifier: vibesFilterNotifier,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Sticky Section (Tabs + Search Bar)
          Positioned(
            top: topPadding + math.max(0.0, scrollableHeight - shrinkOffset),
            left: 0,
            right: 0,
            height: stickyHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tab Bar (Chats, Vibes, Thoughts, Tools)
                Container(
                  height: tabBarHeight,
                  color: headerColor,
                  child: Row(
                    children: [
                      _buildTabItem(context, 'Chats', 0),
                      _buildTabItem(context, 'Vibes', 1),
                      _buildTabItem(context, 'Thoughts', 2),
                      _buildTabItem(context, 'Tools', 3),
                    ],
                  ),
                ),
                // Search Bar (Compact & Sleek)
                Container(
                  height: searchBarHeight,
                  color: headerColor,
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF202C33)
                          : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(18),
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
                        color: isDark
                            ? material.Colors.white
                            : material.Colors.black87,
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFFFFC00),
                      decoration: material.InputDecoration(
                        isDense: true,
                        hintText: selectedIndex == 3
                            ? 'Search tools, games, or features...'
                            : selectedIndex == 2
                                ? 'Search thoughts...'
                                : selectedIndex == 1
                                    ? 'Search vibes & stories...'
                                    : 'Search chats, mates, tools...',
                        hintStyle: GoogleFonts.outfit(
                          color: isDark
                              ? material.Colors.white.withValues(alpha: 0.35)
                              : material.Colors.black.withValues(alpha: 0.35),
                          fontSize: 13,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 8.0),
                          child: Icon(
                            material.Icons.search_rounded,
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.7),
                            size: 17,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isSearching)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: material.CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: const Color(0xFFFFFC00),
                                  ),
                                ),
                              ),
                            if (searchQuery.isNotEmpty)
                              material.Material(
                                color: material.Colors.transparent,
                                child: material.IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  icon: Icon(
                                    material.Icons.clear_rounded,
                                    color: isDark ? material.Colors.white30 : material.Colors.black38,
                                    size: 16,
                                  ),
                                  onPressed: () => searchController.clear(),
                                ),
                              ),
                          ],
                        ),
                        border: material.InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
    final themeYellow = const Color(0xFFFFFC00);
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
                        width: 2.0,
                      ),
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? themeYellow : textUnselected,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap, int badgeCount = 0}) {
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
          padding: const EdgeInsets.all(6.5),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: iconColor, size: 17),
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2A55),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2A55).withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeMainHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.searchQuery != searchQuery ||
        oldDelegate.isSearching != isSearching ||
        oldDelegate.statusRefreshKey != statusRefreshKey ||
        oldDelegate.activeUsersRef != activeUsersRef ||
        oldDelegate.vibesFilterNotifier != vibesFilterNotifier ||
        oldDelegate.pendingRequestsCount != pendingRequestsCount;
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
