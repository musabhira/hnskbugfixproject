import 'package:pocket_mates_app/custom_code/widgets/custom_phone_text_field.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_text_field.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:country_state_city_picker/country_state_city_picker.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_studio_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/avatar_network_explorer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_60day_dashboard.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';

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
  Color? _selectedColor = Colors.black;
  String? _colorCode = '#000000';
  Color? _selectedColor1 = Colors.white;
  String? _colorCode1 = '#FFFFFF';
  Color? _selectedColor2 = const Color(0xFFFFD700);
  String? _colorCode2 = '#FFD700';
  Color? _selectedColor3 = Colors.black;
  String? _colorCode3 = '#000000';

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  Uint8List? _selectedImageBytes;
  
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
  int _learningDay = 1;

  // Profile Information Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController instaIdController = TextEditingController();
  final TextEditingController instaLinkController = TextEditingController();

  // English Learning & Demographic State
  String selectedGender = 'Not specified';
  String selectedNativeLanguage = 'Malayalam';
  String selectedEnglishLevel = 'Intermediate (B1-B2)';
  String selectedLearningGoal = 'Daily Fluency & Speaking';
  DateTime? _selectedDob;
  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    _loadProfileData();
    fetchHideStatus();
  }

  Future<void> _loadProfileData() async {
    try {
      safeSetState(() => _isLoading = true);

      _currentUserId ??= _supabase.auth.currentUser?.id;
      if (_currentUserId == null) {
        // Fallback: wait briefly if session is restoring
        await Future.delayed(const Duration(milliseconds: 300));
        _currentUserId ??= _supabase.auth.currentUser?.id;
        if (_currentUserId == null) return;
      }

      // Fetch profile data
      int userDay = 1;
      try {
        final prefs = await SharedPreferences.getInstance();
        userDay = prefs.getInt('pocket_learning_user_stage_$_currentUserId') ?? prefs.getInt('learning_day_$_currentUserId') ?? 1;
      } catch (_) {}

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
          _phoneNumberController.text = profileResponse['phone_no'] ?? '';
          _bioController.text = profileResponse['bio'] ?? '';
          selectedCountry = profileResponse['country'] ?? '';
          selectedState = profileResponse['state'] ?? '';
          selectedCity = profileResponse['city'] ?? '';
          
          final rawDay = (profileResponse['learning_day'] as num?)?.toInt();
          if (rawDay != null && rawDay > userDay) {
            userDay = rawDay;
          }
          _learningDay = userDay;
          final stage = LearningMilestoneStage.getStageForDay(_learningDay);
          
          _colorCode = stage.bgHex;
          _colorCode1 = stage.textHex;
          _colorCode2 = stage.buttonHex;
          _colorCode3 = stage.buttonTextHex;
          
          _selectedColor = stage.bgColor;
          _selectedColor1 = stage.textColor;
          _selectedColor2 = stage.buttonColor;
          _selectedColor3 = stage.buttonTextColor;

          _imageUrlBanner = (profileResponse['banner_image_url']?.toString().isEmpty ?? true) ? null : profileResponse['banner_image_url'];
          
          final d = (profileResponse['day'] as num?)?.toInt();
          final m = (profileResponse['month'] as num?)?.toInt();
          final y = (profileResponse['year'] as num?)?.toInt();
          if (d != null && m != null && y != null && y > 1900 && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
            try {
              _selectedDob = DateTime(y, m, d);
            } catch (_) {}
          }

          selectedGender = profileResponse['gender'] ?? 'Not specified';
          selectedNativeLanguage = profileResponse['native_language'] ?? 'Malayalam';
          selectedEnglishLevel = profileResponse['english_level'] ?? 'Intermediate (B1-B2)';
          selectedLearningGoal = profileResponse['learning_goal'] ?? 'Daily Fluency & Speaking';

          instaIdController.text = profileResponse['insta_id'] ?? '';
          instaLinkController.text = profileResponse['insta_link'] ?? '';
          _selectedTemplateId = profileResponse['web_template_id'] ?? 'default';
          
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
    // First, validate required fields
    bool isValid = true;
    String errorMessage = '';

    // Check for required text fields
    if (_nameController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Please enter your name';
    } else if (_containsObjectionableContent(_nameController.text)) {
      isValid = false;
      errorMessage =
          'Name contains inappropriate content. Please use appropriate language.';
    } else if (_bioController.text.isNotEmpty && _containsObjectionableContent(_bioController.text)) {
      isValid = false;
      errorMessage =
          'Bio contains inappropriate content. Please use appropriate language.';
    }

    // Default colors if unselected
    _colorCode = (_colorCode != null && _colorCode!.isNotEmpty) ? _colorCode : '#000000';
    _colorCode1 = (_colorCode1 != null && _colorCode1!.isNotEmpty) ? _colorCode1 : '#FFFFFF';
    _colorCode2 = (_colorCode2 != null && _colorCode2!.isNotEmpty) ? _colorCode2 : '#FFD700';
    _colorCode3 = (_colorCode3 != null && _colorCode3!.isNotEmpty) ? _colorCode3 : '#000000';

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

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Please log in to save your profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      _currentUserId = currentUser.id;

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
      final internalShopName = sanitizedName.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
      final sanitizedBio = _sanitizeContent(_bioController.text);

      // Update/Insert profile data via atomic upsert
      await _supabase.from('profile').upsert(
        {
          'id': _loadedProfileId ?? _currentUserId,
          'user_id': _currentUserId,
          'name': sanitizedName,
          'profile_image_url': _imageUrl,
          'shop_name': internalShopName,
          'slug': _sanitizeSlug(internalShopName),
          'phone_no': _phoneNumberController.text.trim(),
          'bio': sanitizedBio,
          'country': selectedCountry,
          'state': selectedState,
          'city': selectedCity,
          'bg_color_code': _colorCode,
          'bg_text_color': _colorCode1,
          'button_color_code': _colorCode2,
          'button_text_color': _colorCode3,
          'banner_image_url': _imageUrlBanner,
          'day': _selectedDob?.day,
          'month': _selectedDob?.month,
          'year': _selectedDob?.year,
          'gender': selectedGender,
          'native_language': selectedNativeLanguage,
          'english_level': selectedEnglishLevel,
          'learning_goal': selectedLearningGoal,
          'insta_id': instaIdController.text.trim(),
          'insta_link': instaLinkController.text.trim(),
          'web_template_id': _selectedTemplateId,
          'updated_at': DateTime.now().toIso8601String(),
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
        title: const Text('Reset Profile Details?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to reset your profile details? This will reset your avatar, bio, and settings to defaults. This action cannot be undone.',
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
            child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        _phoneNumberController.clear();
        _bioController.clear();
        instaIdController.clear();
        instaLinkController.clear();
        _selectedDob = null;

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
    final hasLocation = (selectedCountry ?? '').isNotEmpty;
    final locationString = [selectedCountry, selectedState, selectedCity]
        .where((s) => (s ?? '').isNotEmpty)
        .join(', ');

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 1.0, 20.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: theme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Location & Country',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Prominent Selected Country / Location Banner if already chosen
          if (hasLocation)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: theme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: $locationString',
                      style: TextStyle(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Dropdown selector
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
                style: TextStyle(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DarkModeTheme();

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: theme.primaryBackground,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.primaryText,
                size: 20.0,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Edit Profile',
              style: GoogleFonts.outfit(
                color: theme.primaryText,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                        ),
                      )
                    : Text(
                        'Save',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          backgroundColor: theme.primaryBackground,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Column(
                  children: [
                    // Visual Identity: Banner & Profile Photo / Avatar
                    _buildVisualIdentitySection(theme),

                    // Community Guidelines Notice
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.25)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Make your profile welcoming for global language practice mates!',
                                style: GoogleFonts.inter(
                                  color: theme.primaryText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Card 1: 👤 Personal Information
                    _buildCardContainer(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      accentColor: const Color(0xFFFFD700),
                      children: [
                        CustomTextField(
                          width: double.infinity,
                          height: 56.0,
                          controller: _nameController,
                          labelText: 'Your Name *',
                          hintText: 'Enter your full name',
                        ),
                        _buildGenderSection(theme),
                        const SizedBox(height: 14),
                        _buildDobPicker(theme),
                        const SizedBox(height: 14),
                        CustomTextField(
                          width: double.infinity,
                          height: 80.0,
                          controller: _bioController,
                          labelText: 'Bio (Optional)',
                          hintText: 'Share a little about yourself, hobbies, and why you love learning English...',
                          maxLines: 3,
                        ),
                      ],
                    ),

                    // Card 2: 🎓 English Learning Journey
                    _buildCardContainer(
                      title: 'English Learning Profile',
                      icon: Icons.school_outlined,
                      accentColor: const Color(0xFF6366F1),
                      children: [
                        _buildNativeLanguageSection(theme),
                        const SizedBox(height: 14),
                        _buildEnglishLevelSection(theme),
                        const SizedBox(height: 14),
                        _buildLearningGoalSection(theme),
                        const SizedBox(height: 14),
                        _buildLevelThemeCard(),
                      ],
                    ),

                    // Card 3: 📱 Social, Contact & Privacy
                    _buildCardContainer(
                      title: 'Social & Privacy',
                      icon: Icons.security_rounded,
                      accentColor: const Color(0xFF10B981),
                      children: [
                        // Privacy toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.alternate),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline, color: theme.primaryText, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Private Account',
                                  style: TextStyle(
                                    color: theme.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _isPrivate,
                                onChanged: (v) => safeSetState(() => _isPrivate = v),
                                activeThumbColor: const Color(0xFFFFD700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Instagram Section
                        CustomTextField(
                          width: double.infinity,
                          height: 56.0,
                          controller: instaIdController,
                          labelText: 'Instagram ID (Optional)',
                          hintText: '@username',
                        ),
                        CustomTextField(
                          width: double.infinity,
                          height: 56.0,
                          controller: instaLinkController,
                          labelText: 'Instagram Profile Link (Optional)',
                          hintText: 'https://instagram.com/yourprofile',
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🎓', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Private Mentor Access: Your Instagram handle is private and used by Sovereign Mentors to celebrate your Day 90 Graduation and issue your verified Certificate.',
                                  style: GoogleFonts.inter(
                                    color: theme.primaryText.withValues(alpha: 0.85),
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Optional Phone Number
                        CustomPhoneTextField(
                          width: double.infinity,
                          height: 56.0,
                          controller: _phoneNumberController,
                          labelText: 'Phone Number (Optional)',
                          hintText: 'Enter your phone number',
                          initialCountryCode: 'IN',
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.primaryBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.alternate),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.shield_outlined, color: theme.secondaryText, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '100% Confidential: Phone numbers are never exposed publicly.',
                                  style: GoogleFonts.inter(
                                    color: theme.secondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Location Picker
                        buildBeautifulLocationPicker(),
                      ],
                    ),

                    // Card 4: ⚠️ Danger Zone
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset Profile Settings',
                                    style: GoogleFonts.inter(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Reset bio, avatar, and settings to factory defaults.',
                                    style: GoogleFonts.inter(
                                      color: theme.secondaryText,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _isLoading ? null : _deleteProfile,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Big Save Profile Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProfile,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20),
                          label: Text(
                            _isLoading ? 'Saving Changes...' : 'Save Profile Changes',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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

  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final theme = DarkModeTheme();
    final effectiveAccent = accentColor ?? const Color(0xFFFFD700);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveAccent.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: effectiveAccent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: theme.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVisualIdentitySection(DarkModeTheme theme) {
    return Stack(
      children: [
        // Banner Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: AspectRatio(
              aspectRatio: 2.2,
              child: _selectedImageBytesBanner != null
                  ? Image.memory(
                      _selectedImageBytesBanner!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: _imageUrlBanner ?? 'https://picsum.photos/seed/463/600',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.secondaryBackground,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFF1E293B),
                        child: const Center(
                          child: Icon(Icons.landscape_rounded, color: Colors.white24, size: 40),
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Banner Edit / Delete Buttons
        Positioned(
          right: 28,
          bottom: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((_imageUrlBanner != null && _imageUrlBanner!.isNotEmpty) || _selectedImageBytesBanner != null)
                GestureDetector(
                  onTap: _isLoading ? null : () => safeSetState(() {
                    _imageUrlBanner = null;
                    _selectedImageBytesBanner = null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 16),
                  ),
                ),
              GestureDetector(
                onTap: (_isLoading || _isCompressingBanner) ? null : _selectImageBanner,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: _isCompressingBanner
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 16),
                ),
              ),
            ],
          ),
        ),

        // Centered Avatar & Studio Buttons
        Padding(
          padding: const EdgeInsets.only(top: 85),
          child: Center(
            child: Column(
              children: [
                // Avatar with gold border
                GestureDetector(
                  onTap: (_isLoading || _isCompressingProfile) ? null : _selectImage,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipOval(
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
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => VectorAvatarWidget(
                                    config: _avatarConfig,
                                    size: 100,
                                  ),
                                )
                              : VectorAvatarWidget(
                                  config: _avatarConfig,
                                  size: 100,
                                )),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 3 Quick-Action Buttons: Photo, Avatar Studio, Explore
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Photo button
                    InkWell(
                      onTap: (_isLoading || _isCompressingProfile) ? null : _selectImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white70),
                            const SizedBox(width: 5),
                            Text(
                              'Photo',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Avatar Studio Button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VectorAvatarStudioPage(
                              initialConfig: _avatarConfig,
                              onAvatarSaved: (newCfg) {
                                safeSetState(() {
                                  _avatarConfig = newCfg;
                                  _imageUrl = null;
                                  _selectedImageBytes = null;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎨', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(
                              'Avatar Studio',
                              style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Explore Network Avatars
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvatarNetworkExplorerPage(
                              onAvatarSelected: (selectedAvatarUrl) {
                                safeSetState(() {
                                  _imageUrl = selectedAvatarUrl;
                                  _selectedImageBytes = null;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🌐', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(
                              'Explore',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSection(DarkModeTheme theme) {
    final options = ['Not specified', 'Male', 'Female', 'Other'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: TextStyle(color: theme.secondaryText, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selectedGender == opt;
              return ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (val) {
                  if (val) safeSetState(() => selectedGender = opt);
                },
                selectedColor: const Color(0xFFFFD700),
                backgroundColor: theme.primaryBackground,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.black : theme.primaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFFD700) : theme.alternate,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDobPicker(DarkModeTheme theme) {
    final dobFormatted = _selectedDob != null
        ? DateFormat('dd MMMM yyyy').format(_selectedDob!)
        : 'Select your birthday';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final initialDate = _selectedDob ?? DateTime(now.year - 18, 1, 1);
          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1920),
            lastDate: now,
            builder: (context, child) {
              return Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFFFD700),
                    onPrimary: Colors.black,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0F172A)),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            safeSetState(() => _selectedDob = picked);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: TextStyle(color: theme.secondaryText, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dobFormatted,
                      style: TextStyle(
                        color: _selectedDob != null ? theme.primaryText : theme.secondaryText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.calendar_month_rounded, color: theme.secondaryText, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNativeLanguageSection(DarkModeTheme theme) {
    final languages = [
      {'name': 'Malayalam', 'native': 'മലയാളം'},
      {'name': 'Tamil', 'native': 'தமிழ்'},
      {'name': 'Hindi', 'native': 'हिन्दी'},
      {'name': 'Arabic', 'native': 'العربية'},
      {'name': 'Bengali', 'native': 'বাংলা'},
      {'name': 'Telugu', 'native': 'తెలుగు'},
      {'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
      {'name': 'Urdu', 'native': 'اردو'},
      {'name': 'English', 'native': 'English'},
      {'name': 'Spanish', 'native': 'Español'},
      {'name': 'French', 'native': 'Français'},
      {'name': 'Other', 'native': 'Other'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Native Language (Mother Tongue)',
            style: TextStyle(color: theme.secondaryText, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.alternate),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: theme.secondaryBackground,
                value: languages.any((l) => l['name'] == selectedNativeLanguage)
                    ? selectedNativeLanguage
                    : 'Malayalam',
                items: languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang['name'],
                    child: Row(
                      children: [
                        Text(
                          lang['name']!,
                          style: GoogleFonts.inter(
                            color: theme.primaryText,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${lang['native']})',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) safeSetState(() => selectedNativeLanguage = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnglishLevelSection(DarkModeTheme theme) {
    final levels = [
      'Beginner (A1-A2)',
      'Intermediate (B1-B2)',
      'Advanced (C1-C2)',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current English Level',
            style: TextStyle(color: theme.secondaryText, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: levels.map((lvl) {
              final isSelected = selectedEnglishLevel == lvl;
              return ChoiceChip(
                label: Text(lvl),
                selected: isSelected,
                onSelected: (val) {
                  if (val) safeSetState(() => selectedEnglishLevel = lvl);
                },
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: theme.primaryBackground,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.white : theme.primaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6366F1) : theme.alternate,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningGoalSection(DarkModeTheme theme) {
    final goals = [
      'Daily Fluency & Speaking',
      'IELTS / TOEFL Prep',
      'Job Interview & Career',
      'Public Speaking & Confidence',
      'Grammar & Vocabulary',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Goal',
            style: TextStyle(color: theme.secondaryText, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goals.map((g) {
              final isSelected = selectedLearningGoal == g;
              return ChoiceChip(
                label: Text(g),
                selected: isSelected,
                onSelected: (val) {
                  if (val) safeSetState(() => selectedLearningGoal = g);
                },
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: theme.primaryBackground,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.white : theme.primaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6366F1) : theme.alternate,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelThemeCard() {
    final stage = LearningMilestoneStage.getStageForDay(_learningDay);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stage.bgColor.withValues(alpha: 0.9),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stage.buttonColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: stage.buttonColor.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stage.buttonColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: stage.buttonColor, width: 1.2),
                ),
                child: Text(
                  stage.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: stage.buttonColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DAY $_learningDay OF 90',
                            style: GoogleFonts.outfit(
                              color: stage.buttonTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stage.fluencyTier,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.stageName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your profile theme is earned through your English learning journey. As you progress through the 90 days, your profile colors, buttons, and companion avatar transform dynamically.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Swatches Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE PALETTE SWATCHES',
                      style: GoogleFonts.outfit(
                        color: stage.buttonColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 11, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          'Level Locked',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildThemeSwatch('Background', stage.bgColor, stage.bgHex),
                    const SizedBox(width: 8),
                    _buildThemeSwatch('Text', stage.textColor, stage.textHex),
                    const SizedBox(width: 8),
                    _buildThemeSwatch('Button', stage.buttonColor, stage.buttonHex),
                    const SizedBox(width: 8),
                    _buildThemeSwatch('Btn Text', stage.buttonTextColor, stage.buttonTextHex),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Milestone Gates Row
          Text(
            'MAJOR MILESTONE THEMES',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMilestoneBadge(1, 'Genesis', '🌱', _learningDay >= 1),
                _buildMilestoneBadge(21, 'Habit Gate', '🎯', _learningDay >= 21),
                _buildMilestoneBadge(30, 'Silver Knight', '⚔️', _learningDay >= 30),
                _buildMilestoneBadge(60, 'Gold Sovereign', '👑', _learningDay >= 60),
                _buildMilestoneBadge(90, 'Celestial Void', '🌌', _learningDay >= 90),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Dashboard Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (_currentUserId != null) {
                  Learning60DayDashboardSheet.show(context, userId: _currentUserId!);
                }
              },
              icon: const Icon(Icons.insights_rounded, size: 15, color: Color(0xFFFFFC00)),
              label: Text(
                'Open 90-Day Learning Dashboard',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFFC00),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFFC00)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwatch(String label, Color color, String hex) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              hex,
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneBadge(int day, String title, String emoji, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFFFFC00).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            'Day $day',
            style: GoogleFonts.outfit(
              color: isUnlocked ? const Color(0xFFFFFC00) : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 11,
            color: isUnlocked ? const Color(0xFFFFFC00) : Colors.white38,
          ),
        ],
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

