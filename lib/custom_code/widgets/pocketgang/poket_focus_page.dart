import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_learning_track_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pocket_spend_page.dart';
import 'pocketgang_diagram_hub_widget.dart';
import 'pocketgang_tool_storage.dart';

/// 🎓 Poket Focus: Unified All-in-One Student Productivity & Study Suite
/// Parallel flagship to Poket Spend — consolidates Focus Timer, Exam & Homework Planner,
/// Weekly Timetable, Active Recall Flashcards, Formula & Mistake Vault, and Habit Streaks
/// inside one rich multi-theme panel.
class PoketFocusPage extends StatefulWidget {
  final String? groupId;
  final String? groupName;
  final bool embeddedInGroup;
  final int initialTab;
  final PocketSpendCoupleTheme? coupleTheme;

  static final ValueNotifier<int> focusThemeNotifier = ValueNotifier<int>(0);

  static const List<PocketSpendCoupleTheme> focusThemes = [
    PocketSpendCoupleTheme(
      name: 'Obsidian Gold',
      isDark: true,
      bgGradient: [Color(0xFF090D16), Color(0xFF1E1B4B)],
      cardColor: Color(0xFF171F33),
      accent: Color(0xFFFFD700),
      secondaryAccent: Color(0xFF38BDF8),
      textColor: Colors.white,
      subTextColor: Colors.white60,
    ),
    PocketSpendCoupleTheme(
      name: 'Ocean Sky',
      isDark: true,
      bgGradient: [Color(0xFF071B2E), Color(0xFF0F294A)],
      cardColor: Color(0xFF132A40),
      accent: Color(0xFF38BDF8),
      secondaryAccent: Color(0xFF22D3EE),
      textColor: Colors.white,
      subTextColor: Color(0xFFBAE6FD),
    ),
    PocketSpendCoupleTheme(
      name: 'Emerald Mint',
      isDark: true,
      bgGradient: [Color(0xFF042F2E), Color(0xFF065F46)],
      cardColor: Color(0xFF0B3B36),
      accent: Color(0xFF34D399),
      secondaryAccent: Color(0xFFA7F3D0),
      textColor: Colors.white,
      subTextColor: Colors.white70,
    ),
    PocketSpendCoupleTheme(
      name: 'Cosmic Violet',
      isDark: true,
      bgGradient: [Color(0xFF1A0B2E), Color(0xFF3B0764)],
      cardColor: Color(0xFF1E133D),
      accent: Color(0xFFC084FC),
      secondaryAccent: Color(0xFF22D3EE),
      textColor: Colors.white,
      subTextColor: Color(0xFFE9D5FF),
    ),
    PocketSpendCoupleTheme(
      name: 'Clean Light',
      isDark: false,
      bgGradient: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
      cardColor: Colors.white,
      accent: Color(0xFF0F172A),
      secondaryAccent: Color(0xFF10B981),
      textColor: Color(0xFF0F172A),
      subTextColor: Color(0xFF64748B),
    ),
    PocketSpendCoupleTheme(
      name: 'Daylight Mint',
      isDark: false,
      bgGradient: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
      cardColor: Colors.white,
      accent: Color(0xFF059669),
      secondaryAccent: Color(0xFF10B981),
      textColor: Color(0xFF064E3B),
      subTextColor: Color(0xFF047857),
    ),
    PocketSpendCoupleTheme(
      name: 'Blush Light',
      isDark: false,
      bgGradient: [Color(0xFFFFF1F5), Color(0xFFFCE7F3)],
      cardColor: Colors.white,
      accent: Color(0xFFE11D48),
      secondaryAccent: Color(0xFFF43F5E),
      textColor: Color(0xFF4C0519),
      subTextColor: Color(0xFF9F1239),
    ),
  ];

  const PoketFocusPage({
    super.key,
    this.groupId,
    this.groupName,
    this.embeddedInGroup = false,
    this.initialTab = 0,
    this.coupleTheme,
  });

  @override
  State<PoketFocusPage> createState() => _PoketFocusPageState();
}

class _PoketFocusPageState extends State<PoketFocusPage> {
  static const List<String> _subjects = [
    'English',
    'German',
    'Math',
    'Science',
    'Coding',
    'General',
  ];

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<Map<String, dynamic>> _defaultHabits = [
    {
      'id': 'h_revise',
      'title': 'Revise class notes (15m)',
      'done': false,
      'streak': 1
    },
    {
      'id': 'h_lang',
      'title': 'Daily language / vocab drill',
      'done': false,
      'streak': 1
    },
    {
      'id': 'h_practice',
      'title': 'Solve 10 practice questions',
      'done': false,
      'streak': 1
    },
  ];

  static const List<Map<String, dynamic>> _defaultFlashcards = [
    {
      'id': 'fc_1',
      'subject': 'English',
      'front': 'Resilient',
      'back': 'Able to bounce back quickly after setbacks.',
      'mastered': false,
    },
    {
      'id': 'fc_2',
      'subject': 'German',
      'front': 'die Konzentration',
      'back':
          'Focus / Concentration — Ich brauche Ruhe für gute Konzentration.',
      'mastered': false,
    },
    {
      'id': 'fc_3',
      'subject': 'Math',
      'front': 'Quadratic Formula',
      'back': 'x = (-b ± √(b² - 4ac)) / 2a',
      'mastered': false,
    },
  ];

