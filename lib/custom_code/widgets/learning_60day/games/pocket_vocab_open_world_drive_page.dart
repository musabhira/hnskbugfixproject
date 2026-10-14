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
import '../pocket_fortress_defense_service.dart';

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
class PocketVocabOpenWorldDrivePage extends StatefulWidget {
  final String? userId;
  final VoidCallback? onCompleted;

  const PocketVocabOpenWorldDrivePage({
    super.key,
    this.userId,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String? userId,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketVocabOpenWorldDrivePage(
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
  bool _speechAvailable = false;
  bool _allCompleted = false;

  // Distance between each vocabulary house
  static const double kDistancePerCheckpoint = 320.0;

  @override
  void initState() {
    super.initState();
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
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
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
          _currentCheckpointIndex < vocabCheckpoints.length &&
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

    final item = vocabCheckpoints[_currentCheckpointIndex];
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

    setState(() {
      _isRecording = false;
      _isWordVerified = true;
      _checkpointGateOpening = true;
    });

    // Computer verifies speech and pronounces the target sentence aloud ONLY AFTER learner finishes speaking!
    // ("Voice record aayi off cheythu kazhinjaalaanu 'The sun is bright' ennu computer parayullu!")
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

        if (_currentCheckpointIndex >= vocabCheckpoints.length) {
          _allCompleted = true;
          _onCompleteAllCheckpoints();
        }
      });
    });
  }

  Future<void> _onCompleteAllCheckpoints() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    _speak('Congratulations! You completed all 20 vocabulary checkpoints on the highway!');

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_1_step_2_done', true);

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
    final currentItem = _currentCheckpointIndex < vocabCheckpoints.length
        ? vocabCheckpoints[_currentCheckpointIndex]
        : vocabCheckpoints.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Open World Driving Canvas (Sky, Hills, Trees, Road, House Landmark & Car)
            Positioned.fill(
              child: CustomPaint(
                painter: _OpenWorldDrivePainter(
                  distanceTraveled: _distanceTraveled,
                  speed: _speed,
                  carLaneY: _carLaneY,
                  cloudScroll: _cloudScroll,
                  sceneryScroll: _sceneryScroll,
                  currentCheckpoint: _currentCheckpointIndex,
                  isAtCheckpoint: _isAtCheckpoint,
                  gateOpening: _checkpointGateOpening,
                  particles: _particles,
                  checkpoints: vocabCheckpoints,
                  kDistancePerCheckpoint: kDistancePerCheckpoint,
                ),
              ),
            ),

            // 2. Responsive Minimal Top Navigation Bar
            Positioned(
              top: 10,
              left: 14,
              right: 14,
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

            // 5. Grand Victory Overlay when all 20 checkpoints completed
            if (_allCompleted)
              Positioned.fill(
                child: _buildGrandVictoryOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  /// 🌟 Super Clean, Responsive Top Navigation Bar
  Widget _buildMinimalTopBar() {
    final currentItem = _currentCheckpointIndex < vocabCheckpoints.length
        ? vocabCheckpoints[_currentCheckpointIndex]
        : vocabCheckpoints.last;
    final currentWord = currentItem['word'] ?? 'Book';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),

        // Clean, Compact Title & Word Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.75),
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
              const Text('🚗', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Vocab Drive • $currentWord (${_currentCheckpointIndex + 1}/20)',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
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
              size: 20,
            ),
          ),
        ),
      ],
    );
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
                  _spokenText.isNotEmpty
                      ? '“$_spokenText”'
                      : 'Speak aloud into your mic...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _spokenText.isNotEmpty ? const Color(0xFFFFD700) : Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
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
                'You drove to all 20 vocabulary houses and mastered everyday words!',
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

/// 🌄 CustomPainter for rendering the 2D Open World Driving Landscape & Vocabulary Houses
class _OpenWorldDrivePainter extends CustomPainter {
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
    // 1. Sky Gradient (Bright sunny morning)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.58));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.58), skyPaint);

