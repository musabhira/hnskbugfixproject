import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cyber_vocab_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 Cyber Vocab Striker: 60FPS Flame-Powered Vocabulary Action Game
// ─────────────────────────────────────────────────────────────────────────────

class CyberVocabGamePage extends StatefulWidget {
  final VocabStrikerLevelData levelData;
  final ValueChanged<int>? onCompleted;

  const CyberVocabGamePage({
    super.key,
    this.levelData = kMission02VocabStrikerData,
    this.onCompleted,
  });

  @override
  State<CyberVocabGamePage> createState() => _CyberVocabGamePageState();
}

class _CyberVocabGamePageState extends State<CyberVocabGamePage> {
  late CyberVocabFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  int _currentWaveIndex = 0;
  int _scoreXp = 0;
  int _shields = 3;
  int _combo = 0;
  int _bestCombo = 0;
  bool _audioMuted = false;
  bool _isLevelComplete = false;
  VocabWordItem? _justMasteredWord;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlameGame();
  }

  void _initTts() {
    try {
      _tts.setLanguage('en-US');
      _tts.setSpeechRate(0.48);
      _tts.setPitch(1.0);
    } catch (_) {
      // Graceful fallback if TTS is unavailable
    }
  }

  void _speakWord(String text) {
    if (_audioMuted) return;
    try {
      _tts.stop();
      _tts.speak(text);
    } catch (_) {}
  }

  void _initFlameGame() {
    _flameGame = CyberVocabFlameGame(
      currentWave: widget.levelData.waves[_currentWaveIndex],
      onWordHit: _handleWordHit,
      onMissedWord: _handleMissedWord,
      onPowerUpCollected: _handlePowerUpCollected,
    );
  }

  @override
  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  void _handleWordHit(String word, bool isCorrect) {
    HapticFeedback.mediumImpact();
    if (isCorrect) {
      final currentWave = widget.levelData.waves[_currentWaveIndex];
      _speakWord(currentWave.target.word);

      setState(() {
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        final comboMultiplier = math.min(1 + (_combo ~/ 3), 4);
        _scoreXp += 150 * comboMultiplier;
        _justMasteredWord = currentWave.target;
      });

      // Advance wave after brief celebration
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (_currentWaveIndex + 1 < widget.levelData.waves.length) {
          setState(() {
            _currentWaveIndex++;
            _justMasteredWord = null;
          });
          _flameGame.loadWave(widget.levelData.waves[_currentWaveIndex]);
        } else {
          // Level Completed!
          setState(() {
            _isLevelComplete = true;
          });
          widget.onCompleted?.call(_scoreXp);
          _showVictoryDialog();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _combo = 0;
        _shields = math.max(0, _shields - 1);
      });
      if (_shields <= 0) {
        // Recharge shield after warning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Shield depleted! Emergency cyber reboot restored 1 shield.',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _shields = 1;
        });
      }
    }
  }

  void _handleMissedWord() {
    HapticFeedback.lightImpact();
    setState(() {
      _combo = 0;
    });
  }

  void _handlePowerUpCollected(StrikerPowerUpType powerUp) {
    HapticFeedback.selectionClick();
    setState(() {
      if (powerUp == StrikerPowerUpType.shieldBoost) {
        _shields = math.min(5, _shields + 1);
      }
      _scoreXp += 50;
    });

    final name = powerUp == StrikerPowerUpType.slowMotion
        ? '⚡ Time Slow-Mo Activated!'
        : powerUp == StrikerPowerUpType.shieldBoost
            ? '🛡️ Deflector Shield Restored!'
            : '💡 Target Frequency Scanner Online!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0284C7),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _showVictoryDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildVictoryDialog(ctx),
    );
  }

  Widget _buildVictoryDialog(BuildContext ctx) {
    final waves = widget.levelData.waves;
    return Dialog(
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
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              'MISSION ACCOMPLISHED!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cyber Vocab Striker Cleared · 10 Words Mastered',
              style: GoogleFonts.inter(
                color: const Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatPill('SCORE', '$_scoreXp XP', Icons.stars_rounded,
                    const Color(0xFFFFD700)),
                _buildStatPill('BEST COMBO', '${_bestCombo}x', Icons.bolt_rounded,
                    const Color(0xFF00F0FF)),
                _buildStatPill('STARS', '⭐⭐⭐', Icons.military_tech_rounded,
                    const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 16),
            // Vocabulary Review List
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF030712).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: waves.length,
                separatorBuilder: (_, __) => const Divider(
                    color: Colors.white10, height: 8, thickness: 1),
                itemBuilder: (_, i) {
                  final item = waves[i].target;
                  return Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.word} · ${item.phonetic}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        item.malayalamMeaning.split(' / ').first,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // dismiss dialog
                  Navigator.of(context).pop(true); // return true to parent page
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
                        fontSize: 14,
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
    );
  }

  Widget _buildStatPill(
      String title, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWave = widget.levelData.waves[_currentWaveIndex];
    final progress = (_currentWaveIndex + 1) / widget.levelData.waves.length;

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
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
            const Icon(Icons.bolt_rounded, color: Color(0xFF38BDF8), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Cyber Vocab Striker',
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
          // Audio Mute Toggle
          IconButton(
            icon: Icon(
              _audioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _audioMuted ? Colors.white38 : const Color(0xFF38BDF8),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _audioMuted = !_audioMuted;
              });
            },
          ),
          // Shield Hearts
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Icon(
                i < _shields
                    ? Icons.shield_rounded
                    : Icons.shield_outlined,
                color: i < _shields
                    ? const Color(0xFF38BDF8)
                    : Colors.white24,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // 🎮 1. Flame 60FPS Game Canvas
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final width = MediaQuery.of(context).size.width;
                _flameGame.moveShipByPixels(details.delta.dx, width);
              },
              child: GameWidget(game: _flameGame),
            ),
          ),

          // 🎯 2. Top HUD: Mission Clue & Objective Display
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Wave Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 8),
                // Clue Card
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'WAVE ${_currentWaveIndex + 1} / ${widget.levelData.waves.length}',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (_combo > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🔥 ${_combo}x STREAK',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Audio Speaker Button
                          InkWell(
                            onTap: () =>
                                _speakWord(currentWave.target.word),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.volume_up_rounded,
                                  color: Color(0xFF38BDF8), size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Clue Question / Definition
                      Text(
                        currentWave.cluePrompt,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Malayalam meaning & phonetic helper
                      Row(
                        children: [
                          const Icon(Icons.translate_rounded,
                              color: Color(0xFFFFD700), size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${currentWave.target.malayalamMeaning} · ${currentWave.target.phonetic}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✨ 3. Word Mastered Celebration Overlay Banner
          if (_justMasteredWord != null)
            Positioned(
              top: 140,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF022C22)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DECRYPTED: ${_justMasteredWord!.word}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _justMasteredWord!.definition,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🕹️ 4. Bottom Controls / Quick Interceptor Steer Bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Steer Left Button
                _buildDirectionBtn(
                  icon: Icons.arrow_left_rounded,
                  label: 'STEER LEFT',
                  onTap: () => _flameGame.moveShipRelative(-0.16),
                ),
                // Tap/Fire Laser Pulse Button
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _flameGame.fireLaser();
                  },
                  icon: const Icon(Icons.gps_fixed_rounded,
                      color: Colors.black, size: 18),
                  label: Text(
                    'FIRE LASER ⚡',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F0FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                ),
                // Steer Right Button
                _buildDirectionBtn(
                  icon: Icons.arrow_right_rounded,
                  label: 'STEER RIGHT',
                  onTap: () => _flameGame.moveShipRelative(0.16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionBtn({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 Flame 60FPS Game Implementation
// ─────────────────────────────────────────────────────────────────────────────

class CyberVocabFlameGame extends FlameGame with TapCallbacks {
  VocabStrikerWave currentWave;
  final void Function(String word, bool isCorrect) onWordHit;
  final VoidCallback onMissedWord;
  final void Function(StrikerPowerUpType powerUp) onPowerUpCollected;

  CyberVocabFlameGame({
    required this.currentWave,
    required this.onWordHit,
    required this.onMissedWord,
    required this.onPowerUpCollected,
  });

  // Game state entities
  double shipNormalizedX = 0.5; // 0.0 to 1.0
  final List<FallingNode> _nodes = [];
  final List<LaserBeam> _lasers = [];
  final List<ExplosionParticle> _particles = [];
  final List<StarParticle> _stars = [];

  bool isSlowMoActive = false;
  double slowMoTimer = 0.0;
  bool isClueMatrixActive = false;
  double clueMatrixTimer = 0.0;
  double gameTime = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF030712);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initStars();
    loadWave(currentWave);
  }

  void _initStars() {
    final rng = math.Random();
    for (int i = 0; i < 45; i++) {
      _stars.add(
        StarParticle(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          speed: 0.05 + rng.nextDouble() * 0.15,
          radius: 0.8 + rng.nextDouble() * 1.5,
          color: i % 3 == 0
              ? const Color(0xFF38BDF8)
              : i % 3 == 1
                  ? const Color(0xFF818CF8)
                  : Colors.white70,
        ),
      );
    }
  }

  void loadWave(VocabStrikerWave wave) {
    currentWave = wave;
    _nodes.clear();
    _lasers.clear();

    final allWords = wave.allChoices;
    final rng = math.Random();

    // Spawn 4 nodes spaced across screen width
    for (int i = 0; i < allWords.length; i++) {
      final word = allWords[i];
      final isTarget = word == wave.target.word;
      final slotX = 0.14 + (i * 0.24) + ((rng.nextDouble() - 0.5) * 0.06);

      _nodes.add(
        FallingNode(
          word: word,
          isTarget: isTarget,
          x: slotX.clamp(0.08, 0.92),
          y: -40.0 - (rng.nextDouble() * 80.0),
          speed: 45.0 + rng.nextDouble() * 20.0,
          wobblePhase: rng.nextDouble() * math.pi * 2,
        ),
      );
    }

    // Spawn bonus power-up if available
    if (wave.bonusPowerUp != null) {
      isClueMatrixActive = false;
      isSlowMoActive = false;
    }
  }

  void moveShipRelative(double deltaX) {
    shipNormalizedX = (shipNormalizedX + deltaX).clamp(0.1, 0.9);
  }

  void moveShipByPixels(double deltaX, double screenWidth) {
    if (screenWidth > 0) {
      shipNormalizedX =
          (shipNormalizedX + (deltaX / screenWidth)).clamp(0.08, 0.92);
    }
  }

  void fireLaser() {
    final shipX = shipNormalizedX * size.x;
    final shipY = size.y - 80.0;
    _lasers.add(LaserBeam(x: shipX, y: shipY));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final tapX = event.localPosition.x;
    final tapY = event.localPosition.y;

    // Check if player tapped directly on a falling node
    for (final node in _nodes) {
      if (node.isDestroyed) continue;
      final nodeX = node.x * size.x;
      final nodeY = node.y;
      final rect = Rect.fromCenter(
        center: Offset(nodeX, nodeY),
        width: 100,
        height: 50,
      );
      if (rect.contains(Offset(tapX, tapY))) {
        _shootTargetNode(node);
        return;
      }
    }

    // Otherwise, move ship toward tap location and fire laser!
    shipNormalizedX = (tapX / size.x).clamp(0.1, 0.9);
    fireLaser();
  }

  void _shootTargetNode(FallingNode node) {
    node.isDestroyed = true;
    _spawnExplosion(node.x * size.x, node.y, node.isTarget);
    onWordHit(node.word, node.isTarget);
  }

  void _spawnExplosion(double x, double y, bool isTarget) {
    final rng = math.Random();
    final count = isTarget ? 30 : 16;
    final color = isTarget ? const Color(0xFF00F0FF) : const Color(0xFFEF4444);

    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 60.0 + rng.nextDouble() * 180.0;
      _particles.add(
        ExplosionParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: i % 2 == 0 ? color : const Color(0xFFFFD700),
          life: 0.7,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTime += dt;

    // Power-up timers
    if (isSlowMoActive) {
      slowMoTimer -= dt;
      if (slowMoTimer <= 0) isSlowMoActive = false;
    }
    if (isClueMatrixActive) {
      clueMatrixTimer -= dt;
      if (clueMatrixTimer <= 0) isClueMatrixActive = false;
    }

    final effectiveSpeedMultiplier = isSlowMoActive ? 0.45 : 1.0;

    // 1. Update Stars
    for (final star in _stars) {
      star.y += star.speed * dt * (isSlowMoActive ? 0.5 : 1.0);
      if (star.y > 1.0) {
        star.y = 0.0;
        star.x = math.Random().nextDouble();
      }
    }

    // 2. Update Lasers
    for (final laser in _lasers) {
      laser.y -= 520.0 * dt;
    }
    _lasers.removeWhere((l) => l.y < -20.0 || l.isSpent);

    // 3. Update Nodes
    final bottomBoundary = size.y - 120.0;
    for (final node in _nodes) {
      if (node.isDestroyed) continue;
      node.y += node.speed * effectiveSpeedMultiplier * dt;
      node.wobblePhase += dt * 2.5;

      // Laser collision check
      final nodeX = node.x * size.x;
      final nodeY = node.y;
      final nodeRect = Rect.fromCenter(
        center: Offset(nodeX, nodeY),
        width: 90,
        height: 40,
      );

      for (final laser in _lasers) {
        if (!laser.isSpent && nodeRect.contains(Offset(laser.x, laser.y))) {
          laser.isSpent = true;
          _shootTargetNode(node);
          break;
        }
      }

      // Ship collision (interception)
      final shipX = shipNormalizedX * size.x;
      final shipY = size.y - 75.0;
      final shipRect = Rect.fromCenter(
        center: Offset(shipX, shipY),
        width: 80,
        height: 50,
      );

      if (!node.isDestroyed && nodeRect.overlaps(shipRect)) {
        _shootTargetNode(node);
      }

      // Reached bottom without hit
      if (node.y > bottomBoundary && !node.isDestroyed) {
        node.isDestroyed = true;
        if (node.isTarget) {
          onMissedWord();
          // Respawn target word at top so player can still complete wave!
          _nodes.add(
            FallingNode(
              word: node.word,
              isTarget: true,
              x: (math.Random().nextDouble() * 0.7 + 0.15),
              y: -30.0,
              speed: node.speed,
              wobblePhase: 0,
            ),
          );
        }
      }
    }

    // 4. Update Particles
    for (final p in _particles) {
      p.update(dt);
    }
    _particles.removeWhere((p) => p.isDead);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Draw Starfield Background
    _renderStars(canvas);

    // 2. Draw Cyber Defense Grid Lines
    _renderCyberGrid(canvas);

    // 3. Draw Lasers
    _renderLasers(canvas);

    // 4. Draw Falling Word Nodes
    _renderWordNodes(canvas);

    // 5. Draw Interceptor Ship
    _renderInterceptorShip(canvas);

    // 6. Draw Particles
    for (final p in _particles) {
      p.render(canvas);
    }
  }

  void _renderStars(Canvas canvas) {
    final paint = Paint();
    for (final star in _stars) {
      paint.color = star.color;
      canvas.drawCircle(
        Offset(star.x * size.x, star.y * size.y),
        star.radius,
        paint,
      );
    }
  }

  void _renderCyberGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    // Vertical Perspective Lines
    final centerTopX = size.x * 0.5;
    const topY = 0.0;
    final bottomY = size.y;

    for (int i = -4; i <= 4; i++) {
      final bottomX = centerTopX + (i * size.x * 0.16);
      canvas.drawLine(
        Offset(centerTopX + (i * 20), topY),
        Offset(bottomX, bottomY),
        gridPaint,
      );
    }

    // Horizontal Laser Defense Line
    final defenseLinePaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.y - 120.0),
      Offset(size.x, size.y - 120.0),
      defenseLinePaint,
    );
  }

  void _renderLasers(Canvas canvas) {
    final laserPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.4)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    for (final laser in _lasers) {
      canvas.drawLine(
        Offset(laser.x, laser.y),
        Offset(laser.x, laser.y + 18.0),
        glowPaint,
      );
      canvas.drawLine(
        Offset(laser.x, laser.y),
        Offset(laser.x, laser.y + 18.0),
        laserPaint,
      );
    }
  }

  void _renderWordNodes(Canvas canvas) {
    for (final node in _nodes) {
      if (node.isDestroyed) continue;

      final cx = node.x * size.x + (math.sin(node.wobblePhase) * 4.0);
      final cy = node.y;

      final isTarget = node.isTarget;
      final borderCol = isTarget
          ? const Color(0xFF00F0FF)
          : const Color(0xFF94A3B8);
      final fillCol = isTarget
          ? const Color(0xFF0C4A6E).withValues(alpha: 0.9)
          : const Color(0xFF1E293B).withValues(alpha: 0.85);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 96, height: 38),
        const Radius.circular(10),
      );

      // Glow halo for target
      if (isTarget) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawRRect(rrect, glowPaint);
      }

      // Node background
      final bgPaint = Paint()..color = fillCol;
      canvas.drawRRect(rrect, bgPaint);

      // Node Border
      final borderPaint = Paint()
        ..color = borderCol
        ..style = PaintingStyle.stroke
        ..strokeWidth = isTarget ? 2.0 : 1.2;
      canvas.drawRRect(rrect, borderPaint);

      // Node Text
      final textSpan = TextSpan(
        text: node.word,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 90);

      textPainter.paint(
        canvas,
        Offset(cx - (textPainter.width / 2), cy - (textPainter.height / 2)),
      );
    }
  }

  void _renderInterceptorShip(Canvas canvas) {
    final cx = shipNormalizedX * size.x;
    final cy = size.y - 75.0;

    // 1. Thruster Glow and Flame
    final thrusterFlicker = (math.sin(gameTime * 20.0) * 4.0);
    final flamePaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.85);
    final flamePath = Path()
      ..moveTo(cx - 8, cy + 16)
      ..lineTo(cx + 8, cy + 16)
      ..lineTo(cx, cy + 30 + thrusterFlicker)
      ..close();
    canvas.drawPath(flamePath, flamePaint);

    // 2. Futuristic Ship Wings & Body
    final shipPaint = Paint()..color = const Color(0xFF0284C7);
    final shipTrimPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shipPath = Path()
      ..moveTo(cx, cy - 24) // Ship Nose
      ..lineTo(cx + 26, cy + 14) // Right Wingtip
      ..lineTo(cx + 12, cy + 16) // Right Thruster
      ..lineTo(cx, cy + 10) // Center Engine
      ..lineTo(cx - 12, cy + 16) // Left Thruster
      ..lineTo(cx - 26, cy + 14) // Left Wingtip
      ..close();

    canvas.drawPath(shipPath, shipPaint);
    canvas.drawPath(shipPath, shipTrimPaint);

    // 3. Cockpit Glass
    final cockpitPaint = Paint()..color = const Color(0xFF00F0FF);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 8, height: 16),
      cockpitPaint,
    );

    // 4. Wingtip Laser Cannons
    final cannonPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(cx - 26, cy + 14), 2.5, cannonPaint);
    canvas.drawCircle(Offset(cx + 26, cy + 14), 2.5, cannonPaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 👾 Particle and Node Helper Entities
// ─────────────────────────────────────────────────────────────────────────────

class FallingNode {
  final String word;
  final bool isTarget;
  double x;
  double y;
  final double speed;
  double wobblePhase;
  bool isDestroyed = false;

  FallingNode({
    required this.word,
    required this.isTarget,
    required this.x,
    required this.y,
    required this.speed,
    required this.wobblePhase,
  });
}

class LaserBeam {
  final double x;
  double y;
  bool isSpent = false;

  LaserBeam({required this.x, required this.y});
}

class StarParticle {
  double x;
  double y;
  final double speed;
  final double radius;
  final Color color;

  StarParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.color,
  });
}

class ExplosionParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double life;
  final double maxLife;

  ExplosionParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.life,
  }) : maxLife = life;

  bool get isDead => life <= 0;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
  }

  void render(Canvas canvas) {
    final alpha = (life / maxLife).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(x, y), 2.5, paint);
  }
}
