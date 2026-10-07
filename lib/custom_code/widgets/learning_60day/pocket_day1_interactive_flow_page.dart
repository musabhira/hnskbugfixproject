import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/community_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/anonymous_english_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/pocket_talk_card_swiper_dialog.dart';
import 'pocket_day1_tutor_curriculum.dart';
import 'curriculum_data/day_1_curriculum_data.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_language_selection_dialog.dart';
import 'pocket_day1_diagnostic_sheet.dart';
import 'pocket_level_exam_dialog.dart';

/// 🎮 Dedicated Day 1 Interactive Learning & Game Flow Page
/// 
/// User Audio Directive:
/// 1. Single Unified Track with Diagnostic Pre-Check:
///    - Step 1: Meet Letters & Phonics (can be skipped)
///    - Step 2: 50+ Beginner Vocabularies (can be skipped)
///    - Step 3: Game 1 - Letter & Word Hunt (6 rounds)
///    - Step 4: Game 2 - Match & Sentence Builder (6 rounds)
///    - Step 5: Reading Room - Book reading with audio & mic (6 sentences + 3 quiz)
///    - Step 6: Spoken Speech Lab - 6 Everyday sentences mic practice
///    - Step 7: Random Call Partner (Anonymous English Chat)
///    - Step 8: PocketTalk Mate Request (4-Day Pact card swiper)
///    - Step 9: Community Group Chat (English Hub Intro)
///    - Step 10: House Defense Shield & Citadel Combat + House 1 Gate Exam
/// 2. 100% JSON-Driven: All data comes directly from day_1_curriculum.json
class PocketDay1InteractiveFlowPage extends StatefulWidget {
  final int initialStep; // 1 to 10
  final Day1Track? initialTrack;
  final String? userId;
  final VoidCallback? onCompleted;
  final Function(int stepIndex)? onStepFinished;
  final bool singleStepOnly;

  const PocketDay1InteractiveFlowPage({
    super.key,
    this.initialStep = 1,
    this.initialTrack,
    this.userId,
    this.onCompleted,
    this.onStepFinished,
    this.singleStepOnly = true,
  });

  static Future<void> show(
    BuildContext context, {
    int initialStep = 1,
    Day1Track? initialTrack,
    String? userId,
    VoidCallback? onCompleted,
    Function(int stepIndex)? onStepFinished,
    bool singleStepOnly = true,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDay1InteractiveFlowPage(
          initialStep: initialStep,
          initialTrack: initialTrack,
          userId: userId,
          onCompleted: onCompleted,
          onStepFinished: onStepFinished,
          singleStepOnly: singleStepOnly,
        ),
      ),
    );
  }

  @override
  State<PocketDay1InteractiveFlowPage> createState() =>
      _PocketDay1InteractiveFlowPageState();
}

