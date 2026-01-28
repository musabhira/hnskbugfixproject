import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
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
    final emailController = TextEditingController();
    // In real app, search by email/username. Here, we might need a search widget.
    // For simplicity, let's assume we can input a USER ID for now, or this needs a user search feature which is larger scope.
    // I'll put a placeholder for User ID input as per raw requirement.

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text('Add Member (User ID)',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter User UUID',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;
              try {
                await _service.inviteMember(
                    widget.team.id, emailController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Member added!')));
                _loadData(); // Reload to see if they appeared (if auto-approved)
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text('Invite'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, foregroundColor: Colors.black),
          ),
        ],
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
    if (_tasks.isEmpty) {
      return Center(
          child: Text('No tasks yet',
              style: GoogleFonts.outfit(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          color: const Color(0xFF2C2C2C),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(task.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  Text(task.description!,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(task.priority.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                          task.status.toUpperCase().replaceAll('_', ' '),
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      const Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        task.dueDate.toString().split(' ')[0],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (task.timeSpent > 0) ...[
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${task.timeSpent} mins',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ]
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (val) async {
                if (val == 'delete') {
                  await _service.deleteTask(task.id);
                  _loadData();
                } else if (val == 'log_time') {
                  _showLogTimeDialog(task);
                } else {
                  await _service.updateTaskStatus(task.id, val);
                  _loadData();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'todo', child: Text('Mark Todo')),
                const PopupMenuItem(
                    value: 'in_progress', child: Text('Mark In Progress')),
                const PopupMenuItem(
                    value: 'completed', child: Text('Mark Completed')),
                const PopupMenuItem(value: 'bug', child: Text('Mark as Bug')),
                const PopupMenuItem(
                    value: 'on_hold', child: Text('Mark On Hold')),
                const PopupMenuItem(value: 'log_time', child: Text('Log Time')),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
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
            title: Text(member.userId.substring(0, 8),
                style: const TextStyle(
                    color: Colors.white)), // Placeholder for name
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
}
