import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_routine_pdf_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';
import 'package:share_plus/share_plus.dart';

/// 📚 Kids Productivity, Daily Routine & Mini-Games Arcade Hub (Light Mode)
///
/// Features:
/// 1. 📅 Daily Routine & Morning-to-Evening Timetable Builder with checkmarks & alarms.
/// 2. 📄 Illustrated PDF Timetable Generation & Print Preview (`pdf` & `printing`).
/// 3. 📲 One-tap Routine & Study Notes Sharing to WhatsApp and Mates.
/// 4. 📝 Study Notes & Key Points Notepad with bullet points & TTS audio.
/// 5. 🎮 4 Awesome Cartoon Mini-Games:
///    - 🔤 Spell Quest (Interactive typing & letter blocks with phonics).
///    - 🎈 Balloon Pop Phonics (Pop balloons with matching sounds).
///    - 🧠 Animal Memory Match (Flip card matching game).
///    - 🚀 Math Star Rocket (Addition challenge launching rockets).
/// 6. 🗂️ Flashcard Word Bank with animal mascot cheer voices.
/// 7. 🎯 Daily Quests with star rewards.
class PocketKidsStudyToolsPage extends StatefulWidget {
  const PocketKidsStudyToolsPage({super.key});

  @override
  State<PocketKidsStudyToolsPage> createState() => _PocketKidsStudyToolsPageState();
}

