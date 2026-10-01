// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:timeago/timeago.dart' as timeago;
import 'ai_prompt_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';

class ThreadFeedPage extends StatefulWidget {
  final double? width;
  final double? height;
  const ThreadFeedPage({super.key, this.width, this.height});

  @override
  State<ThreadFeedPage> createState() => _ThreadFeedPageState();
}

class _ThreadFeedPageState extends State<ThreadFeedPage> {
  List<Map<String, dynamic>> threads = [];
  Set<String> likedThreadIds = {}; // Track liked threads locally
  bool isLoading = true;
  String? currentUserId;
  final supabase = SupaFlow.client;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  // Define our color scheme
  Color get primaryYellow => const Color(0xFFFFD700);
  Color get darkBlack => FlutterFlowTheme.of(context).primaryText;
  Color get pureWhite => FlutterFlowTheme.of(context).secondaryBackground;
  Color get lightYellow => FlutterFlowTheme.of(context).primaryBackground;
  Color get mediumYellow => const Color(0xFFFFE666);

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _scrollController.addListener(_onScroll);
    _fetchThreads();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

// Scroll listener for lazy loading

  Future<void> _getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        currentUserId = user.id;
      });
      await _fetchUserLikes(); // Load user's likes
    } else {
      _showLoginDialog();
    }
  }

  // Fetch which threads the current user has liked
  Future<void> _fetchUserLikes() async {
    if (currentUserId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final robotLiked = prefs.getStringList('robot_liked_threads_${currentUserId}') ?? [];
      final Set<String> likes = Set<String>.from(robotLiked);

      final response = await supabase
          .from('thread_likes')
          .select('thread_id')
          .eq('user_id', currentUserId!);

      likes.addAll(response.map((like) => like['thread_id'] as String));

      if (mounted) {
        safeSetState(() {
          likedThreadIds = likes;
        });
      }
    } catch (e) {
      print('Error fetching user likes: $e');
    }
  }

  Future<void> _showLoginDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryYellow, width: 3),
        ),
        title: Text(
          'Login',
          style: TextStyle(
            color: darkBlack,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: darkBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryYellow, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: darkBlack, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: lightYellow,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: darkBlack),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryYellow, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: darkBlack, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: lightYellow,
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  try {
                    final response = await supabase.auth.signInWithPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      safeSetState(() {
                        currentUserId = response.user?.id;
                      });

                      // Optional: Add or update user in `users` table
                      final user = response.user;
                      if (user != null) {
                        final userData = {
                          'email': user.email,
                        };

                        // Upsert ensures it inserts if not existing, or updates if existing
                        await supabase.from('users').upsert(userData);
                      }

                      await _fetchUserLikes();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: darkBlack,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: primaryYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Login',
                  style:
                      TextStyle(color: darkBlack, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  safeSetState(() {
                    currentUserId = 'sample-id';
                  });
                  Navigator.pop(context);
                  _fetchUserLikes();
                },
                style: TextButton.styleFrom(
                  backgroundColor: darkBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Use Demo',
                  style: TextStyle(
                      color: primaryYellow, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Future<void> _fetchThreads() async {
  //   safeSetState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     final response = await supabase
  //         .from('threads_view')
  //         .select()
  //         .order('created_at', ascending: false);

  //     if (mounted) {
  //       safeSetState(() {
  //         threads = List<Map<String, dynamic>>.from(response);
  //         isLoading = false;
  //       });

  //       // Fetch user likes after threads are loaded
  //       if (currentUserId != null) {
  //         await _fetchUserLikes();
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       safeSetState(() {
  //         isLoading = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error fetching threads: ${e.toString()}'),
  //           backgroundColor: darkBlack,
  //         ),
  //       );
  //     }
  //   }
  // }

  // OPTIMIZED: Update only the specific thread's like data without rebuilding ListView
  Future<void> _likeThread(String threadId) async {
    if (currentUserId == null) return;

    final threadIndex =
        threads.indexWhere((thread) => thread['id'] == threadId);
    if (threadIndex == -1) return;

    // Current state
    final bool currentlyLiked = likedThreadIds.contains(threadId);
    final int currentLikeCount = threads[threadIndex]['like_count'] ?? 0;

    // Optimistically update UI first for immediate feedback
    safeSetState(() {
      if (currentlyLiked) {
        likedThreadIds.remove(threadId);
        threads[threadIndex]['like_count'] = currentLikeCount - 1;
      } else {
        likedThreadIds.add(threadId);
        threads[threadIndex]['like_count'] = currentLikeCount + 1;
      }
    });

    if (threadId.contains('robot')) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final likedList = likedThreadIds.where((id) => id.contains('robot')).toList();
        await prefs.setStringList('robot_liked_threads_${currentUserId}', likedList);
      } catch (_) {}
      return;
    }

    try {
      // Check current state in database first
      final existingLike = await supabase
          .from('thread_likes')
          .select('id')
          .eq('thread_id', threadId)
          .eq('user_id', currentUserId!)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike: Remove the like (regardless of UI state)
        await supabase
            .from('thread_likes')
            .delete()
            .eq('id', existingLike['id']);

        // Ensure UI reflects unliked state
        if (mounted) {
          safeSetState(() {
            likedThreadIds.remove(threadId);
          });
        }
      } else {
        // Like: Add the like (regardless of UI state)
        await supabase.from('thread_likes').insert({
          'thread_id': threadId,
          'user_id': currentUserId,
        });

        // Ensure UI reflects liked state
        if (mounted) {
          safeSetState(() {
            likedThreadIds.add(threadId);
          });
        }
      }

      // Get updated like count from server to ensure accuracy
      final updatedThread = await supabase
          .from('threads_view')
          .select('like_count')
          .eq('id', threadId)
          .single();

      // Update with server data
      if (mounted) {
        safeSetState(() {
          threads[threadIndex]['like_count'] = updatedThread['like_count'];
        });
      }
    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        safeSetState(() {
          if (currentlyLiked) {
            likedThreadIds.add(threadId);
            threads[threadIndex]['like_count'] = currentLikeCount;
          } else {
            likedThreadIds.remove(threadId);
            threads[threadIndex]['like_count'] = currentLikeCount;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking thread: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Like error: $e');
      }
    }
  }

  // OPTIMIZED: Update comment count without rebuilding ListView
  void _showComments(String threadId, String threadContent, [Map<String, dynamic>? threadData]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadCommentsPage(
          threadId: threadId,
          threadContent: threadContent,
          threadData: threadData,
        ),
      ),
    ).then((result) {
      // Only update comment count for the specific thread
      if (result != null && result is Map<String, dynamic>) {
        final newCommentCount = result['commentCount'] as int?;
        if (newCommentCount != null) {
          _updateCommentCount(threadId, newCommentCount);
        }
      } else {
        // Fallback: fetch only the comment count for this specific thread
        _updateSingleThreadCommentCount(threadId);
      }
    });
  }

  // Helper method to update comment count for a specific thread
  void _updateCommentCount(String threadId, int newCommentCount) {
    final threadIndex =
        threads.indexWhere((thread) => thread['id'] == threadId);
    if (threadIndex != -1 && mounted) {
      safeSetState(() {
        threads[threadIndex]['comment_count'] = newCommentCount;
      });
    }
  }

  // Helper method to fetch and update comment count for a single thread
  Future<void> _updateSingleThreadCommentCount(String threadId) async {
    try {
      final updatedThread = await supabase
          .from('threads_view')
          .select('comment_count')
          .eq('id', threadId)
          .single();

      final threadIndex =
          threads.indexWhere((thread) => thread['id'] == threadId);
      if (threadIndex != -1 && mounted) {
        safeSetState(() {
          threads[threadIndex]['comment_count'] =
              updatedThread['comment_count'];
        });
      }
    } catch (e) {
      print('Error updating comment count: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreThreads();
      }
    }
  }

// Updated _fetchThreads method for initial load
  Future<void> _fetchThreads() async {
    safeSetState(() {
      isLoading = true;
      _currentPage = 0;
      _hasMoreData = true;
    });

    try {
      final response = await supabase
          .from('threads_view')
          .select()
          .order('created_at', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      if (mounted) {
        final List<Map<String, dynamic>> combined = List<Map<String, dynamic>>.from(response);
        // Interleave educational thoughts from active Pocket Robots
        final roboThoughts = PocketRobotService.getRobotThreads('robot_citadel_1_0');
        if (roboThoughts.isNotEmpty) {
          combined.insert(0, roboThoughts.first);
          if (roboThoughts.length > 1 && combined.length > 3) {
            combined.insert(3, roboThoughts[1]);
          }
        }

        safeSetState(() {
          threads = combined;
          isLoading = false;
          _hasMoreData = response.length == _pageSize;
          _currentPage = 1;
        });

        // Fetch user likes after threads are loaded
        if (currentUserId != null) {
          await _fetchUserLikes();
        }
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching threads: ${e.toString()}'),
            backgroundColor: darkBlack,
          ),
        );
      }
    }
  }

// New method for loading more threads
  Future<void> _loadMoreThreads() async {
    if (_isLoadingMore || !_hasMoreData) return;

    safeSetState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await supabase
          .from('threads_view')
          .select()
          .order('created_at', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      if (mounted) {
        safeSetState(() {
          threads.addAll(List<Map<String, dynamic>>.from(response));
          _isLoadingMore = false;
          _hasMoreData = response.length == _pageSize;
          _currentPage++;
        });

        // Fetch user likes for new threads
        if (currentUserId != null) {
          await _fetchUserLikes();
        }
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more threads: ${e.toString()}'),
            backgroundColor: darkBlack,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Thoughts',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryYellow),
                backgroundColor: darkBlack,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchThreads();
                if (currentUserId != null) {
                  await _fetchUserLikes();
                }
              },
              color: primaryYellow,
              backgroundColor: darkBlack,
              child: threads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mode_comment_outlined,
                              size: 64, color: darkBlack),
                          const SizedBox(height: 16),
                          Text(
                            'No threads yet',
                            style: TextStyle(
                              color: darkBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to create a thread!',
                            style: TextStyle(
                              color: darkBlack,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      cacheExtent: 400,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: threads.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index == threads.length) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: _isLoadingMore
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                          );
                        }

                        final thread = threads[index];
                        final String threadId = thread['id']?.toString() ?? '$index';
                        final bool isLikedByCurrentUser =
                            likedThreadIds.contains(threadId);

                        return RepaintBoundary(
                          key: ValueKey('thread_card_$threadId'),
                          child: ModernCard(
                            cardData: thread,
                            isLiked: isLikedByCurrentUser,
                            onLike: (id) {
                              _likeThread(id);
                            },
                            onComment: (id, content) {
                              _showComments(id, content, thread);
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isAuthenticated = await AuthAlertBox.checkAuthAndShowAlert(
            context: context,
            customMessage: "Please login to create a thought",
          );
          if (isAuthenticated && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateThreadPage(
                        userId: currentUserId ?? '',
                      )),
            ).then((_) => _fetchThreads());
          }
        },
        backgroundColor: primaryYellow,
        foregroundColor: darkBlack,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryYellow, width: 2),
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ModernCard extends StatelessWidget {
  final Map<String, dynamic> cardData;
  final Function(String) onLike;
  final Function(String, String) onComment;
  final bool isLiked;

  const ModernCard({
    super.key,
    required this.cardData,
    required this.onLike,
    required this.onComment,
    this.isLiked = false,
  });
  Future<void> _shareContent(
      BuildContext context, Map<String, dynamic> cardData) async {
    final String content = cardData['content'] ?? 'No content available';
    final String postId = cardData['id']?.toString() ?? '';

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShareContentScreen(
            contentToShare: content,
            currentUserId: SupaFlow.client.auth.currentUser?.id ?? '',
            contentId: postId,
            contentType: 'thought',
            metadata: cardData,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to share screen: $e');
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      double millions = count / 1000000;
      return '${millions == millions.truncateToDouble() ? millions.toInt() : millions.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      double thousands = count / 1000;
      return '${thousands == thousands.truncateToDouble() ? thousands.toInt() : thousands.toStringAsFixed(1)}k';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color primaryColor = Color(0xFFFFD700); // Bright Yellow (Gold tone)
    const Color accentColor = Color(0xFFFFFC00); // Deep Yellow/Amber
    final Color backgroundColor = FlutterFlowTheme.of(context).secondaryBackground;
    final Color textColor = FlutterFlowTheme.of(context).primaryText;
    // const Color lightGrey =
    //     Color(0xFF1A1A1A); // Dark Grey for subtle backgrounds

    // Format date
    final DateTime createdDate =
        DateTime.parse(cardData['created_at'] ?? DateTime.now().toString());
    final String formattedDate = DateFormat('MMM d, y').format(createdDate);

    // Get initials if no image
    String initials = 'U';
    if (cardData['name'] != null &&
        cardData['name'].toString().trim().isNotEmpty) {
      initials = cardData['name'].toString().trim()[0].toUpperCase();
    }
    final int likeCount = cardData['like_count'] ?? 0;
    final int fakeLikes = cardData['fake_likes'] ?? 0;
    final int totalLikes = likeCount + fakeLikes;
    final String formattedLikes = _formatCount(totalLikes);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ModernDetailPage(
              //       cardData: cardData,
              //       onLike: onLike,
              //       onComment: onComment,
              //       isLiked: isLiked,
              //     ),
              //   ),
              // );
              // context.pushNamed(
              //   DemohomeWidget.routeName,
              //   extra: {
              //     'cardData': cardData,
              //     'onLike': onLike,
              //     'onComment': onComment,
              //     'isLiked': isLiked,
              //   },
              // );
            },
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.1),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content with quote styling
                        Container(
                          padding: const EdgeInsets.only(
                              top: 14, bottom: 8, left: 8, right: 8),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '"${cardData['content'] ?? 'No content available'}"',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),

                  // Interaction section with gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.05),
                          accentColor.withValues(alpha: 0.05)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Like button with animated effect
                          InkWell(
                            onTap: () async {
                              final isAuthenticated =
                                  await AuthAlertBox.checkAuthAndShowAlert(
                                context: context,
                                customMessage: "Please login to continue",
                              );
                              if (isAuthenticated) {
                                onLike(cardData['id']);
                              }
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked
                                        ? accentColor
                                        : textColor.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedLikes,
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Divider
                          Container(
                            height: 8,
                            width: 1,
                            color: Colors.black12,
                          ),

                          // Comment button
                          InkWell(
                            onTap: () async {
                              final isAuthenticated =
                                  await AuthAlertBox.checkAuthAndShowAlert(
                                context: context,
                                customMessage: "Please login to continue",
                              );
                              if (isAuthenticated) {
                                onComment(cardData['id'], cardData['content']);
                              }
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: textColor.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${cardData['comment_count'] ?? 0}',
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _shareContent(context, cardData),
                            borderRadius: BorderRadius.circular(50),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Icon(
                                Icons.share_outlined,
                                // ignore: deprecated_member_use
                                color: textColor.withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ),
                          ),
                          ReportButton(
                            contentType: 'thought',
                            contentId: cardData['id'].toString(),
                            contentTitle: cardData['content'] ?? 'Thought',
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating user info
          Positioned(
            top: -15,
            left: 10,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VerfiedSwitchPage(userId: cardData['user_id'] ?? ''),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: cardData['profile_image_url'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                cardData['profile_image_url'],
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    // Name and date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardData['name'] ?? 'Anonymous',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Accent corner decoration
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.article_outlined,
                  color: Colors.black,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateThreadPage extends StatefulWidget {
  final String? userId;
  const CreateThreadPage({super.key, this.userId});

  @override
  State<CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _isPolishing = false;
  final supabase = SupaFlow.client;

  String _authorName = 'You';
  String? _authorAvatarUrl;
  int _authorStage = 1;
  String? _authorTalisman;

  final List<Map<String, String>> _promptStarters = [
    {
      'label': '💡 Reflection',
      'starter': 'Today\'s English insight: ',
    },
    {
      'label': '📚 New Vocab',
      'starter': 'A powerful word I learned today is "',
    },
    {
      'label': '🎯 Goal',
      'starter': 'My speaking goal for this week is: ',
    },
    {
      'label': '🥊 Daily Win',
      'starter': 'Proud of my practice streak today because ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onTextChanged);
    _loadUserProfile();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final uid = widget.userId ?? supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final profile = await supabase
          .from('profile')
          .select('name, profile_image_url, pocket_score, xp, stage, equipped_talisman, talisman_id')
          .eq('user_id', uid)
          .maybeSingle();

      if (profile != null && mounted) {
        final score = (profile['pocket_score'] as num?)?.toInt() ?? 0;
        final stage = PocketScoreLevelEngine.getLevelFromScore(score);
        setState(() {
          _authorName = profile['name']?.toString() ?? 'You';
          _authorAvatarUrl = profile['profile_image_url']?.toString();
          _authorStage = stage.clamp(1, 90);
          _authorTalisman = profile['equipped_talisman']?.toString() ?? profile['talisman_id']?.toString();
        });
      }
    } catch (_) {}
  }

  Future<void> _createThread() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('Please login to share your thought', Colors.redAccent);
      return;
    }
    final userId = currentUser.id;

    if (_containsObjectionableContent(text)) {
      _showSnackBar('Please avoid using inappropriate language.', Colors.orangeAccent);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final inserted = await supabase.from('threads').insert({
        'user_id': userId,
        'content': text,
      }).select().maybeSingle();

      // Simulated robot classmate peer interactions (likes / cheers)
      if (inserted != null && inserted['id'] != null) {
        final threadId = inserted['id'].toString();
        Future.delayed(const Duration(seconds: 4), () async {
          try {
            await supabase.from('threads').update({
              'fake_likes': 3,
            }).eq('id', threadId);
          } catch (_) {}
        });
      }

      if (mounted) {
        _showSnackBar('Thought shared successfully! ✨', const Color(0xFF22C55E));
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.pop(context, inserted ?? {'content': text, 'user_id': userId});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackBar('Error creating thought: ${e.toString()}', Colors.redAccent);
      }
    }
  }

  Future<void> _polishThought() async {
    final currentText = _contentController.text.trim();
    if (currentText.isEmpty) {
      _showSnackBar('Write your thought first, then tap polish! ✍️', Colors.amber);
      return;
    }

    setState(() => _isPolishing = true);
    HapticFeedback.lightImpact();

    try {
      final prompt = '''
You are a helpful language mentor.
User thought: "$currentText"

Task: Polish and refine this thought into clean, engaging, natural English while keeping the exact same personal meaning and emotion.
Requirements:
1. Keep it concise (1 to 3 sentences maximum).
2. Human, inspiring, and expressive.
3. Return ONLY the polished text without quotes or meta-commentary.
''';

      final aiService = AIService();
      final response = await aiService.generateText(prompt: prompt);

      if (response.isSuccess && response.data != null) {
        var polished = response.data!.trim();
        if (polished.startsWith('"') && polished.endsWith('"')) {
          polished = polished.substring(1, polished.length - 1);
        }
        setState(() {
          _contentController.text = polished;
          _contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: polished.length),
          );
          _isPolishing = false;
        });
        _showSnackBar('Polished by AI! ✨', const Color(0xFF38BDF8));
      } else {
        setState(() => _isPolishing = false);
        _showSnackBar('Could not polish right now: ${response.error}', Colors.orange);
      }
    } catch (e) {
      setState(() => _isPolishing = false);
      _showSnackBar('AI Polish error: $e', Colors.redAccent);
    }
  }

  bool _containsObjectionableContent(String text) {
    final lower = text.toLowerCase();
    const badWords = [
      'fuck', 'shit', 'bitch', 'dick', 'motherfucker', 'cock',
      'racist', 'terrorist', 'sexist', 'violence', 'murder',
      'nude', 'naked', 'porn', 'xxx', 'drug', 'cocaine', 'scam',
    ];
    for (final word in badWords) {
      if (lower.contains(word)) return true;
    }
    return false;
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasText = _contentController.text.trim().isNotEmpty;
    final charCount = _contentController.text.length;
    const maxChars = 500;

    final avatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(
      _authorStage,
      talismanId: _authorTalisman,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1017) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0C1017) : const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white70 : Colors.black87,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Thought',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: (_isSubmitting || !hasText) ? null : _createThread,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                disabledBackgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.08),
                foregroundColor: Colors.black,
                disabledForegroundColor: isDark ? Colors.white30 : Colors.black26,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: ClipOval(
                            child: VectorAvatarWidget(
                              config: avatarConfig,
                              size: 38,
                              showAura: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _authorName,
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.public, size: 11, color: isDark ? Colors.white60 : Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Public',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Stage $_authorStage',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFFFC00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Expanding Text Field
                    TextField(
                      controller: _contentController,
                      focusNode: _focusNode,
                      maxLines: null,
                      maxLength: maxChars,
                      autofocus: true,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16.5,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: const Color(0xFFFFFC00),
                      decoration: InputDecoration(
                        hintText: "What's on your mind? Share your thought or question...",
                        hintStyle: GoogleFonts.inter(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Starter Chips
            Container(
              height: 34,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _promptStarters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final item = _promptStarters[idx];
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (_contentController.text.trim().isEmpty) {
                        _contentController.text = item['starter']!;
                        _contentController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _contentController.text.length),
                        );
                      } else {
                        _contentController.text = '${_contentController.text}\n\n${item['starter']}';
                        _contentController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _contentController.text.length),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161F2E) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item['label']!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Minimal Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F141E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // AI Polish Button
                  InkWell(
                    onTap: _isPolishing ? null : _polishThought,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isPolishing)
                            const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFFC00),
                              ),
                            )
                          else
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: Color(0xFFFFFC00),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            _isPolishing ? 'Polishing...' : 'AI Polish',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFC00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Character Count
                  Text(
                    '$charCount / $maxChars',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: charCount > maxChars - 30
                          ? Colors.redAccent
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThreadCommentsPage extends StatefulWidget {
  final String threadId;
  final String threadContent;
  final Map<String, dynamic>? threadData;

  const ThreadCommentsPage({
    super.key,
    required this.threadId,
    required this.threadContent,
    this.threadData,
  });

  @override
  State<ThreadCommentsPage> createState() => _ThreadCommentsPageState();
}

class _ThreadCommentsPageState extends State<ThreadCommentsPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  final supabase = SupaFlow.client;
  bool isPosting = false;
  bool _hasCommentText = false;
  Map<String, dynamic>? _threadDetail;
  String? _currentUserAvatarUrl;
  String? _currentUserName;
  final Set<String> _likedCommentIds = {};
  final Map<String, int> _commentLikesCount = {};

  @override
  void initState() {
    super.initState();
    if (widget.threadData != null) {
      _threadDetail = Map<String, dynamic>.from(widget.threadData!);
    }
    _commentController.addListener(() {
      final has = _commentController.text.trim().isNotEmpty;
      if (has != _hasCommentText) {
        safeSetState(() => _hasCommentText = has);
      }
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) {
      try {
        final p = await supabase
            .from('profile')
            .select('name, profile_image_url')
            .eq('user_id', uid)
            .maybeSingle();
        if (p != null && mounted) {
          setState(() {
            _currentUserName = p['name'];
            _currentUserAvatarUrl = p['profile_image_url'];
          });
        }
      } catch (_) {}
    }

    if (_threadDetail == null) {
      try {
        final t = await supabase
            .from('threads_view')
            .select()
            .eq('id', widget.threadId)
            .maybeSingle();
        if (t != null && mounted) {
          setState(() => _threadDetail = Map<String, dynamic>.from(t));
        }
      } catch (_) {}
    }

    await _fetchComments();
  }

  Future<void> _fetchComments() async {
    safeSetState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedComments = [];
      if (!widget.threadId.contains('robot')) {
        final response = await supabase
            .from('thread_comments_view')
            .select()
            .eq('thread_id', widget.threadId)
            .order('created_at');
        fetchedComments = List<Map<String, dynamic>>.from(response);

        // If there are few comments on human thought, add a polite robot study peer reflection
        if (fetchedComments.length <= 1) {
          final authorUserId = _threadDetail?['user_id']?.toString() ?? '';
          final stageNum = (_threadDetail?['stage'] as num?)?.toInt() ?? 8;
          final robot = PocketRobotService.getRobotByLevel(math.max(1, stageNum));
          final dynLvl = PocketRobotService.getDynamicLevel(robot);
          fetchedComments.add({
            'id': 'robot_peer_${widget.threadId}_0',
            'thread_id': widget.threadId,
            'user_id': robot.id,
            'content': 'Great reflection! Daily consistency in thinking in English is the fastest route to fluency. Keep it up! 🌟💪',
            'created_at': DateTime.now().subtract(const Duration(minutes: 12)).toIso8601String(),
            'name': robot.name,
            'profile_image_url': robot.avatarUrl,
            'is_robot': true,
            'level': dynLvl,
            'has_trophy': dynLvl == 90,
          });
        }
      } else {
        fetchedComments =
            PocketRobotService.getRobotThreadComments(widget.threadId);
      }

      // Merge any locally posted comments for this thread
      final prefs = await SharedPreferences.getInstance();
      final localRaw =
          prefs.getString('local_thread_comments_${widget.threadId}');
      if (localRaw != null && localRaw.isNotEmpty) {
        try {
          final localList =
              List<Map<String, dynamic>>.from(jsonDecode(localRaw));
          fetchedComments.addAll(localList);
        } catch (_) {}
      }

      if (mounted) {
        safeSetState(() {
          comments = fetchedComments;
          isLoading = false;
        });
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
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    safeSetState(() {
      isPosting = true;
    });

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('Please login to comment');
      return;
    }
    final userId = currentUser.id;

    try {
      if (widget.threadId.contains('robot')) {
        final prefs = await SharedPreferences.getInstance();
        final localKey = 'local_thread_comments_${widget.threadId}';
        final localRaw = prefs.getString(localKey);
        List<Map<String, dynamic>> localList = [];
        if (localRaw != null && localRaw.isNotEmpty) {
          try {
            localList = List<Map<String, dynamic>>.from(jsonDecode(localRaw));
          } catch (_) {}
        }
        final profileRes = await supabase
            .from('profile')
            .select('name, profile_image_url')
            .eq('user_id', userId)
            .maybeSingle();

        localList.add({
          'id': 'local_cmt_${DateTime.now().millisecondsSinceEpoch}',
          'thread_id': widget.threadId,
          'user_id': userId,
          'content': text,
          'created_at': DateTime.now().toIso8601String(),
          'name': profileRes?['name'] ?? 'You',
          'profile_image_url': profileRes?['profile_image_url'],
          'is_robot': false,
        });
        await prefs.setString(localKey, jsonEncode(localList));

        _commentController.clear();
        await _fetchComments();

        // 🤖 Autonomous robot author reply back to human comment!
        Future.delayed(const Duration(milliseconds: 1500), () async {
          if (!mounted) return;
          try {
            final authorRobotId = _threadDetail?['user_id']?.toString() ?? 'pocket_robot_lvl_5';
            final robot = PocketRobotService.getRobotById(authorRobotId) ?? PocketRobotService.getRobotByLevel(5);
            final dynLvl = PocketRobotService.getDynamicLevel(robot);

            final replies = [
              'Thanks for your thoughtful comment! Love having you participate! 🌟',
              'Awesome perspective! Try making your own sentence with this today! 🥊',
              'Spot on! Daily reflections and discussions like this really sharpen fluency! 🚀',
              'Great point! Keep practicing and sharing your thoughts! 📖✨',
            ];
            final replyText = replies[DateTime.now().second % replies.length];

            final p = await SharedPreferences.getInstance();
            final lRaw = p.getString(localKey);
            List<Map<String, dynamic>> updated = [];
            if (lRaw != null) {
              updated = List<Map<String, dynamic>>.from(jsonDecode(lRaw));
            }
            updated.add({
              'id': 'robot_reply_${DateTime.now().millisecondsSinceEpoch}',
              'thread_id': widget.threadId,
              'user_id': robot.id,
              'content': replyText,
              'created_at': DateTime.now().toIso8601String(),
              'name': robot.name,
              'profile_image_url': robot.avatarUrl,
              'is_robot': true,
              'level': dynLvl,
              'has_trophy': dynLvl == 90,
            });
            await p.setString(localKey, jsonEncode(updated));
            if (mounted) await _fetchComments();
          } catch (_) {}
        });
      } else {
        await supabase.from('thread_comments').insert({
          'thread_id': widget.threadId,
          'user_id': userId,
          'content': text,
        });

        _commentController.clear();
        await _fetchComments();
      }

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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Reply',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this reply?',
            style: GoogleFonts.inter(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await supabase.from('thread_comments').delete().eq('id', commentId);
        safeSetState(() {
          comments.removeAt(index);
        });
        _showSuccessSnackBar('Reply deleted');
      } catch (e) {
        _showErrorSnackBar('Error deleting reply: ${e.toString()}');
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
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildParentThread(bool isDark) {
    final authorName = _threadDetail?['name'] ?? _threadDetail?['author_name'] ?? 'Author';
    final authorUserId = _threadDetail?['user_id']?.toString() ?? _threadDetail?['author_id']?.toString() ?? '';
    final isAuthorRobot = PocketRobotService.isRobotId(authorUserId);
    final timeStr = _threadDetail?['created_at']?.toString();
    final timeFormatted = timeStr != null
        ? timeago.format(DateTime.tryParse(timeStr) ?? DateTime.now())
        : '';
    final isVerified = _threadDetail?['verified'] == true || _threadDetail?['is_verified'] == true;
    final day = (_threadDetail?['learning_day'] as num?)?.toInt() ?? 1;
    final mediaUrl = _threadDetail?['media_url']?.toString();

    VectorAvatarConfig authorAvatarConfig;
    if (isAuthorRobot) {
      final robot = PocketRobotService.getRobotById(authorUserId) ?? PocketRobotService.getRobotByLevel(1);
      authorAvatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(PocketRobotService.getDynamicLevel(robot));
    } else {
      final score = (_threadDetail?['pocket_score'] as num?)?.toInt() ?? 0;
      final stage = PocketScoreLevelEngine.getLevelFromScore(score);
      final talisman = _threadDetail?['equipped_talisman']?.toString() ?? _threadDetail?['talisman_id']?.toString();
      authorAvatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(stage.clamp(1, 90), talismanId: talisman);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Avatar with continuous line connector below it
              Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (authorUserId.isNotEmpty) {
                        PocketCitadelAttackPage.openForUser(context, userId: authorUserId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isAuthorRobot
                              ? const Color(0xFFFFB300)
                              : const Color(0xFFFFFC00).withValues(alpha: 0.35),
                          width: isAuthorRobot ? 1.8 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: VectorAvatarWidget(
                          config: authorAvatarConfig,
                          size: 38,
                          showAura: isAuthorRobot,
                        ),
                      ),
                    ),
                  ),
                  if (comments.isNotEmpty)
                    Container(
                      width: 2,
                      height: 24,
                      margin: const EdgeInsets.only(top: 8),
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (authorUserId.isNotEmpty) {
                                PocketCitadelAttackPage.openForUser(context, userId: authorUserId);
                              }
                            },
                            child: Text(
                              authorName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF3897F0)),
                        ],
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'D$day',
                            style: const TextStyle(
                              color: Color(0xFFFFFC00),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (timeFormatted.isNotEmpty)
                          Text(
                            timeFormatted,
                            style: GoogleFonts.inter(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.threadContent,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white.withValues(alpha: 0.95) : Colors.black87,
                        fontSize: 15.5,
                        height: 1.45,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: mediaUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: isDark ? Colors.white10 : Colors.black12,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFC00)),
                            ),
                          ),
                          errorWidget: (context, url, error) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              thickness: 0.6,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, int index, bool isDark) {
    final currentUserId = supabase.auth.currentUser?.id;
    final isOwner = comment['user_id'] == currentUserId;
    final authorName = comment['name'] ?? 'User';
    final commentUserId = comment['user_id']?.toString() ?? '';
    final isCommentRobot = PocketRobotService.isRobotId(commentUserId);
    final timeStr = comment['created_at']?.toString();
    final timeFormatted = timeStr != null
        ? timeago.format(DateTime.tryParse(timeStr) ?? DateTime.now(), locale: 'en_short')
        : '';
    final commentId = comment['id']?.toString() ?? '$index';
    final isLiked = _likedCommentIds.contains(commentId);
    final likesCount = _commentLikesCount[commentId] ?? (comment['likes_count'] as num?)?.toInt() ?? 0;
    final isLast = index == comments.length - 1;

    VectorAvatarConfig commentAvatarConfig;
    if (isCommentRobot) {
      final robot = PocketRobotService.getRobotById(commentUserId) ?? PocketRobotService.getRobotByLevel(1);
      commentAvatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(PocketRobotService.getDynamicLevel(robot));
    } else {
      final score = (comment['pocket_score'] as num?)?.toInt() ?? 0;
      final stage = PocketScoreLevelEngine.getLevelFromScore(score);
      final talisman = comment['equipped_talisman']?.toString() ?? comment['talisman_id']?.toString();
      commentAvatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(stage.clamp(1, 90), talismanId: talisman);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Avatar + Continuous Connecting Thread Line
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (commentUserId.isNotEmpty) {
                        PocketCitadelAttackPage.openForUser(context, userId: commentUserId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCommentRobot
                              ? const Color(0xFFFFB300)
                              : const Color(0xFFFFFC00).withValues(alpha: 0.35),
                          width: isCommentRobot ? 1.6 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: VectorAvatarWidget(
                          config: commentAvatarConfig,
                          size: 34,
                          showAura: isCommentRobot,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.6,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Right Column: Comment header, text, action bar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (commentUserId.isNotEmpty) {
                                PocketCitadelAttackPage.openForUser(context, userId: commentUserId);
                              }
                            },
                            child: Text(
                              authorName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (timeFormatted.isNotEmpty) ...[
                          Text(
                            ' · $timeFormatted',
                            style: GoogleFonts.inter(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (isOwner)
                          InkWell(
                            onTap: () => _deleteComment(comment['id']?.toString() ?? '', index),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ),
                        ReportButton(
                          contentType: 'comment',
                          contentId: '${comment['id']}',
                          contentTitle: authorName,
                          onReportSubmitted: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for your report. We\'ll review it soon.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment['content']?.toString() ?? '',
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Micro-interactions row: Like, Reply, Share (Twitter / Threads style)
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              if (isLiked) {
                                _likedCommentIds.remove(commentId);
                                _commentLikesCount[commentId] = math.max(0, likesCount - 1);
                              } else {
                                _likedCommentIds.add(commentId);
                                _commentLikesCount[commentId] = likesCount + 1;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isLiked ? Colors.redAccent : (isDark ? Colors.white38 : Colors.black38),
                                ),
                                if (likesCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '$likesCount',
                                    style: TextStyle(
                                      color: isLiked ? Colors.redAccent : (isDark ? Colors.white54 : Colors.black54),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _commentController.text = '@$authorName ';
                            _commentController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _commentController.text.length),
                            );
                            _commentFocusNode.requestFocus();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 15,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reply',
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShareContentScreen(
                                    contentToShare: comment['content']?.toString() ?? '',
                                    currentUserId: supabase.auth.currentUser?.id ?? '',
                                    contentId: commentId,
                                    contentType: 'thought_comment',
                                    metadata: comment,
                                  ),
                                ),
                              );
                            } catch (_) {}
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Icon(
                              Icons.share_outlined,
                              size: 15,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInputBar(bool isDark) {
    final authorName = _threadDetail?['name'] ?? 'author';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D14) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
              backgroundImage: (_currentUserAvatarUrl != null && _currentUserAvatarUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(_currentUserAvatarUrl!)
                  : null,
              child: (_currentUserAvatarUrl == null || _currentUserAvatarUrl!.isEmpty)
                  ? Text(
                      (_currentUserName != null && _currentUserName!.isNotEmpty)
                          ? _currentUserName![0].toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                        color: Color(0xFFFFFC00),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161E28) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 0.6,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Reply to $authorName...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _hasCommentText
                    ? const Color(0xFFFFD700)
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: (isPosting || !_hasCommentText) ? null : _postComment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: isPosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Reply',
                            style: GoogleFonts.outfit(
                              color: _hasCommentText
                                  ? Colors.black
                                  : (isDark ? Colors.white30 : Colors.black26),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070A0F) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF070A0F) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context, {'commentCount': comments.length}),
        ),
        title: Text(
          'Thread',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.6),
          child: Divider(
            height: 0.6,
            thickness: 0.6,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFFC00),
                      strokeWidth: 2.5,
                    ),
                  )
                : CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildParentThread(isDark),
                      ),
                      if (comments.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 42,
                                    color: isDark ? Colors.white24 : Colors.black26,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No replies yet',
                                    style: GoogleFonts.outfit(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Be the first to reply to this thought!',
                                    style: GoogleFonts.inter(
                                      color: isDark ? Colors.white38 : Colors.black38,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildCommentItem(comments[index], index, isDark);
                            },
                            childCount: comments.length,
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
          ),
          _buildBottomInputBar(isDark),
        ],
      ),
    );
  }
}


