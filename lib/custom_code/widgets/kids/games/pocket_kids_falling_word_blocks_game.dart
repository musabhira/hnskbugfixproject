import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/events.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';

// ============================================================================
// 🔥 1. FLAME 2D ENGINE & COMPONENTS FOR FALLING WORD BLOCKS GAME
// ============================================================================

/// ✨ Sparkle Particle bursting when a block is tapped
class FlameStarSparkle extends Component {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double radius;
  double life;
  final double decay;
  final bool isStar;

  FlameStarSparkle({
    required this.position,
    required this.velocity,
    required this.color,
    this.radius = 8.0,
    this.life = 1.0,
    this.decay = 2.0,
    this.isStar = true,
  });

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 120.0 * dt; // gentle gravity
    life -= decay * dt;
    radius = math.max(0, radius - (3.0 * dt));
    if (life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: life.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    if (isStar) {
      _drawStar(canvas, Offset(position.x, position.y), 5, radius, radius * 0.45, paint);
    } else {
      canvas.drawCircle(Offset(position.x, position.y), radius, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outer, double inner, Paint paint) {
    final path = Path();
    final double step = math.pi / points;
    double rot = -math.pi / 2;
    path.moveTo(center.dx + math.cos(rot) * outer, center.dy + math.sin(rot) * outer);
    for (int i = 0; i < points; i++) {
      rot += step;
      path.lineTo(center.dx + math.cos(rot) * inner, center.dy + math.sin(rot) * inner);
      rot += step;
      path.lineTo(center.dx + math.cos(rot) * outer, center.dy + math.sin(rot) * outer);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// 🎊 Victory Confetti Piece floating down on game completion
class FlameConfettiPiece extends Component {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double sizeW;
  double sizeH;
  double rotation;
  double rotSpeed;
  double life;

  FlameConfettiPiece({
    required this.position,
    required this.velocity,
    required this.color,
    this.sizeW = 10.0,
    this.sizeH = 6.0,
    this.rotation = 0.0,
    this.rotSpeed = 3.0,
    this.life = 1.0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.x += math.sin(position.y * 0.05) * 15.0 * dt; // flutter
    rotation += rotSpeed * dt;
    if (position.y > 1000) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.rotate(rotation);
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: sizeW, height: sizeH),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.restore();
  }
}

/// 🐻 Cute Animated Cartoon Bear Companion (Kumi Style) sitting in the scene
class FlameMascotBearComponent extends PositionComponent {
  double animTime = 0.0;
  bool isCheering = false;
  bool isWobbling = false;
  double cheerTimer = 0.0;

  FlameMascotBearComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size, anchor: Anchor.bottomCenter);

  void cheer() {
    isCheering = true;
    isWobbling = false;
    cheerTimer = 1.2;
  }

  void wobble() {
    isWobbling = true;
    isCheering = false;
    cheerTimer = 0.8;
  }

  @override
  void update(double dt) {
    super.update(dt);
    animTime += dt;
    if (cheerTimer > 0) {
      cheerTimer -= dt;
      if (cheerTimer <= 0) {
        isCheering = false;
        isWobbling = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final double bounce = isCheering
        ? -math.sin(animTime * 14).abs() * 14.0
        : (isWobbling ? math.sin(animTime * 20) * 8.0 : math.sin(animTime * 3) * 3.0);

    final double w = size.x;
    final double h = size.y;

    canvas.save();
    canvas.translate(0, bounce);

    // Bear Face Center
    final center = Offset(w / 2, h / 2 + 10);
    const double headRadius = 36.0;

    // Ears
    final earPaint = Paint()..color = const Color(0xFFB45309);
    final innerEarPaint = Paint()..color = const Color(0xFFFDE68A);

    // Left Ear
    canvas.drawCircle(Offset(center.dx - 28, center.dy - 30), 14, earPaint);
    canvas.drawCircle(Offset(center.dx - 28, center.dy - 30), 8, innerEarPaint);

    // Right Ear
    canvas.drawCircle(Offset(center.dx + 28, center.dy - 30), 14, earPaint);
    canvas.drawCircle(Offset(center.dx + 28, center.dy - 30), 8, innerEarPaint);

    // Head Base
    final headPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(center, headRadius, headPaint);

    // Head 3D Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 10, center.dy - 12), headRadius * 0.55, highlightPaint);

    // Snout / Muzzle
    final snoutPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 8), width: 38, height: 26),
      snoutPaint,
    );

    // Nose
    final nosePaint = Paint()..color = const Color(0xFF78350F);
    final nosePath = Path()
      ..moveTo(center.dx - 7, center.dy + 2)
      ..lineTo(center.dx + 7, center.dy + 2)
      ..quadraticBezierTo(center.dx, center.dy + 9, center.dx - 7, center.dy + 2);
    canvas.drawPath(nosePath, nosePaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (isCheering) {
      // Open happy mouth
      final mouthPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 12), width: 14, height: 10),
        mouthPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 8), width: 14, height: 10),
        0.2,
        math.pi - 0.4,
        false,
        smilePaint,
      );
    }

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1F2937);
    final glintPaint = Paint()..color = Colors.white;

    if (isCheering) {
      // Happy squint arch eyes ^ ^
      final squintPaint = Paint()
        ..color = const Color(0xFF1F2937)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx - 14, center.dy - 6), width: 12, height: 10),
        math.pi,
        math.pi,
        false,
        squintPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx + 14, center.dy - 6), width: 12, height: 10),
        math.pi,
        math.pi,
        false,
        squintPaint,
      );
    } else {
      // Big friendly cartoon eyes
      canvas.drawCircle(Offset(center.dx - 14, center.dy - 6), 5, eyePaint);
      canvas.drawCircle(Offset(center.dx + 14, center.dy - 6), 5, eyePaint);
      canvas.drawCircle(Offset(center.dx - 15, center.dy - 8), 1.8, glintPaint);
      canvas.drawCircle(Offset(center.dx + 13, center.dy - 8), 1.8, glintPaint);
    }

    // Blush Cheeks
    final blushPaint = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(center.dx - 22, center.dy + 6), 6.5, blushPaint);
    canvas.drawCircle(Offset(center.dx + 22, center.dy + 6), 6.5, blushPaint);

    // Cheering Paws
    if (isCheering) {
      final pawPaint = Paint()..color = const Color(0xFFB45309);
      canvas.drawCircle(Offset(center.dx - headRadius - 4, center.dy - 20), 10, pawPaint);
      canvas.drawCircle(Offset(center.dx + headRadius + 4, center.dy - 20), 10, pawPaint);
    }

    canvas.restore();
  }
}