  late int _tabIndex;
  bool _isSquadMode = false;
  int _themeIdx = 0;
  int _dailyTargetMins = 120;
  bool _isLoading = true;

  // Focus Timer State
  int _presetMinutes = 25;
  bool _isBreakMode = false;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  String _selectedSubject = 'English';
  Timer? _timer;

  // Planner / Vault sub-tabs
  int _plannerSubTab = 0; // 0: Exams & Homework, 1: Timetable
  int _selectedWeekday = DateTime.now().weekday - 1;
  int _vaultSubTab = 0; // 0: Flashcards, 1: Formula & Mistake Notes
  int _flashcardIndex = 0;
  bool _showCardBack = false;

  final TextEditingController _quickAddCtrl = TextEditingController();
  final FlutterTts _tts = FlutterTts();

  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> _timetable = [];
  List<Map<String, dynamic>> _habits = [];
  List<Map<String, dynamic>> _flashcards = [];
  List<Map<String, dynamic>> _notes = [];

  String get _uid {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  String get _scopeKey {
    if (widget.groupId != null && widget.groupId!.isNotEmpty && _isSquadMode) {
      return 'squad_${widget.groupId}';
    }
    return _isSquadMode ? 'squad_$_uid' : 'solo_$_uid';
  }

  PocketSpendCoupleTheme get _theme =>
      widget.coupleTheme ??
      PoketFocusPage.focusThemes[_themeIdx % PoketFocusPage.focusThemes.length];

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 4);
    _isSquadMode = widget.embeddedInGroup;
    _initData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quickAddCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getInt('poket_focus_theme_idx') ?? 0;
    final savedTarget = prefs.getInt('poket_focus_daily_target_$_uid') ?? 120;
    PoketFocusPage.focusThemeNotifier.value = savedTheme;

