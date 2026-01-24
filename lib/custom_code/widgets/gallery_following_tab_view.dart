// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/gallery_search_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'index.dart'; // Imports other custom widgets

import 'dart:async';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryFollowingTabViewPage extends StatefulWidget {
  const GalleryFollowingTabViewPage({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<GalleryFollowingTabViewPage> createState() =>
      _GalleryFollowingTabViewPageState();
}

class _GalleryFollowingTabViewPageState
    extends State<GalleryFollowingTabViewPage> {
  List<String> _followingCategories = ['Following'];
  bool _isLoadingCategories = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    // If user is not authenticated, show login prompt
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Please login to see following gallery',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingCategories) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: FollowingPaginatedGalleryTabView(
              categories: _followingCategories,
              tableName: 'gallery_with_comments_view',
              orderByColumn: 'gallery_created_at',
              ascending: false,
              itemsPerPage: 24,
              baseCrossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              currentUserId: user.id,
            ),
          ),
        ],
      ),
    );
  }
}

class FollowingPaginatedGalleryTabView extends StatefulWidget {
  final List<String> categories;
  final String tableName;
  final String orderByColumn;
  final bool ascending;
  final int itemsPerPage;
  final int baseCrossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final String currentUserId;

  const FollowingPaginatedGalleryTabView({
    super.key,
    required this.categories,
    required this.tableName,
    required this.orderByColumn,
    this.ascending = false,
    this.itemsPerPage = 16,
    this.baseCrossAxisCount = 3,
    this.childAspectRatio = 0.6,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    required this.currentUserId,
  });

  @override
  State<FollowingPaginatedGalleryTabView> createState() =>
      _FollowingPaginatedGalleryTabViewState();
}

