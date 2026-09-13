// Automatic FlutterFlow imports
import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import 'index.dart'; // Imports other custom widgets
// Imports custom actions
import '/flutter_flow/flutter_flow_theme.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_search_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.width,
    this.height,
    this.initialTab = 'people',
  });

  final double? width;
  final double? height;
  final String? initialTab;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late String _selectedTab; // 'people' or 'market'
  String _currentSearchQuery = '';
  String _currentFilter = ''; // '', 'human', 'robot'
  int _totalResults = 0;
  String _searchStatus = '';
  bool _hasSearched = false;
  List<String> _searchHistory = [];
  final Map<String, int> _searchAnalytics = {};

  @override
  void initState() {
    super.initState();
    _selectedTab = (widget.initialTab == 'market') ? 'market' : 'people';
  }

  String get _effectiveSearchQuery {
    if (_currentSearchQuery.isNotEmpty) return _currentSearchQuery;
    return _currentFilter;
  }

  void _handleSearchChanged(String query) {
    safeSetState(() {
      _currentSearchQuery = query;
    });
  }

  void _handleFilterChanged(String filter) {
    safeSetState(() {
      _currentFilter = filter;
    });
  }

  void _handleResultsChanged(List<Map<String, dynamic>> results) {
    safeSetState(() {
      _totalResults = results.length;
      _hasSearched = true;

      // Update search status message
      final effectiveQ = _effectiveSearchQuery;
      if (effectiveQ.isEmpty) {
        _searchStatus = 'Showing latest profiles ($_totalResults found)';
      } else {
        _searchStatus = _totalResults > 0
            ? 'Found $_totalResults results for "$effectiveQ"'
            : 'No results found for "$effectiveQ"';
      }

      // Add to search history (avoid duplicates and empty queries)
      if (_currentSearchQuery.isNotEmpty &&
          !_searchHistory.contains(_currentSearchQuery)) {
        _searchHistory.insert(0, _currentSearchQuery);
        // Keep only last 10 searches
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      }

      // Update search analytics
      if (_currentSearchQuery.isNotEmpty) {
        _searchAnalytics[_currentSearchQuery] =
            (_searchAnalytics[_currentSearchQuery] ?? 0) + 1;
      }
    });

    // Log analytics (you can send this to your analytics service)
    _logSearchAnalytics(_currentSearchQuery, results.length);

    // Optional: Save search history to local storage or preferences
    _saveSearchHistory();

    // Optional: Track popular searches
    _updatePopularSearches();
  }

  Widget _buildTopTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_selectedTab != 'people') {
                    safeSetState(() {
                      _selectedTab = 'people';
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: _selectedTab == 'people'
                        ? const Color(0xFFFFFC00)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        size: 15,
                        color: _selectedTab == 'people' ? Colors.black : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'People',
                        style: GoogleFonts.outfit(
                          color: _selectedTab == 'people' ? Colors.black : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_selectedTab != 'market') {
                    safeSetState(() {
                      _selectedTab = 'market';
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: _selectedTab == 'market'
                        ? const Color(0xFFFFFC00)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 17,
                        color: _selectedTab == 'market' ? Colors.black : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Market',
                        style: GoogleFonts.outfit(
                          color: _selectedTab == 'market' ? Colors.black : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logSearchAnalytics(String query, int resultCount) {
    debugPrint(
        'Search Analytics: Query="$query", Results=$resultCount, Timestamp=${DateTime.now()}');
  }

  void _saveSearchHistory() {
    debugPrint('Search History Updated: $_searchHistory');
  }

  void _updatePopularSearches() {
    var sortedSearches = _searchAnalytics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var popularSearches = sortedSearches.take(5).map((e) => e.key).toList();
    debugPrint('Popular Searches: $popularSearches');
  }

  void _clearSearchHistory() {
    safeSetState(() {
      _searchHistory.clear();
      _searchAnalytics.clear();
    });
    _saveSearchHistory();
  }

  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return _searchHistory.take(5).toList();

    return _searchHistory
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  Widget _buildMinimalFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 6),
      child: Row(
        children: [
          _filterChipItem('All', ''),
          const SizedBox(width: 6),
          _filterChipItem('👤 Humans', 'human'),
          const SizedBox(width: 6),
          _filterChipItem('🤖 Robots', 'robot'),
        ],
      ),
    );
  }

  Widget _filterChipItem(String label, String filterKey) {
    final isSelected = (_currentFilter == filterKey);
    return InkWell(
      onTap: () => _handleFilterChanged(filterKey),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFFC00).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFFFFFC00) : Colors.white60,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Minimal Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (_searchHistory.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.history_rounded,
                          color: Colors.white54, size: 20),
                      onPressed: _showSearchHistoryDialog,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (_searchHistory.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.cleaning_services_rounded,
                          color: Colors.white54, size: 18),
                      onPressed: _showClearHistoryDialog,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),

            // Sleek Minimal Search Bar
            CustomSearchWidget(
              onSearchChanged: _handleSearchChanged,
            ),

            // Top Tabs (People vs Market)
            _buildTopTabs(),

            if (_selectedTab == 'people') ...[
              // Quick Minimal Filter Chips (All, Humans, Robots)
              _buildMinimalFilterChips(),

              // Results Counter / Status
              if (_hasSearched)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 2.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _searchStatus,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),

              // People Content
              Expanded(
                child: SearchResultsWidget(
                  searchQuery: _effectiveSearchQuery,
                  onResultsChanged: _handleResultsChanged,
                ),
              ),
            ] else ...[
              // Market Content
              Expanded(
                child: MarketSearchResultsWidget(
                  searchQuery: _currentSearchQuery,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Search History',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final searchTerm = _searchHistory[index];
                final searchCount = _searchAnalytics[searchTerm] ?? 1;
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.yellow),
                  title: Text(
                    searchTerm,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Searched $searchCount time${searchCount > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    safeSetState(() {
                      _currentSearchQuery = searchTerm;
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Close', style: TextStyle(color: Colors.yellow)),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Clear Search History',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to clear all search history?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _clearSearchHistory();
                Navigator.of(context).pop();
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

class CustomSearchWidget extends StatefulWidget {
  final Function(String) onSearchChanged;

  const CustomSearchWidget({
    super.key,
    required this.onSearchChanged,
  });

  @override
  State<CustomSearchWidget> createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5),
          cursorColor: const Color(0xFFFFFC00),
          decoration: InputDecoration(
            hintText: 'Search people or business...',
            hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white54,
              size: 18,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: widget.onSearchChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Search Results Widget
class SearchResultsWidget extends StatefulWidget {
  final String searchQuery;
  final Function(List<Map<String, dynamic>>)? onResultsChanged;

  const SearchResultsWidget({
    super.key,
    required this.searchQuery,
    this.onResultsChanged,
  });

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();
  final _supabase = SupaFlow.client;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String _currentQuery = '';
  final int _pageSize = 10;
  String _currentPlan = 'free';

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
    _scrollController.addListener(_onScroll);
    _fetchInitialProfiles();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      safeSetState(() {
        _currentPlan = prefs.getString('handskill_plan') ?? 'free';
      });
    }
  }

  @override
  void didUpdateWidget(SearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _performSearch(widget.searchQuery);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProfiles();
      }
    }
  }

  void _fetchInitialProfiles() async {
    safeSetState(() {
      _isLoading = true;
      _currentPage = 0;
      _searchResults.clear();
      _hasMoreData = true;
      _currentQuery = '';
    });

    try {
      final response = await _supabase
          .from('profile')
          .select('profile_image_url, shop_name, verified, user_id, name, learning_day, daily_streak, avatar_config')
          .order('name', ascending: true)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      // Featured spotlight robots showcasing the Human & Robot co-existing world
      final spotlightRobots = [
        PocketRobotService.getRobotByLevel(1),
        PocketRobotService.getRobotByLevel(45),
        PocketRobotService.getRobotByLevel(90),
      ];
      final List<Map<String, dynamic>> robotMaps = spotlightRobots.map((r) => {
        'user_id': r.id,
        'name': r.name,
        'shop_name': 'Lvl ${r.level} • ${r.archetype.label} ${r.archetype.icon}',
        'profile_image_url': r.avatarUrl,
        'verified': false,
        'is_robot': true,
        'robot_level': r.level,
        'robot_archetype': r.archetype.label,
        'robot_archetype_icon': r.archetype.icon,
        'robot_bio': r.bio,
        'robot_cefr': r.cefrRank,
        'robot_opening': r.openingMessage,
      }).toList();

      safeSetState(() {
        var resultsToDisplay = List<Map<String, dynamic>>.from(response);
        _hasMoreData = response.length == _pageSize;
        _searchResults = [...robotMaps, ...resultsToDisplay];
        _isLoading = false;
        _currentPage++;
      });

      // Notify parent about results change
      if (widget.onResultsChanged != null) {
        widget.onResultsChanged!(_searchResults);
      }
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching profiles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profiles: $e')),
        );
      }
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      _fetchInitialProfiles();
      return;
    }

    safeSetState(() {
      _isLoading = true;
      _currentPage = 0;
      _searchResults.clear();
      _hasMoreData = true;
      _currentQuery = query;
    });

    final cleanQ = query.trim().toLowerCase();
    final isHumanOnly = cleanQ == 'human' || cleanQ == 'humans';
    final isRobotOnly = cleanQ == 'robot' || cleanQ == 'robots' || cleanQ == 'all robots';

    try {
      List<dynamic> response = [];

      // 1. Fetch humans if not searching robots exclusively
      if (!isRobotOnly) {
        final queryBuilder = _supabase
            .from('profile')
            .select('profile_image_url, shop_name, verified, user_id, name, learning_day, daily_streak, avatar_config')
            .neq('is_private', true);

        if (isHumanOnly) {
          response = await queryBuilder
              .order('name', ascending: true)
              .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
        } else {
          response = await queryBuilder
              .or('name.ilike.%$query%,shop_name.ilike.%$query%,slug.ilike.%$query%')
              .order('name', ascending: true)
              .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
        }
      }

      // 2. Fetch matching robots if not searching humans exclusively
      List<PocketRobot> matchingRobots = [];
      if (!isHumanOnly) {
        matchingRobots = isRobotOnly
            ? PocketRobotService.getAllRobots()
            : PocketRobotService.searchRobots(query);
      }

      final List<Map<String, dynamic>> robotMaps = matchingRobots.map((r) => {
        'user_id': r.id,
        'name': r.name,
        'shop_name': 'Lvl ${r.level} • ${r.archetype.label} ${r.archetype.icon}',
        'profile_image_url': r.avatarUrl,
        'verified': false,
        'is_robot': true,
        'robot_level': r.level,
        'robot_archetype': r.archetype.label,
        'robot_archetype_icon': r.archetype.icon,
        'robot_bio': r.bio,
        'robot_cefr': r.cefrRank,
        'robot_opening': r.openingMessage,
      }).toList();

      safeSetState(() {
        var resultsToDisplay = List<Map<String, dynamic>>.from(response);
        _hasMoreData = response.length == _pageSize;
        _searchResults = [...robotMaps, ...resultsToDisplay];
        _isLoading = false;
        _currentPage++;
      });

      // Notify parent about results change
      if (widget.onResultsChanged != null) {
        widget.onResultsChanged!(_searchResults);
      }
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      debugPrint('Error searching profiles: $e');
    }
  }

  void _loadMoreProfiles() async {
    if (_isLoadingMore || !_hasMoreData) return;

    safeSetState(() {
      _isLoadingMore = true;
    });

    try {
      List<Map<String, dynamic>> response;

      if (_currentQuery.isEmpty) {
        response = await _supabase
            .from('profile')
            .select('profile_image_url, shop_name, verified, user_id, name, learning_day, daily_streak, avatar_config')
            .neq('is_private', true)
            .order('name', ascending: true)
            .range(
                _currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      } else {
        response = await _supabase
            .from('profile')
            .select('profile_image_url, shop_name, verified, user_id, name, learning_day, daily_streak, avatar_config')
            .neq('is_private', true)
            .or(
                'name.ilike.%$_currentQuery%,shop_name.ilike.%$_currentQuery%,slug.ilike.%$_currentQuery%')
            .order('name', ascending: true)
            .range(
                _currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      }

      safeSetState(() {
        _searchResults.addAll(response);
        _isLoadingMore = false;
        _hasMoreData = response.length == _pageSize;
        _currentPage++;
      });

      // Notify parent about results change
      if (widget.onResultsChanged != null) {
        widget.onResultsChanged!(_searchResults);
      }
    } catch (e) {
      safeSetState(() {
        _isLoadingMore = false;
      });
      debugPrint('Error loading more profiles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFFFC00),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: Colors.white24, size: 36),
            const SizedBox(height: 8),
            Text(
              'No results found',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      itemCount: _searchResults.length + (_hasMoreData ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          if (_currentPlan == 'free') {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())).then((_) {
                  _loadCurrentPlan();
                  _performSearch(_currentQuery);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unlock Unlimited Discover',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text('Upgrade to Premium to view more entrepreneurs.',
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
                  ],
                ),
              ),
            );
          }
          return _isLoadingMore
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Color(0xFFFFFC00), strokeWidth: 2),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }

        final profile = _searchResults[index];
        final name = profile['name'] ?? 'Partner';
        final shopName = profile['shop_name'];
        final isVerified = profile['verified'] == true;
        final isRobot = profile['is_robot'] == true;

        return GestureDetector(
          onTap: () {
            if (isRobot) {
              _showPocketRobotProfileSheet(context, profile);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isVerified
                    ? VerfiedSwitchPage(userId: profile['user_id'])
                    : MainProfileWidget(userId: profile['user_id']),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRobot
                    ? const Color(0xFF06B6D4).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.05),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                // Compact Level Avatar
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isRobot
                        ? const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)])
                        : (isVerified
                            ? const LinearGradient(
                                colors: [Color(0xFFFFFC00), Colors.orangeAccent])
                            : LinearGradient(
                                colors: [
                                  const Color(0xFFFFFC00).withValues(alpha: 0.8),
                                  const Color(0xFF10B981).withValues(alpha: 0.8),
                                ],
                              )),
                    border: (!isVerified && !isRobot)
                        ? Border.all(color: Colors.white12, width: 0.8)
                        : null,
                  ),
                  child: ClipOval(
                    child: Container(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      child: VectorAvatarWidget(
                        config: isRobot
                            ? VectorAvatarConfig.getEvolutionAvatarForStage((profile['robot_level'] as num?)?.toInt() ?? 1)
                            : ((profile['avatar_config'] != null)
                                ? VectorAvatarConfig.fromMap(Map<String, dynamic>.from(profile['avatar_config']))
                                : VectorAvatarConfig.getEvolutionAvatarForStage((profile['learning_day'] as num?)?.toInt() ?? 1)),
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                // Compact Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: GoogleFonts.outfit(
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isRobot
                                  ? const Color(0xFF06B6D4).withValues(alpha: 0.18)
                                  : const Color(0xFFFFFC00).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isRobot
                                    ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                                    : const Color(0xFFFFFC00).withValues(alpha: 0.5),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              isRobot
                                  ? 'Lvl ${(profile['robot_level'] as num?)?.toInt() ?? 1} 🤖'
                                  : 'Lvl ${(profile['learning_day'] as num?)?.toInt() ?? 1} ⭐',
                              style: GoogleFonts.outfit(
                                color: isRobot ? const Color(0xFF06B6D4) : const Color(0xFFFFFC00),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                color: Color(0xFF38BDF8), size: 15),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (isRobot) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                'Robot${profile['robot_level'] != null ? ' • Lvl ${profile['robot_level']}' : ''}',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF06B6D4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white10,
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                '👤 Human',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                          if (shopName != null && shopName.toString().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                shopName.toString(),
                                style: GoogleFonts.inter(
                                  color: isRobot
                                      ? const Color(0xFFFFFC00).withValues(alpha: 0.85)
                                      : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: isRobot ? const Color(0xFF06B6D4).withValues(alpha: 0.6) : Colors.white24,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPocketRobotProfileSheet(BuildContext context, Map<String, dynamic> robotData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F111A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF06B6D4), width: 1.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage: CachedNetworkImageProvider(robotData['profile_image_url'] ?? ''),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    robotData['name'] ?? 'Pocket Robot',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF06B6D4)),
                    ),
                    child: Text(
                      '🤖 ROBOT',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF06B6D4),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${robotData['robot_archetype_icon'] ?? '✨'} ${robotData['robot_archetype'] ?? 'Mate'} • ${robotData['robot_cefr'] ?? 'A1 Rookie'}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFFC00),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              if (robotData['robot_bio'] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    robotData['robot_bio'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final myId = SupaFlow.client.auth.currentUser?.id ?? '';
                        if (myId.isNotEmpty) {
                          await PocketRobotService.acceptRobotRequest(
                            myId: myId,
                            robotId: robotData['user_id'],
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✨ Added ${robotData['name']} to your Pocket Mates!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.person_add_rounded, color: Colors.black, size: 18),
                      label: Text(
                        'Add Mate',
                        style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WhatsAppGroupChat(
                              groupId: 'p:${robotData['user_id']}',
                              groupName: robotData['name'],
                              groupImage: robotData['profile_image_url'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'Chat',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

class FollowButton extends StatefulWidget {
  final String userId;
  final bool initialIsFollowing;
  final DateTime? firstFollowTimestamp;
  final Color? buttonColor;
  final Color? buttonTextColor;

  const FollowButton({
    super.key,
    required this.userId,
    required this.initialIsFollowing,
    this.firstFollowTimestamp,
    this.buttonColor,
    this.buttonTextColor,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
  bool _isRequested = false;
  bool _isLoading = false;
  final _supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
    _checkFollowingStatus(); // Check the following status on init
    _fetchFollowCounts();
    _fetchProfileData();
  }

  Future<void> _checkFollowingStatus() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return; // If not logged in, no need to check
    }

    try {
      final existingFollow = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('followed_id', widget.userId)
          .maybeSingle();

      if (existingFollow != null) {
        // If the relationship exists, set _isFollowing to true
        safeSetState(() {
          _isFollowing = true;
        });
      }
    } catch (e) {
      debugPrint("Error checking follow status: $e");
    }
  }

  Future<void> _toggleFollow() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to follow users')),
      );
      return;
    }

    final isPrivate = _profileData?['is_private'] == true;

    safeSetState(() {
      _isLoading = true;
    });

    try {
      if (isPrivate && !_isFollowing) {
        final oldRequested = _isRequested;
        safeSetState(() {
          _isRequested = !_isRequested;
          _isLoading = false;
        });

        try {
          if (_isRequested) {
            final myProfile = await _supabase.from('profile').select('name').eq('user_id', currentUserId).maybeSingle();
            final myName = myProfile?['name'] ?? 'Someone';
            await _supabase.from('notifications').insert({
              'user_id': widget.userId,
              'sender_id': currentUserId,
              'message': '$myName wants to follow you.',
              'type': 'follow_request',
              'status': 'pending',
            });
          } else {
            await _supabase
                .from('notifications')
                .delete()
                .eq('sender_id', currentUserId)
                .eq('user_id', widget.userId)
                .eq('type', 'follow_request')
                .eq('status', 'pending');
          }
        } catch (e) {
          safeSetState(() {
            _isRequested = oldRequested;
          });
        }
        return;
      }

      if (_isFollowing) {
        // Unfollow - delete the record
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('followed_id', widget.userId);
      } else {
        // Check if the follow relationship already exists
        final existingFollow = await _supabase
            .from('follows')
            .select()
            .eq('follower_id', currentUserId)
            .eq('followed_id', widget.userId)
            .maybeSingle();

        // Only insert if the relationship doesn't exist
        if (existingFollow == null) {
          // Follow - insert a new record with timestamp
          await _supabase.from('follows').insert({
            'follower_id': currentUserId,
            'followed_id': widget.userId,
          });
        }
      }

      // Update state
      safeSetState(() {
        _isFollowing = !_isFollowing;
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      debugPrint("$e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status: $e')),
      );
    }
  }

  void _fetchFollowCounts() async {
    try {
      await _supabase
          .from('profile_follow_counts')
          .select(
              'followers_count, following_count, gallery_count, service_count')
          .eq('user_id', widget.userId)
          .single();

      safeSetState(() {
        // _followersCount = followResponse['followers_count'] ?? 0;
        // _followingCount = followResponse['following_count'] ?? 0;
        // _galleryCount = followResponse['gallery_count'] ?? 0;
        // _serviceCount = followResponse['service_count'] ?? 0;
      });
    } catch (e) {
      debugPrint('Error fetching follow counts: $e');
    }
  }

  void _fetchProfileData() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      // Fetch button colors directly from profile table
      final buttonColorsResponse = await _supabase
          .from('profile')
          .select('button_color_code, button_text_color, is_private')
          .eq('user_id', widget.userId)
          .limit(1);

      Map<String, dynamic>? buttonColors =
          buttonColorsResponse.isNotEmpty ? buttonColorsResponse.first : null;

      bool isReq = false;
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null && currentUserId != widget.userId) {
        final reqCheck = await _supabase
            .from('notifications')
            .select('id')
            .eq('sender_id', currentUserId)
            .eq('user_id', widget.userId)
            .eq('type', 'follow_request')
            .eq('status', 'pending')
            .maybeSingle();
        isReq = reqCheck != null;
      }

      safeSetState(() {
        // Store button colors in _profileData
        _profileData = buttonColors ?? {};
        _isRequested = isReq;
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
    }
  }

  Map<String, dynamic>? _profileData;
  Color _getButtonColor() {
    if (widget.buttonColor != null) {
      return widget.buttonColor!;
    }
    
    // Debug print to check if button_color_code exists
    debugPrint('Profile data: $_profileData');
    debugPrint('Button color code: ${_profileData?['button_color_code']}');

    if (_profileData != null && _profileData!['button_color_code'] != null) {
      try {
        String colorCode = _profileData!['button_color_code'].toString();
        // Handle both formats: #FFFFFF and FFFFFF
        if (colorCode.startsWith('#')) {
          colorCode = colorCode.substring(1);
        }
        return Color(int.parse('FF$colorCode', radix: 16));
      } catch (e) {
        debugPrint('Error parsing color code: $e');
        return Theme.of(context).primaryColor;
      }
    }
    return Theme.of(context).primaryColor;
  }
  
  Color _getButtonTextColor() {
    if (widget.buttonTextColor != null) {
      return widget.buttonTextColor!;
    }
    
    if (_profileData != null && _profileData!['button_text_color'] != null) {
      try {
        String colorCode = _profileData!['button_text_color'].toString();
        if (colorCode.startsWith('#')) {
          colorCode = colorCode.substring(1);
        }
        return Color(int.parse('FF$colorCode', radix: 16));
      } catch (e) {
        return Colors.white; // Or a reasonable default text color
      }
    }
    return Colors.black; // Default if not found
  }

  @override
  Widget build(BuildContext context) {
    final labelText = _isFollowing
        ? 'Following'
        : (_isRequested ? 'Requested' : 'Follow');
    final labelIcon = _isFollowing
        ? Icons.person_remove
        : (_isRequested ? Icons.hourglass_empty : Icons.person_add);

    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _toggleFollow,
      icon: Icon(labelIcon, color: _isFollowing ? _getButtonColor() : _getButtonTextColor()),
      label: Text(labelText, style: TextStyle(color: _isFollowing ? _getButtonColor() : _getButtonTextColor())),
      style: OutlinedButton.styleFrom(
        foregroundColor: _isFollowing
            ? _getButtonColor().withValues(alpha: 0.5)
            : _getButtonColor(),
        side: BorderSide(
          color: _isFollowing
              ? _getButtonColor().withValues(alpha: 0.5)
              : _getButtonColor(),
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: _isFollowing
            ? _getButtonColor().withValues(alpha: 0.1)
            : _getButtonColor().withValues(alpha: 0.1),
      ),
    );
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

class ProfileDetailPage extends StatefulWidget {
  final String userId;

  const ProfileDetailPage({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];
  bool _isLoading = false;
  final _supabase = SupaFlow.client;

  late TabController _tabController;
  int _followersCount = 0;
  bool _isFollowing = false;
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileData();
    _checkFollowStatus();
    _fetchFollowCounts();
  }

  void _fetchFollowCounts() async {
    try {
      final followResponse = await _supabase
          .from('profile_follow_counts')
          .select(
              'followers_count, following_count, gallery_count, service_count')
          .eq('user_id', widget.userId)
          .single();

      safeSetState(() {
        _followersCount = followResponse['followers_count'] ?? 0;
      });
    } catch (e) {
      // Handle error quietly
      debugPrint('Error fetching follow counts: $e');
    }
  }

  void _fetchProfileData() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      final pCheck = await _supabase
          .from('profile')
          .select('is_private')
          .eq('user_id', widget.userId)
          .maybeSingle();
      final isPrivate = pCheck?['is_private'] == true;

      // Fetch profile data - get the first entry for this user
      final profileResponse =
          await _supabase.from('profile_gallery_service_likes_view').select('''
          profile_id, profile_created_at, user_id, name, phone_no, country, bio, 
          shop_name, profile_image_url, banner_image_url, button_color_code, 
          bg_color_code, bg_text_color, state, city, button_text_color, layout
        ''').eq('user_id', widget.userId).limit(1);

      Map<String, dynamic>? profile =
          profileResponse.isNotEmpty ? profileResponse.first : null;

      // Fetch gallery items - using not 'is' null instead of isNotNull
      final galleryResponse = await _supabase
          .from('profile_gallery_service_likes_view')
          .select('''
          gallery_id, gallery_created_at, gallery_title, gallery_description, 
          gallery_price, gallery_image_url, gallery_category, like_id, like_created_at
        ''')
          .eq('user_id', widget.userId)
          .not('gallery_id', 'is', null) // Correct way to check for non-null
          .order('gallery_created_at', ascending: false);

      // Manual deduplication based on gallery_id
      final Map<String, Map<String, dynamic>> uniqueGalleryItems = {};
      for (var item in galleryResponse) {
        if (item['gallery_id'] != null) {
          uniqueGalleryItems[item['gallery_id'].toString()] = item;
        }
      }

      // Fetch service items - using not 'is' null instead of isNotNull
      final serviceResponse = await _supabase
          .from('profile_gallery_service_likes_view')
          .select('''
          service_id, service_created_at, service_title, service_description, 
          service_price, service_category
        ''')
          .eq('user_id', widget.userId)
          .not('service_id', 'is', null) // Correct way to check for non-null
          .order('service_created_at', ascending: false);

      // Manual deduplication based on service_id
      final Map<String, Map<String, dynamic>> uniqueServiceItems = {};
      for (var item in serviceResponse) {
        if (item['service_id'] != null) {
          uniqueServiceItems[item['service_id'].toString()] = item;
        }
      }

      safeSetState(() {
        _profileData = profile;
        _isPrivate = isPrivate;
        _galleryItems = uniqueGalleryItems.values.toList();
        _serviceItems = uniqueServiceItems.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
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
      debugPrint('Error checking follow status: $e');
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

  void _navigateToFollowers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          userId: widget.userId,
          isFollowers: true,
          userName: _profileData?['name'] ?? 'User',
        ),
      ),
    );
  }

  // void _showGalleryItemDetails(Map<String, dynamic> item) {
  //   // Show gallery item details
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) => DraggableScrollableSheet(
  //       initialChildSize: 0.8,
  //       maxChildSize: 0.9,
  //       minChildSize: 0.5,
  //       expand: false,
  //       builder: (context, scrollController) => SingleChildScrollView(
  //         controller: scrollController,
  //         child: GalleryItemDetails(
  //           item: item,
  //           buttonColor: _profileData != null &&
  //                   _profileData!['button_color_code'] != null
  //               ? Color(int.parse(
  //                   'FF${_profileData!['button_color_code'].substring(1)}',
  //                   radix: 16))
  //               : Theme.of(context).primaryColor,
  //           buttonTextColor: _profileData != null &&
  //                   _profileData!['button_text_color'] != null
  //               ? Color(int.parse(
  //                   'FF${_profileData!['button_text_color'].substring(1)}',
  //                   radix: 16))
  //               : Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Color ensureContrast(Color fg, Color bg, {bool isButton = true}) {
      double getLuminance(Color color) {
        double r = color.r;
        double g = color.g;
        double b = color.b;
        r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
        g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
        b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
      }

      double l1 = getLuminance(fg);
      double l2 = getLuminance(bg);
      double ratio = (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);

      if (ratio < 2.0) {
        bool bgIsDark = l2 < 0.2;
        if (bgIsDark) {
          return isButton ? const Color(0xFFFFD600) : Colors.white;
        } else {
          return isButton ? const Color(0xFF1E293B) : Colors.black87;
        }
      }
      return fg;
    }

    Color bgColor = _profileData != null &&
            _profileData!['bg_color_code'] != null
        ? Color(int.parse('FF${_profileData!['bg_color_code'].substring(1)}',
            radix: 16))
        : Colors.white;

    Color rawButtonColor =
        _profileData != null && _profileData!['button_color_code'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_color_code'].substring(1)}',
                radix: 16))
            : Theme.of(context).primaryColor;
    Color buttonColor = ensureContrast(rawButtonColor, bgColor, isButton: true);

    Color rawButtonTextColor =
        _profileData != null && _profileData!['button_text_color'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_text_color'].substring(1)}',
                radix: 16))
            : Colors.white;
    Color buttonTextColor = ensureContrast(rawButtonTextColor, buttonColor, isButton: false);

    Color rawBgTextColor = _profileData != null &&
            _profileData!['bg_text_color'] != null
        ? Color(int.parse('FF${_profileData!['bg_text_color'].substring(1)}',
            radix: 16))
        : Colors.black;
    Color bgTextColor = ensureContrast(rawBgTextColor, bgColor, isButton: false);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          _profileData?['name'] ?? 'Profile',
          style: TextStyle(color: bgTextColor),
        ),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: bgTextColor),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profileData == null
              ? const Center(child: Text('Profile not found'))
              : Stack(
                  children: [
                    Column(
                      children: [
                        // Profile Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Banner Image
                              if (_profileData!['banner_image_url'] != null)
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        _profileData!['banner_image_url'],
                                      ),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),

                              // Profile Image
                              // CircleAvatar(
                              //   radius: 50,
                              //   backgroundImage:
                              //       _profileData!['profile_image_url'] != null
                              //           ? CachedNetworkImageProvider(
                              //               _profileData!['profile_image_url'])
                              //           : null,
                              //   child:
                              //       _profileData!['profile_image_url'] == null
                              //           ? Icon(Icons.person, size: 50)
                              //           : null,
                              // ),

                              const SizedBox(height: 16),

                              // Name
                              Text(
                                _profileData!['name'] ?? 'No Name',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: bgTextColor,
                                ),
                              ),

                              // Shop Name
                              if (_profileData!['shop_name'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _profileData!['shop_name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: bgTextColor.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),

                              // Location
                              if (_profileData!['city'] != null ||
                                  _profileData!['country'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 16,
                                          color: bgTextColor.withValues(
                                              alpha: 0.7)),
                                      const SizedBox(width: 4),
                                      Text(
                                        [
                                          _profileData!['city'],
                                          _profileData!['state'],
                                          _profileData!['country']
                                        ]
                                            .where((item) => item != null)
                                            .join(', '),
                                        style: TextStyle(
                                          color: bgTextColor.withValues(
                                              alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Bio
                              if (_profileData!['bio'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    _profileData!['bio'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: bgTextColor),
                                  ),
                                ),

                              // Contact Button
                              if (!(_isPrivate && !_isFollowing && widget.userId != _supabase.auth.currentUser?.id))
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _navigateToMessages();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      foregroundColor: buttonTextColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Contact'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        FollowButton(
                          initialIsFollowing: _isFollowing,
                          userId: widget.userId,
                        ),
                        GestureDetector(
                          onTap: _navigateToFollowers,
                          child: Column(
                            children: [
                              Text(
                                _followersCount.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: bgTextColor,
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  color: bgTextColor.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tab Bar
                        if (!(_isPrivate && !_isFollowing && widget.userId != _supabase.auth.currentUser?.id))
                          TabBar(
                            controller: _tabController,
                            labelColor: bgTextColor,
                            indicatorColor: buttonColor,
                            tabs: const [
                              Tab(text: 'Gallery'),
                              Tab(text: 'Services'),
                            ],
                          ),

                        // Tab Content
                        Expanded(
                          child: (_isPrivate && !_isFollowing && widget.userId != _supabase.auth.currentUser?.id)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: buttonColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock_outline_rounded,
                                          color: buttonColor,
                                          size: 48,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'This account is private',
                                        style: TextStyle(
                                          color: bgTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Follow this user to see their photos and services.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: bgTextColor.withValues(alpha: 0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : TabBarView(
                                  controller: _tabController,
                                  children: [
                              _galleryItems.isEmpty
                                  ? Center(
                                      child: Text('No gallery items',
                                          style: TextStyle(color: bgTextColor)))
                                  : LayoutBuilder(builder: (context, constraints) {
                                      int getCrossAxisCount(double width) {
                                        if (width > 1200) return 6;
                                        if (width > 900) return 5;
                                        if (width > 600) return 4;
                                        return 3;
                                      }
                                      final crossAxisCount = getCrossAxisCount(constraints.maxWidth);
                                      return GridView.builder(
                                        padding: const EdgeInsets.all(8),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 4,
                                          mainAxisSpacing: 4,
                                        ),
                                        itemCount: _galleryItems.length,
                                        itemBuilder: (context, index) {
                                          final item = _galleryItems[index];
                                          return GestureDetector(
                                            onTap: () {
                                              // Show gallery item details
                                              // _showGalleryItemDetails(item);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    item['gallery_image_url'] ??
                                                        '',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }),

                              // Services Tab
                              _serviceItems.isEmpty
                                  ? Center(
                                      child: Text('No services',
                                          style: TextStyle(color: bgTextColor)))
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: _serviceItems.length,
                                      itemBuilder: (context, index) {
                                        final service = _serviceItems[index];
                                        return Card(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      service['service_title'] ??
                                                          'No Title',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Chip(
                                                      label: Text(
                                                        '\$${service['service_price'] ?? 0}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          buttonColor,
                                                    ),
                                                  ],
                                                ),
                                                if (service[
                                                        'service_category'] !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4.0),
                                                    child: Text(
                                                      service[
                                                          'service_category'],
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                if (service[
                                                        'service_description'] !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(service[
                                                        'service_description']),
                                                  ),
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      // Handle service booking
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Booking functionality to be implemented')),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          buttonColor,
                                                      foregroundColor:
                                                          buttonTextColor,
                                                    ),
                                                    child:
                                                        const Text('Book Now'),
                                                  ),
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
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(
                              color: bgColor,
                              width: 6.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: 130.0,
                          height: 130.0,
                          clipBehavior: Clip.antiAlias,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                _profileData!['profile_image_url'] != null
                                    ? CachedNetworkImageProvider(
                                        _profileData!['profile_image_url'])
                                    : null,
                            child: _profileData!['profile_image_url'] == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

class MarketSearchResultsWidget extends StatefulWidget {
  final String searchQuery;

  const MarketSearchResultsWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  State<MarketSearchResultsWidget> createState() => _MarketSearchResultsWidgetState();
}

class _MarketSearchResultsWidgetState extends State<MarketSearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();
  final _supabase = SupaFlow.client;

  List<Map<String, dynamic>> _marketResults = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 16;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _performMarketSearch(widget.searchQuery);
  }

  @override
  void didUpdateWidget(MarketSearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _performMarketSearch(widget.searchQuery);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreMarketItems();
      }
    }
  }

  Future<void> _performMarketSearch(String query) async {
    safeSetState(() {
      _isLoading = true;
      _currentPage = 0;
      _marketResults.clear();
      _hasMoreData = true;
      _currentQuery = query;
    });

    final trimmed = query.trim();
    try {
      var queryBuilder = _supabase
          .from('gallery')
          .select('*, profile(name, verified, profile_image_url, learning_day, avatar_config)');

      List<dynamic> response;
      if (trimmed.isEmpty) {
        response = await queryBuilder
            .order('created_at', ascending: false)
            .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      } else {
        response = await queryBuilder
            .ilike('title', '%$trimmed%')
            .order('created_at', ascending: false)
            .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      }

      if (mounted) {
        safeSetState(() {
          _marketResults = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
          _hasMoreData = response.length == _pageSize;
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('Market search error: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreMarketItems() async {
    if (_isLoadingMore || !_hasMoreData) return;

    safeSetState(() {
      _isLoadingMore = true;
    });

    final trimmed = _currentQuery.trim();
    try {
      var queryBuilder = _supabase
          .from('gallery')
          .select('*, profile(name, verified, profile_image_url, learning_day, avatar_config)');

      List<dynamic> response;
      if (trimmed.isEmpty) {
        response = await queryBuilder
            .order('created_at', ascending: false)
            .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      } else {
        response = await queryBuilder
            .ilike('title', '%$trimmed%')
            .order('created_at', ascending: false)
            .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      }

      if (mounted) {
        safeSetState(() {
          _marketResults.addAll(List<Map<String, dynamic>>.from(response));
          _isLoadingMore = false;
          _hasMoreData = response.length == _pageSize;
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('Error loading more market items: $e');
      if (mounted) {
        safeSetState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  static const List<Color> _cardAccentPalette = [
    Color(0xFFFF5252), // Vibrant Coral / Red
    Color(0xFFFFD124), // Cyber Yellow / Amber
    Color(0xFF00E676), // Neon Emerald Green
    Color(0xFF00D2FF), // Electric Sky Blue
    Color(0xFFA855F7), // Neon Purple / Violet
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFFFC00),
          ),
        ),
      );
    }

    if (_marketResults.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _performMarketSearch(_currentQuery),
        color: const Color(0xFFFFFC00),
        backgroundColor: const Color(0xFF161822),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                      border: Border.all(color: Colors.white12, width: 0.8),
                    ),
                    child: const Icon(Icons.storefront_outlined, color: Colors.white38, size: 36),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No products found',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pull down to refresh or try another search',
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int cols = width >= 1200 ? 6 : (width >= 900 ? 5 : (width >= 600 ? 4 : 3));

        return RefreshIndicator(
          onRefresh: () => _performMarketSearch(_currentQuery),
          color: const Color(0xFFFFFC00),
          backgroundColor: const Color(0xFF161822),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            itemCount: _marketResults.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _marketResults.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Color(0xFFFFFC00), strokeWidth: 2),
                    ),
                  ),
                );
              }

              final item = _marketResults[index];
              final accentColor = _cardAccentPalette[index % _cardAccentPalette.length];
              final imageUrl = item['gallery_image_url'] ?? item['image_url'];
              final title = item['gallery_title'] ?? item['title'] ?? 'Product';
              final price = item['gallery_price'] ?? item['price'];
              final profile = item['profile'] as Map<String, dynamic>?;
              final sellerName = profile?['name'] ?? item['name'] ?? 'Creator';
              final sellerDay = (profile?['learning_day'] as num?)?.toInt() ?? 1;

              final VectorAvatarConfig sellerAvatar = (profile?['avatar_config'] != null)
                  ? VectorAvatarConfig.fromMap(Map<String, dynamic>.from(profile!['avatar_config']))
                  : VectorAvatarConfig.getEvolutionAvatarForStage(sellerDay);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryDetailsPage(
                        item: item,
                        allItems: _marketResults,
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
                    children: [
                      // Thumbnail
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl != null && imageUrl.toString().isNotEmpty)
                              CachedNetworkImage(
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
                            else
                              Container(
                                color: accentColor.withValues(alpha: 0.06),
                                child: Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 22,
                                    color: accentColor.withValues(alpha: 0.4),
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
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Minimal Info Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
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
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ClipOval(
                                  child: VectorAvatarWidget(
                                    config: sellerAvatar,
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    sellerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 9.5,
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
            },
          ),
        );
      },
    );
  }
}

