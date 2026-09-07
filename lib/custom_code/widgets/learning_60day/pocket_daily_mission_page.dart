import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/english_match/stage_peer_matchmaker.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_defense_trap_modal.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_battle_arena_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mission_timer_service.dart';

/// 📚 Model for Daily 10 Vocabulary Words to Memorize
class DailyVocabItem {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String malayalamMeaning;
  final String exampleSentence;
  final String phonetic;

  const DailyVocabItem({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.malayalamMeaning,
    required this.exampleSentence,
    required this.phonetic,
  });
}

/// 🎯 Comprehensive Interactive Daily English Mission Experience
class PocketDailyMissionPage extends StatefulWidget {
  final int day;
  final VoidCallback? onMissionCompleted;

  const PocketDailyMissionPage({
    super.key,
    required this.day,
    this.onMissionCompleted,
  });

  @override
  State<PocketDailyMissionPage> createState() => _PocketDailyMissionPageState();
}

class _PocketDailyMissionPageState extends State<PocketDailyMissionPage> {
  final FlutterTts _tts = FlutterTts();

  // ⏱️ Shared 60-Minute Daily Practice Timer Service
  final PocketMissionTimerService _timerService = PocketMissionTimerService.instance;

  // Checklist Subtasks Progress
  bool _hubChatVerified = false;
  bool _peerCallVerified = false;
  bool _vocabMemorized = false;
  bool _readingNotesCompleted = false;
  bool _revisionQuizPassed = false;
  bool _defenseTrapArmed = false;
  bool _trialRaidLaunched = false;

