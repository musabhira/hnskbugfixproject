import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'message_runner_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLAME GAME – 2D Modern Corporate Campus
// ─────────────────────────────────────────────────────────────────────────────

class MessageRunnerFlameGame extends FlameGame with TapCallbacks {
  final MessageRunnerLevelData levelData;
  final VoidCallback onNpcInteract;

  static const double worldWidth = 2400;
  static const double groundY = 270;

  double _playerX = 120;
  double _targetX = 120;
  bool _facingRight = true;
  bool _isMoving = false;
  double _walkCycle = 0;
  double _cameraX = 0;

  int currentTargetIndex = 0;

  MessageRunnerFlameGame({
    required this.levelData,
    required this.onNpcInteract,
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

    // Check interaction with NPCs
    for (final npc in levelData.npcs) {
      if ((wx - npc.worldX).abs() < 60) {
        onNpcInteract();
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final viewport = Rect.fromLTWH(_cameraX, 0, size.x, size.y);
    _drawBackground(canvas, viewport);
    _drawZones(canvas, viewport);
    _drawNpcs(canvas, viewport);
    _drawPlayer(canvas, viewport);
    _drawWaypoint(canvas, viewport);
  }

  void _drawBackground(Canvas canvas, Rect viewport) {
    // Modern architectural gradient wall
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldWidth, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, groundY), wallPaint);

    // Modern continuous terrazzo floor
    final floorPaint = Paint()..color = const Color(0xFF1E2235);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, size.y - groundY), floorPaint);

    // Floor accent lines
    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.15)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, groundY), Offset(worldWidth, groundY), linePaint);
    canvas.drawLine(Offset(0, groundY + 30), Offset(worldWidth, groundY + 30), linePaint);
  }

  void _drawZones(Canvas canvas, Rect viewport) {
    for (int i = 0; i < levelData.zones.length; i++) {
      final zone = levelData.zones[i];
      final sx = zone.worldX - viewport.left;
      if (sx < -140 || sx > size.x + 140) continue;

      // Zone glass partition backdrop
      final glassPaint = Paint()
        ..color = zone.color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 110, 40, 220, groundY - 50),
          const Radius.circular(16),
        ),
        glassPaint,
      );

      final borderPaint = Paint()
        ..color = zone.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 110, 40, 220, groundY - 50),
          const Radius.circular(16),
        ),
        borderPaint,
      );

      // Zone Name Sign
      final tp = TextPainter(
        text: TextSpan(
          text: zone.name.toUpperCase(),
          style: TextStyle(
            color: zone.color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - tp.width / 2, 52));

      // Desk/terminal in each zone
      final deskPaint = Paint()..color = const Color(0xFF334155);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 50, groundY - 45, 100, 45),
          const Radius.circular(6),
        ),
        deskPaint,
      );

      // Computer monitor
      final monitorPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawRect(Rect.fromLTWH(sx - 16, groundY - 75, 32, 24), monitorPaint);
      final screenPaint = Paint()..color = zone.color.withValues(alpha: 0.7);
      canvas.drawRect(Rect.fromLTWH(sx - 14, groundY - 73, 28, 20), screenPaint);
    }
  }

  void _drawNpcs(Canvas canvas, Rect viewport) {
    for (final npc in levelData.npcs) {
      final sx = npc.worldX - viewport.left;
      if (sx < -80 || sx > size.x + 80) continue;

      // NPC shadow
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sx, groundY + 8), width: 36, height: 12),
        Paint()..color = Colors.black45,
      );

      // NPC body
      final bodyPaint = Paint()..color = npc.badgeColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx - 14, groundY - 60, 28, 48),
          const Radius.circular(8),
        ),
        bodyPaint,
      );

      // NPC Head
      canvas.drawCircle(Offset(sx, groundY - 74), 13, Paint()..color = const Color(0xFFFFDBAC));

      // Avatar emoji symbol
      final tp = TextPainter(
        text: TextSpan(
          text: npc.avatarSymbol,
          style: const TextStyle(fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - tp.width / 2, groundY - 84));

      // Name & Role Tag
      final nameTp = TextPainter(
        text: TextSpan(
          text: '${npc.name} (${npc.role})',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      nameTp.paint(canvas, Offset(sx - nameTp.width / 2, groundY - 105));
    }
  }

  void _drawPlayer(Canvas canvas, Rect viewport) {
    final sx = _playerX - viewport.left;
    final sy = groundY;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(sx, sy + 8), width: 40, height: 14),
      Paint()..color = Colors.black54,
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

    // Body / Courier Uniform (Modern Teal)
    final bodyPaint = Paint()..color = const Color(0xFF0D9488);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx - 14, sy - 64 + bob, 28, 46),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Courier messenger bag
    final bagPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx - 8, sy - 42 + bob, 16, 18),
        const Radius.circular(4),
      ),
      bagPaint,
    );

    // Head & Hair
    canvas.drawCircle(Offset(sx, sy - 78 + bob), 14, Paint()..color = const Color(0xFFFFE0BD));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(sx, sy - 82 + bob), radius: 14),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF332211),
    );

    // Smartphone in hand
    final phonePaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx + 10, sy - 46 + bob, 6, 12),
        const Radius.circular(2),
      ),
      phonePaint,
    );

    canvas.restore();
  }

  void _drawWaypoint(Canvas canvas, Rect viewport) {
    if (currentTargetIndex >= levelData.tasks.length) return;
    final currentTask = levelData.tasks[currentTargetIndex];
    final targetZone = levelData.zones.firstWhere(
      (z) => z.id == currentTask.targetZoneId,
      orElse: () => levelData.zones.first,
    );

    final sx = targetZone.worldX - viewport.left;
    final pulse = 1.0 + 0.15 * math.sin(DateTime.now().millisecondsSinceEpoch / 250.0);

    // Target beacon
    final beaconPaint = Paint()
      ..color = (currentTask.priority == MessagePriority.urgent
              ? const Color(0xFFEF4444)
              : const Color(0xFF38BDF8))
          .withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(sx, groundY - 120), 18 * pulse, beaconPaint);

    final arrowPaint = Paint()
      ..color = currentTask.priority == MessagePriority.urgent
          ? const Color(0xFFEF4444)
          : const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(sx - 8, groundY - 140)
      ..lineTo(sx + 8, groundY - 140)
      ..lineTo(sx, groundY - 125)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLUTTER HUD – Inbox, Typing Overlay, Task Board, Victory Screen
