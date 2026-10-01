import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pocket_mates_app/custom_code/widgets/thread_feed_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_feed_vibe_share_sheet.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_thought_game_card.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_reels_game_engine.dart';

class ThoughtsFeedSection extends StatefulWidget {
  final String currentUserId;
  final String currentProfileId;
  final String searchQuery;

  const ThoughtsFeedSection({
    super.key,
    required this.currentUserId,
    required this.currentProfileId,
    this.searchQuery = '',
    this.onStatusShared,
  });

  final VoidCallback? onStatusShared;

  @override
  State<ThoughtsFeedSection> createState() => _ThoughtsFeedSectionState();
}

class _ThoughtsFeedSectionState extends State<ThoughtsFeedSection>
    with SingleTickerProviderStateMixin {
  final supabase = SupaFlow.client;
  late TabController _tabController;
  // Removed local _scrollController to use PrimaryScrollController from NestedScrollView

  List<Map<String, dynamic>> _publicThreads = [];
  List<Map<String, dynamic>> _followingThreads = [];
  Set<String> _likedThreadIds = {};

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 15;

  String _activeTab = 'Public'; // 'Public' or 'Following'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Removed _scrollController.addListener(_onScroll);
    _loadCache();
    _fetchThreads(refresh: true);
    _fetchUserLikes();
  }

  @override
  void didUpdateWidget(ThoughtsFeedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _fetchThreads(refresh: true);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    // Removed _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _activeTab = _tabController.index == 0 ? 'Public' : 'Following';
        _currentPage = 0;
        _hasMore = true;
      });
      _fetchThreads(refresh: true);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels >=
          notification.metrics.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMore) {
          _fetchThreads();
        }
      }
    }
    return false;
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_thoughts_$_activeTab');
    if (cached != null && widget.searchQuery.isEmpty) {
      setState(() {
        final List<dynamic> decoded = jsonDecode(cached);
        if (_activeTab == 'Public') {
          _publicThreads = List<Map<String, dynamic>>.from(decoded);
        } else {
          _followingThreads = List<Map<String, dynamic>>.from(decoded);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCache(List<Map<String, dynamic>> data) async {
    if (widget.searchQuery.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_thoughts_$_activeTab', jsonEncode(data));
  }

  Future<void> _fetchUserLikes() async {
    final Set<String> likes = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final robotLiked = prefs.getStringList('robot_liked_threads_${widget.currentUserId}') ?? [];
      likes.addAll(robotLiked);

      if (widget.currentUserId.isNotEmpty) {
        final response = await supabase
            .from('thread_likes')
            .select('thread_id')
            .eq('user_id', widget.currentUserId);

        likes.addAll(response.map<String>((e) => e['thread_id'].toString()));
      }

      if (mounted) {
        setState(() {
          _likedThreadIds = likes;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user likes: $e');
    }
  }

  Future<void> _fetchThreads({bool refresh = false}) async {
    if (_isLoadingMore) return;

    if (refresh) {
      setState(() {
        _currentPage = 0;
        _hasMore = true;
        if ((_activeTab == 'Public' && _publicThreads.isEmpty) ||
            (_activeTab == 'Following' && _followingThreads.isEmpty)) {
          _isLoading = true;
        }
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      var query = supabase.from('threads_view').select();

      // Apply Search Filter
      if (widget.searchQuery.isNotEmpty) {
        query = query.ilike('content', '%${widget.searchQuery}%');
      }

      if (_activeTab == 'Following') {
        // Get people I follow
        final followingResponse = await supabase
            .from('follows')
            .select('followed_id')
            .eq('follower_id', widget.currentUserId);

        final followedIds =
            followingResponse.map((e) => e['followed_id']).toList();
        if (followedIds.isEmpty) {
          setState(() {
            _followingThreads = [];
            _isLoading = false;
            _isLoadingMore = false;
            _hasMore = false;
          });
          return;
        }
        query = query.filter('user_id', 'in', followedIds);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      final List<Map<String, dynamic>> newThreads =
          List<Map<String, dynamic>>.from(response);

      // 🤖 Inject Robot English Learning Thoughts into Public Feed
      if ((refresh || _currentPage == 0) && _activeTab == 'Public') {
        final robotThoughts = PocketRobotService.getAllRobotFeedThoughts(
          currentUserId: widget.currentUserId,
        );
        final filteredRobo = widget.searchQuery.isNotEmpty
            ? robotThoughts.where((t) {
                final content = (t['content'] ?? '').toString().toLowerCase();
                final name = (t['name'] ?? '').toString().toLowerCase();
                final q = widget.searchQuery.toLowerCase();
                return content.contains(q) || name.contains(q);
              }).toList()
            : robotThoughts;

        // Ensure real human & user thoughts ALWAYS appear first at the top of the feed!
        if (newThreads.isEmpty) {
          newThreads.addAll(filteredRobo);
        } else if (filteredRobo.isNotEmpty) {
          // Interleave robot thoughts after user thoughts (index 2 and 5)
          final insertIdx = newThreads.length >= 2 ? 2 : newThreads.length;
          newThreads.insert(insertIdx, filteredRobo.first);
          if (filteredRobo.length > 1 && newThreads.length > 4) {
            newThreads.insert(4, filteredRobo[1]);
          }
        }
      }

      if (mounted) {
        setState(() {
          if (refresh) {
            if (_activeTab == 'Public') {
              _publicThreads = newThreads;
            } else {
              _followingThreads = newThreads;
            }
          } else {
            if (_activeTab == 'Public') {
              _publicThreads.addAll(newThreads);
            } else {
              _followingThreads.addAll(newThreads);
            }
          }

          _isLoading = false;
          _isLoadingMore = false;
          _hasMore = newThreads.length >= _pageSize;
          _currentPage++;
        });

        if (refresh) _saveCache(newThreads);
      }
    } catch (e) {
      debugPrint('Error fetching threads: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleLike(String threadId) async {
    final bool currentlyLiked = _likedThreadIds.contains(threadId);

    setState(() {
      if (currentlyLiked) {
        _likedThreadIds.remove(threadId);
      } else {
        _likedThreadIds.add(threadId);
      }
    });

    // Handle robot posts locally with persistent preferences
    if (threadId.contains('robot')) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final likedList = _likedThreadIds.where((id) => id.contains('robot')).toList();
        await prefs.setStringList('robot_liked_threads_${widget.currentUserId}', likedList);

        final threads =
            _activeTab == 'Public' ? _publicThreads : _followingThreads;
        final index = threads.indexWhere((t) => t['id'] == threadId);
        if (index != -1) {
          setState(() {
            threads[index]['like_count'] =
                (threads[index]['like_count'] ?? 0) + (currentlyLiked ? -1 : 1);
          });
        }
      } catch (_) {}
      return;
    }

    try {
      if (currentlyLiked) {
        await supabase
            .from('thread_likes')
            .delete()
            .eq('thread_id', threadId)
            .eq('user_id', widget.currentUserId);
      } else {
        await supabase.from('thread_likes').insert({
          'thread_id': threadId,
          'user_id': widget.currentUserId,
        });
      }

      // Update local count
      final threads =
          _activeTab == 'Public' ? _publicThreads : _followingThreads;
      final index = threads.indexWhere((t) => t['id'] == threadId);
      if (index != -1) {
        setState(() {
          threads[index]['like_count'] =
              (threads[index]['like_count'] ?? 0) + (currentlyLiked ? -1 : 1);
        });
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (currentlyLiked) {
          _likedThreadIds.add(threadId);
        } else {
          _likedThreadIds.remove(threadId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
        // Minimal Sleek Tab Switcher
        Container(
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFFFFFC00),
              borderRadius: BorderRadius.circular(15),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            labelStyle:
                GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11.5),
            unselectedLabelStyle:
                GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11.5),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Public'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        // Thoughts Compose Prompt Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateThreadPage(userId: widget.currentUserId),
                ),
              );
              if (result != null) {
                await _fetchThreads(refresh: true);
                if (mounted && result is Map<String, dynamic>) {
                  _showInstantShareModal(context, result);
                }
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2232) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        const Color(0xFFFFFC00).withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFFFFFC00),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "What's on your mind? Share a thought...",
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Feed List
        Expanded(
          child: _isLoading &&
                  (_activeTab == 'Public'
                      ? _publicThreads.isEmpty
                      : _followingThreads.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
              : NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: RefreshIndicator(
                    onRefresh: () => _fetchThreads(refresh: true),
                    color: const Color(0xFFFFFC00),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: _buildFeedList(),
                  ),
                ),
        ),
      ],
    ),
   );
  }

  Widget _buildFeedList() {
    final threads = _activeTab == 'Public' ? _publicThreads : _followingThreads;

    if (threads.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.forum_outlined, size: 64, color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  widget.searchQuery.isNotEmpty
                      ? 'No items found matching "${widget.searchQuery}"'
                      : (_activeTab == 'Public'
                          ? 'No thoughts yet'
                          : 'Not following anyone yet'),
                  style:
                      GoogleFonts.outfit(color: FlutterFlowTheme.of(context).secondaryText, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      // Removed controller to use PrimaryScrollController (NestedScrollView inner controller)
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: threads.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == threads.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: CircularProgressIndicator(
                    color: Colors.yellow, strokeWidth: 2)),
          );
        }

        final thread = threads[index];
        return TwitterThreadCard(
          key: ValueKey(thread['id']),
          thread: thread,
          currentUserId: widget.currentUserId,
          isLiked: _likedThreadIds.contains(thread['id']),
          onLike: () => _handleLike(thread['id']),
          onStatusShared: widget.onStatusShared,
          onComment: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreadCommentsPage(
                  threadId: thread['id'],
                  threadContent: thread['content'] ?? '',
                ),
              ),
            ).then((_) => _fetchThreads(refresh: true));
          },
        );
      },
    );
  }

  void _showInstantShareModal(BuildContext context, Map<String, dynamic> thoughtData) {
    final content = (thoughtData['content'] ?? '').toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131826) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF22C55E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Thought Shared! ✨',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E2538), const Color(0xFF141926)]
                        : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFFFFC00),
                          child: Icon(Icons.person, color: Colors.black87, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Just now • Public Thought',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        SharePlus.share(
                          '💬 "$content"\n\n— Shared via Pocket Mates\nhttps://pocketmates.app',
                          subject: 'Pocket Mates Thought',
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18, color: Colors.black),
                      label: Text(
                        'Share with Mates',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thought copied to clipboard! 📋'),
                          backgroundColor: Color(0xFF10B981),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class TwitterThreadCard extends StatefulWidget {
  final Map<String, dynamic> thread;
  final String currentUserId;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const TwitterThreadCard({
    super.key,
    required this.thread,
    required this.currentUserId,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    this.onStatusShared,
  });

  final VoidCallback? onStatusShared;

  @override
  State<TwitterThreadCard> createState() => _TwitterThreadCardState();
}

class _TwitterThreadCardState extends State<TwitterThreadCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String content = widget.thread['content'] ?? '';
    final String name = widget.thread['name'] ?? 'Anonymous';
    final createdAt = DateTime.parse(
        widget.thread['created_at'] ?? DateTime.now().toIso8601String());
    final likes =
        (widget.thread['like_count'] ?? 0) + (widget.thread['fake_likes'] ?? 0);
    final comments = widget.thread['comment_count'] ?? 0;

    final bool isLongContent = content.length > 180;
    final String displayedContent = (_isExpanded || !isLongContent)
        ? content
        : '${content.substring(0, 180)}...';
    final bool isRobot = widget.thread['is_robot'] == true ||
        widget.thread['profile']?['is_robot'] == true ||
        widget.thread['user_id']?.toString().startsWith('robot_') == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve author's evolution avatar
    VectorAvatarConfig avatarConfig;
    if (isRobot) {
      final robot = PocketRobotService.getRobotById(widget.thread['user_id']?.toString() ?? '') ??
          PocketRobotService.getRobotByLevel(1);
      final dynLvl = PocketRobotService.getDynamicLevel(robot);
      avatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(dynLvl);
    } else {
      final profile = widget.thread['profile'] is Map ? widget.thread['profile'] : null;
      final rawScore = widget.thread['pocket_score'] ?? profile?['pocket_score'];
      final score = (rawScore as num?)?.toInt() ?? 0;
      final stage = PocketScoreLevelEngine.getLevelFromScore(score);
      final talisman = widget.thread['equipped_talisman']?.toString() ?? profile?['equipped_talisman']?.toString() ?? profile?['talisman_id']?.toString();
      avatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(stage.clamp(1, 90), talismanId: talisman);
    }

    final authorId = widget.thread['user_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131B26).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? (isRobot
                  ? const Color(0xFFFFB300).withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.10))
              : Colors.black.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? (isRobot
                    ? const Color(0xFFFFB300).withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.35))
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar (Tapping navigates to Attack Profile)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (authorId.isNotEmpty) {
                      PocketCitadelAttackPage.openForUser(context, userId: authorId);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isRobot
                            ? const Color(0xFFFFB300)
                            : const Color(0xFFFFFC00).withValues(alpha: 0.35),
                        width: isRobot ? 1.8 : 1,
                      ),
                    ),
                    child: ClipOval(
                      child: VectorAvatarWidget(
                        config: avatarConfig,
                        size: 36,
                        showAura: isRobot,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Header: Name & Time (Tapping name navigates to Attack Profile)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (authorId.isNotEmpty) {
                            PocketCitadelAttackPage.openForUser(context, userId: authorId);
                          }
                        },
                        child: Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(createdAt, locale: 'en_short'),
                        style: GoogleFonts.inter(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                ReportButton(
                  contentType: 'thought',
                  contentId: widget.thread['id'].toString(),
                  contentTitle: widget.thread['content'] ?? 'Thought',
                  onReportSubmitted: () {},
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Content
            GestureDetector(
              onTap: isLongContent
                  ? () => setState(() => _isExpanded = !_isExpanded)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayedContent,
                    style: GoogleFonts.inter(
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 14.0,
                      height: 1.45,
                    ),
                  ),
                  if (isLongContent)
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        _isExpanded ? 'Show less' : 'Read more',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 🎮 Interactive Game Challenge Card (Sentence Builder, Gap Fill, Smart Reply)
            if (widget.thread['is_game'] == true &&
                widget.thread['game_card'] is ReelGameCard)
              PocketThoughtGameCard(
                card: widget.thread['game_card'] as ReelGameCard,
                authorName: name,
              ),

            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                _buildAction(
                  icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: likes.toString(),
                  activeColor: Colors.pinkAccent,
                  isActive: widget.isLiked,
                  onTap: widget.onLike,
                ),
                const SizedBox(width: 16),
                _buildAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: comments.toString(),
                  activeColor: const Color(0xFFFFFC00),
                  isActive: false,
                  onTap: widget.onComment,
                ),
                const SizedBox(width: 16),
                _buildAction(
                  icon: Icons.send_rounded,
                  label: '',
                  activeColor: FlutterFlowTheme.of(context).secondaryText,
                  isActive: false,
                  onTap: () {
                    _showShareBottomSheet(context);
                  },
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    PocketFeedVibeShareSheet.show(
      context,
      customText: widget.thread['content'] ?? '',
      thoughtId: widget.thread['id']?.toString(),
      onSharedSuccessfully: () {
        widget.onStatusShared?.call();
      },
    );
  }


  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color activeColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color = isActive ? activeColor : FlutterFlowTheme.of(context).secondaryText;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17.5, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4.5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
