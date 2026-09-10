import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adventure_models.dart';
import 'city_navigator_models.dart';

/// 🏙️ Level 2: City Navigator – Metro Pursuit 2D Mobile Game Screen
class CityNavigatorGamePage extends StatefulWidget {
  final AdventureLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const CityNavigatorGamePage({
    super.key,
    this.levelData = kMission02CityData,
    this.onCompleted,
  });

  @override
  State<CityNavigatorGamePage> createState() => _CityNavigatorGamePageState();
}

class _CityNavigatorGamePageState extends State<CityNavigatorGamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final FlutterTts _tts = FlutterTts();

  // World dimensions
  final double _worldWidth = 1600.0;
  final double _worldHeight = 560.0;
  double _cameraX = 0.0;

  // Player State
  double _playerX = 140.0;
  double _playerY = 285.0; // on the main boulevard
  PlayerFacing _playerFacing = PlayerFacing.right;
  PlayerAnimationState _playerAnim = PlayerAnimationState.idle;
  double _playerWalkCycle = 0.0;
  Offset? _targetWaypoint;
  bool _isDashing = false;

  // Virtual Joystick
  double _joystickDx = 0.0;
  double _joystickDy = 0.0;
  bool _isJoystickActive = false;

  // Progression & Score
  int _currentChallengeIndex = 0;
  int _lives = 3;
  int _scoreXp = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _isLevelFinished = false;

  // Collectible street tokens
  late final List<StreetToken> _streetTokens;
  String? _floatingPickupText;
  Offset? _floatingPickupPos;
  Timer? _floatingTextTimer;

  // Active Challenge Modal State
  bool _isChallengeModalOpen = false;
  AdventureChallenge? _activeChallenge;
  int? _selectedOptionIndex;
  bool _hasAnsweredCurrent = false;

  // Route Builder State (Challenge 7)
  List<String> _builtRouteTiles = [];
  List<String> _availableRouteTiles = [];

  // Timed Navigation (Challenge 8: 15s)
  Timer? _timedCountdown;
  int _timeRemainingSeconds = 15;
  bool _isTimedChallengeActive = false;

  // Audio Mute & Listening Subtitles
  bool _isMuted = false;
  bool _showListeningSubtitles = false;

  // Metro Train Animation
  double _metroTrainX = -300.0;

  @override
  void initState() {
    super.initState();
    _initTts();

    // Populate collectible street tokens
    _streetTokens = [
      StreetToken(id: 't1', label: 'Briefcase Alpha', position: const Offset(260, 280), icon: '💼', xp: 15),
      StreetToken(id: 't2', label: 'Transit Pass', position: const Offset(440, 270), icon: '🎫', xp: 15),
      StreetToken(id: 't3', label: 'GPS Chip', position: const Offset(630, 300), icon: '📡', xp: 15),
      StreetToken(id: 't4', label: 'Tech Data Key', position: const Offset(870, 280), icon: '🔑', xp: 15),
      StreetToken(id: 't5', label: 'Encrypted USB', position: const Offset(1080, 290), icon: '💾', xp: 15),
    ];

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);
    _ticker.repeat();

    // Opening briefing after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakDialogue(
        'Welcome to City Navigator! Navigate along the neon boulevard, collect dispatch briefcases, and solve directional challenges.',
      );
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakDialogue(String text) async {
    if (_isMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker.dispose();
    _timedCountdown?.cancel();
    _floatingTextTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  // ─── GAME LOOP ─────────────────────────────────────────────────────────────
  void _gameLoop() {
    if (!mounted || _isLevelFinished) return;

    setState(() {
      // Animate Metro train along top elevated line
      _metroTrainX += 4.5;
      if (_metroTrainX > _worldWidth + 200) {
        _metroTrainX = -400;
      }

      if (_isChallengeModalOpen) return;

      double moveX = 0.0;
      double moveY = 0.0;
      final speedMultiplier = _isDashing ? 6.2 : 3.6;

      if (_isJoystickActive) {
        moveX = _joystickDx * speedMultiplier;
        moveY = _joystickDy * speedMultiplier;
      } else if (_targetWaypoint != null) {
        final dx = _targetWaypoint!.dx - _playerX;
        final dy = _targetWaypoint!.dy - _playerY;
        final dist = math.sqrt(dx * dx + dy * dy);

        if (dist > 6.0) {
          moveX = (dx / dist) * speedMultiplier;
          moveY = (dy / dist) * speedMultiplier;
        } else {
          _targetWaypoint = null;
        }
      }

      if (moveX != 0.0 || moveY != 0.0) {
        _playerX = (_playerX + moveX).clamp(60.0, _worldWidth - 60.0);
        _playerY = (_playerY + moveY).clamp(160.0, _worldHeight - 80.0);

        if (moveX.abs() > moveY.abs()) {
          _playerFacing = moveX > 0 ? PlayerFacing.right : PlayerFacing.left;
        } else {
          _playerFacing = moveY > 0 ? PlayerFacing.down : PlayerFacing.up;
        }

        _playerAnim = PlayerAnimationState.walking;
        _playerWalkCycle += 0.22;
      } else {
        _playerAnim = PlayerAnimationState.idle;
      }

      // Check collectible tokens
      for (final token in _streetTokens) {
        if (!token.isCollected) {
          final dist = math.sqrt(
            math.pow(_playerX - token.position.dx, 2) +
            math.pow(_playerY - token.position.dy, 2),
          );
          if (dist < 38) {
            token.isCollected = true;
            _scoreXp += token.xp;
            _combo++;
            if (_combo > _bestCombo) _bestCombo = _combo;
            HapticFeedback.lightImpact();
            _triggerFloatingPickup('${token.icon} +${token.xp} XP!', token.position);
          }
        }
      }

      // Smooth camera follow
      final screenWidth = MediaQuery.of(context).size.width;
      final targetCamX = (_playerX - screenWidth / 2).clamp(0.0, _worldWidth - screenWidth);
      _cameraX += (targetCamX - _cameraX) * 0.14;
    });
  }

  void _triggerFloatingPickup(String text, Offset pos) {
    setState(() {
      _floatingPickupText = text;
      _floatingPickupPos = pos;
    });
    _floatingTextTimer?.cancel();
    _floatingTextTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _floatingPickupText = null);
    });
  }

  // ─── CHALLENGE TRIGGERING ──────────────────────────────────────────────────
  AdventureChallenge get _activeCurrentChallenge {
    if (_currentChallengeIndex < widget.levelData.challenges.length) {
      return widget.levelData.challenges[_currentChallengeIndex];
    }
    return widget.levelData.challenges.last;
  }

  void _openChallengeModal(AdventureChallenge challenge) {
    setState(() {
      _activeChallenge = challenge;
      _isChallengeModalOpen = true;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
      _showListeningSubtitles = false;

      if (challenge.type == AdventureChallengeType.sentenceBuilder &&
          challenge.sentenceTiles != null) {
        _availableRouteTiles = List.from(challenge.sentenceTiles!)..shuffle();
        _builtRouteTiles = [];
      }

      if (challenge.type == AdventureChallengeType.quickResponse) {
        _startTimedCountdown(challenge.timeLimitSeconds ?? 15);
      }
    });

    HapticFeedback.mediumImpact();
    if (challenge.type == AdventureChallengeType.listening && challenge.audioPrompt != null) {
      _speakDialogue(challenge.audioPrompt!);
    } else {
      _speakDialogue(challenge.npcDialogue);
    }
  }

  void _startTimedCountdown(int seconds) {
    _timedCountdown?.cancel();
    _timeRemainingSeconds = seconds;
    _isTimedChallengeActive = true;

    _timedCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeRemainingSeconds > 0) {
          _timeRemainingSeconds--;
        } else {
          timer.cancel();
          _isTimedChallengeActive = false;
          _handleAnswer(false, 'Time expired! Keep your eyes on the road signs.');
        }
      });
    });
  }

  void _handleAnswer(bool isCorrect, String feedback) {
    _timedCountdown?.cancel();
    _isTimedChallengeActive = false;
    _totalAttempts++;

    setState(() {
      _hasAnsweredCurrent = true;
      if (isCorrect) {
        _correctCount++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        final xpGain = _activeChallenge?.xpReward ?? 25;
        _scoreXp += xpGain + (_combo > 2 ? 10 : 0);
        HapticFeedback.heavyImpact();
        _speakDialogue('Correct! ${_activeChallenge?.options.firstWhere((o) => o.isCorrect).reaction ?? ""}');
      } else {
        _combo = 0;
        _lives = math.max(0, _lives - 1);
        HapticFeedback.vibrate();
        _speakDialogue('Incorrect. $feedback');
      }
    });
  }

  void _advanceToNextChallenge() {
    setState(() {
      _isChallengeModalOpen = false;
      _activeChallenge = null;
      _currentChallengeIndex++;

      if (_currentChallengeIndex >= widget.levelData.challenges.length) {
        _isLevelFinished = true;
        widget.onCompleted?.call(_scoreXp);
        _speakDialogue('City Navigator mission completed! You are a certified Urban Navigation Specialist.');
      }
    });
  }

  // ─── UI BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // 1. 2D City Canvas & World Layer
          GestureDetector(
            onTapDown: (details) {
              if (!_isChallengeModalOpen) {
                final worldTap = Offset(details.localPosition.dx + _cameraX, details.localPosition.dy);
                setState(() => _targetWaypoint = worldTap);
                HapticFeedback.selectionClick();
              }
            },
            child: CustomPaint(
              size: screenSize,
              painter: _CityMetroWorldPainter(
                worldWidth: _worldWidth,
                worldHeight: _worldHeight,
                cameraX: _cameraX,
                playerX: _playerX,
                playerY: _playerY,
                playerFacing: _playerFacing,
                playerAnim: _playerAnim,
                playerWalkCycle: _playerWalkCycle,
                targetWaypoint: _targetWaypoint,
                landmarks: kCityLandmarks,
                signs: kCitySigns,
                npcs: widget.levelData.npcs,
                streetTokens: _streetTokens,
                metroTrainX: _metroTrainX,
                currentChallengeIndex: _currentChallengeIndex,
                isDashing: _isDashing,
              ),
            ),
          ),

          // 2. Floating Pickup Notification
          if (_floatingPickupText != null && _floatingPickupPos != null)
            Positioned(
              left: _floatingPickupPos!.dx - _cameraX - 40,
              top: _floatingPickupPos!.dy - 50,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    _floatingPickupText!,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Top Clean Minimal App Bar (Overflow-Proof)
          _buildCleanTopBar(),

          // 4. Active Quest Prompt Banner
          if (!_isLevelFinished && !_isChallengeModalOpen)
            _buildActiveQuestBanner(),

          // 5. On-Screen Virtual Controls (Joystick + Dash + Action Button)
          if (!_isLevelFinished && !_isChallengeModalOpen)
            _buildControlHUD(),

          // 6. Challenge Interactive Modal Sheet
          if (_isChallengeModalOpen && _activeChallenge != null)
            _buildChallengeModal(context),

          // 7. Level Finished Certification Screen
          if (_isLevelFinished)
            _buildLevelCompleteScreen(),
        ],
      ),
    );
  }

  // ─── 🏆 CLEAN TOP APP BAR (NO OVERFLOW) ─────────────────────────────────────
  Widget _buildCleanTopBar() {
    final progress = (_currentChallengeIndex / widget.levelData.challenges.length).clamp(0.0, 1.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            // Left: Back button + Minimal Title
            Flexible(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                            'City Navigator',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                              minHeight: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Right: Lives + Combo + XP + Mute
            Flexible(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Lives
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            i < _lives ? '❤️' : '🤍',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // XP Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$_scoreXp XP',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Mute toggle
                  InkWell(
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Icon(
                        _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 📍 ACTIVE QUEST BANNER ────────────────────────────────────────────────
  Widget _buildActiveQuestBanner() {
    final challenge = _activeCurrentChallenge;
    final targetNpc = widget.levelData.npcs.firstWhere(
      (n) => n.id == challenge.npcId,
      orElse: () => widget.levelData.npcs.first,
    );

    return Positioned(
      top: 60,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(targetNpc.avatarEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'STOP ${_currentChallengeIndex + 1}/10',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          challenge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Approach ${targetNpc.name} (${targetNpc.role}) to unlock.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () => _openChallengeModal(challenge),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'INTERACT ➔',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 🎮 VIRTUAL CONTROLS & HUD ─────────────────────────────────────────────
  Widget _buildControlHUD() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Virtual Analog Joystick
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F172A).withValues(alpha: 0.7),
              border: Border.all(color: Colors.white12, width: 2),
            ),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _isJoystickActive = true);
                _updateJoystick(details.localPosition, const Size(110, 110));
              },
              onPanUpdate: (details) {
                _updateJoystick(details.localPosition, const Size(110, 110));
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
                  Container(
                    width: 38,
                    height: 38,
                    transform: Matrix4.translationValues(_joystickDx * 28, _joystickDy * 28, 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF38BDF8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Right Controls: Dash / Sprint Button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTapDown: (_) => setState(() => _isDashing = true),
                onTapUp: (_) => setState(() => _isDashing = false),
                onTapCancel: () => setState(() => _isDashing = false),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isDashing
                          ? [const Color(0xFFF59E0B), const Color(0xFFEA580C)]
                          : [const Color(0xFF0284C7), const Color(0xFF0369A1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isDashing ? const Color(0xFFF59E0B) : const Color(0xFF0284C7))
                            .withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                      Text(
                        'SPRINT',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Direct Interact Button
              ElevatedButton.icon(
                onPressed: () => _openChallengeModal(_activeCurrentChallenge),
                icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.black),
                label: Text(
                  'TALK',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateJoystick(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rawDx = localPos.dx - center.dx;
    final rawDy = localPos.dy - center.dy;
    final dist = math.sqrt(rawDx * rawDx + rawDy * rawDy);
    final maxDist = size.width / 2;

    setState(() {
      if (dist > 0) {
        _joystickDx = (rawDx / dist) * math.min(1.0, dist / maxDist);
        _joystickDy = (rawDy / dist) * math.min(1.0, dist / maxDist);
      } else {
        _joystickDx = 0.0;
        _joystickDy = 0.0;
      }
    });
  }

  // ─── 🧩 CHALLENGE MODAL (Interactive) ──────────────────────────────────────
  Widget _buildChallengeModal(BuildContext context) {
    final challenge = _activeChallenge!;
    final npc = widget.levelData.npcs.firstWhere(
      (n) => n.id == challenge.npcId,
      orElse: () => widget.levelData.npcs.first,
    );

    return Container(
      color: Colors.black54,
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(npc.avatarEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          npc.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          npc.role,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => setState(() => _isChallengeModalOpen = false),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Dialogue Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.npcDialogue,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (challenge.type == AdventureChallengeType.listening &&
                        challenge.audioPrompt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _speakDialogue(challenge.audioPrompt!),
                            icon: const Icon(Icons.volume_up_rounded, size: 16),
                            label: const Text('REPLAY AUDIO'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() => _showListeningSubtitles = !_showListeningSubtitles),
                            child: Text(
                              _showListeningSubtitles ? 'Hide Subtitles' : 'Show Subtitles',
                              style: const TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
                      if (_showListeningSubtitles)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"${challenge.audioPrompt}"',
                            style: GoogleFonts.inter(color: Colors.amberAccent, fontSize: 12),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Question
              Text(
                challenge.question,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF8FAFC),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              // Timed Countdown Indicator (Challenge 8)
              if (_isTimedChallengeActive)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '⚡ RAPID TIMEOUT:',
                            style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          Text(
                            '${_timeRemainingSeconds}s',
                            style: GoogleFonts.outfit(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _timeRemainingSeconds / 15,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Route Builder (Challenge 7)
              if (challenge.type == AdventureChallengeType.sentenceBuilder) ...[
                _buildRouteBuilderSection(challenge),
              ] else ...[
                // Standard Multiple Choice Options
                ...List.generate(challenge.options.length, (idx) {
                  final option = challenge.options[idx];
                  final isSelected = _selectedOptionIndex == idx;

                  Color btnColor = const Color(0xFF1E293B);
                  BorderSide border = const BorderSide(color: Colors.white12);

                  if (_hasAnsweredCurrent) {
                    if (option.isCorrect) {
                      btnColor = const Color(0xFF065F46);
                      border = const BorderSide(color: Color(0xFF10B981), width: 1.5);
                    } else if (isSelected && !option.isCorrect) {
                      btnColor = const Color(0xFF7F1D1D);
                      border = const BorderSide(color: Color(0xFFEF4444), width: 1.5);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: _hasAnsweredCurrent
                          ? null
                          : () {
                              setState(() => _selectedOptionIndex = idx);
                              _handleAnswer(option.isCorrect, option.feedback);
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.fromBorderSide(border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white12,
                              ),
                              child: Text(
                                String.fromCharCode(65 + idx),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                option.text,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
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

              // Feedback & Advance Button
              if (_hasAnsweredCurrent) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 VOCABULARY & GRAMMAR NOTE:',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        challenge.vocabularyMeaning,
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _advanceToNextChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _currentChallengeIndex >= widget.levelData.challenges.length - 1
                        ? 'FINISH MISSION 🚀'
                        : 'CONTINUE EXPEDITION ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── 🧭 ROUTE BUILDER (Challenge 7) ────────────────────────────────────────
  Widget _buildRouteBuilderSection(AdventureChallenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Built Sequence Container
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
          ),
          child: _builtRouteTiles.isEmpty
              ? Center(
                  child: Text(
                    'Tap the step tiles below in correct sequence...',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _builtRouteTiles.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      backgroundColor: const Color(0xFF0284C7),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Colors.white70),
                      onDeleted: _hasAnsweredCurrent
                          ? null
                          : () {
                              setState(() {
                                final removed = _builtRouteTiles.removeAt(entry.key);
                                _availableRouteTiles.add(removed);
                              });
                            },
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 10),

        // Available Tiles
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableRouteTiles.map((tile) {
            return ActionChip(
              label: Text(tile, style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: const Color(0xFF334155),
              onPressed: _hasAnsweredCurrent
                  ? null
                  : () {
                      setState(() {
                        _availableRouteTiles.remove(tile);
                        _builtRouteTiles.add(tile);
                      });
                    },
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        if (!_hasAnsweredCurrent)
          ElevatedButton(
            onPressed: _builtRouteTiles.length == (challenge.sentenceTiles?.length ?? 4)
                ? () {
                    final fullBuilt = _builtRouteTiles.join(' ');
                    final isMatch = fullBuilt.trim() == (challenge.targetSentence?.trim() ?? '');
                    _handleAnswer(
                      isMatch,
                      isMatch
                          ? 'Flawless route sequence!'
                          : 'Review the step order: exit station ➔ turn right ➔ walk past library ➔ enter lobby.',
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('SUBMIT ROUTE SEQUENCE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  // ─── 🎓 LEVEL COMPLETE CERTIFICATION ───────────────────────────────────────
  Widget _buildLevelCompleteScreen() {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF10B981), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              'CITY NAVIGATOR COMPLETE!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Certified Urban Navigation Specialist',
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBox('XP EARNED', '+$_scoreXp', const Color(0xFFF59E0B)),
                _buildStatBox('MAX COMBO', '🔥 $_bestCombo', const Color(0xFFEA580C)),
                _buildStatBox('ACCURACY', '${((_correctCount / math.max(1, _totalAttempts)) * 100).toInt()}%', const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'CLAIM CERTIFICATE ➔',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 2D CITY METRO WORLD PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _CityMetroWorldPainter extends CustomPainter {
  final double worldWidth;
  final double worldHeight;
  final double cameraX;
  final double playerX;
  final double playerY;
  final PlayerFacing playerFacing;
  final PlayerAnimationState playerAnim;
  final double playerWalkCycle;
  final Offset? targetWaypoint;
  final List<CityLandmark> landmarks;
  final List<CitySign> signs;
  final List<AdventureNpc> npcs;
  final List<StreetToken> streetTokens;
  final double metroTrainX;
  final int currentChallengeIndex;
  final bool isDashing;

  _CityMetroWorldPainter({
    required this.worldWidth,
    required this.worldHeight,
    required this.cameraX,
    required this.playerX,
    required this.playerY,
    required this.playerFacing,
    required this.playerAnim,
    required this.playerWalkCycle,
    required this.targetWaypoint,
    required this.landmarks,
    required this.signs,
    required this.npcs,
    required this.streetTokens,
    required this.metroTrainX,
    required this.currentChallengeIndex,
    required this.isDashing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Dark Asphalt Metropolis Ground
    final groundPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), groundPaint);

    // 2. Elevated Metro Track at Top
    _drawElevatedMetroLine(canvas);

    // 3. Wide Neon Boulevard (Main Road)
    final roadPaint = Paint()..color = const Color(0xFF1E293B);
    const roadRect = Rect.fromLTWH(0, 240, 1600, 100);
    canvas.drawRect(roadRect, roadPaint);

    // Road Markings (Glowing Neon Center Dashes)
    final dashPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..strokeWidth = 3;
    for (double x = 20; x < worldWidth; x += 40) {
      canvas.drawLine(Offset(x, 290), Offset(x + 20, 290), dashPaint);
    }

    // Pedestrian Zebra Crosswalks
    _drawCrosswalk(canvas, 280, 240, 100);
    _drawCrosswalk(canvas, 750, 240, 100);
    _drawCrosswalk(canvas, 1140, 240, 100);

    // Sidewalk Borders
    final curbPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 4;
    canvas.drawLine(const Offset(0, 240), Offset(worldWidth, 240), curbPaint);
    canvas.drawLine(const Offset(0, 340), Offset(worldWidth, 340), curbPaint);

    // 4. City Buildings & Landmarks
    for (final lm in landmarks) {
      _drawLandmark(canvas, lm);
    }

    // 5. Street Signs
    for (final sign in signs) {
      _drawStreetSign(canvas, sign);
    }

    // 6. Collectible Street Tokens (Briefcases / Energy Orbs)
    for (final token in streetTokens) {
      if (!token.isCollected) {
        _drawStreetToken(canvas, token);
      }
    }

    // 7. Interactive NPCs
    for (final npc in npcs) {
      _drawNpc(canvas, npc);
    }

    // 8. Tap Target Waypoint Ring
    if (targetWaypoint != null) {
      final wpPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(targetWaypoint!, 14, wpPaint);
      canvas.drawCircle(targetWaypoint!, 5, Paint()..color = const Color(0xFF38BDF8));
    }

    // 9. Player Avatar
    _drawPlayer(canvas);

    canvas.restore();
  }

  void _drawElevatedMetroLine(Canvas canvas) {
    // Metro Track Rails
    final trackPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.4)
      ..strokeWidth = 4;
    canvas.drawLine(const Offset(0, 70), Offset(worldWidth, 70), trackPaint);
    canvas.drawLine(const Offset(0, 85), Offset(worldWidth, 85), trackPaint);

    // Track Ties
    final tiePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2;
    for (double x = 0; x < worldWidth; x += 18) {
      canvas.drawLine(Offset(x, 66), Offset(x, 89), tiePaint);
    }

    // Glowing Metro Train
    if (metroTrainX > -250 && metroTrainX < worldWidth + 250) {
      final trainRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(metroTrainX, 60, 180, 30),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        trainRect,
        Paint()..color = const Color(0xFF0284C7),
      );
      // Train Headlights
      canvas.drawCircle(
        Offset(metroTrainX + 175, 75),
        4,
        Paint()..color = const Color(0xFFFDE047),
      );
      // Windows
      for (int i = 0; i < 4; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(metroTrainX + 15 + i * 38, 66, 26, 14),
            const Radius.circular(3),
          ),
          Paint()..color = const Color(0xFFE0F2FE),
        );
      }
    }
  }

  void _drawCrosswalk(Canvas canvas, double x, double y, double height) {
    final stripePaint = Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.85);
    for (double dy = 6; dy < height; dy += 16) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y + dy, 40, 8), const Radius.circular(2)),
        stripePaint,
      );
    }
  }

  void _drawLandmark(Canvas canvas, CityLandmark lm) {
    final rect = Rect.fromLTWH(lm.position.dx, lm.position.dy, lm.size.width, lm.size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Building Shadow & Glow
    final glowPaint = Paint()
      ..color = lm.primaryColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(rrect, glowPaint);

    // Building Body
    final bodyPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(rrect, bodyPaint);

    // Building Roof Accent Trim
    final trimPaint = Paint()..color = lm.primaryColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lm.position.dx, lm.position.dy, lm.size.width, 10),
        const Radius.circular(4),
      ),
      trimPaint,
    );

    // Building Windows Grid
    final winPaint = Paint()..color = lm.primaryColor.withValues(alpha: 0.4);
    for (double wx = lm.position.dx + 12; wx < lm.position.dx + lm.size.width - 20; wx += 24) {
      for (double wy = lm.position.dy + 20; wy < lm.position.dy + lm.size.height - 30; wy += 22) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(wx, wy, 14, 12), const Radius.circular(2)),
          winPaint,
        );
      }
    }

    // Glowing Neon Sign Label
    final tp = TextPainter(
      text: TextSpan(
        text: lm.signLabel,
        style: GoogleFonts.outfit(
          color: lm.primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(lm.position.dx + (lm.size.width - tp.width) / 2, lm.position.dy + lm.size.height - 18));
  }

  void _drawStreetSign(Canvas canvas, CitySign sign) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(sign.position.dx, sign.position.dy, 75, 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: sign.text,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(sign.position.dx + (75 - tp.width) / 2, sign.position.dy + 4));
  }

  void _drawStreetToken(Canvas canvas, StreetToken token) {
    // Pulsing Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(token.position, 14, glowPaint);

    final tp = TextPainter(
      text: TextSpan(text: token.icon, style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(token.position.dx - tp.width / 2, token.position.dy - tp.height / 2));
  }

  void _drawNpc(Canvas canvas, AdventureNpc npc) {
    final pos = Offset(npc.worldX, npc.worldY);

    // Active Quest Indicator Ring
    final pulsePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(pos, 22, pulsePaint);

    // Avatar Emoji
    final tp = TextPainter(
      text: TextSpan(text: npc.avatarEmoji, style: const TextStyle(fontSize: 24)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));

    // Name Label Pill
    final nameTp = TextPainter(
      text: TextSpan(
        text: npc.name,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final nameBg = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx - nameTp.width / 2 - 4, pos.dy + 16, nameTp.width + 8, 14),
      const Radius.circular(4),
    );
    canvas.drawRRect(nameBg, Paint()..color = const Color(0xFF0F172A));
    nameTp.paint(canvas, Offset(pos.dx - nameTp.width / 2, pos.dy + 17));
  }

  void _drawPlayer(Canvas canvas) {
    final pos = Offset(playerX, playerY);

    // Dash trail effects
    if (isDashing) {
      final trailPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(playerX - (playerFacing == PlayerFacing.right ? 18 : -18), playerY), 16, trailPaint);
    }

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 16), width: 28, height: 10),
      Paint()..color = Colors.black45,
    );

    // Avatar Body
    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(pos, 14, bodyPaint);

    // Head / Visor
    final visorPaint = Paint()..color = const Color(0xFF38BDF8);
    final visorOffset = playerFacing == PlayerFacing.right
        ? const Offset(4, -2)
        : playerFacing == PlayerFacing.left
            ? const Offset(-4, -2)
            : const Offset(0, -2);
    canvas.drawCircle(pos + visorOffset, 5, visorPaint);

    // Direction Pointer
    final dirPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final dirOffset = playerFacing == PlayerFacing.right
        ? const Offset(12, 0)
        : playerFacing == PlayerFacing.left
            ? const Offset(-12, 0)
            : playerFacing == PlayerFacing.down
                ? const Offset(0, 12)
                : const Offset(0, -12);
    canvas.drawLine(pos, pos + dirOffset, dirPaint);
  }

  @override
  bool shouldRepaint(covariant _CityMetroWorldPainter oldDelegate) => true;
}
