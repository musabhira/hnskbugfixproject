import '../../services/pocketgang_chat_share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketgang_task_service.dart';

/// 👥 Responsive PocketGang Team Management Screen
/// Includes Title, Description, Estimated Hours, Multi-Assignees, Multi-Approvers,
/// Workflow: To Do -> In Progress -> Ready for Production / Pending Approval -> Completed,
/// Rejection comments, and Task Filters (Search, All, Mine) + Approvals (Mine, All).
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
  String _selectedStatusFilter = 'all'; // 'all', 'mine', 'todo', 'in_progress', 'review', 'completed'
  String _searchQuery = '';
  String _approvalFilter = 'mine'; // 'mine', 'all'

  void _showCreateTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final hoursController = TextEditingController(text: '2.0');
    final searchAssigneeController = TextEditingController();
    final searchApproverController = TextEditingController();

    List<String> selectedAssigneeNames = [];
    List<String> selectedAssigneeIds = [];
    List<String> selectedApproverNames = [];
    List<String> selectedApproverIds = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161924),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final assigneeQuery = searchAssigneeController.text.trim().toLowerCase();
          final filteredAssignees = widget.groupMembers.where((m) {
            final name = (m['profile']?['name'] ?? m['name'] ?? 'Member').toString().toLowerCase();
            return name.contains(assigneeQuery);
          }).toList();

          final approverQuery = searchApproverController.text.trim().toLowerCase();
          final filteredApprovers = widget.groupMembers.where((m) {
            final name = (m['profile']?['name'] ?? m['name'] ?? 'Member').toString().toLowerCase();
            return name.contains(approverQuery);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Create New Task',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Task Title
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

                  // Task Description
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
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

                  // Estimated Hours
                  TextField(
                    controller: hoursController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Estimated Hours (e.g., 2.5)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.timer_outlined, color: Color(0xFFFFD700), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Multi-Assignee Section
                  Text('Assignee Members (Select from Group):',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: searchAssigneeController,
                    onChanged: (_) => setDialogState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search group members to assign...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                      filled: true,
                      isDense: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: filteredAssignees.map((m) {
                      final name = m['profile']?['name']?.toString() ??
                          m['name']?.toString() ??
                          'Member';
                      final uid = m['user_id']?.toString() ?? '';
                      final isAssigned = selectedAssigneeIds.contains(uid);

                      return FilterChip(
                        label: Text(name),
                        selected: isAssigned,
                        selectedColor: const Color(0xFFFFD700),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: isAssigned ? Colors.black : Colors.white70,
                          fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              selectedAssigneeIds.add(uid);
                              selectedAssigneeNames.add(name);
                            } else {
                              selectedAssigneeIds.remove(uid);
                              selectedAssigneeNames.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Multi-Approver Section
                  Text('Approval Members (Select Approvers):',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: searchApproverController,
                    onChanged: (_) => setDialogState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search group members to approve...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: const Icon(Icons.verified_user_outlined, color: Colors.white38, size: 18),
                      filled: true,
                      isDense: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: filteredApprovers.map((m) {
                      final name = m['profile']?['name']?.toString() ??
                          m['name']?.toString() ??
                          'Member';
                      final uid = m['user_id']?.toString() ?? '';
                      final isApprover = selectedApproverIds.contains(uid);

                      return FilterChip(
                        label: Text(name),
                        selected: isApprover,
                        selectedColor: const Color(0xFF10B981),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: isApprover ? Colors.black : Colors.white70,
                          fontWeight: isApprover ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              selectedApproverIds.add(uid);
                              selectedApproverNames.add(name);
                            } else {
                              selectedApproverIds.remove(uid);
                              selectedApproverNames.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        final hours = double.tryParse(hoursController.text.trim()) ?? 1.0;
                        Navigator.pop(ctx);

                        final newTask = PocketGangTask(
                          id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                          groupId: widget.groupId,
                          title: title,
                          description: descController.text.trim(),
                          estimatedHours: hours,
                          effortPoints: hours.round().clamp(1, 100),
                          assignedMemberNames: selectedAssigneeNames,
                          assignedUserIds: selectedAssigneeIds,
                          approverMemberNames: selectedApproverNames,
                          approverUserIds: selectedApproverIds,
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
          );
        },
      ),
    );
  }

  void _showRejectReasonDialog(PocketGangTask task, BuildContext parentContext) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Request Changes / Reject',
            style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please add feedback or reasons for the assignees:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter feedback/changes required...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              Navigator.pop(dCtx);
              Navigator.pop(parentContext);

              task.status = 'in_progress';
              task.rejectionReason = reason.isNotEmpty ? reason : 'Changes requested by approver.';
              await PocketGangTaskService.instance.saveTasks(
                groupId: widget.groupId,
                tasks: widget.tasks,
                userId: widget.currentUserId,
              );
              widget.onTasksChanged();
            },
            child: const Text('Send Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
        builder: (ctx, setDetailsState) {
          final isApprover = task.approverUserIds.contains(widget.currentUserId) ||
              (task.approverUserIds.isEmpty && widget.isAdmin);
          final isAssignee = task.assignedUserIds.contains(widget.currentUserId) ||
              task.assignedUserIds.isEmpty;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(task.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _getStatusColor(task.status).withValues(alpha: 0.3)),
                        ),
                        child: Text(_getStatusLabel(task.status).toUpperCase(),
                            style: TextStyle(
                                color: _getStatusColor(task.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                          Text('${task.estimatedHours.toStringAsFixed(1)} hrs',
                              style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
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
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),

                  // Assignees List
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_outline, color: Colors.white54, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Assignees: ${task.assignedMemberNames.isEmpty ? "All Members" : task.assignedMemberNames.join(", ")}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Approvers List
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Designated Approvers: ${task.approverMemberNames.isEmpty ? "Admins" : task.approverMemberNames.join(", ")}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (task.rejectionReason != null && task.rejectionReason!.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.feedback_outlined, color: Color(0xFFEF4444), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Feedback: ${task.rejectionReason}',
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (task.approvedBy != null) ...[
                    Text('Approved by: ${task.approvedBy}',
                        style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 16),

                  // Share to Group Chat Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 16, color: Color(0xFFFFD700)),
                      label: const Text('Share Task to Group Chat',
                          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final success = await PocketGangChatShareService.instance.shareTaskToGroupChat(
                          groupId: widget.groupId,
                          userId: widget.currentUserId,
                          task: task,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? '🚀 Task shared to Group Chat!' : 'Failed to share task.'),
                              backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Actions Based on Status Workflow
                  if (task.status == 'todo' && isAssignee)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
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
                        label: const Text('Start Task (Move to In Progress)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else if (task.status == 'in_progress' && isAssignee)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
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
                        label: const Text('Ready for Production / Pending Approval',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else if (task.status == 'review') ...[
                    if (isApprover)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => _showRejectReasonDialog(task, ctx),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                  side: const BorderSide(color: Color(0xFFEF4444))),
                              label: const Text('Reject & Add Comment'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 16),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                task.status = 'completed';
                                task.approvedBy = widget.currentUserId;
                                task.approvedAt = DateTime.now();
                                task.rejectionReason = null;
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
                              label: const Text('Approve Work',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    else
                      const Center(
                        child: Text('⏳ Awaiting assigned approver review.',
                            style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Pending Approval';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
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
    final query = _searchQuery.trim().toLowerCase();

    final filteredTasks = widget.tasks.where((t) {
      if (query.isNotEmpty) {
        final title = t.title.toLowerCase();
        final desc = t.description.toLowerCase();
        if (!title.contains(query) && !desc.contains(query)) return false;
      }

      if (_selectedStatusFilter == 'mine') {
        return t.assignedUserIds.contains(widget.currentUserId);
      } else if (_selectedStatusFilter == 'approvals') {
        if (_approvalFilter == 'mine') {
          return t.status == 'review' &&
              (t.approverUserIds.contains(widget.currentUserId) ||
                  (t.approverUserIds.isEmpty && widget.isAdmin));
        } else {
          return t.status == 'review';
        }
      } else if (_selectedStatusFilter != 'all') {
        return t.status == _selectedStatusFilter;
      }
      return true;
    }).toList();

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF161924),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Search tasks by title or details...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                            prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showCreateTaskDialog,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.black, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Main Status Filters: All | Mine | To Do | In Progress | Approvals | Completed
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All (${widget.tasks.length})'),
                      const SizedBox(width: 6),
                      _buildFilterChip('mine', 'Mine'),
                      const SizedBox(width: 6),
                      _buildFilterChip('todo', 'To Do'),
                      const SizedBox(width: 6),
                      _buildFilterChip('in_progress', 'In Progress'),
                      const SizedBox(width: 6),
                      _buildFilterChip('approvals', 'Approvals'),
                      const SizedBox(width: 6),
                      _buildFilterChip('completed', 'Completed'),
                    ],
                  ),
                ),

                // If Approvals filter active: Show Mine / All toggle
                if (_selectedStatusFilter == 'approvals') ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('Approvals View:', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Mine', style: TextStyle(fontSize: 11)),
                        selected: _approvalFilter == 'mine',
                        selectedColor: const Color(0xFFA855F7),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                            color: _approvalFilter == 'mine' ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold),
                        onSelected: (val) {
                          if (val) setState(() => _approvalFilter = 'mine');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('All Group Approvals', style: TextStyle(fontSize: 11)),
                        selected: _approvalFilter == 'all',
                        selectedColor: const Color(0xFFA855F7),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                            color: _approvalFilter == 'all' ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold),
                        onSelected: (val) {
                          if (val) setState(() => _approvalFilter = 'all');
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Task Cards List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text('No tasks found.',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Tap + above to create a task.',
                            style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    itemCount: filteredTasks.length,
                    itemBuilder: (ctx, i) {
                      final task = filteredTasks[i];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11.5,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedStatusFilter = key);
      },
    );
  }

  Widget _buildTaskCard(PocketGangTask task) {
    return GestureDetector(
      onTap: () => _showTaskDetails(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(task.status).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusLabel(task.status),
                    style: TextStyle(
                      color: _getStatusColor(task.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFFFFD700), size: 13),
                const SizedBox(width: 4),
                Text(
                  '${task.estimatedHours.toStringAsFixed(1)} hrs',
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.people_outline, color: Colors.white54, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.assignedMemberNames.isEmpty ? 'All Members' : task.assignedMemberNames.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
