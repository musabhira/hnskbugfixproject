import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketgang_task_service.dart';
import 'pocket_spend_page.dart';

/// ✅ PocketGang To-Do List Widget: Team task checklist & quick addition
class PocketGangTodoWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final List<dynamic> groupMembers;
  final bool isAdmin;
  final List<PocketGangTask> tasks;
  final VoidCallback onTasksChanged;
  final PocketSpendCoupleTheme? coupleTheme;

  const PocketGangTodoWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.groupMembers,
    required this.isAdmin,
    required this.tasks,
    required this.onTasksChanged,
    this.coupleTheme,
  });

  @override
  State<PocketGangTodoWidget> createState() => _PocketGangTodoWidgetState();
}

class _PocketGangTodoWidgetState extends State<PocketGangTodoWidget> {
  final TextEditingController _taskInputController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _taskInputController.dispose();
    super.dispose();
  }

  Future<void> _quickAddTask() async {
    final title = _taskInputController.text.trim();
    if (title.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _isAdding = true);

    try {
      final newTask = PocketGangTask(
        id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
        groupId: widget.groupId,
        title: title,
        status: 'todo',
        createdBy: widget.currentUserId,
        estimatedHours: 1.0,
      );

      final updated = [...widget.tasks, newTask];
      await PocketGangTaskService.instance.saveTasks(
        groupId: widget.groupId,
        tasks: updated,
        userId: widget.currentUserId,
      );
      _taskInputController.clear();
      widget.onTasksChanged();
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _toggleTaskStatus(PocketGangTask task) async {
    HapticFeedback.selectionClick();
    final newStatus = task.status == 'completed' ? 'todo' : 'completed';
    task.status = newStatus;

    await PocketGangTaskService.instance.saveTasks(
      groupId: widget.groupId,
      tasks: widget.tasks,
      userId: widget.currentUserId,
    );
    widget.onTasksChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = widget.tasks.where((t) => t.status != 'completed').toList();
    final completedTasks = widget.tasks.where((t) => t.status == 'completed').toList();

    final theme = widget.coupleTheme;
    final bgColor = theme != null ? theme.bgGradient.first : const Color(0xFF0F111A);
    final headerBg = theme != null ? theme.cardColor : const Color(0xFF161924);
    final inputBg = theme != null ? theme.surfaceAltColor : const Color(0xFF1E2232);
    final textColor = theme != null ? theme.textColor : Colors.white;
    final subTextColor = theme != null ? theme.subTextColor : Colors.white54;
    final accentColor = theme != null ? theme.accent : const Color(0xFF38BDF8);
    final onAccentColor = theme != null ? theme.onAccentTextColor : Colors.white;
    final borderColor = theme != null ? theme.borderColor : Colors.white.withValues(alpha: 0.08);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // Header summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('✅', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team To-Do Checklist',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pendingTasks.length} pending • ${completedTasks.length} completed',
                        style: GoogleFonts.outfit(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick add field
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
                      controller: _taskInputController,
                      style: GoogleFonts.outfit(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a new group to-do...',
                        hintStyle: GoogleFonts.outfit(color: subTextColor, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _quickAddTask(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isAdding ? null : _quickAddTask,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isAdding
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: onAccentColor))
                        : Icon(Icons.add, color: onAccentColor, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: widget.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(
                          'No to-do tasks yet!',
                          style: GoogleFonts.outfit(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add items above for your gang to complete together.',
                          style: GoogleFonts.outfit(color: subTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: [
                      if (pendingTasks.isNotEmpty) ...[
                        _buildSectionHeader('PENDING (${pendingTasks.length})'),
                        ...pendingTasks.map((t) => _buildTaskTile(t)),
                      ],
                      if (completedTasks.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionHeader('COMPLETED (${completedTasks.length})'),
                        ...completedTasks.map((t) => _buildTaskTile(t)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTaskTile(PocketGangTask task) {
    final isDone = task.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161924),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? Colors.green.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: InkWell(
          onTap: () => _toggleTaskStatus(task),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? Colors.green : Colors.transparent,
              border: Border.all(
                color: isDone ? Colors.green : Colors.white38,
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.outfit(
            color: isDone ? Colors.white38 : Colors.white,
            fontSize: 14,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white24),
          onPressed: () async {
            HapticFeedback.lightImpact();
            widget.tasks.removeWhere((t) => t.id == task.id);
            await PocketGangTaskService.instance.saveTasks(
              groupId: widget.groupId,
              tasks: widget.tasks,
              userId: widget.currentUserId,
            );
            widget.onTasksChanged();
            setState(() {});
          },
        ),
      ),
    );
  }
}

