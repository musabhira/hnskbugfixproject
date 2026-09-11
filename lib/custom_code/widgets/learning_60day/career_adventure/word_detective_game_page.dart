import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_detective_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLAME GAME – 2D Office World
// ─────────────────────────────────────────────────────────────────────────────

class WordDetectiveFlameGame extends FlameGame with TapCallbacks {
  final WordDetectiveLevelData levelData;
  final VoidCallback onObjectInteract;

  // World dimensions
  static const double worldWidth = 2040;
  static const double worldHeight = 340;

  // Player
  double _playerX = 80;
  double _targetX = 80;
  bool _facingRight = true;
  bool _isMoving = false;

  // Camera offset
  double _cameraX = 0;

  // Clue markers (world-space X, areaId)
  final List<_ClueMarker> _clueMarkers = [];

  // Discovered areas
  final Set<String> _enteredAreaIds = {};

  // Current area callback
  final void Function(String areaId)? onAreaEntered;

  WordDetectiveFlameGame({
    required this.levelData,
    required this.onObjectInteract,
    this.onAreaEntered,
  });

  Future<void> _initMarkers() async {
    // Define clue marker positions per area
    _clueMarkers.addAll([
      _ClueMarker('reception', 450),
      _ClueMarker('reception', 570),
      _ClueMarker('corridor', 780),
      _ClueMarker('meeting_room_3', 1100),
      _ClueMarker('meeting_room_3', 1250),
      _ClueMarker('corridor', 720),
      _ClueMarker('meeting_room_3', 1180),
      _ClueMarker('coffee_area', 1520),
      _ClueMarker('corridor', 840),
      _ClueMarker('storage_room', 1800),
    ]);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initMarkers();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePlayerMovement(dt);
    _updateCamera();
    _checkAreaEntry();
  }

  void _updatePlayerMovement(double dt) {
    final dx = _targetX - _playerX;
    if (dx.abs() > 4) {
      _isMoving = true;
      _facingRight = dx > 0;
      _playerX += dx.sign * 180 * dt;
    } else {
      _playerX = _targetX;
      _isMoving = false;
    }
  }

  void _updateCamera() {
    final screenW = size.x;
    _cameraX = (_playerX - screenW / 2).clamp(0, worldWidth - screenW);
  }

  void _checkAreaEntry() {
    for (final area in levelData.areas) {
      if (_playerX >= area.startX && _playerX < area.endX) {
        if (!_enteredAreaIds.contains(area.id)) {
          _enteredAreaIds.add(area.id);
          onAreaEntered?.call(area.id);
        }
      }
    }
  }

  void movePlayerToChallenge(int challengeIndex) {
    if (challengeIndex < _clueMarkers.length) {
      _targetX = _clueMarkers[challengeIndex].worldX.clamp(60, worldWidth - 60);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final worldTapX = event.localPosition.x + _cameraX;
    _targetX = worldTapX.clamp(60, worldWidth - 60);

    // Check if near a clue marker
    for (final marker in _clueMarkers) {
      if ((worldTapX - marker.worldX).abs() < 50) {
        onObjectInteract();
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final viewport = Rect.fromLTWH(_cameraX, 0, size.x, size.y);
    _drawWorld(canvas, viewport);
    _drawPlayer(canvas, viewport);
    _drawClueMarkers(canvas, viewport);
    _drawMiniMap(canvas);
  }

  void _drawWorld(Canvas canvas, Rect viewport) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0A0F1E), const Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    // Draw areas
    for (final area in levelData.areas) {
      final screenLeft = area.startX - viewport.left;
      final width = area.endX - area.startX;
      if (screenLeft + width < 0 || screenLeft > size.x) continue;

      // Area floor
      final floorPaint = Paint()..color = area.primaryColor;
      canvas.drawRect(
        Rect.fromLTWH(screenLeft, size.y - 90, width - 2, 90),
        floorPaint,
      );

      // Area border
      final borderPaint = Paint()
        ..color = area.accentColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRect(
        Rect.fromLTWH(screenLeft, 0, width - 2, size.y),
        borderPaint,
      );

      // Area label
      final tp = TextPainter(
        text: TextSpan(
          text: '${area.icon} ${area.name}',
          style: TextStyle(
            color: area.accentColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(screenLeft + 10, 12));

      // Draw office furniture silhouettes
      _drawFurniture(canvas, screenLeft, area, width);
    }

    // Floor line
    final floorLinePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.y - 90), Offset(size.x, size.y - 90), floorLinePaint);
  }

  void _drawFurniture(Canvas canvas, double left, OfficeArea area, double width) {
    final paint = Paint()..color = area.accentColor.withValues(alpha: 0.15);
    final paint2 = Paint()
      ..color = area.accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // desk
    canvas.drawRect(Rect.fromLTWH(left + 40, size.y - 150, 70, 60), paint);
    canvas.drawRect(Rect.fromLTWH(left + 40, size.y - 150, 70, 60), paint2);

    if (width > 250) {
      // second desk
      canvas.drawRect(
          Rect.fromLTWH(left + width - 120, size.y - 150, 70, 60), paint);
      canvas.drawRect(
          Rect.fromLTWH(left + width - 120, size.y - 150, 70, 60), paint2);
    }
  }

  void _drawPlayer(Canvas canvas, Rect viewport) {
    final sx = _playerX - viewport.left;
    final sy = size.y - 90;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF6366F1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx - 14, sy - 52, 28, 44),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(sx, sy - 64), 14, headPaint);

