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
  Color? _selectedColor;
  Color? _selectedColor1;
  Color? _selectedColor2;
  Color? _selectedColor3;

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
  final TextEditingController _PhoneNumberController = TextEditingController();
  final TextEditingController _BioController = TextEditingController();
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
          .from('hide_profile')
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

      await SupaFlow.client.from('hide_profile').upsert({
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
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileResponse != null) {
        safeSetState(() {
          _nameController.text = profileResponse['display_name'] ?? '';
          _imageUrlBanner = profileResponse['banner_image_url'] ?? '';
          _imageUrl = profileResponse['profile_image_url'] ?? '';
          _shopNameController.text = profileResponse['shop_name'] ?? '';
          _PhoneNumberController.text = profileResponse['phone_no'] ?? '';
          _BioController.text = (profileResponse['bio'] ?? '').isEmpty
              ? 'Welcome to my profile!'
              : profileResponse['bio'];
          selectedCountry = profileResponse['country'] ?? '';
          selectedState = profileResponse['state'] ?? '';
          selectedCity = profileResponse['city'] ?? '';

          String? dob = profileResponse['dob'];
          if (dob != null && dob.contains('-')) {
            var parts = dob.split('-');
            if (parts.length == 3) {
              _yearController.text = parts[0];
              _monthController.text = parts[1];
              _dayController.text = parts[2];
            }
          }

          instaIdController.text = profileResponse['insta_id'] ?? '';
          instaLinkController.text = profileResponse['insta_link'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<String?> _uploadImage(Uint8List bytes, String fileName) async {
    final user = SupaFlow.client.auth.currentUser;
    if (user == null) return null;

    final path = 'profiles/${user.id}/$fileName';
    try {
      await SupaFlow.client.storage.from('profiles').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return SupaFlow.client.storage.from('profiles').getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  String filterContent(String text) {
    List<String> badWords = ['badword1', 'badword2']; // Example
    String filtered = text;
    for (var word in badWords) {
      filtered = filtered.replaceAll(
          RegExp(word, caseSensitive: false), '*' * word.length);
    }
    return filtered;
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

    safeSetState(() => _isLoading = true);

    try {
      String? profileUrl = _imageUrl;
      if (_selectedImageBytes != null) {
        profileUrl = await _uploadImage(_selectedImageBytes!, 'profile.jpg');
      }

      String? bannerUrl = _imageUrlBanner;
      if (_selectedImageBytesBanner != null) {
        bannerUrl =
            await _uploadImage(_selectedImageBytesBanner!, 'banner.jpg');
      }

      String dob = '';
      if (_dayController.text.isNotEmpty &&
          _monthController.text.isNotEmpty &&
          _yearController.text.isNotEmpty) {
        dob =
            '${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}';
      }

      final profileData = {
        'user_id': user.id,
        'display_name': filterContent(_nameController.text),
        'phone_no': _PhoneNumberController.text,
        'profile_image_url': profileUrl,
        'banner_image_url': bannerUrl,
        'bio': filterContent(_BioController.text),
        'country': selectedCountry,
        'state': selectedState,
        'city': selectedCity,
        'dob': dob.isEmpty ? null : dob,
        'insta_id': instaIdController.text,
        'insta_link': instaLinkController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupaFlow.client.from('user_profiles').upsert(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
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
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
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
            leading: IconButton(
              icon: const Icon(fluent.FluentIcons.back, color: Colors.yellow),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile Creation',
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
                            : (_imageUrlBanner != null
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
                                    Icon(fluent.FluentIcons.edit,
                                        size: 14),
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
                                border:
                                    Border.all(color: Colors.yellow, width: 3),
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
                            controller: _PhoneNumberController,
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
                            color: Colors.yellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.yellow.withOpacity(0.3)),
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
                          controller: _BioController,
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
                                  fluent.ButtonState.all(Colors.yellow),
                              padding: fluent.ButtonState.all(
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
