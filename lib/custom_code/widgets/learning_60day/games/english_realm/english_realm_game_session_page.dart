import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_language_selection_dialog.dart';
import 'english_realm_localization_service.dart';
import 'english_realm_models.dart';
import 'english_realm_progress_service.dart';

/// 🎮 Full-screen Interactive Playable Game Session for all 180 English Realm Games
class EnglishRealmGameSessionPage extends StatefulWidget {
  final RealmGameSpec spec;
  final VoidCallback? onCompleted;

  const EnglishRealmGameSessionPage({
    super.key,
    required this.spec,
    this.onCompleted,
  });

  static Future<void> launch(
    BuildContext context, {
    required RealmGameSpec spec,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnglishRealmGameSessionPage(
          spec: spec,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<EnglishRealmGameSessionPage> createState() =>
      _EnglishRealmGameSessionPageState();
}

class _EnglishRealmGameSessionPageState
    extends State<EnglishRealmGameSessionPage>
    with TickerProviderStateMixin {
  late final FlutterTts _tts;
  int _currentRoundIndex = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _lives = 3;
  int? _selectedAnswerIndex;
  bool _answered = false;
  bool _isAnswerCorrect = false;
  bool _isGameFinished = false;

  // Arena Battle specific state
  double _bossHealth = 1.0;
  double _playerHealth = 1.0;

  // Sentence Builder tile assembly
  final List<String> _assembledTiles = [];

  late AnimationController _feedbackAnim;
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initTts();

    _feedbackAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    PocketLanguageService.activeLanguageNotifier.addListener(_onLanguageChanged);
    _speakCurrentRound();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  void _speakCurrentRound() {
    final round = _currentRound;
    if (round.audioVoiceText != null && round.audioVoiceText!.isNotEmpty) {
      _speak(round.audioVoiceText!);
    } else {
      _speak(round.promptEn);
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    PocketLanguageService.activeLanguageNotifier.removeListener(_onLanguageChanged);
    _tts.stop();
    _feedbackAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  RealmChallengeRound get _currentRound =>
      widget.spec.rounds[_currentRoundIndex.clamp(0, widget.spec.rounds.length - 1)];

  void _onOptionSelected(int index) {
    if (_answered || _isGameFinished) return;

    final round = _currentRound;
    final isCorrect = round.isCorrectAnswer(index);

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
      _isAnswerCorrect = isCorrect;

      if (isCorrect) {
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;
        final bonus = _combo * 20;
        _score += (100 + bonus);
        _bossHealth = (_bossHealth - 0.22).clamp(0.0, 1.0);
        _feedbackAnim.forward(from: 0.0);
      } else {
        _combo = 0;
        _lives = (_lives - 1).clamp(0, 3);
        _playerHealth = (_playerHealth - 0.34).clamp(0.0, 1.0);
      }
    });

    if (isCorrect) {
      _speak(round.options[index]);
    }
  }

  void _nextRound() {
    if (_currentRoundIndex + 1 < widget.spec.rounds.length) {
      setState(() {
        _currentRoundIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
        _assembledTiles.clear();
      });
      _speakCurrentRound();
    } else {
      _finishGame();
    }
  }

  Future<void> _finishGame() async {
    final stars = _lives == 3 ? 3 : (_lives >= 2 ? 2 : 1);
    final xp = widget.spec.xpReward + (_score ~/ 10);
    final coins = widget.spec.coinReward + (_maxCombo * 2);

    await EnglishRealmProgressService.saveGameResult(
      day: widget.spec.day,
      gameIndex: widget.spec.gameIndex,
      score: _score,
      stars: stars,
      xpEarned: xp,
      coinsEarned: coins,
    );

    widget.onCompleted?.call();

    if (mounted) {
      setState(() {
        _isGameFinished = true;
      });
    }
  }

  void _retryGame() {
    setState(() {
      _currentRoundIndex = 0;
      _score = 0;
      _combo = 0;
      _lives = 3;
      _bossHealth = 1.0;
      _playerHealth = 1.0;
      _selectedAnswerIndex = null;
      _answered = false;
      _isGameFinished = false;
      _assembledTiles.clear();
    });
    _speakCurrentRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: _isGameFinished ? _buildVictoryScreen() : _buildActiveGameScreen(),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ACTIVE GAMEPLAY SCREEN
  // --------------------------------------------------------------------------
  Widget _buildActiveGameScreen() {
    final spec = widget.spec;
    final round = _currentRound;
    final totalRounds = spec.rounds.length;

    return Column(
      children: [
        // Top Game Header HUD
        _buildHeaderHud(spec, totalRounds),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Archetype Game Arena Board
                _buildArchetypeArena(spec),

                const SizedBox(height: 16),

                // Question Prompt Card
                _buildQuestionCard(round, spec),

                const SizedBox(height: 18),

                // Interactive Answer Choices / Mechanics
                ..._buildAnswerOptions(round, spec),

                if (_answered) ...[
                  const SizedBox(height: 16),
                  _buildExplanationBanner(round),
                ],
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        _buildBottomActionBar(),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // TOP HUD
  // --------------------------------------------------------------------------
  Widget _buildHeaderHud(RealmGameSpec spec, int totalRounds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
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
              color: spec.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: spec.accentColor, width: 1.2),
            ),
            child: Text(
              'DAY ${spec.day} • G${spec.gameIndex}',
              style: GoogleFonts.outfit(
                color: spec.accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ROUND ${_currentRoundIndex + 1} OF $totalRounds',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Lives / Hearts
          Row(
            children: List.generate(3, (i) {
              final active = i < _lives;
              return Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Icon(
                  active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: active ? const Color(0xFFEF4444) : Colors.white24,
                  size: 18,
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          // Language Switcher Badge
          GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              await PocketLanguageSelectionDialog.show(
                context,
                currentLanguage: PocketLanguageService.currentLanguage,
              );
              if (mounted) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 3),
                  Text(
                    EnglishRealmLocalizationService.getLanguageBadge(PocketLanguageService.currentLanguage),
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
          const SizedBox(width: 8),
          // Score counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
  // ARCHETYPE ARENA (Game Theme Visuals)
  // --------------------------------------------------------------------------
  Widget _buildArchetypeArena(RealmGameSpec spec) {
    switch (spec.archetype) {
      case GameArchetype.arenaBattle:
        return _buildArenaBattleVisuals(spec);
      case GameArchetype.runnerCollector:
        return _buildRunnerVisuals(spec);
      case GameArchetype.sortingFactory:
        return _buildSortingFactoryVisuals(spec);
      case GameArchetype.gatekeeperDungeon:
        return _buildDungeonGateVisuals(spec);
      case GameArchetype.detectiveInvestigation:
        return _buildDetectiveVisuals(spec);
      case GameArchetype.sentenceBuilder:
        return _buildSentenceBuilderVisuals(spec);
      case GameArchetype.timelineSequencer:
        return _buildTimelineVisuals(spec);
      case GameArchetype.dialogueRpg:
        return _buildDialogueRpgVisuals(spec);
    }
  }

  Widget _buildArenaBattleVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [spec.accentColor.withValues(alpha: 0.25), const Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('YOU (LEVEL 1)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
              Text('GRAMMAR GOLEM 👹', style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _playerHealth,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                    minHeight: 8,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('⚔️', style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _bossHealth,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFEF4444)),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunnerVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🏃💨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLLECTOR SPEEDRUN',
                  style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Text(
                  'Dodge obstacles & catch the valid grammar orb!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_combo > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_combo}x COMBO!',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortingFactoryVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🏭📦', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SORTING CONVEYOR BELT', style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Classify the term into its correct linguistic category.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDungeonGateVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🗝️🚪', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHAMBER GATEKEEPER LOCK', style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Provide the exact grammatical key to unlock the path.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectiveVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🔎📜', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GRAMMAR DETECTIVE CASE', style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Examine clues and eliminate mother-tongue translation traps.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceBuilderVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🧩🧱', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SENTENCE CONSTRUCTOR MATRIX', style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Arrange clauses and blocks into fluent spoken English.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('⌛🚀', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TEMPORAL TIMELINE SEQUENCER', style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Order past, present, and future aspects with zero conflict.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueRpgVisuals(RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: spec.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('☕🗣️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REALM DIALOGUE CAFÉ', style: GoogleFonts.outfit(color: spec.accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Roleplay natural conversational turn-taking with NPCs.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // QUESTION PROMPT CARD
  // --------------------------------------------------------------------------
  Widget _buildQuestionCard(RealmChallengeRound round, RealmGameSpec spec) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  round.promptEn,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 22),
                onPressed: () => _speak(round.audioVoiceText ?? round.promptEn),
              ),
            ],
          ),
          Builder(
            builder: (_) {
              final promptNative = round.getLocalizedPrompt(PocketLanguageService.currentLanguage);
              if (promptNative.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  promptNative,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ANSWER CHOICES
  // --------------------------------------------------------------------------
  List<Widget> _buildAnswerOptions(RealmChallengeRound round, RealmGameSpec spec) {
    final list = <Widget>[];

    for (int i = 0; i < round.options.length; i++) {
      final opt = round.options[i];
      final isSelected = _selectedAnswerIndex == i;
      final isCorrect = round.isCorrectAnswer(i);

      Color borderColor = Colors.white12;
      Color bgColor = const Color(0xFF1A2642);
      Color textColor = Colors.white;

      if (_answered) {
        if (isCorrect) {
          borderColor = const Color(0xFF10B981);
          bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
          textColor = const Color(0xFF34D399);
        } else if (isSelected && !isCorrect) {
          borderColor = const Color(0xFFEF4444);
          bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
          textColor = const Color(0xFFF87171);
        }
      }

      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: _answered ? null : () => _onOptionSelected(i),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: isSelected || (_answered && isCorrect) ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (_isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                          : Colors.white10,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + i),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (_answered && isCorrect)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  if (_answered && isSelected && !isCorrect)
                    const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return list;
  }

  // --------------------------------------------------------------------------
  // EXPLANATION BANNER
  // --------------------------------------------------------------------------
  Widget _buildExplanationBanner(RealmChallengeRound round) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAnswerCorrect
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _isAnswerCorrect
                    ? EnglishRealmLocalizationService.t('correct_banner')
                    : EnglishRealmLocalizationService.t('incorrect_banner'),
                style: GoogleFonts.outfit(
                  color: _isAnswerCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 18),
                onPressed: () => _speak(round.explanationEn),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            round.explanationEn,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          if (!PocketLanguageService.isEnglish) ...[
            const SizedBox(height: 6),
            Text(
              round.getLocalizedExplanation(PocketLanguageService.currentLanguage),
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BOTTOM ACTION BAR
  // --------------------------------------------------------------------------
  Widget _buildBottomActionBar() {
    if (!_answered) return const SizedBox(height: 16);

    final isLast = _currentRoundIndex + 1 >= widget.spec.rounds.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF131D33),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _nextRound,
          icon: Icon(isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded, size: 20),
          label: Text(
            isLast
                ? EnglishRealmLocalizationService.t('complete_round')
                : EnglishRealmLocalizationService.t('next_challenge'),
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // VICTORY & REWARDS SCREEN
  // --------------------------------------------------------------------------
  Widget _buildVictoryScreen() {
    final spec = widget.spec;
    final stars = _lives == 3 ? 3 : (_lives >= 2 ? 2 : 1);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              'VICTORY ACHIEVED!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Day ${spec.day} • ${spec.title}',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 18),
            // Star rating display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final earned = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: earned ? const Color(0xFFFFD700) : Colors.white24,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Stats Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF131D33),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('SCORE', '$_score', const Color(0xFF38BDF8)),
                  _buildStatItem('MAX COMBO', '${_maxCombo}x', const Color(0xFF10B981)),
                  _buildStatItem('XP GAINED', '+${spec.xpReward + (_score ~/ 10)}', const Color(0xFFA855F7)),
                  _buildStatItem('COINS', '+${spec.coinReward + (_maxCombo * 2)}', const Color(0xFFFFD700)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.public_rounded, size: 22),
                label: Text(
                  'RETURN TO ENGLISH REALM 🌍',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _retryGame,
              icon: const Icon(Icons.replay_rounded, color: Colors.white60, size: 18),
              label: Text(
                'Play Again for High Score',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
