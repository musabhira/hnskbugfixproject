import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'main_market_logic.dart';
import 'gallery_profile_search_page.dart';
import 'gallery_search_page.dart';
import 'search_page.dart' show SearchPage;

class MainMarketPage extends ConsumerStatefulWidget {
  const MainMarketPage({super.key});

  @override
  ConsumerState<MainMarketPage> createState() => _MainMarketPageState();
}

class _MainMarketPageState extends ConsumerState<MainMarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    // Initialize market data
    Future.microtask(() => ref.read(marketProvider.notifier).initialize());
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: Colors.black,
              title: const Text(
                'MARKET',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              bottom: TabBar(
                controller: _mainTabController,
                indicatorColor: Colors.amber,
                indicatorWeight: 3,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.white54,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'EXPLORE'),
                  Tab(text: 'FOLLOWING'),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () =>
                      ref.read(marketProvider.notifier).loadCategories(),
                  icon:
                      const Icon(Icons.refresh, color: Colors.white, size: 22),
                  tooltip: 'Refresh Categories',
                ),
                IconButton(
                  onPressed: _showInterestSelection,
                  icon: const Icon(Icons.tune, color: Colors.white, size: 22),
                  tooltip: 'Edit Interests',
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white70),
                  onPressed: () {
                    // Navigate to a search page or show search bar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GalleryProfileSearchPage(userid: ''),
                      ),
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: TabBarView(
          controller: _mainTabController,
          children: const [
            MarketExploreTabView(),
            MarketFollowingTabView(),
          ],
        ),
      ),
    );
  }

  Future<void> _showInterestSelection() async {
    final state = ref.read(marketProvider);
    final allCategories = state.categories.where((c) => c != 'All').toList()
      ..sort();
    final selectedInterests = <String>[];
    String searchQuery = '';

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredCategories = allCategories
              .where((c) =>
                  c.toLowerCase().contains(searchQuery.toLowerCase().trim()))
              .toList();

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1E1E1E), Colors.black],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune,
                              color: Colors.amber, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Personalize Your Feed',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        // Search Bar Inside Choice
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: TextField(
                            onChanged: (val) =>
                                setDialogState(() => searchQuery = val),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 14),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  size: 18),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        final isSelected = selectedInterests.contains(category);
                        return Theme(
                          data:
                              ThemeData(unselectedWidgetColor: Colors.white24),
                          child: CheckboxListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(category,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.amber
                                        : Colors.white.withValues(alpha: 0.8),
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.amber.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_getCategoryIcon(category),
                                  size: 18,
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.white24),
                            ),
                            value: isSelected,
                            activeColor: Colors.amber,
                            checkColor: Colors.black,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedInterests.add(category);
                                } else {
                                  selectedInterests.remove(category);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                if (selectedInterests.isNotEmpty)
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: selectedInterests.isEmpty
                                  ? null
                                  : () async {
                                      Navigator.pop(context);
                                      await ref
                                          .read(marketProvider.notifier)
                                          .saveSelectedInterests(
                                              selectedInterests);
                                    },
                              child: Text(
                                  selectedInterests.isEmpty
                                      ? 'Select One'
                                      : 'Apply (${selectedInterests.length})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
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

  IconData _getCategoryIcon(String category) {
    final l = category.toLowerCase();
    if (l.contains('draw')) return Icons.draw;
    if (l.contains('paint')) return Icons.brush;
    if (l.contains('design')) return Icons.design_services;
    if (l.contains('digital')) return Icons.computer;
    if (l.contains('photo')) return Icons.photo_camera;
    if (l.contains('sculpt')) return Icons.view_in_ar;
    if (l.contains('illustrat')) return Icons.edit_note;
    if (l.contains('canvas')) return Icons.crop_original;
    return Icons.category_rounded;
  }
}

class MarketExploreTabView extends ConsumerWidget {
  const MarketExploreTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketProvider);
    final notifier = ref.read(marketProvider.notifier);

    if (state.isLoadingCategories && state.categories.length <= 1) {
      return const MarketLoadingSkeleton();
    }

    return DefaultTabController(
      length: state.categories.length,
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                  bottom:
                      BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: TabBar(
              isScrollable: true,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.amber, width: 2),
                insets: EdgeInsets.symmetric(horizontal: 20),
              ),
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white38,
              onTap: (index) {
                final category = state.categories[index];
                if (state.itemsByCategory[category] == null) {
                  notifier.loadItems(category);
                }
              },
              tabs: state.categories
                  .map((c) => Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Text(c,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: state.categories.map((category) {
                return MarketItemsList(category: category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MarketItemsList extends ConsumerWidget {
  final String category;
  const MarketItemsList({super.key, required this.category});

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketProvider);
    final items = state.itemsByCategory[category] ?? [];

    if (items.isEmpty && !state.isLoadingCategories) {
      Future.microtask(
          () => ref.read(marketProvider.notifier).loadItems(category));
      return const MarketLoadingSkeleton();
    }

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

      return RefreshIndicator(
        onRefresh: () => ref
            .read(marketProvider.notifier)
            .loadItems(category, isRefresh: true),
        color: Colors.amber,
        backgroundColor: Colors.grey[900],
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 500) {
              ref.read(marketProvider.notifier).loadMore(category);
            }
            return false;
          },
          child: MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            itemCount: items.length +
                (state.isLoadingMore[category] == true ? crossAxisCount : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return const ItemSkeleton();
              }
              return MarketItemCard(
                  item: items[index], index: index, allItems: items);
            },
          ),
        ),
      );
    });
  }
}

