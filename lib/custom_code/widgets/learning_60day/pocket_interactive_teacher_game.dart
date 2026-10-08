import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_syllabus_repository.dart';
import 'pocket_day1_tutor_curriculum.dart';

/// 🎙️ Dynamic Voice Option
class TeacherVoiceOption {
  final String label;
  final String locale;
  final double pitch;
  final double rate;
  final String? voiceName;

  const TeacherVoiceOption({
    required this.label,
    required this.locale,
    required this.pitch,
    required this.rate,
    this.voiceName,
  });
}

/// 🎮 Bright & Vibrant Interactive Speaking Tutor & Game Page
/// User Directive:
/// - "ടാർഗറ്റ് പേജിലേക്ക് വന്നു കഴിഞ്ഞാൽ 6 സിലബസ് ഉണ്ട്... ടൂട്ടർ പഠിപ്പിച്ചു കൊടുക്കുന്ന പോലെ..."
/// - "ഒന്നാമത്തെ ഡേ നമ്മൾ എന്താണ് പഠിപ്പിച്ചു കൊടുക്കുക എന്നുള്ളത് പ്ലാൻ ചെയ്യുക..."
/// - "വോയ്സ് സ്പീക്ക് ചെയ്തിട്ട് ഗെയിം കളിച്ചുകൊണ്ട് പഠിപ്പിക്കുന്ന പോലെ ആയിരിക്കണം... ഫ്ലെയിം ഗെയിം പോലെ..."
class PocketInteractiveTeacherGamePage extends StatefulWidget {
  final int day;
  final String? userId;
  final LearnerLevel? initialLevel;
  final VoidCallback onCompleted;

  const PocketInteractiveTeacherGamePage({
    super.key,
    required this.day,
    this.userId,
    this.initialLevel,
    required this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    String? userId,
    LearnerLevel? initialLevel,
    required VoidCallback onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketInteractiveTeacherGamePage(
          day: day,
          userId: userId,
          initialLevel: initialLevel,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketInteractiveTeacherGamePage> createState() =>
      _PocketInteractiveTeacherGamePageState();
}

/// Backward compatibility alias
typedef PocketInteractiveTeacherGameModal = PocketInteractiveTeacherGamePage;

class _PocketInteractiveTeacherGamePageState
    extends State<PocketInteractiveTeacherGamePage>
    with TickerProviderStateMixin {
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _showMalayalam = true;

  // Active Learner Level (Zero to Expert)
  LearnerLevel _currentLevel = LearnerLevel.zero;
  DayTutorLesson get _currentLesson =>
      PocketDay1TutorCurriculum.getLesson(_currentLevel, widget.day);

  // Curated natural voices
  List<TeacherVoiceOption> _availableVoices = [
    const TeacherVoiceOption(
        label: 'CyberCat (Playful Tutor) 🐱',
        locale: 'en-US',
        pitch: 1.25,
        rate: 0.44),
    const TeacherVoiceOption(
        label: 'Maya (Warm & Natural) 👩‍🏫',
        locale: 'en-US',
        pitch: 1.05,
        rate: 0.44),
    const TeacherVoiceOption(
        label: 'Emma (British Accent) 🇬🇧',
        locale: 'en-GB',
        pitch: 1.02,
        rate: 0.43),
    const TeacherVoiceOption(
        label: 'Alex (Friendly Male) 👨‍🏫',
        locale: 'en-US',
        pitch: 0.94,
        rate: 0.45),
  ];
  int _selectedVoiceIndex = 0;

  // Conversation turns:
  // 0: Greeting & Opening Check (Name / First Sound / Reflex)
  // 1: Master Formula / Concept breakdown with interactive bricks
  // 2: Real Usage & Deepening with examples
  // 3: Spoken Repeat Challenge
  // 4: Interactive Game Challenge (Bubble Pop, Train Puzzle, Reflex Gym, etc.)
  // 5: Victory celebration & +30 PS
  int _turnIndex = 0;

  String _userName = '';
  final TextEditingController _textInputCtrl = TextEditingController();

  // Active Game Coaching Safari State (User Directive: "കളിപ്പിച്ചുകൊണ്ട് പഠിപ്പിക്കുക")
  int _bubbleSafariStep = 0; // 0: Apple (A), 1: Ball (B), 2: Cat (C), 3: Victory
  bool _balloonReady = false; // true after user speaks/selects word, prompts to pop balloon
  int _safariXp = 0; // 0, 10, 20, 30 XP
  String? _lastPoppedId;

  // Spoken recognition feedback
  String _recognizedWords = '';
  bool _spokeCorrectly = false;

  // Turn 4 Game State
  // Bubble Pop game state
  String _selectedBubbleId = '';
  bool _bubblePopped = false;

  // Sentence Train state
  final List<String> _trainSelected = [];
  bool _trainError = false;

  // Reflex Timer state
  Timer? _reflexTimer;
  double _reflexProgress = 1.0;
  bool _reflexFailed = false;
  bool _reflexSuccess = false;

  // Bridge connector state
  String _selectedConnector = '';
  bool _bridgeLocked = false;

  // Boardroom diplomacy state
  int _selectedBoardroomOption = -1;
  bool _boardroomSuccess = false;

  // Debate rebuttal state
  bool _debateRecorded = false;
  int _debateSecondsRemaining = 30;
  Timer? _debateTimer;

  late final AnimationController _pulseCtrl;
  late final AnimationController _ambientGameCtrl;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _ambientGameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _initApp();
  }

  Future<void> _initApp() async {
    await _initLevelAndContent();
    await _initSpeechRecognizer();
    await _initTts();
    if (mounted) {
      if (_safariStages.isNotEmpty) {
        _speak(_safariStages[0]['introVoice'] as String);
      } else {
        _speak(_currentLesson.teacherGreetingEn);
      }
    }
  }

  Future<void> _initLevelAndContent() async {
    if (widget.initialLevel != null) {
      if (mounted) setState(() => _currentLevel = widget.initialLevel!);
    } else {
      final saved = await PocketSyllabusRepository.getSavedLevel();
      if (mounted) setState(() => _currentLevel = saved);
    }
  }

  Future<void> _initSpeechRecognizer() async {
    try {
      final available = await _speech.initialize(
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {}
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.44);
      await _tts.setPitch(1.22);
      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}

    // Query extra voices in background without blocking initial speech
    _tts.getVoices.then((rawVoices) {
      if (!mounted) return;
      if (rawVoices is List && rawVoices.isNotEmpty) {
        final List<TeacherVoiceOption> dynamicList = [];
        for (var v in rawVoices) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';
            if (locale.startsWith('en') &&
                (name.contains('natural') ||
                    name.contains('local') ||
                    name.contains('neural') ||
                    name.contains('female'))) {
              dynamicList.add(
                TeacherVoiceOption(
                  label: name.contains('female')
                      ? 'Natural Voice 🎙️'
                      : 'Smooth English 🗣️',
                  locale: locale,
                  pitch: 1.05,
                  rate: 0.44,
                  voiceName: name,
                ),
              );
            }
          }
        }
        if (dynamicList.isNotEmpty && mounted) {
          setState(() {
            _availableVoices = [...dynamicList.take(2), ..._availableVoices];
          });
        }
      }
    }).catchError((_) {});
  }