class _PocketDay1InteractiveFlowPageState
    extends State<PocketDay1InteractiveFlowPage>
    with TickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  late Day1Track _currentTrack;
  late int _activeStep; // 1 to 10
  int _xpEarned = 0;
  final Map<int, bool> _completedSteps = {};

  // Native language
  String _nativeLanguage = 'Malayalam';

  // Animation controllers
  late AnimationController _pulseController;

  // Step 2 Vocab search
  String _vocabSearchQuery = '';

  // Step 3 Hunt State
  int _huntRound = 0;

  // Step 4 Match & Build State
  int _matchBuildRound = 0;
  final List<String> _assembledWords = [];

  // Step 5 Reading Room State
  int _readingSentenceIndex = 0;
  final Map<int, int> _readingQuizAnswers = {};

  // Step 6 Spoken Lab State
  int _spokenChallengeIndex = 0;
  String _lastRecognizedWords = '';
  bool _spokenSuccess = false;

  // Step 10 Defense & Combat State
  final Set<int> _armedGates = {};
  int _botHp = 100;
  bool _botDefeated = false;

  // Audio toggle & auto speech on entry
  bool _autoSpeechEnabled = true;
  bool _isPlayingStory = false;

  @override
  void initState() {
    super.initState();
    _currentTrack = widget.initialTrack ?? Day1Track.middle;
    _activeStep = widget.initialStep.clamp(1, 10);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _speech = stt.SpeechToText();
    _initAudioAndSpeech();
    _loadState();
    _triggerAutoSpeechForStep(_activeStep);
  }

  void _triggerAutoSpeechForStep(int step) {
    if (!_autoSpeechEnabled) return;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || !_autoSpeechEnabled) return;
      if (step == 1) {
        _speak('Letters and Phonics. A for Apple, B for Ball, C for Cat, D for Dog, E for Egg, F for Fish.');
      } else if (step == 2) {
        _speak('Vocabulary Words. Apple, Book, Water, Cat, Dog, Door, Tea, Food, Money, Friend.');
      } else if (step == 3) {
        _speak('Game 1: Letter Hunt Run. Tap the matching letters as fast as you can!');
      } else if (step == 4) {
        _speak('Game 2: Match and Sentence Builder. Build the sentence correctly!');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initAudioAndSpeech() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
    } catch (_) {}

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {}
  }

  Future<void> _loadState() async {
    final lang = PocketLanguageService.currentLanguage;
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    final trackKey = 'pocket_day1_selected_track_${uid ?? "guest"}';
    final savedTrackStr = prefs.getString(trackKey);
    Day1Track resolved = widget.initialTrack ?? Day1Track.middle;
    if (savedTrackStr != null && widget.initialTrack == null) {
      for (final t in Day1Track.values) {
        if (t.name == savedTrackStr) {
          resolved = t;
          break;
        }
      }
    }

    final Map<int, bool> completed = {};
    for (int s = 1; s <= 10; s++) {
      final key = 'pocket_day_${uid ?? "guest"}_1_step_${s}_done';
      completed[s] = prefs.getBool(key) ?? false;
    }

    if (mounted) {
      setState(() {
        _nativeLanguage = lang;
        _currentTrack = resolved;
        _completedSteps.addAll(completed);
      });
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      setState(() => _isSpeaking = true);
      await _tts.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _startListening({required Function(String) onResult}) async {
    HapticFeedback.lightImpact();
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎙️ Microphone simulator active. Great speech!'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      onResult("PASS");
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
          setState(() => _isListening = false);
        }
      },
    );
  }

  Future<void> _markStepCompleted(int stepIndex) async {
    HapticFeedback.heavyImpact();
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    final key = 'pocket_day_${uid ?? "guest"}_1_step_${stepIndex}_done';
    await prefs.setBool(key, true);

    const xp = 30;
    _xpEarned += xp;
    if (uid != null && uid.isNotEmpty) {
      await PocketFortressDefenseService.recordTrainingPoints(xp, uid);
    }

    widget.onStepFinished?.call(stepIndex);

    setState(() {
      _completedSteps[stepIndex] = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Step $stepIndex Completed! +$xp XP 🪙',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    if (stepIndex >= 10) {
      await _onDay1FullyCompleted();
    } else {
      if (widget.singleStepOnly) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Step $stepIndex Done!',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                'Great job! +$xp XP earned. Return to map to see your vehicle drive to Step ${stepIndex + 1}! 🚗',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13.5),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text('PROCEED ON MAP ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _activeStep = (stepIndex + 1).clamp(1, 10);
        });
      }
    }
  }

  Future<void> _onDay1FullyCompleted() async {
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('pocket_day_${uid ?? "guest"}_1_completed', true);
    await prefs.setInt('learning_last_completed_day_${uid ?? "guest"}', 1);
    final now = DateTime.now();
    await prefs.setString(
        'learning_day_${uid ?? "guest"}_1_completed_date', '${now.year}-${now.month}-${now.day}');

    if (uid != null && uid.isNotEmpty) {
      await PocketFortressDefenseService.recordTrainingPoints(150, uid);
    }

    widget.onCompleted?.call();

    if (mounted) {
      _showDay1VictoryDialog();
    }
  }

  void _showDay1VictoryDialog() {
    final summary = Day1Curriculum.getCompletionSummary();
    final bullets = (summary['learnedBullets'] as List<String>?) ?? [];
    final isMl = _nativeLanguage.toLowerCase().contains('malay');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'HOUSE 1 MASTERED!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...bullets.take(4).map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Text('✓ ', style: TextStyle(color: Color(0xFF10B981))),
                      Expanded(
                        child: Text(b, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isMl ? summary['messageMl'] : summary['messageEn'],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF67E8F9), fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text('PROCEED TO HOUSE 2 ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = Day1Curriculum.getSteps(_currentTrack);
    final activeStepData = steps[(_activeStep - 1).clamp(0, steps.length - 1)];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            // Ribbon
            if (!widget.singleStepOnly)
              _buildStepRibbon(steps),

            // Active Step Playground
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStepHeaderCard(activeStepData, steps.length),
                    const SizedBox(height: 16),
                    _buildActiveStepContent(activeStepData),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            _buildBottomActionBar(activeStepData, steps.length),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAY 1: ME + BASIC ENGLISH',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'ഞാനും അടിസ്ഥാന ഇംഗ്ലീഷും',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          // Language selector
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (ctx) => PocketLanguageSelectionDialog(
                  currentLanguage: _nativeLanguage,
                ),
              );
              setState(() {
                _nativeLanguage = PocketLanguageService.currentLanguage;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(_nativeLanguage, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // 🔊 Audio Mute / Unmute Toggle Button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _autoSpeechEnabled = !_autoSpeechEnabled;
                if (!_autoSpeechEnabled) {
                  _tts.stop();
                  _isSpeaking = false;
                } else {
                  _triggerAutoSpeechForStep(_activeStep);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: _autoSpeechEnabled
                    ? const Color(0xFF10B981).withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _autoSpeechEnabled ? const Color(0xFF10B981) : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _autoSpeechEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: _autoSpeechEnabled ? const Color(0xFF10B981) : Colors.white60,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _autoSpeechEnabled ? 'AUDIO' : 'OFF',
                    style: GoogleFonts.outfit(
                      color: _autoSpeechEnabled ? const Color(0xFF10B981) : Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Pre-check button
          GestureDetector(
            onTap: () async {
              final res = await PocketDay1DiagnosticSheet.show(context, userId: widget.userId);
              if (res != null) {
                final skip1 = res['skipStep1'] ?? false;
                final skip2 = res['skipStep2'] ?? false;
                if (skip1 && skip2) {
                  setState(() => _activeStep = 3);
                } else if (skip1) {
                  setState(() => _activeStep = 2);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF38BDF8)),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 3),
                  Text('Level Check', style: GoogleFonts.outfit(color: const Color(0xFF7DD3FC), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // 🚀 3-Track Master Switcher (Zero, Middle, Higher)
          GestureDetector(
            onTap: () async {
              final selected = await showModalBottomSheet<Day1Track>(
                context: context,
                backgroundColor: const Color(0xFF0F172A),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => _buildTrackSelectionModal(),
              );
              if (selected != null && selected != _currentTrack) {
                HapticFeedback.selectionClick();
                final uid = widget.userId ?? _supabase.auth.currentUser?.id;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('pocket_day1_selected_track_${uid ?? "guest"}', selected.name);
                setState(() {
                  _currentTrack = selected;
                  _activeStep = 1;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _currentTrack.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _currentTrack.color, width: 1.2),
              ),
              child: Row(
                children: [
                  Text(
                    _currentTrack.badge,
                    style: GoogleFonts.outfit(
                      color: _currentTrack.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down_rounded, color: _currentTrack.color, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackSelectionModal() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Select Your Track (ലെവൽ മാറ്റുക)',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'നിങ്ങളുടെ അറിവിനനുസരിച്ച് സിലബസും വെല്ലുവിളികളും മാറും:',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ...Day1Track.values.map((t) {
              final isSelected = t == _currentTrack;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => Navigator.pop(context, t),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? t.color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? t.color : Colors.white12, width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            t == Day1Track.zero ? '🌱' : (t == Day1Track.middle ? '🗣️' : '🚀'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.displayNameEn, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(t.displayNameMl, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(t.goalEn, style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: t.color, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRibbon(List<Day1StepModel> steps) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF0F172A),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final stepNum = i + 1;
          final isCurrent = stepNum == _activeStep;
          final isDone = _completedSteps[stepNum] == true;
          final stepData = steps[i];

          Color chipBg = const Color(0xFF1E293B);
          Color border = Colors.white12;
          if (isCurrent) {
            chipBg = const Color(0xFF38BDF8).withValues(alpha: 0.25);
            border = const Color(0xFF38BDF8);
          } else if (isDone) {
            chipBg = const Color(0xFF10B981).withValues(alpha: 0.20);
            border = const Color(0xFF10B981);
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeStep = stepNum);
              _triggerAutoSpeechForStep(stepNum);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: isCurrent ? 1.6 : 1.0),
              ),
              child: Row(
                children: [
                  Text(stepData.icon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    'Step $stepNum',
                    style: GoogleFonts.outfit(
                      color: isCurrent
                          ? const Color(0xFFFFD700)
                          : (isDone ? const Color(0xFF6EE7B7) : Colors.white70),
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                  if (isDone) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 12),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepHeaderCard(Day1StepModel step, int totalSteps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.15),
            const Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF38BDF8)),
            ),
            alignment: Alignment.center,
            child: Text(step.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STEP $_activeStep OF $totalSteps',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (_completedSteps[_activeStep] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'COMPLETED ✓',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.titleEn,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  step.titleMl,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined, color: const Color(0xFFFFD700)),
            onPressed: () => _speak('${step.titleEn}. ${step.descriptionEn}'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ACTIVE STEP CONTENT ROUTER
  // -------------------------------------------------------------
  Widget _buildActiveStepContent(Day1StepModel step) {
    switch (_activeStep) {
      case 1:
        return _buildStep1Alphabet(step);
      case 2:
        return _buildStep2VocabBank(step);
      case 3:
        return _buildStep3GameHunt(step);
      case 4:
        return _buildStep4GameMatchBuild(step);
      case 5:
        return _buildStep5ReadingRoom(step);
      case 6:
        return _buildStep6SpokenLab(step);
      case 7:
        return _buildStep7RandomCall(step);
      case 8:
        return _buildStep8PocketTalk(step);
      case 9:
        return _buildStep9CommunityChat(step);
      case 10:
        return _buildStep10HouseDefense(step);
      default:
        return const SizedBox.shrink();
    }
  }

  // -------------------------------------------------------------
  // STEP 1: ALPHABET & PHONICS (With skippable banner)
  // -------------------------------------------------------------
  Widget _buildStep1Alphabet(Day1StepModel step) {
    final items = (step.data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skip Banner
        _buildSkipOptionBanner(
          text: 'Already know ABCD (Alphabet)?',
          subtext: 'You can skip letters and start with vocabulary!',
          onSkip: () => _markStepCompleted(1),
        ),
        const SizedBox(height: 14),

        // CyberCat greeting
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              VectorAvatarWidget(config: VectorAvatarConfig.defaultConfig, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CyberCat Tutor 🐱', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      'Tap each letter card to hear the sound, word, and native meaning!',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Letter Cards
        ...items.map((item) {
          final letter = item['letter']?.toString() ?? '';
          final sound = item['sound']?.toString() ?? '';
          final word = item['word']?.toString() ?? '';
          final emoji = item['emoji']?.toString() ?? '';
          final voice = item['voice']?.toString() ?? '';
          final meaning = Day1CurriculumJsonData.getLocalizedString(item['meaning'], lang: _nativeLanguage);
          final example = item['example'];
          final exEn = example is Map ? (example['en']?.toString() ?? '') : (example?.toString() ?? '');

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('$letter for $word', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(sound, style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(meaning, style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5)),
                      if (exEn.isNotEmpty)
                        Text('• $exEn', style: GoogleFonts.inter(color: const Color(0xFF7DD3FC), fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700)),
                  onPressed: () => _speak(voice.isNotEmpty ? voice : '$letter. $word.'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: 50+ VOCABULARY WORDS (With skippable banner)
  // -------------------------------------------------------------
  Widget _buildStep2VocabBank(Day1StepModel step) {
    final words = (step.data['words'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final filtered = words.where((w) {
      final name = w['word']?.toString().toLowerCase() ?? '';
      return name.contains(_vocabSearchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skip Banner
        _buildSkipOptionBanner(
          text: 'Already know 50+ basic words?',
          subtext: 'Apple, Book, Water, Grapes, Bed, Crow... Skip to interactive games!',
          onSkip: () => _markStepCompleted(2),
        ),
        const SizedBox(height: 14),

        // Search Bar
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search 50+ words (e.g. Bed, Crow, Water)...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          onChanged: (val) => setState(() => _vocabSearchQuery = val),
        ),
        const SizedBox(height: 12),

        Text(
          '📚 Word Bank (${filtered.length} words):',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Word Grid / List
        ...filtered.map((w) {
          final word = w['word']?.toString() ?? '';
          final emoji = w['emoji']?.toString() ?? '✨';
          final phonetic = w['phonetic']?.toString() ?? '';
          final meaning = Day1CurriculumJsonData.getLocalizedString(w['meaning'], lang: _nativeLanguage);
          final example = w['example']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(word, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(phonetic, style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11)),
                        ],
                      ),
                      Text(meaning, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                      if (example.isNotEmpty)
                        Text(example, style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
                  onPressed: () => _speak(word),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 3: GAME 1 - LETTER & WORD HUNT (6 Rounds)
  // -------------------------------------------------------------
  Widget _buildStep3GameHunt(Day1StepModel step) {
    final rounds = (step.data['rounds'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (rounds.isEmpty) return const SizedBox.shrink();

    final currentRoundData = rounds[_huntRound % rounds.length];
    final prompt = Day1CurriculumJsonData.getLocalizedString(currentRoundData['prompt'], lang: _nativeLanguage);
    final options = (currentRoundData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final correct = currentRoundData['correct']?.toString() ?? '';

    return Column(
      children: [
        // Round Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Text(
            '🔍 ROUND ${_huntRound + 1} OF ${rounds.length}',
            style: GoogleFonts.outfit(color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          prompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),

        // 4 Option Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: options.length,
          itemBuilder: (ctx, idx) {
            final opt = options[idx];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white12),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (opt == correct) {
                  _speak('Correct! $opt');
                  if (_huntRound < rounds.length - 1) {
                    setState(() => _huntRound++);
                  } else {
                    _markStepCompleted(3);
                  }
                } else {
                  _speak('Try again!');
                }
              },
              child: Text(opt, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 4: GAME 2 - MATCH & SENTENCE BUILDER (6 Rounds)
  // -------------------------------------------------------------
  Widget _buildStep4GameMatchBuild(Day1StepModel step) {
    final rounds = (step.data['rounds'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (rounds.isEmpty) return const SizedBox.shrink();

    final rData = rounds[_matchBuildRound % rounds.length];
    final type = rData['type']?.toString() ?? 'match';
    final prompt = Day1CurriculumJsonData.getLocalizedString(rData['prompt'], lang: _nativeLanguage);

    return Column(
      children: [
        // Round Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Text(
            '🧩 CHALLENGE ${_matchBuildRound + 1} OF ${rounds.length} ($type)',
            style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          prompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        if (type == 'match') ...[
          // Match Object options
          ...((rData['options'] as List?) ?? []).map((opt) {
            final optStr = opt.toString();
            final correct = rData['correct']?.toString() ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  if (optStr == correct) {
                    _speak('Correct match!');
                    if (_matchBuildRound < rounds.length - 1) {
                      setState(() => _matchBuildRound++);
                    } else {
                      _markStepCompleted(4);
                    }
                  } else {
                    _speak('Incorrect! Try again.');
                  }
                },
                child: Text(optStr, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ] else ...[
          // Sentence builder
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Text(
              _assembledWords.isEmpty ? 'Tap words below in order...' : _assembledWords.join(' '),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),

          // Scrambled word chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ((rData['scrambled'] as List?) ?? []).map((w) {
              final wordStr = w.toString();
              return ActionChip(
                backgroundColor: const Color(0xFF334155),
                label: Text(wordStr, style: const TextStyle(color: Colors.white, fontSize: 14)),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _assembledWords.add(wordStr);
                  });
                  final currentSentence = _assembledWords.join(' ');
                  final expected = rData['expected']?.toString() ?? '';
                  if (currentSentence == expected) {
                    _speak('Sentence complete: $expected');
                    _assembledWords.clear();
                    if (_matchBuildRound < rounds.length - 1) {
                      setState(() => _matchBuildRound++);
                    } else {
                      _markStepCompleted(4);
                    }
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _assembledWords.clear()),
            child: const Text('Reset Words ↺', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 5: READING ROOM (Story & Audio & Quiz)
  // -------------------------------------------------------------
  Widget _buildStep5ReadingRoom(Day1StepModel step) {
    final passage = step.data['passage'] as Map<String, dynamic>? ?? {};
    final title = Day1CurriculumJsonData.getLocalizedString(passage['bookTitle'], lang: _nativeLanguage);
    final sentences = (passage['sentences'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final questions = (passage['comprehensionQuestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Storybook Reading', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 26),
                onPressed: () {
                  final allText = sentences.map((s) => s['en']).join(' ');
                  _speak(allText);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sentences with audio
        ...sentences.asMap().entries.map((entry) {
          final idx = entry.key;
          final s = entry.value;
          final en = s['en']?.toString() ?? '';
          final ml = Day1CurriculumJsonData.getLocalizedString(s, lang: _nativeLanguage);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF06B6D4),
                  child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(en, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(ml, style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
                  onPressed: () => _speak(en),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),
        Text('Comprehension Check:', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),

        // Quiz Questions
        ...questions.map((q) {
          final qId = q['id'] as int? ?? 1;
          final qText = Day1CurriculumJsonData.getLocalizedString(q['question'], lang: _nativeLanguage);
          final opts = (q['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
          final correctIdx = q['correctIndex'] as int? ?? 0;
          final selected = _readingQuizAnswers[qId];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qText, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...opts.asMap().entries.map((optEntry) {
                  final optIdx = optEntry.key;
                  final optText = optEntry.value;
                  final isAnswered = selected != null;
                  final isSelected = selected == optIdx;
                  final isCorrect = optIdx == correctIdx;

                  Color btnBg = const Color(0xFF0F172A);
                  if (isAnswered) {
                    if (isCorrect) btnBg = const Color(0xFF10B981);
                    if (isSelected && !isCorrect) btnBg = Colors.redAccent;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _readingQuizAnswers[qId] = optIdx;
                        });
                        if (isCorrect) {
                          _speak('Correct!');
                          if (_readingQuizAnswers.length >= questions.length) {
                            _markStepCompleted(5);
                          }
                        } else {
                          _speak('Incorrect! Try again.');
                        }
                      },
                      child: Align(alignment: Alignment.centerLeft, child: Text(optText)),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 6: SPOKEN LAB (6 Challenges with Mic)
  // -------------------------------------------------------------
  Widget _buildStep6SpokenLab(Day1StepModel step) {
    final challenges = (step.data['challenges'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (challenges.isEmpty) return const SizedBox.shrink();

    final c = challenges[_spokenChallengeIndex % challenges.length];
    final phrase = c['phrase']?.toString() ?? '';
    final phonetic = c['phonetic']?.toString() ?? '';
    final meaning = Day1CurriculumJsonData.getLocalizedString(c['meaning'], lang: _nativeLanguage);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B5CF6)),
          ),
          child: Text(
            '🎙️ CHALLENGE ${_spokenChallengeIndex + 1} OF ${challenges.length}',
            style: GoogleFonts.outfit(color: const Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                phrase,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(phonetic, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              Text(meaning, style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Mic Button
        GestureDetector(
          onTap: () {
            _speak(phrase);
            _startListening(
              onResult: (words) {
                setState(() {
                  _lastRecognizedWords = words;
                  _spokenSuccess = true;
                });
                _speak('Great pronunciation!');
                Timer(const Duration(milliseconds: 1400), () {
                  if (_spokenChallengeIndex < challenges.length - 1) {
                    setState(() {
                      _spokenChallengeIndex++;
                      _spokenSuccess = false;
                    });
                  } else {
                    _markStepCompleted(6);
                  }
                });
              },
            );
          },
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.redAccent : const Color(0xFF8B5CF6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isListening ? 'Listening... Speak phrase!' : 'Tap mic and speak aloud',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 7: RANDOM CALL PARTNER OR ROBOT PRACTICE
  // -------------------------------------------------------------
  Widget _buildStep7RandomCall(Day1StepModel step) {
    if (_currentTrack == Day1Track.zero) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Column(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(
                  'Tutor Robot Voice Practice',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'ലളിതമായ വാക്കുകൾ റോബോട്ടിനൊപ്പം സ്വകാര്യമായി പറഞ്ഞു ശീലിക്കുക. ആരും കേൾക്കില്ല, പേടിയില്ലാതെ സംസാരിക്കാം!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: ['Apple 🍎', 'Water 💧', 'Ball ⚽', 'Book 📖'].map((w) {
                    return ActionChip(
                      backgroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      label: Text(w, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () => _speak(w.split(' ').first),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _speak('Great job! You spoke wonderful English with the robot!');
                    _markStepCompleted(7);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text('COMPLETE ROBOT PRACTICE ✓', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnonymousEnglishChatPage()),
                    );
                  },
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white54),
                  label: Text('Try Real Partner Call (Optional)', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8)),
          ),
          child: Column(
            children: [
              const Text('📞', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'Live Random Partner Call',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Connect anonymously with a real English learning partner from Kerala/India to practice speaking today’s words!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnonymousEnglishChatPage()),
                  );
                  _markStepCompleted(7);
                },
                icon: const Icon(Icons.phone_in_talk_rounded),
                label: Text('START CALL NOW ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 8: POCKET TALK OR PHONICS MEMORY MATCH
  // -------------------------------------------------------------
  Widget _buildStep8PocketTalk(Day1StepModel step) {
    if (_currentTrack == Day1Track.zero) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Column(
              children: [
                const Text('🧩', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(
                  'Phonics & Word Memory Match',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'അക്ഷരങ്ങളും ശബ്ദങ്ങളും തിരിച്ചറിഞ്ഞ് മെമ്മറി ഉറപ്പിക്കുക. ടാപ്പ് ചെയ്ത് ഉച്ചാരണം കേൾക്കൂ!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPhonicsMatchTile('A', '🍎 Apple', () => _speak('A for Apple')),
                    _buildPhonicsMatchTile('B', '⚽ Ball', () => _speak('B for Ball')),
                    _buildPhonicsMatchTile('C', '🐱 Cat', () => _speak('C for Cat')),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _speak('Excellent! Memory match complete!');
                    _markStepCompleted(8);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text('COMPLETE MEMORY MATCH ✓', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () async {
                    await PocketTalkCardSwiperDialog.show(context);
                  },
                  icon: const Icon(Icons.swipe_rounded, size: 16, color: Colors.white54),
                  label: Text('Browse PocketTalk Mates (Optional)', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Column(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'PocketTalk: 4-Day Spoken Pact',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Swipe through learner cards and send a 4-Day Spoken English Pact request to find your dedicated practice buddy!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await PocketTalkCardSwiperDialog.show(context);
                  _markStepCompleted(8);
                },
                icon: const Icon(Icons.swipe_rounded),
                label: Text('OPEN POCKETTALK SWIPER ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhonicsMatchTile(String letter, String word, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B)),
        ),
        child: Column(
          children: [
            Text(letter, style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(word, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 9: COMMUNITY GROUP CHAT
  // -------------------------------------------------------------
  Widget _buildStep9CommunityChat(Day1StepModel step) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6366F1)),
          ),
          child: Column(
            children: [
              const Text('💬', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'English Hub Group Chat',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Step into the community room and post your Day 1 English introduction message!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CommunityChatPage()),
                  );
                  _markStepCompleted(9);
                },
                icon: const Icon(Icons.forum_rounded),
                label: Text('ENTER COMMUNITY ROOM ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 10: HOUSE DEFENSE SHIELD & CITADEL COMBAT
  // -------------------------------------------------------------
  Widget _buildStep10HouseDefense(Day1StepModel step) {
    final traps = (step.data['defenseTraps'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final combat = step.data['combatTest'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Combat Test
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.redAccent),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('⚔️ Combat Test: Iron Citadel Bot', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('HP: $_botHp / 100', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: _botHp / 100.0, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Colors.redAccent)),
              const SizedBox(height: 12),
              Text(
                Day1CurriculumJsonData.getLocalizedString(combat['challenge'], lang: _nativeLanguage),
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ((combat['options'] as List?) ?? []).map((opt) {
                  final optStr = opt.toString();
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                    onPressed: () {
                      if (optStr == combat['correct']) {
                        setState(() {
                          _botHp = 0;
                          _botDefeated = true;
                        });
                        _speak('Critical attack! Citadel Bot Defeated!');
                      } else {
                        _speak('Deflected! Try again.');
                      }
                    },
                    child: Text(optStr),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text('🛡️ Equip 5 Defense Traps:', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),

        // 5 Defense Traps
        ...traps.asMap().entries.map((entry) {
          final idx = entry.key;
          final trap = entry.value;
          final q = Day1CurriculumJsonData.getLocalizedString(trap['question'], lang: _nativeLanguage);
          final opts = (trap['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
          final correctIdx = trap['correctIndex'] as int? ?? 0;
          final isArmed = _armedGates.contains(idx);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isArmed ? const Color(0xFF10B981) : Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GATE ${idx + 1}', style: GoogleFonts.outfit(color: isArmed ? const Color(0xFF10B981) : const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
                    if (isArmed) const Text('ARMED ✓', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                Text(q, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: opts.asMap().entries.map((oEntry) {
                    final oIdx = oEntry.key;
                    final oText = oEntry.value;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isArmed && oIdx == correctIdx ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        if (oIdx == correctIdx) {
                          setState(() => _armedGates.add(idx));
                          _speak('Trap Armed!');
                        }
                      },
                      child: Text(oText, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),
        // Big Exam Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final passed = await PocketLevelExamDialog.show(context, level: 1);
              if (passed == true) {
                await _onDay1FullyCompleted();
              }
            },
            icon: const Icon(Icons.school_rounded),
            label: Text('TAKE HOUSE 1 GATE EXAM (8 Qs) 🎓 ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipOptionBanner({
    required String text,
    required String subtext,
    required VoidCallback onSkip,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                Text(subtext, style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onSkip,
            child: const Text('SKIP ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(Day1StepModel step, int totalSteps) {
    final isDone = _completedSteps[_activeStep] == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF101726),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          if (!widget.singleStepOnly && _activeStep > 1)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
              onPressed: () => setState(() => _activeStep--),
            ),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _markStepCompleted(_activeStep),
              icon: Icon(isDone ? Icons.check_circle_rounded : Icons.star_rounded),
              label: Text(
                isDone
                    ? (_activeStep < totalSteps ? 'PROCEED ON MAP 🚗 ➔' : 'DAY 1 COMPLETED ✓')
                    : 'COMPLETE STEP $_activeStep (+30 XP)',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          if (!widget.singleStepOnly && _activeStep < totalSteps) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
              onPressed: () => setState(() => _activeStep++),
            ),
          ],
        ],
      ),
    );
  }
}
