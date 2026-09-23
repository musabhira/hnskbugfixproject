import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_day_detail_overview_page.dart';
import 'pocket_fluency_gym_data.dart';

/// 🎙️ Dedicated Full-Screen Fluency Gym Training Arena & Vocal Science Detail Page
class PocketFluencyGymDetailPage extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isInitiallyCompleted;
  final ValueChanged<bool>? onCompleted;

  const PocketFluencyGymDetailPage({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    this.isInitiallyCompleted = false,
    this.onCompleted,
  });

  static Future<bool?> open(
    BuildContext context, {
    required int day,
    String selectedLanguage = 'Malayalam',
    bool isInitiallyCompleted = false,
    ValueChanged<bool>? onCompleted,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PocketFluencyGymDetailPage(
          day: day,
          selectedLanguage: selectedLanguage,
          isInitiallyCompleted: isInitiallyCompleted,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketFluencyGymDetailPage> createState() =>
      _PocketFluencyGymDetailPageState();
}

class _PocketFluencyGymDetailPageState extends State<PocketFluencyGymDetailPage>
    with SingleTickerProviderStateMixin {
  late PocketFluencyGymDayData _data;
  final FlutterTts _tts = FlutterTts();
  late TabController _tabController;

  PocketLearnerLevel _learnerLevel = PocketLearnerLevel.beginner;
  late bool _isCompleted;
  final Set<int> _completedTabs = {};

  // Speed Challenge Timer
  Timer? _challengeTimer;
  int _challengeRemainingSeconds = 0;
  bool _isChallengeRunning = false;
  bool _isChallengeSucceeded = false;

  // Dictation
  final TextEditingController _dictationController = TextEditingController();
  bool? _isDictationCorrect;

  // Active audio feedback
  String? _currentlySpeakingText;

  @override
  void initState() {
    super.initState();
    _data = PocketFluencyGymRegistry.getDataForDay(widget.day);
    _isCompleted = widget.isInitiallyCompleted;
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initTts();
    _loadUserLevel();
  }

  @override
  void dispose() {
    _challengeTimer?.cancel();
    _dictationController.dispose();
    _tabController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _loadUserLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelStr = prefs.getString('pocket_user_english_level');
      if (levelStr != null && mounted) {
        setState(() {
          if (levelStr == 'intermediate') {
            _learnerLevel = PocketLearnerLevel.intermediate;
          } else if (levelStr == 'expert') {
            _learnerLevel = PocketLearnerLevel.expert;
          } else {
            _learnerLevel = PocketLearnerLevel.beginner;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _setUserLevel(PocketLearnerLevel level) async {
    HapticFeedback.lightImpact();
    setState(() => _learnerLevel = level);
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = level == PocketLearnerLevel.intermediate
          ? 'intermediate'
          : (level == PocketLearnerLevel.expert ? 'expert' : 'beginner');
      await prefs.setString('pocket_user_english_level', val);
    } catch (_) {}
  }

  double get _speechRate {
    switch (_learnerLevel) {
      case PocketLearnerLevel.beginner:
        return 0.38;
      case PocketLearnerLevel.intermediate:
        return 0.48;
      case PocketLearnerLevel.expert:
        return 0.58;
    }
  }

  Future<void> _speak(String text, {double? rate}) async {
    HapticFeedback.selectionClick();
    setState(() => _currentlySpeakingText = text);
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate ?? _speechRate);
      await _tts.speak(text);
      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) setState(() => _currentlySpeakingText = null);
    } catch (_) {
      if (mounted) setState(() => _currentlySpeakingText = null);
    }
  }

  void _startSpeedChallenge() {
    HapticFeedback.mediumImpact();
    final targetSec = _learnerLevel == PocketLearnerLevel.expert
        ? (_data.tongueTwisterTargetSeconds * 0.7).round()
        : (_learnerLevel == PocketLearnerLevel.beginner
            ? _data.tongueTwisterTargetSeconds + 5
            : _data.tongueTwisterTargetSeconds);

    setState(() {
      _challengeRemainingSeconds = targetSec;
      _isChallengeRunning = true;
      _isChallengeSucceeded = false;
    });

    _challengeTimer?.cancel();
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_challengeRemainingSeconds > 1) {
        setState(() {
          _challengeRemainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _challengeRemainingSeconds = 0;
          _isChallengeRunning = false;
          _isChallengeSucceeded = true;
          _completedTabs.add(0);
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _stopSpeedChallenge() {
    _challengeTimer?.cancel();
    setState(() {
      _isChallengeRunning = false;
    });
  }

  void _verifyDictation() {
    HapticFeedback.mediumImpact();
    final input = _dictationController.text.trim().toLowerCase();
    final target = _data.dictationAnswer.trim().toLowerCase();
    final isCorrect = input == target;

    setState(() {
      _isDictationCorrect = isCorrect;
      if (isCorrect) {
        _completedTabs.add(7);
      }
    });

    if (isCorrect) {
      HapticFeedback.heavyImpact();
    }
  }

  void _finishGymSession() {
    HapticFeedback.heavyImpact();
    setState(() => _isCompleted = true);
    if (widget.onCompleted != null) {
      widget.onCompleted!(true);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Fluency Gym Completed! +50 XP Awarded',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Level Pill Switcher
            _buildLevelPillBar(),

            // 8-Tab Navigation Bar
            _buildDrillTabBar(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTongueTwisterArena(),
                  _buildWordStressArena(),
                  _buildConnectedSpeechArena(),
                  _buildRoleplayArena(),
                  _buildShadowingArena(),
                  _buildFillerEliminatorArena(),
                  _buildPictureSituationArena(),
                  _buildDictationArena(),
                ],
              ),
            ),

            // Bottom Session Completion Footer
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context, _isCompleted),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
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
                    Expanded(
                      child: Text(
                        'Vocal Fluency Gym Arena',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_completedTabs.length}/8 Drills Mastered • 50 XP Arena',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6EE7B7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '+50 XP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
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

  Widget _buildLevelPillBar() {
    return Container(
      color: const Color(0xFF0C1322),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Text(
            'DIFFICULTY:',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                _buildSmallLevelBtn(PocketLearnerLevel.beginner, '🌱 Beginner (0.75x)'),
                const SizedBox(width: 6),
                _buildSmallLevelBtn(PocketLearnerLevel.intermediate, '🌿 Intermediate (1.0x)'),
                const SizedBox(width: 6),
                _buildSmallLevelBtn(PocketLearnerLevel.expert, '⚡ Expert (1.4x)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLevelBtn(PocketLearnerLevel level, String label) {
    final isSelected = _learnerLevel == level;
    final color = level == PocketLearnerLevel.beginner
        ? const Color(0xFF10B981)
        : (level == PocketLearnerLevel.intermediate
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444));

    return Expanded(
      child: GestureDetector(
        onTap: () => _setUserLevel(level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.22) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.white10,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildDrillTabBar() {
    final tabs = [
      {'icon': '👅', 'label': 'Twister'},
      {'icon': '🎵', 'label': 'Stress'},
      {'icon': '🌊', 'label': 'Connected'},
      {'icon': '🎭', 'label': 'Roleplay'},
      {'icon': '🎙️', 'label': 'Shadow'},
      {'icon': '🚫', 'label': 'Fillers'},
      {'icon': '🖼️', 'label': 'Picture'},
      {'icon': '🎧', 'label': 'Dictation'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: const Color(0xFF10B981),
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        tabs: tabs.asMap().entries.map((entry) {
          final idx = entry.key;
          final tab = entry.value;
          final isDone = _completedTabs.contains(idx);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tab['icon']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  tab['label']!,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isDone) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle,
                      color: Color(0xFF10B981), size: 12),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTongueTwisterArena() {
    final targetSec = _learnerLevel == PocketLearnerLevel.expert
        ? (_data.tongueTwisterTargetSeconds * 0.7).round()
        : (_learnerLevel == PocketLearnerLevel.beginner
            ? _data.tongueTwisterTargetSeconds + 5
            : _data.tongueTwisterTargetSeconds);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧠 Science & Theory Box
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF TONGUE TWISTERS',
            theory:
                'Tongue twisters rapidly stimulate the motor cortex that controls the 100+ muscles in your tongue, lips, and larynx. By cycling between contrasting phonemes (${_data.tongueTwisterTargetSound}), your brain automates articulatory dexterity, permanently eliminating stuttering and hesitancy.',
            malayalamTip: _data.tongueTwisterTipMl,
          ),

          const SizedBox(height: 16),

          // Main Drill Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF131D33), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TARGET SOUND: ${_data.tongueTwisterTargetSound}',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _currentlySpeakingText == _data.tongueTwister
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        color: const Color(0xFF00FFCC),
                      ),
                      onPressed: () => _speak(_data.tongueTwister),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _data.tongueTwister,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                // Speed challenge countdown
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0F1D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isChallengeRunning
                              ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                              : const Color(0xFF10B981).withValues(alpha: 0.2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isChallengeRunning
                              ? '$_challengeRemainingSeconds'
                              : '$targetSec',
                          style: GoogleFonts.outfit(
                            color: _isChallengeRunning
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isChallengeRunning
                                  ? 'SAY IT 3 TIMES FAST!'
                                  : (_isChallengeSucceeded
                                      ? '🎉 SPEED CHALLENGE COMPLETED!'
                                      : 'TARGET: 3 REPETITIONS IN $targetSec SEC'),
                              style: GoogleFonts.inter(
                                color: _isChallengeSucceeded
                                    ? const Color(0xFF34D399)
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Hit start and recite without pausing.',
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isChallengeRunning
                            ? _stopSpeedChallenge
                            : _startSpeedChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isChallengeRunning
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: Text(
                          _isChallengeRunning ? 'STOP' : 'START ⚡',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

  Widget _buildWordStressArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF WORD STRESS & CADENCE',
            theory:
                'English is a "stress-timed" language. In syllable-timed languages (like Malayalam and Hindi), every syllable receives equal length. In English, stressed syllables are held longer, louder, and higher in pitch. Misplaced stress makes English sound unnatural or incomprehensible to native listeners.',
            malayalamTip: _data.rhythmRule,
          ),
          const SizedBox(height: 16),
          Text(
            'TODAY\'S STRESS FOCUS: ${_data.wordStressFocus.toUpperCase()}',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          ..._data.wordStressPairs.map((pair) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131D33),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pair.primaryWord,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pair.phoneticStress,
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF38BDF8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pair.explanation,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded,
                        color: Color(0xFFFFD700), size: 24),
                    onPressed: () {
                      _speak(pair.primaryWord);
                      setState(() => _completedTabs.add(1));
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConnectedSpeechArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF CONNECTED SPEECH & ELISION',
            theory:
                'Native speakers do not speak word-by-word. When the final consonant of one word meets the first vowel of the next, they blend seamlessly together (Consonant-to-Vowel Linking). Master this, and your spoken English immediately sounds 10x more natural and effortless.',
            malayalamTip: _data.soundClinicTipMl,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFCC).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data.connectedSpeechTitle,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00FFCC),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WRITTEN FORM:',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 10)),
                          Text(
                            _data.writtenForm,
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF00FFCC), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NATURAL SPOKEN FORM:',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 10)),
                          Text(
                            _data.spokenForm,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF00FFCC),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    _speak(_data.writtenForm);
                    setState(() => _completedTabs.add(2));
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                  label: const Text('LISTEN TO NATIVE BLEND 🎧'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFCC),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_data.minimalPairs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'MINIMAL PAIR SOUND DRILL:',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _data.minimalPairs.map((pair) {
                return GestureDetector(
                  onTap: () => _speak(pair),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔊', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          pair,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleplayArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF SITUATIONAL ROLEPLAY',
            theory:
                'Contextual roleplaying simulates genuine social adrenaline. When your amygdala perceives realistic interaction without real-world stakes, the "affective filter" drops, unlocking natural fluency and rapid conversational reflexes.',
            malayalamTip:
                'യഥാർത്ഥ സാഹചര്യങ്ങളിൽ പെട്ടെന്ന് ഉത്തരം നൽകാൻ റോൾപ്ലേ പരിശീലനം നിങ്ങളെ സഹായിക്കുന്നു.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFA855F7).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎭', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _data.roleplayScenario,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFC084FC),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Partner's line
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('👤', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '"${_data.partnerLine}"',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            color: Color(0xFFA855F7)),
                        onPressed: () => _speak(_data.partnerLine),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'YOUR MISSION: ${_data.yourPrompt}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Suggested response: "${_data.suggestedResponse}"',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _speak(_data.suggestedResponse);
                    setState(() => _completedTabs.add(3));
                  },
                  icon: const Icon(Icons.mic_rounded, size: 18),
                  label: const Text('PRACTICE YOUR RESPONSE 🗣️'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShadowingArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF SPEECH SHADOWING',
            theory:
                'Pioneered by linguist Prof. Alexander Arguelles, shadowing forces your brain to replicate cadence, pitch contour, and breath intake in real-time. Do not wait for the audio to finish — speak along with it with just a 0.5-second delay.',
            malayalamTip: _data.shadowingPacingTip,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎙️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'SHADOWING PASSAGE (READ ALOUD)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _data.shadowingPassage,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _speak(_data.shadowingPassage);
                        setState(() => _completedTabs.add(4));
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('SHADOW ALOUD 🎙️'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _speak(_data.shadowingPassage, rate: 0.34),
                      icon: const Icon(Icons.slow_motion_video_rounded, size: 18),
                      label: const Text('SLOW (0.7X)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        side: const BorderSide(color: Color(0xFF38BDF8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  Widget _buildFillerEliminatorArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF KILLING FILLER WORDS',
            theory:
                'Fillers like "um", "uh", "actually", and "you know" are vocal pacifiers. They occur because your vocal cords feel uncomfortable with silence while your brain searches for the next word. Replacing fillers with deliberate silent pauses makes you sound authoritative and in control.',
            malayalamTip:
                '"Um", "Uh" തുടങ്ങിയ വാക്കുകൾ ഒഴിവാക്കി പകരം 1 സെക്കന്റ് നിശബ്ദമായി ശ്വാസമെടുത്ത് സംസാരിക്കുക.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF24151D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🚫', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'FILLER-HEAVY SPEECH (WEAK)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFB7185),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _data.fillerWordTrap,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFDA4AF),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'CLEAN POLISHED REPLACEMENT (POWERFUL)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF34D399),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _data.confidentReplacement,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    _speak(_data.confidentReplacement);
                    setState(() => _completedTabs.add(5));
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('LISTEN TO CLEAN VERSION 🎙️'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPictureSituationArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF SITUATION & VISUAL DESCRIPTION',
            theory:
                'Describing visual scenes bridges the gap between imagination and verbalization. It trains your prefrontal cortex to spontaneously formulate descriptive adjectives and prepositions of place without pre-scripting.',
            malayalamTip:
                'ചിത്രം അല്ലെങ്കിൽ സാഹചര്യം കണ്ട് 60 സെക്കന്റ് തുടർച്ചയായി ഇംഗ്ലീഷിൽ സംസാരിക്കുക.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFB703).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🖼️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _data.situationTitle,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFB703),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _data.situationDescription,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'TARGET KEYWORDS TO USE IN YOUR SPEECH:',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _data.powerKeywords.map((kw) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        kw,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFB703),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _speak(
                        'Describe the scene using the target keywords: ${_data.powerKeywords.join(', ')}');
                    setState(() => _completedTabs.add(6));
                  },
                  icon: const Icon(Icons.mic_rounded, size: 18),
                  label: const Text('START 60S UNPREPARED TALK 🗣️'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDictationArena() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVocalScienceBox(
            title: 'THE SCIENCE OF ACOUSTIC DICTATION',
            theory:
                'Dictation trains your ears to parse fast-spoken connected speech into discrete grammatical tokens. By testing your spelling and listening comprehension simultaneously, it cements neurological links between phonemes and written text.',
            malayalamTip:
                'ഓഡിയോ ശ്രദ്ധയോടെ കേട്ട് വിട്ടുപോയ വാക്ക് ശരിയായി ടൈപ്പ് ചെയ്യുക.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎧', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'LISTEN TO AUDIO & FILL THE GAP',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFA78BFA),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFFA78BFA), size: 26),
                      onPressed: () =>
                          _speak(_data.dictationAudioSentence),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _data.dictationPromptWithBlank,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dictationController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Type missing word here...',
                    hintStyle: GoogleFonts.inter(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981)),
                      onPressed: _verifyDictation,
                    ),
                  ),
                  onSubmitted: (_) => _verifyDictation(),
                ),
                if (_isDictationCorrect != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isDictationCorrect!
                          ? const Color(0xFF064E3B)
                          : const Color(0xFF4C0519),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(_isDictationCorrect! ? '✅' : '❌',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isDictationCorrect!
                                ? 'Correct! Well done.'
                                : 'Not quite. Answer: "${_data.dictationAnswer}"',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
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

  Widget _buildVocalScienceBox({
    required String title,
    required String theory,
    required String malayalamTip,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1C30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            theory,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (malayalamTip.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF131D33),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌴', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      malayalamTip,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _finishGymSession,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      _isCompleted
                          ? 'SESSION COMPLETED ✓'
                          : 'COMPLETE FLUENCY GYM (+50 XP)',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
