import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pocket_20days_40games_spec.dart';
import 'english_realm/english_realm_manifest.dart';
import '../pocket_90day_vocab_curriculum.dart';
import '../pocket_master_curriculum_90.dart';

/// 🌟 Particle particle model for explosions, boosts, confettis
class ArcadeParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;
  final double size;

  ArcadeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });
}

/// 🎮 Master Multi-Genre Universal Arcade Engine
/// User Audio Directive:
/// "90 ലെവലിലും ഒരു ഒന്നാമത്തെ സ്റ്റെപ്പിലുള്ള ഒരു ഗെയിം വിചാരിക്ക്, അതേ സെയിം ഗെയിം 90 ലെവലിലും കാണിക്കരുത് അഡൾട്ടിൽ തന്നെ...
/// Different different ആയിട്ടുള്ള ഗെയിമുകൾ build ചെയ്യുക:
/// കാർ റൈസിംഗ് (car racing), ബൈക്ക് റൈസിംഗ്, ട്രെയിൻ (train tracking), കട്ടകൾ വീഴുന്നത് (falling blocks),
/// ജമ്പ് ചെയ്യുന്നത് (platformer jumping), വെള്ളത്തിലൂടെ പോകുന്നത് (boat/river crossing), ബലൂൺ പൊട്ടിക്കൽ (balloon pop),
/// സബ്‌വേ സർഫേഴ്സ് (Subway Surfers runner), വെടിവെക്കുന്നത് (target shooting)...
/// ഒരൊറ്റ ഗെയിം പോലും repeat ആയിട്ട് വരരുത്!"
class PocketUniversalArcadeEnginePage extends StatefulWidget {
  final int day;
  final int gameIndex; // 1 or 2
  final DayGameSpec? spec;
  final VoidCallback? onCompleted;

  const PocketUniversalArcadeEnginePage({
    super.key,
    required this.day,
    this.gameIndex = 1,
    this.spec,
    this.onCompleted,
  });

