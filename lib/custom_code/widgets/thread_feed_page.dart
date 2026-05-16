// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:timeago/timeago.dart' as timeago;
import 'ai_prompt_service.dart';

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
  final Color primaryYellow = const Color(0xFFFFD700);
  final Color darkBlack = const Color(0xFFFFFFFF);
  final Color pureWhite = const Color(0xFF121212);
  final Color lightYellow = const Color(0xFF121212);
  final Color mediumYellow = const Color(0xFFFFE666);

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
      final response = await supabase
          .from('thread_likes')
          .select('thread_id')
          .eq('user_id', currentUserId!);

      if (mounted) {
        safeSetState(() {
          likedThreadIds =
              response.map((like) => like['thread_id'] as String).toSet();
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
  void _showComments(String threadId, String threadContent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThreadCommentsPage(
          threadId: threadId,
          threadContent: threadContent,
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
        safeSetState(() {
          threads = List<Map<String, dynamic>>.from(response);
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
                        final String threadId = thread['id'];
                        final bool isLikedByCurrentUser =
                            likedThreadIds.contains(threadId);

                        return ModernCard(
                          cardData: thread,
                          isLiked: isLikedByCurrentUser,
                          onLike: (id) {
                            _likeThread(id);
                          },
                          onComment: (id, content) {
                            _showComments(id, content);
                          },
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
    const Color accentColor = Color(0xFFFFA000); // Deep Yellow/Amber
    const Color backgroundColor = Color(0xFF000000); // True Black
    const Color textColor = Colors.white; // White text for good contrast
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
                            style: const TextStyle(
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
                            color: Colors.black,
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

class _CreateThreadPageState extends State<CreateThreadPage>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  bool _isPolishing = false;
  Map<String, dynamic>? profileData;
  List<Map<String, dynamic>> userThreads = [];
  bool isLoading = true;
  final supabase = SupaFlow.client;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _createThread() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Thread content cannot be empty', Colors.red.shade600);
      return;
    }

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('Please login to create a thread', Colors.red.shade600);
      return;
    }
    final userId = currentUser.id;

    if (_containsObjectionableContent(_contentController.text.trim())) {
      _showContentFilterSnackbar('content');
      return; // Exit early if objectionable content found
    }

    safeSetState(() {
      _isSubmitting = true;
    });

    try {
      await supabase.from('threads').insert({
        'user_id': userId,
        'content': _contentController.text.trim(),
      });

      if (mounted) {
        _showSnackBar('Thread created successfully!', Colors.green.shade600);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          _isSubmitting = false;
        });
        _showSnackBar(
            'Error creating thread: ${e.toString()}', Colors.red.shade600);
      }
    }
  }

  Future<void> _polishThought() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Nothing to polish! Please write something first.', Colors.orange);
      return;
    }

    setState(() => _isPolishing = true);

    try {
      final prompt = '''
      You are a creative writing assistant.
      User's thought: "${_contentController.text.trim()}"
      
      Task: Refine this thought to make it more engaging, clear, and impactful while preserving its original meaning and tone.
      Requirements:
      1. Keep it concise (max 2-3 sentences).
      2. Use a natural, human tone.
      3. Return ONLY the polished text. No conversational filler.
      
      Polished Thought:''';

      final aiService = AIService();
      final response = await aiService.generateText(prompt: prompt);

      if (response.isSuccess && response.data != null) {
        final polished = response.data!.trim();
        // Remove quotes if the AI added them
        String cleaned = polished;
        if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
          cleaned = cleaned.substring(1, cleaned.length - 1);
        }
        
        setState(() {
          _contentController.text = cleaned;
          _isPolishing = false;
        });
        _showSnackBar('Thought polished by AI!', Colors.blueAccent);
      } else {
        setState(() => _isPolishing = false);
        _showSnackBar('AI Polish failed: ${response.error}', Colors.red);
      }
    } catch (e) {
      setState(() => _isPolishing = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _showContentFilterSnackbar(String fieldName) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Content not allowed in $fieldName. Please use appropriate language.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  bool _containsObjectionableContent(String text) {
    // Convert to lowercase for case-insensitive checking
    String lowerText = text.toLowerCase();

    // More targeted list of truly objectionable words
    List<String> objectionableWords = [
      // Strong profanity - keep only the most offensive ones
      'fuck', 'shit', 'bitch', 'dick',
      'motherfucker', 'cock',

      // Hate speech / Discrimination
      'racist', 'terrorist', 'sexist',
      'violence',
      'murder',

      // Sexual content
      'nude', 'naked', 'porn', 'sex', 'xxx', 'boobs', 'penis',
      'orgasm', 'milf', 'blowjob',

      // Drugs & illegal content
      'drug',
      'weed',
      'cocaine',
      'scam',
      'fraud',
    ];

    // Check for exact matches or phrases
    for (String word in objectionableWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }

    // Additional pattern-based checks
    if (_containsSuspiciousPatterns(lowerText)) {
      return true;
    }

    return false;
  }

  bool _containsSuspiciousPatterns(String text) {
    // Check for repeated characters (like "fuuuuck")
    if (RegExp(r'f+u+c+k+|s+h+i+t+|b+i+t+c+h+').hasMatch(text)) {
      return true;
    }

    // Check for l33t speak substitutions
    String leetText = text
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('1', 'i')
        .replaceAll('0', 'o')
        .replaceAll('5', 's')
        .replaceAll('@', 'a')
        .replaceAll('!', 'i');

    List<String> leetWords = ['fuck', 'shit', 'bitch'];
    for (String word in leetWords) {
      if (leetText.contains(word)) {
        return true;
      }
    }

    // Check for excessive caps (might indicate shouting/spam)
    if (text.length > 10) {
      int capsCount = text.replaceAll(RegExp(r'[^A-Z]'), '').length;
      if (capsCount / text.length > 0.7) {
        return true;
      }
    }

    return false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade600,
                Colors.yellow.shade600,
                Colors.amber.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.amber.shade400,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: const Text(
                'Create Thoughts',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.amber.shade400,
                      size: 24,
                    ),
                    onPressed: () {
                      // Add inspiration or tips functionality
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.grey.shade900,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Add space for app bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),

                // Main content
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section with inspiration
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withValues(alpha: 0.1),
                                Colors.yellow.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Colors.amber.shade400,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Share Your Thoughts',
                                          style: TextStyle(
                                            color: Colors.amber.shade400,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Express your thoughts and connect with others',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.yellow
                                        .withValues(alpha: 0.2), // less opacity
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Please avoid using inappropriate words in your thoughts.',
                                          style: TextStyle(
                                            color: Colors.yellow[
                                                800], // slightly darker text for contrast
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
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

                        // Text Input Section
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade900,
                                Colors.grey.shade800,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.amber.shade400,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Write your thoughts',
                                    style: TextStyle(
                                      color: Colors.amber.shade400,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_isPolishing)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.amber,
                                      ),
                                    )
                                  else
                                    TextButton.icon(
                                      onPressed: _isSubmitting ? null : _polishThought,
                                      icon: const Icon(Icons.auto_awesome,
                                          size: 16, color: Colors.amber),
                                      label: const Text(
                                        'AI Polish',
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                constraints:
                                    const BoxConstraints(minHeight: 300),
                                child: TextField(
                                  controller: _contentController,
                                  maxLines: null,
                                  maxLength: 580,
                                  decoration: InputDecoration(
                                    hintText:
                                        'What\'s on your mind? Share your thoughts, ideas, or experiences...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade700,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade700,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.amber.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.black.withValues(alpha: 0.3),
                                    contentPadding: const EdgeInsets.all(20),
                                    counterStyle: TextStyle(
                                      color: Colors.amber.shade400,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.white,
                                  ),
                                  autofocus: true,
                                  cursorColor: Colors.amber.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Media Options Row
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Post Button
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade600,
                                Colors.yellow.shade600,
                                Colors.amber.shade500,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _createThread,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color:
                                            Colors.black.withValues(alpha: 0.8),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Share Your Thoughts',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black
                                              .withValues(alpha: 0.8),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // Bottom spacing for better scrolling
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

class ThreadCommentsPage extends StatefulWidget {
  final String threadId;
  final String threadContent;

  const ThreadCommentsPage({
    super.key,
    required this.threadId,
    required this.threadContent,
  });

  @override
  State<ThreadCommentsPage> createState() => _ThreadCommentsPageState();
}

class _ThreadCommentsPageState extends State<ThreadCommentsPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _threadScrollController =
      ScrollController(); // New scroll controller for thread content
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  final supabase = SupaFlow.client;
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
      final response = await supabase
          .from('thread_comments_view')
          .select()
          .eq('thread_id', widget.threadId)
          .order('created_at');

      if (mounted) {
        safeSetState(() {
          comments = List<Map<String, dynamic>>.from(response);
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

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('Please login to comment');
      return;
    }
    final userId = currentUser.id;

    try {
      await supabase.from('thread_comments').insert({
        'thread_id': widget.threadId,
        'user_id': userId,
        'content': _commentController.text.trim(),
      });

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
        await supabase.from('thread_comments').delete().eq('id', commentId);

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
    final currentUserId = supabase.auth.currentUser?.id;
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