class _FollowingPaginatedGalleryTabViewState
    extends State<FollowingPaginatedGalleryTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final supabase = Supabase.instance.client;

  // Data variables
  List<Map<String, dynamic>> galleryItems = [];
  bool isLoading = true;
  String? error;
  List<String> _followingUserIds = [];

  // Pagination variables
  final Map<String, int> _currentPageMap = {};
  final Map<String, List<Map<String, dynamic>>> _paginatedItemsMap = {};
  final Map<String, bool> _isLoadingMoreMap = {};
  final Map<String, bool> _hasMoreItemsMap = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.categories.length, vsync: this);
    _initializePaginationMaps();
    _loadFollowingUsersAndFetchData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializePaginationMaps() {
    for (var category in widget.categories) {
      _currentPageMap[category] = 0;
      _paginatedItemsMap[category] = [];
      _isLoadingMoreMap[category] = false;
      _hasMoreItemsMap[category] = false;
    }
  }

  // Calculate crossAxisCount based on available width
  int _calculateCrossAxisCount(double availableWidth) {
    const double minItemWidth = 120.0;
    const double maxItemWidth = 200.0;

    // Account for cross axis spacing
    final totalSpacing =
        widget.crossAxisSpacing * (widget.baseCrossAxisCount - 1);
    final availableForItems = availableWidth - totalSpacing;

    // Calculate based on minimum item width
    int maxPossibleCount = (availableForItems / minItemWidth).floor();

    // Calculate based on maximum item width
    int minRequiredCount = (availableForItems / maxItemWidth).ceil();

    // Ensure we don't go below 1 or above a reasonable maximum
    maxPossibleCount = maxPossibleCount.clamp(1, 6);
    minRequiredCount = minRequiredCount.clamp(1, maxPossibleCount);

    // If screen is very wide, prefer the base count or calculated count
    if (availableWidth > 600) {
      return maxPossibleCount.clamp(widget.baseCrossAxisCount, 6);
    } else if (availableWidth > 400) {
      return maxPossibleCount.clamp(2, 4);
    } else {
      return maxPossibleCount.clamp(1, 3);
    }
  }

  // Get random height for masonry effect
  double _getRandomHeight(int index) {
    final heights = [180.0, 220.0, 200.0, 240.0, 190.0, 210.0, 230.0];
    return heights[index % heights.length];
  }

  Future<void> _loadFollowingUsersAndFetchData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // First, get following user IDs
      final followsResponse = await supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', widget.currentUserId);

      _followingUserIds = followsResponse
          .map<String>((item) => item['followed_id'].toString())
          .toList();

      if (_followingUserIds.isEmpty) {
        setState(() {
          galleryItems = [];
          isLoading = false;
        });
        return;
      }

      // Then fetch gallery data filtered by following users
      await fetchGalleryData();
    } catch (e) {
      print('Error loading following users: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  Future<void> fetchGalleryData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      if (_followingUserIds.isEmpty) {
        setState(() {
          galleryItems = [];
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from(widget.tableName)
          .select()
          .inFilter('user_id', _followingUserIds)
          .order(widget.orderByColumn, ascending: widget.ascending);

      setState(() {
        // Remove duplicates based on gallery ID
        final Map<String, Map<String, dynamic>> uniqueItems = {};

        for (var item in response) {
          final galleryId =
              item['gallery_id']?.toString() ?? item['id']?.toString();
          if (galleryId != null && !uniqueItems.containsKey(galleryId)) {
            uniqueItems[galleryId] = item;
          }
        }

        galleryItems = uniqueItems.values.toList();
        isLoading = false;

        // Initialize paginated items for each category
        for (var category in widget.categories) {
          _loadInitialItemsForCategory(category);
        }
      });
    } catch (e) {
      print('Error fetching gallery data: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  // Filter items by category (for following, we show all)
  List<Map<String, dynamic>> getFilteredItems(String category) {
    // For following tab, show all items from followed users
    return galleryItems;
  }

  // Load initial items (first batch) for a category
  void _loadInitialItemsForCategory(String category) {
    final allItems = getFilteredItems(category);
    final paginatedItems = allItems.take(widget.itemsPerPage).toList();

    _paginatedItemsMap[category] = paginatedItems;
    _hasMoreItemsMap[category] = allItems.length > widget.itemsPerPage;
  }

  // Load more items when user scrolls to the bottom
  Future<void> _loadMoreItems(String category) async {
    if (_isLoadingMoreMap[category] == true ||
        _hasMoreItemsMap[category] == false) {
      return;
    }

    setState(() {
      _isLoadingMoreMap[category] = true;
    });

    // Simulate network delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final allItems = getFilteredItems(category);
    final currentPage = _currentPageMap[category]!;
    final nextPage = currentPage + 1;

    final startIndex = currentPage * widget.itemsPerPage;
    final endIndex = nextPage * widget.itemsPerPage;

    if (startIndex < allItems.length) {
      final newItems =
          allItems.skip(startIndex).take(widget.itemsPerPage).toList();

      setState(() {
        _paginatedItemsMap[category]!.addAll(newItems);
        _currentPageMap[category] = nextPage;
        _hasMoreItemsMap[category] = endIndex < allItems.length;
        _isLoadingMoreMap[category] = false;
      });
    } else {
      setState(() {
        _hasMoreItemsMap[category] = false;
        _isLoadingMoreMap[category] = false;
      });
    }
  }

  Widget _buildCategoryContent(String category) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadFollowingUsersAndFetchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_followingUserIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No following users yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Follow some artists to see their work here',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_paginatedItemsMap[category]?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No posts from following users',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollEndNotification) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                // User has reached the end of the list
                if (_hasMoreItemsMap[category] == true) {
                  _loadMoreItems(category);
                }
              }
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: widget.crossAxisSpacing,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  childCount: _paginatedItemsMap[category]!.length,
                  itemBuilder: (context, index) {
                    final items = _paginatedItemsMap[category]!;
                    final item = items[index];
                    final height = _getRandomHeight(index);

                    // Use advanced card with all parameters
                    return MasonryGalleryItemCard(
                      item: item,
                      allItems: items,
                      initialIndex: index,
                      height: height,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: _isLoadingMoreMap[category] == true
                    ? Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        ),
                      )
                    : _hasMoreItemsMap[category] == false &&
                            _paginatedItemsMap[category]!.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text(
                              'No more items to load',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   color: Colors.black,
        //   child: TabBar(
        //     controller: _tabController,
        //     isScrollable: true,
        //     labelColor: Colors.yellow,
        //     unselectedLabelColor: Colors.grey,
        //     indicatorColor: Colors.yellow,
        //     tabs: widget.categories
        //         .map((category) => Tab(text: category))
        //         .toList(),
        //   ),
        // ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.categories.map((category) {
              return _buildCategoryContent(category);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class MasonryGalleryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final double height;
  final List<Map<String, dynamic>> allItems;
  final int initialIndex;

  const MasonryGalleryItemCard({
    super.key,
    required this.item,
    required this.allItems,
    required this.initialIndex,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GalleryDetailsPage(
                    item: item,
                    allItems: allItems,
                    initialIndex: initialIndex,
                  )),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                item['gallery_image_url'] ?? 'https://via.placeholder.com/200',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[850],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        item['gallery_title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // User info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.grey[700],
                            backgroundImage: item['profile_image_url'] != null
                                ? NetworkImage(item['profile_image_url'])
                                : null,
                            child: item['profile_image_url'] == null
                                ? Icon(Icons.person,
                                    size: 10, color: Colors.grey[400])
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Price
                      if (item['gallery_price'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.orangeAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '₹${item['gallery_price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
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
  }
}
