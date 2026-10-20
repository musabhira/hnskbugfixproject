import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_citadel_attack_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_world_street_page.dart';

/// ⚔️ Dedicated House Attack Page (Step 8/9 across Days 1 to 90)
///
/// Built according to User Audio Directives:
/// 1. Attack Step available from Day 1 onwards.
/// 2. Target Matchmaking: Pairs beginner with a higher-level house (Lvl 12-15+ for Day 1-3).
///    Checks Supabase for real human houses, falls back to dynamic AI Robot Defender.
/// 3. Profile Presentation: Displays target's Name, Avatar, House Level, Shield status, and House Visual.
/// 4. Top Prominent Shuffle Button: "🎲 SHUFFLE TARGET" to re-roll and view different opponents.
/// 5. 24-Hour Presidential Protection: Target is protected for 24 hours after an attack and cannot be attacked again.
/// 6. Beginner Safeguard (Levels 1 to 20): Even if questions are not answered 100% correctly,
///    attempting the attack successfully passes the step and awards Pocket Score ("അറ്റാക്ക് ചെയ്യാൻ ശ്രമിച്ചല്ലോ...").
class PocketHouseAttackPage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketHouseAttackPage({
    super.key,
    required this.day,
    this.stepIndex = 11,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 11,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketHouseAttackPage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketHouseAttackPage> createState() => _PocketHouseAttackPageState();
}

class _PocketHouseAttackPageState extends State<PocketHouseAttackPage>
    with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final FlutterTts _tts = FlutterTts();

  PocketNeighbor? _target;
  bool _inChatIntro = true;
  int _chatState = 0;
  bool _isLoadingTarget = true;
  bool _isTargetProtected = false;
  int _protectionMinutesLeft = 0;

  List<HouseShieldQuestion> _battleQuestions = [];
  int _currentQIdx = 0;
  int? _selectedOption;
  final bool _inBattle = false;
  bool _battleCompleted = false;
  bool _isVictory = false;
  int _correctAnswers = 0;
  int _scoreEarned = 0;

  String _userName = 'Learner';
  bool _soundEnabled = true;

  late AnimationController _pulseController;
  late AnimationController _shieldAnimController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shieldAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _initAudioAndTts();
    _loadUserName();
    _fetchTargetOpponent();
  }

  Future<void> _initAudioAndTts() async {
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
    } catch (_) {
      try {
        await _tts.setLanguage('en-IN');
        await _tts.setSpeechRate(0.46);
        await _tts.setPitch(1.08);
      } catch (_) {}
    }
    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (_) {}
  }

  Future<void> _loadUserName() async {
    try {
      final uid = widget.userId ?? _supabase.auth.currentUser?.id;
      if (uid != null) {
        final profile = await _supabase
            .from('profile')
            .select('first_name, name')
            .eq('user_id', uid)
            .maybeSingle();
        if (profile != null && mounted) {
          setState(() {
            _userName = profile['first_name'] ?? profile['name'] ?? 'Learner';
          });
        }
      }
    } catch (_) {}
    if (_soundEnabled) {
      _speak(
        'Hi $_userName! We are going to attack a rival house now! Here we don\'t attack with weapons, we attack with English power! Are you ready?',
      );
    }
  }

  Future<void> _fetchTargetOpponent() async {
    setState(() => _isLoadingTarget = true);
    try {
      final neighbor = await PocketFortressDefenseService.getRecommendedRivalTarget(
        userDay: widget.day,
      );

      final isProtected = await PocketFortressDefenseService.isUnderPresidentialProtection(neighbor.id);
      final minutesLeft = isProtected
          ? await PocketFortressDefenseService.getPresidentialProtectionMinutesRemaining(neighbor.id)
          : 0;

      // Load battle defense questions for this target
      final questions = await PocketFortressDefenseService.loadGauntletQuestionsForStage(
        neighbor.day,
        isNeighbor: true,
      );

      // If attacking a robot (fallback), question count equals robot level (day)
      final count = neighbor.isPocketRobo
          ? math.min(neighbor.day, questions.length)
          : math.min(5, math.max(3, questions.length));
      final selectedQuestions = questions.take(count).toList();

      if (mounted) {
        setState(() {
          _target = neighbor;
          _isTargetProtected = isProtected;
          _protectionMinutesLeft = minutesLeft;
          _battleQuestions = selectedQuestions;
          _isLoadingTarget = false;
        });

        // Announce target via voice
        if (_soundEnabled) {
          _speak(
            'Target matched! House ${neighbor.day}: ${neighbor.name}. Are you ready to attack?',
          );
        }
      }
    } catch (e) {
      // Fallback AI Robot
      final targetLvl = math.max(12, widget.day + 11);
      final fallbackRobo = PocketNeighbor(
        id: 'pocket_robo_$targetLvl',
        name: 'CyberGuardian Lvl $targetLvl',
        day: targetLvl,
        streak: targetLvl,
        rank: 'Bastion Defender',
        paletteId: 'stone_castle',
        isMe: false,
        hasActiveShield: true,
        statusMessage: 'Fortified Citadel Lvl $targetLvl',
        isPocketRobo: true,
        hp: 100,
        maxHp: 100,
      );

      final questions = await PocketFortressDefenseService.loadGauntletQuestionsForStage(
        targetLvl,
        isNeighbor: true,
      );

      if (mounted) {
        setState(() {
          _target = fallbackRobo;
          _isTargetProtected = false;
          _protectionMinutesLeft = 0;
          _battleQuestions = questions.take(math.min(targetLvl, questions.length)).toList();
          _isLoadingTarget = false;
        });
      }
    }
  }

  void _onUserRepliesAttack() {
    HapticFeedback.mediumImpact();
    setState(() {
      _chatState = 1;
    });
    if (_soundEnabled) {
      _speak('Awesome, $_userName! Click the button below to launch the attack!');
    }
  }

  Future<void> _launchDirectAttack() async {
    HapticFeedback.heavyImpact();
    if (_target == null) {
      await _fetchTargetOpponent();
    }
    final target = _target;
    if (target == null) return;
    if (!mounted) return;

    // Navigate DIRECTLY to that target's Attack Profile (PocketCitadelAttackPage)!
    // Audio Directive: "ഈ അറ്റാക്ക് പ്രൊഫൈൽ ഇല്ലേ, അതിലേക്ക് പോവണം ട്ടോ. അതിൽ പോയിട്ട് അറ്റാക്ക് ചെയ്യുക."
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PocketCitadelAttackPage(
          neighbor: target,
          attackerDay: widget.day,
        ),
      ),
    );

    // If passed or beginner courage pass (Level <= 20)
    if (result == true || widget.day <= 20) {
      final uid = widget.userId ?? _supabase.auth.currentUser?.id;
      if (uid != null && uid.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pocket_day_${uid}_${widget.day}_step_${widget.stepIndex}_done', true);
      }
      widget.onStepFinished?.call(widget.stepIndex);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        setState(() {
          _inChatIntro = false;
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    if (!_soundEnabled || text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _speakQuestion() {
    if (_currentQIdx < _battleQuestions.length) {
      final q = _battleQuestions[_currentQIdx];
      _speak(q.question);
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedOption == null) return;
    HapticFeedback.selectionClick();

    final q = _battleQuestions[_currentQIdx];
    final isCorrect = _selectedOption == q.correctIndex;
    if (isCorrect) {
      _correctAnswers++;
      SystemSound.play(SystemSoundType.click);
    } else {
      HapticFeedback.heavyImpact();
    }

    if (_currentQIdx + 1 < _battleQuestions.length) {
      setState(() {
        _currentQIdx++;
        _selectedOption = null;
      });
      _speakQuestion();
    } else {
      // Completed all questions!
      await _resolveBattle();
    }
  }

  Future<void> _resolveBattle() async {
    final target = _target;
    if (target == null) return;

    final isFullVictory = _correctAnswers == _battleQuestions.length;
    // User Audio Directive: Beginners up to level 20 pass even if they make mistakes, because they tried!
    final isBeginnerPass = widget.day <= 20;
    final isPass = isFullVictory || isBeginnerPass;

    final score = isFullVictory ? 100 : (isBeginnerPass ? 60 : 20);

    // Place target house under 24-hour Presidential Protection (Humans only)!
    // "പ്രസിഡൻഷ്യൽ പ്രൊട്ടക്ഷൻ 24 മണിക്കൂറാണ് ഒരു യൂസർക്ക്... അതേ യൂസറെ രണ്ടാമത് അറ്റാക്ക് ചെയ്യാൻ പറ്റില്ല 24 മണിക്കൂർ കഴിയാതെ... പക്ഷെ റോബോട്ടുകൾക്ക് പ്രസിഡൻഷ്യൽ പ്രൊട്ടക്ഷൻ ഇല്ല"
    await PocketFortressDefenseService.placeUnderPresidentialProtection(
      target.id,
      hours: 24,
    );

    // If human target, deduct defender home HP & mark damaged in Supabase
    if (target.isPocketRobo != true && !target.id.startsWith('pocket_robo') && !target.id.startsWith('kid_bot_')) {
      try {
        final currentHp = target.hp;
        final newHp = math.max(0, currentHp - 40);
        await _supabase.from('pocket_homes').update({
          'hp': newHp,
          'is_damaged': true,
          'last_attacked_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', target.id);
      } catch (_) {}
    }

    // Award score points
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid != null) {
      await PocketFortressDefenseService.recordTrainingPoints(score, uid);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pocket_day_${uid}_${widget.day}_step_attack_done', true);
    }

    HapticFeedback.heavyImpact();

    if (mounted) {
      setState(() {
        _battleCompleted = true;
        _isVictory = isPass;
        _scoreEarned = score;
      });

      if (isFullVictory) {
        _speak('Brilliant victory! You breached House ${target.day}\'s defenses and earned $score Pocket Score!');
      } else {
        _speak('Brave raid, $_userName! You attacked House ${target.day} and earned $score Pocket Score!');
      }
    }
  }

  Future<void> _finishAndExit() async {
    HapticFeedback.mediumImpact();
    final uid = widget.userId ?? _supabase.auth.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pocket_day_${uid}_${widget.day}_step_${widget.stepIndex}_done', true);
    }
    widget.onStepFinished?.call(widget.stepIndex);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shieldAnimController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoadingTarget
                  ? _buildLoadingState()
                  : (_battleCompleted
                      ? _buildResolutionView()
                      : (_inChatIntro
                          ? _buildChatIntroView()
                          : (_inBattle ? _buildBattleView() : _buildTargetOverview()))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _tts.stop();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),

          // Attack Emblem
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFF9F1239)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text('⚔️', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Step ${widget.stepIndex}: House Attack ⚔️',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  _inChatIntro
                      ? 'CyberCat 🐱 • Mission Briefing'
                      : (_target != null
                          ? 'House #${_target!.day} • ${_target!.name}'
                          : 'Target Matched'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFDA4AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Sound Toggle (No shuffle button as commanded: direct attack!)
          IconButton(
            onPressed: () {
              setState(() => _soundEnabled = !_soundEnabled);
              if (!_soundEnabled) _tts.stop();
            },
            icon: Icon(
              _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _soundEnabled ? const Color(0xFFF43F5E) : Colors.white38,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 WhatsApp-Style Conversational Avatar Chat Entry (User Audio Directive)
  Widget _buildChatIntroView() {
    return Container(
      color: const Color(0xFF0B1120),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // 1. CyberCat Greeting Bubble
                _buildCyberCatMessageBubble(
                  textEn:
                      'Hi $_userName! We are going to attack a rival house now! Here we don\'t attack with weapons, we attack with ENGLISH power! Are you ready?',
                  textMl:
                      'ഹായ് $_userName! നമ്മൾ ഇപ്പോൾ ഒരു വീടിനെ അറ്റാക്ക് ചെയ്യാൻ പോവുകയാണ്! ഇവിടെ നമ്മൾ അറ്റാക്ക് ചെയ്യുന്നത് തോക്കുകൊണ്ടോ വാളുകൊണ്ടോ അല്ല, നമ്മുടെ ഇംഗ്ലീഷ് കൊണ്ടാണ്! Are you ready?',
                  child: _chatState == 0
                      ? Column(
                          children: [
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white24, height: 1),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _onUserRepliesAttack,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('⚔️', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Attack! ⚔️',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),

                // 2. User Response Bubble (if _chatState >= 1)
                if (_chatState >= 1) ...[
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'Attack! ⚔️',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // 3. CyberCat Reply & Direct Launch Button
                  const SizedBox(height: 18),
                  _buildCyberCatMessageBubble(
                    textEn: 'Awesome! Click this button to launch the attack!',
                    textMl: 'ഗംഭീരം! ഈ ബട്ടണിൽ ക്ലിക്ക് ചെയ്ത് അറ്റാക്ക് തുടങ്ങൂ!',
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + (_pulseController.value * 0.035);
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: InkWell(
                            onTap: _launchDirectAttack,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.flash_on_rounded, color: Color(0xFFFFD700), size: 24),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Please Click This ➔ Launch Attack ⚔️',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14.5,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ഇതിൽ ക്ലിക്ക് ചെയ്ത് അറ്റാക്ക് ചെയ്യുക ➔',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberCatMessageBubble({
    required String textEn,
    required String textMl,
    Widget? child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: Text('🐱', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CyberCat 🐱',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _speak(textEn),
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  textEn,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  textMl,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                if (child != null) child,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: Color(0xFFF43F5E),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scouting Rival Citadel Targets...',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Matching with House 12–15+ Fortresses for thrilling English challenge',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 🏰 Defender Profile & House View (User Audio Directive: Name, Avatar, House Level, Status)
  Widget _buildTargetOverview() {
    final target = _target;
    if (target == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Mission Alert Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RIVAL HOUSE DETECTED!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFDA4AF),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Attack House #${target.day} to crack their English defense shields and loot Pocket Score!',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Target Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111827), Color(0xFF1F2937)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar + Rank
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                        ),
                        border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          target.isPocketRobo ? '🤖' : '🛡️',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  target.name,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (target.isPocketRobo) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'AI DEFENDER',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Level ${target.day} Fortress • ${target.rank}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '"${target.statusMessage}"',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Shield Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCol('🛡️ DEFENSE SHIELDS', '${_battleQuestions.length} Armed', const Color(0xFF38BDF8)),
                    _buildMetricCol('⚔️ HOUSE STAGE', 'House #${target.day}', const Color(0xFFF43F5E)),
                    _buildMetricCol('🪙 BOUNTY', '+100 PS', const Color(0xFFFFD700)),
                  ],
                ),

                const SizedBox(height: 14),

                // 24-Hour Presidential Protection Alert if Active
                if (_isTargetProtected) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C2D12).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF97316)),
                    ),
                    child: Row(
                      children: [
                        const Text('👮‍♂️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRESIDENTIAL POLICE PROTECTION ACTIVE',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFDBA74),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                              Text(
                                'This house was recently raided. Protected for another ${(_protectionMinutesLeft / 60).toStringAsFixed(1)} hours. Shuffle for an active target!',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. CyberCat Briefing
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                    ),
                  ),
                  child: const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CyberCat Commander',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF34D399),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$_userName, cracking this citadel requires speaking and answering ${_battleQuestions.length} English defense traps. Break them down to earn your Pocket Score!',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Action Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: _launchDirectAttack,
              icon: const Icon(Icons.flash_on_rounded, size: 22),
              label: Text(
                'ATTACK HOUSE #${target.day} GATES ⚔️',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Secondary option: Launch full 3D canvas siege
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _launchDirectAttack,
              icon: const Icon(Icons.castle_rounded, color: Color(0xFF38BDF8), size: 18),
              label: Text(
                'Open Full Attack Profile & Citadel Siege ➔',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String title, String val, Color col) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.outfit(color: col, fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }

  /// 🛡️ Active Battle View: Question & Answering Phase
  Widget _buildBattleView() {
    if (_battleQuestions.isEmpty) {
      return const Center(child: Text('No defense questions found.', style: TextStyle(color: Colors.white)));
    }

    final q = _battleQuestions[_currentQIdx];
    final progress = (_currentQIdx + 1) / _battleQuestions.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SHIELD BREACH ${_currentQIdx + 1} OF ${_battleQuestions.length}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF43F5E),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Cracked',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF43F5E)),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 18),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q.trapType.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _speakQuestion,
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 22),
                      tooltip: 'Listen to Question',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  q.question,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options A, B, C, D
          Text(
            'SELECT THE CODEWORD TO BREACH SHIELD:',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          ...List.generate(q.options.length, (idx) {
            final isSelected = _selectedOption == idx;
            const letters = ['A', 'B', 'C', 'D'];
            final letter = idx < letters.length ? letters[idx] : '${idx + 1}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedOption = idx);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF43F5E).withValues(alpha: 0.2)
                        : const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF43F5E)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFFF43F5E) : Colors.white12,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[idx],
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFFF43F5E), size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedOption == null ? Colors.white12 : const Color(0xFF10B981),
                foregroundColor: _selectedOption == null ? Colors.white38 : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _selectedOption == null ? null : _submitAnswer,
              child: Text(
                _currentQIdx + 1 < _battleQuestions.length
                    ? 'VERIFY SHIELD BREACH CODE ➔'
                    : 'FINAL BREACH STRIKE ⚡',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🏆 Resolution & Rewards View (Beginner Pass Guaranteed!)
  Widget _buildResolutionView() {
    final target = _target;
    final isFullWin = _isVictory && _correctAnswers == _battleQuestions.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Trophy / Shield Icon
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isFullWin
                    ? [const Color(0xFFFFD700), const Color(0xFFB45309)]
                    : [const Color(0xFF10B981), const Color(0xFF047857)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isFullWin ? const Color(0xFFFFD700) : const Color(0xFF10B981)).withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(isFullWin ? '🏆' : '🛡️', style: const TextStyle(fontSize: 44)),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isFullWin ? 'CITADEL BREACHED!' : 'ATTACK MISSION COMPLETED!',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Audio Directive: Beginners up to level 20 pass because they attempted the raid!
          Text(
            isFullWin
                ? 'Outstanding accuracy! You cracked every single defense shield on House #${target?.day}.'
                : 'Great bravery, $_userName! You launched a daring raid against House #${target?.day}. By challenging tougher houses, your spoken fluency grows rapidly. Step Passed! ✓',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Reward Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+$_scoreEarned POCKET SCORE',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Combat Valor Reward Credited',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 24-Hour Presidential Protection Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Text('👮‍♂️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'House #${target?.day} is now placed under 24-Hour Presidential Police Protection and cannot be attacked again until tomorrow.',
                    style: GoogleFonts.inter(color: const Color(0xFFBAE6FD), fontSize: 11, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Finish Step Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: _finishAndExit,
              icon: const Icon(Icons.check_circle_rounded, size: 22),
              label: Text(
                'CLAIM REWARD & FINISH STEP ➔',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
