import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fast_fix_models.dart';

/// 2D Flame Game Page for Level 8: Fast Fix
class FastFixGamePage extends StatefulWidget {
  final FastFixLevelData levelData;

  const FastFixGamePage({
    super.key,
    required this.levelData,
  });

  @override
  State<FastFixGamePage> createState() => _FastFixGamePageState();
}

class _FastFixGamePageState extends State<FastFixGamePage> {
  late final FastFixFlameGame _flameGame;
  late final FlutterTts _flutterTts;

  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _hintsUsed = 0;
  int _mistakesCount = 0;
  int _comboStreak = 0;
  int _bestCombo = 0;
  int _stabilityPct = 100;
  bool _audioMuted = false;
  bool _isOptionSelected = false;
  String? _lastExplanation;

  // Challenge 8: Speed Repair State (30s)
  Timer? _speedTimer;
  int _speedSecondsRemaining = 30;

  // Challenge 10: System Override State (60s)
  Timer? _overrideTimer;
  int _overrideSecondsRemaining = 60;
  int _currentOverrideSubIndex = 0;
  final List<String> _overrideAnswers = [];

  // Metrics
  int _grammarFixes = 0;
  int _vocabFixes = 0;
  int _listeningFixes = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlameGame();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.48);
    _flutterTts.setPitch(1.0);
  }

  void _initFlameGame() {
    _flameGame = FastFixFlameGame(
      levelData: widget.levelData,
      onTerminalInteract: () {
        // Player tapped terminal
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentChallenge();
    });
  }

  void _speakCurrentChallenge() {
    if (_audioMuted) return;
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    _speak(challenge.spokenText);
  }

  Future<void> _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _overrideTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _startSpeedRepairTimer() {
    _speedTimer?.cancel();
    setState(() {
      _speedSecondsRemaining = 30;
    });
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_speedSecondsRemaining > 1) {
        setState(() {
          _speedSecondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  void _startOverrideTimer() {
    _overrideTimer?.cancel();
    setState(() {
      _overrideSecondsRemaining = 60;
    });
    _overrideTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_overrideSecondsRemaining > 1) {
        setState(() {
          _overrideSecondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  void _showHintDialog() {
    HapticFeedback.lightImpact();
    setState(() {
      _hintsUsed++;
      if (_scoreXp > 5) _scoreXp -= 5;
    });

    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_rounded,
                color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(
              'Diagnostic Clue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          challenge.hint,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'PROCEED',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0EA5E9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOptionSelected(FixOption option) {
    if (_isOptionSelected) return;

    HapticFeedback.selectionClick();
    setState(() {
      _isOptionSelected = true;
      _lastExplanation = option.explanation;
    });

    if (option.isCorrect) {
      HapticFeedback.mediumImpact();
      final comboBonus = _comboStreak * 5;
      setState(() {
        _scoreXp += option.xpReward + comboBonus;
        _comboStreak++;
        if (_comboStreak > _bestCombo) _bestCombo = _comboStreak;
        _stabilityPct = math.min(100, _stabilityPct + 5);

        final challenge = widget.levelData.challenges[_currentChallengeIndex];
        if (challenge.type == FastFixChallengeType.grammarTerminal ||
            challenge.type == FastFixChallengeType.spotError ||
            challenge.type == FastFixChallengeType.missingWord) {
          _grammarFixes++;
        } else if (challenge.type == FastFixChallengeType.wordChoice) {
          _vocabFixes++;
        } else if (challenge.type == FastFixChallengeType.listenAndCorrect) {
          _listeningFixes++;
        }
      });

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _advanceToNextChallenge();
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _mistakesCount++;
        _comboStreak = 0;
        _stabilityPct = math.max(10, _stabilityPct - 10);
      });

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _isOptionSelected = false;
          _lastExplanation = null;
        });
      });
    }
  }

  void _handleOverrideChoiceSelected(String choice, SystemOverrideSubProblem prob) {
    HapticFeedback.selectionClick();
    final isCorrect = choice == prob.correctAnswer;
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      setState(() {
        _scoreXp += 15;
        _comboStreak++;
        if (_comboStreak > _bestCombo) _bestCombo = _comboStreak;
        _overrideAnswers.add(choice);
        _lastExplanation = prob.explanation;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        final challenge = widget.levelData.challenges[_currentChallengeIndex];
        if (_currentOverrideSubIndex < (challenge.overrideProblems?.length ?? 1) - 1) {
          setState(() {
            _currentOverrideSubIndex++;
            _lastExplanation = null;
          });
        } else {
          _overrideTimer?.cancel();
          _showVictoryDialog();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _mistakesCount++;
        _comboStreak = 0;
        _stabilityPct = math.max(10, _stabilityPct - 10);
        _lastExplanation = 'Incorrect: ${prob.explanation}';
      });
    }
  }

  void _advanceToNextChallenge() {
    if (_currentChallengeIndex < widget.levelData.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _isOptionSelected = false;
        _lastExplanation = null;
      });

      // Handle timers for timed challenges
      final nextChallenge = widget.levelData.challenges[_currentChallengeIndex];
      if (nextChallenge.type == FastFixChallengeType.speedRepair) {
        _startSpeedRepairTimer();
      } else if (nextChallenge.type == FastFixChallengeType.systemOverride) {
        _startOverrideTimer();
      }

      _flameGame.movePlayerToChallenge(_currentChallengeIndex);
      _speakCurrentChallenge();
    } else {
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    final grammarPct = math.min(100, 85 + (_grammarFixes * 3)).clamp(75, 100);
    final vocabPct = math.min(100, 88 + (_vocabFixes * 4)).clamp(75, 100);
    final listeningPct = math.min(100, 82 + (_listeningFixes * 5)).clamp(75, 100);
    final communicationPct = math.max(75, 100 - (_mistakesCount * 4));

    final overall = ((grammarPct + vocabPct + listeningPct + communicationPct) / 4).round();
    final stars = overall >= 90 ? 3 : (overall >= 75 ? 2 : 1);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0EA5E9),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('⚡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            Text(
              'SYSTEM RESTORED!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'All communication errors fixed. Facility 100% operational.',
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isStar = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isStar ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isStar ? const Color(0xFFFFD700) : Colors.white24,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Score Metrics Grid
            Container(
              padding: const EdgeInsets.all(12),
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
                      _metricStat('Grammar', '$grammarPct%'),
                      _metricStat('Vocabulary', '$vocabPct%'),
                      _metricStat('Listening', '$listeningPct%'),
                      _metricStat('Communication', '$communicationPct%'),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricStat('Errors Fixed', '14/14'),
                      _metricStat('Best Combo', '🔥 x$_bestCombo'),
                      _metricStat('Total XP', '+$_scoreXp XP'),
                      _metricStat('Hints', '$_hintsUsed'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'CONTINUE TO DAY 9 🚀',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: const Color(0xFFFFD700),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    final progress = (_currentChallengeIndex + 1) / widget.levelData.challenges.length;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70, size: 18),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.build_circle_rounded,
                color: Color(0xFF0EA5E9), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Fast Fix',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Audio speech toggle
          IconButton(
            icon: Icon(
              _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _audioMuted ? Colors.white38 : const Color(0xFF0EA5E9),
              size: 20,
            ),
            tooltip: 'Toggle Speech Audio',
            onPressed: () {
              setState(() {
                _audioMuted = !_audioMuted;
              });
            },
          ),
          // Hint Lightbulb
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded,
                color: Color(0xFFFFD700), size: 22),
            tooltip: 'Diagnostic Hint',
            onPressed: _showHintDialog,
          ),
          // Stability Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded,
                    color: Color(0xFF10B981), size: 13),
                const SizedBox(width: 3),
                Text(
                  '$_stabilityPct%',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // XP Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 3),
                Text(
                  '$_scoreXp XP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // 🎮 1. Continuous 2D Flame Game Canvas
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final width = MediaQuery.of(context).size.width;
                _flameGame.movePlayerByPixels(details.delta.dx, width);
              },
              child: GameWidget(game: _flameGame),
            ),
          ),

          // 🎯 2. Top HUD: Terminal Code & Diagnostic Progress
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTopDiagnosticHudCard(challenge),
              ],
            ),
          ),

          // ⚡ 3. Combo Streak Banner
          if (_comboStreak >= 2)
            Positioned(
              top: 84,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      'FIX x$_comboStreak${_comboStreak >= 5 ? ' (PERFECT!)' : ''}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🕹️ 4. Bottom Interactive Diagnostic & Terminal Panel
          Positioned(
            bottom: 10,
            left: 12,
            right: 12,
            child: _buildBottomInteractiveTerminalPanel(challenge),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDiagnosticHudCard(FastFixChallenge challenge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Terminal Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              challenge.terminalCode,
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Title & Zone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${challenge.zoneTitle} · CH ${challenge.id}/10',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  challenge.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (challenge.timeLimitSeconds > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_rounded,
                      color: Color(0xFFEF4444), size: 12),
                  const SizedBox(width: 3),
                  Text(
                    challenge.type == FastFixChallengeType.speedRepair
                        ? '${_speedSecondsRemaining}s'
                        : '${_overrideSecondsRemaining}s',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomInteractiveTerminalPanel(FastFixChallenge challenge) {
    if (challenge.type == FastFixChallengeType.systemOverride &&
        challenge.overrideProblems != null) {
      return _buildOverridePanel(challenge);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Corrupted Message Display (Terminal CRT Style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF021727),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0284C7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TERMINAL INPUT LOG',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFF38BDF8), size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _speak(challenge.spokenText),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  challenge.corruptedDisplay,
                  style: GoogleFonts.firaCode(
                    color: const Color(0xFFFF6B6B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          if (_lastExplanation != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _lastExplanation!.contains('Correct') ||
                          _lastExplanation!.contains('Outstanding')
                      ? const Color(0xFF10B981)
                      : Colors.orangeAccent,
                ),
              ),
              child: Text(
                _lastExplanation!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Options
          ...challenge.options.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOptionSelected
                      ? null
                      : () => _handleOptionSelected(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt.id.split('_').last.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opt.text,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 4),

          // Walk Step Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _flameGame.movePlayerLeft(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white60, size: 14),
                    label: Text(
                      'WALK LEFT',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _flameGame.movePlayerRight(),
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white60, size: 14),
                    label: Text(
                      'WALK RIGHT',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverridePanel(FastFixChallenge challenge) {
    final subProb = challenge.overrideProblems![_currentOverrideSubIndex];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CORE OVERRIDE ${_currentOverrideSubIndex + 1}/6 · ${subProb.category.toUpperCase()}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${_overrideSecondsRemaining}s REMAINING',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subProb.corruptedText,
            style: GoogleFonts.firaCode(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_lastExplanation != null) ...[
            const SizedBox(height: 6),
            Text(
              _lastExplanation!,
              style: GoogleFonts.inter(
                color: const Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: subProb.choices.map((choice) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => _handleOverrideChoiceSelected(choice, subProb),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF0EA5E9)),
                      ),
                    ),
                    child: Text(
                      choice,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
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
}

/// 2D Flame Game World for Level 8: Fast Fix
class FastFixFlameGame extends FlameGame with TapCallbacks {
  final FastFixLevelData levelData;
  final VoidCallback onTerminalInteract;

  double playerX = 120.0;
  double targetPlayerX = 120.0;
  bool isMoving = false;
  bool facingRight = true;
  double walkCycle = 0.0;

  static const double worldWidth = 1900.0;
  static const double groundY = 270.0;

  FastFixFlameGame({
    required this.levelData,
    required this.onTerminalInteract,
  });

  void movePlayerByPixels(double dx, double screenWidth) {
    targetPlayerX = (playerX + dx * (worldWidth / screenWidth)).clamp(40.0, worldWidth - 40.0);
    facingRight = dx >= 0;
    isMoving = true;
  }

  void movePlayerLeft() {
    targetPlayerX = (playerX - 100.0).clamp(40.0, worldWidth - 40.0);
    facingRight = false;
    isMoving = true;
  }

  void movePlayerRight() {
    targetPlayerX = (playerX + 100.0).clamp(40.0, worldWidth - 40.0);
    facingRight = true;
    isMoving = true;
  }

  void movePlayerToChallenge(int index) {
    final step = (worldWidth - 200.0) / (levelData.challenges.length - 1);
    targetPlayerX = (100.0 + (index * step)).clamp(40.0, worldWidth - 40.0);
    facingRight = targetPlayerX >= playerX;
    isMoving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((targetPlayerX - playerX).abs() > 2.0) {
      final direction = (targetPlayerX - playerX).sign;
      playerX += direction * 220.0 * dt;
      walkCycle += dt * 8.0;
      isMoving = true;
    } else {
      playerX = targetPlayerX;
      isMoving = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final viewWidth = size.x;
    final cameraX = (playerX - (viewWidth / 2))
        .clamp(0.0, math.max<double>(0.0, worldWidth - viewWidth));

    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Cyber Operations Center Background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF030712), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, worldWidth, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, groundY), bgPaint);

    // 2. Continuous Raised Technical Floor with Glow Grid
    final floorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, groundY, worldWidth, size.y - groundY), floorPaint);

    final gridLinePaint = Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.2)..strokeWidth = 1.2;
    for (double gx = 0; gx < worldWidth; gx += 40) {
      canvas.drawLine(Offset(gx, groundY), Offset(gx, size.y), gridLinePaint);
    }

    // 3. Render Facility Zones
    _renderReceptionZone(canvas);
    _renderCustomerServiceZone(canvas);
    _renderOfficeAreaZone(canvas);
    _renderDocumentRoomZone(canvas);
    _renderControlCenterZone(canvas);

    // 4. Render Player (Technician / Specialist)
    _renderPlayer(canvas, playerX, groundY);

    canvas.restore();
  }

  void _renderReceptionZone(Canvas canvas) {
    // Large Mainframe Monitor (x: 0 .. 380)
    final framePaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(60, 80, 200, 110), const Radius.circular(8)), framePaint);

    final screenPaint = Paint()..color = const Color(0xFF021727);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(66, 86, 188, 98), const Radius.circular(6)), screenPaint);

    // Reception Desk with Terminal 1
    final deskPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50, 205, 220, 65), const Radius.circular(6)), deskPaint);

    // Blinking Error Indicator
    final alertPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(const Offset(240, 100), 6, alertPaint);
  }

  void _renderCustomerServiceZone(Canvas canvas) {
    // Customer Booths (x: 380 .. 740)
    final boothPaint = Paint()..color = const Color(0xFF0F766E);
    canvas.drawRect(const Rect.fromLTWH(420, 110, 130, 160), boothPaint);
    canvas.drawRect(const Rect.fromLTWH(580, 110, 130, 160), boothPaint);

    // Terminal Monitor
    final termPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRect(const Rect.fromLTWH(460, 175, 45, 30), termPaint);
    canvas.drawRect(const Rect.fromLTWH(620, 175, 45, 30), termPaint);
  }

  void _renderOfficeAreaZone(Canvas canvas) {
    // Operations Office Area (x: 740 .. 1120)
    final officeWall = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(const Rect.fromLTWH(770, 70, 310, 200), officeWall);

    // Multi-monitor Desk
    final deskPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(820, 210, 180, 60), const Radius.circular(8)), deskPaint);

    final m1 = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRect(const Rect.fromLTWH(835, 175, 40, 30), m1);
    canvas.drawRect(const Rect.fromLTWH(885, 170, 50, 35), m1);
    canvas.drawRect(const Rect.fromLTWH(945, 175, 40, 30), m1);
  }

  void _renderDocumentRoomZone(Canvas canvas) {
    // Tall Archive Shelves (x: 1120 .. 1520)
    final shelfPaint = Paint()..color = const Color(0xFF312E81);
    canvas.drawRect(const Rect.fromLTWH(1160, 80, 100, 190), shelfPaint);
    canvas.drawRect(const Rect.fromLTWH(1340, 80, 100, 190), shelfPaint);

    // Document Boxes
    final boxPaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1170, 110, 80, 25), const Radius.circular(4)), boxPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1170, 150, 80, 25), const Radius.circular(4)), boxPaint);

    // Sarah NPC avatar
    final sarahBody = Paint()..color = const Color(0xFF8B5CF6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1280, 225, 18, 30), const Radius.circular(4)), sarahBody);
    final sarahHead = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(1289, 215), 9, sarahHead);
  }

  void _renderControlCenterZone(Canvas canvas) {
    // Communication Control Center Core (x: 1520 .. 1900)
    final corePaint = Paint()..color = const Color(0xFF831843);
    canvas.drawRect(const Rect.fromLTWH(1550, 60, 320, 210), corePaint);

    // Server Towers with blinking LED strips
    final rackPaint = Paint()..color = const Color(0xFF111827);
    canvas.drawRect(const Rect.fromLTWH(1580, 80, 55, 190), rackPaint);
    canvas.drawRect(const Rect.fromLTWH(1780, 80, 55, 190), rackPaint);

    final ledPaint = Paint()..color = const Color(0xFF06B6D4);
    for (double ly = 95; ly < 260; ly += 25) {
      canvas.drawCircle(Offset(1607, ly), 3, ledPaint);
      canvas.drawCircle(Offset(1807, ly), 3, ledPaint);
    }

    // Central Holographic Mainframe Sphere
    final holoPaint = Paint()..color = const Color(0xFFEC4899).withValues(alpha: 0.35);
    canvas.drawCircle(const Offset(1710, 160), 45, holoPaint);
  }

  void _renderPlayer(Canvas canvas, double x, double groundY) {
    canvas.save();
    canvas.translate(x, groundY);
    if (!facingRight) {
      canvas.scale(-1.0, 1.0);
    }

    final swing = isMoving ? math.sin(walkCycle) * 10 : 0.0;

    // Legs
    final legPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 5..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-4, -18), Offset(-4 + swing, 0), legPaint);
    canvas.drawLine(const Offset(4, -18), Offset(4 - swing, 0), legPaint);

    // Body (Cyan IT Uniform Vest)
    final bodyPaint = Paint()..color = const Color(0xFF0EA5E9);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -42, 18, 26), const Radius.circular(6)), bodyPaint);

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFD1A4);
    canvas.drawCircle(const Offset(0, -50), 10, headPaint);

    // Headset / Cap
    final capPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawArc(const Rect.fromLTWH(-10, -60, 20, 16), math.pi, math.pi, true, capPaint);

    // Diagnostic Tablet / Tool
    final toolPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, -32, 10, 14), const Radius.circular(2)), toolPaint);

    canvas.restore();
  }
}
