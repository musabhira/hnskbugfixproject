import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lost_package_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 📦 Level 6: Mission 06 – The Lost Package (Flutter + Flame 2D Investigation)
// ─────────────────────────────────────────────────────────────────────────────

class LostPackageGamePage extends StatefulWidget {
  final LostPackageLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const LostPackageGamePage({
    super.key,
    this.levelData = kMission06LostPackageData,
    this.onCompleted,
  });

  @override
  State<LostPackageGamePage> createState() => _LostPackageGamePageState();
}

class _LostPackageGamePageState extends State<LostPackageGamePage> {
  late LostPackageFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  // Progress & Game State
  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _hintsUsed = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _audioMuted = false;
  bool _isLevelComplete = false;

  // Document Inspection State
  DeliveryDocumentData? _inspectingDocument;

  // Smart Locker PIN Pad State (Challenge 10)
  String _enteredPin = '';
  Timer? _lockerCountdown;
  int _lockerSecondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlameGame();

    // Initial narrative speech after mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCurrentChallenge();
    });
  }

  void _initTts() {
    try {
      _tts.setLanguage('en-US');
      _tts.setSpeechRate(0.46);
      _tts.setPitch(1.0);
    } catch (_) {}
  }

  void _initFlameGame() {
    _flameGame = LostPackageFlameGame(
      currentChallenge: widget.levelData.challenges[_currentChallengeIndex],
      onPlayerReachedZone: _handlePlayerReachedZone,
      onPlayerInspectDocument: _handlePlayerInspectDocument,
      onPlayerSelectPackage: _handlePackageSelected,
      onPlayerInteractLocker: _handleLockerInteracted,
    );
  }

  Future<void> _speak(String text) async {
    if (_audioMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _startCurrentChallenge() {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    _flameGame.loadChallenge(challenge);
    _enteredPin = '';

    if (challenge.type == LostPackageChallengeType.lockerCode) {
      _startLockerTimer();
    }

    if (challenge.document != null) {
      _speak(challenge.document!.spokenText);
    }
  }

  void _startLockerTimer() {
    _lockerCountdown?.cancel();
    setState(() {
      _lockerSecondsRemaining = 60;
    });

    _lockerCountdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_lockerSecondsRemaining > 1) {
        setState(() {
          _lockerSecondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  void _handlePlayerReachedZone(String zoneId) {
    // Player entered zone
  }

  void _handlePlayerInspectDocument() {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    if (challenge.document != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _inspectingDocument = challenge.document;
      });
      _speak(challenge.document!.spokenText);
    }
  }

  void _handlePackageSelected(String ref) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    if (challenge.type == LostPackageChallengeType.packageSearch) {
      final isCorrect = ref == challenge.targetReference;
      _handleAnswerOption(
        LostPackageOption(
          text: ref,
          isCorrect: isCorrect,
          feedback: isCorrect
              ? 'Package Found! PK-4827 is the correct parcel!'
              : 'Incorrect package. Please look for PK-4827.',
        ),
      );
    }
  }

  void _handleLockerInteracted() {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    if (challenge.type == LostPackageChallengeType.lockerCode) {
      setState(() {
        _inspectingDocument = challenge.document;
      });
    }
  }

  void _handleAnswerOption(LostPackageOption option) {
    _totalAttempts++;
    HapticFeedback.mediumImpact();

    if (option.isCorrect) {
      _correctCount++;
      final earnedXp =
          widget.levelData.challenges[_currentChallengeIndex].xpReward;

      setState(() {
        _scoreXp += earnedXp;
        _inspectingDocument = null;
      });

      _speak('Correct! ${option.feedback}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Correct! +$earnedXp XP — ${option.feedback}',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(milliseconds: 1600),
        ),
      );

      // Advance to next challenge
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        if (_currentChallengeIndex + 1 < widget.levelData.challenges.length) {
          setState(() {
            _currentChallengeIndex++;
          });
          _startCurrentChallenge();
        } else {
          // Level Completed!
          _lockerCountdown?.cancel();
          setState(() {
            _isLevelComplete = true;
          });
          widget.onCompleted?.call(_scoreXp);
          _showVictoryDialog();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      _speak('Incorrect. ${option.feedback}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${option.feedback}',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(milliseconds: 1800),
        ),
      );
    }
  }

  void _showHintDialog() {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    setState(() {
      _hintsUsed++;
    });
    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF38BDF8)),
        ),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_rounded,
                color: Color(0xFFFFD700), size: 22),
            const SizedBox(width: 8),
            Text(
              'Investigation Clue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ${challenge.hint1}',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '• ${challenge.hint2}',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'GOT IT',
              style: GoogleFonts.outfit(
                color: const Color(0xFF38BDF8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    final accuracy = _totalAttempts > 0
        ? ((_correctCount / _totalAttempts) * 100).round()
        : 100;
    final stars = accuracy >= 88 && _hintsUsed <= 1
        ? 3
        : accuracy >= 70
            ? 2
            : 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                blurRadius: 28,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📦', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 6),
              Text(
                'PACKAGE RECOVERED!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mission 06 – The Lost Package Cleared · PK-4827 Retrieved',
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
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFFD700),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Metrics
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF030712).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric(
                        'READING ACCURACY', '$accuracy%', const Color(0xFF10B981)),
                    _buildMetric(
                        'XP GAINED', '+$_scoreXp', const Color(0xFFFFD700)),
                    _buildMetric('HINTS USED', '$_hintsUsed', const Color(0xFF38BDF8)),
                    _buildMetric('WORDS', '20+', const Color(0xFFEC4899)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Target Vocabulary Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: widget.levelData.targetVocabulary
                    .take(8)
                    .map(
                      (w) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          w,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'CONTINUE MISSION (VERIFY +50 PTS)',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
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
    );
  }

  Widget _buildMetric(String title, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _lockerCountdown?.cancel();
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    final progress =
        (_currentChallengeIndex + 1) / widget.levelData.challenges.length;

    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1120),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(_isLevelComplete),
        ),
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded,
                color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'The Lost Package',
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
          // Audio Read-aloud Toggle
          IconButton(
            icon: Icon(
              _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _audioMuted ? Colors.white38 : const Color(0xFF38BDF8),
              size: 20,
            ),
            tooltip: 'Toggle Read-Aloud Audio',
            onPressed: () {
              setState(() {
                _audioMuted = !_audioMuted;
              });
            },
          ),
          // Clue Hint Icon
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded,
                color: Color(0xFFFFD700), size: 22),
            tooltip: 'Investigation Clue',
            onPressed: _showHintDialog,
          ),
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

          // 🎯 2. Top HUD: Mission Objective & Progress
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
                        const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                _buildMissionHudCard(challenge),
              ],
            ),
          ),

          // 📄 3. Document Inspection Modal Overlay
          if (_inspectingDocument != null)
            Positioned(
              top: 130,
              left: 16,
              right: 16,
              child: _buildDocumentOverlayCard(_inspectingDocument!),
            ),

          // 🔢 4. Smart Locker 24 PIN Keypad (Challenge 10)
          if (challenge.type == LostPackageChallengeType.lockerCode)
            Positioned(
              bottom: 90,
              left: 20,
              right: 20,
              child: _buildLockerPinPad(challenge),
            ),

          // 🕹️ 5. Bottom Navigation & Action Question HUD
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: _buildBottomInteractionPanel(challenge),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionHudCard(LostPackageChallenge challenge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'INVESTIGATION ${challenge.id} / 10',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  'REF: ${widget.levelData.targetReference}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (challenge.document != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _inspectingDocument = challenge.document;
                    });
                    _speak(challenge.document!.spokenText);
                  },
                  icon: const Icon(Icons.description_rounded,
                      color: Color(0xFF38BDF8), size: 16),
                  label: Text(
                    'INSPECT 📄',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challenge.objective,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentOverlayCard(DeliveryDocumentData doc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_rounded,
                  color: Color(0xFF38BDF8), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      doc.subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 20),
                onPressed: () {
                  setState(() {
                    _inspectingDocument = null;
                  });
                },
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          // Key Fields
          ...doc.keyFields.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${e.key}: ',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    e.value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            doc.bodyText,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _speak(doc.spokenText),
                icon: const Icon(Icons.volume_up_rounded, size: 14),
                label: const Text('READ ALOUD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: const Color(0xFF38BDF8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _inspectingDocument = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockerPinPad(LostPackageChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEC4899), width: 1.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔐 SMART LOCKER 24 ACCESS KEYPAD',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFEC4899),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '00:$_lockerSecondsRemaining',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // PIN Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEC4899)),
            ),
            child: Text(
              _enteredPin.isEmpty
                  ? '_ _ _ _'
                  : _enteredPin.split('').join('  '),
              style: GoogleFonts.outfit(
                color: const Color(0xFF00F0FF),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Keypad Buttons
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'].map((digit) {
                return SizedBox(
                  width: 44,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      if (_enteredPin.length < 4) {
                        setState(() {
                          _enteredPin += digit;
                        });
                      }
                      if (_enteredPin.length == 4) {
                        final isCorrect =
                            _enteredPin == challenge.targetLockerCode;
                        _handleAnswerOption(
                          LostPackageOption(
                            text: _enteredPin,
                            isCorrect: isCorrect,
                            feedback: isCorrect
                                ? 'Locker 24 Unlocked! Package PK-4827 retrieved!'
                                : 'Code sequence $_enteredPin is incorrect. Pass reads 7316.',
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      digit,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(
                width: 60,
                height: 38,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    if (_enteredPin.isNotEmpty) {
                      setState(() {
                        _enteredPin =
                            _enteredPin.substring(0, _enteredPin.length - 1);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.backspace_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInteractionPanel(LostPackageChallenge challenge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Question Options
        if (challenge.options.isNotEmpty &&
            challenge.type != LostPackageChallengeType.lockerCode)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (challenge.question != null) ...[
                  Text(
                    challenge.question!,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Column(
                  children: challenge.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _handleAnswerOption(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              option.text,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Movement Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWalkButton(
              icon: Icons.arrow_back_rounded,
              label: 'WALK LEFT',
              onTap: () => _flameGame.movePlayerRelative(-40),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Text(
                'ZONE: ${_flameGame.currentZoneName}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildWalkButton(
              icon: Icons.arrow_forward_rounded,
              label: 'WALK RIGHT',
              onTap: () => _flameGame.movePlayerRelative(40),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalkButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 Flame 2D World Implementation for The Lost Package
// ─────────────────────────────────────────────────────────────────────────────

class LostPackageFlameGame extends FlameGame with TapCallbacks {
  LostPackageChallenge currentChallenge;
  final void Function(String zoneId) onPlayerReachedZone;
  final VoidCallback onPlayerInspectDocument;
  final void Function(String packageRef) onPlayerSelectPackage;
  final VoidCallback onPlayerInteractLocker;

  LostPackageFlameGame({
    required this.currentChallenge,
    required this.onPlayerReachedZone,
    required this.onPlayerInspectDocument,
    required this.onPlayerSelectPackage,
    required this.onPlayerInteractLocker,
  });

  static const double worldWidth = 1950.0;
  static const double worldHeight = 560.0;
  double playerX = 160.0;
  double playerY = 380.0;
  double cameraX = 0.0;
  bool isWalking = false;
  double walkCycle = 0.0;
  bool facingRight = true;

  String currentZoneName = 'Market Street';

  @override
  Color backgroundColor() => const Color(0xFF070D18);

  void loadChallenge(LostPackageChallenge challenge) {
    currentChallenge = challenge;
  }

  void movePlayerRelative(double deltaX) {
    playerX = (playerX + deltaX).clamp(40.0, worldWidth - 60.0);
    facingRight = deltaX >= 0;
    isWalking = true;
    _checkZoneArrival();
  }

  void movePlayerByPixels(double deltaX, double screenWidth) {
    if (screenWidth > 0) {
      playerX = (playerX + deltaX).clamp(40.0, worldWidth - 60.0);
      facingRight = deltaX >= 0;
      isWalking = true;
      _checkZoneArrival();
    }
  }

  void _checkZoneArrival() {
    for (final zone in kMission06LostPackageData.zones) {
      if (playerX >= zone.startX && playerX <= zone.endX) {
        currentZoneName = zone.name;
        onPlayerReachedZone(zone.id);
        break;
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final worldTapX = event.localPosition.x + cameraX;
    playerX = worldTapX.clamp(40.0, worldWidth - 60.0);
    isWalking = true;
    _checkZoneArrival();

    // Check tapping on Directory Board (x: 560)
    if ((worldTapX - 560).abs() < 80) {
      onPlayerInspectDocument();
    }

    // Check tapping on Parcel Storage (x: 1350)
    if ((worldTapX - 1350).abs() < 120) {
      onPlayerSelectPackage('PK-4827');
    }

    // Check tapping on Locker 24 (x: 1750)
    if ((worldTapX - 1750).abs() < 80) {
      onPlayerInteractLocker();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isWalking) {
      walkCycle += dt * 10.0;
    }

    // Camera follow player
    final targetCameraX =
        (playerX - (size.x * 0.4)).clamp(0.0, worldWidth - size.x);
    cameraX += (targetCameraX - cameraX) * 0.12;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Environmental Zones
    _renderEnvironmentZones(canvas);

    // 2. Ground & Flooring
    _renderGround(canvas);

    // 3. Physical Objects (Directory, Reception, Packages, Lockers)
    _renderWorldObjects(canvas);

    // 4. Animated Player Avatar
    _renderPlayer(canvas);

    canvas.restore();
  }

  void _renderGround(Canvas canvas) {
    final floorPaint = Paint()..color = const Color(0xFF0F172A);
    final curbPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
      ..strokeWidth = 2.0;

    canvas.drawRect(
      const Rect.fromLTWH(0, 420, worldWidth, 140),
      floorPaint,
    );
    canvas.drawLine(
      const Offset(0, 420),
      const Offset(worldWidth, 420),
      curbPaint,
    );
  }

  void _renderEnvironmentZones(Canvas canvas) {
    for (final zone in kMission06LostPackageData.zones) {
      final rect =
          Rect.fromLTWH(zone.startX, 100, zone.endX - zone.startX, 320);

      final bgPaint = Paint()..color = zone.primaryColor.withValues(alpha: 0.12);
      canvas.drawRect(rect, bgPaint);

      final borderPaint = Paint()
        ..color = zone.primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRect(rect, borderPaint);

      final textSpan = TextSpan(
        text: '${zone.tag}: ${zone.name}',
        style: GoogleFonts.outfit(
          color: zone.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(zone.startX + 16, 110));
    }
  }

  void _renderWorldObjects(Canvas canvas) {
    // 1. Directory Board (x: 560)
    final dirPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(510, 240, 100, 180),
        const Radius.circular(8),
      ),
      dirPaint,
    );

    // 2. Reception Counter & Computer (x: 950)
    final recepPaint = Paint()..color = const Color(0xFF8B5CF6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(900, 300, 130, 120),
        const Radius.circular(8),
      ),
      recepPaint,
    );

    // 3. Storage Shelves with 4 Packages (x: 1350)
    final shelfPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRect(const Rect.fromLTWH(1280, 240, 140, 180), shelfPaint);

    // Render individual parcels with reference tags
    final packages = kMission06LostPackageData.storagePackages;
    for (int i = 0; i < packages.length; i++) {
      final pkg = packages[i];
      final px = 1290.0 + ((i % 2) * 65.0);
      final py = 260.0 + ((i ~/ 2) * 70.0);

      final boxPaint = Paint()..color = pkg.boxColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(px, py, 55, 45),
          const Radius.circular(6),
        ),
        boxPaint,
      );

      final labelSpan = TextSpan(
        text: pkg.referenceNumber,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(px + 4, py + 16));
    }

    // 4. Smart Locker Bay (Lockers 22, 23, 24, 25) (x: 1750)
    final lockerBankPaint = Paint()..color = const Color(0xFFEC4899);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1680, 220, 150, 200),
        const Radius.circular(10),
      ),
      lockerBankPaint,
    );
  }

  void _renderPlayer(Canvas canvas) {
    final cx = playerX;
    final cy = playerY;

    final bodyPaint = Paint()..color = const Color(0xFF10B981);
    final headPaint = Paint()..color = const Color(0xFFFFD700);

    // Head
    canvas.drawCircle(Offset(cx, cy - 32), 12, headPaint);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 8), width: 22, height: 32),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Walking legs animation
    final legSwing = math.sin(walkCycle) * 8.0;
    final legPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(cx - 5, cy + 8),
      Offset(cx - 5 + legSwing, cy + 28),
      legPaint,
    );
    canvas.drawLine(
      Offset(cx + 5, cy + 8),
      Offset(cx + 5 - legSwing, cy + 28),
      legPaint,
    );
  }
}
