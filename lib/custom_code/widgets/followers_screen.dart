import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  final bool isFollowers;
  final String userName;

  const FollowersScreen({
    super.key,
    required this.userId,
    required this.isFollowers,
    required this.userName,
  });

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final _supabase = SupaFlow.client;
  late String _currentUserId;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> response;

      if (widget.isFollowers) {
        // Load followers (people who follow this user)
        response = await _supabase
            .from('follows')
            .select('follower_id, profiles:follower_id(*)')
            .eq('following_id', widget.userId);

        _users = response
            .map((item) => item['profiles'] as Map<String, dynamic>)
            .toList();
      } else {
        // Load following (people this user follows)
        response = await _supabase
            .from('follows')
            .select('following_id, profiles:following_id(*)')
            .eq('follower_id', widget.userId);

        _users = response
            .map((item) => item['profiles'] as Map<String, dynamic>)
            .toList();
      }

      // Also fetch follow status for each user
      for (var user in _users) {
        final followStatus = await _supabase
            .from('follows')
            .select()
            .eq('follower_id', _currentUserId)
            .eq('following_id', user['id'])
            .maybeSingle();

        user['is_following'] = followStatus != null;
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow(String userId, bool currentlyFollowing) async {
    try {
      if (currentlyFollowing) {
        // Unfollow user
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', _currentUserId)
            .eq('following_id', userId);
      } else {
        // Follow user
        await _supabase.from('follows').insert({
          'follower_id': _currentUserId,
          'following_id': userId,
        });
      }

      // Update local state
      safeSetState(() {
        for (var user in _users) {
          if (user['id'] == userId) {
            user['is_following'] = !currentlyFollowing;
            break;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final username = user['username']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          username.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.isFollowers ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.userName}\'s Connections'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
            onTap: (index) {
              if ((index == 0 && !widget.isFollowers) ||
                  (index == 1 && widget.isFollowers)) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => FollowersScreen(
                      userId: widget.userId,
                      isFollowers: index == 0,
                      userName: widget.userName,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search ${widget.isFollowers ? 'followers' : 'following'}',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  safeSetState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // User list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isFollowers
                                    ? Icons.people_outline
                                    : Icons.person_outline,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No users found'
                                    : widget.isFollowers
                                        ? 'No followers yet'
                                        : 'Not following anyone yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final isCurrentUser =
                                  user['id'] == _currentUserId;
                              final isFollowing = user['is_following'] ?? false;

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: user['avatar_url'] != null
                                      ? NetworkImage(user['avatar_url'])
                                      : null,
                                  backgroundColor: Colors.blue.shade100,
                                  child: user['avatar_url'] == null
                                      ? Text(
                                          (user['name'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  user['name'] ?? 'User',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('@${user['username'] ?? ''}'),
                                trailing: isCurrentUser
                                    ? const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : OutlinedButton(
                                        onPressed: () => _toggleFollow(
                                            user['id'], isFollowing),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: isFollowing
                                              ? Colors.white
                                              : Colors.blue,
                                          side: BorderSide(
                                            color: isFollowing
                                                ? Colors.grey.shade300
                                                : Colors.blue,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          minimumSize: const Size(100, 36),
                                        ),
                                        child: Text(
                                          isFollowing ? 'Following' : 'Follow',
                                          style: TextStyle(
                                            color: isFollowing
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                onTap: () {
                                  // Navigate to user profile
                                  // Add your navigation code here
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
