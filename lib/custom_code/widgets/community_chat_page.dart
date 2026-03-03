// Automatic FlutterFlow imports
import 'package:pocket_mates_app/auth_page/auth_page_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:async';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui' as ui;
import 'dart:ui' as ui;
import 'package:shimmer/shimmer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as img;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/material.dart' as flutter;

class CommunityChatPage extends StatefulWidget {
  final double? width;
  final double? height;
  const CommunityChatPage({
    super.key,
    this.width,
    this.height,
  });

  @override
  _CommunityChatPageState createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage>
    with TickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  late String _currentUserId;
  String? _currentUserProfileId;
  late TabController _tabController;

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  Uint8List? _selectedImageBytes;
  Map<String, dynamic>? _group;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
    _tabController = TabController(length: 2, vsync: this);
    if (_currentUserId.isNotEmpty) {
      _initializeUserProfile();
      _setupAutoRefresh();
      _fetchGroupDatahandskill();
    }
    super.initState();
  }

  Future<void> _initializeUserProfile() async {
    try {
      // Get current user's profile_id
      final profileResponse = await _supabase
          .from('profile')
          .select('id')
          .eq('user_id', _currentUserId)
          .single();

      _currentUserProfileId = profileResponse['id'];
      _loadData();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentUserProfileId != null) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (_currentUserProfileId == null) return;

    await Future.wait([
      _loadConversations(),
      _loadGroups(),
    ]);
  }

  Future<void> _loadConversations() async {
    final user = _supabase.auth.currentUser;
    try {
      final conversationsResponse = await _supabase
          .from('conversations')
          .select('*')
          .or('user1_id.eq.${user!.id},user2_id.eq.${user.id}')
          .order('updated_at', ascending: false);

      final userIds = <String>{};
      for (final conv in conversationsResponse) {
        userIds.add(conv['user1_id']);
        userIds.add(conv['user2_id']);
      }

      final profilesResponse = await _supabase
          .from('profile')
          .select('user_id, name, shop_name, profile_image_url, phone_no')
          .inFilter('user_id', userIds.toList());

      final profileMap = <String, Map<String, dynamic>>{};
      for (final profile in profilesResponse) {
        profileMap[profile['user_id']] = profile;
      }

      final conversations = conversationsResponse.map((conv) {
        return {
          ...conv,
          'user1_profile': profileMap[conv['user1_id']],
          'user2_profile': profileMap[conv['user2_id']],
        };
      }).toList();

      if (mounted) {
        safeSetState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadGroups() async {
    if (_currentUserProfileId == null) return;

    try {
      // First get groups where user is a member
      final groupMembersResponse = await _supabase
          .from('group_members')
          .select('group_id')
          .eq('profile_id', _currentUserProfileId!)
          .eq('is_active', true);

      final groupIds = groupMembersResponse
          .map((member) => member['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        if (mounted) {
          safeSetState(() {
            _groups = [];
            _isLoading = false;
          });
        }
        return;
      }

      // Get group details with member count
      final groupsResponse = await _supabase
          .from('groups')
          .select('''
            *,
            member_count:group_members(count)
          ''')
          .inFilter('id', groupIds)
          .eq('is_active', true)
          .eq('group_members.is_active', true)
          .order('updated_at', ascending: false);

      if (mounted) {
        safeSetState(() {
          _groups = groupsResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchGroupDatahandskill() async {
    try {
      // Fetch group details
      final groupResponse = await _supabase
          .from('groups')
          .select()
          .eq('id', '6364e70c-e585-41c2-abd3-0de9dc9ec9f0')
          .single();

      // Check if user is a member
      final memberResponse = await _supabase
          .from('group_members')
          .select()
          .eq('group_id', '6364e70c-e585-41c2-abd3-0de9dc9ec9f0')
          .eq('user_id', _currentUserId);

      // Fetch messages
      // final messagesResponse = await _supabase
      //     .from('group_messages')
      //     .select('*, sender:users(*)')
      //     .eq('group_id', widget.groupId)
      //     .order('created_at', ascending: false)
      //     .limit(50);

      safeSetState(() {
        _group = groupResponse;
        _isMember = memberResponse.isNotEmpty;
        // _messages = List<Map<String, dynamic>>.from(messagesResponse);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching group data: $e');
      safeSetState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading group data: $e')),
      );
    }
  }

  Future<void> _joinGroup() async {
    try {
      await _supabase.from('group_members').insert({
        'group_id': '6364e70c-e585-41c2-abd3-0de9dc9ec9f0',
        'user_id': _currentUserId,
        'role': 'member',
        "profile_id": _currentUserProfileId
      });

      // Update last message time (optional)
      await _supabase
          .from('groups')
          .update({'updated_at': DateTime.now().toUtc().toIso8601String()}).eq(
              'id', '6364e70c-e585-41c2-abd3-0de9dc9ec9f0');

      safeSetState(() {
        _isMember = true;
      });
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining group: $e')),
      );
    }
  }

  Map<String, dynamic> _getOtherUser(Map<String, dynamic> conversation) {
    final isUser1 = conversation['user1_id'] == _currentUserId;
    final profile =
        isUser1 ? conversation['user2_profile'] : conversation['user1_profile'];

    return {
      'id': isUser1 ? conversation['user2_id'] : conversation['user1_id'],
      'name': profile?['name'] ?? profile?['shop_name'] ?? 'Unknown',
      'avatar': profile?['profile_image_url'],
      'phonenumber': profile?['phone_no'],
    };
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

// Alternative without shimmer package - using AnimationController
  Widget _buildShimmerEffectAlternative() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.1, 0.3, 0.4],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 8, // Show 8 shimmer items
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Profile picture shimmer
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _buildShimmerEffect(),
                  ),
                ),
                const SizedBox(width: 12),
                // Chat content shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Name shimmer
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildShimmerEffect(),
                          ),
                          // Time shimmer
                          Container(
                            width: 40,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _buildShimmerEffect(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Message shimmer
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: _buildShimmerEffect(),
                      ),
                      const SizedBox(height: 4),
                      // Shorter message shimmer
                      Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: _buildShimmerEffect(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final allChats = [
      ..._conversations.map((conv) => {
            'type': 'personal',
            'data': conv,
            'other_user': _getOtherUser(conv),
          }),
      ..._groups.map((group) => {
            'type': 'group',
            'data': group,
          }),
    ];

    // Sort by last activity
    allChats.sort((a, b) {
      final aTime = (a['data'] as Map<String, dynamic>?)?['last_message_time']
              as String? ??
          (a['data'] as Map<String, dynamic>?)?['updated_at'] as String? ??
          '1970-01-01T00:00:00Z';
      final bTime = (b['data'] as Map<String, dynamic>?)?['last_message_time']
              as String? ??
          (b['data'] as Map<String, dynamic>?)?['updated_at'] as String? ??
          '1970-01-01T00:00:00Z';
      return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
    });

    if (allChats.isEmpty) {
      return Center(
          child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.yellow.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: _group!['group_image_url'] != null
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(_group!['group_image_url']),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[800],
                    child: Icon(Icons.group, color: Colors.yellow, size: 30),
                  ),
                ),
          title: Text(
            _group!['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_group!['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _group!['description'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (!_isMember) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _joinGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Join Group',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.yellow,
      backgroundColor: Colors.grey.shade900,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: allChats.length,
        itemBuilder: (context, index) {
          final chat = allChats[index];
          final isGroup = chat['type'] == 'group';

          return _buildChatListItem(chat, isGroup);
        },
      ),
    );
  }

  Widget _buildChatListItem(Map<String, dynamic> chat, bool isGroup) {
    final data = chat['data'];
    final isUnread = (data['unread_count'] ?? 0) > 0;
    final lastMessageTime = data['last_message_time'] != null
        ? timeago.format(DateTime.parse(data['last_message_time']))
        : data['updated_at'] != null
            ? timeago.format(DateTime.parse(data['updated_at']))
            : '';

    String title;
    String? avatar;
    String subtitle;
    int memberCount = 0;

    if (isGroup) {
      title = data['name'];
      avatar = data['group_image_url'];
      subtitle = data['last_message'] ?? 'No messages yet';
      memberCount = data['member_count']?[0]?['count'] ?? 0;
    } else {
      final otherUser = chat['other_user'];
      title = otherUser['name'];
      avatar = otherUser['avatar'];
      subtitle = data['last_message'] ?? 'No messages yet';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border.all(color: Colors.yellow.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              backgroundColor: Colors.yellow.shade700,
              child: avatar == null
                  ? Icon(
                      isGroup ? Icons.group : Icons.person,
                      color: Colors.black,
                      size: isGroup ? 24 : 20,
                    )
                  : null,
            ),
            if (isGroup)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: const Icon(
                    Icons.group,
                    size: 12,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isGroup)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow, width: 0.5),
                ),
                child: Text(
                  '$memberCount',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGroup && data['description'] != null) ...[
              Text(
                data['description'],
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],
            Text(
              subtitle,
              style: TextStyle(
                color: isUnread ? Colors.white70 : Colors.grey.shade500,
                fontSize: 14,
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastMessageTime.isNotEmpty)
              Text(
                lastMessageTime,
                style: TextStyle(
                  color: isUnread ? Colors.yellow : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            if (isUnread) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${data['unread_count']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          if (isGroup) {
            _navigateToGroupChat(data);
          } else {
            _navigateToPersonalChat(chat['other_user']);
          }
        },
      ),
    );
  }

  Widget _buildGroupsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      );
    }

    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create or join a group to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Create Group',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      color: Colors.yellow,
      backgroundColor: Colors.grey.shade900,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          final memberCount = group['member_count']?[0]?['count'] ?? 0;
          final isUnread = (group['unread_count'] ?? 0) > 0;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: isUnread
                  ? Border.all(
                      color: Colors.yellow.withValues(alpha: 0.3), width: 1)
                  : null,
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: group['group_image_url'] != null
                    ? NetworkImage(group['group_image_url'])
                    : null,
                backgroundColor: Colors.yellow.shade700,
                child: group['group_image_url'] == null
                    ? const Icon(
                        Icons.group,
                        color: Colors.black,
                        size: 24,
                      )
                    : null,
              ),
              title: Text(
                group['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (group['description'] != null) ...[
                    Text(
                      group['description'],
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    group['last_message'] ?? '$memberCount members',
                    style: TextStyle(
                      color: isUnread ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight:
                          isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow, width: 0.5),
                    ),
                    child: Text(
                      '$memberCount',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${group['unread_count']}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () => _navigateToGroupChat(group),
            ),
          );
        },
      ),
    );
  }

  void _navigateToPersonalChat(Map<String, dynamic> otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: 'p:${otherUser['id']}',
          groupName: otherUser['name'],
          groupImage: otherUser['avatar'],
        ),
      ),
    );
  }

  void _navigateToGroupChat(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: group['id'],
          groupName: group['name'],
          groupImage: group['group_image_url'],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(
        onGroupCreated: () {
          _loadData(); // Reload both conversations and groups
        },
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Community Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(text: 'All Chats'),
            Tab(text: 'Groups'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add, color: Colors.yellow),
            onPressed: () async {
              final isAuthenticated = await AuthAlertBox.checkAuthAndShowAlert(
                context: context,
                customMessage: "Please login to create a group",
              );
              if (isAuthenticated) {
                // ignore: use_build_context_synchronously
                _showCreateGroupDialog();
              }
            },
            tooltip: 'Create Group',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _currentUserId.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No user logged in',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (context.mounted) {
                          context
                              .pushReplacementNamed(AuthPageWidget.routeName);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.login,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatsList(),
                _buildGroupsList(),
              ],
            ),
    );
  }
}

