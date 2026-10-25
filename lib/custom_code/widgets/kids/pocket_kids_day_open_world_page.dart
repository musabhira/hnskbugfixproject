import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';

/// 🌍 Kids Dedicated 2D Open World Rolling-Hills Driving Adventure
///
/// Features:
/// - Side-scrolling rolling hills countryside physics (Hill Climb style)
/// - Cute animated kids cartoon buggy with spinning wheels, bouncing suspension, and driver
/// - Gas, Brake/Reverse, and Jump/Bounce pedals
/// - 90+ roadside Buddy Houses with waving animal robots from Buddy Village
/// - Roadside interactive Vocabulary Billboards with audio pronunciation and Malayalam meanings
/// - Seamless infinite looping terrain
/// - Distance odometer, words collected tracker, and KS star rewards
class PocketKidsDayOpenWorldPage extends StatefulWidget {
  final int day;

  const PocketKidsDayOpenWorldPage({super.key, required this.day});

  static Future<void> open(BuildContext context, int day) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsDayOpenWorldPage(day: day),
      ),
    );
  }

  @override
  State<PocketKidsDayOpenWorldPage> createState() =>
      _PocketKidsDayOpenWorldPageState();
}

class _VocabCheckpoint {
  final double worldX;
  final String word;
  final String emoji;
  final String meaningMl;
  final String exampleEn;
  bool isCollected = false;

  _VocabCheckpoint({
    required this.worldX,
    required this.word,
    required this.emoji,
    required this.meaningMl,
    required this.exampleEn,
  });
}

