import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart';
import 'index.dart';

import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/status_display_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';

import 'package:pocket_mates_app/auth/auth_helper.dart';

class GalleryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<Map<String, dynamic>> allItems;
  final int initialIndex;

  const GalleryDetailsPage({
    super.key,
    required this.item,
    required this.allItems,
    required this.initialIndex,
  });

  @override
  State<GalleryDetailsPage> createState() => _GalleryDetailsPageState();
}

class _GalleryDetailsPageState extends State<GalleryDetailsPage> {
  late PageController _pageController;
  late int currentIndex;
  bool isImageExpanded = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _comments = [];
  bool _isLiked = false;
  int _likeCount = 0;
  String? _errorMessage;
  final _supabase = SupaFlow.client;
  bool isLoading = true;
  Map<String, dynamic>? hideData;
  String? sharetext;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _loadComments();
    _checkIfLiked();
    _getLikeCount();
    fetchHideStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchHideStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('hide')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      safeSetState(() {
        print(response);
        hideData = response.isNotEmpty ? response.first : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching hide status: $e');
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadComments({String? contentFilter}) async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      // Start with the base query filtering by gallery_id
      var query = _supabase
          .from('gallery_with_comments_view')
          .select()
          .eq('gallery_id', widget.item['gallery_id'])
          // Only show rows where comment_content is not null
          .not('comment_content', 'is', null);

      // Add content filter if provided
      if (contentFilter != null && contentFilter.isNotEmpty) {
        // Filter comments that contain the search text
        query = query.ilike('comment_content', '%$contentFilter%');
      }

      // Execute the query
      final response = await query;

      // Remove duplicates based on comment_content
      final Map<String, Map<String, dynamic>> uniqueComments = {};

      for (var comment in response) {
        final commentContent = comment['comment_content']?.toString();
        if (commentContent != null && commentContent.isNotEmpty) {
          // Keep the first occurrence or the one with more recent timestamp
          if (!uniqueComments.containsKey(commentContent) ||
              _isMoreRecent(comment, uniqueComments[commentContent]!)) {
            uniqueComments[commentContent] = comment;
          }
        }
      }

      // Convert back to list
      final deduplicatedComments = uniqueComments.values.toList();

      // Get unique profile_comment_ids from the deduplicated comments
      final profileCommentIds = deduplicatedComments
          .map((comment) => comment['profile_comment_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      // Fetch profile information for all comment authors
      Map<String, Map<String, dynamic>> profilesMap = {};

      if (profileCommentIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profile')
            .select('id, name, profile_image_url')
            .inFilter('id', profileCommentIds);

        // Create a map for quick lookup
        for (var profile in profilesResponse) {
          profilesMap[profile['id'].toString()] = profile;
        }
      }

      // Combine comment data with profile information
      final List<Map<String, dynamic>> enrichedComments =
          deduplicatedComments.map((comment) {
        final profileCommentId = comment['profile_comment_id']?.toString();
        final profileData = profilesMap[profileCommentId];

        return {
          ...comment,
          // Add profile information to each comment
          'commenter_name': profileData?['name'] ?? 'Unknown User',
          'commenter_profile_image_url': profileData?['profile_image_url'],
        };
      }).toList();

      // Sort comments by timestamp (newest first) - optional
      enrichedComments.sort((a, b) {
        final aTime = a['created_at'] ?? a['comment_created_at'];
        final bTime = b['created_at'] ?? b['comment_created_at'];
        if (aTime != null && bTime != null) {
          return DateTime.parse(bTime.toString())
              .compareTo(DateTime.parse(aTime.toString()));
        }
        return 0;
      });

      safeSetState(() {
        _comments = enrichedComments;
        _isLoading = false;
        _errorMessage = null; // Clear any previous error
      });
    } catch (error) {
      safeSetState(() {
        _errorMessage = 'Failed to load comments: $error';
        print(_errorMessage);
        _isLoading = false;
        // Don't clear _comments on error to preserve existing data
      });
    }
  }

// Helper method to determine if a comment is more recent
  bool _isMoreRecent(
      Map<String, dynamic> comment1, Map<String, dynamic> comment2) {
    final time1 = comment1['created_at'] ?? comment1['comment_created_at'];
    final time2 = comment2['created_at'] ?? comment2['comment_created_at'];

    if (time1 == null || time2 == null) return false;

    try {
      return DateTime.parse(time1.toString())
          .isAfter(DateTime.parse(time2.toString()));
    } catch (e) {
      return false;
    }
  }

  Future<void> _getLikeCount() async {
    try {
      final response = await _supabase
          .from('likes')
          .select('count')
          .eq('gallery_id', widget.item['gallery_id'])
          .single();

      safeSetState(() {
        _likeCount = response['count'] ?? 0;
      });
    } catch (e) {
      print('Error getting like count: $e');
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      if (currentUserId != null) {
        final response = await _supabase
            .from('likes')
            .select()
            .eq('gallery_id', widget.item['gallery_id'])
            .eq('user_id', currentUserId)
            .maybeSingle();

        safeSetState(() {
          _isLiked = response != null;
        });
      }
    } catch (e) {
      print('Error checking like status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.allItems.length,
          onPageChanged: (index) {
            safeSetState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = widget.allItems[index];
            return BuildDetailContent(
                item: item); // This uses the named parameter;
          },
        ),
      ),
    );
  }
}

class BuildDetailContent extends StatefulWidget {
  final Map<String, dynamic> item;
  const BuildDetailContent({
    super.key,
    required this.item,
  });

