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
import 'package:pocket_mates_app/custom_code/widgets/chat/english_learning_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/anonymous_english_chat_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/pocket_talk_card_swiper_dialog.dart';
import 'pocket_day1_tutor_curriculum.dart';
import 'curriculum_data/day_1_curriculum_data.dart';
import 'curriculum_data/pocket_day_curriculum_service.dart';
import 'curriculum_data/day1_az_and_300vocab_data.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_language_selection_dialog.dart';
import 'pocket_day1_diagnostic_sheet.dart';
import 'pocket_citadel_attack_page.dart';
import 'games/meadow_runner_game_page.dart';
import 'games/word_catcher_game_page.dart';
import 'games/word_catcher_models.dart';

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
  final int day;
  final int initialStep; // 1 to 10
  final Day1Track? initialTrack;
  final String? userId;
  final VoidCallback? onCompleted;
  final Function(int stepIndex)? onStepFinished;
  final bool singleStepOnly;

  const PocketDay1InteractiveFlowPage({
    super.key,
    this.day = 1,
    this.initialStep = 1,
    this.initialTrack,
    this.userId,
    this.onCompleted,
    this.onStepFinished,
    this.singleStepOnly = true,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
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
          day: day,
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
  final Map<int, bool> _completedSteps = {};

  // Native language
  String _nativeLanguage = 'Malayalam';

  // Step 1 Letters Carousel State
  int _letterIndex = 0;
  bool _step1GridView = false;

  // Step 2 Vocab Bank Carousel & Filter State
  int _vocabIndex = 0;
  bool _step2GridView = false;
  String _selectedVocabCategory = 'All';

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
  final Map<int, int> _readingQuizAnswers = {};
  double _storyFontSize = 14.5;
  bool _isStoryNarrating = false;

  // Step 6 Spoken Lab State
  int _spokenChallengeIndex = 0;

  // Audio toggle & auto speech on entry
  bool _autoSpeechEnabled = true;

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
    _loadRuntimeCurriculum();
    _initAudioAndSpeech();
    _loadState();
    _triggerAutoSpeechForStep(_activeStep);
  }

  /// Populates the universal JSON cache before legacy synchronous Day-1
  /// widgets resolve their curriculum data.
  Future<void> _loadRuntimeCurriculum() async {
    try {
      await PocketDayCurriculumService.preloadDay(widget.day);
      if (mounted) setState(() {});
    } catch (_) {
      // The compatibility adapter retains its existing local fallback.
    }
  }

  void _triggerAutoSpeechForStep(int step) {
    if (!_autoSpeechEnabled) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted || !_autoSpeechEnabled) return;
      if (step == 1) {
        final currentLetter = Day1AlphabetData.lettersAtoZ[_letterIndex % Day1AlphabetData.lettersAtoZ.length];
        _speak('${currentLetter['letter']} for ${currentLetter['word']}.');
      } else if (step == 2) {
        final currentWord = Day1VocabBankData.words300[_vocabIndex % Day1VocabBankData.words300.length];
        _speak('${currentWord['word']}.');
      } else if (step == 3) {
        _speak('Game 1: Letter Hunt Run.');
      } else if (step == 4) {
        _speak('Game 2: Word Catcher and Sentence Builder.');
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
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
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

  String? _lastSpokenText;
  DateTime? _lastSpokenTime;

  Future<void> _speak(String text) async {
    final now = DateTime.now();
    // Anti-looping debounce: ignore identical speech requests within 1.5 seconds
    if (_lastSpokenText == text &&
        _lastSpokenTime != null &&
        now.difference(_lastSpokenTime!).inMilliseconds < 1500) {
      return;
    }
    _lastSpokenText = text;
    _lastSpokenTime = now;

    try {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = true);
      await _tts.speak(text);
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 38)),
              const SizedBox(height: 8),
              Text(
                'DAY ${widget.day} COMPLETED! 🌟',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'House 1 Fortified & All Steps Mastered',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'ENTER DAY 2 ➔',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
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
    final steps = Day1Curriculum.getSteps(_currentTrack, widget.day);
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
    final cached = PocketDayCurriculumService.getCachedDay(widget.day);
    final topicEn = cached != null
        ? PocketDayCurriculumService.getLocalizedText(cached['course']?['topic'], lang: 'en')
        : 'BASIC ENGLISH';
    final topicMl = cached != null
        ? PocketDayCurriculumService.getLocalizedText(cached['course']?['topic'], lang: 'ml')
        : 'അടിസ്ഥാന ഇംഗ്ലീഷ്';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAY ${widget.day} • ${topicEn.toUpperCase()}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _nativeLanguage == 'Malayalam'
                      ? topicMl
                      : topicEn,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 3),
                  Text(
                    _nativeLanguage == 'Malayalam' ? 'മലയാളം' : _nativeLanguage,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _autoSpeechEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: _autoSpeechEnabled ? const Color(0xFF10B981) : Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _autoSpeechEnabled ? 'ON' : 'OFF',
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
          const SizedBox(width: 4),
          // More Menu (Track Switcher / Level Check) - compact 3 dots icon!
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 20),
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) async {
              if (val == 'level_check') {
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
              } else if (val == 'switch_track') {
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
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'switch_track',
                child: Row(
                  children: [
                    Text(_currentTrack.badge, style: GoogleFonts.outfit(color: _currentTrack.color, fontWeight: FontWeight.bold, fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.white70),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'level_check',
                child: Row(
                  children: [
                    const Text('🎯 Level Check', style: TextStyle(color: Color(0xFF7DD3FC), fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ],
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
        return widget.day > 1 ? _buildStep1ConceptRoom(step) : _buildStep1Alphabet(step);
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
        return _buildStep9GroupChat(step);
      case 10:
        return _buildStep10HouseDefense(step);
      default:
        return const SizedBox.shrink();
    }
  }

  // -------------------------------------------------------------
  // STEP 1 (DAY > 1): CONCEPT ROOM (Grammar & Spoken Formula)
  // -------------------------------------------------------------
  Widget _buildStep1ConceptRoom(Day1StepModel step) {
    final cached = PocketDayCurriculumService.getCachedDay(widget.day);
    final grammar = cached?['grammarRule'] as Map<String, dynamic>? ?? {};
    final formula = grammar['formula']?.toString() ?? step.titleEn;
    final expEn = PocketDayCurriculumService.getLocalizedText(grammar['explanation'], lang: 'en', fallback: step.descriptionEn);
    final expMl = PocketDayCurriculumService.getLocalizedText(grammar['explanation'], lang: 'ml', fallback: step.descriptionMl);
    final goldenTipEn = PocketDayCurriculumService.getLocalizedText(grammar['goldenTip'], lang: 'en');
    final goldenTipMl = PocketDayCurriculumService.getLocalizedText(grammar['goldenTip'], lang: 'ml');
    final topicEn = PocketDayCurriculumService.getLocalizedText(cached?['course']?['topic'], lang: 'en');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkipOptionBanner(
          text: 'Already master today\'s concept?',
          subtext: 'You can proceed directly to Vocabulary & 2D Arcade Games!',
          onSkip: () => _markStepCompleted(1),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              VectorAvatarWidget(config: VectorAvatarConfig.defaultConfig, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CyberCat Tutor 🐱',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5)),
                    Text(
                      'Day ${widget.day} Concept Room: $topicEn',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
                onPressed: () => _speak('$topicEn. $formula. $goldenTipEn'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8)),
                    ),
                    child: Text('RULE & FORMULA',
                        style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                  const Spacer(),
                  const Text('🏛️', style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formula,
                style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Text(
                expMl,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
              ),
              if (expEn.isNotEmpty && expEn != expMl) ...[
                const SizedBox(height: 8),
                Text(
                  expEn,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, height: 1.4),
                ),
              ],
              if (goldenTipMl.isNotEmpty || goldenTipEn.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goldenTipMl.isNotEmpty ? goldenTipMl : goldenTipEn,
                              style: GoogleFonts.inter(color: const Color(0xFFFFE066), fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            if (goldenTipEn.isNotEmpty && goldenTipMl.isNotEmpty)
                              Text(
                                goldenTipEn,
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 18),
                        onPressed: () => _speak(goldenTipEn.isNotEmpty ? goldenTipEn : formula),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _speak('Awesome! Concept learned. Let us move to Vocabulary.');
              _markStepCompleted(1);
            },
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            label: Text(
              'CONCEPT MASTERED • NEXT STEP ➔',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 1: ALPHABET & PHONICS (With skippable banner)
  // -------------------------------------------------------------
  // -------------------------------------------------------------
  // STEP 1: ALPHABET & PHONICS (Full 26 Letters A-Z with Card Mode)
  // -------------------------------------------------------------
  Widget _buildStep1Alphabet(Day1StepModel step) {
    final letters = Day1AlphabetData.lettersAtoZ;
    final current = letters[_letterIndex.clamp(0, letters.length - 1)];
    final letter = current['letter']?.toString() ?? 'A';
    final sound = current['sound']?.toString() ?? '';
    final word = current['word']?.toString() ?? '';
    final emoji = current['emoji']?.toString() ?? '🍎';
    final meaning = current['meaning'] is Map
        ? Day1CurriculumJsonData.getLocalizedString(current['meaning'], lang: _nativeLanguage)
        : current['meaning']?.toString() ?? '';
    final exEn = current['exampleEn']?.toString() ?? '';
    final exMl = current['exampleMl']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skip Banner
        _buildSkipOptionBanner(
          text: 'Already know ABCD (Alphabet)?',
          subtext: 'You can skip letters and start with vocabulary!',
          onSkip: () => _markStepCompleted(1),
        ),
        const SizedBox(height: 12),

        // Tutor Bar & View Mode Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              VectorAvatarWidget(config: VectorAvatarConfig.defaultConfig, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CyberCat Tutor 🐱',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5)),
                    Text(
                      _step1GridView
                          ? 'Tap any letter in the grid to jump and listen!'
                          : 'Press NEXT to learn each letter and sound!',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _step1GridView ? Icons.view_carousel_rounded : Icons.grid_view_rounded,
                  color: const Color(0xFF38BDF8),
                  size: 22,
                ),
                tooltip: _step1GridView ? 'Card View' : 'Grid View',
                onPressed: () {
                  setState(() => _step1GridView = !_step1GridView);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_step1GridView)
          // 🔠 Full 26 Letters Grid View
          _buildStep1GridView(letters)
        else
          // 📇 Interactive Card Carousel Mode (1 by 1 with Next / Prev)
          _buildStep1CardView(letters, current, letter, sound, word, emoji, meaning, exEn, exMl),
      ],
    );
  }

  Widget _buildStep1CardView(
    List<Map<String, dynamic>> letters,
    Map<String, dynamic> current,
    String letter,
    String sound,
    String word,
    String emoji,
    String meaning,
    String exEn,
    String exMl,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Letter progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'LETTER ${_letterIndex + 1} OF ${letters.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF7DD3FC),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // Pronounce Speaker Button
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 28),
                onPressed: () => _speak('$letter for $word. $sound.'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_letterIndex + 1) / letters.length,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            ),
          ),
          const SizedBox(height: 20),

          // Big Letter Showcase Box
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF7DD3FC), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Phonics Sound Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Text(
              'Sound: $sound',
              style: GoogleFonts.inter(
                color: const Color(0xFFFFD700),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Word & Emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              Text(
                '$letter for $word',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Meaning
          Text(
            meaning,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // Example Sentence Box
          if (exEn.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(
                    '💬 "$exEn"',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFBAE6FD),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (exMl.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      exMl,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 22),

          // ⬅️ PREV and NEXT ➔ Controls
          Row(
            children: [
              // PREV Button
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: _letterIndex > 0
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _letterIndex--;
                          });
                          if (_autoSpeechEnabled) {
                            final prev = letters[_letterIndex];
                            _speak('${prev['letter']} for ${prev['word']}.');
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text('PREV', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),

              // NEXT Button (or FINISH if on Z)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (_letterIndex < letters.length - 1) {
                      setState(() {
                        _letterIndex++;
                      });
                      if (_autoSpeechEnabled) {
                        final next = letters[_letterIndex];
                        _speak('${next['letter']} for ${next['word']}.');
                      }
                    } else {
                      // Finished all 26 letters!
                      _markStepCompleted(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _letterIndex == letters.length - 1
                        ? const Color(0xFF10B981)
                        : const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(
                    _letterIndex == letters.length - 1
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _letterIndex == letters.length - 1 ? 'FINISH LETTERS ✓' : 'NEXT LETTER ➔',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1GridView(List<Map<String, dynamic>> letters) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.88,
          ),
          itemCount: letters.length,
          itemBuilder: (context, index) {
            final item = letters[index];
            final l = item['letter']?.toString() ?? '';
            final em = item['emoji']?.toString() ?? '';
            final w = item['word']?.toString() ?? '';
            final isSelected = index == _letterIndex;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _letterIndex = index;
                  _step1GridView = false;
                });
                _speak('$l for $w.');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white12,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l, style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(em, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      w,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => setState(() => _step1GridView = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Back to Card View'),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getVocabWords() {
    if (widget.day > 1) {
      final cached = PocketDayCurriculumService.getCachedDay(widget.day);
      if (cached != null && cached.containsKey('vocabulary')) {
        final vocab = cached['vocabulary'] as Map<String, dynamic>? ?? {};
        final verbs = vocab['verbs'] as List<dynamic>? ?? [];
        final nouns = vocab['nouns'] as List<dynamic>? ?? [];
        final list = <Map<String, dynamic>>[];
        for (final v in verbs) {
          if (v is Map<String, dynamic>) {
            final word = v['v1']?.toString() ?? '';
            final meaning = PocketDayCurriculumService.getLocalizedText(v['meaning'], lang: _nativeLanguage);
            final forms = 'V1: ${v['v1']} • V2: ${v['v2']} • V3: ${v['v3']}';
            list.add({
              'word': word,
              'phonetic': forms,
              'emoji': '⚡',
              'category': 'Verbs',
              'meaning': meaning,
              'exampleEn': v['example']?.toString() ?? '',
              'exampleMl': v['exampleMl']?.toString() ?? '',
            });
          }
        }
        for (final n in nouns) {
          if (n is Map<String, dynamic>) {
            final word = n['word']?.toString() ?? '';
            final meaning = PocketDayCurriculumService.getLocalizedText(n['meaning'], lang: _nativeLanguage);
            list.add({
              'word': word,
              'phonetic': 'Noun',
              'emoji': '🏷️',
              'category': 'Nouns',
              'meaning': meaning,
              'exampleEn': n['example']?.toString() ?? '',
              'exampleMl': '',
            });
          }
        }
        if (list.isNotEmpty) {
          return [...list, ...Day1VocabBankData.words300];
        }
      }
    }
    return Day1VocabBankData.words300;
  }

  // -------------------------------------------------------------
  // STEP 2: 300+ VOCABULARY WORDS (Interactive Card & Browse Mode)
  // -------------------------------------------------------------
  Widget _buildStep2VocabBank(Day1StepModel step) {
    final allWords = _getVocabWords();
    final filtered = allWords.where((w) {
      final matchesCat = _selectedVocabCategory == 'All' ||
          (w['category']?.toString().toLowerCase() == _selectedVocabCategory.toLowerCase());
      if (!matchesCat) return false;
      if (_vocabSearchQuery.isEmpty) return true;
      final q = _vocabSearchQuery.toLowerCase();
      final wordName = w['word']?.toString().toLowerCase() ?? '';
      final meaningStr = w['meaning']?.toString().toLowerCase() ?? '';
      return wordName.contains(q) || meaningStr.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skip Banner
        _buildSkipOptionBanner(
          text: 'Already know basic vocabulary?',
          subtext: '300+ everyday words! Skip anytime to jump to 2D Arcade Games!',
          onSkip: () => _markStepCompleted(2),
        ),
        const SizedBox(height: 12),

        // Search Bar & View Mode Toggle
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search 300+ words (Water, Food, Bed)...',
                    hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _vocabSearchQuery = val;
                      _vocabIndex = 0;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Toggle Card vs List View
            IconButton(
              icon: Icon(
                _step2GridView ? Icons.view_carousel_rounded : Icons.list_alt_rounded,
                color: const Color(0xFF38BDF8),
                size: 24,
              ),
              tooltip: _step2GridView ? 'Card Mode' : 'List Mode',
              onPressed: () {
                setState(() => _step2GridView = !_step2GridView);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Category Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: Day1VocabBankData.categories.map((cat) {
              final isSel = _selectedVocabCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat),
                  labelStyle: GoogleFonts.outfit(
                    color: isSel ? Colors.black : Colors.white70,
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF1E293B),
                  side: BorderSide(
                    color: isSel ? const Color(0xFFFFD700) : Colors.white10,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedVocabCategory = cat;
                        _vocabIndex = 0;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No words matching "$_vocabSearchQuery"',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              ),
            ),
          )
        else if (_step2GridView)
          // 📋 List Browse Mode
          _buildStep2ListView(filtered)
        else
          // 📇 Interactive Flashcard Mode (One by One with Next ➔)
          _buildStep2CardView(filtered),
      ],
    );
  }

  Widget _buildStep2CardView(List<Map<String, dynamic>> words) {
    final curIdx = _vocabIndex.clamp(0, words.length - 1);
    final current = words[curIdx];
    final word = current['word']?.toString() ?? '';
    final emoji = current['emoji']?.toString() ?? '✨';
    final phonetic = current['phonetic']?.toString() ?? '';
    final category = current['category']?.toString() ?? 'General';
    final meaning = current['meaning']?.toString() ?? '';
    final example = current['example']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Word count progress & speaker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'WORD ${curIdx + 1} OF ${words.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF7DD3FC),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 28),
                onPressed: () => _speak('$word. $example'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (curIdx + 1) / words.length,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            ),
          ),
          const SizedBox(height: 20),

          // Big Emoji & Category
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // English Word
          Text(
            word,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),

          // Phonetic
          Text(
            phonetic,
            style: GoogleFonts.inter(
              color: const Color(0xFFFFD700),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Native Malayalam Meaning
          Text(
            meaning,
            style: GoogleFonts.inter(
              color: const Color(0xFF6EE7B7),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Example Sentence Box
          if (example.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                '💬 "$example"',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFBAE6FD),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 22),

          // ⬅️ PREV and NEXT ➔ Controls
          Row(
            children: [
              // PREV Button
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: curIdx > 0
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _vocabIndex = curIdx - 1;
                          });
                          if (_autoSpeechEnabled) {
                            final prev = words[_vocabIndex];
                            _speak('${prev['word']}.');
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text('PREV', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),

              // NEXT Button (or FINISH if at end)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (curIdx < words.length - 1) {
                      setState(() {
                        _vocabIndex = curIdx + 1;
                      });
                      if (_autoSpeechEnabled) {
                        final next = words[_vocabIndex];
                        _speak('${next['word']}.');
                      }
                    } else {
                      // Finished vocabulary bank!
                      _markStepCompleted(2);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: curIdx == words.length - 1
                        ? const Color(0xFF10B981)
                        : const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(
                    curIdx == words.length - 1
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    curIdx == words.length - 1 ? 'FINISH VOCABULARY ✓' : 'NEXT WORD ➔',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ListView(List<Map<String, dynamic>> words) {
    return Column(
      children: [
        ...words.map((w) {
          final word = w['word']?.toString() ?? '';
          final emoji = w['emoji']?.toString() ?? '✨';
          final phonetic = w['phonetic']?.toString() ?? '';
          final meaning = w['meaning']?.toString() ?? '';
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
                  onPressed: () => _speak('$word. $example'),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => setState(() => _step2GridView = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Back to Card View'),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 3: GAME 1 - 2D OPEN-WORLD MEADOW RUNNER (6 Rounds)
  // -------------------------------------------------------------
  Widget _buildStep3GameHunt(Day1StepModel step) {
    final rounds = (step.data['rounds'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (rounds.isEmpty) return const SizedBox.shrink();

    final screenH = MediaQuery.of(context).size.height;
    final gameH = (screenH * 0.70).clamp(460.0, 620.0);

    return SizedBox(
      height: gameH,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: MeadowRunnerGamePage(
          rounds: rounds,
          initialRound: _huntRound,
          nativeLanguage: _nativeLanguage,
          isFullscreen: false,
          onRoundCompleted: (round) {
            setState(() => _huntRound = round + 1);
          },
          onAllCompleted: () {
            _markStepCompleted(3);
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 4: GAME 2 - 2D WORD CATCHER & SENTENCE BUILDER (6 Rounds)
  // -------------------------------------------------------------
  Widget _buildStep4GameMatchBuild(Day1StepModel step) {
    final rounds = (step.data['rounds'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (rounds.isEmpty) return const SizedBox.shrink();

    final rData = rounds[_matchBuildRound % rounds.length];
    final type = rData['type']?.toString() ?? 'match';
    final prompt = Day1CurriculumJsonData.getLocalizedString(rData['prompt'], lang: _nativeLanguage);

    return Column(
      children: [
        // 🌟 2D Open-World Arcade Launcher Banner ("ആകാശത്തുനിന്നും വീഴുന്ന വാക്കുകൾ പിടിക്കുക")
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0284C7), Color(0xFF10B981)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🎮', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2D OPEN-WORLD WORD CATCHER',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'ആകാശത്തുനിന്നും വീഴുന്ന വാക്കുകൾ ബാസ്കറ്റിൽ പിടിക്കുക! (Full Screen 2D Arcade)',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 22, color: Color(0xFF0F172A)),
                  label: Text(
                    'PLAY FULLSCREEN 2D ARCADE ➔',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.6,
                    ),
                  ),
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordCatcherGamePage(
                          levelData: kWordCatcherLevel1Data,
                          preferredLanguage: _nativeLanguage,
                          onCompleted: (xp) {
                            _markStepCompleted(4);
                          },
                        ),
                      ),
                    );
                    if (result == true) {
                      _markStepCompleted(4);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

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
        const SizedBox(height: 14),

        Text(
          prompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    ),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  if (optStr == correct) {
                    _speak('Correct match! $optStr');
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
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6)),
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
                backgroundColor: const Color(0xFF047857),
                side: const BorderSide(color: Color(0xFF34D399), width: 1.2),
                label: Text(
                  wordStr,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white60, size: 16),
            onPressed: () => setState(() => _assembledWords.clear()),
            label: const Text('Reset Words ↺', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 5: READING ROOM (Story & Audio & Quiz)
  // -------------------------------------------------------------
  // -------------------------------------------------------------
  // STEP 5: READING ROOM (Illustrated Storybook with Art, Audio & Quiz)
  // -------------------------------------------------------------
  Widget _buildStep5ReadingRoom(Day1StepModel step) {
    // 📖 Rich Illustrated Story Data
    final String storyTitleEn;
    final String storyTitleMl;
    final List<Map<String, dynamic>> paragraphs;
    final List<Map<String, dynamic>> comprehensionQuestions;

    if (widget.day > 1) {
      final cached = PocketDayCurriculumService.getCachedDay(widget.day);
      final topic = cached?['course']?['topic'];
      storyTitleEn = PocketDayCurriculumService.getLocalizedText(topic, lang: 'en', fallback: step.titleEn);
      storyTitleMl = PocketDayCurriculumService.getLocalizedText(topic, lang: 'ml', fallback: step.titleMl);

      final sentences = (step.data['sentences'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      paragraphs = sentences.map((s) {
        final en = s['text']?.toString() ?? '';
        final ml = s['meaningMl']?.toString() ?? '';
        final words = en.split(' ').where((w) => w.length > 3).take(3).toList();
        return {
          'en': en,
          'ml': ml,
          'focus': words.isNotEmpty ? words : ['Daily', 'Spoken'],
        };
      }).toList();

      comprehensionQuestions = [
        {
          'id': 1,
          'question': {
            'en': 'What did we read and practice in this lesson?',
            'ml': 'ഈ പാഠത്തിൽ നമ്മൾ എന്ത് വിഷയമാണ് വായിച്ചു പരിശീലിച്ചത്?',
          },
          'options': [storyTitleEn, 'Flying in space', 'Cooking alone'],
          'correctIndex': 0,
          'explanation': 'Focused on today\'s lesson topic.',
        },
        if (sentences.isNotEmpty)
          {
            'id': 2,
            'question': {
              'en': 'Which sentence was read aloud in today\'s passage?',
              'ml': 'ഇന്നത്തെ പാഠത്തിൽ ഉറക്കെ വായിച്ച വാചകം ഏതാണ്?',
            },
            'options': [
              sentences.first['text']?.toString() ?? '',
              'I forgot my homework',
              'The bus left early',
            ],
            'correctIndex': 0,
            'explanation': 'Matches the core spoken sentence practiced.',
          },
      ];
    } else {
      storyTitleEn = 'The Little Fox & The Golden Star';
      storyTitleMl = 'സൗഹൃദ കുറുക്കനും സുവർണ്ണ നക്ഷത്രവും';

      paragraphs = [
        {
          'en': 'Once upon a time, in a peaceful green meadow, lived a small, friendly fox named Oliver. Every night, the bright silver moon illuminated the sleepy valley. Oliver loved watching the peaceful night sky while resting near the ancient oak tree.',
          'ml': 'ഒരിക്കൽ, ശാന്തമായ ഒരു പച്ചപ്പുൽമേട്ടിൽ ഒലിവർ എന്ന കൊച്ചു കുറുക്കൻ താമസിച്ചിരുന്നു. എല്ലാ രാത്രിയിലും വെള്ളിച്ചന്ദ്രൻ താഴ്വരയെ പ്രകാശിപ്പിച്ചു. പുരാതനമായ ഓക്ക് മരത്തിനടുത്ത് ഇരുന്ന് രാത്രിയിലെ ആകാശം കാണാൻ ഒലിവറിന് വളരെ ഇഷ്ടമായിരുന്നു.',
          'focus': ['Fox', 'Meadow', 'Moon', 'Night'],
        },
        {
          'en': 'One warm evening, Oliver walked toward the crystal river to drink fresh, cold water. While drinking, he noticed a magical golden glow dancing between the green leaves of the oak tree. It was not a red apple, and it was not a lamp—it was a twinkling golden star that had fallen softly from the sky!',
          'ml': 'ഒരു ദിവസം വൈകുന്നേരം, ഒലിവർ തെളിഞ്ഞ നദിയിലേക്ക് തണുത്ത വെള്ളം കുടിക്കാൻ നടന്നു. വെള്ളം കുടിക്കുന്നതിനിടയിൽ, ഓക്ക് മരത്തിന്റെ ഇലകൾക്കിടയിൽ ഒരു മാന്ത്രിക സുവർണ്ണ വെളിച്ചം അവൻ കണ്ടു. അതൊരു ചുവന്ന ആപ്പിളോ വിളക്കോ അല്ലായിരുന്നു—ആകാശത്തുനിന്ന് പതിയെ താഴേക്ക് വീണ മിന്നുന്ന ഒരു സുവർണ്ണ നക്ഷത്രമായിരുന്നു അത്!',
          'focus': ['Water', 'Apple', 'Star', 'Tree'],
        },
        {
          'en': "Oliver gently climbed the strong tree branch. 'Hello, little star! Are you hurt?' Oliver asked with a kind smile. The star chimed softly: 'I slipped from the clouds. Can you help me find my way back home?' Oliver smiled warmly: 'Do not worry, my new friend! Together, we will climb to the mountain top where the gentle breeze can lift you back to the sky.'",
          'ml': "ഒലിവർ പതുക്കെ മരത്തിന്റെ കൊമ്പിലേക്ക് കയറി. 'ഹലോ, കൊച്ചു നക്ഷത്രമേ! നിനക്ക് വല്ലതും പറ്റിയോ?' ഒലിവർ സ്നേഹത്തോടെ ചോദിച്ചു. നക്ഷത്രം മണിനാദം പോലെ പറഞ്ഞു: 'ഞാൻ മേഘങ്ങളിൽ നിന്ന് വീണുപോയി. എനിക്ക് തിരികെ വീട്ടിലെത്താൻ സഹായിക്കാമോ?' ഒലിവർ പുഞ്ചിരിച്ചു: 'പേടിക്കണ്ട എന്റെ പുതിയ കൂട്ടുകാരാ! കാറ്റ് നിന്നെ ആകാശത്തേക്ക് ഉയർത്തുന്ന മലമുകളിലേക്ക് നമുക്ക് ഒരുമിച്ച് പോകാം.'",
          'focus': ['Smile', 'Friend', 'Mountain', 'Sky'],
        },
        {
          'en': 'With brave and steady steps, Oliver carried the little star to the windy peak. A soft night breeze embraced them, and the golden star floated gracefully back into the deep blue sky, shining brighter than ever before. Oliver walked back to his warm bed feeling immensely proud and happy, knowing that kindness always lights up the darkest night.',
          'ml': 'ധീരമായ ചുവടുകളോടെ ഒലിവർ കൊച്ചു നക്ഷത്രത്തെ മലമുകളിലെത്തിച്ചു. രാത്രിയിലെ ഇളംകാറ്റ് അവരെ തഴുകി, സുവർണ്ണ നക്ഷത്രം നീലാകാശത്തേക്ക് ഭംഗിയായി ഉയർന്നുപൊങ്ങി. ഒലിവർ തന്റെ കിടക്കയിലേക്ക് മടങ്ങിയെത്തി, കാരുണ്യവും സൗഹൃദവുമാണ് ഏറ്റവും വലിയ വെളിച്ചമെന്ന് മനസ്സിലാക്കി അവൻ സമാധാനമായി ഉറങ്ങി.',
          'focus': ['Bed', 'Happy', 'Kindness', 'Blue'],
        },
      ];

      comprehensionQuestions = [
        {
          'id': 1,
          'question': {
            'en': 'Who is the main hero in the story?',
            'ml': 'കഥയിലെ പ്രധാന കഥാപാത്രം ആരാണ്?',
          },
          'options': ['Oliver the friendly fox 🦊', 'A sleeping giant 🧌', 'A fierce tiger 🐅', 'A noisy crow 🐦‍⬛'],
          'correctIndex': 0,
          'explanation': 'Oliver is the kind, friendly fox living in the meadow.',
        },
        {
          'id': 2,
          'question': {
            'en': 'What was shining between the leaves of the oak tree?',
            'ml': 'ഓക്ക് മരത്തിന്റെ ഇലകൾക്കിടയിൽ തിളങ്ങി നിന്നത് എന്തായിരുന്നു?',
          },
          'options': ['A red apple 🍎', 'A twinkling golden star ⭐', 'A gold pocket watch ⏰', 'A street lamp 💡'],
          'correctIndex': 1,
          'explanation': 'A twinkling golden star that had fallen softly from the sky.',
        },
        {
          'id': 3,
          'question': {
            'en': 'How did Oliver help the little star return home?',
            'ml': 'നക്ഷത്രത്തെ തിരികെ വീട്ടിലെത്താൻ ഒലിവർ എങ്ങനെ സഹായിച്ചു?',
          },
          'options': [
            'Threw it with a slingshot 🎯',
            'Put it in a cardboard box 📦',
            'Guided it to the mountain top for the breeze to lift it 🏔️',
            'Left it in the river water 💧',
          ],
          'correctIndex': 2,
          'explanation': 'Oliver guided the star up the mountain peak where the breeze lifted it back to the sky.',
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🎨 1. Illustrated Book Header & Landscape Art Banner
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B192C)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.65), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beautiful Custom Painted Night Sky & Starlit Oak Tree Scene
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: Container(
                  height: 155,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0A1128), Color(0xFF1C2541), Color(0xFF283655)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Twinkling Stars
                      Positioned(top: 20, left: 40, child: _buildStarDot(size: 6, opacity: 0.8)),
                      Positioned(top: 45, left: 110, child: _buildStarDot(size: 4, opacity: 0.6)),
                      Positioned(top: 25, right: 70, child: _buildStarDot(size: 5, opacity: 0.7)),
                      Positioned(top: 70, right: 140, child: _buildStarDot(size: 4, opacity: 0.5)),
                      Positioned(top: 85, left: 60, child: _buildStarDot(size: 5, opacity: 0.75)),

                      // Glowing Moon
                      Positioned(
                        top: 18,
                        right: 28,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFFFBEB), Color(0xFFFEF08A), Colors.transparent],
                              stops: [0.35, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFEF08A).withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌙', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),

                      // Ancient Oak Tree Art
                      Positioned(
                        left: 20,
                        bottom: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('🌳', style: TextStyle(fontSize: 74)),
                            Transform.translate(
                              offset: const Offset(-20, -38),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                                      blurRadius: 18,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text('⭐', style: TextStyle(fontSize: 28)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Little Fox Looking Up
                      Positioned(
                        right: 80,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🦊', style: TextStyle(fontSize: 42)),
                        ),
                      ),

                      // Floating Golden Banner Tag
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📖', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                'STORYBOOK • CHAPTER 1',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
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

              // Title, Subtitle & Interactive Audio Narration Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storyTitleEn,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _nativeLanguage == 'Malayalam' ? storyTitleMl : 'A magical story of friendship and kindness',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD700),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Audio Controls & Font Size Toolbar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          // Narration Play / Stop Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isStoryNarrating ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            icon: Icon(_isStoryNarrating ? Icons.stop_rounded : Icons.volume_up_rounded, size: 18),
                            label: Text(
                              _isStoryNarrating ? 'STOP' : 'READ ALOUD 🎙️',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              if (_isStoryNarrating) {
                                _tts.stop();
                                setState(() => _isStoryNarrating = false);
                              } else {
                                setState(() => _isStoryNarrating = true);
                                final fullStoryText = paragraphs.map((p) => p['en'] as String).join(' \n\n');
                                _tts.stop();
                                _tts.speak(fullStoryText).then((_) {
                                  if (mounted) setState(() => _isStoryNarrating = false);
                                });
                              }
                            },
                          ),

                          const Spacer(),

                          // Font Sizing Controls (A- / A+)
                          Text(
                            'Font:',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              if (_storyFontSize > 12) setState(() => _storyFontSize -= 1.5);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('A-', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              if (_storyFontSize < 20) setState(() => _storyFontSize += 1.5);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('A+', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 📜 2. Scrollable Story Parchment Book Reader Frame
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✦ ═══ ', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                  Text(
                    'READ THE STORY',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(' ═══ ✦', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 14),

              // Paragraphs List
              ...paragraphs.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final en = p['en'] as String;
                final ml = p['ml'] as String;
                final focusWords = (p['focus'] as List<String>?) ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paragraph Header with TTS play button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Part ${idx + 1}',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF38BDF8),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _tts.stop();
                              _tts.speak(en);
                            },
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            tooltip: 'Listen to Part ${idx + 1}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // English Story Text
                      Text(
                        en,
                        style: GoogleFonts.literata(
                          color: const Color(0xFFF8FAFC),
                          fontSize: _storyFontSize,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Native Meaning in Malayalam
                      Text(
                        ml,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Core Focus Vocabulary Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: focusWords.map((word) {
                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _tts.stop();
                              _tts.speak(word);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    word,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 11),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // 🧠 3. Story Comprehension Quiz Check
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'Story Comprehension Check',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Answer 3 simple questions about Oliver the fox to complete Step 5:',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
              ),
              const SizedBox(height: 16),

              // Quiz Cards
              ...comprehensionQuestions.map((q) {
                final qId = q['id'] as int;
                final qEn = (q['question'] as Map)['en'] as String;
                final qMl = (q['question'] as Map)['ml'] as String;
                final opts = q['options'] as List<String>;
                final correctIdx = q['correctIndex'] as int;
                final selected = _readingQuizAnswers[qId];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q$qId: $qEn',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        qMl,
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 10),

                      ...opts.asMap().entries.map((optEntry) {
                        final optIdx = optEntry.key;
                        final optText = optEntry.value;
                        final isAnswered = selected != null;
                        final isSelected = selected == optIdx;
                        final isCorrect = optIdx == correctIdx;

                        Color btnBg = const Color(0xFF1E293B);
                        Color borderCol = Colors.white12;
                        if (isAnswered) {
                          if (isCorrect) {
                            btnBg = const Color(0xFF065F46);
                            borderCol = const Color(0xFF10B981);
                          } else if (isSelected) {
                            btnBg = const Color(0xFF7F1D1D);
                            borderCol = const Color(0xFFEF4444);
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: btnBg,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: borderCol, width: 1.2),
                              ),
                              elevation: 1,
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _readingQuizAnswers[qId] = optIdx;
                              });
                              if (isCorrect) {
                                _speak('Correct!');
                                if (_readingQuizAnswers.length >= comprehensionQuestions.length &&
                                    _readingQuizAnswers.values.every((v) => true)) {
                                  _markStepCompleted(5);
                                }
                              } else {
                                _speak('Try again!');
                              }
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                optText,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarDot({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: opacity),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
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
                _speak('Great pronunciation!');
                Timer(const Duration(milliseconds: 1400), () {
                  if (_spokenChallengeIndex < challenges.length - 1) {
                    setState(() {
                      _spokenChallengeIndex++;
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
  // STEP 8: POKETALK OR PHONICS MEMORY MATCH
  // -------------------------------------------------------------
  Widget _buildStep8PocketTalk(Day1StepModel step) {
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
                'Poketalk: 4-Day Spoken Pact',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _nativeLanguage == 'Malayalam'
                    ? 'കാർഡുകൾ സ്വൈപ്പ് ചെയ്ത് നിങ്ങളുടെ സ്പോക്കൺ ഇംഗ്ലീഷ് പാർട്ണറെ കണ്ടെത്തുക! 4-ദിവസത്തെ സംസാര പാക്ട് റിക്വസ്റ്റ് അയക്കുക.'
                    : 'Swipe through learner cards and send a 4-Day Spoken English Pact request to find your dedicated practice buddy!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await PocketTalkCardSwiperDialog.show(context);
                    _markStepCompleted(8);
                  },
                  icon: const Icon(Icons.swipe_rounded, size: 18),
                  label: Text('OPEN POKET TALK SWIPER ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 9: ENGLISH HUB LEVEL GROUP CHAT OR AI TUTOR
  // -------------------------------------------------------------
  Widget _buildStep9GroupChat(Day1StepModel step) {
    final isZero = _currentTrack == Day1Track.zero;
    final isMl = _nativeLanguage.toLowerCase().contains('malay');

    if (isZero) {
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
                const Text('🤖', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'AI Tutor Private Practice Lab',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isMl
                      ? 'നിങ്ങളുടെ പേഴ്സണൽ AI റോബോട്ട് ട്യൂട്ടറുമായി വാക്കുകൾ പറഞ്ഞു നോക്കുക. പൂർണ്ണമായും പ്രൈവറ്റ് ആണ്!'
                      : 'Practice speaking basic words with your private AI Robot Tutor in a safe, zero-pressure space.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _speak('Welcome to the private AI speaking lab! Great job practicing today.');
                      _markStepCompleted(9);
                    },
                    icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                    label: Text('START PRIVATE PRACTICE ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
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
            border: Border.all(color: const Color(0xFF6366F1)),
          ),
          child: Column(
            children: [
              const Text('💬', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'English Hub Level Group Chat',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                isMl
                    ? 'ഇംഗ്ലീഷ് ഹബ്ബ് ഗ്രൂപ്പിൽ പ്രവേശിക്കുക! നിങ്ങളുടെ ലെവൽ ഗ്രൂപ്പിലുള്ള കൂട്ടുകാരുമായി ഇന്നത്തെ വാക്കുകൾ ചാറ്റ് ചെയ്തു പരിശീലിക്കുക.'
                    : 'Enter your dedicated English Hub Group Chat! Connect with learners at your level and send messages to build muscle memory.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: const Color(0xFF0F172A),
                          body: EnglishLearningGroupChatWidget(
                            onCancel: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    );
                    _markStepCompleted(9);
                  },
                  icon: const Icon(Icons.forum_rounded, size: 18),
                  label: Text('ENTER ENGLISH HUB GROUP ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 10: FORTIFY HOUSE 1 CITADEL DEFENSE SYSTEM
  // -------------------------------------------------------------
  Widget _buildStep10HouseDefense(Day1StepModel step) {
    final isMl = _nativeLanguage.toLowerCase().contains('malay');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'FORTIFY DAY ${widget.day} CITADEL DEFENSE',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                isMl
                    ? 'നിങ്ങളുടെ വീടിന് ഡിഫെൻസ് സിസ്റ്റം വെക്കണം, അല്ലെങ്കിൽ എതിരാളികൾ വന്ന് നിങ്ങളുടെ വീട് തകർക്കും!'
                    : 'You must set up a defense system for your house, or rivals will raid and destroy your house!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  final myId = widget.userId ?? _supabase.auth.currentUser?.id;
                  if (myId != null && myId.isNotEmpty) {
                    await PocketCitadelAttackPage.openForUser(
                      context,
                      userId: myId,
                      attackerDay: widget.day,
                      isDefenseMode: true,
                    );
                    _markStepCompleted(10);
                  }
                },
                icon: const Icon(Icons.shield_rounded, color: Colors.black, size: 22),
                label: Text(
                  'ENTER DEFENSE SYSTEM ➔',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                    ? (_activeStep < totalSteps ? 'PROCEED ON MAP 🚗 ➔' : 'DAY ${widget.day} COMPLETED ✓')
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
