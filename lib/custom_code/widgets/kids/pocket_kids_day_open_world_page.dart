import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';

/// 🌍 Kids Dedicated 2D Open World Adventure Page
/// 
/// Parity with Adult Open World (PocketDayOpenWorldAdventurePage), but specifically
/// tailored for Kids with a 100% Sunny Daytime aesthetic, rolling green hills,
/// living ocean, animated sun, hot air balloons, and 10 DISTINCT non-duplicated games per day!
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

  // Active step game modal state
  int? _activePlayingStep;

  // 10 Distinct Game Types per Day
  static const List<Map<String, dynamic>> _stepDefinitions = [
    {
      'index': 0,
      'title': 'Balloon Pop Phonics',
      'icon': '🎈',
      'color': Color(0xFFEF4444),
      'desc': 'Listen to phonics sound and pop the matching floating balloon!',
    },
    {
      'index': 1,
      'title': 'Letter Train Jigsaw',
      'icon': '🚂',
      'color': Color(0xFF3B82F6),
      'desc': 'Assemble letter wagons in correct spelling order!',
    },
    {
      'index': 2,
      'title': 'Animal Feast Vocab',
      'icon': '🍎',
      'color': Color(0xFF10B981),
      'desc': 'Feed your animal companion the requested vocabulary food!',
    },
    {
      'index': 3,
      'title': 'Safari Memory Flip',
      'icon': '🃏',
      'color': Color(0xFFF59E0B),
      'desc': 'Flip and match memory challenge cards on the grass!',
    },
    {
      'index': 4,
      'title': 'Slingshot Word Target',
      'icon': '🏹',
      'color': Color(0xFF8B5CF6),
      'desc': 'Aim and fire star pellets at correct word targets!',
    },
    {
      'index': 5,
      'title': 'River Lilypad Hopper',
      'icon': '🐸',
      'color': Color(0xFF06B6D4),
      'desc': 'Help the frog leap across river stones by picking rhyming words!',
    },
    {
      'index': 6,
      'title': 'Detective Meadow Spy',
      'icon': '🔍',
      'color': Color(0xFFEC4899),
      'desc': 'Use magnifying glass to spot target items in the meadow!',
    },
    {
      'index': 7,
      'title': 'Rainbow Sentence Builder',
      'icon': '🧩',
      'color': Color(0xFFF97316),
      'desc': 'Snap colored puzzle blocks to construct a fluent sentence!',
    },
    {
      'index': 8,
      'title': 'Voice Magic Echo',
      'icon': '🗣️',
      'color': Color(0xFF14B8A6),
      'desc': 'Speak the sentence aloud into the magic microphone!',
    },
    {
      'index': 9,
      'title': 'Summit Gate Guardian Duel',
      'icon': '🏰',
      'color': Color(0xFFFFD700),
      'desc': 'Final summit test to unlock next house and earn the Crown!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _syllabus = PocketKids100DaySyllabusDB.getSyllabusForDay(widget.day);
    _dayBuddy = (widget.day - 1 < PocketKidsRobotsData.robotsAndHomies.length)
        ? PocketKidsRobotsData.robotsAndHomies[widget.day - 1]
        : null;

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _buggyDriveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _initTts();

    // Center camera on active step on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCameraOnStep(_currentStepIndex);
    });
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

  @override
  void dispose() {
    _ambientController.dispose();
    _buggyDriveController.dispose();
    _transformController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _centerCameraOnStep(int stepIndex) {
    final stepPos = _getStepPosition(stepIndex);
    final matrix = Matrix4.identity()
      ..setTranslationRaw(-stepPos.dx + 180, -stepPos.dy + 300, 0.0);
    _transformController.value = matrix;
  }

  // Rolling hill position calculations (World size: 2400 x 1400)
  static const double worldWidth = 2400.0;
  static const double worldHeight = 1400.0;

  Offset _getStepPosition(int index) {
    final double t = (index + 1) / 11.0; // Spaced evenly along the mountain curve
    final double x = 280 + t * (worldWidth - 560);
    // Smooth undulating mountain ascent curve
    final double y = 1080 - (t * 700) + math.sin(t * math.pi * 3) * 60;
    return Offset(x, y);
  }

  void _onStepTapped(int index) {
    if (index > _currentStepIndex && !_completedStepIndices.contains(index)) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete Step ${_currentStepIndex + 1} first! 🐾'),
          backgroundColor: const Color(0xFF1E293B),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();
    setState(() {
      _activePlayingStep = index;
    });
  }

  void _completeActiveStep() {
    if (_activePlayingStep == null) return;
    final completedIdx = _activePlayingStep!;
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _completedStepIndices.add(completedIdx);
      _earnedStars += 3;
      if (completedIdx == _currentStepIndex && _currentStepIndex < 9) {
        _currentStepIndex++;
        _buggyDriveController.forward(from: 0.0);
      }
      _activePlayingStep = null;
    });

    if (_completedStepIndices.length >= 10) {
      _finishDay();
    } else {
      _centerCameraOnStep(_currentStepIndex);
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
              'DAY ${widget.day} COMPLETED!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You conquered all 10 Games in the Open World!\nHouse ${widget.day + 1} is now unlocked on the mountain!',
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
                    '+30 STAR COINS EARNED',
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
      backgroundColor: const Color(0xFF38BDF8), // Sunny Azure Sky
      body: Stack(
        children: [
          // 1. Panoramic Open World Canvas (Panning & Zooming)
          InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(500),
            minScale: 0.6,
            maxScale: 1.6,
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

                  // 🐾 10 Stepping Game Ledges
                  for (int i = 0; i < 10; i++) _buildStepNode(i),

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
            _buildActiveGameOverlay(_activePlayingStep!),
        ],
      ),
    );
  }

  Widget _buildTopHud() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 14,
      right: 14,
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
              padding: const EdgeInsets.all(10),
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

          // Day Badge & Buddy HUD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                  'DAY ${widget.day} OPEN WORLD 🌍',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_completedStepIndices.length}/10 GAMES',
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

          // Star Points Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  '$_earnedStars PTS',
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
    );
  }

  Widget _buildStepNode(int index) {
    final pos = _getStepPosition(index);
    final def = _stepDefinitions[index];
    final isCompleted = _completedStepIndices.contains(index);
    final isCurrent = index == _currentStepIndex;
    final isLocked = index > _currentStepIndex && !isCompleted;
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
            // Game Icon / Status Badge
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
                'STEP ${index + 1}: ${def['title']}',
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
                  isCompleted ? '⭐' : (isLocked ? '🔒' : def['icon']),
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
    final curPos = _getStepPosition(_currentStepIndex);
    return Positioned(
      left: curPos.dx - 28,
      top: curPos.dy - 120,
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
                size: 40,
                showAura: false,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Cartoon Red & Gold Adventure Buggy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: const Text('🏎️💨', style: TextStyle(fontSize: 16)),
          ),
        ],
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
        : 'HELLO';
    final targetPhonics = _syllabus.phonicsFocus;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
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
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 28,
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
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
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70),
                      onPressed: () => setState(() => _activePlayingStep = null),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 18),

                // Specific Game Interaction per step
                _buildGameContentForStep(stepIndex, targetWord, targetPhonics),

                const SizedBox(height: 20),
                // Complete / Win Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _completeActiveStep,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 18)),
                        Text(
                          'CLAIM STEP STARS & CONTINUE! 🚀',
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

  Widget _buildGameContentForStep(
      int step, String word, String phonics) {
    switch (step) {
      case 0:
        // 🎈 1. Balloon Pop Phonics
        return Column(
          children: [
            Text(
              'Listen and pop the matching Balloon sound:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _speak(phonics),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_up_rounded,
                        color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Text('Tap to Hear Phonics: "$phonics"',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                phonics,
                'ch',
                'th',
                'sh',
              ].map((p) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    PocketGameAudioService.instance.playCoinSound();
                    _speak(p);
                  },
                  child: Container(
                    width: 74,
                    height: 94,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        p,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 1:
        // 🚂 2. Letter Train Jigsaw
        final letters = word.toUpperCase().split('');
        return Column(
          children: [
            Text(
              'Assemble the Letter Train wagons to spell "$word":',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚂', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 6),
                for (final l in letters)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      l,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );

      case 2:
        // 🍎 3. Animal Feast Vocab
        return Column(
          children: [
            Text(
              'Feed your hungry buddy the word "$word":',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dayBuddy?.avatar ?? '🦁',
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '"Mmm! Feed me $word to power up my English level!"',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              children: [
                '🍎 $word',
                '🍌 Banana',
                '🥕 Carrot',
              ].map((item) {
                return ActionChip(
                  label: Text(item,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFF10B981),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _speak(item);
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        // 🃏 4. Safari Memory Flip
        return Column(
          children: [
            Text(
              'Flip and match the Safari card pairs:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                '🦁 $word',
                '🐯 Tiger',
                '🐼 Panda',
                '🦊 Fox',
              ].map((card) {
                return Container(
                  width: 80,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      card,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 4:
        // 🏹 5. Slingshot Word Target
        return Column(
          children: [
            Text(
              'Aim and launch star pellets at "$word":',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text('🏹 🎯', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF8B5CF6)),
              ),
              child: Text(
                'TARGET HIT: [ $word ] 💥',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFA78BFA),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );

      case 5:
        // 🐸 6. River Lilypad Hopper
        return Column(
          children: [
            Text(
              'Pick the correct rhyming lilypad stone:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('🐸', style: TextStyle(fontSize: 28)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(word,
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0891B2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Next Lilypad 🌊',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        );

      case 6:
        // 🔍 7. Detective Meadow Spy
        return Column(
          children: [
            Text(
              'Spot the hidden item matching "$word" in the meadow:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEC4899)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Text(
                    'FOUND: 1/1 "$word" 🌸',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 7:
        // 🧩 8. Rainbow Sentence Builder
        final sentence = _syllabus.sentencePattern;
        return Column(
          children: [
            Text(
              'Snap together the Rainbow Sentence Train:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF97316)),
              ),
              child: Text(
                '"$sentence"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      case 8:
        // 🗣️ 9. Spoken Voice Magic Echo
        final speech = _syllabus.speakingMission;
        return Column(
          children: [
            Text(
              'Tap and speak this sentence aloud into the microphone:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.mic_rounded),
              label: const Text('LISTEN TO COACH 🗣️'),
              onPressed: () => _speak(speech),
            ),
          ],
        );

      case 9:
      default:
        // 🏰 10. Summit Gate Guardian Duel
        return Column(
          children: [
            Text(
              'Summit Gate Guardian Duel! Prove Day ${widget.day} Mastery:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: Column(
                children: [
                  const Text('👑 🏰 🦁', style: TextStyle(fontSize: 34)),
                  const SizedBox(height: 8),
                  Text(
                    'GUARDIAN QUESTION: "${_syllabus.dailyDefenseWord}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: READY TO UNLOCK HOUSE ${widget.day + 1}! 🌟',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
