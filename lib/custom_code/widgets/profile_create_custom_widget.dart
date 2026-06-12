import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/main.dart';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Begin custom action code

class _CompressParams {
  final Uint8List imageBytes;
  final int quality;

  _CompressParams(this.imageBytes, this.quality);
}

class ProfileCreateCustomWidget extends StatefulWidget {
  final double width;
  final double height;
  static const String routeName = 'ProfileCreate';
  static const String routePath = '/profile_create';

  const ProfileCreateCustomWidget({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  State<ProfileCreateCustomWidget> createState() =>
      _ProfileCreateCustomWidgetState();
}

class _ProfileCreateCustomWidgetState extends State<ProfileCreateCustomWidget> {
  String? _imageUrl;
  String? _imageUrlBanner;
  Uint8List? _selectedImageBytes;
  Uint8List? _selectedImageBytesBanner;
  bool _isLoading = false;
  bool _isCompressingProfile = false;
  bool _isCompressingBanner = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController instaIdController = TextEditingController();
  final TextEditingController instaLinkController = TextEditingController();

  String selectedCountry = '';
  String selectedState = '';
  String selectedCity = '';
  
  String _businessType = 'product';
  bool _wantsPaymentIntegration = false;

  Map<String, dynamic>? hideData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchHideStatus();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _fetchHideStatus() async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) return;

      final response = await SupaFlow.client
          .from('hide')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      safeSetState(() {
        hideData = response;
      });
    } catch (e) {
      debugPrint('Error fetching hide status: $e');
    }
  }

  Future<void> saveHideStatus(bool isHidden) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) return;

      await SupaFlow.client.from('hide').upsert({
        'user_id': user.id,
        'is_hidden': isHidden,
      });

      _fetchHideStatus();
    } catch (e) {
      debugPrint('Error saving hide status: $e');
    }
  }

  Future<void> _loadProfile() async {
    final user = SupaFlow.client.auth.currentUser;
    if (user == null) return;

    safeSetState(() => _isLoading = true);

    try {
      final profileResponse = await SupaFlow.client
          .from('profile')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileResponse != null) {
        safeSetState(() {
          _nameController.text = profileResponse['name'] ?? '';
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _imageUrlBanner = (profileResponse['banner_image_url']?.toString().isEmpty ?? true) ? null : profileResponse['banner_image_url'];
          _imageUrl = (profileResponse['profile_image_url']?.toString().isEmpty ?? true) ? null : profileResponse['profile_image_url'];
          _phoneNumberController.text = profileResponse['phone_no'] ?? '';
          _bioController.text = profileResponse['bio'] ?? '';
          selectedCountry = profileResponse['country'] ?? '';
          selectedState = profileResponse['state'] ?? '';
          selectedCity = profileResponse['city'] ?? '';

          _dayController.text = profileResponse['day']?.toString() ?? '';
          _monthController.text = profileResponse['month']?.toString() ?? '';
          _yearController.text = profileResponse['year']?.toString() ?? '';

          instaIdController.text = profileResponse['insta_id'] ?? '';
          instaLinkController.text = profileResponse['insta_link'] ?? '';
          
          _businessType = profileResponse['business_type'] ?? 'product';
          _wantsPaymentIntegration = profileResponse['wants_payment_integration'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  static Uint8List _compressImageStatic(_CompressParams params) {
    try {
      img.Image? image = img.decodeImage(params.imageBytes);
      if (image == null) return params.imageBytes;

      img.Image resized = img.copyResize(image, width: 800);
      return Uint8List.fromList(img.encodeJpg(resized, quality: params.quality));
    } catch (e) {
      debugPrint('Error in background image compression: $e');
      return params.imageBytes;
    }
  }

  Future<Uint8List> compressImage(Uint8List bytes) async {
    // Run compression in a background Isolate to keep UI fluid and responsive!
    return await compute(
      _compressImageStatic,
      _CompressParams(bytes, 70),
    );
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      safeSetState(() => _isCompressingProfile = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final compressed = await compressImage(bytes);
        safeSetState(() {
          _selectedImageBytes = compressed;
        });
      } catch (e, stackTrace) {
        debugPrint('=== IMAGE COMPRESS ERROR ===\n$e\n$stackTrace\n===================');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing image: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        safeSetState(() => _isCompressingProfile = false);
      }
    }
  }

  Future<void> _selectImageBanner() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      safeSetState(() => _isCompressingBanner = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final compressed = await compressImage(bytes);
        safeSetState(() {
          _selectedImageBytesBanner = compressed;
        });
      } catch (e, stackTrace) {
        debugPrint('=== BANNER COMPRESS ERROR ===\n$e\n$stackTrace\n===================');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing banner image: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        safeSetState(() => _isCompressingBanner = false);
      }
    }
  }

  Future<String?> _uploadImage(
      Uint8List bytes, String bucket, String fileName) async {
    final user = SupaFlow.client.auth.currentUser;
    if (user == null) return null;

    final path = '${user.id}/$fileName';
    try {
      await SupaFlow.client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return SupaFlow.client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  String filterContent(String text) {
    // Basic sanitization
    return text.trim();
  }

  String _sanitizeSlug(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  }

  Future<void> _saveProfile() async {
    final user = SupaFlow.client.auth.currentUser;
    if (user == null) return;

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_shopNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a shop name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    safeSetState(() => _isLoading = true);

    try {
      String? profileUrl = _imageUrl;
      if (_selectedImageBytes != null) {
        profileUrl =
            await _uploadImage(_selectedImageBytes!, 'profile', 'profile.jpg');
      }

      String? bannerUrl = _imageUrlBanner;
      if (_selectedImageBytesBanner != null) {
        bannerUrl = await _uploadImage(
            _selectedImageBytesBanner!, 'profile_banner', 'banner.jpg');
      }

      final profileData = {
        'id': user.id,
        'user_id': user.id,
        'name': filterContent(_nameController.text),
        'shop_name': filterContent(_shopNameController.text),
        'slug': _sanitizeSlug(_shopNameController.text),
        'phone_no': _phoneNumberController.text,
        'profile_image_url': profileUrl,
        'banner_image_url': bannerUrl,
        'bio': filterContent(_bioController.text),
        'country': selectedCountry,
        'state': selectedState,
        'city': selectedCity,
        'day': int.tryParse(_dayController.text),
        'month': int.tryParse(_monthController.text),
        'year': int.tryParse(_yearController.text),
        'insta_id': instaIdController.text,
        'insta_link': instaLinkController.text,
        'updated_at': DateTime.now().toIso8601String(),
        'eula_accepted': true,
        'business_type': _businessType,
        'wants_payment_integration': _wantsPaymentIntegration,
        // Set default theme colors if not present
        'bg_color_code': '#000000',
        'bg_text_color': '#FFFFFF',
        'button_color_code': '#FFFF00',
        'button_text_color': '#000000',
      };

      await SupaFlow.client.from('profile').upsert(profileData);

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_cache_${user.id}');
        await prefs.remove('cached_profile_${user.id}');
        await prefs.remove('cached_stats_${user.id}');
      } catch (e) {
        debugPrint('Error clearing cache: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        try {
          MyApp.of(context).restartApp();
        } catch (_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePageWidget(),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== PROFILE SAVE ERROR ===\n$e\n$stackTrace\n===================');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  Widget buildBeautifulLocationPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Location',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
          ),
          const SizedBox(height: 12),
          SelectState(
            onCountryChanged: (value) =>
                safeSetState(() => selectedCountry = value),
            onStateChanged: (value) =>
                safeSetState(() => selectedState = value),
            onCityChanged: (value) => safeSetState(() => selectedCity = value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            dropdownColor: Colors.black,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHidden = hideData?['is_hidden'] ?? false;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Material(
          color: Colors.black,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.yellow),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Set Up Your Business',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Container(
            color: Colors.black,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, Entrepreneur! Let\'s build your storefront.',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: _selectedImageBytesBanner != null
                            ? Image.memory(
                                _selectedImageBytesBanner!,
                                width: double.infinity,
                                height: 160.0,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: _imageUrlBanner!,
                                width: double.infinity,
                                height: 160.0,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[800],
                                  height: 160,
                                  width: double.infinity,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2.0),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  height: 160,
                                  width: double.infinity,
                                  child: const Center(
                                    child: Icon(
                                        Icons.image,
                                        color: Colors.white30,
                                        size: 40),
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isCompressingBanner)
                              ? null
                              : _selectImageBanner,
                          child: _isCompressingBanner
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 14),
                                    SizedBox(width: 8),
                                    Text('Edit Banner'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -50),
                      child: GestureDetector(
                        onTap: (_isLoading || _isCompressingProfile)
                            ? null
                            : _selectImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.yellow, width: 3),
                              ),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[900],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipOval(
                                      child: _selectedImageBytes != null
                                          ? Image.memory(
                                              _selectedImageBytes!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : (_imageUrl != null && _imageUrl!.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: _imageUrl!,
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => const Center(
                                                    child: CircularProgressIndicator(strokeWidth: 2.0),
                                                  ),
                                                  errorWidget: (context, url, error) => const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Icon(Icons.person,
                                                  size: 50, color: Colors.white)),
                                    ),
                                    if (_isCompressingProfile)
                                      const CircularProgressIndicator(),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.black, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branding',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 15),
                        InfoLabel(
                          label: 'Shop Name (Unique)',
                          child: TextBox(
                            controller: _shopNameController,
                            placeholder: 'e.g. My Awesome Studio',
                            padding: const EdgeInsets.all(12),
                            decoration: WidgetStateProperty.all(BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            )),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) {
                              // Optional: Add live slug preview
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Business Setup',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text('What is your business type?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => safeSetState(() => _businessType = 'product'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _businessType == 'product' ? Colors.yellow : Colors.grey[900],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('Product', style: TextStyle(color: _businessType == 'product' ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
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
                                    color: _businessType == 'service' ? Colors.yellow : Colors.grey[900],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('Service', style: TextStyle(color: _businessType == 'service' ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payment, color: Colors.yellow, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Enable Payment Integration (Coming soon)',
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ),
                              ToggleSwitch(
                                checked: _wantsPaymentIntegration,
                                onChanged: (v) {
                                  safeSetState(() => _wantsPaymentIntegration = v);
                                  if (v) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment integration will be fully unlocked in a future update!')));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.language, color: Colors.yellow, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Your Shop Website', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Your store will be hosted at:\nhandskillapp.web.app/${_shopNameController.text.isNotEmpty ? _sanitizeSlug(_shopNameController.text) : 'your-shop-name'}', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Contact team for custom domain hosting
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please contact the Pocket Mates Team to establish your custom domain.')));
                                  },
                                  icon: const Icon(Icons.language, color: Colors.yellow),
                                  label: const Text('Get Custom Domain', style: TextStyle(color: Colors.yellow)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.yellow),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Personal Details',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 15),
                        InfoLabel(
                          label: 'Display Name',
                          child: TextBox(
                            controller: _nameController,
                            placeholder: 'How should we call you?',
                            padding: const EdgeInsets.all(12),
                            decoration: WidgetStateProperty.all(BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            )),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),
                        InfoLabel(
                          label: 'Phone Number',
                          child: TextBox(
                            controller: _phoneNumberController,
                            placeholder: '+1 234 567 8900',
                            padding: const EdgeInsets.all(12),
                            decoration: WidgetStateProperty.all(BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            )),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.yellow.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock,
                                  color: Colors.yellow, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Hide Phone Number & Call features from profile',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                              ToggleSwitch(
                                checked: isHidden,
                                onChanged: (v) => saveHideStatus(v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Date of Birth',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextBox(
                                controller: _dayController,
                                placeholder: 'Day',
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextBox(
                                controller: _monthController,
                                placeholder: 'Month',
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextBox(
                                controller: _yearController,
                                placeholder: 'Year',
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Social Links',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextBox(
                          controller: instaIdController,
                          placeholder: 'Instagram ID',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(Icons.person_search,
                                size: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextBox(
                          controller: instaLinkController,
                          placeholder: 'Instagram Profile Link',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(Icons.link, size: 16),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Bio',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextBox(
                          controller: _bioController,
                          placeholder: 'Tell people about yourself...',
                          maxLines: 3,
                          padding: const EdgeInsets.all(12),
                        ),
                        const SizedBox(height: 25),
                        buildBeautifulLocationPicker(),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : Text(
                                    'Launch Storefront',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
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
}

class InfoLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const InfoLabel({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class ToggleSwitch extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final Widget? content;

  const ToggleSwitch({
    super.key,
    required this.checked,
    this.onChanged,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: checked,
          onChanged: onChanged,
          activeColor: Colors.yellow,
        ),
        if (content != null) ...[
          const SizedBox(width: 8),
          Expanded(child: content!),
        ],
      ],
    );
  }
}

class TextBox extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final EdgeInsetsGeometry padding;
  final WidgetStateProperty<Decoration>? decoration;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final TextStyle? placeholderStyle;
  final TextStyle? style;

  const TextBox({
    super.key,
    this.controller,
    this.placeholder,
    this.padding = const EdgeInsets.all(12),
    this.decoration,
    this.maxLines = 1,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.prefix,
    this.onChanged,
    this.placeholderStyle,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration? boxDec;
    if (decoration != null) {
      boxDec = decoration!.resolve({}) as BoxDecoration?;
    }

    return Container(
      decoration: boxDec ?? BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textAlign: textAlign,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: style ?? const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: placeholderStyle ?? const TextStyle(color: Colors.grey),
          prefixIcon: prefix,
          contentPadding: padding,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
