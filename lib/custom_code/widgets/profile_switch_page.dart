import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';

class ProfileSwitchPage extends StatefulWidget {
  final double width;
  final double height;
  final Map<String, dynamic>? preloadedProfile;
  final String? followersCount;
  final String? followingCount;
  final List<Map<String, dynamic>>? userThreads;

  const ProfileSwitchPage({
    super.key,
    required this.width,
    required this.height,
    this.preloadedProfile,
    this.followersCount,
    this.followingCount,
    this.userThreads,
  });

  @override
  State<ProfileSwitchPage> createState() => _ProfileSwitchPageState();
}

class _ProfileSwitchPageState extends State<ProfileSwitchPage> {
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
  String? _currentUserId;
  bool _isLoading = false;
  int? selectedContainer;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    if (widget.preloadedProfile != null) {
      _applyPreloadedData();
    } else {
      _loadProfileData();
    }
  }

  void _applyPreloadedData() {
    final profile = widget.preloadedProfile!;
    _shopNameController.text = profile['shop_name'] ?? '';
    _colorCode = profile['bg_color_code'] ?? '';
    _colorCode1 = profile['bg_text_color'] ?? '';
    _colorCode2 = profile['button_color_code'] ?? '';
    _colorCode3 = profile['button_text_color'] ?? '';
  }

  Future<void> _getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      safeSetState(() {
        _currentUserId = user.id;
      });
    }
  }

  Future<void> _loadProfileData() async {
    try {
      safeSetState(() => _isLoading = true);

      if (_currentUserId == null) return;

      // Fetch profile data
      final profileResponse = await _supabase
          .from('profile')
          .select()
          .eq('user_id', _currentUserId!)
          .maybeSingle();
      print(profileResponse);
      if (profileResponse != null && mounted) {
        safeSetState(() {
          _shopNameController.text = profileResponse['shop_name'] ?? '';
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

  Color _convertStringToColor(String colorCode) {
    if (colorCode.isEmpty) return Colors.transparent;
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.transparent;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgcolorcode = _convertStringToColor(_colorCode ?? '#000000');
    final Color bgtextcolor = _convertStringToColor(_colorCode1 ?? '#FFFFFF');
    final Color buttoncolorcode =
        _convertStringToColor(_colorCode2 ?? '#FFFF00');
    final Color buttontextcolor =
        _convertStringToColor(_colorCode3 ?? '#000000');

    return Scaffold(
      backgroundColor: bgcolorcode ?? Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: bgcolorcode ?? const Color.fromARGB(255, 30, 44, 50),
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: bgtextcolor,
            size: 24.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: InkWell(
          onTap: () {
            // AutoLoginBottomSheet.show(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _shopNameController.text.toString(),
                style: GoogleFonts.interTight(
                  color: bgtextcolor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: bgtextcolor,
                size: 24.0,
              ),
            ],
          ),
        ),
        centerTitle: true,

        /// 👇 Added home icon here
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.web,
                color: bgtextcolor,
                size: 26.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerfiedSwitchPage(
                      userId: _currentUserId!,
                    ),
                  ),
                );
              },
              tooltip: 'Home',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  3, // Adjust to fit within screen
              width: MediaQuery.of(context).size.width,
              child: MainProfileWidget(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                preloadedProfile: widget.preloadedProfile,
                followersCount: widget.followersCount,
                followingCount: widget.followingCount,
                userThreads: widget.userThreads,
              ),
            ),
          ),

          // if (selectedContainer == 2)
          //   TwoProfileWidget(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //   ),
          // if (selectedContainer == 3)
          //   ThreeProfileWidget(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //   ),
          // if (selectedContainer == 4)
          //   FiveProfileWidget(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //   ),
          // if (selectedContainer == null)
          //   MainProfileWidget(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //   ),
        ],
      ),
    );
  }

  Widget _buildContainer(Color color, String text) {
    return Expanded(
      child: Container(
        color: color,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
