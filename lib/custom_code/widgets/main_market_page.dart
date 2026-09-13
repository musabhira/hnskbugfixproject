import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_market_logic.dart';
import 'gallery_profile_search_page.dart';
import 'gallery_search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_ad_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';

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
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground.withValues(alpha: 0.95),
              title: Text(
                'MARKET',
                style: GoogleFonts.outfit(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 16,
                ),
              ),
              centerTitle: true,
              bottom: TabBar(
                controller: _mainTabController,
                indicatorColor: const Color(0xFFFFFC00),
                indicatorWeight: 2.5,
                labelColor: const Color(0xFFFFFC00),
                unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                labelStyle:
                    GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle:
                    GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
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
                      Icon(Icons.refresh, color: FlutterFlowTheme.of(context).primaryText, size: 20),
                  tooltip: 'Refresh Categories',
                ),
                IconButton(
                  onPressed: _showInterestSelection,
                  icon: Icon(Icons.tune, color: FlutterFlowTheme.of(context).primaryText, size: 20),
                  tooltip: 'Edit Interests',
                ),
                IconButton(
                  icon: Icon(Icons.search, color: FlutterFlowTheme.of(context).secondaryText, size: 20),
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
                  colors: [FlutterFlowTheme.of(context).secondaryBackground, FlutterFlowTheme.of(context).primaryBackground],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Color(0xFFFFFC00).withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
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
                            color: Color(0xFFFFFC00).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune,
                              color: Color(0xFFFFFC00), size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Personalize Your Feed',
                          style: TextStyle(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        // Search Bar Inside Choice
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.05)),
                          ),
                          child: TextField(
                            onChanged: (val) =>
                                setDialogState(() => searchQuery = val),
                            style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              hintStyle: TextStyle(
                                  color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.5),
                                  fontSize: 14),
                              prefixIcon: Icon(Icons.search,
                                  color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.5),
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
                                        ? Color(0xFFFFFC00)
                                        : FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.8),
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFFFFFC00).withValues(alpha: 0.1)
                                    : FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_getCategoryIcon(category),
                                  size: 18,
                                  color: isSelected
                                      ? Color(0xFFFFFC00)
                                      : FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.4)),
                            ),
                            value: isSelected,
                            activeColor: Color(0xFFFFFC00),
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
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: FlutterFlowTheme.of(context).secondaryText,
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
                                    color: Color(0xFFFFFC00).withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFFC00),
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
            height: 42,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              border: Border(
                bottom: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
            ),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFFFFFC00), width: 2),
                insets: EdgeInsets.symmetric(horizontal: 14),
              ),
              labelColor: const Color(0xFFFFFC00),
              unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
              onTap: (index) {
                final category = state.categories[index];
                if (state.itemsByCategory[category] == null) {
                  notifier.loadItems(category);
                }
              },
              tabs: state.categories
                  .map((c) => Tab(text: c))
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
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
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
        color: const Color(0xFFFFFC00),
        backgroundColor: const Color(0xFF161822),
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: items.length +
                (items.length >= 6 ? (items.length ~/ 6) : 0) +
                (state.isLoadingMore[category] == true ? crossAxisCount : 0),
            itemBuilder: (context, index) {
              // Insert a native sponsor card every 6th item
              final int adInterval = 6;
              final bool isAdSlot = (index + 1) % (adInterval + 1) == 0;

              if (isAdSlot) {
                return const MarketNativeProductAdCard();
              }

              final int actualItemIndex = index - (index ~/ (adInterval + 1));

              if (actualItemIndex >= items.length) {
                return const ItemSkeleton();
              }
              return MarketItemCard(
                  item: items[actualItemIndex],
                  index: actualItemIndex,
                  allItems: items);
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
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followingMarketProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const MarketLoadingSkeleton();
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(followingMarketProvider.notifier)
            .loadFollowingItems(isRefresh: true),
        color: const Color(0xFFFFFC00),
        backgroundColor: const Color(0xFF161822),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                      border: Border.all(color: Colors.white12, width: 0.8),
                    ),
                    child: const Icon(Icons.people_outline,
                        size: 36, color: Colors.white38),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No artworks from creators you follow",
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pull down to refresh or follow more artists",
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

      return RefreshIndicator(
        onRefresh: () => ref
            .read(followingMarketProvider.notifier)
            .loadFollowingItems(isRefresh: true),
        color: const Color(0xFFFFFC00),
        backgroundColor: const Color(0xFF161822),
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
  static const List<Color> _cardAccentPalette = [
    Color(0xFFFF5252), // Vibrant Coral / Red
    Color(0xFFFFD124), // Cyber Yellow / Amber
    Color(0xFF00E676), // Neon Emerald Green
    Color(0xFF00D2FF), // Electric Sky Blue
    Color(0xFFA855F7), // Neon Purple / Violet
  ];

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final index = widget.index;
    final accentColor = _cardAccentPalette[index % _cardAccentPalette.length];
    final imageUrl = item['gallery_image_url'] ?? item['image_url'];
    final title = item['gallery_title'] ?? item['title'] ?? 'Untitled';
    final price = item['gallery_price'] ?? item['price'];
    final userName = item['name'] ?? 'Artist';
    final userProfileImg = item['profile_image_url'];

    return GestureDetector(
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
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13151D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
            width: 0.9,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail with minimal price badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: imageUrl != null && imageUrl.toString().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl.toString(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: accentColor.withValues(alpha: 0.06),
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: accentColor.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withValues(alpha: 0.04),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 20,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: accentColor.withValues(alpha: 0.06),
                          child: Center(
                            child: Icon(
                              Icons.palette_outlined,
                              size: 22,
                              color: accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                ),
                if (price != null)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.55),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        '₹$price',
                        style: GoogleFonts.outfit(
                          color: accentColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Minimal Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ClipOval(
                        child: item['avatar_config'] != null
                            ? VectorAvatarWidget(
                                config: VectorAvatarConfig.fromJson(item['avatar_config']),
                                size: 16,
                                showAura: false,
                              )
                            : (userProfileImg != null && userProfileImg.toString().isNotEmpty
                                ? Image.network(
                                    userProfileImg,
                                    width: 16,
                                    height: 16,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.person, size: 12, color: Colors.white60),
                                  )
                                : VectorAvatarWidget(
                                    config: VectorAvatarConfig(
                                      hairStyle: 'anime_spiky',
                                      auraStyle: 'pocket_gold',
                                      outfitStyle: 'artist_beret',
                                    ),
                                    size: 16,
                                    showAura: false,
                                  )),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11.5,
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
    );
  }
}

class MarketLoadingSkeleton extends StatelessWidget {
  const MarketLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF13151D),
      highlightColor: const Color(0xFF1E2230),
      child: MasonryGridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: 9,
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
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
      ),
    );
  }
}

