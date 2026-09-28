import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/profile_create_custom_widget.dart';
import 'package:pocket_mates_app/services/push_notification_service.dart';
import 'learning_60day/flame_english_house_game.dart';
import 'learning_60day/pocket_citadel_attack_page.dart';
import 'avatar/vector_avatar_widget.dart';
import 'avatar/vector_avatar_config.dart';
import 'learning_60day/pocket_syllabus_repository.dart';
import 'learning_60day/pocket_generating_syllabus_page.dart';
import 'tools_page.dart';
import '../services/pocket_game_audio_service.dart';

enum WelcomeMode {
  welcome,
  onboarding,
  signIn,
}

class OnboardingRoutineItem {
  String id;
  String title;
  String? description;
  DateTime startTime;
  DateTime endTime;
  Color color;
  bool isCompleted;
  bool hasAlarm;
  bool isStudySlot;

  OnboardingRoutineItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.isCompleted = false,
    this.hasAlarm = false,
    this.isStudySlot = false,
  });

  ScheduleItem toScheduleItem() {
    return ScheduleItem(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color,
      isCompleted: isCompleted,
      source: isStudySlot ? ScheduleSource.aiGenerated : ScheduleSource.manual,
    );
  }
}

class WelcomeOnboardingPage extends StatefulWidget {
  const WelcomeOnboardingPage({super.key});

  @override
  State<WelcomeOnboardingPage> createState() => _WelcomeOnboardingPageState();
}

