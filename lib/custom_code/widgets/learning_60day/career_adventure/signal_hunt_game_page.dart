import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signal_hunt_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 📡 Level 5: Mission 05 – Signal Hunt (Flutter + Flame 2D Listening Adventure)
// ─────────────────────────────────────────────────────────────────────────────

class SignalHuntGamePage extends StatefulWidget {
  final SignalHuntLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const SignalHuntGamePage({
    super.key,
    this.levelData = kMission05SignalHuntData,
    this.onCompleted,
  });

  @override
  State<SignalHuntGamePage> createState() => _SignalHuntGamePageState();
}

class _SignalHuntGamePageState extends State<SignalHuntGamePage> {
  late SignalHuntFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  // Progress & Game State
  int _currentChallengeIndex = 0;
  int _scoreXp = 0;
  int _replaysUsed = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;
  double _speechRate = 0.46; // default 1.0x normal speed
  bool _audioMuted = false;
  bool _showTranscript = false;
  bool _isLevelComplete = false;
  bool _isPhoneCallActive = false;

  // Timed Challenge 9 State
  Timer? _countdownTimer;
  int _secondsRemaining = 6;
  bool _isTimedActive = false;

  // Interactive Challenges States
  final Set<String> _selectedCafeItems = {};
  int? _selectedTicketNumber;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlameGame();