    if (mounted) {
      setState(() {
        _themeIdx = savedTheme;
        _dailyTargetMins = savedTarget;
      });
    }
    await _loadScopedData();
  }

  Future<void> _loadScopedData() async {
    final prefs = await SharedPreferences.getInstance();
    final useCloudGroup =
        _isSquadMode && widget.groupId != null && widget.groupId!.isNotEmpty;

    List<Map<String, dynamic>> decodeList(String? raw) {
      if (raw == null || raw.isEmpty) return [];
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(raw));
      } catch (_) {
        return [];
      }
    }

    List<Map<String, dynamic>> sessions;
    List<Map<String, dynamic>> exams;
    List<Map<String, dynamic>> timetable;
    List<Map<String, dynamic>> habits;
    List<Map<String, dynamic>> flashcards;
    List<Map<String, dynamic>> notes;

    if (useCloudGroup) {
      sessions = await PocketGangToolStorage.loadList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_sessions',
        memberCount: 2,
      );
      exams = await PocketGangToolStorage.loadList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_exams',
        memberCount: 2,
      );
      timetable = await PocketGangToolStorage.loadList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_timetable',
        memberCount: 2,
      );
      habits = await PocketGangToolStorage.loadList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_habits',
        memberCount: 2,
      );
      flashcards = await PocketGangToolStorage.loadList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_flashcards',
        memberCount: 2,
      );
      notes = await PocketGangToolStorage.loadList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_notes',
        memberCount: 2,
      );
    } else {
      sessions = decodeList(prefs.getString('poket_focus_sessions_$_scopeKey'));
      exams = decodeList(prefs.getString('poket_focus_exams_$_scopeKey'));
      timetable =
          decodeList(prefs.getString('poket_focus_timetable_$_scopeKey'));
      habits = decodeList(prefs.getString('poket_focus_habits_$_scopeKey'));
      flashcards =
          decodeList(prefs.getString('poket_focus_flashcards_$_scopeKey'));
      notes = decodeList(prefs.getString('poket_focus_notes_$_scopeKey'));
    }

    // Daily habit reset check if last reset date != today
    final lastHabitDate =
        prefs.getString('poket_focus_habit_date_$_scopeKey') ?? '';
    if (habits.isEmpty) {
      habits = _defaultHabits.map((e) => Map<String, dynamic>.from(e)).toList();
    } else if (lastHabitDate != _todayKey) {
      for (final h in habits) {
        h['done'] = false;
      }
      await prefs.setString('poket_focus_habit_date_$_scopeKey', _todayKey);
    }

    if (flashcards.isEmpty) {
      flashcards =
          _defaultFlashcards.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _exams = exams;
        _timetable = timetable;
        _habits = habits;
        _flashcards = flashcards;
        _notes = notes;
        _isLoading = false;
      });
    }
  }

  Future<void> _persist(String bucket, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('poket_focus_${bucket}_$_scopeKey', jsonEncode(data));
    if (bucket == 'habits') {
      await prefs.setString('poket_focus_habit_date_$_scopeKey', _todayKey);
    }
    if (_isSquadMode && widget.groupId != null && widget.groupId!.isNotEmpty) {
      await PocketGangToolStorage.saveList(
        groupId: widget.groupId!,
        activityType: 'poket_focus_$bucket',
        title: 'Poket Focus $bucket',
        userId: _uid,
        memberCount: 2,
        items: data,
      );
    }
  }

  Future<void> _cycleTheme() async {
    HapticFeedback.selectionClick();
    final nextIdx = (_themeIdx + 1) % PoketFocusPage.focusThemes.length;
    PoketFocusPage.focusThemeNotifier.value = nextIdx;
    setState(() => _themeIdx = nextIdx);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('poket_focus_theme_idx', nextIdx);
  }

  int get _todayFocusedMins {
    return _sessions
        .where((s) => s['date'] == _todayKey)
        .fold<int>(0, (sum, s) => sum + ((s['minutes'] as num?)?.toInt() ?? 0));
  }

  int get _totalFocusedMins {
    return _sessions.fold<int>(
        0, (sum, s) => sum + ((s['minutes'] as num?)?.toInt() ?? 0));
  }

  int get _studyStreakDays {
    if (_sessions.isEmpty) return 0;
    final dates = _sessions
        .map((s) => s['date']?.toString() ?? '')
        .where((d) => d.isNotEmpty)
        .toSet();
    int streak = 0;
    DateTime cursor = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final k =
          '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      if (dates.contains(k)) {
        streak++;
      } else if (i > 0) {
        break;
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void _setTimerPreset(int mins, {bool isBreak = false}) {
    _timer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      _isRunning = false;
      _isBreakMode = isBreak;
      _presetMinutes = mins;
      _remainingSeconds = mins * 60;
    });
  }

  void _toggleTimer() {
    HapticFeedback.selectionClick();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        if (!_isBreakMode) {
          _recordSession(_presetMinutes);
        }
        setState(() {
          _isRunning = false;
          _isBreakMode = !_isBreakMode;
          _presetMinutes = _isBreakMode ? 5 : 25;
          _remainingSeconds = _presetMinutes * 60;
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _recordSession(int minutes) async {
    if (minutes <= 0) return;
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'subject': _selectedSubject,
      'minutes': minutes,
      'date': _todayKey,
      'created_at': DateTime.now().toIso8601String(),
      'uid': _uid,
    };
    final updated = [entry, ..._sessions];
    setState(() => _sessions = updated);
    await _persist('sessions', updated);
  }

  Future<void> _speakText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.setLanguage(PocketLearningTrackService.ttsLocale);
      await _tts.setSpeechRate(0.46);
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = _theme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: t.bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.embeddedInGroup
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: t.textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Poket Focus',
                  style: GoogleFonts.outfit(
                    color: t.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: _showTargetMinutesDialog,
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 4, top: 10, bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: t.cardColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: t.textColor.withValues(alpha: 0.14)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_dailyTargetMins}m Goal',
                        style: GoogleFonts.outfit(
                          color: t.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cycleTheme,
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            t.accent.withValues(alpha: 0.22),
                            t.secondaryAccent.withValues(alpha: 0.14),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: t.accent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.palette_rounded,
                              color: t.accent, size: 17),
                          const SizedBox(width: 5),
                          Text(
                            t.name,
                            style: GoogleFonts.outfit(
                              color: t.textColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: t.accent))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: t.cardColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: t.textColor.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeChip(
                              label: '🎓 Solo Study',
                              selected: !_isSquadMode,
                              onTap: () async {
                                setState(() => _isSquadMode = false);
                                await _loadScopedData();
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildModeChip(
                              label: '👥 Study Squad',
                              selected: _isSquadMode,
                              onTap: () async {
                                setState(() => _isSquadMode = true);
                                await _loadScopedData();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _tabIndex,
                      children: [
                        _buildFocusTimerTab(),
                        _buildTasksOnlyTab(),
                        _buildScheduleOnlyTab(),
                        PocketGangDiagramHubWidget(
                          groupId: _scopeKey,
                          groupName: 'Poket Focus',
                          currentUserId: _uid,
                          coupleTheme: t,
                        ),
                        _buildHabitsTab(),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: (_tabIndex == 1 || _tabIndex == 2)
            ? FloatingActionButton.extended(
                backgroundColor: t.accent,
                foregroundColor: t.onAccentTextColor,
                onPressed: _openQuickContextualAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  _tabIndex == 1 ? 'Add Task' : 'Add Slot',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                ),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
          backgroundColor: t.cardColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: t.accent,
          unselectedItemColor: t.subTextColor,
          selectedLabelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11.5),
          unselectedLabelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.timer_rounded), label: 'Focus'),
            BottomNavigationBarItem(
                icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
            BottomNavigationBarItem(
                icon: Icon(Icons.hub_rounded), label: 'Diagram'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_fire_department_rounded),
                label: 'Habits'),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final t = _theme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? t.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: selected ? t.onAccentTextColor : t.subTextColor,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _showTargetMinutesDialog() async {
    final t = _theme;
    final options = [60, 90, 120, 180, 240];
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Daily Focus Target',
            style: GoogleFonts.outfit(
                color: t.textColor, fontWeight: FontWeight.w800)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((m) {
            final sel = _dailyTargetMins == m;
            return ChoiceChip(
              label: Text(
                  '${m}m (${(m / 60).toStringAsFixed(m % 60 == 0 ? 0 : 1)}h)'),
              selected: sel,
              selectedColor: t.accent,
              labelStyle: TextStyle(
                color: sel ? t.onAccentTextColor : t.textColor,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('poket_focus_daily_target_$_uid', m);
                if (mounted) setState(() => _dailyTargetMins = m);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openQuickContextualAdd() {
    if (_tabIndex == 2) {
      _openAddTimetableDialog();
    } else {
      _openAddExamDialog();
    }
  }

  Widget _buildTasksOnlyTab() {
    final t = _theme;
    return _exams.isEmpty
        ? Center(
            child: Text(
              'No tasks or exams yet.\nTap + Add Task below!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: t.subTextColor, fontSize: 13),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: _exams.length,
            itemBuilder: (_, idx) => _buildExamCard(_exams[idx]),
          );
  }

  Widget _buildScheduleOnlyTab() {
    final t = _theme;
    final daySlots = _timetable
        .where((s) => (s['weekday'] as num?)?.toInt() == _selectedWeekday)
        .toList();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: List.generate(_weekdays.length, (i) {
              final sel = _selectedWeekday == i;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_weekdays[i]),
                  selected: sel,
                  selectedColor: t.accent,
                  backgroundColor: t.cardColor,
                  labelStyle: GoogleFonts.outfit(
                    color: sel ? t.onAccentTextColor : t.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedWeekday = i),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: daySlots.isEmpty
              ? Center(
                  child: Text(
                    'No study blocks for ${_weekdays[_selectedWeekday]}.\nTap + Add Slot to schedule!',
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.inter(color: t.subTextColor, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: daySlots.length,
                  itemBuilder: (_, idx) {
                    final slot = daySlots[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            t.cardColor,
                            t.cardColor.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: t.accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              slot['time']?.toString() ?? '09:00',
                              style: GoogleFonts.outfit(
                                color: t.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              slot['title']?.toString() ?? '',
                              style: GoogleFonts.outfit(
                                color: t.textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: t.subTextColor, size: 18),
                            onPressed: () async {
                              final updated = List<Map<String, dynamic>>.from(
                                  _timetable)
                                ..removeWhere((s) => s['id'] == slot['id']);
                              setState(() => _timetable = updated);
                              await _persist('timetable', updated);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHabitsTab() => _buildTodayDashboardTab();

  // ---------------------------------------------------------------------------
  // 1. TODAY DASHBOARD
  // ---------------------------------------------------------------------------
  Widget _buildTodayDashboardTab() {
    final t = _theme;
    final todayMins = _todayFocusedMins;
    final pct = (_dailyTargetMins > 0 ? todayMins / _dailyTargetMins : 0.0)
        .clamp(0.0, 1.0);
    final pendingExams = _exams.where((e) => e['done'] != true).toList();
    final habitsDone = _habits.where((h) => h['done'] == true).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      children: [
        // Hero Focus Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: t.borderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 8,
                        backgroundColor: t.textColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(t.accent),
                      ),
                    ),
                    Text(
                      '${(pct * 100).round()}%',
                      style: GoogleFonts.outfit(
                        color: t.textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Study Focus',
                      style: GoogleFonts.outfit(
                        color: t.subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${todayMins}m / ${_dailyTargetMins}m',
                      style: GoogleFonts.outfit(
                        color: t.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: t.accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔥 $_studyStreakDays day streak',
                            style: GoogleFonts.outfit(
                              color: t.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _tabIndex = 1),
                          child: Text(
                            'Start Timer ➔',
                            style: GoogleFonts.outfit(
                              color: t.secondaryAccent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
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
        ),
        const SizedBox(height: 14),

        // Quick Add Homework / Habit
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quickAddCtrl,
                  style: TextStyle(color: t.textColor, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Quick add daily study habit...',
                    hintStyle: TextStyle(color: t.subTextColor, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_rounded, color: t.accent),
                onPressed: () async {
                  final text = _quickAddCtrl.text.trim();
                  if (text.isEmpty) return;
                  _quickAddCtrl.clear();
                  final updated = [
                    {
                      'id': 'hab_${DateTime.now().millisecondsSinceEpoch}',
                      'title': text,
                      'done': false,
                      'streak': 1,
                    },
                    ..._habits,
                  ];
                  setState(() => _habits = updated);
                  await _persist('habits', updated);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Daily Study Habits (Consolidated seamlessly)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Daily Study Habits ($habitsDone/${_habits.length})',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Resets daily',
              style: GoogleFonts.inter(color: t.subTextColor, fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._habits.asMap().entries.map((e) {
          final idx = e.key;
          final h = e.value;
          final done = h['done'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: t.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color:
                      done ? t.accent.withValues(alpha: 0.45) : t.borderColor),
            ),
            child: CheckboxListTile(
              value: done,
              activeColor: t.accent,
              checkColor: t.onAccentTextColor,
              title: Text(
                h['title']?.toString() ?? '',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                'Streak: ${h['streak'] ?? 1}d',
                style: GoogleFonts.inter(color: t.subTextColor, fontSize: 11),
              ),
              secondary: IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: t.subTextColor, size: 18),
                onPressed: () async {
                  final copy = List<Map<String, dynamic>>.from(_habits)
                    ..removeAt(idx);
                  setState(() => _habits = copy);
                  await _persist('habits', copy);
                },
              ),
              onChanged: (v) async {
                final copy =
                    _habits.map((x) => Map<String, dynamic>.from(x)).toList();
                final prevDone = copy[idx]['done'] == true;
                copy[idx]['done'] = v == true;
                if (!prevDone && v == true) {
                  copy[idx]['streak'] =
                      ((copy[idx]['streak'] as num?)?.toInt() ?? 0) + 1;
                }
                setState(() => _habits = copy);
                await _persist('habits', copy);
              },
            ),
          );
        }),
        const SizedBox(height: 14),

        // Upcoming Exams & Deadlines Preview
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Upcoming Exams & Homework',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _tabIndex = 2),
              child: Text('Open Planner',
                  style: GoogleFonts.outfit(
                      color: t.accent, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        if (pendingExams.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.borderColor),
            ),
            child: Text(
              'No pending exams or homework. Tap + Add to plan your study schedule!',
              style: GoogleFonts.inter(color: t.subTextColor, fontSize: 12.5),
            ),
          )
        else
          ...pendingExams.take(3).map((ex) => _buildExamCard(ex)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. FOCUS POMODORO & DEEP WORK TAB
  // ---------------------------------------------------------------------------
  Widget _buildFocusTimerTab() {
    final t = _theme;
    final total = _presetMinutes * 60;
    final progress = total > 0 ? 1.0 - (_remainingSeconds / total) : 0.0;
    final mins = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // Preset Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _presetPill('25m Pomodoro', !_isBreakMode && _presetMinutes == 25,
                  () => _setTimerPreset(25)),
              const SizedBox(width: 8),
              _presetPill(
                  '50m Deep Work',
                  !_isBreakMode && _presetMinutes == 50,
                  () => _setTimerPreset(50)),
              const SizedBox(width: 8),
              _presetPill('15m Sprint', !_isBreakMode && _presetMinutes == 15,
                  () => _setTimerPreset(15)),
              const SizedBox(width: 8),
              _presetPill('5m Break', _isBreakMode && _presetMinutes == 5,
                  () => _setTimerPreset(5, isBreak: true)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Subject selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _subjects.map((sub) {
              final sel = _selectedSubject == sub;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(sub),
                  selected: sel,
                  selectedColor: t.secondaryAccent,
                  backgroundColor: t.cardColor,
                  labelStyle: GoogleFonts.outfit(
                    color: sel ? Colors.black : t.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedSubject = sub),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // Clock Circle Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.borderColor),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 11,
                        backgroundColor: t.textColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                            _isBreakMode ? t.secondaryAccent : t.accent),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$mins:$secs',
                          style: GoogleFonts.outfit(
                            color: t.textColor,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _isBreakMode
                              ? 'RECHARGE BREAK'
                              : _selectedSubject.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: t.subTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(_isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded),
                    label: Text(_isRunning ? 'Pause' : 'Start Focus',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.accent,
                      foregroundColor: t.onAccentTextColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _setTimerPreset(_presetMinutes, isBreak: _isBreakMode),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.textColor,
                      side: BorderSide(color: t.borderColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_isBreakMode) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final elapsed =
                        ((_presetMinutes * 60 - _remainingSeconds) ~/ 60)
                            .clamp(1, _presetMinutes);
                    await _recordSession(elapsed);
                    _setTimerPreset(_presetMinutes);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '✅ Logged ${elapsed}m for $_selectedSubject!'),
                          backgroundColor: t.accent,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Finish & Log Session Now',
                    style: GoogleFonts.outfit(
                      color: t.secondaryAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Sessions (${_sessions.length})',
          style: GoogleFonts.outfit(
            color: t.textColor,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ..._sessions.take(6).map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: t.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${s['subject'] ?? 'Study'} • ${s['date'] ?? ''}',
                    style: GoogleFonts.outfit(
                      color: t.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '+${s['minutes'] ?? 0}m',
                    style: GoogleFonts.outfit(
                      color: t.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _presetPill(String label, bool active, VoidCallback onTap) {
    final t = _theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? t.accent : t.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? t.accent : t.borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? t.onAccentTextColor : t.textColor,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. PLANNER TAB (EXAMS & HOMEWORK + WEEKLY TIMETABLE)
  // ---------------------------------------------------------------------------
  Widget _buildPlannerTab() {
    final t = _theme;
    final daySlots = _timetable
        .where((s) => (s['weekday'] as num?)?.toInt() == _selectedWeekday)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              _subTabChip(
                  '📝 Exams & Tasks (${_exams.length})',
                  _plannerSubTab == 0,
                  () => setState(() => _plannerSubTab = 0)),
              const SizedBox(width: 8),
              _subTabChip('📅 Timetable', _plannerSubTab == 1,
                  () => setState(() => _plannerSubTab = 1)),
            ],
          ),
        ),
        if (_plannerSubTab == 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_weekdays.length, (i) {
                final sel = _selectedWeekday == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_weekdays[i]),
                    selected: sel,
                    selectedColor: t.accent,
                    backgroundColor: t.cardColor,
                    labelStyle: GoogleFonts.outfit(
                      color: sel ? t.onAccentTextColor : t.textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedWeekday = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: _plannerSubTab == 0
              ? (_exams.isEmpty
                  ? Center(
                      child: Text(
                        'No exams or assignments added.\nTap + Add Exam/Task below.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: t.subTextColor, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: _exams.length,
                      itemBuilder: (_, idx) => _buildExamCard(_exams[idx]),
                    ))
              : (daySlots.isEmpty
                  ? Center(
                      child: Text(
                        'No classes/study blocks for ${_weekdays[_selectedWeekday]}.\nTap + Add Slot to schedule!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: t.subTextColor, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: daySlots.length,
                      itemBuilder: (_, idx) {
                        final slot = daySlots[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: t.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: t.borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: t.accent.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  slot['time']?.toString() ?? '09:00',
                                  style: GoogleFonts.outfit(
                                    color: t.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot['subject']?.toString() ?? 'Study',
                                      style: GoogleFonts.outfit(
                                        color: t.textColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if ((slot['topic']?.toString() ?? '')
                                        .isNotEmpty)
                                      Text(
                                        slot['topic'].toString(),
                                        style: GoogleFonts.inter(
                                          color: t.subTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: t.subTextColor, size: 18),
                                onPressed: () async {
                                  final copy = _timetable
                                      .where((x) => x['id'] != slot['id'])
                                      .toList();
                                  setState(() => _timetable = copy);
                                  await _persist('timetable', copy);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )),
        ),
      ],
    );
  }

  Widget _buildExamCard(Map<String, dynamic> item) {
    final t = _theme;
    final done = item['done'] == true;
    final due =
        DateTime.tryParse(item['due_date']?.toString() ?? '') ?? DateTime.now();
    final nowDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final daysLeft = due.difference(nowDay).inDays;
    final badge = daysLeft <= 0
        ? 'Today'
        : (daysLeft == 1 ? '1d left' : '${daysLeft}d left');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Row(
        children: [
          Checkbox(
            value: done,
            activeColor: t.accent,
            checkColor: t.onAccentTextColor,
            onChanged: (v) async {
              final copy =
                  _exams.map((e) => Map<String, dynamic>.from(e)).toList();
              final targetIdx = copy.indexWhere((e) => e['id'] == item['id']);
              if (targetIdx != -1) {
                copy[targetIdx]['done'] = v == true;
                setState(() => _exams = copy);
                await _persist('exams', copy);
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']?.toString() ?? '',
                  style: GoogleFonts.outfit(
                    color: t.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${item['type'] ?? 'Exam'} • ${item['subject'] ?? 'General'}',
                  style:
                      GoogleFonts.inter(color: t.subTextColor, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: GoogleFonts.outfit(
                color: t.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: t.subTextColor, size: 18),
            onPressed: () async {
              final copy = _exams.where((e) => e['id'] != item['id']).toList();
              setState(() => _exams = copy);
              await _persist('exams', copy);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openAddExamDialog() async {
    final t = _theme;
    final titleCtrl = TextEditingController();
    String subject = _subjects.first;
    String kind = 'Exam';
    DateTime due = DateTime.now().add(const Duration(days: 3));

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => AlertDialog(
          backgroundColor: t.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Exam / Homework',
              style: GoogleFonts.outfit(
                  color: t.textColor, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  hintText: 'Title (e.g. Chapter 4 Quiz)',
                  hintStyle: TextStyle(color: t.subTextColor),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: subject,
                dropdownColor: t.cardColor,
                style: TextStyle(color: t.textColor),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setM(() => subject = v);
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: ['Exam', 'Homework', 'Revision'].map((k) {
                  final sel = kind == k;
                  return ChoiceChip(
                    label: Text(k),
                    selected: sel,
                    selectedColor: t.accent,
                    labelStyle: TextStyle(
                      color: sel ? t.onAccentTextColor : t.textColor,
                      fontSize: 11.5,
                    ),
                    onSelected: (_) => setM(() => kind = k),
                  );
                }).toList(),
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: due,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setM(() => due = picked);
                },
                icon: Icon(Icons.calendar_today_rounded,
                    color: t.accent, size: 16),
                label: Text('Due: ${due.day}/${due.month}/${due.year}',
                    style: TextStyle(color: t.accent)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: t.subTextColor))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: t.onAccentTextColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved == true && titleCtrl.text.trim().isNotEmpty) {
      final updated = [
        {
          'id': 'ex_${DateTime.now().millisecondsSinceEpoch}',
          'title': titleCtrl.text.trim(),
          'subject': subject,
          'type': kind,
          'due_date': due.toIso8601String(),
          'done': false,
        },
        ..._exams,
      ];
      setState(() => _exams = updated);
      await _persist('exams', updated);
    }
  }

  Future<void> _openAddTimetableDialog() async {
    final t = _theme;
    final topicCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00 AM');
    String subject = _subjects.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => AlertDialog(
          backgroundColor: t.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add ${_weekdays[_selectedWeekday]} Study Slot',
              style: GoogleFonts.outfit(
                  color: t.textColor, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeCtrl,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  labelText: 'Time (e.g. 09:00 AM)',
                  labelStyle: TextStyle(color: t.subTextColor),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: subject,
                dropdownColor: t.cardColor,
                style: TextStyle(color: t.textColor),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setM(() => subject = v);
                },
              ),
              TextField(
                controller: topicCtrl,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  labelText: 'Topic / Chapter',
                  labelStyle: TextStyle(color: t.subTextColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: t.subTextColor))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: t.onAccentTextColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved == true) {
      final updated = [
        ..._timetable,
        {
          'id': 'tt_${DateTime.now().millisecondsSinceEpoch}',
          'weekday': _selectedWeekday,
          'time':
              timeCtrl.text.trim().isEmpty ? '09:00 AM' : timeCtrl.text.trim(),
          'subject': subject,
          'topic': topicCtrl.text.trim(),
        }
      ];
      setState(() => _timetable = updated);
      await _persist('timetable', updated);
    }
  }

  // ---------------------------------------------------------------------------
  // 4. VAULT TAB (ACTIVE RECALL FLASHCARDS + FORMULA & MISTAKE NOTES)
  // ---------------------------------------------------------------------------
  Widget _buildVaultTab() {
    final t = _theme;
    final mastered = _flashcards.where((c) => c['mastered'] == true).length;
    final safeIdx = _flashcards.isEmpty
        ? 0
        : _flashcardIndex.clamp(0, _flashcards.length - 1);
    final currentCard = _flashcards.isNotEmpty ? _flashcards[safeIdx] : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              _subTabChip('🃏 Flashcards ($mastered/${_flashcards.length})',
                  _vaultSubTab == 0, () => setState(() => _vaultSubTab = 0)),
              const SizedBox(width: 8),
              _subTabChip('📐 Formulas & Notes (${_notes.length})',
                  _vaultSubTab == 1, () => setState(() => _vaultSubTab = 1)),
            ],
          ),
        ),
        Expanded(
          child: _vaultSubTab == 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
                  child: currentCard == null
                      ? Center(
                          child: Text(
                            'No flashcards yet. Tap + Add Card!',
                            style: GoogleFonts.inter(color: t.subTextColor),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                      () => _showCardBack = !_showCardBack);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: t.cardColor,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _showCardBack
                                          ? t.secondaryAccent
                                          : t.accent.withValues(alpha: 0.45),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: t.accent
                                                  .withValues(alpha: 0.16),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              currentCard['subject']
                                                      ?.toString() ??
                                                  'Study',
                                              style: GoogleFonts.outfit(
                                                color: t.accent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.volume_up_rounded,
                                                color: t.accent),
                                            onPressed: () => _speakText(
                                              (_showCardBack
                                                          ? currentCard['back']
                                                          : currentCard[
                                                              'front'])
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        _showCardBack
                                            ? 'ANSWER / EXPLANATION'
                                            : 'TAP CARD TO REVEAL',
                                        style: GoogleFonts.inter(
                                          color: _showCardBack
                                              ? t.secondaryAccent
                                              : t.subTextColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        (_showCardBack
                                                    ? currentCard['back']
                                                    : currentCard['front'])
                                                ?.toString() ??
                                            '',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          color: t.textColor,
                                          fontSize: _showCardBack ? 18 : 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => setState(() {
                                    _flashcardIndex = (_flashcardIndex -
                                            1 +
                                            _flashcards.length) %
                                        _flashcards.length;
                                    _showCardBack = false;
                                  }),
                                  icon: Icon(Icons.arrow_back_ios_rounded,
                                      color: t.textColor),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final copy = _flashcards
                                        .map(
                                            (e) => Map<String, dynamic>.from(e))
                                        .toList();
                                    copy[safeIdx]['mastered'] =
                                        !(copy[safeIdx]['mastered'] == true);
                                    setState(() => _flashcards = copy);
                                    await _persist('flashcards', copy);
                                  },
                                  icon: Icon(
                                    currentCard['mastered'] == true
                                        ? Icons.check_circle_rounded
                                        : Icons.star_outline_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    currentCard['mastered'] == true
                                        ? 'Mastered ✓'
                                        : 'Got It',
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        currentCard['mastered'] == true
                                            ? t.secondaryAccent
                                            : t.cardColor,
                                    foregroundColor:
                                        currentCard['mastered'] == true
                                            ? Colors.black
                                            : t.textColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() {
                                    _flashcardIndex = (_flashcardIndex + 1) %
                                        _flashcards.length;
                                    _showCardBack = false;
                                  }),
                                  icon: Icon(Icons.arrow_forward_ios_rounded,
                                      color: t.textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                )
              : (_notes.isEmpty
                  ? Center(
                      child: Text(
                        'Save formulas, grammar rules & mistake logs here.\nTap + Add Note below!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: t.subTextColor, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: _notes.length,
                      itemBuilder: (_, idx) {
                        final n = _notes[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: t.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: t.borderColor),
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
                                      color: t.accent.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      n['subject']?.toString() ?? 'Note',
                                      style: GoogleFonts.outfit(
                                        color: t.accent,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.volume_up_rounded,
                                        color: t.subTextColor, size: 18),
                                    onPressed: () => _speakText(
                                        n['content']?.toString() ?? ''),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: t.subTextColor, size: 18),
                                    onPressed: () async {
                                      final copy =
                                          List<Map<String, dynamic>>.from(
                                              _notes)
                                            ..removeAt(idx);
                                      setState(() => _notes = copy);
                                      await _persist('notes', copy);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                n['title']?.toString() ?? '',
                                style: GoogleFonts.outfit(
                                  color: t.textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['content']?.toString() ?? '',
                                style: GoogleFonts.inter(
                                  color: t.subTextColor,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
        ),
      ],
    );
  }

  Future<void> _openAddFlashcardDialog() async {
    final t = _theme;
    final frontCtrl = TextEditingController();
    final backCtrl = TextEditingController();
    String subject = _subjects.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => AlertDialog(
          backgroundColor: t.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('New Flashcard',
              style: GoogleFonts.outfit(
                  color: t.textColor, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: subject,
                dropdownColor: t.cardColor,
                style: TextStyle(color: t.textColor),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setM(() => subject = v);
                },
              ),
              TextField(
                controller: frontCtrl,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  labelText: 'Front (Question / Word)',
                  labelStyle: TextStyle(color: t.subTextColor),
                ),
              ),
              TextField(
                controller: backCtrl,
                maxLines: 2,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  labelText: 'Back (Answer / Formula)',
                  labelStyle: TextStyle(color: t.subTextColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: t.subTextColor))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: t.onAccentTextColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok == true &&
        frontCtrl.text.trim().isNotEmpty &&
        backCtrl.text.trim().isNotEmpty) {
      final updated = [
        {
          'id': 'fc_${DateTime.now().millisecondsSinceEpoch}',
          'subject': subject,
          'front': frontCtrl.text.trim(),
          'back': backCtrl.text.trim(),
          'mastered': false,
        },
        ..._flashcards,
      ];
      setState(() {
        _flashcards = updated;
        _flashcardIndex = 0;
        _showCardBack = false;
      });
      await _persist('flashcards', updated);
    }
  }

  Future<void> _openAddNoteDialog() async {
    final t = _theme;
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String subject = _subjects.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => AlertDialog(
          backgroundColor: t.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Formula / Mistake Note',
              style: GoogleFonts.outfit(
                  color: t.textColor, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: subject,
                dropdownColor: t.cardColor,
                style: TextStyle(color: t.textColor),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setM(() => subject = v);
                },
              ),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  labelText: 'Title (e.g. Bayes Theorem / German Cases)',
                  labelStyle: TextStyle(color: t.subTextColor),
                ),
              ),
              TextField(
                controller: contentCtrl,
                maxLines: 3,
                style: TextStyle(color: t.textColor),
                decoration: InputDecoration(
                  labelText: 'Key Formula / Mistake to Remember',
                  labelStyle: TextStyle(color: t.subTextColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: t.subTextColor))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: t.onAccentTextColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      final updated = [
        {
          'id': 'nt_${DateTime.now().millisecondsSinceEpoch}',
          'subject': subject,
          'title': titleCtrl.text.trim(),
          'content': contentCtrl.text.trim(),
        },
        ..._notes,
      ];
      setState(() => _notes = updated);
      await _persist('notes', updated);
    }
  }

  Widget _subTabChip(String label, bool active, VoidCallback onTap) {
    final t = _theme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          decoration: BoxDecoration(
            color: active ? t.accent : t.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? t.accent : t.borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: active ? t.onAccentTextColor : t.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. STATS TAB
  // ---------------------------------------------------------------------------
  Widget _buildStatsTab() {
    final t = _theme;
    final Map<String, int> bySubject = {};
    for (final s in _sessions) {
      final sub = s['subject']?.toString() ?? 'General';
      bySubject[sub] =
          (bySubject[sub] ?? 0) + ((s['minutes'] as num?)?.toInt() ?? 0);
    }
    final maxSub = bySubject.values.fold<int>(1, (a, b) => a > b ? a : b);
    final masteredCards =
        _flashcards.where((c) => c['mastered'] == true).length;
    final completedExams = _exams.where((e) => e['done'] == true).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _statTile(
                'Total Focus',
                '${(_totalFocusedMins / 60).toStringAsFixed(1)}h',
                '${_sessions.length} sessions',
                t.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                'Study Streak',
                '$_studyStreakDays Days',
                'Consistency score',
                t.secondaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statTile(
                'Cards Mastered',
                '$masteredCards/${_flashcards.length}',
                'Active recall',
                t.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                'Tasks Cleared',
                '$completedExams/${_exams.length}',
                'Exams & homework',
                t.secondaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Breakdown by Subject',
                style: GoogleFonts.outfit(
                  color: t.textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (bySubject.isEmpty)
                Text(
                  'Complete a focus session to see subject analytics.',
                  style:
                      GoogleFonts.inter(color: t.subTextColor, fontSize: 12.5),
                )
              else
                ...bySubject.entries.map((e) {
                  final frac = (e.value / maxSub).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key,
                                style: GoogleFonts.outfit(
                                    color: t.textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            Text('${e.value} mins',
                                style: GoogleFonts.outfit(
                                    color: t.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: frac,
                            minHeight: 7,
                            backgroundColor: t.textColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(t.accent),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statTile(String title, String value, String sub, Color color) {
    final t = _theme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(color: t.subTextColor, fontSize: 11.5)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(sub,
              style: GoogleFonts.inter(color: t.subTextColor, fontSize: 11)),
        ],
      ),
    );
  }
}
