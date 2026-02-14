// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/event_display_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/event_display_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_switch_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';

import '/backend/supabase/supabase.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:share_plus/share_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' as flutter;
import 'package:flutter/services.dart' as flutter;

import 'dart:async';
import 'dart:async';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class VerfiedSearchProfileDetailPage extends StatefulWidget {
  const VerfiedSearchProfileDetailPage({
    super.key,
    this.width,
    this.height,
    required this.userId,
  });

  final double? width;
  final double? height;
  final String userId;

  @override
  State<VerfiedSearchProfileDetailPage> createState() =>
      _VerfiedSearchProfileDetailPageState();
}

class _VerfiedSearchProfileDetailPageState
    extends State<VerfiedSearchProfileDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];
  List<Map<String, dynamic>> _commentItems = [];
  bool _isLoading = false;
  final _supabase = SupaFlow.client;
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  int _followersCount = 0;
  int _followingCount = 0;
  String _followersCountFormatted = '0';
  String _followingCountFormatted = '0';
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  String? _currentUserId;
  List<Map<String, dynamic>> userThreads = [];
  bool isLoading = true;
  Map<String, dynamic>? hideData;
  List<Map<String, dynamic>> _comments = [];
  String? _errorMessage;
  bool _isBlocked = false;
  bool _isBlockedByOther = false;
  bool _checkingBlockStatus = true;
  DateTime? _blockTime;
  DateTime? _blockedByOtherTime;
  bool _isExpanded = false;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  List<Map<String, dynamic>> _filteredGalleryItems = [];
  bool _showScrollToTop = false;
  List<Map<String, dynamic>> _userBanners = [];
  bool _hasEvents = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProfileData();
    _checkFollowStatus();
    fetchFollowCounts();
    _checkIfCurrentUser();
    _getCurrentUser();
    _loadProfilethreadsData();
    fetchHideStatus();
    _checkBlockStatus();
    _initScrollListener();
    _initializeData();
    _checkEventsTable();
  }

  Future<void> _initializeData() async {
    await _fetchUserBanners();
  }

  Future<void> _checkEventsTable() async {
    try {
      // Build the query step by step
      var query = Supabase.instance.client.from('events').select('id');

      // Add user_id filter since userId is non-nullable
      query = query.eq('user_id', widget.userId);

      // Execute the query with limit
      final response = await query.limit(1);

      setState(() {
        _hasEvents = response.isNotEmpty;
        _isLoading = false;
      });
    } catch (error) {
      print('Error checking events table: $error');
      setState(() {
        _hasEvents = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserBanners() async {
    try {
      final response = await _supabase
          .from('premiumbannergallery')
          .select(
              'id, user_id, title, description, price, category, image_url, created_at, updated_at')
          .eq('user_id', widget.userId!)
          .order('created_at', ascending: false);

      setState(() {
        _userBanners = List<Map<String, dynamic>>.from(response);
        print(_userBanners);
      });
    } catch (e) {
      print('Error fetching user banners: $e');
    }
  }

  void _initScrollListener() {
    _scrollController.addListener(() {
      // Show button when scrolled down more than 200 pixels
      bool shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }
    });
  }

// Add this method to scroll to top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _checkIfCurrentUser() {
    final currentUserId = _supabase.auth.currentUser?.id;
    safeSetState(() {
      _isCurrentUser = currentUserId == widget.userId;
    });
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

  Future<void> _checkBlockStatus() async {
    try {
      setState(() {
        _checkingBlockStatus = true;
      });

      // Check if current user blocked the receiver
      final blockedByMe = await _supabase
          .from('blocks')
          .select('created_at')
          .eq('blocker_id', _currentUserId.toString())
          .eq('blocked_id', widget.userId)
          .limit(1);

      // Check if receiver blocked the current user
      final blockedByOther = await _supabase
          .from('blocks')
          .select('created_at')
          .eq('blocker_id', widget.userId)
          .eq('blocked_id', _currentUserId.toString())
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

  void fetchFollowCounts() async {
    try {
      // Get followers count - people who follow this user
      final followersResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', widget.userId);

      // Get following count - people this user follows
      final followingResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', widget.userId);

      // Get followers count from users table
      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', widget.userId)
          .single();

      final double userTableFollowers =
          userResponse['followers']?.toDouble() ?? 0.0;

      final int followersCountRaw =
          followersResponse.length + userTableFollowers.toInt();
      final int followingCountRaw = followingResponse.length;

      safeSetState(() {
        _followersCount = followersCountRaw;
        _followingCount = followingCountRaw;
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
      final threads = await _supabase
          .from('threads_view')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

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

  void _fetchProfileData() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      final profileResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
        profile_id, profile_created_at, user_id, name, phone_no, country, bio, 
        shop_name, profile_image_url, banner_image_url, button_color_code,
        bg_color_code, bg_text_color, state, city, button_text_color, verified,insta_id,insta_link, slug
        ''')
          .eq('user_id', widget.userId)
          .limit(1);

      Map<String, dynamic>? profile =
          profileResponse.isNotEmpty ? profileResponse.first : null;

      final galleryResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
        gallery_id, gallery_title, profile_id, shop_name, gallery_description, 
        gallery_price, gallery_image_url, gallery_category, like_id, like_created_at,
        comment_id,comment_content,comment_created_at,comment_updated_at
        ''')
          .eq('user_id', widget.userId)
          .not('gallery_id', 'is', null)
          .order('gallery_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueGalleryItems = {};
      Set<String> categorySet = {'All'}; // Start with 'All' category

      for (var item in galleryResponse) {
        if (item['gallery_id'] != null) {
          uniqueGalleryItems[item['gallery_id'].toString()] = item;

          // Extract categories
          if (item['gallery_category'] != null &&
              item['gallery_category'].toString().trim().isNotEmpty) {
            categorySet.add(item['gallery_category'].toString().trim());
          }
        }
      }

      final commentResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
        gallery_id, gallery_created_at, gallery_title, gallery_description, 
        gallery_price, gallery_image_url, gallery_category, like_id, like_created_at,
        comment_id, comment_content, comment_created_at, comment_updated_at
        ''')
          .eq('user_id', widget.userId)
          .not('gallery_id', 'is', null)
          .order('gallery_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniquecommentItems = {};
      for (var item in commentResponse) {
        if (item['comment_id'] != null) {
          uniquecommentItems[item['comment_id'].toString()] = item;
        }
      }

      final serviceResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
        service_id, service_created_at, service_title, service_description, 
        service_price, service_category
        ''')
          .eq('user_id', widget.userId)
          .not('service_id', 'is', null)
          .order('service_created_at', ascending: false);

      final Map<String, Map<String, dynamic>> uniqueServiceItems = {};
      for (var item in serviceResponse) {
        if (item['service_id'] != null) {
          uniqueServiceItems[item['service_id'].toString()] = item;
        }
      }

      safeSetState(() {
        _profileData = profile;
        _galleryItems = uniqueGalleryItems.values.toList();
        _categories = categorySet.toList();
        _filteredGalleryItems = _galleryItems; // Initially show all
        _serviceItems = uniqueServiceItems.values.toList();
        _commentItems = uniquecommentItems.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      print('Error fetching profile data: $e');
    }
  }

// Add this method to filter gallery items
  void _filterGalleryByCategory(String category) {
    safeSetState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredGalleryItems = _galleryItems;
      } else {
        _filteredGalleryItems = _galleryItems.where((item) {
          return item['gallery_category']?.toString().trim() == category;
        }).toList();
      }
    });
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

  Future<void> toggleFollow() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to follow users')),
      );
      return;
    }

    try {
      if (_isFollowing) {
        await _supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('followed_id', widget.userId);
      } else {
        await _supabase.from('follows').insert({
          'follower_id': currentUserId,
          'followed_id': widget.userId,
        });
      }

      safeSetState(() {
        _isFollowing = !_isFollowing;
        _followersCount =
            _isFollowing ? _followersCount + 1 : _followersCount - 1;
      });
    } catch (e) {
      print('Error fetching profile data: $e');
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
          phonenumber: _profileData?['phone_no'],
        ),
      ),
    );
  }

  Widget buildVerifiedTick(bool isVerified, Color? color) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.verified,
        color: color ?? Colors.blue,
        size: 20,
      ),
    );
  }

