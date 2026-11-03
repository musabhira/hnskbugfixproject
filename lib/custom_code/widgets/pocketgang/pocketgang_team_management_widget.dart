import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketgang_task_service.dart';

/// 👥 Responsive Team Management Screen: Minimal Task Cards, Clean Kanban, and Admin Review
class PocketGangTeamManagementWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final List<Map<String, dynamic>> groupMembers;
  final bool isAdmin;
  final List<PocketGangTask> tasks;
  final VoidCallback onTasksChanged;

  const PocketGangTeamManagementWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.groupMembers,
    required this.isAdmin,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<PocketGangTeamManagementWidget> createState() =>
      _PocketGangTeamManagementWidgetState();
}

class _PocketGangTeamManagementWidgetState
    extends State<PocketGangTeamManagementWidget> {
  String _selectedStatusFilter = 'all'; // 'all', 'todo', 'in_progress', 'review', 'completed'

  void _showCreateTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int effortPoints = 5;
    List<String> selectedMemberNames = [];
    List<String> selectedUserIds = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161924),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Task',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Optional Description',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Effort Points Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Effort Points: $effortPoints PTS',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Slider(
                    value: effortPoints.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: const Color(0xFFFFD700),
                    inactiveColor: Colors.white12,
                    onChanged: (v) =>
                        setDialogState(() => effortPoints = v.round()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Member Assignment Chips
              Text('Assign Members:',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: widget.groupMembers.map((m) {
                  final name = m['profile']?['name']?.toString() ??
                      m['name']?.toString() ??
                      'Member';
                  final uid = m['user_id']?.toString() ?? '';
                  final isAssigned = selectedUserIds.contains(uid);

                  return FilterChip(
                    label: Text(name),
                    selected: isAssigned,
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isAssigned ? Colors.black : Colors.white70,
                      fontWeight:
                          isAssigned ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                    onSelected: (val) {
                      setDialogState(() {
                        if (val) {
                          selectedUserIds.add(uid);
                          selectedMemberNames.add(name);
                        } else {
                          selectedUserIds.remove(uid);
                          selectedMemberNames.remove(name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.pop(ctx);

                    final newTask = PocketGangTask(
                      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                      groupId: widget.groupId,
                      title: title,
                      description: descController.text.trim(),
                      effortPoints: effortPoints,
                      assignedMemberNames: selectedMemberNames,
                      assignedUserIds: selectedUserIds,
                      createdBy: widget.currentUserId,
                    );

                    widget.tasks.insert(0, newTask);
                    await PocketGangTaskService.instance.saveTasks(
                      groupId: widget.groupId,
                      tasks: widget.tasks,
                      userId: widget.currentUserId,
                    );
                    widget.onTasksChanged();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Create Task',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(PocketGangTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161924),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDetailsState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(task.status.toUpperCase(),
                        style: TextStyle(
                            color: _getStatusColor(task.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  Text('⚡ ${task.effortPoints} PTS',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(task.title,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.description,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              // Assignees
              Text('Assigned Members: ${task.assignedMemberNames.isEmpty ? "None" : task.assignedMemberNames.join(", ")}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 6),
              if (task.approvedBy != null) ...[
                Text('Approved by Admin: ${task.approvedBy}',
                    style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 16),

              // Action Buttons Based on Status
              if (task.status == 'todo')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      task.status = 'in_progress';
                      await PocketGangTaskService.instance.saveTasks(
                        groupId: widget.groupId,
                        tasks: widget.tasks,
                        userId: widget.currentUserId,
                      );
                      widget.onTasksChanged();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B)),
                    child: const Text('Start Task (In Progress)'),
                  ),
                )
              else if (task.status == 'in_progress')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      task.status = 'review';
                      await PocketGangTaskService.instance.saveTasks(
                        groupId: widget.groupId,
                        tasks: widget.tasks,
                        userId: widget.currentUserId,
                      );
                      widget.onTasksChanged();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA855F7)),
                    child: const Text('Submit for Review'),
                  ),
                )
              else if (task.status == 'review') ...[
                if (widget.isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            task.status = 'in_progress';
                            await PocketGangTaskService.instance.saveTasks(
                              groupId: widget.groupId,
                              tasks: widget.tasks,
                              userId: widget.currentUserId,
                            );
                            widget.onTasksChanged();
                          },
                          style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444)),
                          child: const Text('Request Changes'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            task.status = 'completed';
                            task.approvedBy = widget.currentUserId;
                            task.approvedAt = DateTime.now();
                            await PocketGangTaskService.instance.saveTasks(
                              groupId: widget.groupId,
                              tasks: widget.tasks,
                              userId: widget.currentUserId,
                            );
                            widget.onTasksChanged();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.black),
                          child: const Text('Approve Work',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                else
                  const Center(
                    child: Text('⏳ Awaiting Admin Approval to verify points.',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return const Color(0xFF38BDF8);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'review':
        return const Color(0xFFA855F7);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedStatusFilter == 'all'
        ? widget.tasks
        : widget.tasks
            .where((t) => t.status == _selectedStatusFilter)
            .toList();

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Filter Chips Strip & Add Task Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF161924),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All (${widget.tasks.length})'),
                        const SizedBox(width: 6),
                        _buildFilterChip('todo', 'To Do'),
                        const SizedBox(width: 6),
                        _buildFilterChip('in_progress', 'In Progress'),
                        const SizedBox(width: 6),
                        _buildFilterChip('review', 'Review'),
                        const SizedBox(width: 6),
                        _buildFilterChip('completed', 'Approved'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showCreateTaskDialog,
                  icon: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Main Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text('No tasks in this category',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Tap the + button to create a task for the Gang.',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final task = filteredTasks[idx];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _showTaskDetails(task);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _getStatusColor(task.status)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          task.assignedMemberNames.isEmpty
                                              ? 'Unassigned'
                                              : task.assignedMemberNames
                                                  .join(', '),
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11),
                                        ),
                                        if (task.approvedBy != null) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified,
                                              size: 11,
                                              color: Color(0xFF10B981)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('⚡ ${task.effortPoints} PTS',
                                    style: const TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
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

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedStatusFilter = key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

