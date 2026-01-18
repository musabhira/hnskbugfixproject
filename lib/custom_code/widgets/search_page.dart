// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/verfied_swtich_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:timeago/timeago.dart' as timeago;

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
          .ilike('name', '%$query%')
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
            .ilike('name', '%$_currentQuery%')
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
  DateTime? _firstFollowTimestamp;
  final _supabase = SupaFlow.client;
  int _followersCount = 0;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
    _firstFollowTimestamp = widget.firstFollowTimestamp;
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
          // Set _firstFollowTimestamp if available
          if (existingFollow['first_followed_at'] != null) {
            _firstFollowTimestamp =
                DateTime.parse(existingFollow['first_followed_at']);
          }
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
        safeSetState(() {
          _firstFollowTimestamp = null;
        });
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
          safeSetState(() {
            _firstFollowTimestamp = DateTime.now();
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
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status: $e')),
      );
    }
  }

  String _formatFirstFollowDate() {
    if (_firstFollowTimestamp == null) return '';
    return DateFormat('MMM d, yyyy').format(_firstFollowTimestamp!);
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
            ? _getButtonColor().withOpacity(0.5)
            : _getButtonColor(),
        side: BorderSide(
          color: _isFollowing
              ? _getButtonColor().withOpacity(0.5)
              : _getButtonColor(),
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: _isFollowing
            ? _getButtonColor().withOpacity(0.1)
            : _getButtonColor().withOpacity(0.1),
      ),
    );
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
  int _followingCount = 0;
  int _galleryCount = 0;
  int _serviceCount = 0;
  bool _isFollowing = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileData();
    _checkFollowStatus();
    _fetchFollowCounts();
    _checkIfCurrentUser();
  }

  void _checkIfCurrentUser() {
    final currentUserId = _supabase.auth.currentUser?.id;
    safeSetState(() {
      _isCurrentUser = currentUserId == widget.userId;
    });
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
        _followingCount = followResponse['following_count'] ?? 0;
        _galleryCount = followResponse['gallery_count'] ?? 0;
        _serviceCount = followResponse['service_count'] ?? 0;
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

  Future<void> _toggleFollow() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to follow users')),
      );
      return;
    }

    try {
      if (_isFollowing) {
        // Unfollow
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('followed_id', widget.userId);
      } else {
        // Follow
        await _supabase.from('follows').insert({
          'follower_id': currentUserId,
          'followed_id': widget.userId,
        });
      }

      // Update state
      safeSetState(() {
        _isFollowing = !_isFollowing;
        _followersCount =
            _isFollowing ? _followersCount + 1 : _followersCount - 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status: $e')),
      );
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

  void _navigateToFollowing() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          userId: widget.userId,
          isFollowers: false,
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
                                      color: bgTextColor.withOpacity(0.8),
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
                                          color: bgTextColor.withOpacity(0.7)),
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
                                          color: bgTextColor.withOpacity(0.7),
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
                                  color: bgTextColor.withOpacity(0.7),
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

  void _showGalleryItemDetailss(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery Image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      item['gallery_image_url'] ??
                          'https://via.placeholder.com/400',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Gallery Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['gallery_title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (item['gallery_price'] != null)
                        Chip(
                          label: Text(
                            '\$${item['gallery_price']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _profileData != null &&
                                  _profileData!['button_color_code'] != null
                              ? Color(int.parse(
                                  'FF${_profileData!['button_color_code'].substring(1)}',
                                  radix: 16))
                              : Theme.of(context).primaryColor,
                        ),
                    ],
                  ),

                  if (item['gallery_category'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        item['gallery_category'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),

                  if (item['gallery_description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        item['gallery_description'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle like functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Like functionality to be implemented')),
                            );
                          },
                          icon: Icon(
                            item['like_id'] != null
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item['like_id'] != null ? Colors.red : null,
                          ),
                          label: const Text('Like'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Share functionality to be implemented')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: _profileData != null &&
                                    _profileData!['button_color_code'] != null
                                ? Color(int.parse(
                                    'FF${_profileData!['button_color_code'].substring(1)}',
                                    radix: 16))
                                : Theme.of(context).primaryColor,
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// MessageScreen.dart
class MessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverProfileImage;
  final String? phonenumber;

  const MessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfileImage,
    this.phonenumber,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;
  late String _senderId;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool isLoading = true;
  Map<String, dynamic>? hideData;
  Timer? _messageRefreshTimer;
  final StreamController<List<Map<String, dynamic>>> _messagesStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Block functionality variables
  bool _isBlocked = false;
  bool _isBlockedByOther = false;
  bool _checkingBlockStatus = true;
  DateTime? _blockTime;
  DateTime? _blockedByOtherTime;

  @override
  void initState() {
    super.initState();
    _senderId = _supabase.auth.currentUser!.id;
    _checkBlockStatus();
    _loadMessages();
    _setupMessageStream();
    _markNotificationsAsRead();
    fetchHideStatus();
  }

  // Enhanced block status check with time tracking
  Future<void> _checkBlockStatus() async {
    try {
      setState(() {
        _checkingBlockStatus = true;
      });

      // Check if current user blocked the receiver
      final blockedByMe = await _supabase
          .from('blocks')
          .select('created_at')
          .eq('blocker_id', _senderId)
          .eq('blocked_id', widget.receiverId)
          .limit(1);

      // Check if receiver blocked the current user
      final blockedByOther = await _supabase
          .from('blocks')
          .select('created_at')
          .eq('blocker_id', widget.receiverId)
          .eq('blocked_id', _senderId)
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

  // Block user function
  Future<void> _blockUser() async {
    try {
      await _supabase.rpc('block_user', params: {
        'target_user_id': widget.receiverId,
      });

      _showSuccessSnackBar('User blocked successfully');
      _checkBlockStatus();
    } catch (e) {
      debugPrint('Error blocking user: $e');
      _showErrorSnackBar('Failed to block user');
    }
  }

  // Unblock user function
  Future<void> _unblockUser() async {
    try {
      await _supabase.rpc('unblock_user', params: {
        'target_user_id': widget.receiverId,
      });

      _showSuccessSnackBar('User unblocked successfully');
      _checkBlockStatus();
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      _showErrorSnackBar('Failed to unblock user');
    }
  }

  // Enhanced block dialog with time information
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
                    ? 'Are you sure you want to unblock ${widget.receiverName}?'
                    : 'Are you sure you want to block ${widget.receiverName}? You won\'t be able to send or receive messages.',
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

  // Format block time for display
  String _formatBlockTime(DateTime blockTime) {
    final now = DateTime.now();
    final difference = now.difference(blockTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _setupMessageStream() {
    _messageRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isBlocked && !_isBlockedByOther) {
        _loadMessages();
      }
    });
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      await _supabase
          .from('message_notifications')
          .update({'is_read': true})
          .eq('user_id', _senderId)
          .eq('sender_id', widget.receiverId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
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

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$_senderId,receiver_id.eq.${widget.receiverId}),and(sender_id.eq.${widget.receiverId},receiver_id.eq.$_senderId)')
          .order('created_at', ascending: false)
          .limit(50);

      final messagesList = List<Map<String, dynamic>>.from(response);

      _messagesStreamController.add(messagesList);

      if (mounted) {
        safeSetState(() {
          _messages = messagesList;
          _isLoading = false;
        });
      }

      // Mark messages as read only if not blocked
      if (!_isBlocked && !_isBlockedByOther) {
        await _supabase.from('messages').update({'is_read': true}).match({
          'sender_id': widget.receiverId,
          'receiver_id': _senderId,
          'is_read': false
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isBlocked || _isBlockedByOther) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await _supabase.from('messages').insert({
        'sender_id': _senderId,
        'receiver_id': widget.receiverId,
        'content': messageText,
      });

      _loadMessages();

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _makePhoneCall() async {
    // Don't allow phone calls if either party is blocked
    if (_isBlocked || _isBlockedByOther) {
      _showErrorSnackBar('Cannot make phone call to blocked user');
      return;
    }

    try {
      final phoneNumber = widget.phonenumber;

      if (phoneNumber == null || phoneNumber.toString().isEmpty) {
        _showErrorSnackBar('Phone number not available');
        return;
      }

      String cleanNumber =
          phoneNumber.toString().replaceAll(RegExp(r'[^\d+]'), '');

      final phoneUrl = 'tel:$cleanNumber';
      final Uri uri = Uri.parse(phoneUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('Unable to make phone call');
      }
    } catch (e) {
      _showErrorSnackBar('Error making phone call: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageRefreshTimer?.cancel();
    _messagesStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerfiedSwitchPage(userId: widget.receiverId),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.receiverProfileImage != null
                    ? NetworkImage(widget.receiverProfileImage!)
                    : null,
                backgroundColor: Colors.blue.shade100,
                child: widget.receiverProfileImage == null
                    ? Text(
                        widget.receiverName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isBlocked
                        ? 'Blocked ${_blockTime != null ? _formatBlockTime(_blockTime!) : ''}'
                        : (_isBlockedByOther
                            ? 'Blocked you ${_blockedByOtherTime != null ? _formatBlockTime(_blockedByOtherTime!) : ''}'
                            : 'Online'),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isBlocked || _isBlockedByOther
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!_checkingBlockStatus)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: Colors.grey[800],
              onSelected: (value) {
                if (value == 'block' || value == 'unblock') {
                  _showBlockDialog();
                } else if (value == 'report') {
                  ReportHelper.showReportDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    contentType: 'chat',
                    contentId: widget.receiverId.toString(),
                    contentTitle: widget.receiverName,
                    onReportSubmitted: () {
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
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: _isBlocked ? 'unblock' : 'block',
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
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        'Report',
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          // Hide phone call button if either party is blocked or if hide functionality is enabled
          if (!_isBlocked &&
              !_isBlockedByOther &&
              !(hideData != null && hideData?['is_hidden'] == true))
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: _makePhoneCall,
              tooltip: 'Make Phone Call',
              iconSize: 24,
              color: Colors.green,
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // ✅ hide keyboard
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 32, 31, 31),
          ),
          child: Column(
            children: [
              Expanded(
                child: _checkingBlockStatus
                    ? const Center(child: CircularProgressIndicator())
                    : _isBlockedByOther
                        ? _buildBlockedByOtherView()
                        : _isBlocked
                            ? _buildBlockedView()
                            : _buildMessagesView(),
              ),
              // Only show input field if not blocked by either party
              if (!_isBlocked && !_isBlockedByOther)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.yellow,
                          onPressed: () {},
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 31, 27, 27),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.white),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                              ),
                              style: const TextStyle(color: Colors.white),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: Colors.yellow,
                          onPressed: _sendMessage,
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

  Widget _buildBlockedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.block,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Blocked Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have blocked ${widget.receiverName}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          if (_blockTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Blocked ${_formatBlockTime(_blockTime!)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Messages and calls are disabled',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _unblockUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Unblock User',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          const Icon(
            Icons.block,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Blocked Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This user has blocked you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          if (_blockedByOtherTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Blocked ${_formatBlockTime(_blockedByOtherTime!)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'You cannot send or receive messages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Phone calls are also disabled',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesView() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: _messagesStreamController.stream,
            initialData: _messages,
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_rounded,
                        size: 80,
                        color: Color.fromARGB(255, 208, 207, 207),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 164, 164, 164),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start a conversation!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 206, 206, 206),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message['sender_id'] == _senderId;
                  final time = timeago.format(
                      DateTime.parse(message['created_at']),
                      locale: 'en_short');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.receiverProfileImage != null
                                ? NetworkImage(widget.receiverProfileImage!)
                                : null,
                            backgroundColor: Colors.blue.shade100,
                            child: widget.receiverProfileImage == null
                                ? Text(
                                    widget.receiverName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        if (!isMe) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: isMe
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFf093fb),
                                        Color(0xFFf5576c),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(24),
                                topRight: const Radius.circular(24),
                                bottomLeft: isMe
                                    ? const Radius.circular(24)
                                    : const Radius.circular(6),
                                bottomRight: isMe
                                    ? const Radius.circular(6)
                                    : const Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isMe
                                      ? const Color(0xFF667eea).withOpacity(0.3)
                                      : const Color(0xFFf093fb)
                                          .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        message['is_read'] == true
                                            ? Icons.done_all_rounded
                                            : Icons.done_rounded,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe) const SizedBox(width: 8),
                        if (isMe)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: null,
                            backgroundColor: Colors.blue.shade100,
                            child: const Text(
                              'M',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
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
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

class FollowersScreen extends StatefulWidget {
  final String userId;
  final bool isFollowers;
  final String userName;

  const FollowersScreen({
    super.key,
    required this.userId,
    required this.isFollowers,
    required this.userName,
  });

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final _supabase = Supabase.instance.client;
  late String _currentUserId;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> response;

      if (widget.isFollowers) {
        // Load followers (people who follow this user)
        response = await _supabase
            .from('follows')
            .select('follower_id, profiles:follower_id(*)')
            .eq('following_id', widget.userId);

        _users = response
            .map((item) => item['profiles'] as Map<String, dynamic>)
            .toList();
      } else {
        // Load following (people this user follows)
        response = await _supabase
            .from('follows')
            .select('following_id, profiles:following_id(*)')
            .eq('follower_id', widget.userId);

        _users = response
            .map((item) => item['profiles'] as Map<String, dynamic>)
            .toList();
      }

      // Also fetch follow status for each user
      for (var user in _users) {
        final followStatus = await _supabase
            .from('follows')
            .select()
            .eq('follower_id', _currentUserId)
            .eq('following_id', user['id'])
            .maybeSingle();

        user['is_following'] = followStatus != null;
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow(String userId, bool currentlyFollowing) async {
    try {
      if (currentlyFollowing) {
        // Unfollow user
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', _currentUserId)
            .eq('following_id', userId);
      } else {
        // Follow user
        await _supabase.from('follows').insert({
          'follower_id': _currentUserId,
          'following_id': userId,
        });
      }

      // Update local state
      safeSetState(() {
        for (var user in _users) {
          if (user['id'] == userId) {
            user['is_following'] = !currentlyFollowing;
            break;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final username = user['username']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          username.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.isFollowers ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.userName}\'s Connections'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
            onTap: (index) {
              if ((index == 0 && !widget.isFollowers) ||
                  (index == 1 && widget.isFollowers)) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => FollowersScreen(
                      userId: widget.userId,
                      isFollowers: index == 0,
                      userName: widget.userName,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search ${widget.isFollowers ? 'followers' : 'following'}',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  safeSetState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // User list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isFollowers
                                    ? Icons.people_outline
                                    : Icons.person_outline,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No users found'
                                    : widget.isFollowers
                                        ? 'No followers yet'
                                        : 'Not following anyone yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final isCurrentUser =
                                  user['id'] == _currentUserId;
                              final isFollowing = user['is_following'] ?? false;

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: user['avatar_url'] != null
                                      ? NetworkImage(user['avatar_url'])
                                      : null,
                                  backgroundColor: Colors.blue.shade100,
                                  child: user['avatar_url'] == null
                                      ? Text(
                                          (user['name'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  user['name'] ?? 'User',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('@${user['username'] ?? ''}'),
                                trailing: isCurrentUser
                                    ? const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : OutlinedButton(
                                        onPressed: () => _toggleFollow(
                                            user['id'], isFollowing),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: isFollowing
                                              ? Colors.white
                                              : Colors.blue,
                                          side: BorderSide(
                                            color: isFollowing
                                                ? Colors.grey.shade300
                                                : Colors.blue,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          minimumSize: const Size(100, 36),
                                        ),
                                        child: Text(
                                          isFollowing ? 'Following' : 'Follow',
                                          style: TextStyle(
                                            color: isFollowing
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                onTap: () {
                                  // Navigate to user profile
                                  // Add your navigation code here
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final _supabase = SupaFlow.client;
  late String _currentUserId;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser!.id;
    _loadConversations();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    try {
      // First get conversations
      final conversationsResponse = await _supabase
          .from('conversations')
          .select('*')
          .or('user1_id.eq.$_currentUserId,user2_id.eq.$_currentUserId')
          .order('updated_at', ascending: false);

      // Get user IDs from conversations
      final userIds = <String>{};
      for (final conv in conversationsResponse) {
        userIds.add(conv['user1_id']);
        userIds.add(conv['user2_id']);
      }

      // Get profiles for all users
      final profilesResponse = await _supabase
          .from('profile')
          .select('user_id, name, shop_name, profile_image_url')
          .inFilter('user_id', userIds.toList());

      // Create a map for quick lookup
      final profileMap = <String, Map<String, dynamic>>{};
      for (final profile in profilesResponse) {
        profileMap[profile['user_id']] = profile;
      }

      // Combine conversations with profile data
      final conversations = conversationsResponse.map((conv) {
        return {
          ...conv,
          'user1_profile': profileMap[conv['user1_id']],
          'user2_profile': profileMap[conv['user2_id']],
        };
      }).toList();
      print(_conversations);
      if (mounted) {
        safeSetState(() {
          _conversations = conversations;
          print(_conversations);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getOtherUser(Map<String, dynamic> conversation) {
    final isUser1 = conversation['user1_id'] == _currentUserId;
    if (isUser1) {
      return {
        'id': conversation['user2_id'],
        'name': conversation['user2_profile']?['name'] ??
            conversation['user2_profile']?['shop_name'] ??
            'Unknown',
        'avatar': conversation['user2_profile']?['profile_image_url'],
        'phonenumber': conversation['user2_profile']?['phone_no'],
      };
    } else {
      return {
        'id': conversation['user1_id'],
        'name': conversation['user1_profile']?['name'] ??
            conversation['user1_profile']?['shop_name'] ??
            'Unknown',
        'avatar': conversation['user1_profile']?['profile_image_url'],
        'phonenumber': conversation['user1_profile']?['phone_no'],
      };
    }
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      // Delete conversation and related notifications
      await _supabase.from('conversations').delete().eq('id', conversationId);
      await _supabase
          .from('message_notifications')
          .delete()
          .eq('conversation_id', conversationId);

      // Refresh the list
      _loadConversations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting conversation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToMessageScreen(Map<String, dynamic> otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          receiverId: otherUser['id'],
          receiverName: otherUser['name'],
          receiverProfileImage: otherUser['avatar'],
          phonenumber:
              otherUser['phonenumber'], // Add phone number if available
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 80,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start messaging with someone!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    final otherUser = _getOtherUser(conversation);
                    final isUnread = (conversation['unread_count'] ?? 0) > 0;
                    final lastMessageTime = conversation['last_message_time'] !=
                            null
                        ? timeago.format(
                            DateTime.parse(conversation['last_message_time']))
                        : '';

                    return Dismissible(
                      key: Key(conversation['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text(
                              'Delete Conversation',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this conversation?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.yellow),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _deleteConversation(conversation['id']);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: otherUser['avatar'] != null
                                ? NetworkImage(otherUser['avatar'])
                                : null,
                            backgroundColor: Colors.yellow.shade700,
                            child: otherUser['avatar'] == null
                                ? Text(
                                    otherUser['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            otherUser['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            conversation['last_message'] ?? 'No messages yet',
                            style: TextStyle(
                              color: isUnread
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                lastMessageTime,
                                style: TextStyle(
                                  color: isUnread
                                      ? Colors.yellow
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${conversation['unread_count']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _navigateToMessageScreen(otherUser),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
