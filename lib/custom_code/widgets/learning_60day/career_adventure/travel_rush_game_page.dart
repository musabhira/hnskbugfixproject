import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'travel_rush_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLAME GAME – 2D Travel Hub Concourse World
// ─────────────────────────────────────────────────────────────────────────────

class TravelRushFlameGame extends FlameGame with TapCallbacks {
  final TravelRushLevelData levelData;
  final VoidCallback onInteract;

  static const double worldWidth = 2600;
  static const double groundY = 270;

  double _playerX = 120;
  double _targetX = 120;
  bool _facingRight = true;
  bool _isMoving = false;
  double _walkCycle = 0;
  double _cameraX = 0;

  int currentTargetIndex = 0;

  TravelRushFlameGame({
    required this.levelData,
    required this.onInteract,
  });

  void movePlayerToZone(String zoneId) {
    final zone = levelData.zones.firstWhere(
      (z) => z.id == zoneId,
      orElse: () => levelData.zones.first,
    );
    _targetX = zone.worldX.clamp(60, worldWidth - 60);
  }

  void movePlayerBy(double dx) {
    _targetX = (_playerX + dx).clamp(60, worldWidth - 60);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dx = _targetX - _playerX;
    if (dx.abs() > 4) {
      _facingRight = dx > 0;
      _isMoving = true;
      _playerX += dx.sign * 230 * dt;
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
    _targetX = wx.clamp(60, worldWidth - 60);

    if (currentTargetIndex < levelData.challenges.length) {
      final ch = levelData.challenges[currentTargetIndex];
      final targetZone = levelData.zones.firstWhere(
        (z) => z.id == ch.targetZoneId,
        orElse: () => levelData.zones.first,
      );
      if ((wx - targetZone.worldX).abs() < 80) {
        onInteract();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final viewport = Rect.fromLTWH(_cameraX, 0, size.x, size.y);
    _drawConcourseBackdrop(canvas, viewport);
    _drawZones(canvas, viewport);
    _drawPlayer(canvas, viewport);
    _drawTargetBeacon(canvas, viewport);
  }

  void _drawConcourseBackdrop(Canvas canvas, Rect viewport) {
    // High-vaulted modern airport terminal ceiling & wall
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldWidth, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, groundY), wallPaint);

    // Polished airport terrazzo flooring with reflection lines
    final floorPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, size.y - groundY), floorPaint);

    // Floor navigation guide lines (Blue LED runway path)
    final pathPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(0, groundY + 18), Offset(worldWidth, groundY + 18), pathPaint);
  }

  void _drawZones(Canvas canvas, Rect viewport) {
    for (int i = 0; i < levelData.zones.length; i++) {
      final zone = levelData.zones[i];
      final sx = zone.worldX - viewport.left;
      if (sx < -140 || sx > size.x + 140) continue;

      // Zone backdrop arch
      final archPaint = Paint()
        ..color = zone.themeColor.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 90, 45, 180, groundY - 55),
          const Radius.circular(14),
        ),
        archPaint,
      );

      final archBorder = Paint()
        ..color = zone.themeColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 90, 45, 180, groundY - 55),
          const Radius.circular(14),
        ),
        archBorder,
      );

      // Zone Signboard (Airport Yellow / Cyan)
      final signPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 70, 52, 140, 24),
          const Radius.circular(6),
        ),
        signPaint,
      );
      final signBorder = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 70, 52, 140, 24),
          const Radius.circular(6),
        ),
        signBorder,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: zone.name.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFBBF24),
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - tp.width / 2, 59));

      // Zone terminal fixture (Gate podium or carousel)
      final deskPaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 35, groundY - 40, 70, 40),
          const Radius.circular(6),
        ),
        deskPaint,
      );

      // Digital gate monitor
      final monPaint = Paint()..color = const Color(0xFF0284C7);
      canvas.drawRect(Rect.fromLTWH(sx - 20, groundY - 70, 40, 26), monPaint);

      final monTp = TextPainter(
        text: const TextSpan(
          text: '✈️',
          style: TextStyle(fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      monTp.paint(canvas, Offset(sx - monTp.width / 2, groundY - 67));
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
      ..color = const Color(0xFF1E293B)
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

    // Traveler Jacket (Modern Navy)
    final bodyPaint = Paint()..color = const Color(0xFF1E40AF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx - 13, sy - 64 + bob, 26, 46),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Traveler Head
    canvas.drawCircle(Offset(sx, sy - 78 + bob), 14, Paint()..color = const Color(0xFFFFDBAC));
    // Hair
    canvas.drawArc(
      Rect.fromCircle(center: Offset(sx, sy - 82 + bob), radius: 14),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF4A3525),
    );

    // Rolling Trolley Suitcase (Blue) behind traveler
    final suitcaseX = sx - 22;
    final suitcasePaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(suitcaseX - 8, sy - 34 + bob, 16, 32),
        const Radius.circular(4),
      ),
      suitcasePaint,
    );
    // Trolley handle
    final handlePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    canvas.drawLine(Offset(suitcaseX, sy - 34 + bob), Offset(sx - 10, sy - 40 + bob), handlePaint);
    // Wheels
    canvas.drawCircle(Offset(suitcaseX - 5, sy), 3, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(suitcaseX + 5, sy), 3, Paint()..color = Colors.black);

    canvas.restore();
  }

  void _drawTargetBeacon(Canvas canvas, Rect viewport) {
    if (currentTargetIndex >= levelData.challenges.length) return;
    final ch = levelData.challenges[currentTargetIndex];
    final targetZone = levelData.zones.firstWhere(
      (z) => z.id == ch.targetZoneId,
      orElse: () => levelData.zones.first,
    );

    final sx = targetZone.worldX - viewport.left;
    final pulse = 1.0 + 0.15 * math.sin(DateTime.now().millisecondsSinceEpoch / 250.0);

    final isUrgent = ch.type == TravelChallengeType.finalBoardingRush;
    final color = isUrgent ? const Color(0xFFEF4444) : const Color(0xFF38BDF8);

    final beaconPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(sx, groundY - 120), 16 * pulse, beaconPaint);

    final arrowPaint = Paint()..color = color;
    final path = Path()
      ..moveTo(sx - 8, groundY - 140)
      ..lineTo(sx + 8, groundY - 140)
      ..lineTo(sx, groundY - 125)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUTTER HUD – Travel Card, Departure Board, PA System, 90s Rush, Victory