class _WelcomeOnboardingPageState extends State<WelcomeOnboardingPage>
    with TickerProviderStateMixin {
  WelcomeMode _mode = WelcomeMode.welcome;
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 16;

  // Background Audio
  AudioPlayer? _bgmPlayer;
  bool _isAudioMuted = false;

  // Superhero President Animation
  late AnimationController _heroAnimController;
  late Animation<double> _floatAnimation;

  // 🏡 Interactive House World & Estate Canvas
  late TransformationController _transformationController;
  late AnimationController _ambientController;
  late AnimationController _cloudRevealController;
  late AnimationController _houseRiseController;
  late Animation<double> _houseRiseAnimation;
  bool _isHouseRevealed = false;
  bool _isQuestionSheetMinimized = false;
  bool _hasInitializedTransform = false;
  final String _selectedHousePalette = 'terracotta';

  // Auth & Form State
  bool _isLoading = false;
  String? _loadingMessage;
  String? _errorMessage;
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  final ScrollController _signInScrollController = ScrollController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Feature Flag: Apple Sign-In
  static const bool kEnableAppleSignIn = false;

  // Onboarding Selections
  String _selectedNativeLanguage = 'Malayalam';
  final String _selectedTargetLanguage = 'English';
  String _selectedReferralSource = 'Instagram / Reels';
  String _selectedEnglishLevel = 'Beginner (Starting fresh)';
  String _selectedLearningGoal = 'Daily Fluency & Speaking';
  int _selectedDailyGoalMins = 30;
  String _selectedPlan = 'free'; // 'free' or 'super'
  String _selectedPath = 'scratch'; // 'scratch' or 'placement'

  // ⏰ Schedule & Routine Planner State
  String _selectedOccupation = 'Student';
  String _selectedStudyTimeSlot = 'Custom';
  TimeOfDay? _customStudyTimeOfDay = const TimeOfDay(hour: 20, minute: 0);
  int _routineVariationIndex = 0;
  List<OnboardingRoutineItem> _onboardingRoutineItems = [];

  // Placement Quiz State
  int _quizStep = 0;
  int _quizScore = 0;
  int? _selectedQuizAnswer;

  final List<Map<String, dynamic>> _placementQuestions = [
    {
      'question': 'What is the English word for "വെള്ളം" (Water)?',
      'options': [
        'Paper',
        'Water',
        'Sleep',
        'I do not know / അറിയില്ല',
      ],
      'correct': 1,
    },
    {
      'question': 'How do you say "എനിക്ക് ചായ വേണം" (I want tea)?',
      'options': [
        'Me tea give',
        'I want tea',
        'Tea want I',
        'I do not know / അറിയില്ല',
      ],
      'correct': 1,
    },
    {
      'question': 'Which sentence is grammatically correct?',
      'options': [
        'She go to the office every day.',
        'She goes to the office every day.',
        'She going to the office every day.',
        'I do not know / അറിയില്ല',
      ],
      'correct': 1,
    },
  ];

  // Options Data
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

  final List<Map<String, dynamic>> _referralSources = [
    {
      'title': 'Instagram / Reels',
      'icon': Icons.camera_alt_outlined,
    },
    {
      'title': 'TikTok / Shorts',
      'icon': Icons.play_arrow_rounded,
    },
    {
      'title': 'Friends & Family',
      'icon': Icons.people_outline_rounded,
    },
    {
      'title': 'YouTube',
      'icon': Icons.video_collection_outlined,
    },
    {
      'title': 'Google / App Store',
      'icon': Icons.search_rounded,
    },
  ];

  final List<Map<String, String>> _englishLevels = [
    {
      'title': 'Level 0: Zero Foundation (ABC അറിയില്ല)',
      'subtitle': 'Absolute zero - learn from sounds & voice',
      'emoji': '🌱',
    },
    {
      'title': 'Level 1: Beginner (നിത്യോപയോഗ വാക്കുകൾ)',
      'subtitle': 'Know some words, but cannot speak sentences',
      'emoji': '💬',
    },
    {
      'title': 'Level 2: Elementary (ഏകദേശ ജ്ഞാനം, മടിയുള്ളവർ)',
      'subtitle': 'Know basic phrases, has hesitation & needs speech habits',
      'emoji': '🧭',
    },
    {
      'title': 'Level 3: Middle (Simple conversations / മിഡിൽ)',
      'subtitle': 'Can converse, want fluency & zero hesitation',
      'emoji': '🗣️',
    },
    {
      'title': 'Level 4: Advanced (Workplace & Career)',
      'subtitle': 'Fluent speaker targeting job interviews & leadership',
      'emoji': '💼',
    },
    {
      'title': 'Level 5: Expert (Peak Fluency & Oratory)',
      'subtitle': 'Master eloquence, public speaking & international wit',
      'emoji': '👑',
    },
  ];

  final List<Map<String, dynamic>> _learningGoals = [
    {
      'title': 'Daily Fluency & Real Conversations',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'title': 'Job Interviews & Workplace English',
      'icon': Icons.work_outline_rounded,
    },
    {
      'title': 'Travel & Meeting Global Friends',
      'icon': Icons.flight_takeoff_rounded,
    },
    {
      'title': 'Exam Prep (IELTS, TOEFL, OET)',
      'icon': Icons.school_outlined,
    },
    {
      'title': 'Daily Habit & Confidence',
      'icon': Icons.psychology_outlined,
    },
  ];

  final List<Map<String, dynamic>> _occupations = [
    {'title': 'Student', 'icon': Icons.school_rounded, 'emoji': '🎓'},
    {
      'title': 'Working Professional',
      'icon': Icons.work_rounded,
      'emoji': '💼'
    },
    {'title': 'Homemaker', 'icon': Icons.home_rounded, 'emoji': '🏡'},
    {
      'title': 'Freelancer / Self-Employed',
      'icon': Icons.laptop_mac_rounded,
      'emoji': '💻'
    },
  ];

  final List<Map<String, dynamic>> _studyTimeSlots = [
    {
      'title': 'Morning',
      'range': '7:00 AM - 8:00 AM',
      'startHour': 7,
      'startMin': 0,
      'endHour': 8,
      'endMin': 0,
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Afternoon',
      'range': '2:00 PM - 3:00 PM',
      'startHour': 14,
      'startMin': 0,
      'endHour': 15,
      'endMin': 0,
      'icon': Icons.light_mode_rounded,
      'color': Color(0xFF06B6D4),
    },
    {
      'title': 'Evening',
      'range': '8:00 PM - 9:00 PM',
      'startHour': 20,
      'startMin': 0,
      'endHour': 21,
      'endMin': 0,
      'icon': Icons.nights_stay_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Night',
      'range': '10:00 PM - 11:00 PM',
      'startHour': 22,
      'startMin': 0,
      'endHour': 23,
      'endMin': 0,
      'icon': Icons.bedtime_rounded,
      'color': Color(0xFF818CF8),
    },
  ];

  final List<Map<String, dynamic>> _dailyCommitments = [
    {
      'minutes': 30,
      'label': '30 Minutes / day',
      'desc': 'Quick bite-sized daily conversational sprint',
      'badge': 'RECOMMENDED',
      'badgeColor': Color(0xFF10B981),
      'icon': Icons.bolt_rounded,
    },
    {
      'minutes': 45,
      'label': '45 Minutes / day',
      'desc': 'Steady learning pace with voice practice',
      'badge': 'BALANCED',
      'badgeColor': Color(0xFF38BDF8),
      'icon': Icons.timer_outlined,
    },
    {
      'minutes': 60,
      'label': '1 Hour / day',
      'desc': 'Accelerated fluency & daily coffee table discussions',
      'badge': 'INTENSIVE',
      'badgeColor': Color(0xFFFACC15),
      'icon': Icons.workspace_premium_rounded,
    },
    {
      'minutes': 120,
      'label': '2 Hours / day',
      'desc': 'Rapid mastery: mock interviews, debates & peer practice',
      'badge': 'DEDICATED',
      'badgeColor': Color(0xFFA855F7),
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'minutes': 180,
      'label': '3 Hours / day',
      'desc': 'Full immersion for exams & international relocations',
      'badge': 'IMMERSION',
      'badgeColor': Color(0xFFEC4899),
      'icon': Icons.stars_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initHeroAnimation();
    _initBgm();
    _initHouseWorld();
    _generateOnboardingRoutine();
    _emailFocusNode.addListener(_handleFieldFocus);
    _passwordFocusNode.addListener(_handleFieldFocus);
  }

  void _generateOnboardingRoutine() {
    final now = DateTime.now();
    DateTime makeTime(int hour, int min) =>
        DateTime(now.year, now.month, now.day, hour, min);

    // Determine study slot start and end times
    int studyStartHour = 20;
    int studyStartMin = 0;

    if (_customStudyTimeOfDay != null) {
      studyStartHour = _customStudyTimeOfDay!.hour;
      studyStartMin = _customStudyTimeOfDay!.minute;
    } else {
      final slot = _studyTimeSlots.firstWhere(
        (s) => _selectedStudyTimeSlot.startsWith(s['title'] as String),
        orElse: () => _studyTimeSlots[2],
      );
      studyStartHour = slot['startHour'] as int;
      studyStartMin = slot['startMin'] as int;
    }

    final studyStartDT = makeTime(studyStartHour, studyStartMin);
    final studyEndDT =
        studyStartDT.add(Duration(minutes: _selectedDailyGoalMins));

    // Study slot (Alarm ALWAYS ON by default as requested!)
    final studyItem = OnboardingRoutineItem(
      id: 'onboarding_study_slot',
      title: 'English Speaking & Practice 🗣️',
      description:
          'Daily speaking sprint & voice coffee table with peers (${_selectedDailyGoalMins}m)',
      startTime: studyStartDT,
      endTime: studyEndDT,
      color: const Color(0xFF10B981),
      isStudySlot: true,
      hasAlarm: true, // Default ON
    );

    final List<OnboardingRoutineItem> items = [];
    final varIdx = _routineVariationIndex % 3;

    if (_selectedOccupation == 'Student') {
      if (varIdx == 0) {
        items.addAll([
          OnboardingRoutineItem(
            id: 'routine_wake',
            title: 'Wake Up & Fresh Start 🌅',
            description: 'Morning stretch, freshen up & glass of water',
            startTime: makeTime(6, 30),
            endTime: makeTime(7, 15),
            color: const Color(0xFF38BDF8),
          ),
          OnboardingRoutineItem(
            id: 'routine_breakfast',
            title: 'Bath & Energized Breakfast 🍳',
            description: 'Shower, healthy breakfast & daily packing',
            startTime: makeTime(7, 15),
            endTime: makeTime(8, 0),
            color: const Color(0xFFF59E0B),
          ),
          OnboardingRoutineItem(
            id: 'routine_classes',
            title: 'School / College Classes 📚',
            description:
                'Core lectures, notes, lab work & active participation',
            startTime: makeTime(8, 30),
            endTime: makeTime(16, 0),
            color: const Color(0xFF818CF8),
          ),
          OnboardingRoutineItem(
            id: 'routine_play',
            title: 'Sports, Play & Refreshment ⚽',
            description:
                'Outdoor play, evening snack, tea & unwind with friends',
            startTime: makeTime(16, 30),
            endTime: makeTime(18, 0),
            color: const Color(0xFF10B981),
          ),
          OnboardingRoutineItem(
            id: 'routine_homework',
            title: 'Self-Study & Academic Revision 📝',
            description: 'Homework assignments, exam prep & concept reading',
            startTime: makeTime(18, 30),
            endTime: makeTime(20, 0),
            color: const Color(0xFF6366F1),
          ),
          studyItem,
          OnboardingRoutineItem(
            id: 'routine_dinner',
            title: 'Dinner & Family Time 🍲',
            description: 'Wholesome dinner, family chats & decompressing',
            startTime: makeTime(21, 15),
            endTime: makeTime(22, 15),
            color: const Color(0xFFA855F7),
          ),
          OnboardingRoutineItem(
            id: 'routine_sleep',
            title: 'Night Sleep & Recovery 🌙',
            description:
                'No screens, restful 8 hours of sleep for a fresh brain',
            startTime: makeTime(22, 45),
            endTime: makeTime(6, 30),
            color: const Color(0xFF64748B),
          ),
        ]);
      } else if (varIdx == 1) {
        items.addAll([
          OnboardingRoutineItem(
            id: 'routine_wake',
            title: 'Early Rise & Morning Workout 🏃',
            description: 'Jogging, hydration & revitalizing shower',
            startTime: makeTime(6, 0),
            endTime: makeTime(7, 0),
            color: const Color(0xFFF97316),
          ),
          OnboardingRoutineItem(
            id: 'routine_breakfast',
            title: 'Healthy Breakfast & News ☕',
            description: 'Nutritious meal, check daily timetable',
            startTime: makeTime(7, 15),
            endTime: makeTime(8, 0),
            color: const Color(0xFFF59E0B),
          ),
          OnboardingRoutineItem(
            id: 'routine_classes',
            title: 'College Lectures & Group Projects 🔬',
            description: 'Academic modules, group discussions & coursework',
            startTime: makeTime(8, 30),
            endTime: makeTime(15, 30),
            color: const Color(0xFF6366F1),
          ),
          OnboardingRoutineItem(
            id: 'routine_play',
            title: 'Unwind & Walk / Games 🏸',
            description: 'Campus grounds walk, badminton & evening chai',
            startTime: makeTime(16, 0),
            endTime: makeTime(17, 30),
            color: const Color(0xFF06B6D4),
          ),
          studyItem,
          OnboardingRoutineItem(
            id: 'routine_homework',
            title: 'Project Submission & Coding Practice 💻',
            description: 'Online labs, revision & preparing for exams',
            startTime: makeTime(20, 15),
            endTime: makeTime(21, 30),
            color: const Color(0xFF8B5CF6),
          ),
          OnboardingRoutineItem(
            id: 'routine_dinner',
            title: 'Dinner & Music 🍽️',
            description: 'Warm dinner & relaxing playlist',
            startTime: makeTime(21, 30),
            endTime: makeTime(22, 15),
            color: const Color(0xFFEC4899),
          ),
          OnboardingRoutineItem(
            id: 'routine_sleep',
            title: 'Night Sleep & Rest 🌙',
            description: 'Peaceful bedtime recharge',
            startTime: makeTime(22, 30),
            endTime: makeTime(6, 0),
            color: const Color(0xFF64748B),
          ),
        ]);
      } else {
        items.addAll([
          OnboardingRoutineItem(
            id: 'routine_wake',
            title: 'Morning Awakening & Chai ☕',
            description: 'Quiet mindful start, fresh breeze & meditation',
            startTime: makeTime(6, 45),
            endTime: makeTime(7, 30),
            color: const Color(0xFFF59E0B),
          ),
          OnboardingRoutineItem(
            id: 'routine_breakfast',
            title: 'Bath, Grooming & Breakfast 🥞',
            description: 'Dress up, wholesome breakfast & travel to campus',
            startTime: makeTime(7, 30),
            endTime: makeTime(8, 30),
            color: const Color(0xFF38BDF8),
          ),
          OnboardingRoutineItem(
            id: 'routine_classes',
            title: 'University Classes & Library Study 📖',
            description: 'Reference reading, workshops & seminar sessions',
            startTime: makeTime(9, 0),
            endTime: makeTime(16, 30),
            color: const Color(0xFF3B82F6),
          ),
          OnboardingRoutineItem(
            id: 'routine_play',
            title: 'Evening Relax & Hobby Time 🎸',
            description: 'Listen to podcast, campus hangout & coffee',
            startTime: makeTime(17, 0),
            endTime: makeTime(18, 30),
            color: const Color(0xFF10B981),
          ),
          studyItem,
          OnboardingRoutineItem(
            id: 'routine_dinner',
            title: 'Family Dinner & Evening Walk 🌙',
            description: 'Nutritious dinner, quick stroll & day recap',
            startTime: makeTime(21, 0),
            endTime: makeTime(22, 0),
            color: const Color(0xFFA855F7),
          ),
          OnboardingRoutineItem(
            id: 'routine_sleep',
            title: 'Deep Sleep & Recovery 😴',
            description: 'Sleep for peak mental focus tomorrow',
            startTime: makeTime(22, 30),
            endTime: makeTime(6, 45),
            color: const Color(0xFF64748B),
          ),
        ]);
      }
    } else if (_selectedOccupation == 'Working Professional') {
      if (varIdx == 0) {
        items.addAll([
          OnboardingRoutineItem(
            id: 'routine_wake',
            title: 'Wake Up & Fresh Start 🌅',
            description: 'Hydrate, morning stretch & light breathing',
            startTime: makeTime(6, 30),
            endTime: makeTime(7, 15),
            color: const Color(0xFF38BDF8),
          ),
          OnboardingRoutineItem(
            id: 'routine_breakfast',
            title: 'Bath & Energized Breakfast ☕',
            description: 'Warm shower, healthy breakfast & commute prep',
            startTime: makeTime(7, 15),
            endTime: makeTime(8, 15),
            color: const Color(0xFFF59E0B),
          ),
          OnboardingRoutineItem(
            id: 'routine_work_morn',
            title: 'Work Sprint & Team Standup 💼',
            description:
                'High-focus work tasks, project deliverables & meetings',
            startTime: makeTime(9, 0),
            endTime: makeTime(13, 0),
            color: const Color(0xFF3B82F6),
          ),
          OnboardingRoutineItem(
            id: 'routine_lunch',
            title: 'Lunch Break & Mindful Walk 🥗',
            description: 'Nutritious lunch, step away from screens & fresh air',
            startTime: makeTime(13, 0),
            endTime: makeTime(14, 0),
            color: const Color(0xFF10B981),
          ),
          OnboardingRoutineItem(
            id: 'routine_work_aft',
            title: 'Afternoon Execution & Wrap-Up 📊',
            description: 'Client communication, emails & finalizing goals',
            startTime: makeTime(14, 0),
            endTime: makeTime(18, 0),
            color: const Color(0xFF6366F1),
          ),
          OnboardingRoutineItem(
            id: 'routine_play',
            title: 'Commute & Evening Unwind 🎧',
            description: 'Listen to favorite podcast, workout or gym session',
            startTime: makeTime(18, 30),
            endTime: makeTime(19, 45),
            color: const Color(0xFFF97316),
          ),
          studyItem,
          OnboardingRoutineItem(
            id: 'routine_dinner',
            title: 'Dinner & Family Time 🍽️',
            description: 'Decompress over dinner, casual talks with loved ones',
            startTime: makeTime(21, 15),
            endTime: makeTime(22, 15),
            color: const Color(0xFFA855F7),
          ),
          OnboardingRoutineItem(
            id: 'routine_sleep',
            title: 'Peaceful Night Sleep 🌙',
            description: 'Screen-off bedtime routine & restorative sleep',
            startTime: makeTime(22, 45),
            endTime: makeTime(6, 30),
            color: const Color(0xFF64748B),
          ),
        ]);
      } else {
        items.addAll([
          OnboardingRoutineItem(
            id: 'routine_wake',
            title: 'Morning Gym & Fresh Start 🏋️',
            description: 'Cardio workout, quick stretch & hydration',
            startTime: makeTime(6, 0),
            endTime: makeTime(7, 15),
            color: const Color(0xFFF97316),
          ),
          OnboardingRoutineItem(
            id: 'routine_breakfast',
            title: 'Shower, Grooming & Breakfast ☕',
            description: 'High-protein breakfast & plan today’s priorities',
            startTime: makeTime(7, 15),
            endTime: makeTime(8, 15),
            color: const Color(0xFFF59E0B),
          ),
          OnboardingRoutineItem(
            id: 'routine_work',
            title: 'Office Operations & Client Syncs 💼',
            description: 'Deep focus projects, strategy & deliverables',
            startTime: makeTime(9, 0),
            endTime: makeTime(17, 30),
            color: const Color(0xFF0284C7),
          ),
          OnboardingRoutineItem(
            id: 'routine_play',
            title: 'Evening Walk & Tea Break ☕',
            description: 'Neighborhood walk, coffee break & relaxing music',
            startTime: makeTime(18, 0),
            endTime: makeTime(19, 15),
            color: const Color(0xFF06B6D4),
          ),
          studyItem,
          OnboardingRoutineItem(
            id: 'routine_dinner',
            title: 'Dinner & Book Reading 📖',
            description: 'Light dinner, wind down without blue light',
            startTime: makeTime(21, 15),
            endTime: makeTime(22, 15),
            color: const Color(0xFFA855F7),
          ),
          OnboardingRoutineItem(
            id: 'routine_sleep',
            title: 'Night Sleep & Recovery 🌙',
            description: 'Unbroken restful sleep to recharge energy',
            startTime: makeTime(22, 45),
            endTime: makeTime(6, 0),
            color: const Color(0xFF64748B),
          ),
        ]);
      }
    } else if (_selectedOccupation == 'Homemaker') {
      items.addAll([
        OnboardingRoutineItem(
          id: 'routine_wake',
          title: 'Morning Awakening & Warm Chai ☕',
          description: 'Peaceful quiet morning, hydration & planning the day',
          startTime: makeTime(6, 0),
          endTime: makeTime(6, 45),
          color: const Color(0xFFF59E0B),
        ),
        OnboardingRoutineItem(
          id: 'routine_breakfast',
          title: 'Breakfast Preparation & Family Routine 🍳',
          description:
              'Nutritious cooking, packing lunches & family morning start',
          startTime: makeTime(6, 45),
          endTime: makeTime(8, 30),
          color: const Color(0xFF38BDF8),
        ),
        OnboardingRoutineItem(
          id: 'routine_chores',
          title: 'Home Care, Organizing & Lunch Prep 🥗',
          description:
              'Household tidying, grocery arrangements & delicious lunch',
          startTime: makeTime(9, 30),
          endTime: makeTime(13, 0),
          color: const Color(0xFF10B981),
        ),
        OnboardingRoutineItem(
          id: 'routine_rest',
          title: 'Afternoon Rest & Personal Time 🧘',
          description: 'Relaxing break, hobbies, reading or short nap',
          startTime: makeTime(13, 30),
          endTime: makeTime(15, 30),
          color: const Color(0xFF818CF8),
        ),
        OnboardingRoutineItem(
          id: 'routine_play',
          title: 'Evening Tea & Family Catch-up ☕',
          description:
              'Snacks, talking with family, neighborly chats & walking',
          startTime: makeTime(16, 30),
          endTime: makeTime(18, 0),
          color: const Color(0xFFEC4899),
        ),
        studyItem,
        OnboardingRoutineItem(
          id: 'routine_dinner',
          title: 'Dinner & Family Gathering 👨‍👩‍👧‍👦',
          description: 'Wholesome dinner together & quality bonding',
          startTime: makeTime(20, 30),
          endTime: makeTime(22, 0),
          color: const Color(0xFFA855F7),
        ),
        OnboardingRoutineItem(
          id: 'routine_sleep',
          title: 'Peaceful Night Sleep 🌙',
          description: 'Quiet, restful sleep to wake up rejuvenated',
          startTime: makeTime(22, 30),
          endTime: makeTime(6, 0),
          color: const Color(0xFF64748B),
        ),
      ]);
    } else {
      // Freelancer / Self-Employed
      items.addAll([
        OnboardingRoutineItem(
          id: 'routine_wake',
          title: 'Mindful Morning & Fresh Start ☕',
          description: 'Hydration, quick stretch & priority to-do list',
          startTime: makeTime(7, 0),
          endTime: makeTime(7, 45),
          color: const Color(0xFF06B6D4),
        ),
        OnboardingRoutineItem(
          id: 'routine_breakfast',
          title: 'Shower, Grooming & Breakfast 🍳',
          description: 'Energized meal, set up workstation & coffee',
          startTime: makeTime(7, 45),
          endTime: makeTime(8, 45),
          color: const Color(0xFFF59E0B),
        ),
        OnboardingRoutineItem(
          id: 'routine_deep_work',
          title: 'Deep Work & Client Deliverables 💻',
          description: 'Zero distractions creative execution & building',
          startTime: makeTime(9, 0),
          endTime: makeTime(13, 0),
          color: const Color(0xFF3B82F6),
        ),
        OnboardingRoutineItem(
          id: 'routine_lunch',
          title: 'Lunch & Screen Detox Break 🥗',
          description: 'Healthy lunch, outdoor stroll & mind refresh',
          startTime: makeTime(13, 0),
          endTime: makeTime(14, 0),
          color: const Color(0xFF10B981),
        ),
        OnboardingRoutineItem(
          id: 'routine_client_calls',
          title: 'Client Calls & Business Outreach 📈',
          description: 'Proposals, communications & wrap up today’s tasks',
          startTime: makeTime(14, 30),
          endTime: makeTime(17, 30),
          color: const Color(0xFF8B5CF6),
        ),
        OnboardingRoutineItem(
          id: 'routine_play',
          title: 'Workout / Outdoor Hobby 🎨',
          description: 'Gym, running, gaming or spending time outdoors',
          startTime: makeTime(18, 0),
          endTime: makeTime(19, 30),
          color: const Color(0xFFF97316),
        ),
        studyItem,
        OnboardingRoutineItem(
          id: 'routine_dinner',
          title: 'Dinner & Social Unwind 🍕',
          description: 'Dinner, catching up with friends or favorite series',
          startTime: makeTime(21, 15),
          endTime: makeTime(22, 15),
          color: const Color(0xFFEC4899),
        ),
        OnboardingRoutineItem(
          id: 'routine_sleep',
          title: 'Restorative Sleep 🌙',
          description: 'Calm night sleep for creative energy',
          startTime: makeTime(23, 0),
          endTime: makeTime(7, 0),
          color: const Color(0xFF64748B),
        ),
      ]);
    }

    // Sort items chronologically by startTime
    items.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _onboardingRoutineItems = items;
    });
  }

  void _handleFieldFocus() {
    if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (_signInScrollController.hasClients) {
          _signInScrollController.animateTo(
            _passwordFocusNode.hasFocus ? 240.0 : 140.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void _initHeroAnimation() {
    _heroAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -9.0).animate(
      CurvedAnimation(parent: _heroAnimController, curve: Curves.easeInOut),
    );
  }

  void _initHouseWorld() {
    _transformationController = TransformationController();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _cloudRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _houseRiseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _houseRiseAnimation = CurvedAnimation(
      parent: _houseRiseController,
      curve: Curves.easeOutBack,
    );
  }

  Future<void> _initBgm() async {
    try {
      _isAudioMuted = PocketGameAudioService.instance.isMutedNotifier.value;
      await PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (e) {
      debugPrint('Non-critical BGM note: $e');
    }
  }

  void _toggleAudioMute() {
    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.toggleMute();
    setState(() => _isAudioMuted = PocketGameAudioService.instance.isMutedNotifier.value);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_handleFieldFocus);
    _passwordFocusNode.removeListener(_handleFieldFocus);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _signInScrollController.dispose();
    _bgmPlayer?.stop();
    _bgmPlayer?.dispose();
    _heroAnimController.dispose();
    _transformationController.dispose();
    _ambientController.dispose();
    _cloudRevealController.dispose();
    _houseRiseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_currentStep < _totalSteps - 1) {
      final nextStep = _currentStep + 1;
      setState(() => _currentStep = nextStep);
      _pageController.animateToPage(
        nextStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
      if (nextStep >= 2 && !_isHouseRevealed) {
        _revealHouse();
      }
    }
  }

  void _revealHouse() {
    if (_isHouseRevealed) return;
    setState(() => _isHouseRevealed = true);
    HapticFeedback.heavyImpact();
    _cloudRevealController.forward();
  }

  void _resetHouseCamera(double w, double h) {
    const double worldW = 1200.0;
    const double worldH = 1600.0;
    const double houseW = 420.0;
    const double houseH = 380.0;
    const double groundY = 920.0;
    final double houseTop = groundY - 14.0 - houseH;

    final minScale = math.max(w / worldW, h / worldH);
    const maxScale = 3.5;
    final defaultScale = (w / (houseW * 1.15)).clamp(minScale, maxScale);

    final houseCenterX = worldW / 2; // 600
    final houseCenterY = houseTop + (houseH * 0.52);

    final maxTx = 0.0;
    final minTx = -((worldW * defaultScale) - w);
    final safeMinTx = minTx < maxTx ? minTx : maxTx;
    final tx =
        ((w / 2) - (houseCenterX * defaultScale)).clamp(safeMinTx, maxTx);

    final maxTy = 0.0;
    final minTy = -((worldH * defaultScale) - h);
    final safeMinTy = minTy < maxTy ? minTy : maxTy;
    // Position the house in the lower viewport (around 68% of screen height) so the sky above is open for the question card!
    final targetTy = (h * 0.68) - (houseCenterY * defaultScale);
    final ty = targetTy.clamp(safeMinTy, maxTy);

    final matrix = Matrix4.identity();
    matrix.setEntry(0, 0, defaultScale);
    matrix.setEntry(1, 1, defaultScale);
    matrix.setEntry(0, 3, tx);
    matrix.setEntry(1, 3, ty);

    _transformationController.value = matrix;
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      setState(() => _mode = WelcomeMode.welcome);
    }
  }

  Future<void> _saveOnboardingChoicesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pm_native_language', _selectedNativeLanguage);
      await prefs.setString('pm_target_language', _selectedTargetLanguage);
      await prefs.setString('pm_referral_source', _selectedReferralSource);
      await prefs.setString('pm_english_level', _selectedEnglishLevel);
      final resolvedLvl =
          PocketSyllabusRepository.resolveLevelFromText(_selectedEnglishLevel);
      await prefs.setString(
          PocketSyllabusRepository.kPrefsLearnerLevel, resolvedLvl.name);
      await prefs.setString('pm_learning_goal', _selectedLearningGoal);
      await prefs.setInt('pm_daily_goal_mins', _selectedDailyGoalMins);
      await prefs.setString('pm_plan_type', _selectedPlan);
      await prefs.setString('pm_starting_path', _selectedPath);
      await prefs.setString('pm_house_palette', _selectedHousePalette);
      await prefs.setBool('pm_onboarding_completed', true);
      await prefs.setInt('pm_streak_days', 1);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('pm_onboarding_seen_${user.id}', true);
        await SupaFlow.client.from('profile').upsert({
          'user_id': user.id,
          'native_language': _selectedNativeLanguage,
          'english_level': _selectedEnglishLevel,
          'learning_goal': _selectedLearningGoal,
          'learning_day': 1,
          'learning_points': 50,
          'xp': 50,
          'palette_id': _selectedHousePalette,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }

      // ⏰ 1. Save Schedule locally & sync to Supabase user_schedules
      final scheduleItems =
          _onboardingRoutineItems.map((e) => e.toScheduleItem()).toList();
      final scheduleJson =
          jsonEncode(scheduleItems.map((item) => item.toJson()).toList());

      // Save for both guest and authenticated user
      if (user != null) {
        await prefs.setString('schedule_${user.id}', scheduleJson);
      }
      await prefs.setString('schedule_guest', scheduleJson);
      await prefs.setString('schedule_default', scheduleJson);

      if (user != null && scheduleItems.isNotEmpty) {
        try {
          await SupaFlow.client.from('user_schedules').upsert(
                scheduleItems
                    .map((s) => {
                          'id': s.id,
                          'user_id': user.id,
                          'title': s.title,
                          'start_time': s.startTime.toIso8601String(),
                          'end_time': s.endTime.toIso8601String(),
                          'color':
                              '0x${s.color.toARGB32().toRadixString(16).padLeft(8, '0')}',
                          'is_completed': s.isCompleted,
                          'source': s.source.index,
                        })
                    .toList(),
              );
        } catch (dbError) {
          debugPrint('user_schedules sync note: $dbError');
        }
      }

      // 📌 2. Pin "Schedule" to Favorited Tools list so it appears directly on Chat Screen!
      final targetUserId = user?.id ?? 'guest';
      final favKey = 'favorited_tools_$targetUserId';
      final existingFavRaw = prefs.getString(favKey);
      List<dynamic> favTools = [];
      if (existingFavRaw != null) {
        try {
          favTools = jsonDecode(existingFavRaw) as List<dynamic>;
        } catch (_) {
          favTools = [];
        }
      } else {
        // If first time, include the standard starters + Schedule at top!
        favTools = [
          {'title': 'Schedule', 'timeAdded': DateTime.now().toIso8601String()},
          {
            'title': '90-Day English Tasks',
            'timeAdded': DateTime.now().toIso8601String()
          },
          {
            'title': '1-on-1 English Match',
            'timeAdded': DateTime.now()
                .subtract(const Duration(minutes: 1))
                .toIso8601String()
          },
          {
            'title': 'Voice Speaking Sprint',
            'timeAdded': DateTime.now()
                .subtract(const Duration(minutes: 2))
                .toIso8601String()
          },
        ];
      }

      final alreadyContainsSchedule =
          favTools.any((t) => t is Map && t['title'] == 'Schedule');
      if (!alreadyContainsSchedule) {
        favTools.insert(0, {
          'title': 'Schedule',
          'timeAdded': DateTime.now().toIso8601String(),
        });
      }
      await prefs.setString(favKey, jsonEncode(favTools));

      // Also set for guest fallback
      await prefs.setString('favorited_tools_guest', jsonEncode(favTools));

      // 🔔 3. Schedule Recurring Study Notification Alarm for all active alarms
      for (int i = 0; i < _onboardingRoutineItems.length; i++) {
        final item = _onboardingRoutineItems[i];
        if (item.hasAlarm) {
          final notifId = item.isStudySlot ? 7777 : (8000 + i);
          await PushNotificationService.scheduleDailyNotification(
            id: notifId,
            title: item.isStudySlot
                ? '⏰ English Speaking Practice Time!'
                : '⏰ ${item.title}',
            body: item.isStudySlot
                ? 'Time for your daily English speaking session! Hop in, practice with friends and keep your streak strong! 🔥'
                : (item.description ?? 'Scheduled routine reminder'),
            hour: item.startTime.hour,
            minute: item.startTime.minute,
            payload: 'tool_Schedule',
            isAlarm: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Cache onboarding note: $e');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = _isSignUpMode
          ? 'Connecting with Google...'
          : 'Signing into PoketMates with Google...';
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isSignUpMode) {
        await prefs.setBool('pending_signup_flow', true);
      } else {
        await prefs.setBool('pending_signup_flow', false);
      }
      setState(() => _isQuestionSheetMinimized = true);
      await _houseRiseController.forward();
      await _saveOnboardingChoicesLocally();
      if (!mounted) return;
      GoRouter.of(context).prepareAuthEvent();
      await SupaFlow.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'pocketmatesapp://pocketmatesapp.com/auth-callback',
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Google Sign-In note: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_loginFormKey.currentState!.validate()) return;
    if (_isSignUpMode && !_agreedToTerms) {
      setState(() {
        _errorMessage =
            'Please accept the Terms of Service & Privacy Policy to continue.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _loadingMessage = _isSignUpMode
          ? 'Creating your account...'
          : 'Signing into PoketMates...';
      _errorMessage = null;
    });

    try {
      await _saveOnboardingChoicesLocally();
      if (!mounted) return;
      GoRouter.of(context).prepareAuthEvent();
      if (_isSignUpMode) {
        final user = await authManager.createAccountWithEmail(
          context,
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null && mounted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('just_created_account_${user.uid}', true);
          setState(() {
            _loadingMessage = 'Account created! Starting profile setup...';
          });
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            context.goNamedAuth(
                ProfileCreateCustomWidget.routeName, context.mounted);
          }
        }
      } else {
        final user = await authManager.signInWithEmail(
          context,
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null && mounted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('profile_setup_completed_${user.uid}', true);
          await prefs.setBool('profile_setup_prompted_${user.uid}', true);
          await prefs.remove('just_created_account_${user.uid}');
          setState(() {
            _loadingMessage = 'Welcome back! Opening your home...';
          });
          await Future.delayed(const Duration(milliseconds: 350));
          if (mounted) {
            context.goNamedAuth(HomePageWidget.routeName, context.mounted);
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Auth failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _finishAsGuest() async {
    HapticFeedback.heavyImpact();
    setState(() => _isQuestionSheetMinimized = true);
    await _houseRiseController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    await _saveOnboardingChoicesLocally();
    _bgmPlayer?.stop();
    if (mounted) {
      final lvl =
          PocketSyllabusRepository.resolveLevelFromText(_selectedEnglishLevel);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => PocketGeneratingSyllabusPage(
            level: lvl,
            nativeLanguage: _selectedNativeLanguage,
            onContinue: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                context.goNamed(HomePageWidget.routeName);
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mode == WelcomeMode.signIn
          ? const Color(0xFF0F172A)
          : const Color(0xFF0284C7),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentModeWidget(),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 36),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 26),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF10B981)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _loadingMessage ?? 'Connecting to Pocket Mates...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Please wait a moment...',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12.5,
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
    );
  }

  Widget _buildCurrentModeWidget() {
    switch (_mode) {
      case WelcomeMode.welcome:
        return _buildWelcomeScreen();
      case WelcomeMode.onboarding:
        return _buildOnboardingFlow();
      case WelcomeMode.signIn:
        return _buildSignInScreen();
    }
  }

  // =========================================================================
  // 1. WELCOME SCREEN (Initial Launch)
  // =========================================================================
  Widget _buildWelcomeScreen() {
    return SafeArea(
      key: const ValueKey('WelcomeScreen'),
      child: Stack(
        children: [
          // Ambient soft radial gradient in center
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.85,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF080C16),
                  ],
                ),
              ),
            ),
          ),

          // Top Controls: Mute/Unmute Audio
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _toggleAudioMute,
                icon: Icon(
                  _isAudioMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color:
                      _isAudioMuted ? Colors.white38 : const Color(0xFFFACC15),
                  size: 22,
                ),
                tooltip: _isAudioMuted ? 'Unmute BGM' : 'Mute BGM',
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Minimal Floating Starter Avatar
                    Center(
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          );
                        },
                        child: _buildStarterAvatar(size: 110),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App Title
                    Text(
                      'Pocket Mates',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tagline
                    Text(
                      'Your interactive English speaking world.\nBuild your home, talk daily, unlock fluency.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Minimal Feature Badges
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFeaturePill('🏡 Level 1 Home'),
                        _buildFeaturePill('🗣️ Voice Practice'),
                        _buildFeaturePill('🔥 Daily Streaks'),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // PRIMARY CTA: "GET STARTED"
                    _buildDuolingoButton(
                      label: 'GET STARTED',
                      backgroundColor: const Color(0xFF10B981),
                      shadowColor: const Color(0xFF059669),
                      textColor: Colors.white,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _mode = WelcomeMode.onboarding;
                          _currentStep = 0;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // SECONDARY CTA: "I ALREADY HAVE AN ACCOUNT"
                    _buildDuolingoOutlineButton(
                      label: 'I ALREADY HAVE AN ACCOUNT',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isSignUpMode = false;
                          _errorMessage = null;
                          _mode = WelcomeMode.signIn;
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFFE2E8F0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================================
  // 2. DUOLINGO-STYLE ONBOARDING FLOW WITH INTERACTIVE HOUSE & CLOUDS
  // =========================================================================
  Widget _buildOnboardingFlow() {
    final double progress = (_currentStep + 1) / _totalSteps;

    return LayoutBuilder(
      key: const ValueKey('OnboardingFlow'),
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 🏡 1. Full-Screen Interactive House & Living World (Zoom & Pan)
            Positioned.fill(
              child: _buildInteractiveHouseWorld(w, h),
            ),

            // ☁️ 2. Puffy Cloud Parting Reveal Layer
            Positioned.fill(
              child: _buildCloudOverlay(w, h),
            ),

            // 🌟 3. Top Navigation & Progress Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _prevStep,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor:
                                const Color(0xFF27272A).withValues(alpha: 0.8),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF58CC02),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Camera Center Button (re-focus on house)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Focus on House',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _resetHouseCamera(w, h);
                          },
                          icon: const Icon(Icons.home_rounded,
                              color: Color(0xFF38BDF8), size: 20),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Audio Mute Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _toggleAudioMute,
                          icon: Icon(
                            _isAudioMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: _isAudioMuted
                                ? Colors.white38
                                : const Color(0xFFFACC15),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 📋 4. Floating Question Card in the Sky (Above the House)
            Positioned(
              top: MediaQuery.of(context).padding.top + 52,
              left: 16,
              right: 16,
              child: _buildFloatingQuestionCard(w, h),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInteractiveHouseWorld(double w, double h) {
    const double worldW = 1200.0;
    const double worldH = 1600.0;
    const double houseW = 420.0;
    const double houseH = 380.0;
    const double groundY = 920.0;
    final double houseLeft = (worldW - houseW) / 2; // 390.0
    final double houseTop = groundY - 14.0 - houseH; // 526.0

    final minScale = math.max(w / worldW, h / worldH);
    const maxScale = 3.5;

    if (!_hasInitializedTransform && w > 0 && h > 0) {
      _hasInitializedTransform = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resetHouseCamera(w, h);
      });
    }

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: minScale,
      maxScale: maxScale,
      boundaryMargin: EdgeInsets.zero,
      constrained: false,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: worldW,
        height: worldH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Scenic 2D Living Landscape Painter (Sky, Mountains, Waterfall, Rolling Green Foothills, Sun, Birds)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: CitadelScenicLandscapePainter(
                      isDamaged: false,
                      groundBaseY: groundY,
                      isNight: false,
                      isDay90: false,
                      ambientProg: _ambientController.value,
                      isPresident: false,
                    ),
                  );
                },
              ),
            ),

            // 2. The Level 1 House with Celebratory Rise Animation
            Positioned(
              left: houseLeft,
              top: houseTop,
              width: houseW,
              height: houseH,
              child: AnimatedBuilder(
                animation: _houseRiseAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_houseRiseAnimation.value * 34.0),
                    child: Transform.scale(
                      scale: 1.0 + (_houseRiseAnimation.value * 0.12),
                      child: child,
                    ),
                  );
                },
                child: FlameEnglishHouseWidget(
                  currentDay: 1,
                  streak: 1,
                  isDamaged: false,
                  houseId: 'new_user_home',
                  paletteId: _selectedHousePalette,
                  showTestingControls: false,
                ),
              ),
            ),

            // 3. Chimney Smoke Puffs floating above the roof
            Positioned(
              top: houseTop - 28,
              left: 600.0 - 88,
              child: _buildChimneySmoke(),
            ),
            Positioned(
              top: houseTop - 28,
              left: 600.0 + 88 - 18,
              child: _buildChimneySmoke(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingQuestionCard(double w, double h) {
    final topOffset = MediaQuery.of(context).padding.top + 52;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final maxAvailableHeight = h - topOffset - bottomPadding - 16;

    final double cardMaxHeight =
        _isQuestionSheetMinimized ? 48.0 : maxAvailableHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: cardMaxHeight,
      decoration: BoxDecoration(
        color: const Color(0xE80F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Column(
            children: [
              // Minimal header bar / collapse toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() =>
                      _isQuestionSheetMinimized = !_isQuestionSheetMinimized);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          '${_currentStep + 1}/$_totalSteps',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFACC15),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isQuestionSheetMinimized
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: Colors.white60,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              if (!_isQuestionSheetMinimized)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep0Greeting(),
                      _buildStep1QuestionsIntro(),
                      _buildStep2NativeLanguage(),
                      _buildStep3ReferralSource(),
                      _buildStep4EnglishLevel(),
                      _buildStep5LearningGoal(),
                      _buildStepOccupation(),
                      _buildStepPreferredStudyTime(),
                      _buildStepDailyCommitment(),
                      _buildStepScheduleReview(),
                      _buildStep6Notifications(),
                      _buildStep7WidgetCheer(),
                      _buildStep8ThreeMonthPromise(),
                      _buildStep9PlanChoice(),
                      _buildStep10StartingPath(),
                      _buildStep11CelebrationAndSave(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudOverlay(double w, double h) {
    return AnimatedBuilder(
      animation: _cloudRevealController,
      builder: (context, _) {
        final val = _cloudRevealController.value;
        if (val >= 1.0) {
          return const SizedBox.shrink();
        }

        final curve = Curves.easeInOutCubic.transform(val);
        final opacity = (1.0 - curve).clamp(0.0, 1.0);
        final leftOffset = -w * 1.15 * curve;
        final rightOffset = w * 1.15 * curve;

        return IgnorePointer(
          ignoring: val > 0.3,
          child: Opacity(
            opacity: opacity,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _ambientController,
                  builder: (context, _) {
                    final floatY =
                        math.sin(_ambientController.value * 2 * math.pi) * 8.0;

                    return Stack(
                      children: [
                        // Left Cloud Mass
                        Positioned(
                          left: leftOffset,
                          top: floatY,
                          width: w * 0.95,
                          height: h * 0.65,
                          child: CustomPaint(
                            painter: FluffyCloudClusterPainter(isLeft: true),
                          ),
                        ),

                        // Right Cloud Mass
                        Positioned(
                          right: -rightOffset,
                          top: -floatY,
                          width: w * 0.95,
                          height: h * 0.65,
                          child: CustomPaint(
                            painter: FluffyCloudClusterPainter(isLeft: false),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Center Dream Mystery Badge
                if (val < 0.2)
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: h * 0.25),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('☁️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Your Home is hidden behind the clouds...',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChimneySmoke() {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final dy = math.sin(_ambientController.value * 2 * math.pi) * 4.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Step 0: Welcome Greeting ---
  Widget _buildStep0Greeting() {
    return _buildStepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStarterAvatar(size: 68),
          const SizedBox(height: 16),
          _buildMascotSpeechBubble("Hi there! Welcome to PoketMates 👋"),
          const SizedBox(height: 14),
          Text(
            "Master English speaking naturally with bite-sized daily practice and real conversation.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFFA1A1AA),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
      onContinue: _nextStep,
      buttonText: 'GET STARTED',
    );
  }

  // --- Step 1: Questions Intro ---
  Widget _buildStep1QuestionsIntro() {
    return _buildStepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B),
              border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            ),
            child: const Icon(Icons.tune_rounded,
                color: Color(0xFF38BDF8), size: 30),
          ),
          const SizedBox(height: 16),
          _buildMascotSpeechBubble(
              "5 quick questions to personalize your plan 🎯"),
          const SizedBox(height: 14),
          Text(
            "We'll tune your daily topics, high-impact vocabulary, and speaking level.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFFA1A1AA),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 2: Native Language ---
  Widget _buildStep2NativeLanguage() {
    return _buildStepContainer(
      title: 'What is your native language?\nനിങ്ങളുടെ മാതൃഭാഷ ഏതാണ്?',
      mascotHint:
          'Select your native tongue so we can guide your practice comfortably. (നിങ്ങൾ സംസാരിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക)',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _nativeLanguages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final lang = _nativeLanguages[index];
          final isSelected = _selectedNativeLanguage == lang['code'];
          return _buildOptionCard(
            title: lang['name']!,
            leadingEmoji: lang['flag'],
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedNativeLanguage = lang['code']!);
            },
          );
        },
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 3: Referral Source ---
  Widget _buildStep3ReferralSource() {
    return _buildStepContainer(
      title: 'How did you hear about PoketMates?',
      mascotHint: 'Help us understand how you discovered our community!',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _referralSources.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final source = _referralSources[index];
          final isSelected = _selectedReferralSource == source['title'];
          return _buildOptionCard(
            title: source['title'] as String,
            leadingIcon: source['icon'] as IconData,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(
                  () => _selectedReferralSource = source['title'] as String);
            },
          );
        },
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 4: English Level ---
  Widget _buildStep4EnglishLevel() {
    return _buildStepContainer(
      title: 'How much English do you know right now?',
      mascotHint: 'Select where you feel most comfortable starting.',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _englishLevels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final level = _englishLevels[index];
          final isSelected = _selectedEnglishLevel == level['title'];
          return _buildOptionCard(
            title: level['title']!,
            subtitle: level['subtitle'],
            leadingEmoji: level['emoji'],
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedEnglishLevel = level['title']!);
            },
          );
        },
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 5: Learning Goal ---
  Widget _buildStep5LearningGoal() {
    return _buildStepContainer(
      title: 'Why are you learning English?',
      mascotHint: 'What goal motivates you toward spoken fluency?',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _learningGoals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final goal = _learningGoals[index];
          final isSelected = _selectedLearningGoal == goal['title'];
          return _buildOptionCard(
            title: goal['title'] as String,
            leadingIcon: goal['icon'] as IconData,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedLearningGoal = goal['title'] as String);
            },
          );
        },
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 6: Role / Occupation ---
  Widget _buildStepOccupation() {
    return _buildStepContainer(
      title: 'What is your current role?',
      mascotHint:
          'Tell us your daily routine style so we can shape your schedule perfectly.',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _occupations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final occ = _occupations[index];
          final isSelected = _selectedOccupation == occ['title'];
          return _buildOptionCard(
            title: occ['title'] as String,
            leadingEmoji: occ['emoji'] as String,
            leadingIcon: occ['icon'] as IconData,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedOccupation = occ['title'] as String;
                _generateOnboardingRoutine();
              });
            },
          );
        },
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 7: Preferred Study Time Slot (+ Custom Clock UI as First Priority) ---
  Widget _buildStepPreferredStudyTime() {
    final currentTOD =
        _customStudyTimeOfDay ?? const TimeOfDay(hour: 20, minute: 0);
    final rawHour = currentTOD.hour;
    final rawMinute = currentTOD.minute;
    final isPM = rawHour >= 12;
    final displayHour12 =
        rawHour == 0 ? 12 : (rawHour > 12 ? rawHour - 12 : rawHour);
    final hourStr = displayHour12.toString().padLeft(2, '0');
    final minStr = rawMinute.toString().padLeft(2, '0');
    final periodStr = isPM ? 'PM' : 'AM';
    final formattedTime = '$hourStr:$minStr $periodStr';

    void updateTime(int newHour24, int newMin) {
      HapticFeedback.selectionClick();
      final clampedMin = (newMin % 60 + 60) % 60;
      final clampedHour = (newHour24 % 24 + 24) % 24;
      setState(() {
        _customStudyTimeOfDay =
            TimeOfDay(hour: clampedHour, minute: clampedMin);
        _selectedStudyTimeSlot = 'Custom';
        _generateOnboardingRoutine();
      });
    }

    void stepHour(int delta) {
      updateTime(rawHour + delta, rawMinute);
    }

    void stepMinute(int delta) {
      updateTime(rawHour, rawMinute + delta);
    }

    void togglePeriod(bool toPM) {
      if (toPM && !isPM) {
        updateTime(rawHour + 12, rawMinute);
      } else if (!toPM && isPM) {
        updateTime(rawHour - 12, rawMinute);
      }
    }

    return _buildStepContainer(
      title: 'When do you prefer to practice?',
      mascotHint:
          'Set your ideal daily English speaking time. Tap the clock steppers or presets below to customize!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ⏰ Main Interactive Clock Card (First Priority!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF131D2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded,
                            color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'PRACTICE CLOCK',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'DAILY ALARM ACTIVE',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Digital Clock Display with Stepper Taps
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hour Stepper
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => stepHour(1),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: currentTOD,
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF10B981),
                                    surface: Color(0xFF1E293B),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _customStudyTimeOfDay = picked;
                                _selectedStudyTimeSlot = 'Custom';
                                _generateOnboardingRoutine();
                              });
                            }
                          },
                          child: Container(
                            width: 66,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B111E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              hourStr,
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => stepHour(-1),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Colon Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        ':',
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),

                    // Minute Stepper
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => stepMinute(5),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: currentTOD,
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF10B981),
                                    surface: Color(0xFF1E293B),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _customStudyTimeOfDay = picked;
                                _selectedStudyTimeSlot = 'Custom';
                                _generateOnboardingRoutine();
                              });
                            }
                          },
                          child: Container(
                            width: 66,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B111E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              minStr,
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => stepMinute(-5),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // AM / PM Segmented Switch
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B111E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => togglePeriod(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: !isPM
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'AM',
                                style: GoogleFonts.inter(
                                  color: !isPM ? Colors.black : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => togglePeriod(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPM
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'PM',
                                style: GoogleFonts.inter(
                                  color: isPM ? Colors.black : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick minute nudges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeNudgeChip('-15m', () => stepMinute(-15)),
                    const SizedBox(width: 8),
                    _buildTimeNudgeChip('-5m', () => stepMinute(-5)),
                    const SizedBox(width: 8),
                    _buildTimeNudgeChip('+5m', () => stepMinute(5)),
                    const SizedBox(width: 8),
                    _buildTimeNudgeChip('+15m', () => stepMinute(15)),
                  ],
                ),
                const SizedBox(height: 12),

                // Direct Dial Helper
                InkWell(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: currentTOD,
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF10B981),
                            surface: Color(0xFF1E293B),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _customStudyTimeOfDay = picked;
                        _selectedStudyTimeSlot = 'Custom';
                        _generateOnboardingRoutine();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Color(0xFF38BDF8), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Tap here to pick from full visual clock dial 🕒',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF38BDF8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Preset Routine Slots Header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'OR TAP A POPULAR TIME PRESET',
              style: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Quick preset buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetSlotChip(
                label: 'Morning Focus',
                time: '7:30 AM',
                hour: 7,
                min: 30,
                icon: Icons.wb_sunny_rounded,
                color: const Color(0xFFF59E0B),
                currentHour: rawHour,
                currentMin: rawMinute,
              ),
              _buildPresetSlotChip(
                label: 'After Lunch',
                time: '1:30 PM',
                hour: 13,
                min: 30,
                icon: Icons.light_mode_rounded,
                color: const Color(0xFF06B6D4),
                currentHour: rawHour,
                currentMin: rawMinute,
              ),
              _buildPresetSlotChip(
                label: 'Evening Tea',
                time: '6:30 PM',
                hour: 18,
                min: 30,
                icon: Icons.coffee_rounded,
                color: const Color(0xFFEC4899),
                currentHour: rawHour,
                currentMin: rawMinute,
              ),
              _buildPresetSlotChip(
                label: 'Prime Night',
                time: '8:00 PM',
                hour: 20,
                min: 0,
                icon: Icons.nights_stay_rounded,
                color: const Color(0xFF10B981),
                currentHour: rawHour,
                currentMin: rawMinute,
              ),
              _buildPresetSlotChip(
                label: 'Late Night',
                time: '10:00 PM',
                hour: 22,
                min: 0,
                icon: Icons.bedtime_rounded,
                color: const Color(0xFFA855F7),
                currentHour: rawHour,
                currentMin: rawMinute,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Active Schedule Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Daily Speaking Session: $formattedTime ($_selectedDailyGoalMins mins)',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  Widget _buildTimeNudgeChip(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetSlotChip({
    required String label,
    required String time,
    required int hour,
    required int min,
    required IconData icon,
    required Color color,
    required int currentHour,
    required int currentMin,
  }) {
    final isSelected = currentHour == hour && currentMin == min;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _customStudyTimeOfDay = TimeOfDay(hour: hour, minute: min);
          _selectedStudyTimeSlot = 'Custom';
          _generateOnboardingRoutine();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.22)
              : const Color(0xFF141416),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF27272A),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54, size: 15),
            const SizedBox(width: 6),
            Text(
              '$label ($time)',
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 8: Daily Study Commitment Duration ---
  Widget _buildStepDailyCommitment() {
    return _buildStepContainer(
      title: 'Daily Language Learning Commitment',
      mascotHint:
          'How much time can you comfortably dedicate to English speaking daily?',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _dailyCommitments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = _dailyCommitments[index];
          final minutes = c['minutes'] as int;
          final isSelected = _selectedDailyGoalMins == minutes;

          return _buildOptionCard(
            title: c['label'] as String,
            subtitle: c['desc'] as String,
            badge: c['badge'] as String?,
            badgeColor: c['badgeColor'] as Color?,
            leadingIcon: c['icon'] as IconData,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDailyGoalMins = minutes;
                _generateOnboardingRoutine();
              });
            },
          );
        },
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 9: Schedule Screen (Full Day Routine Review) ---
  // --- Step 9: Schedule Screen (Full Day Routine Review) ---
  Widget _buildStepScheduleReview() {
    return _buildStepContainer(
      title: 'Full-Day Routine Schedule',
      mascotHint:
          'Tap any routine activity or ✏️ to customize its time, name, or alarm. Alarms sync directly to your Schedule Tool!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR FULL-DAY ROUTINE',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // + Add Slot button
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showEditRoutineItemModal(context, null, -1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: Color(0xFF10B981), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            'Add Slot',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Shuffle Preset button
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _routineVariationIndex++;
                        _generateOnboardingRoutine();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF38BDF8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shuffle_rounded,
                              color: Color(0xFF38BDF8), size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'Shuffle',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Routine Cards List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _onboardingRoutineItems.length,
            itemBuilder: (context, index) {
              final item = _onboardingRoutineItems[index];
              return _buildOnboardingScheduleCard(item, index);
            },
          ),
        ],
      ),
      onContinue: _handleConfirmSchedule,
      buttonText: 'CONFIRM SCHEDULE',
    );
  }

  // 💾 Handle schedule confirmation: syncs to Schedule Tool & pins favorite on Chat & Home!
  Future<void> _handleConfirmSchedule() async {
    HapticFeedback.mediumImpact();
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = SupaFlow.client.auth.currentUser;
      final scheduleItems =
          _onboardingRoutineItems.map((e) => e.toScheduleItem()).toList();
      final scheduleJson =
          jsonEncode(scheduleItems.map((item) => item.toJson()).toList());

      // 1. Save schedule for user and guest fallbacks
      if (user != null) {
        await prefs.setString('schedule_${user.id}', scheduleJson);
      }
      await prefs.setString('schedule_guest', scheduleJson);
      await prefs.setString('schedule_default', scheduleJson);

      // 2. Sync to Supabase user_schedules
      if (user != null && scheduleItems.isNotEmpty) {
        try {
          await SupaFlow.client.from('user_schedules').upsert(
                scheduleItems
                    .map((s) => {
                          'id': s.id,
                          'user_id': user.id,
                          'title': s.title,
                          'start_time': s.startTime.toIso8601String(),
                          'end_time': s.endTime.toIso8601String(),
                          'color':
                              '0x${s.color.toARGB32().toRadixString(16).padLeft(8, '0')}',
                          'is_completed': s.isCompleted,
                          'source': s.source.index,
                        })
                    .toList(),
              );
        } catch (dbError) {
          debugPrint('user_schedules sync note: $dbError');
        }
      }

      // 3. Pin "Schedule" to Favorited Tools list for user and guest fallbacks
      final targetUserId = user?.id ?? 'guest';
      final favKey = 'favorited_tools_$targetUserId';
      final existingFavRaw =
          prefs.getString(favKey) ?? prefs.getString('favorited_tools_guest');
      List<dynamic> favTools = [];
      if (existingFavRaw != null) {
        try {
          favTools = jsonDecode(existingFavRaw) as List<dynamic>;
        } catch (_) {
          favTools = [];
        }
      } else {
        favTools = [
          {'title': 'Schedule', 'timeAdded': DateTime.now().toIso8601String()},
          {'title': '90-Day English Tasks', 'timeAdded': DateTime.now().toIso8601String()},
          {'title': '1-on-1 English Match', 'timeAdded': DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String()},
          {'title': 'Voice Speaking Sprint', 'timeAdded': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String()},
        ];
      }

      final alreadyContainsSchedule =
          favTools.any((t) => t is Map && t['title'] == 'Schedule');
      if (!alreadyContainsSchedule) {
        favTools.insert(0, {
          'title': 'Schedule',
          'timeAdded': DateTime.now().toIso8601String(),
        });
      }
      await prefs.setString(favKey, jsonEncode(favTools));
      await prefs.setString('favorited_tools_guest', jsonEncode(favTools));
      if (user != null) {
        await prefs.setString('favorited_tools_${user.id}', jsonEncode(favTools));
      }

      // 4. Schedule Alarms for all routine items where hasAlarm == true!
      for (int i = 0; i < _onboardingRoutineItems.length; i++) {
        final item = _onboardingRoutineItems[i];
        if (item.hasAlarm) {
          final notifId = item.isStudySlot ? 7777 : (8000 + i);
          await PushNotificationService.scheduleDailyNotification(
            id: notifId,
            title: item.isStudySlot
                ? '⏰ English Speaking Practice Time!'
                : '⏰ ${item.title}',
            body: item.isStudySlot
                ? 'Time for your daily English speaking session! Hop in, practice with friends and keep your streak strong! 🔥'
                : (item.description ?? 'Scheduled routine reminder'),
            hour: item.startTime.hour,
            minute: item.startTime.minute,
            payload: 'tool_Schedule',
            isAlarm: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Error confirming schedule: $e');
    }

    _nextStep();
  }

  // ✏️ Edit or Add Routine Activity Modal Bottom Sheet
  void _showEditRoutineItemModal(
      BuildContext context, OnboardingRoutineItem? existingItem, int index) {
    HapticFeedback.mediumImpact();
    final isNew = existingItem == null;
    final titleController =
        TextEditingController(text: isNew ? '' : existingItem.title);
    final descController = TextEditingController(
        text: isNew ? '' : (existingItem.description ?? ''));

    final now = DateTime.now();
    DateTime startDT = isNew
        ? DateTime(now.year, now.month, now.day, 17, 0)
        : existingItem.startTime;
    DateTime endDT = isNew
        ? DateTime(now.year, now.month, now.day, 18, 0)
        : existingItem.endTime;
    bool hasAlarm = isNew ? true : existingItem.hasAlarm;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            String formatDT(DateTime dt) {
              final h = dt.hour;
              final m = dt.minute;
              final p = h >= 12 ? 'PM' : 'AM';
              final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
              return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $p';
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isNew
                              ? 'Add Routine Activity ➕'
                              : 'Edit Routine Activity ✏️',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title Field
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Activity Name',
                        labelStyle:
                            GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        hintText: 'e.g., Morning Workout, Study, Dinner',
                        hintStyle: GoogleFonts.inter(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1E2333),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    TextField(
                      controller: descController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Description / Notes (Optional)',
                        labelStyle:
                            GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        hintText: 'e.g., Hydrate, notes & 30 min focus',
                        hintStyle: GoogleFonts.inter(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1E2333),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Time & End Time Picker Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(startDT),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF10B981),
                                      surface: Color(0xFF1E293B),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  startDT = DateTime(now.year, now.month,
                                      now.day, picked.hour, picked.minute);
                                  if (endDT.isBefore(startDT)) {
                                    endDT = startDT.add(const Duration(minutes: 30));
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2333),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'START TIME',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded,
                                          color: Color(0xFF10B981), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatDT(startDT),
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(endDT),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF10B981),
                                      surface: Color(0xFF1E293B),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  endDT = DateTime(now.year, now.month,
                                      now.day, picked.hour, picked.minute);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2333),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'END TIME',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded,
                                          color: Color(0xFF38BDF8), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatDT(endDT),
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Alarm Toggle Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2333),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasAlarm
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_none_rounded,
                                color: hasAlarm
                                    ? const Color(0xFFFACC15)
                                    : const Color(0xFF71717A),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Daily Alarm for this activity',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: hasAlarm,
                            activeThumbColor: const Color(0xFF10B981),
                            onChanged: (val) {
                              setModalState(() {
                                hasAlarm = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        HapticFeedback.mediumImpact();
                        setState(() {
                          if (isNew) {
                            _onboardingRoutineItems.add(OnboardingRoutineItem(
                              id: 'routine_${DateTime.now().millisecondsSinceEpoch}',
                              title: title,
                              description: descController.text.trim(),
                              startTime: startDT,
                              endTime: endDT,
                              hasAlarm: hasAlarm,
                              color: const Color(0xFF38BDF8),
                            ));
                          } else {
                            existingItem.title = title;
                            existingItem.description =
                                descController.text.trim();
                            existingItem.startTime = startDT;
                            existingItem.endTime = endDT;
                            existingItem.hasAlarm = hasAlarm;
                          }
                          _onboardingRoutineItems.sort(
                              (a, b) => a.startTime.compareTo(b.startTime));
                        });
                        Navigator.pop(modalContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isNew ? 'Add to Schedule' : 'Save Changes',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Delete Button (if editing an existing item)
                    if (!isNew && !existingItem.isStudySlot) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _onboardingRoutineItems.removeAt(index);
                          });
                          Navigator.pop(modalContext);
                        },
                        child: Text(
                          'Delete Activity',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFEF4444),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 📇 Sleek dark schedule card with tap-to-edit, alarm bell, and checkmark
  Widget _buildOnboardingScheduleCard(OnboardingRoutineItem item, int index) {
    final startHour = item.startTime.hour;
    final startMin = item.startTime.minute;
    final endHour = item.endTime.hour;
    final endMin = item.endTime.minute;

    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';

    final startHour12 =
        startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
    final endHour12 =
        endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);

    final startStr =
        '${startHour12.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} $startPeriod';
    final endStr =
        '${endHour12.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')} $endPeriod';

    final isStudy = item.isStudySlot;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isStudy ? const Color(0xFF0F231C) : const Color(0xFF131722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStudy
              ? const Color(0xFF10B981)
              : (item.isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFF1E2333)),
          width: isStudy ? 1.5 : (item.isCompleted ? 1.3 : 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: isStudy
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditRoutineItemModal(context, item, index),
          child: Row(
            children: [
              // Time Column with vertical accent line
              Container(
                width: 78,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startStr,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 2,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isStudy
                            ? const Color(0xFF10B981)
                            : item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      endStr,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 64,
                color: const Color(0xFF1E2333),
              ),

              // Title & Description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: item.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isStudy) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFF10B981), width: 0.8),
                              ),
                              child: Text(
                                'STUDY SLOT',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF10B981),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.description!,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF94A3B8),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Controls: Edit, Alarm Bell, Checkmark
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✏️ Edit Button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF38BDF8),
                        size: 18,
                      ),
                      tooltip: 'Edit routine item',
                      onPressed: () =>
                          _showEditRoutineItemModal(context, item, index),
                    ),

                    // 🔔 Alarm Toggle
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      icon: Icon(
                        item.hasAlarm
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: item.hasAlarm
                            ? const Color(0xFFFACC15)
                            : const Color(0xFF52525B),
                        size: 19,
                      ),
                      tooltip: item.hasAlarm ? 'Alarm Active' : 'Enable Alarm',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          item.hasAlarm = !item.hasAlarm;
                        });
                      },
                    ),

                    // ✅ Checkmark Circle
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          item.isCompleted = !item.isCompleted;
                        });
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          border: Border.all(
                            color: item.isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFF52525B),
                            width: 1.8,
                          ),
                        ),
                        child: item.isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step 6: Notifications ---
  Widget _buildStep6Notifications() {
    return _buildStepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF18181B),
              border: Border.all(color: const Color(0xFF58CC02), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF58CC02).withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Color(0xFF58CC02), size: 34),
          ),
          const SizedBox(height: 16),
          _buildMascotSpeechBubble("Stay on track with gentle reminders ⏰"),
          const SizedBox(height: 12),
          Text(
            "PoketMates can send friendly daily reminders to protect your speaking streak.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFFA1A1AA),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _buildDuolingoButton(
            label: 'ALLOW NOTIFICATIONS',
            backgroundColor: const Color(0xFF58CC02),
            shadowColor: const Color(0xFF46A302),
            textColor: Colors.white,
            onPressed: () async {
              try {
                final granted =
                    await PushNotificationService.requestPermissionExplicitly();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('pm_notifications_enabled', granted);
              } catch (_) {}
              _nextStep();
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _nextStep,
            child: Text(
              'MAYBE LATER',
              style: GoogleFonts.inter(
                color: const Color(0xFFA1A1AA),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      showDefaultButton: false,
    );
  }

  // --- Step 7: Daily Streak Kickoff ---
  Widget _buildStep7WidgetCheer() {
    return _buildStepContainer(
      title: 'Commit to your daily streak 🔥',
      mascotHint: "Consistency is the fastest route to spoken English fluency.",
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: const Color(0xFFF97316).withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStarterAvatar(size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🔥 ', style: TextStyle(fontSize: 15)),
                          Text(
                            'Day 1 Streak Ready!',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$_selectedDailyGoalMins minutes daily practice goal active',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA1A1AA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildWidgetInstructionItem(
            stepNumber: '1',
            text:
                'Bite-sized practice: $_selectedDailyGoalMins minutes a day builds lasting English fluency.',
          ),
          const SizedBox(height: 10),
          _buildWidgetInstructionItem(
            stepNumber: '2',
            text:
                'Live speaking: Practice immediately in friendly voice rooms.',
          ),
          const SizedBox(height: 10),
          _buildWidgetInstructionItem(
            stepNumber: '3',
            text:
                'Streak rewards: Keep your streak alive to unlock rooms & items!',
          ),
        ],
      ),
      onContinue: _nextStep,
      buttonText: "LET'S DO THIS!",
    );
  }

  // --- Step 8: 3-Month Achievement Promise ---
  Widget _buildStep8ThreeMonthPromise() {
    return _buildStepContainer(
      title: "What you will achieve in 3 months:",
      mascotHint:
          "Every feature in PoketMates is designed to make you speak fluently.",
      child: Column(
        children: [
          _buildPromiseCard(
            emoji: '🎓',
            title: 'Official PoketMates Certificate',
            desc:
                'Earn a verified Certificate of English Spoken Fluency upon graduation.',
            badge: 'CERTIFIED',
            badgeColor: const Color(0xFFFACC15),
          ),
          const SizedBox(height: 8),
          _buildPromiseCard(
            emoji: '⚔️',
            title: 'Pocket Citadel Battles & Defense',
            desc:
                'Gamified learning: attack, defend, and master vocabulary through tactical battles.',
            badge: 'GAMIFIED',
            badgeColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 8),
          _buildPromiseCard(
            emoji: '👥',
            title: 'Lifelong Friends & Live Lounges',
            desc:
                'Connect with conversation buddies in real-time coffee tables & voice chat rooms.',
            badge: 'COMMUNITY',
            badgeColor: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 8),
          _buildPromiseCard(
            emoji: '🗣️',
            title: 'Confident Conversational Fluency',
            desc:
                'Overcome speaking fear and master 500+ everyday practical idioms & phrases.',
            badge: 'FLUENCY',
            badgeColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _buildPromiseCard(
            emoji: '👑',
            title: 'Crowns, Ranks & Citadel Growth',
            desc:
                'Collect crowns, level up your avatar, and upgrade your house to a Grand Citadel.',
            badge: 'REWARDS',
            badgeColor: const Color(0xFFA855F7),
          ),
        ],
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 9: Plan Choice (Super vs Free) ---
  Widget _buildStep9PlanChoice() {
    return _buildStepContainer(
      title: 'How do you want to get started?',
      mascotHint: 'Select your preferred experience (change anytime).',
      child: Column(
        children: [
          // Super PoketMates
          _buildOptionCard(
            title: 'Super PoketMates',
            subtitle: 'Unlimited AI calls, faster progress & zero ads.',
            badge: '⚡ PRO',
            badgeColor: const Color(0xFFFACC15),
            leadingEmoji: '👑',
            isSelected: _selectedPlan == 'super',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPlan = 'super');
            },
          ),
          const SizedBox(height: 10),
          // Learn For Free
          _buildOptionCard(
            title: 'Learn for Free',
            subtitle: 'Full learning island, daily streaks & peer chats.',
            badge: '100% FREE',
            badgeColor: const Color(0xFF38BDF8),
            leadingEmoji: '🌱',
            isSelected: _selectedPlan == 'free',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPlan = 'free');
            },
          ),
        ],
      ),
      onContinue: _nextStep,
      buttonText: 'CONTINUE',
    );
  }

  // --- Step 10: Starting Path (Scratch vs Placement) ---
  Widget _buildStep10StartingPath() {
    if (_selectedPath == 'placement_active') {
      return _buildPlacementQuizStep();
    }

    return _buildStepContainer(
      title: 'Where would you like to start?',
      mascotHint: 'Choose your starting point.',
      child: Column(
        children: [
          // Start from Scratch
          _buildOptionCard(
            title: 'Start from scratch',
            subtitle: 'Begin with Day 1 basics: greetings & essentials.',
            leadingEmoji: '🟢',
            isSelected: _selectedPath == 'scratch',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPath = 'scratch');
            },
          ),
          const SizedBox(height: 10),
          // Find my level
          _buildOptionCard(
            title: 'Find my level',
            subtitle:
                'Take a quick 2-minute check to find your starting level.',
            leadingEmoji: '🔵',
            badge: '2-MIN QUIZ',
            badgeColor: const Color(0xFF818CF8),
            isSelected: _selectedPath == 'placement',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPath = 'placement');
            },
          ),
        ],
      ),
      onContinue: () {
        if (_selectedPath == 'placement') {
          setState(() {
            _selectedPath = 'placement_active';
            _quizStep = 0;
            _quizScore = 0;
            _selectedQuizAnswer = null;
          });
        } else {
          _nextStep();
        }
      },
      buttonText: _selectedPath == 'placement' ? 'START QUIZ' : 'CONTINUE',
    );
  }

  // --- Interactive Placement Quiz ---
  Widget _buildPlacementQuizStep() {
    final questionData = _placementQuestions[_quizStep];
    final options = questionData['options'] as List<String>;

    return _buildStepContainer(
      title: 'Placement Check (${_quizStep + 1}/${_placementQuestions.length})',
      mascotHint: questionData['question'] as String,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final isSelected = _selectedQuizAnswer == idx;
              return _buildOptionCard(
                title: options[idx],
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedQuizAnswer = idx);
                },
              );
            },
          ),
        ],
      ),
      onContinue: () {
        if (_selectedQuizAnswer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select an answer to continue')),
          );
          return;
        }

        if (_selectedQuizAnswer == questionData['correct']) {
          _quizScore++;
        }

        if (_quizStep < _placementQuestions.length - 1) {
          setState(() {
            _quizStep++;
            _selectedQuizAnswer = null;
          });
        } else {
          if (_quizScore == 0) {
            _selectedEnglishLevel = 'Level 0: Zero Foundation (ABC അറിയില്ല)';
          } else if (_quizScore == 1) {
            _selectedEnglishLevel =
                'Level 1: Beginner (നിത്യോപയോഗ വാക്കുകൾ)';
          } else if (_quizScore == 2) {
            _selectedEnglishLevel =
                'Level 2: Elementary (ഏകദേശ ജ്ഞാനം, മടിയുള്ളവർ)';
          } else {
            _selectedEnglishLevel =
                'Level 3: Middle (Simple conversations / മിഡിൽ)';
          }
          setState(() => _selectedPath = 'scratch');
          _nextStep();
        }
      },
      buttonText:
          _quizStep == _placementQuestions.length - 1 ? 'FINISH CHECK' : 'NEXT',
    );
  }

  // --- Step 11: Celebration & Save Progress ---
  Widget _buildStep11CelebrationAndSave() {
    return _buildStepContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStarterAvatar(size: 64),
          const SizedBox(height: 14),
          _buildMascotSpeechBubble("You're all set to begin! 🚀"),
          const SizedBox(height: 12),
          Text(
            "Day 1 Streak Started! Save your journey so you never lose your progress:",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFFA1A1AA),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Google 1-Tap Button
          _buildSocialButton(
            label: 'Save with Google',
            iconWidget: const FaIcon(FontAwesomeIcons.google,
                color: Color(0xFFDB4437), size: 19),
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            onPressed: _handleGoogleSignIn,
          ),

          const SizedBox(height: 10),

          // Email Auth Button
          _buildDuolingoOutlineButton(
            label: 'Save with Email',
            onPressed: () {
              setState(() {
                _isSignUpMode = true;
                _mode = WelcomeMode.signIn;
              });
            },
          ),

          const SizedBox(height: 12),

          // Enter as Guest Button
          TextButton(
            onPressed: _finishAsGuest,
            child: Text(
              'CONTINUE AS GUEST 🚀',
              style: GoogleFonts.inter(
                color: const Color(0xFFFACC15),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      showDefaultButton: false,
    );
  }

  // =========================================================================
  // 3. SIGN IN / SIGN UP SCREEN ("I ALREADY HAVE AN ACCOUNT")
  // =========================================================================
  Widget _buildSignInScreen() {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      key: const ValueKey('SignInScreen'),
      children: [
        // 🌌 1. Deep Slate Dark Atmosphere with Gradient & Ambient Orbs
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF070B14),
                ],
              ),
            ),
          ),
        ),

        // Ambient emerald glow at top right
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
            ),
          ),
        ),

        // Ambient cyan glow at bottom left
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0284C7).withValues(alpha: 0.10),
            ),
          ),
        ),

        // 📱 2. Scrollable Form with Keyboard Inset Handling
        Positioned.fill(
          child: SingleChildScrollView(
            controller: _signInScrollController,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20.0,
              topPadding + 62.0,
              20.0,
              24.0 + bottomInset,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xE80F172A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(child: _buildStarterAvatar(size: 68)),
                            const SizedBox(height: 14),
                            Text(
                              _isSignUpMode ? 'Create Account' : 'Welcome Back',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isSignUpMode
                                  ? 'Join PoketMates to protect your streak & live speaking rank'
                                  : 'Log in to continue your daily speaking streak',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFA1A1AA),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Google Sign In
                            _buildSocialButton(
                              label: 'Continue with Google',
                              iconWidget: const FaIcon(
                                FontAwesomeIcons.google,
                                color: Color(0xFFDB4437),
                                size: 19,
                              ),
                              backgroundColor: Colors.white,
                              textColor: Colors.black87,
                              onPressed: _handleGoogleSignIn,
                            ),

                            if (kEnableAppleSignIn) ...[
                              const SizedBox(height: 10),
                              _buildSocialButton(
                                label: 'Sign in with Apple',
                                iconWidget: const FaIcon(
                                  FontAwesomeIcons.apple,
                                  color: Colors.white,
                                  size: 19,
                                ),
                                backgroundColor: const Color(0xFF18181B),
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ],

                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: Color(0xFF27272A))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'OR WITH EMAIL',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF71717A),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                    child: Divider(color: Color(0xFF27272A))),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Error Message Banner
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7F1D1D)
                                      .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFEF4444)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: Color(0xFFFECACA), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFFECACA),
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'name@example.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                              validator: (val) =>
                                  (val == null || !val.contains('@'))
                                      ? 'Valid email required'
                                      : null,
                            ),
                            const SizedBox(height: 12),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleEmailAuth(),
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'Password (min 6 characters)',
                                icon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFFA1A1AA),
                                    size: 19,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (val) =>
                                  (val == null || val.length < 6)
                                      ? 'Password must be 6+ chars'
                                      : null,
                            ),

                            // 📜 Terms & Conditions Checkbox (App Store & Play Store mandatory)
                            if (_isSignUpMode) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                      () => _agreedToTerms = !_agreedToTerms);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(
                                          top: 2, right: 10),
                                      decoration: BoxDecoration(
                                        color: _agreedToTerms
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _agreedToTerms
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF52525B),
                                          width: 1.5,
                                        ),
                                        boxShadow: _agreedToTerms
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF10B981)
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 6,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: _agreedToTerms
                                          ? const Icon(Icons.check_rounded,
                                              color: Colors.white, size: 15)
                                          : null,
                                    ),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'I agree to the ',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFFA1A1AA),
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF38BDF8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => _showTermsSheet(
                                                    isPrivacy: false),
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF38BDF8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => _showTermsSheet(
                                                    isPrivacy: true),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // Submit Button
                            _buildDuolingoButton(
                              label:
                                  _isSignUpMode ? 'CREATE ACCOUNT' : 'LOG IN',
                              backgroundColor: _isSignUpMode
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFFACC15),
                              shadowColor: _isSignUpMode
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFCA8A04),
                              textColor:
                                  _isSignUpMode ? Colors.white : Colors.black,
                              onPressed: _isLoading ? null : _handleEmailAuth,
                            ),

                            const SizedBox(height: 12),

                            // Toggle Sign In vs Sign Up
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isSignUpMode = !_isSignUpMode;
                                    _errorMessage = null;
                                  });
                                },
                                child: Text(
                                  _isSignUpMode
                                      ? 'Already have an account? Sign In'
                                      : "Don't have an account? Sign Up",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFACC15),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // Guest Button
                            Center(
                              child: TextButton(
                                onPressed: _finishAsGuest,
                                child: Text(
                                  'Skip & Continue as Guest 🚀',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFA1A1AA),
                                    fontSize: 12.5,
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
            ),
          ),
        ),

        // 🔙 3. Top Navigation Bar (Back & Brand Pill)
        Positioned(
          top: topPadding + 10,
          left: 16,
          right: 16,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _mode = WelcomeMode.welcome);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      'POKETMATES',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTermsSheet({required bool isPrivacy}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPrivacy
                          ? Icons.privacy_tip_rounded
                          : Icons.gavel_rounded,
                      color: const Color(0xFF10B981),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isPrivacy ? 'Privacy Policy' : 'Terms of Service',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white60),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isPrivacy
                      ? 'PoketMates respects your privacy. We collect minimal account data (email, name, learning preferences) strictly to synchronize your daily streak, calibrate speaking lessons, and match conversation partners. Your audio in live rooms is ephemeral and never recorded or sold to third parties.'
                      : 'By using PoketMates, you agree to treat all language practice partners with respect, follow community guidelines in voice lounges, and refrain from abusive language. Violation of community standards may result in immediate suspension.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA1A1AA),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                _buildDuolingoButton(
                  label: 'I UNDERSTAND',
                  backgroundColor: const Color(0xFF10B981),
                  shadowColor: const Color(0xFF059669),
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _agreedToTerms = true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // REUSABLE UI BUILDERS
  // =========================================================================

  Widget _buildStepContainer({
    String? title,
    String? mascotHint,
    required Widget child,
    VoidCallback? onContinue,
    String buttonText = 'CONTINUE',
    bool showDefaultButton = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (mascotHint != null) ...[
            Row(
              children: [
                _buildStarterAvatar(size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mascotHint,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: child,
            ),
          ),
          if (showDefaultButton && onContinue != null) ...[
            const SizedBox(height: 10),
            _buildDuolingoButton(
              label: buttonText,
              backgroundColor: const Color(0xFF10B981),
              shadowColor: const Color(0xFF059669),
              textColor: Colors.white,
              onPressed: onContinue,
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  // 👤 Starter Avatar Widget
  Widget _buildStarterAvatar({double size = 80}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: const Color(0xFFFACC15), width: size > 40 ? 1.8 : 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFACC15).withValues(alpha: 0.25),
            blurRadius: size * 0.2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: VectorAvatarWidget(
          config: const VectorAvatarConfig(),
          size: size,
          showAura: false,
        ),
      ),
    );
  }

  Widget _buildMascotSpeechBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    String? leadingEmoji,
    IconData? leadingIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E293B)
              : const Color(0xFF141416).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF10B981) : const Color(0xFF27272A),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (leadingEmoji != null) ...[
              Text(leadingEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
            ] else if (leadingIcon != null) ...[
              Icon(leadingIcon,
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFA1A1AA),
                  size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? const Color(0xFF10B981))
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeColor ?? const Color(0xFF10B981),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              color: badgeColor ?? const Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA1A1AA),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFF10B981) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF52525B),
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuolingoButton({
    required String label,
    required Color backgroundColor,
    required Color shadowColor,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: textColor,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuolingoOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF27272A),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFACC15),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFE4E4E7).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetInstructionItem({
    required String stepNumber,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF58CC02),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFFD4D4D8),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromiseCard({
    required String emoji,
    required String title,
    required String desc,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? const Color(0xFF10B981))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: badgeColor ?? const Color(0xFF10B981),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.inter(
                            color: badgeColor ?? const Color(0xFF10B981),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA1A1AA),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFF1E293B).withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 19),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}

