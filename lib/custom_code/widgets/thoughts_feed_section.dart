import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pocket_mates_app/custom_code/widgets/verfied_search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/thread_feed_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';

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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.addListener(_onScroll);
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
    _scrollController.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _fetchThreads();
      }
    }
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
    if (widget.currentUserId.isEmpty) return;
    try {
      final response = await supabase
          .from('thread_likes')
          .select('thread_id')
          .eq('user_id', widget.currentUserId);

      if (mounted) {
        setState(() {
          _likedThreadIds =
              response.map<String>((e) => e['thread_id'].toString()).toSet();
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
          _hasMore = newThreads.length == _pageSize;
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
    return Column(
      children: [
        // Tab Switcher
        Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white54,
            labelStyle:
                GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Public'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        // Feed List
        Expanded(
          child: _isLoading &&
                  (_activeTab == 'Public'
                      ? _publicThreads.isEmpty
                      : _followingThreads.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.yellow))
              : RefreshIndicator(
                  onRefresh: () => _fetchThreads(refresh: true),
                  color: Colors.yellow,
                  backgroundColor: Colors.black,
                  child: _buildFeedList(),
                ),
        ),
      ],
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
                Icon(Icons.forum_outlined, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  widget.searchQuery.isNotEmpty
                      ? 'No items found matching "${widget.searchQuery}"'
                      : (_activeTab == 'Public'
                          ? 'No thoughts yet'
                          : 'Not following anyone yet'),
                  style:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
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
    final String? avatar = widget.thread['profile_image_url'];
    final createdAt = DateTime.parse(
        widget.thread['created_at'] ?? DateTime.now().toIso8601String());
    final likes =
        (widget.thread['like_count'] ?? 0) + (widget.thread['fake_likes'] ?? 0);
    final comments = widget.thread['comment_count'] ?? 0;

    final bool isLongContent = content.length > 180;
    final String displayedContent = (_isExpanded || !isLongContent)
        ? content
        : '${content.substring(0, 180)}...';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerfiedSearchProfileDetailPage(
                            userId: widget.thread['user_id'] ?? ''),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.yellow.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: avatar != null
                          ? CachedNetworkImageProvider(avatar)
                          : null,
                      child: avatar == null
                          ? Text(name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.yellow))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Header: Name & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        timeago.format(createdAt, locale: 'en_short'),
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 12,
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

            const SizedBox(height: 12),

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
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (isLongContent)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _isExpanded ? 'Show less' : 'Read more',
                        style: GoogleFonts.outfit(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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
                const SizedBox(width: 24),
                _buildAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: comments.toString(),
                  activeColor: Colors.yellow,
                  isActive: false,
                  onTap: widget.onComment,
                ),
                const SizedBox(width: 24),
                _buildAction(
                  icon: Icons.send_rounded, // Instagram-style share
                  label: '',
                  activeColor: Colors.white70,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GroupSelectionBottomSheet(
        contentToShare: widget.thread['content'] ?? '',
        currentUserId: widget.currentUserId,
        onGroupSelected: (groupId, groupName, userMessage) {
          Navigator.pop(context);
          _shareToGroup(groupId, groupName, userMessage);
        },
        onPersonSelected: (userId, userName, userMessage) {
          Navigator.pop(context);
          _shareToPerson(userId, userName, userMessage);
        },
        onStatusSelected: (userMessage) {
          Navigator.pop(context);
          _shareToStatus(userMessage);
        },
        onWhatsAppShare: () {
          Navigator.pop(context);
          final text =
              "Check out this thought: ${widget.thread['content'] ?? ''}";
          Share.share(text);
        },
      ),
    );
  }

  Future<void> _shareToPerson(
      String userId, String userName, String? userMessage) async {
    try {
      final supabase = SupaFlow.client;
      // Prepare payload
      final Map<String, dynamic> messageData = {
        'sender_id': widget.currentUserId,
        'receiver_id': userId,
        'content': widget.thread['content'] ?? '',
        'message_text': widget.thread['content'] ?? '',
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'message_type': 'thought',
        'thought_id': widget.thread['id'],
      };

      await supabase.from('messages').insert(messageData);

      // Update conversation record
      final existingConv = await supabase
          .from('conversations')
          .select('id, unread_count')
          .or('and(user1_id.eq.${widget.currentUserId},user2_id.eq.$userId),and(user1_id.eq.$userId,user2_id.eq.${widget.currentUserId})')
          .maybeSingle();

      if (existingConv != null) {
        await supabase.from('conversations').update({
          'last_message': widget.thread['content'] ?? '',
          'last_message_time': DateTime.now().toIso8601String(),
          'last_sender_id': widget.currentUserId,
          'unread_count': (existingConv['unread_count'] ?? 0) + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingConv['id']);
      } else {
        await supabase.from('conversations').insert({
          'user1_id': widget.currentUserId,
          'user2_id': userId,
          'last_message': widget.thread['content'] ?? '',
          'last_message_time': DateTime.now().toIso8601String(),
          'last_sender_id': widget.currentUserId,
          'unread_count': 1,
        });
      }

      if (mounted) {
        widget.onStatusShared?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared to $userName successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareToGroup(
      String groupId, String groupName, String? userMessage) async {
    try {
      final supabase = SupaFlow.client;
      final Map<String, dynamic> messageData = {
        'group_id': groupId,
        'sender_id': widget.currentUserId,
        'message_text': widget.thread['content'] ?? '',
        'message_type': 'thought',
        'thought_id': widget.thread['id'],
      };

      await supabase.from('group_messages').insert(messageData);

      await supabase.from('groups').update({
        'last_message': widget.thread['content'] ?? '',
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      if (mounted) {
        widget.onStatusShared?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared to $groupName successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareToStatus([String? userMessage]) async {
    try {
      final supabase = SupaFlow.client;
      final profileResponse = await supabase
          .from('profile')
          .select('id')
          .eq('user_id', widget.currentUserId)
          .single();
      final profileId = profileResponse['id'] as String;

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatusUploadWidget(
            userId: widget.currentUserId,
            profileId: profileId,
            sharedContent: widget.thread['content'] ?? '',
            sharedContentType: 'thought',
            sharedContentId: widget.thread['id']?.toString(),
            sharedMetadata: widget.thread,
          ),
        ),
      );

      if (result == true && mounted) {
        widget.onStatusShared?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing to status: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color activeColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color = isActive ? activeColor : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
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
