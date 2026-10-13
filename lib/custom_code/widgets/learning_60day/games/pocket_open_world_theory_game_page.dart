import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pocket_master_curriculum_90.dart';

/// 🌟 Particle model for open world energy sparks and bursts
class QuestWorldParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;
  final double size;

  QuestWorldParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });
}

/// 🌍 2D Open-World Linguistic Discovery Quest Game
///
/// User Audio Directive:
/// "തിയറി ആയിട്ട് എന്തെങ്കിലും ഇപ്പൊ നിലവിലുണ്ടോ എന്നുള്ളത് നോക്കുക.
///  തിയറി ആയിട്ടുള്ളത് ഉണ്ടെങ്കിൽ അതിനെ ഗെയിം ആയി കൺവെർട്ട് ചെയ്യണം.
///  ഓപ്പൺ ഗെയിം ആയിരിക്കണം... ഗെയിം കളിച്ചുകൊണ്ടേ പഠിക്കാൻ കഴിയണം!"
///
/// Replaces passive theory reading with an active 2D open-world game:
/// - Open World Exploration: Joystick / touch navigation across scenic open realm.
/// - Station 1: The Speech Code Matrix (Grammar Formula Tile Charging)
/// - Station 2: The Mother-Tongue Error Hunter (Shoot/Fix common regional errors)
/// - Station 3: The Sentence Evolution Sanctuary (Step through 3 fluency portals)
class PocketOpenWorldTheoryGamePage extends StatefulWidget {
  final int day;
  final VoidCallback? onQuestCompleted;

  const PocketOpenWorldTheoryGamePage({
    super.key,
    required this.day,
    this.onQuestCompleted,
  });