    // Hat (detective)
    final hatPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(sx - 16, sy - 86, 32, 18), hatPaint);
    canvas.drawRect(Rect.fromLTWH(sx - 20, sy - 70, 40, 6), hatPaint);

    // Legs
    final legPaint = Paint()..color = const Color(0xFF374151);
    if (_isMoving) {
      final t = DateTime.now().millisecondsSinceEpoch / 200.0;
      canvas.drawRect(
          Rect.fromLTWH(sx - 10, sy - 10, 8, 10 + 4 * math.sin(t)), legPaint);
      canvas.drawRect(
          Rect.fromLTWH(sx + 2, sy - 10, 8, 10 + 4 * math.cos(t)), legPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(sx - 10, sy - 10, 8, 10), legPaint);
      canvas.drawRect(Rect.fromLTWH(sx + 2, sy - 10, 8, 10), legPaint);
    }

    // Facing direction indicator
    if (!_facingRight) {
      canvas.save();
      canvas.scale(-1, 1);
      canvas.translate(-2 * sx, 0);
    }
    final magnifyPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(sx + 16, sy - 42), 8, magnifyPaint);
    canvas.drawLine(Offset(sx + 22, sy - 36), Offset(sx + 27, sy - 31), magnifyPaint);
    if (!_facingRight) canvas.restore();
  }

  void _drawClueMarkers(Canvas canvas, Rect viewport) {
    for (final marker in _clueMarkers) {
      final sx = marker.worldX - viewport.left;
      if (sx < -30 || sx > size.x + 30) continue;

      final pulseScale = 1.0 + 0.15 * math.sin(
          DateTime.now().millisecondsSinceEpoch / 400.0);

      final color = marker.isActive ? const Color(0xFFFFD700) : Colors.white38;
      final glow = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(sx, size.y - 100), 14 * pulseScale, glow);

      final dot = Paint()..color = color;
      canvas.drawCircle(Offset(sx, size.y - 100), 6 * pulseScale, dot);

      final tp = TextPainter(
        text: TextSpan(
          text: '🔍',
          style: TextStyle(fontSize: 14 * pulseScale),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - 8, size.y - 124));
    }
  }

  void _drawMiniMap(Canvas canvas) {
    const mmW = 100.0;
    const mmH = 10.0;
    const mmX = 10.0;
    const mmY = 10.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(mmX - 2, mmY - 2, mmW + 4, mmH + 4),
          const Radius.circular(4)),
      Paint()..color = Colors.black54,
    );

    for (final area in levelData.areas) {
      final x = mmX + (area.startX / worldWidth) * mmW;
      final w = ((area.endX - area.startX) / worldWidth) * mmW;
      canvas.drawRect(
          Rect.fromLTWH(x, mmY, w - 1, mmH),
          Paint()..color = area.accentColor.withValues(alpha: 0.6));
    }

    final px = mmX + (_playerX / worldWidth) * mmW;
    canvas.drawCircle(Offset(px, mmY + mmH / 2), 3,
        Paint()..color = const Color(0xFFFFD700));
  }
}

class _ClueMarker {
  final String areaId;
  final double worldX;
  bool isActive = true;

  _ClueMarker(this.areaId, this.worldX);
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUTTER STATEFUL WIDGET – HUD, Journal, Challenge Panel
// ─────────────────────────────────────────────────────────────────────────────

class WordDetectiveGamePage extends StatefulWidget {
  final WordDetectiveLevelData levelData;

  const WordDetectiveGamePage({super.key, required this.levelData});

