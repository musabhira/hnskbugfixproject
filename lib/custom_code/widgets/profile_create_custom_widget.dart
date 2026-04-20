import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

// Begin custom action code

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
          _imageUrlBanner = profileResponse['banner_image_url'] ?? '';
          _imageUrl = profileResponse['profile_image_url'] ?? '';
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
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  Future<Uint8List> compressImage(Uint8List bytes) async {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    img.Image resized = img.copyResize(image, width: 800);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
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
      } catch (e) {
        debugPrint('Compression error: $e');
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
      } catch (e) {
        debugPrint('Compression error: $e');
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
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (_shopNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shop name')),
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
        // Set default theme colors if not present
        'bg_color_code': '#000000',
        'bg_text_color': '#FFFFFF',
        'button_color_code': '#FFFF00',
        'button_text_color': '#000000',
      };

      await SupaFlow.client.from('profile').upsert(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePageWidget(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
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

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: Colors.black,
        child: fluent.ScaffoldPage(
          padding: EdgeInsets.zero,
          header: fluent.PageHeader(
            leading: fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.back, color: Colors.yellow),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Complete Your Profile',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Container(
            color: Colors.black,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
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
                            : (_imageUrlBanner != null &&
                                    _imageUrlBanner!.isNotEmpty
                                ? Image.network(
                                    _imageUrlBanner!,
                                    width: double.infinity,
                                    height: 160.0,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[800],
                                    height: 160,
                                    width: double.infinity,
                                    child: const Center(
                                      child: Icon(
                                          fluent.FluentIcons.image_pixel,
                                          color: Colors.white30,
                                          size: 40),
                                    ),
                                  )),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: fluent.Button(
                          onPressed: (_isLoading || _isCompressingBanner)
                              ? null
                              : _selectImageBanner,
                          child: _isCompressingBanner
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: fluent.ProgressRing(strokeWidth: 2.0),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(fluent.FluentIcons.edit, size: 14),
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
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[900],
                                backgroundImage: _selectedImageBytes != null
                                    ? MemoryImage(_selectedImageBytes!)
                                        as ImageProvider
                                    : (_imageUrl != null &&
                                            _imageUrl!.isNotEmpty
                                        ? NetworkImage(_imageUrl!)
                                        : null),
                                child: _isCompressingProfile
                                    ? const fluent.ProgressRing()
                                    : (_selectedImageBytes == null &&
                                            (_imageUrl == null ||
                                                _imageUrl!.isEmpty)
                                        ? const Icon(fluent.FluentIcons.contact,
                                            size: 50, color: Colors.white)
                                        : null),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(fluent.FluentIcons.camera,
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
                        fluent.InfoLabel(
                          label: 'Shop Name (Unique)',
                          child: fluent.TextBox(
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
                        const SizedBox(height: 15),
                        Text(
                          'Personal Details',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        const SizedBox(height: 15),
                        fluent.InfoLabel(
                          label: 'Display Name',
                          child: fluent.TextBox(
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
                        fluent.InfoLabel(
                          label: 'Phone Number',
                          child: fluent.TextBox(
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
                              const Icon(fluent.FluentIcons.lock,
                                  color: Colors.yellow, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Hide Phone Number & Call features from profile',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                              fluent.ToggleSwitch(
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
                              child: fluent.TextBox(
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
                              child: fluent.TextBox(
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
                              child: fluent.TextBox(
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
                        fluent.TextBox(
                          controller: instaIdController,
                          placeholder: 'Instagram ID',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(fluent.FluentIcons.profile_search,
                                size: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        fluent.TextBox(
                          controller: instaLinkController,
                          placeholder: 'Instagram Profile Link',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(fluent.FluentIcons.link, size: 16),
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
                        fluent.TextBox(
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
                          child: fluent.FilledButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: fluent.ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.yellow),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 16)),
                            ),
                            child: _isLoading
                                ? const fluent.ProgressRing(
                                    activeColor: Colors.black)
                                : Text(
                                    'GO TO HOME',
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
    );
  }
}
