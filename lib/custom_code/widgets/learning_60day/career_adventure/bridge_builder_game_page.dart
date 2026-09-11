import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bridge_builder_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLAME GAME – 2D Futuristic Bridge & Facility World
// ─────────────────────────────────────────────────────────────────────────────

class BridgeBuilderFlameGame extends FlameGame with TapCallbacks {
  final BridgeBuilderLevelData levelData;
  final VoidCallback onInteract;

  static const double worldWidth = 2500;
  static const double groundY = 270;

  double _playerX = 120;
  double _targetX = 120;
  bool _facingRight = true;
  bool _isMoving = false;
  double _walkCycle = 0;
  double _cameraX = 0;

  // Set of completed challenge IDs that trigger visual repair in the world
  final Set<String> repairedChallengeIds = {};

  int currentTargetIndex = 0;

  BridgeBuilderFlameGame({
    required this.levelData,
    required this.onInteract,
  });

  void movePlayerToChallenge(int index) {
    if (index < levelData.challenges.length) {
      _targetX = (levelData.challenges[index].worldX - 60).clamp(40, worldWidth - 60);
    }
  }

  void movePlayerBy(double dx) {
    _targetX = (_playerX + dx).clamp(40, worldWidth - 60);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dx = _targetX - _playerX;
    if (dx.abs() > 4) {
      _facingRight = dx > 0;
      _isMoving = true;
      _playerX += dx.sign * 220 * dt;
      _walkCycle += dt * 8;
    } else {
      _playerX = _targetX;
      _isMoving = false;
    }

    final sw = size.x;
    _cameraX = (_playerX - sw / 2).clamp(0, worldWidth - sw);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final wx = event.localPosition.x + _cameraX;
    _targetX = wx.clamp(40, worldWidth - 60);

    if (currentTargetIndex < levelData.challenges.length) {
      final ch = levelData.challenges[currentTargetIndex];
      if ((wx - ch.worldX).abs() < 70) {
        onInteract();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final viewport = Rect.fromLTWH(_cameraX, 0, size.x, size.y);
    _drawSkyAndStructures(canvas, viewport);
    _drawFacilityPlatforms(canvas, viewport);
    _drawRepairableObjects(canvas, viewport);
    _drawPlayer(canvas, viewport);
    _drawBeacon(canvas, viewport);
  }

  void _drawSkyAndStructures(Canvas canvas, Rect viewport) {
    // Futuristic sci-fi deep twilight background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A0F1D), Color(0xFF131C31), Color(0xFF0A0F1D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldWidth, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, groundY), bgPaint);

    // Glowing energy grid horizon
    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double y = 40; y < groundY; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(worldWidth, y), gridPaint);
    }
  }

