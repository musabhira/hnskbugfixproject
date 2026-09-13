import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

import '/backend/supabase/supabase.dart';
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
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  final TextEditingController _shopNameController = TextEditingController();
  final _supabase = SupaFlow.client;

  bool _isLoading = false;
  int? selectedContainer;
  bool _isVerified = false;

  // Premium features variables
  int? _selectedHomeDesign;

  bool get _isRobot =>
      PocketRobotService.isRobotId(widget.userId) ||
      !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.userId);

  @override
  void initState() {
    super.initState();

    _loadProfileData();
    _loadPremiumFeatures();
  }

  // New method to load premium features
  Future<void> _loadPremiumFeatures() async {
    if (_isRobot) {
      if (mounted) {
        setState(() {
          _selectedHomeDesign = 1;
        });
      }
      return;
    }

    try {
      final premiumResponse = await _supabase
          .from('premium_features')
          .select('selected_home_design')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (premiumResponse != null && mounted) {
        setState(() {
          _selectedHomeDesign = premiumResponse['selected_home_design'] ?? 1;
        });
      } else {
        setState(() {
          _selectedHomeDesign = 1; // Default design
        });
      }
    } catch (error) {
      debugPrint('Error loading premium features: $error');
      if (mounted) {
        setState(() {
          _selectedHomeDesign = 1;
        });
      }
    }
  }

  Future<void> _loadProfileData() async {
    if (_isRobot) {
      final robot = PocketRobotService.getRobotById(widget.userId) ??
          PocketRobotService.getRobotByLevel(1);
      if (mounted) {
        setState(() {
          _shopNameController.text = robot.archetype.label;
          _isVerified = true;
          _selectedHomeDesign = 1;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Fetch profile data including verification status
      final profileResponse = await _supabase
          .from('profile')
          .select(
              'profile_image_url, shop_name, verified, user_id, name, bg_color_code, bg_text_color, button_color_code, button_text_color')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (profileResponse != null && mounted) {
        setState(() {
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _isVerified = profileResponse['verified'] ?? false;
        });
      }
    } catch (error) {
      debugPrint('Error loading profile: $error');
      if (mounted) {
        setState(() {
          _isVerified = false;
          _selectedHomeDesign = 1;
        });
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
        child: CircularProgressIndicator(),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    if (_isRobot) {
      final robot = PocketRobotService.getRobotById(widget.userId) ??
          PocketRobotService.getRobotByLevel(1);
      final dynamicLevel = PocketRobotService.getDynamicLevel(robot);
      return MainProfileWidget(
        width: screenWidth,
        height: screenHeight,
        userId: robot.id,
        preloadedProfile: {
          'user_id': robot.id,
          'first_name': robot.name,
          'name': robot.name,
          'shop_name': robot.archetype.label,
          'bio': robot.bio,
          'profile_image_url': robot.avatarUrl,
          'learning_day': dynamicLevel,
          'streak': dynamicLevel,
          'rank': robot.cefrRank,
          'palette_id': robot.housePalette,
          'is_pocket_robo': true,
          'verified': true,
          'bg_color_code': '#0F111A',
          'bg_text_color': '#FFFFFF',
          'button_color_code': '#0095F6',
          'button_text_color': '#FFFFFF',
        },
      );
    }

    // Check verification status first
    if (_isVerified == true) {
      // Verified user - show verified designs
      switch (_selectedHomeDesign) {
        case 1:
        case 2:
        case 3:
        case 4:
        default:
          return MainProfileWidget(
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
          return MainProfileWidget(
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