// ─────────────────────────────────────────────────────────────────────────────

class MessageRunnerGamePage extends StatefulWidget {
  final MessageRunnerLevelData levelData;

  const MessageRunnerGamePage({super.key, required this.levelData});

  @override
  State<MessageRunnerGamePage> createState() => _MessageRunnerGamePageState();
}

class _MessageRunnerGamePageState extends State<MessageRunnerGamePage> {
  late final MessageRunnerFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  int _currentTaskIndex = 0;
  int _scoreXp = 0;
  int _messagesDelivered = 0;
  int _spellingMistakes = 0;
  int _hintsUsed = 0;
  bool _audioMuted = false;

  // Real-time task status
  late final List<MessageStatus> _taskStatuses;

  // Typing state
  final TextEditingController _typingController = TextEditingController();

  // Spelling state
  final TextEditingController _spellingController = TextEditingController();

  // 3-way Matching State
  Map<String, String> _userMatches = {};

  // Urgent timer
  Timer? _urgentTimer;
  int _urgentSecondsLeft = 45;
  bool _isUrgentActive = false;

  @override
  void initState() {
    super.initState();
    _taskStatuses = List.generate(widget.levelData.tasks.length, (i) => MessageStatus.unread);
    _initFlameGame();
    _initTts();
  }