  void _drawFacilityPlatforms(Canvas canvas, Rect viewport) {
    // Metal walkway floor
    final floorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, size.y - groundY), floorPaint);

    // Cyber border neon trim
    final neonTrim = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(0, groundY), Offset(worldWidth, groundY), neonTrim);

    // Hazard yellow/black stripes at intervals
    final hazardPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.3)
      ..strokeWidth = 2;
    for (double x = 0; x < worldWidth; x += 180) {
      final sx = x - viewport.left;
      if (sx < -40 || sx > size.x + 40) continue;
      canvas.drawLine(Offset(sx, groundY), Offset(sx + 15, groundY + 15), hazardPaint);
    }
  }

  void _drawRepairableObjects(Canvas canvas, Rect viewport) {
    for (int i = 0; i < levelData.challenges.length; i++) {
      final ch = levelData.challenges[i];
      final sx = ch.worldX - viewport.left;
      if (sx < -120 || sx > size.x + 120) continue;

      final isRepaired = repairedChallengeIds.contains(ch.id);
      final pulse = 1.0 + 0.1 * math.sin(DateTime.now().millisecondsSinceEpoch / 300.0);

      switch (ch.repairType) {
        case RepairType.bridge:
          // Draw bridge gap or repaired energy bridge
          if (isRepaired) {
            final bridgeGlow = Paint()
              ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5 * pulse)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(sx - 50, groundY - 6, 100, 14),
                const Radius.circular(6),
              ),
              bridgeGlow,
            );
            final bridgeSolid = Paint()..color = const Color(0xFF38BDF8);
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(sx - 50, groundY - 4, 100, 10),
                const Radius.circular(4),
              ),
              bridgeSolid,
            );
          } else {
            // Broken gap with red warning holographic wireframe
            final gapPaint = Paint()
              ..color = const Color(0xFFEF4444).withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            canvas.drawRect(Rect.fromLTWH(sx - 40, groundY, 80, 20), gapPaint);
          }
          break;

        case RepairType.gate:
          // Energy security barrier
          final gatePaint = Paint()
            ..color = isRepaired
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : const Color(0xFFEF4444).withValues(alpha: 0.8 * pulse)
            ..strokeWidth = 4;
          canvas.drawLine(Offset(sx, groundY - 120), Offset(sx, groundY), gatePaint);
          break;

        case RepairType.elevator:
        case RepairType.platform:
          // Floating platform
          final platformPaint = Paint()
            ..color = isRepaired ? const Color(0xFF10B981) : const Color(0xFF64748B);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(sx - 35, groundY - 24, 70, 16),
              const Radius.circular(6),
            ),
            platformPaint,
          );
          break;

        case RepairType.terminal:
        case RepairType.controlTower:
          // Computer terminal or tower mast
          final terminalPaint = Paint()
            ..color = isRepaired ? const Color(0xFF06B6D4) : const Color(0xFF475569);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(sx - 20, groundY - 65, 40, 65),
              const Radius.circular(6),
            ),
            terminalPaint,
          );
          // Hologram icon
          final iconTp = TextPainter(
            text: TextSpan(
              text: isRepaired ? '⚡' : '🔧',
              style: const TextStyle(fontSize: 16),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          iconTp.paint(canvas, Offset(sx - iconTp.width / 2, groundY - 95));
          break;
      }

      // Name label
      final nameTp = TextPainter(
        text: TextSpan(
          text: ch.repairTargetName,
          style: TextStyle(
            color: isRepaired ? const Color(0xFF10B981) : Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black.withValues(alpha: 0.7),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      nameTp.paint(canvas, Offset(sx - nameTp.width / 2, groundY - 115));
    }
  }

  void _drawPlayer(Canvas canvas, Rect viewport) {
    final sx = _playerX - viewport.left;
    final sy = groundY;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(sx, sy + 6), width: 38, height: 12),
      Paint()..color = Colors.black45,
    );

    canvas.save();
    if (!_facingRight) {
      canvas.translate(sx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-sx, 0);
    }

    final bob = _isMoving ? math.sin(_walkCycle) * 3 : 0.0;

    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    if (_isMoving) {
      final legSwing = math.sin(_walkCycle) * 8;
      canvas.drawLine(Offset(sx - 4, sy - 18), Offset(sx - 6 - legSwing, sy + 6), legPaint);
      canvas.drawLine(Offset(sx + 4, sy - 18), Offset(sx + 6 + legSwing, sy + 6), legPaint);
    } else {
      canvas.drawLine(Offset(sx - 5, sy - 18), Offset(sx - 5, sy + 6), legPaint);
      canvas.drawLine(Offset(sx + 5, sy - 18), Offset(sx + 5, sy + 6), legPaint);
    }

    // Engineer Body / High-visibility protective suit (Cyber Orange/Yellow)
    final bodyPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx - 14, sy - 64 + bob, 28, 46),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Tool belt
    final beltPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(sx - 14, sy - 36 + bob, 28, 6), beltPaint);

    // Head
    canvas.drawCircle(Offset(sx, sy - 78 + bob), 14, Paint()..color = const Color(0xFFFFDBAC));

    // Hardhat / Helmet
    final helmetPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(sx, sy - 82 + bob), radius: 15),
      math.pi,
      math.pi,
      true,
      helmetPaint,
    );
    // Helmet lamp
    canvas.drawCircle(Offset(sx + 8, sy - 84 + bob), 3, Paint()..color = const Color(0xFFFFD700));

    // Repair tool in hand
    final toolPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawRect(Rect.fromLTWH(sx + 12, sy - 48 + bob, 5, 14), toolPaint);

    canvas.restore();
  }

  void _drawBeacon(Canvas canvas, Rect viewport) {
    if (currentTargetIndex >= levelData.challenges.length) return;
    final ch = levelData.challenges[currentTargetIndex];
    final sx = ch.worldX - viewport.left;

    final pulse = 1.0 + 0.15 * math.sin(DateTime.now().millisecondsSinceEpoch / 250.0);
    final beaconPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(sx, groundY - 135), 16 * pulse, beaconPaint);

    final arrowPaint = Paint()..color = const Color(0xFFF59E0B);
    final path = Path()
      ..moveTo(sx - 8, groundY - 150)
      ..lineTo(sx + 8, groundY - 150)
      ..lineTo(sx, groundY - 135)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUTTER HUD – Word Block Builder, Slot Tray, Audio, Victory
