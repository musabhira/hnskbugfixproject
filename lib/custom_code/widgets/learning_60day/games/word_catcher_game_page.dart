import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'word_catcher_models.dart';

enum GameScreenState {
  intro,
  playing,
  learningMoment,
  finalChallengeIntro,
  finalChallenge,
  levelComplete,
  tryAgain,
}

enum CharacterAnimState {
  idle,
  walkingLeft,
  walkingRight,
  catching,
  happy,
  oops,
}

/// 🌟 Falling Word Orb in the Game Field
class FallingWordItem {
  final WordCatcherItem item;
  final bool isTarget;
  double x; // 0.0 to 1.0 (relative screen width)
  double y; // pixels from top
  final double speed;
  final double wobbleOffset;
  bool isCaught = false;

  FallingWordItem({
    required this.item,
    required this.isTarget,
    required this.x,
    required this.y,
    required this.speed,
    required this.wobbleOffset,
  });
}

/// ✨ Sparkle Particle for Celebrations & Catches
class GameParticle {
  double x;
  double y;
  double vx;
  double vy;
  double alpha;
  Color color;
  double size;

  GameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.alpha,
    required this.color,
    required this.size,
  });
}

/// 🎮 Word Catcher: Reusable 2D Arcade English Learning Game
class WordCatcherGamePage extends StatefulWidget {
  final WordCatcherLevelData levelData;
  final String preferredLanguage;
  final ValueChanged<int>? onCompleted;

  const WordCatcherGamePage({
    super.key,
    this.levelData = kWordCatcherLevel1Data,
    this.preferredLanguage = 'Malayalam',
    this.onCompleted,
  });

  @override
  State<WordCatcherGamePage> createState() => _WordCatcherGamePageState();
}