class _PocketKidsDayOpenWorldPageState extends State<PocketKidsDayOpenWorldPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late Ticker _ticker;

  // Driving Physics State
  double _carWorldX = 120.0;
  double _carSpeed = 0.0;
  double _carJumpY = 0.0;
  double _verticalVelocity = 0.0;
  double _wheelRotation = 0.0;
  bool _isGasPressed = false;
  bool _isBrakePressed = false;

  // Game Stats
  int _score = 0;
  int _wordsCollectedCount = 0;
  final Set<String> _visitedHouseIds = {};

  // Active Proximity Targets
  _VocabCheckpoint? _activeVocabNearby;
  KidMate? _activeBuddyNearby;
  bool _isSpeaking = false;

  // Billboards Database along the endless highway
  late final List<_VocabCheckpoint> _checkpoints;

  // Visual constants
  static const double houseInterval = 820.0;
  static const double vocabInterval = 440.0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _generateHighwayCheckpoints();

    // 60fps smooth game physics loop
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.32);
      await _tts.setSpeechRate(0.44);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) return;
    _isSpeaking = true;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _isSpeaking = false;
    });
  }

  void _generateHighwayCheckpoints() {
    final vocabBank = [
      {'word': 'CAR', 'emoji': '🚗', 'ml': 'കാർ', 'ex': 'The red car goes fast!'},
      {'word': 'SUN', 'emoji': '☀️', 'ml': 'സൂര്യൻ', 'ex': 'The sun is shining bright!'},
      {'word': 'CAT', 'emoji': '🐱', 'ml': 'പൂച്ച', 'ex': 'The cute cat says meow!'},
      {'word': 'DOG', 'emoji': '🐶', 'ml': 'പട്ടി', 'ex': 'The happy dog wags its tail!'},
      {'word': 'STAR', 'emoji': '⭐', 'ml': 'നക്ഷത്രം', 'ex': 'Look at the twinkling star!'},
      {'word': 'TREE', 'emoji': '🌳', 'ml': 'മരം', 'ex': 'Big green tree with sweet apples!'},
      {'word': 'LION', 'emoji': '🦁', 'ml': 'സിംഹം', 'ex': 'King lion roars in the jungle!'},
      {'word': 'BUS', 'emoji': '🚌', 'ml': 'ബസ്', 'ex': 'The yellow school bus is here!'},
      {'word': 'DUCK', 'emoji': '🦆', 'ml': 'താറാവ്', 'ex': 'The duck swims in the pond!'},
      {'word': 'FROG', 'emoji': '🐸', 'ml': 'തവള', 'ex': 'The green frog hops so high!'},
      {'word': 'BOAT', 'emoji': '⛵', 'ml': 'ബോട്ട്', 'ex': 'The little boat sails on the water!'},
      {'word': 'BIRD', 'emoji': '🐦', 'ml': 'പക്ഷി', 'ex': 'The blue bird sings a sweet song!'},
      {'word': 'APPLE', 'emoji': '🍎', 'ml': 'ആപ്പിൾ', 'ex': 'Crunchy red apple for lunch!'},
      {'word': 'BEAR', 'emoji': '🐻', 'ml': 'കരടി', 'ex': 'Friendly brown bear loves honey!'},
      {'word': 'MOON', 'emoji': '🌙', 'ml': 'ചന്ദ്രൻ', 'ex': 'The silver moon glows at night!'},
      {'word': 'BALL', 'emoji': '⚽', 'ml': 'പന്ത്', 'ex': 'Kick the soccer ball into the goal!'},
      {'word': 'TRAIN', 'emoji': '🚂', 'ml': 'ട്രെയിൻ', 'ex': 'Choo choo goes the friendly train!'},
      {'word': 'FISH', 'emoji': '🐟', 'ml': 'മത്സ്യം', 'ex': 'The shiny fish swims so fast!'},
      {'word': 'FLOWER', 'emoji': '🌸', 'ml': 'പൂവ്', 'ex': 'Pretty pink flower in the meadow!'},
      {'word': 'POCKET', 'emoji': '🎒', 'ml': 'പോക്കറ്റ്', 'ex': 'Pocket Mates is full of fun!'},
    ];

    _checkpoints = [];
    for (int i = 0; i < 60; i++) {
      final v = vocabBank[i % vocabBank.length];
      _checkpoints.add(
        _VocabCheckpoint(
          worldX: 300.0 + (i * vocabInterval),
          word: v['word']!,
          emoji: v['emoji']!,
          meaningMl: v['ml']!,
          exampleEn: v['ex']!,
        ),
      );
    }
  }

  // Rolling hills height function (sinusoidal terrain)
  static double getHillY(double x) {
    return 45.0 * math.sin(x * 0.0028) +
        22.0 * math.sin(x * 0.0065) +
        12.0 * math.cos(x * 0.0012);
  }

  // Hill slope angle for car chassis tilt
  static double getHillAngle(double x) {
    final dy = getHillY(x + 10.0) - getHillY(x - 10.0);
    return math.atan2(dy, 20.0);
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    setState(() {
      // 1. Throttle / Brake acceleration
      if (_isGasPressed) {
        _carSpeed += 0.40;
        if (_carSpeed > 10.5) _carSpeed = 10.5;
      } else if (_isBrakePressed) {
        _carSpeed -= 0.55;
        if (_carSpeed < -5.0) _carSpeed = -5.0;
      } else {
        // Natural friction & coasting
        _carSpeed *= 0.95;
        if (_carSpeed.abs() < 0.05) _carSpeed = 0.0;
      }

      // 2. Hill slope gravitational pull
      final carAngle = getHillAngle(_carWorldX);
      _carSpeed -= math.sin(carAngle) * 0.16;

      // 3. Update world position
      _carWorldX += _carSpeed;
      if (_carWorldX < 80.0) {
        _carWorldX = 80.0;
        _carSpeed = 0.0;
      }

      // 4. Wheel rotation based on speed
      _wheelRotation += _carSpeed * 0.08;

      // 5. Jump physics
      if (_carJumpY < 0.0 || _verticalVelocity != 0.0) {
        _carJumpY += _verticalVelocity;
        _verticalVelocity += 0.55; // Gravity
        if (_carJumpY >= 0.0) {
          _carJumpY = 0.0;
          _verticalVelocity = 0.0;
        }
      }

      // 6. Proximity detection for Vocabulary Billboards
      _VocabCheckpoint? closestVocab;
      double minVocabDist = 120.0;
      for (final cp in _checkpoints) {
        final dist = (cp.worldX - _carWorldX).abs();
        if (dist < minVocabDist) {
          minVocabDist = dist;
          closestVocab = cp;
        }
      }

      if (closestVocab != _activeVocabNearby) {
        _activeVocabNearby = closestVocab;
        if (closestVocab != null && !closestVocab.isCollected) {
          HapticFeedback.lightImpact();
          _speak("${closestVocab.word}! ${closestVocab.meaningMl}");
        }
      }

      // 7. Proximity detection for Buddy Houses
      KidMate? closestBuddy;
      final robots = PocketKidsRobotsData.robotsAndHomies;
      double minHouseDist = 140.0;

      for (int i = 0; i < robots.length; i++) {
        final houseX = 650.0 + (i * houseInterval);
        final dist = (houseX - _carWorldX).abs();
        if (dist < minHouseDist) {
          minHouseDist = dist;
          closestBuddy = robots[i];
          break;
        }
      }

      if (closestBuddy != _activeBuddyNearby) {
        _activeBuddyNearby = closestBuddy;
        if (closestBuddy != null) {
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  void _onJump() {
    if (_carJumpY == 0.0) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();
      setState(() {
        _verticalVelocity = -8.5;
        _carJumpY = -1.0;
      });
    }
  }

  void _onHonk() {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playPopSound();
    _speak("Beep beep! Let's drive!");
  }

  void _onCollectVocab(_VocabCheckpoint vocab) async {
    if (vocab.isCollected) return;

    HapticFeedback.heavyImpact();
    PocketGameSFX.playCorrectChime();

    setState(() {
      vocab.isCollected = true;
      _score += 10;
      _wordsCollectedCount++;
    });

    await PocketKidsService.addKidsScore(10);
    await PocketKidsService.addKidStars(1);

    _speak("Great! You learned ${vocab.word}!");
  }

  void _showBuddyModal(KidMate buddy) {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(buddy.avatar, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              buddy.name,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFBBF24)),
              ),
              child: Text(
                '🏡 Buddy Village Home #${buddy.dayLevel} • Ages ${buddy.ageGroup}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              buddy.bio,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    label: Text(
                      'Listen 🔊',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      _tts.stop();
                      _tts.speak("Hello friend! I am ${buddy.name}! Welcome to my house!");
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.waving_hand_rounded, size: 20),
                    label: Text(
                      'Say Hi 👋 (+5 KS)',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      if (!_visitedHouseIds.contains(buddy.id)) {
                        _visitedHouseIds.add(buddy.id);
                        await PocketKidsService.addKidsScore(5);
                        setState(() => _score += 5);
                        HapticFeedback.heavyImpact();
                        PocketGameAudioService.instance.playCoinSound();
                      }
                      _speak("Hi ${buddy.name}! You are wonderful!");
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final groundBase = screenH * 0.65;

    // Viewport camera focuses on the car at 32% screen width
    final cameraX = _carWorldX - (screenW * 0.32);
    final carHillY = getHillY(_carWorldX);
    final carAngle = getHillAngle(_carWorldX);
    final carScreenX = screenW * 0.32;
    final carScreenY = groundBase + carHillY + _carJumpY - 48.0;

    return Scaffold(
      backgroundColor: const Color(0xFF7DD3FC), // Bright Sky Blue
      body: Stack(
        children: [
          // ===================================================================
          // 1. ENDLESS 2D ROLLING HILLS & HIGHWAY CANVAS
          // ===================================================================
          Positioned.fill(
            child: CustomPaint(
              painter: _KidsRollingHillsPainter(
                cameraX: cameraX,
                groundBaseY: groundBase,
                checkpoints: _checkpoints,
                robots: PocketKidsRobotsData.robotsAndHomies,
                houseInterval: houseInterval,
              ),
            ),
          ),

          // ===================================================================
          // 2. THE CARTOON BUGGY & DRIVER
          // ===================================================================
          Positioned(
            left: carScreenX - 45.0,
            top: carScreenY,
            child: Transform.rotate(
              angle: carAngle * 0.85,
              alignment: Alignment.bottomCenter,
              child: _buildBuggy(isDriving: _carSpeed.abs() > 0.5),
            ),
          ),

          // ===================================================================
          // 3. TOP NAVIGATION & STATS HUD
          // ===================================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0F172A),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Distance Odometer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🚗', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '${(_carWorldX / 10).round()} m',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Words Collected Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '$_wordsCollectedCount Words',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Score / Stars Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$_score KS',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // 4. FLOATING CHECKPOINT / BUDDY INTERACTION CARD
          // ===================================================================
          if (_activeVocabNearby != null)
            Positioned(
              bottom: 110,
              left: 20,
              right: 20,
              child: _buildVocabPopupCard(_activeVocabNearby!),
            )
          else if (_activeBuddyNearby != null)
            Positioned(
              bottom: 110,
              left: 20,
              right: 20,
              child: _buildBuddyPopupCard(_activeBuddyNearby!),
            ),

          // ===================================================================
          // 5. DRIVING CONTROLS (GAS, BRAKE, JUMP, HORN)
          // ===================================================================
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Controls: Brake & Horn
                Row(
                  children: [
                    // BRAKE / REVERSE PEDAL
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isBrakePressed = true),
                      onTapUp: (_) => setState(() => _isBrakePressed = false),
                      onTapCancel: () => setState(() => _isBrakePressed = false),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _isBrakePressed
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 26),
                            Text(
                              'BRAKE',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // HORN BUTTON
                    GestureDetector(
                      onTap: _onHonk,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('📯', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ],
                ),

                // Right Controls: Jump & Gas
                Row(
                  children: [
                    // JUMP / BOUNCE BUTTON
                    GestureDetector(
                      onTap: _onJump,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA78BFA),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🦘', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // GAS ACCELERATOR PEDAL
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isGasPressed = true),
                      onTapUp: (_) => setState(() => _isGasPressed = false),
                      onTapCancel: () => setState(() => _isGasPressed = false),
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: _isGasPressed
                              ? const Color(0xFF059669)
                              : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 28),
                            Text(
                              'GAS',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }

  // Cartoon Buggy Widget with driver and spinning wheels
  Widget _buildBuggy({required bool isDriving}) {
    return SizedBox(
      width: 90,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Exhaust smoke puffs when driving
          if (isDriving)
            Positioned(
              left: -12,
              bottom: 12,
              child: Opacity(
                opacity: 0.6,
                child: Text('💨', style: const TextStyle(fontSize: 16)),
              ),
            ),

          // Buggy Body Chassis
          Positioned(
            left: 8,
            bottom: 10,
            child: Container(
              width: 74,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316), // Bright Orange
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Racing stripe
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    height: 5,
                    child: Container(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  // Headlight
                  Positioned(
                    right: 4,
                    top: 8,
                    child: Container(
                      width: 7,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Windshield & Roll Bar
          Positioned(
            left: 24,
            top: 4,
            child: Container(
              width: 32,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFBAE6FD).withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border.all(color: const Color(0xFF0284C7), width: 2),
              ),
            ),
          ),

          // Smiling Driver (Leo / Robo)
          Positioned(
            left: 28,
            top: 2,
            child: const Text('🦁', style: TextStyle(fontSize: 20)),
          ),

          // Rear Wheel
          Positioned(
            left: 12,
            bottom: 0,
            child: Transform.rotate(
              angle: _wheelRotation,
              child: _buildWheel(),
            ),
          ),

          // Front Wheel
          Positioned(
            right: 12,
            bottom: 0,
            child: Transform.rotate(
              angle: _wheelRotation,
              child: _buildWheel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF94A3B8),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Interactive Vocabulary Card Popup
  Widget _buildVocabPopupCard(_VocabCheckpoint vocab) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: vocab.isCollected
              ? const Color(0xFF10B981)
              : const Color(0xFF38BDF8),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(vocab.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      vocab.word,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vocab.meaningMl,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  vocab.exampleEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: vocab.isCollected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => _onCollectVocab(vocab),
            child: Text(
              vocab.isCollected ? 'Learned! ⭐' : 'Collect ⭐',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Buddy House Card Popup
  Widget _buildBuddyPopupCard(KidMate buddy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFBBF24), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(buddy.avatar, style: const TextStyle(fontSize: 38)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buddy.name,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '🏡 Day #${buddy.dayLevel} Home • Tap to visit!',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => _showBuddyModal(buddy),
            child: Text(
              'Visit 🏡',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 CustomPainter to render the rolling hills, road, buddy houses and billboards
class _KidsRollingHillsPainter extends CustomPainter {
  final double cameraX;
  final double groundBaseY;
  final List<_VocabCheckpoint> checkpoints;
  final List<KidMate> robots;
  final double houseInterval;

  _KidsRollingHillsPainter({
    required this.cameraX,
    required this.groundBaseY,
    required this.checkpoints,
    required this.robots,
    required this.houseInterval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Distant Parallax Hills (Soft Teal Green)
    final distantHillPaint = Paint()..color = const Color(0xFF86EFAC);
    final distantPath = Path();
    distantPath.moveTo(0, size.height);

    for (double sx = 0; sx <= size.width; sx += 20) {
      final distantWorldX = (cameraX * 0.45) + sx;
      final dy = 30.0 * math.sin(distantWorldX * 0.0018);
      final sy = groundBaseY - 60.0 + dy;
      distantPath.lineTo(sx, sy);
    }
    distantPath.lineTo(size.width, size.height);
    distantPath.close();
    canvas.drawPath(distantPath, distantHillPaint);

    // 2. Foreground Lush Rolling Hills (Vibrant Lawn Green)
    final hillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
      ).createShader(Rect.fromLTWH(0, groundBaseY - 60, size.width, size.height));

    final hillPath = Path();
    hillPath.moveTo(0, size.height);

    for (double sx = 0; sx <= size.width; sx += 10) {
      final worldX = cameraX + sx;
      final hillY = _PocketKidsDayOpenWorldPageState.getHillY(worldX);
      hillPath.lineTo(sx, groundBaseY + hillY);
    }
    hillPath.lineTo(size.width, size.height);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // 3. Countryside Road Ribbon (Grey Asphalt with yellow dashes)
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 26.0
      ..style = PaintingStyle.stroke;

    final roadPath = Path();
    for (double sx = 0; sx <= size.width; sx += 10) {
      final worldX = cameraX + sx;
      final hillY = _PocketKidsDayOpenWorldPageState.getHillY(worldX);
      if (sx == 0) {
        roadPath.moveTo(sx, groundBaseY + hillY + 12.0);
      } else {
        roadPath.lineTo(sx, groundBaseY + hillY + 12.0);
      }
    }
    canvas.drawPath(roadPath, roadPaint);

    // 4. Draw Roadside Buddy Houses
    for (int i = 0; i < robots.length; i++) {
      final houseWorldX = 650.0 + (i * houseInterval);
      final screenX = houseWorldX - cameraX;

      // Only draw if within viewport range
      if (screenX > -150 && screenX < size.width + 150) {
        final hillY = _PocketKidsDayOpenWorldPageState.getHillY(houseWorldX);
        final houseY = groundBaseY + hillY - 80.0;
        _drawHouse(canvas, screenX, houseY, robots[i]);
      }
    }

    // 5. Draw Roadside Vocabulary Billboards
    for (final cp in checkpoints) {
      final screenX = cp.worldX - cameraX;
      if (screenX > -100 && screenX < size.width + 100) {
        final hillY = _PocketKidsDayOpenWorldPageState.getHillY(cp.worldX);
        final billboardY = groundBaseY + hillY - 65.0;
        _drawBillboard(canvas, screenX, billboardY, cp);
      }
    }
  }

  void _drawHouse(Canvas canvas, double x, double y, KidMate buddy) {
    // House Base / Walls
    final wallPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 32, y + 16, 64, 44),
        const Radius.circular(8),
      ),
      wallPaint,
    );

    // House Roof
    final roofPaint = Paint()..color = const Color(0xFFEF4444);
    final roofPath = Path()
      ..moveTo(x - 40, y + 18)
      ..lineTo(x, y - 8)
      ..lineTo(x + 40, y + 18)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Door
    final doorPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 10, y + 36, 20, 24),
        const Radius.circular(4),
      ),
      doorPaint,
    );

    // Chimney
    final chimneyPaint = Paint()..color = const Color(0xFF991B1B);
    canvas.drawRect(Rect.fromLTWH(x + 16, y - 6, 12, 16), chimneyPaint);

    // Waving Mascot Emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: buddy.avatar,
        style: const TextStyle(fontSize: 26),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x - 13, y + 14));

    // House Number Banner
    final bannerPainter = TextPainter(
      text: TextSpan(
        text: '#${buddy.dayLevel}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bannerBg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 14, y + 4, 28, 14),
        const Radius.circular(4),
      ),
      bannerBg,
    );
    bannerPainter.paint(canvas, Offset(x - (bannerPainter.width / 2), y + 4.5));
  }

  void _drawBillboard(Canvas canvas, double x, double y, _VocabCheckpoint cp) {
    // Wooden post
    final postPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(x - 3, y + 30, 6, 32), postPaint);

    // Signboard Rect
    final signBg = Paint()
      ..color = cp.isCollected ? const Color(0xFF10B981) : Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 30, y, 60, 36),
        const Radius.circular(10),
      ),
      signBg,
    );

    // Sign Border
    final signBorder = Paint()
      ..color = cp.isCollected ? const Color(0xFF059669) : const Color(0xFFF59E0B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 30, y, 60, 36),
        const Radius.circular(10),
      ),
      signBorder,
    );

    // Billboard Emoji & Text
    final emojiPainter = TextPainter(
      text: TextSpan(
        text: cp.emoji,
        style: const TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    emojiPainter.paint(canvas, Offset(x - 22, y + 8));

    final wordPainter = TextPainter(
      text: TextSpan(
        text: cp.word,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: cp.isCollected ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    wordPainter.paint(canvas, Offset(x + 2, y + 11));
  }

  @override
  bool shouldRepaint(covariant _KidsRollingHillsPainter oldDelegate) {
    return oldDelegate.cameraX != cameraX;
  }
}
