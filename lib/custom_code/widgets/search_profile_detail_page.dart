// Automatic FlutterFlow imports
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'index.dart';

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' as flutter;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/src/features/profile/data/profile_repository.dart';

import 'chat/whatsapp_group_chat.dart';

import 'dart:math' as math;

class SearchProfileDetailPage extends StatefulWidget {
  final double? width;
  final double? height;
  final String userId;

  const SearchProfileDetailPage({
    super.key,
    required this.userId,
    this.width,
    this.height,
  });

  @override
  State<SearchProfileDetailPage> createState() =>
      _SearchProfileDetailPageState();
}

class _SearchProfileDetailPageState extends State<SearchProfileDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];
  bool _isLoading = false;
  final _supabase = SupaFlow.client;

  late TabController _tabController;
  int _followersCount = 0;
  final ScrollController _scrollController = ScrollController();
  String _followersCountFormatted = '0';
  String _followingCountFormatted = '0';
  bool _isFollowing = false;
  String? _currentUserId;
  List<Map<String, dynamic>> userThreads = [];
  bool isLoading = true;
  Map<String, dynamic>? hideData;
  List<Map<String, dynamic>> _comments = [];
  String? _errorMessage;
  bool _isBlocked = false;
  bool _isBlockedByOther = false;
  bool _checkingBlockStatus = true;
  DateTime? _blockTime;
  DateTime? _blockedByOtherTime;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProfileData();
    _checkFollowStatus();
    _fetchFollowCounts();
    _checkIfCurrentUser();
    _getCurrentUser();
    _loadProfilethreadsData();
    fetchHideStatus();
    _checkBlockStatus();
    _initScrollListener();
  }

// Add this method to your State class
  void _initScrollListener() {
    _scrollController.addListener(() {
      // Show button when scrolled down more than 200 pixels
      bool shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }
    });
  }

