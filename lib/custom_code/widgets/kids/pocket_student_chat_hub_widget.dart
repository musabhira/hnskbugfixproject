import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/kids_chat_groups_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/active_users_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/create_group_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/thoughts_feed_section.dart';
import 'package:pocket_mates_app/custom_code/widgets/contacts_sync_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/pocket_snap_flame_refresh.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat_list_shimmer.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_snap_service.dart';
import 'package:pocket_mates_app/custom_code/services/vibes_seen_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_vibes_upload_manager.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_notifications_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_friendship_score_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kid_avatar_card_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_friendship_score_dialog.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/living_spreading_aura.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 💬 Pocket Kids Chat Hub - Ported Directly from Adult Chat System
/// Features:
/// 1. Top Header: Logo + PoketMates Branding + Search, Notifications, Create Group
/// 2. Top Horizontal Status Stories Bar (Instagram-style)
/// 3. Segmented 3-Tab Capsule: Chats (0), Vibes (1), Thoughts (2) [Tools tab removed]
/// 4. Search Bar with Live Filter & Directory Search
/// 5. Dedicated Supabase Tables: kids_conversations, kids_groups, kids_group_members, kids_group_messages
/// 6. Animals Filter (🦁 🐾) instead of Robots
/// 7. Attacking Profile Integration: PocketCitadelAttackPage.openForUser
class PocketStudentChatHubWidget extends ConsumerStatefulWidget {
  const PocketStudentChatHubWidget({super.key});

  @override
  ConsumerState<PocketStudentChatHubWidget> createState() =>
      _PocketStudentChatHubWidgetState();
}