/// 🧱 Physics Falling Letter Block Component with Flame TapCallbacks
class FlameFallingLetterBlock extends PositionComponent with TapCallbacks {
  final String letter;
  final Color blockColor;
  final void Function(FlameFallingLetterBlock block) onBlockTapped;
  final void Function(FlameFallingLetterBlock block) onFellOffScreen;

  double speed = 110.0; // pixels per second
  double wobbleAngle = 0.0;
  double wobbleSpeed = 2.5;
  double timeAlive = 0.0;
  bool isCaught = false;

  FlameFallingLetterBlock({
    required Vector2 position,
    required Vector2 size,
    required this.letter,
    required this.blockColor,
    required this.onBlockTapped,
    required this.onFellOffScreen,
    double initialSpeed = 110.0,
  }) : super(position: position, size: size, anchor: Anchor.center) {
    speed = initialSpeed;
    wobbleSpeed = 2.0 + math.Random().nextDouble() * 2.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCaught) return;

    timeAlive += dt;
    position.y += speed * dt;
    angle = math.sin(timeAlive * wobbleSpeed) * 0.09;

    // Check if fallen below screen bounds
    final parentGame = findGame();
    if (parentGame != null && position.y > parentGame.size.y + 40) {
      onFellOffScreen(this);
      removeFromParent();
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final halfW = size.x / 2 + 20;
    final halfH = size.y / 2 + 20;
    final inZeroCenter = point.x >= -halfW && point.x <= halfW && point.y >= -halfH && point.y <= halfH;
    final inTopLeft = point.x >= -20 && point.x <= size.x + 20 && point.y >= -20 && point.y <= size.y + 20;
    return inZeroCenter || inTopLeft;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isCaught) return;
    onBlockTapped(this);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // 1. Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(rrect.shift(const Offset(0, 5)), shadowPaint);

    // 2. Base 3D Border / Thickness
    final borderPaint = Paint()
      ..color = HSLColor.fromColor(blockColor)
          .withLightness((HSLColor.fromColor(blockColor).lightness - 0.2).clamp(0.0, 1.0))
          .toColor();
    canvas.drawRRect(rrect.inflate(2), borderPaint);

