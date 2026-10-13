import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';

/// 🎮 Kids Interactive Multi-Game Engine (100-Day Progressive Curriculum)
/// Features 10 distinct, non-repetitive game mechanics based on the day's syllabus:
/// 1. 🎈 Balloon Pop Phonics
/// 2. 🚂 Letter Train Jigsaw
/// 3. 🍎 Animal Feast
/// 4. 🃏 Safari Memory Cards
/// 5. 🏹 Slingshot Target Hit
/// 6. 🐸 River Stone Hopper
/// 7. 🔍 Detective Object Spy
/// 8. 🧩 Sentence Jigsaw
/// 9. 🗣️ Spoken Voice Echo
/// 10. 🦁 Day 100 King Lion Royal Boss Battle
class PocketKidsGameSessionPage extends StatefulWidget {
  final int day;
  const PocketKidsGameSessionPage({super.key, required this.day});

  @override
  State<PocketKidsGameSessionPage> createState() =>
      _PocketKidsGameSessionPageState();
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double opacity = 1.0;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class _PocketKidsGameSessionPageState extends State<PocketKidsGameSessionPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late KidDaySyllabus _syllabus;

  late AnimationController _pulseController;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  int _currentRound = 0;
  int _starsEarned = 0;
  bool _isSessionFinished = false;
  String _mascotSpeech = '';

  // Interactive Game State Variables
  // Train Scramble & Sentence Jigsaw
  final List<String> _selectedTokens = [];

  // Memory Match Cards (Indices: 0..3)
  final List<int> _flippedIndices = [];
  final Set<int> _matchedIndices = {};

  // King Lion Boss HP (Day 100)
  int _bossHp = 100;