    // 2. Radiant Sun ☀️
    final sunCenter = Offset(size.width * 0.82, size.height * 0.16);
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(sunCenter, 38, sunGlowPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFF066);
    canvas.drawCircle(sunCenter, 22, sunPaint);

    // 3. Clouds (Drifting smoothly)
    _drawCloud(canvas, Offset((cloudScroll * 20) % (size.width + 120) - 60, size.height * 0.10), 40);
    _drawCloud(canvas, Offset(((cloudScroll * 14) + 180) % (size.width + 120) - 60, size.height * 0.18), 32);

    // 4. Distant Green Hills & Mountains
    final mountainPaint = Paint()..color = const Color(0xFF0369A1);
    final mountainPath = Path();
    mountainPath.moveTo(0, size.height * 0.44);
    for (double x = 0; x <= size.width; x += 60) {
      final y = size.height * 0.38 + math.sin((x + sceneryScroll * 0.2) * 0.02) * 22;
      mountainPath.lineTo(x, y);
    }
    mountainPath.lineTo(size.width, size.height * 0.52);
    mountainPath.lineTo(0, size.height * 0.52);
    mountainPath.close();
    canvas.drawPath(mountainPath, mountainPaint);

    // 5. Rolling Green Meadow Hills
    final hillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.46, size.width, size.height * 0.22));

    final hillPath = Path();
    hillPath.moveTo(0, size.height * 0.52);
    for (double x = 0; x <= size.width; x += 30) {
      final y = size.height * 0.50 + math.sin((x + sceneryScroll * 0.6) * 0.015) * 14;
      hillPath.lineTo(x, y);
    }
    hillPath.lineTo(size.width, size.height * 0.62);
    hillPath.lineTo(0, size.height * 0.62);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // 6. Asphalt Road
    final roadTopY = size.height * 0.62;
    final roadBottomY = size.height * 0.86;
    final roadHeight = roadBottomY - roadTopY;

    // Grass border above road
    final grassBorderPaint = Paint()..color = const Color(0xFF047857);
    canvas.drawRect(Rect.fromLTWH(0, roadTopY - 6, size.width, 8), grassBorderPaint);

    // Asphalt surface
    final roadPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, roadTopY, size.width, roadHeight), roadPaint);

    // Bottom curb
    final curbPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, roadBottomY, size.width, size.height * 0.14), curbPaint);

    // Dashed Highway Lane Markers (Scrolls with distance)
    final laneMarkerPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3.5;
    final dashOffset = (distanceTraveled * 1.5) % 40;
    for (double x = -dashOffset; x < size.width; x += 40) {
      canvas.drawLine(
        Offset(x, roadTopY + roadHeight * 0.5),
        Offset(x + 22, roadTopY + roadHeight * 0.5),
        laneMarkerPaint,
      );
    }

    // 7. Roadside Trees
    final treeOffset1 = ((sceneryScroll * 0.9) % (size.width + 120)) - 60;
    _drawTree(canvas, Offset(treeOffset1, roadTopY - 2), 24);

    // 8. Vocabulary Checkpoint Landmark Houses (Prominent Buildings beside road)
    _drawVocabularyHouses(canvas, size, roadTopY);

    // 9. Player Sports Car 🏎️
    _drawPlayerCar(canvas, size);

    // 10. Road Particles & Smoke
    for (final p in particles) {
      final pPaint = Paint()..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, pPaint);
    }
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

  /// 🏠 Draws the Vocabulary Landmark Building / House beside the road
  void _drawVocabularyHouses(Canvas canvas, Size size, double roadTop) {
    for (int i = 0; i < checkpoints.length; i++) {
      final targetDistance = (i + 1) * kDistancePerCheckpoint;
      final distToCar = targetDistance - distanceTraveled;
      final houseX = (size.width * 0.24) + distToCar + 40;

      // Only draw if within screen view
      if (houseX < -180 || houseX > size.width + 180) continue;

      final item = checkpoints[i];
      final word = item['word']?.toString() ?? '';
      final ml = item['meaningMl']?.toString() ?? '';
      final emoji = item['emoji']?.toString() ?? '🏠';

      final houseW = 120.0;
      final houseH = 80.0;
      final houseY = roadTop - houseH;

      // 1. House Shadow
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.3);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(houseX, roadTop + 2), width: houseW + 20, height: 16),
        shadowPaint,
      );

      // 2. House Walls (Cozy styled building)
      final wallPaint = Paint()..color = const Color(0xFFF8FAFC);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(houseX - houseW / 2, houseY + 22, houseW, houseH - 22), const Radius.circular(8)),
        wallPaint,
      );

      // 3. House Door & Windows
      final doorPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(houseX - 12, roadTop - 28, 24, 28), const Radius.circular(4)),
        doorPaint,
      );

      final windowPaint = Paint()..color = const Color(0xFF38BDF8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(houseX - 44, houseY + 36, 18, 18), const Radius.circular(3)),
        windowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(houseX + 26, houseY + 36, 18, 18), const Radius.circular(3)),
        windowPaint,
      );

      // 4. Roof (Terracotta / Emerald)
      final roofPaint = Paint()..color = const Color(0xFFDC2626);
      final roofPath = Path();
      roofPath.moveTo(houseX - houseW / 2 - 10, houseY + 22);
      roofPath.lineTo(houseX, houseY);
      roofPath.lineTo(houseX + houseW / 2 + 10, houseY + 22);
      roofPath.close();
      canvas.drawPath(roofPath, roofPaint);

      // 5. Large Vocabulary Signboard on top of House! (User Audio Directive!)
      final signboardW = 136.0;
      final signboardH = 36.0;
      final signboardY = houseY - signboardH - 4;

      final signBgPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(houseX - signboardW / 2, signboardY, signboardW, signboardH), const Radius.circular(8)),
        signBgPaint,
      );

      final signBorderPaint = Paint()
        ..color = (i == currentCheckpoint && isAtCheckpoint)
            ? const Color(0xFFFFD700)
            : const Color(0xFF38BDF8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(houseX - signboardW / 2, signboardY, signboardW, signboardH), const Radius.circular(8)),
        signBorderPaint,
      );

      // Draw Word & Emoji Text on Signboard
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
      textPainter.layout(maxWidth: signboardW);
      textPainter.paint(canvas, Offset(houseX - textPainter.width / 2, signboardY + 4));
    }
  }

  void _drawPlayerCar(Canvas canvas, Size size) {
    final carX = size.width * 0.24;
    final carY = size.height * carLaneY;

    // Car Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(carX, carY + 16), width: 78, height: 16),
      shadowPaint,
    );

    // Car Body (Sporty Red Racer)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(carX - 36, carY - 14, 72, 28));

    final carPath = Path();
    carPath.moveTo(carX - 34, carY + 8);
    carPath.lineTo(carX - 34, carY - 2);
    carPath.lineTo(carX - 18, carY - 14); // Windshield
    carPath.lineTo(carX + 16, carY - 14); // Roof
    carPath.lineTo(carX + 34, carY - 2); // Hood
    carPath.lineTo(carX + 36, carY + 8);
    carPath.close();
    canvas.drawPath(carPath, bodyPaint);

    // Windshield Glass
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

    // Wheels (Spinning with speed)
    _drawWheel(canvas, Offset(carX - 22, carY + 10));
    _drawWheel(canvas, Offset(carX + 22, carY + 10));
  }

  void _drawWheel(Canvas canvas, Offset center) {
    final tirePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, 9, tirePaint);

    final rimPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawCircle(center, 5, rimPaint);

    // Animated rim spokes
    final spokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2;
    final angle = (distanceTraveled * 0.15) % (math.pi * 2);
    canvas.drawLine(
      Offset(center.dx + math.cos(angle) * 4, center.dy + math.sin(angle) * 4),
      Offset(center.dx - math.cos(angle) * 4, center.dy - math.sin(angle) * 4),
      spokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OpenWorldDrivePainter oldDelegate) => true;
}
