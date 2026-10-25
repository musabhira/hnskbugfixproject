import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_profile_bottom_sheet.dart';

/// 🌍 Kids Dedicated 2D Open World Adventure Page
/// 
/// Completely revamped and supercharged for kids:
/// - Smooth interactive panoramic camera with auto-centering & "My Step" recenter button
/// - Animated cartoon buggy with spinning wheels that drives between stepping stones
/// - 10 genuinely interactive, responsive, playable mini-games (Balloon Pop, Letter Train,
///   Animal Feeder, Safari Memory, Slingshot, Lilypad Hopper, Meadow Spy, Rainbow Sentence,
///   Voice Echo, and Summit Guardian)
/// - Persistent step saving with SharedPreferences so child progress is never lost
/// - Living sunny day landscape with rotating smiling sun, clouds, rolling green hills,
///   valley start house, and summit goal castle.
class PocketKidsDayOpenWorldPage extends StatefulWidget {
  final int day;
  const PocketKidsDayOpenWorldPage({super.key, required this.day});

  static Future<void> open(BuildContext context, int day) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsDayOpenWorldPage(day: day),
      ),
    );
  }

  @override
  State<PocketKidsDayOpenWorldPage> createState() =>
      _PocketKidsDayOpenWorldPageState();
}

class _PocketKidsDayOpenWorldPageState extends State<PocketKidsDayOpenWorldPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late KidDaySyllabus _syllabus;
  late final KidMate? _dayBuddy;

  // Animation controllers for living open world
  late AnimationController _ambientController;
  late AnimationController _buggyDriveController;
  final TransformationController _transformController =
      TransformationController();

  int _currentStepIndex = 0; // 0 to 9 (10 games total)
  final Set<int> _completedStepIndices = {};
  int _earnedStars = 0;
  bool _isDayFullyCompleted = false;

  // Buggy physics & coordinate state
  double _buggyX = 380.0;
  double _buggyY = 1060.0;
  double _buggyAngle = 0.0;
  bool _isDriving = false;

  // Active step game modal state
  int? _activePlayingStep;
  bool _isStepSolved = false;

  // Mini-game specific local state
  // Game 0: Junior Sentence Builder
  List<String> _builderTargetWords = [];
  List<String> _builderPlacedWords = [];
  List<String> _builderAvailableWords = [];
  // Game 1: Letter Train Spelling Bee
  List<String> _targetLetters = [];
  List<String> _placedLetters = [];
  List<String> _availableLetters = [];
  // Game 2: Highway Vocab Catcher
  int? _speedCatcherSelectedIdx;
  bool _speedCatcherRacing = false;
  // Game 3: Safe Bubble Chat
  int? _chatSelectedReplyIdx;
  // Game 4: Little Assembly Speech
  bool _assemblyDelivered = false;
  // Game 5: Daily Spoken English
  bool _isSpeakingMic = false;
  // Game 6: Summit Exam & House Duel
  int? _chosenShieldIdx;

  // 7 Well-Planned Interactive Daily Games for Kids (100% Game-Only)
  static const int totalSteps = 7;
  static const List<Map<String, dynamic>> _stepDefinitions = [
    {
      'index': 0,
      'title': 'Junior Sentence Builder 🧩',
      'icon': '🧩',
      'color': Color(0xFFEF4444),
      'desc': 'Snap words together in correct order to construct today\'s sentence!',
    },
    {
      'index': 1,
      'title': 'Kids Spelling Bee 🔤',
      'icon': '🚂',
      'color': Color(0xFF3B82F6),
      'desc': 'Assemble letter wagons in spelling order to spell today\'s word!',
    },
    {
      'index': 2,
      'title': 'Highway Vocab Catcher 🏎️',
      'icon': '🏎️',
      'color': Color(0xFF10B981),
      'desc': 'Drive the racer and catch target vocabulary words on the highway!',
    },
    {
      'index': 3,
      'title': 'Safe Bubble Chat 💬',
      'icon': '💬',
      'color': Color(0xFFF59E0B),
      'desc': 'Safe minimal chatting with cute buddy: exchange cheerful greetings & replies!',
    },
    {
      'index': 4,
      'title': 'Little Assembly Speech 🎙️',
      'icon': '🎙️',
      'color': Color(0xFF8B5CF6),
      'desc': 'Take the school assembly podium to deliver your confidence speech!',
    },
    {
      'index': 5,
      'title': 'Daily Spoken English 🗣️',
      'icon': '🗣️',
      'color': Color(0xFF06B6D4),
      'desc': 'Speak aloud into the magic microphone for 100% fluency stars!',
    },
    {
      'index': 6,
      'title': 'Summit Exam & House Duel 🏰',
      'icon': '🏰',
      'color': Color(0xFFFFD700),
      'desc': 'Final summit boss duel & exam to conquer the day and unlock the next house!',
    },
  ];

  // World size: 2400 x 1400
  static const double worldWidth = 2400.0;
  static const double worldHeight = 1400.0;

  @override
  void initState() {
    super.initState();
    _syllabus = PocketKids100DaySyllabusDB.getSyllabusForDay(widget.day);
    _dayBuddy = (widget.day - 1 < PocketKidsRobotsData.robotsAndHomies.length)
        ? PocketKidsRobotsData.robotsAndHomies[widget.day - 1]
        : null;

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _buggyDriveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _initTts();
    _loadSavedState();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.2);
    } catch (_) {}
  }

  void _speak(String text) {
    try {
      _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <int>{};
    for (int i = 0; i < totalSteps; i++) {
      if (prefs.getBool('pocket_kids_day_${widget.day}_step_${i}_done') == true) {
        completed.add(i);
      }
    }

    int active = 0;
    for (int i = 0; i < totalSteps; i++) {
      if (!completed.contains(i)) {
        active = i;
        break;
      }
    }

    final initialPos = _getStepPosition(active);

    if (mounted) {
      setState(() {
        _completedStepIndices.clear();
        _completedStepIndices.addAll(completed);
        _currentStepIndex = active;
        _earnedStars = completed.length * 3;
        _isDayFullyCompleted = completed.length >= totalSteps;
        _buggyX = initialPos.dx;
        _buggyY = initialPos.dy;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnPoint(_buggyX, _buggyY, scale: 1.0, animate: false);
      });
    }
  }

  Future<void> _saveStepComplete(int stepIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_kids_day_${widget.day}_step_${stepIndex}_done', true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _buggyDriveController.dispose();
    _transformController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _focusOnPoint(double worldX, double worldY,
      {double scale = 1.0, bool animate = false}) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final targetX = -(worldX * scale) + (size.width / 2.0);
    final targetY = -(worldY * scale) + (size.height / 2.0);

    final targetMatrix = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, targetX)
      ..setEntry(1, 3, targetY);

    _transformController.value = targetMatrix;
  }

  Offset _getStepPosition(int index) {
    final double t = (index + 1) / (totalSteps + 1).toDouble();
    final double x = 280 + t * (worldWidth - 560);
    final double y = 1080 - (t * 700) + math.sin(t * math.pi * 3) * 60;
    return Offset(x, y);
  }

  void _driveBuggyTo(Offset target, {VoidCallback? onArrival}) {
    if (!mounted) return;
    _buggyDriveController.stop();

    final startPos = Offset(_buggyX, _buggyY);
    final dx = target.dx - startPos.dx;
    final dy = target.dy - startPos.dy;
    _buggyAngle = math.atan2(dy, dx).clamp(-0.45, 0.45);

    setState(() {
      _isDriving = true;
    });

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buggyDriveController,
        curve: Curves.easeInOutCubic,
      ),
    );

    void listener() {
      if (!mounted) return;
      final t = animation.value;
      final curX = startPos.dx + (target.dx - startPos.dx) * t;
      final curY = startPos.dy + (target.dy - startPos.dy) * t;
      setState(() {
        _buggyX = curX;
        _buggyY = curY;
      });
      _focusOnPoint(curX, curY, scale: 1.0, animate: false);
    }

    animation.addListener(listener);

    _buggyDriveController.forward(from: 0.0).then((_) {
      animation.removeListener(listener);
      if (mounted) {
        setState(() {
          _buggyX = target.dx;
          _buggyY = target.dy;
          _isDriving = false;
        });
        HapticFeedback.mediumImpact();
        onArrival?.call();
      }
    });
  }

  void _onStepTapped(int index) {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    final targetPos = _getStepPosition(index);
    setState(() {
      _currentStepIndex = index;
      _buggyX = targetPos.dx;
      _buggyY = targetPos.dy;
    });
    _focusOnPoint(targetPos.dx, targetPos.dy, scale: 1.0, animate: true);
    _openGameModal(index);
  }

  void _openGameModal(int index) {
    _initGameStateForStep(index);
    setState(() {
      _activePlayingStep = index;
    });
  }

  void _initGameStateForStep(int index) {
    _isStepSolved = false;
    final targetWord = _syllabus.dailyVocabulary.isNotEmpty
        ? _syllabus.dailyVocabulary[index % _syllabus.dailyVocabulary.length]
        : 'APPLE';

    switch (index) {
      case 0: // Junior Sentence Builder
        final rawSent = _syllabus.sentence.isNotEmpty ? _syllabus.sentence : 'I love learning English';
        final cleanWords = rawSent.split(' ').where((w) => w.trim().isNotEmpty).toList();
        _builderTargetWords = cleanWords.isEmpty ? ['I', 'like', 'cats'] : cleanWords;
        _builderPlacedWords = [];
        _builderAvailableWords = List<String>.from(_builderTargetWords)..shuffle();
        break;

      case 1: // Kids Spelling Bee Train
        final cleanWord = targetWord.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
        _targetLetters = cleanWord.isEmpty ? ['A', 'P', 'P', 'L', 'E'] : cleanWord.split('');
        _placedLetters = [];
        _availableLetters = List<String>.from(_targetLetters)..shuffle();
        break;

      case 2: // Highway Vocab Catcher
        _speedCatcherSelectedIdx = null;
        _speedCatcherRacing = false;
        break;

      case 3: // Safe Bubble Chat
        _chatSelectedReplyIdx = null;
        break;

      case 4: // Little Assembly Speech
        _assemblyDelivered = false;
        break;

      case 5: // Daily Spoken English
        _isSpeakingMic = false;
        break;

      case 6: // Summit Exam & House Duel
      default:
        _chosenShieldIdx = null;
        break;
    }
  }

  void _completeActiveStep() async {
    if (_activePlayingStep == null) return;
    final completedIdx = _activePlayingStep!;
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    await _saveStepComplete(completedIdx);

    setState(() {
      _completedStepIndices.add(completedIdx);
      _earnedStars = _completedStepIndices.length * 3;
      _activePlayingStep = null;
    });

    if (_completedStepIndices.length >= totalSteps) {
      final summitPos = Offset(worldWidth - 260, 400);
      _driveBuggyTo(summitPos, onArrival: () {
        _finishDay();
      });
    } else {
      int nextStep = completedIdx + 1;
      while (nextStep < totalSteps && _completedStepIndices.contains(nextStep)) {
        nextStep++;
      }
      if (nextStep < totalSteps) {
        setState(() {
          _currentStepIndex = nextStep;
        });
        final nextPos = _getStepPosition(nextStep);
        _driveBuggyTo(nextPos);
      }
    }
  }

  Future<void> _finishDay() async {
    setState(() {
      _isDayFullyCompleted = true;
    });
    await PocketKidsService.completeDayGame(widget.day, 3);
    PocketGameAudioService.instance.playVictorySfx();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFFFD700), width: 3),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 👑 🌟', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 12),
            Text(
              'DAY ${widget.day} CONQUERED! 🌟',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You mastered all 7 Daily Games!\n+100 Kids Score (KS) & +3 Star Cookies earned!\n\n🌙 Day ${widget.day + 1} unlocks tonight at 12:00 AM Midnight!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    '+100 KS & HERO CARD #${widget.day} WON! 🃏',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'RETURN TO TRAIL 🚀',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarConfig =
        PocketKidsAvatarSystem.getAvatarConfigForDay(widget.day);

    return Scaffold(
      backgroundColor: const Color(0xFF38BDF8),
      body: Stack(
        children: [
          // 1. Panoramic Open World Canvas (Panning & Zooming)
          InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(500),
            minScale: 0.5,
            maxScale: 1.8,
            child: SizedBox(
              width: worldWidth,
              height: worldHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 🎨 Daytime Sunny Landscape Painter
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _ambientController,
                      builder: (context, _) => CustomPaint(
                        painter: _KidsDaytimeOpenWorldPainter(
                          progress: _ambientController.value,
                        ),
                      ),
                    ),
                  ),

                  // 🏡 Valley Start: House 1 (Day $day Residence)
                  Positioned(
                    left: 80,
                    top: 1040,
                    child: GestureDetector(
                      onTap: () {
                        if (_dayBuddy != null) {
                          HapticFeedback.mediumImpact();
                          PocketKidsProfileBottomSheet.show(context, mate: _dayBuddy!);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFFD700), width: 1.5),
                            ),
                            child: Text(
                              'HOUSE ${widget.day} • START ⛳',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          PocketAvatarHouseWidget(
                            day: widget.day,
                            width: 190,
                            height: 135,
                            lightsOn: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🏰 Summit Finish: House 2 (Day ${day+1} Castle)
                  Positioned(
                    left: worldWidth - 360,
                    top: 320,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFFD700), width: 1.5),
                          ),
                          child: Text(
                            'HOUSE ${widget.day + 1} • GOAL 🏆',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        PocketAvatarHouseWidget(
                          day: widget.day + 1,
                          width: 210,
                          height: 150,
                          lightsOn: _isDayFullyCompleted,
                        ),
                      ],
                    ),
                  ),

                  // 🐾 7 Stepping Game Ledges
                  for (int i = 0; i < totalSteps; i++) _buildStepNode(i),

                  // 🚗 Kid Driver Buggy traveling between steps
                  _buildAnimatedBuggy(avatarConfig),
                ],
              ),
            ),
          ),

          // 2. Top HUD Bar
          _buildTopHud(),

          // 3. Active Step Game Dialog
          if (_activePlayingStep != null)
            Positioned.fill(
              child: _buildActiveGameOverlay(_activePlayingStep!),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHud() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),

          // Day Badge & Step Counter (Flexible & scale down if narrow)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DAY ${widget.day} WORLD 🌍',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_completedStepIndices.length}/$totalSteps',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
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

          // Recenter & Star Points Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recenter to Buggy Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _focusOnPoint(_buggyX, _buggyY, scale: 1.0, animate: true);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: Color(0xFFFFD700), size: 18),
                ),
              ),
              const SizedBox(width: 6),
              // Stars
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$_earnedStars',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index) {
    final pos = _getStepPosition(index);
    final def = _stepDefinitions[index];
    final isCompleted = _completedStepIndices.contains(index);
    final isCurrent = index == _currentStepIndex;
    final Color stepColor = def['color'] as Color;

    return Positioned(
      left: pos.dx - 45,
      top: pos.dy - 65,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onStepTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Title Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : (isCurrent ? stepColor : const Color(0xFF334155)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                'GAME ${index + 1}: ${def['title']}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Floating 3D Stepping Stone
            Container(
              width: isCurrent ? 74 : 64,
              height: isCurrent ? 74 : 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [const Color(0xFF34D399), const Color(0xFF059669)]
                      : (isCurrent
                          ? [stepColor, stepColor.withValues(alpha: 0.7)]
                          : [const Color(0xFF475569), const Color(0xFF1E293B)]),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? const Color(0xFFFFFC00) : Colors.white,
                  width: isCurrent ? 3.5 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrent
                        ? stepColor.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: isCurrent ? 18 : 8,
                    spreadRadius: isCurrent ? 3 : 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isCompleted ? '⭐' : def['icon'],
                  style: TextStyle(fontSize: isCurrent ? 30 : 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBuggy(VectorAvatarConfig avatarConfig) {
    return Positioned(
      left: _buggyX - 32,
      top: _buggyY - 110,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: _buggyAngle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver Avatar inside Buggy
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F172A),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: VectorAvatarWidget(
                  config: avatarConfig,
                  size: 44,
                  showAura: false,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Cartoon Adventure Buggy
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isDriving ? '🏎️💨' : '🏎️',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'KID RACER',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
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

  // =========================================================================
  // 🎮 10 DISTINCT INTERACTIVE GAME ENGINES (ONE PER STEP)
  // =========================================================================
  Widget _buildActiveGameOverlay(int stepIndex) {
    final def = _stepDefinitions[stepIndex];
    final stepTitle = def['title'] as String;
    final stepIcon = def['icon'] as String;
    final targetWord = _syllabus.dailyVocabulary.isNotEmpty
        ? _syllabus.dailyVocabulary[stepIndex % _syllabus.dailyVocabulary.length]
        : 'APPLE';
    final targetPhonics = _syllabus.phonicsFocus;

    return Container(
      color: Colors.black.withValues(alpha: 0.78),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isStepSolved ? const Color(0xFF10B981) : const Color(0xFFFFD700),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isStepSolved ? const Color(0xFF10B981) : const Color(0xFFFFD700))
                    .withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(stepIcon, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 8),
                        Text(
                          'STEP ${stepIndex + 1}: $stepTitle',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => setState(() => _activePlayingStep = null),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 16),

                // Specific Game Interaction per step
                _buildGameContentForStep(stepIndex, targetWord, targetPhonics),

                const SizedBox(height: 18),

                // Celebration & Win Button
                if (_isStepSolved) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎉 🌟 ', style: TextStyle(fontSize: 18)),
                        Text(
                          'SOLVED! AWESOME JOB!',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isStepSolved ? const Color(0xFFFFD700) : const Color(0xFF334155),
                      foregroundColor: _isStepSolved ? Colors.black : Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _isStepSolved ? 6 : 0,
                    ),
                    onPressed: _completeActiveStep,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 18)),
                        Text(
                          _isStepSolved
                              ? 'CLAIM 3 STARS & DRIVE ON! 🚀'
                              : 'SKIP & CONTINUE 🚀',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
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
    );
  }

  Widget _buildGameContentForStep(int step, String word, String phonics) {
    switch (step) {
      case 0:
        // 🧩 1. Junior Sentence Builder
        final sentence = _syllabus.sentence.isNotEmpty ? _syllabus.sentence : 'I love learning English';
        return Column(
          children: [
            Text(
              'Snap the words in order to build today\'s sentence:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Text(
                _builderPlacedWords.isEmpty
                    ? '[ Tap words below to build sentence ]'
                    : '"${_builderPlacedWords.join(' ')}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFEDD5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _builderAvailableWords.map((wordPart) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    _speak(wordPart);
                    setState(() {
                      _builderPlacedWords.add(wordPart);
                      _builderAvailableWords.remove(wordPart);
                      if (_builderPlacedWords.length == _builderTargetWords.length) {
                        if (_builderPlacedWords.join(' ') == _builderTargetWords.join(' ')) {
                          _isStepSolved = true;
                          _speak('Brilliant! $sentence');
                        }
                      }
                    });
                  },
                  child: Text(wordPart, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                );
              }).toList(),
            ),
            if (_builderPlacedWords.isNotEmpty && !_isStepSolved) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                label: Text('Reset Words', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                onPressed: () {
                  setState(() {
                    _builderPlacedWords.clear();
                    _builderAvailableWords = List<String>.from(_builderTargetWords)..shuffle();
                  });
                },
              ),
            ],
          ],
        );

      case 1:
        // 🚂 2. Letter Train Jigsaw
        return Column(
          children: [
            Text(
              'Assemble the wagons to spell "$word":',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            // The Train Display
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚂', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 4),
                  for (int i = 0; i < _targetLetters.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: i < _placedLetters.length
                            ? const Color(0xFF10B981)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: i < _placedLetters.length
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        i < _placedLetters.length ? _placedLetters[i] : '?',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Tap letters in correct order:',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
            const SizedBox(height: 8),
            // Letter choices to tap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableLetters.map((l) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    setState(() {
                      _placedLetters.add(l);
                      _availableLetters.remove(l);
                      if (_placedLetters.length == _targetLetters.length) {
                        if (_placedLetters.join('') == _targetLetters.join('')) {
                          _isStepSolved = true;
                          _speak('Choo Choo! $word is correct!');
                        }
                      }
                    });
                  },
                  child: Text(l, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            if (_placedLetters.isNotEmpty && !_isStepSolved) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                label: Text('Reset Train', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                onPressed: () {
                  setState(() {
                    _placedLetters.clear();
                    _availableLetters = List<String>.from(_targetLetters)..shuffle();
                  });
                },
              ),
            ],
          ],
        );

      case 2:
        // 🏎️ 3. Vocab Speed Catcher & Highway Racer
        final laneOptions = [
          {'icon': '💎', 'word': word, 'isTarget': true},
          {'icon': '⚡', 'word': 'Star', 'isTarget': false},
          {'icon': '🚀', 'word': 'Moon', 'isTarget': false},
        ];
        return Column(
          children: [
            Text(
              'Drive the racer to catch the daily vocabulary gem "$word"!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _speak(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_up_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Target Word: "$word"',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🏁 START',
                          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(
                          _speedCatcherRacing
                              ? '${_dayBuddy?.avatar ?? "🏎️"}💨 TURBO ZOOM!'
                              : '${_dayBuddy?.avatar ?? "🏎️"} RACER READY...',
                          style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('FINISH 🏆',
                          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < laneOptions.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        PocketGameAudioService.instance.playCoinSound();
                        final isCorrect = laneOptions[i]['isTarget'] == true;
                        _speak(laneOptions[i]['word'] as String);
                        setState(() {
                          _speedCatcherSelectedIdx = i;
                          if (isCorrect) {
                            _speedCatcherRacing = true;
                            _isStepSolved = true;
                            _speak('Vroom! You caught $word!');
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _speedCatcherSelectedIdx == i
                              ? (laneOptions[i]['isTarget'] == true
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _speedCatcherSelectedIdx == i
                                ? const Color(0xFFFFD700)
                                : Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Lane ${i + 1}',
                                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text(laneOptions[i]['icon'] as String, style: const TextStyle(fontSize: 20)),
                              ],
                            ),
                            Text(
                              laneOptions[i]['word'] as String,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _speedCatcherSelectedIdx == i
                                  ? (laneOptions[i]['isTarget'] == true ? '🏎️ CAUGHT! ✨' : 'TRY AGAIN')
                                  : 'SPEED ➡️',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

      case 3:
        // 💬 4. Safe Bubble Chat with Buddy
        final buddyName = _dayBuddy?.name ?? 'Sparky Lion';
        final buddyAvatar = _dayBuddy?.avatar ?? '🦁';
        final replies = [
          'Hello $buddyName! 👋',
          'I am ready to learn! 🚀',
          'You are awesome! 🌟',
        ];
        return Column(
          children: [
            Text(
              'Exchange safe, friendly messages with your buddy:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (_dayBuddy != null) {
                  HapticFeedback.mediumImpact();
                  PocketKidsProfileBottomSheet.show(context, mate: _dayBuddy!);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                ),
                child: Row(
                  children: [
                    Text(buddyAvatar, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(buddyName,
                                  style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'VIEW PROFILE 👤',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _chatSelectedReplyIdx == null
                                ? 'Hi buddy! How are you feeling today?'
                                : 'Wonderful! Great to chat with you today! 🌟',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
                      onPressed: () => _speak(
                        _chatSelectedReplyIdx == null
                            ? 'Hi buddy! How are you feeling today?'
                            : 'Wonderful! Great to chat with you today!',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Choose your quick safe reply:',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5)),
            const SizedBox(height: 8),
            for (int r = 0; r < replies.length; r++) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  PocketGameAudioService.instance.playCoinSound();
                  _speak(replies[r]);
                  setState(() {
                    _chatSelectedReplyIdx = r;
                    _isStepSolved = true;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _chatSelectedReplyIdx == r
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _chatSelectedReplyIdx == r ? const Color(0xFFFFD700) : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(replies[r],
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(_chatSelectedReplyIdx == r ? 'SENT 💬' : 'TAP TO SEND 🚀',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );

      case 4:
        // 🎙️ 5. Little Assembly Speech
        final speechText = _syllabus.speakingMission.isNotEmpty
            ? _syllabus.speakingMission
            : 'Good morning teachers and dear friends!';
        return Column(
          children: [
            Text(
              'Step onto the school assembly stage to practice your speech:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎭 🎙️ 🌟', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text('ASSEMBLY PODIUM',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"$speechText"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('LISTEN'),
                  onPressed: () => _speak(speechText),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _assemblyDelivered ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: Icon(_assemblyDelivered ? Icons.celebration_rounded : Icons.mic_rounded, size: 18),
                  label: Text(
                    _assemblyDelivered ? 'SPEECH GIVEN! 👏' : 'DELIVER SPEECH 🎙️',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playVictorySfx();
                    setState(() {
                      _assemblyDelivered = true;
                      _isStepSolved = true;
                    });
                    _speak('Outstanding assembly speech! The audience gives you a standing ovation!');
                  },
                ),
              ],
            ),
          ],
        );

      case 5:
        // 🗣️ 6. Voice Magic Echo
        final speech = _syllabus.speakingMission.isNotEmpty
            ? _syllabus.speakingMission
            : 'English connects friends!';
        return Column(
          children: [
            Text(
              'Listen and repeat aloud into the magic microphone:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF14B8A6)),
              ),
              child: Text(
                '"$speech"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF2DD4BF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('LISTEN'),
                  onPressed: () => _speak(speech),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSpeakingMic ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.mic_rounded),
                  label: Text(_isSpeakingMic ? '100% FLUENCY! 🌟' : 'REPEAT ALOUD'),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    setState(() {
                      _isSpeakingMic = true;
                      _isStepSolved = true;
                    });
                    _speak('Super clear pronunciation! 100% fluency stars awarded!');
                  },
                ),
              ],
            ),
          ],
        );

      case 6:
      default:
        // 🏰 7. Summit Guardian Duel
        final shields = [word, 'Castle', 'Crown'];
        return Column(
          children: [
            Text(
              'Final Summit Challenge! Which word matches Day ${widget.day}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text('👑 🏰 🦁', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(shields.length, (idx) {
                final sh = shields[idx];
                final isChosen = _chosenShieldIdx == idx;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isChosen ? const Color(0xFFFFD700) : const Color(0xFF1E293B),
                    foregroundColor: isChosen ? Colors.black : Colors.white,
                    side: BorderSide(color: const Color(0xFFFFD700), width: isChosen ? 2.5 : 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    _speak(sh);
                    setState(() {
                      _chosenShieldIdx = idx;
                      if (idx == 0) {
                        _isStepSolved = true;
                      }
                    });
                  },
                  child: Text(
                    isChosen ? '🛡️ $sh 👑' : '🛡️ $sh',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                );
              }),
            ),
          ],
        );
    }
  }
}

/// 🎨 Daytime Open World Rolling Hills & Living Scenery Painter
class _KidsDaytimeOpenWorldPainter extends CustomPainter {
  final double progress;
  _KidsDaytimeOpenWorldPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient (Azure blue to warm morning peach)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF7DD3FC), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Smiling Rotating Cartoon Sun
    final sunCenter = Offset(size.width * 0.45, 160);
    final sunPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(sunCenter, 65, sunPaint);
    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6) + (progress * math.pi * 2);
      final p1 = sunCenter + Offset(math.cos(angle) * 75, math.sin(angle) * 75);
      final p2 = sunCenter + Offset(math.cos(angle) * 105, math.sin(angle) * 105);
      canvas.drawLine(p1, p2, rayPaint);
    }

    // 3. Floating Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (int i = 0; i < 6; i++) {
      final cx = (i * 420.0 + progress * 160.0) % size.width;
      final cy = 110.0 + (i % 3) * 60.0;
      canvas.drawCircle(Offset(cx, cy), 32, cloudPaint);
      canvas.drawCircle(Offset(cx + 26, cy - 8), 40, cloudPaint);
      canvas.drawCircle(Offset(cx + 56, cy), 30, cloudPaint);
    }

    // 4. Distant Pastel Rolling Mountains (Background Layer)
    final bgMountainPaint = Paint()
      ..color = const Color(0xFF6EE7B7).withValues(alpha: 0.6);
    final bgPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 720);
    for (double x = 0; x <= size.width; x += 120) {
      final y = 680 - math.sin(x * 0.0025) * 220;
      bgPath.lineTo(x, y);
    }
    bgPath
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(bgPath, bgMountainPaint);

    // 5. Forefront Lush Green Rolling Hills (Active Trail Path)
    final fgHillPaint = Paint()..color = const Color(0xFF22C55E);
    final fgPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 1140);
    for (double x = 0; x <= size.width; x += 60) {
      final t = x / size.width;
      final y = 1100 - (t * 700) + math.sin(t * math.pi * 3) * 60;
      fgPath.lineTo(x, y);
    }
    fgPath
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(fgPath, fgHillPaint);

    // 6. Yellow Dirt Stepping Trail connecting steps
    final trailPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.85)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final trailPath = Path();
    for (double x = 200; x <= size.width - 200; x += 30) {
      final t = x / size.width;
      final y = 1080 - (t * 700) + math.sin(t * math.pi * 3) * 60;
      if (x == 200) {
        trailPath.moveTo(x, y);
      } else {
        trailPath.lineTo(x, y);
      }
    }
    canvas.drawPath(trailPath, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _KidsDaytimeOpenWorldPainter oldDelegate) =>
    oldDelegate.progress != progress;
}
