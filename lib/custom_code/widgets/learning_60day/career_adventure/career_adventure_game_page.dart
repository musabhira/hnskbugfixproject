import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adventure_models.dart';

enum PlayerFacing { left, right, up, down }

enum PlayerAnimationState {
  idle,
  walking,
  talking,
  celebrating,
  confused,
}

/// 🏢 Career Adventure 2D Mobile Game Screen
class CareerAdventureGamePage extends StatefulWidget {
  final AdventureLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const CareerAdventureGamePage({
    super.key,
    this.levelData = kMission01LevelData,
    this.onCompleted,
  });

  @override
  State<CareerAdventureGamePage> createState() =>
      _CareerAdventureGamePageState();
}

class _CareerAdventureGamePageState extends State<CareerAdventureGamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final FlutterTts _tts = FlutterTts();

  // World & Camera
  final double _worldWidth = 1400.0;
  final double _worldHeight = 560.0;
  double _cameraX = 0.0;

  // Player State
  double _playerX = 120.0;
  double _playerY = 340.0;
  PlayerFacing _playerFacing = PlayerFacing.right;
  PlayerAnimationState _playerAnim = PlayerAnimationState.idle;
  double _playerWalkCycle = 0.0;
  Offset? _targetWaypoint;

  // Virtual Joystick
  double _joystickDx = 0.0;
  double _joystickDy = 0.0;
  bool _isJoystickActive = false;

  // Game Progression
  int _currentChallengeIndex = 0;
  int _lives = 3;
  int _scoreXp = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _isLevelFinished = false;

  // Active Challenge Modal State
  bool _isChallengeModalOpen = false;
  AdventureChallenge? _activeChallenge;
  int? _selectedOptionIndex;
  bool _hasAnsweredCurrent = false;

  // Sentence Builder State (Challenge 7)
  List<String> _builtSentenceWords = [];
  List<String> _availableSentenceTiles = [];

  // Quick Response Timer (Challenge 8)
  Timer? _quickResponseTimer;
  int _quickResponseRemaining = 8;

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

    // Opening greeting after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakDialogue(
          'You have an appointment at 10:00 AM at Apex Corporate Tower. Explore the office and complete your conversation challenges.');
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
    _quickResponseTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  // --- 🔄 60 FPS GAME LOOP ---
  void _gameLoop() {
    if (!mounted) return;
    final dt = 0.016;

    // Handle Joystick / Waypoint Movement
    double moveDx = 0.0;
    double moveDy = 0.0;

    if (_isJoystickActive) {
      moveDx = _joystickDx;
      moveDy = _joystickDy;
    } else if (_targetWaypoint != null) {
      final diffX = _targetWaypoint!.dx - _playerX;
      final diffY = _targetWaypoint!.dy - _playerY;
      final dist = math.sqrt(diffX * diffX + diffY * diffY);

      if (dist < 8.0) {
        _targetWaypoint = null;
      } else {
        moveDx = (diffX / dist) * 0.8;
        moveDy = (diffY / dist) * 0.8;
      }
    }

    if (moveDx != 0.0 || moveDy != 0.0) {
      final moveSpeed = 190.0 * dt;
      _playerX = (_playerX + moveDx * moveSpeed).clamp(40.0, _worldWidth - 60.0);
      _playerY = (_playerY + moveDy * moveSpeed).clamp(180.0, _worldHeight - 80.0);

      _playerWalkCycle += dt * 10.0;
      _playerAnim = PlayerAnimationState.walking;

      if (moveDx.abs() > moveDy.abs()) {
        _playerFacing = moveDx > 0 ? PlayerFacing.right : PlayerFacing.left;
      } else {
        _playerFacing = moveDy > 0 ? PlayerFacing.down : PlayerFacing.up;
      }
    } else if (_playerAnim == PlayerAnimationState.walking) {
      _playerAnim = PlayerAnimationState.idle;
    }

    // Camera follow player horizontally
    final screenWidth = MediaQuery.of(context).size.width;
    final targetCamX = (_playerX - screenWidth * 0.45).clamp(
      0.0,
      math.max(0.0, _worldWidth - screenWidth),
    );
    _cameraX += (targetCamX - _cameraX) * 0.12;

    setState(() {});
  }

  // Check which NPC is near player
  AdventureNpc? get _nearbyNpc {
    for (final npc in widget.levelData.npcs) {
      final dist = (Offset(_playerX, _playerY) - Offset(npc.worldX, npc.worldY)).distance;
      if (dist < 90.0) {
        return npc;
      }
    }
    return null;
  }

  AdventureChallenge get _activeCurrentChallenge {
    return widget.levelData.challenges[
        _currentChallengeIndex.clamp(0, widget.levelData.challenges.length - 1)];
  }

  void _openChallengeModal(AdventureChallenge challenge) {
    HapticFeedback.lightImpact();
    setState(() {
      _isChallengeModalOpen = true;
      _activeChallenge = challenge;
      _selectedOptionIndex = null;
      _hasAnsweredCurrent = false;
      _playerAnim = PlayerAnimationState.talking;

      // Setup sentence builder tiles if challenge 7
      if (challenge.type == AdventureChallengeType.sentenceBuilder &&
          challenge.sentenceTiles != null) {
        _availableSentenceTiles = List<String>.from(challenge.sentenceTiles!)..shuffle();
        _builtSentenceWords = [];
      }

      // Setup timer if quick response (challenge 8)
      if (challenge.type == AdventureChallengeType.quickResponse &&
          challenge.timeLimitSeconds != null) {
        _quickResponseRemaining = challenge.timeLimitSeconds!;
        _startQuickResponseTimer();
      }
    });

    _speakDialogue(challenge.audioPrompt ?? challenge.npcDialogue);
  }

  void _startQuickResponseTimer() {
    _quickResponseTimer?.cancel();
    _quickResponseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_quickResponseRemaining > 1) {
          _quickResponseRemaining--;
        } else {
          _quickResponseRemaining = 0;
          _quickResponseTimer?.cancel();
          if (!_hasAnsweredCurrent) {
            _handleOptionSelected(1); // auto-submit wrong on timeout
          }
        }
      });
    });
  }

  void _handleOptionSelected(int index) {
    if (_hasAnsweredCurrent) return;
    _quickResponseTimer?.cancel();

    final challenge = _activeChallenge!;
    final option = challenge.options[index];
    _totalAttempts++;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnsweredCurrent = true;
    });

    if (option.isCorrect) {
      // ✅ Correct
      HapticFeedback.mediumImpact();
      _correctCount++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;

      int earned = challenge.xpReward;
      if (_combo >= 3) earned += 15;
      else if (_combo >= 2) earned += 10;
      _scoreXp += earned;

      _playerAnim = PlayerAnimationState.celebrating;
      _speakDialogue(option.reaction ?? 'Great job!');
    } else {
      // ❌ Wrong
      HapticFeedback.heavyImpact();
      _combo = 0;
      _lives--;
      _playerAnim = PlayerAnimationState.confused;
      _speakDialogue(option.feedback);
    }
  }

  void _advanceToNextChallenge() {
    _quickResponseTimer?.cancel();
    setState(() {
      _isChallengeModalOpen = false;
      _activeChallenge = null;
      _playerAnim = PlayerAnimationState.idle;

      if (_lives <= 0) {
        // Refill hearts gently
        _lives = 3;
        _combo = 0;
      } else if (_currentChallengeIndex >= widget.levelData.challenges.length - 1) {
        _isLevelFinished = true;
        _speakDialogue('Mission Complete! You passed your office career conversation challenge.');
      } else {
        _currentChallengeIndex++;
        // Auto position guide to next zone
        final nextChallenge = _activeCurrentChallenge;
        final targetNpc = widget.levelData.npcs.firstWhere(
          (n) => n.id == nextChallenge.npcId,
          orElse: () => widget.levelData.npcs.first,
        );
        _speakDialogue('Proceed to ${targetNpc.name} at the ${targetNpc.role}.');
      }
    });
  }

  // --- 🎨 BUILD ---
  @override
  Widget build(BuildContext context) {
    final nearbyNpc = _nearbyNpc;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // 1. Layer: 2D Office World Canvas (Scrolling with Camera)
          GestureDetector(
            onTapDown: (details) {
              final tapWorldX = details.localPosition.dx + _cameraX;
              final tapWorldY = details.localPosition.dy;
              setState(() {
                _targetWaypoint = Offset(tapWorldX, tapWorldY);
              });
            },
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _ModernOfficeWorldPainter(
                  cameraX: _cameraX,
                  worldWidth: _worldWidth,
                  worldHeight: _worldHeight,
                  npcs: widget.levelData.npcs,
                  activeChallengeNpcId: _activeCurrentChallenge.npcId,
                  targetWaypoint: _targetWaypoint,
                ),
              ),
            ),
          ),

          // 2. Layer: 2D Animated Player Character
          Positioned(
            left: _playerX - _cameraX - 25.0,
            top: _playerY - 50.0,
            child: IgnorePointer(
              child: SizedBox(
                width: 50,
                height: 60,
                child: CustomPaint(
                  painter: _CorporatePlayerPainter(
                    facing: _playerFacing,
                    animState: _playerAnim,
                    walkCycle: _playerWalkCycle,
                  ),
                ),
              ),
            ),
          ),

          // 3. Layer: Top Status Bar (Level, Objective, Hearts, Combos, XP)
          _buildTopStatusBar(),

          // 4. Layer: Quick Navigation Pill / Quest Objective
          _buildActiveQuestBanner(),

          // 5. Layer: Virtual Joystick (Bottom Left)
          _buildVirtualJoystick(),

          // 6. Layer: Action / Talk Button (Bottom Right)
          if (nearbyNpc != null && !_isChallengeModalOpen)
            _buildInteractButton(nearbyNpc),

          // 7. Layer: Interactive Challenge Dialogue Modal
          if (_isChallengeModalOpen && _activeChallenge != null)
            _buildChallengeModal(),

          // 8. Layer: Level Complete Results Dashboard
          if (_isLevelFinished)
            _buildLevelCompleteOverlay(),
        ],
      ),
    );
  }

  // --- 🏆 TOP STATUS BAR ---
  Widget _buildTopStatusBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            // Close Button
            InkWell(
              onTap: () => Navigator.of(context).pop(false),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 8),

            // ❤️ 3 Lives
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      i < _lives ? '❤️' : '🤍',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // 🔥 Combo Badge
            if (_combo > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '$_combo COMBO',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(width: 8),

            // ⭐ XP Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '+$_scoreXp XP',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Mute Toggle
            InkWell(
              onTap: () => setState(() => _isMuted = !_isMuted),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 📍 ACTIVE QUEST BANNER ---
  Widget _buildActiveQuestBanner() {
    final challenge = _activeCurrentChallenge;
    final targetNpc = widget.levelData.npcs.firstWhere(
      (n) => n.id == challenge.npcId,
      orElse: () => widget.levelData.npcs.first,
    );

    return Positioned(
      top: 64,
      left: 14,
      right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(targetNpc.avatarEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CHALLENGE ${_currentChallengeIndex + 1}/10: ${challenge.title}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Speak with ${targetNpc.name} (${targetNpc.role})',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // "NAVIGATE" Action Button
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _targetWaypoint = Offset(targetNpc.worldX - 45.0, targetNpc.worldY);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'GO 🏃',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🕹️ VIRTUAL JOYSTICK ---
  Widget _buildVirtualJoystick() {
    return Positioned(
      left: 20,
      bottom: 24,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isJoystickActive = true;
            _targetWaypoint = null;
          });
        },
        onPanUpdate: (details) {
          final rad = 45.0;
          final dx = details.localPosition.dx - 45.0;
          final dy = details.localPosition.dy - 45.0;
          final dist = math.sqrt(dx * dx + dy * dy);
          if (dist > 0) {
            final clampDist = dist.clamp(0.0, rad);
            setState(() {
              _joystickDx = (dx / dist) * (clampDist / rad);
              _joystickDy = (dy / dist) * (clampDist / rad);
            });
          }
        },
        onPanEnd: (_) {
          setState(() {
            _isJoystickActive = false;
            _joystickDx = 0.0;
            _joystickDy = 0.0;
            _playerAnim = PlayerAnimationState.idle;
          });
        },
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Center(
            child: Transform.translate(
              offset: Offset(_joystickDx * 24, _joystickDy * 24),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 💬 INTERACT BUTTON ---
  Widget _buildInteractButton(AdventureNpc npc) {
    return Positioned(
      right: 20,
      bottom: 28,
      child: GestureDetector(
        onTap: () => _openChallengeModal(_activeCurrentChallenge),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(npc.avatarEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'TALK / INTERACT 💬',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🧩 CHALLENGE DIALOGUE MODAL ---
  Widget _buildChallengeModal() {
    final challenge = _activeChallenge!;
    final npc = widget.levelData.npcs.firstWhere(
      (n) => n.id == challenge.npcId,
      orElse: () => widget.levelData.npcs.first,
    );

    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NPC Header Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(npc.avatarEmoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              npc.name,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              npc.role,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF38BDF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Audio Replay Icon
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 24),
                        onPressed: () => _speakDialogue(challenge.audioPrompt ?? challenge.npcDialogue),
                        tooltip: 'Replay audio',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Dialogue Speech Bubble
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '"${challenge.npcDialogue}"',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ),

                  // Quick Response Countdown Bar (Challenge 8)
                  if (challenge.type == AdventureChallengeType.quickResponse) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.timer_rounded, color: Color(0xFFF97316), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'TIME REMAINING: ${_quickResponseRemaining}s',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFF97316),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _quickResponseRemaining / (challenge.timeLimitSeconds ?? 8),
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                          _quickResponseRemaining > 3 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Question Prompt
                  Text(
                    challenge.question,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Interactive Sentence Builder (Challenge 7)
                  if (challenge.type == AdventureChallengeType.sentenceBuilder)
                    _buildSentenceBuilderArea(challenge)
                  else
                    // Multiple Choice Options
                    ...List.generate(challenge.options.length, (index) {
                      final option = challenge.options[index];
                      final isSelected = _selectedOptionIndex == index;
                      final showResult = _hasAnsweredCurrent;

                      Color borderColor = Colors.white24;
                      Color bgColor = const Color(0xFF1E293B);

                      if (showResult) {
                        if (option.isCorrect) {
                          borderColor = const Color(0xFF10B981);
                          bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
                        } else if (isSelected && !option.isCorrect) {
                          borderColor = const Color(0xFFEF4444);
                          bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: _hasAnsweredCurrent ? null : () => _handleOptionSelected(index),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 1.4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  String.fromCharCode(65 + index),
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (showResult && option.isCorrect)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                                else if (showResult && isSelected && !option.isCorrect)
                                  const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  // Feedback & Explanation Banner
                  if (_hasAnsweredCurrent) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _activeChallenge!.options[_selectedOptionIndex!].isCorrect
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _activeChallenge!.options[_selectedOptionIndex!].isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeChallenge!.options[_selectedOptionIndex!].isCorrect
                                ? '🎯 SPOT ON!'
                                : '⚠️ LEARNING FEEDBACK:',
                            style: GoogleFonts.outfit(
                              color: _activeChallenge!.options[_selectedOptionIndex!].isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _activeChallenge!.options[_selectedOptionIndex!].feedback,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Key Word: "${challenge.targetVocabulary}" - ${challenge.vocabularyMeaning}',
                            style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _advanceToNextChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _currentChallengeIndex >= widget.levelData.challenges.length - 1
                              ? 'COMPLETE MISSION 01 🚀'
                              : 'CONTINUE EXPLORATION ➔',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
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
    );
  }

  // --- 🧩 SENTENCE BUILDER WIDGET (Challenge 7) ---
  Widget _buildSentenceBuilderArea(AdventureChallenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Answer Slot
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
          ),
          child: _builtSentenceWords.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to arrange your sentence...',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _builtSentenceWords.map((word) {
                    return InkWell(
                      onTap: _hasAnsweredCurrent
                          ? null
                          : () {
                              setState(() {
                                _builtSentenceWords.remove(word);
                                _availableSentenceTiles.add(word);
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          word,
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 12),

        // Word Bank Tiles
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSentenceTiles.map((tile) {
            return InkWell(
              onTap: _hasAnsweredCurrent
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _availableSentenceTiles.remove(tile);
                        _builtSentenceWords.add(tile);
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  tile,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        if (!_hasAnsweredCurrent)
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _availableSentenceTiles = List<String>.from(challenge.sentenceTiles!)..shuffle();
                    _builtSentenceWords = [];
                  });
                },
                child: const Text('RESET', style: TextStyle(color: Colors.white60)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _builtSentenceWords.length == (challenge.sentenceTiles?.length ?? 0)
                    ? () {
                        final formed = _builtSentenceWords.join(' ');
                        final isCorrect = formed.toLowerCase() == challenge.targetSentence?.toLowerCase();
                        _handleOptionSelected(isCorrect ? 0 : 0);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('SUBMIT SENTENCE ✓'),
              ),
            ],
          ),
      ],
    );
  }

  // --- 🎉 LEVEL COMPLETE DASHBOARD ---
  Widget _buildLevelCompleteOverlay() {
    final accuracy = _totalAttempts > 0 ? ((_correctCount / _totalAttempts) * 100).round() : 100;
    int stars = 1;
    if (accuracy >= 85 && _lives >= 2) stars = 3;
    else if (accuracy >= 70) stars = 2;

    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                  Text(
                    List.generate(stars, (_) => '⭐').join(' '),
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'MISSION 01 COMPLETE!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'The First Conversation · Apex Headquarters',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 18),

                  // Metrics Box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricItem('⭐ XP EARNED', '+$_scoreXp', const Color(0xFF10B981)),
                      _buildMetricItem('🔥 BEST COMBO', '$_bestCombo', const Color(0xFFF97316)),
                      _buildMetricItem('🎯 ACCURACY', '$accuracy%', const Color(0xFF38BDF8)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Vocabulary Learned Grid
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mastered Workplace Vocabulary (Tap to listen):',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.levelData.targetVocabularyList.map((word) {
                      return InkWell(
                        onTap: () => _speakDialogue(word),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 12),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Finish Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        widget.onCompleted?.call(_scoreXp);
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'CLAIM REWARDS & COMPLETE STEP 4 ✓',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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

  Widget _buildMetricItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// --- 🎨 MODERN OFFICE 2D ENVIRONMENT PAINTER ---
class _ModernOfficeWorldPainter extends CustomPainter {
  final double cameraX;
  final double worldWidth;
  final double worldHeight;
  final List<AdventureNpc> npcs;
  final String activeChallengeNpcId;
  final Offset? targetWaypoint;

  _ModernOfficeWorldPainter({
    required this.cameraX,
    required this.worldWidth,
    required this.worldHeight,
    required this.npcs,
    required this.activeChallengeNpcId,
    this.targetWaypoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Polished Marble & Modern Floor Tiles
    final floorPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), floorPaint);

    // Grid tile lines
    final linePaint = Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.4)..strokeWidth = 1;
    for (double x = 0; x < worldWidth; x += 60) {
      canvas.drawLine(Offset(x, 140), Offset(x, worldHeight), linePaint);
    }
    for (double y = 140; y < worldHeight; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(worldWidth, y), linePaint);
    }

    // Top Office Wall / Glass Windows with City Skyline
    final wallPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, 140), wallPaint);

    // Modern glass panoramic windows
    final glassPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.15);
    for (double x = 40; x < worldWidth; x += 160) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 20, 110, 100), const Radius.circular(8)),
        glassPaint,
      );
    }

    // --- ZONE 1: Street Entrance & Glass Plaza (X: 0 - 300) ---
    _drawEntrancePlaza(canvas);

    // --- ZONE 2: Reception Desk & Kiosk (X: 300 - 550) ---
    _drawReceptionDesk(canvas);

    // --- ZONE 3: Waiting Lounge & Coffee Bar (X: 550 - 800) ---
    _drawWaitingLounge(canvas);

    // --- ZONE 4: Office Corridor & Meeting Pods (X: 800 - 1100) ---
    _drawCorridorAndPods(canvas);

    // --- ZONE 5: Executive Interview Chamber (X: 1100 - 1400) ---
    _drawInterviewRoom(canvas);

    // Draw NPCs with glowing interaction circles
    for (final npc in npcs) {
      final isTarget = npc.id == activeChallengeNpcId;
      _drawNpc(canvas, npc, isTarget);
    }

    // Draw Tap-to-walk Waypoint Marker
    if (targetWaypoint != null) {
      final wpPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(targetWaypoint!, 12, wpPaint);
      canvas.drawCircle(targetWaypoint!, 4, Paint()..color = const Color(0xFF38BDF8));
    }

    canvas.restore();
  }

  void _drawEntrancePlaza(Canvas canvas) {
    // Sliding Glass Doors
    final doorPaint = Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(80, 120, 80, 16), const Radius.circular(4)),
      doorPaint,
    );
    // Security Turnstiles
    final turnstilePaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRect(const Rect.fromLTWH(180, 200, 12, 40), turnstilePaint);
    canvas.drawRect(const Rect.fromLTWH(210, 200, 12, 40), turnstilePaint);
    // Potted plant
    _drawPottedPlant(canvas, 50, 200);
  }

  void _drawReceptionDesk(Canvas canvas) {
    // Curved Oak Counter
    final counterPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(330, 290, 130, 45), const Radius.circular(12)),
      counterPaint,
    );
    // Logo banner
    final bannerPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(360, 295, 70, 10), const Radius.circular(4)),
      bannerPaint,
    );
    // Digital Kiosk
    canvas.drawRect(const Rect.fromLTWH(480, 250, 18, 32), Paint()..color = const Color(0xFF1E293B));
  }

  void _drawWaitingLounge(Canvas canvas) {
    // Leather Sofa
    final sofaPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(580, 220, 70, 36), const Radius.circular(8)),
      sofaPaint,
    );
    // Coffee Table
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(595, 270, 40, 22), const Radius.circular(4)),
      Paint()..color = const Color(0xFF94A3B8),
    );
    // Water Dispenser
    canvas.drawRect(const Rect.fromLTWH(730, 210, 16, 38), Paint()..color = const Color(0xFF38BDF8));
    _drawPottedPlant(canvas, 755, 210);
  }

  void _drawCorridorAndPods(Canvas canvas) {
    // Glass Meeting Room Wall
    final glassWallPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(const Rect.fromLTWH(820, 160, 200, 120), glassWallPaint);

    // Meeting Room 3 Plaque
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(850, 150, 60, 14), const Radius.circular(3)),
      Paint()..color = const Color(0xFFF59E0B),
    );
  }

  void _drawInterviewRoom(Canvas canvas) {
    // Conference Table
    final tablePaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(1140, 240, 130, 60), const Radius.circular(16)),
      tablePaint,
    );
    // Executive Chairs
    final chairPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(1205, 220), 14, chairPaint);
    canvas.drawCircle(const Offset(1205, 320), 14, chairPaint);
  }

  void _drawPottedPlant(Canvas canvas, double x, double y) {
    // Pot
    canvas.drawRect(Rect.fromLTWH(x, y + 14, 16, 14), Paint()..color = const Color(0xFF92400E));
    // Green Foliage
    canvas.drawCircle(Offset(x + 8, y + 8), 12, Paint()..color = const Color(0xFF16A34A));
  }

  void _drawNpc(Canvas canvas, AdventureNpc npc, bool isTarget) {
    final center = Offset(npc.worldX, npc.worldY);

    // Glowing interaction ring
    final ringPaint = Paint()
      ..color = isTarget ? const Color(0xFFFFD700) : const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isTarget ? 2.5 : 1.5;
    canvas.drawCircle(center, 28, ringPaint);

    // Soft glow
    if (isTarget) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center, 32, glowPaint);
    }

    // NPC Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(npc.worldX, npc.worldY + 18), width: 30, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Text Painter for NPC Emoji
    final textPainter = TextPainter(
      text: TextSpan(text: npc.avatarEmoji, style: const TextStyle(fontSize: 26)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(npc.worldX - 13, npc.worldY - 20));

    // Name Banner Overhead
    final namePainter = TextPainter(
      text: TextSpan(
        text: npc.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Color(0xFF0F172A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    namePainter.paint(canvas, Offset(npc.worldX - (namePainter.width / 2), npc.worldY - 38));
  }

  @override
  bool shouldRepaint(covariant _ModernOfficeWorldPainter oldDelegate) => true;
}

// --- 👔 CORPORATE PLAYER VECTOR PAINTER ---
class _CorporatePlayerPainter extends CustomPainter {
  final PlayerFacing facing;
  final PlayerAnimationState animState;
  final double walkCycle;

  _CorporatePlayerPainter({
    required this.facing,
    required this.animState,
    required this.walkCycle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.45;
    final bobY = math.sin(walkCycle) * 2.5;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 4), width: 24, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final legSwing = animState == PlayerAnimationState.walking ? math.sin(walkCycle) * 7.0 : 0.0;
    canvas.drawLine(Offset(cx - 5, cy + 12 + bobY), Offset(cx - 5 - legSwing, size.height - 6), legPaint);
    canvas.drawLine(Offset(cx + 5, cy + 12 + bobY), Offset(cx + 5 + legSwing, size.height - 6), legPaint);

    // Smart Casual Navy Jacket
    final jacketPaint = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 2 + bobY), width: 20, height: 20), const Radius.circular(5)),
      jacketPaint,
    );

    // Tie / Collar
    canvas.drawLine(Offset(cx, cy - 6 + bobY), Offset(cx, cy + 4 + bobY), Paint()..color = const Color(0xFFDC2626)..strokeWidth = 2);

    // Head
    canvas.drawCircle(Offset(cx, cy - 12 + bobY), 10, Paint()..color = const Color(0xFFFFD1A4));

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 15 + bobY), width: 20, height: 12),
      math.pi,
      math.pi,
      true,
      hairPaint,
    );

    // Face Direction
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    if (facing == PlayerFacing.right) {
      canvas.drawCircle(Offset(cx + 4, cy - 12 + bobY), 1.5, eyePaint);
    } else if (facing == PlayerFacing.left) {
      canvas.drawCircle(Offset(cx - 4, cy - 12 + bobY), 1.5, eyePaint);
    } else {
      canvas.drawCircle(Offset(cx - 3, cy - 12 + bobY), 1.5, eyePaint);
      canvas.drawCircle(Offset(cx + 3, cy - 12 + bobY), 1.5, eyePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CorporatePlayerPainter oldDelegate) => true;
}
