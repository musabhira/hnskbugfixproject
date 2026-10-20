import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import '../pocket_pronunciation_evaluator.dart';
import '../pocket_fortress_defense_service.dart';
import '../pocket_90day_vocab_curriculum.dart';

/// 🚗 Particle effect for road dust, checkpoint celebrations, and coin bursts
class DriveParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;
  final double size;

  DriveParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });
}

/// 🌄 Full-Screen Open-World Vocabulary Driving Quest Game
///
/// Features addressing user audio directive:
/// 1. NO Automatic Driving! Player controls Forward & Reverse driving.
/// 2. Big, prominent Vocabulary Houses / Buildings beside the road with words on top (Book, Car, Water, etc.).
/// 3. When the car reaches the house, game STOPS completely!
/// 4. Minimal Centered Floating Action Button with mic appears: Speak "This is a book."
/// 5. Once spoken and verified, mic disappears, game resumes, and Drive Forward button reappears!
/// 6. Reverse / Back control available if player wants to back up.
/// 7. Open world aesthetics: hills, green grass, sky, trees, and roadside nature.
/// 🚗 Supported Ride & Movement Modes (User Audio Directive!)
enum RideMode {
  car,       // 🏎️ Highway Sports Cruiser (Day 1)
  jeep,      // 🚙 4x4 Off-Road Safari Jeep (Day 2)
  airplane,  // ✈️ Sky Flight over Mountain Summits (Day 3)
  walking,   // 🚶 Nature Explorer Forest Trail (Day 4)
  train,     // 🚆 High-Speed Express Bullet Train (Day 5 - User Audio Directive!)
  rocket,    // 🚀 Cosmic Star Rocket (Day 6)
}

class PocketVocabOpenWorldDrivePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? initialRideMode;
  final String? userId;
  final VoidCallback? onCompleted;

  const PocketVocabOpenWorldDrivePage({
    super.key,
    this.day = 1,
    this.stepIndex = 7,
    this.initialRideMode,
    this.userId,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 7,
    String? initialRideMode,
    String? userId,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketVocabOpenWorldDrivePage(
          day: day,
          stepIndex: stepIndex,
          initialRideMode: initialRideMode,
          userId: userId,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketVocabOpenWorldDrivePage> createState() =>
      _PocketVocabOpenWorldDrivePageState();
}

class _PocketVocabOpenWorldDrivePageState
    extends State<PocketVocabOpenWorldDrivePage>
    with TickerProviderStateMixin {
  late final AnimationController _gameLoopController;
  late final AnimationController _arrowGuideController;
  late final AnimationController _pulseController;
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  final math.Random _random = math.Random();
  final List<DriveParticle> _particles = [];

  // 📚 20 Vocabulary Checkpoint Words with Mini-Sentences
  static const List<Map<String, dynamic>> vocabCheckpoints = [
    {
      'word': 'Book',
      'meaningEn': 'Pages to read and study',
      'meaningMl': 'പുസ്തകം',
      'emoji': '📖',
      'sentence': 'This is a book.',
      'sentenceMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
    },
    {
      'word': 'Car',
      'meaningEn': 'Vehicle for driving',
      'meaningMl': 'കാർ',
      'emoji': '🚗',
      'sentence': 'This is a car.',
      'sentenceMl': 'ഇത് ഒരു കാറാണ്.',
    },
    {
      'word': 'Water',
      'meaningEn': 'Drinkable clear liquid',
      'meaningMl': 'വെള്ളം',
      'emoji': '💧',
      'sentence': 'I drink water.',
      'sentenceMl': 'ഞാൻ വെള്ളം കുടിക്കുന്നു.',
    },
    {
      'word': 'Food',
      'meaningEn': 'Things we eat for energy',
      'meaningMl': 'ഭക്ഷണം',
      'emoji': '🍲',
      'sentence': 'I eat food.',
      'sentenceMl': 'ഞാൻ ഭക്ഷണം കഴിക്കുന്നു.',
    },
    {
      'word': 'Home',
      'meaningEn': 'Place where you live',
      'meaningMl': 'വീട്',
      'emoji': '🏠',
      'sentence': 'This is my home.',
      'sentenceMl': 'ഇത് എന്റെ വീടാണ്.',
    },
    {
      'word': 'Cat',
      'meaningEn': 'A cute furry pet animal',
      'meaningMl': 'പൂച്ച',
      'emoji': '🐱',
      'sentence': 'I love my cat.',
      'sentenceMl': 'ഞാൻ പൂച്ചയെ ഇഷ്ടപ്പെടുന്നു.',
    },
    {
      'word': 'Family',
      'meaningEn': 'Parents, siblings & loved ones',
      'meaningMl': 'കുടുംബം',
      'emoji': '👨‍👩‍👧‍👦',
      'sentence': 'I love my family.',
      'sentenceMl': 'ഞാൻ കുടുംബത്തെ സ്നേഹിക്കുന്നു.',
    },
    {
      'word': 'Friend',
      'meaningEn': 'A companion you like',
      'meaningMl': 'സുഹൃത്ത് / ചങ്ങാതി',
      'emoji': '🤝',
      'sentence': 'You are my friend.',
      'sentenceMl': 'നീ എന്റെ സുഹൃത്താണ്.',
    },
    {
      'word': 'School',
      'meaningEn': 'Place to learn together',
      'meaningMl': 'സ്കൂൾ / വിദ്യാലയം',
      'emoji': '🏫',
      'sentence': 'I go to school.',
      'sentenceMl': 'ഞാൻ സ്കൂളിൽ പോകുന്നു.',
    },
    {
      'word': 'Tree',
      'meaningEn': 'Plant with green leaves',
      'meaningMl': 'മരം',
      'emoji': '🌳',
      'sentence': 'Look at the tree.',
      'sentenceMl': 'മരത്തിലേക്ക് നോക്കൂ.',
    },
    {
      'word': 'Sun',
      'meaningEn': 'Bright star in the sky',
      'meaningMl': 'സൂര്യൻ',
      'emoji': '☀️',
      'sentence': 'The sun is bright.',
      'sentenceMl': 'സൂര്യൻ തിളങ്ങുന്നു.',
    },
    {
      'word': 'Ball',
      'meaningEn': 'Round toy for playing',
      'meaningMl': 'പന്ത്',
      'emoji': '⚽',
      'sentence': 'I have a ball.',
      'sentenceMl': 'എന്റെ കൈയിൽ പന്തുണ്ട്.',
    },
    {
      'word': 'Door',
      'meaningEn': 'Entrance to a room',
      'meaningMl': 'വാതിൽ',
      'emoji': '🚪',
      'sentence': 'Open the door.',
      'sentenceMl': 'വാതിൽ തുറക്കൂ.',
    },
    {
      'word': 'Milk',
      'meaningEn': 'Nutritious white drink',
      'meaningMl': 'പാൽ',
      'emoji': '🥛',
      'sentence': 'I drink milk.',
      'sentenceMl': 'ഞാൻ പാൽ കുടിക്കുന്നു.',
    },
    {
      'word': 'Apple',
      'meaningEn': 'Sweet red fruit',
      'meaningMl': 'ആപ്പിൾ',
      'emoji': '🍎',
      'sentence': 'I like apple.',
      'sentenceMl': 'എനിക്ക് ആപ്പിൾ ഇഷ്ടമാണ്.',
    },
    {
      'word': 'Bird',
      'meaningEn': 'Animal with wings that flies',
      'meaningMl': 'പക്ഷി',
      'emoji': '🐦',
      'sentence': 'The bird flies.',
      'sentenceMl': 'പക്ഷി പറക്കുന്നു.',
    },
    {
      'word': 'Dog',
      'meaningEn': 'Friendly pet animal',
      'meaningMl': 'പട്ടി / നായ',
      'emoji': '🐕',
      'sentence': 'The dog runs.',
      'sentenceMl': 'പട്ടി ഓടുന്നു.',
    },
    {
      'word': 'Fish',
      'meaningEn': 'Animal living in water',
      'meaningMl': 'മീൻ / മത്സ്യം',
      'emoji': '🐟',
      'sentence': 'The fish swims.',
      'sentenceMl': 'മീൻ നീന്തുന്നു.',
    },
    {
      'word': 'Clock',
      'meaningEn': 'Instrument showing time',
      'meaningMl': 'ക്ലോക്ക്',
      'emoji': '⏰',
      'sentence': 'Check the clock.',
      'sentenceMl': 'ക്ലോക്ക് നോക്കൂ.',
    },
    {
      'word': 'Star',
      'meaningEn': 'Bright light in the night sky',
      'meaningMl': 'നക്ഷത്രം',
      'emoji': '⭐',
      'sentence': 'See the star.',
      'sentenceMl': 'നക്ഷത്രത്തെ കാണൂ.',
    },
  ];

  // 🚗 Drive & Physics State
  late RideMode _currentRideMode;
  int _currentCheckpointIndex = 0;
  double _distanceTraveled = 0.0;
  double _speed = 0.0;
  double _targetSpeed = 0.0;
  final double _carLaneY = 0.72;
  double _cloudScroll = 0.0;
  double _sceneryScroll = 0.0;

  bool _isForwardPressed = false;
  bool _isReversePressed = false;
  bool _isAtCheckpoint = false;
  bool _checkpointGateOpening = false;
  bool _isAudioMuted = false;
  bool _isRecording = false;
  String _spokenText = '';
  int _recordingSeconds = 0;
  Timer? _recordTimer;
  bool _isWordVerified = false;
  String? _speechError;
  bool _speechAvailable = false;
  bool _allCompleted = false;
  late final List<Map<String, dynamic>> _checkpoints;

  // Distance between each vocabulary landmark
  static const double kDistancePerCheckpoint = 320.0;

  @override
  void initState() {
    super.initState();

    // Populate day-specific unique vocabulary items (User Audio Directive!)
    final dayItems = Pocket90DayVocabCurriculum.getVocabForDay(widget.day);
    if (dayItems.isNotEmpty) {
      final emojis = ['💎', '🚀', '🌟', '🏆', '🎯', '⚡', '🔥', '📚', '🎨', '✨', '🌍', '🔮', '🛡️', '🔑', '🌈', '💡'];
      _checkpoints = dayItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final v = entry.value;
        return {
          'word': v.word,
          'meaningEn': v.definition,
          'meaningMl': v.malayalamMeaning,
          'emoji': emojis[idx % emojis.length],
          'sentence': v.exampleSentence.isNotEmpty ? v.exampleSentence : 'This is ${v.word}.',
          'sentenceMl': v.malayalamMeaning,
        };
      }).toList();
    } else {
      _checkpoints = vocabCheckpoints;
    }

    // 1 dedicated game theme per day (User Audio Directive!)
    // Day 1: Highway Sports Cruiser (Car)
    // Day 2: 4x4 Off-Road Safari Jeep (with oncoming traffic!)
    // Day 3: Skyward Flight Airplane
    // Day 4: Cosmic Star Rocket
    // Day 5: Forest Trail Nature Explorer
    if (widget.initialRideMode == 'jeep') {
      _currentRideMode = RideMode.jeep;
    } else if (widget.initialRideMode == 'airplane') {
      _currentRideMode = RideMode.airplane;
    } else if (widget.initialRideMode == 'walking') {
      _currentRideMode = RideMode.walking;
    } else if (widget.initialRideMode == 'train') {
      _currentRideMode = RideMode.train;
    } else if (widget.initialRideMode == 'rocket') {
      _currentRideMode = RideMode.rocket;
    } else if (widget.initialRideMode == 'car') {
      _currentRideMode = RideMode.car;
    } else {
      final cycle = (widget.day - 1) % 6;
      if (cycle == 0) {
        _currentRideMode = RideMode.car;
      } else if (cycle == 1) {
        _currentRideMode = RideMode.jeep;
      } else if (cycle == 2) {
        _currentRideMode = RideMode.airplane;
      } else if (cycle == 3) {
        _currentRideMode = RideMode.walking;
      } else if (cycle == 4) {
        _currentRideMode = RideMode.train;
      } else {
        _currentRideMode = RideMode.rocket;
      }
    }

    _initTts();
    _initSpeechRecognizer();
    _initAudioService();

    _arrowGuideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameLoop);
    _gameLoopController.repeat();
  }

  Future<void> _initAudioService() async {
    try {
      await PocketGameAudioService.instance.setVolume(0.12);
    } catch (_) {}
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.05);
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      _speechAvailable = false;
      return;
    }
    try {
      _speech = stt.SpeechToText();
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isRecording) {
              setState(() => _isRecording = false);
            }
          }
        },
        onError: (_) {
          if (mounted && _isRecording) {
            setState(() => _isRecording = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _gameLoopController.dispose();
    _arrowGuideController.dispose();
    _pulseController.dispose();
    _tts.stop();
    try {
      if (_speechAvailable) _speech.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isAudioMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  // =========================================================================
  // 🎮 GAME LOOP & MANUAL DRIVING PHYSICS (NO AUTO DRIVING!)
  // =========================================================================

  void _gameLoop() {
    if (_allCompleted) return;

    setState(() {
      // 1. Manual Drive physics: STOPPED by default unless user holds Forward or Reverse!
      if (_isAtCheckpoint) {
        // Complete stop at checkpoint house
        _targetSpeed = 0.0;
        _speed = 0.0;
      } else {
        if (_isForwardPressed) {
          _targetSpeed = 5.2; // Forward driving speed
          _speed = math.min(_targetSpeed, _speed + 0.4);
        } else if (_isReversePressed) {
          _targetSpeed = -3.2; // Reverse driving speed
          _speed = math.max(_targetSpeed, _speed - 0.35);
        } else {
          // Coasting down to stop immediately when button released
          _targetSpeed = 0.0;
          if (_speed > 0) {
            _speed = math.max(0.0, _speed - 0.35);
          } else if (_speed < 0) {
            _speed = math.min(0.0, _speed + 0.35);
          }
        }
      }

      // 2. Move world distance
      _distanceTraveled += _speed;
      if (_distanceTraveled < 0) _distanceTraveled = 0; // Don't drive past start line
      _sceneryScroll += _speed * 0.85;
      _cloudScroll += 0.25;

      // 3. Spawn wheel dust particles when driving
      if (_speed.abs() > 1.0 && _random.nextDouble() < 0.3) {
        _particles.add(
          DriveParticle(
            x: _speed > 0 ? 0.20 : 0.28,
            y: _carLaneY + 0.04,
            vx: -(_speed * 0.003) - (_random.nextDouble() * 0.003),
            vy: (_random.nextDouble() - 0.5) * 0.002,
            life: 1.0,
            color: Colors.white.withValues(alpha: 0.4),
            size: 4 + _random.nextDouble() * 4,
          ),
        );
      }

      // 4. Update particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.life -= 0.04;
        if (p.life <= 0 || p.x < -0.1 || p.y > 1.1) {
          _particles.removeAt(i);
        }
      }

      // 5. Checkpoint Landmark House detection
      final targetDistanceForNext = (_currentCheckpointIndex + 1) * kDistancePerCheckpoint;
      if (!_isAtCheckpoint &&
          !_checkpointGateOpening &&
          _currentCheckpointIndex < _checkpoints.length &&
          _distanceTraveled >= targetDistanceForNext - 10.0) {
        _distanceTraveled = targetDistanceForNext - 10.0; // Park right in front of house
        _hitCheckpoint();
      }
    });
  }

  void _hitCheckpoint() {
    _isAtCheckpoint = true;
    _speed = 0.0;
    _isForwardPressed = false;
    _isReversePressed = false;
    _isRecording = false;
    _spokenText = '';
    _recordingSeconds = 0;
    _isWordVerified = false;
    _recordTimer?.cancel();
    HapticFeedback.heavyImpact();

    final item = _checkpoints[_currentCheckpointIndex];
    final wrd = item['word'];

    // Per user audio directive:
    // Speak ONLY the word name first (e.g., "Sun!").
    // Do NOT auto-speak the sentence, and do NOT auto-advance without user recording!
    _speak('$wrd!');
  }

  Future<void> _toggleManualRecording(String sentence) async {
    if (_isWordVerified || _checkpointGateOpening) return;

    if (!_isRecording) {
      await _startManualRecording(sentence);
    } else {
      await _stopManualRecordingAndVerify(sentence);
    }
  }

  Future<void> _startManualRecording(String sentence) async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _spokenText = '';
      _speechError = null;
      _recordingSeconds = 0;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobile && _speechAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            if (mounted && _isRecording) {
              setState(() {
                _spokenText = result.recognizedWords;
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 25),
            pauseFor: const Duration(seconds: 4),
            partialResults: true,
            listenMode: stt.ListenMode.dictation,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _stopManualRecordingAndVerify(String sentence) async {
    HapticFeedback.heavyImpact();
    _recordTimer?.cancel();

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobile && _speechAvailable) {
      try {
        await _speech.stop();
      } catch (_) {}
    }

    final currentItem = _currentCheckpointIndex < _checkpoints.length
        ? _checkpoints[_currentCheckpointIndex]
        : _checkpoints.last;
    final wrd = (currentItem['word'] ?? '').toString().toLowerCase();

    final normSpoken = PocketSpeechNormalizer.normalize(_spokenText);
    final cleanSpoken = PocketSpeechNormalizer.clean(normSpoken.isNotEmpty ? normSpoken : _spokenText);

    if (cleanSpoken.isEmpty) {
      if (!isMobile || !_speechAvailable) {
        // Desktop / Simulator / Web test fallback
        _spokenText = sentence;
      } else {
        setState(() {
          _isRecording = false;
          _speechError = 'Microphone did not detect your voice.\nPlease tap the mic and say: "$sentence"';
        });
        PocketGameAudioService.instance.playIncorrectSound();
        await _speak('Please speak into the mic: $sentence');
        return;
      }
    }

    // Accurate Speech Verification with Accent Tolerance (e.g., "I live in Kerala")
    final evalResult = PocketPronunciationEvaluator.evaluate(
      targetSentence: sentence,
      spokenText: _spokenText,
    );

    final containsKeyword = cleanSpoken.contains(wrd) || normSpoken.contains(wrd);
    final isFuzzy = PocketSpeechNormalizer.isFuzzyMatch(cleanSpoken, sentence, thresholdPercentage: 35) ||
        PocketSpeechNormalizer.isFuzzyMatch(normSpoken, sentence, thresholdPercentage: 35);
    final isPassed = evalResult.accuracyPercentage >= 35 || containsKeyword || isFuzzy;

    if (!isPassed) {
      final focus = evalResult.focusWords.take(2).join(', ');
      setState(() {
        _isRecording = false;
        _speechError = 'Please say: "$sentence"${focus.isNotEmpty ? "\nFocus on: $focus" : ""}';
      });
      PocketGameAudioService.instance.playIncorrectSound();
      await _speak('Not quite right. Say: $sentence');
      return;
    }

    // Speech Passed!
    setState(() {
      _isRecording = false;
      _speechError = null;
      _isWordVerified = true;
      _checkpointGateOpening = true;
    });

    // Computer verifies speech and pronounces the target sentence aloud ONLY AFTER learner finishes speaking!
    await _speak(sentence);

    PocketGameAudioService.instance.playCoinSound();
    PocketGameAudioService.instance.playVictorySfx();

    // Spawn victory celebration burst
    for (int i = 0; i < 28; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 0.006 + _random.nextDouble() * 0.012;
      _particles.add(
        DriveParticle(
          x: 0.50,
          y: 0.45,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          life: 1.0,
          color: const Color(0xFFFFD700),
          size: 5 + _random.nextDouble() * 6,
        ),
      );
    }

    // Dismiss checkpoint, open gate, and restore manual driving controls so player can drive to next word
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isAtCheckpoint = false;
        _checkpointGateOpening = false;
        _isWordVerified = false;
        _spokenText = '';
        _recordingSeconds = 0;
        _currentCheckpointIndex++;

        if (_currentCheckpointIndex >= _checkpoints.length) {
          _allCompleted = true;
          _onCompleteAllCheckpoints();
        }
      });
    });
  }

  Future<void> _onCompleteAllCheckpoints() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    _speak('Congratulations! You completed all ${_checkpoints.length} vocabulary checkpoints on the road!');

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    final actualStep = (widget.day == 1 && widget.stepIndex == 2) ? 2 : widget.stepIndex;
    await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_step_${actualStep}_done', true);

    if (uid != null && uid.isNotEmpty) {
      await PocketFortressDefenseService.recordTrainingPoints(35, uid);
    }

    widget.onCompleted?.call();
  }

  // =========================================================================
  // 🎨 UI & CANVAS DRAWING
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final currentItem = _currentCheckpointIndex < _checkpoints.length
        ? _checkpoints[_currentCheckpointIndex]
        : _checkpoints.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Open World Driving Canvas (Sky, Hills, Trees, Road, House Landmark & Car)
            Positioned.fill(
              child: CustomPaint(
                painter: _OpenWorldDrivePainter(
                  rideMode: _currentRideMode,
                  distanceTraveled: _distanceTraveled,
                  speed: _speed,
                  carLaneY: _carLaneY,
                  cloudScroll: _cloudScroll,
                  sceneryScroll: _sceneryScroll,
                  currentCheckpoint: _currentCheckpointIndex,
                  isAtCheckpoint: _isAtCheckpoint,
                  gateOpening: _checkpointGateOpening,
                  particles: _particles,
                  checkpoints: _checkpoints,
                  kDistancePerCheckpoint: kDistancePerCheckpoint,
                ),
              ),
            ),

            // 2. Responsive Minimal Top Navigation Bar with Ride Switcher
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: _buildMinimalTopBar(),
            ),

            // 3. Checkpoint Stopped State: Minimal Centered Mic Action & Prompt
            if (_isAtCheckpoint)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _buildMinimalBottomMicSection(currentItem),
              ),

            // 4. Drive Controls: Reappears when NOT at checkpoint!
            if (!_isAtCheckpoint && !_allCompleted)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildManualDriveControls(),
              ),

            // 5. Grand Victory Overlay when all checkpoints completed
            if (_allCompleted)
              Positioned.fill(
                child: _buildGrandVictoryOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  /// 🌟 Super Clean, Responsive Top Navigation Bar with Dynamic Ride Mode Switcher
  Widget _buildMinimalTopBar() {
    final modeEmojis = {
      RideMode.car: '🏎️',
      RideMode.jeep: '🚙',
      RideMode.airplane: '✈️',
      RideMode.walking: '🚶',
      RideMode.train: '🚆',
      RideMode.rocket: '🚀',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),

            // Clean, Compact Title & Word Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(modeEmojis[_currentRideMode] ?? '🏎️', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'Day ${widget.day} • Step ${widget.stepIndex}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_currentCheckpointIndex + 1}/${_checkpoints.length}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sound Mute Toggle
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isAudioMuted = !_isAudioMuted);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  _isAudioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _isAudioMuted ? Colors.redAccent : const Color(0xFFFFD700),
                  size: 18,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 🚀 Dedicated Day Vehicle & World Badge (User Audio Directive: 1 dedicated game theme per day!)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            _getRideModeTitle(),
            style: GoogleFonts.outfit(
              color: const Color(0xFF38BDF8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  String _getRideModeTitle() {
    switch (_currentRideMode) {
      case RideMode.car:
        return '🏎️ Day ${widget.day} • Highway Sports Cruiser';
      case RideMode.jeep:
        return '🚙 Day ${widget.day} • 4x4 Off-Road Safari Jeep';
      case RideMode.airplane:
        return '✈️ Day ${widget.day} • Skyward Flight Airplane';
      case RideMode.rocket:
        return '🚀 Day ${widget.day} • Cosmic Star Rocket';
      case RideMode.walking:
        return '🚶 Day ${widget.day} • Forest Trail Nature Explorer';
      case RideMode.train:
        return '🚆 Day ${widget.day} • High-Speed Express Bullet Train';
    }
  }

  /// 🎙️ Minimal Centered Floating Action Button with Mic (Appears at stopped checkpoint)
  Widget _buildMinimalBottomMicSection(Map<String, dynamic> item) {
    final wrd = item['word'] ?? 'Book';
    final ml = item['meaningMl'] ?? 'പുസ്തകം';
    final emoji = item['emoji'] ?? '🚗';
    final sentence = item['sentence'] ?? 'This is a $wrd.';
    final sentenceMl = item['sentenceMl'] ?? ml;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sentence Prompt Box: Speak: "The sun is bright."
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isWordVerified
                  ? const Color(0xFF10B981)
                  : (_isRecording ? const Color(0xFFEF4444) : const Color(0xFFFFD700)),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Word Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '$wrd • $ml',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Target Sentence (Bold, Clear, Prominent)
              Text(
                'Speak: "$sentence"',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sentenceMl,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Live Recording Feedback Row
              if (_isRecording) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RECORDING 00:${_recordingSeconds.toString().padLeft(2, '0')}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFCA5A5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🎙️ Speak aloud into your mic...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Error Feedback Box: Shows what learner said vs what was expected!
              if (_speechError != null && !_isRecording && !_isWordVerified) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.8)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'NOT QUITE RIGHT • TAP MIC TO RETRY',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFF87171),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _speechError!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Verified Success Pill
              if (_isWordVerified) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    '✅ Excellent! “$_spokenText”',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34D399),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Centered Floating Action Button with Mic (Tap to record, tap again to STOP & verify)
        GestureDetector(
          onTap: () => _toggleManualRecording(sentence),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale = _isRecording
                  ? 1.0 + (_pulseController.value * 0.12)
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isWordVerified
                          ? [const Color(0xFF059669), const Color(0xFF10B981)]
                          : (_isRecording
                              ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                              : [const Color(0xFF059669), const Color(0xFF10B981)]),
                    ),
                    border: Border.all(
                      color: _isWordVerified
                          ? const Color(0xFF34D399)
                          : (_isRecording
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFFFD700)),
                      width: 2.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isRecording
                            ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                            : const Color(0xFF10B981).withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isWordVerified
                          ? Icons.check_circle_rounded
                          : (_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                      color: Colors.white,
                      size: _isRecording ? 36 : 34,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Hint text below mic
        Text(
          _isWordVerified
              ? '✅ Verified! Road opening...'
              : (_isRecording
                  ? 'Tap red button to STOP & verify'
                  : 'Tap mic & speak aloud'),
          style: GoogleFonts.inter(
            color: _isRecording ? const Color(0xFFFCA5A5) : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 🏎️ Manual Drive Controls (Drive Forward & Reverse)
  Widget _buildManualDriveControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ◀️ Reverse Button
        GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            setState(() => _isReversePressed = true);
          },
          onTapUp: (_) => setState(() => _isReversePressed = false),
          onTapCancel: () => setState(() => _isReversePressed = false),
          child: Container(
            width: 76,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  'BACK',
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

        // 🏎️ Large Drive Forward Button with Animated Arrow Guide
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Guide Arrow
            AnimatedBuilder(
              animation: _arrowGuideController,
              builder: (context, _) {
                final offset = math.sin(_arrowGuideController.value * math.pi) * 3;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'HOLD TO DRIVE ➔',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Drive Forward Button
            GestureDetector(
              onTapDown: (_) {
                HapticFeedback.lightImpact();
                setState(() => _isForwardPressed = true);
              },
              onTapUp: (_) => setState(() => _isForwardPressed = false),
              onTapCancel: () => setState(() => _isForwardPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 150,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isForwardPressed
                        ? [const Color(0xFF047857), const Color(0xFF065F46)]
                        : [const Color(0xFF10B981), const Color(0xFF059669)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'DRIVE ➔',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
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
      ],
    );
  }

  Widget _buildGrandVictoryOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              Text(
                'QUEST COMPLETED! 🏁',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You completed all ${_checkpoints.length} Day ${widget.day} vocabulary landmarks and mastered their pronunciation!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🚗 COMPLETE STEP 2 ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
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
}

/// 🌄 CustomPainter for rendering the Open World Movement Landscape & Thematic Vocabulary Landmarks
class _OpenWorldDrivePainter extends CustomPainter {
  final RideMode rideMode;
  final double distanceTraveled;
  final double speed;
  final double carLaneY;
  final double cloudScroll;
  final double sceneryScroll;
  final int currentCheckpoint;
  final bool isAtCheckpoint;
  final bool gateOpening;
  final List<DriveParticle> particles;
  final List<Map<String, dynamic>> checkpoints;
  final double kDistancePerCheckpoint;

  _OpenWorldDrivePainter({
    required this.rideMode,
    required this.distanceTraveled,
    required this.speed,
    required this.carLaneY,
    required this.cloudScroll,
    required this.sceneryScroll,
    required this.currentCheckpoint,
    required this.isAtCheckpoint,
    required this.gateOpening,
    required this.particles,
    required this.checkpoints,
    required this.kDistancePerCheckpoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // =========================================================================
    // 1. DYNAMIC SKY & BACKGROUND ADAPTED TO RIDE MODE
    // =========================================================================
    _drawDynamicSky(canvas, size);

    // =========================================================================
    // 2. CELESTIAL / HORIZON DETAILS (Sun, Stars, Clouds, Distant Terrain)
    // =========================================================================
    _drawSceneryAndHorizon(canvas, size);

    // =========================================================================
    // 3. ROAD / TRAIL / TERRAIN SURFACE
    // =========================================================================
    final roadTopY = size.height * 0.62;
    final roadBottomY = size.height * 0.86;
    final roadHeight = roadBottomY - roadTopY;

    _drawTerrainSurface(canvas, size, roadTopY, roadBottomY, roadHeight);

    // =========================================================================
    // 4. ONCOMING OPPOSITE VEHICLE (User Audio Directive: "ഓപ്പോസിറ്റ് വരാ!")
    // =========================================================================
    if (rideMode == RideMode.jeep || rideMode == RideMode.car) {
      _drawOppositeTraffic(canvas, size, roadTopY, roadHeight);
    }

    // =========================================================================
    // 5. THEMATIC VOCABULARY LANDMARKS (User Audio Directive: Real objects like Book, Fountain, Tree, etc. instead of houses!)
    // =========================================================================
    _drawThematicVocabularyLandmarks(canvas, size, roadTopY);

    // =========================================================================
    // 6. PLAYER RIDE / AVATAR (Car, Safari Jeep, Plane, Walking Explorer, Rocket)
    // =========================================================================
    _drawPlayerRide(canvas, size);

    // =========================================================================
    // 7. PARTICLES & EXHAUST (Dust, Smoke, Contrails, Sparks)
    // =========================================================================
    for (final p in particles) {
      final pPaint = Paint()..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, pPaint);
    }
  }

  void _drawDynamicSky(Canvas canvas, Size size) {
    switch (rideMode) {
      case RideMode.train:
        // Atmospheric twilight dawn sky (deep indigo to vibrant orange sunrise)
        final skyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF4338CA), Color(0xFFF97316), Color(0xFFFED7AA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.64));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.64), skyPaint);
        break;

      case RideMode.rocket:
        // Deep cosmic space gradient
        final skyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.64));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.64), skyPaint);
        break;

      case RideMode.airplane:
        // High-altitude azure sky
        final skyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFE0F2FE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.64));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.64), skyPaint);
        break;

      case RideMode.walking:
        // Emerald rainforest / jungle canopy atmosphere
        final skyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFFA7F3D0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.64));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.64), skyPaint);
        break;

      case RideMode.jeep:
        // Warm safari canyon sky
        final skyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFFEF3C7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.64));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.64), skyPaint);
        break;

      case RideMode.car:
        // Bright sunny morning
        final skyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.64));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.64), skyPaint);
        break;
    }
  }

  void _drawSceneryAndHorizon(Canvas canvas, Size size) {
    if (rideMode == RideMode.rocket) {
      // Cosmic stars & distant nebula
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      for (int i = 0; i < 40; i++) {
        final sx = ((i * 73 + cloudScroll * 6) % size.width);
        final sy = ((i * 37) % (size.height * 0.55));
        final sRadius = (i % 3 == 0) ? 2.2 : 1.2;
        canvas.drawCircle(Offset(sx, sy), sRadius, starPaint);
      }
      // Distant ringed planet
      final planetPaint = Paint()..color = const Color(0xFF818CF8).withValues(alpha: 0.65);
      canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.16), 26, planetPaint);
      return;
    }

    // Sun for Earthly modes
    final sunCenter = Offset(size.width * 0.82, size.height * 0.16);
    final sunGlowPaint = Paint()
      ..color = (rideMode == RideMode.jeep ? const Color(0xFFF59E0B) : const Color(0xFFFFD700)).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(sunCenter, 38, sunGlowPaint);

    final sunPaint = Paint()..color = (rideMode == RideMode.jeep ? const Color(0xFFFDE68A) : const Color(0xFFFFF066));
    canvas.drawCircle(sunCenter, 22, sunPaint);

    // Drifting clouds (more voluminous for airplane mode!)
    final cloudCount = (rideMode == RideMode.airplane) ? 5 : 2;
    for (int c = 0; c < cloudCount; c++) {
      final speedFactor = 14 + c * 6.0;
      final xPos = ((cloudScroll * speedFactor) + (c * 140)) % (size.width + 160) - 80;
      final yPos = size.height * (0.08 + c * 0.08);
      final cRadius = 34.0 + (c % 2) * 10;
      _drawCloud(canvas, Offset(xPos, yPos), cRadius);
    }

    if (rideMode == RideMode.airplane) {
      // 🏔️ Dramatic Alpine Mountain Summits & Snow Peaks below flight path
      // 1. Distant Snowy Sharp Peaks (Slate / Violet mountain wall with bright snow caps)
      final peakPaint = Paint()..color = const Color(0xFF1E293B);
      final snowPaint = Paint()..color = Colors.white;
      final peakOffset = (sceneryScroll * 0.4) % 160;
      for (double px = -peakOffset; px <= size.width + 160; px += 160) {
        final pPath = Path()
          ..moveTo(px - 90, size.height * 0.62)
          ..lineTo(px, size.height * 0.30)
          ..lineTo(px + 90, size.height * 0.62)
          ..close();
        canvas.drawPath(pPath, peakPaint);

        // Snow Cap
        final sPath = Path()
          ..moveTo(px - 30, size.height * 0.40)
          ..lineTo(px, size.height * 0.30)
          ..lineTo(px + 30, size.height * 0.40)
          ..lineTo(px + 12, size.height * 0.38)
          ..lineTo(px, size.height * 0.41)
          ..lineTo(px - 12, size.height * 0.38)
          ..close();
        canvas.drawPath(sPath, snowPaint);
      }

      // 2. Mid-altitude rolling alpine ridges (ascending & descending peaks)
      final ridgePaint = Paint()..color = const Color(0xFF047857);
      final ridgePath = Path()..moveTo(0, size.height * 0.62);
      for (double x = 0; x <= size.width; x += 25) {
        final ry = size.height * 0.45 + math.sin((x + sceneryScroll * 0.85) * 0.014) * 32;
        ridgePath.lineTo(x, ry);
      }
      ridgePath.lineTo(size.width, size.height * 0.62);
      ridgePath.lineTo(0, size.height * 0.62);
      ridgePath.close();
      canvas.drawPath(ridgePath, ridgePaint);

      // 3. Low altitude deep pine slopes
      final slopePaint = Paint()..color = const Color(0xFF064E3B);
      final slopePath = Path()..moveTo(0, size.height * 0.62);
      for (double x = 0; x <= size.width; x += 20) {
        final sy = size.height * 0.53 + math.sin((x + sceneryScroll * 1.5) * 0.018) * 18;
        slopePath.lineTo(x, sy);
      }
      slopePath.lineTo(size.width, size.height * 0.62);
      slopePath.lineTo(0, size.height * 0.62);
      slopePath.close();
      canvas.drawPath(slopePath, slopePaint);

      // 4. Fast-rushing cloud wisps underneath the plane
      final wispPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
      final wispOffset = (cloudScroll * 24) % (size.width + 160);
      for (int w = 0; w < 3; w++) {
        final wx = (size.width - wispOffset + (w * 170)) % (size.width + 160) - 80;
        final wy = size.height * (0.54 + w * 0.035);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(wx, wy, 90 + w * 30, 10), const Radius.circular(5)),
          wispPaint,
        );
      }
      return;
    }

    // Rolling Distant Hills / Mountains
    final hillColor = rideMode == RideMode.jeep
        ? const Color(0xFF78350F)
        : (rideMode == RideMode.walking ? const Color(0xFF064E3B) : const Color(0xFF0369A1));
    final hillPaint = Paint()..color = hillColor;
    final hillPath = Path();
    hillPath.moveTo(0, size.height * 0.44);
    for (double x = 0; x <= size.width; x += 50) {
      final y = size.height * 0.38 + math.sin((x + sceneryScroll * 0.25) * 0.02) * 20;
      hillPath.lineTo(x, y);
    }
    hillPath.lineTo(size.width, size.height * 0.62);
    hillPath.lineTo(0, size.height * 0.62);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // Foreground lush meadow / desert mounds
    final moundColor = rideMode == RideMode.jeep
        ? const Color(0xFF92400E)
        : (rideMode == RideMode.walking ? const Color(0xFF059669) : const Color(0xFF10B981));
    final moundPaint = Paint()..color = moundColor;
    final moundPath = Path();
    moundPath.moveTo(0, size.height * 0.52);
    for (double x = 0; x <= size.width; x += 30) {
      final y = size.height * 0.50 + math.sin((x + sceneryScroll * 0.6) * 0.015) * 14;
      moundPath.lineTo(x, y);
    }
    moundPath.lineTo(size.width, size.height * 0.62);
    moundPath.lineTo(0, size.height * 0.62);
    moundPath.close();
    canvas.drawPath(moundPath, moundPaint);

    // 🚆 Overhead Catenary Railway Electric Poles & Transmission Wires (Day 5 Train Mode)
    if (rideMode == RideMode.train) {
      final polePaint = Paint()..color = const Color(0xFF64748B)..strokeWidth = 3.5;
      final armPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.5;
      final wirePaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 1.2;

      final wireY = size.height * 0.62 - 44;
      // Continuous overhead contact wires
      canvas.drawLine(Offset(0, wireY), Offset(size.width, wireY), wirePaint);
      canvas.drawLine(Offset(0, wireY - 8), Offset(size.width, wireY - 8), wirePaint);

      // Vertical steel masts scrolling past
      const mastSpacing = 160.0;
      final mastOffset = (sceneryScroll * 1.2) % mastSpacing;
      for (double px = -mastOffset; px <= size.width + mastSpacing; px += mastSpacing) {
        canvas.drawLine(Offset(px, size.height * 0.62), Offset(px, wireY - 14), polePaint);
        canvas.drawLine(Offset(px, wireY - 10), Offset(px + 32, wireY), armPaint);
        canvas.drawCircle(Offset(px + 28, wireY), 3.0, Paint()..color = const Color(0xFFF59E0B));
      }
    }

    // Roadside trees (acacia for safari, jungle palms for walking, oak for car)
    if (rideMode != RideMode.airplane && rideMode != RideMode.rocket && rideMode != RideMode.train) {
      final treeOffset1 = ((sceneryScroll * 0.9) % (size.width + 120)) - 60;
      _drawTree(canvas, Offset(treeOffset1, size.height * 0.62 - 2), 24);
      final treeOffset2 = (((sceneryScroll * 0.9) + size.width * 0.55) % (size.width + 120)) - 60;
      _drawTree(canvas, Offset(treeOffset2, size.height * 0.62 - 2), 20);
    }
  }

  void _drawTerrainSurface(Canvas canvas, Size size, double roadTopY, double roadBottomY, double roadHeight) {
    switch (rideMode) {
      case RideMode.train:
        // 🚆 Authentic High-Speed Railway Track with Ballast Gravel, Wooden Sleepers & Twin Steel Rails
        // 1. Ballast Gravel Bed
        final ballastPaint = Paint()..color = const Color(0xFF334155);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), ballastPaint);

        // Gravel texture specks
        final speckPaint = Paint()..color = const Color(0xFF475569);
        final speckOffset = (distanceTraveled * 1.8) % 18;
        for (double sx = -speckOffset; sx < size.width; sx += 18) {
          canvas.drawCircle(Offset(sx + 4, roadTopY + 8), 1.5, speckPaint);
          canvas.drawCircle(Offset(sx + 12, roadBottomY - 8), 1.5, speckPaint);
        }

        // Embankment curb / borders
        final trackEdgePaint = Paint()..color = const Color(0xFF1E293B);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY - 4, size.width, 5), trackEdgePaint);
        final ballastBedBottom = Paint()..color = const Color(0xFF0F172A);
        canvas.drawRect(Rect.fromLTWH(0, roadBottomY, size.width, size.height * 0.14), ballastBedBottom);

        // 2. Transverse Railroad Ties / Wooden Sleepers
        final tiePaint = Paint()..color = const Color(0xFF451A03);
        final clipPaint = Paint()..color = const Color(0xFF94A3B8);
        const tieSpacing = 24.0;
        final tieOffset = (distanceTraveled * 2.2) % tieSpacing;

        final topRailY = roadTopY + roadHeight * 0.32;
        final botRailY = roadTopY + roadHeight * 0.76;

        for (double tx = -tieOffset; tx < size.width; tx += tieSpacing) {
          // Sleeper tie
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(tx + 2, roadTopY + 10, 10, roadHeight - 20),
              const Radius.circular(2),
            ),
            tiePaint,
          );
          // Steel tie plates / fastening clips at rail intersections
          canvas.drawRect(Rect.fromLTWH(tx + 2, topRailY - 3, 10, 6), clipPaint);
          canvas.drawRect(Rect.fromLTWH(tx + 2, botRailY - 3, 10, 6), clipPaint);
        }

        // 3. Twin Continuous Steel Rails (Shining metallic with highlight gleam)
        final railShadow = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 6.0;
        final railSteel = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 4.0;
        final railHighlight = Paint()..color = Colors.white.withValues(alpha: 0.9)..strokeWidth = 1.5;

        // Top Rail
        canvas.drawLine(Offset(0, topRailY + 1), Offset(size.width, topRailY + 1), railShadow);
        canvas.drawLine(Offset(0, topRailY), Offset(size.width, topRailY), railSteel);
        canvas.drawLine(Offset(0, topRailY - 1), Offset(size.width, topRailY - 1), railHighlight);

        // Bottom Rail
        canvas.drawLine(Offset(0, botRailY + 1), Offset(size.width, botRailY + 1), railShadow);
        canvas.drawLine(Offset(0, botRailY), Offset(size.width, botRailY), railSteel);
        canvas.drawLine(Offset(0, botRailY - 1), Offset(size.width, botRailY - 1), railHighlight);
        break;

      case RideMode.rocket:
        // Cosmic runway grid
        final runwayPaint = Paint()..color = const Color(0xFF090D1A);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), runwayPaint);
        final glowBorder = Paint()..color = const Color(0xFF6366F1)..strokeWidth = 2;
        canvas.drawLine(Offset(0, roadTopY), Offset(size.width, roadTopY), glowBorder);
        canvas.drawLine(Offset(0, roadBottomY), Offset(size.width, roadBottomY), glowBorder);
        // Warp grid markers
        final warpPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)..strokeWidth = 2;
        final dashOffset = (distanceTraveled * 2.2) % 50;
        for (double x = -dashOffset; x < size.width; x += 50) {
          canvas.drawLine(Offset(x, roadTopY + roadHeight * 0.5), Offset(x + 28, roadTopY + roadHeight * 0.5), warpPaint);
        }
        break;

      case RideMode.airplane:
        // Aerial sky corridor with rolling cloud banks and rushing wind streams
        final skyCorridorPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          ).createShader(Rect.fromLTWH(0, roadTopY, size.width, roadHeight));
        canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), skyCorridorPaint);

        // Rolling cloud bed beneath aircraft that scrolls dynamically with distanceTraveled
        final cloudBedPaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
        final cloudRollOffset = (distanceTraveled * 2.2) % 65;
        for (double x = -cloudRollOffset; x <= size.width + 65; x += 65) {
          canvas.drawCircle(Offset(x, roadBottomY - 6), 34, cloudBedPaint);
          canvas.drawCircle(Offset(x + 32, roadBottomY - 14), 26, cloudBedPaint);
        }

        // Fast-rushing wind streamline vectors showing tangible speed
        final windPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        final windOffset1 = (distanceTraveled * 3.8) % 110;
        final windOffset2 = (distanceTraveled * 4.6) % 140;
        for (double x = -windOffset1; x <= size.width + 110; x += 110) {
          canvas.drawLine(Offset(x, roadTopY + roadHeight * 0.28), Offset(x + 48, roadTopY + roadHeight * 0.28), windPaint);
        }
        for (double x = -windOffset2; x <= size.width + 140; x += 140) {
          canvas.drawLine(Offset(x, roadTopY + roadHeight * 0.68), Offset(x + 65, roadTopY + roadHeight * 0.68), windPaint);
        }
        break;

      case RideMode.walking:
        // Forest Cobblestone Path
        final pathPaint = Paint()..color = const Color(0xFF475569);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), pathPaint);
        // Grass borders
        final forestBorder = Paint()..color = const Color(0xFF065F46);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY - 6, size.width, 8), forestBorder);
        canvas.drawRect(Rect.fromLTWH(0, roadBottomY, size.width, size.height * 0.14), forestBorder);
        // Cobblestones
        final stonePaint = Paint()..color = const Color(0xFF64748B);
        final stoneOffset = (distanceTraveled * 1.5) % 40;
        for (double x = -stoneOffset; x < size.width; x += 40) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x + 4, roadTopY + 12, 18, 12), const Radius.circular(4)),
            stonePaint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x + 20, roadTopY + 34, 16, 10), const Radius.circular(4)),
            stonePaint,
          );
        }
        break;

      case RideMode.jeep:
        // Safari Dirt / Canyon Track
        final dirtPaint = Paint()..color = const Color(0xFF78350F);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), dirtPaint);
        // Desert sand shoulder
        final sandBorder = Paint()..color = const Color(0xFF92400E);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY - 6, size.width, 8), sandBorder);
        canvas.drawRect(Rect.fromLTWH(0, roadBottomY, size.width, size.height * 0.14), sandBorder);
        // Rough tire ruts
        final rutPaint = Paint()..color = const Color(0xFF451A03)..strokeWidth = 3;
        final rutOffset = (distanceTraveled * 1.8) % 36;
        for (double x = -rutOffset; x < size.width; x += 36) {
          canvas.drawLine(Offset(x, roadTopY + 16), Offset(x + 18, roadTopY + 16), rutPaint);
          canvas.drawLine(Offset(x, roadTopY + 48), Offset(x + 18, roadTopY + 48), rutPaint);
        }
        break;

      case RideMode.car:
        // Classic Asphalt Highway
        final grassBorderPaint = Paint()..color = const Color(0xFF047857);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY - 6, size.width, 8), grassBorderPaint);
        final roadPaint = Paint()..color = const Color(0xFF1E293B);
        canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), roadPaint);
        final curbPaint = Paint()..color = const Color(0xFF334155);
        canvas.drawRect(Rect.fromLTWH(0, roadBottomY, size.width, size.height * 0.14), curbPaint);
        // Dashed center highway lines
        final laneMarkerPaint = Paint()..color = const Color(0xFFFFD700)..strokeWidth = 3.5;
        final dashOffset = (distanceTraveled * 1.5) % 40;
        for (double x = -dashOffset; x < size.width; x += 40) {
          canvas.drawLine(
            Offset(x, roadTopY + roadHeight * 0.5),
            Offset(x + 22, roadTopY + roadHeight * 0.5),
            laneMarkerPaint,
          );
        }
        break;
    }
  }

  /// 🚗 Oncoming Opposite Vehicle (User Audio Directive: "ഓപ്പോസിറ്റ് വരാ!")
  void _drawOppositeTraffic(Canvas canvas, Size size, double roadTop, double roadHeight) {
    // Calculates a car driving smoothly from right to left in the upper lane
    final cyclePeriod = size.width * 2.8;
    final oppX = size.width + 120 - ((distanceTraveled * 1.4 + sceneryScroll * 2.2) % cyclePeriod);

    if (oppX < -100 || oppX > size.width + 120) return;

    final oppY = roadTop + roadHeight * 0.26;

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(oppX, oppY + 12), width: 62, height: 12), shadowPaint);

    // Opposite vehicle body (Blue/Teal sedan pointing LEFT)
    final oppBodyPaint = Paint()..color = const Color(0xFF0284C7);
    final oppPath = Path();
    oppPath.moveTo(oppX + 26, oppY + 6);
    oppPath.lineTo(oppX + 26, oppY - 2);
    oppPath.lineTo(oppX + 12, oppY - 10);
    oppPath.lineTo(oppX - 10, oppY - 10);
    oppPath.lineTo(oppX - 24, oppY - 2);
    oppPath.lineTo(oppX - 26, oppY + 6);
    oppPath.close();
    canvas.drawPath(oppPath, oppBodyPaint);

    // Windshield facing LEFT
    final glassPaint = Paint()..color = const Color(0xFFBAE6FD);
    canvas.drawRect(Rect.fromLTWH(oppX - 18, oppY - 8, 14, 6), glassPaint);

    // Yellow Headlights beaming to the LEFT!
    final oppLightPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFF066).withValues(alpha: 0.5), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(oppX - 28, oppY + 2), radius: 24));
    canvas.drawOval(Rect.fromLTWH(oppX - 44, oppY - 4, 30, 12), oppLightPaint);

    // Spinning wheels
    final tirePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(oppX - 16, oppY + 7), 6, tirePaint);
    canvas.drawCircle(Offset(oppX + 16, oppY + 7), 6, tirePaint);
  }

  // =========================================================================
  // 📚 THEMATIC VOCABULARY LANDMARKS (User Audio Directive!)
  // =========================================================================
  void _drawThematicVocabularyLandmarks(Canvas canvas, Size size, double roadTop) {
    for (int i = 0; i < checkpoints.length; i++) {
      final targetDistance = (i + 1) * kDistancePerCheckpoint;
      final distToCar = targetDistance - distanceTraveled;
      final objX = (size.width * 0.24) + distToCar + 40;

      // Only draw if within screen view
      if (objX < -180 || objX > size.width + 180) continue;

      final item = checkpoints[i];
      final isSelected = (i == currentCheckpoint && isAtCheckpoint);

      // Draw the specialized 3D thematic sculpture according to the word!
      _drawThematicObject(canvas, objX, roadTop, item, isSelected);

      // Floating illuminated vocabulary billboard on top
      _drawSignboard(canvas, objX, roadTop, item, isSelected, i + 1);
    }
  }

  /// 🎨 Renders Dedicated Thematic Objects instead of generic houses! (User Audio Directive!)
  void _drawThematicObject(Canvas canvas, double objX, double roadTop, Map<String, dynamic> item, bool isSelected) {
    final word = (item['word']?.toString() ?? '').toLowerCase();

    // 1. Base pedestal / Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.32);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(objX, roadTop + 2), width: 130, height: 18),
      shadowPaint,
    );

    // Marble plinth foundation
    final plinthPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(objX - 55, roadTop - 14, 110, 16));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(objX - 55, roadTop - 14, 110, 16), const Radius.circular(5)),
      plinthPaint,
    );

    // 2. Specialized Thematic Sculpture based on Word:
    if (word.contains('book') || word.contains('paper')) {
      _drawGiantOpenBook(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('water') || word.contains('drink')) {
      _drawCrystalFountain(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('tree')) {
      _drawMajesticAncientTree(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('food') || word.contains('eat')) {
      _drawGourmetBistro(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('car')) {
      _drawShowroomTurntable(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('home')) {
      _drawCozyCottage(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('cat') || word.contains('dog')) {
      _drawPetSanctuary(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('sun')) {
      _drawSunTemple(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('ball')) {
      _drawTrophyPodium(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('door')) {
      _drawGoldenDoorway(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('milk')) {
      _drawDairyKiosk(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('school')) {
      _drawAcademyBuilding(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('friend') || word.contains('family')) {
      _drawFriendshipMonument(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('clock')) {
      _drawVictorianClocktower(canvas, objX, roadTop - 14, isSelected);
    } else if (word.contains('star')) {
      _drawCelestialStarShrine(canvas, objX, roadTop - 14, isSelected);
    } else {
      // Default: High-tech holographic energy crystal display
      _drawHolographicCrystalMonument(canvas, objX, roadTop - 14, item, isSelected);
    }
  }

  // 📖 1. Giant Open Book Sculpture (User's specific audio example: "പേപ്പർ അല്ലെങ്കിൽ ബുക്ക് ആക്കാൻ പറ്റുമോ?")
  void _drawGiantOpenBook(Canvas canvas, double x, double y, bool isSelected) {
    final bookW = 86.0;
    final bookH = 48.0;

    // Glowing aura if selected
    if (isSelected) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(Offset(x, y - bookH * 0.5), 44, glowPaint);
    }

    // Book Cover Leather Binding
    final coverPaint = Paint()..color = const Color(0xFF7C2D12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - bookW / 2 - 4, y - bookH - 2, bookW + 8, bookH + 4), const Radius.circular(6)),
      coverPaint,
    );

    // Left Page (Curved Open White Page)
    final leftPagePaint = Paint()..color = const Color(0xFFF8FAFC);
    final leftPath = Path();
    leftPath.moveTo(x - 2, y - 6);
    leftPath.lineTo(x - bookW / 2, y - 4);
    leftPath.quadraticBezierTo(x - bookW / 2 + 8, y - bookH, x - 2, y - bookH + 6);
    leftPath.close();
    canvas.drawPath(leftPath, leftPagePaint);

    // Right Page (Curved Open White Page)
    final rightPagePaint = Paint()..color = const Color(0xFFFFFFFF);
    final rightPath = Path();
    rightPath.moveTo(x + 2, y - 6);
    rightPath.lineTo(x + bookW / 2, y - 4);
    rightPath.quadraticBezierTo(x + bookW / 2 - 8, y - bookH, x + 2, y - bookH + 6);
    rightPath.close();
    canvas.drawPath(rightPath, rightPagePaint);

    // Ruled lines of text on pages
    final textLinePaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6;
    for (int l = 1; l <= 4; l++) {
      final lineY = y - bookH + 12 + l * 6.5;
      canvas.drawLine(Offset(x - bookW / 2 + 10, lineY), Offset(x - 10, lineY), textLinePaint);
      canvas.drawLine(Offset(x + 10, lineY), Offset(x + bookW / 2 - 10, lineY), textLinePaint);
    }

    // Golden Bookmark Ribbon
    final ribbonPaint = Paint()..color = const Color(0xFFFFD700)..strokeWidth = 3.5;
    canvas.drawLine(Offset(x, y - bookH + 4), Offset(x + 4, y + 2), ribbonPaint);
  }

  // 💧 2. Crystal Water Fountain
  void _drawCrystalFountain(Canvas canvas, double x, double y, bool isSelected) {
    // Marble Lower Basin
    final basinPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 10), width: 78, height: 22), basinPaint);

    // Sparkling Blue Water Pool
    final waterPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 12), width: 68, height: 16), waterPaint);

    // Fountain Column
    final colPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 7, y - 42, 14, 32), const Radius.circular(3)), colPaint);

    // Upper Tier Basin
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 40), width: 38, height: 12), basinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 41), width: 32, height: 9), waterPaint);

    // Bubbling water jets
    final jetPaint = Paint()..color = const Color(0xFFBAE6FD)..strokeWidth = 2;
    canvas.drawLine(Offset(x, y - 42), Offset(x, y - 56), jetPaint);
    canvas.drawCircle(Offset(x - 5, y - 48), 2.5, jetPaint);
    canvas.drawCircle(Offset(x + 5, y - 48), 2.5, jetPaint);
  }

  // 🌳 3. Ancient Majestic Oak Tree
  void _drawMajesticAncientTree(Canvas canvas, double x, double y, bool isSelected) {
    // Broad textured trunk
    final trunkPaint = Paint()..color = const Color(0xFF78350F);
    final trunkPath = Path();
    trunkPath.moveTo(x - 14, y);
    trunkPath.lineTo(x - 7, y - 45);
    trunkPath.lineTo(x + 7, y - 45);
    trunkPath.lineTo(x + 14, y);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    // Triple Lush Canopy Foliage
    final foliageDark = Paint()..color = const Color(0xFF065F46);
    final foliageLight = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(x - 18, y - 50), 22, foliageDark);
    canvas.drawCircle(Offset(x + 18, y - 50), 22, foliageDark);
    canvas.drawCircle(Offset(x, y - 62), 26, foliageLight);

    // Glowing Golden Apples/Fruits
    final applePaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(x - 10, y - 52), 4, applePaint);
    canvas.drawCircle(Offset(x + 12, y - 48), 4, applePaint);
    canvas.drawCircle(Offset(x, y - 68), 4, applePaint);
  }

  // 🍲 4. Gourmet Food Bistro
  void _drawGourmetBistro(Canvas canvas, double x, double y, bool isSelected) {
    // Bistro Counter
    final counterPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 36, y - 28, 72, 28), const Radius.circular(5)), counterPaint);

    // Striped Awning
    final awningRed = Paint()..color = const Color(0xFFDC2626);
    final awningWhite = Paint()..color = Colors.white;
    for (int s = 0; s < 5; s++) {
      canvas.drawRect(Rect.fromLTWH(x - 40 + s * 16, y - 48, 8, 16), awningRed);
      canvas.drawRect(Rect.fromLTWH(x - 32 + s * 16, y - 48, 8, 16), awningWhite);
    }

    // Golden Cloche Platter with Steam
    final clochePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawArc(Rect.fromCenter(center: Offset(x, y - 32), width: 26, height: 20), math.pi, math.pi, true, clochePaint);
    final steamPaint = Paint()..color = Colors.white70..strokeWidth = 1.5;
    canvas.drawLine(Offset(x - 3, y - 44), Offset(x - 5, y - 52), steamPaint);
    canvas.drawLine(Offset(x + 3, y - 44), Offset(x + 5, y - 52), steamPaint);
  }

  // 🚗 5. Vehicle Showroom Turntable
  void _drawShowroomTurntable(Canvas canvas, double x, double y, bool isSelected) {
    // Glowing neon turntable base
    final ringPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 6), width: 84, height: 22), ringPaint);

    // Miniature Sports Car Showcase on plinth
    final carPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 22, y - 24, 44, 16), const Radius.circular(4)), carPaint);
    final glassPaint = Paint()..color = const Color(0xFFBAE6FD);
    canvas.drawRect(Rect.fromLTWH(x - 10, y - 30, 20, 8), glassPaint);
  }

  // 🏠 6. Cozy Cottage Home
  void _drawCozyCottage(Canvas canvas, double x, double y, bool isSelected) {
    final wallPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 34, y - 38, 68, 38), const Radius.circular(4)), wallPaint);

    final roofPaint = Paint()..color = const Color(0xFFDC2626);
    final roofPath = Path();
    roofPath.moveTo(x - 42, y - 38);
    roofPath.lineTo(x, y - 60);
    roofPath.lineTo(x + 42, y - 38);
    roofPath.close();
    canvas.drawPath(roofPath, roofPaint);

    // Chimney with smoke
    final chimneyPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(x + 16, y - 58, 10, 18), chimneyPaint);
    final smokePaint = Paint()..color = Colors.white54;
    canvas.drawCircle(Offset(x + 22, y - 64), 4, smokePaint);
    canvas.drawCircle(Offset(x + 26, y - 72), 6, smokePaint);
  }

  // 🐱 7. Pet Sanctuary Pavilion
  void _drawPetSanctuary(Canvas canvas, double x, double y, bool isSelected) {
    final housePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 26, y - 36, 52, 36), const Radius.circular(4)), housePaint);

    final roofPaint = Paint()..color = const Color(0xFF047857);
    final roofPath = Path();
    roofPath.moveTo(x - 32, y - 36);
    roofPath.lineTo(x, y - 52);
    roofPath.lineTo(x + 32, y - 36);
    roofPath.close();
    canvas.drawPath(roofPath, roofPaint);

    // Cute Arched Doghouse/Cathouse Doorway
    final doorPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 10, y - 22, 20, 22), const Radius.circular(8)), doorPaint);
  }

  // ☀️ 8. Sun Temple Obelisk
  void _drawSunTemple(Canvas canvas, double x, double y, bool isSelected) {
    // Obelisk
    final obeliskPaint = Paint()..color = const Color(0xFFD97706);
    final obPath = Path();
    obPath.moveTo(x - 14, y);
    obPath.lineTo(x - 6, y - 48);
    obPath.lineTo(x + 6, y - 48);
    obPath.lineTo(x + 14, y);
    obPath.close();
    canvas.drawPath(obPath, obeliskPaint);

    // Radiant Golden Solar Orb on top
    final sunPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(x, y - 56), 14, sunPaint);

    // Sunburst rays
    final rayPaint = Paint()..color = const Color(0xFFFDE68A)..strokeWidth = 2.2;
    for (int r = 0; r < 8; r++) {
      final angle = r * (math.pi / 4);
      canvas.drawLine(
        Offset(x + math.cos(angle) * 16, y - 56 + math.sin(angle) * 16),
        Offset(x + math.cos(angle) * 23, y - 56 + math.sin(angle) * 23),
        rayPaint,
      );
    }
  }

  // ⚽ 9. Trophy Podium & Soccer Ball
  void _drawTrophyPodium(Canvas canvas, double x, double y, bool isSelected) {
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 22, y - 24, 44, 24), const Radius.circular(4)), goldPaint);

    // Giant Soccer Ball
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y - 42), 18, ballPaint);
    final pentagonPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(x, y - 42), 6, pentagonPaint);
    canvas.drawCircle(Offset(x - 10, y - 48), 4, pentagonPaint);
    canvas.drawCircle(Offset(x + 10, y - 48), 4, pentagonPaint);
    canvas.drawCircle(Offset(x, y - 30), 4, pentagonPaint);
  }

  // 🚪 10. Golden Doorway Arch
  void _drawGoldenDoorway(Canvas canvas, double x, double y, bool isSelected) {
    // Golden Frame
    final framePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 26, y - 54, 52, 54), const Radius.circular(10)), framePaint);

    // Door Portal Opening with Mystical Cyan Light
    final portalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      ).createShader(Rect.fromLTWH(x - 18, y - 48, 36, 48));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 18, y - 48, 36, 48), const Radius.circular(8)), portalPaint);

    // Brass Doorknob
    final knobPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(x + 10, y - 24), 3, knobPaint);
  }

  // 🥛 11. Dairy Milk Kiosk
  void _drawDairyKiosk(Canvas canvas, double x, double y, bool isSelected) {
    final kioskPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 30, y - 28, 60, 28), const Radius.circular(4)), kioskPaint);

    // Giant Glass Milk Bottle
    final bottlePaint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 10, y - 50, 20, 26), const Radius.circular(4)), bottlePaint);
    canvas.drawRect(Rect.fromLTWH(x - 6, y - 56, 12, 8), bottlePaint);
    final capPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRect(Rect.fromLTWH(x - 7, y - 58, 14, 4), capPaint);
  }

  // 🏫 12. Academy Schoolhouse
  void _drawAcademyBuilding(Canvas canvas, double x, double y, bool isSelected) {
    final brickPaint = Paint()..color = const Color(0xFF991B1B);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 36, y - 36, 72, 36), const Radius.circular(3)), brickPaint);

    // Bell / Clock Tower
    canvas.drawRect(Rect.fromLTWH(x - 12, y - 56, 24, 20), brickPaint);
    final spirePaint = Paint()..color = const Color(0xFF1E293B);
    final spire = Path();
    spire.moveTo(x - 14, y - 56);
    spire.lineTo(x, y - 68);
    spire.lineTo(x + 14, y - 56);
    spire.close();
    canvas.drawPath(spire, spirePaint);

    // Clock face
    final clockFace = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y - 46), 6, clockFace);
  }

  // 🤝 13. Friendship Arch
  void _drawFriendshipMonument(Canvas canvas, double x, double y, bool isSelected) {
    final archPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCenter(center: Offset(x, y - 10), width: 56, height: 60), math.pi, math.pi, false, archPaint);

    // Golden Heart Emblem in Center
    final heartPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(x - 5, y - 42), 6, heartPaint);
    canvas.drawCircle(Offset(x + 5, y - 42), 6, heartPaint);
    final triPath = Path();
    triPath.moveTo(x - 10, y - 40);
    triPath.lineTo(x, y - 30);
    triPath.lineTo(x + 10, y - 40);
    triPath.close();
    canvas.drawPath(triPath, heartPaint);
  }

  // ⏰ 14. Victorian Clock Tower
  void _drawVictorianClocktower(Canvas canvas, double x, double y, bool isSelected) {
    final towerPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRect(Rect.fromLTWH(x - 12, y - 54, 24, 54), towerPaint);

    final clockPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(x, y - 40), 12, clockPaint);

    // Hands
    final handPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 1.8;
    canvas.drawLine(Offset(x, y - 40), Offset(x, y - 48), handPaint);
    canvas.drawLine(Offset(x, y - 40), Offset(x + 5, y - 40), handPaint);
  }

  // ⭐ 15. Celestial Star Shrine
  void _drawCelestialStarShrine(Canvas canvas, double x, double y, bool isSelected) {
    final pillarPaint = Paint()..color = const Color(0xFF6366F1);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 14, y - 44, 28, 44), const Radius.circular(5)), pillarPaint);

    // 5-Pointed Star
    final starPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(x, y - 54), 14, starPaint);
  }

  // 🔮 16. Default Holographic Crystal Monument
  void _drawHolographicCrystalMonument(Canvas canvas, double x, double y, Map<String, dynamic> item, bool isSelected) {
    final crystalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
      ).createShader(Rect.fromCircle(center: Offset(x, y - 36), radius: 24));
    canvas.drawCircle(Offset(x, y - 36), 22, crystalPaint);

    // Neon energy ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 36), width: 56, height: 16), ringPaint);
  }

  /// 🏷️ Sleek Floating Illuminated Vocabulary Signboard
  void _drawSignboard(Canvas canvas, double x, double roadTop, Map<String, dynamic> item, bool isSelected, int index) {
    final word = item['word']?.toString() ?? '';
    final ml = item['meaningMl']?.toString() ?? '';
    final emoji = item['emoji']?.toString() ?? '💎';

    final signW = 142.0;
    final signH = 38.0;
    final signY = roadTop - 110.0;

    // Glowing border when stopped at checkpoint
    if (isSelected) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - signW / 2 - 2, signY - 2, signW + 4, signH + 4), const Radius.circular(10)),
        glowPaint,
      );
    }

    // Signboard Body
    final signBgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - signW / 2, signY, signW, signH), const Radius.circular(8)),
      signBgPaint,
    );

    // Signboard Border
    final signBorderPaint = Paint()
      ..color = isSelected ? const Color(0xFFFFD700) : const Color(0xFF38BDF8)
      ..strokeWidth = isSelected ? 2.4 : 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - signW / 2, signY, signW, signH), const Radius.circular(8)),
      signBorderPaint,
    );

    // Word & Malayalam Text
    final textSpan = TextSpan(
      text: '$emoji $word\n$ml',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        height: 1.15,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: signW);
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, signY + 4));
  }

  // =========================================================================
  // 🏎️ DIVERSE PLAYER RIDES & CHARACTERS (User Audio Directive!)
  // =========================================================================
  void _drawPlayerRide(Canvas canvas, Size size) {
    switch (rideMode) {
      case RideMode.jeep:
        _drawSafariJeep(canvas, size);
        break;
      case RideMode.airplane:
        _drawAirplane(canvas, size);
        break;
      case RideMode.walking:
        _drawWalkingExplorer(canvas, size);
        break;
      case RideMode.train:
        _drawExpressTrain(canvas, size);
        break;
      case RideMode.rocket:
        _drawSpaceRocket(canvas, size);
        break;
      case RideMode.car:
        _drawPlayerCar(canvas, size);
        break;
    }
  }

  // 🏎️ Mode 1: Red Sports Racer
  void _drawPlayerCar(Canvas canvas, Size size) {
    final carX = size.width * 0.24;
    final carY = size.height * carLaneY;

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(carX, carY + 16), width: 78, height: 16), shadowPaint);

    // Body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(carX - 36, carY - 14, 72, 28));

    final carPath = Path();
    carPath.moveTo(carX - 34, carY + 8);
    carPath.lineTo(carX - 34, carY - 2);
    carPath.lineTo(carX - 18, carY - 14);
    carPath.lineTo(carX + 16, carY - 14);
    carPath.lineTo(carX + 34, carY - 2);
    carPath.lineTo(carX + 36, carY + 8);
    carPath.close();
    canvas.drawPath(carPath, bodyPaint);

    // Windshield
    final glassPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85);
    final glassPath = Path();
    glassPath.moveTo(carX - 14, carY - 12);
    glassPath.lineTo(carX + 12, carY - 12);
    glassPath.lineTo(carX + 26, carY - 2);
    glassPath.lineTo(carX - 16, carY - 2);
    glassPath.close();
    canvas.drawPath(glassPath, glassPaint);

    // Headlight Beam
    final headlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFF066).withValues(alpha: 0.6), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(carX + 44, carY + 3), radius: 36));
    canvas.drawOval(Rect.fromLTWH(carX + 34, carY - 6, 44, 18), headlightPaint);

    // Wheels
    _drawWheel(canvas, Offset(carX - 22, carY + 10));
    _drawWheel(canvas, Offset(carX + 22, carY + 10));
  }

  // 🚙 Mode 2: 4x4 Off-Road Safari Jeep (User Audio Directive!)
  void _drawSafariJeep(Canvas canvas, Size size) {
    final jeepX = size.width * 0.24;
    final jeepY = size.height * carLaneY;

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.38);
    canvas.drawOval(Rect.fromCenter(center: Offset(jeepX, jeepY + 18), width: 84, height: 18), shadowPaint);

    // Rugged Boxy Jeep Body (Olive Green / Safari Khaki)
    final jeepBody = Paint()..color = const Color(0xFF4D7C0F);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(jeepX - 36, jeepY - 10, 72, 22), const Radius.circular(5)), jeepBody);

    // Cabin
    final cabinPaint = Paint()..color = const Color(0xFF365314);
    canvas.drawRect(Rect.fromLTWH(jeepX - 22, jeepY - 24, 42, 14), cabinPaint);

    // Roof Rack with Luggage
    final rackPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 2.5;
    canvas.drawLine(Offset(jeepX - 24, jeepY - 26), Offset(jeepX + 20, jeepY - 26), rackPaint);
    final bagPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(jeepX - 16, jeepY - 33, 26, 8), const Radius.circular(2)), bagPaint);

    // Large Windshield
    final glassPaint = Paint()..color = const Color(0xFFBAE6FD);
    canvas.drawRect(Rect.fromLTWH(jeepX + 8, jeepY - 22, 10, 11), glassPaint);

    // Front Bullbar with Fog Lights
    final barPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 3;
    canvas.drawLine(Offset(jeepX + 36, jeepY - 4), Offset(jeepX + 36, jeepY + 12), barPaint);
    final fogPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(jeepX + 36, jeepY + 2), 4, fogPaint);

    // Spare Tire mounted on back
    final sparePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(jeepX - 38, jeepY), 9, sparePaint);

    // Heavy Tread Knobby Off-Road Wheels
    _drawKnobbyWheel(canvas, Offset(jeepX - 22, jeepY + 12));
    _drawKnobbyWheel(canvas, Offset(jeepX + 22, jeepY + 12));
  }

  // ✈️ Mode 3: High-Contrast Golden Canary & Crimson Racing Aeroplane
  // (User Audio Directive: "വിമാനം ആകാശത്തിന്റെ അതേ കളർ ആവരുത്! നന്മയായി കാണണം, മലകൾ കേറി ഇറങ്ങുന്ന പോലെയോ സ്പീഡ് നന്നായി ഫീൽ ചെയ്യണം!")
  void _drawAirplane(Canvas canvas, Size size) {
    final planeX = size.width * 0.24;
    // Dynamic flight rhythm with slight pitch tilt
    final flightBob = math.sin(cloudScroll * 0.18) * 7;
    final pitchAngle = math.cos(cloudScroll * 0.18) * 0.05; // Gentle climb/dive pitch
    final planeY = (size.height * (carLaneY - 0.10)) + flightBob;

    canvas.save();
    canvas.translate(planeX, planeY);
    canvas.rotate(pitchAngle);

    // 1. Dynamic Wind Streaks & Contrails (Rushing backwards)
    final contrailPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final contrailCorePaint = Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.8);
    for (int p = 1; p <= 5; p++) {
      final cx = -40.0 - (p * 18.0);
      final cyTop = -14.0 + (p * 1.5) + math.sin((distanceTraveled * 0.1) + p) * 2;
      final cyBottom = 5.0 - (p * 1.0) + math.cos((distanceTraveled * 0.1) + p) * 2;
      final puffRadius = 3.5 + p * 2.2;
      canvas.drawCircle(Offset(cx, cyTop), puffRadius, contrailPaint);
      canvas.drawCircle(Offset(cx, cyBottom), puffRadius * 0.8, contrailPaint);
      if (p <= 2) {
        canvas.drawCircle(Offset(cx + 8, cyTop), puffRadius * 0.4, contrailCorePaint);
      }
    }

    // High-speed air streaks
    final streakPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-30, -22), const Offset(-75, -22), streakPaint);
    canvas.drawLine(const Offset(-20, 16), const Offset(-80, 16), streakPaint);

    // 2. Far/Under Wing (Deep Crimson with outline)
    final farWingPaint = Paint()..color = const Color(0xFFB91C1C);
    final farWingPath = Path()
      ..moveTo(2, -4)
      ..lineTo(-8, -18)
      ..lineTo(0, -18)
      ..lineTo(14, -4)
      ..close();
    canvas.drawPath(farWingPath, farWingPaint);

    // 3. Aeroplane Fuselage (Canary Gold / Amber #F59E0B with Crimson racing stripe and Dark Outline)
    final fuselageOutline = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final fuselagePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-40, -16, 82, 28));

    final fPath = Path()
      ..moveTo(-40, 0)
      ..lineTo(-36, -16) // Tail fin top
      ..lineTo(-26, -16)
      ..lineTo(-18, -4)
      ..lineTo(26, -4)
      ..lineTo(38, 0) // Nose
      ..lineTo(26, 7)
      ..lineTo(-30, 6)
      ..lineTo(-40, 2)
      ..close();

    canvas.drawPath(fPath, fuselagePaint);

    // Crimson Sport Racing Stripe along Fuselage
    final stripePaint = Paint()..color = const Color(0xFFEF4444);
    final stripePath = Path()
      ..moveTo(-32, 0)
      ..lineTo(32, 0)
      ..lineTo(24, 3)
      ..lineTo(-30, 3)
      ..close();
    canvas.drawPath(stripePath, stripePaint);

    // White Trim Stripe
    final whiteStripePaint = Paint()..color = Colors.white;
    final whiteStripePath = Path()
      ..moveTo(-28, -2)
      ..lineTo(28, -2)
      ..lineTo(26, -0.5)
      ..lineTo(-29, -0.5)
      ..close();
    canvas.drawPath(whiteStripePath, whiteStripePaint);

    // Tail Fin Accent (Crimson)
    final finAccentPaint = Paint()..color = const Color(0xFFEF4444);
    final finPath = Path()
      ..moveTo(-35, -15)
      ..lineTo(-27, -15)
      ..lineTo(-21, -6)
      ..lineTo(-31, -6)
      ..close();
    canvas.drawPath(finPath, finAccentPaint);

    // Dark outline stroke for fuselage
    canvas.drawPath(fPath, fuselageOutline);

    // 4. Near / Main Wing (Swept forward-angle, Crimson & Amber with Strobe Light)
    final mainWingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-6, -2, 28, 24));

    final wingPath = Path()
      ..moveTo(-4, -1)
      ..lineTo(10, 22) // Wingtip
      ..lineTo(18, 22)
      ..lineTo(16, 2)
      ..close();

    canvas.drawPath(wingPath, mainWingPaint);

    // Wing edge outline
    final wingOutline = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(wingPath, wingOutline);

    // Wingtip Yellow Cap & Green Navigation Strobe
    final wingTipPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawRect(const Rect.fromLTWH(10, 19, 8, 3), wingTipPaint);
    final strobePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(const Offset(14, 22), 3.5, strobePaint);

    // 5. Cockpit Bubble (Dark Obsidian with glossy high-altitude sky reflection)
    final cockpitBg = Paint()..color = const Color(0xFF0F172A);
    final cockpitRect = Rect.fromCenter(center: const Offset(14, -5), width: 20, height: 10);
    canvas.drawOval(cockpitRect, cockpitBg);

    // Glass reflection curve
    final glassGlare = Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.85);
    canvas.drawOval(Rect.fromCenter(center: const Offset(13, -6.5), width: 14, height: 4), glassGlare);

    // Pilot silhouette helmet (cute pocket-mate aviator)
    final pilotPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(const Offset(13, -5), 3, pilotPaint);

    // 6. Engine Cowling & Spinning Propeller (Motion Blur Disc + Flashing Blades)
    final noseConePaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawOval(Rect.fromCenter(center: const Offset(38, 0), width: 6, height: 10), noseConePaint);

    // Propeller Spinner Hub (Chrome)
    final hubPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(const Offset(40, 0), 3.5, hubPaint);

    // Spinning Blur Disc
    final propBlurPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(Rect.fromCenter(center: const Offset(42, 0), width: 4, height: 34), propBlurPaint);

    // Propeller Blades (spinning fast with distanceTraveled)
    final propAngle = (distanceTraveled * 0.75) % (math.pi * 2);
    final bladePaint = Paint()
      ..color = const Color(0xFFFFFBEB)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    final tipPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.2;

    final bladeDy = math.sin(propAngle) * 16;
    final bladeDx = math.cos(propAngle) * 2;
    canvas.drawLine(
      Offset(41 - bladeDx, -bladeDy),
      Offset(41 + bladeDx, bladeDy),
      bladePaint,
    );
    // Red blade tips
    canvas.drawCircle(Offset(41 + bladeDx, bladeDy), 2, tipPaint);
    canvas.drawCircle(Offset(41 - bladeDx, -bladeDy), 2, tipPaint);

    canvas.restore();
  }

  // 🚶 Mode 4: Nature Trail Explorer Walking/Jogging (User Audio Directive: "നടന്നു പോവാ / കാട്ടിൽ കൂടെ നടന്നു പോവാ!")
  void _drawWalkingExplorer(Canvas canvas, Size size) {
    final walkX = size.width * 0.24;
    // Step bob animation
    final stepCycle = distanceTraveled * 0.18;
    final bobY = math.sin(stepCycle * 2).abs() * 4;
    final walkY = size.height * carLaneY - bobY;

    // Small ground shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset(walkX, walkY + 16), width: 34, height: 9), shadowPaint);

    // Legs (Swinging with walking stride)
    final legPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4..strokeCap = StrokeCap.round;
    final legSwing = math.sin(stepCycle) * 12;
    // Left leg
    canvas.drawLine(Offset(walkX - 2, walkY + 4), Offset(walkX - 2 - legSwing, walkY + 14), legPaint);
    // Right leg
    canvas.drawLine(Offset(walkX + 2, walkY + 4), Offset(walkX + 2 + legSwing, walkY + 14), legPaint);

    // Torso / Jacket (Explorer Red)
    final jacketPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(walkX - 8, walkY - 14, 16, 18), const Radius.circular(4)), jacketPaint);

    // Hiker Backpack (Khaki)
    final packPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(walkX - 16, walkY - 12, 8, 14), const Radius.circular(3)), packPaint);

    // Head with Explorer Cap
    final facePaint = Paint()..color = const Color(0xFFFDBA74);
    canvas.drawCircle(Offset(walkX + 2, walkY - 22), 7, facePaint);
    final capPaint = Paint()..color = const Color(0xFF047857);
    canvas.drawArc(Rect.fromCenter(center: Offset(walkX + 2, walkY - 24), width: 16, height: 12), math.pi, math.pi, true, capPaint);
    canvas.drawRect(Rect.fromLTWH(walkX + 2, walkY - 25, 10, 3), capPaint); // Cap brim

    // Swinging Arms
    final armPaint = Paint()..color = const Color(0xFFFDBA74)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(walkX, walkY - 8), Offset(walkX + legSwing * 0.8, walkY), armPaint);
  }

  // 🚀 Mode 5: Cosmic Star Rocket (User Audio Directive: "വെർട്ടിക്കൽ ആയിട്ട് / റോക്കറ്റ്!")
  void _drawSpaceRocket(Canvas canvas, Size size) {
    final rocketX = size.width * 0.24;
    final rocketY = size.height * (carLaneY - 0.05);

    // Blazing animated rocket exhaust flames!
    final flamePulsing = 18 + math.sin(distanceTraveled * 0.4).abs() * 12;
    final flameOuter = Paint()..color = const Color(0xFFEF4444);
    final flameInner = Paint()..color = const Color(0xFFFFD700);
    final fPath = Path();
    fPath.moveTo(rocketX - 32, rocketY - 6);
    fPath.lineTo(rocketX - 32 - flamePulsing, rocketY);
    fPath.lineTo(rocketX - 32, rocketY + 6);
    fPath.close();
    canvas.drawPath(fPath, flameOuter);
    canvas.drawCircle(Offset(rocketX - 34, rocketY), 5, flameInner);

    // Rocket Body (Sleek White Spacecraft)
    final rocketPaint = Paint()..color = const Color(0xFFF8FAFC);
    final rPath = Path();
    rPath.moveTo(rocketX - 30, rocketY - 9);
    rPath.lineTo(rocketX + 18, rocketY - 9);
    rPath.lineTo(rocketX + 36, rocketY); // Nosecone tip
    rPath.lineTo(rocketX + 18, rocketY + 9);
    rPath.lineTo(rocketX - 30, rocketY + 9);
    rPath.close();
    canvas.drawPath(rPath, rocketPaint);

    // Delta Stabilizer Fins
    final finPaint = Paint()..color = const Color(0xFF0284C7);
    final topFin = Path();
    topFin.moveTo(rocketX - 28, rocketY - 9);
    topFin.lineTo(rocketX - 12, rocketY - 20);
    topFin.lineTo(rocketX, rocketY - 9);
    topFin.close();
    canvas.drawPath(topFin, finPaint);

    final botFin = Path();
    botFin.moveTo(rocketX - 28, rocketY + 9);
    botFin.lineTo(rocketX - 12, rocketY + 20);
    botFin.lineTo(rocketX, rocketY + 9);
    botFin.close();
    canvas.drawPath(botFin, finPaint);

    // Cockpit Circular Porthole
    final portPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(rocketX + 12, rocketY), 5.5, portPaint);
  }


  // 🚆 Mode 6: High-Speed Express Bullet Train (User Audio Directive: "ഇപ്പൊ ട്രെയിൻ ഒക്കെ ആക്ക് ഇനി!")
  void _drawExpressTrain(Canvas canvas, Size size) {
    final trainX = size.width * 0.24;
    final trainY = size.height * carLaneY;

    // Soft track shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    canvas.drawOval(Rect.fromCenter(center: Offset(trainX, trainY + 16), width: 92, height: 12), shadowPaint);

    // Pantograph Arm reaching overhead electric wire
    final pantoPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final wireY = size.height * 0.62 - 44;
    canvas.drawLine(Offset(trainX - 10, trainY - 16), Offset(trainX - 2, wireY + 8), pantoPaint);
    canvas.drawLine(Offset(trainX - 2, wireY + 8), Offset(trainX + 8, wireY), pantoPaint);
    // Pantograph contact collector head
    canvas.drawLine(Offset(trainX + 2, wireY), Offset(trainX + 16, wireY), Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 3.0);
    // Electric spark sparkler occasionally
    if ((distanceTraveled * 0.2).floor() % 4 == 0) {
      canvas.drawCircle(Offset(trainX + 10, wireY), 3.0, Paint()..color = const Color(0xFF67E8F9));
    }

    // Aerodynamic Bullet Locomotive Body (Pearl White to Silver Gradient)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(trainX - 44, trainY - 16, 88, 30));

    final trainPath = Path();
    trainPath.moveTo(trainX - 42, trainY + 14); // Rear bottom
    trainPath.lineTo(trainX - 42, trainY - 14); // Rear top
    trainPath.lineTo(trainX + 16, trainY - 14); // Front roof
    trainPath.quadraticBezierTo(trainX + 38, trainY - 10, trainX + 46, trainY + 4); // Aerodynamic nose curve
    trainPath.lineTo(trainX + 46, trainY + 14); // Front cowcatcher / bumper
    trainPath.close();
    canvas.drawPath(trainPath, bodyPaint);

    // Royal Blue Racing Livery Stripe
    final stripePaint = Paint()..color = const Color(0xFF1E40AF);
    final sPath = Path();
    sPath.moveTo(trainX - 42, trainY + 2);
    sPath.lineTo(trainX + 34, trainY + 2);
    sPath.quadraticBezierTo(trainX + 42, trainY + 6, trainX + 45, trainY + 10);
    sPath.lineTo(trainX + 45, trainY + 14);
    sPath.lineTo(trainX - 42, trainY + 14);
    sPath.close();
    canvas.drawPath(sPath, stripePaint);

    // Gold Accent Trim
    final goldTrim = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.0;
    canvas.drawLine(Offset(trainX - 42, trainY + 1), Offset(trainX + 32, trainY + 1), goldTrim);

    // Driver Cab Panoramic Windshield (Tinted Cyan Glass)
    final glassPaint = Paint()..color = const Color(0xFF0284C7);
    final cabPath = Path();
    cabPath.moveTo(trainX + 14, trainY - 12);
    cabPath.lineTo(trainX + 28, trainY - 12);
    cabPath.quadraticBezierTo(trainX + 38, trainY - 6, trainX + 40, trainY);
    cabPath.lineTo(trainX + 18, trainY);
    cabPath.close();
    canvas.drawPath(cabPath, glassPaint);

    // Passenger Tinted Windows
    final windowPaint = Paint()..color = const Color(0xFF0F172A);
    for (int w = 0; w < 3; w++) {
      final wx = trainX - 36 + (w * 16.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(wx, trainY - 10, 11, 8), const Radius.circular(2)),
        windowPaint,
      );
    }

    // High-Beam LED Headlamp & Lighting Cone
    final headlampCenter = Offset(trainX + 45, trainY + 6);
    final headlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow.withValues(alpha: 0.65), Colors.yellow.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: headlampCenter, radius: 55));

    final lightBeam = Path();
    lightBeam.moveTo(headlampCenter.dx, headlampCenter.dy - 3);
    lightBeam.lineTo(headlampCenter.dx + 65, headlampCenter.dy - 12);
    lightBeam.lineTo(headlampCenter.dx + 65, headlampCenter.dy + 18);
    lightBeam.lineTo(headlampCenter.dx, headlampCenter.dy + 3);
    lightBeam.close();
    canvas.drawPath(lightBeam, headlightPaint);
    canvas.drawCircle(headlampCenter, 3.0, Paint()..color = Colors.white);

    // Steel Flanged Railway Bogie Wheels (2 Bogies: Front & Back)
    _drawTrainWheel(canvas, Offset(trainX - 28, trainY + 15));
    _drawTrainWheel(canvas, Offset(trainX - 12, trainY + 15));
    _drawTrainWheel(canvas, Offset(trainX + 14, trainY + 15));
    _drawTrainWheel(canvas, Offset(trainX + 28, trainY + 15));
  }

  void _drawTrainWheel(Canvas canvas, Offset center) {
    // Wheel Flange
    canvas.drawCircle(center, 7.5, Paint()..color = const Color(0xFF334155));
    // Steel Tread
    canvas.drawCircle(center, 6.0, Paint()..color = const Color(0xFF94A3B8));
    // Center Axle Hub
    canvas.drawCircle(center, 2.5, Paint()..color = const Color(0xFF0F172A));
  }

  void _drawWheel(Canvas canvas, Offset center) {
    final tirePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, 9, tirePaint);

    final rimPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawCircle(center, 5, rimPaint);

    final spokePaint = Paint()..color = Colors.white..strokeWidth = 1.2;
    final angle = (distanceTraveled * 0.15) % (math.pi * 2);
    canvas.drawLine(
      Offset(center.dx + math.cos(angle) * 4, center.dy + math.sin(angle) * 4),
      Offset(center.dx - math.cos(angle) * 4, center.dy - math.sin(angle) * 4),
      spokePaint,
    );
  }

  void _drawKnobbyWheel(Canvas canvas, Offset center) {
    final tirePaint = Paint()..color = const Color(0xFF0A0F1D);
    canvas.drawCircle(center, 11, tirePaint);

    // Rugged Knobby treads
    final treadPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 2.2;
    for (int t = 0; t < 6; t++) {
      final angle = ((distanceTraveled * 0.15) + t * (math.pi / 3)) % (math.pi * 2);
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * 8, center.dy + math.sin(angle) * 8),
        Offset(center.dx + math.cos(angle) * 12, center.dy + math.sin(angle) * 12),
        treadPaint,
      );
    }

    final hubPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(center, 5.5, hubPaint);
  }

  void _drawCloud(Canvas canvas, Offset center, double radius) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    canvas.drawCircle(center, radius, cloudPaint);
    canvas.drawCircle(center.translate(-radius * 0.55, radius * 0.1), radius * 0.75, cloudPaint);
    canvas.drawCircle(center.translate(radius * 0.55, radius * 0.1), radius * 0.75, cloudPaint);
  }

  void _drawTree(Canvas canvas, Offset groundPos, double height) {
    final trunkPaint = Paint()..color = const Color(0xFF78350F)..strokeWidth = 4;
    canvas.drawLine(groundPos, groundPos.translate(0, -height), trunkPaint);

    final foliagePaint = Paint()..color = const Color(0xFF047857);
    canvas.drawCircle(groundPos.translate(0, -height - 8), height * 0.65, foliagePaint);
  }

  @override
  bool shouldRepaint(covariant _OpenWorldDrivePainter oldDelegate) => true;
}