  Future<void> _applyVoice() async {
    final v = _availableVoices[_selectedVoiceIndex];
    try {
      await _tts.setLanguage(v.locale);
      await _tts.setSpeechRate(v.rate);
      await _tts.setPitch(v.pitch);
      if (v.voiceName != null) {
        await _tts.setVoice({'name': v.voiceName!, 'locale': v.locale});
      }
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.setVolume(1.0); // User Audio Directive: TTS voice must never be silenced by background music muting!
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _startListening({required Function(String) onResult}) async {
    HapticFeedback.lightImpact();
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('🎙️ Please type below or tap options if microphone is busy.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await _tts.stop();
    setState(() {
      _isListening = true;
      _recognizedWords = '';
    });
    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedWords = result.recognizedWords;
            });
            if (result.finalResult || result.recognizedWords.isNotEmpty) {
              onResult(result.recognizedWords);
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _reflexTimer?.cancel();
    _debateTimer?.cancel();
    _pulseCtrl.dispose();
    _ambientGameCtrl.dispose();
    _textInputCtrl.dispose();
    super.dispose();
  }

  void _switchSyllabusTrack(LearnerLevel level) async {
    HapticFeedback.selectionClick();
    await PocketSyllabusRepository.saveLevel(level);
    setState(() {
      _currentLevel = level;
      _turnIndex = 0;
      _userName = '';
      _textInputCtrl.clear();
      _recognizedWords = '';
      _spokeCorrectly = false;
      _selectedBubbleId = '';
      _bubblePopped = false;
      _trainSelected.clear();
      _trainError = false;
      _selectedConnector = '';
      _bridgeLocked = false;
      _selectedBoardroomOption = -1;
      _boardroomSuccess = false;
      _debateRecorded = false;
      _bubbleSafariStep = 0;
      _balloonReady = false;
      _safariXp = 0;
      _lastPoppedId = null;
    });
    if (_safariStages.isNotEmpty) {
      _speak(_safariStages[0]['introVoice'] as String);
    } else {
      _speak(_currentLesson.teacherGreetingEn);
    }
  }

  void _advanceTurn(int next) {
    HapticFeedback.mediumImpact();
    setState(() => _turnIndex = next);

    switch (next) {
      case 1:
        _speak(_currentLesson.turn1TeacherVoiceEn);
        break;
      case 2:
        _speak(_currentLesson.turn2TeacherVoiceEn);
        break;
      case 3:
        _speak(
            "Now repeat after me: ${_currentLesson.turn3TargetPhrase}! Tap the microphone and say it aloud.");
        break;
      case 4:
        _startTurn4Game();
        break;
      case 5:
        _speak(
            "Outstanding job! You completed Day 1 like a champion! +30 Pocket Score earned!");
        _awardScore();
        break;
    }
  }

  void _startTurn4Game() {
    _speak(_currentLesson.gameInstructionEn);
    if (_currentLesson.gameType == Day1GameType.rapidReflexTimer) {
      _startReflexTimer();
    } else if (_currentLesson.gameType == Day1GameType.debateRebuttalArena) {
      _startDebateTimer();
    }
  }

  void _startReflexTimer() {
    _reflexTimer?.cancel();
    setState(() {
      _reflexProgress = 1.0;
      _reflexFailed = false;
      _reflexSuccess = false;
    });
    const interval = Duration(milliseconds: 50);
    final totalMs =
        ((_currentLesson.gameData['timerSeconds'] as int? ?? 3) * 1000);
    int elapsedMs = 0;

    _reflexTimer = Timer.periodic(interval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      elapsedMs += 50;
      final remaining = (totalMs - elapsedMs) / totalMs;
      if (remaining <= 0) {
        timer.cancel();
        if (!_reflexSuccess) {
          setState(() {
            _reflexProgress = 0.0;
            _reflexFailed = true;
          });
          HapticFeedback.vibrate();
          _speak("Time is up! Tap 'Count me in' to try again!");
        }
      } else {
        setState(() => _reflexProgress = remaining);
      }
    });
  }

  void _startDebateTimer() {
    _debateTimer?.cancel();
    setState(() {
      _debateSecondsRemaining = 30;
      _debateRecorded = false;
    });
    _debateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_debateSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _debateSecondsRemaining = 0);
      } else {
        setState(() => _debateSecondsRemaining--);
      }
    });
  }

  Future<void> _awardScore() async {
    final uid = widget.userId;
    try {
      await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: Stack(
        children: [
          // 1. ☀️ Open-World Animated Landscape Canvas (Vibrant Azure Sky, Sun, Fluffy Drifting Clouds, Alpine Mountains & Rolling Green Meadows)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientGameCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TutorOpenWorldCanvasPainter(
                    gameTime: _ambientGameCtrl.value * 10.0,
                  ),
                );
              },
            ),
          ),

          // 2. Interactive Tutor Content Overlay (Light, vibrant, conversational!)
          SafeArea(
            child: Column(
              children: [
                // Top Bright Nav Bar with Syllabus Switcher & Voice Switcher
                _buildTopBar(),

                // Conversational Canvas
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // Warm, smiling Teacher Avatar with Live Speech Bubble
                        _buildTutorHero(),

                        const SizedBox(height: 14),

                        // Interactive Stage Card (Bright & Frosted Glass)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          child: _buildCurrentTurnCard(),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Control Action Bar
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final curVoice = _availableVoices[_selectedVoiceIndex];
    final lesson = _currentLesson;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A), size: 18),
            onPressed: () => Navigator.pop(context),
          ),

          // 📚 Syllabus Track Switcher Menu (6 Syllabuses)
          PopupMenuButton<LearnerLevel>(
            tooltip: 'Switch Syllabus Track',
            initialValue: _currentLevel,
            onSelected: (lvl) => _switchSyllabusTrack(lvl),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: lesson.primaryColor, width: 1.5),
            ),
            itemBuilder: (ctx) => LearnerLevel.values.map((lvl) {
              final track = PocketSyllabusRepository.getTrack(lvl);
              final isSel = lvl == _currentLevel;
              return PopupMenuItem<LearnerLevel>(
                value: lvl,
                child: Row(
                  children: [
                    Icon(
                      isSel
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSel ? track.primaryColor : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.badgeText,
                            style: GoogleFonts.outfit(
                              color: isSel ? track.primaryColor : Colors.black87,
                              fontWeight:
                                  isSel ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            track.nameEn,
                            style: GoogleFonts.inter(
                              color: Colors.black54,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: lesson.primaryColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: lesson.primaryColor.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(lesson.icon, color: lesson.primaryColor, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    lesson.levelBadge,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: lesson.primaryColor, size: 18),
                ],
              ),
            ),
          ),
          const Spacer(),

          // 🎙️ Voice Switcher Menu
          PopupMenuButton<int>(
            tooltip: 'Choose Natural Tutor Voice',
            initialValue: _selectedVoiceIndex,
            onSelected: (idx) async {
              HapticFeedback.selectionClick();
              setState(() => _selectedVoiceIndex = idx);
              await _applyVoice();
              _speak("Hello! I am ready to teach you English today.");
            },
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
            itemBuilder: (ctx) => List.generate(
              _availableVoices.length,
              (i) => PopupMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    Icon(
                      _selectedVoiceIndex == i
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: _selectedVoiceIndex == i
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _availableVoices[i].label,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontWeight: _selectedVoiceIndex == i
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.record_voice_over_rounded,
                      color: Color(0xFF0284C7), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    curVoice.label.split(' ')[0],
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Malayalam helper toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showMalayalam = !_showMalayalam);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _showMalayalam
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showMalayalam
                      ? const Color(0xFF10B981)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                'മലയാളം',
                style: GoogleFonts.notoSansMalayalam(
                  color: _showMalayalam
                      ? const Color(0xFF047857)
                      : const Color(0xFF64748B),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorHero() {
    final lesson = _currentLesson;
    final speechText = _getTutorSpeechForTurn();
    final subText = _getMalayalamSubTextForTurn();
    final evolutionAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(widget.day);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: lesson.primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: lesson.primaryColor.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Evolved Companion AI Tutor Avatar with breathing scale & bobbing float animation
          AnimatedBuilder(
            animation: Listenable.merge([_pulseCtrl, _ambientGameCtrl]),
            builder: (ctx, _) {
              final scale = 1.0 + (_pulseCtrl.value * 0.04);
              final bobY = math.sin(_ambientGameCtrl.value * 2 * math.pi) * 3.0;
              return Transform.translate(
                offset: Offset(0, bobY),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [lesson.primaryColor, lesson.secondaryColor],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _isSpeaking
                              ? lesson.primaryColor.withValues(alpha: 0.5)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: _isSpeaking ? 20 : 10,
                          spreadRadius: _isSpeaking ? 4 : 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: VectorAvatarWidget(
                        config: evolutionAvatar,
                        size: 72,
                        showAura: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Speech Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'CyberCat • Day ${widget.day} Tutor 🎓',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: lesson.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_isSpeaking)
                      Row(
                        children: List.generate(
                          4,
                          (i) {
                            final animPhase =
                                (_ambientGameCtrl.value * 4 + (i * 0.25)) % 1.0;
                            final barHeight =
                                6.0 + (math.sin(animPhase * math.pi) * 10.0);
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 3,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: lesson.primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _speak(speechText),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: lesson.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          size: 16,
                          color: lesson.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  speechText,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_showMalayalam && subText.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subText,
                    style: GoogleFonts.notoSansMalayalam(
                      color: const Color(0xFF475569),
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _safariStages {
    if (_currentLesson.safariStages.isNotEmpty) {
      return _currentLesson.safariStages;
    }
    final fallbackLesson = PocketDay1TutorCurriculum.getLesson(LearnerLevel.zero, widget.day);
    return fallbackLesson.safariStages;
  }

  String _getTutorSpeechForTurn() {
    if (_safariStages.isNotEmpty) {
      if (_bubbleSafariStep >= _safariStages.length) {
        final listStr = _safariStages.map((s) => "${s['letter']} for ${s['word']}").join(", ");
        return "Hooray! 🏆 You learned and popped $listStr! +30 Pocket Score earned!";
      }
      final cur = _safariStages[_bubbleSafariStep];
      return _balloonReady
          ? cur['praiseVoice'] as String
          : cur['introVoice'] as String;
    }
    final l = _currentLesson;
    switch (_turnIndex) {
      case 0:
        return l.turn0PromptEn;
      case 1:
        return l.turn1TeacherVoiceEn;
      case 2:
        return l.turn2TeacherVoiceEn;
      case 3:
        return "Now say it with me aloud: '${l.turn3TargetPhrase}'! Tap the microphone!";
      case 4:
        return l.gameInstructionEn;
      case 5:
        return l.victorySubtitleEn;
      default:
        return "";
    }
  }

  String _getMalayalamSubTextForTurn() {
    if (_safariStages.isNotEmpty) {
      if (_bubbleSafariStep >= _safariStages.length) {
        final listMl = _safariStages.map((s) => "${s['letter']} ഫോർ ${s['word']}").join(", ");
        return "നിങ്ങൾ $listMl സംസാരിച്ചു വിജയിച്ചു! +30 പോക്കറ്റ് സ്കോർ നേടി!";
      }
      final cur = _safariStages[_bubbleSafariStep];
      return _balloonReady
          ? cur['praiseVoiceMl'] as String
          : cur['introVoiceMl'] as String;
    }
    final l = _currentLesson;
    switch (_turnIndex) {
      case 0:
        return l.turn0PromptMl;
      case 1:
        return l.turn1TeacherVoiceMl;
      case 2:
        return l.turn2TeacherVoiceMl;
      case 3:
        return "${l.turn3DisplayPhraseMl} എന്ന് ഉറക്കെ പറയൂ. മൈക്ക് ബട്ടണിൽ തൊട്ട് സംസാരിക്കുക:";
      case 4:
        return l.gameInstructionMl;
      case 5:
        return l.victorySubtitleMl;
      default:
        return "";
    }
  }

  Widget _buildCurrentTurnCard() {
    if (_safariStages.isNotEmpty) {
      return _buildLevelZeroCoachedGame();
    }
    switch (_turnIndex) {
      case 0:
        return _buildTurn0Card();
      case 1:
        return _buildTurn1FormulaCard();
      case 2:
        return _buildTurn2DeepeningCard();
      case 3:
        return _buildTurn3SpeakingCard();
      case 4:
        return _buildTurn4GameRouter();
      case 5:
        return _buildTurn5VictoryCard();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLevelZeroCoachedGame() {
    if (_bubbleSafariStep >= _safariStages.length) {
      final letterDetails = _safariStages.map((s) => "${s['letter']} for ${s['word']}").join(", ");
      return Container(
        key: const ValueKey('level0_victory'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                ),
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'DAY ${widget.day} CHAMPION! 🌟',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You spoke & popped $letterDetails with CyberCat!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _safariStages.map((s) {
                return _buildCompletedLetterChip(
                  "${s['badge'] ?? '🔤'} ${s['word']} ${s['emoji'] ?? ''}".trim(),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💎', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '+30 Pocket Score Earned',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFB45309),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCompleted();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏔️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'CLIMB TO STEP 2 ➔',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final cur = _safariStages[_bubbleSafariStep];
    final Color letterColor = cur['color'] as Color;
    final String letter = cur['letter'] as String;
    final String word = cur['word'] as String;
    final String emoji = cur['emoji'] as String;
    final String phonics = cur['phonics'] as String;
    final bubbles = (cur['bubbles'] as List).cast<Map<String, dynamic>>();

    return Column(
      key: ValueKey('zero_stage_$_bubbleSafariStep'),
      children: [
        // 1. 🎮 OPEN-WORLD GAME HUD (Day Safari, Hearts, XP)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🌳 DAY ${widget.day} PHONICS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0284C7),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Glowing Hearts
                  const Row(
                    children: [
                      Text('❤️', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 2),
                      Text('❤️', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 2),
                      Text('❤️', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // XP Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 3),
                        Text(
                          '$_safariXp/30 XP',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Track Bar
              Row(
                children: List.generate(_safariStages.length, (idx) {
                  final isDone = idx < _bubbleSafariStep;
                  final isCurrent = idx == _bubbleSafariStep;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          right: idx == _safariStages.length - 1 ? 0 : 6),
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF10B981)
                            : (isCurrent
                                ? letterColor
                                : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. 🅰️ COACHED TEACHING CARD (Letter, Word, Phonics Sound)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: letterColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: letterColor.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: letterColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: letterColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cur['badge'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$letter is for $word $emoji',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _showMalayalam
                              ? '$letter എന്നാൽ $word'
                              : 'Letter sound: $phonics',
                          style: GoogleFonts.notoSansMalayalam(
                            color: const Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Replay Voice Button
                  GestureDetector(
                    onTap: () => _speak("$letter is for $word"),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: letterColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.volume_up_rounded,
                          color: letterColor, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 3. 🎙️ SPEAKING COACH AREA
              if (!_balloonReady) ...[
                Text(
                  'What is $letter for? Say "$word" $emoji',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Glowing Animated Mic Button
                GestureDetector(
                  onTap: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening(onResult: (spoken) {
                        final lower = spoken.toLowerCase();
                        if (lower.contains(word.toLowerCase()) || spoken.isNotEmpty) {
                          setState(() {
                            _balloonReady = true;
                            _spokeCorrectly = true;
                          });
                          _speak(cur['praiseVoice'] as String);
                        }
                      });
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (ctx, _) {
                      final scale =
                          _isListening ? 1.0 + (_pulseCtrl.value * 0.08) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isListening
                                  ? [
                                      const Color(0xFFEF4444),
                                      const Color(0xFFF97316)
                                    ]
                                  : [letterColor, letterColor.withValues(alpha: 0.8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isListening
                                    ? const Color(0xFFEF4444)
                                        .withValues(alpha: 0.5)
                                    : letterColor.withValues(alpha: 0.4),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isListening ? 'Listening...' : 'Tap Mic & Say: "$word" $emoji',
                  style: GoogleFonts.inter(
                    color: _isListening
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // Quick Tap Accessible Option Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.volume_up_rounded, size: 14),
                      label: Text('$word $emoji',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 12.5)),
                      backgroundColor: letterColor.withValues(alpha: 0.10),
                      side: BorderSide(color: letterColor.withValues(alpha: 0.35)),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _balloonReady = true;
                          _spokeCorrectly = true;
                        });
                        _speak(cur['praiseVoice'] as String);
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.touch_app_rounded, size: 14),
                      label: Text('$letter for $word',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 12.5)),
                      backgroundColor: letterColor.withValues(alpha: 0.10),
                      side: BorderSide(color: letterColor.withValues(alpha: 0.35)),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _balloonReady = true;
                          _spokeCorrectly = true;
                        });
                        _speak(cur['praiseVoice'] as String);
                      },
                    ),
                  ],
                ),
              ] else ...[
                // User Spoke Correctly Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF047857), size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Heard: "$word"! Now pop the balloon below! 🎈',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF047857),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. 🎈 FLOATING BALLOONS GAME ARENA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎈', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'FIND & POP: $word $emoji',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0284C7),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Floating Bubbles
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: bubbles.map((b) {
                  final id = b['id'] as String;
                  final label = b['label'] as String;
                  final isTarget = b['isTarget'] == true;
                  final isPopped = _lastPoppedId == id;

                  return AnimatedBuilder(
                    animation: _ambientGameCtrl,
                    builder: (ctx, _) {
                      final floatY = math.sin((_ambientGameCtrl.value * math.pi * 2) +
                              id.hashCode) *
                          5.0;
                      return Transform.translate(
                        offset: Offset(0, floatY),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            if (isTarget) {
                              setState(() => _lastPoppedId = id);
                              _speak("Pop! Correct, that is $word! +10 XP!");
                              Future.delayed(const Duration(milliseconds: 1200), () {
                                if (!mounted) return;
                                setState(() {
                                  _safariXp += 10;
                                  _bubbleSafariStep++;
                                  _balloonReady = false;
                                  _lastPoppedId = null;
                                });
                                if (_bubbleSafariStep < _safariStages.length) {
                                  _speak(_safariStages[_bubbleSafariStep]['introVoice'] as String);
                                } else {
                                  _awardScore();
                                  _speak("Outstanding job! You learned your letters and sounds by playing with CyberCat! +30 Pocket Score awarded!");
                                }
                              });
                            } else {
                              _speak("Not that one. Find and pop the $word $emoji balloon!");
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: isPopped
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF0F9FF),
                              border: Border.all(
                                color: isPopped
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFF38BDF8),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7)
                                      .withValues(alpha: 0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isPopped ? '💥' : '🎈',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isPopped
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                _balloonReady
                    ? 'Tap the $word $emoji balloon to pop it! 🎈'
                    : 'Say "$word" or tap a chip first to unlock!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: _balloonReady
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedLetterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================================================================
  // TURN 0: WARMUP / DIAGNOSTIC
  // =========================================================================
  Widget _buildTurn0Card() {
    final l = _currentLesson;

    return Container(
      key: ValueKey('turn0_${_currentLevel.name}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: l.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: l.primaryColor.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Featured Visual Lesson Badge (e.g. 🅰️ This is A. A for Apple! 🍎)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  l.primaryColor.withValues(alpha: 0.12),
                  l.secondaryColor.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: l.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [l.primaryColor, l.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: l.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentLevel == LearnerLevel.zero ? '🅰️' : '🗣️',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherGreetingEn,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (_showMalayalam) ...[
                        const SizedBox(height: 3),
                        Text(
                          l.teacherGreetingMl,
                          style: GoogleFonts.notoSansMalayalam(
                            color: const Color(0xFF059669),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Replay Voice Button (Listen to CyberCat say it aloud!)
          InkWell(
            onTap: () => _speak(l.teacherGreetingEn),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: l.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: l.primaryColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Replay Voice ("${l.teacherGreetingEn}")',
                    style: GoogleFonts.inter(
                      color: l.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Spoken Prompt & Mic Button
          Text(
            l.turn0HintEn,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Big Glowing Mic Button
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening(onResult: (spoken) {
                  final lower = spoken.toLowerCase();
                  bool matched = false;
                  for (final kw in l.turn0ExpectedKeywords) {
                    if (lower.contains(kw.toLowerCase())) matched = true;
                  }
                  if (matched || spoken.isNotEmpty) {
                    setState(() {
                      _userName = spoken.trim();
                      _spokeCorrectly = true;
                    });
                    _speak("Purr-fect! You said it like a champion!");
                  }
                });
              }
            },
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (ctx, _) {
                final scale = _isListening ? 1.0 + (_pulseCtrl.value * 0.08) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFEF4444), const Color(0xFFF97316)]
                            : [l.primaryColor, l.secondaryColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isListening
                              ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                              : l.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isListening
                ? 'Listening to your voice...'
                : (_userName.isNotEmpty
                    ? '✓ Heard: "$_userName"'
                    : 'Tap Mic & Say: "${l.turn0Suggestions.first}"'),
            style: GoogleFonts.inter(
              color: _isListening
                  ? const Color(0xFFDC2626)
                  : (_userName.isNotEmpty
                      ? const Color(0xFF059669)
                      : const Color(0xFF64748B)),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // Quick tap chips (Spoken shadow chips)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: l.turn0Suggestions.map((sug) {
              return ActionChip(
                avatar: const Icon(Icons.volume_up_rounded, size: 14),
                label: Text(
                  sug,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                backgroundColor: l.primaryColor.withValues(alpha: 0.10),
                side: BorderSide(color: l.primaryColor.withValues(alpha: 0.35)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _userName = sug;
                    _spokeCorrectly = true;
                  });
                  _speak(sug);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TURN 1: FORMULA / CONCEPT BREAKDOWN
  // =========================================================================
  Widget _buildTurn1FormulaCard() {
    final l = _currentLesson;

    return Container(
      key: ValueKey('turn1_${_currentLevel.name}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: l.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: l.primaryColor.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l.turn1TitleEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: l.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_showMalayalam)
            Text(
              l.turn1TitleMl,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansMalayalam(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          const SizedBox(height: 14),

          // Formula Bricks
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: l.turn1FormulaBricks.map((b) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: b.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: b.color, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      b.title,
                      style: GoogleFonts.outfit(
                        color: b.color,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      b.subtitle,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: l.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: l.primaryColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showMalayalam ? l.turn1InsightMl : l.turn1InsightEn,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E3A8A),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
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

  // =========================================================================
  // TURN 2: REAL USAGE & DEEPENING
  // =========================================================================
  Widget _buildTurn2DeepeningCard() {
    final l = _currentLesson;

    return Container(
      key: ValueKey('turn2_${_currentLevel.name}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: l.primaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: l.primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l.turn2TitleEn,
            style: GoogleFonts.outfit(
              color: l.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...l.turn2Examples.map((ex) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: l.primaryColor.withValues(alpha: 0.08),
                  foregroundColor: l.primaryColor,
                  elevation: 0,
                  side: BorderSide(
                      color: l.primaryColor.withValues(alpha: 0.35), width: 1.2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _speak(ex['en'] ?? '');
                },
                child: Row(
                  children: [
                    const Icon(Icons.volume_up_rounded, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex['en'] ?? '',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          if (_showMalayalam && (ex['ml'] ?? '').isNotEmpty)
                            Text(
                              ex['ml'] ?? '',
                              style: GoogleFonts.notoSansMalayalam(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
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

  // =========================================================================
  // TURN 3: SPONSORED REPEAT CHALLENGE
  // =========================================================================
  Widget _buildTurn3SpeakingCard() {
    final l = _currentLesson;

    return Container(
      key: ValueKey('turn3_${_currentLevel.name}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _spokeCorrectly ? const Color(0xFF10B981) : l.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: l.primaryColor.withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Target Phrase to Say:',
            style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '"${l.turn3TargetPhrase}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E40AF),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_showMalayalam) ...[
            const SizedBox(height: 4),
            Text(
              l.turn3DisplayPhraseMl,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansMalayalam(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Big Mic Button
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening(onResult: (spoken) {
                  final lower = spoken.toLowerCase();
                  bool verified = false;
                  for (final kw in l.turn3RecognizedKeywords) {
                    if (lower.contains(kw.toLowerCase())) verified = true;
                  }
                  if (verified || spoken.length >= 4) {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _spokeCorrectly = true;
                    });
                    _speak(l.turn3PraiseEn);
                    Future.delayed(const Duration(milliseconds: 1400), () {
                      if (mounted) _advanceTurn(4);
                    });
                  }
                });
              }
            },
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _spokeCorrectly
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : (_isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFF97316)]
                          : [l.primaryColor, l.secondaryColor]),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_spokeCorrectly
                            ? const Color(0xFF10B981)
                            : l.primaryColor)
                        .withValues(alpha: 0.45),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                _spokeCorrectly
                    ? Icons.check_circle_rounded
                    : (_isListening
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded),
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _spokeCorrectly
                ? '✅ Excellent speech verified!'
                : (_isListening
                    ? 'Listening... Speak now!'
                    : 'Tap mic & repeat aloud'),
            style: GoogleFonts.outfit(
              color: _spokeCorrectly
                  ? const Color(0xFF059669)
                  : const Color(0xFF0F172A),
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_recognizedWords.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Heard: "$_recognizedWords"',
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B), fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // TURN 4: GAME ROUTER (Flame / Interactive game mechanics for 6 tracks)
  // =========================================================================
  Widget _buildTurn4GameRouter() {
    final l = _currentLesson;
    switch (l.gameType) {
      case Day1GameType.soundBubblePop:
        return _buildGameSoundBubblePop();
      case Day1GameType.sentenceTrainPuzzle:
        return _buildGameSentenceTrainPuzzle();
      case Day1GameType.rapidReflexTimer:
        return _buildGameRapidReflexTimer();
      case Day1GameType.bridgeConnector:
        return _buildGameBridgeConnector();
      case Day1GameType.boardroomDiplomacy:
        return _buildGameBoardroomDiplomacy();
      case Day1GameType.debateRebuttalArena:
        return _buildGameDebateRebuttalArena();
    }
  }

  // GAME 1: Sound Bubble Pop (Level 1 Zero)
  Widget _buildGameSoundBubblePop() {
    final bubbles = (_currentLesson.gameData['bubbles'] as List?) ?? [];

    return Container(
      key: const ValueKey('game_bubble_pop'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🫧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                _currentLesson.gameTitle,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF047857),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Floating bubbles
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: bubbles.map((b) {
              final id = b['id'] as String;
              final label = b['label'] as String;
              final isTarget = b['isTarget'] == true;
              final isPopped = _bubblePopped && id == _selectedBubbleId;

              return AnimatedBuilder(
                animation: _ambientGameCtrl,
                builder: (ctx, _) {
                  final floatY =
                      math.sin((_ambientGameCtrl.value * math.pi * 2) +
                              id.hashCode) *
                          4.0;
                  return Transform.translate(
                    offset: Offset(0, floatY),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _selectedBubbleId = id;
                        });
                        _speak(label.split(' ')[0]);

                        if (isTarget) {
                          final targetWord = _currentLesson.gameData['targetWord'] as String? ?? 'Apple';
                          setState(() => _bubblePopped = true);
                          _speak("Pop! Correct, that is $targetWord!");
                          Future.delayed(const Duration(milliseconds: 1200), () {
                            if (mounted) _advanceTurn(5);
                          });
                        } else {
                          final targetWord = _currentLesson.gameData['targetWord'] as String? ?? 'Apple';
                          _speak("Not that one. Find $targetWord!");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPopped
                              ? const Color(0xFF10B981)
                              : const Color(0xFFE0F2FE),
                          border: Border.all(
                            color: isPopped
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF38BDF8),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7)
                                  .withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPopped
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            _bubblePopped
                ? '🎉 Bubble Popped! Water identified!'
                : 'Tap WATER bubble to burst it!',
            style: GoogleFonts.outfit(
              color: _bubblePopped
                  ? const Color(0xFF10B981)
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  // GAME 2: Sentence Train Puzzle (Level 2 Beginner)
  Widget _buildGameSentenceTrainPuzzle() {
    final shuffled =
        (_currentLesson.gameData['shuffledWords'] as List?)?.cast<String>() ??
            ['tea', 'I', 'want'];
    final correctOrder =
        (_currentLesson.gameData['correctOrder'] as List?)?.cast<String>() ??
            ['I', 'want', 'tea'];

    return Container(
      key: const ValueKey('game_train_puzzle'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚂', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Sentence Train Assembly',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0284C7),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Train Track Slot
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _trainError
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _trainError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _trainSelected.isEmpty
                  ? [
                      Text(
                        'Tap cars below to couple train...',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8), fontSize: 12.5),
                      ),
                    ]
                  : _trainSelected.map((w) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          w,
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
            ),
          ),

          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            children: shuffled.map((word) {
              final isPicked = _trainSelected.contains(word);
              return ActionChip(
                label: Text(
                  word,
                  style: GoogleFonts.outfit(
                    color: isPicked
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                backgroundColor: isPicked
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFEFF6FF),
                side: BorderSide(
                    color: isPicked
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF93C5FD)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: isPicked
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _trainSelected.add(word);
                          _trainError = false;
                        });
                        _speak(word);

                        if (_trainSelected.length == correctOrder.length) {
                          bool match = true;
                          for (int i = 0; i < correctOrder.length; i++) {
                            if (_trainSelected[i] != correctOrder[i]) {
                              match = false;
                            }
                          }
                          if (match) {
                            HapticFeedback.heavyImpact();
                            _speak("Choo-choo! I want tea!");
                            Future.delayed(const Duration(milliseconds: 800), () {
                              if (mounted) _advanceTurn(5);
                            });
                          } else {
                            HapticFeedback.vibrate();
                            setState(() => _trainError = true);
                            _speak("Try again! S + V + O: I comes first!");
                            Future.delayed(const Duration(milliseconds: 1200), () {
                              if (mounted) {
                                setState(() {
                                  _trainSelected.clear();
                                  _trainError = false;
                                });
                              }
                            });
                          }
                        }
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // GAME 3: Rapid Reflex Timer (Level 3 Elementary)
  Widget _buildGameRapidReflexTimer() {
    final data = _currentLesson.gameData;
    final scenario = data['scenario'] as String? ?? '';
    final options = (data['options'] as List?)?.cast<String>() ?? [];
    final correct = data['correctAnswer'] as String? ?? 'Count me in!';

    return Container(
      key: const ValueKey('game_reflex_timer'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2DD4BF), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ Speed Reflex Meter',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F766E),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${(_reflexProgress * 3.0).toStringAsFixed(1)}s',
                style: GoogleFonts.outfit(
                  color: _reflexProgress < 0.3
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF0D9488),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Timer Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _reflexProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(
                _reflexProgress < 0.3
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              scenario,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF065F46),
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),

          ...options.map((opt) {
            final isCorrectOpt = opt.contains(correct);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _reflexSuccess && isCorrectOpt
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF8FAFC),
                  foregroundColor: _reflexSuccess && isCorrectOpt
                      ? Colors.white
                      : const Color(0xFF0F172A),
                  elevation: 0,
                  side: BorderSide(
                    color: _reflexSuccess && isCorrectOpt
                        ? const Color(0xFF059669)
                        : const Color(0xFFCBD5E1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (isCorrectOpt && !_reflexFailed) {
                    HapticFeedback.heavyImpact();
                    _reflexTimer?.cancel();
                    setState(() => _reflexSuccess = true);
                    _speak("Lightning fast! Count me in!");
                    Future.delayed(const Duration(milliseconds: 900), () {
                      if (mounted) _advanceTurn(5);
                    });
                  } else {
                    _startReflexTimer();
                  }
                },
                child: Text(
                  opt,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // GAME 4: Bridge Connector (Level 4 Middle)
  Widget _buildGameBridgeConnector() {
    final data = _currentLesson.gameData;
    final c1 = data['clause1'] as String? ?? '';
    final c2 = data['clause2'] as String? ?? '';
    final options = (data['options'] as List?)?.cast<String>() ?? [];
    final correct = data['correctConnector'] as String? ?? 'nevertheless';

    return Container(
      key: const ValueKey('game_bridge_connector'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA855F7), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌉', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Bridge Connector Challenge',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF7E22CE),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bridge representation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Column(
              children: [
                Text(c1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _bridgeLocked
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedConnector.isEmpty ? '[ ? ]' : _selectedConnector,
                    style: GoogleFonts.outfit(
                      color: _bridgeLocked ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(c2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            children: options.map((opt) {
              return ActionChip(
                label: Text(opt,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                backgroundColor: const Color(0xFFF3E8FF),
                side: const BorderSide(color: Color(0xFFD8B4FE)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedConnector = opt);
                  _speak(opt);

                  if (opt.toLowerCase().contains(correct.toLowerCase())) {
                    HapticFeedback.heavyImpact();
                    setState(() => _bridgeLocked = true);
                    _speak("Bridge locked! Perfect transitional flow!");
                    Future.delayed(const Duration(milliseconds: 900), () {
                      if (mounted) _advanceTurn(5);
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // GAME 5: Boardroom Diplomacy (Level 5 Advanced)
  Widget _buildGameBoardroomDiplomacy() {
    final data = _currentLesson.gameData;
    final statement = data['clientStatement'] as String? ?? '';
    final options = (data['options'] as List?)?.cast<String>() ?? [];
    final correctIdx = data['correctIndex'] as int? ?? 1;

    return Container(
      key: const ValueKey('game_boardroom_diplomacy'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF0EA5E9), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏢', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Boardroom Executive Simulator',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0369A1),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Client Stakeholder:',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF0369A1),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  statement,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(options.length, (i) {
            final isCorrect = i == correctIdx;
            final isSelected = _selectedBoardroomOption == i;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? (isCorrect
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      : const Color(0xFFF8FAFC),
                  foregroundColor:
                      isSelected ? Colors.white : const Color(0xFF0F172A),
                  elevation: 0,
                  side: BorderSide(
                    color: isSelected
                        ? (isCorrect
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626))
                        : const Color(0xFFCBD5E1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _boardroomSuccess
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedBoardroomOption = i);
                        _speak(options[i]);

                        if (isCorrect) {
                          HapticFeedback.heavyImpact();
                          setState(() => _boardroomSuccess = true);
                          Future.delayed(const Duration(milliseconds: 1100), () {
                            if (mounted) _advanceTurn(5);
                          });
                        }
                      },
                child: Text(
                  options[i],
                  textAlign: TextAlign.start,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // GAME 6: Debate Rebuttal Arena (Level 6 Expert)
  Widget _buildGameDebateRebuttalArena() {
    final data = _currentLesson.gameData;
    final assertion = data['opponentAssertion'] as String? ?? '';
    final recommended = data['recommendedRebuttal'] as String? ?? '';

    return Container(
      key: const ValueKey('game_debate_arena'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🎙️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    'Debate Rebuttal Arena',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFB45309),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_debateSecondsRemaining}s',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFFB45309),
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('AI Opponent Assertion:',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  assertion,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Deliver this rhetorical rebuttal aloud:',
            style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '"$recommended"',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: _debateRecorded
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    _debateTimer?.cancel();
                    setState(() => _debateRecorded = true);
                    _speak("Applause! A masterclass in persuasive counter-framing!");
                    Future.delayed(const Duration(milliseconds: 1100), () {
                      if (mounted) _advanceTurn(5);
                    });
                  },
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: Text(
                _debateRecorded ? 'REBUTTAL DELIVERED! 👏' : 'DELIVER REBUTTAL 🎤',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TURN 5: VICTORY & REWARD
  // =========================================================================
  Widget _buildTurn5VictoryCard() {
    final l = _currentLesson;

    return Container(
      key: ValueKey('turn5_${_currentLevel.name}'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Celebratory Evolved Companion Avatar & Star Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [l.primaryColor, const Color(0xFFF59E0B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.day),
                    size: 90,
                    showAura: true,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l.victoryTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _showMalayalam ? l.victorySubtitleMl : l.victorySubtitleEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: const Color(0xFF475569), fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+30 Pocket Score Earned',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_safariStages.isNotEmpty) {
      if (_bubbleSafariStep >= _safariStages.length) {
        return const SizedBox(height: 10);
      }
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            if (_bubbleSafariStep > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _bubbleSafariStep--;
                      _balloonReady = false;
                      _lastPoppedId = null;
                    });
                    _speak(_safariStages[_bubbleSafariStep]['introVoice'] as String);
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text(
                    'PREVIOUS',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _safariXp += 10;
                    _bubbleSafariStep++;
                    _balloonReady = false;
                    _lastPoppedId = null;
                  });
                  if (_bubbleSafariStep < _safariStages.length) {
                    _speak(_safariStages[_bubbleSafariStep]['introVoice'] as String);
                  } else {
                    _awardScore();
                    _speak("Outstanding job! You learned your letters and sounds by playing with CyberCat! +30 Pocket Score awarded!");
                  }
                },
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                label: Text(
                  _bubbleSafariStep < _safariStages.length - 1
                      ? 'SKIP TO NEXT ➔'
                      : 'COMPLETE STEP 1 🏆',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isTurn5 = _turnIndex == 5;

    if (_turnIndex == 4) {
      // Game turns handle their own instant transitions upon success
      return const SizedBox(height: 14);
    }

    String label = 'NEXT ➔';
    if (_turnIndex == 0) label = "CONTINUE TO LESSON 🚀 ➔";
    if (_turnIndex == 1) label = "PRACTICE REAL USAGE 📚";
    if (_turnIndex == 2) label = "LET'S PRACTICE SPEAKING 🎙️";
    if (_turnIndex == 3) label = "PLAY LEVEL GAME 🎮";
    if (_turnIndex == 5) label = "FINISH & CLIMB TO STEP 2 🏔️";

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (isTurn5) {
              Navigator.pop(context);
              widget.onCompleted();
            } else {
              _advanceTurn(_turnIndex + 1);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isTurn5
                ? const Color(0xFF10B981)
                : _currentLesson.primaryColor,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 Sunny Open-World Game Canvas Painter (Blue Sky, Drifting Clouds, Golden Sun, Alpine Mountains & Rolling Meadow)
class _TutorOpenWorldCanvasPainter extends CustomPainter {
  final double gameTime;

  _TutorOpenWorldCanvasPainter({required this.gameTime});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sunny Azure Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFE0F2FE)],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Glowing Golden Sun with Halo
    final sunCenter = Offset(w * 0.82, 60);
    canvas.drawCircle(
      sunCenter,
      44,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(
      sunCenter,
      26,
      Paint()..color = const Color(0xFFFDE047),
    );
    canvas.drawCircle(
      sunCenter,
      16,
      Paint()..color = const Color(0xFFFFFBEB),
    );

    // 3. Drifting Fluffy Clouds
    for (int i = 0; i < 4; i++) {
      final cx = ((w * 0.3 * i) + (gameTime * 12.0)) % (w + 140) - 70;
      final cy = 35.0 + (i % 2 * 30.0);
      _drawCloud(canvas, cx, cy);
    }

    // 4. Distant Alpine Mountain Ridge
    final mountainPath = Path();
    mountainPath.moveTo(0, h);
    mountainPath.lineTo(0, h * 0.62);
    for (double x = 0; x <= w; x += 40) {
      final my = h * 0.62 - (math.sin(x * 0.015) * 22.0) - (math.cos(x * 0.03) * 12.0);
      mountainPath.lineTo(x, my);
    }
    mountainPath.lineTo(w, h);
    mountainPath.close();

    final mountainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.35),
          const Color(0xFF0284C7).withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5));
    canvas.drawPath(mountainPath, mountainPaint);

    // 5. Rolling Emerald Meadow Hills
    final hillPath = Path();
    hillPath.moveTo(0, h);
    hillPath.lineTo(0, h * 0.72);
    hillPath.quadraticBezierTo(w * 0.35, h * 0.65, w * 0.70, h * 0.74);
    hillPath.quadraticBezierTo(w * 0.88, h * 0.78, w, h * 0.71);
    hillPath.lineTo(w, h);
    hillPath.close();

    final hillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF047857)],
      ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.35));
    canvas.drawPath(hillPath, hillPaint);

    // 6. Foreground Rolling Green Lawn
    final foreHill = Path();
    foreHill.moveTo(0, h);
    foreHill.lineTo(0, h * 0.82);
    foreHill.quadraticBezierTo(w * 0.45, h * 0.78, w, h * 0.84);
    foreHill.lineTo(w, h);
    foreHill.close();

    final forePaint = Paint()
      ..color = const Color(0xFF059669).withValues(alpha: 0.95);
    canvas.drawPath(foreHill, forePaint);
  }

  void _drawCloud(Canvas canvas, double x, double y) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.80);
    canvas.drawCircle(Offset(x, y), 16, paint);
    canvas.drawCircle(Offset(x + 14, y - 6), 20, paint);
    canvas.drawCircle(Offset(x + 30, y), 16, paint);
    canvas.drawCircle(Offset(x + 14, y + 4), 14, paint);
  }

  @override
  bool shouldRepaint(covariant _TutorOpenWorldCanvasPainter oldDelegate) => true;
}