  static const List<Color> _candyColors = [
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  @override
  void initState() {
    super.initState();
    _syllabus = PocketKids100DaySyllabusDB.getSyllabusForDay(widget.day);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(_updateParticles);

    _initTts();
    _setupRound(0);
    PocketGameAudioService.instance.playAttackTheme(
      targetId: 'kids_game_${widget.day}',
      targetDay: widget.day,
    );
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _setupRound(int roundIdx) {
    _currentRound = roundIdx;
    _selectedTokens.clear();
    _flippedIndices.clear();
    _matchedIndices.clear();

    final round = _currentRoundData;
    _mascotSpeech = round.prompt;
    _speak("${round.prompt}. ${round.targetWord}");
  }

  KidGameRound get _currentRoundData {
    if (_syllabus.rounds.isEmpty) {
      return const KidGameRound(
        prompt: 'Say the English word!',
        targetWord: 'Hello',
        targetSubtitle: 'Greeting',
        emoji: '👋',
        options: ['Hello', 'No', 'Bye'],
        correctIndex: 0,
        cheerPhrase: 'Awesome!',
      );
    }
    return _syllabus.rounds[_currentRound % _syllabus.rounds.length];
  }

  void _triggerConfetti(double x, double y, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 22; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = rand.nextDouble() * 160 + 60;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: _candyColors[rand.nextInt(_candyColors.length)],
          size: rand.nextDouble() * 9 + 4,
        ),
      );
    }
    _particleController.forward(from: 0.0);
  }

  void _updateParticles() {
    final dt = 0.016;
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 220 * dt; // Gravity
      p.opacity = (p.opacity - 0.024).clamp(0.0, 1.0);
    }
    _particles.removeWhere((p) => p.opacity <= 0.0);
    setState(() {});
  }

  void _handleAnswerSelected(int index, BuildContext context) {
    final round = _currentRoundData;
    HapticFeedback.mediumImpact();

    if (index == round.correctIndex) {
      // Correct!
      HapticFeedback.heavyImpact();
      _starsEarned = (_starsEarned + 1).clamp(0, 3);

      final renderBox = context.findRenderObject() as RenderBox?;
      final center = renderBox != null
          ? Offset(renderBox.size.width / 2, renderBox.size.height / 2)
          : const Offset(200, 300);
      _triggerConfetti(center.dx, center.dy, Colors.amber);

      if (_syllabus.gameType == KidGameType.bossBattle) {
        _bossHp = (_bossHp - 34).clamp(0, 100);
      }

      setState(() {
        _mascotSpeech = round.cheerPhrase;
      });
      _speak(round.cheerPhrase);

      // Advance round or complete game
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (_currentRound + 1 < _syllabus.rounds.length) {
          setState(() {
            _setupRound(_currentRound + 1);
          });
        } else {
          _finishSession();
        }
      });
    } else {
      // Incorrect / Try again
      HapticFeedback.vibrate();
      setState(() {
        _mascotSpeech = 'Almost there! Try again with courage! 🌟';
      });
      _speak('Almost there! Try again with courage!');
    }
  }

  Future<void> _finishSession() async {
    if (_isSessionFinished) return;
    _isSessionFinished = true;
    final earnedStars = _starsEarned.clamp(1, 3);
    await PocketKidsService.completeDayGame(widget.day, earnedStars);

    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    _speak('Super star! Day ${widget.day} Complete! You earned 3 stars!');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildCompletionDialog(ctx, earnedStars),
    );
  }

  Widget _buildCompletionDialog(BuildContext ctx, int earnedStars) {
    final isFree = !PocketKidsService.isKidPremium;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 🌟 👑', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Text(
              'DAY ${widget.day} COMPLETE!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Awesome job, ${PocketKidsService.kidName}! 🌟',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Stars Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i < earnedStars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    active ? '⭐' : '☆',
                    style: TextStyle(fontSize: 34, color: active ? const Color(0xFFFFD700) : Colors.white30),
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            // Mastered Dialogue Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    'MASTERED SENTENCE',
                    style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${_syllabus.dialogueSentence}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Midnight countdown for Free users (Audio Directive)
            if (isFree && widget.day < 100) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF451A03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌙 ', style: TextStyle(fontSize: 16)),
                        Text(
                          'DAY ${widget.day + 1} UNLOCKS AT 12:00 AM MIDNIGHT',
                          style: GoogleFonts.outfit(color: const Color(0xFFFEF3C7), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Timer: ${PocketKidsService.getFormattedMidnightCountdown()}',
                      style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        _showAdventurePassModal(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF59E0B)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '⚡ UNLOCK INSTANTLY WITH VIP PASS',
                          style: GoogleFonts.outfit(color: const Color(0xFF78350F), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text('CONTINUE TRAIL 🏔️', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdventurePassModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AdventurePassSheet(onUnlocked: () {
        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    _particleController.dispose();
    PocketGameAudioService.instance.playAmbientBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Game Layout
            Column(
              children: [
                _buildHeader(),
                _buildMascotBanner(),
                Expanded(child: _buildInteractiveGameArea(context)),
              ],
            ),

            // Particle Confetti Canvas (IgnorePointer prevents blocking touches on back button and game controls)
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _ParticlePainter(_particles),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'DAY ${widget.day} • STEP ${_currentRound + 1}/${_syllabus.rounds.length}',
                    style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 11.5),
                  ),
                ],
              ),
              Text(
                _syllabus.title,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ],
          ),
          const Spacer(),
          // Stars & Step Progress Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${_currentRound + 1}/${_syllabus.rounds.length}',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _speak(_mascotSpeech),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(_syllabus.mascot, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _syllabus.gameTypeInstruction,
                  style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  _mascotSpeech,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFBBF24)),
            onPressed: () => _speak(_mascotSpeech),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🎮 DYNAMIC INTERACTIVE GAME ARENA
  // Switches based on KidGameType for the 100 days
  // =========================================================================

  Widget _buildInteractiveGameArea(BuildContext context) {
    switch (_syllabus.gameType) {
      case KidGameType.balloonPop:
        return _buildBalloonPopGame(context);
      case KidGameType.trainScramble:
        return _buildTrainScrambleGame(context);
      case KidGameType.animalFeeder:
        return _buildAnimalFeederGame(context);
      case KidGameType.memoryMatch:
        return _buildMemoryMatchGame(context);
      case KidGameType.slingshotAim:
        return _buildSlingshotGame(context);
      case KidGameType.steppingStones:
      case KidGameType.bridgeBuilder:
      case KidGameType.riverRafting:
      case KidGameType.vineSwinger:
      case KidGameType.canopyZipLine:
      case KidGameType.relaySprint:
      case KidGameType.savannahSprint:
      case KidGameType.trampolineBounce:
        return _buildSteppingStonesGame(context);
      case KidGameType.detectiveSpot:
      case KidGameType.footprintTracker:
      case KidGameType.questionDetective:
        return _buildDetectiveSpotGame(context);
      case KidGameType.sentenceJigsaw:
      case KidGameType.conjunctionTrain:
      case KidGameType.grammarFortress:
      case KidGameType.timeMachine:
      case KidGameType.wizardWand:
      case KidGameType.miradorTwins:
      case KidGameType.tugOfWar:
      case KidGameType.podiumDebate:
      case KidGameType.preSummitCreed:
      case KidGameType.kingdomAccords:
      case KidGameType.storybookOdyssey:
        return _buildSentenceJigsawGame(context);
      case KidGameType.voiceEcho:
      case KidGameType.soundMimic:
      case KidGameType.choirConcert:
      case KidGameType.emotionMirror:
        return _buildVoiceEchoGame(context);
      case KidGameType.rhythmDrums:
      case KidGameType.danceGroove:
        return _buildBalloonPopGame(context); // rhythm/tap interaction via balloon tap
      case KidGameType.cloudCatcher:
      case KidGameType.eagleFlight:
      case KidGameType.hummingbirdBloom:
      case KidGameType.swanLake:
      case KidGameType.dolphinLeap:
      case KidGameType.balloonPilot:
      case KidGameType.kiteRibbon:
        return _buildSlingshotGame(context); // aim/catch mechanics
      case KidGameType.vowelBubbles:
      case KidGameType.fountainSplash:
      case KidGameType.elephantSpray:
        return _buildBalloonPopGame(context); // bubble/pop interaction
      case KidGameType.starTracing:
      case KidGameType.colorSplash:
      case KidGameType.artistStudio:
      case KidGameType.beehiveArchitect:
      case KidGameType.geometryCastle:
        return _buildSteppingStonesGame(context);
      case KidGameType.treasureChest:
      case KidGameType.magicBox:
      case KidGameType.piggyBank:
      case KidGameType.sharingBasket:
        return _buildMemoryMatchGame(context);
      case KidGameType.cookieOven:
      case KidGameType.kitchenChef:
      case KidGameType.potionBrewer:
      case KidGameType.marshmallowRoast:
        return _buildAnimalFeederGame(context);
      case KidGameType.spellCannon:
      case KidGameType.castleMaze:
      case KidGameType.spatialRadar:
      case KidGameType.rainbowBridge:
        return _buildSlingshotGame(context);
      case KidGameType.scrambleCarousel:
      case KidGameType.beePollinator:
      case KidGameType.windmillSpinner:
      case KidGameType.shapeSorter:
        return _buildTrainScrambleGame(context);
      case KidGameType.squirrelStash:
      case KidGameType.treeTapper:
      case KidGameType.otterJuggler:
      case KidGameType.koalaClimber:
        return _buildMemoryMatchGame(context);
      case KidGameType.submarineSonar:
      case KidGameType.telescopeScience:
      case KidGameType.discoveryBeacon:
      case KidGameType.rangerBadge:
        return _buildDetectiveSpotGame(context);
      case KidGameType.starCounter:
      case KidGameType.balanceScale:
      case KidGameType.heightClimber:
      case KidGameType.thermometerSort:
      case KidGameType.cheetahTrack:
      case KidGameType.fruitMarket:
        return _buildBalloonPopGame(context);
      case KidGameType.playhouseDoors:
      case KidGameType.clockTower:
      case KidGameType.routineClockMaster:
      case KidGameType.bedtimeTale:
        return _buildMemoryMatchGame(context);
      case KidGameType.lionRoar:
      case KidGameType.pandaStroll:
      case KidGameType.owlNightWatch:
        return _buildAnimalFeederGame(context);
      case KidGameType.libraryExplorer:
      case KidGameType.zenGarden:
      case KidGameType.teaPartyManners:
      case KidGameType.etiquetteDoorstep:
      case KidGameType.internationalMeet:
      case KidGameType.playgroundChat:
      case KidGameType.cafeMenuOrder:
      case KidGameType.trailCompass:
      case KidGameType.cheerHorns:
      case KidGameType.meadowMediation:
      case KidGameType.sunsetFarewell:
      case KidGameType.handshakeBridge:
      case KidGameType.knightShield:
        return _buildSentenceJigsawGame(context);
      case KidGameType.bossBattle:
        return _buildKingLionBossBattleGame(context);
    }
  }

  // --- 1. 🎈 Balloon Pop Game ---
  Widget _buildBalloonPopGame(BuildContext context) {
    final round = _currentRoundData;
    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: List.generate(round.options.length, (idx) {
          final opt = round.options[idx];
          final color = _candyColors[idx % _candyColors.length];
          return GestureDetector(
            onTap: () => _handleAnswerSelected(idx, context),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, child) {
                final dy = math.sin(_pulseController.value * math.pi * 2 + idx) * 8;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: Container(
                width: 140,
                height: 160,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.9), color],
                    center: const Alignment(-0.3, -0.4),
                  ),
                  borderRadius: const BorderRadius.all(Radius.elliptical(70, 80)),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(round.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 6),
                    Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 2. 🚂 Letter Train Scramble Game ---
  Widget _buildTrainScrambleGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Train Engine + Selected Wagons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('🚂 CHOO CHOO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ..._selectedTokens.map(
                (tok) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(tok, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Available Train Wagons to Tap
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
              onPressed: () {
                setState(() => _selectedTokens.add(opt));
                _handleAnswerSelected(idx, context);
              },
              child: Text(opt, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
            );
          }),
        ),
      ],
    );
  }

  // --- 3. 🍎 Animal Feast Game ---
  Widget _buildAnimalFeederGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hungry Animal Buddy
        Text(_syllabus.mascot, style: const TextStyle(fontSize: 84)),
        const SizedBox(height: 8),
        Text(
          'I am hungry! Feed me: "${round.targetWord}"',
          style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),

        // Food Choices
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return GestureDetector(
              onTap: () => _handleAnswerSelected(idx, context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('🍎', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 6),
                    Text(opt, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- 4. 🃏 Safari Memory Match Game ---
  Widget _buildMemoryMatchGame(BuildContext context) {
    final round = _currentRoundData;
    return Center(
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: List.generate(round.options.length, (idx) {
          final opt = round.options[idx];
          return GestureDetector(
            onTap: () => _handleAnswerSelected(idx, context),
            child: Container(
              width: 130,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8), width: 2),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(round.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 4),
                  Text(opt, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 5. 🏹 Slingshot Target Hit Game ---
  Widget _buildSlingshotGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎯 🏹', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 12),
        Text(
          'Target: "${round.targetWord}"',
          style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () => _handleAnswerSelected(idx, context),
              icon: const Text('🎯', style: TextStyle(fontSize: 18)),
              label: Text(opt, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            );
          }),
        ),
      ],
    );
  }

  // --- 6. 🐸 River Stepping Stones Game ---
  Widget _buildSteppingStonesGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌊 🐸 🌊', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text('Hop across safely to: "${round.targetWord}"!',
            style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return GestureDetector(
              onTap: () => _handleAnswerSelected(idx, context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF34D399), width: 2.5),
                ),
                child: Column(
                  children: [
                    const Text('🪨', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(opt, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- 7. 🔍 Detective Object Spy Game ---
  Widget _buildDetectiveSpotGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🕵️‍♂️ 🔍 🌳', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 10),
        Text('Detective Mission: Spot "${round.targetWord}"',
            style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 30),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFFFD700))),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: () => _handleAnswerSelected(idx, context),
              icon: const Text('🔍', style: TextStyle(fontSize: 16)),
              label: Text(opt, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            );
          }),
        ),
      ],
    );
  }

  // --- 8. 🧩 Sentence Jigsaw Game ---
  Widget _buildSentenceJigsawGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🧩 ✍️', style: TextStyle(fontSize: 50)),
        const SizedBox(height: 12),
        Text('Build English Sentence:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
          child: Text(round.targetWord, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          children: List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => _handleAnswerSelected(idx, context),
              child: Text(opt, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            );
          }),
        ),
      ],
    );
  }

  // --- 9. 🗣️ Spoken Voice Echo Game ---
  Widget _buildVoiceEchoGame(BuildContext context) {
    final round = _currentRoundData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _speak(round.targetWord),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), blurRadius: 18),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 54),
          ),
        ),
        const SizedBox(height: 16),
        Text('Listen & Repeat Aloud:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('"${round.targetWord}"', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          onPressed: () => _handleAnswerSelected(round.correctIndex, context),
          icon: const Icon(Icons.check_circle_rounded, size: 20),
          label: Text('I SPOKE IT ALOUD! ⭐', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ],
    );
  }

  // --- 10. 🦁 Day 100 King Lion Royal Boss Battle ---
  Widget _buildKingLionBossBattleGame(BuildContext context) {
    final round = _currentRoundData;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // King Lion Boss Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFF59E0B)]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🦁', style: TextStyle(fontSize: 48)),
                    SizedBox(width: 12),
                    Text('👑 KING LION', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                // Boss HP Bar
                Row(
                  children: [
                    Text('BOSS HP: $_bossHp%', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _bossHp / 100,
                          backgroundColor: Colors.black38,
                          color: const Color(0xFFEF4444),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Boss Question Prompt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              round.prompt,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),

          // Royal Battle Attack Options
          ...List.generate(round.options.length, (idx) {
            final opt = round.options[idx];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFFFD700)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onPressed: () => _handleAnswerSelected(idx, context),
                  icon: const Text('⚔️', style: TextStyle(fontSize: 18)),
                  label: Text(opt, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =========================================================================
// VIP ADVENTURE PASS BOTTOM SHEET (INSTANT UNLOCK)
// =========================================================================

class _AdventurePassSheet extends StatefulWidget {
  final VoidCallback onUnlocked;
  const _AdventurePassSheet({required this.onUnlocked});

  @override
  State<_AdventurePassSheet> createState() => _AdventurePassSheetState();
}

class _AdventurePassSheetState extends State<_AdventurePassSheet> {
  bool _loading = false;

  Future<void> _activatePass() async {
    setState(() => _loading = true);
    HapticFeedback.heavyImpact();
    await PocketKidsService.setKidPremium(true);
    widget.onUnlocked();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Text('👑 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Text('VIP Adventure Pass Activated! All 100 Days Unlocked!', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          const Text('👑 🚀 🌟', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            'VIP ADVENTURE PASS',
            style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Skip 12:00 AM midnight timers and unlock all 100 days immediately!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          _buildPerk('⚡ Zero Midnight Wait', 'Climb through levels as fast as you practice!'),
          _buildPerk('🏰 King Lion Palace Access', 'Instant summit clearance to challenge Day 100!'),
          _buildPerk('🏆 Official Fluency Certificate', 'Cryptographic graduation seal for parents!'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF78350F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _loading ? null : _activatePass,
              child: _loading
                  ? const CircularProgressIndicator(color: Color(0xFF78350F))
                  : Text('ACTIVATE PASS NOW 👑', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerk(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Particle painter for confetti celebrations
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
