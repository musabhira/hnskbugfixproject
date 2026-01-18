// Automatic FlutterFlow imports
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/report_dailoge.dart';
import 'package:pocket_mates_app/custom_code/widgets/search_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'package:cached_network_image/cached_network_image.dart';

import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' as flutter;

class SearchProfileDetailPage extends StatefulWidget {
  final double? width;
  final double? height;
  final String userId;

  const SearchProfileDetailPage({
    super.key,
    required this.userId,
    this.width,
    this.height,
  });

  @override
  _SearchProfileDetailPageState createState() =>
      _SearchProfileDetailPageState();
}

class _SearchProfileDetailPageState extends State<SearchProfileDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  final _supabase = SupaFlow.client;

  late TabController _tabController;
  int _followersCount = 0;
  int _followingCount = 0;
  ScrollController _scrollController = ScrollController();
  String _followersCountFormatted = '0';
  String _followingCountFormatted = '0';
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  String? _currentUserId;
  List<Map<String, dynamic>> userThreads = [];
  List<Map<String, dynamic>> userServices = [];
  List<Map<String, dynamic>> userGallery = [];
  bool isLoading = true;
  Map<String, dynamic>? hideData;

  bool _isBlocked = false;
  bool _isBlockedByOther = false;
  bool _checkingBlockStatus = true;
  DateTime? _blockTime;
  DateTime? _blockedByOtherTime;
  bool _showScrollToTop = false;

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
    _loadServicesData();
    _loadGalleryData();
    fetchHideStatus();
    _checkBlockStatus();
    _initScrollListener();
  }

