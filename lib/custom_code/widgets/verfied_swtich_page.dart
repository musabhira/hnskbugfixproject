// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/verfied_search_profile_detail_page.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';

class VerfiedSwitchPage extends StatefulWidget {
  const VerfiedSwitchPage({
    super.key,
    this.width,
    this.height,
    required this.userId,
  });

  final double? width;
  final double? height;
  final String userId;
  static String routeName = 'verifiedProfile';
  static String routePath = '/verifiedProfile';

  @override
  State<VerfiedSwitchPage> createState() => _VerfiedSwitchPageState();
}

class _VerfiedSwitchPageState extends State<VerfiedSwitchPage> {
  Color? _selectedColor;
  String? _colorCode;
  Color? _selectedColor1;
  String? _colorCode1;
  Color? _selectedColor2;
  String? _colorCode2;
  Color? _selectedColor3;
  String? _colorCode3;

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _shopNameController = TextEditingController();
  final _supabase = SupaFlow.client;

  bool _isLoading = false;
  int? selectedContainer;
  String? _imageUrl;
  bool _isVerified = false;

  // Premium features variables
  int? _selectedHomeDesign;
  bool _hasPremiumFeatures = false;

  @override
  void initState() {
    super.initState();

    _loadProfileData();
    _loadPremiumFeatures();
  }

  // Future<void> _getCurrentUser() async {
  //   final user = _supabase.auth.currentUser;
  //   if (user != null) {
  //     safeSetState(() {
  //       _currentUserId = user.id;
  //     });
  //   }
  // }

  // New method to load premium features
  Future<void> _loadPremiumFeatures() async {
    try {
      final premiumResponse = await _supabase
          .from('premium_features')
          .select('selected_home_design')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (premiumResponse != null && mounted) {
        safeSetState(() {
          _selectedHomeDesign = premiumResponse['selected_home_design'] ?? 1;
          _hasPremiumFeatures = true;
        });
      } else {
        // User doesn't have premium features, use default
        safeSetState(() {
          _selectedHomeDesign = 1; // Default design
          _hasPremiumFeatures = false;
        });
      }
    } catch (error) {
      print('Error loading premium features: $error');
      // Use default if error occurs
      if (mounted) {
        safeSetState(() {
          _selectedHomeDesign = 1;
          _hasPremiumFeatures = false;
        });
      }
    }
  }

  Future<void> _loadProfileData() async {
    try {
      safeSetState(() => _isLoading = true);

      // Fetch profile data including verification status
      final profileResponse = await _supabase
          .from('profile')
          .select(
              'profile_image_url, shop_name, verified, user_id, name, bg_color_code, bg_text_color, button_color_code, button_text_color')
          .eq('user_id', widget.userId)
          .maybeSingle();

      print(profileResponse);

      if (profileResponse != null && mounted) {
        safeSetState(() {
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _colorCode = profileResponse['bg_color_code'] ?? '';
          _colorCode1 = profileResponse['bg_text_color'] ?? '';
          _colorCode2 = profileResponse['button_color_code'] ?? '';
          _colorCode3 = profileResponse['button_text_color'] ?? '';
          _isVerified = profileResponse['verified']; // Get verification status
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
        safeSetState(() => _isLoading = false);
      }
    }
  }

  // Method to get the appropriate widget based on selected home design
  Widget _getSelectedDesignWidget() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Check verification status first
    if (_isVerified == true) {
      // Verified user - show verified designs
      switch (_selectedHomeDesign) {
        case 1:
          return VerfiedSearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );
        case 2:
          return VerfiedSearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );
        case 3:
          return VerfiedSearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );
        case 4:
          return VerfiedSearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );
        default:
          return VerfiedSearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );
      }
    } else {
      // Non-verified user - show different designs
      switch (_selectedHomeDesign) {
        case 1:
          return SearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );

        default:
          return SearchProfileDetailPage(
            width: screenWidth,
            height: screenHeight,
            userId: widget.userId,
          );
      }
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child:
                  _getSelectedDesignWidget(), // Use the selected design widget
            ),
          ),
        ],
      ),
    );
  }
}
// https://handskillapp.web.app/?userid=67f21fa3-3cc9-4bad-9554-be88b8c4b740
