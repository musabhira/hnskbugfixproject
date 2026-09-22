import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_phone_text_field.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

class ProfileSetupOnboardingPage extends StatefulWidget {
  final double width;
  final double height;

  const ProfileSetupOnboardingPage({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  State<ProfileSetupOnboardingPage> createState() =>
      _ProfileSetupOnboardingPageState();
}

class _ProfileSetupOnboardingPageState
    extends State<ProfileSetupOnboardingPage> {
  final _supabase = SupaFlow.client;
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Media
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Learning preferences
  String _selectedNativeLanguage = 'Malayalam';
  String _selectedEnglishLevel = 'Intermediate (B1-B2)';
  String _selectedLearningGoal = 'Daily Fluency & Speaking';

  final List<String> _nativeLanguages = [
    'Malayalam',
    'Tamil',
    'Hindi',
    'Kannada',
    'Telugu',
    'Bengali',
    'Marathi',
    'Urdu',
    'Arabic',
    'Other',
  ];

  final List<Map<String, String>> _englishLevels = [
    {
      'title': 'Beginner (A1-A2)',
      'desc': 'I know basic words but struggle to form full sentences.',
    },
    {
      'title': 'Intermediate (B1-B2)',
      'desc': 'I can hold conversations but want natural fluency and confidence.',
    },
    {
      'title': 'Advanced (C1-C2)',
      'desc': 'Fluent speaker aiming for professional mastery and accent polish.',
    },
  ];

  final List<Map<String, dynamic>> _learningGoals = [
    {
      'title': 'Daily Fluency & Speaking',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'title': 'Job Interview & Career',
      'icon': Icons.work_outline_rounded,
    },
    {
      'title': 'IELTS / OET Exam Prep',
      'icon': Icons.school_outlined,
    },
    {
      'title': 'Travel & Global Friends',
      'icon': Icons.flight_takeoff_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromAuth();
  }

  Future<void> _prefillFromAuth() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final emailPrefix = (user.email ?? '').split('@').first;
        if (emailPrefix.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = emailPrefix;
        }

        final existing = await _supabase
            .from('profile')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (existing != null && mounted) {
          setState(() {
            if ((existing['name']?.toString().isNotEmpty ?? false) &&
                existing['name'] != 'Pocket Mate') {
              _nameController.text = existing['name'];
            }
            if (existing['phone_no']?.toString().isNotEmpty ?? false) {
              _phoneController.text = existing['phone_no'];
            }
            if (existing['native_language']?.toString().isNotEmpty ?? false) {
              _selectedNativeLanguage = existing['native_language'];
            }
            if (existing['english_level']?.toString().isNotEmpty ?? false) {
              _selectedEnglishLevel = existing['english_level'];
            }
            if (existing['learning_goal']?.toString().isNotEmpty ?? false) {
              _selectedLearningGoal = existing['learning_goal'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error prefilling profile: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      Uint8List bytes;
      if (kIsWeb) {
        bytes = await picked.readAsBytes();
      } else {
        bytes = await io.File(picked.path).readAsBytes();
      }

      if (mounted) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleNextStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your name to continue');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.replaceAll(RegExp(r'\D'), '').length < 7) {
        _showError('Please enter your phone number to assist and support your account');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfileAndComplete();
    }
  }

  Future<void> _saveProfileAndComplete() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showError('Please login to complete setup');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = user.id;
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Pocket Mate';
      final phone = _phoneController.text.trim();
      final cleanSlug =
          name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      // 1. Guarantee public.users has this user
      await _supabase.from('users').upsert({
        'id': userId,
        'email': user.email ?? '',
      }, onConflict: 'id');

      // 2. Upload photo if selected
      String? uploadedImageUrl;
      if (_selectedImageBytes != null) {
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storagePath = '$userId/$fileName';
          await _supabase.storage.from('profile').uploadBinary(
                storagePath,
                _selectedImageBytes!,
                fileOptions: const FileOptions(upsert: true),
              );
          uploadedImageUrl =
              _supabase.storage.from('profile').getPublicUrl(storagePath);
        } catch (storageErr) {
          debugPrint('Error uploading profile picture: $storageErr');
        }
      }

      // 3. Upsert profile safely
      final profilePayload = <String, dynamic>{
        'id': userId,
        'user_id': userId,
        'name': name,
        'phone_no': phone,
        'shop_name': name.toLowerCase().replaceAll(' ', '-'),
        'slug': cleanSlug.isNotEmpty
            ? cleanSlug
            : 'mate${DateTime.now().millisecondsSinceEpoch % 10000}',
        'native_language': _selectedNativeLanguage,
        'english_level': _selectedEnglishLevel,
        'learning_goal': _selectedLearningGoal,
        'learning_day': 1,
        'learning_stage': 1,
        'learning_points': 50,
        'xp': 50,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (uploadedImageUrl != null) {
        profilePayload['profile_image_url'] = uploadedImageUrl;
      }

      await _supabase.from('profile').upsert(
            profilePayload,
            onConflict: 'user_id',
          );

      // 4. Cache state locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_profile_$userId', jsonEncode(profilePayload));
      await prefs.setString(
          'profile_cache_$userId', jsonEncode(profilePayload));
      await prefs.setBool('profile_setup_completed_$userId', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile set up successfully! Welcome to Pocket Mates 🎉',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Smooth navigation to HomePage
        context.goNamedAuth(HomePageWidget.routeName, context.mounted);
      }
    } catch (e, st) {
      debugPrint('Error saving onboarding profile: $e\n$st');
      _showError('Failed to save profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentStep = page),
                  children: [
                    _buildStep1Identity(),
                    _buildStep2PhoneSupport(),
                    _buildStep3LearningGoals(),
                  ],
                ),
              ),
              _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              else
                const SizedBox(width: 40),
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of 3',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == 2 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Identity() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            'Create Your Identity ✨',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let peers recognise you in voice calls and community vibes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Profile Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _selectedImageBytes != null
                        ? Image.memory(
                            _selectedImageBytes!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFF1E2230),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Photo (Optional)',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Name Field
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Name *',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: TextField(
              controller: _nameController,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your full name or nickname',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFFFD700),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF6366F1), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your display name can be changed anytime from Edit Profile.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2PhoneSupport() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Account Help & Support 📞',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Please provide your phone number for account assistance.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Prominent Supportive Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.15),
                  const Color(0xFF0F111A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why is phone number mandatory?',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We use your phone number exclusively to assist and support your account, deliver priority customer service, and enable sovereign mentor guidance. Your number is strictly confidential and never displayed to other users.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Phone Number (Mandatory) *',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Custom Phone Field
          CustomPhoneTextField(
            width: double.infinity,
            height: 56.0,
            controller: _phoneController,
            labelText: 'Phone Number *',
            hintText: 'Enter your phone number',
            initialCountryCode: 'IN',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(
                '100% Private • Used only for support & recovery',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3LearningGoals() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Personalize Learning 🎯',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Choose your goals so we can recommend the best practice partners.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Native Language
          Text(
            'Your Mother Tongue',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedNativeLanguage,
                dropdownColor: const Color(0xFF18181B),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFFFD700)),
                items: _nativeLanguages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(
                      lang,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedNativeLanguage = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Current English Level
          Text(
            'Current English Level',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ..._englishLevels.map((lvl) {
            final isSelected = _selectedEnglishLevel == lvl['title'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedEnglishLevel = lvl['title']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lvl['title']!,
                            style: GoogleFonts.outfit(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lvl['desc']!,
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // Primary Learning Goal
          Text(
            'Primary Goal',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _learningGoals.map((g) {
              final isSelected = _selectedLearningGoal == g['title'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedLearningGoal = g['title']),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                        : const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.white.withValues(alpha: 0.12),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        g['icon'] as IconData,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.white60,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        g['title'] as String,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final isLastStep = _currentStep == 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141622),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep ? 'Save & Start Exploring 🚀' : 'Continue',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (!isLastStep) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.black, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
