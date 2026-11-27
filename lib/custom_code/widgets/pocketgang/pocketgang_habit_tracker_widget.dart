import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_spend_page.dart';
import 'pocketgang_tool_storage.dart';

/// 🎯 Shared Goal & Habit Tracker (Solo = Local, 2+ Members = Global Sync)
class PocketGangHabitTrackerWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final int memberCount;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangHabitTrackerWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    this.memberCount = 1,
    this.coupleTheme,
  });

  @override
  State<PocketGangHabitTrackerWidget> createState() =>
      _PocketGangHabitTrackerWidgetState();
}

class _PocketGangHabitTrackerWidgetState
    extends State<PocketGangHabitTrackerWidget> {
  static const String _activityType = 'gang_habit_tracker';
  final TextEditingController _habitController = TextEditingController();
  List<Map<String, dynamic>> _habits = [];
  bool _isLoading = true;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final loaded = await PocketGangToolStorage.loadList(
      groupId: widget.groupId,
      activityType: _activityType,
      memberCount: widget.memberCount,
    );
    if (!mounted) return;
    if (loaded.isEmpty) {
      setState(() {
        _habits = [
          {
            'id': 'h_english',
            'title': '10 min English Speaking',
            'streak': 0,
            'completedDates': <String>[],
          },
          {
            'id': 'h_savings',
            'title': 'Daily Savings Check-in',
            'streak': 0,
            'completedDates': <String>[],
          },
          {
            'id': 'h_workout',
            'title': '20 min Workout / Walk',
            'streak': 0,
            'completedDates': <String>[],
          },
        ];
        _isLoading = false;
      });
    } else {
      setState(() {
        _habits = loaded;
        _isLoading = false;
      });
    }
  }

  Future<void> _persist() async {
    await PocketGangToolStorage.saveList(
      groupId: widget.groupId,
      activityType: _activityType,
      title: 'Shared Goal & Habit Tracker',
      userId: widget.currentUserId,
      memberCount: widget.memberCount,
      items: _habits,
    );
  }

  Future<void> _addHabit() async {
    final title = _habitController.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.mediumImpact();
    _habitController.clear();
    setState(() {
      _habits.insert(0, {
        'id': 'h_${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'streak': 0,
        'completedDates': <String>[],
      });
    });
    await _persist();
  }

  Future<void> _toggleToday(int index) async {
    HapticFeedback.selectionClick();
    final item = Map<String, dynamic>.from(_habits[index]);
    final dates = List<String>.from(item['completedDates'] ?? []);
    final today = _todayKey;
    int streak = (item['streak'] as num?)?.toInt() ?? 0;

    if (dates.contains(today)) {
      dates.remove(today);
      streak = (streak - 1).clamp(0, 9999);
    } else {
      dates.add(today);
      streak += 1;
    }
    item['completedDates'] = dates;
    item['streak'] = streak;
    setState(() => _habits[index] = item);
    await _persist();
  }

  Future<void> _deleteHabit(int index) async {
    HapticFeedback.lightImpact();
    setState(() => _habits.removeAt(index));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.coupleTheme;
    final bgColor = theme?.bgGradient.first ?? const Color(0xFF0F111A);
    final headerBg = theme?.cardColor ?? const Color(0xFF161924);
    final inputBg = theme?.surfaceAltColor ?? const Color(0xFF1E2232);
    final textColor = theme?.textColor ?? Colors.white;
    final subTextColor = theme?.subTextColor ?? Colors.white54;
    final accentColor = theme?.accent ?? const Color(0xFF10B981);
    final onAccentColor = theme?.onAccentTextColor ?? Colors.white;
    final borderColor =
        theme?.borderColor ?? Colors.white.withValues(alpha: 0.08);
    final isShared =
        PocketGangToolStorage.isSharedGroup(widget.groupId, widget.memberCount);

    final doneCount = _habits.where((h) {
      final dates = (h['completedDates'] as List?) ?? [];
      return dates.contains(_todayKey);
    }).length;

    return Container(
      color: bgColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal & Habit Tracker',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$doneCount/${_habits.length} done today • ${isShared ? "Shared Sync" : "Local Only"}',
                        style: GoogleFonts.outfit(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_todayKey',
                    style: GoogleFonts.outfit(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _habitController,
                      style: GoogleFonts.outfit(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add daily goal or habit...',
                        hintStyle: GoogleFonts.outfit(
                            color: subTextColor, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addHabit(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addHabit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add, color: onAccentColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final h = _habits[index];
                      final dates = (h['completedDates'] as List?) ?? [];
                      final isDone = dates.contains(_todayKey);
                      final streak = (h['streak'] as num?)?.toInt() ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: headerBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDone
                                ? accentColor.withValues(alpha: 0.6)
                                : borderColor,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _toggleToday(index),
                          leading: Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isDone ? accentColor : subTextColor,
                          ),
                          title: Text(
                            h['title']?.toString() ?? '',
                            style: GoogleFonts.outfit(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            'Streak: $streak days',
                            style: TextStyle(color: subTextColor, fontSize: 11.5),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                color: subTextColor, size: 18),
                            onPressed: () => _deleteHabit(index),
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
}