class _PocketStudentChatHubWidgetState
    extends ConsumerState<PocketStudentChatHubWidget> {
  final supabase = SupaFlow.client;

  String? _currentUserId;
  String? _profileId;
  int _refreshKeyCount = 0;
  int _chatTabIndex = 0; // 0: Chats, 1: Vibes, 2: Thoughts
  late PageController _pageController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  async.Timer? _searchDebounce;

  // Search state
  int _searchTabIndex = 0; // 0: People, 1: Products
  int _searchPeopleFilterIndex = 0; // 0: All, 1: Humans, 2: Animals
  bool _isCongestedSearch = false;
  bool _isSearchingPeople = false;
  bool _isSearchingProducts = false;
  List<Map<String, dynamic>> _personSearchResults = [];
  List<Map<String, dynamic>> _productSearchResults = [];

  // Filter chips in Chats tab (Animals instead of Robots)
  int _chatCategoryFilterIndex = 0; // 0: All, 1: Animals, 2: Humans, 3: Requests, 4: Unread, 5: Groups
  int _requestsSubTab = 0; // 0: Received, 1: Sent

  // Requests state
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  bool _isLoadingRequests = false;

  final ValueNotifier<String> _vibesFilterNotifier =
      ValueNotifier<String>('all');

  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _chatTabIndex);
    _searchController.addListener(_onSearchChanged);
    _loadUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    _vibesFilterNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      try {
        final profile = await supabase
            .from('profile')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();
        if (mounted) {
          safeSetState(() {
            _profileId = profile?['id']?.toString() ?? user.id;
          });
        }
      } catch (_) {
        if (mounted) {
          safeSetState(() {
            _profileId = user.id;
          });
        }
      }
      await _loadPendingRequests();
    }
  }

  Future<void> _loadPendingRequests() async {
    final uid = _currentUserId ?? supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    if (mounted) safeSetState(() => _isLoadingRequests = true);
    try {
      final receivedIds = PocketKidsService.receivedRequestIds;
      final sentIds = PocketKidsService.sentRequestIds;

      final List<Map<String, dynamic>> reqs = [];
      for (final id in receivedIds) {
        final mate = PocketKidsService.getKidMateById(id);
        if (mate != null) {
          reqs.add({
            'id': mate.id,
            'sender_id': mate.id,
            'sender_name': mate.name,
            'sender_profile_image': null,
            'avatar': mate.avatar,
            'message': mate.isRobot
                ? '🐾 Friendly animal buddy wants to practice English!'
                : '🎒 School mate wants to be study buddies!',
            'status': 'pending',
          });
        }
      }

      final List<Map<String, dynamic>> sentReqs = [];
      for (final id in sentIds) {
        final mate = PocketKidsService.getKidMateById(id);
        if (mate != null) {
          sentReqs.add({
            'id': mate.id,
            'receiver_id': mate.id,
            'receiver_name': mate.name,
            'receiver_profile_image': null,
            'avatar': mate.avatar,
            'message': 'Study mate request sent',
            'status': 'pending',
          });
        }
      }

      if (mounted) {
        safeSetState(() {
          _pendingRequests = reqs;
          _sentRequests = sentReqs;
          _isLoadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) {
        safeSetState(() => _isLoadingRequests = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    safeSetState(() {
      _refreshKeyCount++;
    });
    await _loadPendingRequests();
    ref.read(kidsConversationsProvider.notifier).refreshNow();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    safeSetState(() {
      _searchQuery = query;
    });

    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = async.Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
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
      final List<Map<String, dynamic>> results = [];

      // 1. Search Animal Companions matching query
      final qLower = trimmed.toLowerCase();
      for (final bot in PocketKidsRobotsData.robotsAndHomies) {
        if (bot.name.toLowerCase().contains(qLower) ||
            bot.bio.toLowerCase().contains(qLower) ||
            bot.avatar.contains(qLower)) {
          results.add({
            'id': bot.id,
            'user_id': bot.id,
            'name': '${bot.name} ${bot.avatar}',
            'profile_image_url': null,
            'avatar': bot.avatar,
            'is_animal': true,
            'tagline': bot.bio,
            'day_level': bot.dayLevel,
          });
        }
      }

      // 2. Search ONLY Kid/Student accounts from database (Strictly No Adult Profiles or Adult Robots)
      final peopleResponse = await supabase
          .from('profile')
          .select()
          .eq('is_kid', true)
          .or('name.ilike.%$trimmed%,slug.ilike.%$trimmed%')
          .range(0, 14);

      for (var p in peopleResponse) {
        final uid = p['user_id']?.toString() ?? p['id']?.toString() ?? '';
        if (PocketKidsService.isAllowedKidMateId(uid)) {
          results.add(Map<String, dynamic>.from(p));
        }
      }

      final galleryResults = await supabase
          .from('gallery')
          .select('*, profile(name, verified, profile_image_url)')
          .ilike('title', '%$trimmed%')
          .range(0, 14);

      safeSetState(() {
        _personSearchResults = results;
        List<Map<String, dynamic>> products = [];
        for (var item in galleryResults) {
          final isService = item['is_service'] == true;
          products.add({...item, 'type': isService ? 'service' : 'gallery'});
        }
        _productSearchResults = products;
        _isSearchingPeople = false;
        _isSearchingProducts = false;
      });
    } catch (_) {
      safeSetState(() {
        _isSearchingPeople = false;
        _isSearchingProducts = false;
      });
    }
  }

  void _onTabTapped(int index) {
    if (_chatTabIndex == index) return;
    safeSetState(() {
      _chatTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_chatTabIndex != index) {
      safeSetState(() {
        _chatTabIndex = index;
      });
    }
  }

  Future<void> _acceptMateRequest(Map<String, dynamic> req) async {
    HapticFeedback.mediumImpact();
    final senderId =
        req['sender_id']?.toString() ?? req['id']?.toString() ?? '';

    await PocketKidsService.acceptMateRequest(senderId);

    safeSetState(() {
      _pendingRequests.removeWhere(
          (r) => r['id'] == senderId || r['sender_id'] == senderId);
    });
    _handleRefresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✨ ${req['sender_name'] ?? 'Mate'} is now your Study Buddy!',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _declineMateRequest(Map<String, dynamic> req) async {
    HapticFeedback.lightImpact();
    final senderId =
        req['sender_id']?.toString() ?? req['id']?.toString() ?? '';

    await PocketKidsService.rejectMateRequest(senderId);

    safeSetState(() {
      _pendingRequests.removeWhere(
          (r) => r['id'] == senderId || r['sender_id'] == senderId);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request declined',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showConversationActionSheet(ChatConversation conversation) {
    HapticFeedback.heavyImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: const Color(0xFF161B26),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white12,
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
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    PocketCitadelAttackPage.openForUser(
                      context,
                      userId: conversation.id,
                      isKidMode: true,
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        const Color(0xFFFFFC00).withValues(alpha: 0.2),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        conversation.isPinned
                            ? 'Pinned Chat 📌'
                            : 'Pocket Mate Chat',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
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
                  conversation.isPinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin_rounded,
                  color: const Color(0xFFFFFC00),
                  size: 20,
                ),
              ),
              title: Text(
                conversation.isPinned ? 'Unpin from Top' : 'Pin to Top',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                conversation.isPinned
                    ? 'Remove from top of chats list'
                    : 'Keep this chat at the very top of your inbox',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final isNowPinned = !conversation.isPinned;
                ref
                    .read(kidsConversationsProvider.notifier)
                    .togglePin(conversation.id);
                _handleRefresh();
                messenger.showSnackBar(
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
              },
            ),
            // View Profile / House Attack
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFFFFFC00),
                  size: 20,
                ),
              ),
              title: Text(
                'View Profile / Citadel 🏰',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Challenge their English defense house',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                PocketCitadelAttackPage.openForUser(
                  context,
                  userId: conversation.id,
                  isKidMode: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(kidsConversationsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PocketKidsNatureSceneryBackground(
        showSun: true,
        showTrees: true,
        hillHeightFraction: 0.36,
        glassOverlayOpacity: 0.08,
        child: material.Scaffold(
          backgroundColor: material.Colors.transparent,
          body: PocketSnapFlameRefresh(
            onRefresh: _handleRefresh,
            triggerDistance: 85.0,
            maxPullDistance: 210.0,
            restingHeight: 150.0,
                child: material.NestedScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _KidsChatHeaderDelegate(
                          topPadding: topPadding,
                          currentUserId:
                              _currentUserId ?? supabase.auth.currentUser?.id ?? '',
                          currentProfileId: _profileId ?? '',
                          statusRefreshKey: _refreshKeyCount,
                          activeUsersRef: ref.watch(
                              activeUsersProvider(_profileId ?? '')),
                          onTapSearch: () {
                            Navigator.push(
                              context,
                              material.MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );
                          },
                          onTapNotifications: () {
                            Navigator.push(
                              context,
                              material.MaterialPageRoute(
                                builder: (context) =>
                                    const PocketKidsNotificationsPage(),
                              ),
                            );
                          },
                          onTapCreateGroup: () async {
                            final auth =
                                await AuthAlertBox.checkAuthAndShowAlert(
                                    context: context);
                            if (auth && context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => CreateGroupDialog(
                                  onGroupCreated: _handleRefresh,
                                ),
                              );
                            }
                          },
                          onRefresh: _handleRefresh,
                          selectedIndex: _chatTabIndex,
                          onTabTap: _onTabTapped,
                          searchController: _searchController,
                          searchQuery: _searchQuery,
                          isSearching: _isSearchingPeople || _isSearchingProducts,
                          vibesFilterNotifier: _vibesFilterNotifier,
                          pendingRequestsCount: _pendingRequests.length,
                        ),
                      ),
                    ];
                  },
                  body: material.Material(
                    color: material.Colors.transparent,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        // Page 0: Chats
                        material.CustomScrollView(
                          cacheExtent: 400,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            _buildChatListSliver(conversationsAsync),
                          ],
                        ),
                        // Page 1: Vibes
                        _buildVibesSection(),
                        // Page 2: Thoughts (Strict Kid Thoughts)
                        ThoughtsFeedSection(
                          key: ValueKey('thoughts_feed_$_refreshKeyCount'),
                          currentUserId: _currentUserId ?? '',
                          currentProfileId: _profileId ?? '',
                          isKidMode: true,
                          onStatusShared: _handleRefresh,
                          searchQuery:
                              _chatTabIndex == 2 ? _searchQuery : '',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildVibesSection() {
    return StatusDisplayWidget(
      key: ValueKey('vibes_list_$_refreshKeyCount'),
      currentUserId: _currentUserId ?? '',
      currentProfileId: _profileId ?? '',
      searchQuery: _chatTabIndex == 1 ? _searchQuery : '',
      filterNotifier: _vibesFilterNotifier,
      isVertical: true,
      isKidMode: true,
      onStatusWatched: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(kidsConversationsProvider.notifier).refreshNow();
            safeSetState(() {});
          }
        });
      },
    );
  }

  Widget _buildChatListSliver(
      AsyncValue<List<ChatConversation>> conversationsAsync) {
    return conversationsAsync.when(
      data: (conversations) {
        final chatConversations = conversations.where((c) {
          if (c.isNotification) return false;
          final lowerName = c.name.toLowerCase();
          if (lowerName.contains('english hub') ||
              lowerName.contains('english learning') ||
              lowerName.contains('english practice')) {
            return false;
          }
          return true;
        }).toList();

        List<ChatConversation> combined = [...chatConversations];

        // Sort by pinned then last message time
        combined.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          final aTime = a.lastMessageTime ?? DateTime(0);
          final bTime = b.lastMessageTime ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

        final filteredConversations = combined.where((conversation) {
          final lowerName = conversation.name.toLowerCase();
          if (_searchQuery.isNotEmpty &&
              !lowerName.contains(_searchQuery.toLowerCase())) {
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
                      const SizedBox(width: 10),
                      _buildSearchTabItem('Products', 1),
                      const Spacer(),
                      material.InkWell(
                        onTap: () {
                          safeSetState(() {
                            _isCongestedSearch = !_isCongestedSearch;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isCongestedSearch
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.18)
                                : material.Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isCongestedSearch
                                  ? const Color(0xFFFFFC00).withValues(alpha: 0.6)
                                  : material.Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isCongestedSearch
                                    ? material.Icons.grid_view_rounded
                                    : material.Icons.view_agenda_outlined,
                                size: 13,
                                color: _isCongestedSearch
                                    ? const Color(0xFFFFFC00)
                                    : material.Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isCongestedSearch ? 'Compact' : 'Normal',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isCongestedSearch
                                      ? const Color(0xFFFFFC00)
                                      : material.Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_searchTabIndex == 0) ...[
                // Sub-filter chips for People (All, Humans, Animals)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSearchFilterChip(
                            label: 'All',
                            isSelected: _searchPeopleFilterIndex == 0,
                            onTap: () => safeSetState(
                                () => _searchPeopleFilterIndex = 0),
                          ),
                          const SizedBox(width: 8),
                          _buildSearchFilterChip(
                            label: 'Humans',
                            icon: material.Icons.person_rounded,
                            isSelected: _searchPeopleFilterIndex == 1,
                            onTap: () => safeSetState(
                                () => _searchPeopleFilterIndex = 1),
                          ),
                          const SizedBox(width: 8),
                          _buildSearchFilterChip(
                            label: 'Animals',
                            icon: material.Icons.pets_rounded,
                            isSelected: _searchPeopleFilterIndex == 2,
                            onTap: () => safeSetState(
                                () => _searchPeopleFilterIndex = 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // People: Filtered Active Conversations first
                Builder(
                  builder: (context) {
                    final displayActiveConversations =
                        filteredConversations.where((c) {
                      if (!PocketKidsService.isAllowedKidMateId(c.id)) return false;
                      final isAnimal = c.id.startsWith('kid_bot_') ||
                          c.id == KidsConversationsNotifier.animalMentorId ||
                          PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == c.id);
                      if (_searchPeopleFilterIndex == 1) {
                        return !isAnimal;
                      } else if (_searchPeopleFilterIndex == 2) {
                        return isAnimal;
                      }
                      return true;
                    }).toList();

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final conversation = displayActiveConversations[index];
                          return RepaintBoundary(
                            key: ValueKey(conversation.id),
                            child: _buildKidGameConversationCard(conversation),
                          );
                        },
                        childCount: displayActiveConversations.length,
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                      ),
                    );
                  },
                ),

                // Directory Search Results
                Builder(
                  builder: (context) {
                    final peopleResults = _personSearchResults.where((p) {
                      final uid = p['user_id']?.toString() ?? p['id']?.toString() ?? '';
                      if (!PocketKidsService.isAllowedKidMateId(uid)) return false;
                      final isAnimal = uid.startsWith('kid_bot_') ||
                          uid == KidsConversationsNotifier.animalMentorId ||
                          p['is_animal'] == true ||
                          PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == uid);
                      if (_searchPeopleFilterIndex == 1) {
                        return !isAnimal;
                      } else if (_searchPeopleFilterIndex == 2) {
                        return isAnimal;
                      }
                      return true;
                    }).toList();

                    if (peopleResults.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Row(
                              children: [
                                const Icon(
                                  material.Icons.people_rounded,
                                  size: 16,
                                  color: Color(0xFFFFFC00),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'STUDENTS (${peopleResults.length})',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFC00),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final person = peopleResults[index];
                                final name = person['name'] ?? 'Mate';
                                final avatarUrl = person['profile_image_url'];
                                final userId = person['user_id']?.toString() ??
                                    person['id']?.toString() ??
                                    '';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B26),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: material.Colors.white
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        PocketCitadelAttackPage.openForUser(
                                          context,
                                          userId: userId,
                                          isKidMode: true,
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(0xFFFFFC00)
                                            .withValues(alpha: 0.15),
                                        backgroundImage: (avatarUrl != null &&
                                                avatarUrl.isNotEmpty)
                                            ? CachedNetworkImageProvider(avatarUrl)
                                            : null,
                                        child: (avatarUrl == null || avatarUrl.isEmpty)
                                            ? Text(
                                                name.isNotEmpty
                                                    ? name[0].toUpperCase()
                                                    : '?',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(0xFFFFFC00),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    title: Text(
                                      name,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      material.Icons.chat_bubble_outline_rounded,
                                      color: Color(0xFFFFFC00),
                                      size: 18,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        material.MaterialPageRoute(
                                          builder: (context) => WhatsAppGroupChat(
                                            groupId: 'p:$userId',
                                            groupName: name,
                                            groupImage: avatarUrl,
                                          ),
                                        ),
                                      ).then((_) {
                                        ref.invalidate(kidsConversationsProvider);
                                      });
                                    },
                                  ),
                                );
                              },
                              childCount: peopleResults.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ] else ...[
                // Products / Items tab
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _productSearchResults[index];
                        final title = product['title'] ?? 'Product';
                        final profile = product['profile'] as Map<String, dynamic>?;
                        final creatorName = profile?['name'] ?? 'Creator';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B26),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: material.Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFC00)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  material.Icons.shopping_bag_outlined,
                                  color: Color(0xFFFFFC00),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'by $creatorName',
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: _productSearchResults.length,
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Standard View (No active search query)
              // Category Filter Chips (All, Animals, Humans, Requests, Unread, Groups)
              SliverToBoxAdapter(
                child: _buildChatCategoryFilterChips(combined),
              ),

              if (_chatCategoryFilterIndex == 3) ...[
                // Requests View
                _buildRequestsSubTabToggle(),
                _buildPendingRequestsSliver(),
              ] else ...[
                if (_chatCategoryFilterIndex == 0) ...[
                  _buildVibeUploadStatusTile(),
                  if (_pendingRequests.isNotEmpty)
                    _buildPendingRequestsBanner(),
                ],

                // Active Conversations List
                Builder(
                  builder: (context) {
                    final pendingSenderIds = _pendingRequests
                        .map((r) => r['sender_id']?.toString())
                        .whereType<String>()
                        .toSet();

                    List<ChatConversation> activeFiltered =
                        filteredConversations
                            .where((c) =>
                                !pendingSenderIds.contains(c.id) &&
                                PocketKidsService.isAllowedKidMateId(c.id))
                            .toList();

                    if (_chatCategoryFilterIndex == 0) {
                      // Under 'All': Show all active
                      activeFiltered = activeFiltered.toList();
                    } else if (_chatCategoryFilterIndex == 1) {
                      // 🐾 Animals
                      activeFiltered = activeFiltered
                          .where((c) =>
                              c.id.startsWith('kid_bot_') ||
                              c.id == KidsConversationsNotifier.animalMentorId ||
                              PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == c.id))
                          .toList();
                    } else if (_chatCategoryFilterIndex == 2) {
                      // 🎒 Classmates (Students)
                      activeFiltered = activeFiltered
                          .where((c) =>
                              !c.id.startsWith('kid_bot_') &&
                              c.id != KidsConversationsNotifier.animalMentorId &&
                              !PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == c.id) &&
                              !c.isGroup &&
                              !c.isTool &&
                              !c.isNotification &&
                              !c.isActiveTimer)
                          .toList();
                    } else if (_chatCategoryFilterIndex == 4) {
                      activeFiltered = activeFiltered
                          .where((c) => c.unreadCount > 0)
                          .toList();
                    } else if (_chatCategoryFilterIndex == 5) {
                      activeFiltered = activeFiltered.where((c) {
                        if (!c.isGroup) return false;
                        final lowerName = c.name.toLowerCase();
                        return !lowerName.contains('english hub') &&
                            !lowerName.contains('english learning') &&
                            !lowerName.contains('english practice');
                      }).toList();
                    }

                    if (activeFiltered.isNotEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final conversation = activeFiltered[index];
                            return RepaintBoundary(
                              key: ValueKey(conversation.id),
                              child: _buildKidGameConversationCard(conversation),
                            );
                          },
                          childCount: activeFiltered.length,
                          addAutomaticKeepAlives: true,
                          addRepaintBoundaries: true,
                        ),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              material.Icons.chat_bubble_rounded,
                              size: 54,
                              color: material.Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _chatCategoryFilterIndex == 1
                                  ? 'No Animal Buddies yet'
                                  : (_chatCategoryFilterIndex == 2
                                      ? 'No student mates yet. Connect with classmates!'
                                      : (_chatCategoryFilterIndex == 4
                                          ? 'No unread messages'
                                          : (_chatCategoryFilterIndex == 5
                                              ? 'No groups joined yet'
                                              : 'No conversations yet'))),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: material.Colors.white.withValues(alpha: 0.35),
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
            if (_currentUserId != null && _searchQuery.isEmpty && !PocketKidsService.isKidAccount)
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
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  void _handleConversationTap(ChatConversation conversation) async {
    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.playCoinSound();
    if (conversation.isGroup) {
      await Navigator.push(
        context,
        material.MaterialPageRoute(
          builder: (context) => WhatsAppGroupChat(
            groupId: conversation.id,
            groupName: conversation.name,
            groupImage: conversation.imageUrl,
            avatarConfig: conversation.avatarConfig,
          ),
        ),
      );
      ref.read(kidsConversationsProvider.notifier).refreshNow();
      if (mounted) safeSetState(() {});
    } else {
      ref.read(kidsConversationsProvider.notifier).markAsRead(conversation.id, false);

      await Navigator.push(
        context,
        material.MaterialPageRoute(
          builder: (context) => WhatsAppGroupChat(
            groupId: 'p:${conversation.id}',
            groupName: conversation.name,
            groupImage: conversation.imageUrl,
            avatarConfig: conversation.avatarConfig,
          ),
        ),
      );
      ref.read(kidsConversationsProvider.notifier).refreshNow();
      if (mounted) safeSetState(() {});
    }
  }

  void _handleSnapCamera(ChatConversation conversation) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      final isAuth = await AuthAlertBox.checkAuthAndShowAlert(
        context: context,
        customMessage: "Please login to send snaps",
      );
      if (!isAuth) return;
    }
    if (!mounted) return;
    PocketSnapService.launchSnapWorkflow(
      context,
      userId: _currentUserId ?? '',
      profileId: _currentUserId ?? '',
      preselectedRecipientId: conversation.id,
      onUploaded: _handleRefresh,
    );
  }

  void _handleStatusTap(ChatConversation conversation) {
    if (conversation.hasStatus && conversation.statusData != null) {
      VibesSeenService.markSeen(
        currentUserId: _currentUserId ?? '',
        userId: conversation.id,
        profileId: conversation.id,
        groupId: conversation.isGroup ? conversation.id : null,
        statusIds: conversation.statusData!
            .map((s) => s['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList(),
      );
      Navigator.push(
        context,
        material.MaterialPageRoute(
          builder: (context) => StatusViewerWrapper(
            allStatusGroups: [
              {
                'profile': {
                  'id': conversation.id,
                  'user_id': conversation.id,
                  'name': conversation.name,
                  'profile_image_url': conversation.imageUrl,
                },
                'statuses': conversation.statusData,
                'is_own': false,
              }
            ],
            initialGroupIndex: 0,
            currentUserId: _currentUserId ?? '',
            currentProfileId: _profileId ?? '',
            isFromGroup: true,
            onGroupWatched: (gId) {
              VibesSeenService.markSeen(
                currentUserId: _currentUserId ?? '',
                userId: conversation.id,
                profileId: gId,
                groupId: conversation.isGroup ? conversation.id : null,
              );
            },
          ),
        ),
      ).then((_) {
        VibesSeenService.markSeen(
          currentUserId: _currentUserId ?? '',
          userId: conversation.id,
          profileId: conversation.id,
          groupId: conversation.isGroup ? conversation.id : null,
        );
        ref.read(kidsConversationsProvider.notifier).refreshNow();
        safeSetState(() {});
      });
    }
  }

  /// 🎮 Gamified Conversation Card for Kids Mode
  /// Turns conversations into Playful Quest / Buddy Cards with Animal Mascots,
  /// Classmate Badges, 3D Gaming Border, Glowing Star Coins, and Online Beacons!
  Widget _buildKidGameConversationCard(ChatConversation conversation) {
    final isMentor =
        conversation.id == KidsConversationsNotifier.animalMentorId;
    final isAnimal = isMentor ||
        conversation.id.startsWith('kid_bot_') ||
        PocketKidsRobotsData.robotsAndHomies
            .any((m) => m.id == conversation.id);
    final isGroup = conversation.isGroup;
    final hasUnread = conversation.unreadCount > 0;

    KidMate? animalBot;
    if (isAnimal && !isMentor) {
      try {
        animalBot = PocketKidsRobotsData.robotsAndHomies.firstWhere(
          (m) => m.id == conversation.id,
        );
      } catch (_) {}
    }

    final cardBorderColor = isMentor
        ? const Color(0xFFFFD700)
        : (isAnimal
            ? const Color(0xFF38BDF8)
            : (isGroup ? const Color(0xFFA855F7) : const Color(0xFF10B981)));

    final cardWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasUnread
              ? const Color(0xFFF59E0B)
              : cardBorderColor.withValues(alpha: 0.45),
          width: hasUnread ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasUnread
                ? const Color(0xFFF59E0B).withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _handleConversationTap(conversation),
          onLongPress: () => _showConversationActionSheet(conversation),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // 1. Gamified Vector Avatar Portal (Tap to view Collectible Card)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (isAnimal || isMentor) {
                      PocketKidAvatarCardDialog.show(
                        context,
                        day: isMentor ? 100 : (animalBot?.dayLevel ?? 1),
                        mateId: conversation.id,
                        mateName: isMentor ? 'King' : conversation.name,
                        mateBio: animalBot?.bio ?? '',
                      );
                    } else {
                      _handleStatusTap(conversation);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      LivingSpreadingAura(
                        color: cardBorderColor,
                        size: 52,
                        speed: 0.8,
                        intensity: 0.9,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            border: Border.all(
                              color: cardBorderColor.withValues(alpha: 0.75),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cardBorderColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 1.2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: isMentor
                                ? VectorAvatarWidget(
                                    config: PocketKidsAvatarSystem
                                        .getAvatarConfigForDay(100),
                                    size: 46,
                                    showAura: true,
                                  )
                                : (animalBot != null
                                    ? VectorAvatarWidget(
                                        config: animalBot.vectorAvatarConfig,
                                        size: 46,
                                        showAura: true,
                                      )
                                    : (conversation.imageUrl != null &&
                                            conversation.imageUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: conversation.imageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) =>
                                                const Center(
                                                    child: Text('🎒')),
                                            errorWidget: (_, __, ___) =>
                                                const Center(
                                                    child: Text('🎒')),
                                          )
                                        : (conversation.avatarConfig != null
                                            ? VectorAvatarWidget(
                                                config:
                                                    VectorAvatarConfig.fromMap(
                                                        conversation
                                                            .avatarConfig!),
                                                size: 46,
                                                showAura: true,
                                              )
                                            : Center(
                                                child: Text(
                                                  isGroup ? '🏰' : '🎒',
                                                  style: const TextStyle(
                                                      fontSize: 22),
                                                ),
                                              )))),
                          ),
                        ),
                      ),

                      // Online Gaming Pulse Dot
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981),
                            border: Border.all(
                                color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 2. Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              isMentor ? 'King' : conversation.name,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMentor) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: Color(0xFFFFD700),
                            ),
                          ] else if (isAnimal) ...[
                            const SizedBox(width: 6),
                            Builder(
                              builder: (ctx) {
                                final report =
                                    PocketFriendshipScoreService.calculateReport(
                                  conversation.id,
                                  mateDayLevel: animalBot?.dayLevel,
                                );
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    PocketFriendshipScoreDialog.show(
                                      context,
                                      mateId: conversation.id,
                                      mateName: conversation.name,
                                      mateAvatar: animalBot?.avatar ?? '🐾',
                                      dayLevel: animalBot?.dayLevel ?? 1,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF2F8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFF472B6),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      '💖 ${report.score}%',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFDB2777),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ] else if (isGroup) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF8B5CF6)
                                      .withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '🏰 POCKET GANG',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF7C3AED),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        conversation.lastMessage ??
                            (isAnimal
                                ? 'Tap to speak with your buddy!'
                                : 'Ready to study English together!'),
                        style: GoogleFonts.inter(
                          color: hasUnread ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Right Badges (Unread Star Coins / Citadel Attack / Camera)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (conversation.lastMessageTime != null)
                      Text(
                        timeago.format(conversation.lastMessageTime!,
                            locale: 'en_short'),
                        style: GoogleFonts.outfit(
                          color: hasUnread
                              ? const Color(0xFFD97706)
                              : const Color(0xFF94A3B8),
                          fontSize: 10.5,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ⚔️ Quick Citadel Challenge Action
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            PocketCitadelAttackPage.openForUser(
                              context,
                              userId: conversation.id,
                              isKidMode: true,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF292524),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.7),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⚔️', style: TextStyle(fontSize: 9.5)),
                                const SizedBox(width: 2),
                                Text(
                                  'Attack',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '⭐ ${conversation.unreadCount}',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => _handleSnapCamera(conversation),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF38BDF8),
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('kid_chat_swipe_${conversation.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        HapticFeedback.heavyImpact();
        PocketGameAudioService.instance.playCoinSound();
        PocketCitadelAttackPage.openForUser(
          context,
          userId: conversation.id,
          targetName: conversation.name,
          isKidMode: true,
        );
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFF97316)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Text('⚔️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'ATTACK CITADEL! 🏰',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFDC2626)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'ATTACK CITADEL! 🏰',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Text('⚔️', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
      child: cardWidget,
    );
  }

  Widget _buildChatCategoryFilterChips(List<ChatConversation> conversations) {
    final validConversations = conversations
        .where((c) => PocketKidsService.isAllowedKidMateId(c.id))
        .toList();

    final animalsCount = validConversations
        .where((c) =>
            c.id.startsWith('kid_bot_') ||
            c.id == KidsConversationsNotifier.animalMentorId ||
            PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == c.id))
        .length;
    final classmatesCount = validConversations
        .where((c) =>
            !c.id.startsWith('kid_bot_') &&
            c.id != KidsConversationsNotifier.animalMentorId &&
            !PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == c.id) &&
            !c.isGroup &&
            !c.isTool &&
            !c.isNotification &&
            !c.isActiveTimer)
        .length;
    final unreadCount =
        validConversations.where((c) => c.unreadCount > 0).length;
    final groupsCount = validConversations.where((c) => c.isGroup).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildCategoryChipItem(
              title: '🌟 Quests',
              index: 0,
              icon: Icons.explore_rounded,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: '🐾 Animals',
              index: 1,
              count: animalsCount,
              icon: Icons.pets_rounded,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: '🎒 Classmates',
              index: 2,
              count: classmatesCount,
              icon: Icons.school_rounded,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: '📩 Mailbox',
              index: 3,
              count: (_pendingRequests.length + _sentRequests.length) > 0
                  ? (_pendingRequests.length + _sentRequests.length)
                  : null,
              icon: Icons.mark_email_unread_rounded,
              highlightBadge: _pendingRequests.isNotEmpty,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: '⭐ Active',
              index: 4,
              count: unreadCount,
              icon: Icons.star_rounded,
            ),
            const SizedBox(width: 6),
            _buildCategoryChipItem(
              title: '🏰 Pocket Gangs',
              index: 5,
              count: groupsCount,
              icon: Icons.groups_rounded,
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
  }) {
    final isSelected = _chatCategoryFilterIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        safeSetState(() {
          _chatCategoryFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.black : const Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black : const Color(0xFF334155),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black.withValues(alpha: 0.15)
                      : (highlightBadge
                          ? const Color(0xFFFF2A55)
                          : const Color(0xFFF1F5F9)),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: GoogleFonts.outfit(
                    color: isSelected
                        ? Colors.black
                        : (highlightBadge ? Colors.white : const Color(0xFF0F172A)),
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

  Widget _buildRequestsSubTabToggle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    safeSetState(() => _requestsSubTab = 0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _requestsSubTab == 0
                          ? const Color(0xFFFFD700)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 15,
                            color: _requestsSubTab == 0
                                ? const Color(0xFF78350F)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Received (${_pendingRequests.length})',
                            style: GoogleFonts.outfit(
                              color: _requestsSubTab == 0
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    safeSetState(() => _requestsSubTab = 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _requestsSubTab == 1
                          ? const Color(0xFFFFD700)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 15,
                            color: _requestsSubTab == 1
                                ? const Color(0xFF78350F)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sent (${_sentRequests.length})',
                            style: GoogleFonts.outfit(
                              color: _requestsSubTab == 1
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  Widget _buildPendingRequestsSliver() {
    if (_isLoadingRequests) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
          ),
        ),
      );
    }

    if (_requestsSubTab == 1) {
      if (_sentRequests.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.outbox_rounded,
                        size: 28, color: Color(0xFFD97706)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No Sent Requests',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
            final req = _sentRequests[index];
            final reqId = req['id']?.toString() ?? '$index';
            final isPending = req['status'] == 'pending';

            return RepaintBoundary(
              key: ValueKey('sent_$reqId'),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          const Color(0xFFFEF3C7),
                      backgroundImage: req['receiver_profile_image'] != null
                          ? NetworkImage(req['receiver_profile_image'])
                          : null,
                      child: req['receiver_profile_image'] == null
                          ? Text(
                              req['avatar'] ?? (req['receiver_name'] ?? 'M')[0].toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: req['avatar'] != null ? 18 : 14,
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
                            req['receiver_name'] ?? 'Mate',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            req['message'] ?? 'Connection request sent',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPending ? 'Pending ⏳' : 'Accepted ✨',
                        style: GoogleFonts.outfit(
                          color: isPending
                              ? const Color(0xFFB45309)
                              : const Color(0xFF15803D),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _sentRequests.length,
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
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_search_rounded,
                      size: 28, color: Color(0xFFD97706)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No Pending Requests',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
          final reqId = req['id']?.toString() ?? '$index';
          final senderUserId = req['sender_id']?.toString() ?? '';

          return RepaintBoundary(
            key: ValueKey(reqId),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (senderUserId.isNotEmpty) {
                        PocketCitadelAttackPage.openForUser(
                          context,
                          userId: senderUserId,
                          isKidMode: true,
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          const Color(0xFFFEF3C7),
                      backgroundImage: req['sender_profile_image'] != null
                          ? NetworkImage(req['sender_profile_image'])
                          : null,
                      child: req['sender_profile_image'] == null
                          ? Text(
                              req['avatar'] ?? (req['sender_name'] ?? 'M')[0].toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: req['avatar'] != null ? 18 : 14,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req['sender_name'] ?? 'Friend',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          req['message'] ?? 'wants to connect as a Mate',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: const Color(0xFF78350F),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: const Size(60, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFF94A3B8)),
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        onPressed: () => _declineMateRequest(req),
                        tooltip: 'Decline',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: _pendingRequests.length,
      ),
    );
  }

  Widget _buildVibeUploadStatusTile() {
    return ValueListenableBuilder<VibeUploadTask?>(
      valueListenable: PocketVibesUploadManager.instance.activeTask,
      builder: (context, task, _) {
        if (task == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: task.isError
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : task.isCompleted
                          ? Colors.green.withValues(alpha: 0.5)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded,
                      color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.isCompleted
                          ? 'Vibe uploaded successfully!'
                          : task.isError
                              ? 'Failed to upload vibe'
                              : 'Uploading your Vibe...',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestsBanner() {
    if (_pendingRequests.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final topReq = _pendingRequests.first;
    final senderName = topReq['sender_name'] ?? 'Friend';
    final msg = topReq['message'] ?? 'wants to connect as your Mate';
    final hasMultiple = _pendingRequests.length > 1;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFDE68A),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  safeSetState(() => _chatCategoryFilterIndex = 3);
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    safeSetState(() => _chatCategoryFilterIndex = 3);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              senderName,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasMultiple) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${_pendingRequests.length - 1} more',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF4338CA),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        msg,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF78350F),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(62, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _acceptMateRequest(topReq),
                child: Text(
                  'Accept',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTabItem(String label, int index) {
    final isSelected = _searchTabIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        safeSetState(() => _searchTabIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? const Color(0xFF78350F) : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFEF3C7)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? const Color(0xFFD97706)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? const Color(0xFFB45309)
                    : const Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌟 Top Sticky & Scrollable Header for Kids Chat
/// Exactly replicating Adult _HomeMainHeaderDelegate:
/// - Logo + PoketMates
/// - Search, Notification Bell with badge, Add Group
/// - Horizontal Status Display Widget
/// - 3-Tab Segmented Capsule (Chats, Vibes, Thoughts)
/// - Search input
class _KidsChatHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String currentUserId;
  final String currentProfileId;
  final AsyncValue<ActiveUsersData> activeUsersRef;
  final VoidCallback onTapSearch;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapCreateGroup;
  final int statusRefreshKey;
  final VoidCallback onRefresh;

  final int selectedIndex;
  final ValueChanged<int> onTabTap;

  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearching;
  final ValueNotifier<String> vibesFilterNotifier;
  final int pendingRequestsCount;

  _KidsChatHeaderDelegate({
    required this.topPadding,
    required this.currentUserId,
    required this.currentProfileId,
    required this.activeUsersRef,
    required this.onTapSearch,
    required this.onTapNotifications,
    required this.onTapCreateGroup,
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

  static const double topBarHeight = 44.0;
  static const double tabBarHeight = 42.0;
  static const double searchBarHeight = 48.0;

  double get scrollableHeight => topBarHeight;
  double get stickyHeight => tabBarHeight + searchBarHeight;

  @override
  double get maxExtent => topPadding + scrollableHeight + stickyHeight;

  @override
  double get minExtent => topPadding + stickyHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double scrollProgress =
        (shrinkOffset / scrollableHeight).clamp(0.0, 1.0);
    final Color headerColor = Color.lerp(
      Colors.transparent,
      const Color(0xFF082F49).withValues(alpha: 0.88),
      scrollProgress,
    )!;

    return material.Material(
      color: headerColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Scrollable Section (Top App Bar + Status Stories)
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
                    // Top Bar (Kids Arcade Gaming Header)
                      Container(
                        height: topBarHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: material.Image.asset(
                                      'assets/images/pocket_mates_logo.png',
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'POCKET MATES',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.3,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            _buildAdultSwitchBadge(context),
                                          ],
                                        ),
                                        Text(
                                          'STUDENT REALM 🎒',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF38BDF8),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.4,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeaderIconButton(
                                  context,
                                  icon: material.Icons.search_rounded,
                                  onTap: onTapSearch,
                                ),
                                const SizedBox(width: 6),
                                _buildHeaderIconButton(
                                  context,
                                  icon: material.Icons.notifications_outlined,
                                  badgeCount: pendingRequestsCount,
                                  onTap: onTapNotifications,
                                ),
                                const SizedBox(width: 6),
                                _buildHeaderIconButton(
                                  context,
                                  icon: material.Icons.person_add_rounded,
                                  onTap: onTapCreateGroup,
                                ),
                              ],
                            ),
                          ],
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
                // Tab Bar Capsule: 3 Tabs (Chats 💬, Vibes 🎈, Thoughts 💡)
                Container(
                  height: tabBarHeight,
                  color: headerColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Row(
                      children: [
                        _buildTabItem('Chats', 0),
                        _buildTabItem('Vibes', 1),
                        _buildTabItem('Thoughts', 2),
                      ],
                    ),
                  ),
                ),
                // Search Bar
                Container(
                  height: searchBarHeight,
                  color: headerColor,
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: material.TextField(
                      controller: searchController,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFF59E0B),
                      decoration: material.InputDecoration(
                        isDense: true,
                        hintText: selectedIndex == 2
                            ? 'Search thoughts 💡...'
                            : selectedIndex == 1
                                ? 'Search vibes 🎈...'
                                : '🔍 Search animal buddies & classmates...',
                        hintStyle: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        prefixIcon: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 8.0),
                          child: Icon(
                            material.Icons.search_rounded,
                            color: const Color(0xFF38BDF8),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: material.CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            if (searchQuery.isNotEmpty)
                              material.Material(
                                color: material.Colors.transparent,
                                child: material.IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 28, minHeight: 28),
                                  icon: const Icon(
                                    material.Icons.clear_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 16,
                                  ),
                                  onPressed: () => searchController.clear(),
                                ),
                              ),
                          ],
                        ),
                        border: material.InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
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
  Widget _buildTabItem(String label, int index) {
    final isSelected = selectedIndex == index;
    final textUnselected = const Color(0xFF64748B);
    final displayLabel = index == 0
        ? 'Chats 💬'
        : (index == 1 ? 'Vibes 🎈' : 'Thoughts 💡');

    return Expanded(
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onTabTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : material.Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              displayLabel,
              style: GoogleFonts.outfit(
                color: isSelected ? material.Colors.white : textUnselected,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdultSwitchBadge(BuildContext context) {
    return GestureDetector(
      onTap: () => _promptSwitchToAdult(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              material.Icons.lock_outline_rounded,
              color: Color(0xFF38BDF8),
              size: 11,
            ),
            const SizedBox(width: 3),
            Text(
              'ADULT',
              style: GoogleFonts.outfit(
                color: const Color(0xFF38BDF8),
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptSwitchToAdult(BuildContext context) async {
    HapticFeedback.lightImpact();
    final unlocked = await PocketParentalPatternLock.verifyOrSetup(
      context,
      title: 'Parent Verification 🔒',
      subtitle: 'Draw pattern lock to switch back to Adult Mode.',
    );
    if (unlocked) {
      await PocketKidsService.activateAdultAccount();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          material.MaterialPageRoute(builder: (_) => const HomePageWidget()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildHeaderIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
    Color? iconColor,
  }) {
    final bgColor = const Color(0xFF1E293B);
    final borderColor = const Color(0xFF334155);
    final effectiveIconColor = iconColor ?? const Color(0xFF38BDF8);

    return material.Material(
      color: material.Colors.transparent,
      child: material.InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: effectiveIconColor, size: 20),
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
  bool shouldRebuild(covariant _KidsChatHeaderDelegate oldDelegate) {
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