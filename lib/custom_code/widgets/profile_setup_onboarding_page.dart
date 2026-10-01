import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_phone_text_field.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';


/// 🌟 Clean Step-by-Step Profile Creation Flow
///
/// Features:
/// 1. 3 Clean, Step-by-Step Profile Steps (No repeated language questions):
///    - Step 1: Your Name & Identity (Name input with encouragement)
///    - Step 2: Phone Number (CustomPhoneTextField for support & recovery)
///    - Step 3: Profile Photo / Avatar & Launch (Upload/avatar selection, Day 1 streak activation)
/// 2. Matches the first onboarding aesthetic with clean progress bar & animations
/// 3. Preserves gentle ambient audio, Supabase profile upsert, and smooth navigation to HomePage
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
  static const int _totalSteps = 4;
  bool _isLoading = false;
  bool _isRedirectingHome = false;

  // Birthday & Age for Smart Matching
  DateTime? _selectedDob;

  // Background Audio
  AudioPlayer? _bgmPlayer;
  bool _isAudioMuted = false;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Media & Preset Avatars
  Uint8List? _selectedImageBytes;
  String? _selectedPresetAvatar;
  final ImagePicker _picker = ImagePicker();

  final List<String> _presetAvatars = [
    '🦁',
    '🦊',
    '🐼',
    '🐯',
    '🚀',
    '🌟',
    '🎧',
    '🦉',
  ];

  // Retrieved user preferences from welcome onboarding
  String _selectedNativeLanguage = PocketLanguageService.currentLanguage;
  String _selectedTargetLanguage = 'English';
  String _selectedReferralSource = 'Instagram / Reels';
  String _selectedEnglishLevel = 'Intermediate (B1-B2)';
  String _selectedLearningGoal = 'Daily Fluency & Speaking';
  int _selectedDailyGoalMins = 10;

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndPrefill();
    _initBgm();
  }

  Future<void> _initBgm() async {
    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(0.18);
      await _bgmPlayer!.play(UrlSource(
        'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
      ));
    } catch (e) {
      debugPrint('Non-critical BGM initialization notice: $e');
    }
  }

  void _toggleAudioMute() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAudioMuted = !_isAudioMuted;
    });
    if (_bgmPlayer != null) {
      _bgmPlayer!.setVolume(_isAudioMuted ? 0.0 : 0.18);
    }
  }

  Future<void> _loadPreferencesAndPrefill() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedNativeLanguage =
          prefs.getString('pm_native_language') ?? PocketLanguageService.currentLanguage;
      _selectedTargetLanguage =
          prefs.getString('pm_target_language') ?? 'English';
      _selectedReferralSource =
          prefs.getString('pm_referral_source') ?? 'Instagram / Reels';
      _selectedEnglishLevel =
          prefs.getString('pm_english_level') ?? 'Intermediate (B1-B2)';
      _selectedLearningGoal =
          prefs.getString('pm_learning_goal') ?? 'Daily Fluency & Speaking';
      _selectedDailyGoalMins = prefs.getInt('pm_daily_goal_mins') ?? 10;

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

        final hasExistingProfile = existing != null &&
            (existing['name']?.toString().trim().isNotEmpty ?? false) &&
            existing['name'] != 'Pocket Mate';

        final justCreated =
            prefs.getBool('just_created_account_${user.id}') ?? false;

        // If user already has an existing profile and didn't just perform a fresh Sign Up:
        if (hasExistingProfile && !justCreated && mounted) {
          setState(() {
            _isRedirectingHome = true;
          });
          await prefs.setBool('profile_setup_completed_${user.id}', true);
          await prefs.setBool('profile_setup_prompted_${user.id}', true);
          await _bgmPlayer?.stop();
          await PocketGameAudioService.instance.stop();
          await Future.delayed(const Duration(milliseconds: 350));
          if (mounted) {
            context.goNamedAuth(HomePageWidget.routeName, context.mounted);
            return;
          }

        }

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
            final d = (existing['day'] as num?)?.toInt();
            final m = (existing['month'] as num?)?.toInt();
            final y = (existing['year'] as num?)?.toInt();
            if (d != null && m != null && y != null && y > 1900 && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
              try {
                _selectedDob = DateTime(y, m, d);
              } catch (_) {}
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
    _bgmPlayer?.stop();
    _bgmPlayer?.dispose();
    PocketGameAudioService.instance.stop();
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();
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
          _selectedPresetAvatar = null;
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
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleNextStep() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      // Step 1: Validate Name
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your name to proceed');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 1) {
      // Step 2: Validate Date of Birth & Age
      if (_selectedDob == null) {
        _showError('Please select your Date of Birth to match with peers');
        return;
      }
      final age = DateTime.now().year - _selectedDob!.year;
      if (age < 8 || age > 100) {
        _showError('Please select a valid birth date');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 2) {
      // Step 3: Validate Phone Number
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.replaceAll(RegExp(r'\D'), '').length < 7) {
        _showError(
            'Please enter your phone number to assist & support your account');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Step 4: Final Launch & Complete Profile
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
      final cleanSlug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      // 1. Guarantee public.users record
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

      if (_selectedDob != null) {
        profilePayload['day'] = _selectedDob!.day;
        profilePayload['month'] = _selectedDob!.month;
        profilePayload['year'] = _selectedDob!.year;
      }

      if (uploadedImageUrl != null) {
        profilePayload['profile_image_url'] = uploadedImageUrl;
      }

      await _supabase.from('profile').upsert(
            profilePayload,
            onConflict: 'user_id',
          );

      // 4. Cache state and flags locally so onboarding is never shown again
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_profile_$userId', jsonEncode(profilePayload));
      await prefs.setString(
          'profile_cache_$userId', jsonEncode(profilePayload));
      await prefs.setBool('profile_setup_completed_$userId', true);
      await prefs.setBool('profile_setup_prompted_$userId', true);
      await prefs.setBool('pm_onboarding_seen_$userId', true);
      await prefs.setBool('pm_onboarding_completed', true);

      // Save onboarding answers
      await PocketLanguageService.setNativeLanguage(_selectedNativeLanguage);
      await prefs.setString(
          'pm_native_language_$userId', _selectedNativeLanguage);
      await prefs.setString(
          'pm_target_language_$userId', _selectedTargetLanguage);
      await prefs.setString(
          'pm_referral_source_$userId', _selectedReferralSource);
      await prefs.setString('pm_english_level_$userId', _selectedEnglishLevel);
      await prefs.setString('pm_learning_goal_$userId', _selectedLearningGoal);
      if (_selectedDob != null) {
        await prefs.setString('pm_dob_$userId', _selectedDob!.toIso8601String());
        final calculatedAge = DateTime.now().year - _selectedDob!.year;
        await prefs.setInt('pm_age_$userId', calculatedAge);
      }
      await prefs.setInt('pm_daily_goal_mins_$userId', _selectedDailyGoalMins);
      await prefs.setString('pm_active_island_$userId', 'english');

      // Stop BGM gracefully before entering HomePage
      _bgmPlayer?.stop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome $name! Day 1 Streak Started! 🔥',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        await _bgmPlayer?.stop();
        await PocketGameAudioService.instance.stop();

        // Smooth navigation to HomePage
        if (!mounted) return;
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
    if (_isRedirectingHome) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F111A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏡', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Welcome back!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Loading your learning home...',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                    _buildStep1Name(),
                    _buildStep2Dob(),
                    _buildStep3Phone(),
                    _buildStep4PhotoAndReady(),
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

  // ==========================================
  // TOP HEADER: Back + Step Counter + Progress + Audio Toggle
  // ==========================================
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                )
              else
                const SizedBox(width: 44),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: _isAudioMuted ? 'Unmute Sound' : 'Mute Sound',
                icon: Icon(
                  _isAudioMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color:
                      _isAudioMuted ? Colors.white38 : const Color(0xFFFFD700),
                  size: 22,
                ),
                onPressed: _toggleAudioMute,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segmented Progress Bar
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 3),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isCurrent
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.14)),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 1: What should we call you? (Name)
  // ==========================================
  Widget _buildStep1Name() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  width: 2),
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'What should we call you?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your practice partners and AI coaches will greet you with this name.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Name or Nickname *',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'e.g. Rahul, Sneha, Alex',
                hintStyle:
                    GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFFFD700),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 6),
              Text(
                'Visible to your spoken practice partners in rooms',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: Date of Birth & Age (Peer Vibe Matching)
  // ==========================================
  Widget _buildStep2Dob() {
    final int? calculatedAge = _selectedDob != null
        ? (DateTime.now().year - _selectedDob!.year)
        : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
              border: Border.all(
                color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('🎂', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'When is your birthday?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Used to calculate your age so we can pair you with peers in your age vibe in Pocket Talk ✨',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Main Birthday Selector Card
          InkWell(
            onTap: _pickDateOfBirth,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E2230),
                    Color(0xFF131722),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _selectedDob != null
                      ? const Color(0xFFFFD700)
                      : Colors.white.withValues(alpha: 0.18),
                  width: _selectedDob != null ? 1.8 : 1.0,
                ),
                boxShadow: _selectedDob != null
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: _selectedDob != null
                            ? const Color(0xFFFFD700)
                            : Colors.white54,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDob != null
                            ? '${_selectedDob!.day.toString().padLeft(2, '0')} / ${_selectedDob!.month.toString().padLeft(2, '0')} / ${_selectedDob!.year}'
                            : 'Select Date of Birth',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedDob != null
                          ? const Color(0xFF10B981).withValues(alpha: 0.18)
                          : const Color(0xFFFFD700).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedDob != null
                            ? const Color(0xFF10B981).withValues(alpha: 0.5)
                            : const Color(0xFFFFD700).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      _selectedDob != null
                          ? '🎉 Age: $calculatedAge Years Old'
                          : '👉 Tap here to select your birth date',
                      style: GoogleFonts.outfit(
                        color: _selectedDob != null
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFFD700),
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Peer Matching Guarantee Note
          if (_selectedDob != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Smart Age Matching active! You’ll be paired with peers around ${math.max(16, (calculatedAge ?? 20) - 3)}–${(calculatedAge ?? 20) + 4} years old for maximum conversation chemistry.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Quick Age Category helper chips
            Text(
              'Or tap your age bracket for quick setup:',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildAgeQuickChip(label: '18–21 (College)', year: 2004),
                _buildAgeQuickChip(label: '22–26 (Young Pro)', year: 2001),
                _buildAgeQuickChip(label: '27–34 (Mid Career)', year: 1996),
                _buildAgeQuickChip(label: '35+ (Experienced)', year: 1988),
              ],
            ),
          ],

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.privacy_tip_outlined, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(
                'Your exact birth date is kept private and never shared publicly',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeQuickChip({required String label, required int year}) {
    final isSelected = _selectedDob?.year == year;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedDob = DateTime(year, 6, 15);
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(2002, 6, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1925),
      lastDate: DateTime(now.year - 6, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF18181B),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF18181B)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  // ==========================================
  // STEP 3: Phone Number (Support & Recovery)
  // ==========================================
  Widget _buildStep3Phone() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                  width: 2),
            ),
            child: const Center(
              child: Text('📱', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Add your phone number',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Used exclusively for account assistance, quick recovery, and verified community badge.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Phone Number *',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomPhoneTextField(
            width: double.infinity,
            height: 52.0,
            controller: _phoneController,
            labelText: 'Phone Number *',
            hintText: 'Enter phone number',
            initialCountryCode: 'IN',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(
                '100% Private • Exclusively for support & account security',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 4: Profile Photo / Avatar & Launch
  // ==========================================
  Widget _buildStep4PhotoAndReady() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Habit Motivational Streak Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.16),
                  const Color(0xFF10B981).withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day 1 Streak Ready! 🚀',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '25 words target set for your first week. Your learning journey is locked in!',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.35,
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
            'Choose your profile photo',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload a photo or pick an avatar (optional).',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 20),

          // Photo Upload or Emoji Avatar
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 16,
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
                            child: Center(
                              child: _selectedPresetAvatar != null
                                  ? Text(
                                      _selectedPresetAvatar!,
                                      style: const TextStyle(fontSize: 48),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      size: 54,
                                      color: Colors.white54,
                                    ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
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
            'Tap circle to upload from Gallery',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Preset Avatars Row
          Text(
            'Or pick an avatar:',
            style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _presetAvatars.map((avatar) {
              final isSelected = _selectedPresetAvatar == avatar &&
                  _selectedImageBytes == null;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedPresetAvatar = avatar;
                    _selectedImageBytes = null;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                        : const Color(0xFF1E2230),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected ? const Color(0xFFFFD700) : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 22)),
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

  // ==========================================
  // BOTTOM ACTION BAR: Continue / Start Button
  // ==========================================
  Widget _buildBottomActionBar() {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                      isLastStep
                          ? 'Start Exploring & Day 1 Streak 🚀'
                          : 'Continue',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (!isLastStep) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.black, size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
