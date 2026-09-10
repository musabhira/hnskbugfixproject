import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adventure_models.dart';
import 'word_factory_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🏭 Level 4: Word Factory – 2D Mobile Puzzle/Adventure Game Screen
// ─────────────────────────────────────────────────────────────────────────────

class WordFactoryGamePage extends StatefulWidget {
  final AdventureLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const WordFactoryGamePage({
    super.key,
    this.levelData = kMission04WordFactoryData,
    this.onCompleted,
  });

  @override
  State<WordFactoryGamePage> createState() => _WordFactoryGamePageState();
}

class _WordFactoryGamePageState extends State<WordFactoryGamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final FlutterTts _tts = FlutterTts();

  // World dimensions (wide scrollable factory)
  final double _worldWidth = 1600.0;
  final double _worldHeight = 560.0;
  double _cameraX = 0.0;

  // Player State
  double _playerX = 140.0;
  double _playerY = 340.0;
  PlayerFacing _playerFacing = PlayerFacing.right;
  PlayerAnimationState _playerAnim = PlayerAnimationState.idle;
  double _playerWalkCycle = 0.0;
  Offset? _targetWaypoint;

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

  // Collected word tokens (shown in HUD)
  final List<String> _collectedWords = [];

  // Locked zone alert toast
  String? _lockedZoneToast;
  Timer? _lockedZoneTimer;

  // Active Challenge Modal State
  bool _isChallengeModalOpen = false;
  AdventureChallenge? _activeChallenge;
  int? _selectedOptionIndex;
  bool _hasAnsweredCurrent = false;
  bool _showListeningSubtitles = false;

  // Sentence Builder Tile State
  List<String> _builtTiles = [];
  List<String> _availableTiles = [];

  // Quick Response Timer
  Timer? _timedCountdown;
  int _timeRemainingSeconds = 8;
  bool _isTimedChallengeActive = false;

  // Conveyor belt animation offset (pixels)
  double _conveyorOffset = 0.0;

  // Unlocked zones (unlocked as challenges progress)
  final Set<String> _unlockedZones = {'entrance', 'word_storage'};

  // Audio Mute
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);
    _ticker.repeat();

    // Opening system-error briefing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(
        'SYSTEM ERROR. Communication grid offline. Repair all modules to restore the factory.',
      );
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
    _timedCountdown?.cancel();
    _lockedZoneTimer?.cancel();
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  // ─── GAME LOOP ──────────────────────────────────────────────────────────────

  void _gameLoop() {
    if (!mounted || _isLevelFinished) return;

    double vx = 0.0, vy = 0.0;
    const double speed = 3.4;

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
      final newY = (_playerY + vy).clamp(80.0, _worldHeight - 60.0);

      // Zone-wall collision: prevent entering locked zones
      bool blocked = false;
      for (final zone in kFactoryZones) {
        if (_unlockedZones.contains(zone.id)) continue;
        final rect = Rect.fromLTWH(
          zone.position.dx + 10,
          zone.position.dy + 10,
          zone.size.width - 20,
          zone.size.height - 20,
        );
        if (rect.contains(Offset(newX, newY))) {
          blocked = true;
          _triggerLockedZoneToast(zone.label);
          break;
        }
      }

      if (!blocked) {
        _playerX = newX;
        _playerY = newY;
      }
    } else if (!_isChallengeModalOpen) {
      _playerAnim = PlayerAnimationState.idle;
    }

    // Conveyor belt scroll
    _conveyorOffset = (_conveyorOffset + 1.2) % 40;

    // Camera smooth follow
    final screenWidth = MediaQuery.of(context).size.width;
    final targetCameraX = (_playerX - screenWidth / 2)
        .clamp(0.0, math.max(0.0, _worldWidth - screenWidth));
    _cameraX += (targetCameraX - _cameraX) * 0.12;

    setState(() {});
  }

  // ─── ZONE UNLOCK PROGRESSION ────────────────────────────────────────────────

  void _unlockZonesForProgress() {
    // Each pair of challenges unlocks the next zone
    final idx = _currentChallengeIndex;
    if (idx >= 2) _unlockedZones.add('sentence_workshop');
    if (idx >= 4) _unlockedZones.add('communication_room');
    if (idx >= 6) _unlockedZones.add('grammar_lab');
    if (idx >= 8) _unlockedZones.add('control_room');
  }

  void _triggerLockedZoneToast(String zoneName) {
    if (_lockedZoneTimer != null && _lockedZoneTimer!.isActive) return;
    setState(() {
      _lockedZoneToast = '🔒 $zoneName is locked. Complete challenges to unlock!';
    });
    _lockedZoneTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _lockedZoneToast = null);
    });
  }

  // ─── NPC INTERACTION ────────────────────────────────────────────────────────

  AdventureNpc? _getNearbyNpc() {
    for (final npc in widget.levelData.npcs) {
      final dist = math.sqrt(
        math.pow(_playerX - npc.worldX, 2) + math.pow(_playerY - npc.worldY, 2),
      );
      if (dist < 90.0) return npc;
    }
    return null;
  }

  void _interactWithNearbyNpc() {
    final npc = _getNearbyNpc();
    if (npc == null || _currentChallengeIndex >= widget.levelData.challenges.length) return;

    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    HapticFeedback.selectionClick();

    setState(() {
      _activeChallenge = challenge;
      _isChallengeModalOpen = true;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
      _showListeningSubtitles = false;
      _playerAnim = PlayerAnimationState.talking;

      if (challenge.type == AdventureChallengeType.sentenceBuilder &&
          challenge.sentenceTiles != null) {
        _builtTiles = [];
        _availableTiles = List.from(challenge.sentenceTiles!)..shuffle();
      }

      if (challenge.timeLimitSeconds != null && challenge.timeLimitSeconds! > 0) {
        _startTimedChallenge(challenge.timeLimitSeconds!);
      }
    });

    final speech = challenge.audioPrompt ?? challenge.npcDialogue;
    _speak(speech);
  }

  // ─── TIMED CHALLENGE ─────────────────────────────────────────────────────────

  void _startTimedChallenge(int seconds) {
    _timedCountdown?.cancel();
    _timeRemainingSeconds = seconds;
    _isTimedChallengeActive = true;

    _timedCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeRemainingSeconds > 0) {
          _timeRemainingSeconds--;
        } else {
          timer.cancel();
          _isTimedChallengeActive = false;
          if (!_hasAnsweredCurrent) _onOptionSelected(1);
        }
      });
    });
  }

  // ─── ANSWER SELECTION ────────────────────────────────────────────────────────

  void _onOptionSelected(int index) {
    if (_hasAnsweredCurrent || _activeChallenge == null) return;
    final opt = _activeChallenge!.options[index];

    _timedCountdown?.cancel();
    _isTimedChallengeActive = false;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnsweredCurrent = true;
      _totalAttempts++;

      if (opt.isCorrect) {
        _correctCount++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        int earned = _activeChallenge!.xpReward;
        if (_activeChallenge!.timeLimitSeconds != null && _timeRemainingSeconds > 4) {
          earned += 15; // speed bonus
        }
        _scoreXp += earned;
        _playerAnim = PlayerAnimationState.celebrating;
        HapticFeedback.heavyImpact();

        // Collect vocabulary word as a token
        final vocab = _activeChallenge!.targetVocabulary;
        if (!_collectedWords.contains(vocab)) {
          _collectedWords.add(vocab);
        }
      } else {
        _combo = 0;
        _playerAnim = PlayerAnimationState.confused;
        _lives = math.max(0, _lives - 1);
        HapticFeedback.vibrate();
      }
    });

    if (opt.reaction != null) _speak(opt.reaction!);
  }

  void _advanceToNextChallenge() {
    setState(() {
      _isChallengeModalOpen = false;
      _activeChallenge = null;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
      _currentChallengeIndex++;
      _playerAnim = PlayerAnimationState.idle;

      _unlockZonesForProgress();

      if (_currentChallengeIndex >= widget.levelData.challenges.length) {
        _isLevelFinished = true;
        _scoreXp += 50; // completion bonus
      }
    });

    if (_isLevelFinished) {
      widget.onCompleted?.call(_scoreXp);
      _speak('Mission 04 complete! Communication grid restored. You are a certified Language Engineer.');
    }
  }

  // ─── JOYSTICK ────────────────────────────────────────────────────────────────

  void _updateJoystick(Offset localPos, double radius) {
    final dx = localPos.dx - radius;
    final dy = localPos.dy - radius;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) {
      _joystickDx = 0;
      _joystickDy = 0;
    } else {
      final clamped = math.min(distance, radius);
      _joystickDx = (dx / distance) * (clamped / radius);
      _joystickDy = (dy / distance) * (clamped / radius);
    }
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nearbyNpc = _getNearbyNpc();

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: SafeArea(
        child: Stack(
          children: [
            // 2D Factory World Canvas
            GestureDetector(
              onTapDown: (details) {
                if (_isChallengeModalOpen) return;
                setState(() {
                  _targetWaypoint = Offset(
                    details.localPosition.dx + _cameraX,
                    details.localPosition.dy,
                  );
                });
              },
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, _worldHeight),
                painter: _FactoryWorldPainter(
                  cameraX: _cameraX,
                  playerX: _playerX,
                  playerY: _playerY,
                  playerFacing: _playerFacing,
                  playerAnim: _playerAnim,
                  walkCycle: _playerWalkCycle,
                  targetWaypoint: _targetWaypoint,
                  zones: kFactoryZones,
                  unlockedZones: _unlockedZones,
                  npcs: widget.levelData.npcs,
                  conveyorOffset: _conveyorOffset,
                  currentChallengeIndex: _currentChallengeIndex,
                ),
              ),
            ),

            // Top HUD
            _buildTopHud(),

            // Collected Word Token Bar
            if (_collectedWords.isNotEmpty) _buildWordTokenBar(),

            // Locked Zone Toast
            if (_lockedZoneToast != null) _buildLockedToast(),

            // NPC Proximity Button
            if (nearbyNpc != null && !_isChallengeModalOpen && !_isLevelFinished)
              _buildNpcProximityButton(nearbyNpc),

            // Virtual Joystick
            if (!_isChallengeModalOpen && !_isLevelFinished)
              Positioned(
                left: 20,
                bottom: 24,
                child: _buildVirtualJoystick(),
              ),

            // Tap-to-walk hint
            if (!_isChallengeModalOpen && !_isLevelFinished)
              Positioned(
                right: 20,
                bottom: 24,
                child: _buildTapHintPill(),
              ),

            // Challenge Modal
            if (_isChallengeModalOpen && _activeChallenge != null)
              _buildChallengeOverlay(),

            // Mission Complete Screen
            if (_isLevelFinished) _buildMissionCompleteModal(),
          ],
        ),
      ),
    );
  }

  // ─── TOP HUD ─────────────────────────────────────────────────────────────────

  Widget _buildTopHud() {
    final progress = _currentChallengeIndex / widget.levelData.challenges.length;

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Back + Mission info
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Word Factory',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFF6B35),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Zone ${_currentChallengeIndex ~/ 2 + 1}/6  •  Module $_currentChallengeIndex/10',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Right: XP, Lives, Mute
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
                const Icon(Icons.bolt_rounded, color: Color(0xFFFF6B35), size: 16),
                const SizedBox(width: 3),
                Text(
                  '$_scoreXp',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  3,
                  (i) => Icon(
                    Icons.favorite_rounded,
                    color: i < _lives ? const Color(0xFFEF4444) : Colors.white24,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _isMuted = !_isMuted),
                  child: Icon(
                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── WORD TOKEN BAR ──────────────────────────────────────────────────────────

  Widget _buildWordTokenBar() {
    return Positioned(
      top: 72,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: Color(0xFFFF6B35), size: 14),
            const SizedBox(width: 6),
            Text(
              'COLLECTED:',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF6B35),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _collectedWords
                      .map(
                        (w) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            w,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOCKED ZONE TOAST ───────────────────────────────────────────────────────

  Widget _buildLockedToast() {
    return Positioned(
      top: _collectedWords.isNotEmpty ? 110 : 72,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7C2D12).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEF4444)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _lockedZoneToast!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── NPC PROXIMITY BUTTON ────────────────────────────────────────────────────

  Widget _buildNpcProximityButton(AdventureNpc npc) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _interactWithNearbyNpc,
          icon: Text(npc.avatarEmoji, style: const TextStyle(fontSize: 18)),
          label: Text(
            'TALK TO ${npc.name.toUpperCase()}',
            style: GoogleFonts.outfit(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 8,
          ),
        ),
      ),
    );
  }

  // ─── VIRTUAL JOYSTICK ────────────────────────────────────────────────────────

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
        onPanStart: (d) {
          _isJoystickActive = true;
          _updateJoystick(d.localPosition, 50.0);
        },
        onPanUpdate: (d) => _updateJoystick(d.localPosition, 50.0),
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
                    colors: [Color(0xFFFF6B35), Color(0xFFEA4C0B)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
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

  Widget _buildTapHintPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_rounded, color: Color(0xFFFF6B35), size: 14),
          const SizedBox(width: 4),
          Text(
            'Tap floor to move',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ─── CHALLENGE MODAL ─────────────────────────────────────────────────────────

  Widget _buildChallengeOverlay() {
    final challenge = _activeChallenge!;
    final isSentenceBuilder = challenge.type == AdventureChallengeType.sentenceBuilder;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1C1007)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header row ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            challenge.title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFF6B35),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (_isTimedChallengeActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_rounded, color: Color(0xFFEF4444), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${_timeRemainingSeconds}s',
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

                    // ── NPC speech bubble ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.terminal_rounded,
                                color: Color(0xFFFF6B35),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  challenge.audioPrompt != null && !_showListeningSubtitles
                                      ? '🔊 Transmission playing. Listen carefully.'
                                      : challenge.npcDialogue,
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
                                icon: const Icon(Icons.replay_rounded,
                                    color: Color(0xFFFF6B35), size: 20),
                                onPressed: () {
                                  _speak(challenge.audioPrompt ?? challenge.npcDialogue);
                                },
                              ),
                            ],
                          ),
                          if (challenge.audioPrompt != null && !_showListeningSubtitles)
                            TextButton.icon(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () => setState(() => _showListeningSubtitles = true),
                              icon: const Icon(Icons.subtitles_rounded,
                                  size: 14, color: Colors.white54),
                              label: Text(
                                'Show subtitles',
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Question ─────────────────────────────────────────────
                    Text(
                      challenge.question,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Sentence builder or MCQ ──────────────────────────────
                    if (isSentenceBuilder) ...[
                      _buildSentenceBuilderSection(),
                      const SizedBox(height: 12),
                    ] else ...[
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
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

                    // ── Feedback & continue ──────────────────────────────────
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeChallenge!.options[_selectedOptionIndex ?? 0].feedback,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            if (_activeChallenge!.vocabularyMeaning.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '📖 ${_activeChallenge!.targetVocabulary}: ',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFF6B35),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _activeChallenge!.vocabularyMeaning,
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: _advanceToNextChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _currentChallengeIndex + 1 >= widget.levelData.challenges.length
                                ? 'RESTORE SYSTEM ✓'
                                : 'NEXT MODULE ➔',
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

  // ─── SENTENCE BUILDER SECTION ────────────────────────────────────────────────

  Widget _buildSentenceBuilderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assembly tray (built tiles)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSEMBLY TRAY:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFF6B35),
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
                          'Tap word tiles below to assemble the phrase...',
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
                            backgroundColor: const Color(0xFFFF6B35),
                            deleteIcon:
                                const Icon(Icons.close_rounded, size: 14, color: Colors.black),
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

        // Available tile pool
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

                    // Auto-check when all tiles are placed
                    if (_builtTiles.length == (_activeChallenge?.sentenceTiles?.length ?? 0)) {
                      final built = _builtTiles.join(' ').toLowerCase().trim();
                      final target =
                          (_activeChallenge?.targetSentence ?? '').toLowerCase().trim();
                      _onOptionSelected(built == target ? 0 : 1);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ─── MISSION COMPLETE MODAL ───────────────────────────────────────────────────

  Widget _buildMissionCompleteModal() {
    final accuracyScore = ((_correctCount / math.max(1, _totalAttempts)) * 100).toInt();
    final vocabScore = math.min(100, _collectedWords.length * 5 + 50);
    final grammarScore = math.min(100, 80 + _bestCombo * 4);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1C0A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏭', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 6),
                    Text(
                      'MISSION 04 COMPLETE!',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Language Engineer Certification Achieved',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFF6B35),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Icon(
                          i < (_lives > 0 ? (accuracyScore >= 80 ? 3 : 2) : 1)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFD700),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Score total
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_scoreXp XP EARNED',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF6B35),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox('Accuracy', '$accuracyScore%'),
                        _buildStatBox('Vocabulary', '$vocabScore%'),
                        _buildStatBox('Grammar', '$grammarScore%'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Collected words
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
                            'WORDS COLLECTED (${_collectedWords.length}/10)',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFF6B35),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: _collectedWords
                                .map(
                                  (w) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      w,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: Text(
                          'CLAIM CERTIFICATE & UNLOCK LEVEL 5 ✓',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: const Color(0xFFFF6B35),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎨 2D Factory World Painter
// ─────────────────────────────────────────────────────────────────────────────

class _FactoryWorldPainter extends CustomPainter {
  final double cameraX;
  final double playerX;
  final double playerY;
  final PlayerFacing playerFacing;
  final PlayerAnimationState playerAnim;
  final double walkCycle;
  final Offset? targetWaypoint;
  final List<FactoryZone> zones;
  final Set<String> unlockedZones;
  final List<AdventureNpc> npcs;
  final double conveyorOffset;
  final int currentChallengeIndex;

  _FactoryWorldPainter({
    required this.cameraX,
    required this.playerX,
    required this.playerY,
    required this.playerFacing,
    required this.playerAnim,
    required this.walkCycle,
    required this.targetWaypoint,
    required this.zones,
    required this.unlockedZones,
    required this.npcs,
    required this.conveyorOffset,
    required this.currentChallengeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, 0);

    _drawBackground(canvas);
    _drawFloorGrid(canvas);
    _drawConveyorBelts(canvas);
    _drawFactoryZones(canvas);
    _drawNpcs(canvas);
    _drawPlayer(canvas);

    canvas.restore();

    // Fixed HUD: zone progress labels (drawn after restore so no camera offset)
    _drawZoneProgressHud(canvas, size);
  }

  void _drawBackground(Canvas canvas) {
    // Dark industrial background
    final bgPaint = Paint()..color = const Color(0xFF080C14);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1600, 560), bgPaint);

    // Ceiling industrial pipes
    final pipePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    for (double x = 0; x < 1600; x += 200) {
      canvas.drawLine(Offset(x, 0), Offset(x, 80), pipePaint);
      canvas.drawLine(Offset(x, 40), Offset(x + 200, 40), pipePaint);
    }

    // Floor line
    final floorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(const Rect.fromLTWH(0, 430, 1600, 130), floorPaint);
    final floorLinePaint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, 430), const Offset(1600, 430), floorLinePaint);

    // Warning stripe on floor edges
    final stripeW = 24.0;
    for (double x = 0; x < 1600; x += stripeW * 2) {
      final stripePaint = Paint()
        ..color = const Color(0xFFFF6B35).withValues(alpha: 0.15);
      canvas.drawRect(Rect.fromLTWH(x, 430, stripeW, 8), stripePaint);
    }
  }

  void _drawFloorGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    for (double x = 0; x < 1600; x += 60) {
      canvas.drawLine(Offset(x, 80), Offset(x, 430), gridPaint);
    }
    for (double y = 80; y <= 430; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(1600, y), gridPaint);
    }
  }

  void _drawConveyorBelts(Canvas canvas) {
    // Two conveyor belts running horizontally across the factory
    final beltBg = Paint()..color = const Color(0xFF374151);
    final beltStripe = Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 3;
    final beltEdge = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 2;

    for (final beltY in [155.0, 400.0]) {
      canvas.drawRect(Rect.fromLTWH(200, beltY, 1200, 18), beltBg);
      // Animated stripes
      for (double x = 200 + (conveyorOffset % 20) - 20; x < 1400; x += 20) {
        canvas.drawLine(Offset(x, beltY), Offset(x + 10, beltY + 18), beltStripe);
      }
      canvas.drawLine(Offset(200, beltY), Offset(1400, beltY), beltEdge);
      canvas.drawLine(Offset(200, beltY + 18), Offset(1400, beltY + 18), beltEdge);
    }
  }

  void _drawFactoryZones(Canvas canvas) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final zone in zones) {
      final isUnlocked = unlockedZones.contains(zone.id);
      final rect = Rect.fromLTWH(
        zone.position.dx,
        zone.position.dy,
        zone.size.width,
        zone.size.height,
      );

      // Zone background
      final zonePaint = Paint()
        ..color = zone.wallColor.withValues(alpha: isUnlocked ? 1.0 : 0.45);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), zonePaint);

      // Zone border
      final borderPaint = Paint()
        ..color = isUnlocked
            ? const Color(0xFFFF6B35).withValues(alpha: 0.6)
            : const Color(0xFF374151).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), borderPaint);

      // Lock overlay
      if (!isUnlocked) {
        final lockPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), lockPaint);
      }

      // Zone icon
      textPainter.text = TextSpan(
        text: zone.icon,
        style: TextStyle(fontSize: isUnlocked ? 28 : 20),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2 - 10,
        ),
      );

      // Zone label
      textPainter.text = TextSpan(
        text: zone.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isUnlocked ? const Color(0xFFFF6B35) : const Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      );
      textPainter.layout(maxWidth: zone.size.width - 8);
      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.bottom - 22,
        ),
      );

      // Lock icon
      if (!isUnlocked) {
        textPainter.text = const TextSpan(text: '🔒', style: TextStyle(fontSize: 16));
        textPainter.layout();
        textPainter.paint(canvas, Offset(rect.right - 24, rect.top + 6));
      }
    }
  }

  void _drawNpcs(Canvas canvas) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final npc in npcs) {
      final cx = npc.worldX;
      final cy = npc.worldY;

      // Shadow
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 30), width: 36, height: 12),
          shadowPaint);

      // Body
      final bodyPaint = Paint()..color = const Color(0xFF1E3A5F);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy + 10), width: 28, height: 36),
            const Radius.circular(8)),
        bodyPaint,
      );

      // Head
      final headPaint = Paint()..color = const Color(0xFF2D5016);
      canvas.drawCircle(Offset(cx, cy - 14), 16, headPaint);

      // Avatar emoji
      textPainter.text =
          TextSpan(text: npc.avatarEmoji, style: const TextStyle(fontSize: 20));
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 25));

      // Name label
      textPainter.text = TextSpan(
        text: npc.name.split(' ').first,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF6B35),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - 38));

      // Chat bubble pulse
      final pulsePaint = Paint()
        ..color = const Color(0xFFFF6B35).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(cx, cy), 42, pulsePaint);
    }
  }

  void _drawPlayer(Canvas canvas) {
    final cx = playerX;
    final cy = playerY;

    // Walking bob
    final bob = playerAnim == PlayerAnimationState.walking
        ? math.sin(walkCycle * 6) * 3.0
        : 0.0;

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 32), width: 32, height: 10),
      shadowPaint,
    );

    // Legs
    final legColor = playerAnim == PlayerAnimationState.celebrating
        ? const Color(0xFFFF6B35)
        : const Color(0xFF1E40AF);
    final legPaint = Paint()..color = legColor;
    final legSwing = playerAnim == PlayerAnimationState.walking ? math.sin(walkCycle * 6) * 8 : 0.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 9, cy + 16 + bob, 7, 18), const Radius.circular(3)),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 2, cy + 16 + bob - legSwing, 7, 18), const Radius.circular(3)),
      legPaint,
    );

    // Body
    Color bodyColor;
    if (playerAnim == PlayerAnimationState.celebrating) {
      bodyColor = const Color(0xFF16A34A);
    } else if (playerAnim == PlayerAnimationState.confused) {
      bodyColor = const Color(0xFF7C2D12);
    } else {
      bodyColor = const Color(0xFF0369A1);
    }
    final bodyPaint = Paint()..color = bodyColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + bob), width: 24, height: 32),
          const Radius.circular(6)),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFFCD34D);
    canvas.drawCircle(Offset(cx, cy - 18 + bob), 14, headPaint);

    // Face expression
    final faceTextPainter = TextPainter(textDirection: TextDirection.ltr);
    final faceEmoji = playerAnim == PlayerAnimationState.celebrating
        ? '😄'
        : playerAnim == PlayerAnimationState.confused
            ? '😕'
            : playerAnim == PlayerAnimationState.talking
                ? '💬'
                : '😐';
    faceTextPainter.text =
        TextSpan(text: faceEmoji, style: const TextStyle(fontSize: 14));
    faceTextPainter.layout();
    faceTextPainter.paint(
      canvas,
      Offset(cx - faceTextPainter.width / 2, cy - 25 + bob),
    );

    // Direction indicator
    if (playerAnim == PlayerAnimationState.walking) {
      final arrowPaint = Paint()
        ..color = const Color(0xFFFF6B35)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final arrowX = playerFacing == PlayerFacing.right ? cx + 18 : cx - 18;
      canvas.drawLine(
        Offset(cx, cy - 6 + bob),
        Offset(arrowX, cy - 6 + bob),
        arrowPaint,
      );
    }

    // Target waypoint
    if (targetWaypoint != null) {
      final waypointPaint = Paint()
        ..color = const Color(0xFFFF6B35).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(targetWaypoint!, 8, waypointPaint);
      canvas.drawLine(
        Offset(targetWaypoint!.dx - 5, targetWaypoint!.dy),
        Offset(targetWaypoint!.dx + 5, targetWaypoint!.dy),
        waypointPaint,
      );
      canvas.drawLine(
        Offset(targetWaypoint!.dx, targetWaypoint!.dy - 5),
        Offset(targetWaypoint!.dx, targetWaypoint!.dy + 5),
        waypointPaint,
      );
    }
  }

  void _drawZoneProgressHud(Canvas canvas, Size size) {
    // Mini zone indicators at the very bottom (screen-fixed)
    final zonePainter = TextPainter(textDirection: TextDirection.ltr);
    final totalZones = kFactoryZones.length;
    const zoneSize = 28.0;
    final totalWidth = totalZones * zoneSize + (totalZones - 1) * 4;
    double startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < totalZones; i++) {
      final zone = kFactoryZones[i];
      final isUnlocked = unlockedZones.contains(zone.id);
      final rect = Rect.fromLTWH(startX + i * (zoneSize + 4), size.height - 36, zoneSize, zoneSize);

      final bgPaint = Paint()
        ..color = isUnlocked
            ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
            : const Color(0xFF1E293B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        bgPaint,
      );

      zonePainter.text =
          TextSpan(text: zone.icon, style: const TextStyle(fontSize: 14));
      zonePainter.layout();
      zonePainter.paint(
        canvas,
        Offset(
          rect.center.dx - zonePainter.width / 2,
          rect.center.dy - zonePainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FactoryWorldPainter oldDelegate) =>
      oldDelegate.cameraX != cameraX ||
      oldDelegate.playerX != playerX ||
      oldDelegate.playerY != playerY ||
      oldDelegate.playerAnim != playerAnim ||
      oldDelegate.walkCycle != walkCycle ||
      oldDelegate.conveyorOffset != conveyorOffset ||
      oldDelegate.unlockedZones.length != unlockedZones.length;
}
