import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adventure_models.dart';
import 'city_navigator_models.dart';

/// 🏙️ Level 2: City Navigator 2D Mobile Game Screen
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
  double _playerY = 285.0; // on the main road
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
  int _wrongTurnCount = 0;
  bool _isLevelFinished = false;

  // Navigation Direction Warning Toast
  String? _directionWarning;
  Timer? _directionWarningTimer;

  // Active Challenge Modal State
  bool _isChallengeModalOpen = false;
  AdventureChallenge? _activeChallenge;
  int? _selectedOptionIndex;
  bool _hasAnsweredCurrent = false;

  // Route Builder State (Challenge 7)
  List<String> _builtRouteTiles = [];
  List<String> _availableRouteTiles = [];

  // Timed Navigation (Challenge 8: 60 seconds)
  Timer? _timedCountdown;
  int _timeRemainingSeconds = 60;
  bool _isTimedChallengeActive = false;

  // Highlighted Landmark (e.g., Pharmacy in Challenge 2, Library in Challenge 4)
  String? _highlightedLandmarkId;
  Timer? _highlightTimer;

  // Minimap Visibility
  bool _showMinimap = true;

  // Audio Mute & Listening Subtitles
  bool _isMuted = false;
  bool _showListeningSubtitles = false;

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
      _speakDialogue(
        'Your meeting starts at 11:00 AM at the City Business Center. Walk straight, follow the English clues, and navigate the city.',
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
    _directionWarningTimer?.cancel();
    _timedCountdown?.cancel();
    _highlightTimer?.cancel();
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  // --- GAME LOOP & PHYSICS ---
  void _gameLoop() {
    if (!mounted || _isLevelFinished) return;

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
      final newY = (_playerY + vy).clamp(80.0, _worldHeight - 50.0);

      // Simple building boundary collision check
      bool collidesWithBuilding = false;
      for (final lm in kCityLandmarks) {
        final rect = Rect.fromLTWH(
          lm.position.dx,
          lm.position.dy,
          lm.size.width,
          lm.size.height,
        );
        // Allow walking on road / plaza, collide with solid walls
        if (lm.id != 'start_plaza' && rect.inflate(-10).contains(Offset(newX, newY))) {
          collidesWithBuilding = true;
          break;
        }
      }

      if (!collidesWithBuilding) {
        _playerX = newX;
        _playerY = newY;
      }

      // Check wrong direction during navigation challenges
      _checkDirectionHeading(vx);
    } else if (!_isChallengeModalOpen) {
      _playerAnim = PlayerAnimationState.idle;
    }

    // Camera smoothly follows player
    final screenWidth = MediaQuery.of(context).size.width;
    final targetCameraX = (_playerX - screenWidth / 2)
        .clamp(0.0, math.max(0.0, _worldWidth - screenWidth));
    _cameraX += (targetCameraX - _cameraX) * 0.12;

    setState(() {});
  }

  void _checkDirectionHeading(double vx) {
    // If on Challenge 1 ("Go straight and turn right") and player moves far left backwards:
    if (_currentChallengeIndex == 0 && vx < -2.0 && _playerX < 120.0) {
      _triggerWrongDirectionWarning();
    }
  }

  void _triggerWrongDirectionWarning() {
    if (_directionWarningTimer != null && _directionWarningTimer!.isActive) return;
    _wrongTurnCount++;
    HapticFeedback.mediumImpact();

    String warningMsg = 'Wrong direction. Recalculating route...';
    if (_wrongTurnCount >= 3) {
      warningMsg = 'Wrong direction! -1 Life. Follow the signs.';
      if (_lives > 1) {
        _lives--;
      }
    } else if (_wrongTurnCount == 2) {
      warningMsg = 'Wrong direction. Minor navigation delay (-5 XP).';
      _scoreXp = math.max(0, _scoreXp - 5);
    }

    setState(() {
      _directionWarning = warningMsg;
    });

    _directionWarningTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _directionWarning = null;
        });
      }
    });
  }

  // --- NPC / CHALLENGE INTERACTION ---
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
    if (npc == null || _currentChallengeIndex >= widget.levelData.challenges.length) {
      return;
    }

    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    HapticFeedback.selectionClick();

    setState(() {
      _activeChallenge = challenge;
      _isChallengeModalOpen = true;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
      _playerAnim = PlayerAnimationState.talking;
      _showListeningSubtitles = false;

      // Initialize sentence / route builder tiles if needed
      if (challenge.type == AdventureChallengeType.sentenceBuilder &&
          challenge.sentenceTiles != null) {
        _builtRouteTiles = [];
        _availableRouteTiles = List.from(challenge.sentenceTiles!)..shuffle();
      }

      // Initialize 60s timer if Challenge 8
      if (challenge.timeLimitSeconds != null && challenge.timeLimitSeconds! > 0) {
        _startTimedChallenge(challenge.timeLimitSeconds!);
      }
    });

    // Speak audio prompt or NPC dialogue
    final speech = challenge.audioPrompt ?? challenge.npcDialogue;
    _speakDialogue(speech);
  }

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
          // Timeout penalty
          if (!_hasAnsweredCurrent) {
            _onOptionSelected(1); // pick incorrect option on timeout
          }
        }
      });
    });
  }

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
        // Fast completion bonus on timed challenge
        if (_activeChallenge!.timeLimitSeconds != null && _timeRemainingSeconds > 30) {
          earned += 25;
        }
        _scoreXp += earned;
        _playerAnim = PlayerAnimationState.celebrating;
        HapticFeedback.heavyImpact();

        // Highlight landmark if relevant
        if (_activeChallenge!.id == 2) {
          _highlightLandmark('pharmacy');
        } else if (_activeChallenge!.id == 4) {
          _highlightLandmark('library');
        }
      } else {
        _combo = 0;
        _playerAnim = PlayerAnimationState.confused;
        _lives = math.max(0, _lives - 1);
        HapticFeedback.vibrate();
      }
    });

    if (opt.reaction != null) {
      _speakDialogue(opt.reaction!);
    }
  }

  void _highlightLandmark(String landmarkId) {
    _highlightTimer?.cancel();
    setState(() {
      _highlightedLandmarkId = landmarkId;
    });
    _highlightTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _highlightedLandmarkId = null;
        });
      }
    });
  }

  void _advanceToNextChallenge() {
    setState(() {
      _isChallengeModalOpen = false;
      _activeChallenge = null;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
      _currentChallengeIndex++;
      _playerAnim = PlayerAnimationState.idle;

      if (_currentChallengeIndex >= widget.levelData.challenges.length) {
        _isLevelFinished = true;
        _scoreXp += 50; // Completion master bonus
      }
    });

    if (_isLevelFinished) {
      widget.onCompleted?.call(_scoreXp);
      _speakDialogue('Mission Complete! You are now a certified City Navigator.');
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    final nearbyNpc = _getNearbyNpc();
    final activeTarget = _getActiveDestination();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Stack(
          children: [
            // 2D City Canvas World
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
                painter: _CityWorldPainter(
                  cameraX: _cameraX,
                  playerX: _playerX,
                  playerY: _playerY,
                  playerFacing: _playerFacing,
                  playerAnim: _playerAnim,
                  walkCycle: _playerWalkCycle,
                  targetWaypoint: _targetWaypoint,
                  landmarks: kCityLandmarks,
                  signs: kCitySigns,
                  npcs: widget.levelData.npcs,
                  highlightedLandmarkId: _highlightedLandmarkId,
                  activeTargetPos: activeTarget?.position,
                ),
              ),
            ),

            // Top Minimal HUD
            _buildMinimalTopHud(),

            // Minimap Radar Overlay (Top Right)
            if (_showMinimap) _buildMinimapHud(),

            // Direction Warning Banner
            if (_directionWarning != null) _buildDirectionWarningBanner(),

            // Proximity NPC Prompt Button
            if (nearbyNpc != null && !_isChallengeModalOpen && !_isLevelFinished)
              _buildNpcProximityAction(nearbyNpc),

            // Virtual Joystick Controller (Bottom Left)
            if (!_isChallengeModalOpen && !_isLevelFinished)
              Positioned(
                left: 20,
                bottom: 24,
                child: _buildVirtualJoystick(),
              ),

            // Tap-to-move hint / quick controls (Bottom Right)
            if (!_isChallengeModalOpen && !_isLevelFinished)
              Positioned(
                right: 20,
                bottom: 24,
                child: _buildNavigationHintPill(),
              ),

            // Active Challenge Modal / Dialog
            if (_isChallengeModalOpen && _activeChallenge != null)
              _buildChallengeOverlay(),

            // Mission Finished Summary Modal
            if (_isLevelFinished) _buildMissionCompleteModal(),
          ],
        ),
      ),
    );
  }

  CityLandmark? _getActiveDestination() {
    if (_currentChallengeIndex >= widget.levelData.challenges.length) {
      return kCityLandmarks.firstWhere((l) => l.id == 'business_center');
    }
    final c = widget.levelData.challenges[_currentChallengeIndex];
    if (c.id == 1 || c.id == 5) {
      return kCityLandmarks.firstWhere((l) => l.id == 'bank');
    } else if (c.id == 2) {
      return kCityLandmarks.firstWhere((l) => l.id == 'pharmacy');
    } else if (c.id == 3) {
      return kCityLandmarks.firstWhere((l) => l.id == 'bus_stop');
    } else if (c.id == 4) {
      return kCityLandmarks.firstWhere((l) => l.id == 'library');
    } else if (c.id == 6) {
      return kCityLandmarks.firstWhere((l) => l.id == 'metro_station');
    } else {
      return kCityLandmarks.firstWhere((l) => l.id == 'business_center');
    }
  }

  // --- MINIMAL TOP HUD ---
  Widget _buildMinimalTopHud() {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button & Mission Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.88),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MISSION 02: CITY NAVIGATOR',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Target: City Business Center (11:00 AM)',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Pill: XP & Lives
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.88),
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
                    const SizedBox(width: 10),
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
              const SizedBox(width: 6),
              // Minimap toggle
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  padding: const EdgeInsets.all(8),
                ),
                icon: Icon(
                  _showMinimap ? Icons.map_rounded : Icons.map_outlined,
                  color: const Color(0xFF38BDF8),
                  size: 18,
                ),
                onPressed: () {
                  setState(() => _showMinimap = !_showMinimap);
                },
              ),
              // Mute toggle
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  padding: const EdgeInsets.all(8),
                ),
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                onPressed: () {
                  setState(() => _isMuted = !_isMuted);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MINIMAP RADAR HUD ---
  Widget _buildMinimapHud() {
    return Positioned(
      top: 66,
      right: 12,
      child: Container(
        width: 130,
        height: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _MinimapPainter(
            worldWidth: _worldWidth,
            worldHeight: _worldHeight,
            playerX: _playerX,
            playerY: _playerY,
            landmarks: kCityLandmarks,
            activeTarget: _getActiveDestination()?.position,
          ),
        ),
      ),
    );
  }

  // --- DIRECTION WARNING TOAST ---
  Widget _buildDirectionWarningBanner() {
    return Positioned(
      top: 80,
      left: 20,
      right: 160,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFB91C1C).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEF4444)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _directionWarning!,
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

  // --- NPC PROXIMITY ACTION BUTTON ---
  Widget _buildNpcProximityAction(AdventureNpc npc) {
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
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 6,
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
            // Center stick
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

  Widget _buildNavigationHintPill() {
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
          const Icon(Icons.touch_app_rounded, color: Color(0xFF38BDF8), size: 14),
          const SizedBox(width: 4),
          Text(
            'Tap road to walk',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // --- CHALLENGE MODAL OVERLAY ---
  Widget _buildChallengeOverlay() {
    final challenge = _activeChallenge!;
    final isRouteBuilder = challenge.type == AdventureChallengeType.sentenceBuilder;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
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
                    // Challenge Header
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
                        if (_isTimedChallengeActive)
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

                    // NPC Speech / Audio prompt
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
                              const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  challenge.audioPrompt != null && !_showListeningSubtitles
                                      ? '🔊 Spoken direction played. Listen and select.'
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
                                icon: const Icon(Icons.replay_rounded, color: Color(0xFF38BDF8), size: 20),
                                onPressed: () {
                                  _speakDialogue(challenge.audioPrompt ?? challenge.npcDialogue);
                                },
                              ),
                            ],
                          ),
                          if (challenge.audioPrompt != null && !_showListeningSubtitles)
                            TextButton.icon(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () {
                                setState(() => _showListeningSubtitles = true);
                              },
                              icon: const Icon(Icons.subtitles_rounded, size: 14, color: Colors.white54),
                              label: Text(
                                'Show subtitles',
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
                              ),
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

                    // Route Builder Tiles if Challenge 7
                    if (isRouteBuilder) ...[
                      _buildRouteBuilderSection(),
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

                    // Feedback & Continue
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'CONTINUE NAVIGATION ➔',
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

  // --- ROUTE BUILDER TILE INTERACTION ---
  Widget _buildRouteBuilderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assembled slots
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
                'YOUR ROUTE ORDER:',
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
                children: _builtRouteTiles.isEmpty
                    ? [
                        Text(
                          'Tap tiles below to order the route...',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                        ),
                      ]
                    : _builtRouteTiles
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
                                _builtRouteTiles.remove(t);
                                _availableRouteTiles.add(t);
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

        // Available tiles
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableRouteTiles
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
                      _availableRouteTiles.remove(tile);
                      _builtRouteTiles.add(tile);
                    });

                    // Check if complete
                    if (_builtRouteTiles.length == 3) {
                      final builtStr = _builtRouteTiles.join(' ');
                      final isMatch = builtStr == 'GO STRAIGHT TURN RIGHT CROSS THE ROAD';
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

  // --- MISSION COMPLETE SCREEN ---
  Widget _buildMissionCompleteModal() {
    final navScore = ((_correctCount / math.max(1, _totalAttempts)) * 100).toInt();
    final listeningScore = math.min(100, 85 + (_combo * 3));
    final commScore = math.min(100, 88 + (_lives * 3));

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
                    const Text('🏙️', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 6),
                    Text(
                      'MISSION 02 COMPLETE!',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'City Navigator Certification Achieved',
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

                    // Score Cards Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox('Navigation', '$navScore%'),
                        _buildStatBox('Listening', '$listeningScore%'),
                        _buildStatBox('Communication', '$commScore%'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Target Vocabulary Bank
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
                            'VOCABULARY LEARNED (20 WORDS)',
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
                            children: kCityTargetVocabulary
                                .take(12)
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

                    // Return / Unlock button
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: Text(
                          'CLAIM CERTIFICATE & UNLOCK LEVEL 3 ✓',
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
              color: const Color(0xFF38BDF8),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2D CANVAS CITY WORLD PAINTER ---
class _CityWorldPainter extends CustomPainter {
  final double cameraX;
  final double playerX;
  final double playerY;
  final PlayerFacing playerFacing;
  final PlayerAnimationState playerAnim;
  final double walkCycle;
  final Offset? targetWaypoint;
  final List<CityLandmark> landmarks;
  final List<CitySign> signs;
  final List<AdventureNpc> npcs;
  final String? highlightedLandmarkId;
  final Offset? activeTargetPos;

  _CityWorldPainter({
    required this.cameraX,
    required this.playerX,
    required this.playerY,
    required this.playerFacing,
    required this.playerAnim,
    required this.walkCycle,
    required this.targetWaypoint,
    required this.landmarks,
    required this.signs,
    required this.npcs,
    required this.highlightedLandmarkId,
    required this.activeTargetPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Background Paving / Terrain
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, 1600, 560), bgPaint);

    // 2. Roads & Sidewalks
    _drawCityRoads(canvas);

    // 3. Landmarks & Buildings
    _drawBuildings(canvas);

    // 4. Street Signs
    _drawStreetSigns(canvas);

    // 5. Active Target Waypoint Pulse
    if (activeTargetPos != null) {
      _drawWaypointPulse(canvas, activeTargetPos!);
    }

    // 6. Tap-to-move Waypoint Marker
    if (targetWaypoint != null) {
      _drawTargetMarker(canvas, targetWaypoint!);
    }

    // 7. NPCs
    _drawNpcs(canvas);

    // 8. Player Character
    _drawPlayer(canvas);

    canvas.restore();
  }

  void _drawCityRoads(Canvas canvas) {
    // Grand Avenue (horizontal central road)
    final roadPaint = Paint()..color = const Color(0xFF1E2430);
    canvas.drawRect(const Rect.fromLTWH(0, 250, 1600, 90), roadPaint);

    // Sidewalk curbs
    final curbPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 250), const Offset(1600, 250), curbPaint);
    canvas.drawLine(const Offset(0, 340), const Offset(1600, 340), curbPaint);

    // Dashed center road dividers
    final dashPaint = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.6)
      ..strokeWidth = 2;
    for (double x = 10; x < 1600; x += 30) {
      canvas.drawLine(Offset(x, 295), Offset(x + 16, 295), dashPaint);
    }

    // Zebra Crosswalks at intersections (x: 270, 770, 1120)
    final zebraPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    for (final cx in [270.0, 770.0, 1120.0]) {
      for (double y = 254; y < 336; y += 14) {
        canvas.drawRect(Rect.fromLTWH(cx, y, 22, 7), zebraPaint);
      }
    }
  }

  void _drawBuildings(Canvas canvas) {
    for (final lm in landmarks) {
      final rect = Rect.fromLTWH(
        lm.position.dx,
        lm.position.dy,
        lm.size.width,
        lm.size.height,
      );

      final isHighlighted = lm.id == highlightedLandmarkId;

      // Glow if highlighted
      if (isHighlighted) {
        final glowPaint = Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(12)),
          glowPaint,
        );
      }

      // Building Base
      final basePaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        basePaint,
      );

      // Building Accent Trim
      final trimPaint = Paint()
        ..color = lm.primaryColor
        ..strokeWidth = isHighlighted ? 3 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        trimPaint,
      );

      // Label on building top
      final textPainter = TextPainter(
        text: TextSpan(
          text: lm.signLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          lm.position.dx + (lm.size.width - textPainter.width) / 2,
          lm.position.dy + 8,
        ),
      );
    }
  }

  void _drawStreetSigns(Canvas canvas) {
    for (final sign in signs) {
      // Pole
      final polePaint = Paint()
        ..color = Colors.white70
        ..strokeWidth = 2;
      canvas.drawLine(sign.position, sign.position + const Offset(0, 20), polePaint);

      // Sign Badge
      final badgeRect = Rect.fromLTWH(sign.position.dx - 22, sign.position.dy - 12, 44, 16);
      final badgePaint = Paint()..color = const Color(0xFF0284C7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
        badgePaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: sign.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          badgeRect.left + (badgeRect.width - tp.width) / 2,
          badgeRect.top + (badgeRect.height - tp.height) / 2,
        ),
      );
    }
  }

  void _drawWaypointPulse(Canvas canvas, Offset pos) {
    final ringPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos + const Offset(50, 40), 22, ringPaint);
  }

  void _drawTargetMarker(Canvas canvas, Offset target) {
    final markerPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(target, 5, markerPaint);
  }

  void _drawNpcs(Canvas canvas) {
    for (final npc in npcs) {
      final pos = Offset(npc.worldX, npc.worldY);

      // Proximity aura
      final auraPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.15);
      canvas.drawCircle(pos, 28, auraPaint);

      // Avatar emoji
      final tp = TextPainter(
        text: TextSpan(
          text: npc.avatarEmoji,
          style: const TextStyle(fontSize: 22),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));

      // Name label
      final nameTp = TextPainter(
        text: TextSpan(
          text: npc.name,
          style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      nameTp.paint(canvas, Offset(pos.dx - nameTp.width / 2, pos.dy + 14));
    }
  }

  void _drawPlayer(Canvas canvas) {
    final pos = Offset(playerX, playerY);

    // Player shadow
    final shadowPaint = Paint()..color = Colors.black38;
    canvas.drawOval(
      Rect.fromCenter(center: pos + const Offset(0, 16), width: 22, height: 8),
      shadowPaint,
    );

    // Player torso/head (Clean modern traveler character)
    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 18, height: 26),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFDBAC);
    canvas.drawCircle(pos - const Offset(0, 15), 8, headPaint);

    // Eyes direction
    final eyePaint = Paint()..color = Colors.black87;
    final eyeOffset = playerFacing == PlayerFacing.left
        ? const Offset(-3, -15)
        : playerFacing == PlayerFacing.right
            ? const Offset(3, -15)
            : const Offset(0, -15);
    canvas.drawCircle(pos + eyeOffset, 1.5, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _CityWorldPainter oldDelegate) => true;
}