class _WordCatcherGamePageState extends State<WordCatcherGamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final FlutterTts _tts = FlutterTts();
  final math.Random _random = math.Random();

  // Game Progression State
  GameScreenState _screenState = GameScreenState.intro;
  int _currentWordIndex = 0;
  int _lives = 3;
  int _xpScore = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _finalChallengeStreak = 0;
  WordCatcherItem? _lastCaughtItem;
  WordCatcherItem? _failedTargetItem;
  String? _oopsCaughtWord;

  // Character State
  double _characterNormalizedX = 0.5; // 0.0 (left) to 1.0 (right)
  CharacterAnimState _animState = CharacterAnimState.idle;
  int _walkDir = 0; // -1 = left, 0 = still, 1 = right
  double _characterBobAngle = 0.0;

  // Spawning & Falling Objects
  final List<FallingWordItem> _fallingItems = [];
  final List<GameParticle> _particles = [];
  double _lastSpawnTime = 0.0;
  double _gameTime = 0.0;

  // Audio / Mute
  bool _isMuted = false;
  String _activeLanguage = 'Malayalam';

  @override
  void initState() {
    super.initState();
    _activeLanguage = widget.preferredLanguage;
    _initTts();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);

    _ticker.repeat();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.05);
    } catch (_) {}
  }

  Future<void> _speakText(String text) async {
    if (_isMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tts.stop();
    super.dispose();
  }

  WordCatcherItem get _currentTargetWord {
    if (_screenState == GameScreenState.finalChallenge) {
      final index = (_currentWordIndex + _finalChallengeStreak) %
          widget.levelData.targetWords.length;
      return widget.levelData.targetWords[index];
    }
    return widget.levelData.targetWords[
        _currentWordIndex.clamp(0, widget.levelData.targetWords.length - 1)];
  }

  // --- 🔄 GAME LOOP & PHYSICS ---
  void _gameLoop() {
    if (!mounted) return;
    final dt = 0.016; // approx 60 FPS
    _gameTime += dt;
    _characterBobAngle += dt * 8.0;

    // Update Particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 180.0 * dt; // gravity
      p.alpha -= dt * 1.2;
      if (p.alpha <= 0) {
        _particles.removeAt(i);
      }
    }

    if (_screenState != GameScreenState.playing &&
        _screenState != GameScreenState.finalChallenge) {
      setState(() {});
      return;
    }

    // Handle Smooth Character Walking
    if (_walkDir != 0) {
      final speed = 0.65; // screen width per second
      _characterNormalizedX = (_characterNormalizedX + _walkDir * speed * dt)
          .clamp(0.08, 0.92);
      _animState = _walkDir < 0
          ? CharacterAnimState.walkingLeft
          : CharacterAnimState.walkingRight;
    } else if (_animState == CharacterAnimState.walkingLeft ||
        _animState == CharacterAnimState.walkingRight) {
      _animState = CharacterAnimState.idle;
    }

    // Spawn falling words
    final round = _currentWordIndex;
    final spawnInterval = round < 3
        ? 2.6
        : round < 7
            ? 2.2
            : 1.8;

    if (_gameTime - _lastSpawnTime > spawnInterval) {
      _spawnWave();
      _lastSpawnTime = _gameTime;
    }

    // Update Falling Word Positions
    final size = MediaQuery.of(context).size;
    final catchZoneY = size.height - 150.0;
    final characterScreenX = _characterNormalizedX * size.width;
    final catchRadius = 60.0;

    for (int i = _fallingItems.length - 1; i >= 0; i--) {
      final item = _fallingItems[i];
      item.y += item.speed * dt;

      // Check Collision with Character
      final itemScreenX = item.x * size.width;
      final distY = (item.y - catchZoneY).abs();
      final distX = (itemScreenX - characterScreenX).abs();

      if (distY < 45.0 && distX < catchRadius && !item.isCaught) {
        item.isCaught = true;
        _fallingItems.removeAt(i);
        _handleWordCaught(item);
        break;
      }

      // If fallen past bottom of screen without catch
      if (item.y > size.height - 40.0) {
        _fallingItems.removeAt(i);
      }
    }

    setState(() {});
  }

  void _spawnWave() {
    _fallingItems.clear();
    final target = _currentTargetWord;
    final round = _currentWordIndex;

    // Number of choices: 3 for rounds 1-3, 4 for rounds 4-10
    final numChoices = round < 3 ? 3 : 4;
    final baseSpeed = widget.levelData.baseFallSpeed + (round * 9.0);

    // Pick distractors from all target words except target
    final allWords = List<WordCatcherItem>.from(widget.levelData.targetWords)
      ..removeWhere((w) => w.id == target.id);
    allWords.shuffle(_random);

    final waveItems = <WordCatcherItem>[target];
    for (int i = 0; i < numChoices - 1 && i < allWords.length; i++) {
      waveItems.add(allWords[i]);
    }
    waveItems.shuffle(_random);

    // Lane spacing
    final laneStep = 0.84 / numChoices;
    for (int i = 0; i < waveItems.length; i++) {
      final laneX = 0.08 + (i * laneStep) + (_random.nextDouble() * 0.04);
      final speedJitter = (_random.nextDouble() * 20.0) - 10.0;
      final startY = -40.0 - (_random.nextDouble() * 60.0);

      _fallingItems.add(
        FallingWordItem(
          item: waveItems[i],
          isTarget: waveItems[i].id == target.id,
          x: laneX.clamp(0.08, 0.90),
          y: startY,
          speed: baseSpeed + speedJitter,
          wobbleOffset: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  // --- 🎯 CATCH HANDLER ---
  void _handleWordCaught(FallingWordItem caught) {
    final size = MediaQuery.of(context).size;
    final charX = _characterNormalizedX * size.width;
    final charY = size.height - 150.0;

    if (caught.isTarget) {
      // ✅ SUCCESS!
      HapticFeedback.lightImpact();
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;

      // Scoring + streak bonus
      int gainedXp = 10;
      if (_streak >= 5) {
        gainedXp += 10; // +10 bonus for 5 streak
      } else if (_streak >= 3) {
        gainedXp += 5; // +5 bonus for 3 streak
      }
      _xpScore += gainedXp;

      _animState = CharacterAnimState.catching;
      _spawnSparkles(charX, charY, const Color(0xFFFFD700));

      _lastCaughtItem = caught.item;
      _speakText('${caught.item.word}. ${caught.item.word} means ${caught.item.getNativeMeaning(_activeLanguage)}');

      if (_screenState == GameScreenState.finalChallenge) {
        _finalChallengeStreak++;
        if (_finalChallengeStreak >= widget.levelData.finalChallengeTargetStreak) {
          _triggerLevelComplete();
        } else {
          _fallingItems.clear();
          _lastSpawnTime = _gameTime + 0.8;
        }
      } else {
        // Pause for 1 second Learning Moment
        _screenState = GameScreenState.learningMoment;
        Timer(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          if (_currentWordIndex >= widget.levelData.targetWords.length - 1) {
            // Reached end of 10 words -> start Final Challenge
            setState(() {
              _screenState = GameScreenState.finalChallengeIntro;
            });
          } else {
            setState(() {
              _currentWordIndex++;
              _screenState = GameScreenState.playing;
              _fallingItems.clear();
              _lastSpawnTime = _gameTime + 0.5;
            });
          }
        });
      }
    } else {
      // ❌ WRONG CATCH
      HapticFeedback.heavyImpact();
      _streak = 0;
      _lives--;
      _animState = CharacterAnimState.oops;
      _oopsCaughtWord = caught.item.word;
      _failedTargetItem = _currentTargetWord;
      _spawnSparkles(charX, charY, const Color(0xFFEF4444));

      if (_lives <= 0) {
        setState(() {
          _screenState = GameScreenState.tryAgain;
        });
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Oops! You caught "${caught.item.word}". Target is "${_currentTargetWord.word}".',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _fallingItems.clear();
        _lastSpawnTime = _gameTime + 0.8;
      }
    }
  }

  void _triggerLevelComplete() {
    _screenState = GameScreenState.levelComplete;
    HapticFeedback.heavyImpact();
    _speakText('Congratulations! Level one complete! You learned ten new English words!');
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 40; i++) {
      _spawnSparkles(
        size.width * 0.5 + (_random.nextDouble() * 200 - 100),
        size.height * 0.35 + (_random.nextDouble() * 100 - 50),
        Colors.primaries[_random.nextInt(Colors.primaries.length)],
      );
    }
  }

  void _spawnSparkles(double x, double y, Color color) {
    for (int i = 0; i < 16; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 80.0 + _random.nextDouble() * 160.0;
      _particles.add(
        GameParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 60.0,
          alpha: 1.0,
          color: color,
          size: 4.0 + _random.nextDouble() * 6.0,
        ),
      );
    }
  }

  // --- 🎨 BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue
      body: Stack(
        children: [
          // 1. Layer: 2D Park Environment & Landscape
          Positioned.fill(
            child: CustomPaint(
              painter: _ParkEnvironmentPainter(
                time: _gameTime,
                cloudsOffset: _gameTime * 15.0,
              ),
            ),
          ),

          // 2. Layer: Falling Word Orbs
          if (_screenState == GameScreenState.playing ||
              _screenState == GameScreenState.finalChallenge)
            ..._fallingItems.map((item) => _buildFallingWordBubble(item)),

          // 3. Layer: 2D Animated Player Character
          _buildCharacterWidget(),

          // 4. Layer: Particles & Sparkles
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(particles: _particles),
              ),
            ),
          ),

          // 5. Layer: Top HUD (Banner, Progress, Hearts, Streak, XP)
          _buildTopHud(),

          // 6. Layer: Bottom Touch Controls
          if (_screenState == GameScreenState.playing ||
              _screenState == GameScreenState.finalChallenge)
            _buildBottomControls(),

          // 7. Layer: Interactive Overlays
          if (_screenState == GameScreenState.intro)
            _buildIntroOverlay(),

          if (_screenState == GameScreenState.learningMoment &&
              _lastCaughtItem != null)
            _buildLearningMomentOverlay(),

          if (_screenState == GameScreenState.finalChallengeIntro)
            _buildFinalChallengeIntroOverlay(),

          if (_screenState == GameScreenState.tryAgain)
            _buildTryAgainOverlay(),

          if (_screenState == GameScreenState.levelComplete)
            _buildLevelCompleteOverlay(),
        ],
      ),
    );
  }

  // --- 🎈 FALLING WORD BUBBLE ---
  Widget _buildFallingWordBubble(FallingWordItem item) {
    final size = MediaQuery.of(context).size;
    final posX = item.x * size.width - 65.0;
    final isTarget = item.isTarget;

    return Positioned(
      left: posX,
      top: item.y,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isTarget
                ? const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]
                : const [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isTarget ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTarget ? const Color(0xFFF59E0B) : Colors.black)
                  .withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.item.emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 2),
            Text(
              item.item.word.toUpperCase(),
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 🧒 2D ANIMATED CHARACTER ---
  Widget _buildCharacterWidget() {
    final size = MediaQuery.of(context).size;
    final posX = _characterNormalizedX * size.width - 45.0;
    final posY = size.height - 170.0;

    return Positioned(
      left: posX,
      top: posY,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _characterNormalizedX = (_characterNormalizedX +
                    details.delta.dx / size.width)
                .clamp(0.08, 0.92);
          });
        },
        child: SizedBox(
          width: 90,
          height: 110,
          child: CustomPaint(
            painter: _CharacterPainter(
              animState: _animState,
              bobAngle: _characterBobAngle,
            ),
          ),
        ),
      ),
    );
  }

  // --- 🏆 TOP HUD DECK ---
  Widget _buildTopHud() {
    final target = _currentTargetWord;
    final totalWords = widget.levelData.targetWords.length;
    final currentProgress = (_currentWordIndex + 1).clamp(1, totalWords);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Back Button, Lives, Streak, XP, Sound
            Row(
              children: [
                // Back / Close
                InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF1E293B), size: 20),
                  ),
                ),
                const SizedBox(width: 8),

                // ❤️ Lives
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final hasHeart = index < _lives;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          hasHeart ? '❤️' : '🤍',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // 🔥 Streak Counter
                if (_streak > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$_streak STREAK',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(width: 8),

                // ⭐ XP Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    '+$_xpScore XP',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 🔊 Mute Toggle
                InkWell(
                  onTap: () {
                    setState(() => _isMuted = !_isMuted);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: const Color(0xFF1E293B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2: Target Word Banner
            if (_screenState == GameScreenState.playing ||
                _screenState == GameScreenState.finalChallenge)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      target.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _screenState == GameScreenState.finalChallenge
                                ? 'FINAL CHALLENGE (${_finalChallengeStreak + 1}/${widget.levelData.finalChallengeTargetStreak})'
                                : 'CATCH THE TARGET WORD:',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                target.word.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                target.phonetics,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Audio Pronounce Button
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFFFFD700), size: 24),
                      onPressed: () => _speakText(target.word),
                      tooltip: 'Pronounce',
                    ),
                  ],
                ),
              ),

            // Row 3: Progress Dots
            if (_screenState == GameScreenState.playing) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalWords, (index) {
                  final isDone = index < _currentWordIndex;
                  final isCurrent = index == _currentWordIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: isCurrent ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF10B981)
                          : isCurrent
                              ? const Color(0xFFFFD700)
                              : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentProgress of $totalWords Words Learned',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 🕹️ BOTTOM CONTROLS ---
  Widget _buildBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ◀ LEFT BUTTON
              Listener(
                onPointerDown: (_) => setState(() => _walkDir = -1),
                onPointerUp: (_) => setState(() => _walkDir = 0),
                onPointerCancel: (_) => setState(() => _walkDir = 0),
                child: Container(
                  width: 90,
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
              ),

              // Drag Hint in center
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '◀ CATCH WORDS ▶',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // RIGHT ▶ BUTTON
              Listener(
                onPointerDown: (_) => setState(() => _walkDir = 1),
                onPointerUp: (_) => setState(() => _walkDir = 0),
                onPointerCancel: (_) => setState(() => _walkDir = 0),
                child: Container(
                  width: 90,
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 📖 SCREEN 1: LEVEL INTRO OVERLAY ---
  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.levelData.title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    widget.levelData.subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Friendly Guide Bubble
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '"${widget.levelData.guideIntro}"',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF38BDF8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Example Words Preview Cards
                  Text(
                    'Preview Words:',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.levelData.introExamples.map((item) {
                      return InkWell(
                        onTap: () => _speakText(item.word),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 85,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white24, width: 1.2),
                          ),
                          child: Column(
                            children: [
                              Text(item.emoji,
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 4),
                              Text(
                                item.word,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                item.phonetics,
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Big Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _screenState = GameScreenState.playing;
                          _currentWordIndex = 0;
                          _lives = 3;
                          _streak = 0;
                          _xpScore = 0;
                          _fallingItems.clear();
                          _lastSpawnTime = _gameTime;
                        });
                        _speakText('Catch: ${_currentTargetWord.word}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'START GAME 🎮',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 💡 SCREEN 2: 1-SECOND LEARNING MOMENT OVERLAY ---
  Widget _buildLearningMomentOverlay() {
    final item = _lastCaughtItem!;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF10B981), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 28),
                const SizedBox(width: 8),
                Text(
                  'GREAT CATCH! +10 XP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 6),
            Text(
              '${item.word} = ${item.emoji}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              item.phonetics,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_activeLanguage: ${item.getNativeMeaning(_activeLanguage)}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🏆 FINAL CHALLENGE INTRO ---
  Widget _buildFinalChallengeIntroOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                'FINAL CHALLENGE!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You learned all 10 words!\nCatch 5 target words consecutively to finish Level 1!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _screenState = GameScreenState.finalChallenge;
                      _finalChallengeStreak = 0;
                      _fallingItems.clear();
                      _lastSpawnTime = _gameTime;
                    });
                    _speakText('Final challenge! Catch ${_currentTargetWord.word}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'START FINAL CHALLENGE 🚀',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
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

  // --- 💔 TRY AGAIN MODAL ---
  Widget _buildTryAgainOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEF4444), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                'TRY AGAIN!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFEF4444),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Don\'t worry, you keep all your learned words!\nTake a breath and try again.',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _lives = 3;
                      _streak = 0;
                      _screenState = GameScreenState.playing;
                      _fallingItems.clear();
                      _lastSpawnTime = _gameTime;
                    });
                    _speakText('Catch: ${_currentTargetWord.word}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'REFILL HEARTS & CONTINUE ❤️',
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

  // --- 🎉 SCREEN 5: LEVEL COMPLETE & REVIEW MODE ---
  Widget _buildLevelCompleteOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    'LEVEL 1 COMPLETE!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'You learned 10 new English words!',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBox('⭐ XP EARNED', '+$_xpScore', const Color(0xFF10B981)),
                      _buildStatBox('🔥 BEST STREAK', '$_bestStreak', const Color(0xFFF97316)),
                      _buildStatBox('📚 WORDS', '10/10', const Color(0xFF38BDF8)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Review Mode Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tap any word to listen & review:',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 10 Words Review Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.levelData.targetWords.map((item) {
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _speakText('${item.word}. ${item.getNativeMeaning(_activeLanguage)}');
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                item.word,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.volume_up_rounded,
                                  color: Color(0xFFFFD700), size: 14),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Big Finish / Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        widget.onCompleted?.call(_xpScore);
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'COMPLETE & CLAIM STEP 4 ✓',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 🎨 2D PARK ENVIRONMENT PAINTER ---
class _ParkEnvironmentPainter extends CustomPainter {
  final double time;
  final double cloudsOffset;

  _ParkEnvironmentPainter({
    required this.time,
    required this.cloudsOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Warm Sun with Sunbeams
    final sunCenter = Offset(size.width * 0.82, 80);
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(sunCenter, 42, sunGlowPaint);

    final sunPaint = Paint()..color = const Color(0xFFFACC15);
    canvas.drawCircle(sunCenter, 28, sunPaint);

    // 3. Drifting Puffy Clouds
    _drawCloud(canvas, (size.width * 0.2 + cloudsOffset) % (size.width + 120) - 60, 60, 30);
    _drawCloud(canvas, (size.width * 0.65 + cloudsOffset * 0.7) % (size.width + 120) - 60, 110, 24);

    // 4. Distant Rolling Green Hills
    final hillPaintFar = Paint()..color = const Color(0xFF86EFAC);
    final hillPathFar = Path()
      ..moveTo(0, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.62,
          size.width * 0.6, size.height * 0.69)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.74, size.width,
          size.height * 0.66)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPathFar, hillPaintFar);

    // 5. Near Rolling Hills with Cottages
    final hillPaintNear = Paint()..color = const Color(0xFF4ADE80);
    final hillPathNear = Path()
      ..moveTo(0, size.height * 0.74)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.70,
          size.width * 0.7, size.height * 0.76)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.79, size.width,
          size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPathNear, hillPaintNear);

    // Small village cottages in background
    _drawCottage(canvas, size.width * 0.18, size.height * 0.66);
    _drawCottage(canvas, size.width * 0.72, size.height * 0.71);

    // Background trees
    _drawTree(canvas, size.width * 0.08, size.height * 0.68, 38);
    _drawTree(canvas, size.width * 0.35, size.height * 0.65, 34);
    _drawTree(canvas, size.width * 0.88, size.height * 0.70, 42);

    // 6. Walking Path & Foreground Grass
    final groundPaint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 100, size.width, 100),
      groundPaint,
    );

    // Stone pathway
    final pathPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - 80, size.width, 42),
        const Radius.circular(8),
      ),
      pathPaint,
    );

    // Little flowers on grass
    final flowerPaint = Paint()..color = const Color(0xFFF43F5E);
    for (int i = 0; i < 7; i++) {
      final fx = (size.width * 0.12) + (i * size.width * 0.13);
      final fy = size.height - 90.0 + (i % 2 == 0 ? 3 : -3);
      canvas.drawCircle(Offset(fx, fy), 4, flowerPaint);
      canvas.drawCircle(Offset(fx, fy), 1.5, Paint()..color = Colors.yellow);
    }
  }

  void _drawCloud(Canvas canvas, double x, double y, double radius) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    canvas.drawCircle(Offset(x, y), radius, cloudPaint);
    canvas.drawCircle(Offset(x + radius * 0.8, y - radius * 0.2),
        radius * 0.75, cloudPaint);
    canvas.drawCircle(Offset(x - radius * 0.7, y + radius * 0.1),
        radius * 0.65, cloudPaint);
    canvas.drawCircle(Offset(x + radius * 1.5, y + radius * 0.1),
        radius * 0.6, cloudPaint);
  }

  void _drawTree(Canvas canvas, double x, double y, double height) {
    final trunkPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(x - 3, y - height * 0.4, 6, height * 0.4), trunkPaint);

    final foliagePaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(Offset(x, y - height * 0.55), height * 0.35, foliagePaint);
    canvas.drawCircle(Offset(x - 6, y - height * 0.45), height * 0.25, foliagePaint);
    canvas.drawCircle(Offset(x + 6, y - height * 0.45), height * 0.25, foliagePaint);
  }

  void _drawCottage(Canvas canvas, double x, double y) {
    // Walls
    final wallPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawRect(Rect.fromLTWH(x - 14, y - 18, 28, 18), wallPaint);

    // Roof
    final roofPaint = Paint()..color = const Color(0xFFDC2626);
    final roofPath = Path()
      ..moveTo(x - 18, y - 18)
      ..lineTo(x, y - 30)
      ..lineTo(x + 18, y - 18)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Door & Window
    canvas.drawRect(Rect.fromLTWH(x - 4, y - 10, 8, 10), Paint()..color = const Color(0xFF92400E));
    canvas.drawRect(Rect.fromLTWH(x + 6, y - 14, 5, 5), Paint()..color = const Color(0xFF38BDF8));
  }

  @override
  bool shouldRepaint(covariant _ParkEnvironmentPainter oldDelegate) => true;
}

