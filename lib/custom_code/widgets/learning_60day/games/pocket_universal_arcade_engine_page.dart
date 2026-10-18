import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';

import 'pocket_20days_40games_spec.dart';
import '../pocket_90day_vocab_curriculum.dart';

// ============================================================================
// 1. DATA MODELS & CHALLENGE ROUNDS
// ============================================================================

class ArcadeChallengeRound {
  final String promptEn;
  final String promptMl;
  final String voiceLeadIn;
  final String targetWord;
  final List<String> options;
  final int correctIndex;
  final String explanationEn;

  ArcadeChallengeRound({
    required this.promptEn,
    required this.promptMl,
    required this.voiceLeadIn,
    required this.targetWord,
    required this.options,
    required this.correctIndex,
    required this.explanationEn,
  });
}

/// Particle model for open-world star sparkles, confetti, and fireworks
class FlameArcadeParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final Color color;
  final double size;
  final bool isSquare;

  FlameArcadeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
    this.isSquare = false,
  }) : maxLife = life;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 120 * dt; // gravity
    life -= dt;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final progress = (life / maxLife).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: progress)
      ..style = PaintingStyle.fill;

    if (isSquare) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: size * progress, height: size * progress),
        paint,
      );
    } else {
      canvas.drawCircle(Offset(x, y), size * progress, paint);
    }
  }
}

/// Floating text popups (e.g. "+100 XP", "PERFECT!")
class FlameFloatingText {
  double x;
  double y;
  final String text;
  final Color color;
  double life;
  final double maxLife;

  FlameFloatingText({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
    this.life = 1.2,
  }) : maxLife = life;

  void update(double dt) {
    y -= 45 * dt; // floats upward
    life -= dt;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;
    final progress = (life / maxLife).clamp(0.0, 1.0);
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: progress),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        fontFamily: 'Outfit',
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.8 * progress),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }
}

/// 10 Dedicated Flame Game Archetypes
enum FlameArchetype {
  racer,         // Highway / Countryside Road / Taxi / Grand Prix
  runner,        // Lush Meadow / Forest Trail / Stepping Stones
  popIt,         // Sunny Sky Pop-It / Falling Letter Balloons
  targetShooter, // Meadow Archery / Target Range / Slingshot
  sportsGoal,    // Football Pitch / Orchard Basket / Tennis
  oceanDiver,    // Sunlit Turquoise Lagoon / Submarine / River Boat
  trainCoupler,  // Countryside Railroad / Freight Wagon Coupler
  bombDefusal,   // Sunlit Moss Temple Altar & Rune Pedestals
  bossBattle,    // Sunlit Castle Arena & Mythical Challenge Guardian
  worldRadar,    // Lush Tropical Island Expedition Radar
}

// ============================================================================
// 2. MASTER FLAME GAME ENGINE (100% FLAME 2D OPEN WORLD - NATURE VIBRANT)
// ============================================================================

class PocketFlameArcadeGame extends FlameGame with TapCallbacks {
  final int day;
  final int gameIndex;
  final DayGameSpec spec;
  final List<ArcadeChallengeRound> rounds;
  final void Function(int score, int lives, int combo) onStatsChanged;
  final void Function(bool isCorrect, String text, String explanation) onAnswerFeedback;
  final VoidCallback onGameCompleted;

  PocketFlameArcadeGame({
    required this.day,
    required this.gameIndex,
    required this.spec,
    required this.rounds,
    required this.onStatsChanged,
    required this.onAnswerFeedback,
    required this.onGameCompleted,
  });

  late final FlameArchetype archetype;

  int currentRoundIndex = 0;
  int score = 0;
  int combo = 0;
  int lives = 3;

  double totalTime = 0.0;
  double scrollOffset = 0.0;
  double transitionTimer = 0.0;
  double screenShakeTimer = 0.0;
  double feedbackFlashTimer = 0.0;
  Color feedbackFlashColor = Colors.transparent;

  final List<FlameArcadeParticle> particles = [];
  final List<FlameFloatingText> floatingTexts = [];

  // Interactive Game-Specific State
  // 1. Racer (Day 2 G1, Day 8 G1, Day 11 G1, Day 14 G1, Day 16 G1, Day 17 G1 & G2)
  double carX = 0.5; // 0.0 to 1.0 (lanes 0, 1, 2)
  double targetCarX = 0.5;
  int carLane = 1;
  double approachProgress = 0.0;
  bool nitroActive = false;

  // 2. Meadow Runner (Day 1 G1, Day 4 G1, Day 7 G1, Day 9 G2, Day 10 G2, Day 15 G1, Day 18 G1, Day 20 G1)
  double heroX = 0.5;
  double heroY = 0.78;
  double heroJumpY = 0.0;
  bool isHeroWalking = true;
  double walkCycle = 0.0;

  // 3. Football / Goal / Orchard (Day 3 G2, Day 7 G2, Day 12 G1, Day 13 G2, Day 19 G1)
  double ballX = 0.5;
  double ballY = 0.82;
  bool ballKicked = false;
  int targetGoalIdx = 0;

  // 4. Submarine & Ocean (Day 3 G1, Day 5 G1, Day 11 G1)
  double subX = 0.5;
  double subY = 0.70;
  double targetSubX = 0.5;

  // 5. Boss Battle (Day 10 G1, Day 20 G2)
  double bossHp = 1.0;
  double spellBeamProgress = 0.0;
  int activeSpellRune = -1;