  static Future<void> launch(
    BuildContext context, {
    required int day,
    int gameIndex = 1,
    DayGameSpec? spec,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketUniversalArcadeEnginePage(
          day: day,
          gameIndex: gameIndex,
          spec: spec,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketUniversalArcadeEnginePage> createState() =>
      _PocketUniversalArcadeEnginePageState();
}

class _PocketUniversalArcadeEnginePageState
    extends State<PocketUniversalArcadeEnginePage>
    with TickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _gameLoopController;
  late final AnimationController _pulseController;

  late DayGameSpec _activeSpec;
  final List<ArcadeParticle> _particles = [];
  final math.Random _random = math.Random();

  int _score = 0;
  int _combo = 0;
  int _lives = 3;
  int _currentChallengeIndex = 0;
  bool _isAnswerChecking = false;
  bool _isGameFinished = false;

  // Challenge round data
  late List<_ArcadeChallengeRound> _rounds;

  // ---------------------------------------------------------------------------
  // GENRE-SPECIFIC INTERACTIVE GAME STATES
  // ---------------------------------------------------------------------------
  // 1. CAR RACING / HIGHWAY NITRO
  int _carLane = 1; // 0: Left, 1: Center, 2: Right
  double _roadScrollY = 0.0;
  double _signDistance = 0.0; // 0.0 (far) to 1.0 (reached car)

  // 2. 3-LANE RUNNER (Subway Surfers style)
  int _runnerLane = 1;
  bool _isJumping = false;
  double _jumpY = 0.0;

  // 3. FALLING BLOCKS / TETRIS
  double _blockY = 0.0;
  int _selectedSlot = 1;

  // 4. RIVER BOAT / RAFT CROSSING
  double _boatX = 0.5;

  // 5. TRAIN WAGON ASSEMBLER
  final List<String> _assembledWagons = [];

  // 6. TARGET SHOOTING & BALLOON POP
  final List<double> _balloonOffsets = [0.0, 0.0, 0.0, 0.0];

  // 7. BOMB DEFUSAL
  int _bombTimerSeconds = 30;
  Timer? _bombTimer;

  // 8. ARENA BOSS BATTLE
  double _bossHp = 1.0;
  double _playerHp = 1.0;

  // 9. AIRPLANE SKY FLIGHT
  int _flightLane = 1; // 0: Left, 1: Center, 2: Right

  @override
  void initState() {
    super.initState();
    _activeSpec = widget.spec ?? _resolveGameSpec(widget.day, widget.gameIndex);
    _rounds = _generateRoundsForDay(widget.day, _activeSpec);

    _initTts();

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onGameLoopUpdate);
    _gameLoopController.repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    if (_activeSpec.genre == GameGenre.bombDefusal) {
      _startBombCountdown();
    }

    _speakCurrentPrompt();
  }

  void _onGameLoopUpdate() {
    if (!mounted || _isGameFinished) return;

    setState(() {
      // Highway road scroll
      _roadScrollY = (_roadScrollY + 4.0) % 60.0;
      if (_activeSpec.genre == GameGenre.driving ||
          _activeSpec.genre == GameGenre.nitroRace ||
          _activeSpec.genre == GameGenre.chase ||
          _activeSpec.genre == GameGenre.trafficCrossing ||
          _activeSpec.genre == GameGenre.snowRide) {
        _signDistance += 0.012;
        if (_signDistance >= 1.0 && !_isAnswerChecking) {
          _handleCarLaneHit();
        }
      }

      // Subway 3-lane runner approach
      if (_activeSpec.genre == GameGenre.runner ||
          _activeSpec.genre == GameGenre.metroRush ||
          _activeSpec.genre == GameGenre.swarmEvasion ||
          _activeSpec.genre == GameGenre.mazeRunner ||
          _activeSpec.genre == GameGenre.jumping ||
          _activeSpec.genre == GameGenre.climbing) {
        _signDistance += 0.013;
        if (_signDistance >= 1.0 && !_isAnswerChecking) {
          _handleRunnerLaneHit();
        }
      }

      // Airplane sky flight approach
      if (_activeSpec.genre == GameGenre.flying ||
          _activeSpec.genre == GameGenre.skySelection) {
        _signDistance += 0.012;
        if (_signDistance >= 1.0 && !_isAnswerChecking) {
          _handleFlightLaneHit();
        }
      }

      // Falling blocks descent
      if (_activeSpec.genre == GameGenre.fallingBlocks) {
        _blockY += 0.008;
        if (_blockY >= 0.85 && !_isAnswerChecking) {
          _handleBlockDrop();
        }
      }

      // Balloon / target float movement
      for (int i = 0; i < 4; i++) {
        _balloonOffsets[i] = math.sin(_gameLoopController.value * math.pi * 2 + i) * 12.0;
      }

      // Runner jump arc physics
      if (_isJumping) {
        _jumpY -= 3.0;
        if (_jumpY <= -45.0) {
          _isJumping = false;
        }
      } else if (_jumpY < 0.0) {
        _jumpY += 3.0;
        if (_jumpY > 0.0) _jumpY = 0.0;
      }

      // Particle update
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.life -= 0.035;
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  void _startBombCountdown() {
    _bombTimer?.cancel();
    _bombTimerSeconds = 30;
    _bombTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isGameFinished) {
        t.cancel();
        return;
      }
      setState(() {
        if (_bombTimerSeconds > 0) {
          _bombTimerSeconds--;
        } else {
          t.cancel();
          _handleWrongAnswer('Time Expired!');
        }
      });
    });
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  void _speakCurrentPrompt() {
    if (_rounds.isEmpty || _currentChallengeIndex >= _rounds.length) return;
    final r = _rounds[_currentChallengeIndex];
    try {
      _tts.speak('${r.voiceLeadIn}: ${r.targetWord}');
    } catch (_) {}
  }

  @override
  void dispose() {
    _bombTimer?.cancel();
    _gameLoopController.dispose();
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  DayGameSpec _resolveGameSpec(int day, int index) {
    final matches = Pocket20Days40GamesRegistry.allGames
        .where((g) => g.day == day && g.gameIndex == index)
        .toList();
    if (matches.isNotEmpty) return matches.first;
    final anyForDay = Pocket20Days40GamesRegistry.allGames
        .where((g) => g.day == day)
        .toList();
    if (anyForDay.isNotEmpty) return anyForDay.first;

    // Fallback based on day rotation
    const fallbackGenres = [
      GameGenre.driving,
      GameGenre.runner,
      GameGenre.fallingBlocks,
      GameGenre.shooting,
      GameGenre.boating,
      GameGenre.trainTracking,
      GameGenre.bombDefusal,
      GameGenre.arenaBoss,
    ];
    final genre = fallbackGenres[(day + index) % fallbackGenres.length];
    return DayGameSpec(
      day: day,
      gameIndex: index,
      title: 'Day $day English Arena',
      emoji: '🎮',
      genre: genre,
      englishTarget: 'Spoken English & Fast Speech Reflexes',
      descriptionEn: 'Interactive action gaming applied to English mastery.',
      descriptionMl: 'ഗെയിം കളിച്ചുകൊണ്ട് ഇംഗ്ലീഷ് പഠിക്കുക.',
      controlMechanism: 'Touch & swipe mechanics',
    );
  }

  List<_ArcadeChallengeRound> _generateRoundsForDay(int day, DayGameSpec spec) {
    final List<_ArcadeChallengeRound> list = [];

    // 🌟 Priority 1: Handcrafted authentic Sentence & Grammar Rounds from EnglishRealmManifest (Zero Repetition!)
    try {
      final realmGames = EnglishRealmManifest.getGamesForDay(day);
      if (realmGames.isNotEmpty) {
        final realmGame = realmGames.firstWhere(
          (g) => g.gameIndex == spec.gameIndex,
          orElse: () => realmGames.first,
        );
        if (realmGame.rounds.isNotEmpty) {
          for (final r in realmGame.rounds) {
            if (r.options.isNotEmpty) {
              int cIdx = 0;
              if (r.solution is int &&
                  (r.solution as int) >= 0 &&
                  (r.solution as int) < r.options.length) {
                cIdx = r.solution as int;
              } else if (r.solution is String) {
                final found = r.options.indexWhere(
                  (opt) =>
                      opt.trim().toLowerCase() ==
                      (r.solution as String).trim().toLowerCase(),
                );
                if (found >= 0) cIdx = found;
              }
              final opts = List<String>.from(r.options);
              while (opts.length < 3) {
                opts.add('Option ${opts.length + 1}');
              }

              list.add(
                _ArcadeChallengeRound(
                  promptEn: r.promptEn,
                  promptMl: r.promptMl,
                  voiceLeadIn: r.audioVoiceText ?? r.promptEn,
                  targetWord: r.contextSnippet ?? realmGame.englishTopic,
                  options: opts,
                  correctIndex: cIdx.clamp(0, opts.length - 1),
                  explanationEn: r.explanationEn,
                ),
              );
            }
          }
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}

    final vocab = Pocket90DayVocabCurriculum.getVocabForDay(day);
    final masterDay = PocketMasterCurriculum90.getDay(day);

    final targetWord1 = vocab.isNotEmpty ? vocab[0].word : 'Begin';
    final targetWord2 = vocab.length > 1 ? vocab[1].word : 'Explore';
    final targetWord3 = vocab.length > 2 ? vocab[2].word : 'Master';
    final targetWord4 = vocab.length > 3 ? vocab[3].word : 'Conquer';
    final targetWord5 = vocab.length > 4 ? vocab[4].word : 'Achieve';

    void addRound({
      required String promptEn,
      required String promptMl,
      required String voiceLeadIn,
      required String targetWord,
      required String correctOption,
      required List<String> distractors,
      required String explanationEn,
    }) {
      final opts = [correctOption, ...distractors.take(2)];
      opts.shuffle(_random);
      final cIdx = opts.indexOf(correctOption);
      list.add(
        _ArcadeChallengeRound(
          promptEn: promptEn,
          promptMl: promptMl,
          voiceLeadIn: voiceLeadIn,
          targetWord: targetWord,
          options: opts,
          correctIndex: cIdx,
          explanationEn: explanationEn,
        ),
      );
    }

    // Round 1: Target Word Meaning
    addRound(
      promptEn: 'Select the authentic meaning of "$targetWord1":',
      promptMl: '"$targetWord1" എന്ന വാക്കിന്റെ കൃത്യമായ അർത്ഥം തെരഞ്ഞെടുക്കുക:',
      voiceLeadIn: 'Find meaning of',
      targetWord: targetWord1,
      correctOption: vocab.isNotEmpty ? vocab[0].definition : 'To start an action',
      distractors: ['Completely broken or ruined', 'Silent and unwilling to speak'],
      explanationEn: vocab.isNotEmpty ? vocab[0].exampleSentence : 'Accurate usage of the word.',
    );

    // Round 2: Grammar Concept Evolution
    final correctSentence = masterDay.sentenceEvolution.isNotEmpty
        ? masterDay.sentenceEvolution[0].replaceAll(RegExp(r'^[🟢🟡🟣]\s*Basic:\s*'), '')
        : 'I am learning English enthusiastically.';
    addRound(
      promptEn: 'Identify the grammatically correct sentence:',
      promptMl: 'ശരിയായ വ്യാകരണ വാക്യം കണ്ടെത്തുക:',
      voiceLeadIn: 'Spot correct sentence for',
      targetWord: masterDay.grammarConcept,
      correctOption: correctSentence,
      distractors: ['Yesterday I will go there directly.', 'She do not know the answer.'],
      explanationEn: masterDay.whyItMatters.isNotEmpty ? masterDay.whyItMatters : 'Natural grammar rule.',
    );

    // Round 3: Colloquial Context & Phrase Completion
    addRound(
      promptEn: 'Which word naturally completes the phrase for "$targetWord2"?',
      promptMl: 'വാക്യം പൂർത്തിയാക്കാൻ ശരിയായ വാക്ക് ഏതാണ്?',
      voiceLeadIn: 'Complete the phrase with',
      targetWord: targetWord2,
      correctOption: targetWord2,
      distractors: ['${targetWord2}ing wrong', 'un${targetWord2}ed'],
      explanationEn: vocab.length > 1 ? vocab[1].exampleSentence : 'Essential context usage.',
    );

    // Round 4: Rapid Audio / Listening Reflex
    addRound(
      promptEn: 'Listen to the audio and select the spoken word "$targetWord3":',
      promptMl: 'ശബ്ദം ശ്രദ്ധിച്ച് കേട്ട് ശരിയായ വാക്ക് തെരഞ്ഞെടുക്കുക:',
      voiceLeadIn: 'Listen closely to',
      targetWord: targetWord3,
      correctOption: targetWord3,
      distractors: [targetWord4, targetWord5],
      explanationEn: 'Sharp listening and speech recognition reflex.',
    );

    // Round 5: Master Challenge / Real-World Usage
    addRound(
      promptEn: 'Choose the natural situational response for "${spec.title}":',
      promptMl: 'ഈ സാഹചര്യത്തിൽ അനുയോജ്യമായ ഉത്തരം ഏതാണ്?',
      voiceLeadIn: 'Select best response for',
      targetWord: targetWord4,
      correctOption: vocab.length > 3 ? vocab[3].exampleSentence : 'I understand and agree completely.',
      distractors: ['Not possible at any moment.', 'I has forgotten my notes.'],
      explanationEn: 'Fluent and natural communication skill.',
    );

    return list;
  }

  void _spawnParticles(double x, double y, Color color) {
    for (int i = 0; i < 24; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = _random.nextDouble() * 6.0 + 2.0;
      _particles.add(
        ArcadeParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          life: 1.0,
          color: color,
          size: _random.nextDouble() * 5.0 + 3.0,
        ),
      );
    }
  }

  void _handleCorrectAnswer() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);

    setState(() {
      _isAnswerChecking = true;
      _score += 100 + (_combo * 25);
      _combo++;
      _signDistance = 0.0;
      _blockY = 0.0;
      _bossHp = math.max(0.0, _bossHp - 0.28);
    });

    _spawnParticles(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2, const Color(0xFFFFD700));

    if (_currentChallengeIndex + 1 < _rounds.length) {
      setState(() {
        _currentChallengeIndex++;
        _isAnswerChecking = false;
      });
      _speakCurrentPrompt();
      if (_activeSpec.genre == GameGenre.bombDefusal) {
        _startBombCountdown();
      }
    } else {
      _finishGame();
    }
  }

  void _handleWrongAnswer(String reason) {
    HapticFeedback.vibrate();
    setState(() {
      _combo = 0;
      _lives--;
      _playerHp = math.max(0.0, _playerHp - 0.35);
      _signDistance = 0.0;
      _blockY = 0.0;
    });

    _spawnParticles(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2, const Color(0xFFEF4444));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $reason (Lives remaining: $_lives)'),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (_lives <= 0) {
      _restartGame();
    }
  }

  void _restartGame() {
    setState(() {
      _lives = 3;
      _combo = 0;
      _score = 0;
      _currentChallengeIndex = 0;
      _bossHp = 1.0;
      _playerHp = 1.0;
      _signDistance = 0.0;
      _blockY = 0.0;
      _flightLane = 1;
    });
    _speakCurrentPrompt();
  }

  void _finishGame() {
    setState(() {
      _isGameFinished = true;
    });
    _bombTimer?.cancel();
    HapticFeedback.heavyImpact();
    widget.onCompleted?.call();
  }

  // ---------------------------------------------------------------------------
  // GENRE ACTIONS
  // ---------------------------------------------------------------------------
  void _handleCarLaneHit() {
    final current = _rounds[_currentChallengeIndex];
    if (_carLane == current.correctIndex) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer('Wrong lane!');
    }
  }

