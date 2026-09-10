import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adventure_models.dart';
import 'memory_break_in_models.dart';

enum MemoryGameState {
  intro,
  memorize, // 60s observation phase
  hideTransition,
  challenge, // Active memory challenges
  complete,
}

/// 🧠 Level 3: Memory Break-In 2D Mobile Game Screen
class MemoryBreakInGamePage extends StatefulWidget {
  final AdventureLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const MemoryBreakInGamePage({
    super.key,
    this.levelData = kMission03MemoryData,
    this.onCompleted,
  });

  @override
  State<MemoryBreakInGamePage> createState() => _MemoryBreakInGamePageState();
}

class _MemoryBreakInGamePageState extends State<MemoryBreakInGamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final FlutterTts _tts = FlutterTts();

  // World dimensions
  final double _worldWidth = 1050.0;
  final double _worldHeight = 540.0;
  double _cameraX = 0.0;

  // Player State
  double _playerX = 140.0;
  double _playerY = 320.0;
  PlayerFacing _playerFacing = PlayerFacing.right;
  PlayerAnimationState _playerAnim = PlayerAnimationState.idle;
  double _playerWalkCycle = 0.0;
  Offset? _targetWaypoint;

  // Virtual Joystick
  double _joystickDx = 0.0;
  double _joystickDy = 0.0;
  bool _isJoystickActive = false;

  // Game Flow State
  MemoryGameState _gameState = MemoryGameState.intro;

  // 60-Second Memorize Phase Timer
  Timer? _memorizeTimer;
  int _memorizeSecondsRemaining = 60;

  // Progression & Score
  int _currentChallengeIndex = 0;
  int _lives = 3;
  int _scoreXp = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;

  // Active Challenge Modal State
  bool _isChallengeModalOpen = false;
  AdventureChallenge? _activeChallenge;
  int? _selectedOptionIndex;
  bool _hasAnsweredCurrent = false;

  // Draggable / Tap Tile States (Spelling & Sentence Rebuild)
  List<String> _builtTiles = [];
  List<String> _availableTiles = [];

  // Fast Memory Countdown (Challenge 8: 8 seconds)
  Timer? _fastMemoryTimer;
  int _fastMemorySecondsRemaining = 8;
  bool _isFastMemoryActive = false;

  // Audio Mute
  final bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);
    _ticker.repeat();

    // Opening briefing after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startObservationPhase();
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.44);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    if (_isMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker.dispose();
    _memorizeTimer?.cancel();
    _fastMemoryTimer?.cancel();
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  // --- MEMORY FLOW ---
  void _startObservationPhase() {
    setState(() {
      _gameState = MemoryGameState.memorize;
      _memorizeSecondsRemaining = 60;
    });

    _speak(
      'You have 60 seconds to inspect the room. Walk around and memorize every object, label, and location.',
    );

    _memorizeTimer?.cancel();
    _memorizeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_memorizeSecondsRemaining > 0) {
          _memorizeSecondsRemaining--;
        } else {
          timer.cancel();
          _transitionToTestPhase();
        }
      });
    });
  }

  void _transitionToTestPhase() {
    _memorizeTimer?.cancel();
    HapticFeedback.heavyImpact();

    setState(() {
      _gameState = MemoryGameState.hideTransition;
    });

    _speak('Observation complete. All labels hidden. Memory test commencing.');

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _gameState = MemoryGameState.challenge;
          _openChallenge(0);
        });
      }
    });
  }

  // --- GAME LOOP & PHYSICS ---
  void _gameLoop() {
    if (!mounted || _gameState == MemoryGameState.complete) return;

    double vx = 0.0;
    double vy = 0.0;
    const double speed = 3.6;

    if (_isJoystickActive) {
      vx = _joystickDx * speed;
      vy = _joystickDy * speed;
    } else if (_targetWaypoint != null) {
      final dx = _targetWaypoint!.dx - _playerX;
      final dy = _targetWaypoint!.dy - _playerY;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 4.0) {
        _targetWaypoint = null;
      } else {
        vx = (dx / dist) * speed;
        vy = (dy / dist) * speed;
      }
    }

    if (vx != 0.0 || vy != 0.0) {
      _playerWalkCycle += 0.22;
      _playerAnim = PlayerAnimationState.walking;

      if (vx.abs() > vy.abs()) {
        _playerFacing = vx > 0 ? PlayerFacing.right : PlayerFacing.left;
      } else {
        _playerFacing = vy > 0 ? PlayerFacing.down : PlayerFacing.up;
      }

      final newX = (_playerX + vx).clamp(40.0, _worldWidth - 40.0);
      final newY = (_playerY + vy).clamp(110.0, _worldHeight - 40.0);

      _playerX = newX;
      _playerY = newY;
    } else if (!_isChallengeModalOpen) {
      _playerAnim = PlayerAnimationState.idle;
    }

    // Camera follow
    final screenWidth = MediaQuery.of(context).size.width;
    final targetCameraX = (_playerX - screenWidth / 2)
        .clamp(0.0, math.max(0.0, _worldWidth - screenWidth));
    _cameraX += (targetCameraX - _cameraX) * 0.12;

    setState(() {});
  }

  // --- PROXIMITY INSPECTION (DURING MEMORIZE PHASE) ---
  MemoryObjectData? _getNearbyObject() {
    for (final obj in kRoomMemoryObjects) {
      final dist = math.sqrt(
        math.pow(_playerX - obj.position.dx, 2) +
            math.pow(_playerY - obj.position.dy, 2),
      );
      if (dist < 75.0) return obj;
    }
    return null;
  }

  void _inspectNearbyObject(MemoryObjectData obj) {
    HapticFeedback.selectionClick();
    _speak(obj.audioPrompt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(obj.icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('${obj.word}: ${obj.zone}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- CHALLENGE MODAL SYSTEM ---
  void _openChallenge(int index) {
    if (index >= widget.levelData.challenges.length) {
      setState(() {
        _gameState = MemoryGameState.complete;
        _isChallengeModalOpen = false;
        _scoreXp += 50; // Master certification bonus
      });
      widget.onCompleted?.call(_scoreXp);
      _speak('Mission Complete! You passed the Memory Break-In inspection.');
      return;
    }

    final challenge = widget.levelData.challenges[index];
    HapticFeedback.lightImpact();

    setState(() {
      _currentChallengeIndex = index;
      _activeChallenge = challenge;
      _isChallengeModalOpen = true;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;

      // Handle tile challenges (Spelling or Sentence Rebuild)
      if (challenge.sentenceTiles != null) {
        _builtTiles = [];
        _availableTiles = List.from(challenge.sentenceTiles!)..shuffle();
      }

      // Handle 8s countdown for Challenge 8
      if (challenge.timeLimitSeconds != null && challenge.timeLimitSeconds! > 0) {
        _startFastMemoryTimer(challenge.timeLimitSeconds!);
      }
    });

    _speak(challenge.audioPrompt ?? challenge.npcDialogue);
  }

  void _startFastMemoryTimer(int seconds) {
    _fastMemoryTimer?.cancel();
    _fastMemorySecondsRemaining = seconds;
    _isFastMemoryActive = true;

    _fastMemoryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_fastMemorySecondsRemaining > 0) {
          _fastMemorySecondsRemaining--;
        } else {
          t.cancel();
          _isFastMemoryActive = false;
          if (!_hasAnsweredCurrent) {
            _onOptionSelected(1); // Incorrect on timeout
          }
        }
      });
    });
  }

  void _onOptionSelected(int index) {
    if (_hasAnsweredCurrent || _activeChallenge == null) return;
    final opt = _activeChallenge!.options[index];

    _fastMemoryTimer?.cancel();
    _isFastMemoryActive = false;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnsweredCurrent = true;
      _totalAttempts++;

      if (opt.isCorrect) {
        _correctCount++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;

        int earned = _activeChallenge!.xpReward;
        if (_combo >= 3) earned += 10; // Streak bonus
        _scoreXp += earned;
        HapticFeedback.heavyImpact();
      } else {
        _combo = 0;
        _lives = math.max(0, _lives - 1);
        HapticFeedback.vibrate();
      }
    });

    if (opt.reaction != null) {
      _speak(opt.reaction!);
    }
  }

  void _advanceToNextChallenge() {
    setState(() {
      _isChallengeModalOpen = false;
      _activeChallenge = null;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
    });

    _openChallenge(_currentChallengeIndex + 1);
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    final nearbyObj = _getNearbyObject();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Stack(
          children: [
            // 2D Room Canvas World
            GestureDetector(
              onTapDown: (details) {
                if (_isChallengeModalOpen) return;
                final touchWorldX = details.localPosition.dx + _cameraX;
                final touchWorldY = details.localPosition.dy;
                setState(() {
                  _targetWaypoint = Offset(touchWorldX, touchWorldY);
                });
              },
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, _worldHeight),
                painter: _RoomWorldPainter(
                  cameraX: _cameraX,
                  playerX: _playerX,
                  playerY: _playerY,
                  playerFacing: _playerFacing,
                  playerAnim: _playerAnim,
                  walkCycle: _playerWalkCycle,
                  targetWaypoint: _targetWaypoint,
                  objects: kRoomMemoryObjects,
                  zones: kRoomZones,
                  showLabels: _gameState == MemoryGameState.memorize,
                ),
              ),
            ),

            // Top Status HUD (Observation Countdown or Test Progress)
            _buildTopStatusHud(),

            // Inspect Nearby Object Action (During Memorize Phase)
            if (_gameState == MemoryGameState.memorize && nearbyObj != null && !_isChallengeModalOpen)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _inspectNearbyObject(nearbyObj),
                    icon: Icon(nearbyObj.icon, color: Colors.black, size: 18),
                    label: Text(
                      'INSPECT ${nearbyObj.label}',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 6,
                    ),
                  ),
                ),
              ),

            // Virtual Joystick (Bottom Left)
            if (!_isChallengeModalOpen && _gameState != MemoryGameState.complete)
              Positioned(
                left: 20,
                bottom: 24,
                child: _buildVirtualJoystick(),
              ),

            // Transition Overlay
            if (_gameState == MemoryGameState.hideTransition)
              _buildTransitionBanner(),

            // Active Challenge Modal Dialog
            if (_isChallengeModalOpen && _activeChallenge != null)
              _buildChallengeOverlay(),

            // Mission Finished Summary Modal
            if (_gameState == MemoryGameState.complete)
              _buildMissionCompleteModal(),
          ],
        ),
      ),
    );
  }

  // --- TOP STATUS HUD ---
  Widget _buildTopStatusHud() {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mission info
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Memory Break-In',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          _gameState == MemoryGameState.memorize
                              ? 'Observation (${_memorizeSecondsRemaining}s)'
                              : 'Challenge ${_currentChallengeIndex + 1}/10',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Observation Countdown bar / Ready button
          if (_gameState == MemoryGameState.memorize)
            ElevatedButton.icon(
              onPressed: _transitionToTestPhase,
              icon: const Icon(Icons.timer_rounded, size: 16, color: Colors.black),
              label: Text(
                'TEST NOW (${_memorizeSecondsRemaining}s) ➔',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else
            // XP & Lives
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_scoreXp XP',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Icon(
                        Icons.favorite_rounded,
                        color: i < _lives ? const Color(0xFFEF4444) : Colors.white24,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- TRANSITION BANNER ---
  Widget _buildTransitionBanner() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_off_rounded, color: Color(0xFF38BDF8), size: 48),
              const SizedBox(height: 12),
              Text(
                'LABELS HIDDEN!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Recall everything from memory to complete the test.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- VIRTUAL JOYSTICK ---
  Widget _buildVirtualJoystick() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.65),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          _isJoystickActive = true;
          _updateJoystick(details.localPosition, 50.0);
        },
        onPanUpdate: (details) {
          _updateJoystick(details.localPosition, 50.0);
        },
        onPanEnd: (_) {
          setState(() {
            _isJoystickActive = false;
            _joystickDx = 0.0;
            _joystickDy = 0.0;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(_joystickDx * 28.0, _joystickDy * 28.0),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateJoystick(Offset localPos, double radius) {
    final dx = localPos.dx - radius;
    final dy = localPos.dy - radius;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance == 0) {
      _joystickDx = 0;
      _joystickDy = 0;
    } else {
      final clampedDist = math.min(distance, radius);
      _joystickDx = (dx / distance) * (clampedDist / radius);
      _joystickDy = (dy / distance) * (clampedDist / radius);
    }
  }

  // --- CHALLENGE OVERLAY MODAL ---
  Widget _buildChallengeOverlay() {
    final challenge = _activeChallenge!;
    final isTileArranger = challenge.sentenceTiles != null;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            challenge.title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (_combo >= 2)
                          Text(
                            '🔥 STREAK x$_combo',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFF7043),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        if (_isFastMemoryActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_rounded, color: Color(0xFFEF4444), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${_fastMemorySecondsRemaining}s',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFEF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dialogue / Audio prompt
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology_rounded, color: Color(0xFF38BDF8), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              challenge.npcDialogue,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 20),
                            onPressed: () {
                              _speak(challenge.audioPrompt ?? challenge.npcDialogue);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Question
                    Text(
                      challenge.question,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Interactive Tile Section (Spelling / Sentence Rebuild)
                    if (isTileArranger) ...[
                      _buildTileArrangerSection(),
                      const SizedBox(height: 12),
                    ] else ...[
                      // Multiple Choice Options
                      ...List.generate(challenge.options.length, (i) {
                        final opt = challenge.options[i];
                        final isSelected = _selectedOptionIndex == i;
                        Color btnBg = const Color(0xFF1E293B);
                        Color borderColor = Colors.white12;

                        if (_hasAnsweredCurrent) {
                          if (opt.isCorrect) {
                            btnBg = const Color(0xFF065F46);
                            borderColor = const Color(0xFF10B981);
                          } else if (isSelected) {
                            btnBg = const Color(0xFF7F1D1D);
                            borderColor = const Color(0xFFEF4444);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () => _onOptionSelected(i),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: btnBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                opt.text,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],

                    // Feedback & Continue Button
                    if (_hasAnsweredCurrent) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (_activeChallenge!.options[_selectedOptionIndex ?? 0].isCorrect)
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _activeChallenge!.options[_selectedOptionIndex ?? 0].feedback,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _advanceToNextChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'NEXT CHALLENGE ➔',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TILE ARRANGER (SPELLING & SENTENCE REBUILD) ---
  Widget _buildTileArrangerSection() {
    final challenge = _activeChallenge!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assembled Tiles Tray
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR SEQUENCE:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _builtTiles.isEmpty
                    ? [
                        Text(
                          'Tap tiles below to build the answer...',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                        ),
                      ]
                    : _builtTiles
                        .map(
                          (t) => Chip(
                            label: Text(
                              t,
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            backgroundColor: const Color(0xFF38BDF8),
                            deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Colors.black),
                            onDeleted: () {
                              setState(() {
                                _builtTiles.remove(t);
                                _availableTiles.add(t);
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Available Tiles
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableTiles
              .map(
                (tile) => ActionChip(
                  label: Text(
                    tile,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Colors.white24),
                  onPressed: () {
                    setState(() {
                      _availableTiles.remove(tile);
                      _builtTiles.add(tile);
                    });

                    // Check if complete
                    if (_builtTiles.length == challenge.sentenceTiles!.length) {
                      final builtStr = _builtTiles.join(' ');
                      final isMatch = builtStr == challenge.targetSentence;
                      _onOptionSelected(isMatch ? 0 : 1);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // --- MISSION COMPLETE MODAL ---
  Widget _buildMissionCompleteModal() {
    final memoryAccuracy = ((_correctCount / math.max(1, _totalAttempts)) * 100).toInt();
    final vocabScore = math.min(100, 84 + (_combo * 3));
    final spellingScore = math.min(100, 88 + (_lives * 3));
    final listeningScore = math.min(100, 80 + (_correctCount * 2));

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF10B981), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 6),
                    Text(
                      'MISSION 03 COMPLETE!',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Memory Break-In Certification Achieved',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 30),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Performance Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox('Memory', '$memoryAccuracy%'),
                        _buildStatBox('Vocabulary', '$vocabScore%'),
                        _buildStatBox('Spelling', '$spellingScore%'),
                        _buildStatBox('Listening', '$listeningScore%'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Vocabulary Bank (15 Words)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VOCABULARY LEARNED (15 WORDS)',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: kMemoryTargetVocabulary
                                .map(
                                  (w) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      w,
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Return Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                        ),
                        child: Text(
                          'CLAIM CERTIFICATE & UNLOCK LEVEL 4 ✓',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.white54, fontSize: 9)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2D WORKSPACE ROOM CUSTOM PAINTER ---
class _RoomWorldPainter extends CustomPainter {
  final double cameraX;
  final double playerX;
  final double playerY;
  final PlayerFacing playerFacing;
  final PlayerAnimationState playerAnim;
  final double walkCycle;
  final Offset? targetWaypoint;
  final List<MemoryObjectData> objects;
  final List<RoomAreaZone> zones;
  final bool showLabels;

  _RoomWorldPainter({
    required this.cameraX,
    required this.playerX,
    required this.playerY,
    required this.playerFacing,
    required this.playerAnim,
    required this.walkCycle,
    required this.targetWaypoint,
    required this.objects,
    required this.zones,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Hardwood Floor Terrain
    final floorPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1050, 540), floorPaint);

    // Floorboard lines
    final plankPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.5;
    for (double y = 40; y < 540; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(1050, y), plankPaint);
    }

    // 2. Room Architectural Zones
    for (final zone in zones) {
      final zonePaint = Paint()..color = zone.color.withValues(alpha: 0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(zone.bounds, const Radius.circular(12)),
        zonePaint,
      );

      final borderPaint = Paint()
        ..color = Colors.white12
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(zone.bounds, const Radius.circular(12)),
        borderPaint,
      );

      // Zone name badge
      final tp = TextPainter(
        text: TextSpan(
          text: zone.name.toUpperCase(),
          style: const TextStyle(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(zone.bounds.left + 8, zone.bounds.top + 6));
    }

    // 3. Furniture Drawings
    // Executive Workstation Desk (rect at 270, 190)
    final deskPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(280, 200, 180, 100), const Radius.circular(8)),
      deskPaint,
    );

    // Sofa Lounge (rect at 600, 280)
    final sofaPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(590, 280, 140, 90), const Radius.circular(14)),
      sofaPaint,
    );

    // Bookshelf (rect at 690, 130)
    final shelfPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(690, 130, 120, 70), const Radius.circular(6)),
      shelfPaint,
    );

    // 4. Memory Objects & Labels
    for (final obj in objects) {
      // Glow circle
      final glowPaint = Paint()
        ..color = obj.color.withValues(alpha: showLabels ? 0.35 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(obj.position, 14, glowPaint);

      // Object Icon representation
      final iconPaint = Paint()..color = obj.color;
      canvas.drawCircle(obj.position, 9, iconPaint);

      // Floating English Label Badge (Visible during memorization)
      if (showLabels) {
        final badgeRect = Rect.fromLTWH(
          obj.position.dx - 30,
          obj.position.dy - 26,
          60,
          14,
        );
        final badgePaint = Paint()..color = const Color(0xFF0284C7);
        canvas.drawRRect(
          RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
          badgePaint,
        );

        final labelTp = TextPainter(
          text: TextSpan(
            text: obj.label,
            style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w900),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        labelTp.paint(
          canvas,
          Offset(
            badgeRect.left + (badgeRect.width - labelTp.width) / 2,
            badgeRect.top + (badgeRect.height - labelTp.height) / 2,
          ),
        );
      }
    }

    // 5. Host NPC (Specialist Vance)
    final npcPos = Offset(kLevel3Npc.worldX, kLevel3Npc.worldY);
    final auraPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.15);
    canvas.drawCircle(npcPos, 26, auraPaint);

    final npcTp = TextPainter(
      text: TextSpan(text: kLevel3Npc.avatarEmoji, style: const TextStyle(fontSize: 22)),
      textDirection: TextDirection.ltr,
    )..layout();
    npcTp.paint(canvas, npcPos - Offset(npcTp.width / 2, npcTp.height / 2));

    // 6. Tap-to-move Marker
    if (targetWaypoint != null) {
      final markerPaint = Paint()..color = const Color(0xFF10B981);
      canvas.drawCircle(targetWaypoint!, 5, markerPaint);
    }

    // 7. Player Character
    final pPos = Offset(playerX, playerY);
    final shadowPaint = Paint()..color = Colors.black38;
    canvas.drawOval(Rect.fromCenter(center: pPos + const Offset(0, 16), width: 22, height: 8), shadowPaint);

    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: pPos, width: 18, height: 26), const Radius.circular(6)),
      bodyPaint,
    );

    final headPaint = Paint()..color = const Color(0xFFFFDBAC);
    canvas.drawCircle(pPos - const Offset(0, 15), 8, headPaint);

    final eyePaint = Paint()..color = Colors.black87;
    final eyeOffset = playerFacing == PlayerFacing.left
        ? const Offset(-3, -15)
        : playerFacing == PlayerFacing.right
            ? const Offset(3, -15)
            : const Offset(0, -15);
    canvas.drawCircle(pPos + eyeOffset, 1.5, eyePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoomWorldPainter oldDelegate) => true;
}