  // 6. Garden Temple Altar / Lock (Day 8 G2, Day 15 G2)
  int defusalTimerSeconds = 25;
  double defusalTickTimer = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF064E3B); // Lush emerald green nature background

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    archetype = _resolveArchetype(spec.genre, day, gameIndex);
    _resetRoundPositions();
  }

  FlameArchetype _resolveArchetype(GameGenre genre, int day, int gameIndex) {
    // Dedicated Open-World archetype routing for Days 1 to 20
    if (day == 1) {
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.popIt;
    } else if (day == 2) {
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.targetShooter;
    } else if (day == 3) {
      return gameIndex == 1 ? FlameArchetype.oceanDiver : FlameArchetype.sportsGoal;
    } else if (day == 4) {
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.targetShooter;
    } else if (day == 5) {
      return gameIndex == 1 ? FlameArchetype.oceanDiver : FlameArchetype.popIt;
    } else if (day == 6) {
      return gameIndex == 1 ? FlameArchetype.trainCoupler : FlameArchetype.popIt;
    } else if (day == 7) {
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.targetShooter;
    } else if (day == 8) {
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.bombDefusal;
    } else if (day == 9) {
      return gameIndex == 1 ? FlameArchetype.oceanDiver : FlameArchetype.runner;
    } else if (day == 10) {
      return gameIndex == 1 ? FlameArchetype.targetShooter : FlameArchetype.runner;
    } else if (day == 11) {
      // Day 11: Speedboat River Navigator & Wave Island Beach
      return gameIndex == 1 ? FlameArchetype.oceanDiver : FlameArchetype.popIt;
    } else if (day == 12) {
      // Day 12: Castle Inn Food Counter & Garden Shield Slash
      return gameIndex == 1 ? FlameArchetype.sportsGoal : FlameArchetype.targetShooter;
    } else if (day == 13) {
      // Day 13: Botanical Park Detective & Sunny Orchard Small-Talk
      return gameIndex == 1 ? FlameArchetype.worldRadar : FlameArchetype.sportsGoal;
    } else if (day == 14) {
      // Day 14: Hilltop Market Road Delivery & Parachute Market Drop
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.popIt;
    } else if (day == 15) {
      // Day 15: River Stepping Stones Phone & Sunlit Stone Altar
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.bombDefusal;
    } else if (day == 16) {
      // Day 16: Dragon Mountain Flight & Meadow Flying Clay Discs
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.targetShooter;
    } else if (day == 17) {
      // Day 17: Pine Forest Grand Prix & Countryside Scenic Highway
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.racer;
    } else if (day == 18) {
      // Day 18: Lakeside Resort Check-In & Sunny Lake Target Splash
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.targetShooter;
    } else if (day == 19) {
      // Day 19: Green Meadow Sports Turf & Botanical Hedge Maze Idioms
      return gameIndex == 1 ? FlameArchetype.sportsGoal : FlameArchetype.worldRadar;
    } else if (day == 20) {
      // Day 20: Grand Emerald Mountain Interview & Sunlit Castle Arena Mastery
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.bossBattle;
    } else if (day == 21) {
      // Day 21: Word Chase Police Racer & Magnet Word Collector Turf
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.sportsGoal;
    } else if (day == 22) {
      // Day 22: Sentence Construction Coupler & Bomb Defusal Altar
      return gameIndex == 1 ? FlameArchetype.trainCoupler : FlameArchetype.bombDefusal;
    } else if (day == 23) {
      // Day 23: UFO Word Catch Pop-It & Moving Target Grammar Shooter
      return gameIndex == 1 ? FlameArchetype.popIt : FlameArchetype.targetShooter;
    } else if (day == 24) {
      // Day 24: Grammar Snow Ride Slalom & Ice Breaker Conversational Shooter
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.targetShooter;
    } else if (day == 25) {
      // Day 25: Island Survival Runner & River Crossing Diver
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.oceanDiver;
    } else if (day == 26) {
      // Day 26: Factory Sorter Train Coupler & Machine Word Fixer Altar
      return gameIndex == 1 ? FlameArchetype.trainCoupler : FlameArchetype.bombDefusal;
    } else if (day == 27) {
      // Day 27: Word Swarm Runner & Precision Homophone Shooter
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.targetShooter;
    } else if (day == 28) {
      // Day 28: Metro English Rush Runner & Correct Door Escape Radar
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.worldRadar;
    } else if (day == 29) {
      // Day 29: Mountain Climb Runner & Falling Rock Choice Pop-It
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.popIt;
    } else if (day == 30) {
      // Day 30: 30-Day English Arena Pitch & Sovereign Grammar King Boss Battle
      return gameIndex == 1 ? FlameArchetype.sportsGoal : FlameArchetype.bossBattle;
    } else if (day == 31) {
      // Day 31: Desert Runner & Vocabulary Survival Radar
      return gameIndex == 1 ? FlameArchetype.runner : FlameArchetype.worldRadar;
    } else if (day == 32) {
      // Day 32: Nitro Sentence Race & Highway Patrol Grammar Checkpoint
      return gameIndex == 1 ? FlameArchetype.racer : FlameArchetype.racer;
    } else if (day == 33) {
      // Day 33: Rescue Mission Helicopter Diver & Sky Landing Words Pop-It
      return gameIndex == 1 ? FlameArchetype.oceanDiver : FlameArchetype.popIt;
    } else if (day == 34) {
      // Day 34: Emergency Hospital Triage Altar & Fast Response 911 Racer
      return gameIndex == 1 ? FlameArchetype.bombDefusal : FlameArchetype.racer;
    } else if (day == 35) {
      // Day 35: Magic Word Quest Boss Battle & Spell Sentence Coupler
      return gameIndex == 1 ? FlameArchetype.bossBattle : FlameArchetype.trainCoupler;
    }

    // General fallback mapping for Days 21 to 90
    switch (genre) {
      case GameGenre.driving:
      case GameGenre.nitroRace:
      case GameGenre.chase:
      case GameGenre.trafficCrossing:
      case GameGenre.snowRide:
      case GameGenre.metroRush:
        return FlameArchetype.racer;

      case GameGenre.runner:
      case GameGenre.swarmEvasion:
      case GameGenre.climbing:
      case GameGenre.mazeRunner:
      case GameGenre.snake:
        return FlameArchetype.runner;

      case GameGenre.fallingBlocks:
      case GameGenre.skySelection:
      case GameGenre.flying:
        return FlameArchetype.popIt;

      case GameGenre.shooting:
      case GameGenre.slashing:
      case GameGenre.archery:
        return FlameArchetype.targetShooter;

      case GameGenre.collecting:
      case GameGenre.jumping:
        return FlameArchetype.sportsGoal;

      case GameGenre.diving:
      case GameGenre.boating:
      case GameGenre.riverCrossing:
      case GameGenre.islandSurvival:
      case GameGenre.iceBreaker:
        return FlameArchetype.oceanDiver;

      case GameGenre.trainTracking:
      case GameGenre.factorySorting:
      case GameGenre.machineFixing:
      case GameGenre.construction:
        return FlameArchetype.trainCoupler;

      case GameGenre.bombDefusal:
      case GameGenre.codeBreaker:
      case GameGenre.scienceLab:
      case GameGenre.escapeRoom:
        return FlameArchetype.bombDefusal;

      case GameGenre.castleDefense:
      case GameGenre.arenaBoss:
      case GameGenre.survival:
      case GameGenre.rescueMission:
      case GameGenre.emergencyResponse:
      case GameGenre.robotBattle:
      case GameGenre.dialogueBattle:
      case GameGenre.interviewBattle:
        return FlameArchetype.bossBattle;

      case GameGenre.detective:
      case GameGenre.worldExpedition:
      case GameGenre.treasureHunt:
      case GameGenre.magicQuest:
      case GameGenre.arcadeMemory:
      case GameGenre.doorEscape:
      case GameGenre.audioHunter:
      case GameGenre.liveReporting:
      case GameGenre.magnet:
        return FlameArchetype.worldRadar;
    }
  }

  void _resetRoundPositions() {
    approachProgress = 0.0;
    nitroActive = false;
    ballKicked = false;
    heroJumpY = 0.0;
    spellBeamProgress = 0.0;
    defusalTimerSeconds = 25;
    defusalTickTimer = 0.0;
  }

  ArcadeChallengeRound get currentRound {
    if (rounds.isEmpty) {
      return ArcadeChallengeRound(
        promptEn: 'Master the Challenge!',
        promptMl: 'ശരിയായ ഉത്തരം തിരഞ്ഞെടുക്കുക',
        voiceLeadIn: 'Choose the correct answer',
        targetWord: 'Ready',
        options: ['Ready', 'Set', 'Go'],
        correctIndex: 0,
        explanationEn: 'Prepare to learn and explore!',
      );
    }
    return rounds[currentRoundIndex.clamp(0, rounds.length - 1)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    totalTime += dt;
    scrollOffset += dt * 180.0;

    // Smooth Car Lerp
    carX += (targetCarX - carX) * (dt * 12.0);

    // Smooth Submarine Lerp
    subX += (targetSubX - subX) * (dt * 8.0);

    // Hero Walk Cycle
    walkCycle += dt * 8.0;
    if (heroJumpY > 0) {
      heroJumpY = math.max(0, heroJumpY - (dt * 180.0));
    }

    // Ball Kicked Animation
    if (ballKicked) {
      final round = currentRound;
      final targetNetX = (targetGoalIdx + 0.5) / (round.options.length.clamp(2, 4));
      ballX += (targetNetX - ballX) * (dt * 10.0);
      ballY -= dt * 1.6;
      if (ballY <= 0.38) {
        ballKicked = false;
        _evaluateAnswer(targetGoalIdx);
      }
    }

    // Approach Progress for Racers / Highway
    approachProgress = (approachProgress + dt * 0.45).clamp(0.0, 1.0);
    if (approachProgress >= 1.0 && archetype == FlameArchetype.racer) {
      _evaluateAnswer(carLane);
      approachProgress = 0.0;
    }

    // Bomb Defusal Countdown Tick
    if (archetype == FlameArchetype.bombDefusal) {
      defusalTickTimer += dt;
      if (defusalTickTimer >= 1.0) {
        defusalTickTimer = 0.0;
        if (defusalTimerSeconds > 0) {
          defusalTimerSeconds--;
        } else {
          // Time expired -> count as mistake and reset timer
          _evaluateAnswer(-1);
          defusalTimerSeconds = 25;
        }
      }
    }

    // Screen Shake & Feedback Flash
    if (screenShakeTimer > 0) screenShakeTimer -= dt;
    if (feedbackFlashTimer > 0) feedbackFlashTimer -= dt;

    // Transition between rounds
    if (transitionTimer > 0) {
      transitionTimer -= dt;
      if (transitionTimer <= 0) {
        _advanceToNextRound();
      }
    }

    // Update Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].life <= 0) {
        particles.removeAt(i);
      }
    }

    // Update Floating Texts
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].update(dt);
      if (floatingTexts[i].life <= 0) {
        floatingTexts.removeAt(i);
      }
    }
  }

  // ==========================================================================
  // DIRECT TOUCH INPUT HANDLING (Responsive Open World Tap)
  // ==========================================================================
  @override
  void onTapDown(TapDownEvent event) {
    if (transitionTimer > 0) return; // wait for round transition

    final pos = event.localPosition;
    final w = size.x;
    final h = size.y;
    final round = currentRound;
    final numOptions = round.options.length.clamp(2, 4);

    switch (archetype) {
      case FlameArchetype.racer:
        // Tap on left, center, or right lane
        final lane = (pos.x / (w / 3.0)).floor().clamp(0, 2);
        carLane = lane;
        targetCarX = (lane + 0.5) / 3.0;
        HapticFeedback.selectionClick();
        _spawnParticles(pos.x, pos.y, const Color(0xFF38BDF8), count: 6);
        if (pos.y < h * 0.58) {
          _triggerLaneAnswer(lane);
        }
        break;

      case FlameArchetype.popIt:
        // Tap directly on falling balloons/bubbles
        for (int i = 0; i < numOptions; i++) {
          final bx = w * ((i + 1) / (numOptions + 1));
          final by = h * 0.38 + math.sin(totalTime * 2.5 + i * 1.5) * 35;
          final dist = (Offset(pos.x, pos.y) - Offset(bx, by)).distance;
          if (dist <= 60) {
            _spawnPopBurst(bx, by, _getOptionColor(i));
            _evaluateAnswer(i);
            return;
          }
        }
        final col = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        _evaluateAnswer(col);
        break;

      case FlameArchetype.targetShooter:
        // Tap archery bullseye target or range zone
        for (int i = 0; i < numOptions; i++) {
          final tx = w * 0.5 + math.sin(totalTime * (1.2 + i * 0.3) + i) * (w * 0.28);
          final ty = h * (0.28 + i * 0.15);
          final dist = (Offset(pos.x, pos.y) - Offset(tx, ty)).distance;
          if (dist <= 65) {
            _spawnLaserBeam(w * 0.5, h * 0.86, tx, ty);
            _evaluateAnswer(i);
            return;
          }
        }
        final targetIdx = (pos.y / (h * 0.65) * numOptions).floor().clamp(0, numOptions - 1);
        _evaluateAnswer(targetIdx);
        break;

      case FlameArchetype.sportsGoal:
        // Tap goal net / orchard tree basket
        final goalIdx = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        targetGoalIdx = goalIdx;
        ballKicked = true;
        HapticFeedback.mediumImpact();
        break;

      case FlameArchetype.oceanDiver:
        // Tap ocean pearl or submarine path
        final diverLane = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        subX = targetSubX = (diverLane + 0.5) / numOptions;
        _spawnParticles(pos.x, pos.y, const Color(0xFF06B6D4), count: 12);
        _evaluateAnswer(diverLane);
        break;

      case FlameArchetype.trainCoupler:
        // Tap freight wagon to couple it
        final wagonIdx = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        _spawnParticles(pos.x, pos.y, const Color(0xFFF59E0B), count: 10);
        _evaluateAnswer(wagonIdx);
        break;

      case FlameArchetype.bombDefusal:
        // Tap garden altar rune stone
        for (int i = 0; i < numOptions; i++) {
          final wy = h * (0.38 + i * 0.13);
          if (pos.y >= wy && pos.y <= wy + 52) {
            _spawnParticles(pos.x, pos.y, _getOptionColor(i), count: 14);
            _evaluateAnswer(i);
            return;
          }
        }
        final wireIdx = ((pos.y - h * 0.35) / (h * 0.40) * numOptions).floor().clamp(0, numOptions - 1);
        _evaluateAnswer(wireIdx);
        break;

      case FlameArchetype.bossBattle:
        // Tap spell casting rune
        for (int i = 0; i < numOptions; i++) {
          final rx = w * ((i + 1) / (numOptions + 1));
          final ry = h * 0.62;
          final dist = (Offset(pos.x, pos.y) - Offset(rx, ry)).distance;
          if (dist <= 50) {
            _spawnSpellBeam(rx, ry, w * 0.5, h * 0.32);
            _evaluateAnswer(i);
            return;
          }
        }
        final runeIdx = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        _evaluateAnswer(runeIdx);
        break;

      case FlameArchetype.worldRadar:
        // Tap radar discovery blip
        final blipIdx = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        _spawnParticles(pos.x, pos.y, const Color(0xFF10B981), count: 15);
        _evaluateAnswer(blipIdx);
        break;

      case FlameArchetype.runner:
        // Tap open-world stepping stone or path lane
        final runLane = (pos.x / (w / numOptions)).floor().clamp(0, numOptions - 1);
        heroX = (runLane + 0.5) / numOptions;
        heroJumpY = 28.0;
        HapticFeedback.lightImpact();
        _spawnParticles(pos.x, pos.y, const Color(0xFFFFD700), count: 8);
        _evaluateAnswer(runLane);
        break;
    }
  }

  void _triggerLaneAnswer(int lane) {
    _evaluateAnswer(lane);
  }

  void _evaluateAnswer(int selectedIndex) {
    final round = currentRound;
    final isCorrect = selectedIndex == round.correctIndex;
    final selectedText = (selectedIndex >= 0 && selectedIndex < round.options.length)
        ? round.options[selectedIndex]
        : 'Option';

    if (isCorrect) {
      combo++;
      final bonus = combo * 25;
      score += (100 + bonus);
      nitroActive = true;

      // Celebrate with particles & floating XP text
      _spawnFireworks(size.x * 0.5, size.y * 0.45);
      floatingTexts.add(
        FlameFloatingText(
          x: size.x * 0.5,
          y: size.y * 0.42,
          text: 'PERFECT! +${100 + bonus} XP ⭐',
          color: const Color(0xFFFFD700),
        ),
      );

      if (archetype == FlameArchetype.bossBattle) {
        bossHp = (bossHp - 0.35).clamp(0.0, 1.0);
      }

      HapticFeedback.heavyImpact();
      onStatsChanged(score, lives, combo);
      onAnswerFeedback(true, selectedText, round.explanationEn);

      transitionTimer = 0.85; // smooth advance to next round
    } else {
      combo = 0;
      lives = (lives - 1).clamp(0, 3);
      screenShakeTimer = 0.35; // screen shakes
      _spawnRedSmoke(size.x * 0.5, size.y * 0.50);

      floatingTexts.add(
        FlameFloatingText(
          x: size.x * 0.5,
          y: size.y * 0.45,
          text: 'TRY AGAIN! -1 ❤️',
          color: const Color(0xFFEF4444),
        ),
      );

      HapticFeedback.vibrate();
      onStatsChanged(score, lives, combo);
      onAnswerFeedback(false, selectedText, round.explanationEn);

      if (lives <= 0) {
        // Auto-refresh lives so player never gets permanently stuck
        lives = 3;
        onStatsChanged(score, lives, combo);
      }
    }
  }

  void _advanceToNextRound() {
    if (currentRoundIndex < rounds.length - 1) {
      currentRoundIndex++;
      _resetRoundPositions();
    } else {
      // Completed all rounds
      onGameCompleted();
    }
  }

  // ==========================================================================
  // PARTICLE & VISUAL EFFECTS
  // ==========================================================================
  void _spawnParticles(double x, double y, Color color, {int count = 8}) {
    final rand = math.Random();
    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 60 + rand.nextDouble() * 140;
      particles.add(
        FlameArcadeParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          life: 0.6 + rand.nextDouble() * 0.4,
          color: color,
          size: 4 + rand.nextDouble() * 4,
          isSquare: rand.nextBool(),
        ),
      );
    }
  }

  void _spawnPopBurst(double x, double y, Color color) {
    _spawnParticles(x, y, color, count: 16);
    _spawnParticles(x, y, Colors.white, count: 8);
  }

  void _spawnFireworks(double x, double y) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFF38BDF8),
      const Color(0xFF10B981),
      const Color(0xFFF43F5E),
      Colors.white,
    ];
    final rand = math.Random();
    for (int i = 0; i < 28; i++) {
      final color = colors[i % colors.length];
      final angle = (i / 28.0) * math.pi * 2;
      final speed = 90 + rand.nextDouble() * 160;
      particles.add(
        FlameArcadeParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          life: 0.8 + rand.nextDouble() * 0.5,
          color: color,
          size: 5 + rand.nextDouble() * 4,
          isSquare: rand.nextBool(),
        ),
      );
    }
  }

  void _spawnRedSmoke(double x, double y) {
    final rand = math.Random();
    for (int i = 0; i < 14; i++) {
      particles.add(
        FlameArcadeParticle(
          x: x + (rand.nextDouble() - 0.5) * 40,
          y: y + (rand.nextDouble() - 0.5) * 20,
          vx: (rand.nextDouble() - 0.5) * 60,
          vy: -40 - rand.nextDouble() * 50,
          life: 0.6,
          color: const Color(0xFFEF4444).withValues(alpha: 0.8),
          size: 8 + rand.nextDouble() * 6,
        ),
      );
    }
  }

  void _spawnLaserBeam(double x1, double y1, double x2, double y2) {
    _spawnParticles(x2, y2, const Color(0xFFFFD700), count: 12);
  }

  void _spawnSpellBeam(double x1, double y1, double x2, double y2) {
    _spawnParticles(x2, y2, const Color(0xFFA855F7), count: 14);
  }

  Color _getOptionColor(int index) {
    const palette = [
      Color(0xFF38BDF8), // Cyan / Sky Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Amber / Gold
      Color(0xFFA855F7), // Purple / Amethyst
    ];
    return palette[index % palette.length];
  }

  // ==========================================================================
  // MASTER RENDER LOOP (100% LUSH GREEN NATURE OPEN WORLD - ZERO DARK MODE)
  // ==========================================================================
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    if (w <= 0 || h <= 0) return;

    // Apply Screen Shake if active
    if (screenShakeTimer > 0) {
      final shakeX = (math.Random().nextDouble() - 0.5) * 10;
      final shakeY = (math.Random().nextDouble() - 0.5) * 10;
      canvas.save();
      canvas.translate(shakeX, shakeY);
    }

    final round = currentRound;

    // Route to dedicated 2D Open-World Nature Renderer
    switch (archetype) {
      case FlameArchetype.racer:
        _renderRoadRacer(canvas, w, h, round);
        break;
      case FlameArchetype.runner:
        _renderMeadowRunner(canvas, w, h, round);
        break;
      case FlameArchetype.popIt:
        _renderSkyPopIt(canvas, w, h, round);
        break;
      case FlameArchetype.targetShooter:
        _renderTargetShooter(canvas, w, h, round);
        break;
      case FlameArchetype.sportsGoal:
        _renderSportsGoal(canvas, w, h, round);
        break;
      case FlameArchetype.oceanDiver:
        _renderOceanDiver(canvas, w, h, round);
        break;
      case FlameArchetype.trainCoupler:
        _renderTrainCoupler(canvas, w, h, round);
        break;
      case FlameArchetype.bombDefusal:
        _renderBombDefusal(canvas, w, h, round);
        break;
      case FlameArchetype.bossBattle:
        _renderBossBattle(canvas, w, h, round);
        break;
      case FlameArchetype.worldRadar:
        _renderWorldRadar(canvas, w, h, round);
        break;
    }

    // Render Particles
    for (final p in particles) {
      p.render(canvas);
    }

    // Render Floating XP Texts
    for (final t in floatingTexts) {
      t.render(canvas);
    }

    if (screenShakeTimer > 0) {
      canvas.restore();
    }
  }

  // --------------------------------------------------------------------------
  // 1. HIGHWAY / COUNTRYSIDE SCENIC ROAD RACER (Lush Green Countryside)
  // --------------------------------------------------------------------------
  void _renderRoadRacer(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Sunny blue sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF7DD3FC), Color(0xFFBAE6FD)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.35));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.35), skyPaint);

    // Glowing Golden Sun
    canvas.drawCircle(Offset(w * 0.85, h * 0.12), 28, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(Offset(w * 0.85, h * 0.12), 38, Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.35));

    // Rolling green hills on horizon
    final hillPath = Path()..moveTo(0, h * 0.35);
    for (double x = 0; x <= w; x += 30) {
      hillPath.lineTo(x, h * 0.28 + math.sin(x * 0.03) * 16);
    }
    hillPath.lineTo(w, h * 0.35);
    canvas.drawPath(hillPath, Paint()..color = const Color(0xFF15803D));

    // Lush green roadside borders with wildflowers
    canvas.drawRect(Rect.fromLTWH(0, h * 0.35, w, h * 0.65), Paint()..color = const Color(0xFF16A34A));

    // 3-Lane Clean Countryside Road Track
    final roadRect = Rect.fromLTWH(w * 0.08, h * 0.35, w * 0.84, h * 0.65);
    canvas.drawRect(roadRect, Paint()..color = const Color(0xFF334155));

    // Racing Red & White Curb Blocks
    for (double y = h * 0.35; y < h; y += 24) {
      final isRed = ((y / 24).floor() % 2 == 0);
      final curbColor = isRed ? const Color(0xFFEF4444) : Colors.white;
      canvas.drawRect(Rect.fromLTWH(w * 0.08 - 8, y, 8, 24), Paint()..color = curbColor);
      canvas.drawRect(Rect.fromLTWH(w * 0.92, y, 8, 24), Paint()..color = curbColor);
    }

    // Dashed Lane Dividers (Animated downward scrolling)
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3;
    final lane1X = w * 0.08 + (w * 0.84 / 3.0);
    final lane2X = w * 0.08 + (w * 0.84 / 3.0 * 2.0);

    for (double y = h * 0.35 + (scrollOffset % 48) - 48; y < h; y += 48) {
      if (y >= h * 0.35) {
        canvas.drawLine(Offset(lane1X, y), Offset(lane1X, y + 24), stripePaint);
        canvas.drawLine(Offset(lane2X, y), Offset(lane2X, y + 24), stripePaint);
      }
    }

    // Overhead Highway Signs (Lush Emerald Signs with Gold Borders)
    final numOpts = round.options.length.clamp(2, 3);
    final signY = h * 0.38 + (approachProgress * (h * 0.32));

    for (int i = 0; i < numOpts; i++) {
      final laneCenterX = w * 0.08 + (w * 0.84 / 3.0 * (i + 0.5));
      final isSelectedLane = carLane == i;
      final signRect = Rect.fromCenter(
        center: Offset(laneCenterX, signY),
        width: (w * 0.84 / 3.0) - 8,
        height: 54,
      );

      final signBg = Paint()
        ..color = isSelectedLane ? const Color(0xFF047857) : const Color(0xFF065F46)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(signRect, const Radius.circular(10)), signBg);

      final signBorder = Paint()
        ..color = isSelectedLane ? const Color(0xFFFFD700) : const Color(0xFF34D399)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelectedLane ? 2.8 : 1.5;
      canvas.drawRRect(RRect.fromRectAndRadius(signRect, const Radius.circular(10)), signBorder);

      // Sign Text
      _drawCenteredText(
        canvas,
        round.options[i],
        Offset(laneCenterX, signY),
        fontSize: 12.0,
        color: Colors.white,
      );
    }

    // 2D Yellow & Cyan Sports Car
    final playerX = w * 0.08 + (w * 0.84 * carX);
    final playerY = h * 0.82;
    _draw2DCar(canvas, playerX, playerY, nitroActive);
  }

  void _draw2DCar(Canvas canvas, double cx, double cy, bool nitro) {
    // Underglow
    final glowPaint = Paint()
      ..color = (nitro ? const Color(0xFF10B981) : const Color(0xFFFFD700)).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy), 28, glowPaint);

    // Car Body
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: 44, height: 68);
    final carPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
      ).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(10)), carPaint);

    // Windshield
    final glassRect = Rect.fromCenter(center: Offset(cx, cy - 8), width: 32, height: 20);
    canvas.drawRRect(RRect.fromRectAndRadius(glassRect, const Radius.circular(4)), Paint()..color = const Color(0xFF0284C7));

    // Wheels
    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 24, cy - 16), width: 6, height: 16), const Radius.circular(3)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 24, cy - 16), width: 6, height: 16), const Radius.circular(3)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 24, cy + 16), width: 6, height: 16), const Radius.circular(3)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 24, cy + 16), width: 6, height: 16), const Radius.circular(3)), wheelPaint);

    // Nitro exhaust trail
    if (nitro) {
      final nitroPaint = Paint()..color = const Color(0xFF00E5FF);
      canvas.drawCircle(Offset(cx - 10, cy + 38), 6, nitroPaint);
      canvas.drawCircle(Offset(cx + 10, cy + 38), 6, nitroPaint);
    }
  }

  // --------------------------------------------------------------------------
  // 2. LUSH GREEN MEADOW & FOREST RUNNER
  // --------------------------------------------------------------------------
  void _renderMeadowRunner(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Sunny blue sky
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFFBAE6FD)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.45), sky);

    // Golden Sun
    canvas.drawCircle(Offset(w * 0.85, h * 0.15), 32, Paint()..color = const Color(0xFFFDE047));

    // Layered green rolling hills
    final hill1 = Path()
      ..moveTo(0, h * 0.42)
      ..quadraticBezierTo(w * 0.35, h * 0.32, w * 0.70, h * 0.40)
      ..quadraticBezierTo(w * 0.85, h * 0.44, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h);
    canvas.drawPath(hill1, Paint()..color = const Color(0xFF15803D));

    final hill2 = Path()
      ..moveTo(0, h * 0.52)
      ..quadraticBezierTo(w * 0.45, h * 0.44, w, h * 0.50)
      ..lineTo(w, h)
      ..lineTo(0, h);
    canvas.drawPath(hill2, Paint()..color = const Color(0xFF16A34A));

    final hill3 = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.55, h * 0.60, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h);
    canvas.drawPath(hill3, Paint()..color = const Color(0xFF22C55E));

    // Open-World Word Discovery Shrines / Stepping Stones
    final numOpts = round.options.length.clamp(2, 4);
    for (int i = 0; i < numOpts; i++) {
      final px = w * ((i + 1) / (numOpts + 1));
      final py = h * 0.45 + math.sin(totalTime * 3 + i) * 14;

      // Stone Pedestal base
      final baseRect = Rect.fromCenter(center: Offset(px, py + 26), width: (w / numOpts) - 14, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(baseRect, const Radius.circular(8)), Paint()..color = const Color(0xFF475569));

      // Lush Emerald crystal container
      final orbRect = Rect.fromCenter(center: Offset(px, py), width: (w / numOpts) - 14, height: 52);
      canvas.drawRRect(RRect.fromRectAndRadius(orbRect, const Radius.circular(14)), Paint()..color = const Color(0xFF065F46).withValues(alpha: 0.95));
      canvas.drawRRect(
        RRect.fromRectAndRadius(orbRect, const Radius.circular(14)),
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      _drawCenteredText(canvas, round.options[i], Offset(px, py), fontSize: 12.5, color: Colors.white);
    }

    // Interactive Animated Explorer Hero
    final heroXPos = w * heroX;
    final heroYPos = (h * heroY) - heroJumpY;
    _drawExplorerHero(canvas, heroXPos, heroYPos, isHeroWalking, walkCycle);
  }

  void _drawExplorerHero(Canvas canvas, double rx, double ry, bool isWalking, double walk) {
    // Shadow
    canvas.drawOval(Rect.fromCenter(center: Offset(rx, ry + 28), width: 34, height: 12), Paint()..color = Colors.black26);

    // Animated Legs
    final legSwing = math.sin(walk) * 6;
    final legPaint = Paint()..color = const Color(0xFF1E3A8A)..strokeWidth = 5;
    canvas.drawLine(Offset(rx - 6, ry + 14), Offset(rx - 6 - legSwing, ry + 26), legPaint);
    canvas.drawLine(Offset(rx + 6, ry + 14), Offset(rx + 6 + legSwing, ry + 26), legPaint);

    // Torso (Adventurer Jacket)
    final jacketRect = Rect.fromCenter(center: Offset(rx, ry + 2), width: 24, height: 24);
    canvas.drawRRect(RRect.fromRectAndRadius(jacketRect, const Radius.circular(6)), Paint()..color = const Color(0xFF10B981));

    // Explorer Backpack
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(rx - 12, ry + 2), width: 8, height: 18), const Radius.circular(3)), Paint()..color = const Color(0xFF78350F));

    // Head
    canvas.drawCircle(Offset(rx, ry - 16), 13, Paint()..color = const Color(0xFFFDBA74));
    // Safari Hat
    canvas.drawOval(Rect.fromCenter(center: Offset(rx, ry - 22), width: 34, height: 10), Paint()..color = const Color(0xFF0284C7));
    canvas.drawCircle(Offset(rx, ry - 24), 9, Paint()..color = const Color(0xFF0369A1));
  }

  // --------------------------------------------------------------------------
  // 3. SUNNY SKY POP-IT & RAINBOW BALLOONS
  // --------------------------------------------------------------------------
  void _renderSkyPopIt(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Bright morning blue sky
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Subtle Rainbow Arc across sky
    final rainbowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    rainbowPaint.color = const Color(0xFFEF4444).withValues(alpha: 0.25);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.40), width: w * 1.2, height: h * 0.7), math.pi, math.pi, false, rainbowPaint);
    rainbowPaint.color = const Color(0xFFF59E0B).withValues(alpha: 0.25);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.40), width: w * 1.2 - 12, height: h * 0.7 - 12), math.pi, math.pi, false, rainbowPaint);
    rainbowPaint.color = const Color(0xFF10B981).withValues(alpha: 0.25);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.40), width: w * 1.2 - 24, height: h * 0.7 - 24), math.pi, math.pi, false, rainbowPaint);

    // Drifting puffy clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.40);
    for (int i = 0; i < 4; i++) {
      final cx = (w * (0.2 + i * 0.3) + scrollOffset * 0.15) % (w + 100) - 50;
      final cy = h * (0.10 + (i % 2) * 0.08);
      canvas.drawCircle(Offset(cx, cy), 30, cloudPaint);
      canvas.drawCircle(Offset(cx + 20, cy - 6), 38, cloudPaint);
      canvas.drawCircle(Offset(cx + 40, cy), 26, cloudPaint);
    }

    // Lush green meadow on lower horizon
    final meadowPath = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.5, h * 0.78, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h);
    canvas.drawPath(meadowPath, Paint()..color = const Color(0xFF16A34A));

    // Vibrant Floating Balloons / Pop-It Spheres
    final numOpts = round.options.length.clamp(2, 4);
    for (int i = 0; i < numOpts; i++) {
      final bx = w * ((i + 1) / (numOpts + 1));
      final by = h * 0.44 + math.sin(totalTime * 2.5 + i * 1.5) * 35;
      final color = _getOptionColor(i);

      // Balloon string
      final stringPaint = Paint()
        ..color = Colors.white70
        ..strokeWidth = 1.8;
      canvas.drawLine(Offset(bx, by + 45), Offset(bx, by + 90), stringPaint);

      // Pop-It Balloon Sphere with 3D gradient highlight
      final balloonRect = Rect.fromCircle(center: Offset(bx, by), radius: 46);
      final spherePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [Colors.white.withValues(alpha: 0.9), color, color.withValues(alpha: 0.95)],
        ).createShader(balloonRect);
      canvas.drawCircle(Offset(bx, by), 46, spherePaint);

      // Tactile dots
      for (int d = 0; d < 6; d++) {
        final dAngle = (d / 6.0) * math.pi * 2;
        final dx = bx + math.cos(dAngle) * 32;
        final dy = by + math.sin(dAngle) * 32;
        canvas.drawCircle(Offset(dx, dy), 4.5, Paint()..color = Colors.white38);
      }

      // Word / Phrase Text
      _drawCenteredText(
        canvas,
        round.options[i],
        Offset(bx, by),
        fontSize: 12.0,
        color: Colors.white,
        shadowColor: Colors.black87,
      );
    }
  }

  // --------------------------------------------------------------------------
  // 4. SUNNY MEADOW ARCHERY & TARGET RANGE
  // --------------------------------------------------------------------------
  void _renderTargetShooter(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Sunny sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.65),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.65)),
    );

    // Green archery practice turf
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), Paint()..color = const Color(0xFF15803D));

    // Wooden Cedar Fence backdrop
    final fencePaint = Paint()
      ..color = const Color(0xFFB45309)
      ..strokeWidth = 6;
    for (double x = 10; x < w; x += 36) {
      canvas.drawLine(Offset(x, h * 0.20), Offset(x, h * 0.65), fencePaint);
    }

    // Moving Bullseye Targets (oscillating horizontally)
    final numOpts = round.options.length.clamp(2, 3);
    for (int i = 0; i < numOpts; i++) {
      final tx = w * 0.5 + math.sin(totalTime * (1.2 + i * 0.3) + i) * (w * 0.28);
      final ty = h * (0.28 + i * 0.14);

      // Wooden Post Stand
      canvas.drawLine(Offset(tx, ty), Offset(tx, h * 0.65), Paint()..color = const Color(0xFF92400E)..strokeWidth = 5);

      // Bullseye concentric target rings
      canvas.drawCircle(Offset(tx, ty), 38, Paint()..color = const Color(0xFFEF4444));
      canvas.drawCircle(Offset(tx, ty), 28, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(tx, ty), 18, Paint()..color = const Color(0xFF0284C7));
      canvas.drawCircle(Offset(tx, ty), 8, Paint()..color = const Color(0xFFFFD700));

      // Emerald Option Banner beneath target
      final bannerRect = Rect.fromCenter(center: Offset(tx, ty + 42), width: 125, height: 28);
      canvas.drawRRect(RRect.fromRectAndRadius(bannerRect, const Radius.circular(8)), Paint()..color = const Color(0xFF065F46));
      canvas.drawRRect(RRect.fromRectAndRadius(bannerRect, const Radius.circular(8)), Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 1.8);

      _drawCenteredText(canvas, round.options[i], Offset(tx, ty + 42), fontSize: 11.5, color: Colors.white);
    }

    // Player Bow / Laser Crosshair
    final bowX = w * 0.5;
    final bowY = h * 0.86;
    canvas.drawCircle(Offset(bowX, bowY), 24, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.35));
    canvas.drawCircle(Offset(bowX, bowY), 10, Paint()..color = const Color(0xFF0284C7));
    final crossPaint = Paint()..color = const Color(0xFFFFD700)..strokeWidth = 2;
    canvas.drawLine(Offset(bowX - 18, bowY), Offset(bowX + 18, bowY), crossPaint);
    canvas.drawLine(Offset(bowX, bowY - 18), Offset(bowX, bowY + 18), crossPaint);
  }

  // --------------------------------------------------------------------------
  // 5. STADIUM GREEN TURF FOOTBALL / ORCHARD CATCHER
  // --------------------------------------------------------------------------
  void _renderSportsGoal(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Alternating green lawn stripes
    final stripeHeight = h / 12.0;
    for (int s = 0; s < 12; s++) {
      final sColor = (s % 2 == 0) ? const Color(0xFF15803D) : const Color(0xFF16A34A);
      canvas.drawRect(Rect.fromLTWH(0, s * stripeHeight, w, stripeHeight), Paint()..color = sColor);
    }

    // Pitch Line Markings
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w * 0.5, h * 0.78), 44, linePaint);
    canvas.drawLine(Offset(0, h * 0.55), Offset(w, h * 0.55), linePaint);

    // 3 Goal Nets across the pitch
    final numOpts = round.options.length.clamp(2, 3);
    for (int i = 0; i < numOpts; i++) {
      final netX = w * ((i + 1) / (numOpts + 1));
      final netRect = Rect.fromCenter(center: Offset(netX, h * 0.32), width: (w / numOpts) - 12, height: 75);

      // Net background in emerald green
      canvas.drawRRect(RRect.fromRectAndRadius(netRect, const Radius.circular(10)), Paint()..color = const Color(0xFF065F46).withValues(alpha: 0.90));

      // White Goal Post Frame
      final postPaint = Paint()
        ..color = targetGoalIdx == i && ballKicked ? const Color(0xFFFFD700) : Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(RRect.fromRectAndRadius(netRect, const Radius.circular(10)), postPaint);

      // Net grid mesh lines
      final meshPaint = Paint()..color = Colors.white30..strokeWidth = 1;
      for (double gx = netRect.left + 8; gx < netRect.right; gx += 10) {
        canvas.drawLine(Offset(gx, netRect.top), Offset(gx, netRect.bottom), meshPaint);
      }

      // Option Text Banner
      _drawCenteredText(canvas, round.options[i], Offset(netX, h * 0.32), fontSize: 12.0, color: Colors.white);
    }

    // Football
    final fbX = w * ballX;
    final fbY = h * ballY;
    canvas.drawCircle(Offset(fbX, fbY), 16, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(fbX, fbY), 16, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset(fbX, fbY), 6, Paint()..color = Colors.black);
  }

  // --------------------------------------------------------------------------
  // 6. SUNLIT TROPICAL LAGOON & OCEAN DIVER
  // --------------------------------------------------------------------------
  void _renderOceanDiver(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Sunlit turquoise lagoon gradient
    final ocean = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF0F766E)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), ocean);

    // Golden sandy seafloor
    final sandPath = Path()
      ..moveTo(0, h * 0.90)
      ..quadraticBezierTo(w * 0.5, h * 0.86, w, h * 0.90)
      ..lineTo(w, h)
      ..lineTo(0, h);
    canvas.drawPath(sandPath, Paint()..color = const Color(0xFFFDE047));

    // Green seaweed swaying on seabed
    final kelpPaint = Paint()..color = const Color(0xFF15803D)..strokeWidth = 4..style = PaintingStyle.stroke;
    for (double kx = 20; kx < w; kx += 45) {
      final kPath = Path()..moveTo(kx, h);
      kPath.quadraticBezierTo(kx + math.sin(totalTime * 3 + kx) * 12, h * 0.88, kx, h * 0.80);
      canvas.drawPath(kPath, kelpPaint);
    }

    // Rising Air Bubbles
    for (int b = 0; b < 10; b++) {
      final bx = (w * (b * 0.11) + math.sin(totalTime * 2 + b) * 8) % w;
      final by = (h * 0.85 - (totalTime * 40 + b * 50)) % h;
      canvas.drawCircle(Offset(bx, by), 4 + (b % 4), Paint()..color = Colors.white.withValues(alpha: 0.40));
    }

    // 3 Glowing Oyster Pearls (Word targets)
    final numOpts = round.options.length.clamp(2, 3);
    for (int i = 0; i < numOpts; i++) {
      final px = w * ((i + 1) / (numOpts + 1));
      final py = h * 0.36 + math.sin(totalTime * 2 + i) * 16;
      final pearlRect = Rect.fromCenter(center: Offset(px, py), width: (w / numOpts) - 14, height: 56);

      // Oyster Shell background in rich teal
      canvas.drawRRect(RRect.fromRectAndRadius(pearlRect, const Radius.circular(16)), Paint()..color = const Color(0xFF0F766E).withValues(alpha: 0.95));
      canvas.drawRRect(
        RRect.fromRectAndRadius(pearlRect, const Radius.circular(16)),
        Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 2,
      );

      _drawCenteredText(canvas, round.options[i], Offset(px, py), fontSize: 12.0, color: Colors.white);
    }

    // Yellow Explorer Submarine
    final sx = w * subX;
    final sy = h * subY;
    final subRect = Rect.fromCenter(center: Offset(sx, sy), width: 62, height: 34);
    canvas.drawRRect(RRect.fromRectAndRadius(subRect, const Radius.circular(16)), Paint()..color = const Color(0xFFFACC15));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(sx, sy - 18), width: 22, height: 14), const Radius.circular(6)), Paint()..color = const Color(0xFFEAB308));
    canvas.drawCircle(Offset(sx + 10, sy), 7, Paint()..color = const Color(0xFF0284C7));
    canvas.drawCircle(Offset(sx - 34, sy), 6, Paint()..color = Colors.white70);
  }

  // --------------------------------------------------------------------------
  // 7. COUNTRYSIDE RAILROAD & FREIGHT WAGON SENTENCE COUPLER
  // --------------------------------------------------------------------------
  void _renderTrainCoupler(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Sunny blue sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.50),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.50)),
    );

    // Green countryside hills
    canvas.drawRect(Rect.fromLTWH(0, h * 0.50, w, h * 0.50), Paint()..color = const Color(0xFF15803D));

    // Railroad Track Ties
    final trackY = h * 0.72;
    canvas.drawRect(Rect.fromLTWH(0, trackY, w, 14), Paint()..color = const Color(0xFF78716C));
    final tiePaint = Paint()..color = const Color(0xFF78350F)..strokeWidth = 4;
    for (double x = 0; x < w; x += 22) {
      canvas.drawLine(Offset(x, trackY - 4), Offset(x, trackY + 18), tiePaint);
    }

    // Freight Wagons at Depot
    final numOpts = round.options.length.clamp(2, 3);
    for (int i = 0; i < numOpts; i++) {
      final wx = w * ((i + 1) / (numOpts + 1));
      final wy = h * 0.40;
      final wagonRect = Rect.fromCenter(center: Offset(wx, wy), width: (w / numOpts) - 12, height: 56);

      canvas.drawRRect(RRect.fromRectAndRadius(wagonRect, const Radius.circular(8)), Paint()..color = const Color(0xFFF59E0B));
      canvas.drawRRect(RRect.fromRectAndRadius(wagonRect, const Radius.circular(8)), Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

      _drawCenteredText(canvas, round.options[i], Offset(wx, wy), fontSize: 12.0, color: Colors.black, bold: true);
    }

    // Steam Locomotive Engine
    final trainX = w * 0.35 + math.sin(totalTime * 4) * 8;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(trainX, trackY - 24), width: 75, height: 44), const Radius.circular(8)), Paint()..color = const Color(0xFFDC2626));
    canvas.drawRect(Rect.fromLTWH(trainX + 18, trackY - 48, 12, 16), Paint()..color = Colors.black);
    canvas.drawCircle(Offset(trainX + 24, trackY - 60 + math.sin(totalTime * 6) * 4), 10, Paint()..color = Colors.white70);
  }

  // --------------------------------------------------------------------------
  // 8. SUNLIT JUNGLE TEMPLE ALTAR & RUNE PEDESTALS (Nature Lock)
  // --------------------------------------------------------------------------
  void _renderBombDefusal(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Lush green jungle canopy backdrop
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14532D), Color(0xFF166534), Color(0xFF15803D)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Cascading sun rays
    final rayPaint = Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.12)..strokeWidth = 40;
    canvas.drawLine(Offset(w * 0.2, 0), Offset(w * 0.5, h), rayPaint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.9, h), rayPaint);

    // Sunlit Stone Altar Clock Display
    final timerRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: 190, height: 54);
    canvas.drawRRect(RRect.fromRectAndRadius(timerRect, const Radius.circular(12)), Paint()..color = const Color(0xFF064E3B));
    canvas.drawRRect(RRect.fromRectAndRadius(timerRect, const Radius.circular(12)), Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawCenteredText(
      canvas,
      '⏳ 00:${defusalTimerSeconds.toString().padLeft(2, '0')}',
      Offset(w * 0.5, h * 0.22),
      fontSize: 26,
      color: const Color(0xFFFFD700),
    );

    // Hanging jungle vine accents
    final vinePaint = Paint()..color = const Color(0xFF15803D)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.1, 0), Offset(w * 0.12, h * 0.35), vinePaint);
    canvas.drawLine(Offset(w * 0.9, 0), Offset(w * 0.88, h * 0.35), vinePaint);

    // Glowing Elemental Rune Stones
    final numOpts = round.options.length.clamp(2, 3);
    for (int i = 0; i < numOpts; i++) {
      final wy = h * (0.38 + i * 0.13);
      final wireRect = Rect.fromLTWH(w * 0.08, wy, w * 0.84, 52);

      canvas.drawRRect(RRect.fromRectAndRadius(wireRect, const Radius.circular(12)), Paint()..color = const Color(0xFF065F46).withValues(alpha: 0.95));
      canvas.drawRRect(
        RRect.fromRectAndRadius(wireRect, const Radius.circular(12)),
        Paint()..color = _getOptionColor(i)..style = PaintingStyle.stroke..strokeWidth = 2.2,
      );

      canvas.drawCircle(Offset(w * 0.16, wy + 26), 10, Paint()..color = _getOptionColor(i));
      _drawCenteredText(canvas, round.options[i], Offset(w * 0.52, wy + 26), fontSize: 13.0, color: Colors.white);
    }
  }

  // --------------------------------------------------------------------------
  // 9. SUNLIT CASTLE ARENA & MYTHICAL CHALLENGE GUARDIAN
  // --------------------------------------------------------------------------
  void _renderBossBattle(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Sunny blue sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.40),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.40)),
    );

    // Green ivy covered stone battlement walls
    canvas.drawRect(Rect.fromLTWH(0, h * 0.40, w, h * 0.60), Paint()..color = const Color(0xFF15803D));

    final bossX = w * 0.5;
    final bossY = h * 0.30 + math.sin(totalTime * 2) * 8;

    // Guardian Body (Friendly Golden Mythical Guardian)
    canvas.drawCircle(Offset(bossX, bossY), 52, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(Offset(bossX, bossY), 46, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(Offset(bossX - 16, bossY - 10), 6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(bossX + 16, bossY - 10), 6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(bossX - 16, bossY - 10), 3, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(bossX + 16, bossY - 10), 3, Paint()..color = Colors.black);

    // Health Bar
    final hpRect = Rect.fromCenter(center: Offset(bossX, bossY - 72), width: 150, height: 14);
    canvas.drawRRect(RRect.fromRectAndRadius(hpRect, const Radius.circular(7)), Paint()..color = Colors.black26);
    final curHpRect = Rect.fromLTWH(hpRect.left, hpRect.top, hpRect.width * bossHp, hpRect.height);
    canvas.drawRRect(RRect.fromRectAndRadius(curHpRect, const Radius.circular(7)), Paint()..color = const Color(0xFF10B981));

    _drawCenteredText(canvas, 'SPEAKING MASTER GUARDIAN 🦁', Offset(bossX, bossY - 92), fontSize: 11.5, color: const Color(0xFFFFD700));

    // 3 Elemental Spell Shields
    final numOpts = round.options.length.clamp(2, 3);
    for (int i = 0; i < numOpts; i++) {
      final rx = w * ((i + 1) / (numOpts + 1));
      final ry = h * 0.62;
      final runeRect = Rect.fromCenter(center: Offset(rx, ry), width: (w / numOpts) - 12, height: 56);

      canvas.drawRRect(RRect.fromRectAndRadius(runeRect, const Radius.circular(14)), Paint()..color = const Color(0xFF065F46).withValues(alpha: 0.95));
      canvas.drawRRect(
        RRect.fromRectAndRadius(runeRect, const Radius.circular(14)),
        Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 2,
      );

      _drawCenteredText(canvas, round.options[i], Offset(rx, ry), fontSize: 12.0, color: Colors.white);
    }
  }

  // --------------------------------------------------------------------------
  // 10. LUSH TROPICAL ISLAND EXPEDITION RADAR
  // --------------------------------------------------------------------------
  void _renderWorldRadar(Canvas canvas, double w, double h, ArcadeChallengeRound round) {
    // Lush tropical green island background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final rCenter = Offset(w * 0.5, h * 0.44);
    final ringPaint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(rCenter, 70, ringPaint);
    canvas.drawCircle(rCenter, 120, ringPaint);
    canvas.drawCircle(rCenter, 170, ringPaint);

    final sweepAngle = totalTime * 2.5;
    final sweepPath = Path()
      ..moveTo(rCenter.dx, rCenter.dy)
      ..lineTo(rCenter.dx + math.cos(sweepAngle) * 170, rCenter.dy + math.sin(sweepAngle) * 170)
      ..lineTo(rCenter.dx + math.cos(sweepAngle - 0.4) * 170, rCenter.dy + math.sin(sweepAngle - 0.4) * 170)
      ..close();
    canvas.drawPath(sweepPath, Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.20));

    // Radar Targets (Options)
    final numOpts = round.options.length.clamp(2, 4);
    for (int i = 0; i < numOpts; i++) {
      final angle = (i / numOpts.toDouble()) * math.pi * 2 + (totalTime * 0.3);
      final dist = 110.0;
      final bx = rCenter.dx + math.cos(angle) * dist;
      final by = rCenter.dy + math.sin(angle) * dist;

      canvas.drawCircle(Offset(bx, by), 12, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(bx, by), 20, Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.3));

      final textRect = Rect.fromCenter(center: Offset(bx, by + 26), width: 110, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(textRect, const Radius.circular(6)), Paint()..color = const Color(0xFF065F46));
      _drawCenteredText(canvas, round.options[i], Offset(bx, by + 26), fontSize: 11, color: Colors.white);
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 14,
    Color color = Colors.white,
    Color? shadowColor,
    bool bold = true,
  }) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        fontFamily: 'Outfit',
        shadows: shadowColor != null
            ? [Shadow(color: shadowColor, blurRadius: 4, offset: const Offset(1, 1))]
            : [const Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(1, 1))],
      ),
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
}