  @override
  State<WordDetectiveGamePage> createState() => _WordDetectiveGamePageState();
}

class _WordDetectiveGamePageState extends State<WordDetectiveGamePage>
    with TickerProviderStateMixin {
  late final WordDetectiveFlameGame _flameGame;
  late final FlutterTts _flutterTts;

  // Progress
  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _hintsUsed = 0;
  int _mistakesCount = 0;
  bool _audioMuted = false;
  bool _isOptionSelected = false;
  String? _lastExplanation;
  bool _showTranscript = false;

  // Discovered clues
  final List<ClueData> _discoveredClues = [];

  // Journal
  bool _journalOpen = false;
  JournalTab _activeTab = JournalTab.caseFile;

  // Timeline – discovered events indexed
  final Set<String> _discoveredTimelineIds = {};

  // Skill metrics
  int _readingCorrect = 0;
  int _listeningCorrect = 0;
  int _inferenceCorrect = 0;
  int _vocabCorrect = 0;

  // Hint progression per challenge
  int _currentHintLevel = 0;

  // Animation
  late final AnimationController _clueFoundController;
  bool _showClueFoundBanner = false;
  String _clueFoundText = '';

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlameGame();
    _clueFoundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (mounted) setState(() => _showClueFoundBanner = false);
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.46);
    _flutterTts.setPitch(1.0);
  }

  void _initFlameGame() {
    _flameGame = WordDetectiveFlameGame(
      levelData: widget.levelData,
      onObjectInteract: () {},
      onAreaEntered: (areaId) {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _speakCurrent() {
    final ch = _currentChallenge;
    _speak(ch.spokenText);
  }

  InvestigationChallenge get _currentChallenge =>
      widget.levelData.challenges[_currentChallengeIndex];

  @override
  void dispose() {
    _flutterTts.stop();
    _clueFoundController.dispose();
    super.dispose();
  }

  void _showHint() {
    HapticFeedback.lightImpact();
    final ch = _currentChallenge;
    final hints = [ch.hint1, ch.hint2, ch.hint3]
        .where((h) => h.isNotEmpty)
        .toList();
    final hintText = _currentHintLevel < hints.length
        ? hints[_currentHintLevel]
        : hints.last;

    setState(() {
      _hintsUsed++;
      _currentHintLevel = math.min(_currentHintLevel + 1, hints.length - 1);
      if (_scoreXp > 5) _scoreXp -= 5;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.4),
        ),
        title: Row(children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD700), size: 22),
          const SizedBox(width: 8),
          Text('Detective Hint $_currentHintLevel',
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        content: Text(hintText,
            style: GoogleFonts.inter(
                color: Colors.white70, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('GOT IT',
                style: GoogleFonts.outfit(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleOptionSelected(DetectiveOption option) {
    if (_isOptionSelected) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isOptionSelected = true;
      _lastExplanation = option.explanation;
    });

    if (option.isCorrect) {
      HapticFeedback.mediumImpact();
      final ch = _currentChallenge;
      setState(() {
        _scoreXp += option.xpReward + ch.clueXpBonus;
        _updateMetrics(ch.type);
        if (ch.rewardClue != null) {
          _discoveredClues.add(ch.rewardClue!);
          _unlockTimelineEvents(ch.rewardClue!);
        }
        _showClueFoundBanner = true;
        _clueFoundText =
            ch.rewardClue != null ? '🔍 CLUE FOUND: ${ch.rewardClue!.title}' : '✅ Correct!';
      });
      _clueFoundController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _advanceChallenge();
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _mistakesCount++;
      });
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() {
          _isOptionSelected = false;
          _lastExplanation = null;
        });
      });
    }
  }

  void _updateMetrics(DetectiveChallengeType type) {
    switch (type) {
      case DetectiveChallengeType.readingComprehension:
      case DetectiveChallengeType.detailFinding:
      case DetectiveChallengeType.messageAnalysis:
        _readingCorrect++;
        break;
      case DetectiveChallengeType.listeningClue:
        _listeningCorrect++;
        break;
      case DetectiveChallengeType.timelineReasoning:
      case DetectiveChallengeType.clueConnection:
      case DetectiveChallengeType.caseSolution:
        _inferenceCorrect++;
        break;
      case DetectiveChallengeType.vocabularyContext:
        _vocabCorrect++;
        break;
      default:
        break;
    }
  }

  void _unlockTimelineEvents(ClueData clue) {
    if (clue.timeStamp != null) {
      for (final te in widget.levelData.masterTimeline) {
        if (te.time == clue.timeStamp || clue.text.contains(te.time)) {
          _discoveredTimelineIds.add(te.id);
        }
      }
    }
  }

  void _advanceChallenge() {
    if (_currentChallengeIndex < widget.levelData.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _isOptionSelected = false;
        _lastExplanation = null;
        _currentHintLevel = 0;
        _showTranscript = false;
      });
      _flameGame.movePlayerToChallenge(_currentChallengeIndex);
      _speakCurrent();
    } else {
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    _speak('Case solved! Excellent detective work!');

    final readPct = (85 + _readingCorrect * 2).clamp(75, 100);
    final lisPct = (80 + _listeningCorrect * 5).clamp(75, 100);
    final infPct = (82 + _inferenceCorrect * 3).clamp(75, 100);
    final vocPct = (88 + _vocabCorrect * 4).clamp(75, 100);
    final overall =
        ((readPct + lisPct + infPct + vocPct) / 4).round();
    final stars = overall >= 90 ? 3 : (overall >= 78 ? 2 : 1);
    final totalClues = _discoveredClues.length;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Color(0xFF6366F1), blurRadius: 32, spreadRadius: 2),
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
            const Text('🔎', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 6),
            Text('CASE SOLVED!',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 0.5)),
            Text(widget.levelData.finalRevealText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: const Color(0xFF10B981), fontSize: 12)),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: i < stars
                              ? const Color(0xFFFFD700)
                              : Colors.white24,
                          size: 34,
                        ),
                      )),
            ),
            const SizedBox(height: 14),

            // Skill Metrics
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _metricTile('Reading', '$readPct%', '📖'),
                  _metricTile('Listening', '$lisPct%', '🎧'),
                  _metricTile('Inference', '$infPct%', '🧠'),
                  _metricTile('Vocabulary', '$vocPct%', '📝'),
                ]),
                const Divider(color: Colors.white12, height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _metricTile('Case Accuracy', '$overall%', '🎯'),
                  _metricTile('Clues Found', '$totalClues/10', '🔍'),
                  _metricTile('Total XP', '+$_scoreXp', '⚡'),
                  _metricTile('Hints/Errors', '$_hintsUsed/$_mistakesCount', '💡'),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // Final solution banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
              ),
              child: Text(
                '🔎 ${widget.levelData.finalSolution}',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: const Color(0xFFC4B5FD),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
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
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('CONTINUE TO DAY 11 🚀',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
        ],
      );

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Stack(
          children: [
            Column(children: [
              _buildTopHUD(),
              _buildFlameView(),
              _buildChallengePanel(),
            ]),

            // Clue Found Banner
            if (_showClueFoundBanner) _buildClueFoundBanner(),

            // Journal Overlay
            if (_journalOpen) _buildJournalPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHUD() {
    final ch = _currentChallenge;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
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
            Text(widget.levelData.caseTitle,
                style: GoogleFonts.outfit(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5)),
            Text(ch.areaTitle,
                style: GoogleFonts.outfit(
                    color: Colors.white70, fontSize: 11)),
          ]),
        ),
        // Progress dots
        Row(children: List.generate(
            widget.levelData.challenges.length,
            (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: i == _currentChallengeIndex ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < _currentChallengeIndex
                        ? const Color(0xFF10B981)
                        : i == _currentChallengeIndex
                            ? const Color(0xFF6366F1)
                            : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ))),
        const SizedBox(width: 10),
        // XP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('⚡$_scoreXp XP',
              style: GoogleFonts.outfit(
                  color: const Color(0xFFA78BFA),
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        const SizedBox(width: 8),
        // Journal button
        GestureDetector(
          onTap: () => setState(() => _journalOpen = true),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(children: [
              const Text('📒', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('${_discoveredClues.length}',
                  style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        // Mute
        GestureDetector(
          onTap: () {
            setState(() => _audioMuted = !_audioMuted);
            if (!_audioMuted) _speakCurrent();
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
        height: 170,
        child: GameWidget(game: _flameGame),
      );

  Widget _buildChallengePanel() {
    final ch = _currentChallenge;
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Challenge type badge
            Row(children: [
              _challengeTypeBadge(ch.type),
              const Spacer(),
              // Hint button
              GestureDetector(
                onTap: _showHint,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text('Hint',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              if (ch.type == DetectiveChallengeType.listeningClue) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _speak(ch.spokenText),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.replay_rounded,
                        color: Color(0xFF0EA5E9), size: 16),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 10),

            // Challenge title
            Text(ch.title,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
            const SizedBox(height: 8),

            // Clue briefing card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ch.clueBriefing,
                        style: GoogleFonts.sourceCodePro(
                            color: const Color(0xFF93C5FD),
                            fontSize: 12,
                            height: 1.6)),
                    if (ch.type == DetectiveChallengeType.listeningClue &&
                        ch.audioTranscript != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showTranscript = !_showTranscript),
                        child: Row(children: [
                          Icon(
                            _showTranscript
                                ? Icons.visibility_off_rounded
                                : Icons.subtitles_rounded,
                            color: Colors.white38,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showTranscript
                                ? 'Hide transcript'
                                : 'Show transcript',
                            style: GoogleFonts.inter(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ]),
                      ),
                      if (_showTranscript) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(ch.audioTranscript!,
                              style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ],
                  ]),
            ),
            const SizedBox(height: 10),

            // Explanation feedback
            if (_lastExplanation != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _isOptionSelected &&
                          (_currentChallengeIndex <
                              widget.levelData.challenges.length)
                      ? (_currentChallenge.options
                              .firstWhere(
                                  (o) =>
                                      o.explanation == _lastExplanation,
                                  orElse: () =>
                                      _currentChallenge.options.first)
                              .isCorrect
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.12))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(_lastExplanation!,
                    style: GoogleFonts.inter(
                        color: Colors.white70, fontSize: 12, height: 1.4)),
              ),

            // Question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('❓ ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(ch.question,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // Options
            ...ch.options.asMap().entries.map((entry) {
              final opt = entry.value;
              final isSelected =
                  _isOptionSelected && opt.explanation == _lastExplanation;
              Color border = Colors.white12;
              Color bg = const Color(0xFF1E293B);
              if (_isOptionSelected) {
                if (opt.isCorrect) {
                  border = const Color(0xFF10B981);
                  bg = const Color(0xFF10B981).withValues(alpha: 0.12);
                } else if (isSelected && !opt.isCorrect) {
                  border = Colors.red;
                  bg = Colors.red.withValues(alpha: 0.1);
                }
              }
              return GestureDetector(
                onTap: () => _handleOptionSelected(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 1.4),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(opt.text,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13)),
                    ),
                    if (_isOptionSelected && opt.isCorrect)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 18),
                    if (_isOptionSelected && isSelected && !opt.isCorrect)
                      const Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 18),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _challengeTypeBadge(DetectiveChallengeType type) {
    final config = {
      DetectiveChallengeType.readingComprehension: ('📖 Reading', const Color(0xFF3B82F6)),
      DetectiveChallengeType.detailFinding: ('🔎 Detail Finding', const Color(0xFF10B981)),
      DetectiveChallengeType.messageAnalysis: ('📱 Message Analysis', const Color(0xFF8B5CF6)),
      DetectiveChallengeType.timelineReasoning: ('⏰ Timeline', const Color(0xFFEF4444)),
      DetectiveChallengeType.vocabularyContext: ('📝 Vocabulary', const Color(0xFFF59E0B)),
      DetectiveChallengeType.listeningClue: ('🎧 Listening Clue', const Color(0xFF0EA5E9)),
      DetectiveChallengeType.clueConnection: ('🔗 Clue Connection', const Color(0xFFEC4899)),
      DetectiveChallengeType.redHerring: ('❌ Red Herring', const Color(0xFF6B7280)),
      DetectiveChallengeType.npcQuestioning: ('💬 NPC Interview', const Color(0xFF14B8A6)),
      DetectiveChallengeType.caseSolution: ('🏁 Solve the Case', const Color(0xFFFFD700)),
    };
    final c = config[type] ?? ('Challenge', Colors.white38);
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

  Widget _buildClueFoundBanner() {
    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: _showClueFoundBanner ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xFF10B981), blurRadius: 16, spreadRadius: 1),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🔍', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(_clueFoundText,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DETECTIVE JOURNAL
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildJournalPanel() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: const Color(0xFF0A0F1E).withValues(alpha: 0.95),
          child: SafeArea(
            child: Column(children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  const Text('📒', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Detective Journal',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _journalOpen = false),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 22),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: JournalTab.values
                    .map((tab) => GestureDetector(
                          onTap: () => setState(() => _activeTab = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _activeTab == tab
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _activeTab == tab
                                      ? const Color(0xFF6366F1)
                                      : Colors.white12),
                            ),
                            child: Text(_tabLabel(tab),
                                style: GoogleFonts.outfit(
                                    color: _activeTab == tab
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ))
                    .toList()),
              ),
              const SizedBox(height: 10),

              // Content
              Expanded(child: _buildJournalContent()),
            ]),
          ),
        ),
      ),
    );
  }

  String _tabLabel(JournalTab tab) => switch (tab) {
        JournalTab.caseFile => '📁 CASE',
        JournalTab.clues => '🔍 CLUES (${_discoveredClues.length})',
        JournalTab.timeline => '⏰ TIMELINE',
        JournalTab.people => '👥 PEOPLE',
        JournalTab.locations => '📍 LOCATIONS',
      };

  Widget _buildJournalContent() => switch (_activeTab) {
        JournalTab.caseFile => _buildCaseTab(),
        JournalTab.clues => _buildCluesTab(),
        JournalTab.timeline => _buildTimelineTab(),
        JournalTab.people => _buildPeopleTab(),
        JournalTab.locations => _buildLocationsTab(),
      };

  Widget _buildCaseTab() => ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        children: [
          _journalSection('CASE FILE', [
            _journalRow('Case', widget.levelData.caseTitle),
            _journalRow('Missing Object', widget.levelData.missingObject),
            _journalRow('Location', widget.levelData.incidentLocation),
            _journalRow('Time Window', widget.levelData.incidentTimeRange),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(widget.levelData.openingBriefing,
                style: GoogleFonts.inter(
                    color: Colors.white70, fontSize: 13, height: 1.5)),
          ),
        ],
      );

  Widget _buildCluesTab() {
    if (_discoveredClues.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text('No clues discovered yet.',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 14)),
          Text('Explore the building to find clues.',
              style: GoogleFonts.inter(color: Colors.white24, fontSize: 12)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      itemCount: _discoveredClues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final clue = _discoveredClues[i];
        final importanceColor = clue.importance == ClueImportance.critical
            ? const Color(0xFFEF4444)
            : clue.importance == ClueImportance.supporting
                ? const Color(0xFFF59E0B)
                : Colors.white24;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: importanceColor.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(clue.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('CLUE #${i + 1} – ${clue.title}',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: importanceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    clue.importance == ClueImportance.critical
                        ? 'CRITICAL'
                        : clue.importance == ClueImportance.supporting
                            ? 'SUPPORTING'
                            : 'IRRELEVANT',
                    style: TextStyle(
                        color: importanceColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(clue.text,
                style: GoogleFonts.inter(
                    color: Colors.white70, fontSize: 12, height: 1.4)),
            if (clue.timeStamp != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.access_time_rounded,
                    color: Colors.white38, size: 12),
                const SizedBox(width: 4),
                Text(clue.timeStamp!,
                    style:
                        GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
              ]),
            ],
          ]),
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      itemCount: widget.levelData.masterTimeline.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Container(width: 2, height: 12, color: Colors.white12),
      ),
      itemBuilder: (_, i) {
        final te = widget.levelData.masterTimeline[i];
        final isDiscovered = _discoveredTimelineIds.contains(te.id) ||
            i <= _currentChallengeIndex;
        return Row(children: [
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(te.time.replaceAll(' PM', ''),
                style: GoogleFonts.outfit(
                    color:
                        isDiscovered ? const Color(0xFF6366F1) : Colors.white24,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDiscovered
                  ? const Color(0xFF6366F1)
                  : Colors.white12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDiscovered
                        ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                        : Colors.white12),
              ),
              child: isDiscovered
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(te.description,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 12)),
                      if (te.personName != null)
                        Text('👤 ${te.personName}',
                            style: GoogleFonts.inter(
                                color: Colors.white54, fontSize: 10)),
                    ])
                  : Text('??? — Not yet discovered',
                      style: GoogleFonts.inter(
                          color: Colors.white24, fontSize: 12)),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildPeopleTab() => ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        children: widget.levelData.suspects
            .map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(children: [
                    Text(s.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(s.role,
                                style: GoogleFonts.inter(
                                    color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text('"${s.statement}"',
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF93C5FD),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic)),
                          ]),
                    ),
                  ]),
                ))
            .toList(),
      );

  Widget _buildLocationsTab() => ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        children: widget.levelData.areas
            .map((area) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: area.primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: area.accentColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    Text(area.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(area.name,
                        style: GoogleFonts.outfit(
                            color: area.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ]),
                ))
            .toList(),
      );

  Widget _journalSection(String title, List<Widget> rows) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: rows),
          ),
        ],
      );

  Widget _journalRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text('$label: ',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}