// --- MINIMAP PAINTER ---
class _MinimapPainter extends CustomPainter {
  final double worldWidth;
  final double worldHeight;
  final double playerX;
  final double playerY;
  final List<CityLandmark> landmarks;
  final Offset? activeTarget;

  _MinimapPainter({
    required this.worldWidth,
    required this.worldHeight,
    required this.playerX,
    required this.playerY,
    required this.landmarks,
    required this.activeTarget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / worldWidth;
    final scaleY = size.height / worldHeight;

    // Road strip
    final roadPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, 250 * scaleY, size.width, 90 * scaleY), roadPaint);

    // Landmarks
    for (final lm in landmarks) {
      final lmPaint = Paint()..color = lm.primaryColor.withValues(alpha: 0.8);
      canvas.drawRect(
        Rect.fromLTWH(
          lm.position.dx * scaleX,
          lm.position.dy * scaleY,
          lm.size.width * scaleX,
          lm.size.height * scaleY,
        ),
        lmPaint,
      );
    }

    // Active Target Pin
    if (activeTarget != null) {
      final pinPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(
        Offset(activeTarget!.dx * scaleX, activeTarget!.dy * scaleY),
        3.5,
        pinPaint,
      );
    }

    // Player Blip
    final playerPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(
      Offset(playerX * scaleX, playerY * scaleY),
      3.0,
      playerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) => true;
}