// Add this method to your State class
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
        _followersCountFormatted = _formatCount(followersCountRaw);
        _followingCountFormatted = _formatCount(followingCountRaw);
        print('Followers count: $_followersCountFormatted');
        print('Following count: $_followingCountFormatted');
      });
    } catch (e) {
      print('Error fetching follow counts: $e');
    }
  }

  Future<void> _loadServicesData() async {
    try {
      final services = await _supabase
          .from('service')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      if (mounted) {
        safeSetState(() {
          userServices = List<Map<String, dynamic>>.from(services);
        });
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
    }
  }

  Future<void> _loadGalleryData() async {
    try {
      final gallery = await _supabase
          .from('gallery')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      if (mounted) {
        safeSetState(() {
          userGallery = List<Map<String, dynamic>>.from(gallery);
        });
      }
    } catch (e) {
      debugPrint('Error loading gallery: $e');
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

  void _fetchProfileData() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      final profileResponse = await _supabase.from('profile').select('''
          id, created_at, user_id, name, phone_no, country, bio, 
          shop_name, profile_image_url, banner_image_url, button_color_code, 
          bg_color_code, bg_text_color, state, city, button_text_color, verified,insta_id,insta_link
        ''').eq('user_id', widget.userId).limit(1);

      Map<String, dynamic>? profile =
          profileResponse.isNotEmpty ? profileResponse.first : null;

      safeSetState(() {
        _profileData = profile;
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
      });
      print('Error fetching profile data: $e');
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        : Colors.white;
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
          '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
      String message = 'Check out this profile: $profileUrl';
      String whatsappUrl =
          'https://wa.me/?text=${Uri.encodeComponent(message)}';
      _launchUrl(whatsappUrl);
    } catch (e) {
      String profileUrl =
          '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
      String message = 'Check out this profile: $profileUrl';
      await launchUrl(
        Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}"),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _shareToInstagram() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
    // Instagram doesn't support direct text sharing, so copy to clipboard
    flutter.Clipboard.setData(flutter.ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied! Paste in Instagram')),
    );
  }

  void _copyLink() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
    flutter.Clipboard.setData(flutter.ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareToAnywhere() {
    String profileUrl =
        '${WhatsAppShareHelper.baseAppUrl}/searchprofileuser?userid=${widget.userId}';
    Share.share('Check out this profile: $profileUrl');
  }

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
          ? CircularShimmer(
              buttonColor: buttonColor,
              bgColor: bgColor,
              size: 100,
            )
          : _profileData == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'the User Not Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : _checkingBlockStatus
                  ? const Center(child: CircularProgressIndicator())
                  : _isBlockedByOther
                      ? _buildBlockedByOtherView()
                      : _isBlocked
                          ? _buildBlockedView()
                          : Stack(
                              children: [
                                // Banner covering full screen with gradient overlay
                                // Container(
                                //   height:
                                //       MediaQuery.of(context).size.height * 0.4,
                                //   width: double.infinity,
                                //   decoration: BoxDecoration(
                                //     image: _profileData!['banner_image_url'] !=
                                //             null
                                //         ? DecorationImage(
                                //             image: CachedNetworkImageProvider(
                                //               _profileData!['banner_image_url'],
                                //             ),
                                //             fit: BoxFit.cover,
                                //           )
                                //         : null,
                                //     color: _profileData!['banner_image_url'] ==
                                //             null
                                //         ? buttonColor
                                //         : null,
                                //   ),
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       gradient: LinearGradient(
                                //         begin: Alignment.topCenter,
                                //         end: Alignment.bottomCenter,
                                //         colors: [
                                //           Colors.transparent,
                                //           bgColor.withOpacity(0.8),
                                //           bgColor,
                                //         ],
                                //         stops: const [0.1, 0.7, 0.9],
                                //       ),
                                //     ),
                                //   ),
                                // ),
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
                                        ? Colors
                                            .black // Changed to Colors.black for visibility
                                        : null,
                                  ),
                                  child: _profileData!['banner_image_url'] !=
                                          null
                                      ? Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                bgColor.withOpacity(0.8),
                                                bgColor,
                                              ],
                                              stops: const [0.1, 0.7, 0.9],
                                            ),
                                          ),
                                        )
                                      : null, // No gradient overlay when there's no banner image
                                ),
                                // Main content
                                CustomScrollView(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    // Top spacing to push content below banner
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25),
                                    ),

                                    // Profile card with info
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                600, // Set your desired max width
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: bgColor.withOpacity(0.95),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: buttonColor
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Avatar and Name section
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 10, 10),
                                                  child: Row(
                                                    children: [
                                                      // Profile image
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(11),
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
                                                                  .circular(11),
                                                          child: Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: bgColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: _profileData![
                                                                        'profile_image_url'] !=
                                                                    null
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10), // Half of width/height for perfect circle
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          _profileData![
                                                                              'profile_image_url'],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 80,
                                                                      height:
                                                                          80,
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    width: 80,
                                                                    height: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          600], // Dark grey color
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .person,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.7),
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      // Name and shop info
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 80,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
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
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          bgTextColor,
                                                                    ),
                                                                  ),
                                                                  buildVerifiedTick(
                                                                      _profileData?[
                                                                              'verified'] ??
                                                                          false,
                                                                      buttonColor),
                                                                ],
                                                              ),
                                                              if (_profileData![
                                                                      'shop_name'] !=
                                                                  null)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
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
                                                                          FontWeight
                                                                              .w500,
                                                                      color: bgTextColor
                                                                          .withOpacity(
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
                                                                  padding:
                                                                      const EdgeInsets
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
                                                                        color: bgTextColor
                                                                            .withOpacity(0.6),
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
                                                                          ].where((item) => item != null).join(
                                                                              ', '),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                bgTextColor.withOpacity(0.6),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize:
                                                                                11,
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
                                                    ],
                                                  ),
                                                ),

                                                // Stats row
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: buttonColor
                                                        .withOpacity(0.08),
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
                                                          _followersCountFormatted
                                                              .toString(),
                                                          'Followers',
                                                          bgTextColor),
                                                      _buildStatWidget(
                                                          context,
                                                          _followingCountFormatted
                                                              .toString(),
                                                          'Friends',
                                                          bgTextColor),
                                                      _buildStatWidget(
                                                          context,
                                                          _formatCount(
                                                              userThreads
                                                                  .length),
                                                          'Threads',
                                                          bgTextColor),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 12),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Bio Card
                                    if (_profileData!['bio'] != null)
                                      SliverToBoxAdapter(
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth:
                                                  600, // Set your desired max width
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  11, 12, 11, 0),
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color:
                                                    bgColor.withOpacity(0.95),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 12,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: buttonColor
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.info_outline,
                                                        size: 16,
                                                        color: buttonColor,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'About',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: buttonColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _profileData!['bio'],
                                                    style: TextStyle(
                                                      color: bgTextColor
                                                          .withOpacity(0.9),
                                                      fontSize: 13,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Action Buttons
                                    SliverToBoxAdapter(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                600, // Set your desired max width
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(11),
                                            padding: const EdgeInsets.all(11),
                                            decoration: BoxDecoration(
                                              color: bgColor.withOpacity(0.95),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 12,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: buttonColor
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // Message Button
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed:
                                                        _showMessageOptions,
                                                    icon: const Icon(
                                                        Icons.message,
                                                        size: 18),
                                                    label:
                                                        const Text('Message'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          buttonColor,
                                                      foregroundColor:
                                                          buttonTextColor,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 17),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                // Follow Button
                                                Expanded(
                                                  child: FollowButton(
                                                    initialIsFollowing:
                                                        _isFollowing,
                                                    userId: widget.userId,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Tab Bar
                                    SliverPersistentHeader(
                                      pinned: true,
                                      delegate: SliverAppBarDelegate(
                                        TabBar(
                                          controller: _tabController,
                                          labelColor: buttonColor,
                                          unselectedLabelColor:
                                              bgTextColor.withOpacity(0.7),
                                          indicatorColor: buttonColor,
                                          indicatorWeight: 3,
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          tabs: const [
                                            Tab(text: 'Threads'),
                                            Tab(text: 'Services'),
                                            Tab(text: 'Gallery'),
                                          ],
                                        ),
                                        color: bgColor,
                                      ),
                                    ),

                                    // Tab Content
                                    SliverFillRemaining(
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          _buildThreadsList(
                                              bgColor,
                                              bgTextColor,
                                              buttonColor,
                                              buttonTextColor),
                                          _buildServicesList(
                                              bgColor,
                                              bgTextColor,
                                              buttonColor,
                                              buttonTextColor),
                                          _buildGalleryGrid(
                                              bgColor,
                                              bgTextColor,
                                              buttonColor,
                                              buttonTextColor),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  buttonColor.withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: buttonColor
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.keyboard_arrow_up,
                                                  color: buttonTextColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Top',
                                                  style: TextStyle(
                                                    color: buttonTextColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
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
      floatingActionButton:
          _checkingBlockStatus || _isBlockedByOther || _isBlocked
              ? null // Hide FAB when blocked
              : FloatingActionButton.extended(
                  onPressed: () => _showAIAssistant(context),
                  icon: const Icon(Icons.smart_toy_rounded),
                  label: const Text('Ask AI'),
                  backgroundColor: _getButtonColor(),
                  foregroundColor: _getButtonTextColor(),
                ),
    );
  }

  Widget _buildThreadsList(
    Color bgColor,
    Color bgTextColor,
    Color buttonColor,
    Color buttonTextColor,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userThreads.isEmpty) {
      return Center(
        child: Text(
          'No threads yet',
          style: TextStyle(color: bgTextColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userThreads.length,
      itemBuilder: (context, index) {
        final thread = userThreads[index];
        final int likeCount = (thread['like_count'] as int?) ?? 0;
        final int fakeLikes = (thread['fake_likes'] as int?) ?? 0;
        final int totalLikes = likeCount + fakeLikes;
        final String formattedLikes = _formatCount(totalLikes);

        return Card(
          color: buttonColor.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: buttonColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeago.format(DateTime.parse(thread['created_at'])),
                  style: TextStyle(
                    color: bgTextColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  thread['content'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: bgTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThreadCommentsPage(
                              threadContent: thread['content'],
                              threadId: thread['id'],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border,
                              size: 18, color: buttonColor),
                          const SizedBox(width: 4),
                          Text(formattedLikes,
                              style: TextStyle(color: bgTextColor)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThreadCommentsPage(
                              threadContent: thread['content'],
                              threadId: thread['id'],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 18, color: buttonColor),
                          const SizedBox(width: 4),
                          Text('${thread['comment_count'] ?? 0}',
                              style: TextStyle(color: bgTextColor)),
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

  Widget _buildServicesList(
      Color bgcolor, Color textcolor, Color btncolor, Color btntextcolor) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (userServices.isEmpty) {
      return Center(
          child: Text('No services offered',
              style: TextStyle(color: textcolor.withOpacity(0.5))));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: userServices.length,
      itemBuilder: (context, index) {
        final service = userServices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: textcolor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textcolor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service['title'] ?? 'Untitled Service',
                      style: TextStyle(
                        color: textcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (service['price'] != null)
                    Text(
                      '₹${service['price']}',
                      style: TextStyle(
                        color: btncolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
              if (service['category'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: btncolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service['category'],
                      style: TextStyle(
                        color: btncolor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                service['description'] ?? '',
                style:
                    TextStyle(color: textcolor.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid(
      Color bgcolor, Color textcolor, Color btncolor, Color btntextcolor) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (userGallery.isEmpty) {
      return Center(
          child: Text('No gallery items',
              style: TextStyle(color: textcolor.withOpacity(0.5))));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: userGallery.length,
      itemBuilder: (context, index) {
        final item = userGallery[index];
        return Container(
          decoration: BoxDecoration(
            color: textcolor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textcolor.withOpacity(0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: item['image_url'] != null
                      ? Image.network(
                          item['image_url'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 40),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Untitled',
                        style: TextStyle(
                            color: textcolor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item['price'] != null)
                        Text(
                          '₹${item['price']}',
                          style: TextStyle(
                              color: btncolor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
  List<Map<String, dynamic>> userThreads = [];
  String _followersCount = '0';
  String _followingCount = '0';

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // Suggested questions
  final List<String> _suggestedQuestions = [
    "Who is this person?",
    "Tell me about their profile",
    "Tell me about their threads",
    "How can I contact them?",
    "Where are they located?",
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
            "Hello! I'm $aiName. I can help you with information about this profile, their threads, and more. What would you like to know?",
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

      // Fetch follow counts
      await _fetchFollowCounts();
    } catch (e) {
      print('Error fetching data: $e');
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
        _followersCount = _formatCount(followersCountRaw);
        _followingCount = _formatCount(followingCountRaw);
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

        return AIResponse(text: response);
      }
      return AIResponse(
          text:
              "I'm still loading the profile information. Please wait a moment and try again.");
    }

    // Profile information queries
    if (message.contains('about') ||
        message.contains('info') ||
        message.contains('profile')) {
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
                "👤 Following: $_followingCount\n\n"
                "Bio: ${_profileData!['bio'] ?? 'No bio available'}");
      }
    }

    // Threads queries
    if (message.contains('thread') || message.contains('post')) {
      if (userThreads.isNotEmpty) {
        return AIResponse(
          text:
              "This user has ${userThreads.length} threads. You can view them on the profile page.",
        );
      }
      return AIResponse(text: "This user hasn't posted any threads yet.");
    }

    // Default response
    return AIResponse(
        text:
            "I'm ${_getAIName()} and I can help you with profile details, contact info, and more. Just ask!");
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
                  color: Colors.black.withOpacity(0.1),
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
                            color: _getButtonTextColor().withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header content
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getButtonTextColor().withOpacity(0.2),
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
                                          .withOpacity(0.8),
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
                      color: _getButtonColor().withOpacity(0.05),
                      border: Border(
                        top: BorderSide(
                          color: _getButtonColor().withOpacity(0.1),
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
                                  color: _getButtonColor().withOpacity(0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Ask me anything...',
                                  hintStyle: TextStyle(
                                    color: _getTextColor().withOpacity(0.5),
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
                                    color: _getButtonColor().withOpacity(0.3),
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
              color: _getTextColor().withOpacity(0.7),
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
                    color: _getButtonColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getButtonColor().withOpacity(0.2),
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
                    color: _getButtonColor().withOpacity(0.1),
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
                        : _getButtonColor().withOpacity(0.1),
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
                                  .withOpacity(0.6),
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
                  backgroundColor: _getButtonColor().withOpacity(0.1),
                  child: Icon(
                    Icons.person_rounded,
                    color: _getButtonColor(),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ],
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
              color: _getButtonColor().withOpacity(0.1),
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
              color: _getButtonColor().withOpacity(0.1),
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
                    color: _getTextColor().withOpacity(0.7),
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

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIResponse {
  final String text;

  AIResponse({
    required this.text,
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
        baseColor: bgColor.withOpacity(0.3),
        highlightColor: buttonColor.withOpacity(0.7),
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

class ThreadCommentsPage extends StatefulWidget {
  final String threadId;
  final String threadContent;

  const ThreadCommentsPage({
    super.key,
    required this.threadId,
    required this.threadContent,
  });

  @override
  State<ThreadCommentsPage> createState() => _ThreadCommentsPageState();
}

class _ThreadCommentsPageState extends State<ThreadCommentsPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _threadScrollController =
      ScrollController(); // New scroll controller for thread content
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  bool isPosting = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fetchComments();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _threadScrollController.dispose(); // Dispose the new scroll controller
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    safeSetState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('thread_comments_view')
          .select()
          .eq('thread_id', widget.threadId)
          .order('created_at');

      if (mounted) {
        safeSetState(() {
          comments = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Error fetching comments: ${e.toString()}');
      }
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    safeSetState(() {
      isPosting = true;
    });

    final userId = supabase.auth.currentUser?.id ?? 'sample-user-id';

    try {
      await supabase.from('thread_comments').insert({
        'thread_id': widget.threadId,
        'user_id': userId,
        'content': _commentController.text.trim(),
      });

      _commentController.clear();
      await _fetchComments();

      // Scroll to bottom to show new comment
      if (_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error posting comment: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          isPosting = false;
        });
      }
    }
  }

  Future<void> _deleteComment(String commentId, int index) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Delete Comment',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this comment?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await supabase.from('thread_comments').delete().eq('id', commentId);

        // Remove comment with animation
        safeSetState(() {
          comments.removeAt(index);
        });

        _showSuccessSnackBar('Comment deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting comment: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, int index) {
    final currentUserId = supabase.auth.currentUser?.id;
    final isOwner = comment['user_id'] == currentUserId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'avatar_${comment['user_id']}_$index',
          child: CircleAvatar(
            radius: 24,
            backgroundImage: comment['profile_image_url'] != null
                ? NetworkImage(comment['profile_image_url'])
                : null,
            backgroundColor: Colors.yellow[700],
            child: comment['profile_image_url'] == null
                ? Text(
                    comment['name']?[0]?.toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
        ),
        title: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment['name'] ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                ReportButton(
                  contentType: 'comment',
                  contentId: '${comment['id']}',
                  contentTitle: comment['name'] ?? 'Comment',
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
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      comment['content'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeago.format(DateTime.parse(comment['created_at'])),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteComment(comment['id'], index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red[700]?.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellow),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.yellow.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Original thread with fixed height and scrollable content
          Container(
            width: double.infinity,
            height: 200, // Fixed height for the container
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.yellow.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        color: Colors.yellow[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Original Thread',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content section
                Expanded(
                  child: Scrollbar(
                    controller: _threadScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _threadScrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        widget.threadContent,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                      strokeWidth: 3,
                    ),
                  )
                : comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return _buildCommentItem(comments[index], index);
                          },
                        ),
                      ),
          ),

          // Enhanced comment input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(
                  color: Colors.yellow.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Add a thoughtful comment...',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Material(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: isPosting ? null : _postComment,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: isPosting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.black,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsAppShareHelper {
  // Static base URL for your application
  static const String baseAppUrl = 'https://handskillapp.web.app';

  /// Share to WhatsApp with all item details (for general sharing)
  static Future<void> shareToWhatsApp({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) async {
    try {
      String message = _buildFullMessage(item);
      String whatsappUrl = _buildWhatsAppUrl(message: message);

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      _showError(context, 'Error sharing to WhatsApp: $e');
    }
  }

  /// Share to specific WhatsApp number (for direct messaging)
  static Future<void> shareToSpecificWhatsAppNumber({
    required BuildContext context,
    required Map<String, dynamic> item,
    required String phoneNumber,
    bool includeFullDetails = true,
  }) async {
    try {
      String message = includeFullDetails
          ? _buildFullMessage(item)
          : _buildSimpleMessage(item);

      // Format phone number
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (formattedNumber.startsWith('0')) {
        formattedNumber = formattedNumber.substring(1);
      }

      String whatsappUrl = _buildWhatsAppUrl(
        message: message,
        phoneNumber: formattedNumber,
      );

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      _showError(context, 'Error sharing to WhatsApp: $e');
    }
  }

  /// Share only link without item details
  static Future<void> shareOnlyLink({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) async {
    try {
      String itemLink = _generateItemLink(item);
      String message = 'Check this out: $itemLink';
      String whatsappUrl = _buildWhatsAppUrl(message: message);

      await _launchWhatsApp(context, whatsappUrl);
    } catch (e) {
      _showError(context, 'Error sharing link to WhatsApp: $e');
    }
  }

  static Future<void> sendWhatsAppMessageSimple({
    required BuildContext context,
    required String phoneNumber,
    required String message,
  }) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '$formattedNumber'; // Add your country code
    }

    String encodedMessage = Uri.encodeComponent(message);

    // Try multiple URL formats
    List<String> urls = [
      "https://wa.me/$formattedNumber?text=$encodedMessage",
      "whatsapp://send?phone=$formattedNumber&text=$encodedMessage",
      "https://api.whatsapp.com/send?phone=$formattedNumber&text=$encodedMessage",
    ];

    bool launched = false;
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched) {
      _showError(context, 'Error launching WhatsApp');
    }
  }

  /// Build full message with all item details
  static String _buildFullMessage(Map<String, dynamic> item) {
    String message = '';

    if (item['name'] != null && item['name'].toString().isNotEmpty) {
      message += 'Artist: ${item['name']}\n';
    }

    if (item['shop_name'] != null && item['shop_name'].toString().isNotEmpty) {
      message += 'Shop: ${item['shop_name']}\n';
    }

    if (item['phone_no'] != null && item['phone_no'].toString().isNotEmpty) {
      message += 'Phone: ${item['phone_no']}\n';
    }

    if (item['gallery_description'] != null &&
        item['gallery_description'].toString().isNotEmpty) {
      message += 'Description: ${item['gallery_description']}\n';
    }

    if (item['gallery_category'] != null &&
        item['gallery_category'].toString().isNotEmpty) {
      message += 'Category: ${item['gallery_category']}\n';
    }

    String itemLink = _generateItemLink(item);
    message += '\n🔗 Check it out here: $itemLink';

    return message;
  }

  /// Build simple message for direct messaging
  static String _buildSimpleMessage(Map<String, dynamic> item) {
    String message = 'Hi! ';

    if (item['name'] != null && item['name'].toString().isNotEmpty) {
      message += 'I\'m interested in your work (${item['name']}). ';
    }

    String itemLink = _generateItemLink(item);
    message += '\n\n🔗 Link: $itemLink';

    return message;
  }

  /// Generate item link based on item data
  static String _generateItemLink(Map<String, dynamic> item) {
    // You can customize this based on your app's URL structure
    String itemId = item['id']?.toString() ??
        item['gallery_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return '$baseAppUrl/item/$itemId';
  }

  /// Build WhatsApp URL based on platform
  static String _buildWhatsAppUrl({
    required String message,
    String? phoneNumber,
  }) {
    final encodedMessage = Uri.encodeComponent(message);

    if (kIsWeb) {
      // Web platform
      if (phoneNumber != null) {
        return 'https://wa.me/$phoneNumber?text=$encodedMessage';
      } else {
        return 'https://wa.me/?text=$encodedMessage';
      }
    } else if (Platform.isIOS) {
      // iOS platform
      if (phoneNumber != null) {
        return 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
      } else {
        return 'whatsapp://send?text=$encodedMessage';
      }
    } else {
      // Android platform
      if (phoneNumber != null) {
        return 'https://wa.me/$phoneNumber?text=$encodedMessage';
      } else {
        return 'https://wa.me/?text=$encodedMessage';
      }
    }
  }

  /// Launch WhatsApp with error handling
  static Future<void> _launchWhatsApp(
      BuildContext context, String whatsappUrl) async {
    try {
      if (kIsWeb) {
        // Web platform - simple launch
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else {
          _showError(context, 'Could not open WhatsApp Web');
        }
      } else {
        // Mobile platforms - try multiple methods
        await _launchWhatsAppMobile(context, whatsappUrl);
      }
    } catch (e) {
      _showError(context, 'Could not launch WhatsApp: $e');
    }
  }

  static Future<void> _launchWhatsAppMobile(
      BuildContext context, String whatsappUrl) async {
    // Extract phone number and message from the original URL for fallbacks
    String phoneNumber = '';
    String message = '';

    try {
      Uri uri = Uri.parse(whatsappUrl);
      phoneNumber = uri.path.replaceAll('/', '');
      message = uri.queryParameters['text'] ?? '';
    } catch (e) {
      // Continue with original URL if parsing fails
    }

    // Method 1: Try the original URL first
    if (await _tryLaunchUrl(whatsappUrl)) {
      return;
    }

    // Method 2: Try different URL formats based on platform
    List<String> fallbackUrls = [];

    if (Platform.isIOS) {
      // iOS fallbacks
      fallbackUrls = [
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      ];
    } else if (Platform.isAndroid) {
      // Android fallbacks
      fallbackUrls = [
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      ];
    }

    // Try each fallback URL
    for (String url in fallbackUrls) {
      if (await _tryLaunchUrl(url)) {
        return;
      }
    }

    // If all methods fail, show installation dialog
    _showWhatsAppNotInstalledDialog(context);
  }

  static Future<bool> _tryLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // Try to launch without checking canLaunchUrl first
      // because canLaunchUrl sometimes returns false even when the app exists
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      // If direct launch fails, try with canLaunchUrl check
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e2) {
        // Silently continue to next method
      }
    }
    return false;
  }

  static void _showWhatsAppNotInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WhatsApp Not Available'),
          content: Text(Platform.isIOS
              ? 'WhatsApp is not installed. Would you like to install it from the App Store?'
              : 'WhatsApp is not installed. Would you like to install it from the Play Store?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _installWhatsApp();
              },
              child: const Text('Install'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _installWhatsApp() async {
    String storeUrl;

    if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/app/whatsapp-messenger/id310633997';
    } else if (Platform.isAndroid) {
      storeUrl = 'https://play.google.com/store/apps/details?id=com.whatsapp';
    } else {
      storeUrl = 'https://www.whatsapp.com/download';
    }

    await _tryLaunchUrl(storeUrl);
  }

  /// Show error message to user
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
