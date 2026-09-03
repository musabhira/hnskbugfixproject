import 'package:pocket_mates_app/custom_code/widgets/color_picker_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_phone_text_field.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_text_field.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:country_state_city_picker/country_state_city_picker.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_studio_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_60day_dashboard.dart';

// Begin custom action code

class _CompressParams {
  final Uint8List imageBytes;
  final int quality;

  _CompressParams(this.imageBytes, this.quality);
}

class ProfileCustomWidget extends StatefulWidget {
  final double width;
  final double height;

  const ProfileCustomWidget({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<ProfileCustomWidget> createState() => _ProfileCustomWidgetState();
}

class _ProfileCustomWidgetState extends State<ProfileCustomWidget> {
  String _currentPlan = 'free';
  Color? _selectedColor = Colors.black;
  String? _colorCode = '#000000';
  Color? _selectedColor1 = Colors.white;
  String? _colorCode1 = '#FFFFFF';
  Color? _selectedColor2 = const Color(0xFFFFD700); // Luxury Gold
  String? _colorCode2 = '#FFD700';
  Color? _selectedColor3 = Colors.black;
  String? _colorCode3 = '#000000';

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  Uint8List? _selectedImageBytes;
  
  String _businessType = 'product';
  bool _wantsPaymentIntegration = false;
  bool _isPrivate = false;
  final _supabase = SupaFlow.client;
  String? _currentUserId;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  Uint8List? _selectedImageBytesBanner;
  String? _imageUrlBanner;
  Map<String, dynamic>? hideData;
  bool isLoading = true;
  bool _isCompressingProfile = false;
  bool _isCompressingBanner = false;
  String? _selectedTemplateId = 'default';
  String? _loadedProfileId;
  VectorAvatarConfig _avatarConfig = const VectorAvatarConfig();

  final List<Map<String, String>> _avatarBannerPresets = [
    {
      'name': 'Pocket Gold Glow ✨',
      'url': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
      'aura': 'pocket_gold',
    },
    {
      'name': 'Cyberpunk Matrix ⚡',
      'url': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80',
      'aura': 'matrix_green',
    },
    {
      'name': 'Comic Action Boom 💥',
      'url': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1200&q=80',
      'aura': 'comic_boom',
    },
    {
      'name': 'Neon Synthwave 🌌',
      'url': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=1200&q=80',
      'aura': 'cyber_synthwave',
    },
    {
      'name': 'Electric Aqua Grid 🌊',
      'url': 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=1200&q=80',
      'aura': 'electric_aqua',
    },
    {
      'name': 'Sakura Blossom 🌸',
      'url': 'https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=1200&q=80',
      'aura': 'sakura_blossom',
    },
    {
      'name': 'Royal Monarch Gold 👑',
      'url': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=1200&q=80',
      'aura': 'royal_gold',
    },
    {
      'name': '8-Bit Pixel Arcade 👾',
      'url': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
      'aura': 'pixel_arcade',
    },
    {
      'name': 'Obsidian Stealth 🖤',
      'url': 'https://images.unsplash.com/photo-1618005198919-d3d4b5a92ead?auto=format&fit=crop&w=1200&q=80',
      'aura': 'obsidian_stealth',
    },
    {
      'name': 'Sunset Horizon Glow 🌅',
      'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
      'aura': 'sunset_glow',
    },
  ];

  void _applyAvatarTheme(VectorAvatarConfig cfg) {
    final auraId = cfg.auraStyle;
    Map<String, String> themeMap;
    switch (auraId) {
      case 'matrix_green':
        themeMap = {
          'bgColor': '#050D0A',
          'textColor': '#E8F5E9',
          'btnColor': '#00FF66',
          'btnTextColor': '#000000',
        };
        break;
      case 'comic_boom':
        themeMap = {
          'bgColor': '#0E0D14',
          'textColor': '#FFF9E6',
          'btnColor': '#FF8906',
          'btnTextColor': '#000000',
        };
        break;
      case 'cyber_synthwave':
        themeMap = {
          'bgColor': '#0D0818',
          'textColor': '#F3E5F5',
          'btnColor': '#E056FD',
          'btnTextColor': '#FFFFFF',
        };
        break;
      case 'electric_aqua':
        themeMap = {
          'bgColor': '#041018',
          'textColor': '#E0F7FA',
          'btnColor': '#00E5FF',
          'btnTextColor': '#000000',
        };
        break;
      case 'sakura_blossom':
        themeMap = {
          'bgColor': '#170A17',
          'textColor': '#FCE4EC',
          'btnColor': '#FF69B4',
          'btnTextColor': '#000000',
        };
        break;
      case 'royal_gold':
        themeMap = {
          'bgColor': '#0E0E12',
          'textColor': '#FFFDF0',
          'btnColor': '#FFD700',
          'btnTextColor': '#000000',
        };
        break;
      case 'pixel_arcade':
        themeMap = {
          'bgColor': '#100020',
          'textColor': '#EDE7F6',
          'btnColor': '#FF007F',
          'btnTextColor': '#FFFFFF',
        };
        break;
      case 'obsidian_stealth':
        themeMap = {
          'bgColor': '#121212',
          'textColor': '#E0E0E0',
          'btnColor': '#2C3E50',
          'btnTextColor': '#FFFFFF',
        };
        break;
      case 'sunset_glow':
        themeMap = {
          'bgColor': '#170914',
          'textColor': '#FFF3E0',
          'btnColor': '#FF5722',
          'btnTextColor': '#FFFFFF',
        };
        break;
      default:
        themeMap = {
          'bgColor': '#0D0E15',
          'textColor': '#FFFFFF',
          'btnColor': '#FFFC00',
          'btnTextColor': '#000000',
        };
    }

    safeSetState(() {
      _colorCode = themeMap['bgColor'];
      _colorCode1 = themeMap['textColor'];
      _colorCode2 = themeMap['btnColor'];
      _colorCode3 = themeMap['btnTextColor'];
      _selectedColor = _convertStringToColor(_colorCode!);
      _selectedColor1 = _convertStringToColor(_colorCode1!);
      _selectedColor2 = _convertStringToColor(_colorCode2!);
      _selectedColor3 = _convertStringToColor(_colorCode3!);
    });

    _scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('✨ Applied theme colors matching your Avatar aura!'),
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController instaIdController = TextEditingController();
  final TextEditingController instaLinkController = TextEditingController();

  // Verification State
  bool _isShopNameVerified = false;
  String? _shopNameMessage;
  bool _checkingShopName = false;
  Color _shopNameMessageColor = const Color(0xFF95A1AC); // Initial grey fallback

  // Getters to access the values
  int? get day =>
      _dayController.text.isNotEmpty ? int.tryParse(_dayController.text) : null;
  int? get month => _monthController.text.isNotEmpty
      ? int.tryParse(_monthController.text)
      : null;
  int? get year => _yearController.text.isNotEmpty
      ? int.tryParse(_yearController.text)
      : null;

  final List<Map<String, String>> _colorPresets = [
    {
      'name': 'Luxury Gold',
      'bgColor': '#000000',
      'textColor': '#FFFFFF',
      'btnColor': '#FFD700',
      'btnTextColor': '#000000',
    },
    {
      'name': 'Royal Navy',
      'bgColor': '#0D1B2A',
      'textColor': '#E0E1DD',
      'btnColor': '#415A77',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Rose Gold',
      'bgColor': '#FAF3F3',
      'textColor': '#3D3D3D',
      'btnColor': '#E0A899',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Emerald',
      'bgColor': '#0A2E24',
      'textColor': '#F4F9F4',
      'btnColor': '#D4AF37',
      'btnTextColor': '#0A2E24',
    },
    {
      'name': 'Midnight',
      'bgColor': '#121212',
      'textColor': '#E0E0E0',
      'btnColor': '#2B2B2B',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Coral Sunset',
      'bgColor': '#FFF5F0',
      'textColor': '#2D2D2D',
      'btnColor': '#FF6F59',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Ocean Mint',
      'bgColor': '#F0F9F8',
      'textColor': '#1E3535',
      'btnColor': '#2EC4B6',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Lavender',
      'bgColor': '#F8F7FF',
      'textColor': '#2A2A3A',
      'btnColor': '#B8B8FF',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Cyberpunk',
      'bgColor': '#1A0B2E',
      'textColor': '#00FFFF',
      'btnColor': '#FF007F',
      'btnTextColor': '#FFFFFF',
    },
    {
      'name': 'Ruby Red',
      'bgColor': '#1C0A10',
      'textColor': '#FADAE2',
      'btnColor': '#C1272D',
      'btnTextColor': '#FFFFFF',
    },
  ];

  final List<String> imageAssets = [
    'assets/images/image1.png', // Replace with your actual asset paths
    'assets/images/image2.png',
    'assets/images/image3.png',
    'assets/images/image4.png',
  ];
  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
    _getCurrentUser();
    _loadProfileData();
    fetchHideStatus();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      safeSetState(() {
        _currentPlan = prefs.getString('handskill_plan') ?? 'free';
      });
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

      if (profileResponse != null && mounted) {
        safeSetState(() {
          _loadedProfileId = profileResponse['id']?.toString();
          _nameController.text = profileResponse['name'] ?? '';
          _imageUrl = (profileResponse['profile_image_url']?.toString().isEmpty ?? true) ? null : profileResponse['profile_image_url'];
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _phoneNumberController.text = profileResponse['phone_no'] ?? '';
          _bioController.text = profileResponse['bio'] ?? '';
          selectedCountry = profileResponse['country'] ?? '';
          selectedState = profileResponse['state'] ?? '';
          selectedCity = profileResponse['city'] ?? '';
          
          _colorCode = (profileResponse['bg_color_code'] != null && profileResponse['bg_color_code'].toString().isNotEmpty) ? profileResponse['bg_color_code'] : '#000000';
          _colorCode1 = (profileResponse['bg_text_color'] != null && profileResponse['bg_text_color'].toString().isNotEmpty) ? profileResponse['bg_text_color'] : '#FFFFFF';
          _colorCode2 = (profileResponse['button_color_code'] != null && profileResponse['button_color_code'].toString().isNotEmpty) ? profileResponse['button_color_code'] : '#FFD700';
          _colorCode3 = (profileResponse['button_text_color'] != null && profileResponse['button_text_color'].toString().isNotEmpty) ? profileResponse['button_text_color'] : '#000000';
          
          _selectedColor = _convertStringToColor(_colorCode!);
          _selectedColor1 = _convertStringToColor(_colorCode1!);
          _selectedColor2 = _convertStringToColor(_colorCode2!);
          _selectedColor3 = _convertStringToColor(_colorCode3!);

          _imageUrlBanner = (profileResponse['banner_image_url']?.toString().isEmpty ?? true) ? null : profileResponse['banner_image_url'];
          _dayController.text = profileResponse['day']?.toString() ?? '';
          _monthController.text = profileResponse['month']?.toString() ?? '';
          _yearController.text = profileResponse['year']?.toString() ?? '';
          instaIdController.text = profileResponse['insta_id'] ?? '';
          instaLinkController.text = profileResponse['insta_link'] ?? '';
          _selectedTemplateId = profileResponse['web_template_id'] ?? 'default';
          
          _businessType = profileResponse['business_type'] ?? 'product';
          _wantsPaymentIntegration = profileResponse['wants_payment_integration'] ?? false;
          _isPrivate = profileResponse['is_private'] ?? false;
          if (profileResponse['avatar_config'] != null) {
            try {
              final map = Map<String, dynamic>.from(profileResponse['avatar_config']);
              _avatarConfig = VectorAvatarConfig.fromMap(map);
            } catch (_) {}
          }
        });
      }
    } catch (error) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isLoading = false);
      }
    }
  }

  static Uint8List _compressImageStatic(_CompressParams params) {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(params.imageBytes);
      if (image == null) return params.imageBytes;

      // Resize image if it's too large (optional - keeps clarity but reduces file size)
      // Max width/height of 1920px for good quality while reducing size
      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1920 : null,
          interpolation: img.Interpolation.cubic, // Better quality interpolation
        );
      }

      // Compress as JPEG with specified quality (85 = good balance of quality/size)
      List<int> compressedBytes = img.encodeJpg(image, quality: params.quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('Error in background image compression: $e');
      return params.imageBytes; // Return original if compression fails
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes,
      {int quality = 85}) async {
    // Run compression in a background Isolate to keep UI fluid and responsive!
    return await compute(
      _compressImageStatic,
      _CompressParams(imageBytes, quality),
    );
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Show loading state
    safeSetState(() {
      _isCompressingProfile = true;
    });

    try {
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await pickedFile.readAsBytes();
      } else {
        final file = io.File(pickedFile.path);
        fileBytes = await file.readAsBytes();
      }

      // Show beautiful interactive crop dialog
      if (!mounted) return;
      final croppedBytes = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ImageCropDialog(
          imageBytes: fileBytes,
          isCircle: true,
        ),
      );

      if (croppedBytes == null) {
        safeSetState(() {
          _isCompressingProfile = false;
        });
        return;
      }

      // Compress the image
      final compressedBytes = await _compressImage(croppedBytes);

      safeSetState(() {
        _selectedImageBytes = compressedBytes;
        _isCompressingProfile = false;
      });
    } catch (e, stackTrace) {
      debugPrint('=== IMAGE COMPRESS ERROR ===\n$e\n$stackTrace\n===================');
      safeSetState(() {
        _isCompressingProfile = false;
      });

      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _selectImageBanner() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Show loading state
    safeSetState(() {
      _isCompressingBanner = true;
    });

    try {
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await pickedFile.readAsBytes();
      } else {
        final file = io.File(pickedFile.path);
        fileBytes = await file.readAsBytes();
      }

      // Show beautiful interactive crop dialog
      if (!mounted) return;
      final croppedBytes = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ImageCropDialog(
          imageBytes: fileBytes,
          isCircle: false,
        ),
      );

      if (croppedBytes == null) {
        safeSetState(() {
          _isCompressingBanner = false;
        });
        return;
      }

      // Compress the banner image
      final compressedBytes = await _compressImage(croppedBytes, quality: 90);

      safeSetState(() {
        _selectedImageBytesBanner = compressedBytes;
        _isCompressingBanner = false;
      });
    } catch (e, stackTrace) {
      debugPrint('=== BANNER COMPRESS ERROR ===\n$e\n$stackTrace\n===================');
      safeSetState(() {
        _isCompressingBanner = false;
      });

      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error processing banner image: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    // First, validate all required fields
    bool isValid = true;
    String errorMessage = '';

    // Check for required text fields
    if (_nameController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Please enter your name';
    } else if (_shopNameController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Please enter your shop name';
    } else if (_phoneNumberController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Please enter your phone number';
    } else if (_bioController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Please enter your bio';
    }

    // Content filtering validation
    if (isValid) {
      // Check for objectionable content in text fields
      if (_containsObjectionableContent(_nameController.text)) {
        isValid = false;
        errorMessage =
            'Name contains inappropriate content. Please use appropriate language.';
      } else if (_containsObjectionableContent(_shopNameController.text)) {
        isValid = false;
        errorMessage =
            'Shop name contains inappropriate content. Please use appropriate language.';
      } else if (_containsObjectionableContent(_bioController.text)) {
        isValid = false;
        errorMessage =
            'Bio contains inappropriate content. Please use appropriate language.';
      }
    }



    // Check for location
    if (isValid && (selectedCountry == null || selectedCountry!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select your country';
    } else if (isValid && (selectedState == null || selectedState!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select your state';
    } else if (isValid && (selectedCity == null || selectedCity!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select your city';
    }

    // Check for colors
    if (isValid && (_colorCode == null || _colorCode!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select a background color';
    } else if (isValid && (_colorCode1 == null || _colorCode1!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select a background text color';
    } else if (isValid && (_colorCode2 == null || _colorCode2!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select a button color';
    } else if (isValid && (_colorCode3 == null || _colorCode3!.isEmpty)) {
      isValid = false;
      errorMessage = 'Please select a button text color';
    }

    // If validation fails, show error and return
    if (!isValid) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // If all validations pass, proceed with saving
    try {
      safeSetState(() => _isLoading = true);

      // _currentUserId = 'd4d20f8e-c56c-444f-8a4d-b01ed60fb05b';
      _currentUserId = _supabase.auth.currentUser!.id;

      if (_selectedImageBytes != null) {
        try {
          if (_imageUrl != null && _imageUrl!.isNotEmpty && !_imageUrl!.contains('picsum.photos')) {
            final oldFilePath = Uri.parse(_imageUrl!).pathSegments.last;
            await _supabase.storage
                .from('profile')
                .remove(['$_currentUserId/$oldFilePath']);
          }
        } catch (e) {
          debugPrint('Error removing old profile image: $e');
        }

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storagePath = '$_currentUserId/$fileName';

        // Upload to nested path
        await _supabase.storage
            .from('profile')
            .uploadBinary(
              storagePath,
              _selectedImageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        // Get public URL with correct path
        final response =
            _supabase.storage.from('profile').getPublicUrl(storagePath);
        _imageUrl = response;

        _selectedImageBytes = null;
      }
      if (_selectedImageBytesBanner != null) {
        try {
          // Remove old image if exists
          if (_imageUrlBanner != null && _imageUrlBanner!.isNotEmpty && !_imageUrlBanner!.contains('picsum.photos')) {
            final oldFilePath = Uri.parse(_imageUrlBanner!).pathSegments.last;
            await _supabase.storage
                .from('profile_banner')
                .remove(['$_currentUserId/$oldFilePath']);
          }
        } catch (e) {
          debugPrint('Error removing old banner image: $e');
        }

        // Create filename with nested folder structure
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storagePath = '$_currentUserId/$fileName';

        // Upload to nested path
        await _supabase.storage
            .from('profile_banner')
            .uploadBinary(
              storagePath,
              _selectedImageBytesBanner!,
              fileOptions: const FileOptions(upsert: true),
            );

        // Get public URL with correct path
        final response =
            _supabase.storage.from('profile_banner').getPublicUrl(storagePath);
        _imageUrlBanner = response;

        _selectedImageBytesBanner = null;
      }

      // Sanitize content before saving
      final sanitizedName = _sanitizeContent(_nameController.text);
      final sanitizedShopName = _sanitizeContent(_shopNameController.text);
      final sanitizedBio = _sanitizeContent(_bioController.text);

      // Update/Insert profile data via atomic upsert
      await _supabase.from('profile').upsert(
        {
          'id': _loadedProfileId ?? _currentUserId,
          'user_id': _currentUserId,
          'name': sanitizedName,
          'profile_image_url': _imageUrl,
          'shop_name': sanitizedShopName,
          'slug': _sanitizeSlug(sanitizedShopName),
          'phone_no': _phoneNumberController.text,
          'bio': sanitizedBio,
          'country': selectedCountry,
          'state': selectedState,
          'city': selectedCity,
          'bg_color_code': _colorCode,
          'bg_text_color': _colorCode1,
          'button_color_code': _colorCode2,
          'button_text_color': _colorCode3,
          'banner_image_url': _imageUrlBanner,
          'day': _dayController.text.isEmpty
              ? null
              : int.tryParse(_dayController.text),
          'month': _monthController.text.isEmpty
              ? null
              : int.tryParse(_monthController.text),
          'year': _yearController.text.isEmpty
              ? null
              : int.tryParse(_yearController.text),
          'insta_id': instaIdController.text,
          'insta_link': instaLinkController.text,
          'web_template_id': _selectedTemplateId,
          'updated_at': DateTime.now().toIso8601String(),
          'business_type': _businessType,
          'wants_payment_integration': _wantsPaymentIntegration,
          'is_private': _isPrivate,
          'avatar_config': _avatarConfig.toMap(),
        },
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_cache_$_currentUserId');
        await prefs.remove('cached_profile_$_currentUserId');
        await prefs.remove('cached_stats_$_currentUserId');
      } catch (e) {
        debugPrint('Error clearing cache: $e');
      }

      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (error, stackTrace) {
      debugPrint('=== PROFILE SAVE ERROR ===\n$error\n$stackTrace\n===================');
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $error', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  String _sanitizeSlug(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  }

  Future<void> _checkShopName() async {
    final shopName = _shopNameController.text.trim();
    if (shopName.isEmpty) {
      safeSetState(() {
        _shopNameMessage = 'Please enter a shop name';
        _shopNameMessageColor = Colors.red;
        _isShopNameVerified = false;
      });
      return;
    }

    safeSetState(() => _checkingShopName = true);

    try {
      final slug = _sanitizeSlug(shopName);

      final response = await _supabase
          .from('profile')
          .select('user_id')
          .eq('slug', slug)
          .maybeSingle();

      if (response != null && response['user_id'] != _currentUserId) {
        safeSetState(() {
          _shopNameMessage = 'Shop name is already taken';
          _shopNameMessageColor = Colors.red;
          _isShopNameVerified = false;
        });
      } else {
        safeSetState(() {
          _shopNameMessage =
              'Shop name available! Website: handskillapp.web.app/$slug';
          _shopNameMessageColor = Colors.green;
          _isShopNameVerified = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking shop name: $e');
    } finally {
      safeSetState(() => _checkingShopName = false);
    }
  }

  // Helper method to check for objectionable content
  bool _containsObjectionableContent(String text) {
    // Convert to lowercase for case-insensitive checking
    String lowerText = text.toLowerCase();

    // List of inappropriate words/phrases to filter
    List<String> inappropriateWords = [
      // Profanity
      'fuck', 'shit', 'bitch', 'dick',
      'motherfucker', 'cock',

      // Hate speech / Discrimination
      'racist', 'terrorist', 'sexist',
      'violence',
      'murder',

      // Sexual content
      'nude', 'naked', 'porn', 'sex', 'xxx', 'boobs', 'penis',
      'orgasm', 'milf', 'blowjob',

      // Drugs & illegal content
      'drug',
      'weed',
      'cocaine',
      'scam',
      'fraud',

      // Add your own local/regional slang or language-specific offensive words if needed
    ];

    // Check for inappropriate content
    for (String word in inappropriateWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }

    // Check for excessive special characters (potential spam)
    RegExp specialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]{5,}');
    if (specialChars.hasMatch(text)) {
      return true;
    }

    // Check for excessive capitalization (potential spam)
    if (text.length > 5 && text.toUpperCase() == text) {
      return true;
    }

    // Check for repeated characters (potential spam)
    RegExp repeatedChars = RegExp(r'(.)\1{4,}');
    if (repeatedChars.hasMatch(text)) {
      return true;
    }

    return false;
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Helper method to sanitize content
  String _sanitizeContent(String text) {
    // Remove leading/trailing whitespace
    String sanitized = text.trim();

    // Remove excessive whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove potentially harmful HTML tags if any
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove excessive special characters
    sanitized = sanitized.replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]{3,}'), '');

    // Limit length to prevent abuse
    if (sanitized.length > 500) {
      sanitized = sanitized.substring(0, 500);
    }

    return sanitized;
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
        debugPrint(response.toString());
        hideData = response.isNotEmpty ? response.first : null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching hide status: $e');
      safeSetState(() {
        isLoading = false;
      });
    }
  }

  // Save hide status with current time
  Future<void> saveHideStatus(bool isHidden) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      if (hideData == null) {
        // Create new record
        await _supabase.from('hide').insert({
          'user_id': user.id,
          'is_hidden': isHidden,
        });
      } else {
        // Update existing record with new timestamp
        await _supabase.from('hide').update({
          'is_hidden': isHidden,
          'created_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
      }

      fetchHideStatus();
    } catch (e) {
      debugPrint('Error saving hide status: $e');
    }
  }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Delete Profile?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete your online shop profile? This will reset all details, colors, website themes, and delete your shop link. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      safeSetState(() => _isLoading = true);

      if (_currentUserId != null) {
        // Delete custom database record
        await _supabase.from('profile').delete().eq('user_id', _currentUserId!);

        // Clear local storage cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_cache_$_currentUserId');
        await prefs.remove('cached_profile_$_currentUserId');
        await prefs.remove('cached_stats_$_currentUserId');

        // Clear controllers locally
        _nameController.clear();
        _shopNameController.clear();
        _phoneNumberController.clear();
        _bioController.clear();
        _dayController.clear();
        _monthController.clear();
        _yearController.clear();
        instaIdController.clear();
        instaLinkController.clear();

        safeSetState(() {
          _imageUrl = null;
          _selectedImageBytes = null;
          _imageUrlBanner = null;
          _selectedImageBytesBanner = null;
          _colorCode = '#000000';
          _colorCode1 = '#FFFFFF';
          _colorCode2 = '#FFD700';
          _colorCode3 = '#000000';
          _selectedColor = Colors.black;
          _selectedColor1 = Colors.white;
          _selectedColor2 = const Color(0xFFFFD700);
          _selectedColor3 = Colors.black;
          selectedCountry = '';
          selectedState = '';
          selectedCity = '';
          _selectedTemplateId = 'default';
          _shopNameMessage = null;
          _isShopNameVerified = false;
        });

        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: const Text('Profile deleted and reset successfully!'),
              backgroundColor: FlutterFlowTheme.of(context).success,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePageWidget()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  Widget buildBeautifulLocationPicker() {
    final theme = DarkModeTheme();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 1.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 15),

          // Custom implementation showing initial values
          Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectState(
                // Using the country_state_city_picker package
                onCountryChanged: (value) {
                  safeSetState(() {
                    selectedCountry = value;
                    selectedState = '';
                    selectedCity = '';
                  });
                },
                onStateChanged: (value) {
                  safeSetState(() {
                    selectedState = value;
                    selectedCity = '';
                  });
                },
                onCityChanged: (value) {
                  safeSetState(() {
                    selectedCity = value;
                  });
                },
                dropdownColor: Colors.black,
                // Style customization
                style: TextStyle(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Display selected values in beautiful tiles
          const SizedBox(height: 20),
          Text(
            'Your Selected Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Country display
          if ((selectedCountry ?? '').isNotEmpty)
            _buildLocationTile(
              title: 'Country',
              value: selectedCountry ?? '',
              icon: Icons.flag_outlined,
              color: theme.primary,
            ),

          // State display
          if ((selectedState ?? '').isNotEmpty)
            _buildLocationTile(
              title: 'State/Province',
              value: selectedState ?? '',
              icon: Icons.location_city_outlined,
              color: theme.secondary,
            ),

          // City display
          if ((selectedCity ?? '').isNotEmpty)
            _buildLocationTile(
              title: 'City',
              value: selectedCity ?? '',
              icon: Icons.business_outlined,
              color: theme.tertiary,
            ),
        ],
      ),
    );
  }

  Color _convertStringToColor(String colorString) {
    try {
      // Remove # if present
      String cleanString = colorString.replaceAll('#', '');
      // Remove 0xFF if present
      cleanString = cleanString.replaceAll('0xFF', '');

      return Color(int.parse(cleanString, radix: 16) + 0xFF000000);
    } catch (e) {
      // Return a default color if parsing fails
      return Colors.black;
    }
  }

// Helper method to build beautiful location tiles
  Widget _buildLocationTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = DarkModeTheme();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: theme.primaryText.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: theme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHidden = hideData?['is_hidden'] ?? true;
    final theme = DarkModeTheme();

    Color ensureContrast(Color fg, Color bg, {bool isButton = true}) {
      double getLuminance(Color color) {
        double r = color.r;
        double g = color.g;
        double b = color.b;
        r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
        g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
        b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
      }

      double l1 = getLuminance(fg);
      double l2 = getLuminance(bg);
      double ratio = (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);

      if (ratio < 2.0) {
        bool bgIsDark = l2 < 0.2;
        if (bgIsDark) {
          return isButton ? const Color(0xFFFFD600) : Colors.white;
        } else {
          return isButton ? const Color(0xFF1E293B) : Colors.black87;
        }
      }
      return fg;
    }

    final Color previewBgColor = _selectedColor ?? _convertStringToColor(_colorCode ?? '#FFFFFF');
    
    final Color rawBgTextColor = _selectedColor1 ?? _convertStringToColor(_colorCode1 ?? '#212121');
    final Color previewBgTextColor = ensureContrast(rawBgTextColor, previewBgColor, isButton: false);

    final Color rawBtnColor = _selectedColor2 ?? _convertStringToColor(_colorCode2 ?? '#2196F3');
    final Color previewBtnColor = ensureContrast(rawBtnColor, previewBgColor, isButton: true);

    final Color rawBtnTextColor = _selectedColor3 ?? _convertStringToColor(_colorCode3 ?? '#FFFFFF');
    final Color previewBtnTextColor = ensureContrast(rawBtnTextColor, previewBtnColor, isButton: false);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Scaffold(
          key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          automaticallyImplyLeading: false,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: theme.primaryText,
                  size: 24.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.primaryText,
                  size: 24.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          leadingWidth: 100,
          actions: const [],
          centerTitle: true,
          elevation: 2.0,
        ),
        backgroundColor: theme.primaryBackground,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 16.0, 0.0, 16.0),
                        child: Text(
                          'Create your Online shop Profile',
                          style: theme.headlineMedium.override(
                            fontFamily: 'Poppins',
                            color: theme.primaryText,
                            fontSize: 22.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: AspectRatio(
                                aspectRatio: 2.0,
                                child: _selectedImageBytesBanner != null
                                    ? Image.memory(
                                        _selectedImageBytesBanner!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: _imageUrlBanner ??
                                            'https://picsum.photos/seed/463/600',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          width: double.infinity,
                                          color: theme.secondaryBackground,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Image.network(
                                          'https://picsum.photos/seed/463/600',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          if (_isCompressingBanner)
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Compressing banner image...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
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
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 130.0, 0.0, 16.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: (_isLoading ||
                                              _isCompressingProfile)
                                          ? null
                                          : _selectImage,
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                           Container(
                                             width: 100,
                                             height: 100,
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: theme.secondaryBackground,
                                             ),
                                             child: Stack(
                                               alignment: Alignment.center,
                                               children: [
                                                 ClipOval(
                                                   child: _selectedImageBytes != null
                                                       ? Image.memory(
                                                           _selectedImageBytes!,
                                                           width: 100,
                                                           height: 100,
                                                           fit: BoxFit.cover,
                                                         )
                                                       : (_imageUrl != null && _imageUrl!.isNotEmpty
                                                           ? CachedNetworkImage(
                                                               imageUrl: _imageUrl!,
                                                               width: 100,
                                                               height: 100,
                                                               fit: BoxFit.cover,
                                                               placeholder: (context, url) => const Center(
                                                                 child: CircularProgressIndicator(
                                                                   strokeWidth: 2,
                                                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                                                 ),
                                                               ),
                                                               errorWidget: (context, url, error) => Icon(
                                                                 Icons.person,
                                                                 size: 40,
                                                                 color: theme.secondaryText,
                                                               ),
                                                             )
                                                           : Icon(Icons.person,
                                                               size: 40,
                                                               color: theme.secondaryText)),
                                                 ),
                                                 if (_isCompressingProfile)
                                                   Container(
                                                     decoration: const BoxDecoration(
                                                       color: Colors.black54,
                                                       shape: BoxShape.circle,
                                                     ),
                                                     alignment: Alignment.center,
                                                     child: CircularProgressIndicator(
                                                       strokeWidth: 3,
                                                       valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                                                     ),
                                                   ),
                                               ],
                                             ),
                                           ),
                                          if (!_isLoading &&
                                              !_isCompressingProfile)
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: theme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.add_a_photo,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          if (_imageUrl != null && _imageUrl!.isNotEmpty || _selectedImageBytes != null)
                                            Positioned(
                                              left: 0,
                                              bottom: 0,
                                              child: GestureDetector(
                                                onTap: _isLoading ? null : () {
                                                  safeSetState(() {
                                                    _imageUrl = null;
                                                    _selectedImageBytes = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Edit button for banner
                      Positioned(
                        right: 32,
                        bottom: 60,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_imageUrlBanner != null && _imageUrlBanner!.isNotEmpty || _selectedImageBytesBanner != null)
                              GestureDetector(
                                onTap: _isLoading ? null : () {
                                  safeSetState(() {
                                    _imageUrlBanner = null;
                                    _selectedImageBytesBanner = null;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: (_isLoading || _isCompressingBanner)
                                  ? null
                                  : _selectImageBanner,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: _isCompressingBanner
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Banner image and Profile picture',
                      style: theme.bodyMedium.override(
                        fontFamily: 'Montserrat',
                        color: theme.secondaryText,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Warning Message
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Avoid using inappropriate words in your name, shop name, or description.',
                              style: theme.bodySmall.override(
                                fontFamily: 'Montserrat',
                                color: theme.primaryText,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Name Text Field
                  CustomTextField(
                    width: double.infinity,
                    height: 56.0,
                    controller: _nameController,
                    labelText: 'Your Name',
                    hintText: 'Enter your full name',
                  ),

                  // Shop Name Text Field
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          width: double.infinity,
                          height: 56.0,
                          controller: _shopNameController,
                          labelText: 'Shop Name',
                          hintText: 'Unique name for your shop',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _checkingShopName ? null : _checkShopName,
                              icon: _checkingShopName
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: theme.primary))
                                  : Icon(Icons.check_circle,
                                      color: _isShopNameVerified
                                          ? theme.success
                                          : theme.secondaryText),
                              tooltip: 'Verify Availability',
                            ),
                            Text('Verify',
                                style: theme.bodySmall.override(
                                  fontFamily: 'Montserrat',
                                  color: theme.primaryText,
                                  fontSize: 10,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                  if (_shopNameMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Text(
                        _shopNameMessage!,
                        style: theme.bodySmall.override(
                          fontFamily: 'Montserrat',
                          color: _shopNameMessageColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  // Business Setup Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Setup',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'What is your business type?',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => safeSetState(() => _businessType = 'product'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _businessType == 'product' ? theme.primary : theme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _businessType == 'product' ? theme.primary : theme.alternate,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Product',
                                    style: TextStyle(
                                      color: _businessType == 'product' ? Colors.black : theme.primaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => safeSetState(() => _businessType = 'service'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _businessType == 'service' ? theme.primary : theme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _businessType == 'service' ? theme.primary : theme.alternate,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Service',
                                    style: TextStyle(
                                      color: _businessType == 'service' ? Colors.black : theme.primaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: theme.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Enable Payment Integration (Coming soon)',
                                  style: TextStyle(color: theme.primaryText, fontSize: 13),
                                ),
                              ),
                              Switch(
                                value: _wantsPaymentIntegration,
                                onChanged: (v) {
                                  safeSetState(() => _wantsPaymentIntegration = v);
                                  if (v) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Payment integration will be fully unlocked in a future update!')),
                                    );
                                  }
                                },
                                activeThumbColor: theme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline, color: theme.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Private Account',
                                  style: TextStyle(color: theme.primaryText, fontSize: 13),
                                ),
                              ),
                              Switch(
                                value: _isPrivate,
                                onChanged: (v) {
                                  safeSetState(() => _isPrivate = v);
                                },
                                activeThumbColor: theme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.alternate),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.language, color: theme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Your Shop Website',
                                    style: TextStyle(color: theme.primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  if (_currentPlan == 'free') ...[
                                    const Spacer(),
                                    Icon(Icons.lock, color: Colors.red[400], size: 16),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_currentPlan == 'free') ...[
                                Text(
                                  'Upgrade to Premium to unlock your custom web profile.',
                                  style: TextStyle(color: theme.secondaryText, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                                    },
                                    icon: const Icon(Icons.workspace_premium),
                                    label: const Text('Upgrade Plan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD700),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Your store will be hosted at:\nhandskillapp.web.app/${_shopNameController.text.isNotEmpty ? _sanitizeSlug(_shopNameController.text) : 'your-shop-name'}',
                                  style: TextStyle(color: theme.secondaryText, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please contact the Handskill Team at +91 0000000000 to setup a custom domain.')),
                                      );
                                    },
                                    icon: Icon(Icons.support_agent, color: theme.primary),
                                    label: Text('Get Custom Domain Hosting', style: TextStyle(color: theme.primary)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: theme.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone Number Section
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 16.0, 24.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _phoneNumberController.text.isNotEmpty
                              ? '${_phoneNumberController.text} | Phone number'
                              : 'Add your phone number',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  CustomPhoneTextField(
                    width: double.infinity,
                    height: 56.0,
                    controller: _phoneNumberController,
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    initialCountryCode: 'IN',
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.alternate),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.security, color: theme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Show WhatsApp & Phone number in public view',
                              style: theme.bodySmall.override(
                                fontFamily: 'Montserrat',
                                color: theme.primaryText,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Switch(
                            value: !isHidden,
                            onChanged: (value) => saveHideStatus(!value),
                            activeThumbColor: theme.primary,
                            activeTrackColor: theme.primary.withValues(alpha: 0.3),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: theme.alternate,
                          ),
                        ],
                      ),
                    ),
                  ),


                  // Bio Text Field
                  CustomTextField(
                    width: double.infinity,
                    height: 56.0,
                    controller: _bioController,
                    labelText: 'Your Bio',
                    hintText: 'Tell the world about yourself...',
                    maxLines: 3,
                  ),

                  // DOB Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          'Date of Birth',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dayController,
                            style: TextStyle(color: theme.primaryText),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'DD',
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.secondaryBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.alternate),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _monthController,
                            style: TextStyle(color: theme.primaryText),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'MM',
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.secondaryBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.alternate),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _yearController,
                            style: TextStyle(color: theme.primaryText),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'YYYY',
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.secondaryBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: theme.alternate),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Social Links Section
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: CustomTextField(
                      width: double.infinity,
                      height: 56.0,
                      controller: instaIdController,
                      labelText: 'Instagram ID',
                      hintText: '@username',
                    ),
                  ),
                  CustomTextField(
                    width: double.infinity,
                    height: 56.0,
                    controller: instaLinkController,
                    labelText: 'Instagram Profile Link',
                    hintText: 'https://instagram.com/yourprofile',
                  ),

                  // Template Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          'Web Profile Template',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildTemplateItem('default', 'React Glassmorphism', Icons.auto_awesome),
                        _buildTemplateItem('minimal', 'React Cyber Neon', Icons.bolt),
                        _buildTemplateItem('modern', 'Next.js Portfolio', Icons.web),
                        _buildTemplateItem('classic', 'Three.js 3D Web', Icons.view_in_ar_rounded),
                      ],
                    ),
                  ),

                  // Live Preview Section
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.alternate),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Live Color Preview',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: previewBgColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: previewBgTextColor.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 35,
                                  color: previewBgTextColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
                                style: TextStyle(
                                  color: previewBgTextColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: previewBtnColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                child: Center(
                                  child: Text(
                                    'View Profile',
                                    style: TextStyle(
                                      color: previewBtnTextColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: theme.primaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildColorInfo('BG', _colorCode ?? '#FFFFFF'),
                              _buildColorInfo('Text', _colorCode1 ?? '#212121'),
                              _buildColorInfo('Btn', _colorCode2 ?? '#2196F3'),
                              _buildColorInfo('Btn Text', _colorCode3 ?? '#FFFFFF'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Pocket Mates Avatar & Comic Styling Section ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.08),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pocket Mates Avatar & Styling 🎭',
                                      style: GoogleFonts.outfit(
                                        color: theme.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '50+ Roles, Hairstyles, Comic Banners & Theme Sync',
                                      style: GoogleFonts.inter(
                                        color: theme.secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Avatar Preview & Action Row
                          Row(
                            children: [
                              // Live Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFFFC00), width: 2),
                                ),
                                child: VectorAvatarWidget(
                                  config: _avatarConfig,
                                  size: 76,
                                  showAura: true,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Edit Avatar & Match Theme Buttons
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VectorAvatarStudioPage(
                                                initialConfig: _avatarConfig,
                                                onAvatarSaved: (newCfg) {
                                                  safeSetState(() {
                                                    _avatarConfig = newCfg;
                                                  });
                                                  _applyAvatarTheme(newCfg);
                                                },
                                              ),
                                            ),
                                          ).then((res) {
                                            if (res is VectorAvatarConfig) {
                                              safeSetState(() => _avatarConfig = res);
                                              _applyAvatarTheme(res);
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.palette, size: 16, color: Colors.black),
                                        label: Text(
                                          'Open Avatar Studio',
                                          style: GoogleFonts.outfit(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFFC00),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _applyAvatarTheme(_avatarConfig),
                                        icon: const Icon(Icons.sync_alt, size: 15, color: Color(0xFFFFFC00)),
                                        label: Text(
                                          'Sync Theme to Avatar',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFFC00),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFFFFC00)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161822),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.verified_rounded, color: Color(0xFFFFD700), size: 14),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '1-of-1 NFT: ${_avatarConfig.mintId ?? "#MATE-ORIGINAL"} • ${_avatarConfig.rarityTier.toUpperCase()}',
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFFFD700),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 12),

                          // Avatar Themed Banners
                          Text(
                            'Avatar-Themed Banners (10 Presets)',
                            style: GoogleFonts.outfit(
                              color: theme.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 70,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _avatarBannerPresets.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final preset = _avatarBannerPresets[index];
                                final isSelected = _imageUrlBanner == preset['url'];

                                return GestureDetector(
                                  onTap: () {
                                    safeSetState(() {
                                      _imageUrlBanner = preset['url'];
                                      _selectedImageBytesBanner = null;
                                    });
                                    _scaffoldMessengerKey.currentState?.showSnackBar(
                                      SnackBar(
                                        content: Text('🖼️ Applied ${preset['name']} banner!'),
                                        duration: const Duration(milliseconds: 700),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                                        width: isSelected ? 2.5 : 1,
                                      ),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(preset['url']!),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                                                blurRadius: 8,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black87, Colors.transparent],
                                        ),
                                      ),
                                      alignment: Alignment.bottomLeft,
                                      padding: const EdgeInsets.all(6),
                                      child: Text(
                                        preset['name']!,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🎯 60-Day English Journey Theme Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.5), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🎯', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              '60-Day English Palette Evolution',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFFC00),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your profile theme unlocks automatically through 20 progressive color milestones as you practice English daily.',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (_currentUserId != null) {
                                Learning60DayDashboardSheet.show(context, userId: _currentUserId!);
                              }
                            },
                            icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFFFFC00)),
                            label: Text(
                              'View 60-Day Dashboard & 20 Palettes',
                              style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFFFC00)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Preset Selection Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          'Select Color Theme Preset',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Montserrat',
                            color: theme.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: _colorPresets.map((preset) {
                        final bg = _convertStringToColor(preset['bgColor']!);
                        final text = _convertStringToColor(preset['textColor']!);
                        final btn = _convertStringToColor(preset['btnColor']!);
                        final btnText = _convertStringToColor(preset['btnTextColor']!);
                        
                        // Check if current values match this preset
                        final isSelected = _colorCode?.toUpperCase() == preset['bgColor']?.toUpperCase() &&
                            _colorCode1?.toUpperCase() == preset['textColor']?.toUpperCase() &&
                            _colorCode2?.toUpperCase() == preset['btnColor']?.toUpperCase() &&
                            _colorCode3?.toUpperCase() == preset['btnTextColor']?.toUpperCase();

                        return GestureDetector(
                          onTap: () {
                            safeSetState(() {
                              _colorCode = preset['bgColor'];
                              _colorCode1 = preset['textColor'];
                              _colorCode2 = preset['btnColor'];
                              _colorCode3 = preset['btnTextColor'];
                              
                              _selectedColor = bg;
                              _selectedColor1 = text;
                              _selectedColor2 = btn;
                              _selectedColor3 = btnText;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.primary : theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? theme.primary : theme.alternate,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.primary.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Mini Swatch Preview
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: btn,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  preset['name']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : theme.primaryText,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Color Pickers
                  ColorPickerWidget(
                    key: ValueKey('bg_$_colorCode'),
                    width: double.infinity,
                    height: 56.0,
                    label: 'Website Background color',
                    initialColor: _selectedColor,
                    initialColorCode: _colorCode ?? '#FFFFFF',
                    onColorSelected: (color, code) {
                      safeSetState(() {
                        _selectedColor = color;
                        _colorCode = code;
                      });
                    },
                  ),
                  ColorPickerWidget(
                    key: ValueKey('text_$_colorCode1'),
                    width: double.infinity,
                    height: 56.0,
                    label: 'Website Text color',
                    initialColor: _selectedColor1,
                    initialColorCode: _colorCode1 ?? '#212121',
                    onColorSelected: (color, code) {
                      safeSetState(() {
                        _selectedColor1 = color;
                        _colorCode1 = code;
                      });
                    },
                  ),
                  ColorPickerWidget(
                    key: ValueKey('btn_$_colorCode2'),
                    width: double.infinity,
                    height: 56.0,
                    label: 'Website Button color',
                    initialColor: _selectedColor2,
                    initialColorCode: _colorCode2 ?? '#2196F3',
                    onColorSelected: (color, code) {
                      safeSetState(() {
                        _selectedColor2 = color;
                        _colorCode2 = code;
                      });
                    },
                  ),
                  ColorPickerWidget(
                    key: ValueKey('btntext_$_colorCode3'),
                    width: double.infinity,
                    height: 56.0,
                    label: 'Website Button Text color',
                    initialColor: _selectedColor3,
                    initialColorCode: _colorCode3 ?? '#FFFFFF',
                    onColorSelected: (color, code) {
                      safeSetState(() {
                        _selectedColor3 = color;
                        _colorCode3 = code;
                      });
                    },
                  ),

                  buildBeautifulLocationPicker(),

                  // Danger Zone (Delete Profile)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Danger Zone',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Delete your shop profile and reset all settings to defaults.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.secondaryText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _deleteProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Delete Profile'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 40),
                    child: FFButtonWidget(
                      onPressed: _isLoading ? null : _saveProfile,
                      text: _isLoading ? 'Saving...' : 'Complete Profile',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        color: theme.primary,
                        textStyle: theme.titleMedium.override(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(12.0),
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
  );
}

  Widget _buildColorInfo(String label, String colorCode) {
    final theme = DarkModeTheme();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _convertStringToColor(colorCode),
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.secondaryText,
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          colorCode.substring(1, 4).toUpperCase(),
          style: TextStyle(
            color: theme.secondaryText.withValues(alpha: 0.8),
            fontSize: 9.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateItem(String id, String name, IconData icon) {
    final theme = DarkModeTheme();
    final isSelected = _selectedTemplateId == id;
    
    // Build the visual preview representing the template layout
    Widget previewWidget;
    switch (id) {
      case 'default':
        // React Glassmorphism
        previewWidget = Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 2),
                      Container(width: 25, height: 4, decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 'minimal':
        // React Cyber Neon
        previewWidget = Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF0D0221),
          ),
          child: Stack(
            children: [
              // Neon Grid mock
              Positioned.fill(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, idx) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x3300FFFF), width: 0.5),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF140152),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00FFFF), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF007F))),
                      const SizedBox(height: 4),
                      Container(width: 50, height: 4, decoration: BoxDecoration(color: const Color(0xFF00FFFF), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 2),
                      Container(width: 30, height: 4, decoration: BoxDecoration(color: const Color(0xFF00FFFF).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 'modern':
        // Next.js Portfolio
        previewWidget = Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFF1F5F9),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F172A))),
                    const SizedBox(width: 6),
                    Container(width: 40, height: 6, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFF64748B))),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Center(child: Icon(Icons.settings_outlined, size: 16, color: Color(0xFF64748B))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case 'classic':
      default:
        // Three.js 3D Web
        previewWidget = Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF0A0F1D), Color(0xFF070A13)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Floating orbital particles
              Positioned(
                left: 15,
                top: 15,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [const Color(0xFF8B5CF6).withValues(alpha: 0.8), const Color(0xFF8B5CF6).withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [const Color(0xFFEC4899).withValues(alpha: 0.6), const Color(0xFFEC4899).withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              // Floating 3D card layout in perspective
              Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.003)
                    ..rotateX(0.2)
                    ..rotateY(-0.2),
                  alignment: Alignment.center,
                  child: Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
    }

    return GestureDetector(
      onTap: () => safeSetState(() => _selectedTemplateId = id),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14, bottom: 8),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: previewWidget,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? theme.primary : theme.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? theme.primary : theme.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Interactive Image Crop Dialog & Custom Painters (Pure Dart)
// -------------------------------------------------------------

class ImageCropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final bool isCircle;

  const ImageCropDialog({
    super.key,
    required this.imageBytes,
    required this.isCircle,
  });

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final TransformationController _transformationController = TransformationController();
  final GlobalKey<ScaffoldMessengerState> _dialogScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _isProcessing = false;
  img.Image? _decodedImage;
  bool _isDecoding = true;
  double? _childWidth;
  double? _childHeight;
  bool _initMatrix = false;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  Future<void> _decodeImage() async {
    try {
      final decoded = await compute(img.decodeImage, widget.imageBytes);
      if (mounted) {
        setState(() {
          _decodedImage = decoded;
          _isDecoding = false;
        });
      }
    } catch (e) {
      debugPrint('Error decoding image for crop: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _applyCrop(double screenWidth, double screenHeight) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final matrix = _transformationController.value;
      final double scale = matrix.getMaxScaleOnAxis();
      final double tx = matrix.entry(0, 3);
      final double ty = matrix.entry(1, 3);

      double viewportWidth = widget.isCircle ? 260.0 : 320.0;
      double viewportHeight = widget.isCircle ? 260.0 : 160.0;

      double left = (screenWidth - viewportWidth) / 2;
      double top = (screenHeight - viewportHeight) / 2;

      double cropLeftRendered = (left - tx) / scale;
      double cropTopRendered = (top - ty) / scale;
      double cropWidthRendered = viewportWidth / scale;
      double cropHeightRendered = viewportHeight / scale;

      double childWidth = _childWidth!;
      double childHeight = _childHeight!;
      int originalWidth = _decodedImage!.width;
      int originalHeight = _decodedImage!.height;

      double cropLeftOrig = cropLeftRendered * (originalWidth / childWidth);
      double cropTopOrig = cropTopRendered * (originalHeight / childHeight);
      double cropWidthOrig = cropWidthRendered * (originalWidth / childWidth);
      double cropHeightOrig = cropHeightRendered * (originalHeight / childHeight);

      int x = cropLeftOrig.round().clamp(0, originalWidth - 1);
      int y = cropTopOrig.round().clamp(0, originalHeight - 1);
      int w = cropWidthOrig.round().clamp(1, originalWidth - x);
      int h = cropHeightOrig.round().clamp(1, originalHeight - y);

      final croppedImage = await compute(_cropImageIsolate, _CropParams(_decodedImage!, x, y, w, h));
      final croppedBytes = await compute(_encodeImageIsolate, croppedImage);

      if (mounted) {
        Navigator.pop(context, croppedBytes);
      }
    } catch (e) {
      debugPrint('Error applying crop: $e');
      if (mounted) {
        _dialogScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error cropping image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _dialogScaffoldMessengerKey,
      child: Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Scaffold(
        backgroundColor: Colors.black,
        body: _isDecoding
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFFFD700),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Image...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;

                  double viewportWidth = widget.isCircle ? 260.0 : 320.0;
                  double viewportHeight = widget.isCircle ? 260.0 : 160.0;

                  double imageWidth = _decodedImage!.width.toDouble();
                  double imageHeight = _decodedImage!.height.toDouble();
                  double imageAspect = imageWidth / imageHeight;
                  double viewportAspect = viewportWidth / viewportHeight;

                  double childWidth;
                  double childHeight;

                  if (imageAspect > viewportAspect) {
                    childHeight = viewportHeight;
                    childWidth = viewportHeight * imageAspect;
                  } else {
                    childWidth = viewportWidth;
                    childHeight = viewportWidth / imageAspect;
                  }

                  _childWidth = childWidth;
                  _childHeight = childHeight;

                  double left = (screenWidth - viewportWidth) / 2;
                  double top = (screenHeight - viewportHeight) / 2;

                  if (!_initMatrix) {
                    double xInitial = left + (viewportWidth - childWidth) / 2;
                    double yInitial = top + (viewportHeight - childHeight) / 2;

                    final matrix = Matrix4.identity()
                      ..setTranslationRaw(xInitial, yInitial, 0);
                    _transformationController.value = matrix;
                    _initMatrix = true;
                  }

                  return Stack(
                    children: [
                      // The Image view that is pannable and zoomable
                      Positioned.fill(
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1.0,
                          maxScale: 5.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(180.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: childWidth,
                              height: childHeight,
                              child: Image.memory(
                                widget.imageBytes,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),


                      // Overlay Mask with hole and gold frame
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: CropMaskPainter(isCircle: widget.isCircle),
                          ),
                        ),
                      ),

                      // Top Bar
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              widget.isCircle ? 'Crop Profile Photo' : 'Crop Banner Photo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 48), // To balance the back button
                          ],
                        ),
                      ),

                      // Bottom controls
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Pinch to zoom • Drag to position',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white54),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isProcessing ? null : () => _applyCrop(screenWidth, screenHeight),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD700), // Luxury Gold
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isProcessing
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                            ),
                                          )
                                        : const Text(
                                            'Save Crop',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }
}

class CropMaskPainter extends CustomPainter {
  final bool isCircle;

  CropMaskPainter({required this.isCircle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    double viewportWidth = isCircle ? 260.0 : 320.0;
    double viewportHeight = isCircle ? 260.0 : 160.0;

    double left = (size.width - viewportWidth) / 2;
    double top = (size.height - viewportHeight) / 2;
    final viewportRect = Rect.fromLTWH(left, top, viewportWidth, viewportHeight);

    final holePath = Path();
    if (isCircle) {
      holePath.addOval(viewportRect);
    } else {
      holePath.addRRect(RRect.fromRectAndRadius(viewportRect, const Radius.circular(16)));
    }

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final maskPath = Path.combine(PathOperation.difference, outerPath, holePath);
    canvas.drawPath(maskPath, paint);

    final framePaint = Paint()
      ..color = const Color(0xFFFFD700) // Luxury Gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    if (isCircle) {
      canvas.drawOval(viewportRect, framePaint);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(viewportRect, const Radius.circular(16)), framePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CropParams {
  final img.Image image;
  final int x;
  final int y;
  final int w;
  final int h;

  _CropParams(this.image, this.x, this.y, this.w, this.h);
}

img.Image _cropImageIsolate(_CropParams params) {
  return img.copyCrop(
    params.image,
    x: params.x,
    y: params.y,
    width: params.w,
    height: params.h,
  );
}

Uint8List _encodeImageIsolate(img.Image image) {
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