  // Quiz state
  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  late final List<DailyVocabItem> _vocabList;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadVocabForDay();
    _timerService.initForDay(widget.day);
    _timerService.addListener(_onTimerStateChanged);
    _loadSavedMissionState();
  }

  void _onTimerStateChanged() {
    if (mounted) setState(() {});
  }

  void _initTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
  }

  void _speakWord(String text) async {
    HapticFeedback.lightImpact();
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerStateChanged);
    super.dispose();
  }

  void _loadVocabForDay() {
    // 10 high-impact vocabulary words for Day 1
    _vocabList = const [
      DailyVocabItem(
        word: 'Ambition',
        partOfSpeech: 'noun',
        definition: 'A strong desire to achieve success or greatness.',
        malayalamMeaning: 'ഉയർന്ന ലക്ഷ്യം / ആഗ്രഹം',
        exampleSentence: 'Her ambition is to speak fluent English with confidence.',
        phonetic: '/æmˈbɪʃ.ən/',
      ),
      DailyVocabItem(
        word: 'Courage',
        partOfSpeech: 'noun',
        definition: 'The ability to do something that frightens you; bravery.',
        malayalamMeaning: 'ധൈര്യം',
        exampleSentence: 'Have the courage to speak without fear of making mistakes.',
        phonetic: '/ˈkʌr.ɪdʒ/',
      ),
      DailyVocabItem(
        word: 'Diligent',
        partOfSpeech: 'adjective',
        definition: 'Showing careful and persistent work and effort.',
        malayalamMeaning: 'കഠിനാധ്വാനം ചെയ്യുന്ന / ശ്രദ്ധാലുവായ',
        exampleSentence: 'A diligent student practices English every single day.',
        phonetic: '/ˈdɪl.ə.dʒənt/',
      ),
      DailyVocabItem(
        word: 'Express',
        partOfSpeech: 'verb',
        definition: 'To convey feelings, thoughts, or ideas in words.',
        malayalamMeaning: 'വ്യക്തമാക്കുക / പ്രകടിപ്പിക്കുക',
        exampleSentence: 'Reading books will help you express your thoughts easily.',
        phonetic: '/ɪkˈspres/',
      ),
      DailyVocabItem(
        word: 'Fluency',
        partOfSpeech: 'noun',
        definition: 'The ability to speak or write a language easily and accurately.',
        malayalamMeaning: 'സരളത / അനായാസമായ സംസാരം',
        exampleSentence: 'Consistency across 90 days creates unstoppable fluency.',
        phonetic: '/ˈfluː.ən.si/',
      ),
      DailyVocabItem(
        word: 'Grateful',
        partOfSpeech: 'adjective',
        definition: 'Feeling or showing appreciation for kindness received.',
        malayalamMeaning: 'നന്ദിയുള്ള',
        exampleSentence: 'I am grateful for every mate who helps me practice speaking.',
        phonetic: '/ˈɡreɪt.fəl/',
      ),
      DailyVocabItem(
        word: 'Hesitate',
        partOfSpeech: 'verb',
        definition: 'To pause before saying or doing something through uncertainty.',
        malayalamMeaning: 'മടിക്കുക / സംശയിച്ചു നിൽക്കുക',
        exampleSentence: 'Do not hesitate when speaking; just let the words flow.',
        phonetic: '/ˈhez.ə.teɪt/',
      ),
      DailyVocabItem(
        word: 'Inspire',
        partOfSpeech: 'verb',
        definition: 'To fill someone with the urge or ability to do something.',
        malayalamMeaning: 'പ്രചോദിപ്പിക്കുക',
        exampleSentence: 'Great communicators inspire people around the world.',
        phonetic: '/ɪnˈspaɪər/',
      ),
      DailyVocabItem(
        word: 'Journey',
        partOfSpeech: 'noun',
        definition: 'An act of traveling from one place or milestone to another.',
        malayalamMeaning: 'യാത്ര / ഘട്ടം',
        exampleSentence: 'Your transformative 90-day English journey begins today.',
        phonetic: '/ˈdʒɜː.ni/',
      ),
      DailyVocabItem(
        word: 'Knowledge',
        partOfSpeech: 'noun',
        definition: 'Facts, information, and skills acquired through experience.',
        malayalamMeaning: 'അറിവ്',
        exampleSentence: 'Knowledge is gained by learning, and fluency by speaking.',
        phonetic: '/ˈnɒl.ɪdʒ/',
      ),
    ];
  }

  Future<void> _loadSavedMissionState() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    setState(() {
      _hubChatVerified = prefs.getBool('${dayKey}_hub_chat') ?? false;
      _peerCallVerified = prefs.getBool('${dayKey}_peer_call') ?? false;
      _vocabMemorized = prefs.getBool('${dayKey}_vocab_mem') ?? false;
      _readingNotesCompleted = prefs.getBool('${dayKey}_reading') ?? false;
      _revisionQuizPassed = prefs.getBool('${dayKey}_quiz') ?? false;
      _defenseTrapArmed = prefs.getBool('${dayKey}_defense') ?? false;
      _trialRaidLaunched = prefs.getBool('${dayKey}_raid') ?? false;
    });
  }

  Future<void> _saveSubtask(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    await prefs.setBool('${dayKey}_$key', value);
  }

  int get _completedSubtasksCount {
    int count = 0;
    if (_hubChatVerified) count++;
    if (_peerCallVerified) count++;
    if (_vocabMemorized) count++;
    if (_readingNotesCompleted) count++;
    if (_revisionQuizPassed) count++;
    if (_defenseTrapArmed) count++;
    if (_trialRaidLaunched) count++;
    return count;
  }

  bool get _isAllCompleted => _completedSubtasksCount >= 7;
  bool get _isTimerCompleted => _timerService.hasReachedTarget;
  bool get _canClaimAndAdvance => _isTimerCompleted && _isAllCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // Subtle dark vignette background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF070B14)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Deck
                _buildHeader(context),

                // Mission Body Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    children: [
                      // ⏱️ 60-Min Daily Practice Study Timer Card
                      _buildDailyStudyTimerCard(),

                      const SizedBox(height: 18),

                      // 📋 Mission Subtasks Tracker Header
                      _buildMissionProgressCard(),

                      const SizedBox(height: 18),

                      // Subtask 1: 💬 English Hub Group Practice
                      _buildSubtaskCard(
                        stepNumber: '1',
                        icon: '💬',
                        title: 'English Hub Group Practice',
                        description: 'Enter the active English Hub and send at least 3 English messages to fellow learners.',
                        isVerified: _hubChatVerified,
                        actionLabel: 'OPEN ENGLISH HUB CHAT',
                        actionColor: const Color(0xFFFFFC00),
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WhatsAppGroupChat(
                                groupId: 'english_hub',
                                groupName: 'English Hub',
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _hubChatVerified = true);
                              _saveSubtask('hub_chat', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _hubChatVerified = true);
                          _saveSubtask('hub_chat', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 2: 🎙️ Anonymous Peer Talk / Call
                      _buildSubtaskCard(
                        stepNumber: '2',
                        icon: '🎙️',
                        title: 'Peer Call / 1-on-1 English Talk',
                        description: 'Connect with 2 mates for live conversation practice to conquer speaking hesitation.',
                        isVerified: _peerCallVerified,
                        actionLabel: 'FIND 1-ON-1 PEERS',
                        actionColor: const Color(0xFF00E5FF),
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StagePeerMatchmakerPage(),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _peerCallVerified = true);
                              _saveSubtask('peer_call', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _peerCallVerified = true);
                          _saveSubtask('peer_call', true);
                          HapticFeedback.lightImpact();
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 3: 🧠 10 Vocabulary Words to Memorize
                      _buildVocabDeckCard(),

                      const SizedBox(height: 14),

                      // Subtask 4: 📖 Core Notes & Reading Passage
                      _buildReadingNotesCard(),

                      const SizedBox(height: 14),

                      // Subtask 5: ✍️ Quick Revision Mini-Quiz
                      _buildRevisionQuizCard(),

                      const SizedBox(height: 14),

                      // Subtask 6: 🛡️ Craft Citadel Defense Trap
                      _buildSubtaskCard(
                        stepNumber: '6',
                        icon: '🛡️',
                        title: 'Craft Day 1 Citadel Defense Trap',
                        description: 'Arm your front gate with an authentic English challenge to defend your house from raiders.',
                        isVerified: _defenseTrapArmed,
                        actionLabel: 'CRAFT DEFENSE TRAP',
                        actionColor: const Color(0xFF8B5CF6),
                        onAction: () {
                          PocketDefenseTrapModal.show(context, widget.day);
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                        },
                        onVerify: () {
                          setState(() => _defenseTrapArmed = true);
                          _saveSubtask('defense', true);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Subtask 7: ⚔️ Launch First Trial Raid
                      _buildSubtaskCard(
                        stepNumber: '7',
                        icon: '⚔️',
                        title: 'First Trial Siege Attack (Level 5 House)',
                        description: 'Launch your first raid against a Level 5 Neighbor Citadel in the Battle Arena to test your combat English!',
                        isVerified: _trialRaidLaunched,
                        actionLabel: 'LAUNCH BATTLE ARENA RAID',
                        actionColor: const Color(0xFFEF4444),
                        onAction: () {
                          final rival = PocketNeighbor(
                            id: 'trial_citadel_lvl5',
                            name: 'Shadow Sentinel Lvl 5',
                            day: 5,
                            streak: 8,
                            rank: 'Rival Fortress',
                            paletteId: 'regal_amethyst',
                            statusMessage: 'Can you breach my English gates?',
                            hasActiveShield: true,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PocketBattleArenaPage(
                                neighbor: rival,
                                userDay: widget.day,
                                userStreak: 1,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() => _trialRaidLaunched = true);
                              _saveSubtask('raid', true);
                            }
                          });
                        },
                        onVerify: () {
                          setState(() => _trialRaidLaunched = true);
                          _saveSubtask('raid', true);
                        },
                      ),

                      const SizedBox(height: 24),

                      // 🏆 Final Mission Completion Button
                      _buildFinalClaimButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TOP APP BAR HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DAY ${widget.day}',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'ENGLISH LEARNING MISSION',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Stage ${widget.day}/90 • Foundation & First Steps',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$_completedSubtasksCount/7 Done',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFC00),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ⏱️ 60-MINUTE PRACTICE TIMER CARD ---
  Widget _buildDailyStudyTimerCard() {
    final isRunning = _timerService.isRunning;
    final isTargetMet = _timerService.hasReachedTarget;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRunning
              ? const Color(0xFFFFD700)
              : (isTargetMet ? const Color(0xFF10B981) : Colors.white12),
          width: (isRunning || isTargetMet) ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isRunning)
            BoxShadow(
              color: const Color(0xFFFF8906).withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          if (isTargetMet)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'DAILY 60-MIN PRACTICE TIMER',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isRunning
                      ? Colors.green.withValues(alpha: 0.2)
                      : (isTargetMet
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : Colors.white10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isRunning
                      ? 'ACTIVE'
                      : (isTargetMet
                          ? 'TARGET MET'
                          : _timerService.pauseReason.toUpperCase()),
                  style: TextStyle(
                    color: isRunning
                        ? Colors.greenAccent
                        : (isTargetMet ? const Color(0xFF10B981) : Colors.white54),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rule: Spend 60+ mins practicing English daily (chat, voice calls, drills). Pauses when leaving app.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _timerService.formatTime(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/ ${_timerService.formatTime(_timerService.targetSeconds)} Target',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _timerService.progress,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isTargetMet
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFFC00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (isTargetMet) {
                    _timerService.addAnotherHourPractice();
                  } else {
                    _timerService.toggleTimer();
                  }
                },
                icon: Icon(
                  isRunning
                      ? Icons.pause_rounded
                      : (isTargetMet ? Icons.add_alarm_rounded : Icons.play_arrow_rounded),
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(
                  isRunning
                      ? 'PAUSE'
                      : (isTargetMet ? '+60m' : 'START'),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning
                      ? Colors.amberAccent
                      : (isTargetMet ? const Color(0xFF10B981) : const Color(0xFFFFFC00)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          // ⚠️ Extra Hour Prompt Banner when 60 minutes are met but subtasks remain
          if (isTargetMet && !_isAllCompleted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '60-Min Target Reached! (${7 - _completedSubtasksCount} subtasks pending)',
                          style: GoogleFonts.outfit(
                            color: Colors.amberAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice timer automatically stopped at 60:00. You must complete all 7 subtasks to advance to Day ${widget.day + 1}. Complete the tasks below, or add an extra 1-hour practice session.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _timerService.addAnotherHourPractice();
                          },
                          icon: const Icon(Icons.add_alarm_rounded, size: 16, color: Color(0xFFFFFC00)),
                          label: Text(
                            '+ ADD 1-HR PRACTICE',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFFC00),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFFC00)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _timerService.restartPracticeSession();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                          label: Text(
                            'RESTART 1-HR RUN',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 📋 OVERALL MISSION PROGRESS CARD ---
  Widget _buildMissionProgressCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141A29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎯', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${widget.day} Subtask Checklist',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete all 7 actions below to claim Day ${widget.day} rewards & badge.',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${((_completedSubtasksCount / 7) * 100).toInt()}%',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFFC00),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // --- GENERIC SUBTASK CARD ---
  Widget _buildSubtaskCard({
    required String stepNumber,
    required String icon,
    required String title,
    required String description,
    required bool isVerified,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
    required VoidCallback onVerify,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFF10B981) : Colors.white12,
          width: isVerified ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STEP $stepNumber',
                  style: TextStyle(
                    color: isVerified ? Colors.black : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text('VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: actionColor,
                    side: BorderSide(color: actionColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    actionLabel,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onVerify,
                icon: Icon(isVerified ? Icons.check_rounded : Icons.done_all_rounded, color: Colors.black, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: isVerified ? const Color(0xFF10B981) : Colors.white24,
                ),
                tooltip: 'Mark Complete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 3: 🧠 10 VOCABULARY WORDS TO MEMORIZE CARD ---
  Widget _buildVocabDeckCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFF8906).withValues(alpha: 0.5),
          width: _vocabMemorized ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFF8906),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('STEP 3', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('🧠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '10 Core Vocabulary Words to Memorize',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_vocabMemorized)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Memorize all 10 words below (definitions, Malayalam meanings & pronunciation):',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vocabList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final v = _vocabList[idx];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${idx + 1}', style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                v.word,
                                style: GoogleFonts.outfit(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                v.phonetic,
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${v.partOfSpeech})',
                                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📖 ${v.definition}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '🗣️ അർത്ഥം: ${v.malayalamMeaning}',
                            style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '💡 "${v.exampleSentence}"',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFFC00), size: 20),
                      onPressed: () => _speakWord('${v.word}. ${v.exampleSentence}'),
                      tooltip: 'Pronounce',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _vocabMemorized = true);
                _saveSubtask('vocab_mem', true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 10 Vocabulary Words memorized and recorded!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: Icon(_vocabMemorized ? Icons.check_circle_rounded : Icons.star_rounded, color: Colors.black),
              label: Text(
                _vocabMemorized ? '10 WORDS MEMORIZED ✓' : 'I MEMORIZED ALL 10 WORDS',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _vocabMemorized ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 4: 📖 CORE NOTES & READING PASSAGE CARD ---
  Widget _buildReadingNotesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _readingNotesCompleted ? const Color(0xFF10B981) : Colors.white12,
          width: _readingNotesCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _readingNotesCompleted ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('STEP 4', style: TextStyle(color: _readingNotesCompleted ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('📖', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Core Grammar Notes & Reading Passage',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_readingNotesCompleted)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📚 Rule 1: English Sentence Structure (S + V + O)',
                  style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'English sentences follow the order: Subject (who) + Verb (action) + Object (what).\n• Correct: "She reads books."\n• In Malayalam: "അവൾ പുസ്തകം വായിക്കുന്നു" (Subject + Object + Verb). Remember to place the action verb BEFORE the object in English!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const Divider(color: Colors.white12, height: 16),
                Text(
                  '🗣️ Aloud Reading Exercise:',
                  style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Every great journey begins with a single confident step. By practicing 60 minutes each day, I transform my communication and unlock endless opportunities across the globe."',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontStyle: FontStyle.italic, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => _readingNotesCompleted = true);
                _saveSubtask('reading', true);
                HapticFeedback.lightImpact();
              },
              icon: Icon(_readingNotesCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded, color: const Color(0xFFFFFC00)),
              label: Text(
                _readingNotesCompleted ? 'NOTES & PASSAGE READ ✓' : 'I FINISHED READING ALOUD',
                style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFFC00)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBTASK 5: ✍️ QUICK REVISION MINI-QUIZ CARD ---
  Widget _buildRevisionQuizCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _revisionQuizPassed ? const Color(0xFF10B981) : Colors.white12,
          width: _revisionQuizPassed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _revisionQuizPassed ? const Color(0xFF10B981) : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('STEP 5', style: TextStyle(color: _revisionQuizPassed ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('✍️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Quick Revision Mini-Quiz',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (_revisionQuizPassed)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Q: Which sentence follows the correct English "Subject + Verb + Object" order?',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...List.generate(3, (i) {
            final options = [
              'She reads books diligently.',
              'She books reads diligently.',
              'Reads she books diligently.',
            ];
            final isCorrect = i == 0;
            final isSelected = _selectedQuizAnswer == i;

            Color optionBg = const Color(0xFF1E293B);
            if (_quizSubmitted) {
              if (isCorrect) optionBg = const Color(0xFF10B981).withValues(alpha: 0.3);
              if (isSelected && !isCorrect) optionBg = Colors.red.withValues(alpha: 0.3);
            } else if (isSelected) {
              optionBg = const Color(0xFFFFFC00).withValues(alpha: 0.2);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: optionBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
                ),
              ),
              child: ListTile(
                title: Text(
                  options[i],
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
                onTap: _quizSubmitted
                    ? null
                    : () {
                        setState(() => _selectedQuizAnswer = i);
                        HapticFeedback.lightImpact();
                      },
                trailing: isSelected ? const Icon(Icons.radio_button_checked, color: Color(0xFFFFFC00), size: 18) : null,
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedQuizAnswer == -1
                  ? null
                  : () {
                      setState(() {
                        _quizSubmitted = true;
                        if (_selectedQuizAnswer == 0) {
                          _revisionQuizPassed = true;
                          _saveSubtask('quiz', true);
                        }
                      });
                      HapticFeedback.mediumImpact();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _revisionQuizPassed ? 'QUIZ PASSED ✓' : 'SUBMIT ANSWER',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🏆 FINAL CLAIM & ADVANCE BUTTON ---
  Widget _buildFinalClaimButton() {
    final isTimerMet = _isTimerCompleted;
    final isSubtasksMet = _isAllCompleted;
    final canClaim = _canClaimAndAdvance;

    String headerTitle;
    String description;
    String buttonText;

    if (canClaim) {
      headerTitle = '🎉 MISSION COMPLETED!';
      description =
          '60-Minute practice target met & all 7 subtasks verified! Claim +100 XP, +40 Fortress Defense Coins and unlock Day ${widget.day + 1}!';
      buttonText = 'CLAIM DAY ${widget.day} REWARDS & ADVANCE 🚀';
    } else if (isTimerMet && !isSubtasksMet) {
      headerTitle = '⚠️ ${7 - _completedSubtasksCount} SUBTASKS REMAINING';
      description =
          'Practice time target (60m) completed! You must complete all 7 subtasks below before unlocking Day ${widget.day + 1}.';
      buttonText = 'FINISH ${7 - _completedSubtasksCount} MORE SUBTASKS TO ADVANCE';
    } else if (!isTimerMet && isSubtasksMet) {
      headerTitle = '⏱️ PRACTICE TIME TARGET PENDING';
      description =
          'All 7 subtasks are verified! Practice for ${_timerService.formatTime(_timerService.remainingSeconds)} more minutes in app chats, drills, or calls to complete the 60-min target.';
      buttonText = 'PRACTICE ${_timerService.formatTime(_timerService.remainingSeconds)} MORE TO ADVANCE';
    } else {
      headerTitle = 'PRACTICE TARGET & SUBTASKS PENDING';
      description =
          'Progress: ${_timerService.formatTime()}/${_timerService.formatTime(_timerService.targetSeconds)} practice time • $_completedSubtasksCount/7 subtasks verified.';
      buttonText = '${7 - _completedSubtasksCount} SUBTASKS & ${_timerService.formatTime(_timerService.remainingSeconds)} REMAINING';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canClaim
              ? const [Color(0xFF10B981), Color(0xFF047857)]
              : const [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (canClaim)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            headerTitle,
            style: GoogleFonts.outfit(
              color: canClaim ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim
                  ? () async {
                      HapticFeedback.heavyImpact();
                      final uid = SupaFlow.client.auth.currentUser?.id;
                      if (uid != null) {
                        await Learning60DayService().completeTask(
                          userId: uid,
                          taskId: 'day_${widget.day}_mission',
                        );
                        await PocketFortressDefenseService.recordActivityPoints(
                          'daily_mission',
                        );
                      }
                      widget.onMissionCompleted?.call();
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🎉 Day ${widget.day} English Mission Complete! +100 XP • Day ${widget.day + 1} Unlocked!',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.outfit(
                  color: canClaim ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
