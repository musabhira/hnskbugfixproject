import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_buttom.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_custom_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/features/profile/data/profile_repository.dart';

class MainProfileWidget extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const MainProfileWidget({
    super.key,
    required this.width,
    required this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  });

  @override
  ConsumerState<MainProfileWidget> createState() => _MainProfileWidgetState();
}

class _MainProfileWidgetState extends ConsumerState<MainProfileWidget>
    with TickerProviderStateMixin {
  late TabController _tabBarController;
  Color? _selectedColor;
  String? _colorCode;
  Color? _selectedColor1;
  String? _colorCode1;
  Color? _selectedColor2;
  String? _colorCode2;
  Color? _selectedColor3;
  String? _colorCode3;
  int _totalCoins = 0;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Uint8List? _selectedImageBytes;
  final _supabase = SupaFlow.client;
  String? _currentUserId;
  bool _isLoading = false;

  String? _imageUrl;
  String? _imageUrlShowcase;
  String? titleshowcase;
  String? descriptionshowcase;
  String? category;
  bool isPremium = false;
  String? priceshowcase;
  String? profileId;
  Uint8List? _selectedImageBytesBanner;
  String? _imageUrlBanner;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _PhoneNumberController = TextEditingController();
  final TextEditingController _BioController = TextEditingController();
  final List<Map<String, dynamic>> galleries = [];

  final int _galleryCount = 0;
  final int _serviceCount = 0;
  String _followersCountFormatted = '0';
  String _followingCountFormatted = '0';
  bool _hasMore = true;
  final int _limit = 10;
  int _offset = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;
  List<Map<String, dynamic>> userThreads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Don't block UI with isLoading = true initially
    isLoading = false;

    // Start data fetching in background, considering preloaded data
    _initData();

    // Initialize with preloaded data if available
    if (widget.preloadedProfile != null) {
      _applyPreloadedData();
    }
    if (widget.userThreads != null) {
      userThreads = widget.userThreads!;
    }
    if (widget.followersCount != null) {
      _followersCountFormatted = widget.followersCount!;
    }
    if (widget.followingCount != null) {
      _followingCountFormatted = widget.followingCount!;
    }

    _tabBarController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initData() async {
    await _getCurrentUser();

    // Create a list to track futures we need to await
    List<Future> futures = [];

    // Only fetch profile if not preloaded
    if (widget.preloadedProfile == null) {
      futures.add(_loadProfileData());
    }

    // Always load these as they might not be fully preloaded or need fresh data
    futures.add(_loadInitialData());
    futures.add(_loadGalleries());
    futures.add(galleryLengthlike());
    futures.add(_loadProfileDataServies());
    futures.add(_loadTotalCoins());

    // Only fetch threads if not provided
    if (widget.userThreads == null) {
      futures.add(_loadProfilethreadsData());
    }

    await Future.wait(futures);

    // Only fetch follow counts if not provided
    if (widget.followersCount == null || widget.followingCount == null) {
      fetchFollowCounts();
    }
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _applyPreloadedData() {
    final profile = widget.preloadedProfile!;
    safeSetState(() {
      profileId = profile['id']?.toString() ?? '';
      _nameController.text = profile['name']?.toString() ?? '';
      _imageUrl = profile['profile_image_url']?.toString() ?? '';
      _shopNameController.text = profile['shop_name']?.toString() ?? '';
      _PhoneNumberController.text = profile['phone_no']?.toString() ?? '';
      _BioController.text = profile['bio']?.toString() ?? '';
      selectedCountry = profile['country']?.toString() ?? '';
      selectedState = profile['state']?.toString() ?? '';
      selectedCity = profile['city']?.toString() ?? '';
      _colorCode = profile['bg_color_code']?.toString() ?? '';
      _colorCode1 = profile['bg_text_color']?.toString() ?? '';
      _colorCode2 = profile['button_color_code']?.toString() ?? '';
      _colorCode3 = profile['button_text_color']?.toString() ?? '';
      _imageUrlBanner = profile['banner_image_url']?.toString() ?? '';
      isPremium = profile['verified'] ?? false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    await _loadProfileDataShowcase(isInitialLoad: true);
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    } else {
      return count.toString();
    }
  }

  void fetchFollowCounts() async {
    try {
      // Get followers count - people who follow this user
      final followersResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', _currentUserId!);

      // Get following count - people this user follows
      final followingResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', _currentUserId!);

      // Get followers count from users table
      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', _currentUserId!)
          .single();

      final double userTableFollowers =
          userResponse['followers']?.toDouble() ?? 0.0;

      final int followersCountRaw =
          followersResponse.length + userTableFollowers.toInt();
      final int followingCountRaw = followingResponse.length;

      safeSetState(() {
        _followersCountFormatted = formatCount(followersCountRaw);
        _followingCountFormatted = formatCount(followingCountRaw);
        print('Followers count: $_followersCountFormatted');
        print('Following count: $_followingCountFormatted');
      });
    } catch (e) {
      print('Error fetching follow counts: $e');
    }
  }

  Future<void> _loadProfilethreadsData() async {
    safeSetState(() {
      isLoading = true;
    });

    try {
      // Fetch user threads
      final threads = await ref
          .read(profileRepositoryProvider)
          .fetchUserThreads(_currentUserId!);

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

  Future<void> _loadTotalCoins() async {
    try {
      final coins = await ref
          .read(profileRepositoryProvider)
          .fetchWatchSessionCoins(_currentUserId.toString());

      if (mounted) {
        setState(() => _totalCoins = coins);
      }
    } catch (e) {
      print('Error loading coins: $e');
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMore || _isLoading) return;
    _offset += _limit;
    await _loadProfileDataShowcase(isInitialLoad: false);
  }

  Future<void> _loadGalleries() async {
    safeSetState(() {
      _galleries = [];
    });
  }

  Future<void> _loadProfileData() async {
    try {
      // safeSetState(() => _isLoading = true);

      if (_currentUserId == null) return;

      final profileResponse = await ref
          .read(profileRepositoryProvider)
          .fetchUserProfile(_currentUserId!);
      print(profileResponse);
      if (profileResponse != null && mounted) {
        safeSetState(() {
          profileId = profileResponse['id'] ?? '';
          _nameController.text = profileResponse['name'] ?? '';
          _imageUrl = profileResponse['profile_image_url'] ?? '';
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _PhoneNumberController.text = profileResponse['phone_no'] ?? '';
          _BioController.text = profileResponse['bio'] ?? '';
          selectedCountry = profileResponse['country'] ?? '';
          selectedState = profileResponse['state'] ?? '';
          selectedCity = profileResponse['city'] ?? '';
          _colorCode = profileResponse['bg_color_code'] ?? '';
          _colorCode1 = profileResponse['bg_text_color'] ?? '';
          _colorCode2 = profileResponse['button_color_code'] ?? '';
          _colorCode3 = profileResponse['button_text_color'] ?? '';
          _imageUrlBanner = profileResponse['banner_image_url'] ?? '';
          isPremium = profileResponse['verified'] ?? false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        // safeSetState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfileDataServies() async {
    try {
      safeSetState(() => _isLoading = true);

      if (_currentUserId == null) return;

      final List<dynamic> profileResponse = await ref
          .read(profileRepositoryProvider)
          .fetchUserServices(_currentUserId!);

      if (profileResponse.isNotEmpty && mounted) {
        safeSetState(() {
          titleshowcase = profileResponse[0]['title'] ?? '';

          descriptionshowcase = profileResponse[0]['description'] ?? '';
          category = profileResponse[0]['category'] ?? '';
          priceshowcase = (profileResponse[0]['price'] ?? 0).toString();

          _service = profileResponse
              .map((gallery) => {
                    'id': gallery['id'],
                    'title': gallery['title'] ?? '',
                    'description': gallery['description'] ?? '',
                    'category': gallery['category'] ?? '',
                    'price': gallery['price'] ?? '',
                  })
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error details: $error');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  bool safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      // Handle string representations of boolean
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      // Handle numeric representations (0 = false, non-zero = true)
      return value != 0;
    }

    return false;
  }

  Future<void> galleryLengthlike() async {
    try {
      if (!mounted) return;
      // safeSetState(() => _isLoading = true);

      if (_currentUserId == null) {
        if (mounted) safeSetState(() => _isLoading = false);
        return;
      }
      final response = await ref
          .read(profileRepositoryProvider)
          .fetchGalleriesWithSocialData(_currentUserId!, _currentUserId!);

      if (!mounted) return;

      final List<dynamic> profileResponse = response;

      safeSetState(() {
        if (profileResponse.isNotEmpty) {
          final firstItem = profileResponse[0];
          titleshowcase = firstItem['title']?.toString() ?? '';
          descriptionshowcase = firstItem['description']?.toString() ?? '';
          category = firstItem['category']?.toString() ?? '';
          priceshowcase = firstItem['price']?.toString() ?? '0';
        }

        _gallerieslist = profileResponse.map<Map<String, dynamic>>((gallery) {
          // Explicitly convert is_liked to a boolean
          bool liked = false;
          if (gallery['is_liked'] == true) {
            liked = true;
          }

          return {
            'id': gallery['id'],
            'title': gallery['title']?.toString() ?? '',
            'image_url': gallery['image_url']?.toString() ?? '',
            'description': gallery['description']?.toString() ?? '',
            'category': gallery['category']?.toString() ?? '',
            'price': gallery['price']?.toString() ?? '0',
            'like_count':
                int.tryParse(gallery['like_count']?.toString() ?? '0') ?? 0,
            'comment_count':
                int.tryParse(gallery['comment_count']?.toString() ?? '0') ?? 0,
            'is_liked': gallery['is_liked'],
            'user_id': gallery['user_id'],
            'username': gallery['username']?.toString() ?? 'Anonymous',
            'user_avatar': gallery['user_avatar']?.toString() ?? '',
          };
        }).toList();
        print(_gallerieslist);
      });
    } catch (error) {
      if (mounted) {
        print('Error details: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading galleries: $error'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error details: $error');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  Future<void> gallerylength() async {
    try {
      safeSetState(() => _isLoading = true);

      if (_currentUserId == null) return;

      final List<dynamic> profileResponse = await _supabase
          .from('gallery')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      if (profileResponse.isNotEmpty && mounted) {
        safeSetState(() {
          // You can either use the first item
          titleshowcase = profileResponse[0]['title'] ?? '';

          descriptionshowcase = profileResponse[0]['description'] ?? '';
          category = profileResponse[0]['category'] ?? '';
          priceshowcase = (profileResponse[0]['price'] ?? 0).toString();
          // Or store all items if you need to display multiple galleries
          _gallerieslist = profileResponse
              .map((gallery) => {
                    'id': gallery['id'],
                    'title': gallery['title'] ?? '',
                    'image_url': gallery['image_url'] ?? '',
                    'description': gallery['description'] ?? '',
                    'category': gallery['category'] ?? '',
                    'price': gallery['price'] ?? '',
                  })
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error details: $error');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfileDataShowcase({required bool isInitialLoad}) async {
    try {
      safeSetState(() => _isLoading = true);

      if (_currentUserId == null) return;

      final List<dynamic> profileResponse = await ref
          .read(profileRepositoryProvider)
          .fetchGalleryShowcase(_currentUserId!, _offset, _limit);

      if (mounted) {
        safeSetState(() {
          if (isInitialLoad) {
            _galleries.clear();
          }

          if (profileResponse.isEmpty) {
            _hasMore = false;
          }

          _galleries.addAll(
            profileResponse.map((gallery) => {
                  'id': gallery['id'],
                  'title': gallery['title'] ?? '',
                  'image_url': gallery['image_url'] ?? '',
                  'description': gallery['description'] ?? '',
                  'category': gallery['category'] ?? '',
                  'price': gallery['price'] ?? '',
                }),
          );

          // Set showcase data only for initial load
          if (isInitialLoad && profileResponse.isNotEmpty) {
            titleshowcase = profileResponse[0]['title'] ?? '';
            _imageUrlShowcase = profileResponse[0]['image_url'] ?? '';
            descriptionshowcase = profileResponse[0]['description'] ?? '';
            category = profileResponse[0]['category'] ?? '';
            priceshowcase = (profileResponse[0]['price'] ?? 0).toString();
          }
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error details: $error');
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _service = [];
  List<Map<String, dynamic>> _galleries = [];
  List<Map<String, dynamic>> _gallerieslist = [];

  Color _convertStringToColor(String colorCode) {
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark the widget as disposed
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabBarController.dispose();
    _nameController.dispose();
    _shopNameController.dispose();
    _PhoneNumberController.dispose();
    _BioController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _mapGalleryItems(
      List<Map<String, dynamic>> items) {
    return items.map((item) {
      return {
        ...item,
        // Ensure consistent keys expected by Detail Page
        'gallery_id': item['id'],
        'gallery_title': item['title'],
        'gallery_description': item['description'],
        'gallery_image_url': item['image_url'],
        'gallery_price': item['price'],
        'gallery_category': item['category'],
        'id': item['id'], // Alias for compatibility

        // Add profile info for Detail Page
        'name': _nameController.text,
        'profile_image_url': _imageUrl,
        'phone_no': _PhoneNumberController.text,
        'user_id': _currentUserId,
      };
    }).toList();
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(),
      ),
    );
  }

  Future<void> _deleteGalleryItem(dynamic itemId, int index) async {
    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Item ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // First, get the item's image_url from the gallery table to pass to repo
      final response = await _supabase
          .from('gallery')
          .select('image_url')
          .eq('id', itemId)
          .single();

      await ref
          .read(profileRepositoryProvider)
          .deleteGalleryItem(itemId, response['image_url'] as String?);

      safeSetState(() {
        _gallerieslist.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteServiceItem(dynamic itemId, int index) async {
    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Item ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(profileRepositoryProvider).deleteServiceItem(itemId);

      safeSetState(() {
        _service.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCommentsBottomSheet(
      BuildContext context, Map<String, dynamic> galleryItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return CommentSection(
              galleryItem: galleryItem,
              currentUserId: _currentUserId ?? '',
            );
          },
        );
      },
    );
  }

  /* Unused method - originally _loadProfilethreadssData */

  Future<void> _deleteThread(String threadId) async {
    try {
      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Thread'),
            content: const Text(
                'Are you sure you want to delete this thread? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        // Delete from Supabase via Repo
        await ref.read(profileRepositoryProvider).deleteThread(threadId);

        // Remove from local list and update UI
        if (mounted) {
          safeSetState(() {
            userThreads.removeWhere((thread) => thread['id'] == threadId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thread deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting thread: ${e.toString()}')),
        );
      }
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

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 480) {
      return 3; // Small mobile
    } else if (screenWidth < 600) {
      return 4; // Mobile portrait
    } else if (screenWidth < 768) {
      return 5; // Mobile landscape
    } else if (screenWidth < 1024) {
      return 6; // Small tablet
    } else if (screenWidth < 1200) {
      return 7; // Large tablet
    } else if (screenWidth < 1440) {
      return 8; // Small desktop
    } else if (screenWidth < 1920) {
      return 9; // Medium desktop
    } else {
      return 10; // Large desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgcolorcode = _convertStringToColor(_colorCode ?? '#000000');
    final Color bgtextcolor = _convertStringToColor(_colorCode1 ?? '#FFFFFF');
    final Color buttoncolorcode =
        _convertStringToColor(_colorCode2 ?? '#FFFF00');
    final Color buttontextcolor =
        _convertStringToColor(_colorCode3 ?? '#000000');
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 8.0, 16.0, 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: _imageUrlBanner != null
                                ? CachedNetworkImage(
                                    imageUrl: _imageUrlBanner!,
                                    width: double.infinity,
                                    height: 139.0,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(color: Colors.grey[800]),
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 139.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[
                                          300], // You can change this color
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      size: 48.0,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                          ),
                        ),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatColumn(
                                      context,
                                      _gallerieslist.length.toString(),
                                      'Gallery'),
                                  _buildStatColumn(context, '', ''),
                                  _buildStatColumn(context,
                                      _service.length.toString(), 'Service'),
                                  _buildStatColumn(
                                      context, _totalCoins.toString(), 'Coins'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatColumn(
                                      context,
                                      _followingCountFormatted.toString(),
                                      'Following'),
                                  // _buildStatColumn(context, '', ''),
                                  _buildStatColumn(
                                      context,
                                      _followersCountFormatted.toString(),
                                      'Followers'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nameController.text.toString(),
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                              fontFamily: 'Poppins',
                                              letterSpacing: 0.0,
                                              color: bgtextcolor),
                                    ),
                                    Text(
                                      _BioController.text.toString(),
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                              fontFamily: 'Montserrat',
                                              letterSpacing: 0.0,
                                              color:
                                                  bgtextcolor.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CustomButton(
                                width: double.infinity,
                                height: double.infinity,
                                textKey: 'Profile Edit',
                                routeWidget: const ProfileCustomWidget(
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                buttonColor: buttoncolorcode,
                                textColor: buttontextcolor,
                              ),
                              /*
                              CustomButton(
                                width: double.infinity,
                                height: double.infinity,
                                textKey: 'Premium Edit',
                                routeWidget: PremiumFeaturesWidget(
                                  userId: _currentUserId.toString(),
                                ),
                                buttonColor: buttoncolorcode,
                                textColor: buttontextcolor,
                              ),
                              */

                              // CustomButton(
                              //   textKey: 'Add Service',
                              //   routeWidget: CreateServiceWidget(),
                              //   buttonColor: buttoncolorcode,
                              //   textColor: buttontextcolor,
                              // ),
                              // CustomButton(
                              //   textKey: 'Add Gallery',
                              //   routeWidget: CreateShowCaseWidget(),
                              //   buttonColor: buttoncolorcode,
                              //   textColor: buttontextcolor, width: null, height: null,
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // InkWell(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => AdWatchEarningScreen(
                        //           userId: _currentUserId.toString(),
                        //           profileId: profileId?.toString() ?? '',
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   child: Container(
                        //     margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        //     width: double.infinity,
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 16, vertical: 12),
                        //     decoration: BoxDecoration(
                        //       gradient: LinearGradient(
                        //         colors: [
                        //           Colors.orange,
                        //           Colors.orange.withOpacity(0.8)
                        //         ],
                        //         begin: Alignment.topLeft,
                        //         end: Alignment.bottomRight,
                        //       ),
                        //       borderRadius: BorderRadius.circular(12),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.orange.withOpacity(0.3),
                        //           blurRadius: 8,
                        //           offset: const Offset(0, 4),
                        //         ),
                        //       ],
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //           padding: const EdgeInsets.all(8),
                        //           decoration: BoxDecoration(
                        //             color: Colors.white.withOpacity(0.2),
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           child: const Icon(
                        //             Icons.play_circle_outline,
                        //             color: Colors.white,
                        //             size: 28,
                        //           ),
                        //         ),
                        //         const SizedBox(width: 12),
                        //         Expanded(
                        //           child: Column(
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.start,
                        //             children: [
                        //               const Text(
                        //                 'Watch Ads & Earn Coins',
                        //                 style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontSize: 16,
                        //                   fontWeight: FontWeight.bold,
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 4),
                        //               Text(
                        //                 'Unlock premium features by earning coins',
                        //                 style: TextStyle(
                        //                   color: Colors.white.withOpacity(0.9),
                        //                   fontSize: 12,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         const Icon(
                        //           Icons.arrow_forward_ios,
                        //           color: Colors.white,
                        //           size: 16,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 4),
                      ],
                    ),
                    Positioned(
                      // left: 0,
                      right: 10,
                      top: -30,
                      bottom: 0,
                      child: Center(
                        child: _imageUrl != null
                            ? Container(
                                width: 130.0,
                                height: 130.0,
                                decoration: BoxDecoration(
                                  color: bgcolorcode,
                                  border: Border.all(
                                    color: bgcolorcode,
                                    width: 6.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                  child: CachedNetworkImage(
                                    imageUrl: _imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              )
                            : Container(
                                width: 130.0,
                                height: 130.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[600], // Dark grey color
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverAppBar(
                pinned: true,
                elevation: 15,
                backgroundColor: bgcolorcode,
                automaticallyImplyLeading: false,
                flexibleSpace: TabBar(
                  labelColor: bgtextcolor,
                  unselectedLabelColor: bgtextcolor.withOpacity(0.4),
                  labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.0,
                      ),
                  unselectedLabelStyle:
                      FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Poppins',
                            letterSpacing: 0.0,
                          ),
                  indicatorColor: bgcolorcode,
                  tabs: const [
                    Tab(icon: Icon(Icons.photo_library_rounded)), // Gallery
                    Tab(icon: Icon(Icons.miscellaneous_services)), // Services
                    Tab(icon: Icon(Icons.chat_bubble_outline)),
                  ],
                  controller: _tabBarController,
                  onTap: (i) async {
                    [() async {}, () async {}][i]();
                  },
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabBarController,
              children: [
                _gallerieslist.isEmpty
                    ? EmptyStateWidget(
                        message: 'No galleries found',
                        icon: Icons.image_not_supported_outlined,
                        buttonText: 'Refresh',
                        onButtonPressed: () {
                          galleryLengthlike(); // Re-fetch data
                        },
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 150,
                        ),
                        controller: _scrollController,
                        itemCount: _gallerieslist.length + (_hasMore ? 1 : 0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(context),
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          if (index >= _gallerieslist.length) {
                            return _buildLoadingIndicator();
                          }

                          Future<void> toggleLike(
                              String galleryId, int index) async {
                            if (_currentUserId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'You need to be logged in to like posts'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              // Fix: explicit comparison with true
                              final currentIsLiked =
                                  _gallerieslist[index]['is_liked'] == true;

                              if (currentIsLiked) {
                                // Unlike
                                await _supabase
                                    .from('likes')
                                    .delete()
                                    .eq('gallery_id', galleryId)
                                    .eq('user_id', _currentUserId.toString());

                                if (mounted) {
                                  safeSetState(() {
                                    _gallerieslist[index]['is_liked'] = false;
                                    _gallerieslist[index]['like_count'] =
                                        (_gallerieslist[index]['like_count'] ??
                                                1) -
                                            1;
                                  });
                                }
                              } else {
                                // Like
                                await _supabase.from('likes').insert({
                                  'gallery_id': galleryId,
                                  'user_id': _currentUserId,
                                });

                                if (mounted) {
                                  safeSetState(() {
                                    _gallerieslist[index]['is_liked'] = true;
                                    _gallerieslist[index]['like_count'] =
                                        (_gallerieslist[index]['like_count'] ??
                                                0) +
                                            1;
                                  });
                                }
                              }
                            } catch (error) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error toggling like: $error'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                print('Error details: $error');
                              }
                            }
                          }

                          Map<String, dynamic> galleryItem =
                              _gallerieslist[index];
                          return GestureDetector(
                            onTap: () {
                              if (_currentUserId != null) {
                                final mappedGalleryItems =
                                    _mapGalleryItems(_gallerieslist);
                                final mappedItem = mappedGalleryItems[index];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GalleryDetailsprofilePage(
                                      userid: _currentUserId,
                                      item: mappedItem,
                                      allItems: mappedGalleryItems,
                                      initialIndex: index,
                                      bgColor: bgcolorcode,
                                      bgtextcolor: bgtextcolor,
                                      buttoncolorcode: buttoncolorcode,
                                      buttontextcolor: buttontextcolor,
                                    ),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor:
                                        const Color.fromARGB(255, 30, 29, 29),
                                    title: const Text('Delete Item',
                                        style: TextStyle(color: Colors.white)),
                                    content: const Text(
                                        'Are you sure you want to delete this item?',
                                        style: TextStyle(color: Colors.white)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteGalleryItem(
                                              galleryItem['id'], index);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: buttoncolorcode,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Image with hero animation
                                        Hero(
                                          tag:
                                              'gallery_${galleryItem['image_url']}',
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(8),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  galleryItem['image_url'] ??
                                                      '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.grey[900],
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        // Overlay gradient for better text visibility
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.5),
                                                ],
                                              ),
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                bottom: Radius.circular(0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Title directly on the image
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Text(
                                            galleryItem['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Simple info bar
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Price
                                        Text(
                                          '${galleryItem['price']}',
                                          style: TextStyle(
                                            color: buttontextcolor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                        // Interaction icons
                                        Row(
                                          children: [
                                            // Like button and count
                                            GestureDetector(
                                              onTap: () => toggleLike(
                                                  galleryItem['id'], index),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    galleryItem['is_liked'] ==
                                                            true
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: galleryItem[
                                                                'is_liked'] ==
                                                            true
                                                        ? Colors.red
                                                        : buttontextcolor
                                                            .withOpacity(0.7),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${galleryItem['like_count'] ?? 0}',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: buttontextcolor
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Comment button and count
                                            GestureDetector(
                                              onTap: () =>
                                                  _showCommentsBottomSheet(
                                                      context, galleryItem),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.comment_outlined,
                                                    color: buttontextcolor
                                                        .withOpacity(0.7),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${galleryItem['comment_count'] ?? 0}',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: buttontextcolor
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
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
                ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  itemCount: _service.length,
                  itemBuilder: (context, index) {
                    final item = _service[index];
                    return InkWell(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 30, 29, 29),
                              title: const Text('Delete Item',
                                  style: TextStyle(color: Colors.white)),
                              content: const Text(
                                  'Are you sure you want to delete this item?',
                                  style: TextStyle(color: Colors.white)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteServiceItem(item['id'], index);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        child: Card(
                          color: buttoncolorcode,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: bgtextcolor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.work_rounded,
                                      color: bgcolorcode,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Title and Category
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: buttontextcolor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['category'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: buttontextcolor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Price
                                  Text(
                                    '${item['price']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: buttontextcolor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                userThreads.isEmpty
                    ? const Center(child: Text('No threads yet'))
                    : ListView.builder(
                        itemCount: userThreads.length,
                        itemBuilder: (context, index) {
                          final thread = userThreads[index];
                          final int likeCount =
                              (thread['like_count'] as int?) ?? 0;
                          final int fakeLikes =
                              (thread['fake_likes'] as int?) ?? 0;
                          final int totalLikes = likeCount + fakeLikes;
                          final String formattedLikes =
                              _formatCount(totalLikes);
                          return Card(
                            color: buttoncolorcode,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        timeago.format(DateTime.parse(
                                            thread['created_at'])),
                                        style: TextStyle(
                                          color: buttontextcolor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      // Delete button
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: buttontextcolor,
                                          size: 20,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            _deleteThread(thread['id']);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red,
                                                    size: 16),
                                                SizedBox(width: 8),
                                                Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    thread['content'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: buttontextcolor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.favorite,
                                              size: 16, color: buttontextcolor),
                                          const SizedBox(width: 4),
                                          Text(formattedLikes,
                                              style: TextStyle(
                                                  color: buttontextcolor)),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () => {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ThreadCommentsPage(
                                                        threadContent:
                                                            thread['content'],
                                                        threadId: thread['id'],
                                                      )))
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.comment,
                                                size: 16,
                                                color: buttontextcolor),
                                            const SizedBox(width: 4),
                                            Text(
                                                '${thread['comment_count'] ?? 0}',
                                                style: TextStyle(
                                                    color: buttontextcolor)),
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
                      )
              ],
            ),
          ),
        ));
  }

  Widget _buildStatColumn(
      BuildContext context, String countKey, String labelKey) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 18.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            countKey,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Poppins', letterSpacing: 0.0, fontSize: 15),
          ),
          Text(
            labelKey,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Montserrat',
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}

class GalleryDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> galleries;
  final int initialIndex;
  final Function(String) onDelete;

  const GalleryDetailPage({
    super.key,
    required this.galleries,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  final _supabase = SupaFlow.client;
  String? sharetext;
  Future<void> _shareToGroup(String groupId, String groupName) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Insert message to group
      await _supabase.from('group_messages').insert({
        'group_id': groupId,
        'sender_id': _supabase.auth.currentUser?.id.toString() ?? '',
        'gallery_id': widget.galleries[widget.initialIndex]['id'],
        'message_text':
            '${sharetext ?? widget.galleries[widget.initialIndex]['gallery_title']}\n${widget.galleries[widget.initialIndex]['gallery_description']}\n${widget.galleries[widget.initialIndex]['gallery_image_url']}',
        'message_type': 'gallery',
      });

      // Update group's last message
      await _supabase.from('groups').update({
        'last_message':
            '${widget.galleries[widget.initialIndex]['gallery_title']}\n${widget.galleries[widget.initialIndex]['gallery_description']}\n${widget.galleries[widget.initialIndex]['gallery_image_url']}',
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      Navigator.pop(context); // Close loading

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $groupName successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing content: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showGroupSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GroupSelectionBottomSheet(
        contentToShare:
            '${widget.galleries[widget.initialIndex]['gallery_title']}\n${widget.galleries[widget.initialIndex]['gallery_description']}\n${widget.galleries[widget.initialIndex]['gallery_image_url']}',
        currentUserId: _supabase.auth.currentUser?.id.toString() ?? '',
        onGroupSelected: (groupId, groupName, userMessage) {
          sharetext = userMessage;
          Navigator.pop(context);
          _shareToGroup(groupId, groupName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: PageController(initialPage: widget.initialIndex),
        itemCount: widget.galleries.length,
        itemBuilder: (context, index) {
          final gallery = widget.galleries[index];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'gallery_${gallery['image_url']}',
                    child: Image.network(
                      gallery['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 30, 29, 29),
                            title: const Text('Delete Item',
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                'Are you sure you want to delete this item?',
                                style: TextStyle(color: Colors.white)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete(gallery['id']);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              gallery['title'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Adds "..." if text is too long
                              maxLines: 1, // Single-line only
                              softWrap: false,
                            ),
                          ),
                          const SizedBox(width: 8), // Optional spacing
                          ElevatedButton(
                            onPressed: () =>
                                _showGroupSelectionBottomSheet(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.group),
                                SizedBox(width: 2),
                                Text(
                                  'Share to Groups',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          gallery['category'],
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        gallery['description'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${gallery['price']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//comment
class CommentSection extends StatefulWidget {
  final Map<String, dynamic> galleryItem;
  final String currentUserId;

  const CommentSection({
    super.key,
    required this.galleryItem,
    required this.currentUserId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _currentUserProfile;
  bool _isLoading = false;
  final _supabase = SupaFlow.client;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserProfile() async {
    if (widget.currentUserId.isEmpty) return;

    try {
      final response = await _supabase
          .from('profile')
          .select('id, name, profile_image_url')
          .eq('user_id', widget.currentUserId)
          .single();
      print(response);
      if (mounted) {
        safeSetState(() {
          _currentUserProfile = response;
        });
      }
    } catch (error) {
      print('Error loading user profile: $error');
    }
  }

  Future<void> _loadComments() async {
    safeSetState(() => _isLoading = true);

    try {
      // Fetch comments
      final commentsResponse = await _supabase
          .from('comments')
          .select('*')
          .eq('gallery_id', widget.galleryItem['id'])
          .order('created_at', ascending: false);

      // Process comments to include profile information
      List<Map<String, dynamic>> processedComments = [];

      for (var comment in commentsResponse) {
        try {
          // Get profile information for each comment
          if (comment['profile_id'] != null) {
            final profileResponse = await _supabase
                .from('profile')
                .select('name, profile_image_url')
                .eq('id', comment['profile_id'])
                .single();

            // Add profile information to the comment
            comment['profile'] = profileResponse;
          }
        } catch (e) {
          // If profile not found, leave profile as null
          print('Error fetching profile for comment: $e');
        }

        processedComments.add(comment);
      }

      if (mounted) {
        safeSetState(() {
          _comments = processedComments;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        safeSetState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading comments: $error'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error loading comments: $error');
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    if (widget.currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // If we haven't loaded the user's profile yet, try to load it
      if (_currentUserProfile == null) {
        await _loadCurrentUserProfile();
      }

      // Add the comment to the database
      await _supabase.from('comments').insert({
        'gallery_id': widget.galleryItem['id'],
        'user_id': widget.currentUserId,
        'content': _commentController.text.trim(),
        'profile_id':
            _currentUserProfile?['id'], // Include profile_id if available
      });

      // Clear the input field
      _commentController.clear();

      // Reload comments to show the new one
      await _loadComments();

      // Update the comment count in the gallery item
      if (mounted) {
        safeSetState(() {
          widget.galleryItem['comment_count'] =
              (widget.galleryItem['comment_count'] ?? 0) + 1;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bottom sheet header with drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title and comment count
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Comments (${_comments.length.toString() ?? 0})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Comments list
          _isLoading
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              : _comments.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child:
                            Text('No comments yet. Be the first to comment!'),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final profile = comment['profile'] ?? {};
                          final username = profile['name'] ?? 'Anonymous';
                          final userAvatar = profile['profile_image_url'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User avatar
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: userAvatar != null
                                      ? NetworkImage(userAvatar)
                                      : null,
                                  child: userAvatar == null
                                      ? Text(username[0].toUpperCase())
                                      : null,
                                ),
                                const SizedBox(width: 8),

                                // Comment content
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Username and timestamp
                                        Row(
                                          children: [
                                            Text(
                                              username,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              _formatTimestamp(
                                                  comment['created_at']),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Comment text
                                        Text(comment['content'] ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _addComment,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    this.message = 'No items found',
    this.buttonText,
    this.onButtonPressed,
    this.icon = Icons.image_not_supported_outlined,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
