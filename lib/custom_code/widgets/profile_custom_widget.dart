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

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:country_state_city_picker/country_state_city_picker.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

// Begin custom action code

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
  Uint8List? _selectedImageBytes;
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
  bool _isVerified = false;

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

  final List<String> imageAssets = [
    'assets/images/image1.png', // Replace with your actual asset paths
    'assets/images/image2.png',
    'assets/images/image3.png',
    'assets/images/image4.png',
  ];
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadProfileData();
    fetchHideStatus();
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
          _nameController.text = profileResponse['name'] ?? '';
          _imageUrl = profileResponse['profile_image_url'] ?? '';
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _phoneNumberController.text = profileResponse['phone_no'] ?? '';
          _bioController.text = profileResponse['bio'] ?? '';
          selectedCountry = profileResponse['country'] ?? '';
          selectedState = profileResponse['state'] ?? '';
          selectedCity = profileResponse['city'] ?? '';
          _colorCode = profileResponse['bg_color_code'] ?? '';
          _colorCode1 = profileResponse['bg_text_color'] ?? '';
          _colorCode2 = profileResponse['button_color_code'] ?? '';
          _colorCode3 = profileResponse['button_text_color'] ?? '';
          _imageUrlBanner = profileResponse['banner_image_url'] ?? '';
          _dayController.text = profileResponse['day']?.toString() ?? '';
          _monthController.text = profileResponse['month']?.toString() ?? '';
          _yearController.text = profileResponse['year']?.toString() ?? '';
          instaIdController.text = profileResponse['insta_id'] ?? '';
          instaLinkController.text = profileResponse['insta_link'] ?? '';
          _selectedTemplateId = profileResponse['web_template_id'] ?? 'default';
          _isVerified = profileResponse['verified'] ?? false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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

  Future<Uint8List> _compressImage(Uint8List imageBytes,
      {int quality = 85}) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize image if it's too large (optional - keeps clarity but reduces file size)
      // Max width/height of 1920px for good quality while reducing size
      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1920 : null,
          interpolation:
              img.Interpolation.cubic, // Better quality interpolation
        );
      }

      // Compress as JPEG with specified quality (85 = good balance of quality/size)
      List<int> compressedBytes = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageBytes; // Return original if compression fails
    }
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

      // Compress the image
      final compressedBytes = await _compressImage(fileBytes);

      safeSetState(() {
        _selectedImageBytes = compressedBytes;
        _isCompressingProfile = false;
      });
    } catch (e) {
      safeSetState(() {
        _isCompressingProfile = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
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

      // Compress the banner image
      final compressedBytes = await _compressImage(fileBytes, quality: 90);

      safeSetState(() {
        _selectedImageBytesBanner = compressedBytes;
        _isCompressingBanner = false;
      });
    } catch (e) {
      safeSetState(() {
        _isCompressingBanner = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing banner image: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
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

    // Check for images
    if (isValid && (_imageUrl == null && _selectedImageBytes == null)) {
      isValid = false;
      errorMessage = 'Please select a profile image';
    } else if (isValid &&
        (_imageUrlBanner == null && _selectedImageBytesBanner == null)) {
      isValid = false;
      errorMessage = 'Please select a banner image';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: FlutterFlowTheme.of(context).error,
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
        if (_imageUrl != null && _imageUrl!.isNotEmpty) {
          final oldFilePath = Uri.parse(_imageUrl!).pathSegments.last;
          await _supabase.storage
              .from('profile')
              .remove(['profile/$oldFilePath']);
        }

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$_currentUserId.jpg';
        final storagePath = 'profile/$fileName';

        // Upload to nested path
        await _supabase.storage
            .from('profile')
            .uploadBinary(storagePath, _selectedImageBytes!);

        // Get public URL with correct path
        final response =
            _supabase.storage.from('profile').getPublicUrl(storagePath);
        _imageUrl = response;

        _selectedImageBytes = null;
      }
      if (_selectedImageBytesBanner != null) {
        // Remove old image if exists
        if (_imageUrlBanner != null && _imageUrlBanner!.isNotEmpty) {
          final oldFilePath = Uri.parse(_imageUrlBanner!).pathSegments.last;
          await _supabase.storage
              .from('profile_banner')
              .remove(['profile_banner/$oldFilePath']);
        }

        // Create filename with nested folder structure
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$_currentUserId.jpg';
        final storagePath = 'profile_banner/$fileName';

        // Upload to nested path
        await _supabase.storage
            .from('profile_banner')
            .uploadBinary(storagePath, _selectedImageBytesBanner!);

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

      // Update profile data
      final existingProfile = await _supabase
          .from('profile')
          .select()
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (existingProfile != null) {
        // Update profile record
        await _supabase.from('profile').update(
          {
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
          },
        ).eq('user_id', _currentUserId!);
      } else {
        await _supabase.from('profile').insert(
          {
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
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageWidget()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $error'),
            backgroundColor: FlutterFlowTheme.of(context).error,
            duration: const Duration(seconds: 3),
          ),
        );
        debugPrint('Error updating profile: $error');
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

  Widget buildBeautifulLocationPicker() {
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
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 15),

          // Custom implementation showing initial values
          Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
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
                  color: FlutterFlowTheme.of(context).primaryText,
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
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Country display
          if ((selectedCountry ?? '').isNotEmpty)
            _buildLocationTile(
              title: 'Country',
              value: selectedCountry ?? '',
              icon: Icons.flag_outlined,
              color: FlutterFlowTheme.of(context).primary,
            ),

          // State display
          if ((selectedState ?? '').isNotEmpty)
            _buildLocationTile(
              title: 'State/Province',
              value: selectedState ?? '',
              icon: Icons.location_city_outlined,
              color: FlutterFlowTheme.of(context).secondary,
            ),

          // City display
          if ((selectedCity ?? '').isNotEmpty)
            _buildLocationTile(
              title: 'City',
              value: selectedCity ?? '',
              icon: Icons.business_outlined,
              color: FlutterFlowTheme.of(context).tertiary,
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
            color:
                FlutterFlowTheme.of(context).primaryText.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHidden = hideData?['is_hidden'] ?? false;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
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
        backgroundColor: Colors.black,
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
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                fontFamily: 'Poppins',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: _selectedImageBytesBanner != null
                              ? Image.memory(
                                  _selectedImageBytesBanner!,
                                  width: double.infinity,
                                  height: 183.0,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _imageUrlBanner ??
                                      'https://picsum.photos/seed/463/600',
                                  width: double.infinity,
                                  height: 183.0,
                                  fit: BoxFit.cover,
                                ),
                        ),
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
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.grey[200],
                                              backgroundImage:
                                                  _selectedImageBytes != null
                                                      ? MemoryImage(
                                                              _selectedImageBytes!)
                                                          as ImageProvider<
                                                              Object>
                                                      : (_imageUrl != null &&
                                                              _imageUrl!
                                                                  .isNotEmpty
                                                          ? NetworkImage(
                                                                  _imageUrl!)
                                                              as ImageProvider<
                                                                  Object>
                                                          : null),
                                              child: _isCompressingProfile
                                                  ? const CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.yellow),
                                                    )
                                                  : (_selectedImageBytes ==
                                                              null &&
                                                          (_imageUrl == null ||
                                                              _imageUrl!
                                                                  .isEmpty)
                                                      ? const Icon(Icons.person,
                                                          size: 40,
                                                          color: Colors.grey)
                                                      : null),
                                            ),
                                            if (!_isCompressingProfile)
                                              Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.yellow,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                              ),
                                            if (_isCompressingProfile)
                                              Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.yellow,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                              Align(
                                alignment:
                                    const AlignmentDirectional(-0.04, -1.16),
                                child: InkWell(
                                  onTap: (_isLoading || _isCompressingBanner)
                                      ? null
                                      : _selectImageBanner,
                                  child: Container(
                                    width: 128.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: _isCompressingBanner
                                          ? Colors.yellow.withValues(alpha: 0.7)
                                          : Colors.grey[900],
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0.0, 0.0),
                                      child: _isCompressingBanner
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Processing...',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Montserrat',
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'Edit Banner',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Montserrat',
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.yellow
                            .withValues(alpha: 0.2), // less opacity
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Please avoid using inappropriate words in your name, shop name, or description.',
                              style: TextStyle(
                                color: Colors.yellow[
                                    800], // slightly darker text for contrast
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  CustomTextField(
                    width: double.infinity,
                    height: double.infinity,
                    controller: _nameController,
                    hintText: 'Your Name',
                    labelText: 'Your Name',
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          width: double.infinity,
                          height: double.infinity,
                          controller: _shopNameController,
                          hintText: 'Shop Name',
                          labelText: 'Shop Name',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          onPressed: _checkingShopName ? null : _checkShopName,
                          icon: _checkingShopName
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.yellow))
                              : Icon(Icons.check_circle,
                                  color: _isShopNameVerified
                                      ? Colors.green
                                      : Colors.grey),
                          tooltip: 'Verify Availability',
                        ),
                        const Text('Verify',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ])
                    ],
                  ),
                  if (_shopNameMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 8),
                      child: Text(
                        _shopNameMessage!,
                        style: TextStyle(
                            color: _shopNameMessageColor, fontSize: 12),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _phoneNumberController.text.isNotEmpty
                              ? '${_phoneNumberController.text} | Edit phone number'
                              : 'Add a new phone number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  CustomPhoneTextField(
                    width: double.infinity,
                    height: double.infinity,
                    controller: _phoneNumberController,
                    hintText: 'Phone Number',
                    labelText: 'Phone Number',
                    initialCountryCode: 'IN', // Optional: Set India as default
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 2, bottom: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.yellow
                            .withValues(alpha: 0.2), // less opacity
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Hide whatsapp & Phone Number, Hide a Phone call feature',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isHidden,
                            onChanged: (value) => saveHideStatus(value),
                            activeThumbColor: Colors.yellow,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  CustomTextField(
                    width: double.infinity,
                    height: double.infinity,
                    controller: _bioController,
                    hintText: 'Your bio',
                    labelText: 'Your bio',
                    maxLines: 3,
                  ), // Generated code for this Text Widget...
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Date of Birth',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Day TextField
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _dayController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Day',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Month TextField
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _monthController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Month',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Year TextField
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _yearController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Year',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.yellow
                            .withValues(alpha: 0.2), // less opacity
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Want to link your Instagram profile? Drop your Instagram ID here — we’ll use it only to connect with you. Don’t worry, it stays private.',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomTextField(
                    width: double.infinity,
                    height: double.infinity,
                    controller: instaIdController,
                    hintText: 'Instagram ID (Optional)',
                    labelText: 'Your Instagram ID (Optional)',
                  ),
                  CustomTextField(
                    width: double.infinity,
                    height: double.infinity,
                    controller: instaLinkController,
                    hintText: 'Instagram profile Link add (Optional)',
                    labelText: 'Your Instagram profile Link (Optional)',
                  ),

                  if (_isVerified) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Premium Web Templates',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select a premium design for your public website.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildTemplateItem('default', 'Modern Gold',
                                    Icons.dashboard_rounded),
                                _buildTemplateItem(
                                    'neon', 'Cyber Neon', Icons.bolt_rounded),
                                _buildTemplateItem('elite', 'Luxury Elite',
                                    Icons.auto_awesome_rounded),
                                _buildTemplateItem('glass', 'Bubble Glass',
                                    Icons.blur_on_rounded),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.yellow,
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.3),
                          blurRadius: 15.0,
                          spreadRadius: 2.0,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Text(
                          'Live Color Preview',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Mini Profile Card
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _selectedColor ??
                                _convertStringToColor(_colorCode ?? '#FFFFFF'),
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Profile Picture
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: (_selectedColor1 ??
                                        _convertStringToColor(
                                            _colorCode1 ?? '#E0E0E0'))
                                    .withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 35,
                                  color: _selectedColor1 ??
                                      _convertStringToColor(
                                          _colorCode1 ?? '#757575'),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Name
                              Text(
                                'John Doe',
                                style: TextStyle(
                                  color: _selectedColor1 ??
                                      _convertStringToColor(
                                          _colorCode1 ?? '#212121'),
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Email
                              Text(
                                'john.doe@email.com',
                                style: TextStyle(
                                  color: (_selectedColor1 ??
                                          _convertStringToColor(
                                              _colorCode1 ?? '#212121'))
                                      .withValues(alpha: 0.7),
                                  fontSize: 14.0,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Action Button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: _selectedColor2 ??
                                      _convertStringToColor(
                                          _colorCode2 ?? '#2196F3'),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_selectedColor2 ??
                                              _convertStringToColor(
                                                  _colorCode2 ?? '#2196F3'))
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6.0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                child: Center(
                                  child: Text(
                                    'View Profile',
                                    style: TextStyle(
                                      color: _selectedColor3 ??
                                          _convertStringToColor(
                                              _colorCode3 ?? '#FFFFFF'),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Color Info Footer
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildColorInfo('BG', _colorCode ?? '#FFFFFF'),
                              _buildColorInfo('Text', _colorCode1 ?? '#212121'),
                              _buildColorInfo(
                                  'Button', _colorCode2 ?? '#2196F3'),
                              _buildColorInfo(
                                  'Btn Text', _colorCode3 ?? '#FFFFFF'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  ColorPickerWidget(
                    width: double.infinity,
                    height: double.infinity,
                    label: 'Edit background Color',
                    initialColor: _selectedColor,
                    initialColorCode: _colorCode ?? '#111311',
                    onColorSelected: (color, code) {
                      debugPrint('First Color Selected: $color, Code: $code');
                      safeSetState(() {
                        _selectedColor = color;
                        _colorCode = code;
                      });
                    },
                  ),
                  ColorPickerWidget(
                    width: double.infinity,
                    height: double.infinity,
                    label: 'Edit background text Color',
                    initialColor: _selectedColor1,
                    initialColorCode: _colorCode1 ?? '#111311',
                    onColorSelected: (color, code) {
                      debugPrint('First Color Selected: $color, Code: $code');
                      safeSetState(() {
                        _selectedColor1 = color;
                        _colorCode1 = code;
                      });
                    },
                  ),
                  ColorPickerWidget(
                    width: double.infinity,
                    height: double.infinity,
                    label: 'Edit button Color',
                    initialColor: _selectedColor2,
                    initialColorCode: _colorCode2 ?? '#111311',
                    onColorSelected: (color, code) {
                      debugPrint('First Color Selected: $color, Code: $code');
                      safeSetState(() {
                        _selectedColor2 = color;
                        _colorCode2 = code;
                      });
                    },
                  ),
                  ColorPickerWidget(
                    width: double.infinity,
                    height: double.infinity,
                    label: 'Edit botton text Color',
                    // initialColor: _selectedColor3,
                    initialColorCode: _colorCode3 ?? '#111311',
                    onColorSelected: (color, code) {
                      debugPrint('First Color Selected: $color, Code: $code');
                      safeSetState(() {
                        _selectedColor3 = color;
                        _colorCode3 = code;
                      });
                    },
                  ),

                  buildBeautifulLocationPicker(),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.05),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 10.0, 20.0, 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: _isLoading ? null : _saveProfile,
                              text: _nameController.text.isEmpty
                                  ? 'save, Go to Home'
                                  : 'Save',
                              options: FFButtonOptions(
                                width: 270.0,
                                height: 50.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 2.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
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
        ),
      ),
    );
  }

  Widget _buildColorInfo(String label, String colorCode) {
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
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          colorCode.substring(1, 4).toUpperCase(),
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.8),
            fontSize: 9.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateItem(String id, String name, IconData icon) {
    final isSelected = _selectedTemplateId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateId = id),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.yellow : FlutterFlowTheme.of(context).alternate,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white60,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : FlutterFlowTheme.of(context).primaryText,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