  void _initFlameGame() {
    _flameGame = MessageRunnerFlameGame(
      levelData: widget.levelData,
      onNpcInteract: _handleNpcInteract,
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

  MessageRunnerTask get _currentTask => widget.levelData.tasks[_currentTaskIndex];

  void _handleNpcInteract() {
    final task = _currentTask;
    HapticFeedback.selectionClick();

    switch (task.actionType) {
      case MessageActionType.deliverInfo:
      case MessageActionType.politeRewrite:
      case MessageActionType.urgentDelivery:
        _showDialogueOptionsModal();
        break;
      case MessageActionType.typeReply:
        _openTypingModal();
        break;
      case MessageActionType.spellingCorrection:
        _openSpellingModal();
        break;
      case MessageActionType.matchRecipients:
        _openMatchingModal();
        break;
      case MessageActionType.sequenceDelivery:
        _showDialogueOptionsModal();
        break;
    }
  }

  void _showDialogueOptionsModal() {
    final task = _currentTask;
    _speak(task.messageBody);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                      color: _priorityColor(task.priority).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _priorityColor(task.priority)),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: _priorityColor(task.priority),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
                    onPressed: () => _speak(task.messageBody),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'To: ${task.recipientName}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task.prompt,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...List.generate(task.dialogueOptions.length, (idx) {
                final option = task.dialogueOptions[idx];
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
                              option,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.4,
                              ),
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
      ),
    );
  }

  void _handleOptionChosen(int index) {
    final task = _currentTask;
    if (index == task.correctOptionIndex) {
      HapticFeedback.mediumImpact();
      _completeTaskSuccess(task.xpReward);
    } else {
      HapticFeedback.heavyImpact();
      _showFeedbackSnackBar('Incorrect detail. Check the recipient and message again.', isError: true);
    }
  }

  void _openTypingModal() {
    _typingController.clear();
    final task = _currentTask;
    _speak(task.prompt);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
              Text(
                'TYPE YOUR REPLY',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'To: ${task.recipientName}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                task.prompt,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _typingController,
                autofocus: true,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type your message reply here...',
                  hintStyle: GoogleFonts.inter(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    label: Text('💡 Hint', style: GoogleFonts.inter(color: const Color(0xFFFBBF24), fontSize: 11)),
                    onPressed: () {
                      setState(() => _hintsUsed++);
                      _showFeedbackSnackBar(task.hint);
                    },
                  ),
                  ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    label: Text('🔊 Listen', style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11)),
                    onPressed: () => _speak(task.prompt),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    'SEND REPLY',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final res = MessageEvaluationService.evaluateReply(
                      input: _typingController.text,
                      requiredKeywords: task.acceptedKeywords,
                      referenceAnswer: task.referenceReply,
                    );
                    if (res.isAcceptable) {
                      Navigator.of(ctx).pop();
                      _completeTaskSuccess(task.xpReward);
                    } else {
                      _showFeedbackSnackBar(res.feedback, isError: true);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSpellingModal() {
    _spellingController.clear();
    final task = _currentTask;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
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
            Text(
              'CORRECT SPELLING',
              style: GoogleFonts.outfit(
                color: const Color(0xFFF87171),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Misspelled: "${task.misspelledWord}"',
              style: GoogleFonts.inter(
                color: const Color(0xFFF87171),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              task.prompt,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _spellingController,
              autofocus: true,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type correct spelling...',
                hintStyle: GoogleFonts.inter(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF87171)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final input = _spellingController.text.trim().toLowerCase();
                  if (input == task.correctWord?.toLowerCase()) {
                    Navigator.of(ctx).pop();
                    _completeTaskSuccess(task.xpReward);
                  } else {
                    setState(() => _spellingMistakes++);
                    _showFeedbackSnackBar('Incorrect spelling. Hint: ${task.hint}', isError: true);
                  }
                },
                child: Text(
                  'CONFIRM CORRECTION',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMatchingModal() {
    final task = _currentTask;
    final pairs = task.matchPairs ?? {};
    _userMatches = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECIPIENT MATCHING',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF818CF8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Match each message to the correct team member:',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...pairs.keys.map((msg) {
                final currentRecipient = _userMatches[msg];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Sarah', 'Michael', 'Daniel'].map((name) {
                            final isSelected = currentRecipient == name;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                                selected: isSelected,
                                selectedColor: const Color(0xFF6366F1),
                                backgroundColor: const Color(0xFF0F172A),
                                onSelected: (val) {
                                  setModalState(() {
                                    if (val) {
                                      _userMatches[msg] = name;
                                    } else {
                                      _userMatches.remove(msg);
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    bool allCorrect = true;
                    for (final entry in pairs.entries) {
                      if (_userMatches[entry.key] != entry.value) {
                        allCorrect = false;
                        break;
                      }
                    }
                    if (allCorrect && _userMatches.length == pairs.length) {
                      Navigator.of(ctx).pop();
                      _completeTaskSuccess(task.xpReward);
                    } else {
                      _showFeedbackSnackBar('Some matches are incorrect. Try again!', isError: true);
                    }
                  },
                  child: Text(
                    'SUBMIT MATCHES',
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

  void _completeTaskSuccess(int xp) {
    setState(() {
      _scoreXp += xp;
      _messagesDelivered++;
      _taskStatuses[_currentTaskIndex] = MessageStatus.delivered;
    });

    _showFeedbackSnackBar('✅ Message Delivered! +$xp XP');

    if (_currentTaskIndex < widget.levelData.tasks.length - 1) {
      setState(() {
        _currentTaskIndex++;
        _flameGame.currentTargetIndex = _currentTaskIndex;
      });
      final nextTask = _currentTask;
      _flameGame.movePlayerToZone(nextTask.targetZoneId);

      if (nextTask.actionType == MessageActionType.urgentDelivery) {
        _startUrgentCountdown();
      }
    } else {
      _urgentTimer?.cancel();
      _showVictoryDialog();
    }
  }

  void _startUrgentCountdown() {
    _isUrgentActive = true;
    _urgentSecondsLeft = 45;
    _urgentTimer?.cancel();
    _urgentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_urgentSecondsLeft > 0) {
          _urgentSecondsLeft--;
        } else {
          timer.cancel();
          _isUrgentActive = false;
          _showFeedbackSnackBar('⏰ Time expired for urgent message! Proceeding with penalty.', isError: true);
        }
      });
    });
  }

  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _priorityColor(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.urgent:
        return const Color(0xFFEF4444);
      case MessagePriority.important:
        return const Color(0xFFFBBF24);
      case MessagePriority.normal:
        return const Color(0xFF38BDF8);
    }
  }

  void _openInboxDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TODAY'S INBOX",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_messagesDelivered / ${widget.levelData.tasks.length} Delivered',
                    style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: widget.levelData.tasks.length,
                  itemBuilder: (ctx, i) {
                    final t = widget.levelData.tasks[i];
                    final status = _taskStatuses[i];
                    final isCurrent = i == _currentTaskIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF0F172A).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFF38BDF8) : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status == MessageStatus.delivered
                                ? Icons.check_circle_rounded
                                : Icons.mail_rounded,
                            color: status == MessageStatus.delivered
                                ? const Color(0xFF10B981)
                                : _priorityColor(t.priority),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${t.id.toUpperCase()}: ${t.messageTitle}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'To: ${t.recipientName} (${t.targetZoneId})',
                                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            status.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: status == MessageStatus.delivered
                                  ? const Color(0xFF10B981)
                                  : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    _speak('Communication complete! All messages delivered.');

    final readingPct = 91;
    final writingPct = (86 - _spellingMistakes * 3).clamp(70, 100);
    final spellingPct = (88 - _spellingMistakes * 4).clamp(70, 100);
    final commPct = (92 - _hintsUsed * 2).clamp(70, 100);

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
            BoxShadow(color: Color(0xFF0D9488), blurRadius: 32, spreadRadius: 2),
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
              const Text('📨', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              Text(
                'COMMUNICATION COMPLETE!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'All workplace messages reached the right team members.',
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
                        _metricTile('Reading', '$readingPct%', '📖'),
                        _metricTile('Writing', '$writingPct%', '✍️'),
                        _metricTile('Spelling', '$spellingPct%', '🔤'),
                        _metricTile('Communication', '$commPct%', '💬'),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricTile('Delivered', '$_messagesDelivered/${widget.levelData.tasks.length}', '📬'),
                        _metricTile('Errors', '$_spellingMistakes', '⚠️'),
                        _metricTile('Total XP', '+$_scoreXp', '⚡'),
                        _metricTile('Hints', '$_hintsUsed', '💡'),
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
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'CONTINUE TO LEVEL 13 (BRIDGE BUILDER)',
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
    _urgentTimer?.cancel();
    _typingController.dispose();
    _spellingController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = _currentTask;

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
              'MESSAGE RUNNER',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Task ${_currentTaskIndex + 1} of ${widget.levelData.tasks.length}',
              style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_isUrgentActive)
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
                  '⏱ ${_urgentSecondsLeft}s',
                  style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: Badge(
              label: Text('$_messagesDelivered'),
              backgroundColor: const Color(0xFF0D9488),
              child: const Icon(Icons.inbox_rounded, color: Colors.white),
            ),
            onPressed: _openInboxDrawer,
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

          // Active Message Card
          Positioned(
            top: 10,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _priorityColor(task.priority), width: 1.2),
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
                          Icon(Icons.mail_outline_rounded, color: _priorityColor(task.priority), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            task.messageTitle,
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        'Target: ${task.recipientName}',
                        style: GoogleFonts.inter(color: const Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.messageBody,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Quick Navigation & Interaction Bar
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
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                    label: Text(
                      'DELIVER TO ${task.recipientName.toUpperCase()}',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: _handleNpcInteract,
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
