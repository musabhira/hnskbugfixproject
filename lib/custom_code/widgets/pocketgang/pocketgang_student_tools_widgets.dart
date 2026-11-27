import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_spend_page.dart';
import 'pocketgang_tool_storage.dart';

/// 🧩 Clean standalone Scaffold wrapper so any PocketGang/Student tool
/// can be launched directly from ToolsPage or Home Favorites.
class PocketGangStandaloneToolPage extends StatelessWidget {
  final String title;
  final Widget child;

  const PocketGangStandaloneToolPage({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: child,
    );
  }
}

/// ⏱️ 1. Study Focus Timer (Pomodoro + Daily Study Minutes & Streak)
class PocketGangStudyTimerWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangStudyTimerWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.memberCount,
    this.coupleTheme,
  });

  @override
  State<PocketGangStudyTimerWidget> createState() =>
      _PocketGangStudyTimerWidgetState();
}

class _PocketGangStudyTimerWidgetState
    extends State<PocketGangStudyTimerWidget> {
  static const int _focusSeconds = 25 * 60;
  static const int _breakSeconds = 5 * 60;

  bool _isFocusMode = true;
  int _remainingSeconds = _focusSeconds;
  bool _isRunning = false;
  Timer? _timer;
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final items = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: 'study_timer_sessions',
      memberCount: widget.memberCount,
    );
    if (mounted) {
      setState(() {
        _sessions = items;
        _loading = false;
      });
    }
  }

  Future<void> _logSession(int minutes) async {
    final now = DateTime.now();
    final updated = [
      {
        'id': now.millisecondsSinceEpoch.toString(),
        'minutes': minutes,
        'mode': _isFocusMode ? 'Focus' : 'Break',
        'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'user_id': widget.currentUserId,
      },
      ..._sessions,
    ];
    setState(() => _sessions = updated);
    await PocketGangToolStorage.saveList(
      groupId: widget.groupId,
      activityType: 'study_timer_sessions',
      title: 'Study Timer Sessions',
      userId: widget.currentUserId,
      memberCount: widget.memberCount,
      items: updated,
    );
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
        if (_isFocusMode) {
          _logSession(25);
        }
        setState(() {
          _isRunning = false;
          _isFocusMode = !_isFocusMode;
          _remainingSeconds = _isFocusMode ? _focusSeconds : _breakSeconds;
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isFocusMode ? _focusSeconds : _breakSeconds;
    });
  }

  void _switchMode(bool focus) {
    _timer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      _isRunning = false;
      _isFocusMode = focus;
      _remainingSeconds = focus ? _focusSeconds : _breakSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bg = theme?.bgGradient.first ?? const Color(0xFF0B1120);
    final cardBg = theme?.surfaceAltColor ?? const Color(0xFF141D2E);
    final accent = theme?.accent ?? const Color(0xFF38BDF8);
    final textColor = theme?.textColor ?? Colors.white;
    final subColor = theme?.subTextColor ?? Colors.white60;

    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayMinutes = _sessions
        .where((s) => s['date'] == todayKey)
        .fold<int>(0, (sum, s) => sum + ((s['minutes'] as num?)?.toInt() ?? 0));
    final totalSessions = _sessions.length;

    final totalForMode = _isFocusMode ? _focusSeconds : _breakSeconds;
    final progress = 1.0 - (_remainingSeconds / totalForMode);
    final mins = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      color: bg,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _modeChip('📚 Focus 25m', _isFocusMode, accent,
                        () => _switchMode(true)),
                    const SizedBox(width: 8),
                    _modeChip('☕ Break 5m', !_isFocusMode,
                        const Color(0xFF10B981), () => _switchMode(false)),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 170,
                              height: 170,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                strokeWidth: 10,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation(
                                  _isFocusMode
                                      ? accent
                                      : const Color(0xFF10B981),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$mins:$secs',
                                  style: GoogleFonts.outfit(
                                    color: textColor,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  _isFocusMode ? 'STAY FOCUSED' : 'RECHARGE',
                                  style: GoogleFonts.inter(
                                    color: subColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _toggleTimer,
                            icon: Icon(_isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                            label: Text(_isRunning ? 'Pause' : 'Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _resetTimer,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _statBox(
                        cardBg,
                        'Today Studied',
                        '${todayMinutes}m',
                        accent,
                        textColor,
                        subColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statBox(
                        cardBg,
                        'Total Sessions',
                        '$totalSessions',
                        const Color(0xFF10B981),
                        textColor,
                        subColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _modeChip(
      String label, bool active, Color accent, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? accent.withValues(alpha: 0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? accent : Colors.white12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: active ? accent : Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(Color cardBg, String label, String val, Color accent,
      Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: subColor, fontSize: 11.5)),
          const SizedBox(height: 4),
          Text(val,
              style: GoogleFonts.outfit(
                  color: accent, fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

/// 🗓️ 2. Study, Homework & Exam Countdown Tracker
class PocketGangExamTrackerWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangExamTrackerWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.memberCount,
    this.coupleTheme,
  });

  @override
  State<PocketGangExamTrackerWidget> createState() =>
      _PocketGangExamTrackerWidgetState();
}

class _PocketGangExamTrackerWidgetState
    extends State<PocketGangExamTrackerWidget> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: 'student_exam_tracker',
      memberCount: widget.memberCount,
    );
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _save(List<Map<String, dynamic>> updated) async {
    setState(() => _items = updated);
    await PocketGangToolStorage.saveList(
      groupId: widget.groupId,
      activityType: 'student_exam_tracker',
      title: 'Study & Exam Tracker',
      userId: widget.currentUserId,
      memberCount: widget.memberCount,
      items: updated,
    );
  }

  Future<void> _addItemDialog() async {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    String type = 'Exam';
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF161924),
          title: Text('Add Study Task / Exam',
              style: GoogleFonts.outfit(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Maths Unit Test)',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              TextField(
                controller: subjectCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Subject / Notes',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Exam', 'Homework', 'Class'].map((t) {
                  final sel = type == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: sel,
                      onSelected: (_) => setModalState(() => type = t),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setModalState(() => dueDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(
                    'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      await _save([
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': titleCtrl.text.trim(),
          'subject': subjectCtrl.text.trim(),
          'type': type,
          'due_date': dueDate.toIso8601String(),
          'done': false,
        },
        ..._items,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bg = theme?.bgGradient.first ?? const Color(0xFF0B1120);
    final cardBg = theme?.surfaceAltColor ?? const Color(0xFF141D2E);
    final accent = theme?.accent ?? const Color(0xFFFFD700);
    final textColor = theme?.textColor ?? Colors.white;
    final subColor = theme?.subTextColor ?? Colors.white60;

    return Container(
      color: bg,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('STUDY, HOMEWORK & EXAMS',
                          style: GoogleFonts.outfit(
                              color: subColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800)),
                      ElevatedButton.icon(
                        onPressed: _addItemDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Text(
                            'No exams or homework added yet.\nTap + Add to track your schedule!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: subColor, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _items.length,
                          itemBuilder: (_, idx) {
                            final item = _items[idx];
                            final done = item['done'] == true;
                            final due = DateTime.tryParse(
                                    item['due_date']?.toString() ?? '') ??
                                DateTime.now();
                            final daysLeft = due
                                .difference(DateTime(DateTime.now().year,
                                    DateTime.now().month, DateTime.now().day))
                                .inDays;
                            final badgeText = daysLeft <= 0
                                ? 'Today'
                                : daysLeft == 1
                                    ? '1 day'
                                    : '$daysLeft days';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: done,
                                    activeColor: const Color(0xFF10B981),
                                    onChanged: (v) {
                                      final copy = _items
                                          .map((e) =>
                                              Map<String, dynamic>.from(e))
                                          .toList();
                                      copy[idx]['done'] = v == true;
                                      _save(copy);
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']?.toString() ?? '',
                                          style: GoogleFonts.outfit(
                                            color: textColor,
                                            fontWeight: FontWeight.w700,
                                            decoration: done
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if ((item['subject']?.toString() ?? '')
                                            .isNotEmpty)
                                          Text(
                                            '${item['type']} • ${item['subject']}',
                                            style: GoogleFonts.inter(
                                                color: subColor, fontSize: 11.5),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: GoogleFonts.outfit(
                                          color: accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.white38, size: 18),
                                    onPressed: () {
                                      final copy = List<Map<String, dynamic>>.from(
                                          _items)
                                        ..removeAt(idx);
                                      _save(copy);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// 🃏 3. Quick Revision Flashcards (Words, Formulas & Notes Vault)
class PocketGangFlashcardsWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangFlashcardsWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.memberCount,
    this.coupleTheme,
  });

  @override
  State<PocketGangFlashcardsWidget> createState() =>
      _PocketGangFlashcardsWidgetState();
}

class _PocketGangFlashcardsWidgetState
    extends State<PocketGangFlashcardsWidget> {
  static const List<Map<String, dynamic>> _starterCards = [
    {
      'id': 'seed_1',
      'front': 'Resilient',
      'back': 'Able to recover quickly from difficulties (വേഗത്തിൽ തിരിച്ചുവരാൻ കഴിവുള്ള)',
      'mastered': false,
    },
    {
      'id': 'seed_2',
      'front': 'Consistency beats intensity',
      'back': 'Daily small practice beats rare cramming!',
      'mastered': false,
    },
    {
      'id': 'seed_3',
      'front': 'Eloquence',
      'back': 'Fluent, persuasive speaking or writing',
      'mastered': false,
    },
  ];

  List<Map<String, dynamic>> _cards = [];
  int _index = 0;
  bool _showBack = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: 'student_flashcards',
      memberCount: widget.memberCount,
    );
    if (mounted) {
      setState(() {
        _cards = items.isNotEmpty
            ? items
            : _starterCards.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    }
  }

  Future<void> _save(List<Map<String, dynamic>> updated) async {
    setState(() => _cards = updated);
    await PocketGangToolStorage.saveList(
      groupId: widget.groupId,
      activityType: 'student_flashcards',
      title: 'Quick Revision Flashcards',
      userId: widget.currentUserId,
      memberCount: widget.memberCount,
      items: updated,
    );
  }

  Future<void> _addCardDialog() async {
    final frontCtrl = TextEditingController();
    final backCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161924),
        title: Text('New Flashcard',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Front (Word / Question / Formula)',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            TextField(
              controller: backCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Back (Meaning / Answer)',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add Card')),
        ],
      ),
    );
    if (ok == true &&
        frontCtrl.text.trim().isNotEmpty &&
        backCtrl.text.trim().isNotEmpty) {
      await _save([
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'front': frontCtrl.text.trim(),
          'back': backCtrl.text.trim(),
          'mastered': false,
        },
        ..._cards,
      ]);
      setState(() {
        _index = 0;
        _showBack = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bg = theme?.bgGradient.first ?? const Color(0xFF0B1120);
    final cardBg = theme?.surfaceAltColor ?? const Color(0xFF141D2E);
    final accent = theme?.accent ?? const Color(0xFFFFD700);
    final textColor = theme?.textColor ?? Colors.white;
    final subColor = theme?.subTextColor ?? Colors.white60;

    if (_loading) {
      return Container(
          color: bg, child: const Center(child: CircularProgressIndicator()));
    }

    final safeIndex = _cards.isEmpty ? 0 : _index.clamp(0, _cards.length - 1);
    final current = _cards.isNotEmpty ? _cards[safeIndex] : null;
    final masteredCount = _cards.where((c) => c['mastered'] == true).length;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MASTERED: $masteredCount / ${_cards.length}',
                style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
              ElevatedButton.icon(
                onPressed: _addCardDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (current != null)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showBack = !_showBack);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _showBack
                          ? const Color(0xFF10B981)
                          : accent.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showBack ? 'ANSWER / MEANING' : 'TAP TO FLIP',
                        style: GoogleFonts.inter(
                          color: _showBack ? const Color(0xFF10B981) : subColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (_showBack ? current['back'] : current['front'])
                                ?.toString() ??
                            '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: _showBack ? 18 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          if (current != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _index = (_index - 1 + _cards.length) % _cards.length;
                      _showBack = false;
                    });
                  },
                  icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final copy = _cards
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList();
                    copy[safeIndex]['mastered'] =
                        !(copy[safeIndex]['mastered'] == true);
                    _save(copy);
                  },
                  icon: Icon(
                    current['mastered'] == true
                        ? Icons.check_circle_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                  ),
                  label: Text(current['mastered'] == true
                      ? 'Mastered ✓'
                      : 'Mark Mastered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current['mastered'] == true
                        ? const Color(0xFF10B981)
                        : Colors.white12,
                    foregroundColor:
                        current['mastered'] == true ? Colors.black : textColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _index = (_index + 1) % _cards.length;
                      _showBack = false;
                    });
                  },
                  icon: Icon(Icons.arrow_forward_ios_rounded, color: textColor),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
