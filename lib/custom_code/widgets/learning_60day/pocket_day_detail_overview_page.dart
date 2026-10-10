import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'pocket_master_curriculum_90.dart';
import 'curriculum_data/pocket_day_curriculum_service.dart';

/// 🧠 Learner Proficiency Level
enum PocketLearnerLevel {
  beginner, // 🟢 Beginner (Slow audio, native language support, step-by-step SVO)
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
    _loadRuntimeCurriculum();
    _initTts();
    _loadUserLevel();
  }

  /// The JSON curriculum is authoritative. The legacy in-memory model is used
  /// only until the asset has loaded, then receives a display-model projection.
  Future<void> _loadRuntimeCurriculum() async {
    final data = await PocketDayCurriculumService.loadDayCurriculum(widget.day);
    if (data == null || !mounted) return;

    final langCode = PocketLanguageService.languageCode;
    final course = data['course'] as Map<String, dynamic>? ?? const {};
    final grammar = data['grammarRule'] as Map<String, dynamic>? ?? const {};
    final vocabulary = data['vocabulary'] as Map<String, dynamic>? ?? const {};
    final steps = (data['steps'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final builder = steps.where(
        (step) => step['gameType'] == 'word_catcher_builder').cast<Map<String, dynamic>>();
    final spoken = steps.where(
        (step) => step['gameType'] == 'speech_analyzer').cast<Map<String, dynamic>>();
    final social = steps.where(
        (step) => step['gameType'] == 'social_arena').cast<Map<String, dynamic>>();

    final items = <CurriculumVocabItem>[];
    for (final verb in vocabulary['verbs'] as List<dynamic>? ?? const []) {
      if (verb is! Map<String, dynamic>) continue;
      items.add(CurriculumVocabItem(
        word: verb['v1']?.toString() ?? '',
        phonetic: '',
        partOfSpeech: 'verb',
        meaningEn: '',
        meaningMl: PocketDayCurriculumService.getLocalizedText(verb['meaning'], lang: langCode),
        exampleEn: verb['example']?.toString() ?? '',
        exampleMl: verb['exampleMl']?.toString() ?? '',
      ));
    }
    for (final noun in vocabulary['nouns'] as List<dynamic>? ?? const []) {
      if (noun is! Map<String, dynamic>) continue;
      items.add(CurriculumVocabItem(
        word: noun['word']?.toString() ?? '',
        phonetic: '',
        partOfSpeech: 'noun',
        meaningEn: '',
        meaningMl: PocketDayCurriculumService.getLocalizedText(noun['meaning'], lang: langCode),
        exampleEn: noun['example']?.toString() ?? '',
      ));
    }

    final builderStep = builder.isEmpty ? const <String, dynamic>{} : builder.first;
    final spokenStep = spoken.isEmpty ? const <String, dynamic>{} : spoken.first;
    final socialStep = social.isEmpty ? const <String, dynamic>{} : social.first;
    final voiceTasks = spokenStep['voiceTasks'] as Map<String, dynamic>? ?? const {};
    final middleVoice = voiceTasks['middle'] as Map<String, dynamic>? ?? const {};
    final socialConfig = socialStep['socialConfig'] as Map<String, dynamic>? ?? const {};
    final middleSocial = socialConfig['middleTrack'] as Map<String, dynamic>? ?? const {};

    setState(() {
      _dayData = _dayData.copyWith(
        title: PocketDayCurriculumService.getLocalizedText(course['topic']),
        phaseName: PocketDayCurriculumService.getLocalizedText(course['houseTitle']),
        focusArea: PocketDayCurriculumService.getLocalizedText(course['topic']),
        grammarConcept: grammar['formula']?.toString() ?? '',
        theoryConcept: grammar['formula']?.toString() ?? '',
        theoryExplanationEn: PocketDayCurriculumService.getLocalizedText(grammar['explanation']),
        theoryExplanationMl: PocketDayCurriculumService.getLocalizedText(grammar['explanation'], lang: langCode),
        vocabulary: items,
        sentenceEvolution: (builderStep['challengePatterns'] as List<dynamic>? ?? const [])
            .map((pattern) => pattern.toString())
            .toList(),
        speakingDrill: middleVoice['targetSentence']?.toString() ?? '',
        dailyChallenge: middleVoice['prompt']?.toString() ?? '',
        peerChatMission: middleSocial['englishHubPrompt']?.toString() ?? '',
        xpReward: course['totalXpReward'] as int? ?? _dayData.xpReward,
      );
    });
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

                    // Sentence Evolution (Basic -> Intermediate -> Advanced)
                    if (_dayData.sentenceEvolution.isNotEmpty) ...[
                      _buildSentenceEvolutionCard(),
                      const SizedBox(height: 18),
                    ],

                    // Daily 5-Pillar Target Guide
                    _buildDailyPillarsCard(),
                    const SizedBox(height: 18),

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            color: isSelected
                ? color.withValues(alpha: 0.22)
                : const Color(0xFF1E293B),
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
      {
        'num': '1',
        'name': 'Today Lesson • Day ${widget.day} Step 1: Core Linguistic Theory',
        'short': 'Core Theory & Linguistic Rules',
        'desc': 'Deep-dive into grammar mechanics, formula breakdown & common native mistakes.',
        'icon': '📖',
        'badge': 'THEORY & FORMULA',
        'color': '0xFFA855F7',
      },
      {
        'num': '2',
        'name': 'Today Lesson • Day ${widget.day} Step 2: Vocabulary & Phonetics Bank',
        'short': 'Vocabulary & Phonetics Bank',
        'desc': 'Targeted high-frequency vocabulary, native pronunciation audio & phonetic drills.',
        'icon': '📚',
        'badge': 'PHONETICS & WORDS',
        'color': '0xFF38BDF8',
      },
      {
        'num': '3',
        'name': 'Today Lesson • Day ${widget.day} Step 3: Fluency Gym & Tongue Reflexes',
        'short': 'Fluency Gym & Vocal Reflex Arena',
        'desc': 'Speed tongue-twisters, syllable stress & acoustic muscle memory drills.',
        'icon': '🏋️',
        'badge': 'VOCAL AGILITY',
        'color': '0xFF10B981',
      },
      {
        'num': '4',
        'name': 'Today Lesson • Day ${widget.day} Step 4: Interactive Grammar Simulator',
        'short': 'Sentence Builder Simulator',
        'desc': 'Real-time sentence reconstruction, drag-and-drop syntax & game arenas.',
        'icon': '🎮',
        'badge': 'INTERACTIVE QUEST',
        'color': '0xFFF59E0B',
      },
      {
        'num': '5',
        'name': 'Today Lesson • Day ${widget.day} Step 5: Peer Spoken English Immersion',
        'short': 'Peer Speaking & Live Audio Hub',
        'desc': 'Unscripted live speaking practice with matched study partner / AI robot mate.',
        'icon': '💬',
        'badge': 'SPEAKING MISSION',
        'color': '0xFFEC4899',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF131D33), Color(0xFF0B132B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S LESSON BOARD • DAY ${widget.day}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Tap any step for deep futuristic theory & guidelines',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                ),
                child: Text(
                  '5 STEPS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...steps.map((st) {
            final col = Color(int.parse(st['color']!));
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showFuturisticStepTheoryBottomSheet(context, int.parse(st['num']!), st);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: col.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: col, width: 1.6),
                            boxShadow: [
                              BoxShadow(
                                color: col.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            st['num']!,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
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
                                  Text(st['icon']!, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      st['name']!,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                st['desc']!,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: col.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      st['badge']!,
                                      style: GoogleFonts.firaCode(
                                        color: col,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'TAP TO VIEW THEORY ➔',
                                    style: GoogleFonts.outfit(
                                      color: col,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 🚀 Deep Futuristic Theoretical Bottom Sheet for Step Exploration across all 90 days
  void _showFuturisticStepTheoryBottomSheet(
    BuildContext context,
    int stepNum,
    Map<String, String> stepInfo,
  ) {
    final col = Color(int.parse(stepInfo['color']!));
    final langName = PocketLanguageService.currentLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.82,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F1D),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: col.withValues(alpha: 0.5),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: col.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: col.withValues(alpha: 0.6)),
                      ),
                      child: Text(stepInfo['icon']!, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAY ${widget.day} • STEP $stepNum DEEP THEORY',
                            style: GoogleFonts.firaCode(
                              color: col,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            stepInfo['short']!,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Holographic Focus Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [col.withValues(alpha: 0.15), const Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: col.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🧠 LINGUISTIC NEURAL ARCHITECTURE',
                              style: GoogleFonts.firaCode(
                                color: col,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dayData.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Target Concept: ${_dayData.focusArea}',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF38BDF8),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Theory Rule & Formula Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131D33),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'MASTER FORMULA / SPEAKING BLUEPRINT',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                _dayData.grammarConcept.isNotEmpty
                                    ? _dayData.grammarConcept
                                    : 'Subject + Verb (Form) + Context [S-V-O]',
                                style: GoogleFonts.firaCode(
                                  color: const Color(0xFFFFE066),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // In-Depth Theoretical Explanation
                      Text(
                        'THEORETICAL EXPLANATION & PEDAGOGY',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151C2C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dayData.theoryExplanationEn,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13.5,
                                height: 1.45,
                              ),
                            ),
                            if (_dayData.theoryExplanationMl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '🌐 Guide in $langName:',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF93C5FD),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _dayData.theoryExplanationMl,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFBAE6FD),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Real-Life Speaking Drill
                      if (_dayData.speakingDrill.isNotEmpty) ...[
                        Text(
                          'DAILY ORAL REFLEX DRILL',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.record_voice_over_rounded, color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Say it out loud with confidence:',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF6EE7B7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981), size: 20),
                                    onPressed: () => _speak(_dayData.speakingDrill),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '"${_dayData.speakingDrill}"',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],

                      // Bottom CTA
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            if (widget.onStartMissions != null) {
                              widget.onStartMissions!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: col,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'PRACTICE STEP $stepNum IN TODAY\'S MISSIONS ➔',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildSentenceEvolutionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111C35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('📈', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SENTENCE GROWTH & EVOLUTION',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF818CF8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'പഴയ grammar + പുതിയത് ചേർത്ത് വാക്യങ്ങൾ വികസിപ്പിക്കുക',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._dayData.sentenceEvolution.map((evo) {
            final isSpeaking = _currentlySpeakingWord == evo;
            Color badgeColor = const Color(0xFF34D399);
            if (evo.contains('Intermediate') || evo.contains('🟡')) {
              badgeColor = const Color(0xFFFBBF24);
            } else if (evo.contains('Advanced') || evo.contains('🟣')) {
              badgeColor = const Color(0xFFA855F7);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSpeaking
                      ? const Color(0xFF00FFCC)
                      : badgeColor.withValues(alpha: 0.25),
                  width: isSpeaking ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      evo,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isSpeaking
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_rounded,
                      color: isSpeaking ? const Color(0xFF00FFCC) : badgeColor,
                      size: 20,
                    ),
                    onPressed: () => _speak(evo),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyPillarsCard() {
    final pillars = [
      {
        'title': '1. Grammar Concept (15 min)',
        'desc': _dayData.grammarConcept,
        'icon': '📚',
        'color': const Color(0xFF38BDF8)
      },
      {
        'title': '2. Vocabulary Bank (10 min)',
        'desc': '5–10 Words + Contextual Sentences',
        'icon': '🧠',
        'color': const Color(0xFFFFD700)
      },
      {
        'title': '3. Sentence Building (15 min)',
        'desc': 'Word → Sentence → Situation flow',
        'icon': '📝',
        'color': const Color(0xFF34D399)
      },
      {
        'title': '4. Active Listening (15 min)',
        'desc': _dayData.listeningGoal.isNotEmpty
            ? _dayData.listeningGoal
            : 'Listen to natural English dialogue',
        'icon': '🎧',
        'color': const Color(0xFFA855F7)
      },
      {
        'title': '5. Speaking Challenge (15–20 min)',
        'desc': _dayData.dailyChallenge.isNotEmpty
            ? _dayData.dailyChallenge
            : _dayData.speakingDrill,
        'icon': '🎤',
        'color': const Color(0xFFFB7185)
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('⚡', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5 DAILY PILLARS (70–90 MIN TOTAL)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF34D399),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'ദിവസവും ചെയ്യേണ്ട 5 കാര്യങ്ങൾ — Grammar + Vocab + Sentences + Listening + Speaking',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...pillars.map((pil) {
            final pColor = pil['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: pColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pil['icon'] as String,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pil['title'] as String,
                          style: GoogleFonts.outfit(
                            color: pColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pil['desc'] as String,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            height: 1.35,
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
                  isSpeaking
                      ? Icons.volume_up_rounded
                      : Icons.volume_down_rounded,
                  color: isSpeaking
                      ? const Color(0xFF00FFCC)
                      : const Color(0xFFFFD700),
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