  void _handleRunnerLaneHit() {
    final current = _rounds[_currentChallengeIndex];
    if (_runnerLane == current.correctIndex) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer('Missed target token!');
    }
  }

  void _handleFlightLaneHit() {
    final current = _rounds[_currentChallengeIndex];
    if (_flightLane == current.correctIndex) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer('Flew through wrong sky ring!');
    }
  }

  void _handleBlockDrop() {
    final current = _rounds[_currentChallengeIndex];
    if (_selectedSlot == current.correctIndex) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer('Wrong slot!');
    }
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: _isGameFinished ? _buildVictoryScreen() : _buildActiveGameArea(),
      ),
    );
  }

  Widget _buildActiveGameArea() {
    final current = _rounds[_currentChallengeIndex];

    return Stack(
      children: [
        // 1. DYNAMIC GENRE CANVAS
        Positioned.fill(
          child: _buildGenreCanvas(current),
        ),

        // 2. PARTICLE OVERLAY
        Positioned.fill(
          child: CustomPaint(
            painter: _ArcadeParticlePainter(particles: _particles),
          ),
        ),

        // 3. TOP HUD
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopHud(),
        ),

        // 4. BOTTOM CHALLENGE PROMPT CARD & CONTROLS
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildBottomInteractiveControls(current),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TOP HUD
  // ---------------------------------------------------------------------------
  Widget _buildTopHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
            ),
            child: Row(
              children: [
                Text(_activeSpec.emoji, style: const TextStyle(fontSize: 14)),
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
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GENRE CANVAS SELECTOR
  // ---------------------------------------------------------------------------
  Widget _buildGenreCanvas(_ArcadeChallengeRound round) {
    switch (_activeSpec.genre) {
      case GameGenre.driving:
      case GameGenre.nitroRace:
      case GameGenre.chase:
      case GameGenre.trafficCrossing:
      case GameGenre.snowRide:
        return _buildHighwayRacingCanvas(round);

      case GameGenre.runner:
      case GameGenre.metroRush:
      case GameGenre.swarmEvasion:
      case GameGenre.mazeRunner:
      case GameGenre.jumping:
      case GameGenre.climbing:
        return _buildSubwayRunnerCanvas(round);

      case GameGenre.fallingBlocks:
      case GameGenre.factorySorting:
      case GameGenre.machineFixing:
        return _buildTetrisFallingBlocksCanvas(round);

      case GameGenre.shooting:
      case GameGenre.archery:
      case GameGenre.slashing:
        return _buildTargetShootingCanvas(round);

      case GameGenre.flying:
      case GameGenre.skySelection:
        return _buildSkyFlightCanvas(round);

      case GameGenre.boating:
      case GameGenre.riverCrossing:
      case GameGenre.diving:
      case GameGenre.islandSurvival:
        return _buildRiverBoatCanvas(round);

      case GameGenre.trainTracking:
      case GameGenre.construction:
      case GameGenre.snake:
      case GameGenre.magnet:
        return _buildTrainWagonCanvas(round);

      case GameGenre.bombDefusal:
      case GameGenre.codeBreaker:
      case GameGenre.doorEscape:
      case GameGenre.escapeRoom:
        return _buildBombDefusalCanvas(round);

      case GameGenre.arenaBoss:
      case GameGenre.castleDefense:
      case GameGenre.robotBattle:
      case GameGenre.dialogueBattle:
      case GameGenre.interviewBattle:
        return _buildBossBattleCanvas(round);

      case GameGenre.detective:
      case GameGenre.arcadeMemory:
      case GameGenre.audioHunter:
      case GameGenre.liveReporting:
      case GameGenre.scienceLab:
      case GameGenre.worldExpedition:
      case GameGenre.rescueMission:
      case GameGenre.emergencyResponse:
      case GameGenre.magicQuest:
      case GameGenre.treasureHunt:
      case GameGenre.survival:
      case GameGenre.iceBreaker:
      case GameGenre.collecting:
        return _buildDetectiveRadarCanvas(round);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. HIGHWAY RACING CANVAS (Car Racing / Lane Steer)
  // ---------------------------------------------------------------------------
  Widget _buildHighwayRacingCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final laneWidth = w / 3.0;

        return Stack(
          children: [
            // Road background
            Container(color: const Color(0xFF1E2430)),

            // Road lane divider stripes
            CustomPaint(
              size: Size(w, h),
              painter: _RoadStripesPainter(scrollY: _roadScrollY),
            ),

            // Approaching Overhead Signs (Target Words in 3 lanes)
            Positioned(
              top: h * 0.15 + (_signDistance * (h * 0.50)),
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _signDistance.clamp(0.2, 1.0),
                child: Row(
                  children: List.generate(3, (idx) {
                    final text = idx < round.options.length ? round.options[idx] : '...';
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: idx == round.correctIndex ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Player's Sports Car
            Positioned(
              bottom: h * 0.32,
              left: _carLane * laneWidth + (laneWidth / 2.0) - 26,
              child: _buildSportsCarWidget(),
            ),

            // Lane Steer Touch Areas
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _carLane = 0),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _carLane = 1),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _carLane = 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSportsCarWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Windshield
              Container(
                width: 38,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text('🏎️', style: TextStyle(fontSize: 22)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. SUBWAY RUNNER CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildSubwayRunnerCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final laneWidth = w / 3.0;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF064E3B), Color(0xFF022C22)],
                ),
              ),
            ),
            // Track stripes
            CustomPaint(
              size: Size(w, h),
              painter: _RoadStripesPainter(scrollY: _roadScrollY),
            ),
            // Approaching Overhead Subway Arches (Target Words in 3 lanes)
            Positioned(
              top: h * 0.15 + (_signDistance * (h * 0.50)),
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _signDistance.clamp(0.2, 1.0),
                child: Row(
                  children: List.generate(3, (idx) {
                    final text = idx < round.options.length ? round.options[idx] : '...';
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: idx == round.correctIndex
                                ? [const Color(0xFF10B981), const Color(0xFF047857)]
                                : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: idx == round.correctIndex
                                ? const Color(0xFFFFD700)
                                : Colors.white24,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              idx == round.correctIndex ? '⭐ TOKEN' : '⚠️ HAZARD',
                              style: GoogleFonts.outfit(
                                color: idx == round.correctIndex ? const Color(0xFFFFD700) : Colors.white54,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              text,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Runner Hero
            Positioned(
              bottom: h * 0.32 - _jumpY,
              left: _runnerLane * laneWidth + (laneWidth / 2.0) - 26,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isJumping ? '🦘' : '🏃',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  if (_isJumping)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'JUMP!',
                        style: GoogleFonts.outfit(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
              ),
            ),
            // Touch & Swipe detector lanes
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _runnerLane = 0),
                      onVerticalDragEnd: (d) {
                        if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                          setState(() => _isJumping = true);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _runnerLane = 1),
                      onVerticalDragEnd: (d) {
                        if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                          setState(() => _isJumping = true);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _runnerLane = 2),
                      onVerticalDragEnd: (d) {
                        if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                          setState(() => _isJumping = true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 3. TETRIS FALLING BLOCKS CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildTetrisFallingBlocksCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final slotW = w / 3.0;

        return Stack(
          children: [
            Container(color: const Color(0xFF1E1B4B)),
            // Target slots at bottom
            Positioned(
              bottom: h * 0.28,
              left: 0,
              right: 0,
              child: Row(
                children: List.generate(3, (idx) {
                  final text = idx < round.options.length ? round.options[idx] : '...';
                  final isSelected = _selectedSlot == idx;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSlot = idx),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF312E81),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1),
                        ),
                        child: Center(
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Falling brick
            Positioned(
              top: h * _blockY,
              left: _selectedSlot * slotW + (slotW / 2.0) - 30,
              child: Container(
                width: 60,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.6), blurRadius: 10),
                  ],
                ),
                child: Center(
                  child: Text(
                    round.targetWord,
                    style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4. TARGET SHOOTING & BALLOON POP CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildTargetShootingCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            Container(color: const Color(0xFF0C4A6E)),
            // Floating target balloons
            ...List.generate(round.options.length, (idx) {
              final xPos = (idx % 2 == 0 ? 0.20 : 0.65) * w;
              final yPos = (0.15 + (idx * 0.12)) * h + _balloonOffsets[idx];

              return Positioned(
                left: xPos,
                top: yPos,
                child: GestureDetector(
                  onTap: () {
                    if (idx == round.correctIndex) {
                      _handleCorrectAnswer();
                    } else {
                      _handleWrongAnswer('Popped wrong target!');
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (c, _) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: idx == round.correctIndex
                              ? [const Color(0xFF10B981), const Color(0xFF047857)]
                              : [const Color(0xFFEC4899), const Color(0xFFBE185D)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎈', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            round.options[idx],
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 5. RIVER BOAT / RAFT CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildRiverBoatCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            Container(color: const Color(0xFF0369A1)),
            // Water ripples
            Center(
              child: Text(
                '〰️ 〰️ 〰️ RIVER CURRENT 〰️ 〰️ 〰️',
                style: GoogleFonts.outfit(color: Colors.white24, fontWeight: FontWeight.w900),
              ),
            ),
            // Boat
            Positioned(
              bottom: h * 0.32,
              left: _boatX * w - 30,
              child: GestureDetector(
                onHorizontalDragUpdate: (d) {
                  setState(() {
                    _boatX = (_boatX + d.delta.dx / w).clamp(0.1, 0.9);
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🛶', style: TextStyle(fontSize: 30))),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 6. TRAIN WAGON CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildTrainWagonCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final h = constraints.maxHeight;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1C1917), Color(0xFF0C0A09)],
                ),
              ),
            ),
            // Clouds / Steam
            Positioned(
              top: h * 0.10,
              left: 40 + (_roadScrollY * 2),
              child: const Text('☁️', style: TextStyle(fontSize: 32)),
            ),
            // Track ballast & ties
            Positioned(
              bottom: h * 0.34,
              left: 0,
              right: 0,
              child: Container(
                height: 14,
                color: const Color(0xFF78716C),
              ),
            ),
            // Locomotive Engine & Coupled Wagons
            Positioned(
              bottom: h * 0.35,
              left: 16,
              child: Row(
                children: [
                  const Text('🚂', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 4),
                  ..._assembledWagons.map(
                    (wagonText) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '🚃 $wagonText',
                        style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Options as Train Wagons waiting at the depot
            Positioned(
              top: h * 0.20,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Text(
                    'COUPLE THE CORRECT GRAMMAR WAGON TO THE TRAIN:',
                    style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(round.options.length, (idx) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (idx == round.correctIndex) {
                              setState(() {
                                _assembledWagons.add(round.options[idx]);
                              });
                              _handleCorrectAnswer();
                            } else {
                              _handleWrongAnswer('Wrong wagon order!');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF334155), Color(0xFF1E293B)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                const Text('🚃', style: TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  round.options[idx],
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 7. BOMB DEFUSAL CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildBombDefusalCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          color: const Color(0xFF18181B),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💣', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 10),
                Text(
                  '00:${_bombTimerSeconds.toString().padLeft(2, '0')}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFEF4444),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'CUT THE CORRECT SYNTAX WIRE BEFORE DETONATION!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 8. BOSS BATTLE CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildBossBattleCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final h = constraints.maxHeight;

        return Container(
          color: const Color(0xFF2E1065),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Boss HUD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GRAMMAR GOLEM 👹', style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.w900)),
                  Text('${(_bossHp * 100).toInt()}% HP', style: GoogleFonts.outfit(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: _bossHp, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFFEF4444))),
              const Spacer(),
              // Player HUD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SOVEREIGN KNIGHT 🛡️', style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.w900)),
                  Text('${(_playerHp * 100).toInt()}% HP', style: GoogleFonts.outfit(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: _playerHp, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981))),
              SizedBox(height: h * 0.32),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 9. DETECTIVE & RADAR EXPEDITION CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildDetectiveRadarCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Dark Cyber Radar Background
            Container(color: const Color(0xFF0F172A)),
            // Animated Radar concentric circles
            Center(
              child: Container(
                width: math.min(w, h) * 0.75,
                height: math.min(w, h) * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25), width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: math.min(w, h) * 0.45,
                    height: math.min(w, h) * 0.45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38BDF8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Radar sweeping line
            Center(
              child: Transform.rotate(
                angle: _gameLoopController.value * math.pi * 2,
                child: Container(
                  width: math.min(w, h) * 0.75,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, const Color(0xFF38BDF8).withValues(alpha: 0.8)],
                    ),
                  ),
                ),
              ),
            ),
            // Evidence Radar Blips
            ...List.generate(round.options.length, (idx) {
              final angle = (idx * (2 * math.pi / round.options.length)) + 0.4;
              final dist = (math.min(w, h) * 0.26);
              final bx = (w / 2) + math.cos(angle) * dist - 50;
              final by = (h / 2) + math.sin(angle) * dist - 50;

              return Positioned(
                left: bx,
                top: by,
                child: GestureDetector(
                  onTap: () {
                    if (idx == round.correctIndex) {
                      _handleCorrectAnswer();
                    } else {
                      _handleWrongAnswer('False evidence clue!');
                    }
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: idx == round.correctIndex ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          idx == round.correctIndex ? '🔍 EVIDENCE' : '📁 CLUE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          round.options[idx],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 9. AIRPLANE SKY FLIGHT CANVAS (Supersonic Sky Waypoint Flight)
  // ---------------------------------------------------------------------------
  Widget _buildSkyFlightCanvas(_ArcadeChallengeRound round) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final laneWidth = w / 3.0;

        return Stack(
          children: [
            // Sky gradient: twilight / stratosphere
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A),
                    Color(0xFF0284C7),
                  ],
                ),
              ),
            ),

            // Animated Sky Streamers / Clouds
            CustomPaint(
              size: Size(w, h),
              painter: _SkyCloudsPainter(scrollY: _roadScrollY),
            ),

            // Approaching Sky Waypoint Rings (Target Words in 3 aerial corridors)
            Positioned(
              top: h * 0.12 + (_signDistance * (h * 0.52)),
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _signDistance.clamp(0.25, 1.0),
                child: Row(
                  children: List.generate(3, (idx) {
                    final text = idx < round.options.length ? round.options[idx] : '...';
                    final isCorrect = idx == round.correctIndex;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isCorrect
                                ? [const Color(0xFF065F46), const Color(0xFF047857)]
                                : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCorrect ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect ? const Color(0xFF34D399) : const Color(0xFF38BDF8))
                                  .withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isCorrect ? '🪐 WAYPOINT RING' : '☁️ AIR CORRIDOR',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              text,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Player's Supersonic Flight Jet
            Positioned(
              bottom: h * 0.32,
              left: _flightLane * laneWidth + (laneWidth / 2.0) - 28,
              child: _buildFlightJetWidget(),
            ),

            // Flight Corridor Touch Areas (Left, Center, Right)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _flightLane = 0),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _flightLane = 1),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _flightLane = 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFlightJetWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 82,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF1D4ED8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cockpit canopy
              Container(
                width: 24,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2FE), Color(0xFF0284C7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Text('✈️', style: TextStyle(fontSize: 24)),
              // Jet Thruster Afterburner
              Container(
                width: 14,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM INTERACTIVE CONTROLS CARD
  // ---------------------------------------------------------------------------
  Widget _buildBottomInteractiveControls(_ArcadeChallengeRound current) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Challenge Prompt Banner
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 22),
                onPressed: _speakCurrentPrompt,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.promptEn,
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      current.promptMl,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Option Action Buttons
          ...List.generate(current.options.length, (idx) {
            final opt = current.options[idx];
            final isDriving = _activeSpec.genre == GameGenre.driving ||
                _activeSpec.genre == GameGenre.nitroRace ||
                _activeSpec.genre == GameGenre.chase ||
                _activeSpec.genre == GameGenre.trafficCrossing ||
                _activeSpec.genre == GameGenre.snowRide;
            final isRunner = _activeSpec.genre == GameGenre.runner ||
                _activeSpec.genre == GameGenre.metroRush ||
                _activeSpec.genre == GameGenre.swarmEvasion ||
                _activeSpec.genre == GameGenre.mazeRunner ||
                _activeSpec.genre == GameGenre.jumping ||
                _activeSpec.genre == GameGenre.climbing;
            final isFalling = _activeSpec.genre == GameGenre.fallingBlocks ||
                _activeSpec.genre == GameGenre.factorySorting ||
                _activeSpec.genre == GameGenre.machineFixing;
            final isFlying = _activeSpec.genre == GameGenre.flying ||
                _activeSpec.genre == GameGenre.skySelection;

            final isSelected = (isDriving && _carLane == idx) ||
                (isRunner && _runnerLane == idx) ||
                (isFalling && _selectedSlot == idx) ||
                (isFlying && _flightLane == idx);

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white12,
                    width: isSelected ? 2.0 : 1.4,
                  ),
                ),
                onPressed: () {
                  if (isDriving) {
                    setState(() => _carLane = idx);
                  } else if (isRunner) {
                    setState(() => _runnerLane = idx);
                  } else if (isFalling) {
                    setState(() => _selectedSlot = idx);
                  } else if (isFlying) {
                    setState(() => _flightLane = idx);
                  } else if (idx == current.correctIndex) {
                    _handleCorrectAnswer();
                  } else {
                    _handleWrongAnswer('Incorrect option selected!');
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VICTORY SCREEN
  // ---------------------------------------------------------------------------
  Widget _buildVictoryScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            Text(
              'CHALLENGE VICTORY!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You conquered Day ${widget.day} ${_activeSpec.title}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: $_score PTS',
              style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('CONTINUE QUEST 🚀', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcadeChallengeRound {
  final String promptEn;
  final String promptMl;
  final String voiceLeadIn;
  final String targetWord;
  final List<String> options;
  final int correctIndex;
  final String explanationEn;

  _ArcadeChallengeRound({
    required this.promptEn,
    required this.promptMl,
    required this.voiceLeadIn,
    required this.targetWord,
    required this.options,
    required this.correctIndex,
    required this.explanationEn,
  });
}

class _RoadStripesPainter extends CustomPainter {
  final double scrollY;
  _RoadStripesPainter({required this.scrollY});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 3;

    final lane1X = size.width / 3.0;
    final lane2X = (size.width / 3.0) * 2.0;

    for (double y = -60 + scrollY; y < size.height; y += 40) {
      canvas.drawLine(Offset(lane1X, y), Offset(lane1X, y + 20), p);
      canvas.drawLine(Offset(lane2X, y), Offset(lane2X, y + 20), p);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadStripesPainter oldDelegate) =>
      oldDelegate.scrollY != scrollY;
}

class _SkyCloudsPainter extends CustomPainter {
  final double scrollY;
  _SkyCloudsPainter({required this.scrollY});

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final windPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..strokeWidth = 2;

    final lane1X = size.width / 3.0;
    final lane2X = (size.width / 3.0) * 2.0;

    // Corridor dashed guidance lines
    for (double y = -60 + scrollY; y < size.height; y += 45) {
      canvas.drawLine(Offset(lane1X, y), Offset(lane1X, y + 22), windPaint);
      canvas.drawLine(Offset(lane2X, y), Offset(lane2X, y + 22), windPaint);
    }

    // Drifting clouds
    for (double y = -100 + (scrollY * 1.5); y < size.height + 100; y += 140) {
      canvas.drawCircle(Offset(size.width * 0.2, y), 24, cloudPaint);
      canvas.drawCircle(Offset(size.width * 0.24, y - 6), 32, cloudPaint);
      canvas.drawCircle(Offset(size.width * 0.28, y), 22, cloudPaint);

      canvas.drawCircle(Offset(size.width * 0.78, y + 60), 28, cloudPaint);
      canvas.drawCircle(Offset(size.width * 0.83, y + 54), 36, cloudPaint);
      canvas.drawCircle(Offset(size.width * 0.88, y + 60), 26, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyCloudsPainter oldDelegate) =>
      oldDelegate.scrollY != scrollY;
}

class _ArcadeParticlePainter extends CustomPainter {
  final List<ArcadeParticle> particles;
  _ArcadeParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeParticlePainter oldDelegate) => true;
}