class MarketFollowingTabView extends ConsumerStatefulWidget {
  const MarketFollowingTabView({super.key});

  @override
  ConsumerState<MarketFollowingTabView> createState() =>
      _MarketFollowingTabViewState();
}

class _MarketFollowingTabViewState
    extends ConsumerState<MarketFollowingTabView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(followingMarketProvider.notifier).loadFollowingItems());
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followingMarketProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const MarketLoadingSkeleton();
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 80, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            const Text(
              "No artworks from people you follow",
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

      return RefreshIndicator(
        onRefresh: () => ref
            .read(followingMarketProvider.notifier)
            .loadFollowingItems(isRefresh: true),
        color: Colors.amber,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 500) {
              ref.read(followingMarketProvider.notifier).loadFollowingItems();
            }
            return false;
          },
          child: MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              return MarketItemCard(
                  item: state.items[index],
                  index: index,
                  allItems: state.items);
            },
          ),
        ),
      );
    });
  }
}

class MarketItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final List<Map<String, dynamic>> allItems;

  const MarketItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.allItems,
  });

  @override
  State<MarketItemCard> createState() => _MarketItemCardState();
}

class _MarketItemCardState extends State<MarketItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final index = widget.index;
    final imageUrl = item['gallery_image_url'] ?? item['image_url'];
    final title = item['gallery_title'] ?? item['title'] ?? 'Untitled';
    final price = item['gallery_price'] ?? item['price'];
    final userName = item['name'] ?? 'Artist';
    final userProfileImg = item['profile_image_url'];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GalleryDetailsPage(
                item: item,
                allItems: widget.allItems,
                initialIndex: index,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.02))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? Colors.amber.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl.toString(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180 + (index % 4 * 25).toDouble(),
                        color: Colors.grey[900],
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: Container(color: Colors.black),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image_outlined,
                            color: Colors.white24, size: 30),
                      ),
                    ),
                    // Gradient Overlay for readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (price != null)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '₹$price',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: const Color(0xFF1A1A1A),
                            backgroundImage: userProfileImg != null
                                ? NetworkImage(userProfileImg)
                                : null,
                            child: userProfileImg == null
                                ? const Icon(Icons.person,
                                    size: 11, color: Colors.white54)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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

class MarketLoadingSkeleton extends StatelessWidget {
  const MarketLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => const ItemSkeleton(),
      ),
    );
  }
}

class ItemSkeleton extends StatelessWidget {
  const ItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
