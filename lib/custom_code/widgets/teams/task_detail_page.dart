import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

class TaskDetailPage extends StatefulWidget {
  final TeamTask task;
  final Team team;
  final List<TeamMember> members;
  final bool isAdmin;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.team,
    required this.members,
    required this.isAdmin,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TeamsService _service = TeamsService();
  late TeamTask _currentTask;
  Timer? _stopwatchTimer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _startStopwatchTimer();
  }

  void _startStopwatchTimer() {
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _currentTask.timerStartedAt != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshTask() async {
    try {
      final tasks = await _service.getTeamTasks(widget.team.id);
      final refreshed = tasks.firstWhere((t) => t.id == _currentTask.id);
      if (mounted) {
        setState(() {
          _currentTask = refreshed;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing task: $e');
    }
  }

  String _getMemberName(String userId) {
    final member = widget.members.firstWhere(
      (m) => m.userId == userId,
      orElse: () => TeamMember(id: '', teamId: '', userId: userId, role: '', status: ''),
    );
    if (member.profile != null && member.profile!['name'] != null) {
      return member.profile!['name'];
    }
    return userId.length > 8 ? userId.substring(0, 8) : userId;
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'high') return Colors.red;
    if (priority == 'medium') return Colors.orange;
    return Colors.green;
  }

  Color _getStatusColor(String status) {
    if (status == 'completed') return Colors.teal;
    if (status == 'in_progress') return Colors.blue;
    return Colors.grey;
  }

  String _calculateLiveTime() {
    int total = _currentTask.timeSpent;
    if (_currentTask.timerStartedAt != null) {
      final diff = DateTime.now().toUtc().difference(_currentTask.timerStartedAt!);
      total += diff.inMinutes;
    }
    return '$total mins';
  }

  String _calculateStopwatch() {
    if (_currentTask.timerStartedAt == null) return "00:00:00";
    final diff = DateTime.now().toUtc().difference(_currentTask.timerStartedAt!);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  void _showEditTaskDialog() {
    final titleController = TextEditingController(text: _currentTask.title);
    final descController = TextEditingController(text: _currentTask.description ?? '');
    String priority = _currentTask.priority;
    DateTime? selectedDate = _currentTask.dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Edit Task Details',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: priority,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    items: ['low', 'medium', 'high'].map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => priority = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      selectedDate == null
                          ? 'No Due Date Set'
                          : 'Due: ${selectedDate.toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(Icons.calendar_today, color: Colors.yellow),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.yellow,
                                onPrimary: Colors.black,
                                surface: Color(0xFF1E1E1E),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  Navigator.pop(context);
                  setState(() => _isSaving = true);
                  try {
                    await _service.updateTaskDetails(
                      _currentTask.id,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      priority: priority,
                      dueDate: selectedDate,
                    );
                    await _refreshTask();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReassignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Assign Task To',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.members.length,
            itemBuilder: (context, index) {
              final member = widget.members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
                title: Text(_getMemberName(member.userId),
                    style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _isSaving = true);
                  try {
                    await _service.updateTaskAssignment(_currentTask.id, member.userId);
                    await _refreshTask();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  } finally {
                    setState(() => _isSaving = false);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogTimeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Manual Time', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current logged time: ${_currentTask.timeSpent} mins",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Minutes to add',
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final mins = int.tryParse(controller.text);
              if (mins != null && mins > 0) {
                Navigator.pop(context);
                setState(() => _isSaving = true);
                try {
                  await _service.logTime(_currentTask.id, mins);
                  await _refreshTask();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                } finally {
                  setState(() => _isSaving = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTimerActive = _currentTask.timerStartedAt != null;
    final String statusLabel = _currentTask.status.toUpperCase().replaceAll('_', ' ');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Task Details', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.isAdmin || _currentTask.createdBy == _service.authUserId)
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.yellow, size: 28),
              tooltip: 'Edit Details',
              onPressed: _showEditTaskDialog,
            ),
          if (widget.isAdmin || _currentTask.createdBy == _service.authUserId)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 26),
              tooltip: 'Delete Task',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure you want to delete this task forever?',
                        style: TextStyle(color: Colors.grey)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  setState(() => _isSaving = true);
                  try {
                    await _service.deleteTask(_currentTask.id);
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                    setState(() => _isSaving = false);
                  }
                }
              },
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C2C2C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(_currentTask.priority).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _getPriorityColor(_currentTask.priority).withValues(alpha: 0.4),
                                    width: 0.8),
                              ),
                              child: Text(
                                '${_currentTask.priority.toUpperCase()} PRIORITY',
                                style: GoogleFonts.outfit(
                                  color: _getPriorityColor(_currentTask.priority),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_currentTask.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _getStatusColor(_currentTask.status).withValues(alpha: 0.4),
                                    width: 0.8),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.outfit(
                                  color: _getStatusColor(_currentTask.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentTask.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentTask.description != null && _currentTask.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFF2C2C2C)),
                          const SizedBox(height: 8),
                          Text(
                            _currentTask.description!,
                            style: GoogleFonts.outfit(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timer Stopwatch Widget
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isTimerActive
                          ? Colors.yellow.withValues(alpha: 0.05)
                          : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTimerActive
                            ? Colors.yellow.withValues(alpha: 0.3)
                            : const Color(0xFF2C2C2C),
                      ),
                      boxShadow: [
                        if (isTimerActive)
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.05),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isTimerActive ? 'ACTIVE TIME TRACKING' : 'TIME ELAPSED',
                          style: GoogleFonts.outfit(
                            color: isTimerActive ? Colors.yellow : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isTimerActive ? _calculateStopwatch() : _calculateLiveTime(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                setState(() => _isSaving = true);
                                try {
                                  if (isTimerActive) {
                                    await _service.stopTimer(_currentTask.id);
                                  } else {
                                    await _service.startTimer(_currentTask.id);
                                  }
                                  await _refreshTask();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                  );
                                } finally {
                                  setState(() => _isSaving = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isTimerActive ? Colors.red : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                              icon: Icon(isTimerActive ? Icons.stop : Icons.play_arrow),
                              label: Text(
                                isTimerActive ? 'Stop Tracking' : 'Start Tracking',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: _showLogTimeDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.yellow,
                                side: const BorderSide(color: Colors.yellow),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Time'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Metadata cards: Assignee, Due Date
                  Row(
                    children: [
                      // Assignee card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2C2C2C)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ASSIGNED TO',
                                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: _showReassignDialog,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey[800],
                                      child: const Icon(Icons.person, size: 14, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _currentTask.assignedTo != null
                                            ? _getMemberName(_currentTask.assignedTo!)
                                            : 'Unassigned',
                                        style: TextStyle(
                                          color: _currentTask.assignedTo != null ? Colors.yellow : Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Due Date card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2C2C2C)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('DUE DATE',
                                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(
                                _currentTask.dueDate != null
                                    ? _currentTask.dueDate.toString().split(' ')[0]
                                    : 'No Limit Set',
                                style: TextStyle(
                                  color: _currentTask.dueDate != null ? Colors.white : Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Status Updates
                  Text(
                    'UPDATE TASK STATUS',
                    style: GoogleFonts.outfit(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusButton('todo', 'Todo'),
                      const SizedBox(width: 8),
                      _statusButton('in_progress', 'Working'),
                      const SizedBox(width: 8),
                      _statusButton('completed', 'Done'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statusButton(String statusValue, String label) {
    final isSelected = _currentTask.status == statusValue;
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          if (isSelected) return;
          setState(() => _isSaving = true);
          try {
            await _service.updateTaskStatus(_currentTask.id, statusValue);
            await _refreshTask();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          } finally {
            setState(() => _isSaving = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? _getStatusColor(statusValue)
              : const Color(0xFF1E1E1E),
          foregroundColor: isSelected ? Colors.white : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.transparent : const Color(0xFF2C2C2C),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