  @override
  BuildDetailContentState createState() => BuildDetailContentState();
}

class BuildDetailContentState extends State<BuildDetailContent> {
  bool isImageExpanded = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _comments = [];
  bool _isLiked = false;
  int _likeCount = 0;
  String? _errorMessage;
  final _supabase = SupaFlow.client;
  bool isLoading = true;
  Map<String, dynamic>? hideData;
  String? sharetext;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadComments();
    _checkIfLiked();
    _getLikeCount();
    fetchHideStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchHideStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('hide')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      safeSetState(() {
        print(response);
        hideData = response.isNotEmpty ? response.first : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching hide status: $e');
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadComments({String? contentFilter}) async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      // Start with the base query filtering by gallery_id
      var query = _supabase
          .from('gallery_with_comments_view')
          .select()
          .eq('gallery_id', widget.item['gallery_id'])
          // Only show rows where comment_content is not null
          .not('comment_content', 'is', null);

      // Add content filter if provided
      if (contentFilter != null && contentFilter.isNotEmpty) {
        // Filter comments that contain the search text
        query = query.ilike('comment_content', '%$contentFilter%');
      }

      // Execute the query
      final response = await query;

      // Remove duplicates based on comment_content
      final Map<String, Map<String, dynamic>> uniqueComments = {};

      for (var comment in response) {
        final commentContent = comment['comment_content']?.toString();
        if (commentContent != null && commentContent.isNotEmpty) {
          // Keep the first occurrence or the one with more recent timestamp
          if (!uniqueComments.containsKey(commentContent) ||
              _isMoreRecent(comment, uniqueComments[commentContent]!)) {
            uniqueComments[commentContent] = comment;
          }
        }
      }

      // Convert back to list
      final deduplicatedComments = uniqueComments.values.toList();

      // Get unique profile_comment_ids from the deduplicated comments
      final profileCommentIds = deduplicatedComments
          .map((comment) => comment['profile_comment_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      // Fetch profile information for all comment authors
      Map<String, Map<String, dynamic>> profilesMap = {};

      if (profileCommentIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profile')
            .select('id, name, profile_image_url')
            .inFilter('id', profileCommentIds);

        // Create a map for quick lookup
        for (var profile in profilesResponse) {
          profilesMap[profile['id'].toString()] = profile;
        }
      }

      // Combine comment data with profile information
      final List<Map<String, dynamic>> enrichedComments =
          deduplicatedComments.map((comment) {
        final profileCommentId = comment['profile_comment_id']?.toString();
        final profileData = profilesMap[profileCommentId];

        return {
          ...comment,
          // Add profile information to each comment
          'commenter_name': profileData?['name'] ?? 'Unknown User',
          'commenter_profile_image_url': profileData?['profile_image_url'],
        };
      }).toList();

      // Sort comments by timestamp (newest first) - optional
      enrichedComments.sort((a, b) {
        final aTime = a['created_at'] ?? a['comment_created_at'];
        final bTime = b['created_at'] ?? b['comment_created_at'];
        if (aTime != null && bTime != null) {
          return DateTime.parse(bTime.toString())
              .compareTo(DateTime.parse(aTime.toString()));
        }
        return 0;
      });

      safeSetState(() {
        _comments = enrichedComments;
        _isLoading = false;
        _errorMessage = null; // Clear any previous error
      });
    } catch (error) {
      safeSetState(() {
        _errorMessage = 'Failed to load comments: $error';
        print(_errorMessage);
        _isLoading = false;
        // Don't clear _comments on error to preserve existing data
      });
    }
  }

// Helper method to determine if a comment is more recent
  bool _isMoreRecent(
      Map<String, dynamic> comment1, Map<String, dynamic> comment2) {
    final time1 = comment1['created_at'] ?? comment1['comment_created_at'];
    final time2 = comment2['created_at'] ?? comment2['comment_created_at'];

    if (time1 == null || time2 == null) return false;

    try {
      return DateTime.parse(time1.toString())
          .isAfter(DateTime.parse(time2.toString()));
    } catch (e) {
      return false;
    }
  }

  Future<void> _getLikeCount() async {
    try {
      final response = await _supabase
          .from('likes')
          .select('count')
          .eq('gallery_id', widget.item['gallery_id'])
          .single();

      safeSetState(() {
        _likeCount = response['count'] ?? 0;
      });
    } catch (e) {
      print('Error getting like count: $e');
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      if (currentUserId != null) {
        final response = await _supabase
            .from('likes')
            .select()
            .eq('gallery_id', widget.item['gallery_id'])
            .eq('user_id', currentUserId)
            .maybeSingle();

        safeSetState(() {
          _isLiked = response != null;
        });
      }
    } catch (e) {
      print('Error checking like status: $e');
    }
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comments (${_comments.length})',
                              style: FlutterFlowTheme.of(context).titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          style: const TextStyle(
                              color: Colors.white), // White input text
                          decoration: InputDecoration(
                            hintText: 'Search comments...',
                            hintStyle: const TextStyle(
                                color:
                                    Colors.white70), // Optional: lighter hint
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.yellow, // Yellow icon
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          onChanged: (value) {
                            if (value.length >= 2 || value.isEmpty) {
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                fetchComments(setModalState,
                                    contentFilter: value);
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Comments list
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orangeAccent,
                                ),
                              )
                            : _comments.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 80,
                                          // ignore: deprecated_member_use
                                          color: Colors.grey
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No comments yet',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Be the first to share your thoughts!',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: _comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = _comments[index];
                                      return EnhancedCommentTile(
                                          comment: comment);
                                    },
                                  ),
                      ),

                      // Comment input area
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Row(
                            children: [
                              // CircleAvatar(
                              //   radius: 18,
                              //   backgroundImage: NetworkImage(
                              //     _supabase.auth.currentUser
                              //             ?.userMetadata?[''] ??
                              //         '',
                              //   ),
                              //   backgroundColor: Colors.grey[300],
                              // ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText),
                                  maxLines: null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
                                    hintStyle: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    // ignore: deprecated_member_use
                                    fillColor:
                                        Colors.grey.withValues(alpha: 0.1),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              MaterialButton(
                                onPressed: () {
                                  _addComment();
                                  // After adding comment, refresh comments list
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    fetchComments(setModalState);
                                  });
                                },
                                color: Colors.yellow,
                                textColor: Colors.black,
                                minWidth: 0,
                                height: 36,
                                padding: const EdgeInsets.all(25),
                                shape: const CircleBorder(),
                                child: const Icon(Icons.send, size: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> fetchComments(StateSetter setModalState,
      {String? contentFilter}) async {
    try {
      // Start with the base query filtering by gallery_id
      var query = _supabase
          .from('gallery_with_comments_view')
          .select()
          .eq('gallery_id', widget.item['gallery_id'])
          // Only show rows where comment_content is not null
          .not('comment_content', 'is', null);

      // Add content filter if provided
      if (contentFilter != null && contentFilter.isNotEmpty) {
        // Filter comments that contain the search text
        query = query.ilike('comment_content', '%$contentFilter%');
      }

      // Execute the query
      final response = await query;

      setModalState(() {
        _comments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      setModalState(() {
        _errorMessage = 'Failed to load comments: $error';
        print(_errorMessage);
        _isLoading = false;
      });
    }
  }

  Future<void> _shareToGroup(String groupId, String groupName) async {
    if (!AuthHelper.checkLoggedIn(context)) return;
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final messageText = sharetext != null && sharetext!.isNotEmpty
          ? sharetext!
          : '${widget.item['gallery_title'] ?? ''}';

      // Insert message to group
      await _supabase.from('group_messages').insert({
        'group_id': groupId,
        'sender_id': _supabase.auth.currentUser?.id.toString() ?? '',
        'gallery_id': widget.item['gallery_id'],
        'message_text': messageText.trim(),
        'message_type': 'gallery',
      });

      // Update group's last message
      await _supabase.from('groups').update({
        'last_message': messageText.trim(),
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $groupName successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing content: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showGroupSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GroupSelectionBottomSheet(
        contentToShare:
            '${widget.item['gallery_title']}\n${widget.item['gallery_description']}\n${widget.item['gallery_image_url']}',
        currentUserId: _supabase.auth.currentUser?.id.toString() ?? '',
        onGroupSelected: (groupId, groupName, userMessage) {
          sharetext = userMessage;
          Navigator.pop(context);
          _shareToGroup(groupId, groupName);
        },
        onPersonSelected: (userId, userName, userMessage) {
          sharetext = userMessage;
          Navigator.pop(context);
          _shareToPerson(userId, userName);
        },
        onStatusSelected: (userMessage) async {
          Navigator.pop(context);
          try {
            final currentUser = _supabase.auth.currentUser;
            if (currentUser == null) return;

            // Fetch current user's profile ID
            final profileResponse = await _supabase
                .from('profile')
                .select('id')
                .eq('user_id', currentUser.id)
                .single();
            final profileId = profileResponse['id'] as String;

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatusUploadWidget(
                    userId: currentUser.id,
                    profileId: profileId,
                    sharedContent: widget.item['gallery_image_url'],
                    sharedContentType: 'gallery',
                    sharedContentId: widget.item['gallery_id']?.toString(),
                  ),
                ),
              ).then((result) {
                if (result == true) {
                  // After successful status upload, we might want to pop the details
                  // or just let it be. Usually, for a share screen, we close it.
                  Navigator.pop(context);
                }
              });
            }
          } catch (e) {
            print('Error preparing status share: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not prepare share')),
            );
          }
        },
        onWhatsAppShare: () {
          WhatsAppShareHelper.shareToWhatsApp(
            context: context,
            item: widget.item,
          );
        },
      ),
    );
  }

  Future<void> _shareToPerson(String userId, String userName) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
        ),
      );