// ─────────────────────────────────────────────────────────────────────────────

class TravelRushGamePage extends StatefulWidget {
  final TravelRushLevelData levelData;

  const TravelRushGamePage({super.key, required this.levelData});

  @override
  State<TravelRushGamePage> createState() => _TravelRushGamePageState();
}

class _TravelRushGamePageState extends State<TravelRushGamePage> {
  late final TravelRushFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _gateChangesHandled = 0;
  int _wrongChoices = 0;
  int _hintsUsed = 0;
  bool _audioMuted = false;

  late TravelCard _travelCard;

  // 90s Final Boarding Sprint Timer
  Timer? _rushTimer;
  int _rushSecondsLeft = 90;
  bool _isRushActive = false;

  @override
  void initState() {
    super.initState();
    _travelCard = widget.levelData.initialTravelCard;
    _initFlameGame();
    _initTts();
  }

  void _initFlameGame() {
    _flameGame = TravelRushFlameGame(
      levelData: widget.levelData,
      onInteract: _openChallengeModal,
    );
  }

  void _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
    } catch (_) {}
  }

  void _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  TravelRushChallenge get _currentChallenge => widget.levelData.challenges[_currentChallengeIndex];

  void _openChallengeModal() {
    final ch = _currentChallenge;
    _speak(ch.audioAnnouncement);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Text(
                    ch.type.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ActionChip(
                      backgroundColor: const Color(0xFF1E293B),
                      label: Text('💡 Hint', style: GoogleFonts.inter(color: const Color(0xFFFBBF24), fontSize: 11)),
                      onPressed: () {
                        setState(() => _hintsUsed++);
                        _showSnackBar(ch.hint);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
                      onPressed: () => _speak(ch.audioAnnouncement),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ch.question,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(ch.prompt, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            ...List.generate(ch.options.length, (idx) {
              final opt = ch.options[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _handleOptionChosen(idx);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0F172A),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            String.fromCharCode(65 + idx),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ),
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

  void _handleOptionChosen(int index) {
    final ch = _currentChallenge;
    if (index == ch.correctOptionIndex) {
      HapticFeedback.mediumImpact();

      // If gate change challenge, update travel card
      if (ch.updatedGate != null) {
        setState(() {
          _travelCard = _travelCard.copyWith(gate: ch.updatedGate);
          _gateChangesHandled++;
        });
      }

      _completeChallengeSuccess(ch.xpReward);
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _wrongChoices++);
      _showSnackBar('Incorrect choice. Check departure information and try again.', isError: true);
    }
  }

  void _completeChallengeSuccess(int xp) {
    setState(() {
      _scoreXp += xp;
    });

    _showSnackBar('✅ Correct Travel Action! +$xp XP');

    if (_currentChallengeIndex < widget.levelData.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _flameGame.currentTargetIndex = _currentChallengeIndex;
      });
      final next = _currentChallenge;
      _flameGame.movePlayerToZone(next.targetZoneId);

      if (next.type == TravelChallengeType.finalBoardingRush) {
        _startRushCountdown();
      }
    } else {
      _rushTimer?.cancel();
      _showVictoryDialog();
    }
  }

  void _startRushCountdown() {
    _isRushActive = true;
    _rushSecondsLeft = 90;
    _rushTimer?.cancel();
    _rushTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_rushSecondsLeft > 0) {
          _rushSecondsLeft--;
        } else {
          timer.cancel();
          _isRushActive = false;
          _showSnackBar('⏰ Boarding gate closing! Rush to the gate immediately!', isError: true);
        }
      });
    });
  }

  void _openTravelCardModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BOARDING PASS',
                  style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                ),
                Text(
                  _travelCard.flightNumber,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardField('Passenger', _travelCard.passengerName),
                      _cardField('Destination', _travelCard.destination),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardField('Gate', _travelCard.gate, highlight: true),
                      _cardField('Departure', _travelCard.departureTime),
                      _cardField('Seat', _travelCard.seat),
                      _cardField('Coach', _travelCard.coach),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Booking Ref: ${_travelCard.referenceId} • Status: CONFIRMED',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardField(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: highlight ? const Color(0xFFFBBF24) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _openDepartureBoardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFBBF24), width: 1.4),
        ),
        title: Row(
          children: [
            const Icon(Icons.flight_takeoff_rounded, color: Color(0xFFFBBF24)),
            const SizedBox(width: 8),
            Text('DEPARTURE BOARD', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.levelData.flights.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12),
            itemBuilder: (ctx, i) {
              final fl = widget.levelData.flights[i];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fl.destination, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(fl.flightNumber, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  Text(fl.departureTime, style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 13)),
                  Text('Gate ${fl.gate}', style: GoogleFonts.outfit(color: const Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CLOSE', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
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
    _speak('Journey complete! You have successfully boarded the Bengaluru express.');

    const reading = 90;
    const listening = 88;
    const navigation = 93;
    const travelKnowledge = 91;

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
            BoxShadow(color: Color(0xFF10B981), blurRadius: 32, spreadRadius: 2),
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
              const Text('✈️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              Text(
                'JOURNEY COMPLETE!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Boarding completed for destination: ${_travelCard.destination}',
                style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 13),
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
                        _metricTile('Reading', '$reading%', '📖'),
                        _metricTile('Listening', '$listening%', '🎧'),
                        _metricTile('Navigation', '$navigation%', '🧭'),
                        _metricTile('Travel Skills', '$travelKnowledge%', '✈️'),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricTile('Gate Updates', '$_gateChangesHandled', '🚪'),
                        _metricTile('Wrong Choices', '$_wrongChoices', '⚠️'),
                        _metricTile('Total XP', '+$_scoreXp', '⚡'),
                        _metricTile('Hints Used', '$_hintsUsed', '💡'),
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
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'COMPLETE DAY 14 (14 / 90 DAYS)',
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
    _rushTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = _currentChallenge;

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
              'TRAVEL RUSH',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Gate: ${_travelCard.gate} • ${_travelCard.destination}',
              style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_isRushActive)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Text(
                  '⏱ ${_rushSecondsLeft}s',
                  style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.confirmation_number_rounded, color: Color(0xFF38BDF8)),
            onPressed: _openTravelCardModal,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_rounded, color: Color(0xFFFBBF24)),
            onPressed: _openDepartureBoardDialog,
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
      body: Stack(
        children: [
          GameWidget(game: _flameGame),

          // Top Public Address Announcement Banner
          Positioned(
            top: 10,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ch.type == TravelChallengeType.finalBoardingRush
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF38BDF8),
                  width: 1.2,
                ),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            color: ch.type == TravelChallengeType.finalBoardingRush
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF38BDF8),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TRAVEL ANNOUNCEMENT',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 18),
                        onPressed: () => _speak(ch.audioAnnouncement),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ch.audioAnnouncement,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation & Challenge Action Bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => _flameGame.movePlayerBy(-120),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ch.type == TravelChallengeType.finalBoardingRush
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.directions_walk_rounded, color: Colors.white),
                    label: Text(
                      'APPROACH ${ch.targetZoneId.toUpperCase()}',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: _openChallengeModal,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  onPressed: () => _flameGame.movePlayerBy(120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