// Placeholder classes - you'll need to implement these

// class GroupChatScreen extends StatelessWidget {
//   final String groupId;
//   final String groupName;
//   final String? groupImage;

//   const GroupChatScreen({
//     Key? key,
//     required this.groupId,
//     required this.groupName,
//     this.groupImage,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         title: Text(groupName),
//       ),
//       body: const Center(
//         child: Text(
//           'Group Chat Screen\n(To be implemented)',
//           style: TextStyle(color: Colors.white),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

class ContactsListView extends StatelessWidget {
  const ContactsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contacts List\n(To be implemented)',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  final VoidCallback onGroupCreated;

  const CreateGroupDialog({Key? key, required this.onGroupCreated})
      : super(key: key);

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _imageFileName;
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<dynamic> _searchResults = [];
  List<dynamic> _selectedMembers = [];

  bool _isCreating = false;
  bool _isSearching = false;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Higher initial resolution for better quality
        maxHeight: 1024,
        imageQuality: 95, // Higher quality for initial selection
      );

      if (image != null) {
        safeSetState(() {
          _isImageUploading = true;
        });

        // Read original image bytes
        final originalBytes = await image.readAsBytes();

        // Compress the image for preview and storage
        final compressedBytes = await _compressImage(
          originalBytes,
          maxWidth: 512,
          maxHeight: 512,
          quality: 85,
        );

        if (compressedBytes != null) {
          safeSetState(() {
            _selectedImageBytes = compressedBytes;
            _imageFileName = image.name;
            _isImageUploading = false;
          });

          // Show compression info
          final originalSize = (originalBytes.length / 1024).round();
          final compressedSize = (compressedBytes.length / 1024).round();
          final compressionRatio =
              ((1 - (compressedBytes.length / originalBytes.length)) * 100)
                  .round();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image compressed: ${originalSize}KB → ${compressedSize}KB (${compressionRatio}% reduction)',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          safeSetState(() {
            _isImageUploading = false;
          });
          _showErrorSnackBar('Failed to process image');
        }
      }
    } catch (e) {
      safeSetState(() {
        _isImageUploading = false;
      });
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  Future<Uint8List?> _compressImage(
    Uint8List imageBytes, {
    int maxWidth = 512,
    int maxHeight = 512,
    int quality = 85,
  }) async {
    try {
      // Decode the image
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Calculate new dimensions while maintaining aspect ratio
      double aspectRatio = originalImage.width / originalImage.height;
      int newWidth = maxWidth;
      int newHeight = maxHeight;

      if (aspectRatio > 1) {
        // Landscape
        newHeight = (maxWidth / aspectRatio).round();
      } else {
        // Portrait or square
        newWidth = (maxHeight * aspectRatio).round();
      }

      // Resize the image
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Compress and encode as JPEG
      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // Remove selected image
  void _removeImage() {
    safeSetState(() {
      _selectedImageBytes = null;
      _imageFileName = null;
    });
  }

  // Upload image to Supabase Storage
  Future<String?> _uploadImageToStorage(String groupId) async {
    if (_selectedImageBytes == null) return null;

    try {
      safeSetState(() {
        _isImageUploading = true;
      });

      final supabase = Supabase.instance.client;
      final fileName =
          'group_${groupId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compress the image before uploading
      final compressedImageBytes = await _compressImage(
        _selectedImageBytes!,
        maxWidth: 512,
        maxHeight: 512,
        quality: 85,
      );

      if (compressedImageBytes == null) {
        throw Exception('Failed to compress image');
      }

      // Upload compressed image
      final response = await supabase.storage
          .from('group-profileimagesorginal')
          .uploadBinary(fileName, compressedImageBytes);

      if (response.isNotEmpty) {
        // Get public URL
        final publicUrl = supabase.storage
            .from('group-profileimagesorginal')
            .getPublicUrl(fileName);

        return publicUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorSnackBar('Failed to upload image: $e');
      return null;
    } finally {
      safeSetState(() {
        _isImageUploading = false;
      });
    }
  }

  Future<void> _searchMembers(String query) async {
    if (query.trim().isEmpty) {
      safeSetState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    safeSetState(() {
      _isSearching = true;
    });

    try {
      final supabase = SupaFlow.client;
      final currentUserId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('profile')
          .select('id, name, shop_name, profile_image_url, city, user_id')
          .or('name.ilike.%$query%,shop_name.ilike.%$query%')
          .neq('user_id', currentUserId) // Compare with user_id instead of id
          .limit(10);

      safeSetState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
        _isSearching = false;
      });
    } catch (e) {
      safeSetState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('Error searching members: $e');
    }
  }

  void _addMember(Map<String, dynamic> member) {
    if (!_selectedMembers.any((m) => m['id'] == member['id'])) {
      safeSetState(() {
        _selectedMembers.add(member);
        _searchController.clear();
        _searchResults = [];
      });
    }
  }

  void _removeMember(String memberId) {
    safeSetState(() {
      _selectedMembers.removeWhere((m) => m['id'] == memberId);
    });
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a group name');
      return;
    }

    safeSetState(() {
      _isCreating = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // First, get the current user's profile_id
      final profileResponse = await supabase
          .from('profile')
          .select('id')
          .eq('user_id', userId)
          .single();

      final currentUserProfileId = profileResponse['id'];

      // Create group with image data
      final groupData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'created_by': userId,
        'is_public': false, // Default to private
      };

      // Add image data if selected
      if (_selectedImageBytes != null) {
        groupData['group_image_data'] = _selectedImageBytes;
      }

      final groupResponse =
          await supabase.from('groups').insert(groupData).select().single();

      final groupId = groupResponse['id'];

      // Upload image to storage if selected
      String? imageUrl;
      if (_selectedImageBytes != null) {
        imageUrl = await _uploadImageToStorage(groupId.toString());

        // Update group with image URL if upload successful
        if (imageUrl != null) {
          await supabase
              .from('groups')
              .update({'group_image_url': imageUrl}).eq('id', groupId);
        }
      }

      // Prepare members to add
      final membersToAdd = <Map<String, dynamic>>[];

      // Add creator as admin (using profile_id)
      membersToAdd.add({
        'group_id': groupId,
        'profile_id': currentUserProfileId,
        'user_id': userId,
        'role': 'admin',
      });

      // Add selected members as members
      for (final member in _selectedMembers) {
        membersToAdd.add({
          'group_id': groupId,
          'profile_id': member['id'],
          'user_id': member['user_id'],
          'role': 'member',
        });
      }

      // Insert all group members at once
      await supabase.from('group_members').insert(membersToAdd);

      widget.onGroupCreated();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      _showSuccessSnackBar(
        'Group "${_nameController.text.trim()}" created with ${_selectedMembers.length + 1} members!',
      );
    } catch (e) {
      print('Error creating group: $e');
      _showErrorSnackBar('Error creating group: $e');
    } finally {
      safeSetState(() {
        _isCreating = false;
      });
    }
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Group Image'),
            if (_selectedImageBytes != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.compress,
                      color: Colors.green,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Compressed (${(_selectedImageBytes!.length / 1024).round()}KB)',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _isImageUploading ? null : _selectImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const ui.Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const ui.Color(0xFFFFD700),
                    width: 1,
                  ),
                ),
                child: _isImageUploading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: ui.Color(0xFFFFD700),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Compressing...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _selectedImageBytes != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: flutter.Image.memory(
                                  _selectedImageBytes!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              // Compression indicator
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.compress,
                                        color: Colors.green,
                                        size: 10,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'Optimized',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                color: ui.Color(0xFFFFD700),
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Image',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Auto-compressed',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(width: 16),
            // Compression info
            if (_selectedImageBytes != null)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const ui.Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Image Optimized',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Size: ${(_selectedImageBytes!.length / 1024).round()}KB\n'
                        '• Max resolution: 512x512\n'
                        '• Format: JPEG (85% quality)\n'
                        '• Optimized for fast upload',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (_imageFileName != null && _selectedImageBytes == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _imageFileName!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: ui.Color(0xFFFFD700),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: ui.Color(0xFFFFD700)),
        filled: true,
        fillColor: const ui.Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ui.Color(0xFFFFD700),
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget _buildSectionTitle(String title) {
  //   return Text(
  //     title,
  //     style: const TextStyle(
  //       color: Color(0xFFFFD700),
  //       fontSize: 16,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   );
  // }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String hintText,
  //   required IconData icon,
  //   int maxLines = 1,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF2A2A2A),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFF404040)),
  //     ),
  //     child: TextField(
  //       controller: controller,
  //       maxLines: maxLines,
  //       style: const TextStyle(color: Colors.white),
  //       decoration: InputDecoration(
  //         hintText: hintText,
  //         hintStyle: const TextStyle(color: Colors.white54),
  //         prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
  //         border: InputBorder.none,
  //         contentPadding: const EdgeInsets.all(16),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const ui.Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const ui.Color(0xFF404040)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          _searchMembers(value);
        },
        decoration: const InputDecoration(
          hintText: 'Search members by name or shop...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: ui.Color(0xFFFFD700)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSelectedMembers() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedMembers.map((member) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const ui.Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const ui.Color(0xFFFFD700)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const ui.Color(0xFFFFD700),
                    backgroundImage: member['profile_image_url'] != null
                        ? NetworkImage(member['profile_image_url'])
                        : null,
                    child: member['profile_image_url'] == null
                        ? Text(
                            (member['name'] ?? member['email'] ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member['name'] ??
                        member['shop_name'] ??
                        member['email'] ??
                        'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeMember(member['id']),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: const ui.Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const ui.Color(0xFF404040)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final member = _searchResults[index];
          final isSelected =
              _selectedMembers.any((m) => m['id'] == member['id']);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const ui.Color(0xFFFFD700),
              backgroundImage: member['profile_image_url'] != null
                  ? NetworkImage(member['profile_image_url'])
                  : null,
              child: member['profile_image_url'] == null
                  ? Text(
                      (member['name'] ?? member['email'] ?? 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              member['name'] ??
                  member['shop_name'] ??
                  member['email'] ??
                  'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (member['email'] != null && member['name'] != null)
                  Text(
                    member['email'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (member['city'] != null)
                  Text(
                    member['city'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: ui.Color(0xFFFFD700))
                : const Icon(Icons.add_circle_outline, color: Colors.white54),
            onTap: isSelected ? null : () => _addMember(member),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isWeb ? 500 : screenWidth * 0.9,
          height: screenHeight * 0.8,
          decoration: BoxDecoration(
            color: const ui.Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const ui.Color(0xFFFFD700),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const ui.Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ui.Color(0xFFFFD700), ui.Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.group_add,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Create Group',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group Image Upload
                      _buildImageUploadSection(),
                      const SizedBox(height: 8),

                      // Group Name
                      _buildSectionTitle('Group Name *'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Enter group name',
                        icon: Icons.group,
                      ),

                      const SizedBox(height: 8),

                      // Description
                      _buildSectionTitle('Description'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Enter group description (optional)',
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 8),

                      // Member Search
                      _buildSectionTitle('Add Members'),
                      const SizedBox(height: 6),
                      _buildSearchField(),

                      const SizedBox(height: 8),

                      // Selected Members
                      if (_selectedMembers.isNotEmpty) ...[
                        _buildSectionTitle(
                            'Selected Members (${_selectedMembers.length})'),
                        const SizedBox(height: 6),
                        _buildSelectedMembers(),
                        const SizedBox(height: 8),
                      ],

                      // Search Results
                      if (_searchResults.isNotEmpty) ...[
                        _buildSectionTitle('Search Results'),
                        const SizedBox(height: 6),
                        _buildSearchResults(),
                      ],

                      if (_isSearching)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: ui.Color(0xFFFFD700),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ui.Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Members: ${_selectedMembers.length + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _isCreating ? null : _createGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const ui.Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isCreating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Group',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    );
  }
}

class GroupInfoSheet extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String? groupImage;
  final List<Map<String, dynamic>> members;

  const GroupInfoSheet({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupImage,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundImage:
                groupImage != null ? NetworkImage(groupImage!) : null,
            backgroundColor: Colors.yellow.shade700,
            child: groupImage == null
                ? const Icon(
                    Icons.group,
                    color: Colors.black,
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            groupName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${members.length} members',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final profile = member['profile'];
                final memberName =
                    profile?['name'] ?? profile?['shop_name'] ?? 'Unknown';
                final isAdmin = member['role'] == 'admin';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profile?['profile_image_url'] != null
                        ? NetworkImage(profile['profile_image_url'])
                        : null,
                    backgroundColor: Colors.yellow.shade700,
                    child: profile?['profile_image_url'] == null
                        ? Text(
                            memberName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    memberName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: isAdmin
                      ? const Text(
                          'Admin',
                          style: TextStyle(color: Colors.yellow),
                        )
                      : null,
                  trailing: isAdmin
                      ? const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.yellow,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
