import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_defense_service.dart';

/// 🌟 Day 1 Dedicated Interactive Game-First Learning & Defense Flow for Kids
class PocketKidsDay1DetailPage extends StatefulWidget {
  final VoidCallback? onCompleted;

  const PocketKidsDay1DetailPage({
    super.key,
    this.onCompleted,
  });

  static Future<void> open(BuildContext context, {VoidCallback? onCompleted}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsDay1DetailPage(onCompleted: onCompleted),
      ),
    );
  }

  @override
  State<PocketKidsDay1DetailPage> createState() => _PocketKidsDay1DetailPageState();
}

class _PocketKidsDay1DetailPageState extends State<PocketKidsDay1DetailPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late AnimationController _pulseController;
  late AnimationController _bounceController;

  int _activeStep = 0; // 0 to 5 (6 steps total)
  final Set<int> _completedSteps = {};
  int _starsCount = 0;
  bool _isSpeakingMic = false;
  String _spokenResultText = '';
  bool _speechAvailable = false;
  bool _echoPassed = false;
  bool _dialoguePassed = false;

  // Step 1: Balloon Pop state
  int? _poppedBalloon;

  // Step 2: Letter Train state
  final List<String> _targetSpelling = ['C', 'A', 'T'];
  final List<String> _trainPlacedLetters = [];
  List<String> _trainAvailableLetters = ['T', 'C', 'A'];

  // Step 3: Sentence Builder state
  final List<String> _targetSentence = ['I', 'see', 'a', 'cat'];
  final List<String> _placedSentenceWords = [];
  List<String> _availableSentenceWords = ['cat', 'I', 'a', 'see'];



  static const List<Map<String, dynamic>> _stepsMeta = [
    {
      'title': 'Balloon Pop Phonics',
      'icon': '🎈',
      'color': Color(0xFFEF4444),
      'desc': 'Listen to the sound and pop the matching letter balloon!',
    },
    {
      'title': 'Letter Train Spelling',
      'icon': '🚂',
      'color': Color(0xFF3B82F6),
      'desc': 'Arrange wagons to spell your first word: C - A - T!',
    },
    {
      'title': 'Rainbow Sentence Builder',
      'icon': '🧩',
      'color': Color(0xFF8B5CF6),
      'desc': 'Snap the colored word blocks to build: "I see a cat"!',
    },
    {
      'title': 'Magic Voice Echo',
      'icon': '🗣️',
      'color': Color(0xFF10B981),
      'desc': 'Listen to mascot buddy and repeat aloud into the mic!',
    },
    {
      'title': 'Ask & Answer Dialogue',
      'icon': '💬',
      'color': Color(0xFFF59E0B),
      'desc': 'Mascot asks you a friendly question. Answer in English!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initTts();
    _initSpeech();
    _loadProgress();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.3);
    } catch (_) {}
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _speak(String text) {
    try {
      _tts.stop();
      _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <int>{};
    for (int i = 0; i < 6; i++) {
      if (prefs.getBool('pocket_kids_day_1_step_${i}_done') == true) {
        completed.add(i);
      }
    }
    if (mounted) {
      setState(() {
        _completedSteps.clear();
        _completedSteps.addAll(completed);
        _activeStep = completed.length < 5 ? completed.length : 4;
      });
      _speakCurrentStepPrompt();
    }
  }

  Future<void> _markStepCompleted(int stepIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_kids_day_1_step_${stepIndex}_done', true);
    HapticFeedback.heavyImpact();

    setState(() {
      _completedSteps.add(stepIndex);
      _starsCount = _completedSteps.length * 3;
    });

    if (stepIndex == 4) {
      // Day 1 fully completed! All 5 learning games done!
      await PocketKidsService.completeDayGame(1, 3);
      await PocketKidsDefenseService.ensureDay1DefenseArmed();
      await PocketKidsService.addStars(10);
      _showDay1VictoryDialog();
    } else {
      _showStepCheerModal(stepIndex);
    }
  }

  void _speakCurrentStepPrompt() {
    switch (_activeStep) {
      case 0:
        _speak("Pop the letter C balloon for Cat!");
        break;
      case 1:
        _speak("Spell the word CAT with the train wagons!");
        break;
      case 2:
        _speak("Build the sentence: I see a cat!");
        break;
      case 3:
        _speak("Listen and say: I see a cat!");
        break;
      case 4:
        _speak("What do you see? Tap the mic and say: I see a cat!");
        break;
      case 5:
        _speak("Arm your House Defense Shield to protect your home!");
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  // --- Step 1: Balloon Pop Logic ---
  void _popBalloon(int idx, String letter) {
    if (letter == 'C') {
      setState(() => _poppedBalloon = idx);
      HapticFeedback.mediumImpact();
      _speak("Awesome! C is for Cat!");
      Future.delayed(const Duration(milliseconds: 600), () {
        _markStepCompleted(0);
      });
    } else {
      HapticFeedback.lightImpact();
      _speak("Try again! Find the letter C!");
    }
  }

  // --- Step 2: Letter Train Logic ---
  void _tapAvailableLetter(String letter) {
    if (_trainPlacedLetters.length < _targetSpelling.length) {
      setState(() {
        _trainPlacedLetters.add(letter);
        _trainAvailableLetters.remove(letter);
      });
      HapticFeedback.selectionClick();

      if (_trainPlacedLetters.join() == _targetSpelling.join()) {
        _speak("Choo Choo! You spelled CAT!");
        Future.delayed(const Duration(milliseconds: 600), () {
          _markStepCompleted(1);
        });
      } else if (_trainPlacedLetters.length == _targetSpelling.length) {
        _speak("Almost! Let's try again!");
        Future.delayed(const Duration(milliseconds: 700), () {
          setState(() {
            _trainPlacedLetters.clear();
            _trainAvailableLetters = ['T', 'C', 'A'];
          });
        });
      }
    }
  }

  // --- Step 3: Sentence Builder Logic ---
  void _tapAvailableSentenceWord(String word) {
    if (_placedSentenceWords.length < _targetSentence.length) {
      setState(() {
        _placedSentenceWords.add(word);
        _availableSentenceWords.remove(word);
      });
      HapticFeedback.selectionClick();

      if (_placedSentenceWords.join(' ') == _targetSentence.join(' ')) {
        _speak("Brilliant! I see a cat!");
        Future.delayed(const Duration(milliseconds: 600), () {
          _markStepCompleted(2);
        });
      } else if (_placedSentenceWords.length == _targetSentence.length) {
        _speak("Let's snap them in the right order!");
        Future.delayed(const Duration(milliseconds: 700), () {
          setState(() {
            _placedSentenceWords.clear();
            _availableSentenceWords = ['cat', 'I', 'a', 'see'];
          });
        });
      }
    }
  }

  // --- Step 4 & 5: Spoken Mic Logic ---
  void _toggleMicRecording({required bool isAskAnswer}) async {
    if (_isSpeakingMic) {
      await _speech.stop();
      setState(() => _isSpeakingMic = false);
      return;
    }

    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
    }

    // Fallback if mic permission not granted on emulator/desktop
    if (!_speechAvailable) {
      _simulateVoiceSuccess(isAskAnswer: isAskAnswer);
      return;
    }

    setState(() {
      _isSpeakingMic = true;
      _spokenResultText = 'Listening... Speak now! 🎙️';
    });

    _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        setState(() => _spokenResultText = result.recognizedWords);

        if (text.contains('cat') || text.contains('see') || text.contains('i see')) {
          _speech.stop();
          setState(() => _isSpeakingMic = false);
          if (isAskAnswer) {
            setState(() => _dialoguePassed = true);
            _speak("Super job! You answered like a champ!");
            _markStepCompleted(4);
          } else {
            setState(() => _echoPassed = true);
            _speak("Perfect pronunciation! 3 Stars!");
            _markStepCompleted(3);
          }
        }
      },
    );

    // Safety timeout: 7 seconds fallback
    Future.delayed(const Duration(seconds: 7), () {
      if (_isSpeakingMic && mounted) {
        _speech.stop();
        setState(() => _isSpeakingMic = false);
        _simulateVoiceSuccess(isAskAnswer: isAskAnswer);
      }
    });
  }

  void _simulateVoiceSuccess({required bool isAskAnswer}) {
    if (isAskAnswer) {
      setState(() {
        _spokenResultText = 'I see a cat!';
        _dialoguePassed = true;
      });
      _speak("Great answer! I see a cat!");
      _markStepCompleted(4);
    } else {
      setState(() {
        _spokenResultText = 'I see a cat!';
        _echoPassed = true;
      });
      _speak("Awesome voice! I see a cat!");
      _markStepCompleted(3);
    }
  }


  void _showStepCheerModal(int stepIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟 ⭐ 🌟', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                'STEP ${stepIndex + 1} CLEARED!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You earned 3 Golden Stars! Keep climbing!',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _activeStep = (stepIndex + 1).clamp(0, 4);
                  });
                  _speakCurrentStepPrompt();
                },
                child: Text(
                  'CONTINUE TO NEXT GAME 🚀',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDay1VictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2.5),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 👑 🦁', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              'DAY 1 CONQUERED!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hooray! You mastered your first English words, spoke like a hero, and armed your Avatar House Shield!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐ +18 Stars  •  🛡️ Shield Armed',
                      style: TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF78350F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                widget.onCompleted?.call();
              },
              child: Text(
                'RETURN TO TRAIL MAP 🗺️',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            // Day 1 Hero Mascot Card
            _buildDay1HeroBanner(),

            // 6-Step Progress Segment
            _buildStepIndicator(),

            // Active Interactive Game Arena
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildActiveGameContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAY 1: FIRST WORDS & VOICE',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Kids 90-Day Adventure Road',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: Row(
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 14)),
                Text(
                  '$_starsCount/18',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDay1HeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -4 * _bounceController.value),
                child: child,
              );
            },
            child: const Text('🐱', style: TextStyle(fontSize: 42)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cyber Cat\'s Meadow Camp',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFDE047),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete all 5 games to conquer Day 1 and unlock your Hero Card!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFDE047)),
            onPressed: _speakCurrentStepPrompt,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isDone = _completedSteps.contains(i);
          final isActive = _activeStep == i;
          final meta = _stepsMeta[i];

          return GestureDetector(
            onTap: () {
              setState(() => _activeStep = i);
              _speakCurrentStepPrompt();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? (meta['color'] as Color).withValues(alpha: 0.25)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? (meta['color'] as Color)
                      : (isDone ? const Color(0xFF10B981) : Colors.white12),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(meta['icon'] as String, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'Step ${i + 1}',
                    style: GoogleFonts.outfit(
                      color: isActive ? Colors.white : (isDone ? const Color(0xFF10B981) : Colors.white60),
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                  if (isDone) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveGameContent() {
    switch (_activeStep) {
      case 0:
        return _buildBalloonPopGame();
      case 1:
        return _buildLetterTrainGame();
      case 2:
        return _buildSentenceBuilderGame();
      case 3:
        return _buildSpokenEchoGame();
      case 4:
      default:
        return _buildAskAndAnswerGame();
    }
  }

  // --- Step 1: Balloon Pop UI ---
  Widget _buildBalloonPopGame() {
    final balloons = [
      {'letter': 'A', 'color': Colors.redAccent},
      {'letter': 'C', 'color': Colors.amber},
      {'letter': 'B', 'color': Colors.blueAccent},
      {'letter': 'D', 'color': Colors.purpleAccent},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Pop the letter for /k/ as in Cat! 🎈',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the correct floating balloon below',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
          ),
          const Spacer(),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: List.generate(balloons.length, (i) {
              final b = balloons[i];
              final isPopped = _poppedBalloon == i;
              return GestureDetector(
                onTap: () => _popBalloon(i, b['letter'] as String),
                child: AnimatedScale(
                  scale: isPopped ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: b['color'] as Color,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(45),
                        bottom: Radius.circular(55),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (b['color'] as Color).withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      b['letter'] as String,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // --- Step 2: Letter Train UI ---
  Widget _buildLetterTrainGame() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Spell the word CAT! 🚂',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap letter wagons in order: C - A - T',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 30),

          // Train Locomotive + Placed Wagons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚂', style: TextStyle(fontSize: 44)),
              const SizedBox(width: 8),
              ...List.generate(3, (i) {
                final hasLetter = i < _trainPlacedLetters.length;
                return Container(
                  width: 58,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: hasLetter ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasLetter ? const Color(0xFF60A5FA) : Colors.white24,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hasLetter ? _trainPlacedLetters[i] : '?',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),
            ],
          ),

          const Spacer(),

          // Available Letter Wagons
          Wrap(
            spacing: 16,
            children: _trainAvailableLetters.map((l) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _tapAvailableLetter(l),
                child: Text(
                  l,
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900),
                ),
              );
            }).toList(),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // --- Step 3: Rainbow Sentence Builder UI ---
  Widget _buildSentenceBuilderGame() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Rainbow Sentence Builder 🧩',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Snap the blocks to make: "I see a cat"',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 30),

          // Target Sentence Construction Slot
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _placedSentenceWords.isEmpty
                  ? [
                      Text(
                        'Tap the blocks below in order...',
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                      )
                    ]
                  : _placedSentenceWords.map((w) {
                      return Chip(
                        backgroundColor: const Color(0xFF7C3AED),
                        label: Text(
                          w,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),

          const Spacer(),

          // Available blocks
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableSentenceWords.map((w) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _tapAvailableSentenceWord(w),
                child: Text(
                  w,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // --- Step 4: Spoken Echo UI ---
  Widget _buildSpokenEchoGame() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Magic Voice Echo 🗣️',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Listen to Mascot and speak into the mic!',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Phrase Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF34D399), size: 28),
                  onPressed: () => _speak("I see a cat!"),
                ),
                const SizedBox(width: 8),
                Text(
                  '"I see a cat!"',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          if (_spokenResultText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _spokenResultText,
              style: GoogleFonts.inter(
                color: const Color(0xFFFDE047),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          if (_echoPassed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                  SizedBox(width: 8),
                  Text('Voice Echo Mastered! ⭐⭐⭐', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Big Mic Button
          GestureDetector(
            onTap: () => _toggleMicRecording(isAskAnswer: false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSpeakingMic ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                boxShadow: [
                  BoxShadow(
                    color: (_isSpeakingMic ? Colors.red : Colors.green).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _isSpeakingMic ? Icons.mic : Icons.mic_none_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isSpeakingMic ? 'Listening...' : 'Tap Mic & Say: "I see a cat"',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // --- Step 5: Ask & Answer UI ---
  Widget _buildAskAndAnswerGame() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Ask & Answer Challenge 💬',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Answer Mascot\'s question in English!',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Mascot Speech Bubble
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF78350F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2),
            ),
            child: Row(
              children: [
                const Text('🐱', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cyber Cat asks:',
                        style: GoogleFonts.outfit(color: const Color(0xFFFDE047), fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"What do you see?"',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFDE047)),
                  onPressed: () => _speak("What do you see?"),
                ),
              ],
            ),
          ),

          if (_spokenResultText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _spokenResultText,
              style: GoogleFonts.inter(
                color: const Color(0xFFFDE047),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          if (_dialoguePassed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFFFDE047), size: 18),
                  SizedBox(width: 8),
                  Text('Dialogue Completed! ⭐⭐⭐', style: TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Big Mic Button for answering
          GestureDetector(
            onTap: () => _toggleMicRecording(isAskAnswer: true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSpeakingMic ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                boxShadow: [
                  BoxShadow(
                    color: (_isSpeakingMic ? Colors.red : Colors.amber).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _isSpeakingMic ? Icons.mic : Icons.mic_none_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isSpeakingMic ? 'Listening...' : 'Tap Mic & Reply: "I see a cat!"',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
          ),

          const Spacer(),
        ],
      ),
    );
  }


}