// ─────────────────────────────────────────────────────────────────────────────

class BridgeBuilderGamePage extends StatefulWidget {
  final BridgeBuilderLevelData levelData;

  const BridgeBuilderGamePage({super.key, required this.levelData});

  @override
  State<BridgeBuilderGamePage> createState() => _BridgeBuilderGamePageState();
}

class _BridgeBuilderGamePageState extends State<BridgeBuilderGamePage> {
  late final BridgeBuilderFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _sentencesBuilt = 0;
  int _hintsUsed = 0;
  int _comboStreak = 0;
  int _bestCombo = 0;
  bool _audioMuted = false;

  // Active sentence building slot state
  List<WordBlock> _availablePool = [];
  List<WordBlock> _placedSlots = [];

  @override
  void initState() {
    super.initState();
    _initFlameGame();
    _initTts();
    _setupChallenge();
  }

  void _initFlameGame() {
    _flameGame = BridgeBuilderFlameGame(
      levelData: widget.levelData,
      onInteract: () => _speakCurrentSentence(),
    );
  }

  void _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46);
    } catch (_) {}
  }

  void _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _setupChallenge() {
    final ch = widget.levelData.challenges[_currentChallengeIndex];
    setState(() {
      final list = List<WordBlock>.from(ch.words);
      list.shuffle(math.Random());
      _availablePool = list;
      _placedSlots = [];
    });
    _flameGame.currentTargetIndex = _currentChallengeIndex;
    _flameGame.movePlayerToChallenge(_currentChallengeIndex);
  }

  void _speakCurrentSentence() {
    final ch = widget.levelData.challenges[_currentChallengeIndex];
    _speak(ch.audioText);
  }

  void _handleWordBlockTapped(WordBlock word, bool isFromPool) {
    HapticFeedback.selectionClick();
    setState(() {
      if (isFromPool) {
        _availablePool.remove(word);
        _placedSlots.add(word);
      } else {
        _placedSlots.remove(word);
        _availablePool.add(word);
      }
    });
  }

  void _resetWords() {
    final ch = widget.levelData.challenges[_currentChallengeIndex];
    HapticFeedback.selectionClick();
    setState(() {
      _availablePool = List<WordBlock>.from(ch.words);
      _placedSlots = [];
    });
  }

  void _checkSentence() {
    final ch = widget.levelData.challenges[_currentChallengeIndex];
    final assembledSentence = _placedSlots.map((w) => w.text).join(' ');

    final isValid = SentenceValidationService.validateSentence(
      assembledSentence,
      ch.acceptedSentences,
    );

    if (isValid) {
      HapticFeedback.mediumImpact();
      _comboStreak++;
      if (_comboStreak > _bestCombo) _bestCombo = _comboStreak;

      _flameGame.repairedChallengeIds.add(ch.id);
      _speak(ch.canonicalSentence);

      final bonus = _comboStreak >= 5 ? 15 : (_comboStreak >= 3 ? 10 : 5);
      final earned = ch.xpReward + bonus;

      setState(() {
        _scoreXp += earned;
        _sentencesBuilt++;
      });

      _showSnackBar(
        _comboStreak >= 5
            ? '🔥 MASTER BUILDER! +$earned XP'
            : '✅ BRIDGE REPAIRED! +$earned XP',
      );

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _advanceNextChallenge();
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _comboStreak = 0);
      _showSnackBar('Sentence incorrect. Check word order and try again!', isError: true);
    }
  }

  void _advanceNextChallenge() {
    if (_currentChallengeIndex < widget.levelData.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
      });
      _setupChallenge();
    } else {
      _showVictoryDialog();
    }
  }

  void _showGrammarHint() {
    final ch = widget.levelData.challenges[_currentChallengeIndex];
    setState(() => _hintsUsed++);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF59E0B)),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Text('Grammar Tip', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          ch.grammarTip,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('GOT IT', style: GoogleFonts.outfit(color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    _speak('All bridges repaired! Transit facility fully operational.');

    const accuracy = 94;
    const grammar = 90;
    const wordOrder = 95;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('🌉', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              Text(
                'BRIDGE COMPLETED!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Every transit pathway has been reconstructed through English.',
                style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 34),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricTile('Sentence Accuracy', '$accuracy%', '🎯'),
                        _metricTile('Grammar', '$grammar%', '📘'),
                        _metricTile('Word Order', '$wordOrder%', '🔤'),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricTile('Sentences Built', '$_sentencesBuilt/${widget.levelData.challenges.length}', '🌉'),
                        _metricTile('Best Combo', 'x$_bestCombo', '⚡'),
                        _metricTile('Total XP', '+$_scoreXp', '⭐'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'CONTINUE TO LEVEL 14 (TRAVEL RUSH)',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, String icon) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.levelData.challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BRIDGE BUILDER',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Target: ${ch.repairTargetName}',
              style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_comboStreak > 1)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6366F1)),
                ),
                child: Text(
                  'BUILD x$_comboStreak',
                  style: GoogleFonts.outfit(color: const Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B)),
            onPressed: _showGrammarHint,
          ),
          IconButton(
            icon: Icon(_audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white),
            onPressed: () => setState(() => _audioMuted = !_audioMuted),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text('+$_scoreXp', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 2D Flame Game World (Top half)
          Expanded(
            flex: 4,
            child: GameWidget(game: _flameGame),
          ),

          // Sentence Construction Workbench (Bottom half)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ch.instruction,
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 20),
                        onPressed: _speakCurrentSentence,
                      ),
                    ],
                  ),

                  // Slot Target Area
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 64),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _placedSlots.isNotEmpty ? const Color(0xFF6366F1) : Colors.white12,
                        width: 1.4,
                      ),
                    ),
                    child: _placedSlots.isEmpty
                        ? Center(
                            child: Text(
                              'Tap word blocks below to build the sentence...',
                              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _placedSlots.map((word) {
                              return GestureDetector(
                                onTap: () => _handleWordBlockTapped(word, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        word.text,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.close_rounded, color: Colors.white60, size: 14),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Available Word Blocks Pool
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availablePool.map((word) {
                          return GestureDetector(
                            onTap: () => _handleWordBlockTapped(word, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                word.text,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Actions: Reset & Verify / Build
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text('RESET', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        onPressed: _resetWords,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.build_rounded, color: Colors.white),
                          label: Text(
                            'ACTIVATE BRIDGE',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: _placedSlots.isNotEmpty ? _checkSentence : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
