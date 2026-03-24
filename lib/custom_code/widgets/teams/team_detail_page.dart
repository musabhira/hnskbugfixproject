import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/user_search_dialog.dart';

class TeamDetailPage extends StatefulWidget {
  final Team team;
  const TeamDetailPage({Key? key, required this.team}) : super(key: key);

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage>
    with SingleTickerProviderStateMixin {
  final TeamsService _service = TeamsService();
  late TabController _tabController;

  List<TeamTask> _tasks = [];
  List<TeamMember> _members = [];
  bool _isLoading = true;
  Timer? _uiTimer;
  String _taskFilter = 'all'; // all, mine, pending

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    // Refresh UI every minute to update active timers
    _uiTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _service.getTeamTasks(widget.team.id);
      final members = await _service.getTeamMembers(widget.team.id);
      setState(() {
        _tasks = tasks;
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading team data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? assignedTo;
    String priority = 'medium';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: Text('New Team Task',
              style: GoogleFonts.outfit(color: Colors.white)),
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
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: assignedTo,
                  dropdownColor: const Color(0xFF333333),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Assign To',
                      labelStyle: TextStyle(color: Colors.grey)),
                  items: _members.map((m) {
                    // Try to show name if available in profile
                    final name = m.profile?['name'] ?? m.userId.substring(0, 8);
                    return DropdownMenuItem(
                      value: m.userId,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => assignedTo = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  dropdownColor: const Color(0xFF333333),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: Colors.grey)),
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
                          ? 'Select Due Date'
                          : 'Due: ${selectedDate.toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.white)),
                  trailing:
                      const Icon(Icons.calendar_today, color: Colors.yellow),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.yellow,
                              onPrimary: Colors.black,
                              surface: Color(0xFF2C2C2C),
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
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                await _service.createTeamTask(
                  widget.team.id,
                  titleController.text,
                  description: descController.text,
                  assignedTo: assignedTo,
                  priority: priority,
                  dueDate: selectedDate, // Pass the date
                );
                Navigator.pop(context);
                _loadData();
              },
              child: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black),
            ),
          ],
        );
      }),
    );
  }

  void _showInviteMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => UserSearchDialog(
        multipleSelection: false,
        onUsersSelected: (users) async {
          if (users.isEmpty) return;
          final user = users.first;
          try {
            await _service.inviteMember(widget.team.id, user.userId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invited ${user.name}!')),
              );
              _loadData();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.team.name,
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Members'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(),
                _buildMembersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddTaskDialog();
          } else {
            _showInviteMemberDialog();
          }
        },
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        _buildTaskFilters(),
        Expanded(
          child: _tasks.isEmpty
              ? Center(
                  child: Text('No tasks yet',
                      style: GoogleFonts.outfit(color: Colors.grey)))
              : _buildFilteredTaskList(),
        ),
      ],
    );
  }

  Widget _buildTaskFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('all', 'All Tasks'),
          _filterChip('mine', 'My Tasks'),
          _filterChip('in_progress', 'Working'),
          _filterChip('todo', 'Todo'),
          _filterChip('completed', 'Done'),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    bool isSelected = _taskFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _taskFilter = id);
        },
        selectedColor: Colors.yellow,
        backgroundColor: const Color(0xFF2C2C2C),
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
            color: isSelected ? Colors.yellow : const Color(0xFF424242)),
      ),
    );
  }

  Widget _buildFilteredTaskList() {
    final currentUserId = _service.authUserId;
    final filtered = _tasks.where((t) {
      if (_taskFilter == 'all') return true;
      if (_taskFilter == 'mine') return t.assignedTo == currentUserId;
      if (_taskFilter == 'in_progress') return t.status == 'in_progress';
      if (_taskFilter == 'todo') return t.status == 'todo';
      if (_taskFilter == 'completed') return t.status == 'completed';
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final task = filtered[index];
        bool isMyTask = task.assignedTo == currentUserId;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isMyTask
                    ? Colors.yellow.withValues(alpha: 0.3)
                    : const Color(0xFF333333)),
            boxShadow: [
              if (task.timerStartedAt != null)
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                title: Text(task.title,
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                subtitle: task.description != null &&
                        task.description!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(task.description!,
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 13)),
                      )
                    : null,
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (val) async {
                    if (val == 'delete' && (task.createdBy == _service.authUserId || _isAdmin)) {
                      await _service.deleteTask(task.id);
                      _loadData();
                    } else if (val == 'log_time') {
                      _showLogTimeDialog(task);
                    } else if (val == 'assign_me') {
                      await _service.updateTaskAssignment(
                          task.id, _service.authUserId);
                      _loadData();
                    } else if (val == 'reassign' && _isAdmin) {
                      _showReassignDialog(task);
                    } else {
                      await _service.updateTaskStatus(task.id, val);
                      _loadData();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'todo', child: Text('Todo')),
                    const PopupMenuItem(
                        value: 'in_progress', child: Text('In Progress')),
                    const PopupMenuItem(
                        value: 'completed', child: Text('Completed')),
                    if (task.assignedTo != _service.authUserId)
                      const PopupMenuItem(
                          value: 'assign_me', child: Text('Assign to Me')),
                    if (_isAdmin)
                      const PopupMenuItem(
                          value: 'reassign', child: Text('Reassign...')),
                    const PopupMenuItem(
                        value: 'log_time', child: Text('Log Time')),
                    if (task.createdBy == _service.authUserId || _isAdmin)
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _tag(task.priority.toUpperCase(),
                            _getPriorityColor(task.priority)),
                        const SizedBox(width: 8),
                        _tag(task.status.toUpperCase().replaceAll('_', ' '),
                            _getStatusColor(task.status)),
                        const Spacer(),
                        if (task.dueDate != null)
                          Text(
                            'Due: ${task.dueDate.toString().split(' ')[0]}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF333333), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[800],
                              child: const Icon(Icons.person,
                                  size: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task.assignedTo != null
                                  ? _getMemberName(task.assignedTo!)
                                  : 'Unassigned',
                              style: TextStyle(
                                color: task.assignedTo != null
                                    ? Colors.yellow
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _calculateTotalTime(task),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            if (task.timerStartedAt == null)
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.play_circle_fill,
                                    color: Colors.green, size: 28),
                                onPressed: () async {
                                  await _service.startTimer(task.id);
                                  _loadData();
                                },
                              )
                            else
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.stop_circle,
                                    color: Colors.red, size: 28),
                                onPressed: () async {
                                  await _service.stopTimer(task.id);
                                  _loadData();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showLogTimeDialog(TeamTask task) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text('Log Time', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Total spent: ${task.timeSpent} mins",
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Minutes to add',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final mins = int.tryParse(controller.text);
              if (mins != null && mins > 0) {
                await _service.logTime(task.id, mins);
                Navigator.pop(context);
                _loadData(); // Refresh UI
              }
            },
            child: Text('Log'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(TeamTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title:
            Text('Reassign Task', style: GoogleFonts.outfit(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
                title: Text(_getMemberName(member.userId),
                    style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  await _service.updateTaskAssignment(task.id, member.userId);
                  Navigator.pop(context);
                  _loadData();
                },
              );
            },
          ),
        ),
      ),
    );
  }


  String _getMemberName(String userId) {
    final member = _members.firstWhere((m) => m.userId == userId,
        orElse: () => TeamMember(
            id: '', teamId: '', userId: userId, role: '', status: ''));
    if (member.profile != null && member.profile!['name'] != null) {
      return member.profile!['name'];
    }
    return userId.substring(0, 8);
  }

  String _calculateTotalTime(TeamTask task) {
    int total = task.timeSpent;
    if (task.timerStartedAt != null) {
      final diff = DateTime.now().toUtc().difference(task.timerStartedAt!);
      total += diff.inMinutes;
    }
    if (total == 0 && task.timerStartedAt != null) {
      // Show seconds if less than a minute and running
      final diff = DateTime.now().toUtc().difference(task.timerStartedAt!);
      return '${diff.inSeconds} secs';
    }
    return '$total mins';
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return Card(
          color: const Color(0xFF2C2C2C),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(_getMemberName(member.userId),
                style: const TextStyle(
                    color: Colors.white)),
            subtitle: Text(member.role.toUpperCase(),
                style: const TextStyle(color: Colors.yellow, fontSize: 12)),
            trailing: member.status == 'pending'
                ? ElevatedButton(
                    onPressed: () async {
                      await _service.updateMemberStatus(member.id, 'approved');
                      _loadData();
                    },
                    child: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                  )
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'high') return Colors.red;
    if (priority == 'medium') return Colors.orange;
    return Colors.green;
  }

  Color _getStatusColor(String status) {
    if (status == 'done') return Colors.blueGrey;
    if (status == 'in_progress') return Colors.blue;
    return Colors.grey;
  }

  bool get _isAdmin {
    final curUser = _service.authUserId;
    if (curUser == null) return false;
    final member = _members.firstWhere((m) => m.userId == curUser,
        orElse: () => TeamMember(
            id: '', teamId: '', userId: curUser, role: 'member', status: ''));
    return member.role == 'owner' || member.role == 'admin';
  }
}
