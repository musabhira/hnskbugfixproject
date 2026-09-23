import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/custom_code/widgets/custom_phone_text_field.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

/// 🌟 7-Step Duolingo-Style Personalized Onboarding with Background Music
///
/// Features:
/// 1. 7 Clean & Simple Steps:
///    - Step 1: Mother Tongue / Native Language
///    - Step 2: Target Language (English live, Arabic/German/Hindi/French islands preview)
///    - Step 3: Discovery Source (Instagram, Friends, YouTube, Play Store)
///    - Step 4: Current Proficiency Level
///    - Step 5: Motivation & Primary Goal
///    - Step 6: Daily Learning Routine (5m, 10m [25 words/wk], 15m)
///    - Step 7: Habit Lock-in, Name, Phone & Avatar setup
/// 2. Gentle Ambient Background Audio with Mute/Unmute toggle
/// 3. Zero-Breakage Database schema mappings for future Language Islands
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
  static const int _totalSteps = 7;
  bool _isLoading = false;

  // Background Audio
  AudioPlayer? _bgmPlayer;
  bool _isAudioMuted = false;
  bool _isAudioPlaying = false;

  // Controllers for Final Step
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Media
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Onboarding Answers State
  String _selectedNativeLanguage = 'Malayalam';
  String _selectedTargetLanguage = 'English';
  String _selectedReferralSource = 'Instagram / Reels';
  String _selectedEnglishLevel = 'Intermediate (B1-B2)';
  String _selectedLearningGoal = 'Daily Fluency & Speaking';
  int _selectedDailyGoalMins = 10;

  // --- Step 1: Native Languages ---
  final List<Map<String, String>> _nativeLanguages = [
    {'code': 'Malayalam', 'name': 'മലയാളം (Malayalam)', 'flag': '🌴'},
    {'code': 'Tamil', 'name': 'தமிழ் (Tamil)', 'flag': '🦚'},
    {'code': 'Hindi', 'name': 'हिन्दी (Hindi)', 'flag': '🇮🇳'},
    {'code': 'Kannada', 'name': 'ಕನ್ನಡ (Kannada)', 'flag': '🌸'},
    {'code': 'Telugu', 'name': 'తెలుగు (Telugu)', 'flag': '🌺'},
    {'code': 'English', 'name': 'English', 'flag': '🌐'},
    {'code': 'Arabic', 'name': 'العربية (Arabic)', 'flag': '🇸🇦'},
    {'code': 'Bengali', 'name': 'বাংলা (Bengali)', 'flag': '🌊'},
    {'code': 'Other', 'name': 'Other Language', 'flag': '✨'},
  ];

  // --- Step 2: Target Languages (Future Islands) ---
  final List<Map<String, dynamic>> _targetLanguages = [
    {
      'code': 'English',
      'title': 'English 🇬🇧',
      'desc': 'Pocket World Island, live voice calls, citadel battles & AI coach active!',
      'isAvailable': true,
      'badge': 'READY TO EXPLORE',
      'color': Color(0xFFFFD700),
    },
    {
      'code': 'Arabic',
      'title': 'Arabic 🇸🇦 (العربية)',
      'desc': 'Arabic Island & Desert Citadel realm in active preparation.',
      'isAvailable': false,
      'badge': '🚀 COMING SOON',
      'color': Color(0xFF10B981),
    },
    {
      'code': 'German',
      'title': 'German 🇩🇪 (Deutsch)',
      'desc': 'Alpine Fortress Island and European vocabulary tracks arriving soon.',
      'isAvailable': false,
      'badge': '🚀 COMING SOON',
      'color': Color(0xFF6366F1),
    },
    {
      'code': 'Hindi',
      'title': 'Hindi 🇮🇳 (हिन्दी)',
      'desc': 'Heritage Island & spoken fluency missions launching next.',
      'isAvailable': false,
      'badge': '🚀 COMING SOON',
      'color': Color(0xFFF59E0B),
    },
    {
      'code': 'French',
      'title': 'French 🇫🇷 (Français)',
      'desc': 'Riviera Island spoken coaching coming in future updates.',
      'isAvailable': false,
      'badge': '🚀 COMING SOON',
      'color': Color(0xFFEC4899),
    },
  ];

  // --- Step 3: Referral / Discovery Source ---
  final List<Map<String, dynamic>> _referralSources = [
    {
      'title': 'Instagram / Reels',
      'icon': Icons.camera_alt_outlined,
      'desc': 'Saw a reel, viral post, or creator spotlight',
    },
    {
      'title': 'Friends & Family',
      'icon': Icons.people_outline_rounded,
      'desc': 'Recommended by someone practicing English',
    },
    {
      'title': 'YouTube Shorts & Videos',
      'icon': Icons.play_circle_outline_rounded,
      'desc': 'Found tutorials, reviews, or spoken drills',
    },
    {
      'title': 'Google Play Store / Search',
      'icon': Icons.search_rounded,
      'desc': 'Searched for English speaking & practice apps',
    },
    {
      'title': 'College & Campus Community',
      'icon': Icons.school_outlined,
      'desc': 'Recommended in study group or campus club',
    },
  ];

  // --- Step 4: Current Proficiency ---
  final List<Map<String, String>> _englishLevels = [
    {
      'title': 'Beginner (Starting Scratch)',
      'desc': 'I know a few basic words, but cannot form sentences confidently.',
      'emoji': '🌱',
    },
    {
      'title': 'Basic Conversations (A2)',
      'desc': 'I understand basic sentences, but hesitate and pause when replying.',
      'emoji': '💬',
    },
    {
      'title': 'Intermediate (B1-B2)',
      'desc': 'I can converse casually, looking for natural speed and fluency.',
      'emoji': '🗣️',
    },
    {
      'title': 'Advanced & Polished (C1)',
      'desc': 'Fluent speaker aiming for executive vocabulary, debates & accent coach.',
      'emoji': '👑',
    },
  ];

  // --- Step 5: Learning Goals ---
  final List<Map<String, dynamic>> _learningGoals = [
    {
      'title': 'Daily Fluency & Speaking',
      'desc': 'Chat with peers, friends, and strangers without fear',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'title': 'Job Interview & Career',
      'desc': 'Excel in corporate discussions, MNC rounds, and presentations',
      'icon': Icons.work_outline_rounded,
    },
    {
      'title': 'Travel & Global Friends',
      'desc': 'Communicate seamlessly while traveling abroad or meeting travelers',
      'icon': Icons.flight_takeoff_rounded,
    },
    {
      'title': 'IELTS / OET Exam Prep',
      'desc': 'Structured practice for band score speaking and grammar drills',
      'icon': Icons.school_outlined,
    },
  ];

  // --- Step 6: Daily Routine Goals ---
  final List<Map<String, dynamic>> _routineGoals = [
    {
      'mins': 5,
      'title': 'Casual',
      'time': '5 mins / day',
      'target': '15 words in your first week',
      'badge': 'LOW PRESSURE',
      'icon': Icons.flash_on_rounded,
      'color': Color(0xFF38BDF8),
    },
    {
      'mins': 10,
      'title': 'Regular',
      'time': '10 mins / day',
      'target': '25 words in your first week! 🎯',
      'badge': 'RECOMMENDED',
      'icon': Icons.local_fire_department_rounded,
      'color': Color(0xFFFFD700),
    },
    {
      'mins': 15,
      'title': 'Serious',
      'time': '15 mins / day',
      'target': '40 words in your first week',
      'badge': 'FAST-TRACK',
      'icon': Icons.rocket_launch_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromAuth();
    _initBgm();
  }

  Future<void> _initBgm() async {
    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(0.18); // Soft, gentle ambient volume
      // Soft gentle lo-fi ambient chime loop
      await _bgmPlayer!.play(UrlSource(
        'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
      ));
      if (mounted) {
        setState(() => _isAudioPlaying = true);
      }
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
    _bgmPlayer?.stop();
    _bgmPlayer?.dispose();
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
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Step 7: Validate Name & Phone before finishing
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your name to complete setup');
        return;
      }
      final phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.replaceAll(RegExp(r'\D'), '').length < 7) {
        _showError('Please enter your phone number to assist and support your account');
        return;
      }
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

      // 3. Upsert profile safely with Multi-Language Island default values
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

      // 4. Cache state and Onboarding answers locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_profile_$userId', jsonEncode(profilePayload));
      await prefs.setString('profile_cache_$userId', jsonEncode(profilePayload));
      await prefs.setBool('profile_setup_completed_$userId', true);
      await prefs.setBool('pm_onboarding_seen_$userId', true);

      // Save onboarding answers for future Island expansion
      await prefs.setString('pm_native_language_$userId', _selectedNativeLanguage);
      await prefs.setString('pm_target_language_$userId', _selectedTargetLanguage);
      await prefs.setString('pm_referral_source_$userId', _selectedReferralSource);
      await prefs.setString('pm_english_level_$userId', _selectedEnglishLevel);
      await prefs.setString('pm_learning_goal_$userId', _selectedLearningGoal);
      await prefs.setInt('pm_daily_goal_mins_$userId', _selectedDailyGoalMins);
      await prefs.setString('pm_active_island_$userId', 'english');

      // Stop BGM gracefully before entering HomePage
      _bgmPlayer?.stop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome $name! Day 1 Streak Started! 🔥 25 Words First-Week Goal Active.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    _buildStep1NativeLanguage(),
                    _buildStep2TargetLanguage(),
                    _buildStep3DiscoverySource(),
                    _buildStep4EnglishLevel(),
                    _buildStep5LearningGoal(),
                    _buildStep6DailyRoutine(),
                    _buildStep7HabitAndProfile(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
              // Ambient Audio Toggle Button
              IconButton(
                tooltip: _isAudioMuted ? 'Unmute Ambient Sound' : 'Mute Sound',
                icon: Icon(
                  _isAudioMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: _isAudioMuted ? Colors.white38 : const Color(0xFFFFD700),
                  size: 22,
                ),
                onPressed: _toggleAudioMute,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Segmented Progress Bar (Duolingo style)
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 2.5),
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
                              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
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
  // STEP 1: What language do you speak? (Mother Tongue)
  // ==========================================
  Widget _buildStep1NativeLanguage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'What language do you speak? 🗣️',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We will customize definitions and explanations for you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 22),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.1,
            ),
            itemCount: _nativeLanguages.length,
            itemBuilder: (context, index) {
              final item = _nativeLanguages[index];
              final isSelected = _selectedNativeLanguage == item['code'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedNativeLanguage = item['code']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFD700).withValues(alpha: 0.16)
                        : const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white.withValues(alpha: 0.12),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(item['flag']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['name']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: What would you like to learn? (Target Language & Islands)
  // ==========================================
  Widget _buildStep2TargetLanguage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'What would you like to learn? 🌍',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore language islands in Pocket World. Switch anytime!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 20),
          ..._targetLanguages.map((lang) {
            final isAvailable = lang['isAvailable'] as bool;
            final isSelected = _selectedTargetLanguage == lang['code'];
            final color = lang['color'] as Color;

            return GestureDetector(
              onTap: () {
                if (isAvailable) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTargetLanguage = lang['code'] as String);
                } else {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${lang['title']} Island is currently in preparation and will open soon! 🏝️',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: color,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.16)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                lang['title'] as String,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  lang['badge'] as String,
                                  style: GoogleFonts.inter(
                                    color: isAvailable
                                        ? const Color(0xFF10B981)
                                        : Colors.white60,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lang['desc'] as String,
                            style: GoogleFonts.inter(
                              color: Colors.white60,
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
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 3: How did you hear about Pocket Mates?
  // ==========================================
  Widget _buildStep3DiscoverySource() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'How did you hear about us? 🔍',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Help us know how language learners discover Pocket Mates.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 20),
          ..._referralSources.map((source) {
            final isSelected = _selectedReferralSource == source['title'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedReferralSource = source['title'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD700).withValues(alpha: 0.14)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        source['icon'] as IconData,
                        color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source['title'] as String,
                            style: GoogleFonts.outfit(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            source['desc'] as String,
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 4: How much English do you know?
  // ==========================================
  Widget _buildStep4EnglishLevel() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'How much English do you know? 📈',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We will calibrate daily missions and battle challenges to your level.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 20),
          ..._englishLevels.map((lvl) {
            final isSelected = _selectedEnglishLevel == lvl['title'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedEnglishLevel = lvl['title']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFD700).withValues(alpha: 0.14)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lvl['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lvl['title']!,
                            style: GoogleFonts.outfit(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            lvl['desc']!,
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 5: Why are you learning English?
  // ==========================================
  Widget _buildStep5LearningGoal() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Why are you learning English? 🎯',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We will match you with mates sharing the same motivation.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 20),
          ..._learningGoals.map((g) {
            final isSelected = _selectedLearningGoal == g['title'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedLearningGoal = g['title'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1).withValues(alpha: 0.18)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        g['icon'] as IconData,
                        color: isSelected ? const Color(0xFF818CF8) : Colors.white70,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g['title'] as String,
                            style: GoogleFonts.outfit(
                              color: isSelected ? const Color(0xFF818CF8) : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            g['desc'] as String,
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? const Color(0xFF818CF8) : Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 6: Daily Learning Routine & Habit Commitment
  // ==========================================
  Widget _buildStep6DailyRoutine() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'What is your daily learning goal? ⏱️',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Small daily habits yield massive conversational fluency.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 20),
          ..._routineGoals.map((r) {
            final isSelected = _selectedDailyGoalMins == r['mins'];
            final color = r['color'] as Color;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDailyGoalMins = r['mins'] as int);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.16)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(r['icon'] as IconData, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${r['title']} • ${r['time']}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  r['badge'] as String,
                                  style: GoogleFonts.inter(
                                    color: color,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r['target'] as String,
                            style: GoogleFonts.inter(
                              color: isSelected ? color : Colors.white70,
                              fontSize: 12.5,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.normal,
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
        ],
      ),
    );
  }

  // ==========================================
  // STEP 7: Habit Lock-in & Profile Identity Completion
  // ==========================================
  Widget _buildStep7HabitAndProfile() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Motivation Habit Card (Duolingo style)
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
                        '25 words in your first week!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Practice daily to make it an automatic habit. Widgets will cheer you on right from your screen!',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Profile Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 14,
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
                                size: 50,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Photo (Optional)',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.5),
          ),
          const SizedBox(height: 16),

          // Name Field
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Name *',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
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
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.5),
              decoration: InputDecoration(
                hintText: 'Enter your name or nickname',
                hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13.5),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Phone Field
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Phone Number (For Account Support & Recovery) *',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          CustomPhoneTextField(
            width: double.infinity,
            height: 52.0,
            controller: _phoneController,
            labelText: 'Phone Number *',
            hintText: 'Enter phone number',
            initialCountryCode: 'IN',
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 13),
              const SizedBox(width: 5),
              Text(
                '100% Private • Exclusively for support & account recovery',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
              ),
            ],
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
