import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_cafe_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPEECH RECOGNITION ADAPTER (Wraps speech_to_text package)
// Thin adapter — swap this class for any other STT backend without touching game code.
// ─────────────────────────────────────────────────────────────────────────────

class SttSpeechRecognitionService implements SpeechRecognitionService {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _initialized = false;
  bool _listening = false;
  String _lastWords = '';
  final _completer = <Completer<String>>[];

  @override
  bool get isAvailable => _initialized;

  @override
  bool get isListening => _listening;

  Future<bool> initialize() async {
    try {
      _initialized = await _stt.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _listening = false;
          }
        },
        onError: (e) {
          _listening = false;
          if (_completer.isNotEmpty) {
            final c = _completer.removeAt(0);
            if (!c.isCompleted) c.complete(_lastWords);
          }
        },
      );
    } catch (_) {
      _initialized = false;
    }
    return _initialized;
  }

  @override
  Future<void> startListening() async {
    if (!_initialized || _listening) return;
    _lastWords = '';
    _listening = true;
    await _stt.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) {
          _listening = false;
          if (_completer.isNotEmpty) {
            final c = _completer.removeAt(0);
            if (!c.isCompleted) c.complete(_lastWords);
          }
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  @override
  Future<String> stopListening() async {
    if (!_listening) return _lastWords;
    final c = Completer<String>();
    _completer.add(c);
    await _stt.stop();
    _listening = false;
    return c.future.timeout(const Duration(seconds: 4),
        onTimeout: () => _lastWords);
  }

  @override
  Future<void> cancelListening() async {
    await _stt.cancel();
    _listening = false;
    for (final c in _completer) {
      if (!c.isCompleted) c.complete('');
    }
    _completer.clear();
  }

  @override
  void dispose() {
    _stt.cancel();
    for (final c in _completer) {
      if (!c.isCompleted) c.complete('');
    }
    _completer.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLAME GAME – 2D Café World
// ─────────────────────────────────────────────────────────────────────────────

class VoiceCafeFlameGame extends FlameGame with TapCallbacks {
  final VoiceCafeLevelData levelData;
  final VoidCallback onInteract;

  static const double worldWidth = 1600;

  double _playerX = 60;
  double _targetX = 60;
  bool _facingRight = true;
  bool _isMoving = false;
  double _cameraX = 0;

  final List<double> _npcPositions = [420, 900, 1400];

  // Background NPC wander
  final List<double> _bgNpcX = [200, 1100, 1350];
  final List<double> _bgNpcDir = [1, -1, 1];

  VoiceCafeFlameGame({required this.levelData, required this.onInteract});

  void movePlayerToChallenge(int index) {
    if (index < _npcPositions.length) {
      _targetX = (_npcPositions[index] - 80).clamp(40, worldWidth - 40);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePlayer(dt);
    _updateBgNpcs(dt);
    _updateCamera();
  }

  void _updatePlayer(double dt) {
    final dx = _targetX - _playerX;
    if (dx.abs() > 4) {
      _facingRight = dx > 0;
      _isMoving = true;
      _playerX += dx.sign * 170 * dt;
    } else {
      _playerX = _targetX;
      _isMoving = false;
    }
  }

  void _updateBgNpcs(double dt) {
    for (int i = 0; i < _bgNpcX.length; i++) {
      _bgNpcX[i] += _bgNpcDir[i] * 24 * dt;
      if (_bgNpcX[i] > worldWidth - 60 || _bgNpcX[i] < 60) {
        _bgNpcDir[i] *= -1;
      }
    }
  }

  void _updateCamera() {
    final sw = size.x;
    _cameraX = (_playerX - sw / 2).clamp(0, worldWidth - sw);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final wx = event.localPosition.x + _cameraX;
    _targetX = wx.clamp(40, worldWidth - 40);
    for (final npc in _npcPositions) {
      if ((wx - npc).abs() < 56) {
        onInteract();
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final vp = Rect.fromLTWH(_cameraX, 0, size.x, size.y);
    _drawCafe(canvas, vp);
    _drawBgNpcs(canvas, vp);
    _drawNpcs(canvas, vp);
    _drawPlayer(canvas, vp);
    _drawMiniMap(canvas);
  }

  void _drawCafe(Canvas canvas, Rect vp) {
    // Warm café background
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF1A0E05), const Color(0xFF0D0802)],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bg);

    for (final area in levelData.areas) {
      final sl = area.startX - vp.left;
      final w = area.endX - area.startX;
      if (sl + w < 0 || sl > size.x) continue;

      // Floor
      canvas.drawRect(
        Rect.fromLTWH(sl, size.y - 80, w - 2, 80),
        Paint()..color = area.primaryColor,
      );
      // Zone border
      canvas.drawRect(
        Rect.fromLTWH(sl, 0, w - 2, size.y),
        Paint()
          ..color = area.accentColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: '${area.icon} ${area.name}',
          style: TextStyle(
              color: area.accentColor.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sl + 8, 10));

      // Furniture
      _drawCafeFurniture(canvas, sl, w, area);
    }

    // Menu board on wall
    final mbX = 700 - vp.left;
    if (mbX > -200 && mbX < size.x + 200) {
      final mbPaint = Paint()..color = const Color(0xFF1A2B3B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(mbX, 30, 200, 100), const Radius.circular(6)),
        mbPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(mbX, 30, 200, 100), const Radius.circular(6)),
        Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      final menuTp = TextPainter(
        text: const TextSpan(
          text: '☕ MENU\nCoffee ₹120\nSandwich ₹180\nJuice ₹80',
          style: TextStyle(
              color: Color(0xFF93C5FD), fontSize: 11, height: 1.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      menuTp.paint(canvas, Offset(mbX + 10, 38));
    }

    // Floor line
    canvas.drawLine(
      Offset(0, size.y - 80),
      Offset(size.x, size.y - 80),
      Paint()
        ..color = Colors.white12
        ..strokeWidth = 1,
    );
  }

  void _drawCafeFurniture(
      Canvas canvas, double left, double width, CafeArea area) {
    final p = Paint()..color = area.accentColor.withValues(alpha: 0.12);
    final ps = Paint()
      ..color = area.accentColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Counter
    if (area.id == 'counter') {
      canvas.drawRect(Rect.fromLTWH(left + 20, size.y - 145, width - 40, 55), p);
      canvas.drawRect(Rect.fromLTWH(left + 20, size.y - 145, width - 40, 55), ps);
    } else if (area.id == 'table') {
      // Round tables
      for (double tx in [left + 60, left + 160, left + 260]) {
        canvas.drawCircle(Offset(tx, size.y - 115), 28, p);
        canvas.drawCircle(Offset(tx, size.y - 115), 28, ps);
      }
    } else {
      // Generic desk
      canvas.drawRect(Rect.fromLTWH(left + 30, size.y - 145, 60, 55), p);
      canvas.drawRect(Rect.fromLTWH(left + 30, size.y - 145, 60, 55), ps);
    }
  }

  void _drawPlayer(Canvas canvas, Rect vp) {
    final sx = _playerX - vp.left;
    final sy = size.y - 80;
    if (!_facingRight) {
      canvas.save();
      canvas.scale(-1, 1);
      canvas.translate(-2 * sx, 0);
    }

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 12, sy - 48, 24, 40), const Radius.circular(6)),
      Paint()..color = const Color(0xFF3B82F6),
    );
    // Head
    canvas.drawCircle(Offset(sx, sy - 60), 13,
        Paint()..color = const Color(0xFFFBBF24));
    // Shirt collar detail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 4, sy - 48, 8, 10), const Radius.circular(2)),
      Paint()..color = const Color(0xFF1E40AF),
    );
    // Legs
    final legP = Paint()..color = const Color(0xFF1E3A5F);
    if (_isMoving) {
      final t = DateTime.now().millisecondsSinceEpoch / 200.0;
      canvas.drawRect(
          Rect.fromLTWH(sx - 10, sy - 8, 8, 8 + 3 * math.sin(t)), legP);
      canvas.drawRect(
          Rect.fromLTWH(sx + 2, sy - 8, 8, 8 + 3 * math.cos(t)), legP);
    } else {
      canvas.drawRect(Rect.fromLTWH(sx - 10, sy - 8, 8, 8), legP);
      canvas.drawRect(Rect.fromLTWH(sx + 2, sy - 8, 8, 8), legP);
    }

    if (!_facingRight) canvas.restore();
  }

  void _drawNpcs(Canvas canvas, Rect vp) {
    final npcs = levelData.npcs;
    for (int i = 0; i < _npcPositions.length && i < npcs.length + 1; i++) {
      final wx = _npcPositions[i];
      final sx = wx - vp.left;
      if (sx < -60 || sx > size.x + 60) continue;

      final npc = i < npcs.length ? npcs[i < 1 ? 0 : 1] : npcs.last;
      final sy = size.y - 80;

      // NPC body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(sx - 12, sy - 52, 24, 44), const Radius.circular(6)),
        Paint()..color = npc.accentColor.withValues(alpha: 0.6),
      );
      // NPC head
      canvas.drawCircle(Offset(sx, sy - 64), 13,
          Paint()..color = const Color(0xFFFDE68A));

      // Pulse ring (interaction indicator)
      final pulse =
          0.7 + 0.3 * math.sin(DateTime.now().millisecondsSinceEpoch / 600.0);
      canvas.drawCircle(
        Offset(sx, sy - 64),
        16 * pulse,
        Paint()
          ..color = npc.accentColor.withValues(alpha: 0.3 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // NPC label
      final tp = TextPainter(
        text: TextSpan(
          text: '${npc.icon} ${npc.name}',
          style: TextStyle(color: npc.accentColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - tp.width / 2, sy - 90));
    }
  }

  void _drawBgNpcs(Canvas canvas, Rect vp) {
    final colors = [
        const Color(0xFF6B7280),
        const Color(0xFF4B5563),
        const Color(0xFF374151)
    ];
    for (int i = 0; i < _bgNpcX.length; i++) {
      final sx = _bgNpcX[i] - vp.left;
      if (sx < -40 || sx > size.x + 40) continue;
      final sy = size.y - 80;
      canvas.drawCircle(Offset(sx, sy - 40), 9,
          Paint()..color = colors[i % colors.length]);
      canvas.drawRect(Rect.fromLTWH(sx - 6, sy - 32, 12, 24),
          Paint()..color = colors[i % colors.length]);
    }
  }

  void _drawMiniMap(Canvas canvas) {
    const mmW = 90.0, mmH = 8.0, mmX = 10.0, mmY = 22.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(mmX - 2, mmY - 2, mmW + 4, mmH + 4),
          const Radius.circular(4)),
      Paint()..color = Colors.black54,
    );
    for (final a in levelData.areas) {
      final x = mmX + (a.startX / worldWidth) * mmW;
      final w = ((a.endX - a.startX) / worldWidth) * mmW;
      canvas.drawRect(Rect.fromLTWH(x, mmY, w - 1, mmH),
          Paint()..color = a.accentColor.withValues(alpha: 0.6));
    }
    final px = mmX + (_playerX / worldWidth) * mmW;
    canvas.drawCircle(Offset(px, mmY + mmH / 2), 3,
        Paint()..color = const Color(0xFFFFD700));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUTTER WIDGET – Main Voice Café Game Page
// ─────────────────────────────────────────────────────────────────────────────

class VoiceCafeGamePage extends StatefulWidget {
  final VoiceCafeLevelData levelData;

  const VoiceCafeGamePage({super.key, required this.levelData});

  @override
  State<VoiceCafeGamePage> createState() => _VoiceCafeGamePageState();
}

class _VoiceCafeGamePageState extends State<VoiceCafeGamePage>
    with TickerProviderStateMixin {
  late final VoiceCafeFlameGame _flameGame;
  late final FlutterTts _flutterTts;
  late final SttSpeechRecognitionService _sttService;

  // Progress
  int _currentChallengeIndex = 0;
  final VoiceCafeScore _score = VoiceCafeScore();
  bool _audioMuted = false;
  bool _showExample = false;

  // Mic state
  MicState _micState = MicState.idle;
  String _recognizedText = '';
  SpeakingEvaluationResult? _lastResult;

  // Permission
  bool _micPermissionGranted = false;
  bool _micPermissionRequested = false;
  bool _sttAvailable = false;

  // Feedback banner
  bool _showFeedbackBanner = false;
  Timer? _feedbackTimer;

  // Waveform animation
  late AnimationController _waveController;
  final List<double> _waveHeights = List.generate(12, (i) => 0.3);

  // TTS speaking state
  bool _npcSpeaking = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..addListener(_updateWave)..repeat();
    _initTts();
    _initFlameGame();
    _initStt();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakNpc());
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.46);
    _flutterTts.setPitch(1.0);
    _flutterTts.setStartHandler(() => setState(() => _npcSpeaking = true));
    _flutterTts.setCompletionHandler(
        () => setState(() => _npcSpeaking = false));
  }

  void _initFlameGame() {
    _flameGame = VoiceCafeFlameGame(
      levelData: widget.levelData,
      onInteract: () {},
    );
  }

  Future<void> _initStt() async {
    _sttService = SttSpeechRecognitionService();
    final ok = await _sttService.initialize();
    if (mounted) setState(() => _sttAvailable = ok);
  }

  Future<void> _speakNpc() async {
    if (_audioMuted) return;
    final ch = _currentChallenge;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(ch.npcDialogue);
    } catch (_) {}
  }

  SpeakingChallenge get _currentChallenge =>
      widget.levelData.challenges[_currentChallengeIndex];

  void _updateWave() {
    if (_micState != MicState.listening) return;
    final r = math.Random();
    setState(() {
      for (int i = 0; i < _waveHeights.length; i++) {
        _waveHeights[i] = 0.2 + r.nextDouble() * 0.8;
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _feedbackTimer?.cancel();
    _flutterTts.stop();
    _sttService.dispose();
    super.dispose();
  }

  // ── Mic permission flow ─────────────────────────────────────────────────

  Future<void> _requestMicPermission() async {
    setState(() => _micPermissionRequested = true);
    // speech_to_text handles permission internally during initialize()
    if (_sttAvailable) {
      setState(() => _micPermissionGranted = true);
    } else {
      final ok = await _sttService.initialize();
      setState(() {
        _sttAvailable = ok;
        _micPermissionGranted = ok;
      });
    }
  }

  // ── Speech flow ─────────────────────────────────────────────────────────

  Future<void> _startSpeaking() async {
    if (!_micPermissionGranted) {
      await _requestMicPermission();
      if (!_micPermissionGranted) return;
    }

    HapticFeedback.mediumImpact();
    // Lower TTS volume while recording
    await _flutterTts.stop();
    setState(() {
      _micState = MicState.listening;
      _recognizedText = '';
      _lastResult = null;
      _showExample = false;
    });

    await _sttService.startListening();

    // Auto-stop after time limit
    Future.delayed(
        Duration(seconds: _currentChallenge.timeLimitSeconds + 1), () {
      if (mounted && _micState == MicState.listening) {
        _stopSpeaking();
      }
    });
  }

  Future<void> _stopSpeaking() async {
    if (_micState != MicState.listening) return;
    setState(() => _micState = MicState.processing);
    HapticFeedback.lightImpact();

    final text = await _sttService.stopListening();
    if (!mounted) return;

    if (text.trim().isEmpty) {
      setState(() {
        _micState = MicState.idle;
        _recognizedText = '';
      });
      return;
    }

    setState(() => _recognizedText = text);

    // Evaluate
    final result = SpeakingEvaluationService.evaluate(
      recognizedText: text,
      challenge: _currentChallenge,
    );

    setState(() {
      _lastResult = result;
      _micState = MicState.done;
      _showFeedbackBanner = true;
    });

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showFeedbackBanner = false);
    });

    if (result.result == SpeechResult.excellent ||
        result.result == SpeechResult.good) {
      HapticFeedback.mediumImpact();
      _score.addResult(result);
      _score.totalXp += _currentChallenge.xpReward;

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        _advanceChallenge();
      });
    } else {
      _score.retriesUsed++;
    }
  }

  void _cancelSpeaking() {
    _sttService.cancelListening();
    setState(() {
      _micState = MicState.idle;
      _recognizedText = '';
    });
  }

  void _retryChallenge() {
    setState(() {
      _micState = MicState.idle;
      _lastResult = null;
      _recognizedText = '';
      _showExample = false;
    });
    _speakNpc();
  }

  void _advanceChallenge() {
    if (_currentChallengeIndex < widget.levelData.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _micState = MicState.idle;
        _lastResult = null;
        _recognizedText = '';
        _showExample = false;
      });
      _flameGame.movePlayerToChallenge(_currentChallengeIndex);
      Future.delayed(const Duration(milliseconds: 600), _speakNpc);
    } else {
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    _flutterTts.speak('Conversation complete! Excellent work!');
    final s = _score;
    final stars = s.overall >= 90 ? 3 : (s.overall >= 75 ? 2 : 1);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0E1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Color(0xFFF59E0B), blurRadius: 32, spreadRadius: 2),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('🎤', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 6),
            Text('CONVERSATION COMPLETE!',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('You completed the café mission using English!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: const Color(0xFF10B981), fontSize: 12)),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3,
                  (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                          color: i < stars ? const Color(0xFFFFD700) : Colors.white24,
                          size: 34,
                        ),
                      )),
            ),
            const SizedBox(height: 14),

            // Score Grid
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1207),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _metricTile('Pronunciation', '${s.avgPronunciation}%', '🗣️'),
                  _metricTile('Grammar', '${s.avgGrammar}%', '📝'),
                  _metricTile('Vocabulary', '${(s.avgCommunication + 5).clamp(0, 100)}%', '📖'),
                  _metricTile('Communication', '${s.avgCommunication}%', '💬'),
                ]),
                const Divider(color: Colors.white12, height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _metricTile('Fluency', '${s.avgFluency}%', '⚡'),
                  _metricTile('Confidence', '${s.confidence}%', '💪'),
                  _metricTile('XP Earned', '+${s.totalXp}', '🏆'),
                  _metricTile('Attempts', '${s.challengesAttempted}', '🎯'),
                ]),
              ]),
            ),
            const SizedBox(height: 12),

            // Speaking Score bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎤', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('Overall Speaking: ${s.overall}%',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFFDE68A),
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                  ]),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('CONTINUE TO DAY 12 🚀',
                    style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, String icon) => Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0802),
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            _buildTopHUD(),
            _buildFlameView(),
            _buildChallengePanel(),
          ]),
          if (_showFeedbackBanner && _lastResult != null)
            _buildFeedbackBanner(),
        ]),
      ),
    );
  }

  Widget _buildTopHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF120A02),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white54, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.levelData.title,
                style: GoogleFonts.outfit(
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5)),
            Text(widget.levelData.missionObjective,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
          ]),
        ),
        // Progress
        Row(children: List.generate(
            widget.levelData.challenges.length,
            (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: i == _currentChallengeIndex ? 14 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < _currentChallengeIndex
                        ? const Color(0xFF10B981)
                        : i == _currentChallengeIndex
                            ? const Color(0xFFF59E0B)
                            : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ))),
        const SizedBox(width: 10),
        // XP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('⚡${_score.totalXp} XP',
              style: GoogleFonts.outfit(
                  color: const Color(0xFFFDE68A),
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() => _audioMuted = !_audioMuted);
            if (!_audioMuted) _speakNpc();
          },
          child: Icon(
            _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: Colors.white38,
            size: 20,
          ),
        ),
      ]),
    );
  }

  Widget _buildFlameView() => SizedBox(
        height: 160,
        child: GameWidget(game: _flameGame),
      );

  Widget _buildChallengePanel() {
    final ch = _currentChallenge;
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF120A02),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Challenge type badge + replay NPC
            Row(children: [
              _typeBadge(ch.type),
              const Spacer(),
              GestureDetector(
                onTap: _speakNpc,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                  ),
                  child: Row(children: [
                    Icon(
                      _npcSpeaking
                          ? Icons.graphic_eq_rounded
                          : Icons.replay_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text('Replay NPC',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFF59E0B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 10),

            // NPC dialogue bubble
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1207),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    width: 1.4),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('☕', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        _currentChallengeIndex < 1 ? 'Alex (Barista)' : 'Alex / Priya',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('"${ch.npcDialogue}"',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4)),
                  ]),
            ),
            const SizedBox(height: 10),

            // Mission instruction
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Text('🎯 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(ch.missionInstruction,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // Example toggle
            if (_showExample)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.35)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REFERENCE SENTENCE',
                          style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text('"${ch.referenceResponse}"',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF93C5FD),
                              fontSize: 14,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _speak(ch.referenceResponse),
                        child: Row(children: [
                          const Icon(Icons.volume_up_rounded,
                              color: Color(0xFF3B82F6), size: 14),
                          const SizedBox(width: 4),
                          Text('Listen',
                              style: GoogleFonts.outfit(
                                  color: const Color(0xFF3B82F6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ]),
              ),

            // Recognized text display
            if (_recognizedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOU SAID',
                          style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('"$_recognizedText"',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13)),
                      if (_lastResult != null &&
                          _lastResult!.matchedKeywords.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(spacing: 4, children: [
                          ..._lastResult!.matchedKeywords.map(
                            (kw) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('✓ $kw',
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF10B981),
                                      fontSize: 10)),
                            ),
                          ),
                          ..._lastResult!.missingKeywords.map(
                            (kw) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('✗ $kw',
                                  style: GoogleFonts.inter(
                                      color: Colors.red.shade300,
                                      fontSize: 10)),
                            ),
                          ),
                        ]),
                      ],
                    ]),
              ),

            // Waveform or mic button
            _buildMicSection(ch),

            // After failed attempt: retry + see example
            if (_micState == MicState.done &&
                _lastResult != null &&
                (_lastResult!.result == SpeechResult.retry ||
                    _lastResult!.result == SpeechResult.needsPractice)) ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retryChallenge,
                    icon: const Icon(Icons.replay_rounded,
                        color: Color(0xFFF59E0B), size: 16),
                    label: Text('TRY AGAIN',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showExample = !_showExample),
                    icon: const Icon(Icons.subtitles_rounded,
                        color: Color(0xFF3B82F6), size: 16),
                    label: Text('SEE EXAMPLE',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              // Hint
              if (ch.hint.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded,
                            color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(ch.hint,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFFDE68A),
                                  fontSize: 12,
                                  height: 1.4)),
                        ),
                      ]),
                ),
            ],

            // Skip to text mode (accessibility)
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _advanceChallenge(),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.keyboard_rounded,
                    color: Colors.white24, size: 14),
                const SizedBox(width: 4),
                Text('Skip (accessibility mode)',
                    style: GoogleFonts.inter(
                        color: Colors.white24, fontSize: 11)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildMicSection(SpeakingChallenge ch) {
    switch (_micState) {
      case MicState.listening:
        return Column(children: [
          // Waveform
          SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _waveHeights
                  .map((h) => AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 5,
                        height: h * 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text('Listening…',
              style: GoogleFonts.outfit(
                  color: const Color(0xFFF59E0B), fontSize: 13)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: _stopSpeaking,
              icon: const Icon(Icons.stop_rounded, size: 18),
              label: Text('STOP',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _cancelSpeaking,
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
            ),
          ]),
        ]);

      case MicState.processing:
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Color(0xFFF59E0B)),
              const SizedBox(height: 10),
              Text('Processing…',
                  style:
                      GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
            ]);

      case MicState.done:
        if (_lastResult != null &&
            (_lastResult!.result == SpeechResult.excellent ||
                _lastResult!.result == SpeechResult.good)) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 22),
              const SizedBox(width: 8),
              Text(_lastResult!.feedback,
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ]),
          );
        }
        return const SizedBox.shrink();

      case MicState.idle:
        return Column(children: [
          const SizedBox(height: 6),
          Center(
            child: GestureDetector(
              onTap: _micPermissionGranted || _sttAvailable
                  ? _startSpeaking
                  : _requestMicPermission,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xFFF59E0B), blurRadius: 20, spreadRadius: 3),
                  ],
                ),
                child: const Icon(Icons.mic_rounded,
                    color: Colors.black, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            !_micPermissionRequested
                ? '🎤 TAP TO SPEAK'
                : !_sttAvailable
                    ? '⚠️ Microphone unavailable'
                    : '🎤 TAP TO SPEAK',
            style: GoogleFonts.outfit(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
          if (!_micPermissionRequested)
            Text('Tap the microphone to begin',
                style:
                    GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
        ]);
    }
  }

  Widget _buildFeedbackBanner() {
    final r = _lastResult;
    if (r == null) return const SizedBox.shrink();
    final color = r.result == SpeechResult.excellent
        ? const Color(0xFF10B981)
        : r.result == SpeechResult.good
            ? const Color(0xFF3B82F6)
            : r.result == SpeechResult.needsPractice
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444);
    return Positioned(
      top: 76,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: _showFeedbackBanner ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: color, blurRadius: 16)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              child: Text(r.feedback,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
            const SizedBox(width: 8),
            Text('${r.overallScore}%',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
          ]),
        ),
      ),
    );
  }

  Widget _typeBadge(SpeakingChallengeType type) {
    final config = {
      SpeakingChallengeType.greeting: ('👋 Greeting', const Color(0xFF10B981)),
      SpeakingChallengeType.placeOrder: ('🍽 Order', const Color(0xFFF59E0B)),
      SpeakingChallengeType.yesNoResponse: ('✅ Yes/No', const Color(0xFF3B82F6)),
      SpeakingChallengeType.askQuestion: ('❓ Ask', const Color(0xFF8B5CF6)),
      SpeakingChallengeType.clarifyRequest: ('🔄 Clarify', const Color(0xFF0EA5E9)),
      SpeakingChallengeType.handleMistake: ('⚠️ Correct', const Color(0xFFEF4444)),
      SpeakingChallengeType.askPrice: ('💰 Price', const Color(0xFFEC4899)),
      SpeakingChallengeType.freeSpeaking: ('🎤 Free Talk', const Color(0xFF14B8A6)),
      SpeakingChallengeType.multiTurn: ('🔁 Multi-Turn', const Color(0xFFFFD700)),
    };
    final c = config[type] ?? ('Speaking', Colors.white38);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.$2.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.$2.withValues(alpha: 0.4)),
      ),
      child: Text(c.$1,
          style: GoogleFonts.outfit(
              color: c.$2, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }
}