  static Future<void> launch(
    BuildContext context, {
    required int day,
    VoidCallback? onQuestCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketOpenWorldTheoryGamePage(
          day: day,
          onQuestCompleted: onQuestCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketOpenWorldTheoryGamePage> createState() =>
      _PocketOpenWorldTheoryGamePageState();
}

class _PocketOpenWorldTheoryGamePageState
    extends State<PocketOpenWorldTheoryGamePage>
    with TickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _gameLoopController;
  late final AnimationController _pulseController;

  late MasterCurriculumDay _dayData;
  final List<QuestWorldParticle> _particles = [];
  final math.Random _random = math.Random();

  // World & Camera Geometry
  static const double _worldWidth = 2800.0;
  static const double _worldHeight = 1200.0;
  double _playerX = 350.0;
  double _playerY = 650.0;
  double _cameraX = 0.0;
  double _cameraY = 0.0;

  // Virtual Joystick
  Offset _joystickDelta = Offset.zero;
  bool _isDraggingJoystick = false;

  // Quest Progression
  int _score = 0;
  bool _station1Completed = false;
  bool _station2Completed = false;
  bool _station3Completed = false;
  bool _isQuestVictorious = false;

  // Station 1: Formula Matrix Tiles
  final List<String> _assembledFormulaTiles = [];
  late List<String> _targetFormulaTiles;

  // Station 2: Error Hunter State
  final int _currentMistakeIndex = 0;
  late List<Map<String, String>> _mistakeChallenges;

  // Station 3: Evolution Gate State
  final int _currentEvolutionTier = 2; // Full gate unlocked for discovery

  // Proximity notification flag
  bool _isInsideStationProximity = false;
  int? _proximityStationId;

  @override
  void initState() {
    super.initState();
    _dayData = PocketMasterCurriculum90.getDay(widget.day);
    _initTts();
    _initStationData();

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateGamePhysics);
    _gameLoopController.repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _speakVoiceGuidance('Welcome to the Day ${widget.day} Open Realm. Explore the world and discover the speech secrets!');
  }

  void _initStationData() {
    final rawFormula = _dayData.grammarConcept.isNotEmpty
        ? _dayData.grammarConcept
        : 'Subject + Verb + Object';
    _targetFormulaTiles = rawFormula
        .split(RegExp(r'[\+\-\>]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (_targetFormulaTiles.isEmpty) {
      _targetFormulaTiles = ['Subject', 'Verb', 'Object'];
    }

    _mistakeChallenges = [];
    if (_dayData.commonMistakes.isNotEmpty) {
      for (final raw in _dayData.commonMistakes) {
        final parts = raw.split(RegExp(r'➔|->|vs|instead of'));
        if (parts.length >= 2) {
          _mistakeChallenges.add({
            'wrong': parts[0].replaceAll(RegExp(r'^[❌🔴\s]+'), '').trim(),
            'correct': parts[1].replaceAll(RegExp(r'^[✅🟢\s]+'), '').trim(),
            'rule': 'Authentic English syntax applies naturally here.',
          });
        }
      }
    }
    if (_mistakeChallenges.isEmpty) {
      _mistakeChallenges = [
        {
          'wrong': 'I did not went there yesterday.',
          'correct': 'I did not go there yesterday.',
          'rule': 'After did/didn\'t, always use the base form (V1).',
        },
        {
          'wrong': 'She do not understand the plan.',
          'correct': 'She does not understand the plan.',
          'rule': 'Singular subjects take does/doesn\'t.',
        },
      ];
    }
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  void _speakVoiceGuidance(String text) {
    try {
      _tts.speak(text);
    } catch (_) {}
  }

  void _updateGamePhysics() {
    if (!mounted || _isQuestVictorious) return;

    setState(() {
      // 1. Apply Joystick Movement
      if (_isDraggingJoystick && _joystickDelta != Offset.zero) {
        final speed = 4.8;
        _playerX = (_playerX + _joystickDelta.dx * speed).clamp(80.0, _worldWidth - 80.0);
        _playerY = (_playerY + _joystickDelta.dy * speed).clamp(120.0, _worldHeight - 120.0);
      }

      // 2. Camera follow player smoothly
      final screenW = MediaQuery.of(context).size.width;
      final screenH = MediaQuery.of(context).size.height;
      final targetCamX = _playerX - (screenW / 2);
      final targetCamY = _playerY - (screenH / 2);
      _cameraX += (targetCamX - _cameraX) * 0.12;
      _cameraY += (targetCamY - _cameraY) * 0.12;
      _cameraX = _cameraX.clamp(0.0, _worldWidth - screenW);
      _cameraY = _cameraY.clamp(0.0, _worldHeight - screenH);

      // 3. Proximity detection to 3 World Stations
      _checkStationProximity(1, 500.0, 650.0);
      _checkStationProximity(2, 1350.0, 550.0);
      _checkStationProximity(3, 2200.0, 680.0);

      // 4. Update particles
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

  void _checkStationProximity(int stationId, double sx, double sy) {
    final dist = math.sqrt(math.pow(_playerX - sx, 2) + math.pow(_playerY - sy, 2));
    if (dist < 130.0) {
      if (!_isInsideStationProximity || _proximityStationId != stationId) {
        _isInsideStationProximity = true;
        _proximityStationId = stationId;
        HapticFeedback.selectionClick();
      }
    } else if (_proximityStationId == stationId && dist >= 150.0) {
      _isInsideStationProximity = false;
      _proximityStationId = null;
    }
  }

  void _spawnParticles(double x, double y, Color color) {
    for (int i = 0; i < 22; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = _random.nextDouble() * 5.0 + 2.0;
      _particles.add(
        QuestWorldParticle(
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

  @override
  void dispose() {
    _gameLoopController.dispose();
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE STATION ACTIONS
  // ---------------------------------------------------------------------------
  void _openActiveStationModal(int stationId) {
    HapticFeedback.heavyImpact();
    if (stationId == 1) {
      _showFormulaStationSheet();
    } else if (stationId == 2) {
      _showErrorHunterSheet();
    } else if (stationId == 3) {
      _showEvolutionSheet();
    }
  }

  // Station 1: Speech Code Formula Matrix
  void _showFormulaStationSheet() {
    _speakVoiceGuidance('Connect the formula blocks to charge the Speech Core!');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isComplete = _assembledFormulaTiles.length == _targetFormulaTiles.length;

          return Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATION 1: SPEECH FORMULA CORE',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Day ${widget.day} Syntactic Architecture',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isComplete ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'POWERED FORMULA CORE:',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: _targetFormulaTiles.map((tile) {
                          final isAssembled = _assembledFormulaTiles.contains(tile);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isAssembled ? const Color(0xFF10B981) : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAssembled ? tile : '???',
                              style: GoogleFonts.outfit(
                                color: isAssembled ? Colors.black : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'TAP AVAILABLE SYNTAX BLOCKS TO ACTIVATE:',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _targetFormulaTiles.map((tile) {
                    final isUsed = _assembledFormulaTiles.contains(tile);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUsed ? const Color(0xFF10B981) : const Color(0xFF334155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isUsed
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              setModalState(() {
                                _assembledFormulaTiles.add(tile);
                              });
                              setState(() {
                                _score += 50;
                                _spawnParticles(_playerX, _playerY, const Color(0xFFFFD700));
                              });
                              if (_assembledFormulaTiles.length == _targetFormulaTiles.length) {
                                setState(() {
                                  _station1Completed = true;
                                });
                                HapticFeedback.heavyImpact();
                                _speakVoiceGuidance('Formula Core fully charged! Head east to the Error Hunter Arena!');
                              }
                            },
                      child: Text(tile, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                if (isComplete)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text('CONTINUE QUEST TO ARENA 2 ➔', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Station 2: Mother-Tongue Error Hunter Arena
  void _showErrorHunterSheet() {
    final challenge = _mistakeChallenges[_currentMistakeIndex];
    _speakVoiceGuidance('Eliminate the regional error and select the authentic sentence!');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final options = [challenge['correct']!, challenge['wrong']!];
          options.shuffle(_random);

          return Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATION 2: ERROR HUNTER ARENA',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Spot & Eradicate Mother-Tongue Errors',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DETECTED ANOMALOUS SPEECH PATTERN:',
                        style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '❌ "${challenge['wrong']}"',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'SELECT THE AUTHENTIC FLUENT SENTENCE TO STRIKE:',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                ...options.map((opt) {
                  final isCorrect = opt == challenge['correct'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: () {
                        if (isCorrect) {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            _score += 100;
                            _station2Completed = true;
                            _spawnParticles(_playerX, _playerY, const Color(0xFF10B981));
                          });
                          _speakVoiceGuidance('Target neutralized! Excellent grammatical accuracy!');
                          Navigator.pop(ctx);
                        } else {
                          HapticFeedback.vibrate();
                          _spawnParticles(_playerX, _playerY, const Color(0xFFEF4444));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ That pattern still contains the error! Try again.'),
                              backgroundColor: Color(0xFFEF4444),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              opt,
                              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold),
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
        },
      ),
    );
  }

  // Station 3: Sentence Evolution Sanctuary
  void _showEvolutionSheet() {
    final evolutions = _dayData.sentenceEvolution;
    _speakVoiceGuidance('Step through the three portals of natural sentence evolution!');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('🟣', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATION 3: SENTENCE EVOLUTION GATE',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFA855F7),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Basic ➔ Intermediate ➔ Sovereign Native Mastery',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                ...List.generate(
                  evolutions.isNotEmpty ? evolutions.length : 3,
                  (idx) {
                    final sent = evolutions.length > idx
                        ? evolutions[idx]
                        : (idx == 0
                            ? '🟢 Basic: I study English daily.'
                            : (idx == 1
                                ? '🟡 Intermediate: I actively practice conversational speaking every morning.'
                                : '🟣 Native Master: I effortlessly articulate complex thoughts without hesitation.'));
                    final isUnlocked = idx <= _currentEvolutionTier;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFF0F172A) : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFFA855F7) : Colors.white12,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              sent,
                              style: GoogleFonts.inter(
                                color: isUnlocked ? Colors.white : Colors.white38,
                                fontSize: 12,
                                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 20),
                            onPressed: isUnlocked ? () => _speakVoiceGuidance(sent) : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _score += 150;
                      _station3Completed = true;
                      _isQuestVictorious = true;
                    });
                    Navigator.pop(ctx);
                    widget.onQuestCompleted?.call();
                    _speakVoiceGuidance('Congratulations! Day ${widget.day} Linguistic Quest complete!');
                  },
                  child: Text(
                    'CLAIM LINGUISTIC MASTERY 🏆',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isQuestVictorious) {
      return Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: SafeArea(child: _buildVictoryScreen()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // 1. OPEN WORLD CANVAS
          Positioned.fill(
            child: _buildOpenWorldCanvas(),
          ),

          // 2. PARTICLE OVERLAY
          Positioned.fill(
            child: CustomPaint(
              painter: _QuestWorldParticlePainter(
                particles: _particles,
                camX: _cameraX,
                camY: _cameraY,
              ),
            ),
          ),

          // 3. TOP REALM HUD
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopRealmHud(),
          ),

          // 4. VIRTUAL JOYSTICK (BOTTOM-LEFT)
          Positioned(
            bottom: 30,
            left: 24,
            child: _buildVirtualJoystick(),
          ),

          // 5. ACTIVE STATION INTERACT PROMPT (BOTTOM-RIGHT)
          if (_isInsideStationProximity && _proximityStationId != null)
            Positioned(
              bottom: 36,
              right: 24,
              child: _buildStationInteractPrompt(_proximityStationId!),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP HUD
  // ---------------------------------------------------------------------------
  Widget _buildTopRealmHud() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981), width: 1.2),
              ),
              child: Text(
                'DAY ${widget.day} • OPEN QUEST',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _dayData.title.isNotEmpty ? _dayData.title : 'Linguistic Discovery Realm',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
            // Station Progress Indicators
            Row(
              children: [
                _buildStationBadge(1, _station1Completed, '⚡'),
                const SizedBox(width: 4),
                _buildStationBadge(2, _station2Completed, '🎯'),
                const SizedBox(width: 4),
                _buildStationBadge(3, _station3Completed, '🟣'),
              ],
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
      ),
    );
  }

  Widget _buildStationBadge(int id, bool isDone, String emoji) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF10B981) : Colors.white12,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? const Color(0xFFFFD700) : Colors.white24,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(isDone ? '✓' : emoji, style: const TextStyle(fontSize: 10, color: Colors.white)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2D OPEN WORLD CANVAS
  // ---------------------------------------------------------------------------
  Widget _buildOpenWorldCanvas() {
    return ClipRect(
      child: Transform.translate(
        offset: Offset(-_cameraX, -_cameraY),
        child: SizedBox(
          width: _worldWidth,
          height: _worldHeight,
          child: Stack(
            children: [
              // 1. Lush Rolling Terrain Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0C4A6E), // Azure daytime sky top
                      Color(0xFF0369A1), // Sky horizon
                      Color(0xFF065F46), // Green valley foothills
                      Color(0xFF064E3B), // Deep lush meadow terrain
                    ],
                    stops: [0.0, 0.35, 0.55, 1.0],
                  ),
                ),
              ),

              // 2. Rolling hills backdrop
              Positioned(
                top: 400,
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: _WorldHillsPainter(),
                ),
              ),

              // 3. Station 1: Speech Code Matrix (x: 500, y: 650)
              _buildStationPillar(
                id: 1,
                x: 500.0,
                y: 650.0,
                emoji: '⚡',
                title: 'Speech Formula Core',
                accentColor: const Color(0xFFFFD700),
                isCompleted: _station1Completed,
              ),

              // 4. Station 2: Error Hunter Arena (x: 1350, y: 550)
              _buildStationPillar(
                id: 2,
                x: 1350.0,
                y: 550.0,
                emoji: '🎯',
                title: 'Error Hunter Arena',
                accentColor: const Color(0xFFEF4444),
                isCompleted: _station2Completed,
              ),

              // 5. Station 3: Sentence Evolution Gate (x: 2200, y: 680)
              _buildStationPillar(
                id: 3,
                x: 2200.0,
                y: 680.0,
                emoji: '🟣',
                title: 'Sentence Evolution Gate',
                accentColor: const Color(0xFFA855F7),
                isCompleted: _station3Completed,
              ),

              // 6. Player Avatar / Vehicle
              Positioned(
                left: _playerX - 26,
                top: _playerY - 26,
                child: _buildPlayerAvatar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationPillar({
    required int id,
    required double x,
    required double y,
    required String emoji,
    required String title,
    required Color accentColor,
    required bool isCompleted,
  }) {
    return Positioned(
      left: x - 60,
      top: y - 80,
      child: GestureDetector(
        onTap: () => _openActiveStationModal(id),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, _) {
                final scale = 1.0 + (_pulseController.value * 0.08);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? const Color(0xFF10B981) : Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.5),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isCompleted ? '✓' : emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('🏎️', style: TextStyle(fontSize: 26)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // VIRTUAL JOYSTICK
  // ---------------------------------------------------------------------------
  Widget _buildVirtualJoystick() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDraggingJoystick = true;
          _joystickDelta = Offset.zero;
        });
      },
      onPanUpdate: (details) {
        final radius = 45.0;
        final rawOffset = details.localPosition - const Offset(55, 55);
        final dist = rawOffset.distance;
        final clamped = dist > radius ? rawOffset / dist * radius : rawOffset;
        setState(() {
          _joystickDelta = Offset(clamped.dx / radius, clamped.dy / radius);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDraggingJoystick = false;
          _joystickDelta = Offset.zero;
        });
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _joystickDelta * 32.0,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationInteractPrompt(int stationId) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      onPressed: () => _openActiveStationModal(stationId),
      icon: const Icon(Icons.touch_app_rounded, size: 20),
      label: Text(
        'ENTER STATION $stationId ➔',
        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
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
              'LINGUISTIC QUEST CONQUERED!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You mastered Day ${widget.day} speech rules and formulas strictly through open-world gameplay!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Earned: $_score XP',
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

class _WorldHillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF047857).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.4);
    for (double x = 0; x <= size.width; x += 100) {
      final y = size.height * 0.35 + math.sin(x * 0.005) * 60.0;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuestWorldParticlePainter extends CustomPainter {
  final List<QuestWorldParticle> particles;
  final double camX;
  final double camY;

  _QuestWorldParticlePainter({
    required this.particles,
    required this.camX,
    required this.camY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x - camX, p.y - camY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuestWorldParticlePainter oldDelegate) => true;
}