// Add this method to scroll to top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _checkIfCurrentUser() {
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    } else {
      return count.toString();
    }
  }

  Future<void> _checkBlockStatus() async {
    try {
      setState(() {
        _checkingBlockStatus = true;
      });

      // Check if current user blocked the receiver
      final blockedByMe = await _supabase
          .from('blocks')
          .select('created_at')
          .eq('blocker_id', _currentUserId.toString())
          .eq('blocked_id', widget.userId)
          .limit(1);

      // Check if receiver blocked the current user
      final blockedByOther = await _supabase
          .from('blocks')
          .select('created_at')
          .eq('blocker_id', widget.userId)
          .eq('blocked_id', _currentUserId.toString())
          .limit(1);

      if (mounted) {
        setState(() {
          _isBlocked = blockedByMe.isNotEmpty;
          _isBlockedByOther = blockedByOther.isNotEmpty;

          // Store block times
          if (_isBlocked && blockedByMe.isNotEmpty) {
            _blockTime = DateTime.parse(blockedByMe.first['created_at']);
          } else {
            _blockTime = null;
          }

          if (_isBlockedByOther && blockedByOther.isNotEmpty) {
            _blockedByOtherTime =
                DateTime.parse(blockedByOther.first['created_at']);
          } else {
            _blockedByOtherTime = null;
          }

          _checkingBlockStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking block status: $e');
      if (mounted) {
        setState(() {
          _checkingBlockStatus = false;
        });
      }
    }
  }

  Future<void> _fetchFollowCounts() async {
    try {
      final followersResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', widget.userId);

      final followingResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', widget.userId);

      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', widget.userId)
          .maybeSingle();

      int baseFollowers = 0;
      if (userResponse != null && userResponse['followers'] != null) {
        baseFollowers = (userResponse['followers'] as num).toInt();
      }

      final int followersCountRaw = followersResponse.length + baseFollowers;
      final int followingCountRaw = followingResponse.length;

      safeSetState(() {
        _followersCount = followersCountRaw;
        _followersCountFormatted = _formatCount(followersCountRaw);
        _followingCountFormatted = _formatCount(followingCountRaw);
      });
    } catch (e) {
      debugPrint('Error fetching follow counts: $e');
    }
  }

  Future<void> _loadProfilethreadsData() async {
    safeSetState(() {
      isLoading = true;
    });

    try {
      // Fetch user threads
      final threads = await _supabase
          .from('threads_view')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      if (mounted) {
        safeSetState(() {
          userThreads = List<Map<String, dynamic>>.from(threads);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  void _fetchProfileData() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      final profileResponse = await _supabase
          .from('profile')
          .select()
          .eq('user_id', widget.userId)
          .limit(1);

      Map<String, dynamic>? profile;
      if (profileResponse.isNotEmpty) {
        profile = Map<String, dynamic>.from(profileResponse.first);
        // Normalize fields for legacy compatibility
        profile['profile_id'] = profile['id'];
        profile['profile_created_at'] = profile['created_at'];
      }

      final galleryResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          gallery_id, gallery_title, profile_id, shop_name, gallery_description, 
          gallery_price, gallery_image_url, gallery_category, like_id, like_created_at,comment_id,comment_content,comment_created_at,comment_updated_at
        ''')
          .eq('user_id', widget.userId)
          .not('gallery_id', 'is', null)
          .order('gallery_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueGalleryItems = {};
      for (var item in galleryResponse) {
        if (item['gallery_id'] != null) {
          uniqueGalleryItems[item['gallery_id'].toString()] = item;
        }
      }
      final commentResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
      gallery_id, gallery_created_at, gallery_title, gallery_description, 
      gallery_price, gallery_image_url, gallery_category, like_id, like_created_at,
      comment_id, comment_content, comment_created_at, comment_updated_at
    ''')
          .eq('user_id', widget.userId)
          // Add this filter for the specific gallery
          .not('gallery_id', 'is', null)
          .order('gallery_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniquecommentItems = {};
      for (var item in commentResponse) {
        if (item['comment_id'] != null) {
          uniquecommentItems[item['comment_id'].toString()] = item;
        }
      }
      for (var item in galleryResponse) {
        if (item['gallery_id'] != null) {
          uniqueGalleryItems[item['gallery_id'].toString()] = item;
        }
      }
      final serviceResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          service_id, service_created_at, service_title, service_description, 
          service_price, service_category
        ''')
          .eq('user_id', widget.userId)
          .not('service_id', 'is', null)
          .order('service_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueServiceItems = {};
      for (var item in serviceResponse) {
        if (item['service_id'] != null) {
          uniqueServiceItems[item['service_id'].toString()] = item;
        }
      }

      safeSetState(() {
        _profileData = profile;
        _galleryItems = uniqueGalleryItems.values.toList();
        _serviceItems = uniqueServiceItems.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      print('Error fetching profile data: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error fetching profile data: $e')),
      // );
    }
  }

  void _checkFollowStatus() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null || currentUserId == widget.userId) {
      safeSetState(() {
        _isFollowing = false;
      });
      return;
    }

    try {
      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('followed_id', widget.userId);

      safeSetState(() {
        _isFollowing = response.isNotEmpty;
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> toggleFollow() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to follow users')),
      );
      return;
    }

    try {
      if (_isFollowing) {
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('followed_id', widget.userId);
      } else {
        await _supabase.from('follows').insert({
          'follower_id': currentUserId,
          'followed_id': widget.userId,
        });
      }

      safeSetState(() {
        _isFollowing = !_isFollowing;
        _followersCount =
            _isFollowing ? _followersCount + 1 : _followersCount - 1;
        _followersCountFormatted = _formatCount(_followersCount);
      });
    } catch (e) {
      print('Error fetching profile data: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating follow status: $e')),
        );
      }
    }
  }

  void _navigateToMessages() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: 'p:${widget.userId}',
          groupName: _profileData?['name'] ?? 'User',
          groupImage: _profileData?['profile_image_url'],
        ),
      ),
    );
  }

  Widget buildVerifiedTick(bool isVerified, Color? color) {
    if (!isVerified) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Icon(
        Icons.verified,
        color: color,
        size: 16,
      ),
    );
  }

  Color _getBgColor() {
    return _profileData != null && _profileData!['bg_color_code'] != null
        ? Color(int.parse('FF${_profileData!['bg_color_code'].substring(1)}',
            radix: 16))
        : Colors.black;
  }

  Color _getButtonColor() {
    return _profileData != null && _profileData!['button_color_code'] != null
        ? Color(int.parse('FF${_profileData!['button_color_code'].substring(1)}',
            radix: 16))
        : Colors.black;
  }

  Color _getButtonTextColor() {
    return _profileData != null && _profileData!['button_text_color'] != null
        ? Color(int.parse(
            'FF${_profileData!['button_text_color'].substring(1)}',
            radix: 16))
        : Colors.white;
  }

  Color _getBgTextColor() {
    return _profileData != null && _profileData!['bg_text_color'] != null
        ? Color(int.parse('FF${_profileData!['bg_text_color'].substring(1)}',
            radix: 16))
        : Colors.black;
  }

  void _showGalleryItemDetails(Map<String, dynamic> item) {
    // Initialize like countAnonymous
    int likeCount = item['like_count'] ?? 0;
    bool isLiked = item['like_id'] != null;
    String galleryId = item['gallery_id'] ?? '';

    bool isLoading = true;
    bool isMoreRecent(
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

    Future<void> fetchComments(StateSetter setModalState,
        {String? contentFilter}) async {
      setModalState(() {
        _isLoading = true;
      });

      try {
        // Start with the base query filtering by gallery_id
        var query = _supabase
            .from('gallery_with_comments_view')
            .select()
            .eq('gallery_id', galleryId)
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
                isMoreRecent(comment, uniqueComments[commentContent]!)) {
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

        setModalState(() {
          _comments = enrichedComments;
          _isLoading = false;
          _errorMessage = null; // Clear any previous error
        });
      } catch (error) {
        setModalState(() {
          _errorMessage = 'Failed to load comments: $error';
          debugPrint(_errorMessage);
          _isLoading = false;
          // Don't clear _comments on error to preserve existing data
        });
      }
    }


    // Initialize comments list and controller
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if (isLoading) {
            fetchComments(setModalState);
          }

          // Define a local toggle like function within the modal
          Future<void> modalToggleLike() async {
            try {
              final userId = _supabase.auth.currentUser?.id;
              if (userId == null) {
                if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('You need to be logged in to like items')),
                );
                return;
              }

              final galleryId = item['gallery_id'];
              if (galleryId == null) return;

              // If already liked, remove the like
              if (isLiked) {
                await _supabase
                    .from('likes')
                    .delete()
                    .eq('id', item['like_id']);

                // Update the state within the modal
                setModalState(() {
                  isLiked = false;
                  likeCount = math.max(0, likeCount - 1);
                });
                // Update the main state
                safeSetState(() {
                  final index = _galleryItems.indexWhere(
                      (element) => element['gallery_id'] == galleryId);
                  if (index != -1) {
                    _galleryItems[index]['like_id'] = null;
                    _galleryItems[index]['like_created_at'] = null;
                    _galleryItems[index]['like_count'] = math.max<int>(0,
                        ((_galleryItems[index]['like_count'] ?? 0) as int) - 1);
                  }
                });

                // Update the item for consistency
                item['like_id'] = null;
                item['like_created_at'] = null;
                item['like_count'] =
                    math.max<int>(0, ((item['like_count'] ?? 0) as int) - 1);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from likes')),
                  );
                }
              }
              // If not liked, add a like
              else {
                final response = await _supabase
                    .from('likes')
                    .insert({
                      'user_id': userId,
                      'gallery_id': galleryId,
                    })
                    .select()
                    .single();

                // Update the state within the modal
                setModalState(() {
                  isLiked = true;
                  likeCount = likeCount + 1;
                });

                // Update the main state
                safeSetState(() {
                  final index = _galleryItems.indexWhere(
                      (element) => element['gallery_id'] == galleryId);
                  if (index != -1) {
                    _galleryItems[index]['like_id'] = response['id'];
                    _galleryItems[index]['like_created_at'] =
                        response['created_at'];
                    _galleryItems[index]['like_count'] =
                        (_galleryItems[index]['like_count'] ?? 0) + 1;
                  }
                });

                // Update the item for consistency
                item['like_id'] = response['id'];
                item['like_created_at'] = response['created_at'];
                item['like_count'] = (item['like_count'] ?? 0) + 1;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to likes')),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error toggling like: $e')),
                );
              }
            }
          }

          // Function to add a comment
          Future<void> addComment() async {
            if (commentController.text.trim().isEmpty) return;

            try {
              final userId = _supabase.auth.currentUser?.id;
              if (userId == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You need to be logged in to comment')),
                  );
                }
                return;
              }

              final galleryId = item['gallery_id'];
              if (galleryId == null) return;
              final profileResponse = await _supabase
                  .from('profile')
                  .select('id')
                  .eq('user_id', userId)
                  .single();

              final profileId = profileResponse['id'];
              if (profileId == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile not found')),
                  );
                }
                return;
              }

              // Add comment to database
              await _supabase.from('comments').insert({
                'user_id': userId,
                'gallery_id': galleryId,
                'content': commentController.text.trim(),
                'profile_id': profileId,
              });

              // Clear the comment field
              commentController.clear();

              // Set loading to true to refresh comments list
              setModalState(() {
                isLoading = true;
              });

              // Re-fetch all comments to update the list
              await fetchComments(setModalState);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment added successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding comment: $e')),
                );
              }
              debugPrint(e.toString());
            }
          }

          // Format timestamp to readable date
          String formatTimestamp(dynamic timestamp) {
            if (timestamp == null) return '';

            try {
              // If it's a string, parse it as DateTime
              if (timestamp is String) {
                final dateTime = DateTime.parse(timestamp);
                // Format the date as needed
                return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
              }
              // If it's already a DateTime
              else if (timestamp is DateTime) {
                return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
              }
              return '';
            } catch (e) {
              return '';
            }
          }

          return FractionallySizedBox(
            heightFactor: 0.9, // Increased height to accommodate comments
            child: Container(
              decoration: BoxDecoration(
                color: _getBgColor(),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Column(
                  children: [
                    // Pull handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gallery Image with double-tap like functionality
                            GestureDetector(
                              onDoubleTap:
                                  modalToggleLike, // Use the local function
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: (item['gallery_image_url'] != null &&
                                              item['gallery_image_url'] != '')
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  item['gallery_image_url']),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      ),
                                    ),
                                  ),
                                  // Like count overlay
                                  // Padding(
                                  //   padding: const EdgeInsets.all(16.0),
                                  //   child: Container(
                                  //     padding: const EdgeInsets.symmetric(
                                  //       horizontal: 12,
                                  //       vertical: 6,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: _getBgColor().withValues(alpha: 0.7),
                                  //       borderRadius: BorderRadius.circular(20),
                                  //     ),
                                  //     child: Row(
                                  //       mainAxisSize: MainAxisSize.min,
                                  //       children: [
                                  //         Icon(
                                  //           Icons.favorite,
                                  //           color: _getButtonColor(),
                                  //           size: 18,
                                  //         ),
                                  //         // SizedBox(width: 6),
                                  //         // Text(
                                  //         //   likeCount.toString(),
                                  //         //   style: TextStyle(
                                  //         //     color: _getBgTextColor(),
                                  //         //     fontWeight: FontWeight.bold,
                                  //         //   ),
                                  //         // ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                            // Gallery Info
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['gallery_title'] ?? 'Gallery',
                                          style: TextStyle(
                                            color: _getBgTextColor(),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (item['gallery_price'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _getButtonColor(),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            '₹${item['gallery_price']}',
                                            style: TextStyle(
                                              color: _getButtonTextColor(),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ReportButton(
                                        contentType: 'gallery',
                                        contentId:
                                            item['gallery_id']?.toString() ??
                                                '',
                                        contentTitle: item['gallery_title'] ??
                                            'Gallery Item',
                                        onReportSubmitted: () {
                                          // Optional: Show feedback to user
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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

                                  if (item['gallery_category'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getButtonColor(),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item['gallery_category'],
                                          style: TextStyle(
                                            color: _getButtonTextColor(),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                  if (item['gallery_description'] != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8.0),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text(
                                        item['gallery_description'],
                                        style: TextStyle(
                                          color: _getButtonTextColor(),
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 32,
                                          width: 32,
                                          decoration: BoxDecoration(
                                            color: _getButtonColor(),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              final link =
                                                  "${WhatsAppShareHelper.baseAppUrl}/shareGallery?galleryId=${item['gallery_id']}";
                                              await flutter.Clipboard.setData(
                                                  flutter.ClipboardData(
                                                      text: link));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Link copied to clipboard'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.link,
                                              size: 16,
                                              color: _getButtonTextColor(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Action buttons for Like and Share
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final isAuthenticated =
                                                await AuthAlertBox
                                                    .checkAuthAndShowAlert(
                                              context: context,
                                              customMessage:
                                                  "Please login to like this gallery",
                                            );
                                            if (isAuthenticated) {
                                              // ignore: use_build_context_synchronously
                                              modalToggleLike();
                                            }
                                          }, // Use the local function
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8),
                                            child: Icon(
                                              isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isLiked
                                                  ? Colors.red
                                                  : _getButtonColor(),
                                            ),
                                          ),
                                          label: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(isLiked ? 'Liked' : 'Like',
                                                  style: TextStyle(
                                                      color:
                                                          _getBgTextColor())),
                                              const SizedBox(width: 4),
                                              // Text('$likeCount',
                                              //     style: TextStyle(
                                              //         color:
                                              //             _getBgTextColor())),
                                            ],
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            side: BorderSide(
                                              color: _getButtonColor(),
                                              // ✅ Replace with your desired color
                                              width:
                                                  2, // Optional: thickness of the border
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _shareGalleryItem(item);
                                          },
                                          icon: const Icon(Icons.share),
                                          label: const Text('Share'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _getButtonColor(),
                                            foregroundColor:
                                                _getButtonTextColor(),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Comments section header
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 32.0, bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Comments',
                                          style: TextStyle(
                                            color: _getBgTextColor(),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getButtonColor()
                                                .withValues(alpha: 0.8),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_comments.length}',
                                            style: TextStyle(
                                              color: _getButtonTextColor(),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Comments list
                                  if (_comments.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20.0),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              size: 48,
                                              color: _getButtonColor(),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No comments yet',
                                              style: TextStyle(
                                                color: _getBgTextColor()
                                                    .withValues(alpha: 0.7),
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Be the first to comment!',
                                              style: TextStyle(
                                                color: _getBgTextColor()
                                                    .withValues(alpha: 0.7),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _comments.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        color: Colors.grey.shade200,
                                        height: 24,
                                      ),
                                      itemBuilder: (context, index) {
                                        final comment = _comments[index];
                                        final bool isCurrentUserComment =
                                            comment['user_id'] ==
                                                _supabase.auth.currentUser?.id;

                                        // Define delete function in this scope
                                        Future<void> deleteComment() async {
                                          try {
                                            final userId =
                                                _supabase.auth.currentUser?.id;
                                            if (userId == null) return;

                                            // Only allow deletion if user owns the comment
                                            if (comment['user_id'] != userId) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'You can only delete your own comments')),
                                              );
                                              return;
                                            }

                                            final commentId =
                                                comment['comment_id'];
                                            if (commentId == null) return;

                                            // Delete from database
                                            await _supabase
                                                .from('comments')
                                                .delete()
                                                .eq('id', commentId);

                                            // Set loading to true to refresh comments list
                                            setModalState(() {
                                              isLoading = true;
                                            });

                                            // Re-fetch all comments to update the list
                                            await fetchComments(setModalState);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Comment deleted')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting comment: $e')),
                                            );
                                            debugPrint(e.toString());
                                          }
                                        }

                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: _getBgColor(),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: _getBgColor()
                                                    .withValues(alpha: 0.6)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // User avatar
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundImage: comment[
                                                                'commenter_profile_image_url'] !=
                                                            null
                                                        ? CachedNetworkImageProvider(
                                                            comment['commenter_profile_image_url']
                                                                as String)
                                                        : null,
                                                    child:
                                                        comment['commenter_profile_image_url'] ==
                                                                null
                                                            ? const Icon(
                                                                Icons.person)
                                                            : null,
                                                  ),
                                                  const SizedBox(width: 12),

                                                  // Comment content
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              (comment['commenter_name']
                                                                      as String?) ??
                                                                  'Anonymous',
                                                              style: TextStyle(
                                                                color:
                                                                    _getBgTextColor(),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            Text(
                                                              formatTimestamp(
                                                                  comment[
                                                                      'created_at']),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: _getBgTextColor()
                                                                    .withValues(alpha: 0.7),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          comment['comment_content']
                                                                  as String? ??
                                                              'No content',
                                                          style: TextStyle(
                                                              color:
                                                                  _getBgTextColor(),
                                                              height: 1.3),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Delete option
                                                  if (isCurrentUserComment)
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        size: 18,
                                                        color: _getBgTextColor()
                                                            .withValues(alpha: 0.7),
                                                      ),
                                                      onPressed: deleteComment,
                                                    ),
                                                  const Spacer(),
                                                  ReportButton(
                                                    contentType: 'comment',
                                                    contentId:
                                                        comment['comment_id'],
                                                    contentTitle:
                                                        comment['comment_content']
                                                                as String? ??
                                                            'Comment',
                                                    onReportSubmitted: () {
                                                      // Optional: Show feedback   to user
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Thank you for your report. We\'ll review it soon.'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Comment input section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getBgColor(),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, -2),
                            blurRadius: 6,
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(
                                      color:
                                          _getBgTextColor()), // White hint text
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor:
                                      _getBgColor().withValues(alpha: 0.6),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                style: TextStyle(
                                    color:
                                        _getBgTextColor()), // White input text
                                maxLines: null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () async {
                                final isAuthenticated =
                                    await AuthAlertBox.checkAuthAndShowAlert(
                                  context: context,
                                  customMessage:
                                      "Please login to Comment to the gallery",
                                );
                                if (isAuthenticated) {
                                  // ignore: use_build_context_synchronously
                                  addComment();
                                }
                              },
                              customBorder: const CircleBorder(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getButtonColor(),
                                ),
                                child: Icon(
                                  Icons.send,
                                  color: _getButtonTextColor(),
                                  size: 20,
                                ),
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


// Share gallery item
  void _shareGalleryItem(Map<String, dynamic> item) async {
    try {
      // This is a simple implementation - you might want to use a share package
      // like 'share_plus' for more features
      final title = item['gallery_title'] ?? 'Check out this item';
      final imageUrl = item['gallery_image_url'] ?? '';
      final description = item['gallery_description'] ?? '';

      // You would implement actual sharing functionality here with your preferred share plugin
      await SharePlus.instance.share(ShareParams(
        text: '$title\n\n$description\n\n$imageUrl',
        subject: title,
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
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
        debugPrint(response.toString());
        hideData = response.isNotEmpty ? response.first : null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching hide status: $e');
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  void _showMessageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          title: const Row(
            children: [
              Icon(Icons.message, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: const Text(
            'Choose how you would like to send a message:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                hideData != null && hideData?['is_hidden'] == true
                    ? const SizedBox() // Hide WhatsApp button
                    : TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _sendWhatsAppMessage();
                        },
                        icon: const Icon(Icons.chat,
                            color: Colors.green, size: 20),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side:
                                const BorderSide(color: Colors.green, width: 1),
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                // In-App Message Option
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final isAuthenticated =
                        await AuthAlertBox.checkAuthAndShowAlert(
                      context: context,
                      customMessage: "Please login to send message",
                    );
                    if (isAuthenticated) {
                      // ignore: use_build_context_synchronously
                      _navigateToMessages();
                    }
                  },
                  icon: const Icon(Icons.message, size: 20),
                  label: const Text('In-App Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _sendWhatsAppMessage() async {
    try {
      String phoneNumber = _profileData?['phone_no'];

      if (phoneNumber.toString().isEmpty) {
        _showErrorSnackBar('WhatsApp number not available');
        return;
      }

      // Clean and format the phone number
      String cleanedNumber = _cleanPhoneNumber(phoneNumber);

      String message = "Hello! I'm reaching out to you.";
      String encodedMessage = Uri.encodeComponent(message);

      final whatsappUrl = 'https://wa.me/$cleanedNumber?text=$encodedMessage';
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(
          Uri.parse(
              "whatsapp://send?phone=$cleanedNumber&text=${Uri.encodeComponent(message)}"),
          mode: LaunchMode.externalApplication,
        );
        // _showErrorSnackBar('WhatsApp is not installed or number is invalid');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening WhatsApp: ${e.toString()}');
    }
  }

  String _cleanPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If number starts with 0, replace with country code (example for India: 91)
    if (cleaned.startsWith('0')) {
      cleaned = '91${cleaned.substring(1)}';
    }

    // If number doesn't start with country code, add it
    if (!cleaned.startsWith('91') && cleaned.length == 10) {
      cleaned = '91$cleaned';
    }

    return cleaned;
  }


// Helper method to show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatWidget(
    BuildContext context,
    String value,
    String label,
    Color textColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  void _showAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantWidget(
        userId: widget.userId,
        bgColor: _getBgColor(),
        buttonColor: _getButtonColor(),
        buttonTextColor: _getButtonTextColor(),
        textColor: _getBgTextColor(),
      ),
    );
  }
  void _shareToWhatsApp() async {
    try {
      String profileUrl =
          '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
      String message = 'Check out this profile: $profileUrl';
      String whatsappUrl =
          'https://wa.me/?text=${Uri.encodeComponent(message)}';
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      String profileUrl =
          '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
      String message = 'Check out this profile: $profileUrl';
      await launchUrl(
        Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}"),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _shareToInstagram() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
    // Instagram doesn't support direct text sharing, so copy to clipboard
    flutter.Clipboard.setData(flutter.ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied for Instagram sharing')),
    );
  }

  void _copyLink() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
    flutter.Clipboard.setData(flutter.ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareToAnywhere() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
    SharePlus.instance.share(ShareParams(text: 'Check out this profile: $profileUrl'));
  }



  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _isBlocked ? 'Unblock User' : 'Block User',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isBlocked
                    ? 'Are you sure you want to unblock ${_profileData!['name'] ?? 'No Name'}?'
                    : 'Are you sure you want to block  ${_profileData!['name'] ?? 'No Name'}? You won\'t be able to send or receive messages.',
                style: const TextStyle(color: Colors.white70),
              ),
              if (_isBlocked && _blockTime != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Blocked on: ${_formatBlockTime(_blockTime!)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_isBlocked) {
                  _unblockUser();
                } else {
                  _blockUser();
                }
              },
              child: Text(
                _isBlocked ? 'Unblock' : 'Block',
                style: TextStyle(
                  color: _isBlocked ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _blockUser() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to block users')),
        );
        return;
      }

      await _supabase.from('blocks').insert({
        'blocker_id': currentUserId,
        'blocked_id': widget.userId,
      });

      safeSetState(() {
        _isBlocked = true;
        _blockTime = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blocked ${_profileData!['name'] ?? 'user'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error blocking user: $e')),
      );
    }
  }

  Future<void> _unblockUser() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to unblock users')),
        );
        return;
      }

      await _supabase
          .from('blocks')
          .delete()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', widget.userId);

      safeSetState(() {
        _isBlocked = false;
        _blockTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unblocked ${_profileData!['name'] ?? 'user'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error unblocking user: $e')),
      );
    }
  }

  String _formatBlockTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} at ${time.hour}:${time.minute}';
  }

  Widget _buildBlockedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 80, color: Colors.red.withValues(alpha: 0.7)),
          const SizedBox(height: 24),
          Text(
            'You have blocked ${_profileData!['name'] ?? 'this user'}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getBgTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          if (_blockTime != null)
            Text(
              'Blocked on: ${_formatBlockTime(_blockTime!)}',
              style: TextStyle(
                color: _getBgTextColor().withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showBlockDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedByOtherView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 80, color: Colors.grey.withValues(alpha: 0.7)),
          const SizedBox(height: 24),
          Text(
            'You have been blocked by ${_profileData!['name'] ?? 'this user'}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getBgTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          if (_blockedByOtherTime != null)
            Text(
              'Blocked on: ${_formatBlockTime(_blockedByOtherTime!)}',
              style: TextStyle(
                color: _getBgTextColor().withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'You cannot view their profile or interact with them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _getBgTextColor().withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Color buttonColor = _getButtonColor();
    Color bgColor = _getBgColor();
    Color buttonTextColor = _getButtonTextColor();
    Color bgTextColor = _getBgTextColor();

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: bgColor, // Pass as parameter
            onSelected: (String value) async {
              switch (value) {
                case 'whatsapp':
                  _shareToWhatsApp();
                  break;
                case 'instagram':
                  _shareToInstagram();
                  break;
                case 'share':
                  _shareToAnywhere();
                  break;
                case 'insta_profile':
                  final String instaLink = _profileData!['insta_link'] ?? '';
                  if (instaLink.isNotEmpty) {
                    final Uri url = Uri.parse(instaLink);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      // Fallback to Instagram app or web
                      final String instaId = _profileData!['insta_id'] ?? '';
                      if (instaId.isNotEmpty) {
                        final Uri fallbackUrl =
                            Uri.parse('https://instagram.com/$instaId');
                        if (await canLaunchUrl(fallbackUrl)) {
                          await launchUrl(fallbackUrl,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    }
                  }
                  break;
                case 'copy':
                  _copyLink();
                  break;

                case 'navigate':
                  context.push('/home');
                  break;
                case 'report':
                  final isAuthenticated =
                      await AuthAlertBox.checkAuthAndShowAlert(
                    context: context,
                    customMessage: "Please login to report content",
                  );
                  if (isAuthenticated) {
                    ReportHelper.showReportDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      contentType: 'account',
                      contentId: widget.userId.toString(),
                      contentTitle: _profileData!['name'].toString(),
                      onReportSubmitted: () {
                        Navigator.of(context).pop(); // Go back to previous page
                        if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Thank you for your report. We\'ll review it soon.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    );
                  }
                  break;
                case 'block':
                  final isAuthenticatedBlock =
                      await AuthAlertBox.checkAuthAndShowAlert(
                    context: context,
                    customMessage: "Please login to block content",
                  );
                  if (isAuthenticatedBlock) {
                    _showBlockDialog();
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.message,
                        color: buttonColor), // Pass as parameter
                    const SizedBox(width: 8),
                    Text('Share to WhatsApp',
                        style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'instagram',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Share to Instagram',
                        style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              if (_profileData!['insta_link'] != null &&
                  _profileData!['insta_link'].toString().isNotEmpty)
                PopupMenuItem<String>(
                  value: 'insta_profile',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: buttonTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Instagram Profile',
                          style: TextStyle(color: bgTextColor)),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Share to anywhere',
                        style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Copy Link', style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'navigate',
                child: Row(
                  children: [
                    Icon(Icons.home, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Home Page', style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Report', style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      _isBlocked ? Icons.person_add : Icons.block,
                      color: _isBlocked ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isBlocked ? 'Unblock User' : 'Block User',
                      style: TextStyle(
                        color: _isBlocked ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

// Helper methods
      ),
      body: _isLoading
          ? CircularShimmer(
              buttonColor: buttonColor,
              bgColor: bgColor,
              size: 100,
            )
          : _profileData == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'the User Not Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : _checkingBlockStatus
                  ? const Center(child: CircularProgressIndicator())
                  : _isBlockedByOther
                      ? _buildBlockedByOtherView()
                      : _isBlocked
                          ? _buildBlockedView()
                          : Stack(
                              children: [
                                // Banner covering full screen with gradient overlay
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: _profileData!['banner_image_url'] !=
                                            null
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              _profileData!['banner_image_url'],
                                            ),
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.high,
                                          )
                                        : null,
                                    color: _profileData!['banner_image_url'] ==
                                            null
                                        ? Colors
                                            .black // Changed to Colors.black for visibility
                                        : null,
                                  ),
                                  child: _profileData!['banner_image_url'] !=
                                          null
                                      ? Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                bgColor.withValues(alpha: 0.8),
                                                bgColor,
                                              ],
                                              stops: const [0.1, 0.7, 0.9],
                                            ),
                                          ),
                                        )
                                      : null, // No gradient overlay when there's no banner image
                                ),
                                // Main content
                                CustomScrollView(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    // Top spacing to push content below banner
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25),
                                    ),

                                    // Profile card with info
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                600, // Set your desired max width
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: bgColor.withValues(alpha: 0.95),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: buttonColor.withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Avatar and Name section
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 10, 10),
                                                  child: Row(
                                                    children: [
                                                      // Profile image
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(11),
                                                          border: Border.all(
                                                            color: buttonColor
                                                                .withValues(alpha: 0.3),
                                                            width: 2.0,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(alpha: 0.1),
                                                              blurRadius: 8,
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(11),
                                                          child: Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: bgColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: _profileData![
                                                                        'profile_image_url'] !=
                                                                    null
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10), // Half of width/height for perfect circle
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          _profileData![
                                                                              'profile_image_url'],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 80,
                                                                      height:
                                                                          80,
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    width: 80,
                                                                    height: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          600], // Dark grey color
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .person,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .white
                                                                          .withValues(alpha: 0.7),
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      // Name and shop info
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 80,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    _profileData![
                                                                            'name'] ??
                                                                        'No Name',
                                                                    style: TextStyle(
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: buttonTextColor,
                                                                    ),
                                                                  ),
                                                                  buildVerifiedTick(
                                                                      _profileData?[
                                                                              'verified'] ??
                                                                          false,
                                                                      buttonColor),
                                                                ],
                                                              ),
                                                              if (_profileData![
                                                                      'shop_name'] !=
                                                                  null)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              1.0),
                                                                  child: Text(
                                                                    _profileData![
                                                                        'shop_name'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: bgTextColor
                                                                          .withValues(alpha: 0.7),
                                                                    ),
                                                                  ),
                                                                ),

                                                              // Location
                                                              if (_profileData![
                                                                          'city'] !=
                                                                      null ||
                                                                  _profileData![
                                                                          'country'] !=
                                                                      null)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              3.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        size:
                                                                            14,
                                                                        color: bgTextColor.withValues(alpha: 0.6),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              2),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          [
                                                                            _profileData!['city'],
                                                                            _profileData!['state'],
                                                                            _profileData!['country']
                                                                          ].where((item) => item != null).join(
                                                                              ', '),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                bgTextColor.withValues(alpha: 0.6),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize:
                                                                                11,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Stats row
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        buttonColor.withValues(alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      _buildStatWidget(
                                                          context,
                                                          _galleryItems.length
                                                              .toString(),
                                                          'Gallery',
                                                          bgTextColor),
                                                      _buildStatWidget(
                                                          context,
                                                          _serviceItems.length
                                                              .toString(),
                                                          'Services',
                                                          bgTextColor),
                                                      GestureDetector(
                                                        // onTap: _navigateToFollowers,
                                                        child: _buildStatWidget(
                                                            context,
                                                            _followersCountFormatted
                                                                .toString(),
                                                            'Followers',
                                                            bgTextColor),
                                                      ),
                                                      GestureDetector(
                                                        // onTap: _navigateToFollowing,
                                                        child: _buildStatWidget(
                                                            context,
                                                            _followingCountFormatted
                                                                .toString(),
                                                            'Following',
                                                            bgTextColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 12),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Bio Card
                                    if (_profileData!['bio'] != null)
                                      SliverToBoxAdapter(
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth:
                                                  600, // Set your desired max width
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  11, 12, 11, 0),
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: bgColor.withValues(alpha: 0.95),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.08),
                                                    blurRadius: 12,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: buttonColor.withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.info_outline,
                                                        size: 16,
                                                        color: buttonColor,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'About',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: buttonColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _profileData!['bio'],
                                                    style: TextStyle(
                                                      color: bgTextColor
                                                          .withValues(alpha: 0.9),
                                                      fontSize: 13,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Action Buttons
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                600, // Set your desired max width
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(11),
                                            padding: const EdgeInsets.all(11),
                                            decoration: BoxDecoration(
                                              color: bgColor.withValues(alpha: 0.95),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.08),
                                                  blurRadius: 12,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: buttonColor.withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // Message Button
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed:
                                                        _showMessageOptions,
                                                    icon: const Icon(
                                                        Icons.message,
                                                        size: 18),
                                                    label:
                                                        const Text('Message'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          buttonColor,
                                                      foregroundColor:
                                                          buttonTextColor,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 17),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                // Follow Button
                                                Expanded(
                                                  child: FollowButton(
                                                    initialIsFollowing:
                                                        _isFollowing,
                                                    userId: widget.userId,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Tab Bar
                                    SliverPersistentHeader(
                                      pinned: true,
                                      delegate: SliverAppBarDelegate(
                                        TabBar(
                                          controller: _tabController,
                                          labelColor: buttonColor,
                                          unselectedLabelColor: bgTextColor
                                              .withValues(alpha: 0.7),
                                          indicatorColor: buttonColor,
                                          indicatorWeight: 3,
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          tabs: const [
                                            Tab(
                                                icon: Icon(Icons
                                                    .photo_library_rounded)),
                                            Tab(
                                                icon: Icon(Icons
                                                    .miscellaneous_services)),
                                            Tab(
                                                icon: Icon(
                                                    Icons.chat_bubble_outline)),
                                          ],
                                        ),
                                        color: bgColor,
                                      ),
                                    ),

                                    // Tab Content
                                    SliverFillRemaining(
                                      child: SizedBox(
                                        height: 800,
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            // Gallery Tab
                                            _galleryItems.isEmpty
                                                ? Center(
                                                    child: Text('no gallery',
                                                        style: TextStyle(
                                                            color:
                                                                bgTextColor)),
                                                  )
                                                // ? _buildEmptyState(
                                                //     'No gallery items', Icons.photo_library)
                                                : LayoutBuilder(
                                                    builder:
                                                        (context, constraints) {
                                                      // Dynamically calculate number of columns based on width
                                                      int crossAxisCount =
                                                          _calculateColumnCount(
                                                              constraints
                                                                  .maxWidth);

                                                      return GridView.builder(
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              crossAxisCount,
                                                          mainAxisSpacing: 1,
                                                          crossAxisSpacing: 1,
                                                          childAspectRatio: 1.0,
                                                        ),
                                                        itemCount: _galleryItems
                                                            .length,
                                                        // physics:
                                                        //     const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 50),
                                                        itemBuilder:
                                                            (context, index) {
                                                          final item =
                                                              _galleryItems[
                                                                  index];

                                                          // Create staggered effect by varying aspect ratio
                                                          // First item in each row gets different aspect ratio
                                                          double aspectRatio =
                                                              index % crossAxisCount ==
                                                                      0
                                                                  ? 0.75
                                                                  : 1.0;

                                                          return AspectRatio(
                                                            aspectRatio:
                                                                aspectRatio,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () =>
                                                                  _showGalleryItemDetails(
                                                                      item),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          CachedNetworkImageProvider(
                                                                        item['gallery_image_url'] ??
                                                                            '',
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withValues(alpha: 0.2),
                                                                        blurRadius:
                                                                            10,
                                                                        spreadRadius:
                                                                            2,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      gradient:
                                                                          LinearGradient(
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter,
                                                                        colors: [
                                                                          Colors
                                                                              .transparent,
                                                                          Colors
                                                                              .black
                                                                              .withValues(alpha: 0.7),
                                                                        ],
                                                                        stops: const [
                                                                          0.7,
                                                                          1.0
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          if (item['gallery_title'] !=
                                                                              null)
                                                                            Text(
                                                                              item['gallery_title'],
                                                                              style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 14,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          if (item['gallery_price'] !=
                                                                              null)
                                                                            if (item['gallery_price'] != null &&
                                                                                item['gallery_price'] != 0 &&
                                                                                item['gallery_price'] != '0')
                                                                              Text(
                                                                                '₹${item['gallery_price']}',
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),

                                            // Services Tab
                                            _serviceItems.isEmpty
                                                ? Center(
                                                    child: Text('No services',
                                                        style: TextStyle(
                                                            color:
                                                                bgTextColor)))
                                                : ListView.builder(
                                                     padding:
                                                         const EdgeInsets.all(
                                                             16),
                                                     shrinkWrap: true,
                                                     physics:
                                                         const NeverScrollableScrollPhysics(),
                                                     itemCount:
                                                         _serviceItems.length,
                                                    // physics:
                                                    //     const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      final service =
                                                          _serviceItems[index];
                                                      return Card(
                                                        color: buttonColor,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 16),
                                                        elevation: 3,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    service['service_title'] ??
                                                                        'No Title',
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          buttonTextColor,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Chip(
                                                                    label: Text(
                                                                      '\₹${service['service_price'] ?? 0}',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            buttonColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    backgroundColor:
                                                                        buttonTextColor,
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8),
                                                                  ),
                                                                ],
                                                              ),
                                                              if (service[
                                                                      'service_category'] !=
                                                                  null)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              4.0),
                                                                  child: Text(
                                                                    service[
                                                                        'service_category'],
                                                                    style:
                                                                        TextStyle(
                                                                      color: buttonTextColor
                                                                          .withValues(alpha: 0.8),
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (service[
                                                                      'service_description'] !=
                                                                  null)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0),
                                                                  child: Text(
                                                                    service[
                                                                        'service_description'],
                                                                    style:
                                                                        TextStyle(
                                                                      color: buttonTextColor
                                                                          .withValues(alpha: 0.8),
                                                                      height:
                                                                          1.3,
                                                                    ),
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                  height: 16),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        ElevatedButton
                                                                            .icon(
                                                                      onPressed:
                                                                          _navigateToMessages,
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .message,
                                                                          size:
                                                                              18),
                                                                      label: const Text(
                                                                          'Message'),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            buttonTextColor,
                                                                        foregroundColor:
                                                                            buttonColor,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                17),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        elevation:
                                                                            0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                            userThreads.isEmpty
                                                ? Center(
                                                    child: Text(
                                                    'No threads yet',
                                                    style: TextStyle(
                                                        color: bgTextColor),
                                                  ))
                                                : ListView.builder(
                                                     padding: EdgeInsets.zero,
                                                     shrinkWrap: true,
                                                     physics:
                                                         const NeverScrollableScrollPhysics(),
                                                     itemCount:
                                                         userThreads.length,
                                                     itemBuilder:
                                                         (context, index) {
                                                      final thread =
                                                          userThreads[index];
                                                      //  final Map<String, dynamic> threads = userThreads[index];
                                                      final int likeCount =
                                                          (thread['like_count']
                                                                  as int?) ??
                                                              0;
                                                      final int fakeLikes =
                                                          (thread['fake_likes']
                                                                  as int?) ??
                                                              0;
                                                      final int totalLikes =
                                                          likeCount + fakeLikes;
                                                      final String
                                                          formattedLikes =
                                                          _formatCount(
                                                              totalLikes);
                                                       return Card(
                                                         color: buttonColor,
                                                         margin: const EdgeInsets
                                                             .symmetric(
                                                           vertical: 1,
                                                           horizontal: 16,
                                                         ),
                                                         child: Padding(
                                                           padding:
                                                               const EdgeInsets
                                                                   .all(16),
                                                           child: Column(
                                                             crossAxisAlignment:
                                                                 CrossAxisAlignment
                                                                     .start,
                                                             children: [
                                                               Text(
                                                                 timeago.format(
                                                                     DateTime.parse(
                                                                         thread[
                                                                             'created_at'])),
                                                                 style:
                                                                     TextStyle(
                                                                   color:
                                                                       buttonTextColor,
                                                                   fontSize: 12,
                                                                 ),
                                                               ),
                                                               const SizedBox(
                                                                   height: 8),
                                                               Text(
                                                                 thread[
                                                                     'content'] ?? '',
                                                                 style:
                                                                     TextStyle(
                                                                   fontSize: 14,
                                                                   fontWeight:
                                                                       FontWeight
                                                                           .w500,
                                                                   color:
                                                                       buttonTextColor,
                                                                 ),
                                                               ),
                                                               const SizedBox(
                                                                   height: 16),
                                                               Row(
                                                                 mainAxisAlignment:
                                                                     MainAxisAlignment
                                                                         .spaceBetween,
                                                                 children: [
                                                                   InkWell(
                                                                     onTap: () =>
                                                                         {
                                                                       Navigator.push(
                                                                           context,
                                                                           MaterialPageRoute(
                                                                               builder: (context) => ThreadCommentsPage(
                                                                                     threadContent: thread['content'] ?? '',
                                                                                     threadId: thread['id'] ?? '',
                                                                                   )))
                                                                     },
                                                                     child: Row(
                                                                       children: [
                                                                         Icon(
                                                                             Icons
                                                                                 .favorite,
                                                                             size:
                                                                                 16,
                                                                             color:
                                                                                 buttonTextColor),
                                                                         const SizedBox(
                                                                             width:
                                                                                 4),
                                                                         Text(
                                                                             formattedLikes,
                                                                             style:
                                                                                 TextStyle(color: buttonTextColor)),
                                                                       ],
                                                                     ),
                                                                   ),
                                                                   InkWell(
                                                                     onTap: () =>
                                                                         {
                                                                       Navigator.push(
                                                                           context,
                                                                           MaterialPageRoute(
                                                                               builder: (context) => ThreadCommentsPage(
                                                                                     threadContent: thread['content'] ?? '',
                                                                                     threadId: thread['id'] ?? '',
                                                                                   )))
                                                                     },
                                                                     child: Row(
                                                                       children: [
                                                                         Icon(
                                                                             Icons
                                                                                 .comment,
                                                                             size:
                                                                                 16,
                                                                             color:
                                                                                 buttonTextColor),
                                                                         const SizedBox(
                                                                             width:
                                                                                 4),
                                                                         Text(
                                                                             '${thread['comment_count'] ?? 0}',
                                                                             style:
                                                                                 TextStyle(color: buttonTextColor)),
                                                                       ],
                                                                     ),
                                                                   ),
                                                                 ],
                                                               ),
                                                             ],
                                                           ),
                                                         ),
                                                       );
                                                    },
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_showScrollToTop)
                                  Positioned(
                                    top: MediaQuery.of(context).padding.top +
                                        50, // Below status bar
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _scrollToTop,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: buttonColor.withValues(alpha: 0.9),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: buttonColor.withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.keyboard_arrow_up,
                                                  color: buttonTextColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Top',
                                                  style: TextStyle(
                                                    color: buttonTextColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
      floatingActionButton:
          _checkingBlockStatus || _isBlockedByOther || _isBlocked
              ? null // Hide FAB when blocked
              : FloatingActionButton.extended(
                  onPressed: () => _showAIAssistant(context),
                  icon: const Icon(Icons.smart_toy_rounded),
                  label: const Text('Ask AI'),
                  backgroundColor: _getButtonColor(),
                  foregroundColor: _getButtonTextColor(),
                ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  SliverAppBarDelegate(this.tabBar, {required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || color != oldDelegate.color;
  }
}

int _calculateColumnCount(double width) {
  if (width < 400) {
    return 3; // Very small mobile screens
  } else if (width < 600) {
    return 4; // Small mobiles
  } else if (width < 750) {
    return 5; // Mid-size mobiles / phablets
  } else if (width < 900) {
    return 6; // Large phones / small tablets
  } else if (width < 1050) {
    return 7; // Tablets
  } else if (width < 1200) {
    return 8; // Large tablets / small desktops
  } else if (width < 1500) {
    return 9; // Standard desktops
  } else if (width < 1800) {
    return 10; // Large desktops
  } else if (width < 2100) {
    return 11; // Ultra-wide screens
  } else {
    return 12; // Super ultra-wide screens
  }
}

class AIAssistantWidget extends StatefulWidget {
  final String userId;
  final Color? buttonColor;
  final Color? bgColor;
  final Color? textColor;
  final Color? buttonTextColor;

  const AIAssistantWidget({
    super.key,
    required this.userId,
    this.buttonColor,
    this.bgColor,
    this.textColor,
    this.buttonTextColor,
  });

  @override
  State<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends State<AIAssistantWidget>
    with TickerProviderStateMixin {
  final SupabaseClient _supabase = SupaFlow.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  final bool _isLoading = false;
  bool _isTyping = false;
  bool _showSuggestedQuestions = true;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];
  String _followersCount = '0';
  String _followingCount = '0';

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // Suggested questions
  final List<String> _suggestedQuestions = [
    "Who is this person?",
    "Tell me about their profile",
    "Show me their gallery",
    "What services do they offer?",
    "How can I contact them?",
    "Where are they located?",
    "What are their prices?",
    "Show me their best work",
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    _initializeAI();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeAI() {
    _fetchProfileData().then((_) {
      final aiName = _getAIName();
      _addMessage(ChatMessage(
        text:
            "Hello! I'm $aiName. I can help you with detailed information about this profile, show you gallery items with images, services, and much more. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getAIName() {
    if (_profileData != null && _profileData!['shop_name'] != null) {
      return "${_profileData!['shop_name']} Assistant AI";
    }
    return "Assistant AI";
  }

  void _addMessage(ChatMessage message) {
    safeSetState(() {
      _messages.add(message);
      if (message.isUser) {
        _showSuggestedQuestions = false;
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchProfileData() async {
    try {
      // Fetch profile data
      final profileResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          profile_id, profile_created_at, user_id, name, phone_no, country, bio, 
          shop_name, profile_image_url, banner_image_url, button_color_code, 
          bg_color_code, bg_text_color, state, city, button_text_color, verified
        ''')
          .eq('user_id', widget.userId)
          .limit(1);

      if (profileResponse.isNotEmpty) {
        _profileData = profileResponse.first;
      }

      // Fetch gallery items
      final galleryResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          gallery_id, gallery_title, gallery_description, 
          gallery_price, gallery_image_url, gallery_category
        ''')
          .eq('user_id', widget.userId)
          .not('gallery_id', 'is', null);

      _galleryItems = galleryResponse;

      // Fetch services
      final serviceResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          service_id, service_title, service_description, 
          service_price, service_category
        ''')
          .eq('user_id', widget.userId)
          .not('service_id', 'is', null);

      _serviceItems = serviceResponse;

      // Fetch follow counts
      await _fetchFollowCounts();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    } else {
      return count.toString();
    }
  }

  Future<void> _fetchFollowCounts() async {
    try {
      final followersResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', widget.userId);

      final followingResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', widget.userId);

      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', widget.userId)
          .maybeSingle();

      int baseFollowers = 0;
      if (userResponse != null && userResponse['followers'] != null) {
        baseFollowers = (userResponse['followers'] as num).toInt();
      }

      final int followersCountRaw = followersResponse.length + baseFollowers;
      final int followingCountRaw = followingResponse.length;

      safeSetState(() {
        _followersCount = _formatCount(followersCountRaw);
        _followingCount = _formatCount(followingCountRaw);
      });
    } catch (e) {
      debugPrint('Error fetching follow counts: $e');
    }
  }

  void _sendMessage([String? predefinedMessage]) async {
    final messageText = predefinedMessage ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    if (predefinedMessage == null) {
      _messageController.clear();
    }

    _addMessage(ChatMessage(
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    safeSetState(() {
      _isTyping = true;
    });
    _typingAnimationController.repeat();

    // Simulate AI thinking time
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiResponse = await _generateAIResponse(messageText);

    safeSetState(() {
      _isTyping = false;
    });
    _typingAnimationController.stop();

    _addMessage(ChatMessage(
      text: aiResponse.text,
      isUser: false,
      timestamp: DateTime.now(),
      galleryItems: aiResponse.galleryItems,
      hasGalleryGrid: aiResponse.hasGalleryGrid,
    ));
  }

  Future<AIResponse> _generateAIResponse(String userMessage) async {
    final message = userMessage.toLowerCase();

    // Who is this person queries
    if (message.contains('who is') ||
        message.contains('who are') ||
        message.contains('about this person') ||
        message.contains('tell me about them')) {
      if (_profileData != null) {
        final name = _profileData!['name'] ?? 'Unknown';
        final shopName = _profileData!['shop_name'];
        final bio = _profileData!['bio'];
        final verified = _profileData!['verified'] == true;
        final location =
            "${_profileData!['city'] ?? ''}, ${_profileData!['state'] ?? ''}"
                    .replaceAll(', ', '')
                    .isNotEmpty
                ? "${_profileData!['city'] ?? ''}, ${_profileData!['state'] ?? ''}"
                : "Location not specified";

        String response = "This is $name";
        if (shopName != null) response += ", owner of $shopName";
        response += ".\n\n";

        if (verified) response += "✓ Verified Profile\n";
        response += "📍 Located in $location\n";
        response +=
            "👥 $_followersCount followers, $_followingCount following\n\n";

        if (bio != null && bio.isNotEmpty) {
          response += "About them:\n$bio\n\n";
        }

        response +=
            "They have ${_galleryItems.length} gallery items and ${_serviceItems.length} services available.";

        return AIResponse(text: response);
      }
      return AIResponse(
          text:
              "I'm still loading the profile information. Please wait a moment and try again.");
    }

    // Profile information queries
    if (message.contains('profile') ||
        message.contains('about') ||
        message.contains('info')) {
      if (_profileData != null) {
        final joinDate = _profileData!['profile_created_at'] != null
            ? DateTime.parse(_profileData!['profile_created_at']).year
            : 'Unknown';

        return AIResponse(
            text: "Here's the complete profile information:\n\n"
                "👤 Name: ${_profileData!['name'] ?? 'Not provided'}\n"
                "🏪 Shop: ${_profileData!['shop_name'] ?? 'Not provided'}\n"
                "📍 Location: ${_profileData!['city'] ?? 'Unknown'}, ${_profileData!['state'] ?? 'Unknown'}\n"
                "🌍 Country: ${_profileData!['country'] ?? 'Not specified'}\n"
                "✅ Verified: ${_profileData!['verified'] == true ? 'Yes ✓' : 'No'}\n"
                "📅 Member since: $joinDate\n"
                "👥 Followers: $_followersCount\n"
                "👤 Following: $_followingCount\n"
                "🖼️ Gallery Items: ${_galleryItems.length}\n"
                "🛠️ Services: ${_serviceItems.length}\n\n"
                "Bio: ${_profileData!['bio'] ?? 'No bio available'}");
      }
      return AIResponse(
          text:
              "I'm still loading the profile information. Please wait a moment and try again.");
    }

    // Gallery queries with images
    if (message.contains('gallery') ||
        message.contains('show me') ||
        message.contains('items') ||
        message.contains('products') ||
        message.contains('work') ||
        message.contains('portfolio')) {
      if (_galleryItems.isNotEmpty) {
        return AIResponse(
          text:
              "Here are the gallery items (${_galleryItems.length} total). Tap on any item to view details:",
          galleryItems: _galleryItems,
          hasGalleryGrid: true,
        );
      }
      return AIResponse(
          text: "This profile doesn't have any gallery items yet.");
    }

    // Services queries
    if (message.contains('service') || message.contains('services')) {
      if (_serviceItems.isNotEmpty) {
        String response =
            "This profile offers ${_serviceItems.length} services:\n\n";
        for (int i = 0; i < _serviceItems.length; i++) {
          final item = _serviceItems[i];
          response +=
              "${i + 1}. ${item['service_title'] ?? 'Untitled Service'}\n";
          if (item['service_description'] != null) {
            response += "   📝 ${item['service_description']}\n";
          }
          if (item['service_price'] != null) {
            response += "   💰 Price: ₹${item['service_price']}\n";
          }
          if (item['service_category'] != null) {
            response += "   🏷️ Category: ${item['service_category']}\n";
          }
          response += "\n";
        }
        return AIResponse(text: response);
      }
      return AIResponse(text: "This profile doesn't offer any services yet.");
    }

    // Contact information
    if (message.contains('contact') ||
        message.contains('phone') ||
        message.contains('call') ||
        message.contains('reach')) {
      if (_profileData != null && _profileData!['phone_no'] != null) {
        return AIResponse(
            text: "📞 Contact Information:\n\n"
                "Phone: ${_profileData!['phone_no']}\n\n"
                "You can also:\n"
                "• Send them a direct message through the app\n"
                "• Contact via WhatsApp\n"
                "• Follow them to stay updated with their latest posts");
      }
      return AIResponse(
          text: "Contact information is not available for this profile.");
    }

    // Location queries
    if (message.contains('location') ||
        message.contains('address') ||
        message.contains('where')) {
      if (_profileData != null) {
        final city = _profileData!['city'];
        final state = _profileData!['state'];
        final country = _profileData!['country'];

        if (city != null || state != null) {
          return AIResponse(
              text: "📍 Location Information:\n\n"
                  "City: ${city ?? 'Unknown'}\n"
                  "State: ${state ?? 'Unknown'}\n"
                  "Country: ${country ?? 'Not specified'}\n\n"
                  "This is where they are based and likely provide their services.");
        }
      }
      return AIResponse(
          text: "Location information is not available for this profile.");
    }

    // Best work queries
    if (message.contains('best') ||
        message.contains('top') ||
        message.contains('featured')) {
      if (_galleryItems.isNotEmpty) {
        // Sort by price or show first few items as "best"
        final bestItems = _galleryItems.take(3).toList();
        return AIResponse(
          text: "Here are some of their best works:",
          galleryItems: bestItems,
          hasGalleryGrid: true,
        );
      }
      return AIResponse(
          text: "No gallery items available to show their best work.");
    }

    // Price queries
    if (message.contains('price') ||
        message.contains('cost') ||
        message.contains('expensive') ||
        message.contains('cheap') ||
        message.contains('budget')) {
      List<int> prices = [];

      for (var item in _galleryItems) {
        if (item['gallery_price'] != null) {
          prices.add(item['gallery_price'] as int);
        }
      }
      for (var item in _serviceItems) {
        if (item['service_price'] != null) {
          prices.add(item['service_price'] as int);
        }
      }

      if (prices.isNotEmpty) {
        prices.sort();
        return AIResponse(
            text: "💰 Pricing Information:\n\n"
                "• Lowest Price: ₹${prices.first}\n"
                "• Highest Price: ₹${prices.last}\n"
                "• Average Price: ₹${(prices.reduce((a, b) => a + b) / prices.length).round()}\n"
                "• Total Priced Items: ${prices.length}\n\n"
                "Prices may vary based on requirements and customization.");
      }
      return AIResponse(
          text:
              "No pricing information is available for this profile's items.");
    }

    // Help queries
    if (message.contains('help') || message.contains('what can you do')) {
      return AIResponse(
          text: "I'm ${_getAIName()} and I can help you with:\n\n"
              "🔍 Profile & Personal Information\n"
              "🖼️ Gallery Items with Images\n"
              "🛠️ Services & Offerings\n"
              "📞 Contact Details\n"
              "📍 Location Information\n"
              "💰 Pricing Details\n"
              "📊 Social Stats\n"
              "🏷️ Categories & Types\n"
              "⭐ Best Work & Featured Items\n\n"
              "Just ask me anything about this profile! You can also tap on the suggested questions below.");
    }

    // Greeting responses
    if (message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey') ||
        message.contains('good morning') ||
        message.contains('good afternoon')) {
      return AIResponse(
          text:
              "Hello! I'm ${_getAIName()}. I'm here to help you learn everything about this profile. "
              "You can ask me about their services, gallery items, contact information, or anything else you'd like to know!\n\n"
              "Try asking: 'Who is this person?' or 'Show me their gallery'");
    }

    // Thank you responses
    if (message.contains('thank') || message.contains('thanks')) {
      return AIResponse(
          text:
              "You're welcome! I'm always here to help. Is there anything else you'd like to know about this profile? "
              "I can show you more gallery items, services, or any other information you need.");
    }

    // Default response with suggestions
    return AIResponse(
        text:
            "I'm not sure about that specific question, but I'm ${_getAIName()} and I can help you with:\n\n"
            "👤 Profile details and personal info\n"
            "🖼️ Gallery items with images\n"
            "🛠️ Services and offerings\n"
            "📞 Contact and location info\n"
            "💰 Pricing and social stats\n\n"
            "Try asking: 'Who is this person?', 'Show me their gallery', or 'What services do they offer?'");
  }

  // "📱 Phone: ${_profileData!['phone_no'] ?? 'Not provided'}\n"
  Color _getButtonColor() {
    return widget.buttonColor ??
        (_profileData != null && _profileData!['button_color_code'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_color_code'].substring(1)}',
                radix: 16))
            : Colors.yellow);
  }

  Color _getBgColor() {
    return widget.bgColor ??
        (_profileData != null && _profileData!['bg_color_code'] != null
            ? Color(int.parse(
                'FF${_profileData!['bg_color_code'].substring(1)}',
                radix: 16))
            : Colors.black);
  }

  Color _getTextColor() {
    return widget.textColor ??
        (_profileData != null && _profileData!['bg_text_color'] != null
            ? Color(int.parse(
                'FF${_profileData!['bg_text_color'].substring(1)}',
                radix: 16))
            : Colors.white);
  }

  Color _getButtonTextColor() {
    return widget.buttonTextColor ??
        (_profileData != null && _profileData!['button_text_color'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_text_color'].substring(1)}',
                radix: 16))
            : Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getBgColor(),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // ✅ hide keyboard
              },
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getButtonColor(),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _getButtonTextColor().withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header content
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getButtonTextColor()
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.smart_toy_rounded,
                                color: _getButtonTextColor(),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getAIName(),
                                    style: TextStyle(
                                      color: _getButtonTextColor(),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Your intelligent profile assistant',
                                    style: TextStyle(
                                      color: _getButtonTextColor()
                                          .withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: _getButtonTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getButtonColor().withValues(alpha: 0.05),
                      border: Border(
                        top: BorderSide(
                          color: _getButtonColor().withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getBgColor(),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color:
                                      _getButtonColor().withValues(alpha: 0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Ask me anything...',
                                  hintStyle: TextStyle(
                                    color:
                                        _getTextColor().withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(color: _getTextColor()),
                                maxLines: null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _sendMessage(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getButtonColor(),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getButtonColor()
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                color: _getButtonTextColor(),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }

                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),

                  // Suggested questions
                  if (_showSuggestedQuestions) _buildSuggestedQuestions(),

                  // Input area
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Questions:',
            style: TextStyle(
              color: _getTextColor().withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((question) {
              return GestureDetector(
                onTap: () => _sendMessage(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getButtonColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getButtonColor().withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    question,
                    style: TextStyle(
                      color: _getButtonColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getButtonColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: _getButtonColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? _getButtonColor()
                        : _getButtonColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color:
                              isUser ? _getButtonTextColor() : _getTextColor(),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color:
                              (isUser ? _getButtonTextColor() : _getTextColor())
                                  .withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getButtonColor().withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getButtonColor(),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          // Gallery grid
          if (message.hasGalleryGrid && message.galleryItems != null)
            _buildGalleryGrid(message.galleryItems!),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => _showGalleryItemDetails(item),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getButtonColor().withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: item['gallery_image_url'] != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                item['gallery_image_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: _getButtonColor().withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Icon(
                                Icons.image,
                                color: _getButtonColor(),
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['gallery_title'] ?? 'Untitled',
                            style: TextStyle(
                              color: _getTextColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (item['gallery_price'] != null)
                            Text(
                              '₹${item['gallery_price']}',
                              style: TextStyle(
                                color: _getButtonColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (item['gallery_category'] != null)
                            Text(
                              item['gallery_category'],
                              style: TextStyle(
                                color: _getTextColor().withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGalleryItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _getBgColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getButtonColor(),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['gallery_title'] ?? 'Gallery Item',
                      style: TextStyle(
                        color: _getButtonTextColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: _getButtonTextColor(),
                    ),
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
                    // Image
                    if (item['gallery_image_url'] != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getButtonColor().withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['gallery_image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[600],
                                  size: 64,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // Details
                    if (item['gallery_price'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            color: _getButtonColor(),
                            size: 18,
                          ),
                          Text(
                            '${item['gallery_price']}',
                            style: TextStyle(
                              color: _getButtonColor(),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (item['gallery_category'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: _getTextColor().withValues(alpha: 0.7),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['gallery_category'],
                            style: TextStyle(
                              color: _getTextColor().withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (item['gallery_description'] != null) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['gallery_description'],
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getButtonColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: _getButtonColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getButtonColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_getAIName().split(' ').first} is typing',
                  style: TextStyle(
                    color: _getTextColor().withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getButtonColor().withValues(alpha: 
                              0.3 +
                                  0.7 *
                                      (((_typingAnimation.value + index * 0.3) %
                                          1.0))),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? galleryItems;
  final bool hasGalleryGrid;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.galleryItems,
    this.hasGalleryGrid = false,
  });
}

class AIResponse {
  final String text;
  final List<Map<String, dynamic>>? galleryItems;
  final bool hasGalleryGrid;

  AIResponse({
    required this.text,
    this.galleryItems,
    this.hasGalleryGrid = false,
  });
}

class CircularShimmer extends StatelessWidget {
  final Color buttonColor;
  final Color bgColor;
  final double size;

  const CircularShimmer({
    super.key,
    required this.buttonColor,
    required this.bgColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomShimmer(
        baseColor: bgColor.withValues(alpha: 0.3),
        highlightColor: buttonColor.withValues(alpha: 0.7),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class CustomShimmer extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;
  final Widget child;
  final Duration duration;

  const CustomShimmer({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// -------------------------------------------------------------------------
// Specialized Tab Content Widgets for High Performance & State Handling
// -------------------------------------------------------------------------

class ThreadsTabContent extends ConsumerStatefulWidget {
  final String userId;
  final Color bgTextColor;
  final Color buttonColor;

  const ThreadsTabContent({
    super.key,
    required this.userId,
    required this.bgTextColor,
    required this.buttonColor,
  });

  @override
  ConsumerState<ThreadsTabContent> createState() => _ThreadsTabContentState();
}

class _ThreadsTabContentState extends ConsumerState<ThreadsTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final threadsAsync = ref.watch(userThreadsProvider(widget.userId));

    return threadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (threads) {
        if (threads.isEmpty) {
          return Center(
            child: Text(
              'No threads yet',
              style: TextStyle(color: widget.bgTextColor),
            ),
          );
        }

        return RepaintBoundary(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return Card(
                color: widget.buttonColor.withValues(alpha: 0.05),
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: widget.buttonColor.withValues(alpha: 0.1)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    flutter.HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThreadCommentsPage(
                          threadContent: thread['content'],
                          threadId: thread['id'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              timeago
                                  .format(DateTime.parse(thread['created_at'])),
                              style: TextStyle(
                                color:
                                    widget.bgTextColor.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          thread['content'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.bgTextColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _StatItem(
                              icon: Icons.favorite_border,
                              value:
                                  '${(thread['like_count'] ?? 0) + (thread['fake_likes'] ?? 0)}',
                              color: widget.buttonColor,
                              textColor: widget.bgTextColor,
                            ),
                            const SizedBox(width: 20),
                            _StatItem(
                              icon: Icons.chat_bubble_outline,
                              value: '${thread['comment_count'] ?? 0}',
                              color: widget.buttonColor,
                              textColor: widget.bgTextColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ServicesTabContent extends ConsumerStatefulWidget {
  final String userId;
  final Color bgTextColor;
  final Color buttonColor;

  const ServicesTabContent({
    super.key,
    required this.userId,
    required this.bgTextColor,
    required this.buttonColor,
  });

  @override
  ConsumerState<ServicesTabContent> createState() => _ServicesTabContentState();
}

class _ServicesTabContentState extends ConsumerState<ServicesTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final servicesAsync = ref.watch(userServicesProvider(widget.userId));

    return servicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (services) {
        if (services.isEmpty) {
          return Center(
            child: Text(
              'No services offered',
              style:
                  TextStyle(color: widget.bgTextColor.withValues(alpha: 0.5)),
            ),
          );
        }

        return RepaintBoundary(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: widget.bgTextColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: widget.bgTextColor.withValues(alpha: 0.08)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 6,
                          color: widget.buttonColor,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service['title'] ?? 'Untitled',
                                        style: TextStyle(
                                          color: widget.bgTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    if (service['price'] != null)
                                      Text(
                                        '₹${service['price']}',
                                        style: TextStyle(
                                          color: widget.buttonColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (service['category'] != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.buttonColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      service['category'],
                                      style: TextStyle(
                                        color: widget.buttonColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                Text(
                                  service['description'] ?? '',
                                  style: TextStyle(
                                    color: widget.bgTextColor
                                        .withValues(alpha: 0.7),
                                    fontSize: 14,
                                    height: 1.4,
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
              );
            },
          ),
        );
      },
    );
  }
}

class GalleryTabContent extends ConsumerStatefulWidget {
  final String userId;
  final Color bgTextColor;
  final Color buttonColor;

  const GalleryTabContent({
    super.key,
    required this.userId,
    required this.bgTextColor,
    required this.buttonColor,
  });

  @override
  ConsumerState<GalleryTabContent> createState() => _GalleryTabContentState();
}

class _GalleryTabContentState extends ConsumerState<GalleryTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final galleryAsync = ref.watch(userGalleryProvider(widget.userId));

    return galleryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (gallery) {
        if (gallery.isEmpty) {
          return Center(
            child: Text(
              'No gallery items',
              style:
                  TextStyle(color: widget.bgTextColor.withValues(alpha: 0.5)),
            ),
          );
        }

        return RepaintBoundary(
          child: MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: gallery.length,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            itemBuilder: (context, index) {
              final item = gallery[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: item['image_url'] ?? '',
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: widget.bgTextColor.withValues(alpha: 0.05),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.buttonColor),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: widget.bgTextColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final Color textColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class ThreadCommentsPage extends ConsumerStatefulWidget {
  final String threadId;
  final String threadContent;

  const ThreadCommentsPage({
    super.key,
    required this.threadId,
    required this.threadContent,
  });

  @override
  ConsumerState<ThreadCommentsPage> createState() => _ThreadCommentsPageState();
}

class _ThreadCommentsPageState extends ConsumerState<ThreadCommentsPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _threadScrollController =
      ScrollController(); // New scroll controller for thread content
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  bool isPosting = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fetchComments();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _threadScrollController.dispose(); // Dispose the new scroll controller
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    safeSetState(() {
      isLoading = true;
    });

    try {
      final response = await ref
          .read(profileRepositoryProvider)
          .fetchThreadComments(widget.threadId);

      if (mounted) {
        safeSetState(() {
          comments = response;
          isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Error fetching comments: ${e.toString()}');
      }
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    safeSetState(() {
      isPosting = true;
    });

    final userId = SupaFlow.client.auth.currentUser?.id ?? 'sample-user-id';

    try {
      await ref.read(profileRepositoryProvider).postThreadComment(
            widget.threadId,
            userId,
            _commentController.text.trim(),
          );

      _commentController.clear();
      await _fetchComments();

      // Scroll to bottom to show new comment
      if (_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error posting comment: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          isPosting = false;
        });
      }
    }
  }

  Future<void> _deleteComment(String commentId, int index) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Comment',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this comment?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await ref
            .read(profileRepositoryProvider)
            .deleteThreadComment(commentId);

        // Remove comment with animation
        safeSetState(() {
          comments.removeAt(index);
        });

        _showSuccessSnackBar('Comment deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting comment: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, int index) {
    final currentUserId = SupaFlow.client.auth.currentUser?.id;
    final isOwner = comment['user_id'] == currentUserId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'avatar_${comment['user_id']}_$index',
          child: CircleAvatar(
            radius: 24,
            backgroundImage: comment['profile_image_url'] != null
                ? NetworkImage(comment['profile_image_url'])
                : null,
            backgroundColor: Colors.yellow[700],
            child: comment['profile_image_url'] == null
                ? Text(
                    comment['name']?[0]?.toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
        ),
        title: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment['name'] ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                ReportButton(
                  contentType: 'comment',
                  contentId: '${comment['id']}',
                  contentTitle: comment['name'] ?? 'Comment',
                  onReportSubmitted: () {
                    // Optional: Show feedback to user
                    if (!mounted) return;
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
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      comment['content'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeago.format(DateTime.parse(comment['created_at'])),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteComment(comment['id'], index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red[700]?.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellow),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.yellow.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Original thread with fixed height and scrollable content
          Container(
            width: double.infinity,
            height: 200, // Fixed height for the container
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.yellow.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        color: Colors.yellow[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Original Thread',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content section
                Expanded(
                  child: Scrollbar(
                    controller: _threadScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _threadScrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        widget.threadContent,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                      strokeWidth: 3,
                    ),
                  )
                : comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return _buildCommentItem(comments[index], index);
                          },
                        ),
                      ),
          ),

          // Enhanced comment input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(
                  color: Colors.yellow.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Add a thoughtful comment...',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Material(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: isPosting ? null : _postComment,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: isPosting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.black,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsAppShareHelper {
  // Static base URL for your application
  static const String baseAppUrl = 'https://handskillapp.web.app';

  /// Share to WhatsApp with all item details (for general sharing)
  static Future<void> shareToWhatsApp({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) async {
    try {
      String message = _buildFullMessage(item);
      String whatsappUrl = _buildWhatsAppUrl(message: message);

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      _showError(context, 'Error sharing to WhatsApp: $e');
    }
  }

  /// Share to specific WhatsApp number (for direct messaging)
  static Future<void> shareToSpecificWhatsAppNumber({
    required BuildContext context,
    required Map<String, dynamic> item,
    required String phoneNumber,
    bool includeFullDetails = true,
  }) async {
    try {
      String message = includeFullDetails
          ? _buildFullMessage(item)
          : _buildSimpleMessage(item);

      // Format phone number
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (formattedNumber.startsWith('0')) {
        formattedNumber = formattedNumber.substring(1);
      }

      String whatsappUrl = _buildWhatsAppUrl(
        message: message,
        phoneNumber: formattedNumber,
      );

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      _showError(context, 'Error sharing to WhatsApp: $e');
    }
  }

  /// Share only link without item details
  static Future<void> shareOnlyLink({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) async {
    try {
      String itemLink = _generateItemLink(item);
      String message = 'Check this out: $itemLink';
      String whatsappUrl = _buildWhatsAppUrl(message: message);

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      _showError(context, 'Error sharing link to WhatsApp: $e');
    }
  }

  static Future<void> sendWhatsAppMessageSimple({
    required BuildContext context,
    required String phoneNumber,
    required String message,
  }) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = formattedNumber; // Add your country code
    }

    String encodedMessage = Uri.encodeComponent(message);

    // Try multiple URL formats
    List<String> urls = [
      "https://wa.me/$formattedNumber?text=$encodedMessage",
      "whatsapp://send?phone=$formattedNumber&text=$encodedMessage",
      "https://api.whatsapp.com/send?phone=$formattedNumber&text=$encodedMessage",
    ];

    bool launched = false;
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched) {
      _showError(context, 'Error launching WhatsApp');
    }
  }

  /// Build full message with all item details
  static String _buildFullMessage(Map<String, dynamic> item) {
    String message = '';

    if (item['name'] != null && item['name'].toString().isNotEmpty) {
      message += 'Artist: ${item['name']}\n';
    }

    if (item['shop_name'] != null && item['shop_name'].toString().isNotEmpty) {
      message += 'Shop: ${item['shop_name']}\n';
    }

    if (item['phone_no'] != null && item['phone_no'].toString().isNotEmpty) {
      message += 'Phone: ${item['phone_no']}\n';
    }

    if (item['gallery_description'] != null &&
        item['gallery_description'].toString().isNotEmpty) {
      message += 'Description: ${item['gallery_description']}\n';
    }

    if (item['gallery_category'] != null &&
        item['gallery_category'].toString().isNotEmpty) {
      message += 'Category: ${item['gallery_category']}\n';
    }

    String itemLink = _generateItemLink(item);
    message += '\n🔗 Check it out here: $itemLink';

    return message;
  }

  /// Build simple message for direct messaging
  static String _buildSimpleMessage(Map<String, dynamic> item) {
    String message = 'Hi! ';

    if (item['name'] != null && item['name'].toString().isNotEmpty) {
      message += 'I\'m interested in your work (${item['name']}). ';
    }

    String itemLink = _generateItemLink(item);
    message += '\n\n🔗 Link: $itemLink';

    return message;
  }

  /// Generate item link based on item data
  static String _generateItemLink(Map<String, dynamic> item) {
    // You can customize this based on your app's URL structure
    String itemId = item['id']?.toString() ??
        item['gallery_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return '$baseAppUrl/item/$itemId';
  }

  /// Build WhatsApp URL based on platform
  static String _buildWhatsAppUrl({
    required String message,
    String? phoneNumber,
  }) {
    final encodedMessage = Uri.encodeComponent(message);

    if (kIsWeb) {
      // Web platform
      if (phoneNumber != null) {
        return 'https://wa.me/$phoneNumber?text=$encodedMessage';
      } else {
        return 'https://wa.me/?text=$encodedMessage';
      }
    } else if (Platform.isIOS) {
      // iOS platform
      if (phoneNumber != null) {
        return 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
      } else {
        return 'whatsapp://send?text=$encodedMessage';
      }
    } else {
      // Android platform
      if (phoneNumber != null) {
        return 'https://wa.me/$phoneNumber?text=$encodedMessage';
      } else {
        return 'https://wa.me/?text=$encodedMessage';
      }
    }
  }

  /// Launch WhatsApp with error handling
  static Future<void> _launchWhatsApp(
      BuildContext context, String whatsappUrl) async {
    try {
      if (kIsWeb) {
        // Web platform - simple launch
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else {
          _showError(context, 'Could not open WhatsApp Web');
        }
      } else {
        // Mobile platforms - try multiple methods
        await _launchWhatsAppMobile(context, whatsappUrl);
      }
    } catch (e) {
      _showError(context, 'Could not launch WhatsApp: $e');
    }
  }

  static Future<void> _launchWhatsAppMobile(
      BuildContext context, String whatsappUrl) async {
    // Extract phone number and message from the original URL for fallbacks
    String phoneNumber = '';
    String message = '';

    try {
      Uri uri = Uri.parse(whatsappUrl);
      phoneNumber = uri.path.replaceAll('/', '');
      message = uri.queryParameters['text'] ?? '';
    } catch (e) {
      // Continue with original URL if parsing fails
    }

    // Method 1: Try the original URL first
    if (await _tryLaunchUrl(whatsappUrl)) {
      return;
    }

    // Method 2: Try different URL formats based on platform
    List<String> fallbackUrls = [];

    if (Platform.isIOS) {
      // iOS fallbacks
      fallbackUrls = [
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      ];
    } else if (Platform.isAndroid) {
      // Android fallbacks
      fallbackUrls = [
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      ];
    }

    // Try each fallback URL
    for (String url in fallbackUrls) {
      if (await _tryLaunchUrl(url)) {
        return;
      }
    }

    // If all methods fail, show installation dialog
    _showWhatsAppNotInstalledDialog(context);
  }

  static Future<bool> _tryLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // Try to launch without checking canLaunchUrl first
      // because canLaunchUrl sometimes returns false even when the app exists
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      // If direct launch fails, try with canLaunchUrl check
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e2) {
        // Silently continue to next method
      }
    }
    return false;
  }

  static void _showWhatsAppNotInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WhatsApp Not Available'),
          content: Text(Platform.isIOS
              ? 'WhatsApp is not installed. Would you like to install it from the App Store?'
              : 'WhatsApp is not installed. Would you like to install it from the Play Store?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _installWhatsApp();
              },
              child: const Text('Install'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _installWhatsApp() async {
    String storeUrl;

    if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/app/whatsapp-messenger/id310633997';
    } else if (Platform.isAndroid) {
      storeUrl = 'https://play.google.com/store/apps/details?id=com.whatsapp';
    } else {
      storeUrl = 'https://www.whatsapp.com/download';
    }

    await _tryLaunchUrl(storeUrl);
  }

  /// Show error message to user
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
