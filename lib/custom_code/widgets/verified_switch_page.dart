// Automatic FlutterFlow imports
import 'package:pocket_mates_app/custom_code/widgets/search_profile_detail_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/verfied_search_profile_detail_page.dart';

import '/backend/supabase/supabase.dart';
// Imports other custom widgets
// Imports custom actions
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' as material show Colors;

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
  // Color? _selectedColor;
  // String? _colorCode;
  // Color? _selectedColor1;
  // String? _colorCode1;
  // Color? _selectedColor2;
  // String? _colorCode2;
  // Color? _selectedColor3;
  // String? _colorCode3;

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  // final scaffoldKey = GlobalKey<ScaffoldState>(); // Removed material scaffold key
  final TextEditingController _shopNameController = TextEditingController();
  final _supabase = SupaFlow.client;

  bool _isLoading = false;
  int? selectedContainer;
  // String? _imageUrl;
  bool _isVerified = false;

  // Premium features variables
  int? _selectedHomeDesign;
  // bool _hasPremiumFeatures = false;

  @override
  void initState() {
    super.initState();

    _loadProfileData();
    _loadPremiumFeatures();
  }

  // New method to load premium features
  Future<void> _loadPremiumFeatures() async {
    try {
      final premiumResponse = await _supabase
          .from('premium_features')
          .select('selected_home_design')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (premiumResponse != null && mounted) {
        setState(() {
          _selectedHomeDesign = premiumResponse['selected_home_design'] ?? 1;
          // _hasPremiumFeatures = true;
        });
      } else {
        // User doesn't have premium features, use default
        setState(() {
          _selectedHomeDesign = 1; // Default design
          // _hasPremiumFeatures = false;
        });
      }
    } catch (error) {
      print('Error loading premium features: $error');
      // Use default if error occurs
      if (mounted) {
        setState(() {
          _selectedHomeDesign = 1;
          // _hasPremiumFeatures = false;
        });
      }
    }
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() => _isLoading = true);

      // Fetch profile data including verification status
      final profileResponse = await _supabase
          .from('profile')
          .select(
              'profile_image_url, shop_name, verified, user_id, name, bg_color_code, bg_text_color, button_color_code, button_text_color')
          .eq('user_id', widget.userId)
          .maybeSingle();

      print(profileResponse);

      if (profileResponse != null && mounted) {
        setState(() {
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          // _colorCode = profileResponse['bg_color_code'] ?? '';
          // _colorCode1 = profileResponse['bg_text_color'] ?? '';
          // _colorCode2 = profileResponse['button_color_code'] ?? '';
          // _colorCode3 = profileResponse['button_text_color'] ?? '';
          _isVerified = profileResponse['verified']; // Get verification status
        });
      }
    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('Error'),
            content: Text('Error loading profile: $error'),
            actions: [
              Button(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Method to get the appropriate widget based on selected home design
  Widget _getSelectedDesignWidget() {
    if (_isLoading) {
      return const Center(
        child: ProgressRing(),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Check verification status first
    if (_isVerified == true) {
      // Verified user - show verified designs
      switch (_selectedHomeDesign) {
        case 1:
        case 2:
        case 3:
        case 4:
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
      color: material.Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: _getSelectedDesignWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
