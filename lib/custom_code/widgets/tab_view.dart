import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pocket_mates_app/backend/supabase/database/database.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_search_page.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';

class GalleryTabViewPage extends StatefulWidget {
  const GalleryTabViewPage({super.key});

  @override
  State<GalleryTabViewPage> createState() => _GalleryTabViewPageState();
}

class _GalleryTabViewPageState extends State<GalleryTabViewPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _dynamicCategories = [];
  bool _isLoadingCategories = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadDynamicCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _debounceSearch(_searchController.text);
    }
  }

  Timer? _debounceTimer;
  void _debounceSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _handleSearch(query);
    });
  }

  Future<void> _handleSearch(String query) async {
    final user = supabase.auth.currentUser;
    if (user == null) return; // Don't handle search for unauthenticated users

    // Find matching category
    final matchingCategory = _findMatchingCategory(query);
    if (matchingCategory != null) {
      await _updateTrendingSearch(user.id, matchingCategory);
      await _loadDynamicCategories(); // Refresh categories order
    }
  }

  List<String> _allAvailableCategories = [];

  String? _findMatchingCategory(String query) {
    final lowerQuery = query.toLowerCase();

    // Check for exact match first
    for (String category in _allAvailableCategories) {
      if (category.toLowerCase() == lowerQuery) {
        return category;
      }
    }

    // Check for partial match
    for (String category in _allAvailableCategories) {
      if (category.toLowerCase().contains(lowerQuery) ||
          lowerQuery.contains(category.toLowerCase())) {
        return category;
      }
    }

    return null;
  }

  Future<void> _updateTrendingSearch(String userId, String category) async {
    try {
      await supabase.rpc('update_trending_search', params: {
        'p_user_id': userId,
        'p_category': category,
      });
    } catch (e) {
      print('Error updating trending search: $e');
    }
  }

  Future<void> _loadDynamicCategories() async {
    try {
      setState(() => _isLoadingCategories = true);

      final user = supabase.auth.currentUser;

      // If user is not authenticated, show only 'All' tab
      if (user == null) {
        setState(() {
          _dynamicCategories = [
            'All',
            'Drawing',
            'Painting',
            'Design',
            'Digital Art',
            'Mural Painting',
            'Pen Art',
            'Ink Art',
            'Illustration',
            'color pencil',
            'Pencil Sketching',
            'Acrylic Painting',
            'Watercolor Art',
            'Oil Painting',
            'Wall Art',
            'Canvas Art',
            'Miniature Painting',
            'Sculpture',
          ];
          _isLoadingCategories = false;
        });
        return;
      }

      // First, get all unique categories from gallery table
      final galleryCategories = await supabase
          .from('gallery')
          .select('category')
          .not('category', 'is', null);

      final uniqueGalleryCategories = <String>{};
      for (var item in galleryCategories) {
        if (item['category'] != null &&
            item['category'].toString().isNotEmpty) {
          uniqueGalleryCategories.add(item['category'].toString());
        }
      }

      _allAvailableCategories = uniqueGalleryCategories.toList()..sort();

      List<String> orderedCategories = [];

      // Get user's trending categories
      final userTrending = await supabase
          .rpc('get_user_trending_categories', params: {'p_user_id': user.id});

      if (userTrending != null && userTrending.isNotEmpty) {
        // Add trending categories first (in order of popularity)
        final trendingCategories = userTrending
            .map<String>((item) => item['category'].toString())
            .where((category) => _allAvailableCategories.contains(category))
            .toList();

        orderedCategories.addAll(trendingCategories);

        // Add remaining categories that aren't in trending
        for (String category in _allAvailableCategories) {
          if (!orderedCategories.contains(category)) {
            orderedCategories.add(category);
          }
        }
      } else {
        // Show interest selection if no trending data
        if (_allAvailableCategories.isNotEmpty) {
          await _showInterestSelection();
          return;
        }
      }

      // Add 'All' tab at the end
      orderedCategories.add('All');

      setState(() {
        _dynamicCategories = orderedCategories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _showInterestSelection() async {
    if (_allAvailableCategories.isEmpty) {
      // Fallback: load categories first
      try {
        final galleryCategories = await supabase
            .from('gallery')
            .select('category')
            .not('category', 'is', null);

        final uniqueGalleryCategories = <String>{};
        for (var item in galleryCategories) {
          if (item['category'] != null &&
              item['category'].toString().isNotEmpty) {
            uniqueGalleryCategories.add(item['category'].toString());
          }
        }
        _allAvailableCategories = uniqueGalleryCategories.toList()..sort();
      } catch (e) {
        print('Error loading categories for interest selection: $e');
        return;
      }
    }

    final selectedInterests = <String>[];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[900]!,
                  Colors.black,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Color(0xFFFFFC00).withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFC00).withValues(alpha: 0.2),
                        Colors.transparent
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.palette,
                        color: Color(0xFFFFFC00),
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choose Your Interests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select categories you\'re interested in to personalize your gallery experience',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      if (selectedInterests.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFC00).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Color(0xFFFFFC00).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${selectedInterests.length} selected',
                            style: const TextStyle(
                              color: Color(0xFFFFFC00),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Categories List
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: _allAvailableCategories.length,
                      itemBuilder: (context, index) {
                        final category = _allAvailableCategories[index];
                        final isSelected = selectedInterests.contains(category);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFFFFC00).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Color(0xFFFFFC00).withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFFFFFC00).withValues(alpha: 0.2)
                                        : Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category),
                                    color: isSelected
                                        ? Color(0xFFFFFC00)
                                        : Colors.grey[400],
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[300],
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedInterests.add(category);
                                } else {
                                  selectedInterests.remove(category);
                                }
                              });
                            },
                            activeColor: Color(0xFFFFFC00),
                            checkColor: Colors.black,
                            side: BorderSide.none,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top row with Select/Deselect All and Cancel buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                if (selectedInterests.length ==
                                    _allAvailableCategories.length) {
                                  selectedInterests.clear();
                                } else {
                                  selectedInterests.clear();
                                  selectedInterests
                                      .addAll(_allAvailableCategories);
                                }
                              });
                            },
                            child: Text(
                              selectedInterests.length ==
                                      _allAvailableCategories.length
                                  ? 'Deselect All'
                                  : 'Select All',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Bottom row with Continue button
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                            onPressed: selectedInterests.isEmpty
                                ? null
                                : () async {
                                    await _saveSelectedInterests(
                                        selectedInterests);
                                    Navigator.of(context).pop();
                                    await _loadDynamicCategories();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFFC00),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey[700],
                              disabledForegroundColor: Colors.grey[500],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              selectedInterests.isEmpty
                                  ? 'Select at least one'
                                  : 'Continue (${selectedInterests.length})',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('drawing') || categoryLower.contains('sketch')) {
      return Icons.draw;
    } else if (categoryLower.contains('painting') ||
        categoryLower.contains('paint')) {
      return Icons.brush;
    } else if (categoryLower.contains('design') ||
        categoryLower.contains('logo')) {
      return Icons.design_services;
    } else if (categoryLower.contains('digital') ||
        categoryLower.contains('3d')) {
      return Icons.computer;
    } else if (categoryLower.contains('photo')) {
      return Icons.photo_camera;
    } else if (categoryLower.contains('craft') ||
        categoryLower.contains('pottery')) {
      return Icons.handyman;
    } else if (categoryLower.contains('animation') ||
        categoryLower.contains('game')) {
      return Icons.play_circle;
    } else if (categoryLower.contains('calligraphy') ||
        categoryLower.contains('ink')) {
      return Icons.create;
    } else if (categoryLower.contains('sculpture')) {
      return Icons.view_in_ar;
    } else if (categoryLower.contains('embroidery') ||
        categoryLower.contains('textile')) {
      return Icons.texture;
    } else if (categoryLower.contains('programming') ||
        categoryLower.contains('code')) {
      return Icons.code;
    } else if (categoryLower.contains('nft') ||
        categoryLower.contains('crypto')) {
      return Icons.currency_bitcoin;
    } else {
      return Icons.category;
    }
  }

  Future<void> _saveSelectedInterests(List<String> interests) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // First, clear all existing interests for the user
      await supabase.rpc('clear_user_interests', params: {
        'p_user_id': user.id,
      });

      // Then add the new interests
      for (String interest in interests) {
        await supabase.rpc('update_trending_search', params: {
          'p_user_id': user.id,
          'p_category': interest,
        });
      }
    } catch (e) {
      print('Error saving interests: $e');
    }
  }

  Widget _buildSearchBar() {
    final user = supabase.auth.currentUser;

    return Container(
      padding: const EdgeInsets.all(0.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (user != null) ...[
            Container(
              margin: const EdgeInsets.only(right: 0, left: 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: const Text(
                'International Market',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _loadDynamicCategories,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
              tooltip: 'Refresh Categories',
              splashColor: const Color(0xFFFFFC00),
              highlightColor: const Color(0xFFFFFC00).withValues(alpha: 0.1),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showInterestSelection,
              icon: const Icon(Icons.tune, color: Colors.white, size: 24),
              tooltip: 'Edit Interests',
              splashColor: const Color(0xFFFFFC00),
              highlightColor: const Color(0xFFFFFC00).withValues(alpha: 0.1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: PaginatedGalleryTabView(
              categories: _dynamicCategories,
              tableName: 'gallery_with_comments_view',
              orderByColumn: 'gallery_created_at',
              ascending: false,
              itemsPerPage: 24,
              baseCrossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}

class PaginatedGalleryTabView extends StatefulWidget {
  final List<String> categories;
  final String tableName;
  final String orderByColumn;
  final bool ascending;
  final int itemsPerPage;
  final int baseCrossAxisCount; // Base count for reference
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const PaginatedGalleryTabView({
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
  });

  @override
  State<PaginatedGalleryTabView> createState() =>
      _PaginatedGalleryTabViewState();
}

class _PaginatedGalleryTabViewState extends State<PaginatedGalleryTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final supabase = SupaFlow.client;

  // Data variables
  List<Map<String, dynamic>> galleryItems = [];
  bool isLoading = true;
  String? error;


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
    fetchGalleryData();
  }

  @override
  void dispose() {
    // for (var adsMap in _nativeAdsMap.values) {
    //   for (var ad in adsMap.values) {
    //     ad?.dispose();
    //   }
    // }
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

  Future<void> fetchGalleryData() async {
    try {
      safeSetState(() {
        isLoading = true;
        error = null;
      });

      final response = await supabase
          .from(widget.tableName)
          .select()
          .order(widget.orderByColumn, ascending: widget.ascending);

      safeSetState(() {
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
      safeSetState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  // Filter items by category
  List<Map<String, dynamic>> getFilteredItems(String category) {
    if (category == 'All') {
      return galleryItems;
    }
    return galleryItems
        .where((item) => item['gallery_category'] == category)
        .toList();
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

    safeSetState(() {
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

      safeSetState(() {
        _paginatedItemsMap[category]!.addAll(newItems);
        _currentPageMap[category] = nextPage;
        _hasMoreItemsMap[category] = endIndex < allItems.length;
        _isLoadingMoreMap[category] = false;
      });
    } else {
      safeSetState(() {
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
              onPressed: fetchGalleryData,
              child: const Text('Retry'),
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
              'No items in this category',
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

                    if (index >= items.length) {
                      return const SizedBox.shrink();
                    }

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
        Container(
          color: Colors.black,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.yellow,
            tabs: widget.categories
                .map((category) => Tab(text: category))
                .toList(),
          ),
        ),
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
  final Map<String, dynamic>? item;
  final double height;
  final List<Map<String, dynamic>>? allItems;
  final int? initialIndex;
  final String? nativeAd;
  final bool isAd;
  final bool isLoaded;
  final int? adIndex;

  const MasonryGalleryItemCard({
    super.key,
    required this.item,
    required this.allItems,
    required this.initialIndex,
    required this.height,
  })  : nativeAd = null,
        isAd = false,
        isLoaded = false,
        adIndex = null;

  const MasonryGalleryItemCard.ad({
    super.key,
    required this.nativeAd,
    required this.height,
    this.isLoaded = false,
    this.adIndex,
  })  : item = null,
        allItems = null,
        initialIndex = null,
        isAd = true;

  @override
  Widget build(BuildContext context) {
    if (isAd) {
      return _buildAdCard(context);
    }
    return _buildItemCard(context);
  }

  Widget _buildAdCard(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[900],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Ad content or community card
            // if (nativeAd != null && isLoaded)
            //   AdWidget(ad: ''!)
            // else
            _buildCommunityCard(context),

            // Ad badge (only show when ad is loaded)
            if (nativeAd != null && isLoaded)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showJoinCommunityAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.palette, color: Colors.yellow, size: 30),
              SizedBox(width: 10),
              Text(
                'Join Community',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hand Skill Art Community',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.yellow,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Would you like to join our creative community and learn amazing hand skills and art techniques?',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.yellow, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Official In-App Community',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhatsAppGroupChat(
                      groupId: 'hand_skill_community',
                      groupName: 'Hand Skill Art Community',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.forum_rounded, color: Colors.black),
              label: const Text(
                'Join In-App Community',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommunityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFC00).withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_outlined,
            size: 25,
            color: Color(0xFFFFFC00),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join Pocketmates Community',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          ElevatedButton(
            onPressed: () {
              _showJoinCommunityAlert(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFFC00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Join ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailsPage(
              item: item!,
              allItems: allItems!,
              initialIndex: initialIndex!,
            ),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
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
                item!['gallery_image_url'] ?? '',
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
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
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
                      Text(
                        item!['gallery_title'] ?? 'Untitled',
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
                      const SizedBox(height: 8),
                      if (item!['gallery_price'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '₹${item!['gallery_price']}',
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

