import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single Personal Task Item Model
class PersonalTaskItem {
  final String id;
  String title;
  bool isCompleted;
  String priority; // 'low', 'medium', 'high'
  DateTime? dueDate;

  PersonalTaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = 'medium',
    this.dueDate,
  });
}

/// Habit Tracker Item Model
class PersonalHabitItem {
  final String id;
  final String name;
  final String emoji;
  int streak;
  bool isDoneToday;

  PersonalHabitItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.streak = 0,
    this.isDoneToday = false,
  });
}

/// 📱 Complete Individual Gang: Personal Productivity Workspace
class PocketGangIndividualWorkspaceWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const PocketGangIndividualWorkspaceWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  State<PocketGangIndividualWorkspaceWidget> createState() =>
      _PocketGangIndividualWorkspaceWidgetState();
}

class _PocketGangIndividualWorkspaceWidgetState
    extends State<PocketGangIndividualWorkspaceWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Personal Tasks State
  final List<PersonalTaskItem> _tasks = [
    PersonalTaskItem(id: '1', title: 'Complete 30-min IELTS Speaking Drill', isCompleted: true, priority: 'high'),
    PersonalTaskItem(id: '2', title: 'Review business model canvas draft', isCompleted: false, priority: 'medium'),
    PersonalTaskItem(id: '3', title: 'Organize week sprint schedule', isCompleted: false, priority: 'low'),
  ];
  final TextEditingController _taskInputCtrl = TextEditingController();

  // 2. Habits State
  final List<PersonalHabitItem> _habits = [
    PersonalHabitItem(id: 'h1', name: 'Morning English Reading', emoji: '📖', streak: 12, isDoneToday: true),
    PersonalHabitItem(id: 'h2', name: '30-min Focus Deep Work', emoji: '⚡', streak: 5, isDoneToday: false),
    PersonalHabitItem(id: 'h3', name: 'Health & Hydration', emoji: '💧', streak: 21, isDoneToday: true),
  ];

  // 3. Focus Timer (Pomodoro) State
  static const int _defaultFocusSeconds = 25 * 60;
  int _secondsLeft = _defaultFocusSeconds;
  bool _isTimerActive = false;
  Timer? _timer;
  int _completedSessions = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _taskInputCtrl.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.selectionClick();
    if (_isTimerActive) {
      _timer?.cancel();
      setState(() => _isTimerActive = false);
    } else {
      setState(() => _isTimerActive = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          t.cancel();
          HapticFeedback.heavyImpact();
          setState(() {
            _isTimerActive = false;
            _secondsLeft = _defaultFocusSeconds;
            _completedSessions++;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Focus session completed! Great job!'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  void _resetTimer() {
    HapticFeedback.selectionClick();
    _timer?.cancel();
    setState(() {
      _isTimerActive = false;
      _secondsLeft = _defaultFocusSeconds;
    });
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _addNewTask(String title) {
    if (title.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _tasks.insert(
        0,
        PersonalTaskItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
        ),
      );
      _taskInputCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Sub-Header Ribbon Tabs
          Container(
            height: 42,
            color: const Color(0xFF1E293B),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFF38BDF8),
              indicatorWeight: 2.5,
              labelColor: const Color(0xFF38BDF8),
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.check_circle_outline, size: 14), text: 'Tasks'),
                Tab(icon: Icon(Icons.local_fire_department_rounded, size: 14), text: 'Habits'),
                Tab(icon: Icon(Icons.timer_outlined, size: 14), text: 'Focus Timer'),
                Tab(icon: Icon(Icons.dashboard_outlined, size: 14), text: 'Dashboard'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksView(),
                _buildHabitsView(),
                _buildFocusTimerView(),
                _buildPersonalDashboardView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Personal Tasks View
  Widget _buildTasksView() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Input Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _taskInputCtrl,
                    onSubmitted: _addNewTask,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '+ Add a new personal task...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _addNewTask(_taskInputCtrl.text),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR TASKS (${_tasks.length})',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              Text(
                '$completedCount / ${_tasks.length} Completed',
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Task List
          Expanded(
            child: ListView.separated(
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: task.isCompleted ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => task.isCompleted = !task.isCompleted);
                        },
                        child: Icon(
                          task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: task.isCompleted ? const Color(0xFF10B981) : Colors.white38,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: task.isCompleted ? Colors.white38 : Colors.white,
                            fontSize: 13.5,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 18),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _tasks.removeAt(index));
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

  // 2. Habits View
  Widget _buildHabitsView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY HABIT CONSISTENCY',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: habit.isDoneToday ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(habit.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.streak} day streak',
                                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            habit.isDoneToday = !habit.isDoneToday;
                            if (habit.isDoneToday) {
                              habit.streak++;
                            } else {
                              habit.streak = (habit.streak - 1).clamp(0, 9999);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: habit.isDoneToday ? const Color(0xFF10B981) : Colors.white12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            habit.isDoneToday ? 'DONE 🔥' : 'CHECK-IN',
                            style: TextStyle(
                              color: habit.isDoneToday ? Colors.black : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
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

  // 3. Focus Timer (Pomodoro) View
  Widget _buildFocusTimerView() {
    final prog = 1.0 - (_secondsLeft / _defaultFocusSeconds);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: prog,
                    strokeWidth: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_secondsLeft),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isTimerActive ? 'FOCUS SESSION 🎯' : 'PAUSED',
                      style: GoogleFonts.inter(
                        color: _isTimerActive ? const Color(0xFF38BDF8) : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTimerActive ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(_isTimerActive ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black),
                  label: Text(
                    _isTimerActive ? 'PAUSE' : 'START FOCUS',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('RESET', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                '🔥 Completed today: $_completedSessions Focus Sessions',
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Personal Dashboard View
  Widget _buildPersonalDashboardView() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final taskPercent = _tasks.isEmpty ? 0 : ((completedCount / _tasks.length) * 100).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONAL PROGRESS OVERVIEW',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          // Stat Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Tasks Completed', '$completedCount / ${_tasks.length}', '$taskPercent% Rate', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard('Focus Time', '${_completedSessions * 25} mins', '$_completedSessions Sessions', const Color(0xFF38BDF8)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Active Habits', '${_habits.length}', '100% On-track', const Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard('Longest Streak', '21 Days', 'Health & Hydration', const Color(0xFFA855F7)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Growth Note Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Text('🌱 ', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keep up the momentum, ${widget.groupName}!',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Your individual workspace stores your personal milestones and habits privately.',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
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

  Widget _buildMetricCard(String label, String value, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