    // 3. Main Face (Gradient)
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromColor(blockColor)
              .withLightness((HSLColor.fromColor(blockColor).lightness + 0.12).clamp(0.0, 1.0))
              .toColor(),
          blockColor,
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, gradientPaint);

    // 4. Glossy Top Bevel Highlight (Reference Image 1 Gloss)
    final glossPath = Path();
    glossPath.moveTo(-w / 2 + 6, -h / 2 + 5);
    glossPath.lineTo(w / 2 - 6, -h / 2 + 5);
    glossPath.quadraticBezierTo(0, -h / 2 + 16, -w / 2 + 6, -h / 2 + 5);
    glossPath.close();

    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    canvas.drawPath(glossPath, glossPaint);

    // 5. Letter Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.35),
              offset: const Offset(1, 2),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}

/// 🎮 Master Flame Game Engine for Falling Word Blocks
class FallingWordBlocksFlameGame extends FlameGame with TapCallbacks {
  final math.Random _rng = math.Random();
  late FlameMascotBearComponent mascot;

  void Function(FlameFallingLetterBlock block)? onBlockTappedCallback;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Spawn animated Kumi mascot bear at bottom left
    mascot = FlameMascotBearComponent(
      position: Vector2(70, size.y - 10),
      size: Vector2(90, 85),
    );
    add(mascot);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final clickPos = event.localPosition;
    for (final block in children.whereType<FlameFallingLetterBlock>().toList().reversed) {
      if (block.isCaught) continue;
      final dist = (block.position - clickPos).length;
      if (dist <= 55.0) {
        block.onTapDown(event);
        break;
      }
    }
  }

  /// Spawn a block at the top of the screen
  void spawnBlock({
    required String letter,
    required Color color,
    double? initialX,
  }) {
    if (size.x <= 0) return;

    final double x = initialX ?? (40.0 + _rng.nextDouble() * (size.x - 80.0));
    final block = FlameFallingLetterBlock(
      position: Vector2(x, -35),
      size: Vector2(62, 62),
      letter: letter,
      blockColor: color,
      initialSpeed: 105.0 + _rng.nextDouble() * 30.0,
      onBlockTapped: (b) {
        onBlockTappedCallback?.call(b);
      },
      onFellOffScreen: (b) {},
    );
    add(block);
  }

  /// Burst star sparkles when a block is successfully caught
  void burstCatchSparkles(Vector2 pos, Color color) {
    mascot.cheer();
    for (int i = 0; i < 14; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 80.0 + _rng.nextDouble() * 120.0;
      add(
        FlameStarSparkle(
          position: Vector2(pos.x, pos.y),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          color: [
            color,
            const Color(0xFFFFD700),
            const Color(0xFFFF5252),
            const Color(0xFF69F0AE),
            Colors.white,
          ][_rng.nextInt(5)],
          radius: 6.0 + _rng.nextDouble() * 4.0,
          isStar: i % 2 == 0,
        ),
      );
    }
  }

  /// Trigger massive victory confetti rain on game win
  void triggerVictoryConfetti() {
    mascot.cheer();
    for (int i = 0; i < 70; i++) {
      final x = _rng.nextDouble() * size.x;
      final y = -20.0 - _rng.nextDouble() * 200.0;
      add(
        FlameConfettiPiece(
          position: Vector2(x, y),
          velocity: Vector2(
            (_rng.nextDouble() - 0.5) * 60.0,
            120.0 + _rng.nextDouble() * 160.0,
          ),
          color: [
            const Color(0xFFFF007A),
            const Color(0xFFFFD700),
            const Color(0xFF38BDF8),
            const Color(0xFF10B981),
            const Color(0xFFF59E0B),
            const Color(0xFF8B5CF6),
          ][_rng.nextInt(6)],
          sizeW: 8.0 + _rng.nextDouble() * 8.0,
          sizeH: 4.0 + _rng.nextDouble() * 5.0,
          rotSpeed: (_rng.nextDouble() - 0.5) * 8.0,
        ),
      );
    }
  }

  void wobbleMascot() {
    mascot.wobble();
  }

  void clearAllBlocks() {
    children.whereType<FlameFallingLetterBlock>().forEach((b) => b.removeFromParent());
  }
}

// ============================================================================
// 📱 2. POCKET KIDS FALLING WORD BLOCKS GAME WIDGET (KUMI REFERENCE UI)
// ============================================================================

class PocketKidsFallingWordBlocksGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsFallingWordBlocksGame({
    super.key,
    required this.day,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsFallingWordBlocksGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsFallingWordBlocksGame> createState() =>
      _PocketKidsFallingWordBlocksGameState();
}

class _PocketKidsFallingWordBlocksGameState
    extends State<PocketKidsFallingWordBlocksGame> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final FallingWordBlocksFlameGame _flameGame;

  // Curated child-friendly progressive word pool for 90 days
  static const List<Map<String, String>> _wordsDatabase = [
    {'word': 'CAT', 'emoji': '🐱', 'meaning': 'പൂച്ച / Cat'},
    {'word': 'SUN', 'emoji': '☀️', 'meaning': 'സൂര്യൻ / Sun'},
    {'word': 'STAR', 'emoji': '⭐', 'meaning': 'നക്ഷത്രം / Star'},
    {'word': 'BOOK', 'emoji': '📖', 'meaning': 'പുസ്തകം / Book'},
    {'word': 'PLAY', 'emoji': '⚽', 'meaning': 'കളിക്കുക / Play'},
    {'word': 'TREE', 'emoji': '🌳', 'meaning': 'മരം / Tree'},
    {'word': 'BIRD', 'emoji': '🐦', 'meaning': 'പക്ഷി / Bird'},
    {'word': 'FISH', 'emoji': '🐟', 'meaning': 'മീൻ / Fish'},
    {'word': 'MOON', 'emoji': '🌙', 'meaning': 'ചന്ദ്രൻ / Moon'},
    {'word': 'RAIN', 'emoji': '🌧️', 'meaning': 'മഴ / Rain'},
    {'word': 'CAKE', 'emoji': '🎂', 'meaning': 'കേക്ക് / Cake'},
    {'word': 'HOME', 'emoji': '🏡', 'meaning': 'വീട് / Home'},
    {'word': 'ROSE', 'emoji': '🌹', 'meaning': 'റോസാപ്പൂ / Rose'},
    {'word': 'LION', 'emoji': '🦁', 'meaning': 'സിംഹം / Lion'},
    {'word': 'FROG', 'emoji': '🐸', 'meaning': 'തവള / Frog'},
  ];

  late List<Map<String, String>> _dayWords;
  int _currentWordIndex = 0;
  List<String> _targetLetters = [];
  final List<String> _placedLetters = [];
  List<String> _availableOptions = [];

  Timer? _spawnTimer;
  bool _showVictory = false;
  int _score = 0;
  int _hearts = 4; // Reference Image 1 Screen 2: 4 Hearts

  static const List<Color> _blockColors = [
    Color(0xFFFF5252), // Coral Red
    Color(0xFFFFA000), // Amber Gold
    Color(0xFF10B981), // Mint Emerald
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF8B5CF6), // Royal Lavender
    Color(0xFFEC4899), // Bubblegum Pink
  ];

  @override
  void initState() {
    super.initState();
    _initTts();

    _flameGame = FallingWordBlocksFlameGame();
    _flameGame.onBlockTappedCallback = _onFlameBlockTapped;

    // Select 3 unique pedagogical words for this exact Day from the 100-Day Syllabus
    final syllabus = PocketKids100DaySyllabusDB.getSyllabusForDay(widget.day);
    final mapped = syllabus.rounds
        .map((r) => {
              'word': r.targetWord
                  .toUpperCase()
                  .replaceAll(RegExp(r'[^A-Z]'), ''),
              'emoji': r.emoji.isNotEmpty ? r.emoji : '🌟',
              'meaning': r.targetSubtitle.isNotEmpty
                  ? r.targetSubtitle
                  : r.targetWord,
            })
        .where((m) => m['word']!.length >= 2 && m['word']!.length <= 8)
        .toList();

    if (mapped.isNotEmpty) {
      _dayWords = mapped;
    } else {
      // Fallback
      final startIndex = ((widget.day - 1) * 3) % _wordsDatabase.length;
      _dayWords = [
        _wordsDatabase[startIndex % _wordsDatabase.length],
        _wordsDatabase[(startIndex + 1) % _wordsDatabase.length],
        _wordsDatabase[(startIndex + 2) % _wordsDatabase.length],
      ];
    }

    _setupWord();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _setupWord() {
    final cur = _dayWords[_currentWordIndex % _dayWords.length];
    _targetLetters = cur['word']!.split('');
    _placedLetters.clear();
    _flameGame.clearAllBlocks();

    // Generate option chips including the target letters + 2 distractors
    final distractors = ['B', 'S', 'O', 'M', 'P', 'R', 'D'];
    final pool = List<String>.from(_targetLetters);
    for (final d in distractors) {
      if (!pool.contains(d) && pool.length < _targetLetters.length + 2) {
        pool.add(d);
      }
    }
    pool.shuffle();
    _availableOptions = pool;

    _speak("Catch letters to spell: ${cur['word']}!");

    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
      if (!mounted || _showVictory) return;
      _spawnNextBlock();
    });
  }

  void _spawnNextBlock() {
    final random = math.Random();
    final nextNeededLetter = _placedLetters.length < _targetLetters.length
        ? _targetLetters[_placedLetters.length]
        : 'A';

    final String letterToSpawn;
    if (random.nextDouble() < 0.65) {
      letterToSpawn = nextNeededLetter;
    } else {
      const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      letterToSpawn = alphabet[random.nextInt(alphabet.length)];
    }

    final color = _blockColors[random.nextInt(_blockColors.length)];
    _flameGame.spawnBlock(letter: letterToSpawn, color: color);
  }

  void _onFlameBlockTapped(FlameFallingLetterBlock block) {
    if (block.isCaught || _showVictory) return;
    block.isCaught = true;
    final pos = block.position.clone();
    final col = block.blockColor;
    block.removeFromParent();
    _processLetter(block.letter, sparklePos: pos, blockColor: col);
  }

  void _onDirectLetterTapped(String letter) {
    if (_showVictory) return;
    _processLetter(letter);
  }

  void _processLetter(String letter, {Vector2? sparklePos, Color? blockColor}) {
    if (_showVictory) return;

    final nextNeededIndex = _placedLetters.length;
    if (nextNeededIndex >= _targetLetters.length) return;

    final neededLetter = _targetLetters[nextNeededIndex];

    if (letter.toUpperCase() == neededLetter.toUpperCase()) {
      HapticFeedback.heavyImpact();
      PocketGameSFX.playCorrectChime();

      final pos = sparklePos ?? Vector2(150, 250);
      final col = blockColor ?? const Color(0xFF10B981);
      _flameGame.burstCatchSparkles(pos, col);

      setState(() {
        _placedLetters.add(neededLetter);
        _score += 10;
      });

      _speak(neededLetter);

      // Check if current word is completed
      if (_placedLetters.length == _targetLetters.length) {
        final cur = _dayWords[_currentWordIndex % _dayWords.length];
        _speak("Great! ${cur['word']}!");
        HapticFeedback.heavyImpact();

        Future.delayed(const Duration(milliseconds: 1100), () {
          if (!mounted) return;
          if (_currentWordIndex + 1 < _dayWords.length) {
            setState(() {
              _currentWordIndex++;
            });
            _setupWord();
          } else {
            _onCompleteAllWords();
          }
        });
      }
    } else {
      // Wrong block tapped: play buzz & shake mascot
      HapticFeedback.lightImpact();
      PocketGameSfx.instance.playErrorBuzz();
      _flameGame.wobbleMascot();

      setState(() {
        if (_hearts > 1) {
          _hearts--;
        }
      });
      _speak("Look for letter $neededLetter!");
    }
  }

  Future<void> _onCompleteAllWords() async {
    _spawnTimer?.cancel();
    _flameGame.triggerVictoryConfetti();

    setState(() {
      _showVictory = true;
    });

    PocketGameSFX.playVictoryFanfare();
    await PocketKidsService.addKidsScore(30);
    await PocketKidsService.markDayCompleted(widget.day);
    widget.onCompleted?.call();
    _speak("Awesome! Day ${widget.day} Word Blocks Completed! You unlocked your Defense Card!");
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curWord = _dayWords[_currentWordIndex % _dayWords.length];
    final card = PopArtCardHelper.getCardForDay(widget.day, isMale: true);

    return Scaffold(
      backgroundColor: const Color(0xFF99E6D8), // Soft mint green from Kumi reference
      body: Stack(
        children: [
          // 1. Lush Pastel Cartoon Scenery Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFBAE6FD), // Sky pastel blue
                    Color(0xFFA7F3D0), // Meadow mint green
                  ],
                ),
              ),
            ),
          ),

          // 2. 🎮 Interactive Flame Game Engine Canvas
          Positioned.fill(
            child: GameWidget(game: _flameGame),
          ),

          // 3. 🌟 Top Kumi Reference Header (Striped Progress Bar + Hearts)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopKumiHeader(),
                  _buildMascotPromptBanner(curWord),
                ],
              ),
            ),
          ),

          // 4. 📥 Bottom Letter Docking Slots & Option Chips
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: _buildLetterDockingTray(),
            ),
          ),

          // 4. 🏆 "You won!" Victory Modal directly matching Reference Image 1 Screen 6
          if (_showVictory) _buildKumiVictoryOverlay(card),
        ],
      ),
    );
  }

  // =========================================================================
  // 🌟 TOP HEADER MATCHING REFERENCE IMAGE 1 SCREEN 2
  // =========================================================================
  Widget _buildTopKumiHeader() {
    final progress = (_currentWordIndex + (_placedLetters.length / _targetLetters.length)) / _dayWords.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Close 'X' Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.close_rounded, color: Color(0xFF0284C7), size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // Candy-Striped Progress Bar
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.08, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '+$_score KS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD97706),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Heart Counter (❤️ 4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('❤️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_hearts',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
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
  // 💬 MASCOT PROMPT BANNER (KUMI STYLE)
  // =========================================================================
  Widget _buildMascotPromptBanner(Map<String, String> curWord) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(curWord['emoji'] ?? '🐱', style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SPELL: ${curWord['word']}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _speak(curWord['word']!),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  curWord['meaning'] ?? '',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
            ),
            child: Text(
              '+10 KS',
              style: GoogleFonts.outfit(
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 📥 LETTER DOCKING TRAY
  // =========================================================================
  Widget _buildLetterDockingTray() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tap the falling blocks to catch letters in order:',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_targetLetters.length, (idx) {
              final hasLetter = idx < _placedLetters.length;
              final letter = hasLetter ? _placedLetters[idx] : '';
              final isNextTarget = idx == _placedLetters.length;

              return Container(
                width: 58,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: hasLetter
                      ? const Color(0xFF10B981)
                      : (isNextTarget
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasLetter
                        ? const Color(0xFF059669)
                        : (isNextTarget
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFCBD5E1)),
                    width: isNextTarget ? 2.5 : 1.8,
                  ),
                  boxShadow: [
                    if (hasLetter)
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  hasLetter ? letter : (isNextTarget ? '?' : '_'),
                  style: GoogleFonts.outfit(
                    color: hasLetter
                        ? Colors.white
                        : (isNextTarget
                            ? const Color(0xFFD97706)
                            : const Color(0xFF94A3B8)),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Pastel Option Chips (Reference Image 1 Screen 2)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: _availableOptions.map((optLetter) {
              return GestureDetector(
                onTap: () => _onDirectLetterTapped(optLetter),
                child: Container(
                  width: 52,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE), // Pastel Blue
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    optLetter,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0369A1),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏆 "YOU WON!" VICTORY MODAL (REFERENCE IMAGE 1 SCREEN 6)
  // =========================================================================
  Widget _buildKumiVictoryOverlay(PopArtAvatarCardData card) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3 Big Shiny Gold Stars (Center biggest)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStarIcon(size: 42, color: const Color(0xFFFFB703)),
                const SizedBox(width: 8),
                _buildStarIcon(size: 60, color: const Color(0xFFFFB703), isCenter: true),
                const SizedBox(width: 8),
                _buildStarIcon(size: 42, color: const Color(0xFFFFB703)),
              ],
            ),
            const SizedBox(height: 12),

            // "You won!" Header Banner
            Text(
              'You won!',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Day ${widget.day} Spelling Mastered! 🌟',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // PopArt Card Reward Preview Pill
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: card.rarityColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 54,
                    decoration: BoxDecoration(
                      color: card.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(card.badgeEmoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEFENSE CARD UNLOCKED',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0284C7),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          card.title,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3 Reward Pills matching Screen 6 (🎖️ 150, 🟡 230, ❤️ 174)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRewardPill('🎖️', '+30 KS', const Color(0xFF38BDF8)),
                _buildRewardPill('🟡', '+50', const Color(0xFFFBBF24)),
                _buildRewardPill('❤️', '$_hearts', const Color(0xFFF43F5E)),
              ],
            ),
            const SizedBox(height: 22),

            // Two Action Buttons (Replay & Next Level Green Candy Buttons)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showVictory = false;
                        _currentWordIndex = 0;
                        _hearts = 4;
                        _score = 0;
                      });
                      _setupWord();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF84CC16), Color(0xFF65A30D)], // Lime Green Candy
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF65A30D).withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEXT LEVEL',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarIcon({required double size, required Color color, bool isCenter = false}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isCenter)
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(Icons.star_rounded, size: size, color: color),
    );
  }

  Widget _buildRewardPill(String emoji, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
