import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_master_curriculum_90.dart';

/// 🧠 Learner Proficiency Level
enum PocketLearnerLevel {
  beginner, // 🟢 Beginner (Slow audio, Malayalam support, step-by-step SVO)
  intermediate, // 🟡 Intermediate (Normal audio, workplace context, idioms)
  expert, // 🔴 Expert (Fast speech challenge, rhetoric, zero filler tolerance)
}

/// 📖 Dedicated Full-Screen Day Theory & Vocabulary Detail Page
class PocketDayDetailOverviewPage extends StatefulWidget {
  final int day;
  final VoidCallback? onStartMissions;

  const PocketDayDetailOverviewPage({
    super.key,
    required this.day,
    this.onStartMissions,
  });

  static Future<void> show(BuildContext context, int day,
      {VoidCallback? onStartMissions}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDayDetailOverviewPage(
          day: day,
          onStartMissions: onStartMissions,
        ),
      ),
    );
  }

  @override
  State<PocketDayDetailOverviewPage> createState() =>
      _PocketDayDetailOverviewPageState();
}

class _PocketDayDetailOverviewPageState
    extends State<PocketDayDetailOverviewPage> {
  late MasterCurriculumDay _dayData;
  final FlutterTts _tts = FlutterTts();
  PocketLearnerLevel _currentLevel = PocketLearnerLevel.beginner;
  String? _currentlySpeakingWord;

  @override
  void initState() {
    super.initState();
    _dayData = PocketMasterCurriculum90.getDay(widget.day);
    _initTts();
    _loadUserLevel();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
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
            _currentLevel = PocketLearnerLevel.intermediate;
          } else if (levelStr == 'expert') {
            _currentLevel = PocketLearnerLevel.expert;
          } else {
            _currentLevel = PocketLearnerLevel.beginner;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _setUserLevel(PocketLearnerLevel level) async {
    HapticFeedback.lightImpact();
    setState(() => _currentLevel = level);
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = level == PocketLearnerLevel.intermediate
          ? 'intermediate'
          : (level == PocketLearnerLevel.expert ? 'expert' : 'beginner');
      await prefs.setString('pocket_user_english_level', val);
    } catch (_) {}
  }

  double get _speechRate {
    switch (_currentLevel) {
      case PocketLearnerLevel.beginner:
        return 0.38; // Slow, crystal-clear phonetics
      case PocketLearnerLevel.intermediate:
        return 0.48; // Natural conversational
      case PocketLearnerLevel.expert:
        return 0.58; // Fast native speech
    }
  }

  Future<void> _speak(String text) async {
    HapticFeedback.selectionClick();
    setState(() => _currentlySpeakingWord = text);
    try {
      await _tts.stop();
      await _tts.setSpeechRate(_speechRate);
      await _tts.speak(text);
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) setState(() => _currentlySpeakingWord = null);
    } catch (_) {
      if (mounted) setState(() => _currentlySpeakingWord = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Hero Banner
                    _buildDayHeroBanner(),

                    const SizedBox(height: 16),

                    // Level Switcher (Beginner vs Expert)
                    _buildLevelSwitcherCard(),

                    const SizedBox(height: 18),

                    // The 5-Step Learning Roadmap
                    _buildLearningRoadmapCard(),

                    const SizedBox(height: 18),

                    // Theory & Linguistic Concept
                    _buildTheoryCard(),

                    const SizedBox(height: 18),

                    // Why It Matters (Neuroscience / Muscle Memory)
                    if (_dayData.whyItMatters.isNotEmpty) ...[
                      _buildWhyItMattersCard(),
                      const SizedBox(height: 18),
                    ],

                    // Common Mistakes & Fixes
                    if (_dayData.commonMistakes.isNotEmpty) ...[
                      _buildMistakesAndFixesCard(),
                      const SizedBox(height: 18),
                    ],

                    // Today's Vocabulary Bank
                    _buildVocabularySection(),

                    const SizedBox(height: 24),

                    // Launch Today's Missions CTA
                    _buildStartMissionsCTA(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DAY ${widget.day} DETAIL',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Theory & Vocabulary Master Guide',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '+${_dayData.xpReward} XP',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _dayData.phaseName.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA5B4FC),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (_dayData.milestoneReward.isNotEmpty)
                Text(
                  _dayData.milestoneReward,
                  style: const TextStyle(fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _dayData.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.center_focus_strong_rounded,
                  color: Color(0xFF00FFCC), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Focus: ${_dayData.focusArea}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00FFCC),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSwitcherCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎚️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'YOUR CURRENT PROFICIENCY LEVEL',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLevelPill(
                level: PocketLearnerLevel.beginner,
                label: 'Beginner',
                nativeSub: 'തുടക്കക്കാരൻ',
                color: const Color(0xFF10B981),
                icon: '🌱',
              ),
              const SizedBox(width: 8),
              _buildLevelPill(
                level: PocketLearnerLevel.intermediate,
                label: 'Intermediate',
                nativeSub: 'ഇടത്തരം',
                color: const Color(0xFFF59E0B),
                icon: '🌿',
              ),
              const SizedBox(width: 8),
              _buildLevelPill(
                level: PocketLearnerLevel.expert,
                label: 'Expert',
                nativeSub: 'വിദഗ്ദ്ധൻ',
                color: const Color(0xFFEF4444),
                icon: '⚡',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentLevel == PocketLearnerLevel.beginner
                ? '🟢 Beginner Mode: Slow crystal-clear audio (0.75x) + Malayalam guides + S-V-O foundation.'
                : (_currentLevel == PocketLearnerLevel.intermediate
                    ? '🟡 Intermediate Mode: Natural speed (1.0x) + Workplace idioms + connecting clauses.'
                    : '🔴 Expert Mode: Rapid native speech (1.4x) + Unscripted speed challenges + Zero filler words.'),
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPill({
    required PocketLearnerLevel level,
    required String label,
    required String nativeSub,
    required Color color,
    required String icon,
  }) {
    final isSelected = _currentLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setUserLevel(level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.22) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.white10,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              Text(
                nativeSub,
                style: GoogleFonts.inter(
                  color: isSelected ? color : Colors.white38,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningRoadmapCard() {
    final steps = [
      {'num': '1', 'name': 'Theory & Rules', 'desc': 'Master the concept & avoid common native mistakes', 'icon': '📖'},
      {'num': '2', 'name': 'Vocabulary Bank', 'desc': 'Listen to phonetics & learn target words', 'icon': '📚'},
      {'num': '3', 'name': 'Fluency Gym', 'desc': 'Vocal agility, tongue twisters & word stress', 'icon': '🏋️'},
      {'num': '4', 'name': 'Interactive Quests', 'desc': 'Sentence building & grammar simulator', 'icon': '🎮'},
      {'num': '5', 'name': 'Peer Speaking', 'desc': 'Live voice practice with your study partner', 'icon': '💬'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'STEP-BY-STEP LEARNING ROADMAP',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.map((st) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      st['num']!,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(st['icon']!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              st['name']!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          st['desc']!,
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTheoryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('💡', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CORE THEORY & LINGUISTIC RULE',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFC084FC),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      _dayData.theoryConcept.isNotEmpty
                          ? _dayData.theoryConcept
                          : _dayData.grammarConcept,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // English Explanation
          Text(
            _dayData.theoryExplanationEn.isNotEmpty
                ? _dayData.theoryExplanationEn
                : 'Master this grammar pillar through deliberate speech repetition.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          if (_dayData.theoryExplanationMl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌴', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dayData.theoryExplanationMl,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 12.5,
                        height: 1.45,
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

  Widget _buildWhyItMattersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('🧠', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHY THIS MATTERS FOR FLUENCY',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dayData.whyItMatters,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakesAndFixesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24151D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'COMMON NATIVE MISTAKES & INSTANT FIXES',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFB7185),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_dayData.commonMistakes.length, (idx) {
            final mistake = _dayData.commonMistakes[idx];
            final fix = idx < _dayData.mistakeCorrections.length
                ? _dayData.mistakeCorrections[idx]
                : '';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF181016),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mistake,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFDA4AF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (fix.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      fix,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVocabularySection() {
    final vocabList = _dayData.vocabulary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'TODAY\'S ESSENTIAL VOCABULARY BANK',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap 🔊 to listen with crystal-clear phonetic pronunciation.',
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        ...vocabList.map((item) => _buildVocabCard(item)),
      ],
    );
  }

  Widget _buildVocabCard(CurriculumVocabItem item) {
    final isSpeaking = _currentlySpeakingWord == item.word;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpeaking
              ? const Color(0xFF00FFCC)
              : Colors.white.withValues(alpha: 0.08),
          width: isSpeaking ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      item.word,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.partOfSpeech,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                  color: isSpeaking ? const Color(0xFF00FFCC) : const Color(0xFFFFD700),
                  size: 24,
                ),
                onPressed: () => _speak(item.word),
              ),
            ],
          ),
          Text(
            item.phonetic,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF38BDF8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.meaningEn,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          if (item.meaningMl.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.meaningMl,
              style: GoogleFonts.inter(
                color: const Color(0xFF6EE7B7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Example sentence
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '"${item.exampleEn}"',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _speak(item.exampleEn),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.play_circle_fill_rounded,
                        color: Color(0xFF38BDF8), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartMissionsCTA() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        if (widget.onStartMissions != null) {
          widget.onStartMissions!();
        }
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'START TODAY\'S INTERACTIVE MISSIONS',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
