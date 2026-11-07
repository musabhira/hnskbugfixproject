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
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_born_address_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_referral_gateway_page.dart';


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
  static const int _totalSteps = 3;
  bool _isLoading = false;
  bool _isRedirectingHome = false;

  // Birthday & Age for Smart Matching (3 columns: Day, Month, Year)
  DateTime? _selectedDob;
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

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
                _selectedDay = d;
                _selectedMonth = m;
                _selectedYear = y;
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
      if (age < 4 || age > 100) {
        _showError('Please select a valid birth date (Ages 4+)');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 2) {
      // Step 3: Validate Phone Number & Complete Profile
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.replaceAll(RegExp(r'\D'), '').length < 7) {
        _showError(
            'Please enter your phone number to assist & support your account');
        return;
      }
      _saveProfileAndComplete();
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
      await prefs.setInt('initial_home_tab_$userId', 3);
      await prefs.setInt('initial_home_tab_global', 3);

      // Save onboarding answers
      await PocketLanguageService.setNativeLanguage(_selectedNativeLanguage,
          userId: userId);
      await prefs.setString(
          'pm_native_language_$userId', _selectedNativeLanguage);
      await prefs.setString(
          'pm_target_language_$userId', _selectedTargetLanguage);
      await prefs.setString(
          'pm_referral_source_$userId', _selectedReferralSource);
      await prefs.setString('pm_english_level_$userId', _selectedEnglishLevel);
      await prefs.setString('pm_learning_goal_$userId', _selectedLearningGoal);
      int calculatedAge = 20;
      if (_selectedDob != null) {
        await prefs.setString('pm_dob_$userId', _selectedDob!.toIso8601String());
        calculatedAge = DateTime.now().year - _selectedDob!.year;
        if (DateTime.now().month < _selectedDob!.month ||
            (DateTime.now().month == _selectedDob!.month &&
                DateTime.now().day < _selectedDob!.day)) {
          calculatedAge--;
        }
        await prefs.setInt('pm_age_$userId', calculatedAge);
      }
      profilePayload['account_type'] = calculatedAge <= 9 ? 'kid' : 'adult';
      await prefs.setInt('pm_daily_goal_mins_$userId', _selectedDailyGoalMins);
      await prefs.setString('pm_active_island_$userId', 'english');

      // Stop BGM gracefully before entering target world
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

        if (!mounted) return;

        // Route strictly based on age:
        // 🧒 Age 1 to 9 -> Kids World (PocketPureKidsHomePage)
        // 🧑 Age 10 to unlimited -> Adult World (No student mode!)
        if (calculatedAge <= 9) {
          // Pure Kids World (Ages 1-9)
          await PocketKidsService.activateKidAccount(
            name: name,
            ageGroup: calculatedAge <= 6 ? '4-6' : '6-8',
            avatar: _selectedPresetAvatar ?? '🦁',
            isParentSwitched: false,
            isPureKid: true,
          );
        } else {
          // Adult Mode (Ages 10 to unlimited - 100% Student Mode Removed)
          await PocketKidsService.activateAdultAccount();
          if (!mounted) return;

          // Check if eligible for one-time post-signup Super Pocketmates VIP offer
          final bool isVip = prefs.getBool('is_vip') == true ||
              prefs.getBool('is_premium') == true ||
              prefs.getBool('has_vip_pass') == true;
          final bool seenVipModal =
              prefs.getBool('post_signup_vip_modal_seen') == true;

          if (!isVip && !seenVipModal) {
            await prefs.setBool('post_signup_vip_modal_seen', true);
            if (mounted) {
              await _showPostSignupVipOffer(context);
            }
          }
        }

        // 🌌 Seamless Transition to Pocket Cosmos Referral Gateway & Born Address Ceremony (പോക്കറ്റ് വേൾഡിലെ ജനന സ്ഥലം)
        if (mounted) {
          await PoketCosmosReferralGatewayPage.launch(
            context,
            userName: name,
            userAvatar: _selectedPresetAvatar ?? '🦁',
            userAge: calculatedAge,
          );
          return;
        }
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

  Future<void> _showPostSignupVipOffer(BuildContext ctx) async {
    await showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👑', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock Super PoketMates',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get unlimited AI conversations, 100% ad-free experience, and fast-track spoken English fluency!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA1A1AA),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    _buildVipFeatureRow('🚫', '100% Zero Ads across the app'),
                    const SizedBox(height: 8),
                    _buildVipFeatureRow('⚡', 'Instant 90-Day Unlocked Binge Mode'),
                    const SizedBox(height: 8),
                    _buildVipFeatureRow('🎙️', 'Unlimited Maya & Alex AI Voice Coaching'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'GET SUPER POKETMATES ⚡',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  'Continue Free',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA1A1AA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVipFeatureRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
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
          // Optional Avatar / Profile Picture Row
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Profile Photo or Avatar (Optional)',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF27272A),
                    border: Border.all(
                      color: _selectedImageBytes != null
                          ? const Color(0xFFFFD700)
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipOval(
                          child: Image.memory(
                            _selectedImageBytes!,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.add_a_photo_rounded,
                              color: Color(0xFFFFD700), size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final avatar = _presetAvatars[index];
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
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                                : const Color(0xFF1E293B),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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

    final currentYear = DateTime.now().year;
    final daysList = List.generate(31, (i) => i + 1);
    final monthsList = [
      {'val': 1, 'name': 'Jan (01)'},
      {'val': 2, 'name': 'Feb (02)'},
      {'val': 3, 'name': 'Mar (03)'},
      {'val': 4, 'name': 'Apr (04)'},
      {'val': 5, 'name': 'May (05)'},
      {'val': 6, 'name': 'Jun (06)'},
      {'val': 7, 'name': 'Jul (07)'},
      {'val': 8, 'name': 'Aug (08)'},
      {'val': 9, 'name': 'Sep (09)'},
      {'val': 10, 'name': 'Oct (10)'},
      {'val': 11, 'name': 'Nov (11)'},
      {'val': 12, 'name': 'Dec (12)'},
    ];
    final yearsList = List.generate(80, (i) => currentYear - 4 - i);

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
            'Select your Day, Month & Year to match you with peers in your age vibe ✨',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // 3 Columns: Day | Month | Year
          Row(
            children: [
              // Column 1: DAY
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAY',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2230),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedDay != null
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                          width: _selectedDay != null ? 1.5 : 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedDay,
                          hint: Text('DD',
                              style: GoogleFonts.outfit(
                                  color: Colors.white38, fontSize: 15)),
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E2230),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFFFD700), size: 18),
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          items: daysList.map((d) {
                            return DropdownMenuItem<int>(
                              value: d,
                              child: Text(d.toString().padLeft(2, '0')),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedDay = val;
                              _updateDobFromComponents();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Column 2: MONTH
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTH',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2230),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedMonth != null
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                          width: _selectedMonth != null ? 1.5 : 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          hint: Text('MM',
                              style: GoogleFonts.outfit(
                                  color: Colors.white38, fontSize: 15)),
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E2230),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFFFD700), size: 18),
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          items: monthsList.map((m) {
                            return DropdownMenuItem<int>(
                              value: m['val'] as int,
                              child: Text(m['name'] as String),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedMonth = val;
                              _updateDobFromComponents();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Column 3: YEAR
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YEAR',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2230),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedYear != null
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                          width: _selectedYear != null ? 1.5 : 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          hint: Text('YYYY',
                              style: GoogleFonts.outfit(
                                  color: Colors.white38, fontSize: 15)),
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E2230),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFFFD700), size: 18),
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          items: yearsList.map((y) {
                            return DropdownMenuItem<int>(
                              value: y,
                              child: Text(y.toString()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedYear = val;
                              _updateDobFromComponents();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Age Confirmation Pill
          if (_selectedDob != null && calculatedAge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Age: $calculatedAge Years Old (Matches peers ${math.max(16, calculatedAge - 3)}–${calculatedAge + 4})',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF34D399),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Select Day, Month and Year to continue',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
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

  void _updateDobFromComponents() {
    final d = _selectedDay ?? 1;
    final m = _selectedMonth ?? 1;
    final y = _selectedYear ?? 2002;
    if (_selectedDay != null && _selectedMonth != null && _selectedYear != null) {
      try {
        final daysInMonth = DateTime(y, m + 1, 0).day;
        final safeDay = d > daysInMonth ? daysInMonth : d;
        _selectedDob = DateTime(y, m, safeDay);
      } catch (_) {
        _selectedDob = DateTime(y, m, 1);
      }
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