/// A Native Sponsor Product Card that fits seamlessly inside Market Grid
class MarketNativeProductAdCard extends StatefulWidget {
  const MarketNativeProductAdCard({super.key});

  @override
  State<MarketNativeProductAdCard> createState() => _MarketNativeProductAdCardState();
}

class _MarketNativeProductAdCardState extends State<MarketNativeProductAdCard> {
  bool _isSubscribed = false;

  final List<Map<String, dynamic>> _sponsorProducts = [
    {
      'title': 'Oxford 30D Master Kit',
      'price': '₹499',
      'brand': 'Oxford Hub',
      'badge': 'SPONSORED',
      'accent': Color(0xFF38BDF8),
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'IELTS AI Simulator',
      'price': '₹299',
      'brand': 'Global Prep',
      'badge': 'SPONSORED',
      'accent': Color(0xFFFFD124),
      'icon': Icons.record_voice_over_rounded,
    },
    {
      'title': 'Tech Interview Guide',
      'price': '₹399',
      'brand': 'CareerSprint',
      'badge': 'SPONSORED',
      'accent': Color(0xFF10B981),
      'icon': Icons.work_outline_rounded,
    },
  ];

  late final Map<String, dynamic> _ad;

  @override
  void initState() {
    super.initState();
    _ad = (_sponsorProducts..shuffle()).first;
    _checkVip();
  }

  Future<void> _checkVip() async {
    final sub = await PocketAdService().isUserSubscribed();
    if (mounted) setState(() => _isSubscribed = sub);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubscribed) return const SizedBox.shrink();

    final Color accent = _ad['accent'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 0.9,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.22), const Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _ad['icon'] as IconData,
                      size: 28,
                      color: accent,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: accent.withValues(alpha: 0.6), width: 0.5),
                      ),
                      child: Text(
                        'AD',
                        style: GoogleFonts.outfit(
                          color: accent,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accent.withValues(alpha: 0.6), width: 0.6),
                      ),
                      child: Text(
                        _ad['price'] as String,
                        style: GoogleFonts.outfit(
                          color: accent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _ad['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _ad['brand'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

