// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';

import '/backend/supabase/supabase.dart';
import 'index.dart'; // Imports other custom widgets
// Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _currentSearchQuery = '';
  int _totalResults = 0;
  String _searchStatus = '';
  bool _hasSearched = false;
  List<String> _searchHistory = [];
  final Map<String, int> _searchAnalytics = {};

  void _handleSearchChanged(String query) {
    safeSetState(() {
      _currentSearchQuery = query;
    });
  }

  void _handleResultsChanged(List<Map<String, dynamic>> results) {
    safeSetState(() {
      _totalResults = results.length;
      _hasSearched = true;

      // Update search status message
      if (_currentSearchQuery.isEmpty) {
        _searchStatus = 'Showing latest profiles ($_totalResults found)';
      } else {
        _searchStatus = _totalResults > 0
            ? 'Found $_totalResults results for "$_currentSearchQuery"'
            : 'No results found for "$_currentSearchQuery"';
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

  void _logSearchAnalytics(String query, int resultCount) {
    // Example: Send to analytics service like Firebase Analytics, Mixpanel, etc.
    print(
        'Search Analytics: Query="$query", Results=$resultCount, Timestamp=${DateTime.now()}');

    // You can implement actual analytics here:
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'search_performed',
    //   parameters: {
    //     'search_query': query,
    //     'result_count': resultCount,
    //     'timestamp': DateTime.now().millisecondsSinceEpoch,
    //   },
    // );
  }

  void _saveSearchHistory() {
    // Example: Save to SharedPreferences or local database
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setStringList('search_history', _searchHistory);
    // });
    print('Search History Updated: $_searchHistory');
  }

  void _updatePopularSearches() {
    // Sort searches by frequency and get top 5
    var sortedSearches = _searchAnalytics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var popularSearches = sortedSearches.take(5).map((e) => e.key).toList();
    print('Popular Searches: $popularSearches');

    // You can use this data to show suggestions or trending searches
  }

  void _clearSearchHistory() {
    safeSetState(() {
      _searchHistory.clear();
      _searchAnalytics.clear();
    });
    _saveSearchHistory();
  }

  // Method to get search suggestions based on history
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return _searchHistory.take(5).toList();

    return _searchHistory
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Show search history button
          if (_searchHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                _showSearchHistoryDialog();
              },
            ),
          // Clear history button
          if (_searchHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                _showClearHistoryDialog();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchWidget(
            onSearchChanged: _handleSearchChanged,
          ),
          // Search status bar
          if (_hasSearched)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.grey[900],
              child: Text(
                _searchStatus,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Expanded(
            child: SearchResultsWidget(
              searchQuery: _currentSearchQuery,
              onResultsChanged: _handleResultsChanged,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.white),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.yellow,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 28, 25, 25),
        ),
        onChanged: (query) {
          widget.onSearchChanged(query);
        },
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInitialProfiles();
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
          .select('profile_image_url, shop_name, verified, user_id, name')
          .order('name', ascending: true)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      safeSetState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
        _hasMoreData = response.length == _pageSize;
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
      print('Error fetching profiles: $e');
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

    try {
      final response = await _supabase
          .from('profile')
          .select('profile_image_url, shop_name, verified, user_id, name')
          .or('name.ilike.%$query%,shop_name.ilike.%$query%,slug.ilike.%$query%')
          .order('name', ascending: true)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      safeSetState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
        _hasMoreData = response.length == _pageSize;
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
      print('Error searching profiles: $e');
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
            .select('profile_image_url, shop_name, verified, user_id, name')
            .order('name', ascending: true)
            .range(
                _currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      } else {
        response = await _supabase
            .from('profile')
            .select('profile_image_url, shop_name, verified, user_id, name')
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
      print('Error loading more profiles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          // Loading indicator at the bottom
          return _isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink();
        }

        final profile = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profile['profile_image_url'] != null
                ? CachedNetworkImageProvider(profile['profile_image_url'])
                : null,
            child: profile['profile_image_url'] == null
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                  )
                : null,
          ),
          title: Text(
            profile['name'] ?? 'No Name',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: profile['shop_name'] != null
              ? Text(
                  profile['shop_name'],
                  style: const TextStyle(color: Colors.grey),
                )
              : null,
          trailing: profile['verified'] == true
              ? const Icon(
                  Icons.verified,
                  color: Colors.yellow,
                  size: 20,
                )
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => profile['verified'] == true
                    ? VerfiedSwitchPage(userId: profile['user_id'])
                    : SearchProfileDetailPage(userId: profile['user_id']),
              ),
            );
            // if (profile['verified'] == true) {
            //   context.goNamed(
            //     VerfiedSwitchPage.routeName,
            //     pathParameters: {
            //       'userid': profile['user_id'],
            //     },
            //   );
            // } else {
            //   context.goNamed(
            //     SearchprofileuserWidget.routeName,
            //     pathParameters: {
            //       'userid': profile['user_id'],
            //     },
            //   );
            // }
          },
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

  const FollowButton({
    super.key,
    required this.userId,
    required this.initialIsFollowing,
    this.firstFollowTimestamp,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
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
      print("Error checking follow status: $e");
    }
  }

  Future<void> _toggleFollow() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to follow users')),
      );
      return;
    }

    safeSetState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        // Unfollow - delete the record
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('followed_id', widget.userId);

        // Reset first follow timestamp when unfollowing
        // safeSetState(() {
        //   _firstFollowTimestamp = null;
        // });
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

          // Update first follow timestamp
          // safeSetState(() {
          //   _firstFollowTimestamp = DateTime.now();
          // });
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
      print("$e");
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
      print('Error fetching follow counts: $e');
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
          .select('button_color_code, button_text_color')
          .eq('user_id', widget.userId)
          .limit(1);

      Map<String, dynamic>? buttonColors =
          buttonColorsResponse.isNotEmpty ? buttonColorsResponse.first : null;

      safeSetState(() {
        // Store button colors in _profileData
        _profileData = buttonColors ?? {};
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
    }
  }

  Map<String, dynamic>? _profileData;
  Color _getButtonColor() {
    // Debug print to check if button_color_code exists
    print('Profile data: $_profileData');
    print('Button color code: ${_profileData?['button_color_code']}');

    if (_profileData != null && _profileData!['button_color_code'] != null) {
      try {
        String colorCode = _profileData!['button_color_code'].toString();
        // Handle both formats: #FFFFFF and FFFFFF
        if (colorCode.startsWith('#')) {
          colorCode = colorCode.substring(1);
        }
        return Color(int.parse('FF$colorCode', radix: 16));
      } catch (e) {
        print('Error parsing color code: $e');
        return Theme.of(context).primaryColor;
      }
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    //  if (_isFollowing)
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _toggleFollow,
      icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
      label: Text(_isFollowing ? 'Following' : 'Follow'),
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
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
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
      print('Error fetching follow counts: $e');
    }
  }

  void _fetchProfileData() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
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
        _galleryItems = uniqueGalleryItems.values.toList();
        _serviceItems = uniqueServiceItems.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
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
      print('Error checking follow status: $e');
    }
  }

  void _navigateToMessages() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          receiverId: widget.userId,
          receiverName: _profileData?['name'] ?? 'User',
          receiverProfileImage: _profileData?['profile_image_url'],
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
    // Use profile's button and background colors if available
    Color buttonColor =
        _profileData != null && _profileData!['button_color_code'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_color_code'].substring(1)}',
                radix: 16))
            : Theme.of(context).primaryColor;

    Color bgColor = _profileData != null &&
            _profileData!['bg_color_code'] != null
        ? Color(int.parse('FF${_profileData!['bg_color_code'].substring(1)}',
            radix: 16))
        : Colors.white;

    Color buttonTextColor =
        _profileData != null && _profileData!['button_text_color'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_text_color'].substring(1)}',
                radix: 16))
            : Colors.white;

    Color bgTextColor = _profileData != null &&
            _profileData!['bg_text_color'] != null
        ? Color(int.parse('FF${_profileData!['bg_text_color'].substring(1)}',
            radix: 16))
        : Colors.black;

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
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _navigateToMessages();
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //       content: Text(
                                    //           'Contact functionality to be implemented')),
                                    // );
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
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _galleryItems.isEmpty
                                  ? Center(
                                      child: Text('No gallery items',
                                          style: TextStyle(color: bgTextColor)))
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(8),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
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
                                                      'https://via.placeholder.com/150',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

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