/// ☁️ Soft, Puffy Dreamy Cumulus Cloud Clusters for Onboarding House Reveal
class FluffyCloudClusterPainter extends CustomPainter {
  final bool isLeft;
  FluffyCloudClusterPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.94)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final shadowPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final centers = isLeft
        ? [
            Offset(w * 0.15, h * 0.35),
            Offset(w * 0.38, h * 0.28),
            Offset(w * 0.52, h * 0.42),
            Offset(w * 0.25, h * 0.52),
            Offset(w * 0.48, h * 0.62),
            Offset(w * 0.12, h * 0.65),
            Offset(w * 0.32, h * 0.75),
            Offset(w * 0.60, h * 0.25),
          ]
        : [
            Offset(w * 0.85, h * 0.35),
            Offset(w * 0.62, h * 0.28),
            Offset(w * 0.48, h * 0.42),
            Offset(w * 0.75, h * 0.52),
            Offset(w * 0.52, h * 0.62),
            Offset(w * 0.88, h * 0.65),
            Offset(w * 0.68, h * 0.75),
            Offset(w * 0.40, h * 0.25),
          ];

    final radii = [95.0, 115.0, 105.0, 120.0, 110.0, 90.0, 105.0, 100.0];

    for (int i = 0; i < centers.length; i++) {
      canvas.drawCircle(
          Offset(centers[i].dx, centers[i].dy + 8), radii[i], shadowPaint);
    }
    for (int i = 0; i < centers.length; i++) {
      canvas.drawCircle(centers[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