// Share gallery item
  void _shareGalleryItem(Map<String, dynamic> item) async {
    try {
      // This is a simple implementation - you might want to use a share package
      // like 'share_plus' for more features
      final title = item['gallery_title'] ?? 'Check out this item';
      final imageUrl = item['gallery_image_url'] ?? '';
      final description = item['gallery_description'] ?? '';

      // You would implement actual sharing functionality here with your preferred share plugin
      await Share.share(
        '$title\n\n$description\n\n$imageUrl',
        subject: title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
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

  void _showMessageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          title: const Row(
            children: [
              Icon(Icons.message, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: const Text(
            'Choose how you would like to send a message:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                hideData != null && hideData?['is_hidden'] == true
                    ? const SizedBox() // Hide WhatsApp button
                    : TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _sendWhatsAppMessage();
                        },
                        icon: const Icon(Icons.chat,
                            color: Colors.green, size: 20),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side:
                                const BorderSide(color: Colors.green, width: 1),
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                // In-App Message Option
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final isAuthenticated =
                        await AuthAlertBox.checkAuthAndShowAlert(
                      context: context,
                      customMessage: "Please login to send message",
                    );
                    if (isAuthenticated) {
                      // ignore: use_build_context_synchronously
                      _navigateToMessages();
                    }
                  },
                  icon: const Icon(Icons.message, size: 20),
                  label: const Text('In-App Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _sendWhatsAppMessage() async {
    try {
      String phoneNumber = _profileData?['phone_no'];

      if (phoneNumber.toString().isEmpty) {
        _showErrorSnackBar('WhatsApp number not available');
        return;
      }

      // Clean and format the phone number
      String cleanedNumber = _cleanPhoneNumber(phoneNumber);

      String message = "Hello! I'm reaching out to you.";
      String encodedMessage = Uri.encodeComponent(message);

      final whatsappUrl = 'https://wa.me/$cleanedNumber?text=$encodedMessage';
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(
          Uri.parse(
              "whatsapp://send?phone=$cleanedNumber&text=${Uri.encodeComponent(message)}"),
          mode: LaunchMode.externalApplication,
        );
        // _showErrorSnackBar('WhatsApp is not installed or number is invalid');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening WhatsApp: ${e.toString()}');
    }
  }

  String _cleanPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If number starts with 0, replace with country code (example for India: 91)
    if (cleaned.startsWith('0')) {
      cleaned = '91${cleaned.substring(1)}';
    }

    // If number doesn't start with country code, add it
    if (!cleaned.startsWith('91') && cleaned.length == 10) {
      cleaned = '91$cleaned';
    }

    return cleaned;
  }

// Alternative version with custom message parameter
  void _sendWhatsAppMessageWithText(String messageText) async {
    try {
      String phoneNumber = _profileData?['phone_no'];

      if (phoneNumber.toString().isEmpty) {
        _showErrorSnackBar('WhatsApp number not available');
        return;
      }

      // Encode the message for URL
      String encodedMessage = Uri.encodeComponent(messageText);

      // Create WhatsApp URL with message
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('WhatsApp is not installed or number is invalid');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening WhatsApp: ${e.toString()}');
    }
  }

// Helper method to show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getButtonColor() {
    return _profileData != null && _profileData!['button_color_code'] != null
        ? Color(int.parse(
            'FF${_profileData!['button_color_code'].substring(1)}',
            radix: 16))
        : Colors.yellow;
  }

  Color _getBgColor() {
    return _profileData != null && _profileData!['bg_color_code'] != null
        ? Color(int.parse('FF${_profileData!['bg_color_code'].substring(1)}',
            radix: 16))
        : Colors.black;
  }

  Color _getButtonTextColor() {
    return _profileData != null && _profileData!['button_text_color'] != null
        ? Color(int.parse(
            'FF${_profileData!['button_text_color'].substring(1)}',
            radix: 16))
        : Colors.white;
  }

  Color _getBgTextColor() {
    return _profileData != null && _profileData!['bg_text_color'] != null
        ? Color(int.parse('FF${_profileData!['bg_text_color'].substring(1)}',
            radix: 16))
        : Colors.black;
  }

  Widget _buildStatWidget(
    BuildContext context,
    String value,
    String label,
    Color textColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  void _showAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantWidget(
        userId: widget.userId,
        bgColor: _getBgColor(),
        buttonColor: _getButtonColor(),
        buttonTextColor: _getButtonTextColor(),
        textColor: _getBgTextColor(),
      ),
    );
  }

  void _shareToWhatsApp() async {
    try {
      String profileUrl =
          '${WhatsAppShareHelper.baseAppUrl}/verifiedProfile?userid=${widget.userId}';
      String message = 'Check out this profile: $profileUrl';
      String whatsappUrl =
          'https://wa.me/?text=${Uri.encodeComponent(message)}';
      _launchUrl(whatsappUrl);
    } catch (e) {
      String profileUrl =
          '${WhatsAppShareHelper.baseAppUrl}/verifiedProfile?userid=${widget.userId}';
      String message = 'Check out this profile: $profileUrl';
      await launchUrl(
        Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}"),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _shareToInstagram() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/verifiedProfile?userid=${widget.userId}';
    // Instagram doesn't support direct text sharing, so copy to clipboard
    flutter.Clipboard.setData(flutter.ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied! Paste in Instagram')),
    );
  }

  void _copyLink() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/verifiedProfile?userid=${widget.userId}';
    flutter.Clipboard.setData(flutter.ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard ')),
    );
  }

  void _shareToAnywhere() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/verifiedProfile?userid=${widget.userId}';
    Share.share('Check out this profile: $profileUrl');
  }

  // https://handskillapp.web.app/verifiedProfile?userid=67f21fa3-3cc9-4bad-9554-be88b8c4b740
//   https://handskillapp.web.app/?userid=67f21fa3-3cc9-4bad-9554-be88b8c4b740
// https://handskillapp.web.app/verifiedProfile?userid=b7f62747-0eb9-46af-aafc-af62dd5eb86d
// // https://handskillapp.web.app/searchprofileuser?userid=9109026b-80d0-4dad-aab4-712c90c975bd
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

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
                    ? 'Are you sure you want to unblock ${_profileData!['name'] ?? 'No Name'}?'
                    : 'Are you sure you want to block  ${_profileData!['name'] ?? 'No Name'}? You won\'t be able to send or receive messages.',
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

  double _getRandomHeight(int index) {
    final heights = [180.0, 220.0, 200.0, 240.0, 190.0, 210.0, 230.0];
    return heights[index % heights.length];
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = _getButtonColor();
    Color bgColor = _getBgColor();
    Color buttonTextColor = _getButtonTextColor();
    Color bgTextColor = _getBgTextColor();

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: bgColor, // Pass as parameter
            onSelected: (String value) async {
              switch (value) {
                case 'whatsapp':
                  _shareToWhatsApp();
                  break;
                case 'instagram':
                  _shareToInstagram();
                  break;
                case 'share':
                  _shareToAnywhere();
                  break;
                case 'insta_profile':
                  final String instaLink = _profileData!['insta_link'] ?? '';
                  if (instaLink.isNotEmpty) {
                    final Uri url = Uri.parse(instaLink);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      // Fallback to Instagram app or web
                      final String instaId = _profileData!['insta_id'] ?? '';
                      if (instaId.isNotEmpty) {
                        final Uri fallbackUrl =
                            Uri.parse('https://instagram.com/$instaId');
                        if (await canLaunchUrl(fallbackUrl)) {
                          await launchUrl(fallbackUrl,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    }
                  }
                  break;
                case 'copy':
                  _copyLink();
                  break;
                case 'navigate':
                  context.push('/home');
                case 'report':
                  final isAuthenticated =
                      await AuthAlertBox.checkAuthAndShowAlert(
                    context: context,
                    customMessage: "Please login to report content",
                  );
                  if (isAuthenticated) {
                    ReportHelper.showReportDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      contentType: 'account',
                      contentId: widget.userId.toString(),
                      contentTitle: _profileData!['name'].toString(),
                      onReportSubmitted: () {
                        Navigator.of(context).pop(); // Go back to previous page
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
                case 'block':
                  final isAuthenticated =
                      await AuthAlertBox.checkAuthAndShowAlert(
                    context: context,
                    customMessage: "Please login to block content",
                  );
                  if (isAuthenticated) {
                    _showBlockDialog();
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.message,
                        color: buttonColor), // Pass as parameter
                    const SizedBox(width: 8),
                    Text('Share to WhatsApp',
                        style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'instagram',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Share to Instagram',
                        style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              if (_profileData!['insta_link'] != null &&
                  _profileData!['insta_link'].toString().isNotEmpty)
                PopupMenuItem<String>(
                  value: 'insta_profile',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: buttonTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Instagram Profile',
                          style: TextStyle(color: bgTextColor)),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Share to anywhere',
                        style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Copy Link', style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'navigate',
                child: Row(
                  children: [
                    Icon(Icons.home, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Home Page', style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: buttonColor),
                    const SizedBox(width: 8),
                    Text('Report', style: TextStyle(color: bgTextColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'block',
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
            ],
          ),
        ],

        // Helper methods
      ),
      body: _isLoading
          ? ListViewShimmer(
              cardHeight: 250.0,
              baseColor: const Color.fromARGB(255, 30, 30, 30)!,
              highlightColor: const Color.fromARGB(255, 43, 43, 43),
              duration: const Duration(milliseconds: 2000),
            )
          : _profileData == null
              ? ListViewShimmer(
                  cardHeight: 250.0,
                  baseColor: const Color.fromARGB(255, 30, 30, 30)!,
                  highlightColor: const Color.fromARGB(255, 43, 43, 43),
                  duration: const Duration(milliseconds: 2000),
                )
              : _checkingBlockStatus
                  ? const Center(child: CircularProgressIndicator())
                  : _isBlockedByOther
                      ? _buildBlockedByOtherView()
                      : _isBlocked
                          ? _buildBlockedView()
                          : Stack(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: _profileData!['banner_image_url'] !=
                                            null
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              _profileData!['banner_image_url'],
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: _profileData!['banner_image_url'] ==
                                            null
                                        ? buttonColor
                                        : null,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          bgColor.withValues(alpha: 0.8),
                                          bgColor,
                                        ],
                                        stops: const [0.1, 0.7, 0.9],
                                      ),
                                    ),
                                  ),
                                ),

                                // Main content
                                CustomScrollView(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 600,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isExpanded = !_isExpanded;
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: bgColor.withValues(
                                                    alpha: 0.95),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 15,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: buttonColor.withValues(
                                                      alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        10, 10, 10, 10),
                                                    child: Row(
                                                      children: [
                                                        // Profile image
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        11),
                                                            border: Border.all(
                                                              color: buttonColor
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 2.0,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 8,
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        11),
                                                            child: Container(
                                                              width: 70,
                                                              height: 70,
                                                              color: bgColor,
                                                              child: _profileData![
                                                                          'profile_image_url'] !=
                                                                      null
                                                                  ? CachedNetworkImage(
                                                                      imageUrl:
                                                                          _profileData![
                                                                              'profile_image_url'],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .person,
                                                                      size: 40,
                                                                      color: bgTextColor
                                                                          .withOpacity(
                                                                              0.7),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        // Name and shop info
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 60,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      _profileData![
                                                                              'name'] ??
                                                                          'No Name',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            bgTextColor,
                                                                      ),
                                                                    ),
                                                                    buildVerifiedTick(
                                                                        _profileData?['verified'] ??
                                                                            false,
                                                                        buttonColor),
                                                                  ],
                                                                ),
                                                                if (_profileData![
                                                                        'shop_name'] !=
                                                                    null)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            1.0),
                                                                    child: Text(
                                                                      _profileData![
                                                                          'shop_name'],
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: bgTextColor.withValues(
                                                                            alpha:
                                                                                0.7),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                // Location
                                                                if (_profileData![
                                                                            'city'] !=
                                                                        null ||
                                                                    _profileData![
                                                                            'country'] !=
                                                                        null)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            3.0),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          size:
                                                                              14,
                                                                          color:
                                                                              bgTextColor.withValues(alpha: 0.6),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                2),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            [
                                                                              _profileData!['city'],
                                                                              _profileData!['state'],
                                                                              _profileData!['country']
                                                                            ].where((item) => item != null).join(', '),
                                                                            style:
                                                                                TextStyle(
                                                                              color: bgTextColor.withValues(alpha: 0.6),
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 11,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        Container(
                                                          child:
                                                              GestureDetector(
                                                            child: _buildStatWidget(
                                                                context,
                                                                _followersCountFormatted
                                                                    .toString(),
                                                                'Followers',
                                                                bgTextColor),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Icon(
                                                          _isExpanded
                                                              ? Icons
                                                                  .arrow_drop_up
                                                              : Icons
                                                                  .arrow_forward_ios,
                                                          color: bgTextColor,
                                                          size: 16,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  // Expandable Bio Section
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    height:
                                                        _isExpanded ? null : 0,
                                                    child: _isExpanded
                                                        ? Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    0,
                                                                    20,
                                                                    20),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Divider(
                                                                  color: buttonColor
                                                                      .withOpacity(
                                                                          0.2),
                                                                  thickness: 1,
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                if (_profileData![
                                                                        'bio'] !=
                                                                    null)
                                                                  Text(
                                                                    _profileData![
                                                                        'bio'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: bgTextColor
                                                                          .withOpacity(
                                                                              0.8),
                                                                      height:
                                                                          1.4,
                                                                    ),
                                                                  )
                                                                else
                                                                  Text(
                                                                    'No bio available',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: bgTextColor
                                                                          .withOpacity(
                                                                              0.5),
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    ),
                                                                  ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                if (_profileData![
                                                                            'slug'] !=
                                                                        null &&
                                                                    _profileData![
                                                                            'slug']
                                                                        .toString()
                                                                        .isNotEmpty)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        final url =
                                                                            'https://handskillapp.web.app/${_profileData!['slug']}';
                                                                        if (await canLaunchUrl(
                                                                            Uri.parse(url))) {
                                                                          await launchUrl(
                                                                              Uri.parse(url),
                                                                              mode: LaunchMode.externalApplication);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.language,
                                                                              size: 16,
                                                                              color: buttonColor),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              'handskillapp.web.app/${_profileData!['slug']}',
                                                                              style: TextStyle(
                                                                                fontSize: 13,
                                                                                color: buttonColor,
                                                                                decoration: TextDecoration.underline,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: buttonColor
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      _buildStatWidget(
                                                                          context,
                                                                          _galleryItems
                                                                              .length
                                                                              .toString(),
                                                                          'Gallery',
                                                                          bgTextColor),
                                                                      _buildStatWidget(
                                                                          context,
                                                                          _serviceItems
                                                                              .length
                                                                              .toString(),
                                                                          'Services',
                                                                          bgTextColor),
                                                                      GestureDetector(
                                                                        // onTap: _navigateToFollowers,
                                                                        child: _buildStatWidget(
                                                                            context,
                                                                            _followersCountFormatted.toString(),
                                                                            'Followers',
                                                                            bgTextColor),
                                                                      ),
                                                                      GestureDetector(
                                                                        // onTap: _navigateToFollowing,
                                                                        child: _buildStatWidget(
                                                                            context,
                                                                            _followingCountFormatted.toString(),
                                                                            'Following',
                                                                            bgTextColor),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          11),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: bgColor
                                                                        .withOpacity(
                                                                            0.95),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withValues(alpha: 0.08),
                                                                        blurRadius:
                                                                            12,
                                                                        spreadRadius:
                                                                            1,
                                                                      ),
                                                                    ],
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: buttonColor
                                                                          .withOpacity(
                                                                              0.2),
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      // Message Button
                                                                      Expanded(
                                                                        child: ElevatedButton
                                                                            .icon(
                                                                          onPressed:
                                                                              _showMessageOptions,
                                                                          icon: const Icon(
                                                                              Icons.message,
                                                                              size: 18),
                                                                          label:
                                                                              const Text('Message'),
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                buttonColor,
                                                                            foregroundColor:
                                                                                buttonTextColor,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 17),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                            ),
                                                                            elevation:
                                                                                0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      // Follow Button
                                                                      Expanded(
                                                                        child:
                                                                            FollowButton(
                                                                          initialIsFollowing:
                                                                              _isFollowing,
                                                                          userId:
                                                                              widget.userId,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: PopularPageViewBanner(
                                        userBanners: _userBanners,
                                        bgColor: bgColor,
                                        bgtextcolor: bgTextColor,
                                        buttonColor: buttonColor,
                                        buttonTextColor: buttonTextColor,
                                        userid: widget.userId,
                                        autoScrollDuration:
                                            const Duration(seconds: 5),
                                        enableAutoScroll: true,
                                      ),
                                    ),
                                    PopularGalleryBanner(
                                      bgColor: bgColor,
                                      bgtextcolor: bgTextColor,
                                      buttonColor: buttonColor,
                                      buttonTextColor: buttonTextColor,
                                      galleryItems: _galleryItems,
                                      userid: widget.userId,
                                    ),
                                    SliverToBoxAdapter(
                                      child: _hasEvents
                                          ? EventsDisplayHomePage(
                                              userId: widget.userId,
                                            )
                                          : const SizedBox(height: 0),
                                    ),
                                    SliverPersistentHeader(
                                      pinned: true,
                                      delegate: SliverAppBarDelegate(
                                        TabBar(
                                          controller: _tabController,
                                          labelColor: buttonColor,
                                          unselectedLabelColor: bgTextColor
                                              .withValues(alpha: 0.7),
                                          indicatorColor: buttonColor,
                                          indicatorWeight: 3,
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          tabs: const [
                                            Tab(
                                                icon: Icon(Icons
                                                    .photo_library_rounded)),
                                            Tab(
                                                icon: Icon(Icons
                                                    .miscellaneous_services)),
                                            Tab(
                                                icon: Icon(
                                                    Icons.chat_bubble_outline)),
                                          ],
                                        ),
                                        color: bgColor,
                                      ),
                                    ),
                                    SliverFillRemaining(
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          // Gallery Tab
                                          _galleryItems.isEmpty
                                              ? Center(
                                                  child: Text('no gallery',
                                                      style: TextStyle(
                                                          color: bgTextColor)),
                                                )
                                              : LayoutBuilder(
                                                  builder:
                                                      (context, constraints) {
                                                    // Dynamically calculate number of columns based on width
                                                    int crossAxisCount =
                                                        _calculateColumnCount(
                                                            constraints
                                                                .maxWidth);

                                                    return Column(
                                                      children: [
                                                        // Category Filter Chips
                                                        if (_categories.length >
                                                            1)
                                                          Container(
                                                            height: 50,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: ListView
                                                                .builder(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0),
                                                              itemCount:
                                                                  _categories
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final category =
                                                                    _categories[
                                                                        index];
                                                                final isSelected =
                                                                    _selectedCategory ==
                                                                        category;

                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8.0),
                                                                  child:
                                                                      FilterChip(
                                                                    label: Text(
                                                                      category,
                                                                      style:
                                                                          TextStyle(
                                                                        color: isSelected
                                                                            ? bgColor
                                                                            : bgTextColor,
                                                                        fontWeight: isSelected
                                                                            ? FontWeight.w600
                                                                            : FontWeight.normal,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                    selected:
                                                                        isSelected,
                                                                    onSelected:
                                                                        (selected) {
                                                                      _filterGalleryByCategory(
                                                                          category);
                                                                    },
                                                                    backgroundColor: isSelected
                                                                        ? Colors
                                                                            .transparent
                                                                        : bgColor,
                                                                    selectedColor: _profileData?['button_color_code'] !=
                                                                            null
                                                                        ? Color(int.parse(_profileData!['button_color_code'].replaceAll(
                                                                            '#',
                                                                            '0xFF')))
                                                                        : Colors
                                                                            .blue,
                                                                    side:
                                                                        BorderSide(
                                                                      color: isSelected
                                                                          ? (_profileData?['button_color_code'] != null
                                                                              ? Color(int.parse(_profileData!['button_color_code'].replaceAll('#', '0xFF')))
                                                                              : Colors.blue)
                                                                          : bgColor,
                                                                      width: 0,
                                                                    ),
                                                                    checkmarkColor:
                                                                        bgColor,
                                                                    elevation:
                                                                        isSelected
                                                                            ? 0
                                                                            : 0,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),

                                                        // Gallery Grid
                                                        Expanded(
                                                          child:
                                                              _filteredGalleryItems
                                                                      .isEmpty
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                        _selectedCategory ==
                                                                                'All'
                                                                            ? 'no gallery'
                                                                            : 'No items in $_selectedCategory category',
                                                                        style: TextStyle(
                                                                            color:
                                                                                bgTextColor),
                                                                      ),
                                                                    )
                                                                  : LayoutBuilder(
                                                                      builder:
                                                                          (context,
                                                                              constraints) {
                                                                        int crossAxisCount =
                                                                            _calculateColumnCount(constraints.maxWidth);

                                                                        return MasonryGridView
                                                                            .count(
                                                                          crossAxisCount:
                                                                              crossAxisCount,
                                                                          mainAxisSpacing:
                                                                              8,
                                                                          crossAxisSpacing:
                                                                              8,
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          itemCount:
                                                                              _filteredGalleryItems.length,
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            final item =
                                                                                _filteredGalleryItems[index];

                                                                            return GestureDetector(
                                                                              onTap: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => GalleryDetailsprofilePage(
                                                                                      userid: widget.userId,
                                                                                      item: item,
                                                                                      allItems: _filteredGalleryItems,
                                                                                      initialIndex: index,
                                                                                      bgColor: bgColor,
                                                                                      bgtextcolor: bgTextColor,
                                                                                      buttoncolorcode: buttonColor,
                                                                                      buttontextcolor: buttonTextColor,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              // onTap: () => _showGalleryItemDetails(item),
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  boxShadow: [
                                                                                    BoxShadow(
                                                                                      color: Colors.black.withValues(alpha: 0.15),
                                                                                      blurRadius: 8,
                                                                                      spreadRadius: 1,
                                                                                      offset: const Offset(0, 2),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      // Background Image
                                                                                      Container(
                                                                                        height: _getRandomHeight(index),
                                                                                        width: double.infinity,
                                                                                        decoration: BoxDecoration(
                                                                                          image: DecorationImage(
                                                                                            image: CachedNetworkImageProvider(
                                                                                              item['gallery_image_url'] ?? 'https://via.placeholder.com/150',
                                                                                            ),
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      // Gradient Overlay
                                                                                      Positioned.fill(
                                                                                        child: Container(
                                                                                          decoration: BoxDecoration(
                                                                                            gradient: LinearGradient(
                                                                                              begin: Alignment.topCenter,
                                                                                              end: Alignment.bottomCenter,
                                                                                              colors: [
                                                                                                Colors.transparent,
                                                                                                Colors.transparent,
                                                                                                Colors.black.withValues(alpha: 0.1),
                                                                                                Colors.black.withValues(alpha: 0.7),
                                                                                              ],
                                                                                              stops: const [
                                                                                                0.0,
                                                                                                0.5,
                                                                                                0.8,
                                                                                                1.0
                                                                                              ],
                                                                                            ),
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
                                                                                              if (item['gallery_title'] != null)
                                                                                                Container(
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.black.withValues(alpha: 0.3),
                                                                                                    borderRadius: BorderRadius.circular(6),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    item['gallery_title'],
                                                                                                    style: const TextStyle(
                                                                                                      color: Colors.white,
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      fontSize: 13,
                                                                                                    ),
                                                                                                    maxLines: 2,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                  ),
                                                                                                ),
                                                                                              if (item['gallery_price'] != null && item['gallery_price'] != 0 && item['gallery_price'] != '0') const SizedBox(height: 6),
                                                                                              if (item['gallery_price'] != null && item['gallery_price'] != 0 && item['gallery_price'] != '0')
                                                                                                Container(
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.green.withValues(alpha: 0.8),
                                                                                                    borderRadius: BorderRadius.circular(6),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    '₹${item['gallery_price']}',
                                                                                                    style: const TextStyle(
                                                                                                      color: Colors.white,
                                                                                                      fontSize: 12,
                                                                                                      fontWeight: FontWeight.w600,
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
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                          _serviceItems.isEmpty
                                              ? Center(
                                                  child: Text('No services',
                                                      style: TextStyle(
                                                          color: bgTextColor)))
                                              : ListView.builder(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  itemCount:
                                                      _serviceItems.length,
                                                  // physics:
                                                  //     const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final service =
                                                        _serviceItems[index];
                                                    return Card(
                                                      color: buttonColor,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 16),
                                                      elevation: 3,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  service['service_title'] ??
                                                                      'No Title',
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        buttonTextColor,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Chip(
                                                                  label: Text(
                                                                    '\₹${service['service_price'] ?? 0}',
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          buttonColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  backgroundColor:
                                                                      buttonTextColor,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                                ),
                                                              ],
                                                            ),
                                                            if (service[
                                                                    'service_category'] !=
                                                                null)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            4.0),
                                                                child: Text(
                                                                  service[
                                                                      'service_category'],
                                                                  style:
                                                                      TextStyle(
                                                                    color: buttonTextColor
                                                                        .withOpacity(
                                                                            0.8),
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (service[
                                                                    'service_description'] !=
                                                                null)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                child: Text(
                                                                  service[
                                                                      'service_description'],
                                                                  style:
                                                                      TextStyle(
                                                                    color: buttonTextColor
                                                                        .withOpacity(
                                                                            0.8),
                                                                    height: 1.3,
                                                                  ),
                                                                ),
                                                              ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      ElevatedButton
                                                                          .icon(
                                                                    onPressed:
                                                                        _navigateToMessages,
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .message,
                                                                        size:
                                                                            18),
                                                                    label: const Text(
                                                                        'Message'),
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          buttonTextColor,
                                                                      foregroundColor:
                                                                          buttonColor,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              17),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(12),
                                                                      ),
                                                                      elevation:
                                                                          0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                          userThreads.isEmpty
                                              ? Center(
                                                  child: Text(
                                                  'No threads yet',
                                                  style: TextStyle(
                                                      color: bgTextColor),
                                                ))
                                              : ListView.builder(
                                                  // physics:
                                                  //     const NeverScrollableScrollPhysics(),
                                                  itemCount: userThreads.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final thread =
                                                        userThreads[index];
                                                    //  final Map<String, dynamic> threads = userThreads[index];
                                                    final int likeCount =
                                                        (thread['like_count']
                                                                as int?) ??
                                                            0;
                                                    final int fakeLikes =
                                                        (thread['fake_likes']
                                                                as int?) ??
                                                            0;
                                                    final int totalLikes =
                                                        likeCount + fakeLikes;
                                                    final String
                                                        formattedLikes =
                                                        _formatCount(
                                                            totalLikes);
                                                    return Card(
                                                      color: buttonColor,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 1,
                                                        horizontal: 16,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              timeago.format(
                                                                  DateTime.parse(
                                                                      thread[
                                                                          'created_at'])),
                                                              style: TextStyle(
                                                                color:
                                                                    buttonTextColor,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              thread['content'],
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    buttonTextColor,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () => {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => ThreadCommentsPage(
                                                                                  threadContent: thread['content'],
                                                                                  threadId: thread['id'],
                                                                                )))
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .favorite,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              buttonTextColor),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                          formattedLikes,
                                                                          style:
                                                                              TextStyle(color: buttonTextColor)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () => {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => ThreadCommentsPage(
                                                                                  threadContent: thread['content'],
                                                                                  threadId: thread['id'],
                                                                                )))
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .comment,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              buttonTextColor),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                          '${thread['comment_count'] ?? 0}',
                                                                          style:
                                                                              TextStyle(color: buttonTextColor)),
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
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth:
                                          400, // Set your desired max width
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 3),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getButtonColor()
                                                        .withValues(
                                                            alpha: 0.80),
                                                    _getButtonColor()
                                                        .withValues(
                                                            alpha: 0.60),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _getButtonColor(),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 20,
                                                    spreadRadius: 0,
                                                    offset: Offset(0, 8),
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.05),
                                                    blurRadius: 6,
                                                    spreadRadius: 0,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Search Button
                                                  _buildNavButton(
                                                    color1:
                                                        _getButtonTextColor(),
                                                    icon: Icons.search_rounded,
                                                    label: 'Search',
                                                    color: _getButtonColor(),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              GalleryProfileSearchPage(
                                                                  userid: widget
                                                                      .userId),
                                                        ),
                                                      );
                                                    },
                                                  ),

                                                  // AI Assistant Button (Center - Featured)
                                                  InkWell(
                                                    onTap: () =>
                                                        _showAIAssistant(
                                                            context),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            _getButtonTextColor()
                                                                // ignore: deprecated_member_use
                                                                .withOpacity(
                                                                    0.8),
                                                            _getButtonTextColor()
                                                                // ignore: deprecated_member_use
                                                                .withOpacity(
                                                                    0.3),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                _getButtonTextColor()
                                                                    .withOpacity(
                                                                        0.8),
                                                            blurRadius: 8,
                                                            offset:
                                                                Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .smart_toy_rounded, // AI assistant icon
                                                        color:
                                                            _getButtonColor(),
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),

                                                  // Profile Button
                                                  _buildNavButton(
                                                    color1:
                                                        _getButtonTextColor(),
                                                    icon: Icons.person_rounded,
                                                    label: 'Profile',
                                                    color: _getButtonColor(),
                                                    onTap: () async {
                                                      final isAuthenticated =
                                                          await AuthAlertBox
                                                              .checkAuthAndShowAlert(
                                                        context: context,
                                                        customMessage:
                                                            "Please login to view your profile",
                                                      );
                                                      if (isAuthenticated) {
                                                        Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation) =>
                                                                const ProfileSwitchPage(
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                            ),
                                                            transitionsBuilder:
                                                                (context,
                                                                    animation,
                                                                    secondaryAnimation,
                                                                    child) {
                                                              const begin = Offset(
                                                                  1.0,
                                                                  0.0); // Start from right
                                                              const end =
                                                                  Offset.zero;
                                                              const curve =
                                                                  Curves
                                                                      .easeInOut;

                                                              final tween = Tween(
                                                                      begin:
                                                                          begin,
                                                                      end: end)
                                                                  .chain(CurveTween(
                                                                      curve:
                                                                          curve));
                                                              final offsetAnimation =
                                                                  animation
                                                                      .drive(
                                                                          tween);

                                                              return SlideTransition(
                                                                position:
                                                                    offsetAnimation,
                                                                child: child,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  _getButtonColor()
                                                      .withValues(alpha: 0.50),
                                                  _getButtonColor()
                                                      .withValues(alpha: 0.30),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: _getButtonColor(),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 20,
                                                  spreadRadius: 0,
                                                  offset: Offset(0, 8),
                                                ),
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 6,
                                                  spreadRadius: 0,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    final isAuthenticated =
                                                        await AuthAlertBox
                                                            .checkAuthAndShowAlert(
                                                      context: context,
                                                      customMessage:
                                                          "Please login to view your Message",
                                                    );
                                                    if (isAuthenticated) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const MessageListPage(),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(7),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          _getButtonTextColor()
                                                              .withValues(
                                                                  alpha: 0.8),
                                                          _getButtonTextColor()
                                                              .withValues(
                                                                  alpha: 0.3),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              _getButtonTextColor()
                                                                  .withOpacity(
                                                                      0.8),
                                                          blurRadius: 8,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .message_rounded, // AI assistant icon
                                                      color: _getButtonColor(),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                if (_showScrollToTop)
                                  Positioned(
                                    top: MediaQuery.of(context).padding.top +
                                        50, // Below status bar
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _scrollToTop,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: AnimatedContainer(
                                                    height: 50,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          // ignore: deprecated_member_use
                                                          buttonColor
                                                              .withValues(
                                                                  alpha: 0.9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              // ignore: deprecated_member_use
                                                              .withValues(
                                                                  alpha: 0.2),
                                                          blurRadius: 8,
                                                          spreadRadius: 1,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                      border: Border.all(
                                                        color: buttonColor
                                                            .withValues(
                                                                alpha: 0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_up,
                                                          color:
                                                              buttonTextColor,
                                                          size: 24,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'Top',
                                                          style: TextStyle(
                                                            color:
                                                                buttonTextColor,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                      ),
                                    ),
                                  ),
                              ],
                            ),
      // floatingActionButton:
      //     _checkingBlockStatus || _isBlockedByOther || _isBlocked
      //         ? null // Hide FAB when blocked
      //         : FloatingActionButton.extended(
      //             onPressed: () => _showAIAssistant(context),
      //             icon: const Icon(Icons.smart_toy_rounded),
      //             label: const Text('Ask AI'),
      //             backgroundColor: _getButtonColor(),
      //             foregroundColor: _getButtonTextColor(),
      //           ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color color1,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color1.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 17,
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
          const Text(
            'You have blocked ',
            style: TextStyle(
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

  Future<void> _blockUser() async {
    try {
      await _supabase.rpc('block_user', params: {
        'target_user_id': widget.userId,
      });

      _showSuccessSnackBar('User blocked successfully');
      _checkBlockStatus();
    } catch (e) {
      debugPrint('Error blocking user: $e');
      _showErrorSnackBar('Failed to block user');
    }
  }

  Future<void> _unblockUser() async {
    try {
      await _supabase.rpc('unblock_user', params: {
        'target_user_id': widget.userId,
      });

      _showSuccessSnackBar('User unblocked successfully');
      _checkBlockStatus();
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      _showErrorSnackBar('Failed to unblock user');
    }
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
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  SliverAppBarDelegate(this.tabBar, {required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || color != oldDelegate.color;
  }
}

int _calculateColumnCount(double width) {
  if (width < 400) {
    return 3; // Very small mobile screens
  } else if (width < 600) {
    return 4; // Small mobiles
  } else if (width < 750) {
    return 5; // Mid-size mobiles / phablets
  } else if (width < 900) {
    return 6; // Large phones / small tablets
  } else if (width < 1050) {
    return 7; // Tablets
  } else if (width < 1200) {
    return 8; // Large tablets / small desktops
  } else if (width < 1500) {
    return 9; // Standard desktops
  } else if (width < 1800) {
    return 10; // Large desktops
  } else if (width < 2100) {
    return 11; // Ultra-wide screens
  } else {
    return 12; // Super ultra-wide screens
  }
}

class AIAssistantWidget extends StatefulWidget {
  final String userId;
  final Color? buttonColor;
  final Color? bgColor;
  final Color? textColor;
  final Color? buttonTextColor;

  const AIAssistantWidget({
    super.key,
    required this.userId,
    this.buttonColor,
    this.bgColor,
    this.textColor,
    this.buttonTextColor,
  });

  @override
  State<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends State<AIAssistantWidget>
    with TickerProviderStateMixin {
  final SupabaseClient _supabase = SupaFlow.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  final bool _isLoading = false;
  bool _isTyping = false;
  bool _showSuggestedQuestions = true;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _galleryItems = [];
  List<Map<String, dynamic>> _serviceItems = [];
  String _followersCount = '0';
  String _followingCount = '0';

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // Suggested questions
  final List<String> _suggestedQuestions = [
    "Who is this person?",
    "Tell me about their profile",
    "Show me their gallery",
    "What services do they offer?",
    "How can I contact them?",
    "Where are they located?",
    "What are their prices?",
    "Show me their best work",
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    _initializeAI();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeAI() {
    _fetchProfileData().then((_) {
      final aiName = _getAIName();
      _addMessage(ChatMessage(
        text:
            "Hello! I'm $aiName. I can help you with detailed information about this profile, show you gallery items with images, services, and much more. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getAIName() {
    if (_profileData != null && _profileData!['shop_name'] != null) {
      return "${_profileData!['shop_name']} Assistant AI";
    }
    return "Assistant AI";
  }

  void _addMessage(ChatMessage message) {
    safeSetState(() {
      _messages.add(message);
      if (message.isUser) {
        _showSuggestedQuestions = false;
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchProfileData() async {
    try {
      // Fetch profile data
      final profileResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          profile_id, profile_created_at, user_id, name, phone_no, country, bio, 
          shop_name, profile_image_url, banner_image_url, button_color_code, 
          bg_color_code, bg_text_color, state, city, button_text_color, verified
        ''')
          .eq('user_id', widget.userId)
          .limit(1);

      if (profileResponse.isNotEmpty) {
        _profileData = profileResponse.first;
      }

      // Fetch gallery items
      final galleryResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          gallery_id, gallery_title, gallery_description, 
          gallery_price, gallery_image_url, gallery_category
        ''')
          .eq('user_id', widget.userId)
          .not('gallery_id', 'is', null);

      _galleryItems = galleryResponse;

      // Fetch services
      final serviceResponse = await _supabase
          .from('profile_gallery_service_likes_comments_view')
          .select('''
          service_id, service_title, service_description, 
          service_price, service_category
        ''')
          .eq('user_id', widget.userId)
          .not('service_id', 'is', null);

      _serviceItems = serviceResponse;

      // Fetch follow counts
      await _fetchFollowCounts();
    } catch (e) {
      print('Error fetching data: $e');
    }
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

  Future<void> _fetchFollowCounts() async {
    try {
      // Get followers count - people who follow this user
      final followersResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('followed_id', widget.userId);

      // Get following count - people this user follows
      final followingResponse = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', widget.userId);

      // Get followers count from users table
      final userResponse = await _supabase
          .from('users')
          .select('followers')
          .eq('id', widget.userId)
          .single();

      final double userTableFollowers =
          userResponse['followers']?.toDouble() ?? 0.0;

      final int followersCountRaw =
          followersResponse.length + userTableFollowers.toInt();
      final int followingCountRaw = followingResponse.length;

      safeSetState(() {
        // _followersCount = followersCountRaw;
        // _followingCount = followingCountRaw;
        _followersCount = formatCount(followersCountRaw);
        _followingCount = formatCount(followingCountRaw);
        print('Followers count: $_followersCount');
        print('Following count: $_followingCount');
      });
    } catch (e) {
      print('Error fetching follow counts: $e');
    }
  }

  void _sendMessage([String? predefinedMessage]) async {
    final messageText = predefinedMessage ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    if (predefinedMessage == null) {
      _messageController.clear();
    }

    _addMessage(ChatMessage(
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    safeSetState(() {
      _isTyping = true;
    });
    _typingAnimationController.repeat();

    // Simulate AI thinking time
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiResponse = await _generateAIResponse(messageText);

    safeSetState(() {
      _isTyping = false;
    });
    _typingAnimationController.stop();

    _addMessage(ChatMessage(
      text: aiResponse.text,
      isUser: false,
      timestamp: DateTime.now(),
      galleryItems: aiResponse.galleryItems,
      hasGalleryGrid: aiResponse.hasGalleryGrid,
    ));
  }

  Future<AIResponse> _generateAIResponse(String userMessage) async {
    final message = userMessage.toLowerCase();

    // Who is this person queries
    if (message.contains('who is') ||
        message.contains('who are') ||
        message.contains('about this person') ||
        message.contains('tell me about them')) {
      if (_profileData != null) {
        final name = _profileData!['name'] ?? 'Unknown';
        final shopName = _profileData!['shop_name'];
        final bio = _profileData!['bio'];
        final verified = _profileData!['verified'] == true;
        final location =
            "${_profileData!['city'] ?? ''}, ${_profileData!['state'] ?? ''}"
                    .replaceAll(', ', '')
                    .isNotEmpty
                ? "${_profileData!['city'] ?? ''}, ${_profileData!['state'] ?? ''}"
                : "Location not specified";

        String response = "This is $name";
        if (shopName != null) response += ", owner of $shopName";
        response += ".\n\n";

        if (verified) response += "✓ Verified Profile\n";
        response += "📍 Located in $location\n";
        response +=
            "👥 $_followersCount followers, $_followingCount following\n\n";

        if (bio != null && bio.isNotEmpty) {
          response += "About them:\n$bio\n\n";
        }

        response +=
            "They have ${_galleryItems.length} gallery items and ${_serviceItems.length} services available.";

        return AIResponse(text: response);
      }
      return AIResponse(
          text:
              "I'm still loading the profile information. Please wait a moment and try again.");
    }

    // Profile information queries
    if (message.contains('profile') ||
        message.contains('about') ||
        message.contains('info')) {
      if (_profileData != null) {
        final joinDate = _profileData!['profile_created_at'] != null
            ? DateTime.parse(_profileData!['profile_created_at']).year
            : 'Unknown';

        return AIResponse(
            text: "Here's the complete profile information:\n\n"
                "👤 Name: ${_profileData!['name'] ?? 'Not provided'}\n"
                "🏪 Shop: ${_profileData!['shop_name'] ?? 'Not provided'}\n"
                "📍 Location: ${_profileData!['city'] ?? 'Unknown'}, ${_profileData!['state'] ?? 'Unknown'}\n"
                "🌍 Country: ${_profileData!['country'] ?? 'Not specified'}\n"
                "✅ Verified: ${_profileData!['verified'] == true ? 'Yes ✓' : 'No'}\n"
                "📅 Member since: $joinDate\n"
                "👥 Followers: $_followersCount\n"
                "👤 Following: $_followingCount\n"
                "🖼️ Gallery Items: ${_galleryItems.length}\n"
                "🛠️ Services: ${_serviceItems.length}\n\n"
                "Bio: ${_profileData!['bio'] ?? 'No bio available'}");
      }
      return AIResponse(
          text:
              "I'm still loading the profile information. Please wait a moment and try again.");
    }

    // Gallery queries with images
    if (message.contains('gallery') ||
        message.contains('show me') ||
        message.contains('items') ||
        message.contains('products') ||
        message.contains('work') ||
        message.contains('portfolio')) {
      if (_galleryItems.isNotEmpty) {
        return AIResponse(
          text:
              "Here are the gallery items (${_galleryItems.length} total). Tap on any item to view details:",
          galleryItems: _galleryItems,
          hasGalleryGrid: true,
        );
      }
      return AIResponse(
          text: "This profile doesn't have any gallery items yet.");
    }

    // Services queries
    if (message.contains('service') || message.contains('services')) {
      if (_serviceItems.isNotEmpty) {
        String response =
            "This profile offers ${_serviceItems.length} services:\n\n";
        for (int i = 0; i < _serviceItems.length; i++) {
          final item = _serviceItems[i];
          response +=
              "${i + 1}. ${item['service_title'] ?? 'Untitled Service'}\n";
          if (item['service_description'] != null) {
            response += "   📝 ${item['service_description']}\n";
          }
          if (item['service_price'] != null) {
            response += "   💰 Price: ₹${item['service_price']}\n";
          }
          if (item['service_category'] != null) {
            response += "   🏷️ Category: ${item['service_category']}\n";
          }
          response += "\n";
        }
        return AIResponse(text: response);
      }
      return AIResponse(text: "This profile doesn't offer any services yet.");
    }

    // Contact information
    if (message.contains('contact') ||
        message.contains('phone') ||
        message.contains('call') ||
        message.contains('reach')) {
      if (_profileData != null && _profileData!['phone_no'] != null) {
        return AIResponse(
            text: "📞 Contact Information:\n\n"
                "Phone: ${_profileData!['phone_no']}\n\n"
                "You can also:\n"
                "• Send them a direct message through the app\n"
                "• Contact via WhatsApp\n"
                "• Follow them to stay updated with their latest posts");
      }
      return AIResponse(
          text: "Contact information is not available for this profile.");
    }

    // Location queries
    if (message.contains('location') ||
        message.contains('address') ||
        message.contains('where')) {
      if (_profileData != null) {
        final city = _profileData!['city'];
        final state = _profileData!['state'];
        final country = _profileData!['country'];

        if (city != null || state != null) {
          return AIResponse(
              text: "📍 Location Information:\n\n"
                  "City: ${city ?? 'Unknown'}\n"
                  "State: ${state ?? 'Unknown'}\n"
                  "Country: ${country ?? 'Not specified'}\n\n"
                  "This is where they are based and likely provide their services.");
        }
      }
      return AIResponse(
          text: "Location information is not available for this profile.");
    }

    // Best work queries
    if (message.contains('best') ||
        message.contains('top') ||
        message.contains('featured')) {
      if (_galleryItems.isNotEmpty) {
        // Sort by price or show first few items as "best"
        final bestItems = _galleryItems.take(3).toList();
        return AIResponse(
          text: "Here are some of their best works:",
          galleryItems: bestItems,
          hasGalleryGrid: true,
        );
      }
      return AIResponse(
          text: "No gallery items available to show their best work.");
    }

    // Price queries
    if (message.contains('price') ||
        message.contains('cost') ||
        message.contains('expensive') ||
        message.contains('cheap') ||
        message.contains('budget')) {
      List<int> prices = [];

      for (var item in _galleryItems) {
        if (item['gallery_price'] != null) {
          prices.add(item['gallery_price'] as int);
        }
      }
      for (var item in _serviceItems) {
        if (item['service_price'] != null) {
          prices.add(item['service_price'] as int);
        }
      }

      if (prices.isNotEmpty) {
        prices.sort();
        return AIResponse(
            text: "💰 Pricing Information:\n\n"
                "• Lowest Price: ₹${prices.first}\n"
                "• Highest Price: ₹${prices.last}\n"
                "• Average Price: ₹${(prices.reduce((a, b) => a + b) / prices.length).round()}\n"
                "• Total Priced Items: ${prices.length}\n\n"
                "Prices may vary based on requirements and customization.");
      }
      return AIResponse(
          text:
              "No pricing information is available for this profile's items.");
    }

    // Help queries
    if (message.contains('help') || message.contains('what can you do')) {
      return AIResponse(
          text: "I'm ${_getAIName()} and I can help you with:\n\n"
              "🔍 Profile & Personal Information\n"
              "🖼️ Gallery Items with Images\n"
              "🛠️ Services & Offerings\n"
              "📞 Contact Details\n"
              "📍 Location Information\n"
              "💰 Pricing Details\n"
              "📊 Social Stats\n"
              "🏷️ Categories & Types\n"
              "⭐ Best Work & Featured Items\n\n"
              "Just ask me anything about this profile! You can also tap on the suggested questions below.");
    }

    // Greeting responses
    if (message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey') ||
        message.contains('good morning') ||
        message.contains('good afternoon')) {
      return AIResponse(
          text:
              "Hello! I'm ${_getAIName()}. I'm here to help you learn everything about this profile. "
              "You can ask me about their services, gallery items, contact information, or anything else you'd like to know!\n\n"
              "Try asking: 'Who is this person?' or 'Show me their gallery'");
    }

    // Thank you responses
    if (message.contains('thank') || message.contains('thanks')) {
      return AIResponse(
          text:
              "You're welcome! I'm always here to help. Is there anything else you'd like to know about this profile? "
              "I can show you more gallery items, services, or any other information you need.");
    }

    // Default response with suggestions
    return AIResponse(
        text:
            "I'm not sure about that specific question, but I'm ${_getAIName()} and I can help you with:\n\n"
            "👤 Profile details and personal info\n"
            "🖼️ Gallery items with images\n"
            "🛠️ Services and offerings\n"
            "📞 Contact and location info\n"
            "💰 Pricing and social stats\n\n"
            "Try asking: 'Who is this person?', 'Show me their gallery', or 'What services do they offer?'");
  }

  // "📱 Phone: ${_profileData!['phone_no'] ?? 'Not provided'}\n"
  Color _getButtonColor() {
    return widget.buttonColor ??
        (_profileData != null && _profileData!['button_color_code'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_color_code'].substring(1)}',
                radix: 16))
            : Colors.yellow);
  }

  Color _getBgColor() {
    return widget.bgColor ??
        (_profileData != null && _profileData!['bg_color_code'] != null
            ? Color(int.parse(
                'FF${_profileData!['bg_color_code'].substring(1)}',
                radix: 16))
            : Colors.black);
  }

  Color _getTextColor() {
    return widget.textColor ??
        (_profileData != null && _profileData!['bg_text_color'] != null
            ? Color(int.parse(
                'FF${_profileData!['bg_text_color'].substring(1)}',
                radix: 16))
            : Colors.white);
  }

  Color _getButtonTextColor() {
    return widget.buttonTextColor ??
        (_profileData != null && _profileData!['button_text_color'] != null
            ? Color(int.parse(
                'FF${_profileData!['button_text_color'].substring(1)}',
                radix: 16))
            : Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getBgColor(),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // ✅ hide keyboard
              },
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getButtonColor(),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _getButtonTextColor().withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header content
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getButtonTextColor()
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.smart_toy_rounded,
                                color: _getButtonTextColor(),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getAIName(),
                                    style: TextStyle(
                                      color: _getButtonTextColor(),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Your intelligent profile assistant',
                                    style: TextStyle(
                                      color: _getButtonTextColor()
                                          .withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: _getButtonTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getButtonColor().withValues(alpha: 0.05),
                      border: Border(
                        top: BorderSide(
                          color: _getButtonColor().withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getBgColor(),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color:
                                      _getButtonColor().withValues(alpha: 0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Ask me anything...',
                                  hintStyle: TextStyle(
                                    color:
                                        _getTextColor().withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(color: _getTextColor()),
                                maxLines: null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _sendMessage(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getButtonColor(),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getButtonColor()
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                color: _getButtonTextColor(),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }

                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),

                  // Suggested questions
                  if (_showSuggestedQuestions) _buildSuggestedQuestions(),

                  // Input area
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Questions:',
            style: TextStyle(
              color: _getTextColor().withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((question) {
              return GestureDetector(
                onTap: () => _sendMessage(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getButtonColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getButtonColor().withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    question,
                    style: TextStyle(
                      color: _getButtonColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getButtonColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: _getButtonColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? _getButtonColor()
                        : _getButtonColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color:
                              isUser ? _getButtonTextColor() : _getTextColor(),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color:
                              (isUser ? _getButtonTextColor() : _getTextColor())
                                  .withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getButtonColor().withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getButtonColor(),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          // Gallery grid
          if (message.hasGalleryGrid && message.galleryItems != null)
            _buildGalleryGrid(message.galleryItems!),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => _showGalleryItemDetails(item),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getButtonColor().withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: item['gallery_image_url'] != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                item['gallery_image_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: _getButtonColor().withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Icon(
                                Icons.image,
                                color: _getButtonColor(),
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['gallery_title'] ?? 'Untitled',
                            style: TextStyle(
                              color: _getTextColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (item['gallery_price'] != null)
                            Text(
                              '₹${item['gallery_price']}',
                              style: TextStyle(
                                color: _getButtonColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (item['gallery_category'] != null)
                            Text(
                              item['gallery_category'],
                              style: TextStyle(
                                color: _getTextColor().withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  void _showGalleryItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _getBgColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getButtonColor(),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['gallery_title'] ?? 'Gallery Item',
                      style: TextStyle(
                        color: _getButtonTextColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: _getButtonTextColor(),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (item['gallery_image_url'] != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getButtonColor().withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['gallery_image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[600],
                                  size: 64,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // Details
                    if (item['gallery_price'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            color: _getButtonColor(),
                            size: 18,
                          ),
                          Text(
                            '${item['gallery_price']}',
                            style: TextStyle(
                              color: _getButtonColor(),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (item['gallery_category'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: _getTextColor().withValues(alpha: 0.7),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['gallery_category'],
                            style: TextStyle(
                              color: _getTextColor().withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (item['gallery_description'] != null) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['gallery_description'],
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getButtonColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: _getButtonColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getButtonColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_getAIName().split(' ').first} is typing',
                  style: TextStyle(
                    color: _getTextColor().withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getButtonColor().withOpacity(
                              0.3 +
                                  0.7 *
                                      (((_typingAnimation.value + index * 0.3) %
                                          1.0)),
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? galleryItems;
  final bool hasGalleryGrid;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.galleryItems,
    this.hasGalleryGrid = false,
  });
}

class AIResponse {
  final String text;
  final List<Map<String, dynamic>>? galleryItems;
  final bool hasGalleryGrid;

  AIResponse({
    required this.text,
    this.galleryItems,
    this.hasGalleryGrid = false,
  });
}

class CircularShimmer extends StatelessWidget {
  final Color buttonColor;
  final Color bgColor;
  final double size;

  const CircularShimmer({
    Key? key,
    required this.buttonColor,
    required this.bgColor,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomShimmer(
        baseColor: bgColor.withValues(alpha: 0.3),
        highlightColor: buttonColor.withValues(alpha: 0.7),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class CustomShimmer extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;
  final Widget child;
  final Duration duration;

  const CustomShimmer({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class PopularGalleryBanner extends StatefulWidget {
  final Color buttonColor;
  final Color buttonTextColor;
  final Color bgColor;
  final Color bgtextcolor;
  final List<Map<String, dynamic>> galleryItems;
  final String? userid;

  const PopularGalleryBanner({
    super.key,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.bgColor,
    required this.bgtextcolor,
    required this.galleryItems,
    this.userid,
  });

  @override
  _PopularGalleryBannerState createState() => _PopularGalleryBannerState();
}

class _PopularGalleryBannerState extends State<PopularGalleryBanner> {
  List<Map<String, dynamic>> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _loadTop10Items();
  }

  void _loadTop10Items() {
    // Get only the first 10 items (or all if less than 10)
    final top10Items = widget.galleryItems.take(10).toList();

    setState(() {
      _displayedItems = top10Items;
    });
  }

  Widget _buildGalleryCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailsprofilePage(
              item: _displayedItems[index],
              allItems: _displayedItems,
              initialIndex: index,
              bgColor: widget.bgColor,
              bgtextcolor: widget.bgtextcolor,
              buttoncolorcode: widget.buttonColor,
              buttontextcolor: widget.buttonTextColor,
              userid: widget.userid,
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        margin: EdgeInsets.only(
          right: 16,
          left: index == 0 ? 16 : 0,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: widget.buttonColor.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: widget.bgColor,
            ),
            child: Stack(
              children: [
                // Background image
                if (item['gallery_image_url'] != null)
                  Positioned.fill(
                    child: Image.network(
                      item['gallery_image_url'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.buttonColor.withValues(alpha: 0.2),
                                widget.buttonColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: widget.buttonColor,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.buttonColor.withValues(alpha: 0.3),
                                widget.buttonColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color:
                                      widget.buttonColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: widget.buttonColor
                                        .withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Beautiful gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Popular badge (for first 3 items)
                if (index < 3)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.buttonColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: widget.buttonTextColor,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              color: widget.buttonTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Content overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item['gallery_title'] != null)
                          Text(
                            item['gallery_title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        if (item['gallery_description'] != null)
                          Text(
                            item['gallery_description'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (item['gallery_price'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.buttonColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.buttonColor
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '₹${item['gallery_price']}',
                                  style: TextStyle(
                                    color: widget.buttonTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    widget.bgtextcolor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: widget.bgtextcolor,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    if (_displayedItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular header section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.buttonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: widget.buttonColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.bgtextcolor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Top ${_displayedItems.length} trending items',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.bgtextcolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.buttonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_displayedItems.length}',
                    style: TextStyle(
                      color: widget.buttonColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal ListView
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 250, // Card height + shadow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    child: _buildGalleryCard(_displayedItems[index], index));
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class PopularPageViewBanner extends StatefulWidget {
  final Color buttonColor;
  final Color buttonTextColor;
  final Color bgColor;
  final Color bgtextcolor;
  final String? userid;
  final Duration autoScrollDuration;
  final bool enableAutoScroll;
  final List<Map<String, dynamic>> userBanners;

  const PopularPageViewBanner({
    super.key,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.bgColor,
    required this.bgtextcolor,
    this.userid,
    this.autoScrollDuration = const Duration(seconds: 4),
    required this.userBanners,
    this.enableAutoScroll = true,
  });

  @override
  _PopularPageViewBannerState createState() => _PopularPageViewBannerState();
}

class _PopularPageViewBannerState extends State<PopularPageViewBanner>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _userBanners = [];
  PageController _pageController = PageController();
  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    // Initialize _userBanners with the passed userBanners
    _userBanners = widget.userBanners;

    // Start auto-scroll if enabled and there are banners
    if (widget.enableAutoScroll && _userBanners.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.enableAutoScroll &&
        !_isUserScrolling &&
        _userBanners.length > 1) {
      _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
        if (mounted && !_isUserScrolling) {
          final nextIndex = (_currentIndex + 1) % _userBanners.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _pauseAutoScroll() {
    setState(() {
      _isUserScrolling = true;
    });
    _autoScrollTimer?.cancel();

    // Resume auto scroll after 3 seconds of inactivity
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserScrolling = false;
        });
        _startAutoScroll();
      }
    });
  }

  void _showBottomSheet(Map<String, dynamic> item, int index) {
    _pauseAutoScroll();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 25,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: widget.buttonColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 25),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.buttonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: widget.buttonColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banner Details',
                        style: TextStyle(
                          color: widget.bgtextcolor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Item ${index + 1} of ${_userBanners.length}',
                        style: TextStyle(
                          color: widget.bgtextcolor.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.buttonColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close,
                      color: widget.buttonColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner image
                    if (item['image_url'] != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color:
                                    widget.buttonColor.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.network(
                            item['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.buttonColor.withValues(alpha: 0.2),
                                      widget.buttonColor.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: widget.buttonColor,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ReportButton(
                          contentType: 'gallery',
                          contentId: item['id'],
                          contentTitle: item['title'] ?? '',
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
                    // Title
                    if (item['title'] != null) ...[
                      _buildDetailRow(Icons.title, 'Title', item['title'],
                          isTitle: true),
                      const SizedBox(height: 20),
                    ],

                    // Description
                    if (item['description'] != null) ...[
                      _buildDetailRow(Icons.description, 'Description',
                          item['description']),
                      const SizedBox(height: 20),
                    ],

                    // Category and Price row
                    Row(
                      children: [
                        if (item['category'] != null)
                          Expanded(
                            child: _buildCategoryChip(item['category']),
                          ),
                        if (item['category'] != null && item['price'] != null)
                          const SizedBox(width: 15),
                        if (item['price'] != null)
                          _buildPriceChip(item['price']),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isTitle = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: widget.buttonColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: widget.bgtextcolor.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: widget.bgtextcolor,
            fontSize: isTitle ? 20 : 16,
            fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.buttonColor.withValues(alpha: 0.1),
            widget.buttonColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: widget.buttonColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category, color: widget.buttonColor, size: 16),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              color: widget.buttonColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip(dynamic price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.buttonColor,
            widget.buttonColor.withValues(alpha: 0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: widget.buttonColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.currency_rupee, color: widget.buttonTextColor, size: 18),
          Text(
            price.toString(),
            style: TextStyle(
              color: widget.buttonTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> item, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        _showBottomSheet(item, index);
      },
      onPanStart: (_) => _pauseAutoScroll(), // Pause on user interaction
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 20,
          vertical: isActive ? 0 : 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isActive ? 0.25 : 0.15),
              blurRadius: isActive ? 25 : 15,
              spreadRadius: 0,
              offset: Offset(0, isActive ? 12 : 6),
            ),
            BoxShadow(
              color:
                  widget.buttonColor.withValues(alpha: isActive ? 0.15 : 0.08),
              blurRadius: isActive ? 40 : 25,
              spreadRadius: 0,
              offset: Offset(0, isActive ? 20 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            // margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.bgColor,
                  widget.bgColor.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background image with parallax effect
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()..scale(isActive ? 1.05 : 1.0),
                    child: Image.network(
                      item['image_url'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.buttonColor.withValues(alpha: 0.3),
                                widget.buttonColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: widget.buttonColor,
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.buttonColor.withValues(alpha: 0.4),
                                widget.buttonColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 72,
                                  color:
                                      widget.buttonColor.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Premium Banner',
                                  style: TextStyle(
                                    color: widget.buttonColor
                                        .withValues(alpha: 0.7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Enhanced gradient overlay
                // Positioned.fill(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: [
                //           Colors.transparent,
                //           Colors.black.withValues(alpha: 0.1),
                //           Colors.black.withValues(alpha: 0.4),
                //           Colors.black.withValues(alpha: 0.85),
                //         ],
                //         stops: const [0.0, 0.4, 0.7, 1.0],
                //       ),
                //     ),
                //   ),
                // ),

                // Page indicator
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${index + 1}/${_userBanners.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Content overlay
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userBanners.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced header section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.buttonColor.withValues(alpha: 0.15),
                      widget.buttonColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.buttonColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: widget.buttonColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.bgtextcolor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      ' ${_userBanners.length} trending banners',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.bgtextcolor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.buttonColor.withValues(alpha: 0.15),
                      widget.buttonColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '${_userBanners.length}',
                  style: TextStyle(
                    color: widget.buttonColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Auto-scroll PageView
        Container(
          margin: const EdgeInsets.only(top: 3),
          height: 270,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.userBanners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildBannerCard(_userBanners[index], index),
              );
            },
          ),
        ),

        // Enhanced page dots indicator with progress
        if (_userBanners.length > 1)
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_userBanners.length, (index) {
                    final isActive = _currentIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  widget.buttonColor,
                                  widget.buttonColor.withValues(alpha: 0.7),
                                ],
                              )
                            : null,
                        color: isActive
                            ? null
                            : widget.buttonColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color:
                                      widget.buttonColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ListViewShimmer extends StatefulWidget {
  final double cardHeight;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ListViewShimmer({
    Key? key,
    this.cardHeight = 300.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ListViewShimmer> createState() => _ListViewShimmerState();
}

class _ListViewShimmerState extends State<ListViewShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            separatorBuilder: (context, index) => const SizedBox(height: 16.0),
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                height: widget.cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.baseColor,
                      widget.highlightColor,
                      widget.baseColor,
                    ],
                    stops: [
                      _animation.value - 0.3,
                      _animation.value,
                      _animation.value + 0.3,
                    ].map((e) => e.clamp(0.0, 1.0)).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