// --- 🧒 2D CHARACTER VECTOR PAINTER ---
class _CharacterPainter extends CustomPainter {
  final CharacterAnimState animState;
  final double bobAngle;

  _CharacterPainter({
    required this.animState,
    required this.bobAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.55;

    // Bobbing offset
    final bobY = math.sin(bobAngle) * 3.0;

    // 1. Shadow under feet
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height - 12),
        width: 48,
        height: 12,
      ),
      shadowPaint,
    );

    // 2. Animated Legs
    final legPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final legSwing = (animState == CharacterAnimState.walkingLeft ||
            animState == CharacterAnimState.walkingRight)
        ? math.sin(bobAngle * 1.6) * 10.0
        : 0.0;

    // Left leg
    canvas.drawLine(
      Offset(cx - 8, cy + 18 + bobY),
      Offset(cx - 8 - legSwing, size.height - 16),
      legPaint,
    );
    // Right leg
    canvas.drawLine(
      Offset(cx + 8, cy + 18 + bobY),
      Offset(cx + 8 + legSwing, size.height - 16),
      legPaint,
    );

    // Shoes
    final shoePaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 14 - legSwing, size.height - 18, 12, 6),
        const Radius.circular(3),
      ),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 2 + legSwing, size.height - 18, 12, 6),
        const Radius.circular(3),
      ),
      shoePaint,
    );

    // 3. Body / Hoodie
    final bodyPaint = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + 4 + bobY),
          width: 32,
          height: 32,
        ),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    // 4. Arms (Catch vs Walking vs Idle)
    final armPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    if (animState == CharacterAnimState.catching ||
        animState == CharacterAnimState.happy) {
      // Arms raised high to catch or celebrate!
      canvas.drawLine(
          Offset(cx - 14, cy + bobY), Offset(cx - 24, cy - 24 + bobY), armPaint);
      canvas.drawLine(
          Offset(cx + 14, cy + bobY), Offset(cx + 24, cy - 24 + bobY), armPaint);
    } else {
      // Arms down / swinging
      canvas.drawLine(Offset(cx - 14, cy + 2 + bobY),
          Offset(cx - 18 + legSwing * 0.5, cy + 16 + bobY), armPaint);
      canvas.drawLine(Offset(cx + 14, cy + 2 + bobY),
          Offset(cx + 18 - legSwing * 0.5, cy + 16 + bobY), armPaint);
    }

    // 5. Head
    final skinPaint = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(Offset(cx, cy - 18 + bobY), 16, skinPaint);

    // 6. Cute Baseball Cap
    final capPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy - 22 + bobY),
        width: 34,
        height: 22,
      ),
      math.pi,
      math.pi,
      true,
      capPaint,
    );
    // Cap visor
    final visorPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 6, cy - 24 + bobY, 22, 5),
        const Radius.circular(2.5),
      ),
      visorPaint,
    );

    // 7. Face (Eyes & Mouth)
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    if (animState == CharacterAnimState.oops) {
      // Squinting eyes on error >_<
      canvas.drawLine(Offset(cx - 8, cy - 20 + bobY),
          Offset(cx - 4, cy - 18 + bobY), eyePaint..strokeWidth = 2);
      canvas.drawLine(Offset(cx - 8, cy - 16 + bobY),
          Offset(cx - 4, cy - 18 + bobY), eyePaint);
      canvas.drawLine(Offset(cx + 4, cy - 18 + bobY),
          Offset(cx + 8, cy - 20 + bobY), eyePaint);
      canvas.drawLine(Offset(cx + 4, cy - 18 + bobY),
          Offset(cx + 8, cy - 16 + bobY), eyePaint);

      // Sweatdrop
      final sweatPaint = Paint()..color = const Color(0xFF38BDF8);
      canvas.drawCircle(Offset(cx + 16, cy - 24 + bobY), 3, sweatPaint);
    } else {
      // Big happy smiling eyes
      canvas.drawCircle(Offset(cx - 5, cy - 18 + bobY), 2.5, eyePaint);
      canvas.drawCircle(Offset(cx + 5, cy - 18 + bobY), 2.5, eyePaint);

      // Catch / happy smile
      final mouthPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy - 12 + bobY),
          width: 8,
          height: 6,
        ),
        0,
        math.pi,
        false,
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) => true;
}

// --- ✨ PARTICLE PAINTER ---
class _ParticlePainter extends CustomPainter {
  final List<GameParticle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