      final messageContent = sharetext != null && sharetext!.isNotEmpty
          ? sharetext!
          : '${widget.item['gallery_title'] ?? ''}';

      final Map<String, dynamic> messageData = {
        'sender_id': _supabase.auth.currentUser!.id,
        'receiver_id': userId,
        'content': messageContent.trim(),
        'message_text': messageContent.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'message_type': 'gallery',
        'gallery_id': widget.item['gallery_id'],
      };

      await _supabase.from('messages').insert(messageData);

      // Update conversation record
      final currentUserId = _supabase.auth.currentUser!.id;
      final existingConv = await _supabase
          .from('conversations')
          .select('id, unread_count')
          .or('and(user1_id.eq.$currentUserId,user2_id.eq.$userId),and(user1_id.eq.$userId,user2_id.eq.$currentUserId)')
          .maybeSingle();

      if (existingConv != null) {
        await _supabase.from('conversations').update({
          'last_message': messageContent.trim(),
          'last_message_time': DateTime.now().toIso8601String(),
          'last_sender_id': currentUserId,
          'unread_count': (existingConv['unread_count'] ?? 0) + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingConv['id']);
      } else {
        await _supabase.from('conversations').insert({
          'user1_id': currentUserId,
          'user2_id': userId,
          'last_message': messageContent.trim(),
          'last_message_time': DateTime.now().toIso8601String(),
          'last_sender_id': currentUserId,
          'unread_count': 1,
        });
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared to $userName successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing content: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget buildAnimatedShareButton(BuildContext context) {
    return AnimatedButtonWithMenu(
      mainIcon: Icons.share,
      mainLabel: 'Share on WhatsApp',
      mainColor: Colors.green,
      onMainTap: () => WhatsAppShareHelper.shareToWhatsApp(
        context: context,
        item: widget.item,
      ),
      menuItems: [
        MenuFlyoutItem(
          leading: const Icon(Icons.description, size: 16),
          text: const Text('Share all details'),
          onPressed: () => WhatsAppShareHelper.shareToWhatsApp(
            context: context,
            item: widget.item,
          ),
        ),
        MenuFlyoutItem(
          leading: const Icon(Icons.link, size: 16),
          text: const Text('Share link only'),
          onPressed: () => WhatsAppShareHelper.shareOnlyLink(
            context: context,
            item: widget.item,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFFFC00), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget buildAnimatedDirectMessageButton(BuildContext context) {
    return widget.item['phone_no'] != null &&
            widget.item['phone_no'].toString().isNotEmpty
        ? AnimatedButtonWithMenu(
            mainIcon: Icons.message,
            mainLabel: 'Message on WhatsApp',
            mainColor: Colors.green.shade700,
            onMainTap: () => WhatsAppShareHelper.shareToSpecificWhatsAppNumber(
              context: context,
              item: widget.item,
              phoneNumber: widget.item['phone_no'].toString(),
              includeFullDetails: false, // Simple message for direct contact
            ),
            menuItems: [
              MenuFlyoutItem(
                leading: const Icon(Icons.chat_bubble_outline, size: 16),
                text: const Text('Send simple message'),
                onPressed: () =>
                    WhatsAppShareHelper.shareToSpecificWhatsAppNumber(
                  context: context,
                  item: widget.item,
                  phoneNumber: widget.item['phone_no'].toString(),
                  includeFullDetails: false,
                ),
              ),
              MenuFlyoutItem(
                leading: const Icon(Icons.info_outline, size: 16),
                text: const Text('Send with full details'),
                onPressed: () =>
                    WhatsAppShareHelper.shareToSpecificWhatsAppNumber(
                  context: context,
                  item: widget.item,
                  phoneNumber: widget.item['phone_no'].toString(),
                  includeFullDetails: true,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Future<void> _toggleLike() async {
    try {
      if (!AuthHelper.checkLoggedIn(context)) return;
      final currentUserId = _supabase.auth.currentUser!.id;

      // Store previous values for rollback if needed
      final previousIsLiked = _isLiked;
      final previousLikeCount = _likeCount;

      safeSetState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });

      if (_isLiked) {
        // Add like
        await _supabase.from('likes').insert({
          'gallery_id': widget.item['gallery_id'],
          'user_id': currentUserId,
        });
      } else {
        // Remove like
        await _supabase
            .from('likes')
            .delete()
            .eq('gallery_id', widget.item['gallery_id'])
            .eq('user_id', currentUserId);
      }
    } catch (e) {
      print('Error toggling like: $e');
      // Revert state if error
      safeSetState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like status')),
      );
    }
  }

  Future<void> _addComment() async {
    if (!AuthHelper.checkLoggedIn(context)) return;
    if (_commentController.text.isEmpty) return;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to comment')),
        );
        return;
      }

      final galleryId = widget.item['gallery_id'];
      if (galleryId == null) return;

      final profileResponse = await _supabase
          .from('profile')
          .select('id')
          .eq('user_id', userId)
          .single();

      final profileId = profileResponse['id'];
      if (profileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not found')),
        );
        return;
      }

      // Add comment to database
      await _supabase.from('comments').insert({
        'user_id': userId,
        'gallery_id': galleryId,
        'content': _commentController.text.trim(),
        'profile_id': profileId,
      });

      // Clear the comment field
      _commentController.clear();

      // Set loading to true to refresh comments list
      safeSetState(() {
        _isLoading = true;
      });

      // Re-fetch all comments to update the list
      await _loadComments();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
      print(e);
    }
  }

  void _toggleImageExpansion() {
    safeSetState(() {
      isImageExpanded = !isImageExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildDetailContent(widget.item);
  }

  Widget _buildDetailContent(Map<String, dynamic> item) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          floating: true,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFC00)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // LikeButton(
            //   isLiked: _isLiked,
            //   likeCount: _likeCount,
            //   onTap: _toggleLike,
            // ),
            ReportButton(
              contentType: 'gallery',
              contentId: widget.item['gallery_id'].toString(),
              contentTitle: widget.item['gallery_title'] ?? 'Gallery Item',
              onReportSubmitted: () {
                // Optional: Show feedback to user
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Thank you for your report. We\'ll review it soon.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),

        // Main Content
        SliverList(
          delegate: SliverChildListDelegate([
            // Image Section
            GestureDetector(
              onTap: _toggleImageExpansion,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: isImageExpanded ? 0.8 : 1.2,
                    child: item['gallery_image_url'] != null
                        ? Image.network(
                            item['gallery_image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFFFFFC00),
                                  size: 64,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.image,
                              color: Color(0xFFFFFC00),
                              size: 64,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Title and Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item['gallery_title'] != null)
                        Expanded(
                          child: Text(
                            item['gallery_title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          final isAuthenticated =
                              await AuthAlertBox.checkAuthAndShowAlert(
                            context: context,
                            customMessage: "Please login to share to groups",
                          );
                          if (isAuthenticated) {
                            // ignore: use_build_context_synchronously
                            _showGroupSelectionBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.share,
                          color: Colors.black,
                          size: 18.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item['gallery_description'] != null)
                    Text(
                      item['gallery_description'],
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final link =
                            "${WhatsAppShareHelper.baseAppUrl}/shareGallery?galleryId=${item['gallery_id']}";
                        await Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.link,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Creator Info Card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerfiedSwitchPage(
                      userId: item['user_id'],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFFFFC00),
                      backgroundImage: item['profile_image_url'] != null
                          ? NetworkImage(item['profile_image_url'])
                          : null,
                      child: item['profile_image_url'] == null
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unknown Creator',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Creator',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Details Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  if (item['gallery_price'] != null)
                    _buildDetailRow(
                      Icons.attach_money,
                      'Price',
                      '₹${item['gallery_price']}',
                    ),

                  // Category
                  if (item['gallery_category'] != null)
                    _buildDetailRow(
                      Icons.category,
                      'Category',
                      item['gallery_category'],
                    ),

                  // Created Date
                  if (item['gallery_created_at'] != null)
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Created',
                      _formatDate(item['gallery_created_at']),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // General share button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (hideData == null || hideData?['is_hidden'] == true || _supabase.auth.currentUser == null)
                      ? const SizedBox()
                      : Expanded(child: buildAnimatedShareButton(context)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  (hideData == null || hideData?['is_hidden'] == true || _supabase.auth.currentUser == null)
                      ? const SizedBox()
                      : Expanded(
                          child: buildAnimatedDirectMessageButton(context)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final isAuthenticated =
                            await AuthAlertBox.checkAuthAndShowAlert(
                          context: context,
                          customMessage: "Please login to Chat with this user",
                        );
                        if (isAuthenticated) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WhatsAppGroupChat(
                                groupId: 'p:${item['user_id']}',
                                groupName: item['name'] ?? 'User',
                                groupImage: item['profile_image_url'],
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colors.black),
                      label: const Text(
                        'Chat',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFFC00),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(
                          'View All (${_comments.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final isAuthenticated =
                              await AuthAlertBox.checkAuthAndShowAlert(
                            context: context,
                            customMessage:
                                "Please login to Comment to the gallery",
                          );
                          if (isAuthenticated) {
                            // ignore: use_build_context_synchronously
                            _showCommentsModal();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comment input (compact version)
                  InkWell(
                    onTap: () async {
                      final isAuthenticated =
                          await AuthAlertBox.checkAuthAndShowAlert(
                        context: context,
                        customMessage: "Please login to Comment to the gallery",
                      );
                      if (isAuthenticated) {
                        // ignore: use_build_context_synchronously
                        _showCommentsModal();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              _supabase.auth.currentUser
                                      ?.userMetadata?['avatar_url'] ??
                                  '',
                            ),
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Add a comment...',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.send,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comments preview (3 most recent)
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.orangeAccent))
                      : _comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No comments yet. Be the first to comment!',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                for (int i = 0;
                                    i < min(3, _comments.length);
                                    i++)
                                  EnhancedCommentTile(comment: _comments[i]),
                                if (_comments.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextButton(
                                      onPressed: _showCommentsModal,
                                      child: Text(
                                        'View ${_comments.length - 3} more comments',
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }
}

