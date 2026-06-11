// Automatic FlutterFlow imports
import 'dart:async';
import 'dart:math';

import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'index.dart';
import 'package:flutter/material.dart' as material;

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';

class GalleryProfileSearchPage extends StatefulWidget {
  const GalleryProfileSearchPage(
      {super.key,
      this.width,
      this.height,
      this.showAppBar = true,
      required this.userid});
  final double? width;
  final double? height;
  final bool? showAppBar;
  final String userid;

  @override
  State<GalleryProfileSearchPage> createState() =>
      _GalleryProfileSearchPageState();
}

class _GalleryProfileSearchPageState extends State<GalleryProfileSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabase = SupaFlow.client;
  String? _colorCode;
  String? _colorCode1;
  String? _colorCode2;
  String? _colorCode3;

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  List<Map<String, dynamic>> galleryItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;
  bool isSearching = false;

  String selectedCategory = 'All';
  List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    fetchGalleryData();
    _loadProfileData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    safeSetState(() {
      _filterItems();
    });
  }

  Future<void> _loadProfileData() async {
    try {
      // safeSetState(() => _isLoading = true);

      final profileResponse = await _supabase
          .from('profile')
          .select()
          .eq('user_id', widget.userid)
          .maybeSingle();
      // print(profileResponse);
      if (profileResponse != null && mounted) {
        safeSetState(() {
          _colorCode = profileResponse['bg_color_code'] ?? '';
          _colorCode1 = profileResponse['bg_text_color'] ?? '';
          _colorCode2 = profileResponse['button_color_code'] ?? '';
          _colorCode3 = profileResponse['button_text_color'] ?? '';
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Error loading profile: $error'),
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

  Color _convertStringToColor(String colorCode) {
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();

    safeSetState(() {
      if (query.isEmpty && selectedCategory == 'All') {
        filteredItems = List.from(galleryItems);
      } else {
        filteredItems = galleryItems.where((item) {
          // Search filter
          bool matchesSearch = query.isEmpty ||
              (item['gallery_title']
                      ?.toString()
                      .toLowerCase()
                      .contains(query) ??
                  false) ||
              (item['gallery_description']
                      ?.toString()
                      .toLowerCase()
                      .contains(query) ??
                  false) ||
              (item['name']?.toString().toLowerCase().contains(query) ?? false);

          // Category filter
          bool matchesCategory = selectedCategory == 'All' ||
              (item['gallery_category']?.toString() == selectedCategory);

          // User ID filter - only show items for the specific user if userid is provided
          bool matchesUser = widget.userid.isEmpty ||
              (item['user_id']?.toString() == widget.userid);

          return matchesSearch && matchesCategory && matchesUser;
        }).toList();
      }
    });
  }

  Future<void> fetchGalleryData() async {
    try {
      safeSetState(() {
        isLoading = true;
      });

      // Build the query with user ID filter if provided
      late final PostgrestList response;

      if (widget.userid.isNotEmpty) {
        // Query with user ID filter
        response = await _supabase
            .from('gallery_with_comments_view')
            .select()
            .eq('user_id', widget.userid)
            .order('gallery_created_at', ascending: false);
      } else {
        // Query without user ID filter
        response = await _supabase
            .from('gallery_with_comments_view')
            .select()
            .order('gallery_created_at', ascending: false);
      }

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

        // Extract unique categories
        Set<String> categorySet = {};
        for (var item in galleryItems) {
          if (item['gallery_category'] != null && item['gallery_category'].toString().trim().isNotEmpty) {
            categorySet.add(item['gallery_category'].toString().trim());
          }
        }
        
        List<String> sortedCategories = categorySet.toList()..sort();
        categories = ['All', ...sortedCategories];

        filteredItems = List.from(galleryItems);
        isLoading = false;
      });
    } catch (e) {
      // print('Error fetching gallery data: $e');
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color ensureContrast(Color fg, Color bg, {bool isButton = true}) {
      double getLuminance(Color color) {
        double r = color.r;
        double g = color.g;
        double b = color.b;
        r = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4).toDouble();
        g = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4).toDouble();
        b = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
      }

      double l1 = getLuminance(fg);
      double l2 = getLuminance(bg);
      double ratio = (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);

      if (ratio < 2.0) {
        bool bgIsDark = l2 < 0.2;
        if (bgIsDark) {
          return isButton ? const Color(0xFFFFFC00) : Colors.white;
        } else {
          return isButton ? const Color(0xFF1E293B) : Colors.black87;
        }
      }
      return fg;
    }

    final Color bgcolorcode = _convertStringToColor(_colorCode ?? '#000000');
    final Color rawBgTextColor = _convertStringToColor(_colorCode1 ?? '#FFFFFF');
    final Color rawButtonColor = _convertStringToColor(_colorCode2 ?? '#FFFF00');
    final Color rawButtonTextColor = _convertStringToColor(_colorCode3 ?? '#000000');
    
    final Color bgtextcolor = ensureContrast(rawBgTextColor, bgcolorcode, isButton: false);
    final Color buttoncolorcode = ensureContrast(rawButtonColor, bgcolorcode, isButton: true);
    final Color buttontextcolor = ensureContrast(rawButtonTextColor, buttoncolorcode, isButton: false);
    return Scaffold(body: ColoredBox(
        color: bgcolorcode,
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              const SizedBox(height: 8),
              Container(
                // height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (widget.showAppBar == true)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back,
                          color: bgtextcolor,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: bgtextcolor),
                        decoration: InputDecoration(
                          hintText: 'Search gallery...',
                          hintStyle: TextStyle(color: bgtextcolor.withOpacity(0.5)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.search, color: bgtextcolor),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close, color: bgtextcolor),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                        onChanged: (text) => _onSearchChanged(),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          safeSetState(() {
                            selectedCategory = category;
                            _filterItems();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? buttoncolorcode : bgcolorcode,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: buttoncolorcode, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? buttontextcolor : bgtextcolor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Results Count
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${filteredItems.length} results',
                        style: TextStyle(
                          color: bgtextcolor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_searchController.text.isNotEmpty ||
                          selectedCategory != 'All')
                        TextButton(
                          onPressed: () {
                            safeSetState(() {
                              _searchController.clear();
                              selectedCategory = 'All';
                              _filterItems();
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_alt_off,
                                  color: bgtextcolor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Clear filters',
                                style:
                                    TextStyle(color: bgtextcolor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Gallery Grid
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  // ignore: deprecated_member_use
                                  color: bgtextcolor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: bgtextcolor.withOpacity(0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: TextStyle(
                                    color: bgtextcolor.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return GallerySearchCard(
                                  userId: widget.userid,
                                  item: item,
                                  allItems:
                                      filteredItems, // Pass the filtered items list
                                  initialIndex: index,
                                  bgColor: bgcolorcode,
                                  bgtextcolor: bgtextcolor,
                                  buttoncolorcode: buttoncolorcode,
                                  buttontextcolor: buttontextcolor,
                                );
                              },
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

class GallerySearchCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final List<Map<String, dynamic>> allItems;
  final int initialIndex;
  final Color bgColor;
  final Color bgtextcolor;
  final Color buttoncolorcode;
  final Color buttontextcolor;
  final String userId;

  const GallerySearchCard({
    super.key,
    required this.item,
    required this.allItems,
    required this.initialIndex,
    required this.bgColor,
    required this.bgtextcolor,
    required this.buttoncolorcode,
    required this.buttontextcolor,
    required this.userId,
  });
  void navigateToDetailPage(BuildContext context, Map<String, dynamic> item,
      List<Map<String, dynamic>> allItems, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryDetailsprofilePage(
          userid: userId,
          item: item,
          allItems: allItems,
          initialIndex: index,
          bgColor: bgColor,
          bgtextcolor: bgtextcolor,
          buttoncolorcode: buttoncolorcode,
          buttontextcolor: buttontextcolor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateToDetailPage(
            context,
            item,
            allItems, // Pass the filtered items list
            initialIndex // Pass the current index
            );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgtextcolor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: bgtextcolor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: item['gallery_image_url'] != null
                    ? Image.network(
                        item['gallery_image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: bgColor.withOpacity(0.8),
                            child: Icon(
                              Icons.error,
                              color: bgtextcolor,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: bgColor.withOpacity(0.8),
                        child: Icon(
                          Icons.image,
                          color: bgtextcolor,
                          size: 48,
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (item['gallery_title'] != null)
                    Text(
                      item['gallery_title'],
                      style: TextStyle(
                        color: bgtextcolor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 4),

                  // Description
                  if (item['gallery_description'] != null)
                    Text(
                      item['gallery_description'],
                      style: TextStyle(
                        color: bgtextcolor.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8),

                  // Creator info and price
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerfiedSwitchPage(
                            userId: item['user_id'],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        // Profile image
                        ClipOval(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: bgtextcolor,
                              shape: BoxShape.circle,
                            ),
                            child: item['profile_image_url'] != null
                                ? Image.network(item['profile_image_url'],
                                    fit: BoxFit.cover)
                                : const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Creator name
                        Expanded(
                          child: Text(
                            item['name'] ?? 'Unknown',
                            style: TextStyle(
                              color: bgtextcolor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price and category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      if (item['gallery_price'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '₹${item['gallery_price']}',
                            style: TextStyle(
                              color: bgtextcolor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Category
                      if (item['gallery_category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.yellow, width: 0.5),
                          ),
                          child: Text(
                            item['gallery_category'],
                            style: TextStyle(
                              color: bgtextcolor,
                              fontSize: 9,
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
    );
  }
}

class GalleryDetailsprofilePage extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<Map<String, dynamic>> allItems;
  final int initialIndex;
  final Color bgColor;
  final Color bgtextcolor;
  final Color buttoncolorcode;
  final Color buttontextcolor;
  final String? userid;

  const GalleryDetailsprofilePage({
    super.key,
    required this.item,
    required this.allItems,
    required this.initialIndex,
    required this.bgColor,
    required this.bgtextcolor,
    required this.buttoncolorcode,
    required this.buttontextcolor,
    this.userid,
  });

  @override
  State<GalleryDetailsprofilePage> createState() =>
      _GalleryDetailsprofilePageState();
}

class _GalleryDetailsprofilePageState extends State<GalleryDetailsprofilePage> {
  late PageController _pageController;
  late int currentIndex;

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.allItems.length,
          onPageChanged: (index) {
            safeSetState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = widget.allItems[index];
            return BuildDetailContent(
                userid: widget.userid,
                item: item,
                bgColor: widget.bgColor,
                bgtextcolor: widget.bgtextcolor,
                buttoncolorcode: widget.buttoncolorcode,
                buttontextcolor:
                    widget.buttontextcolor); // This uses the named parameter;
          },
        ),
      ),
    ));
  }
}

class BuildDetailContent extends StatefulWidget {
  final Map<String, dynamic> item;
  final String? userid;
  final Color bgColor;
  final Color bgtextcolor;
  final Color buttoncolorcode;
  final Color buttontextcolor;
  const BuildDetailContent({
    super.key,
    required this.item,
    required this.bgColor,
    required this.bgtextcolor,
    required this.buttoncolorcode,
    required this.buttontextcolor,
    this.userid,
  });

  @override
  BuildDetailContentState createState() => BuildDetailContentState();
}

class BuildDetailContentState extends State<BuildDetailContent> {
  bool isImageExpanded = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _comments = [];
  bool _isLiked = false;
  int _likeCount = 0;

  final _supabase = SupaFlow.client;
  bool isLoading = true;
  Map<String, dynamic>? hideData;
  String? sharetext;
  final TextEditingController _commentController = TextEditingController();
  String receiverIdprofile = '';
  String receiverNameprofile = 'User';
  String? receiverProfileImageP;
  String? phoneNumberProfile;

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchComments(null);
    _checkIfLiked();
    _getLikeCount();
    fetchHideStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await _supabase
          .from('profile')
          .select('user_id, name, profile_image_url, phone_no')
          .eq('user_id', widget.userid!)
          .single();

      safeSetState(() {
        // print(response);
        receiverIdprofile = response['user_id'] ?? widget.userid;
        receiverNameprofile = response['name'] ?? 'User';
        receiverProfileImageP = response['profile_image_url'];
        phoneNumberProfile = response['phone_no'];
      });
    } catch (e) {
      // print('Error fetching user profile: $e');
    }
  }

  Future<void> fetchHideStatus() async {
    try {
      final targetUserId = widget.userid ?? widget.item['user_id'];
      if (targetUserId == null || targetUserId.toString().isEmpty) {
        safeSetState(() {
          isLoading = false;
        });
        return;
      }

      final response = await _supabase
          .from('hide')
          .select()
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false)
          .limit(1);

      safeSetState(() {
        hideData = response.isNotEmpty ? response.first : null;
        isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchComments(StateSetter? setModalState,
      {String? contentFilter}) async {
    final updateState = setModalState ?? safeSetState;

    updateState(() {
      _isLoading = true;
    });

    try {
      // Start with the base query filtering by gallery_id
      var query = _supabase
          .from('gallery_with_comments_view')
          .select()
          .eq('gallery_id', widget.item['gallery_id'])
          // Only show rows where comment_content is not null
          .not('comment_content', 'is', null);

      // Add content filter if provided
      if (contentFilter != null && contentFilter.isNotEmpty) {
        // Filter comments that contain the search text
        query = query.ilike('comment_content', '%$contentFilter%');
      }

      // Execute the query
      final response = await query;

      // Remove duplicates based on comment_content
      final Map<String, Map<String, dynamic>> uniqueComments = {};

      for (var comment in response) {
        final commentContent = comment['comment_content']?.toString();
        if (commentContent != null && commentContent.isNotEmpty) {
          // Keep the first occurrence or the one with more recent timestamp
          if (!uniqueComments.containsKey(commentContent) ||
              _isMoreRecent(comment, uniqueComments[commentContent]!)) {
            uniqueComments[commentContent] = comment;
          }
        }
      }

      // Convert back to list
      final deduplicatedComments = uniqueComments.values.toList();

      // Get unique profile_comment_ids from the deduplicated comments
      final profileCommentIds = deduplicatedComments
          .map((comment) => comment['profile_comment_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      // Fetch profile information for all comment authors
      Map<String, Map<String, dynamic>> profilesMap = {};

      if (profileCommentIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profile')
            .select('id, name, profile_image_url')
            .inFilter('id', profileCommentIds);

        // Create a map for quick lookup
        for (var profile in profilesResponse) {
          profilesMap[profile['id'].toString()] = profile;
        }
      }

      // Combine comment data with profile information
      final List<Map<String, dynamic>> enrichedComments =
          deduplicatedComments.map((comment) {
        final profileCommentId = comment['profile_comment_id']?.toString();
        final profileData = profilesMap[profileCommentId];

        return {
          ...comment,
          // Add profile information to each comment
          'commenter_name': profileData?['name'] ?? 'Unknown User',
          'commenter_profile_image_url': profileData?['profile_image_url'],
        };
      }).toList();

      // Sort comments by timestamp (newest first) - optional
      enrichedComments.sort((a, b) {
        final aTime = a['created_at'] ?? a['comment_created_at'];
        final bTime = b['created_at'] ?? b['comment_created_at'];
        if (aTime != null && bTime != null) {
          return DateTime.parse(bTime.toString())
              .compareTo(DateTime.parse(aTime.toString()));
        }
        return 0;
      });

      updateState(() {
        _comments = enrichedComments;
        _isLoading = false;
      });
    } catch (error) {
      updateState(() {
        // Don't clear _comments on error to preserve existing data
        _isLoading = false;
      });
    }
  }

// Helper method to determine if a comment is more recent
  bool _isMoreRecent(
      Map<String, dynamic> comment1, Map<String, dynamic> comment2) {
    final time1 = comment1['created_at'] ?? comment1['comment_created_at'];
    final time2 = comment2['created_at'] ?? comment2['comment_created_at'];

    if (time1 == null || time2 == null) return false;

    try {
      return DateTime.parse(time1.toString())
          .isAfter(DateTime.parse(time2.toString()));
    } catch (e) {
      return false;
    }
  }

  Future<void> _getLikeCount() async {
    try {
      final response = await _supabase
          .from('likes')
          .select('count')
          .eq('gallery_id', widget.item['gallery_id'])
          .single();

      safeSetState(() {
        _likeCount = response['count'] ?? 0;
      });
    } catch (e) {
      // print('Error getting like count: $e');
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      if (currentUserId != null) {
        final response = await _supabase
            .from('likes')
            .select()
            .eq('gallery_id', widget.item['gallery_id'])
            .eq('user_id', currentUserId)
            .maybeSingle();

        safeSetState(() {
          _isLiked = response != null;
        });
      }
    } catch (e) {
      // print('Error checking like status: $e');
    }
  }

  void _showCommentsModal() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              constraints: const BoxConstraints(
                  maxWidth: 600), // Limit width for better desktop look
              title: Text(
                'Comments (${_comments.length})',
                style: TextStyle(
                  color: widget.bgtextcolor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: widget.bgtextcolor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Comments (${_comments.length})',
                            style: TextStyle(
                              color: widget.bgtextcolor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: widget.bgtextcolor),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search comments...',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.search,
                              color: widget.buttoncolorcode,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length >= 2 || value.isEmpty) {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              fetchComments(setModalState,
                                  contentFilter: value);
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Comments list
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _comments.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.comment,
                                        size: 80,
                                        color: widget.bgtextcolor
                                            .withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No comments yet',
                                        style: TextStyle(
                                          color: widget.bgtextcolor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Be the first to share your thoughts!',
                                        style: TextStyle(
                                          color: widget.bgtextcolor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: ScrollController(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = _comments[index];
                                    return EnhancedCommentTile(
                                      comment: comment,
                                      onDataChanged: () =>
                                          fetchComments(setModalState),
                                      onCommentDeleted: () =>
                                          fetchComments(setModalState),
                                    );
                                  },
                                ),
                    ),

                    // Comment input area
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.bgColor, // White background color
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) async {
                                  await _addComment();
                                  if (mounted) fetchComments(setModalState);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                await _addComment();
                                // After adding comment, refresh comments list
                                if (mounted) fetchComments(setModalState);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: widget.buttoncolorcode,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.send,
                                  size: 14,
                                  color: widget.buttontextcolor,
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
            );
          },
        );
      },
    );
  }

  // void _showGroupSelectionBottomSheet(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (context) => GroupSelectionBottomSheet(
  //       contentToShare:
  //           '${widget.item['gallery_title']}\n${widget.item['gallery_description']}\n${widget.item['gallery_image_url']}',
  //       currentUserId: _supabase.auth.currentUser?.id.toString() ?? '',
  //       onGroupSelected: (groupId, groupName, userMessage) {
  //         sharetext = userMessage;
  //         Navigator.pop(context);
  //         _shareToGroup(groupId, groupName);
  //       },
  //     ),
  //   );
  // }

  Widget buildAnimatedShareButton(BuildContext context) {
    return AnimatedButtonWithMenu(
      mainIcon: Icons.share,
      mainLabel: 'Share',
      mainColor: Colors.blue,
      onMainTap: () {
        final String title =
            widget.item['gallery_title'] ?? 'Check out this art!';
        final String desc = widget.item['gallery_description'] ?? '';
        final String itemLink =
            '${WhatsAppShareHelper.baseAppUrl}/item/${widget.item['gallery_id']?.toString() ?? widget.item['id']?.toString() ?? ''}';

        SharePlus.instance.share(ShareParams(text: '$title\n\n$desc\n\n$itemLink'));
      },
      menuItems: [
        MenuFlyoutItem(
          leading:
              FaIcon(FontAwesomeIcons.whatsapp, size: 16, color: Colors.green),
          text: const Text('WhatsApp'),
          onPressed: () => WhatsAppShareHelper.shareToWhatsApp(
            context: context,
            item: widget.item,
          ),
        ),
        MenuFlyoutItem(
          text: const Row(
            children: [
              Icon(Icons.copy, size: 16),
              SizedBox(width: 8),
              Text('Copy Link'),
            ],
          ),
          onPressed: () {
            final String itemLink =
                '${WhatsAppShareHelper.baseAppUrl}/item/${widget.item['gallery_id']?.toString() ?? widget.item['id']?.toString() ?? ''}';
            Clipboard.setData(ClipboardData(text: itemLink));
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied' + ': ' + 'Link copied to clipboard!'),
            backgroundColor: Colors.green,
          ),
        );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: widget.buttoncolorcode, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: widget.bgtextcolor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: widget.bgtextcolor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget buildAnimatedDirectMessageButton(BuildContext context) {
    return widget.item['phone_no'] != null &&
            widget.item['phone_no'].toString().isNotEmpty
        ? AnimatedButtonWithMenu(
            mainIcon: Icons.message,
            mainLabel: 'Message on WhatsApp',
            mainColor: Colors.green,
            onMainTap: () => WhatsAppShareHelper.shareToSpecificWhatsAppNumber(
              context: context,
              item: widget.item,
              phoneNumber: widget.item['phone_no'].toString(),
              includeFullDetails: false, // Simple message for direct contact
            ),
            menuItems: [
              MenuFlyoutItem(
                text: const Row(
                  children: [
                    Icon(Icons.chat, size: 16),
                    SizedBox(width: 8),
                    Text('Send simple message'),
                  ],
                ),
                onPressed: () =>
                    WhatsAppShareHelper.shareToSpecificWhatsAppNumber(
                  context: context,
                  item: widget.item,
                  phoneNumber: widget.item['phone_no'].toString(),
                  includeFullDetails: false,
                ),
              ),
              MenuFlyoutItem(
                text: const Row(
                  children: [
                    Icon(Icons.chat, size: 16),
                    SizedBox(width: 8),
                    Text('Send with full details'),
                  ],
                ),
                onPressed: () =>
                    WhatsAppShareHelper.shareToSpecificWhatsAppNumber(
                  context: context,
                  item: widget.item,
                  phoneNumber: widget.item['phone_no'].toString(),
                  includeFullDetails: true,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'You need to be logged in to comment'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final galleryId = widget.item['gallery_id'];
      if (galleryId == null) return;

      final profileResponse = await _supabase
          .from('profile')
          .select('id')
          .eq('user_id', userId)
          .single();

      final profileId = profileResponse['id'];
      if (profileId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Profile not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Add comment to database
      await _supabase.from('comments').insert({
        'user_id': userId,
        'gallery_id': galleryId,
        'content': _commentController.text.trim(),
        'profile_id': profileId,
      });

      // Clear the comment field
      _commentController.clear();

      // Set loading to true to refresh comments list
      safeSetState(() {
        _isLoading = true;
      });

      // Re-fetch all comments to update the list
      await fetchComments(null);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Success' + ': ' + 'Comment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _toggleImageExpansion() {
    safeSetState(() {
      isImageExpanded = !isImageExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildDetailContent(widget.item);
  }

  Widget _buildDetailContent(
    Map<String, dynamic> item,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: widget.bgColor,
            child: PageHeader(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: widget.bgtextcolor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.item['gallery_title'] ?? 'Gallery Detail',
                style: TextStyle(color: widget.bgtextcolor),
              ),
              commandBar: CommandBar(
                mainAxisAlignment: MainAxisAlignment.end,
                primaryItems: [
                  if (_supabase.auth.currentUser?.id == widget.userid)
                    CommandBarButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Delete Showcase', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Showcase?'),
                            content: const Text('Are you sure you want to delete this showcase post? This action cannot be undone.'),
                            actions: [
                              TextButton(child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        try {
                          final String itemId = widget.item['id']?.toString() ?? widget.item['gallery_id']?.toString() ?? '';
                          final String? imageUrl = widget.item['gallery_image_url'] ?? widget.item['image_url'];

                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            final storagePathMatch = RegExp(r'gallery_photos/(.+)').firstMatch(imageUrl);
                            if (storagePathMatch != null) {
                              final storagePath = storagePathMatch.group(1);
                              if (storagePath != null) {
                                await _supabase.storage.from('gallery_photos').remove([storagePath]);
                              }
                            }
                          }
                          await _supabase.from('gallery').delete().match({'id': itemId});

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Success' + ': ' + 'Showcase deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
                            Navigator.pop(context); // Close detail dialog/screen
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Error deleting showcase: $e'),
            backgroundColor: Colors.red,
          ),
        );
                          }
                        }
                      },
                    ),
                  CommandBarButton(
                    icon: Icon(Icons.warning, color: widget.bgtextcolor),
                    label: const Text('Report'),
                    onPressed: () {
                      // Implement report logic
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Content
        SliverList(
          delegate: SliverChildListDelegate([
            // Image Section
            Container(
              color: widget.bgColor,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleImageExpansion,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      color: widget.bgColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: isImageExpanded ? 0.8 : 1.2,
                          child: item['gallery_image_url'] != null
                              ? Image.network(
                                  item['gallery_image_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color:
                                          widget.bgColor.withOpacity(0.5),
                                      child: Icon(
                                        Icons.image,
                                        color: widget.bgtextcolor,
                                        size: 64,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: widget.bgColor.withOpacity(0.5),
                                  child: Icon(
                                    Icons.image,
                                    color: widget.bgtextcolor,
                                    size: 64,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ), // Title and Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      color: widget.bgColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (item['gallery_title'] != null)
                                Expanded(
                                  child: Text(
                                    item['gallery_title'],
                                    style: TextStyle(
                                      color: widget.bgtextcolor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              // TextButton(
                              //   onPressed: () async {
                              //     final isAuthenticated =
                              //         await AuthAlertBox.checkAuthAndShowAlert(
                              //       context: context,
                              //       customMessage:
                              //           "Please login to share to groups",
                              //     );
                              //     if (isAuthenticated) {
                              //       // ignore: use_build_context_synchronously
                              //       _showGroupSelectionBottomSheet(context);
                              //     }
                              //   },
                              //   style: Button.styleFrom(
                              //     backgroundColor: widget.buttoncolorcode,
                              //     foregroundColor: widget.buttontextcolor,
                              //     padding: const EdgeInsets.all(13),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),
                              //     elevation: 4,
                              //   ),
                              //   child: FaIcon(
                              //     FontAwesomeIcons.share,
                              //     color: widget.buttontextcolor,
                              //     size: 18.0,
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (item['gallery_description'] != null)
                            Text(
                              item['gallery_description'],
                              style: TextStyle(
                                color:
                                    widget.bgtextcolor.withOpacity(0.8),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: widget.buttoncolorcode,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final link =
                                  "${WhatsAppShareHelper.baseAppUrl}/shareGallery?galleryId=${item['gallery_id']}";
                              await Clipboard.setData(
                                  ClipboardData(text: link));
                              if (!context.mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied' + ': ' + 'Link copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
                            },
                            icon: Icon(
                              Icons.link,
                              size: 16,
                              color: widget.buttontextcolor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Creator Info Card
                  item['name'] != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerfiedSwitchPage(
                                  userId: item['user_id'] ?? widget.userid,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: widget.bgtextcolor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: material.Colors.grey[800]!, width: 1),
                            ),
                            child: Row(
                              children: [
                                material.CircleAvatar(
                                  radius: 30,
                                  backgroundColor: widget.buttoncolorcode,
                                  backgroundImage: item['profile_image_url'] !=
                                          null
                                      ? NetworkImage(item['profile_image_url'])
                                      : null,
                                  child: item['profile_image_url'] == null
                                      ? Icon(
                                          Icons.person,
                                          size: 30,
                                          color: widget.buttontextcolor,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Unknown Creator',
                                        style: TextStyle(
                                          color: widget.bgtextcolor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Creator',
                                        style: TextStyle(
                                          color: widget.bgtextcolor
                                              .withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(height: 0),
                  const SizedBox(height: 24),

                  // Details Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.bgtextcolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: material.Colors.grey[800]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            color: widget.bgtextcolor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price
                        if (item['gallery_price'] != null)
                          _buildDetailRow(
                            Icons.attach_money,
                            'Price',
                            '₹${item['gallery_price']}',
                          ),

                        // Category
                        if (item['gallery_category'] != null)
                          _buildDetailRow(
                            Icons.list,
                            'Category',
                            item['gallery_category'],
                          ),

                        // Created Date
                        if (item['gallery_created_at'] != null)
                          _buildDetailRow(
                            Icons.calendar_month,
                            'Created',
                            _formatDate(item['gallery_created_at']),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // General share button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _supabase.auth.currentUser == null || hideData == null || hideData?['is_hidden'] == true
                            ? const SizedBox()
                            : Expanded(
                                child: buildAnimatedShareButton(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _supabase.auth.currentUser == null || hideData == null || hideData?['is_hidden'] == true
                            ? const SizedBox()
                            : Expanded(
                                child:
                                    buildAnimatedDirectMessageButton(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final isAuthenticated =
                                  await AuthAlertBox.checkAuthAndShowAlert(
                                context: context,
                                customMessage:
                                    "Please login to Chat with this user",
                              );
                              if (!mounted) return;
                              if (isAuthenticated) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WhatsAppGroupChat(
                                      groupId:
                                          'p:${widget.userid ?? item['user_id']}',
                                      groupName: item['name'] ?? 'User',
                                      groupImage: item['profile_image_url'],
                                    ),
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: widget.buttoncolorcode,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat,
                                    color: widget.buttontextcolor),
                                const SizedBox(width: 8),
                                Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: widget.buttontextcolor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comments',
                              style: TextStyle(
                                color: widget.bgtextcolor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final isAuthenticated =
                                    await AuthAlertBox.checkAuthAndShowAlert(
                                  context: context,
                                  customMessage:
                                      "Please login to Comment to the gallery",
                                );
                                if (isAuthenticated) {
                                  // ignore: use_build_context_synchronously
                                  _showCommentsModal();
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: widget.buttoncolorcode,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat,
                                      size: 18, color: widget.buttoncolorcode),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View All (${_comments.length})',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: widget.buttoncolorcode),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Comment input (compact version)
                        GestureDetector(
                          onTap: () async {
                            final isAuthenticated =
                                await AuthAlertBox.checkAuthAndShowAlert(
                              context: context,
                              customMessage:
                                  "Please login to Comment to the gallery",
                            );
                            if (isAuthenticated) {
                              // ignore: use_build_context_synchronously
                              _showCommentsModal();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.bgColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                material.CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(
                                    _supabase.auth.currentUser
                                            ?.userMetadata?['avatar_url'] ??
                                        '',
                                  ),
                                  backgroundColor: widget.bgColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Add a comment...',
                                    style: TextStyle(
                                      // ignore: deprecated_member_use
                                      color: widget.bgtextcolor
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.send,
                                  color:
                                      widget.bgtextcolor.withOpacity(0.8),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Comments preview (3 most recent)
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                value: 0.5,
                                strokeWidth: 2,
                              ))
                            : _comments.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.chat,
                                            size: 48,
                                            // ignore: deprecated_member_use
                                            color: widget.bgtextcolor
                                                .withOpacity(0.8),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No comments yet. Be the first to comment!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              // ignore: deprecated_member_use
                                              color:
                                                  // ignore: deprecated_member_use
                                                  widget.bgtextcolor
                                                      .withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      for (int i = 0;
                                          i < min(3, _comments.length);
                                          i++)
                                        EnhancedCommentTile(
                                            comment: _comments[i]),
                                      if (_comments.length > 3)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: TextButton(
                                            onPressed: _showCommentsModal,
                                            child: Text(
                                              'View ${_comments.length - 3} more comments',
                                              style: TextStyle(
                                                color: widget.buttoncolorcode,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class EnhancedCommentTile extends StatefulWidget {
  final Map<String, dynamic> comment;
  final VoidCallback? onCommentDeleted;
  final VoidCallback? onDataChanged;

  const EnhancedCommentTile({
    super.key,
    required this.comment,
    this.onCommentDeleted,
    this.onDataChanged,
  });

  @override
  State<EnhancedCommentTile> createState() => _EnhancedCommentTileState();
}

class _EnhancedCommentTileState extends State<EnhancedCommentTile> {
  final _supabase = SupaFlow.client;
  final CommentLikeService _likeService = CommentLikeService();
  final CommentReplyService _replyService = CommentReplyService();

  bool _isLiked = false;
  int _likeCount = 0;
  bool _showReplies = false;
  bool _isLoadingReplies = false;
  List<Map<String, dynamic>> _replies = [];
  final TextEditingController _replyController = TextEditingController();
  bool _isReplying = false;

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLikeData();
    _loadReplies();
  }

  Future<void> _loadLikeData() async {
    final likeCount =
        await _likeService.getLikeCount(widget.comment['comment_id']);
    final hasLiked =
        await _likeService.hasUserLiked(widget.comment['comment_id']);

    if (mounted) {
      safeSetState(() {
        _likeCount = likeCount;
        _isLiked = hasLiked;
      });
    }
  }

  Future<void> _toggleLike() async {
    // Optimistic update
    safeSetState(() {
      if (_isLiked) {
        _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
      } else {
        _likeCount = _likeCount + 1;
      }
      _isLiked = !_isLiked;
    });

    try {
      await _likeService.toggleLike(widget.comment['comment_id']);
      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }
    } catch (e) {
      // Revert on error
      safeSetState(() {
        if (_isLiked) {
          _likeCount = _likeCount - 1;
        } else {
          _likeCount = _likeCount + 1;
        }
        _isLiked = !_isLiked;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Failed to update like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReplies() async {
    if (_isLoadingReplies) return;

    safeSetState(() {
      _isLoadingReplies = true;
    });

    try {
      final replies =
          await _replyService.getReplies(widget.comment['comment_id']);

      if (mounted) {
        safeSetState(() {
          _replies = replies;
          _isLoadingReplies = false;
          _showReplies = true;
        });
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          _isLoadingReplies = false;
        });
        // print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Failed to load replies: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // print(e);
      }
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    try {
      final reply = await _replyService.addReply(
        widget.comment['comment_id'],
        _replyController.text.trim(),
      );

      if (mounted && reply != null) {
        safeSetState(() {
          _replyController.clear();
          _isReplying = false;
        });

        // Load all replies again to ensure consistency with the database
        await _loadReplies();

        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error' + ': ' + 'Failed to add reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(
        widget.comment['created_at'] ?? DateTime.now().toIso8601String());
    final String timeAgo = _getTimeAgo(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.comment['commenter_profile_image_url'] ??
                        '',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        color: material.Colors.grey[800],
                        child: Icon(Icons.person,
                            size: 18, color: material.Colors.grey[400]),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment['commenter_name'] ?? 'Anonymous',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      timeAgo,
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert,
                    color: material.Colors.grey, size: 20),
                onPressed: () {
                  final currentUserId = _supabase.auth.currentUser?.id;
                  final bool isCommentOwner =
                      currentUserId == widget.comment['user_id'];

                  showDialog(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCommentOwner)
                            material.ListTile(
                              leading: const Icon(Icons.delete,
                                  color: material.Colors.red),
                              title: const Text('Delete comment'),
                              onTap: () async {
                                Navigator.pop(context);

                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Comment'),
                                    content: const Text(
                                        'Are you sure you want to delete this comment? This action cannot be undone.'),
                                    actions: [
                                      TextButton(child: const Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text('Delete',
                                            style: TextStyle(
                                                color: Colors.red)),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true) {
                                  try {
                                    await _supabase
                                        .from('comments')
                                        .delete()
                                        .eq('id', widget.comment['comment_id']);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Success'),
            backgroundColor: Colors.green,
          ),
        );

                                      if (widget.onCommentDeleted != null) {
                                        widget.onCommentDeleted!();
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error'),
            backgroundColor: Colors.red,
          ),
        );
                                    }
                                    // print(e);
                                  }
                                }
                              },
                            ),
                          material.ListTile(
                            leading: const Icon(Icons.flag),
                            title: const Text('Report comment'),
                            onTap: () {
                              Navigator.pop(context);
                              ReportHelper.showReportDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                contentType: 'comment',
                                contentId:
                                    widget.comment['comment_id'].toString(),
                                contentTitle:
                                    widget.comment['comment_content'] ??
                                        'Comment',
                                onReportSubmitted: () {
                                  // Optional: Show feedback to user
                                  ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reported'),
            backgroundColor: Colors.red,
          ),
        );
                                },
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reported'),
            backgroundColor: Colors.green,
          ),
        );
                            },
                          ),
                          material.ListTile(
                            leading: const Icon(Icons.copy),
                            title: const Text('Copy text'),
                            onTap: () {
                              Navigator.pop(context);
                              Clipboard.setData(ClipboardData(
                                  text:
                                      widget.comment['comment_content'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied' + ': ' + 'Comment copied to clipboard'),
            backgroundColor: Colors.red,
          ),
        );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.comment['comment_content'] ?? '',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: _toggleLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLiked
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 16,
                      color: _isLiked
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _likeCount > 0 ? '$_likeCount' : 'Like',
                      style: TextStyle(
                        color: _isLiked
                            ? FlutterFlowTheme.of(context).primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  if (_showReplies) {
                    safeSetState(() {
                      _showReplies = false;
                    });
                  } else {
                    if (_replies.isEmpty) {
                      _loadReplies();
                    } else {
                      safeSetState(() {
                        _showReplies = true;
                      });
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.reply, size: 16),
                    const SizedBox(width: 8),
                    Text(_replies.isNotEmpty
                        ? 'Replies (${_replies.length})'
                        : 'Reply'),
                  ],
                ),
              ),
            ],
          ),
          if (_showReplies) ...[
            Container(
              height: 0.5,
              color: material.Colors.grey.withOpacity(0.5),
              margin: const EdgeInsets.symmetric(vertical: 12),
            ),
            if (_isLoadingReplies)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_replies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No replies yet. Be the first to reply!',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _replies.length,
                itemBuilder: (context, index) {
                  final reply = _replies[index];
                  final DateTime replyCreatedAt = DateTime.parse(
                      reply['created_at'] ?? DateTime.now().toIso8601String());
                  final String replyTimeAgo = _getTimeAgo(replyCreatedAt);

                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              reply['profiles']?['profile_image_url'] ?? '',
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.grey[800],
                                  child: Icon(Icons.person,
                                      size: 14, color: Colors.grey[400]),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reply['profiles']?['name'] ?? 'Anonymous',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    replyTimeAgo,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .copyWith(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reply['content'] ?? '',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (reply['user_id'] ==
                            SupaFlow.client.auth.currentUser?.id)
                          IconButton(
                            icon: const Icon(Icons.more_vert,
                                size: 16, color: Colors.grey),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      material.ListTile(
                                        leading: const Icon(Icons.delete,
                                            color: material.Colors.red),
                                        title: const Text('Delete reply'),
                                        onTap: () async {
                                          Navigator.pop(context);

                                          final shouldDelete =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Reply'),
                                              content: const Text(
                                                  'Are you sure you want to delete this reply?'),
                                              actions: [
                                                TextButton(child: const Text('Cancel'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                ),
                                                TextButton(
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: material
                                                              .Colors.red)),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (shouldDelete == true) {
                                            try {
                                              await _replyService.deleteReply(
                                                  reply['id'].toString());

                                              if (mounted) {
                                                safeSetState(() {
                                                  _replies.removeAt(index);
                                                });

                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Success'),
            backgroundColor: Colors.green,
          ),
        );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error'),
            backgroundColor: Colors.red,
          ),
        );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                      material.ListTile(
                                        leading: const Icon(Icons.copy),
                                        title: const Text('Copy text'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Clipboard.setData(ClipboardData(
                                              text: reply['content'] ?? ''));
                                          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied'),
            backgroundColor: Colors.green,
          ),
        );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),

            // Reply input field
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          SupaFlow.client.auth.currentUser
                                  ?.userMetadata?['profile_image_url'] ??
                              '',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 24,
                              height: 24,
                              color: Colors.grey[800],
                              child: Icon(Icons.person,
                                  size: 14, color: Colors.grey[400]),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        onChanged: (value) {
                          safeSetState(() {
                            _isReplying = value.trim().isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          hintStyle: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                color: Colors.grey,
                              ),
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ),
                    if (_isReplying)
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: material.Colors.blue,
                          size: 20,
                        ),
                        onPressed: _submitReply,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _getTimeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else {
    return 'Just now';
  }
}

class CommentLikeService {
  final _supabase = SupaFlow.client;

  Future<void> toggleLike(String commentId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Check if user already liked this comment
    final response = await _supabase
        .from('comment_likes')
        .select()
        .eq('comment_id', commentId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (response != null) {
      // User already liked the comment, so remove the like
      await _supabase
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', user.id);
    } else {
      // User hasn't liked the comment yet, add a like
      await _supabase.from('comment_likes').insert({
        'user_id': user.id,
        'comment_id': commentId,
      });
    }
  }

  Future<bool> hasUserLiked(String commentId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final response = await _supabase
        .from('comment_likes')
        .select()
        .eq('comment_id', commentId)
        .eq('user_id', user.id)
        .maybeSingle();

    return response != null;
  }

  Future<int> getLikeCount(String commentId) async {
    final response = await _supabase.rpc(
      'get_comment_like_count',
      params: {'comment_id': commentId},
    );

    return response ?? 0;
  }
}

class CommentReplyService {
  final _supabase = SupaFlow.client;

  Future<List<Map<String, dynamic>>> getReplies(String commentId) async {
    try {
      // First, let's check the actual column names
      /* final commentColumns =
          await _supabase.from('comments').select('*').limit(1); */

      /* print(
          'Comment table columns: ${commentColumns.isNotEmpty ? commentColumns.first.keys : "No data"}'); */

      // Now use the correct column names in the join
      final response = await _supabase.from('comment_replies').select('''
        *,
        profiles:profile_id(
          id,
          name,
          profile_image_url
        ),
        comments:comment_id(
          id,
          content,
          created_at
        )
      ''').eq('comment_id', commentId).order('created_at');

      // print('Fetched replies: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // print('Error fetching replies: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> addReply(
      String commentId, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      // First get the profile_id from the profile table
      final profileResult = await _supabase
          .from('profile')
          .select('id, name, profile_image_url')
          .eq('user_id', user.id)
          .single();

      // Extract the profile_id
      final profileId = profileResult['id'];

      // Insert the reply with the profile_id
      final insertResult = await _supabase.from('comment_replies').insert({
        'user_id': user.id,
        'comment_id': commentId,
        'content': content,
        'profile_id': profileId,
      }).select();

      // Check if we got any result
      if (insertResult.isEmpty) {
        throw Exception('No data returned after insert');
      }

      final Map<String, dynamic> reply = insertResult.first;

      // Add profile data to the response
      reply['profile'] = {
        'name': profileResult['name'],
        'profile_image_url': profileResult['profile_image_url']
      };

      // print(reply);
      return reply;
    } catch (e) {
      // print('Error in addReply: $e');
      rethrow;
    }
  }

  Future<void> deleteReply(String replyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to delete replies');
    }

    try {
      // First verify this reply belongs to the current user
      final replyCheck = await _supabase
          .from('comment_replies')
          .select('user_id')
          .eq('id', replyId)
          .single();

      // Only allow deletion if the user owns this reply
      if (replyCheck['user_id'] != user.id) {
        throw Exception('You can only delete your own replies');
      }

      // Delete the reply
      await _supabase.from('comment_replies').delete().eq('id', replyId);

      // print('Reply deleted successfully: $replyId');
    } catch (e) {
      // print('Error deleting reply: $e');
      rethrow;
    }
  }
}

class AnimatedButtonWithMenu extends StatefulWidget {
  final IconData mainIcon;
  final String mainLabel;
  final Color mainColor;
  final VoidCallback onMainTap;
  final List<MenuFlyoutItem> menuItems;

  const AnimatedButtonWithMenu({
    super.key,
    required this.mainIcon,
    required this.mainLabel,
    required this.mainColor,
    required this.onMainTap,
    required this.menuItems,
  });

  @override
  State<AnimatedButtonWithMenu> createState() => _AnimatedButtonWithMenuState();
}

class _AnimatedButtonWithMenuState extends State<AnimatedButtonWithMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Offset _tapPosition = Offset.zero;
  bool _isPressed = false;

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMenu() async {
    final RenderBox? overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    
    final MenuFlyoutItem? selected = await showMenu<MenuFlyoutItem>(
      context: context,
      position: RelativeRect.fromRect(
        _tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: widget.menuItems.map((item) {
        return PopupMenuItem<MenuFlyoutItem>(
          value: item,
          child: Row(
            children: [
              if (item.leading != null) ...[
                item.leading!,
                const SizedBox(width: 8),
              ],
              item.text,
            ],
          ),
        );
      }).toList(),
    );

    if (mounted) {
      safeSetState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }

    if (selected != null && selected.onPressed != null) {
      selected.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _tapPosition = details.globalPosition;
        safeSetState(() {
          _isPressed = true;
        });
        _controller.forward();
      },
      onTapUp: (_) {
        Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            safeSetState(() {
              _isPressed = false;
            });
            _controller.reverse();
          }
        });
      },
      onTapCancel: () {
        safeSetState(() {
          _isPressed = false;
        });
        _controller.reverse();
      },
      onLongPress: _showMenu,
      onTap: widget.onMainTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.mainColor.withOpacity(0.8)
                : widget.mainColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, _isPressed ? 1 : 2),
                blurRadius: _isPressed ? 3 : 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.mainIcon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.mainLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MenuFlyoutItem {
  final Widget text;
  final Widget? leading;
  final VoidCallback? onPressed;

  const MenuFlyoutItem({
    required this.text,
    this.leading,
    this.onPressed,
  });
}


class PageHeader extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? commandBar;

  const PageHeader({
    super.key,
    this.leading,
    required this.title,
    this.commandBar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Expanded(child: title),
          if (commandBar != null) commandBar!,
        ],
      ),
    );
  }
}

class CommandBar extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final List<CommandBarButton> primaryItems;

  const CommandBar({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    required this.primaryItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: primaryItems,
    );
  }
}

class CommandBarButton extends StatelessWidget {
  final Widget icon;
  final Widget? label;
  final VoidCallback? onPressed;

  const CommandBarButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label ?? const SizedBox.shrink(),
    );
  }
}