    // Trigger initial audio instructions after mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCurrentChallenge();
    });
  }

  void _initTts() {
    try {
      _tts.setLanguage('en-US');
      _tts.setSpeechRate(_speechRate);
      _tts.setPitch(1.0);
    } catch (_) {}
  }

  void _initFlameGame() {
    _flameGame = SignalHuntFlameGame(
      currentChallenge: widget.levelData.challenges[_currentChallengeIndex],
      onPlayerReachedZone: _handlePlayerReachedZone,
      onPlayerInteract: _handlePlayerInteractWithObject,
    );
  }

  Future<void> _speak(String text, {double? rate}) async {
    if (_audioMuted) return;
    try {
      await _tts.stop();
      if (rate != null) await _tts.setSpeechRate(rate);
      await _tts.speak(text);
    } catch (_) {}
  }

  void _startCurrentChallenge() {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    _flameGame.loadChallenge(challenge);
    _showTranscript = false;
    _selectedCafeItems.clear();
    _selectedTicketNumber = null;

    if (challenge.type == SignalHuntChallengeType.phoneCall) {
      // Simulate phone ringing with haptics
      setState(() {
        _isPhoneCallActive = true;
      });
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 300), () {
        HapticFeedback.vibrate();
      });
    } else if (challenge.type == SignalHuntChallengeType.fastDecision) {
      _startTimedDecision();
      _speak(challenge.audio.spokenText);
    } else {
      _speak(challenge.audio.spokenText);
    }
  }

  void _replayAudio() {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    setState(() {
      _replaysUsed++;
    });
    HapticFeedback.selectionClick();
    _speak(challenge.audio.spokenText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔊 Replaying Audio Signal (Replays: $_replaysUsed)',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0284C7),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _toggleSpeed() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_speechRate < 0.40) {
        _speechRate = 0.46; // 1.0x
      } else if (_speechRate < 0.50) {
        _speechRate = 0.56; // 1.25x
      } else {
        _speechRate = 0.36; // 0.75x
      }
      _tts.setSpeechRate(_speechRate);
    });

    final label = _speechRate > 0.50
        ? '1.25x (Fast)'
        : _speechRate < 0.40
            ? '0.75x (Slow)'
            : '1.0x (Normal)';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Audio Speed: $label',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _startTimedDecision() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 6;
      _isTimedActive = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        t.cancel();
        setState(() {
          _isTimedActive = false;
        });
        // Time ran out
        _handleAnswerOption(
          SignalHuntOption(
            text: 'TIME EXPIRED',
            isCorrect: false,
            feedback: 'Time is up! The manager was waiting at the office entrance.',
          ),
        );
      }
    });
  }

  void _handlePlayerReachedZone(String zoneId) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    if (challenge.type == SignalHuntChallengeType.listenAndMove &&
        zoneId == challenge.targetZoneId) {
      _handleAnswerOption(challenge.options.firstWhere((o) => o.isCorrect));
    }
  }

  void _handlePlayerInteractWithObject(String objectId) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    if (challenge.type == SignalHuntChallengeType.numberListening &&
        objectId == 'ticket_${challenge.targetNumber}') {
      _handleAnswerOption(challenge.options.firstWhere((o) => o.isCorrect));
    }
  }

  void _handleAnswerOption(SignalHuntOption option) {
    _countdownTimer?.cancel();
    _totalAttempts++;
    HapticFeedback.mediumImpact();

    if (option.isCorrect) {
      _correctCount++;
      int earnedXp = widget.levelData.challenges[_currentChallengeIndex].xpReward;
      if (_replaysUsed == 0) earnedXp += 5; // No-replay bonus
      if (_isTimedActive) earnedXp += 15; // Quick response bonus

      setState(() {
        _scoreXp += earnedXp;
        _isTimedActive = false;
      });

      _speak('Nice listening! ${option.feedback}');

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

      // Advance to next challenge after brief pause
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        if (_currentChallengeIndex + 1 < widget.levelData.challenges.length) {
          setState(() {
            _currentChallengeIndex++;
          });
          _startCurrentChallenge();
        } else {
          // All 10 challenges complete!
          setState(() {
            _isLevelComplete = true;
          });
          widget.onCompleted?.call(_scoreXp);
          _showLevelCompletionModal();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      _speak('Listen again. ${option.feedback}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Try Again. ${option.feedback}',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(milliseconds: 1800),
        ),
      );
    }
  }

  void _showLevelCompletionModal() {
    HapticFeedback.heavyImpact();
    final accuracy = _totalAttempts > 0
        ? ((_correctCount / _totalAttempts) * 100).round()
        : 100;
    final stars = accuracy >= 88 && _replaysUsed <= 2
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
            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📡', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 6),
              Text(
                'SIGNAL MASTER!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mission 05 – Signal Hunt Cleared · 10 Challenges Mastered',
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
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFFFFD700),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Metrics Grid
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
                    _buildMetric('ACCURACY', '$accuracy%', const Color(0xFF10B981)),
                    _buildMetric('XP GAINED', '+$_scoreXp', const Color(0xFFFFD700)),
                    _buildMetric('REPLAYS', '$_replaysUsed', const Color(0xFF38BDF8)),
                    _buildMetric('WORDS', '17+', const Color(0xFFEC4899)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Vocabulary Pill Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: widget.levelData.targetVocabulary
                    .take(8)
                    .map(
                      (w) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    backgroundColor: const Color(0xFF0284C7),
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
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.levelData.challenges[_currentChallengeIndex];
    final progress = (_currentChallengeIndex + 1) / widget.levelData.challenges.length;

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
            const Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Signal Hunt',
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
          // Audio Speed Toggle
          TextButton(
            onPressed: _toggleSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _speechRate > 0.50
                    ? '1.25x'
                    : _speechRate < 0.40
                        ? '0.75x'
                        : '1.0x',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          // Audio Mute Toggle
          IconButton(
            icon: Icon(
              _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _audioMuted ? Colors.white38 : const Color(0xFF38BDF8),
              size: 20,
            ),
            tooltip: 'Toggle Audio Mute',
            onPressed: () {
              setState(() {
                _audioMuted = !_audioMuted;
              });
            },
          ),
          // Subtitle / Transcript Toggle
          IconButton(
            icon: Icon(
              _showTranscript ? Icons.subtitles_rounded : Icons.subtitles_off_rounded,
              color: _showTranscript ? const Color(0xFFFFD700) : Colors.white54,
              size: 20,
            ),
            tooltip: 'Toggle Transcript',
            onPressed: () {
              setState(() {
                _showTranscript = !_showTranscript;
              });
            },
          ),
          // Audio Replay Icon
          IconButton(
            icon: const Icon(Icons.replay_circle_filled_rounded,
                color: Color(0xFF00F0FF), size: 22),
            tooltip: 'Replay Spoken Audio',
            onPressed: _replayAudio,
          ),
          // XP Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
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
          // 🎮 1. Continuous 2D Flame Game World Canvas
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final width = MediaQuery.of(context).size.width;
                _flameGame.movePlayerByPixels(details.delta.dx, width);
              },
              child: GameWidget(game: _flameGame),
            ),
          ),

          // 🎯 2. Top HUD: Mission Progress & Spoken Audio Speaker Card
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
                        const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                _buildAudioMissionCard(challenge),
              ],
            ),
          ),

          // 📞 3. Phone Call Overlay (for Challenge 3)
          if (_isPhoneCallActive)
            Positioned(
              top: 140,
              left: 20,
              right: 20,
              child: _buildPhoneCallDialog(challenge),
            ),

          // 🥪 4. Interactive Café Food Tray (for Challenge 5)
          if (challenge.type == SignalHuntChallengeType.itemSelection)
            Positioned(
              bottom: 90,
              left: 14,
              right: 14,
              child: _buildCafeItemSelector(challenge),
            ),

          // 🎫 5. Interactive Ticket Counter Dispenser (for Challenge 4)
          if (challenge.type == SignalHuntChallengeType.numberListening)
            Positioned(
              bottom: 90,
              left: 14,
              right: 14,
              child: _buildTicketSelector(challenge),
            ),

          // ⚡ 6. Fast Timed Decision Bar (for Challenge 9)
          if (_isTimedActive)
            Positioned(
              top: 180,
              left: 30,
              right: 30,
              child: _buildTimedCountdownBar(),
            ),

          // 🕹️ 7. Bottom Navigation & Action Question HUD
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

  Widget _buildAudioMissionCard(SignalHuntChallenge challenge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: challenge.hasBackgroundNoise
              ? const Color(0xFFF59E0B)
              : const Color(0xFF38BDF8).withValues(alpha: 0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SIGNAL ${challenge.id} / 10',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${challenge.audio.avatarEmoji} ${challenge.audio.speaker}',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (challenge.hasBackgroundNoise) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Text(
                    '⚠️ NOISE DETECTED',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF59E0B),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Replay button directly on card
              InkWell(
                onTap: _replayAudio,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.volume_up_rounded,
                      color: Color(0xFF00F0FF), size: 20),
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
          if (_showTranscript) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Transcript: "${challenge.audio.spokenText}"',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFD700),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneCallDialog(SignalHuntChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.35),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('📲', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INCOMING VOICE CALL',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    challenge.audio.speaker,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isPhoneCallActive = false;
                  });
                  _speak(challenge.audio.spokenText);
                },
                icon: const Icon(Icons.call_end_rounded,
                    color: Colors.white, size: 16),
                label: const Text('DISMISS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'The caller says: "${challenge.audio.spokenText}"',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCafeItemSelector(SignalHuntChallenge challenge) {
    final available = challenge.availableItems ?? [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD97706), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🥪 Select the 2 items ordered by your colleague:',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: available.map((item) {
              final isSelected = _selectedCafeItems.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                selectedColor: const Color(0xFFD97706),
                checkmarkColor: Colors.black,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedCafeItems.add(item);
                    } else {
                      _selectedCafeItems.remove(item);
                    }
                  });

                  if (_selectedCafeItems.length == 2) {
                    final target = challenge.targetItems ?? [];
                    final isAllCorrect =
                        _selectedCafeItems.containsAll(target);
                    _handleAnswerOption(
                      SignalHuntOption(
                        text: _selectedCafeItems.join(' and '),
                        isCorrect: isAllCorrect,
                        feedback: isAllCorrect
                            ? 'You collected the Chicken sandwich and Bottle of water.'
                            : 'Incorrect items selected. Listen to the audio again.',
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelector(SignalHuntChallenge challenge) {
    final options = challenge.ticketOptions ?? [68, 71, 78, 87];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎫 Information Desk Ticket Board (Select Announced Ticket):',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((ticketNum) {
              final isSelected = _selectedTicketNumber == ticketNum;
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTicketNumber = ticketNum;
                  });
                  final isCorrect = ticketNum == challenge.targetNumber;
                  _handleAnswerOption(
                    SignalHuntOption(
                      text: 'Ticket $ticketNum',
                      isCorrect: isCorrect,
                      feedback: isCorrect
                          ? 'Collected ticket $ticketNum successfully!'
                          : 'Ticket $ticketNum does not match the announcement.',
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF8B5CF6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '#$ticketNum',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimedCountdownBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'DECIDE QUICKLY: 00:0$_secondsRemaining SECONDS',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInteractionPanel(SignalHuntChallenge challenge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Question Options Container
        if (challenge.options.isNotEmpty)
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
        // Movement & Action Controls
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
                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0284C7)),
              ),
              child: Text(
                'ZONE: ${_flameGame.currentZoneName}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
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
// 🎮 Continuous 2D Flame Game Implementation
// ─────────────────────────────────────────────────────────────────────────────

class SignalHuntFlameGame extends FlameGame with TapCallbacks {
  SignalHuntChallenge currentChallenge;
  final void Function(String zoneId) onPlayerReachedZone;
  final void Function(String objectId) onPlayerInteract;

  SignalHuntFlameGame({
    required this.currentChallenge,
    required this.onPlayerReachedZone,
    required this.onPlayerInteract,
  });

  // World & Camera coordinates
  static const double worldWidth = 1900.0;
  static const double worldHeight = 560.0;
  double playerX = 180.0;
  double playerY = 380.0;
  double cameraX = 0.0;
  bool isWalking = false;
  double walkCycle = 0.0;
  bool facingRight = true;

  String currentZoneName = 'Transit Plaza';

  @override
  Color backgroundColor() => const Color(0xFF070D18);

  void loadChallenge(SignalHuntChallenge challenge) {
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
    for (final zone in kMission05SignalHuntData.zones) {
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

    // Check if player tapped near interactive objects
    if ((worldTapX - 1280).abs() < 70) {
      onPlayerInteract('ticket_78');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isWalking) {
      walkCycle += dt * 10.0;
    }

    // Smooth Camera Follow
    final targetCameraX = (playerX - (size.x * 0.4)).clamp(0.0, worldWidth - size.x);
    cameraX += (targetCameraX - cameraX) * 0.12;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Draw 2D Environment Zones
    _renderEnvironmentZones(canvas);

    // 2. Draw Floor & Sidewalk
    _renderGround(canvas);

    // 3. Draw Landmarks & Signs
    _renderLandmarks(canvas);

    // 4. Draw Animated Player Avatar
    _renderPlayer(canvas);

    canvas.restore();
  }

  void _renderGround(Canvas canvas) {
    final floorPaint = Paint()..color = const Color(0xFF0F172A);
    final curbPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
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
    final zones = kMission05SignalHuntData.zones;

    for (final zone in zones) {
      final rect = Rect.fromLTWH(zone.startX, 100, zone.endX - zone.startX, 320);

      // Building/Zone backdrop
      final bgPaint = Paint()..color = zone.primaryColor.withValues(alpha: 0.12);
      canvas.drawRect(rect, bgPaint);

      // Border outline
      final borderPaint = Paint()
        ..color = zone.primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRect(rect, borderPaint);

      // Zone Sign Header
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

  void _renderLandmarks(Canvas canvas) {
    // 1. Bus Stop (x: 180)
    final busStopPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(140, 260, 80, 160),
        const Radius.circular(8),
      ),
      busStopPaint,
    );

    // 2. Café Counter (x: 540)
    final cafePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(500, 300, 120, 120),
        const Radius.circular(8),
      ),
      cafePaint,
    );

    // 3. Main Entrance Glass Door (x: 900)
    final doorPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.4);
    canvas.drawRect(const Rect.fromLTWH(850, 240, 100, 180), doorPaint);

    // 4. Ticket Dispenser (x: 1280)
    final ticketPaint = Paint()..color = const Color(0xFF8B5CF6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1240, 310, 80, 110),
        const Radius.circular(8),
      ),
      ticketPaint,
    );

    // 5. Room 204 Door (x: 1560) & Room 208 Door (x: 1760)
    final roomPaint = Paint()..color = const Color(0xFFEC4899);
    canvas.drawRect(const Rect.fromLTWH(1520, 240, 70, 180), roomPaint);
    canvas.drawRect(const Rect.fromLTWH(1720, 240, 70, 180), roomPaint);
  }

  void _renderPlayer(Canvas canvas) {
    final cx = playerX;
    final cy = playerY;

    final bodyPaint = Paint()..color = const Color(0xFF38BDF8);
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

    // Animated walking legs
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