// ============================================================================
// 3. FLUTTER HOST PAGE & FLOATING NATURE HUD (ZERO BOTTOM CARD BLOCKAGE)
// ============================================================================

class PocketUniversalArcadeEnginePage extends StatefulWidget {
  final int day;
  final int gameIndex;

  const PocketUniversalArcadeEnginePage({
    super.key,
    required this.day,
    this.gameIndex = 1,
  });

  @override
  State<PocketUniversalArcadeEnginePage> createState() =>
      _PocketUniversalArcadeEnginePageState();
}

class _PocketUniversalArcadeEnginePageState
    extends State<PocketUniversalArcadeEnginePage> {
  late final FlutterTts _tts;
  late final DayGameSpec _activeSpec;
  late final List<ArcadeChallengeRound> _rounds;
  late final PocketFlameArcadeGame _flameGame;

  int _score = 0;
  int _combo = 0;
  int _lives = 3;
  bool _isGameFinished = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    final all = Pocket20Days40GamesRegistry.allGames;
    _activeSpec = all.firstWhere(
      (s) => s.day == widget.day && s.gameIndex == widget.gameIndex,
      orElse: () => DayGameSpec(
        day: widget.day,
        gameIndex: widget.gameIndex,
        title: 'Nature Arcade Day ${widget.day}',
        emoji: '🌿',
        genre: GameGenre.runner,
        englishTarget: 'Spoken English & Active Vocabulary',
        descriptionEn: 'Explore the vibrant green open world and master Spoken English.',
        descriptionMl: 'ഓപ്പൺ വേൾഡ് എക്സ്പ്ലോർ ചെയ്ത് ഇംഗ്ലീഷ് പഠിക്കുക.',
        controlMechanism: 'Tap directly on screen targets',
      ),
    );

    _rounds = _buildRounds(widget.day, widget.gameIndex);

    _flameGame = PocketFlameArcadeGame(
      day: widget.day,
      gameIndex: widget.gameIndex,
      spec: _activeSpec,
      rounds: _rounds,
      onStatsChanged: (score, lives, combo) {
        if (mounted) {
          setState(() {
            _score = score;
            _lives = lives;
            _combo = combo;
          });
        }
      },
      onAnswerFeedback: (isCorrect, text, explanation) {
        if (isCorrect) {
          _speak('Correct! $text');
        } else {
          _speak('Try again. $text');
        }
      },
      onGameCompleted: () {
        if (mounted) {
          setState(() {
            _isGameFinished = true;
          });
          HapticFeedback.heavyImpact();
          _speak('Congratulations! You conquered Day ${widget.day} game!');
        }
      },
    );

    // Initial TTS Voice
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_rounds.isNotEmpty) {
        _speak(_rounds.first.voiceLeadIn);
      }
    });
  }

  void _initTts() {
    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.05);
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (_) {}
  }

  void _speakCurrentPrompt() {
    final current = _flameGame.currentRound;
    _speak(current.voiceLeadIn.isNotEmpty ? current.voiceLeadIn : current.promptEn);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF064E3B), // Lush emerald green nature background
      body: SafeArea(
        child: _isGameFinished ? _buildVictoryScreen() : _buildActiveGameArea(),
      ),
    );
  }

  Widget _buildActiveGameArea() {
    final current = _flameGame.currentRound;

    return Stack(
      children: [
        // 1. FULL-SCREEN 100% FLAME 2D CANVAS (Zero Obstruction Open World)
        Positioned.fill(
          child: GameWidget(game: _flameGame),
        ),

        // 2. SLIM FLOATING FROSTED EMERALD TOP HUD
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopHud(),
        ),

        // 3. COMPACT FLOATING QUEST PILL (Only ~44px, zero screen blockage!)
        Positioned(
          top: 54,
          left: 14,
          right: 14,
          child: _buildFloatingQuestPill(current),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // TOP HUD (Floating Frosted Emerald Glass Header)
  // --------------------------------------------------------------------------
  Widget _buildTopHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF065F46).withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: const Color(0xFF34D399).withValues(alpha: 0.35))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
            ),
            child: Row(
              children: [
                Text(_activeSpec.emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  'DAY ${widget.day} • G${widget.gameIndex}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _activeSpec.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // Hearts / Lives
          Row(
            children: List.generate(
              3,
              (idx) => Icon(
                idx < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: const Color(0xFFEF4444),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF047857),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
            ),
            child: Text(
              '⭐ $_score',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          if (_combo >= 2) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🔥 ${_combo}x',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _speakCurrentPrompt,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // COMPACT FLOATING QUEST PILL (Zero Bottom Obstruction!)
  // --------------------------------------------------------------------------
  Widget _buildFloatingQuestPill(ArcadeChallengeRound current) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF047857),
            Color(0xFF0F766E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF022C22).withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  current.promptEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                if (current.promptMl.isNotEmpty)
                  Text(
                    current.promptMl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD1FAE5),
                      fontSize: 10.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // VICTORY SCREEN (Lush Emerald & Gold Celebration)
  // --------------------------------------------------------------------------
  Widget _buildVictoryScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF065F46),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF047857).withValues(alpha: 0.6),
              blurRadius: 28,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            Text(
              'VICTORY ACHIEVED!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You conquered Day ${widget.day} ${_activeSpec.title}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF047857),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL SCORE: ',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$_score XP ⭐',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF064E3B),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'CONTINUE ADVENTURE 🚀',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CURRICULUM ROUTER & ROUND BUILDERS (DAYS 1 TO 20 DEDICATED SPOKEN CURRICULUM)
  // ==========================================================================
  List<ArcadeChallengeRound> _buildRounds(int day, int gameIndex) {
    if (day >= 1 && day <= 10) {
      final r = _buildDay1to10Rounds(day, gameIndex);
      if (r != null && r.isNotEmpty) return r;
    } else if (day >= 11 && day <= 20) {
      final r = _buildDay11to20SpokenRounds(day, gameIndex);
      if (r != null && r.isNotEmpty) return r;
    } else if (day >= 21 && day <= 35) {
      final r = _buildDay21to35SpokenRounds(day, gameIndex);
      if (r != null && r.isNotEmpty) return r;
    }

    // General fallback for other days
    return _buildVocabFallbackRounds(day, gameIndex);
  }

  // --------------------------------------------------------------------------
  // DAY 1 TO 10 DEDICATED CURRICULUM
  // --------------------------------------------------------------------------
  List<ArcadeChallengeRound>? _buildDay1to10Rounds(int day, int gameIndex) {
    if (day == 1) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Collect letter for "Apple" (A)',
            promptMl: '"Apple" തുടങ്ങുന്ന അക്ഷരം തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect letter A for Apple',
            targetWord: 'A',
            options: ['A', 'B', 'C'],
            correctIndex: 0,
            explanationEn: 'Apple starts with the letter A.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Collect letter for "Ball" (B)',
            promptMl: '"Ball" തുടങ്ങുന്ന അക്ഷരം തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect letter B for Ball',
            targetWord: 'B',
            options: ['D', 'B', 'P'],
            correctIndex: 1,
            explanationEn: 'Ball begins with letter B.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Collect letter for "Cat" (C)',
            promptMl: '"Cat" തുടങ്ങുന്ന അക്ഷരം തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect letter C for Cat',
            targetWord: 'C',
            options: ['O', 'G', 'C'],
            correctIndex: 2,
            explanationEn: 'Cat begins with letter C.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Collect letter for "Dog" (D)',
            promptMl: '"Dog" തുടങ്ങുന്ന അക്ഷരം തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect letter D for Dog',
            targetWord: 'D',
            options: ['D', 'B', 'T'],
            correctIndex: 0,
            explanationEn: 'Dog starts with letter D.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Pop the letter that makes the /æ/ sound',
            promptMl: '/æ/ സൗണ്ട് ഉണ്ടാക്കുന്ന അക്ഷരം പൊട്ടിക്കുക',
            voiceLeadIn: 'Pop letter A for /æ/ as in Ant',
            targetWord: 'A',
            options: ['A', 'E', 'I'],
            correctIndex: 0,
            explanationEn: 'Letter A makes the short /æ/ sound in Ant.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Pop the balloon for the letter "M"',
            promptMl: '"M" ഉള്ള ബലൂൺ പൊട്ടിക്കുക',
            voiceLeadIn: 'Pop letter M as in Moon',
            targetWord: 'M',
            options: ['W', 'M', 'N'],
            correctIndex: 1,
            explanationEn: 'M makes the /m/ sound as in Moon.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Pop the letter for "Sun" (S)',
            promptMl: '"Sun" തുടങ്ങുന്ന S അക്ഷരം പൊട്ടിക്കുക',
            voiceLeadIn: 'Pop letter S for Sun',
            targetWord: 'S',
            options: ['Z', 'C', 'S'],
            correctIndex: 2,
            explanationEn: 'Sun starts with the letter S.',
          ),
        ];
      }
    } else if (day == 2) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Drive into lane for "Car" (കാർ)',
            promptMl: '"Car" ഉള്ള ലെയിനിലേക്ക് കാർ തിരിക്കുക',
            voiceLeadIn: 'Steer to Car',
            targetWord: 'Car',
            options: ['Car', 'Bus', 'Van'],
            correctIndex: 0,
            explanationEn: 'Car is a motor vehicle with four wheels.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Drive into lane for "Tree" (മരം)',
            promptMl: '"Tree" ഉള്ള ലെയിനിലേക്ക് തിരിയുക',
            voiceLeadIn: 'Drive to Tree',
            targetWord: 'Tree',
            options: ['Grass', 'Tree', 'Plant'],
            correctIndex: 1,
            explanationEn: 'Tree is a woody perennial plant.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Drive into lane for "Book" (പുസ്തകം)',
            promptMl: '"Book" ഉള്ള ലെയിൻ തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Drive to Book',
            targetWord: 'Book',
            options: ['Pen', 'Desk', 'Book'],
            correctIndex: 2,
            explanationEn: 'Book is a written work with printed pages.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Shoot the target for "Water" (വെള്ളം)',
            promptMl: '"Water" ഉള്ള ടാർഗറ്റിലേക്ക് വെടിവെക്കുക',
            voiceLeadIn: 'Shoot Water',
            targetWord: 'Water',
            options: ['Water', 'Milk', 'Juice'],
            correctIndex: 0,
            explanationEn: 'Water is essential for life.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Shoot the target for "Bread" (റൊട്ടി)',
            promptMl: '"Bread" ഉള്ള ടാർഗറ്റിലേക്ക് ലക്ഷ്യം വെക്കുക',
            voiceLeadIn: 'Shoot Bread',
            targetWord: 'Bread',
            options: ['Rice', 'Bread', 'Cake'],
            correctIndex: 1,
            explanationEn: 'Bread is made from flour and baked.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Shoot the target for "House" (വീട്)',
            promptMl: '"House" ഉള്ള ടാർഗറ്റ് തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Shoot House',
            targetWord: 'House',
            options: ['Shop', 'Office', 'House'],
            correctIndex: 2,
            explanationEn: 'House is a building for human habitation.',
          ),
        ];
      }
    } else if (day == 3) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Dive submarine to collect "Swim" (നീന്തുക)',
            promptMl: '"Swim" കളക്റ്റ് ചെയ്യാൻ മുങ്ങുക',
            voiceLeadIn: 'Dive to Swim',
            targetWord: 'Swim',
            options: ['Swim', 'Fly', 'Walk'],
            correctIndex: 0,
            explanationEn: 'Swim means to move through water.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Dive submarine to collect "See" (കാണുക)',
            promptMl: '"See" കളക്റ്റ് ചെയ്യാൻ ലക്ഷ്യം വെക്കുക',
            voiceLeadIn: 'Dive to See',
            targetWord: 'See',
            options: ['Hear', 'See', 'Taste'],
            correctIndex: 1,
            explanationEn: 'See means to perceive with the eyes.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Catch the fruit: "Apple"',
            promptMl: '"Apple" ബാസ്കറ്റിൽ പിടിക്കുക',
            voiceLeadIn: 'Catch Apple',
            targetWord: 'Apple',
            options: ['Apple', 'Carrot', 'Potato'],
            correctIndex: 0,
            explanationEn: 'Apple is a sweet, edible red or green fruit.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Catch the drink: "Milk"',
            promptMl: '"Milk" ബാസ്കറ്റിൽ പിടിക്കുക',
            voiceLeadIn: 'Catch Milk',
            targetWord: 'Milk',
            options: ['Bread', 'Milk', 'Butter'],
            correctIndex: 1,
            explanationEn: 'Milk is a white nutrient-rich liquid food.',
          ),
        ];
      }
    } else if (day == 4) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Collect the pronoun: "He" (അവൻ)',
            promptMl: '"He" എന്ന പ്രൊനൗൺ തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect pronoun He',
            targetWord: 'He',
            options: ['He', 'She', 'It'],
            correctIndex: 0,
            explanationEn: 'He refers to a male person.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Collect the pronoun: "We" (ഞങ്ങൾ)',
            promptMl: '"We" എന്ന പ്രൊനൗൺ തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect pronoun We',
            targetWord: 'We',
            options: ['I', 'We', 'They'],
            correctIndex: 1,
            explanationEn: 'We includes the speaker and others.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Slash the word: "Run" (ഓടുക)',
            promptMl: '"Run" എന്ന വാക്ക് വെട്ടുക',
            voiceLeadIn: 'Slash Run',
            targetWord: 'Run',
            options: ['Run', 'Sun', 'Fun'],
            correctIndex: 0,
            explanationEn: 'Run is an action verb meaning move fast on foot.',
          ),
        ];
      }
    } else if (day == 5) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Collect the adjective for large size: "Big"',
            promptMl: 'വലുത് എന്ന് സൂചിപ്പിക്കുന്ന "Big" തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect Big',
            targetWord: 'Big',
            options: ['Big', 'Small', 'Tiny'],
            correctIndex: 0,
            explanationEn: 'Big describes of considerable size or extent.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Collect the speed adjective: "Fast"',
            promptMl: 'വേഗതയുള്ള എന്നർത്ഥം വരുന്ന "Fast" തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Collect Fast',
            targetWord: 'Fast',
            options: ['Slow', 'Fast', 'Late'],
            correctIndex: 1,
            explanationEn: 'Fast means moving at high speed.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Pop opposite of "Hot": "Cold"',
            promptMl: '"Hot"-ന്റെ എതിർവാക്കായ "Cold" പൊട്ടിക്കുക',
            voiceLeadIn: 'Pop Cold',
            targetWord: 'Cold',
            options: ['Cold', 'Warm', 'Bright'],
            correctIndex: 0,
            explanationEn: 'Cold is the opposite of Hot.',
          ),
        ];
      }
    } else if (day == 6) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Complete sentence: "I ___ a book" (read)',
            promptMl: 'വാക്യം പൂർത്തിയാക്കുക: "I ___ a book"',
            voiceLeadIn: 'Choose read',
            targetWord: 'read',
            options: ['read', 'jump', 'fly'],
            correctIndex: 0,
            explanationEn: 'You read a book.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Choose plural of "Cat": "Cats"',
            promptMl: '"Cat"-ന്റെ ബഹുവചനമായ "Cats" തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Choose Cats',
            targetWord: 'Cats',
            options: ['Cats', 'Cates', 'Cating'],
            correctIndex: 0,
            explanationEn: 'Cats is the correct plural form of Cat.',
          ),
        ];
      }
    } else if (day == 7) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Step on pronoun for a girl: "She"',
            promptMl: 'പെൺകുട്ടിയെ സൂചിപ്പിക്കുന്ന "She" തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Choose She',
            targetWord: 'She',
            options: ['She', 'He', 'It'],
            correctIndex: 0,
            explanationEn: 'She is used for female persons.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Kick into net: "The cat is ___ the table" (under)',
            promptMl: '"മേശക്കടിയിൽ" എന്നർത്ഥമുള്ള "under" തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Kick into under',
            targetWord: 'under',
            options: ['on', 'under', 'at'],
            correctIndex: 1,
            explanationEn: 'Under means beneath the table.',
          ),
        ];
      }
    } else if (day == 8) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Drive to proper greeting reply: "Hello!"',
            promptMl: '"Hello!" എന്നതിന് ശരിയായ മറുപടിയിലേക്ക് ഡ്രൈവ് ചെയ്യുക',
            voiceLeadIn: 'Reply with Hello',
            targetWord: 'Hello!',
            options: ['Hello!', 'Goodbye!', 'No!'],
            correctIndex: 0,
            explanationEn: 'Hello is the natural friendly return greeting.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Tap question word for place: "Where"',
            promptMl: 'സ്ഥലത്തെക്കുറിച്ചുള്ള ചോദ്യ വാക്ക്: "Where"',
            voiceLeadIn: 'Choose Where',
            targetWord: 'Where',
            options: ['When', 'Where', 'Why'],
            correctIndex: 1,
            explanationEn: 'Where asks about place or location.',
          ),
        ];
      }
    } else if (day == 9) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Dock rocket to time word: "Morning"',
            promptMl: '"Morning" (പ്രഭാതം) ഡോക്കിംഗ് ബേ തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Dock at Morning',
            targetWord: 'Morning',
            options: ['Morning', 'Noon', 'Night'],
            correctIndex: 0,
            explanationEn: 'Morning is the period from sunrise to midday.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Navigate beacon: "Tea ___ coffee" (or)',
            promptMl: '"Tea ___ coffee" ശരിയായ കൺജങ്ഷൻ "or" തിരഞ്ഞെടുക്കുക',
            voiceLeadIn: 'Choose or',
            targetWord: 'or',
            options: ['and', 'or', 'but'],
            correctIndex: 1,
            explanationEn: 'Or presents alternatives.',
          ),
        ];
      }
    } else if (day == 10) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Shoot past tense of "Go": "Went"',
            promptMl: '"Go"-ന്റെ പാസ്റ്റ് ടെൻസായ "Went" ലക്ഷ്യം വെക്കുക',
            voiceLeadIn: 'Shoot Went',
            targetWord: 'Went',
            options: ['Went', 'Gone', 'Going'],
            correctIndex: 0,
            explanationEn: 'Went is the past simple of go.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Collect coin for "Buy" (വാങ്ങുക)',
            promptMl: '"Buy" (വാങ്ങുക) നാണയം എടുക്കുക',
            voiceLeadIn: 'Collect Buy',
            targetWord: 'Buy',
            options: ['Buy', 'Sell', 'Cost'],
            correctIndex: 0,
            explanationEn: 'Buy means to purchase with money.',
          ),
        ];
      }
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // DAY 11 TO 20 DEDICATED SPOKEN ENGLISH CURRICULUM (LUSH NATURE THEMED)
  // --------------------------------------------------------------------------
  List<ArcadeChallengeRound>? _buildDay11to20SpokenRounds(int day, int gameIndex) {
    if (day == 11) {
      // DAY 11: Travel, Directions & Quick Spoken Reactions
      if (gameIndex == 1) {
        // Speed Boat English / River Navigation
        return [
          ArcadeChallengeRound(
            promptEn: '"Excuse me, where is the station?" (Go straight)',
            promptMl: '"റെയിൽവേ സ്റ്റേഷൻ എവിടെയാണ്?" -> നേരെ മുന്നോട്ട് പോകുക',
            voiceLeadIn: 'Go straight ahead',
            targetWord: 'Go straight ahead',
            options: ['Go straight ahead', 'Turn upside down', 'Stop here forever'],
            correctIndex: 0,
            explanationEn: '"Go straight ahead" is the standard direction phrase.',
          ),
          ArcadeChallengeRound(
            promptEn: '"Which way to the hospital?" (Turn left)',
            promptMl: '"ഹോസ്പിറ്റലിലേക്ക് ഏതുവഴി?" -> ഇടത്തോട്ട് തിരിയുക',
            voiceLeadIn: 'Turn left at the signal',
            targetWord: 'Turn left at the signal',
            options: ['Jump into the river', 'Turn left at the signal', 'Look at the sky'],
            correctIndex: 1,
            explanationEn: '"Turn left at the signal" gives clear direction at an intersection.',
          ),
          ArcadeChallengeRound(
            promptEn: '"How far is the beach?" (Just two kilometers)',
            promptMl: '"ബീച്ച് എത്ര ദൂരെയാണ്?" -> രണ്ട് കിലോമീറ്റർ മാത്രം',
            voiceLeadIn: 'It is just two kilometers',
            targetWord: 'It is just two kilometers',
            options: ['Yesterday morning', 'Ten hours ago', 'It is just two kilometers'],
            correctIndex: 2,
            explanationEn: '"It is just two kilometers" answers distance questions naturally.',
          ),
          ArcadeChallengeRound(
            promptEn: '"Is there a pharmacy nearby?" (Yes, next to the bank)',
            promptMl: '"അടുത്തൊരു മെഡിക്കൽ ഷോപ്പുണ്ടോ?" -> അതെ, ബാങ്കിന് തൊട്ടടുത്ത്',
            voiceLeadIn: 'Yes, next to the bank',
            targetWord: 'Yes, next to the bank',
            options: ['Yes, next to the bank', 'No, I have no money', 'Goodbye friend'],
            correctIndex: 0,
            explanationEn: '"Next to the bank" specifies exact landmark proximity.',
          ),
        ];
      } else {
        // Wave Island Survivor / Beach Courtesy
        return [
          ArcadeChallengeRound(
            promptEn: 'Someone helped carry your bags: "Thank you so much!"',
            promptMl: 'നന്ദി പറയുമ്പോൾ വിനയത്തോടെയുള്ള മറുപടി: "You are welcome!"',
            voiceLeadIn: 'You are welcome',
            targetWord: "You're welcome!",
            options: ["You're welcome!", "I do not care", "Give me money"],
            correctIndex: 0,
            explanationEn: 'You are welcome is the universal polite response to thank you.',
          ),
          ArcadeChallengeRound(
            promptEn: 'You bumped into someone: "___"',
            promptMl: 'ഒരാളെ തട്ടിയാൽ പെട്ടെന്ന് പറയേണ്ടത്: "I am so sorry!"',
            voiceLeadIn: 'I am so sorry',
            targetWord: "I'm so sorry!",
            options: ["Why are you here?", "I'm so sorry!", "Look away"],
            correctIndex: 1,
            explanationEn: 'I am so sorry acknowledges an accidental bump courteously.',
          ),
          ArcadeChallengeRound(
            promptEn: 'You did not hear their words clearly: "___"',
            promptMl: 'പറഞ്ഞത് കേട്ടില്ലെങ്കിൽ ചോദിക്കേണ്ടത്: "Pardon, could you repeat that?"',
            voiceLeadIn: 'Pardon, could you repeat that?',
            targetWord: 'Pardon, could you repeat that?',
            options: ['Shout loudly', 'Do not speak to me', 'Pardon, could you repeat that?'],
            correctIndex: 2,
            explanationEn: '"Pardon, could you repeat that?" is the most polite clarification request.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Someone says "Have a wonderful day!": "___"',
            promptMl: '"നല്ലൊരു ദിവസം ആശംസിക്കുന്നു" എന്ന് പറയുമ്പോൾ: "Same to you!"',
            voiceLeadIn: 'Same to you',
            targetWord: 'Same to you!',
            options: ['Same to you!', 'No day today', 'Wait here'],
            correctIndex: 0,
            explanationEn: '"Same to you!" reciprocates pleasant daily wishes warmly.',
          ),
        ];
      }
    } else if (day == 12) {
      // DAY 12: Food, Cafe & Restaurant Spoken English
      if (gameIndex == 1) {
        // Castle Inn Food Counter & Orders
        return [
          ArcadeChallengeRound(
            promptEn: 'Ordering at a cafe: "___ a cup of tea, please"',
            promptMl: 'ചായ ഓർഡർ ചെയ്യുമ്പോൾ: "Could I have a cup of tea, please"',
            voiceLeadIn: 'Could I have a cup of tea',
            targetWord: 'Could I have',
            options: ['Could I have', 'I must take', 'Throw me'],
            correctIndex: 0,
            explanationEn: '"Could I have..." is the most polite and natural way to order food.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking for recommendation: "What do you ___ today?"',
            promptMl: 'ഇന്നത്തെ സ്പെഷ്യൽ എന്താണെന്ന് ചോദിക്കാൻ: "recommend"',
            voiceLeadIn: 'What do you recommend today?',
            targetWord: 'recommend',
            options: ['refuse', 'recommend', 'forget'],
            correctIndex: 1,
            explanationEn: '"What do you recommend?" invites the waiter\'s top suggestion.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Arriving at restaurant: "A table for ___, please"',
            promptMl: 'രണ്ടുപേർക്കുള്ള ടേബിൾ ചോദിക്കാൻ: "A table for two, please"',
            voiceLeadIn: 'A table for two, please',
            targetWord: 'two, please',
            options: ['yesterday', 'empty', 'two, please'],
            correctIndex: 2,
            explanationEn: '"A table for two, please" states party size upon entering.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Requesting drinking water: "Could we have some ___, please?"',
            promptMl: 'വെള്ളം ആവശ്യപ്പെടാൻ: "water"',
            voiceLeadIn: 'Could we have some water, please?',
            targetWord: 'water',
            options: ['water', 'plates only', 'menu card'],
            correctIndex: 0,
            explanationEn: '"Could we have some water, please?" is clear and polite.',
          ),
        ];
      } else {
        // Garden Shield Slash & Restaurant Bill
        return [
          ArcadeChallengeRound(
            promptEn: 'Finished dining: "Can I get the ___, please?"',
            promptMl: 'ഭക്ഷണം കഴിഞ്ഞ് ബില്ല് ചോദിക്കാൻ: "bill"',
            voiceLeadIn: 'Can I get the bill, please?',
            targetWord: 'bill',
            options: ['bill', 'table', 'cook'],
            correctIndex: 0,
            explanationEn: '"Can I get the bill, please?" is standard across cafes worldwide.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Card payment inquiry: "Do you accept ___ cards?"',
            promptMl: 'കാർഡ് സ്വീകരിക്കുമോ എന്ന് ചോദിക്കാൻ: "credit"',
            voiceLeadIn: 'Do you accept credit cards?',
            targetWord: 'credit',
            options: ['paper', 'credit', 'greeting'],
            correctIndex: 1,
            explanationEn: '"Do you accept credit cards?" clarifies payment modes.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Complimenting the chef: "The food was absolutely ___!"',
            promptMl: 'ഭക്ഷണം വളരെ രുചികരമായിരുന്നു എന്ന് പറയാൻ: "delicious"',
            voiceLeadIn: 'The food was absolutely delicious',
            targetWord: 'delicious',
            options: ['tired', 'noisy', 'delicious'],
            correctIndex: 2,
            explanationEn: '"Delicious" expresses genuine enjoyment of a meal.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Leaving a tip for good service: "Keep the ___"',
            promptMl: 'ബാക്കി തുക ടിപ്പായി നൽകാൻ: "change"',
            voiceLeadIn: 'Keep the change',
            targetWord: 'change',
            options: ['change', 'plate', 'salt'],
            correctIndex: 0,
            explanationEn: '"Keep the change" is the classic phrase when tipping extra.',
          ),
        ];
      }
    } else if (day == 13) {
      // DAY 13: Making Friends & Social Introductions
      if (gameIndex == 1) {
        // Botanical Park Introductions
        return [
          ArcadeChallengeRound(
            promptEn: '"Hello, my name is Rahul." (Nice to meet you!)',
            promptMl: '"എന്റെ പേര് രാഹുൽ." -> കണ്ടതിൽ സന്തോഷം!',
            voiceLeadIn: 'Nice to meet you',
            targetWord: 'Nice to meet you!',
            options: ['Nice to meet you!', 'Who told you?', 'I am going away'],
            correctIndex: 0,
            explanationEn: '"Nice to meet you!" is the friendly response to introductions.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking someone\'s hometown: "Where are you ___?"',
            promptMl: 'നിങ്ങൾ എവിടെ നിന്നാണ് എന്ന് ചോദിക്കാൻ: "from"',
            voiceLeadIn: 'Where are you from?',
            targetWord: 'from',
            options: ['at', 'from', 'with'],
            correctIndex: 1,
            explanationEn: '"Where are you from?" is the natural way to ask about origins.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking their profession: "What do you do for a ___?"',
            promptMl: 'ജോലി എന്താണെന്ന് ചോദിക്കാൻ: "living"',
            voiceLeadIn: 'What do you do for a living?',
            targetWord: 'living',
            options: ['eating', 'sleeping', 'living'],
            correctIndex: 2,
            explanationEn: '"What do you do for a living?" asks about profession or career.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Concluding a pleasant chat: "It was great ___ to you!"',
            promptMl: 'സംസാരിച്ചതിൽ വളരെ സന്തോഷം: "talking"',
            voiceLeadIn: 'It was great talking to you',
            targetWord: 'talking',
            options: ['talking', 'crying', 'forgetting'],
            correctIndex: 0,
            explanationEn: '"It was great talking to you!" ends conversations positively.',
          ),
        ];
      } else {
        // Sunny Orchard Small Talk & Weather
        return [
          ArcadeChallengeRound(
            promptEn: 'Lovely sunny weather today, is it not? (Yes, it is!)',
            promptMl: 'നല്ല കാലാവസ്ഥയാണല്ലേ എന്ന് ചോദിച്ചാൽ: "Yes, absolutely gorgeous!"',
            voiceLeadIn: 'Yes, absolutely gorgeous',
            targetWord: 'Yes, absolutely gorgeous!',
            options: ['Yes, absolutely gorgeous!', 'I do not like sun', 'No weather today'],
            correctIndex: 0,
            explanationEn: '"Yes, absolutely gorgeous!" agrees with positive small talk.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Weekend inquiry: "Do you have any ___ for Saturday?"',
            promptMl: 'ശനിയാഴ്ച എന്തെങ്കിലും പ്ലാൻ ഉണ്ടോ: "plans"',
            voiceLeadIn: 'Do you have any plans for Saturday?',
            targetWord: 'plans',
            options: ['problems', 'plans', 'exams'],
            correctIndex: 1,
            explanationEn: '"Do you have any plans?" is the go-to weekend small talk question.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Sharing plans: "I am going to visit my ___ this weekend"',
            promptMl: 'കുടുംബത്തെ കാണാൻ പോകുന്നു: "family"',
            voiceLeadIn: 'visit my family',
            targetWord: 'family',
            options: ['wallet', 'clock', 'family'],
            correctIndex: 2,
            explanationEn: '"Visit my family" is an everyday conversational plan.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Friendly farewell: "See you later, ___!"',
            promptMl: 'ശ്രദ്ധിക്കുക എന്ന് പറഞ്ഞ് യാത്രപറയാൻ: "take care"',
            voiceLeadIn: 'take care',
            targetWord: 'take care',
            options: ['take care', 'stay hungry', 'don\'t move'],
            correctIndex: 0,
            explanationEn: '"Take care" is warm, friendly, and authentic.',
          ),
        ];
      }
    } else if (day == 14) {
      // DAY 14: Shopping, Prices & Sizing
      if (gameIndex == 1) {
        // Hilltop Market Road Delivery
        return [
          ArcadeChallengeRound(
            promptEn: 'Asking the price: "How ___ does this jacket cost?"',
            promptMl: 'വില എത്രയാണെന്ന് ചോദിക്കാൻ: "much"',
            voiceLeadIn: 'How much does this cost?',
            targetWord: 'much',
            options: ['much', 'many', 'heavy'],
            correctIndex: 0,
            explanationEn: '"How much does this cost?" is standard for prices.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking for a bargain: "Can you give me a ___?"',
            promptMl: 'ഡിസ്കൗണ്ട് ചോദിക്കാൻ: "discount"',
            voiceLeadIn: 'Can you give me a discount?',
            targetWord: 'discount',
            options: ['lesson', 'discount', 'receipt'],
            correctIndex: 1,
            explanationEn: '"Can you give me a discount?" negotiates prices politely.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Deciding to buy: "I\'ll ___ this one, please"',
            promptMl: 'ഞാൻ ഇത് വാങ്ങാം: "take"',
            voiceLeadIn: 'I will take this one',
            targetWord: 'take',
            options: ['break', 'drop', 'take'],
            correctIndex: 2,
            explanationEn: '"I\'ll take this one" confirms your purchase decision.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking for payment proof: "Could I have a ___, please?"',
            promptMl: 'രസീത് ചോദിക്കാൻ: "receipt"',
            voiceLeadIn: 'Could I have a receipt, please?',
            targetWord: 'receipt',
            options: ['receipt', 'hanger', 'coin'],
            correctIndex: 0,
            explanationEn: '"Could I have a receipt, please?" requests the sales slip.',
          ),
        ];
      } else {
        // Parachute Market Drop (Sizes & Fitting)
        return [
          ArcadeChallengeRound(
            promptEn: 'Size request: "Do you have this shirt in a ___ size?"',
            promptMl: 'വലിയ സൈസ് ഉണ്ടോ എന്ന് ചോദിക്കാൻ: "larger"',
            voiceLeadIn: 'in a larger size',
            targetWord: 'larger',
            options: ['larger', 'older', 'tastier'],
            correctIndex: 0,
            explanationEn: '"In a larger size" asks for bigger clothing fit.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Trying clothes on: "Where is the ___ room?"',
            promptMl: 'ട്രയൽ റൂം എവിടെയാണെന്ന് ചോദിക്കാൻ: "fitting"',
            voiceLeadIn: 'Where is the fitting room?',
            targetWord: 'fitting',
            options: ['dining', 'fitting', 'sleeping'],
            correctIndex: 1,
            explanationEn: '"Fitting room" or "changing room" is where clothes are tested.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Perfect fit: "It ___ me perfectly!"',
            promptMl: 'ഇത് എനിക്ക് തികച്ചും പാകമാണ്: "fits"',
            voiceLeadIn: 'It fits me perfectly',
            targetWord: 'fits',
            options: ['hurts', 'fights', 'fits'],
            correctIndex: 2,
            explanationEn: '"It fits me perfectly" means exact size comfort.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Color option: "Do you have this in ___?"',
            promptMl: 'നീല നിറത്തിൽ ഉണ്ടോ എന്ന് ചോദിക്കാൻ: "blue"',
            voiceLeadIn: 'Do you have this in blue?',
            targetWord: 'blue',
            options: ['blue', 'circle', 'square'],
            correctIndex: 0,
            explanationEn: '"Do you have this in blue?" asks for alternative colorways.',
          ),
        ];
      }
    } else if (day == 15) {
      // DAY 15: Phone Calls & Appointments
      if (gameIndex == 1) {
        // River Stepping Stones / Lilypad Calling Flow
        return [
          ArcadeChallengeRound(
            promptEn: 'Answering a call professionally: "Hello, how may I ___ you?"',
            promptMl: 'കോൾ എടുക്കുമ്പോൾ: "help" (ഞാൻ എങ്ങനെ സഹായിക്കണം?)',
            voiceLeadIn: 'How may I help you?',
            targetWord: 'help',
            options: ['help', 'ignore', 'stop'],
            correctIndex: 0,
            explanationEn: '"How may I help you?" is standard formal phone greeting.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking for a person: "Could I speak to Mr. Anand, ___?"',
            promptMl: 'ആനന്ദുമായി സംസാരിക്കാമോ: "please"',
            voiceLeadIn: 'Could I speak to Mr. Anand, please?',
            targetWord: 'please',
            options: ['now', 'please', 'always'],
            correctIndex: 1,
            explanationEn: 'Ending with "please" shows business politeness.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Putting caller on hold: "Please ___ the line for a moment"',
            promptMl: 'ഒരു നിമിഷം ഹോൾഡ് ചെയ്യുക: "hold"',
            voiceLeadIn: 'Please hold the line for a moment',
            targetWord: 'hold',
            options: ['cut', 'drop', 'hold'],
            correctIndex: 2,
            explanationEn: '"Hold the line" means stay on the telephone connection.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Taking a message: "Would you like to leave a ___?"',
            promptMl: 'മെസ്സേജ് അയക്കാൻ ആഗ്രഹിക്കുന്നുണ്ടോ: "message"',
            voiceLeadIn: 'Would you like to leave a message?',
            targetWord: 'message',
            options: ['message', 'phone', 'bill'],
            correctIndex: 0,
            explanationEn: '"Leave a message" when the recipient is unavailable.',
          ),
        ];
      } else {
        // Sunlit Stone Altar Phone Clarifications
        return [
          ArcadeChallengeRound(
            promptEn: 'Bad audio: "Sorry, your voice is ___ up"',
            promptMl: 'ശബ്ദം മുറിഞ്ഞു കേൾക്കുന്നു: "breaking"',
            voiceLeadIn: 'Your voice is breaking up',
            targetWord: 'breaking',
            options: ['breaking', 'running', 'sleeping'],
            correctIndex: 0,
            explanationEn: '"Your voice is breaking up" describes choppy connectivity.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Setting appointment: "Does 3 PM ___ for you tomorrow?"',
            promptMl: 'നാളെ 3 മണി സൗകര്യപ്പെടുമോ: "work"',
            voiceLeadIn: 'Does three PM work for you?',
            targetWord: 'work',
            options: ['fly', 'work', 'fall'],
            correctIndex: 1,
            explanationEn: '"Does [time] work for you?" checks schedule availability.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Confirming appointment: "I am calling to ___ our meeting"',
            promptMl: 'മീറ്റിംഗ് സ്ഥിരീകരിക്കാൻ: "confirm"',
            voiceLeadIn: 'calling to confirm our meeting',
            targetWord: 'confirm',
            options: ['cancel', 'forget', 'confirm'],
            correctIndex: 2,
            explanationEn: '"Confirm our meeting" ensures both parties are prepared.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Ending call politely: "Thank you for calling. Have a great ___!"',
            promptMl: 'നല്ലൊരു ദിവസം ആശംസിക്കാൻ: "day"',
            voiceLeadIn: 'Have a great day',
            targetWord: 'day',
            options: ['day', 'phone', 'call'],
            correctIndex: 0,
            explanationEn: '"Have a great day!" is a warm professional closing.',
          ),
        ];
      }
    } else if (day == 16) {
      // DAY 16: Asking for Help & Emergencies
      if (gameIndex == 1) {
        // Dragon Mountain Flight
        return [
          ArcadeChallengeRound(
            promptEn: 'Seeking assistance: "Could you please ___ me?"',
            promptMl: 'ദയവായി എന്നെ ഒന്ന് സഹായിക്കാമോ: "help"',
            voiceLeadIn: 'Could you please help me?',
            targetWord: 'help',
            options: ['help', 'harm', 'lose'],
            correctIndex: 0,
            explanationEn: '"Could you please help me?" is the universal plea for support.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Lost in an unfamiliar city: "I think I am ___"',
            promptMl: 'എനിക്ക് വഴി തെറ്റി എന്ന് പറയാൻ: "lost"',
            voiceLeadIn: 'I think I am lost',
            targetWord: 'lost',
            options: ['happy', 'lost', 'found'],
            correctIndex: 1,
            explanationEn: '"I think I am lost" explains direction disorientation clearly.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Medical emergency: "I need to see a ___ immediately"',
            promptMl: 'ഉടൻ ഒരു ഡോക്ടറെ കാണണം: "doctor"',
            voiceLeadIn: 'I need to see a doctor immediately',
            targetWord: 'doctor',
            options: ['driver', 'singer', 'doctor'],
            correctIndex: 2,
            explanationEn: '"See a doctor immediately" communicates urgent healthcare needs.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Lost belongings: "Excuse me, I ___ my wallet"',
            promptMl: 'എന്റെ വാലറ്റ് നഷ്ടപ്പെട്ടു: "lost"',
            voiceLeadIn: 'I lost my wallet',
            targetWord: 'lost',
            options: ['lost', 'sold', 'drank'],
            correctIndex: 0,
            explanationEn: '"I lost my wallet" reports misplaced valuables.',
          ),
        ];
      } else {
        // Meadow Flying Clay Discs (Offering Help Politely)
        return [
          ArcadeChallengeRound(
            promptEn: 'Offering a hand with luggage: "May I ___ you with that?"',
            promptMl: 'സഹായം വാഗ്ദാനം ചെയ്യാൻ: "help"',
            voiceLeadIn: 'May I help you with that?',
            targetWord: 'help',
            options: ['help', 'drop', 'take away'],
            correctIndex: 0,
            explanationEn: '"May I help you with that?" is polite and respectful.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Checking on an upset person: "Are you feeling ___?"',
            promptMl: 'സുഖമാണോ എന്ന് ചോദിക്കാൻ: "okay"',
            voiceLeadIn: 'Are you feeling okay?',
            targetWord: 'okay',
            options: ['fast', 'okay', 'heavy'],
            correctIndex: 1,
            explanationEn: '"Are you feeling okay?" shows empathy and care.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Reassuring someone in distress: "Don\'t worry, help is on the ___"',
            promptMl: 'സഹായം ഉടൻ എത്തും: "way"',
            voiceLeadIn: 'help is on the way',
            targetWord: 'way',
            options: ['roof', 'car', 'way'],
            correctIndex: 2,
            explanationEn: '"Help is on the way" comforts people in an emergency.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Calming reassurance: "Everything is going to be ___"',
            promptMl: 'എല്ലാം ശരിയാകും എന്ന് ആശ്വസിപ്പിക്കാൻ: "alright"',
            voiceLeadIn: 'Everything is going to be alright',
            targetWord: 'alright',
            options: ['alright', 'terrible', 'late'],
            correctIndex: 0,
            explanationEn: '"Everything is going to be alright" gives instant peace of mind.',
          ),
        ];
      }
    } else if (day == 17) {
      // DAY 17: Expressing Opinions & Discussion
      if (gameIndex == 1) {
        // Pine Forest Grand Prix Opinions
        return [
          ArcadeChallengeRound(
            promptEn: 'Stating a perspective: "In my honest ___, we should start now"',
            promptMl: 'എന്റെ സത്യസന്ധമായ അഭിപ്രായത്തിൽ: "opinion"',
            voiceLeadIn: 'In my honest opinion',
            targetWord: 'opinion',
            options: ['opinion', 'pocket', 'ticket'],
            correctIndex: 0,
            explanationEn: '"In my honest opinion" opens thoughtful personal views.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Strong agreement: "I completely ___ with your idea"',
            promptMl: 'ഞാൻ പൂർണ്ണമായും യോജിക്കുന്നു: "agree"',
            voiceLeadIn: 'I completely agree with your idea',
            targetWord: 'agree',
            options: ['fight', 'agree', 'forget'],
            correctIndex: 1,
            explanationEn: '"I completely agree" signifies total alignment.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Diplomatic disagreement: "I see your point, but I ___"',
            promptMl: 'എനിക്ക് വ്യത്യസ്ത അഭിപ്രായമാണുള്ളത്: "disagree"',
            voiceLeadIn: 'I see your point, but I disagree',
            targetWord: 'disagree',
            options: ['agree', 'run', 'disagree'],
            correctIndex: 2,
            explanationEn: '"I see your point, but I disagree" is courteous debate.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Inviting feedback: "What are your ___ on this proposal?"',
            promptMl: 'നിങ്ങളുടെ ചിന്തകൾ/അഭിപ്രായം എന്താണ്: "thoughts"',
            voiceLeadIn: 'What are your thoughts on this?',
            targetWord: 'thoughts',
            options: ['thoughts', 'hands', 'shoes'],
            correctIndex: 0,
            explanationEn: '"What are your thoughts?" welcomes constructive input.',
          ),
        ];
      } else {
        // Countryside Scenic Highway (Common Grammar Errors & Question Tags)
        return [
          ArcadeChallengeRound(
            promptEn: '"It is a beautiful sunny morning, ___?" (isn\'t it?)',
            promptMl: 'നല്ലൊരു പ്രഭാതമാണല്ലേ എന്ന് ചോദിക്കാൻ: "isn\'t it?"',
            voiceLeadIn: 'isn\'t it?',
            targetWord: 'isn\'t it?',
            options: ["isn't it?", "is it?", "didn't it?"],
            correctIndex: 0,
            explanationEn: 'Positive statement "It is..." takes negative tag "isn\'t it?".',
          ),
          ArcadeChallengeRound(
            promptEn: '"You enjoy learning English, ___?" (don\'t you?)',
            promptMl: 'ഇംഗ്ലീഷ് പഠിക്കാൻ ഇഷ്ടമാണല്ലേ: "don\'t you?"',
            voiceLeadIn: 'don\'t you?',
            targetWord: 'don\'t you?',
            options: ["are you?", "don't you?", "haven't you?"],
            correctIndex: 1,
            explanationEn: 'Present simple "You enjoy..." takes auxiliary "don\'t you?".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Expressing firm conviction: "I firmly ___ that practice is key"',
            promptMl: 'പരിശീലനമാണ് പ്രധാനം എന്ന് വിശ്വസിക്കുന്നു: "believe"',
            voiceLeadIn: 'I firmly believe',
            targetWord: 'believe',
            options: ['doubt', 'sleep', 'believe'],
            correctIndex: 2,
            explanationEn: '"I firmly believe" articulates deep conviction.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Summarizing a point: "To ___ up, consistency brings fluency"',
            promptMl: 'ചുരുക്കത്തിൽ എന്ന് പറയാൻ: "wrap"',
            voiceLeadIn: 'To wrap up',
            targetWord: 'wrap',
            options: ['wrap', 'tear', 'jump'],
            correctIndex: 0,
            explanationEn: '"To wrap up" or "to sum up" concludes an argument neatly.',
          ),
        ];
      }
    } else if (day == 18) {
      // DAY 18: Hotel, Check-in & Resort Conversations
      if (gameIndex == 1) {
        // Lakeside Resort Check-In
        return [
          ArcadeChallengeRound(
            promptEn: 'Arriving at hotel: "I have a ___ under the name Rahul"',
            promptMl: 'രാഹുൽ എന്ന പേരിൽ മുറി ബുക്ക് ചെയ്തിട്ടുണ്ട്: "reservation"',
            voiceLeadIn: 'I have a reservation',
            targetWord: 'reservation',
            options: ['reservation', 'complaint', 'surprise'],
            correctIndex: 0,
            explanationEn: '"I have a reservation" is the key phrase at reception desks.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Breakfast timing: "What time is breakfast ___?"',
            promptMl: 'പ്രഭാതഭക്ഷണം ഏതു സമയത്താണ് നൽകുന്നത്: "served"',
            voiceLeadIn: 'What time is breakfast served?',
            targetWord: 'served',
            options: ['hidden', 'served', 'thrown'],
            correctIndex: 1,
            explanationEn: '"What time is breakfast served?" inquires about meal schedules.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Internet access: "Could you tell me the Wi-Fi ___?"',
            promptMl: 'വൈഫൈ പാസ്‌വേഡ് ചോദിക്കാൻ: "password"',
            voiceLeadIn: 'Could you tell me the Wi-Fi password?',
            targetWord: 'password',
            options: ['screen', 'router', 'password'],
            correctIndex: 2,
            explanationEn: '"Wi-Fi password" is essential for modern travelers.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Departure timing: "What is the ___ time tomorrow?"',
            promptMl: 'നാളെ ചെക്ക്-ഔട്ട് സമയം എപ്പോഴാണ്: "checkout"',
            voiceLeadIn: 'What is the checkout time?',
            targetWord: 'checkout',
            options: ['checkout', 'sleepout', 'workout'],
            correctIndex: 0,
            explanationEn: '"Checkout time" prevents extra charges on hotel departure.',
          ),
        ];
      } else {
        // Sunny Lake Target Splash (Concierge & Local Requests)
        return [
          ArcadeChallengeRound(
            promptEn: 'Booking transport: "Could you call a ___ for 8 AM?"',
            promptMl: 'രാവിലെ 8 മണിക്ക് ഒരു ടാക്സി ബുക്ക് ചെയ്യാമോ: "taxi"',
            voiceLeadIn: 'Could you call a taxi?',
            targetWord: 'taxi',
            options: ['taxi', 'train', 'plane'],
            correctIndex: 0,
            explanationEn: '"Could you call a taxi?" requests concierge transport help.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Storing baggage: "Can I leave my ___ here until noon?"',
            promptMl: 'ബാഗുകൾ ഇവിടെ സൂക്ഷിക്കാമോ: "luggage"',
            voiceLeadIn: 'leave my luggage here',
            targetWord: 'luggage',
            options: ['car', 'luggage', 'room key'],
            correctIndex: 1,
            explanationEn: '"Leave my luggage" allows sightseeing before flight time.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Extra comfort: "Could we have two extra ___, please?"',
            promptMl: 'അധിക പുതപ്പുകൾ ചോദിക്കാൻ: "blankets"',
            voiceLeadIn: 'two extra blankets',
            targetWord: 'blankets',
            options: ['tables', 'doors', 'blankets'],
            correctIndex: 2,
            explanationEn: '"Extra blankets" requests room amenity replenishment.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Expressing gratitude on departure: "We really ___ our stay!"',
            promptMl: 'താമസം വളരെ മികച്ചതായിരുന്നു എന്ന് പറയാൻ: "enjoyed"',
            voiceLeadIn: 'We really enjoyed our stay',
            targetWord: 'enjoyed',
            options: ['enjoyed', 'disliked', 'lost'],
            correctIndex: 0,
            explanationEn: '"We really enjoyed our stay" is polite hospitality appreciation.',
          ),
        ];
      }
    } else if (day == 19) {
      // DAY 19: Hobbies, Routines & Common Native Idioms
      if (gameIndex == 1) {
        // Green Turf Sports Arena Hobbies
        return [
          ArcadeChallengeRound(
            promptEn: 'Sharing hobbies: "In my free time, I love playing ___"',
            promptMl: 'ഫ്രീ സമയത്ത് ഫുട്ബോൾ കളിക്കാൻ ഇഷ്ടമാണ്: "football"',
            voiceLeadIn: 'playing football',
            targetWord: 'football',
            options: ['football', 'homework', 'dishes'],
            correctIndex: 0,
            explanationEn: '"Playing football/cricket" describes active leisure routines.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Morning routine: "I go jogging in the park ___ morning"',
            promptMl: 'എല്ലാ ദിവസവും രാവിലെ ഓടാൻ പോകും: "every"',
            voiceLeadIn: 'every morning',
            targetWord: 'every',
            options: ['never', 'every', 'rarely'],
            correctIndex: 1,
            explanationEn: '"Every morning" expresses recurring healthy habits.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking leisure habits: "How ___ do you go swimming?"',
            promptMl: 'എത്ര തവണ നീന്താൻ പോകും എന്ന് ചോദിക്കാൻ: "often"',
            voiceLeadIn: 'How often do you go swimming?',
            targetWord: 'often',
            options: ['fast', 'high', 'often'],
            correctIndex: 2,
            explanationEn: '"How often" inquires about frequency of activities.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Music interest: "I am really ___ listening to music"',
            promptMl: 'സംഗീതം കേൾക്കാൻ എനിക്ക് വളരെ താല്പര്യമുണ്ട്: "into"',
            voiceLeadIn: 'I am really into music',
            targetWord: 'into',
            options: ['into', 'over', 'onto'],
            correctIndex: 0,
            explanationEn: '"To be into something" is natural native slang for enjoying it.',
          ),
        ];
      } else {
        // Botanical Hedge Garden Native English Idioms
        return [
          ArcadeChallengeRound(
            promptEn: 'Idiom for very easy: "That test was a piece of ___!"',
            promptMl: 'വളരെ എളുപ്പമുള്ള കാര്യം: "piece of cake"',
            voiceLeadIn: 'piece of cake',
            targetWord: 'cake',
            options: ['cake', 'wood', 'stone'],
            correctIndex: 0,
            explanationEn: '"A piece of cake" means remarkably simple or effortless.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Idiom for very rare: "It happens once in a ___ moon"',
            promptMl: 'വളരെ അപൂർവ്വമായി സംഭവിക്കുന്നത്: "blue moon"',
            voiceLeadIn: 'once in a blue moon',
            targetWord: 'blue',
            options: ['red', 'blue', 'green'],
            correctIndex: 1,
            explanationEn: '"Once in a blue moon" describes infrequent events.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Wishing good luck before a speech: "Break a ___!"',
            promptMl: 'പ്രകടനത്തിന് മുൻപ് ആശംസിക്കാൻ: "Break a leg!"',
            voiceLeadIn: 'Break a leg',
            targetWord: 'leg',
            options: ['hand', 'glass', 'leg'],
            correctIndex: 2,
            explanationEn: '"Break a leg!" is the classic theatre & performance good luck wish.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Idiom for ending work for the day: "Let\'s call it a ___"',
            promptMl: 'ഇന്നത്തെ ജോലി ഇവിടെ നിർത്താം: "call it a day"',
            voiceLeadIn: 'call it a day',
            targetWord: 'day',
            options: ['day', 'night', 'week'],
            correctIndex: 0,
            explanationEn: '"Call it a day" signifies concluding daily tasks.',
          ),
        ];
      }
    } else if (day == 20) {
      // DAY 20: Job Interview & Spoken Mastery Milestone
      if (gameIndex == 1) {
        // Grand Emerald Trail Job Interview & Self-Introduction
        return [
          ArcadeChallengeRound(
            promptEn: 'Interview self-intro: "I am a dedicated professional with strong ___"',
            promptMl: 'ശക്തമായ കഴിവുകളുള്ള പ്രൊഫഷണലാണ് ഞാൻ: "skills"',
            voiceLeadIn: 'strong skills',
            targetWord: 'skills',
            options: ['skills', 'doubts', 'fears'],
            correctIndex: 0,
            explanationEn: '"Strong skills" highlights competence in job interviews.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Stating strengths: "My greatest strength is solving complex ___"',
            promptMl: 'സങ്കീർണ്ണമായ പ്രശ്നങ്ങൾ പരിഹരിക്കാനുള്ള കഴിവ്: "problems"',
            voiceLeadIn: 'solving complex problems',
            targetWord: 'problems',
            options: ['games', 'problems', 'jokes'],
            correctIndex: 1,
            explanationEn: '"Solving complex problems" showcases analytical value.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Teamwork attitude: "I enjoy working ___ with my team members"',
            promptMl: 'ടീമിനൊപ്പം ഒന്നിച്ച് പ്രവർത്തിക്കാൻ ഇഷ്ടമാണ്: "collaboratively"',
            voiceLeadIn: 'working collaboratively',
            targetWord: 'collaboratively',
            options: ['alone', 'angrily', 'collaboratively'],
            correctIndex: 2,
            explanationEn: '"Collaboratively" emphasizes interpersonal team strengths.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Career motivation: "I am eager to learn and take on new ___"',
            promptMl: 'പുതിയ വെല്ലുവിളികൾ ഏറ്റെടുക്കാൻ ഞാൻ തയ്യാറാണ്: "challenges"',
            voiceLeadIn: 'take on new challenges',
            targetWord: 'challenges',
            options: ['challenges', 'holidays', 'complaints'],
            correctIndex: 0,
            explanationEn: '"Take on new challenges" expresses growth mindset and drive.',
          ),
        ];
      } else {
        // Sunlit Castle Speaking Master Guardian (The Grand Milestone Battle)
        return [
          ArcadeChallengeRound(
            promptEn: 'Handling pressure: "I prioritize tasks and stay ___ under pressure"',
            promptMl: 'സമ്മർദ്ദമുള്ളപ്പോഴും ഞാൻ ശാന്തമായി കാര്യങ്ങൾ ചെയ്യുന്നു: "calm"',
            voiceLeadIn: 'stay calm under pressure',
            targetWord: 'calm',
            options: ['calm', 'angry', 'afraid'],
            correctIndex: 0,
            explanationEn: '"Stay calm under pressure" demonstrates emotional resilience.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Why should we hire you? "Because my skills are a perfect ___ for this role"',
            promptMl: 'എന്റെ കഴിവുകൾ ഈ ജോലിക്ക് തികച്ചും അനുയോജ്യമാണ്: "match"',
            voiceLeadIn: 'a perfect match for this role',
            targetWord: 'match',
            options: ['hurdle', 'match', 'secret'],
            correctIndex: 1,
            explanationEn: '"A perfect match" links personal qualifications with the job.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking the interviewer: "Could you describe the company ___?"',
            promptMl: 'കമ്പനി സംസ്കാരത്തെക്കുറിച്ച് കൂടുതൽ അറിയാൻ: "culture"',
            voiceLeadIn: 'describe the company culture',
            targetWord: 'culture',
            options: ['building', 'parking', 'culture'],
            correctIndex: 2,
            explanationEn: '"Company culture" shows deep engagement and professional maturity.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Grand Closing: "Thank you so much for this wonderful ___!"',
            promptMl: 'ഈ മികച്ച അവസരത്തിന് വളരെ നന്ദി: "opportunity"',
            voiceLeadIn: 'wonderful opportunity',
            targetWord: 'opportunity',
            options: ['opportunity', 'obstacle', 'delay'],
            correctIndex: 0,
            explanationEn: '"Thank you for this wonderful opportunity" concludes meetings with grace.',
          ),
        ];
      }
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // DAY 21 TO 35 DEDICATED SPOKEN ENGLISH & ADVANCED GRAMMAR CURRICULUM
  // --------------------------------------------------------------------------
  List<ArcadeChallengeRound>? _buildDay21to35SpokenRounds(int day, int gameIndex) {
    if (day == 21) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Opposite of "Polite": "___"',
            promptMl: '"Polite" (വിനയമുള്ള) എന്നതിന്റെ വിപരീത പദം: "Rude"',
            voiceLeadIn: 'Choose Rude',
            targetWord: 'Rude',
            options: ['Rude', 'Kind', 'Calm'],
            correctIndex: 0,
            explanationEn: 'Rude is the opposite of polite.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Synonym of "Courageous": "___"',
            promptMl: '"Courageous" (ധൈര്യമുള്ള) എന്നതിന്റെ സമാനപദം: "Brave"',
            voiceLeadIn: 'Choose Brave',
            targetWord: 'Brave',
            options: ['Fearful', 'Brave', 'Tired'],
            correctIndex: 1,
            explanationEn: 'Brave means showing courage.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Antonym of "Ancient": "___"',
            promptMl: '"Ancient" (പുരാതനമായ) എന്നതിന്റെ വിപരീത പദം: "Modern"',
            voiceLeadIn: 'Choose Modern',
            targetWord: 'Modern',
            options: ['Old', 'Historic', 'Modern'],
            correctIndex: 2,
            explanationEn: 'Modern relates to present times.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Synonym of "Huge": "___"',
            promptMl: '"Huge" (വളരെ വലിയ) എന്നതിന്റെ സമാനപദം: "Gigantic"',
            voiceLeadIn: 'Choose Gigantic',
            targetWord: 'Gigantic',
            options: ['Gigantic', 'Tiny', 'Narrow'],
            correctIndex: 0,
            explanationEn: 'Gigantic means of extraordinary size.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Natural collocation: "Make an ___"',
            promptMl: 'ശരിയായ ഇംഗ്ലീഷ് പദജോടി: "Make an effort" (ശ്രമിക്കുക)',
            voiceLeadIn: 'Make an effort',
            targetWord: 'effort',
            options: ['effort', 'sleep', 'chair'],
            correctIndex: 0,
            explanationEn: 'We say "make an effort", not "do an effort".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Business collocation: "___ business with international clients"',
            promptMl: '"കച്ചവടം ചെയ്യുക": "Do business"',
            voiceLeadIn: 'Do business',
            targetWord: 'Do',
            options: ['Make', 'Do', 'Create'],
            correctIndex: 1,
            explanationEn: 'The correct collocation is "do business".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Health phrase: "Catch a ___"',
            promptMl: '"ജലദോഷം പിടിക്കുക": "Catch a cold"',
            voiceLeadIn: 'Catch a cold',
            targetWord: 'cold',
            options: ['hot', 'sun', 'cold'],
            correctIndex: 2,
            explanationEn: '"Catch a cold" is the natural medical idiom.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Efficiency collocation: "___ time and money"',
            promptMl: '"സമയം ലാഭിക്കുക": "Save time"',
            voiceLeadIn: 'Save time',
            targetWord: 'Save',
            options: ['Save', 'Kill', 'Drop'],
            correctIndex: 0,
            explanationEn: '"Save time" means reduce time spent.',
          ),
        ];
      }
    } else if (day == 22) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Cause clause: "She was late ___ of heavy rain"',
            promptMl: '"മഴ കാരണം വൈകി": "because of"',
            voiceLeadIn: 'because of',
            targetWord: 'because',
            options: ['because', 'although', 'despite'],
            correctIndex: 0,
            explanationEn: '"Because of" expresses the direct reason.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Contrast connector: "He worked hard, ___ he missed the goal"',
            promptMl: '"എങ്കിലും": "yet"',
            voiceLeadIn: 'yet he missed',
            targetWord: 'yet',
            options: ['so', 'yet', 'because'],
            correctIndex: 1,
            explanationEn: '"Yet" introduces a surprising contrast.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Relative pronoun for people: "The doctor ___ treated me"',
            promptMl: '"ചികിത്സിച്ച ഡോക്ടർ": "who"',
            voiceLeadIn: 'The doctor who treated me',
            targetWord: 'who',
            options: ['which', 'where', 'who'],
            correctIndex: 2,
            explanationEn: '"Who" is used as a relative pronoun for people.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Condition clause: "___ you practice daily, you will speak fluently"',
            promptMl: '"പരിശീലിച്ചാൽ": "If"',
            voiceLeadIn: 'If you practice daily',
            targetWord: 'If',
            options: ['If', 'Unless', 'Or'],
            correctIndex: 0,
            explanationEn: '"If" sets up the conditional prerequisite.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Pick grammatically correct sentence:',
            promptMl: 'ശരിയായ ഇംഗ്ലീഷ് വാക്യം കണ്ടെത്തുക:',
            voiceLeadIn: 'She does not like spicy food',
            targetWord: 'She does not like spicy food',
            options: ['She does not like spicy food', 'She do not likes spicy food', 'She not like spicy food'],
            correctIndex: 0,
            explanationEn: 'Third person singular takes "does not like".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Pick correct subject-verb agreement:',
            promptMl: 'ശരിയായ സബ്ജക്റ്റ്-വെർബ് വാക്യം:',
            voiceLeadIn: 'Every student has a notebook',
            targetWord: 'Every student has a notebook',
            options: ['Every student have a notebook', 'Every student has a notebook', 'Every student are having'],
            correctIndex: 1,
            explanationEn: '"Every student" is singular, requiring "has".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Pick correct past participle usage:',
            promptMl: 'ശരിയായ പാസ്റ്റ് പാർട്ടിസിപ്പിൾ വാക്യം:',
            voiceLeadIn: 'They have finished their assignment',
            targetWord: 'They have finished their assignment',
            options: ['They have finish their work', 'They did finished their work', 'They have finished their assignment'],
            correctIndex: 2,
            explanationEn: '"Have + finished" is the correct present perfect form.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Pick correct question syntax:',
            promptMl: 'ശരിയായ ചോദ്യ നിർമ്മിതി:',
            voiceLeadIn: 'Where does he live?',
            targetWord: 'Where does he live?',
            options: ['Where does he live?', 'Where he lives?', 'Where do he live?'],
            correctIndex: 0,
            explanationEn: '"Where does he live?" is correct inverted question syntax.',
          ),
        ];
      }
    } else if (day == 23) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Phrasal verb: "Please ___ the computer before leaving"',
            promptMl: '"കമ്പ്യൂട്ടർ ഓഫ് ചെയ്യുക": "turn off"',
            voiceLeadIn: 'turn off',
            targetWord: 'turn off',
            options: ['turn off', 'turn on', 'turn over'],
            correctIndex: 0,
            explanationEn: '"Turn off" means shut down electrical power.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Phrasal verb: "Never ___ on your ambitions"',
            promptMl: '"ഉപേക്ഷിക്കരുത്": "give up"',
            voiceLeadIn: 'give up',
            targetWord: 'give up',
            options: ['give in', 'give up', 'give away'],
            correctIndex: 1,
            explanationEn: '"Give up" means surrender or stop trying.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Anticipation phrase: "I ___ seeing you tomorrow"',
            promptMl: '"പ്രതീക്ഷയോടെ കാത്തിരിക്കുന്നു": "look forward to"',
            voiceLeadIn: 'look forward to',
            targetWord: 'look forward to',
            options: ['look back at', 'look up to', 'look forward to'],
            correctIndex: 2,
            explanationEn: '"Look forward to" expresses eager anticipation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Phrasal verb: "___ your shoes before entering"',
            promptMl: '"പാദരക്ഷകൾ അഴിക്കുക": "Take off"',
            voiceLeadIn: 'Take off',
            targetWord: 'Take off',
            options: ['Take off', 'Put on', 'Get in'],
            correctIndex: 0,
            explanationEn: '"Take off" means remove clothing or footwear.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Passive voice: "They built this bridge in 2015"',
            promptMl: '"ഈ പാലം 2015-ൽ നിർമ്മിക്കപ്പെട്ടു": "This bridge was built in 2015"',
            voiceLeadIn: 'This bridge was built in 2015',
            targetWord: 'This bridge was built in 2015',
            options: ['This bridge was built in 2015', 'This bridge built them in 2015', 'Bridge has build in 2015'],
            correctIndex: 0,
            explanationEn: 'Passive voice shifts focus to the bridge as the object.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Passive voice: "Chef prepares the organic meals"',
            promptMl: '"ഭക്ഷണം ഷെഫ് തയ്യാറാക്കുന്നു": "Meals are prepared by the chef"',
            voiceLeadIn: 'Meals are prepared by the chef',
            targetWord: 'Meals are prepared by the chef',
            options: ['Chef is prepared by meals', 'Meals are prepared by the chef', 'Meals prepare chef daily'],
            correctIndex: 1,
            explanationEn: 'Present passive: "are + prepared by".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Passive voice: "They will publish the report tomorrow"',
            promptMl: '"റിപ്പോർട്ട് നാളെ പ്രസിദ്ധീകരിക്കും": "The report will be published tomorrow"',
            voiceLeadIn: 'The report will be published tomorrow',
            targetWord: 'The report will be published tomorrow',
            options: ['Report publishes them tomorrow', 'Report is publishing will', 'The report will be published tomorrow'],
            correctIndex: 2,
            explanationEn: 'Future passive: "will be + published".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Passive voice: "Shakespeare wrote Hamlet"',
            promptMl: '"ഹാംലെറ്റ് ഷേക്സ്പിയറാൽ എഴുതപ്പെട്ടു": "Hamlet was written by Shakespeare"',
            voiceLeadIn: 'Hamlet was written by Shakespeare',
            targetWord: 'Hamlet was written by Shakespeare',
            options: ['Hamlet was written by Shakespeare', 'Shakespeare was written by Hamlet', 'Hamlet writes Shakespeare'],
            correctIndex: 0,
            explanationEn: 'Past passive: "was + written by".',
          ),
        ];
      }
    } else if (day == 24) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Adverb of manner: "He drove very ___ through the mist"',
            promptMl: '"വളരെ ശ്രദ്ധയോടെ ഡ്രൈവ് ചെയ്തു": "carefully"',
            voiceLeadIn: 'carefully',
            targetWord: 'carefully',
            options: ['carefully', 'careless', 'careful'],
            correctIndex: 0,
            explanationEn: '"Carefully" modifies the verb drove.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Adverb: "She explained the concept ___ to everyone"',
            promptMl: '"വ്യക്തമായി വിശദീകരിച്ചു": "clearly"',
            voiceLeadIn: 'clearly',
            targetWord: 'clearly',
            options: ['clear', 'clearly', 'clearness'],
            correctIndex: 1,
            explanationEn: '"Clearly" shows manner of explanation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Degree adverb: "The team was ___ motivated to win"',
            promptMl: '"വളരെയധികം പ്രചോദിതരായി": "highly"',
            voiceLeadIn: 'highly motivated',
            targetWord: 'highly',
            options: ['high', 'height', 'highly'],
            correctIndex: 2,
            explanationEn: '"Highly" emphasizes the level of motivation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Adverb of frequency: "She ___ arrives on time for meetings"',
            promptMl: '"എപ്പോഴും കൃത്യസമയത്ത്": "always"',
            voiceLeadIn: 'always',
            targetWord: 'always',
            options: ['always', 'yesterday', 'nevermore'],
            correctIndex: 0,
            explanationEn: '"Always" indicates 100% frequency.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Networking ice-breaker: "What brings you to this ___?"',
            promptMl: '"ഈ പരിപാടിയിൽ പങ്കെടുക്കാൻ കാരണം എന്താണ്?": "conference"',
            voiceLeadIn: 'What brings you to this conference?',
            targetWord: 'conference',
            options: ['conference', 'bedroom', 'wallet'],
            correctIndex: 0,
            explanationEn: '"What brings you to this event/conference?" is a polite networking starter.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Casual ice-breaker: "Have you ___ the food here yet?"',
            promptMl: '"ഇവിടുത്തെ ഭക്ഷണം കഴിച്ചു നോക്കിയോ?": "tried"',
            voiceLeadIn: 'Have you tried the food here yet?',
            targetWord: 'tried',
            options: ['lost', 'tried', 'sold'],
            correctIndex: 1,
            explanationEn: '"Have you tried...?" breaks the ice over refreshments.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Giving a compliment: "I really ___ your keynote speech!"',
            promptMl: '"നിങ്ങളുടെ പ്രസംഗം എനിക്ക് വളരെ ഇഷ്ടപ്പെട്ടു": "enjoyed"',
            voiceLeadIn: 'I really enjoyed your speech',
            targetWord: 'enjoyed',
            options: ['feared', 'forgot', 'enjoyed'],
            correctIndex: 2,
            explanationEn: 'A sincere compliment opens warm rapport immediately.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Asking common interests: "How long have you been in this ___?"',
            promptMl: '"ഈ മേഖലയിൽ എത്ര കാലമായി പ്രവർത്തിക്കുന്നു?": "industry"',
            voiceLeadIn: 'How long have you been in this industry?',
            targetWord: 'industry',
            options: ['industry', 'ladder', 'suitcase'],
            correctIndex: 0,
            explanationEn: '"In this industry/field" explores professional background.',
          ),
        ];
      }
    } else if (day == 25) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Radio emergency: "Mayday! Send immediate ___ to our coordinates"',
            promptMl: '"ഉടൻ സഹായം അയക്കുക": "assistance"',
            voiceLeadIn: 'immediate assistance',
            targetWord: 'assistance',
            options: ['assistance', 'trouble', 'silence'],
            correctIndex: 0,
            explanationEn: '"Immediate assistance" is formal international distress call.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Navigation instruction: "Hike towards the northern ___"',
            promptMl: '"വടക്കൻ മലനിരകളിലേക്ക് നടക്കുക": "ridge"',
            voiceLeadIn: 'northern ridge',
            targetWord: 'ridge',
            options: ['ceiling', 'ridge', 'floor'],
            correctIndex: 1,
            explanationEn: '"Ridge" refers to a long narrow hilltop.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Safety rule: "Purify all water before ___ it"',
            promptMl: '"കുടിക്കുന്നതിന് മുൻപ് വെള്ളം ശുദ്ധീകരിക്കുക": "drinking"',
            voiceLeadIn: 'drinking it',
            targetWord: 'drinking',
            options: ['spilling', 'freezing', 'drinking'],
            correctIndex: 2,
            explanationEn: '"Drinking" indicates water consumption.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Rescue signal: "Maintain a smoky fire to signal ___"',
            promptMl: '"ഹെലികോപ്റ്ററുകൾക്ക് അടയാളം നൽകാൻ തീ കത്തിക്കുക": "aircraft"',
            voiceLeadIn: 'signal aircraft',
            targetWord: 'aircraft',
            options: ['aircraft', 'fish', 'boulders'],
            correctIndex: 0,
            explanationEn: '"Signal aircraft" aims at aerial rescue discovery.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'First conditional: "If it rains, we ___ inside"',
            promptMl: '"മഴ പെയ്താൽ ഞങ്ങൾ ഉള്ളിൽ ഇരിക്കും": "will stay"',
            voiceLeadIn: 'will stay inside',
            targetWord: 'will stay',
            options: ['will stay', 'stayed', 'had stayed'],
            correctIndex: 0,
            explanationEn: 'First conditional uses present simple + will + verb.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Second conditional: "If I won a lottery, I ___ travel the world"',
            promptMl: '"ലോട്ടറി അടിച്ചാൽ ലോകം ചുറ്റി സഞ്ചരിക്കുമായിരുന്നു": "would"',
            voiceLeadIn: 'I would travel the world',
            targetWord: 'would',
            options: ['will', 'would', 'shall'],
            correctIndex: 1,
            explanationEn: 'Hypothetical situations take "would + infinitive".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Zero conditional: "If you heat ice, it ___"',
            promptMl: '"ഐസ് ചൂടാക്കിയാൽ ഉരുകുന്നു": "melts"',
            voiceLeadIn: 'it melts',
            targetWord: 'melts',
            options: ['melted', 'will melted', 'melts'],
            correctIndex: 2,
            explanationEn: 'General scientific facts take present simple in both clauses.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Giving advice: "If I were you, I ___ accept the offer"',
            promptMl: '"ഞാൻ നിങ്ങളുടെ സ്ഥാനത്താണെങ്കിൽ ആ ഓഫർ സ്വീകരിക്കും": "would"',
            voiceLeadIn: 'I would accept the offer',
            targetWord: 'would',
            options: ['would', 'am', 'did'],
            correctIndex: 0,
            explanationEn: '"If I were you, I would..." is the quintessential advice pattern.',
          ),
        ];
      }
    } else if (day == 26) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Identify the ADJECTIVE:',
            promptMl: 'വിശേഷണ പദം (Adjective) കണ്ടെത്തുക:',
            voiceLeadIn: 'Brilliant',
            targetWord: 'Brilliant',
            options: ['Brilliant', 'Quickly', 'Building'],
            correctIndex: 0,
            explanationEn: 'Brilliant describes quality or intelligence.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Identify the ACTION VERB:',
            promptMl: 'പ്രവൃത്തിയെ സൂചിപ്പിക്കുന്ന പദം (Verb):',
            voiceLeadIn: 'Negotiate',
            targetWord: 'Negotiate',
            options: ['Negotiation', 'Negotiate', 'Negotiator'],
            correctIndex: 1,
            explanationEn: 'Negotiate is an active verb.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Identify the NOUN:',
            promptMl: 'നാമപദം (Noun) തിരഞ്ഞെടുക്കുക:',
            voiceLeadIn: 'Curiosity',
            targetWord: 'Curiosity',
            options: ['Curious', 'Curiously', 'Curiosity'],
            correctIndex: 2,
            explanationEn: 'Curiosity is an abstract noun.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Identify the ADVERB:',
            promptMl: 'ക്രിയാവിശേഷണം (Adverb) കണ്ടെത്തുക:',
            voiceLeadIn: 'Enthusiastically',
            targetWord: 'Enthusiastically',
            options: ['Enthusiastically', 'Enthusiasm', 'Enthusiastic'],
            correctIndex: 0,
            explanationEn: '-ly suffix typically forms adverbs.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Reverse action prefix: "___tie the knot"',
            promptMl: '"കെട്ടഴിക്കുക": "Un-"',
            voiceLeadIn: 'Untie the knot',
            targetWord: 'Un',
            options: ['Un', 'Dis', 'Re'],
            correctIndex: 0,
            explanationEn: 'Un- reverses the action of tie.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Opposite prefix: "___agree with the policy"',
            promptMl: '"യോജിക്കാതിരിക്കുക": "Dis-"',
            voiceLeadIn: 'Disagree',
            targetWord: 'Dis',
            options: ['Mis', 'Dis', 'In'],
            correctIndex: 1,
            explanationEn: 'Dis- indicates negation or opposite.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Repetition prefix: "___write the draft"',
            promptMl: '"വീണ്ടും എഴുതുക": "Re-"',
            voiceLeadIn: 'Rewrite',
            targetWord: 'Re',
            options: ['Pre', 'Post', 'Re'],
            correctIndex: 2,
            explanationEn: 'Re- means to do again.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Wrong prefix: "___understand the instructions"',
            promptMl: '"തെറ്റായി മനസ്സിലാക്കുക": "Mis-"',
            voiceLeadIn: 'Misunderstand',
            targetWord: 'Mis',
            options: ['Mis', 'Un', 'Sub'],
            correctIndex: 0,
            explanationEn: 'Mis- means wrong or mistaken.',
          ),
        ];
      }
    } else if (day == 27) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Select the correct spelling:',
            promptMl: 'ശരിയായ സ്പെല്ലിംഗ് തിരഞ്ഞെടുക്കുക:',
            voiceLeadIn: 'Definitely',
            targetWord: 'Definitely',
            options: ['Definitely', 'Definately', 'Definetly'],
            correctIndex: 0,
            explanationEn: '"Definitely" is spelled with -ite-.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Select the correct spelling:',
            promptMl: 'ശരിയായ സ്പെല്ലിംഗ് കണ്ടെത്തുക:',
            voiceLeadIn: 'Necessary',
            targetWord: 'Necessary',
            options: ['Neccessary', 'Necessary', 'Necesary'],
            correctIndex: 1,
            explanationEn: 'One C, double S: Necessary.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Select the correct spelling:',
            promptMl: 'ശരിയായ സ്പെല്ലിംഗ് കണ്ടെത്തുക:',
            voiceLeadIn: 'Accommodate',
            targetWord: 'Accommodate',
            options: ['Acommodate', 'Accomodate', 'Accommodate'],
            correctIndex: 2,
            explanationEn: 'Double C and double M: Accommodate.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Select the correct spelling:',
            promptMl: 'ശരിയായ സ്പെല്ലിംഗ് തിരഞ്ഞെടുക്കുക:',
            voiceLeadIn: 'Receive',
            targetWord: 'Receive',
            options: ['Receive', 'Recieve', 'Receeve'],
            correctIndex: 0,
            explanationEn: 'Rule: I before E except after C: Receive.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Possessive: "They parked ___ electric car outside"',
            promptMl: '"അവരുടെ": "their"',
            voiceLeadIn: 'their car',
            targetWord: 'their',
            options: ['their', 'there', 'they are'],
            correctIndex: 0,
            explanationEn: '"Their" indicates possession by them.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Location: "Look over ___, the rainbow is visible!"',
            promptMl: '"അവിടെ": "there"',
            voiceLeadIn: 'over there',
            targetWord: 'there',
            options: ['their', 'there', 'they are'],
            correctIndex: 1,
            explanationEn: '"There" specifies physical place.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Contraction: "___ going to join us for dinner"',
            promptMl: '"അവർ വരുന്നു": "They are"',
            voiceLeadIn: 'They are going to join',
            targetWord: 'They are',
            options: ['There', 'Their', 'They are'],
            correctIndex: 2,
            explanationEn: '"They are" is the subject pronoun + verb.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Ownership question: "___ laptop is on the desk?"',
            promptMl: '"ആരുടെ ലാപ്‌ടോപ്പ്": "Whose"',
            voiceLeadIn: 'Whose laptop is this?',
            targetWord: 'Whose',
            options: ['Whose', 'Who is', 'Whom'],
            correctIndex: 0,
            explanationEn: '"Whose" asks about ownership.',
          ),
        ];
      }
    } else if (day == 28) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Transit announcement: "Mind the ___ between the train and platform"',
            promptMl: '"ട്രെയിനും പ്ലാറ്റ്‌ഫോമും തമ്മിലുള്ള വിടവ് ശ്രദ്ധിക്കുക": "gap"',
            voiceLeadIn: 'Mind the gap',
            targetWord: 'gap',
            options: ['gap', 'hat', 'bag'],
            correctIndex: 0,
            explanationEn: '"Mind the gap" is the famous international subway safety alert.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Doors warning: "Stand ___ of the closing doors"',
            promptMl: '"അടയുന്ന വാതിലുകളിൽ നിന്നും മാറിനിൽക്കുക": "clear"',
            voiceLeadIn: 'Stand clear of the closing doors',
            targetWord: 'clear',
            options: ['near', 'clear', 'inside'],
            correctIndex: 1,
            explanationEn: '"Stand clear" means maintain a safe distance.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Direction announcement: "Doors will open on the ___"',
            promptMl: '"ഇടതുവശത്തെ വാതിലുകൾ തുറക്കും": "left"',
            voiceLeadIn: 'Doors will open on the left',
            targetWord: 'left',
            options: ['ceiling', 'roof', 'left'],
            correctIndex: 2,
            explanationEn: 'Specifies exit side for passenger disembarking.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Delay announcement: "We apologize for the brief ___"',
            promptMl: '"ചെറിയ കാലതാമസത്തിൽ ഞങ്ങൾ ക്ഷമ ചോദിക്കുന്നു": "delay"',
            voiceLeadIn: 'apologize for the brief delay',
            targetWord: 'delay',
            options: ['delay', 'ticket', 'station'],
            correctIndex: 0,
            explanationEn: '"Brief delay" explains train holdups politely.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Riddle: "I speak without a mouth and hear without ears. What am I?"',
            promptMl: '"വാക്കുകളില്ലാതെ സംസാരിക്കുന്ന, ചെവികളില്ലാതെ കേൾക്കുന്ന പ്രതിഭാസം?": "An echo"',
            voiceLeadIn: 'An echo',
            targetWord: 'An echo',
            options: ['An echo', 'A river', 'A stone'],
            correctIndex: 0,
            explanationEn: 'An echo repeats spoken sounds back.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Riddle: "What has keys but no locks, space but no room?"',
            promptMl: '"കീകൾ ഉണ്ടെങ്കിലും ലോക്കുകൾ ഇല്ലാത്ത ഉപകരണം?": "A keyboard"',
            voiceLeadIn: 'A keyboard',
            targetWord: 'A keyboard',
            options: ['A piano only', 'A keyboard', 'A bicycle'],
            correctIndex: 1,
            explanationEn: 'Computer keyboards contain spacebars and keys.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Riddle: "The more you take, the more you leave behind. What are they?"',
            promptMl: '"കൂടുതൽ എടുക്കുന്തോറും പിന്നിൽ ഉപേക്ഷിച്ചു പോകുന്ന കാര്യം?": "Footsteps"',
            voiceLeadIn: 'Footsteps',
            targetWord: 'Footsteps',
            options: ['Apples', 'Coins', 'Footsteps'],
            correctIndex: 2,
            explanationEn: 'Every step taken leaves a footstep behind.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Riddle: "What gets wetter the more it dries?"',
            promptMl: '"നനവ് തുടയ്ക്കുന്തോറും കൂടുതൽ നനയുന്ന സാധനം?": "A towel"',
            voiceLeadIn: 'A towel',
            targetWord: 'A towel',
            options: ['A towel', 'A mirror', 'A window'],
            correctIndex: 0,
            explanationEn: 'A towel absorbs moisture while drying skin.',
          ),
        ];
      }
    } else if (day == 29) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Comparative: "Mount Everest is ___ than Mont Blanc"',
            promptMl: '"കൂടുതൽ ഉയരമുള്ളത്": "higher"',
            voiceLeadIn: 'higher',
            targetWord: 'higher',
            options: ['higher', 'highest', 'high'],
            correctIndex: 0,
            explanationEn: 'Comparative of high is higher + than.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Superlative: "This is the ___ challenging mountain trail"',
            promptMl: '"ഏറ്റവും കൂടുതൽ വെല്ലുവിളി നിറഞ്ഞത്": "most"',
            voiceLeadIn: 'most challenging',
            targetWord: 'most',
            options: ['more', 'most', 'much'],
            correctIndex: 1,
            explanationEn: 'Three-syllable adjectives take "most + adjective".',
          ),
          ArcadeChallengeRound(
            promptEn: 'Irregular progression: "Good -> Better -> ___"',
            promptMl: '"ഏറ്റവും മികച്ചത്": "Best"',
            voiceLeadIn: 'Best',
            targetWord: 'Best',
            options: ['Gooder', 'Betterest', 'Best'],
            correctIndex: 2,
            explanationEn: 'Good, better, best is irregular.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Irregular progression: "Bad -> Worse -> ___"',
            promptMl: '"ഏറ്റവും മോശമായത്": "Worst"',
            voiceLeadIn: 'Worst',
            targetWord: 'Worst',
            options: ['Worst', 'Baddest', 'Worser'],
            correctIndex: 0,
            explanationEn: 'Bad, worse, worst is irregular.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Hazard alert: "Look ___! A rolling stone ahead!"',
            promptMl: '"ശ്രദ്ധിക്കൂ!": "out"',
            voiceLeadIn: 'Look out',
            targetWord: 'out',
            options: ['out', 'up', 'in'],
            correctIndex: 0,
            explanationEn: '"Look out!" warns of immediate approaching hazards.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Footing caution: "Watch your ___ on these wet rocks"',
            promptMl: '"കാലടികൾ ശ്രദ്ധിക്കുക": "step"',
            voiceLeadIn: 'Watch your step',
            targetWord: 'step',
            options: ['hand', 'step', 'nose'],
            correctIndex: 1,
            explanationEn: '"Watch your step" cautions against slippery surfaces.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Checking companions: "Is everybody unhurt and ___?"',
            promptMl: '"എല്ലാവരും സുരക്ഷിതരാണോ?": "safe"',
            voiceLeadIn: 'unhurt and safe',
            targetWord: 'safe',
            options: ['tired', 'noisy', 'safe'],
            correctIndex: 2,
            explanationEn: 'Checks overall physical wellbeing in outdoor trekking.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Post-hazard calm: "Take a deep ___ and drink some water"',
            promptMl: '"ദീർഘശ്വാസമെടുക്കൂ": "breath"',
            voiceLeadIn: 'deep breath',
            targetWord: 'breath',
            options: ['breath', 'jump', 'nap'],
            correctIndex: 0,
            explanationEn: '"Take a deep breath" helps recover composure.',
          ),
        ];
      }
    } else if (day == 30) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Polite decline: "I have a prior ___, so I cannot attend"',
            promptMl: '"മുൻകൂട്ടി തീരുമാനിച്ച കാര്യമുണ്ട്": "commitment"',
            voiceLeadIn: 'prior commitment',
            targetWord: 'commitment',
            options: ['commitment', 'quarrel', 'dream'],
            correctIndex: 0,
            explanationEn: '"Prior commitment" declines invitations with supreme diplomacy.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Clarification phrase: "Would you mind saying that once ___?"',
            promptMl: '"ഒന്നുകൂടി പറയാമോ?": "more"',
            voiceLeadIn: 'once more',
            targetWord: 'more',
            options: ['ever', 'more', 'less'],
            correctIndex: 1,
            explanationEn: '"Once more" is courteous and warm.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Hearty congratulations: "Kudos on your well-deserved ___!"',
            promptMl: '"നിങ്ങളുടെ അർഹമായ വിജയത്തിൽ അഭിനന്ദനങ്ങൾ!": "success"',
            voiceLeadIn: 'well-deserved success',
            targetWord: 'success',
            options: ['penalty', 'trouble', 'success'],
            correctIndex: 2,
            explanationEn: '"Well-deserved success" honors dedication and hard work.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Expressing uncertainty: "I am not entirely ___ regarding that figure"',
            promptMl: '"എനിക്ക് പൂർണ്ണമായി ഉറപ്പില്ല": "sure"',
            voiceLeadIn: 'not entirely sure',
            targetWord: 'sure',
            options: ['sure', 'fast', 'brave'],
            correctIndex: 0,
            explanationEn: '"Not entirely sure" indicates measured professional caution.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Fluency King: "What is the secret of language mastery?"',
            promptMl: '"ഭാഷാ പ്രാവീണ്യത്തിന്റെ രഹസ്യം?": "Daily practice and confidence"',
            voiceLeadIn: 'Daily practice and confidence',
            targetWord: 'Daily practice and confidence',
            options: ['Daily practice and confidence', 'Never speaking aloud', 'Avoiding all mistakes'],
            correctIndex: 0,
            explanationEn: 'Continuous spoken repetition breeds fluent eloquence.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Fluency King: "How do you navigate differences of opinion?"',
            promptMl: '"അഭിപ്രായവ്യത്യാസങ്ങളെ എങ്ങനെ കൈകാര്യം ചെയ്യുന്നു?": "With respectful listening"',
            voiceLeadIn: 'With respectful listening',
            targetWord: 'With respectful listening',
            options: ['By shouting louder', 'With respectful listening', 'By leaving the room'],
            correctIndex: 1,
            explanationEn: 'Constructive dialogue starts with attentive listening.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Fluency King: "What defines an effective communicator?"',
            promptMl: '"മികച്ച ആശയവിനിമയക്കാരന്റെ ഗുണം?": "Clarity, warmth, and empathy"',
            voiceLeadIn: 'Clarity, warmth, and empathy',
            targetWord: 'Clarity, warmth, and empathy',
            options: ['Using complex words only', 'Speaking at high speed', 'Clarity, warmth, and empathy'],
            correctIndex: 2,
            explanationEn: 'Authentic empathy connects human hearts in conversation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Fluency King: "Are you ready to claim Month-1 Fluency Crown?"',
            promptMl: '"കിരീടം സ്വീകരിക്കാൻ നിങ്ങൾ തയ്യാറാണോ?": "Yes, I am fully ready!"',
            voiceLeadIn: 'Yes, I am fully ready!',
            targetWord: 'Yes, I am fully ready!',
            options: ['Yes, I am fully ready!', 'Not today maybe later', 'I am afraid'],
            correctIndex: 0,
            explanationEn: 'Confidence seals all language milestones triumphantly!',
          ),
        ];
      }
    } else if (day == 31) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Climate precaution: "Drink abundant fluids to prevent ___"',
            promptMl: '"നിർജ്ജലീകരണം തടയാൻ ധാരാളം വെള്ളം കുടിക്കുക": "dehydration"',
            voiceLeadIn: 'dehydration',
            targetWord: 'dehydration',
            options: ['dehydration', 'excitement', 'nutrition'],
            correctIndex: 0,
            explanationEn: 'Dehydration is the lack of bodily water.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Visibility condition: "The sandstorm reduced ___ to under ten feet"',
            promptMl: '"കാഴ്ചാശേഷി കുറഞ്ഞു": "visibility"',
            voiceLeadIn: 'visibility',
            targetWord: 'visibility',
            options: ['altitude', 'visibility', 'temperature'],
            correctIndex: 1,
            explanationEn: 'Visibility measures distance one can clearly see.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Desert shelter: "We found shade under the date palm ___"',
            promptMl: '"ഈന്തപ്പനകൾക്ക് കീഴിൽ തണൽ കണ്ടെത്തി": "trees"',
            voiceLeadIn: 'palm trees',
            targetWord: 'trees',
            options: ['rocks', 'sand', 'trees'],
            correctIndex: 2,
            explanationEn: 'Palm trees provide critical canopy in desert oases.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Solar protection: "Wear polarized eyewear to shield against sun ___"',
            promptMl: '"സൂര്യപ്രകാശത്തിന്റെ തീക്ഷ്ണത തടയാൻ": "glare"',
            voiceLeadIn: 'sun glare',
            targetWord: 'glare',
            options: ['glare', 'mist', 'raindrops'],
            correctIndex: 0,
            explanationEn: 'Glare is harsh dazzling sunlight.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Survival tool: "Check the orientation on your magnetic ___"',
            promptMl: '"വടക്കുനോക്കിയന്ത്രം പരിശോധിക്കുക": "compass"',
            voiceLeadIn: 'compass',
            targetWord: 'compass',
            options: ['compass', 'clock', 'flashlight'],
            correctIndex: 0,
            explanationEn: 'A compass guides navigation using magnetic north.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Resource rationing: "Carry sufficient energy bars in your ___"',
            promptMl: '"ബാഗിൽ ഭക്ഷണം കരുതുക": "backpack"',
            voiceLeadIn: 'backpack',
            targetWord: 'backpack',
            options: ['pocketbook', 'backpack', 'shoebox'],
            correctIndex: 1,
            explanationEn: 'A backpack holds outdoor essentials.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Destination goal: "Follow the caravan path to reach the ___"',
            promptMl: '"താമസസ്ഥലത്ത് എത്തുക": "settlement"',
            voiceLeadIn: 'settlement',
            targetWord: 'settlement',
            options: ['mountain', 'quicksand', 'settlement'],
            correctIndex: 2,
            explanationEn: 'A settlement is an inhabited village or town.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Reflective signaling: "Use a pocket mirror to flash ___"',
            promptMl: '"സൂര്യപ്രകാശം പ്രതിഫലിപ്പിച്ച് സിഗ്നൽ നൽകുക": "sunlight"',
            voiceLeadIn: 'sunlight',
            targetWord: 'sunlight',
            options: ['sunlight', 'shadow', 'water'],
            correctIndex: 0,
            explanationEn: 'Mirror flashes reflect sunlight miles away.',
          ),
        ];
      }
    } else if (day == 32) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Clause linking: "Although she was tired, she ___ running"',
            promptMl: '"ക്ഷീണിതയായിരുന്നെങ്കിലും ഓട്ടം തുടർന്നു": "kept"',
            voiceLeadIn: 'kept running',
            targetWord: 'kept',
            options: ['kept', 'stopped', 'forgave'],
            correctIndex: 0,
            explanationEn: '"Kept + gerund" expresses uninterrupted continuation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Correlative conjunction: "Not only did he qualify, but he ___ set a record"',
            promptMl: '"മാത്രമല്ല റെക്കോർഡും സ്ഥാപിച്ചു": "also"',
            voiceLeadIn: 'also set a record',
            targetWord: 'also',
            options: ['never', 'also', 'either'],
            correctIndex: 1,
            explanationEn: '"Not only... but also" couples two positive achievements.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Time clause: "As soon as the green flag waved, the cars ___"',
            promptMl: '"കാറുകൾ കുതിച്ചുപാഞ്ഞു": "accelerated"',
            voiceLeadIn: 'accelerated',
            targetWord: 'accelerated',
            options: ['parked', 'refueled', 'accelerated'],
            correctIndex: 2,
            explanationEn: '"Accelerated" indicates instant speed increase.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Decisive action: "When an opportunity arises, you must ___ action"',
            promptMl: '"നടപടിയെടുക്കണം": "take"',
            voiceLeadIn: 'take action',
            targetWord: 'take',
            options: ['take', 'sleep', 'hide'],
            correctIndex: 0,
            explanationEn: '"Take action" is the idiomatic phrase for proactive initiative.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Traffic inspection: "May I inspect your driving ___ and insurance?"',
            promptMl: '"ഡ്രൈവിംഗ് ലൈസൻസ് പരിശോധിക്കട്ടെ?": "license"',
            voiceLeadIn: 'driving license',
            targetWord: 'license',
            options: ['license', 'diploma', 'menu'],
            correctIndex: 0,
            explanationEn: '"Driving license" authorizes legal vehicle operation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Highway regulation: "Never exceed the posted ___ limit"',
            promptMl: '"വേഗപരിധി കവിയരുത്": "speed"',
            voiceLeadIn: 'speed limit',
            targetWord: 'speed',
            options: ['fuel', 'speed', 'gear'],
            correctIndex: 1,
            explanationEn: '"Speed limit" enforces road safety boundaries.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Passenger protection: "All occupants must fasten their ___"',
            promptMl: '"സീറ്റ് ബെൽറ്റുകൾ ധരിക്കുക": "seatbelts"',
            voiceLeadIn: 'fasten their seatbelts',
            targetWord: 'seatbelts',
            options: ['helmets', 'gloves', 'seatbelts'],
            correctIndex: 2,
            explanationEn: '"Seatbelts" provide passive passenger crash protection.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Safe braking room: "Maintain a proper following ___ at all times"',
            promptMl: '"സുരക്ഷിത അകലം പാലിക്കുക": "distance"',
            voiceLeadIn: 'following distance',
            targetWord: 'distance',
            options: ['distance', 'speedometer', 'mirror'],
            correctIndex: 0,
            explanationEn: '"Following distance" allows reaction time behind other cars.',
          ),
        ];
      }
    } else if (day == 33) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Helicopter pilot: "Search helicopter approaching, illuminate the landing ___"',
            promptMl: '"ലാൻഡിംഗ് പ്രദേശം പ്രകാശിപ്പിക്കുക": "zone"',
            voiceLeadIn: 'landing zone',
            targetWord: 'zone',
            options: ['zone', 'curtain', 'bench'],
            correctIndex: 0,
            explanationEn: '"Landing zone" specifies the designated touchdown clearing.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Medical triage radio: "All four survivors are in stable ___"',
            promptMl: '"എല്ലാവരും സുരക്ഷിതമായ ആരോഗ്യസ്ഥിതിയിലാണ്": "condition"',
            voiceLeadIn: 'stable condition',
            targetWord: 'condition',
            options: ['altitude', 'condition', 'apparel'],
            correctIndex: 1,
            explanationEn: '"Stable condition" indicates steady vital health signs.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Winch hoist instruction: "Attach the carabiner securely to your safety ___"',
            promptMl: '"സേഫ്റ്റി ബെൽറ്റിൽ കൊളുത്ത് ഉറപ്പിക്കുക": "harness"',
            voiceLeadIn: 'safety harness',
            targetWord: 'harness',
            options: ['hat', 'shoe', 'harness'],
            correctIndex: 2,
            explanationEn: '"Safety harness" supports passenger weight on helicopter winches.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Mission debrief: "Evacuation complete, returning safely to ___"',
            promptMl: '"ബേസിലേക്ക് മടങ്ങുന്നു": "base"',
            voiceLeadIn: 'returning to base',
            targetWord: 'base',
            options: ['base', 'jungle', 'cliff'],
            correctIndex: 0,
            explanationEn: '"Returning to base" signals completion of an aerial mission.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Spatial preposition: "The parachutist landed directly ___ the target circle"',
            promptMl: '"ലക്ഷ്യസ്ഥാന വൃത്തത്തിനുള്ളിൽ ലാൻഡ് ചെയ്തു": "inside"',
            voiceLeadIn: 'inside the circle',
            targetWord: 'inside',
            options: ['inside', 'underneath', 'without'],
            correctIndex: 0,
            explanationEn: '"Inside" designates interior perimeter placement.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Altitude glide: "The canopy soared majestically ___ the lush canopy"',
            promptMl: '"മരങ്ങൾക്ക് മുകളിലൂടെ പറന്നു": "above"',
            voiceLeadIn: 'above the canopy',
            targetWord: 'above',
            options: ['below', 'above', 'behind'],
            correctIndex: 1,
            explanationEn: '"Above" indicates higher vertical elevation.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Valley navigation: "Steer precisely ___ the two green mountain ridges"',
            promptMl: '"രണ്ട് കുന്നുകൾക്കിടയിലൂടെ": "between"',
            voiceLeadIn: 'between the two ridges',
            targetWord: 'between',
            options: ['around', 'throughout', 'between'],
            correctIndex: 2,
            explanationEn: '"Between" specifies navigation in the middle of two landmarks.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Touchdown phrase: "Touch down smoothly ___ the emerald grass lawn"',
            promptMl: '"പുൽത്തകിടിയിൽ സുഗമമായി ഇറങ്ങുക": "upon"',
            voiceLeadIn: 'upon the grass',
            targetWord: 'upon',
            options: ['upon', 'towards', 'against'],
            correctIndex: 0,
            explanationEn: '"Upon" formal variant of on, indicating arrival contact.',
          ),
        ];
      }
    } else if (day == 34) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Physician diagnosis: "How many hours have you experienced this sharp ___?"',
            promptMl: '"ഈ കഠിനമായ വേദന എത്ര നേരമായി അനുഭവപ്പെടുന്നു?": "pain"',
            voiceLeadIn: 'sharp pain',
            targetWord: 'pain',
            options: ['pain', 'giggle', 'slumber'],
            correctIndex: 0,
            explanationEn: '"Sharp pain" describes acute physical discomfort.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Reporting symptoms: "The patient reports feeling lightheaded and ___"',
            promptMl: '"തലകറക്കവും ഛർദ്ദിക്കാൻ വരുന്ന തോന്നലും": "nauseous"',
            voiceLeadIn: 'nauseous',
            targetWord: 'nauseous',
            options: ['athletic', 'nauseous', 'delighted'],
            correctIndex: 1,
            explanationEn: '"Nauseous" describes an inclination to vomit.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Allergy history: "Are you allergic to penicillin or any other ___?"',
            promptMl: '"മരുന്നുകളോട് അലർജിയുണ്ടോ?": "antibiotics"',
            voiceLeadIn: 'antibiotics',
            targetWord: 'antibiotics',
            options: ['furnishings', 'groceries', 'antibiotics'],
            correctIndex: 2,
            explanationEn: '"Antibiotics" are a major class of allergy-screened medicine.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Dosage instructions: "Take one tablet every morning after ___"',
            promptMl: '"ഭക്ഷണത്തിന് ശേഷം": "breakfast"',
            voiceLeadIn: 'after breakfast',
            targetWord: 'breakfast',
            options: ['breakfast', 'running', 'singing'],
            correctIndex: 0,
            explanationEn: '"After breakfast" ensures gastrointestinal medicine tolerance.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Emergency dispatcher: "What is the exact street ___ of the emergency?"',
            promptMl: '"സംഭവം നടന്ന കൃത്യമായ വിലാസം/സ്ഥലം എന്താണ്?": "address"',
            voiceLeadIn: 'street address',
            targetWord: 'address',
            options: ['address', 'recipe', 'hobby'],
            correctIndex: 0,
            explanationEn: '"Street address" pinpoints incident response coordinates.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Caller report: "A pedestrian was knocked over and hurt his ___"',
            promptMl: '"കാൽനടയാത്രക്കാരന്റെ കാലിന് പരിക്കേറ്റു": "ankle"',
            voiceLeadIn: 'hurt his ankle',
            targetWord: 'ankle',
            options: ['haircut', 'ankle', 'sunglasses'],
            correctIndex: 1,
            explanationEn: '"Ankle" is a common joint subject to pedestrian sprains.',
          ),
          ArcadeChallengeRound(
            promptEn: 'First aid dispatch: "Keep him seated upright and ensure he can ___ freely"',
            promptMl: '"ശ്വാസമെടുക്കാൻ തടസ്സമില്ലെന്ന് ഉറപ്പുവരുത്തുക": "breathe"',
            voiceLeadIn: 'breathe freely',
            targetWord: 'breathe',
            options: ['sprint', 'dance', 'breathe'],
            correctIndex: 2,
            explanationEn: '"Breathe freely" maintains vital respiratory airway open.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Paramedic dispatch: "Paramedic ambulance is en route and will arrive in 3 ___"',
            promptMl: '"മൂന്ന് മിനിറ്റിനുള്ളിൽ ആംബുലൻസ് എത്തും": "minutes"',
            voiceLeadIn: 'arrive in 3 minutes',
            targetWord: 'minutes',
            options: ['minutes', 'decades', 'weeks'],
            correctIndex: 0,
            explanationEn: '"Minutes" conveys reassuring swift response time.',
          ),
        ];
      }
    } else if (day == 35) {
      if (gameIndex == 1) {
        return [
          ArcadeChallengeRound(
            promptEn: 'Rich vocabulary: "The sunrise over the mountain was absolutely ___"',
            promptMl: '"ഗംഭീരവും മനോഹരവുമായ കാഴ്ച": "magnificent"',
            voiceLeadIn: 'magnificent',
            targetWord: 'magnificent',
            options: ['magnificent', 'monotonous', 'dull'],
            correctIndex: 0,
            explanationEn: '"Magnificent" denotes striking splendor or beauty.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Luminous adjective: "The ancient cavern was lit with ___ emerald crystals"',
            promptMl: '"സ്വയം പ്രകാശിക്കുന്ന ക്രിസ്റ്റലുകൾ": "luminous"',
            voiceLeadIn: 'luminous',
            targetWord: 'luminous',
            options: ['shadowy', 'luminous', 'opaque'],
            correctIndex: 1,
            explanationEn: '"Luminous" means emitting light or glowing softly.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Steadfast determination: "Her resolve to master fluent English was ___"',
            promptMl: '"പതറാത്ത ദൃഢനിശ്ചയം": "unwavering"',
            voiceLeadIn: 'unwavering',
            targetWord: 'unwavering',
            options: ['shaky', 'fragile', 'unwavering'],
            correctIndex: 2,
            explanationEn: '"Unwavering" means steady and resolute.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Eloquent expression: "The keynote speaker delivered an exceptionally ___ address"',
            promptMl: '"വാക്ചാതുര്യമുള്ള പ്രസംഗം": "eloquent"',
            voiceLeadIn: 'eloquent address',
            targetWord: 'eloquent',
            options: ['eloquent', 'inaudible', 'confusing'],
            correctIndex: 0,
            explanationEn: '"Eloquent" characterizes fluent, persuasive, and graceful speech.',
          ),
        ];
      } else {
        return [
          ArcadeChallengeRound(
            promptEn: 'Proverbial flow: "Consistent effort always yields genuine ___"',
            promptMl: '"നിരന്തര പരിശ്രമം യഥാർത്ഥ വിജയം നൽകുന്നു": "success"',
            voiceLeadIn: 'genuine success',
            targetWord: 'success',
            options: ['success', 'regret', 'stagnation'],
            correctIndex: 0,
            explanationEn: '"Success" crowns diligent endeavor.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Wisdom saying: "Practice makes a speaker ___"',
            promptMl: '"പരിശീലനം മനുഷ്യനെ തികവുറ്റതാക്കുന്നു": "perfect"',
            voiceLeadIn: 'Practice makes perfect',
            targetWord: 'perfect',
            options: ['weary', 'perfect', 'hesitant'],
            correctIndex: 1,
            explanationEn: '"Practice makes perfect" is the classic learning adage.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Empowerment truth: "Knowledge is the greatest fountain of ___"',
            promptMl: '"ജ്ഞാനമാണ് ഏറ്റവും വലിയ ശക്തി": "empowerment"',
            voiceLeadIn: 'fountain of empowerment',
            targetWord: 'empowerment',
            options: ['doubt', 'conflict', 'empowerment'],
            correctIndex: 2,
            explanationEn: '"Empowerment" gives confidence and self-efficacy.',
          ),
          ArcadeChallengeRound(
            promptEn: 'Mastery milestone: "Speaking English with confidence unlocks boundless ___"',
            promptMl: '"ഇംഗ്ലീഷ് സംസാരിക്കുന്നത് അനന്തമായ അവസരങ്ങൾ തുറന്നുനൽകുന്നു": "opportunities"',
            voiceLeadIn: 'boundless opportunities',
            targetWord: 'opportunities',
            options: ['opportunities', 'barriers', 'limitations'],
            correctIndex: 0,
            explanationEn: '"Boundless opportunities" summarizes the transformative power of language mastery.',
          ),
        ];
      }
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // VOCAB CURRICULUM FALLBACK FOR DAYS 21 TO 90
  // --------------------------------------------------------------------------
  List<ArcadeChallengeRound> _buildVocabFallbackRounds(int day, int gameIndex) {
    final list = <ArcadeChallengeRound>[];
    try {
      final words = Pocket90DayVocabCurriculum.getVocabForDay(day);

      if (words.isNotEmpty) {
        final count = math.min(words.length, 5);

        for (int i = 0; i < count; i++) {
          final item = words[i];
          final opts = <String>[item.word];

          for (int j = 0; j < words.length && opts.length < 3; j++) {
            if (words[j].word != item.word && !opts.contains(words[j].word)) {
              opts.add(words[j].word);
            }
          }

          while (opts.length < 3) {
            opts.add('Option ${opts.length + 1}');
          }

          opts.shuffle();
          final cIdx = opts.indexOf(item.word);

          list.add(
            ArcadeChallengeRound(
              promptEn: 'Select the English word for: "${item.malayalamMeaning}"',
              promptMl: '"${item.malayalamMeaning}" എന്നതിന്റെ ഇംഗ്ലീഷ് തിരഞ്ഞെടുക്കുക',
              voiceLeadIn: 'Select ${item.word}',
              targetWord: item.word,
              options: opts,
              correctIndex: cIdx,
              explanationEn: item.exampleSentence.isNotEmpty
                  ? item.exampleSentence
                  : '${item.word} means ${item.malayalamMeaning}.',
            ),
          );
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list.add(
        ArcadeChallengeRound(
          promptEn: 'Choose the word for "Water" (വെള്ളം)',
          promptMl: '"വെള്ളം" എന്നതിന്റെ വാക്ക് കണ്ടെത്തുക',
          voiceLeadIn: 'Select Water',
          targetWord: 'Water',
          options: ['Water', 'Fire', 'Earth'],
          correctIndex: 0,
          explanationEn: 'Water is the clear liquid that forms seas and rivers.',
        ),
      );
    }

    return list;
  }
}