class _PocketKidsStudyToolsPageState extends State<PocketKidsStudyToolsPage> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  final TextEditingController _taskTimeController = TextEditingController();

  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteSubjectController = TextEditingController();
  final TextEditingController _notePointsController = TextEditingController();

  final TextEditingController _spellInputController = TextEditingController();

  int _selectedTab = 0; // 0 = Routine, 1 = Notes, 2 = Games Arcade, 3 = Words, 4 = Quests
  String _routineCategoryFilter = 'all'; // 'all', 'morning', 'afternoon', 'evening', 'night'

  List<KidRoutineItem> _routines = [];
  List<KidStudyNote> _notes = [];
  bool _isLoadingData = true;

  // --- 🔤 Spell Quest Game Data ---
  final List<Map<String, String>> _spellWords = [
    {
      'word': 'LION',
      'emoji': '🦁',
      'hint': 'King of the animal kingdom with a golden mane!',
      'phonics': '/l/ - /aɪ/ - /ə/ - /n/',
      'cheer': 'Roar! The mighty lion rules the mountain!',
    },
    {
      'word': 'TIGER',
      'emoji': '🐯',
      'hint': 'A brave bouncy friend with bold orange stripes!',
      'phonics': '/t/ - /aɪ/ - /ɡ/ - /ər/',
      'cheer': 'Tigger-riffic! Great spelling skills!',
    },
    {
      'word': 'PANDA',
      'emoji': '🐼',
      'hint': 'Gentle black and white bear that eats green bamboo!',
      'phonics': '/p/ - /æ/ - /n/ - /d/ - /ə/',
      'cheer': 'Sweet panda gives you a warm bear hug!',
    },
    {
      'word': 'APPLE',
      'emoji': '🍎',
      'hint': 'Sweet crunchy fruit that keeps the doctor away!',
      'phonics': '/æ/ - /p/ - /əl/',
      'cheer': 'Crispy and delicious! Keep learning!',
    },
    {
      'word': 'CASTLE',
      'emoji': '🏰',
      'hint': 'A royal citadel with towers, flags, and shields!',
      'phonics': '/k/ - /æ/ - /s/ - /əl/',
      'cheer': 'Citadel fortress unlocked! High five!',
    },
    {
      'word': 'BRAVE',
      'emoji': '⚡',
      'hint': 'Having courage and speaking English with confidence!',
      'phonics': '/b/ - /r/ - /eɪ/ - /v/',
      'cheer': 'You are super brave young explorer!',
    },
    {
      'word': 'RAINBOW',
      'emoji': '🌈',
      'hint': 'Seven shining colors in the sky after the rain!',
      'phonics': '/r/ - /eɪ/ - /n/ - /b/ - /oʊ/',
      'cheer': 'Magical colors shining bright!',
    },
  ];
  int _spellQuestIndex = 0;
  String _typedSpelling = '';
  bool _spellSolved = false;

  // --- 🎈 Balloon Pop Mini-Game State ---
  int _activeGameIndex = 0; // 0 = Spell Quest, 1 = Balloon Pop, 2 = Memory Match, 3 = Math Rocket
  int _balloonScore = 0;
  String _balloonTargetLetter = 'B';
  final List<String> _balloonChoices = ['A', 'B', 'C', 'D', 'E', 'F'];
  final List<Color> _balloonColors = [
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  // --- 🧠 Memory Match Cards State ---
  late List<_MemoryCardItem> _memoryCards;
  int? _flippedFirstIndex;
  bool _isCheckingMatch = false;
  int _memoryMatchesFound = 0;

  // --- 🚀 Math Star Rocket State ---
  int _mathNum1 = 3;
  int _mathNum2 = 4;
  int _mathScore = 0;
  bool _rocketLaunched = false;
  final TextEditingController _mathInputController = TextEditingController();

  // --- Flashcards Dataset ---
  final List<Map<String, String>> _flashcards = [
    {
      'word': 'Brave',
      'emoji': '🦁',
      'phonics': '/breɪv/',
      'definition': 'Having courage and ready to face challenges.',
      'example': 'The little lion cub is brave and climbs to Day 100!',
    },
    {
      'word': 'Friendly',
      'emoji': '🤝',
      'phonics': '/ˈfrend.li/',
      'definition': 'Kind, smiling, and eager to help your classmates.',
      'example': 'We are always friendly and share our toys with mates.',
    },
    {
      'word': 'Curious',
      'emoji': '🔍',
      'phonics': '/ˈkjʊə.ri.əs/',
      'definition': 'Eager to discover new things and ask questions.',
      'example': 'Curious kids explore the mountain biomes with joy.',
    },
    {
      'word': 'Honest',
      'emoji': '✨',
      'phonics': '/ˈɒn.ɪst/',
      'definition': 'Always speaking the truth and doing the right thing.',
      'example': 'An honest explorer is respected by all forest companions.',
    },
    {
      'word': 'Champion',
      'emoji': '🏆',
      'phonics': '/ˈtʃæm.pi.ən/',
      'definition': 'A winner who practices hard and never gives up.',
      'example': 'Every kid on the mountain road is a true English Champion!',
    },
  ];
  int _flashcardIndex = 0;

  // --- Daily Quests Dataset ---
  final List<Map<String, dynamic>> _dailyQuests = [
    {'title': 'Complete 3 Morning Routine Tasks 🌅', 'done': false, 'stars': 15},
    {'title': 'Spell 2 words in Spell Quest 🔤', 'done': false, 'stars': 10},
    {'title': 'Listen to 3 Word Flashcards with Audio 🎧', 'done': false, 'stars': 10},
    {'title': 'Export or Share Daily Timetable with Parents 📄', 'done': false, 'stars': 20},
    {'title': 'Score 5 Stars in Balloon Pop Mini-Game 🎈', 'done': false, 'stars': 15},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadAllData();
    _initMemoryCards();
  }

  Future<void> _loadAllData() async {
    final routines = await PocketKidsRoutinePdfService.loadRoutines();
    final notes = await PocketKidsRoutinePdfService.loadNotes();
    if (mounted) {
      setState(() {
        _routines = routines;
        _notes = notes;
        _isLoadingData = false;
      });
    }
  }

  void _initMemoryCards() {
    final items = [
      {'emoji': '🦁', 'label': 'Lion'},
      {'emoji': '🦁', 'label': 'Lion'},
      {'emoji': '🐼', 'label': 'Panda'},
      {'emoji': '🐼', 'label': 'Panda'},
      {'emoji': '🐯', 'label': 'Tiger'},
      {'emoji': '🐯', 'label': 'Tiger'},
      {'emoji': '🍎', 'label': 'Apple'},
      {'emoji': '🍎', 'label': 'Apple'},
    ];
    items.shuffle(math.Random());
    _memoryCards = items.map((e) => _MemoryCardItem(emoji: e['emoji']!, label: e['label']!)).toList();
    _flippedFirstIndex = null;
    _isCheckingMatch = false;
    _memoryMatchesFound = 0;
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

  @override
  void dispose() {
    _tts.stop();
    _taskTitleController.dispose();
    _taskDescController.dispose();
    _taskTimeController.dispose();
    _noteTitleController.dispose();
    _noteSubjectController.dispose();
    _notePointsController.dispose();
    _spellInputController.dispose();
    _mathInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PocketKidsNatureSceneryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 🌟 Top Cartoon Header Banner
              _buildTopHeader(),

              // 🏷️ Gamified Top Tab Bar Capsule
              _buildTabBarCapsule(),

              // 📱 Tab Views Body
              Expanded(
                child: _isLoadingData
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
                    : IndexedStack(
                        index: _selectedTab,
                        children: [
                          _buildRoutineView(),
                          _buildNotesView(),
                          _buildGamesArcadeView(),
                          _buildFlashcardsView(),
                          _buildQuestsView(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Cartoon Header Banner ---
  Widget _buildTopHeader() {
    final kidStars = PocketKidsService.kidStars;
    final kidName = PocketKidsService.kidName;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF082F49).withValues(alpha: 0.65),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
            ),
            child: const Text('🎒', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'STUDENT PLANNER',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PRO ⚡',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF15803D),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$kidName • Routine, Notes & Games',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // Star HUD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$kidStars PTS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11.5,
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

  // --- Gamified Top Tab Bar Capsule ---
  Widget _buildTabBarCapsule() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildTabCapsuleItem(0, 'ROUTINE 📅'),
            _buildTabCapsuleItem(1, 'NOTES 📝'),
            _buildTabCapsuleItem(2, 'GAMES 🎮'),
            _buildTabCapsuleItem(3, 'WORDS 🗂️'),
            _buildTabCapsuleItem(4, 'QUESTS 🎯'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCapsuleItem(int index, String title) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            color: active ? Colors.black : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // --- 1. DAILY ROUTINE VIEW (Morning to Evening Timetable & PDF Export) ---
  // =========================================================================
  Widget _buildRoutineView() {
    final completedCount = _routines.where((r) => r.isCompleted).length;
    final filtered = _routineCategoryFilter == 'all'
        ? _routines
        : _routines.where((r) => r.category == _routineCategoryFilter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        // Routine Controls & PDF Export Action Row
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY SCHEDULE ($completedCount/${_routines.length} Done)',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Morning to Evening Habit Tracker ☀️',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _showAddRoutineDialog,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      'ADD TASK',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // PDF Print & Share Action Chips Row
              Row(
                children: [
                  Expanded(
                    child: _buildActionIconButton(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'PDF TIMETABLE',
                      color: const Color(0xFFEF4444),
                      onTap: () => PocketKidsRoutinePdfService.printOrPreviewPdf(
                        context: context,
                        routines: _routines,
                        notes: _notes,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionIconButton(
                      icon: Icons.share_rounded,
                      label: 'SHARE PDF',
                      color: const Color(0xFF3B82F6),
                      onTap: () => PocketKidsRoutinePdfService.sharePdfFile(
                        context: context,
                        routines: _routines,
                        notes: _notes,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'SHARE TEXT',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => PocketKidsRoutinePdfService.shareRoutineAsText(
                        context: context,
                        routines: _routines,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Category Filter Chips
        Container(
          height: 34,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCategoryChip('all', 'All Time ⏰'),
              _buildCategoryChip('morning', 'Morning 🌅'),
              _buildCategoryChip('afternoon', 'Afternoon 🥪'),
              _buildCategoryChip('evening', 'Evening ⚽'),
              _buildCategoryChip('night', 'Bedtime 🌙'),
            ],
          ),
        ),

        // Routine Task List Items
        for (final r in filtered)
          _buildRoutineCard(r),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Text('🎈', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  'No routine tasks here yet!',
                  style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tap "ADD TASK" above to schedule your day.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final active = _routineCategoryFilter == id;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _routineCategoryFilter = id);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF59E0B) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFFFFD700) : const Color(0xFF334155),
            width: 1.2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? Colors.black : const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(KidRoutineItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: r.isCompleted ? const Color(0xFF10B981) : const Color(0xFF334155),
          width: r.isCompleted ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: r.isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox toggle with star reward animation
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              setState(() {
                r.isCompleted = !r.isCompleted;
              });
              await PocketKidsRoutinePdfService.saveRoutines(_routines);
              if (r.isCompleted) {
                await PocketKidsService.addStars(r.starReward);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Text('🌟 ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              'Completed "${r.title}"! +${r.starReward} Stars earned! 🎉',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  );
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: r.isCompleted ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: r.isCompleted ? const Color(0xFF10B981) : const Color(0xFF475569),
                  width: 2,
                ),
              ),
              child: r.isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Emoji Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF334155), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(r.icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r.time,
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '+${r.starReward} ⭐',
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFACC15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  r.title,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: r.isCompleted ? const Color(0xFF64748B) : Colors.white,
                    decoration: r.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (r.desc.isNotEmpty) ...[
                  Text(
                    r.desc,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF94A3B8), size: 18),
            onPressed: () async {
              HapticFeedback.lightImpact();
              setState(() {
                _routines.removeWhere((item) => item.id == r.id);
              });
              await PocketKidsRoutinePdfService.saveRoutines(_routines);
            },
          ),
        ],
      ),
    );
  }

  void _showAddRoutineDialog() {
    _taskTitleController.clear();
    _taskDescController.clear();
    _taskTimeController.text = '08:00 AM';
    String selectedCat = 'morning';
    String selectedIcon = '☀️';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('⏰ ➕', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'ADD ROUTINE TASK',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title Input
                TextField(
                  controller: _taskTitleController,
                  autofocus: true,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    hintText: 'e.g. Read 1 English Story Book 📖',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),

                // Time & Description Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _taskTimeController,
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Time Slot',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          hintText: '04:00 PM',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCat,
                        dropdownColor: const Color(0xFF0F172A),
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'morning', child: Text('Morning 🌅')),
                          DropdownMenuItem(value: 'afternoon', child: Text('Afternoon 🥪')),
                          DropdownMenuItem(value: 'evening', child: Text('Evening ⚽')),
                          DropdownMenuItem(value: 'night', child: Text('Night 🌙')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCat = val;
                              selectedIcon = val == 'morning'
                                  ? '🌅'
                                  : (val == 'afternoon' ? '🥪' : (val == 'evening' ? '⚽' : '🌙'));
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description Input
                TextField(
                  controller: _taskDescController,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description / Kid Motto',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    hintText: 'e.g. Practice reading aloud for 15 minutes',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final title = _taskTitleController.text.trim();
                      if (title.isEmpty) return;
                      final newItem = KidRoutineItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        time: _taskTimeController.text.trim().isEmpty
                            ? '08:00 AM'
                            : _taskTimeController.text.trim(),
                        title: title,
                        desc: _taskDescController.text.trim(),
                        icon: selectedIcon,
                        category: selectedCat,
                        starReward: 10,
                      );
                      setState(() {
                        _routines.add(newItem);
                      });
                      await PocketKidsRoutinePdfService.saveRoutines(_routines);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(
                      'SAVE ROUTINE TASK ⭐',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // --- 2. STUDY NOTES VIEW (Key Points Notepad & Sharing) ---
  // =========================================================================
  Widget _buildNotesView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        // Action Bar for Notes
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STUDY NOTES & KEY POINTS 📝',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(80, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _showAddNoteDialog,
                icon: const Icon(Icons.note_add_rounded, size: 16),
                label: Text(
                  'NEW NOTE',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        // Notes List Items
        for (final n in _notes)
          _buildNoteCard(n),

        if (_notes.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Text('📝', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  'No study notes saved yet!',
                  style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tap "NEW NOTE" to jot down speaking tips and key points.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNoteCard(KidStudyNote n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(n.emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${n.subject} • ${n.date}',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              // TTS Audio Button
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 20),
                tooltip: 'Read Note Aloud',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final content = '${n.title}. ${n.keyPoints.join(". ")}';
                  _speak(content);
                },
              ),
              // Share Note
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Color(0xFFA855F7), size: 18),
                tooltip: 'Share Note',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final text = '📝 *${n.title}* (${n.subject})\n\n${n.keyPoints.map((p) => "• $p").join("\n")}\n\n- From Pocket Kids Adventure 🎒';
                  SharePlus.instance.share(ShareParams(text: text));
                },
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFF334155)),

          // Key Bullet Points
          ...n.keyPoints.map(
            (pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐ ', style: TextStyle(fontSize: 11)),
                  Expanded(
                    child: Text(
                      pt,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE2E8F0),
                        height: 1.35,
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
  }

  void _showAddNoteDialog() {
    _noteTitleController.clear();
    _noteSubjectController.text = 'Spoken English';
    _notePointsController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('📝 ➕', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'ADD STUDY NOTE & POINTS',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _noteTitleController,
                autofocus: true,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Topic Title',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  hintText: 'e.g. 5 Polite Greetings in English',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _noteSubjectController,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Subject / Category',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  hintText: 'Spoken English / Vocabulary / Manners',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _notePointsController,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Key Points (Separate lines with Enter)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  hintText: 'Line 1: Say "Good morning" with a smile\nLine 2: Say "Thank you" when helped',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final title = _noteTitleController.text.trim();
                    if (title.isEmpty) return;
                    final lines = _notePointsController.text
                        .trim()
                        .split('\n')
                        .where((l) => l.trim().isNotEmpty)
                        .toList();

                    final newNote = KidStudyNote(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      subject: _noteSubjectController.text.trim().isEmpty
                          ? 'General'
                          : _noteSubjectController.text.trim(),
                      keyPoints: lines.isEmpty ? ['Important rule learned today!'] : lines,
                      date: 'Today',
                      emoji: '💡',
                    );

                    setState(() {
                      _notes.insert(0, newNote);
                    });
                    await PocketKidsRoutinePdfService.saveNotes(_notes);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(
                    'SAVE STUDY NOTE 💡',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // --- 3. GAMES ARCADE VIEW (Fun Gamified Mini-Games) ---
  // =========================================================================
  Widget _buildGamesArcadeView() {
    return Column(
      children: [
        // Mini-Game Selector Carousel
        Container(
          height: 38,
          margin: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildGameTabChip(0, 'Spell Quest 🔤'),
              _buildGameTabChip(1, 'Balloon Pop 🎈'),
              _buildGameTabChip(2, 'Memory Match 🧠'),
              _buildGameTabChip(3, 'Math Rocket 🚀'),
            ],
          ),
        ),

        // Active Game Body
        Expanded(
          child: IndexedStack(
            index: _activeGameIndex,
            children: [
              _buildSpellQuestGame(),
              _buildBalloonPopGame(),
              _buildMemoryMatchGame(),
              _buildMathRocketGame(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameTabChip(int index, String title) {
    final active = _activeGameIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeGameIndex = index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF59E0B) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFFF59E0B) : const Color(0xFF334155),
            width: 1.2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: active ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  // --- Mini-Game 1: Spell Quest ---
  Widget _buildSpellQuestGame() {
    final current = _spellWords[_spellQuestIndex];
    final targetWord = current['word']!;
    final emoji = current['emoji']!;
    final hint = current['hint']!;
    final phonics = current['phonics']!;
    final cheer = current['cheer']!;

    final targetLetters = targetWord.split('');
    final extraLetters = ['A', 'E', 'I', 'O', 'U', 'S', 'T', 'R', 'L', 'N'];
    final keyboardSet = {...targetLetters};
    for (final extra in extraLetters) {
      if (keyboardSet.length >= 10) break;
      keyboardSet.add(extra);
    }
    final sortedLetters = keyboardSet.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        // Game Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _spellSolved ? const Color(0xFF10B981) : const Color(0xFF334155),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _spellSolved
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _speak(targetWord);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Phonics: $phonics',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11),
              ),
              const SizedBox(height: 18),

              // Letter Slots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(targetWord.length, (idx) {
                  final hasLetter = idx < _typedSpelling.length;
                  final letter = hasLetter ? _typedSpelling[idx] : '';
                  final isCorrectSlot = hasLetter && _typedSpelling[idx] == targetWord[idx];

                  return Container(
                    width: 42,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _spellSolved
                          ? const Color(0xFF064E3B)
                          : (hasLetter ? const Color(0xFF0F172A) : const Color(0xFF0F172A)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _spellSolved
                            ? const Color(0xFF10B981)
                            : (hasLetter
                                ? (isCorrectSlot ? const Color(0xFF38BDF8) : Colors.redAccent)
                                : const Color(0xFF334155)),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (_spellSolved) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF022C22)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
            ),
            child: Column(
              children: [
                const Text('🎉 🌟 🏆', style: TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  'SUPER SPELLER! +10 STARS EARNED!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF34D399),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(cheer, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFFE2E8F0))),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF78350F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _typedSpelling = '';
                      _spellSolved = false;
                      _spellInputController.clear();
                      _spellQuestIndex = (_spellQuestIndex + 1) % _spellWords.length;
                    });
                  },
                  child: const Text('NEXT WORD ➡️', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ] else ...[
          // Letter Blocks
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ...sortedLetters.map((char) {
                return GestureDetector(
                  onTap: () async {
                    if (_typedSpelling.length >= targetWord.length) return;
                    HapticFeedback.lightImpact();
                    final next = '$_typedSpelling$char';
                    setState(() => _typedSpelling = next);
                    if (next == targetWord) {
                      HapticFeedback.heavyImpact();
                      setState(() => _spellSolved = true);
                      await PocketKidsService.addStars(10);
                      _speak("Awesome! You spelled $targetWord correctly!");
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      char,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }),
              // Backspace
              GestureDetector(
                onTap: () {
                  if (_typedSpelling.isEmpty) return;
                  HapticFeedback.lightImpact();
                  setState(() => _typedSpelling = _typedSpelling.substring(0, _typedSpelling.length - 1));
                },
                child: Container(
                  width: 48,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('⌫', style: TextStyle(fontSize: 18, color: Color(0xFFB91C1C))),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // --- Mini-Game 2: Balloon Pop Phonics ---
  Widget _buildBalloonPopGame() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFFD700)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'POP BALLOON: "$_balloonTargetLetter"',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF78350F),
                  ),
                ),
                Text(
                  'SCORE: $_balloonScore 🎈',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _balloonChoices.length,
              itemBuilder: (context, idx) {
                final letter = _balloonChoices[idx];
                final color = _balloonColors[idx % _balloonColors.length];

                return GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    if (letter == _balloonTargetLetter) {
                      setState(() => _balloonScore += 10);
                      await PocketKidsService.addStars(5);
                      _speak("Pop! Good job!");
                      // Pick new target
                      final next = _balloonChoices[math.Random().nextInt(_balloonChoices.length)];
                      setState(() => _balloonTargetLetter = next);
                    } else {
                      _speak("Try again!");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Mini-Game 3: Animal Memory Match ---
  Widget _buildMemoryMatchGame() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MATCH THE ANIMAL PAIRS 🧠',
                style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text(
                'Found: $_memoryMatchesFound/4 Pairs',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _memoryCards.length,
              itemBuilder: (context, idx) {
                final card = _memoryCards[idx];
                final showFront = card.isFlipped || card.isMatched;

                return GestureDetector(
                  onTap: () async {
                    if (card.isMatched || card.isFlipped || _isCheckingMatch) return;
                    HapticFeedback.lightImpact();
                    setState(() => card.isFlipped = true);

                    if (_flippedFirstIndex == null) {
                      _flippedFirstIndex = idx;
                    } else {
                      // Check Match
                      _isCheckingMatch = true;
                      final first = _memoryCards[_flippedFirstIndex!];
                      if (first.label == card.label) {
                        // Match!
                        setState(() {
                          first.isMatched = true;
                          card.isMatched = true;
                          _memoryMatchesFound++;
                        });
                        await PocketKidsService.addStars(10);
                        _speak(first.label);
                        _flippedFirstIndex = null;
                        _isCheckingMatch = false;
                      } else {
                        // Mismatch, flip back after delay
                        await Future.delayed(const Duration(milliseconds: 700));
                        if (mounted) {
                          setState(() {
                            first.isFlipped = false;
                            card.isFlipped = false;
                            _flippedFirstIndex = null;
                            _isCheckingMatch = false;
                          });
                        }
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: showFront ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: showFront ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: showFront
                        ? Text(card.emoji, style: const TextStyle(fontSize: 24))
                        : const Text('❓', style: TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            onPressed: () => setState(_initMemoryCards),
            child: Text('RESTART GAME 🔄', style: GoogleFonts.outfit(color: const Color(0xFF78350F), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Mini-Game 4: Math Star Rocket ---
  Widget _buildMathRocketGame() {
    final answer = _mathNum1 + _mathNum2;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  transform: Matrix4.translationValues(0, _rocketLaunched ? -30 : 0, 0),
                  child: const Text('🚀', style: TextStyle(fontSize: 50)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Stars Earned: $_mathScore ⭐',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFFACC15)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_mathNum1 + $_mathNum2 = ?',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFFA5B4FC)),
                ),
                Text('Launch the rocket with correct addition!', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [answer - 1, answer, answer + 2].map((opt) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: const Color(0xFF818CF8),
                    minimumSize: const Size(64, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    ),
                  ),
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    if (opt == answer) {
                      setState(() {
                        _rocketLaunched = true;
                        _mathScore += 10;
                      });
                      await PocketKidsService.addStars(10);
                      _speak("Rocket launched! Great math!");
                      await Future.delayed(const Duration(milliseconds: 800));
                      if (mounted) {
                        setState(() {
                          _rocketLaunched = false;
                          _mathNum1 = math.Random().nextInt(6) + 2;
                          _mathNum2 = math.Random().nextInt(6) + 1;
                        });
                      }
                    } else {
                      _speak("Try again!");
                    }
                  },
                  child: Text('$opt', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // --- 4. WORD BANK FLASHCARDS VIEW ---
  // =========================================================================
  Widget _buildFlashcardsView() {
    final card = _flashcards[_flashcardIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(card['emoji']!, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  Text(
                    card['word']!,
                    style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                  ),
                  Text(
                    card['phonics']!,
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    card['definition']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '"${card['example']!}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF78350F)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _speak('${card['word']!}. ${card['definition']!}'),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    label: const Text('LISTEN TO PRONUNCIATION', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
                onPressed: () {
                  setState(() {
                    _flashcardIndex = (_flashcardIndex - 1 + _flashcards.length) % _flashcards.length;
                  });
                },
              ),
              Text(
                '${_flashcardIndex + 1} / ${_flashcards.length}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 28),
                onPressed: () {
                  setState(() {
                    _flashcardIndex = (_flashcardIndex + 1) % _flashcards.length;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // --- 5. DAILY QUESTS VIEW ---
  // =========================================================================
  Widget _buildQuestsView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
      physics: const BouncingScrollPhysics(),
      itemCount: _dailyQuests.length,
      itemBuilder: (context, index) {
        final q = _dailyQuests[index];
        final done = q['done'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: done ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(done ? '✅' : '🎯', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q['title']!,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '+${q['stars']} Star Coins Reward ⭐',
                      style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (!done)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF78350F),
                    minimumSize: const Size(70, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    setState(() => q['done'] = true);
                    await PocketKidsService.addStars(q['stars'] as int);
                    _speak("Quest complete!");
                  },
                  child: const Text('CLAIM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MemoryCardItem {
  final String emoji;
  final String label;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryCardItem({
    required this.emoji,
    required this.label,
  });
}
