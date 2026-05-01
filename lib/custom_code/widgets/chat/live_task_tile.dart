import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/team_detail_page.dart';

class LiveTaskTile extends StatefulWidget {
  final TeamsService service;
  final String? filterTeamId; // Optional: only show tasks for this team

  const LiveTaskTile({
    super.key,
    required this.service,
    this.filterTeamId,
  });

  @override
  State<LiveTaskTile> createState() => _LiveTaskTileState();
}

class _LiveTaskTileState extends State<LiveTaskTile> {
  List<Map<String, dynamic>> _activeTasks = [];
  Timer? _uiRefreshTimer;
  Timer? _pollingTimer;
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadActiveTasks();
    _setupRealtime();
    
    // UI refresh for the timer display (every second)
    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _activeTasks.isNotEmpty) {
        setState(() {});
      }
    });
  }

  void _setupRealtime() {
    _realtimeSubscription = widget.service.getActiveTasksStream().listen((tasks) {
      // Apply filter if provided
      var filteredTasks = tasks;
      if (widget.filterTeamId != null) {
        filteredTasks = tasks.where((t) => t['team_id'] == widget.filterTeamId).toList();
      }

      if (mounted) {
        setState(() {
          _activeTasks = filteredTasks;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    _pollingTimer?.cancel();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveTasks() async {
    try {
      final tasks = await widget.service.getActiveTimers();
      
      // Apply filter if provided
      var filteredTasks = tasks;
      if (widget.filterTeamId != null) {
        filteredTasks = tasks.where((t) => t['team_id'] == widget.filterTeamId).toList();
      }

      if (mounted) {
        setState(() {
          _activeTasks = filteredTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active tasks in chat: $e');
    }
  }

  String _formatDuration(String? startedAtIso) {
    if (startedAtIso == null) return "00:00:00";
    try {
      final startedAt = DateTime.parse(startedAtIso).toUtc();
      final now = DateTime.now().toUtc();
      final diff = now.difference(startedAt);
      
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      final hours = twoDigits(diff.inHours);
      final minutes = twoDigits(diff.inMinutes.remainder(60));
      final seconds = twoDigits(diff.inSeconds.remainder(60));
      
      return "$hours:$minutes:$seconds";
    } catch (e) {
      return "00:00:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTasks.isEmpty && !_isLoading) return const SizedBox.shrink();
    if (_isLoading) return const SizedBox.shrink();

    // Show only the first active task for brevity in chat
    final task = _activeTasks.first;
    final teamName = task['teams']?['name'] ?? 'Team';
    final taskTitle = task['title'] ?? 'Active Task';
    final teamData = task['teams'] != null ? Team.fromJson(task['teams']) : null;

    return GestureDetector(
      onTap: () {
        if (teamData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailPage(team: teamData),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.yellow.withValues(alpha: 0.15),
              Colors.orange.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.yellow.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(Icons.timer_outlined, size: 16, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'LIVE TASK',
                              style: GoogleFonts.outfit(
                                color: Colors.yellow,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          taskTitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          teamName,
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(task['timer_started_at']),
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.yellow,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          await widget.service.stopTimer(task['id']);
                          _loadActiveTasks();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'STOP',
                            style: GoogleFonts.outfit(
                              color: Colors.redAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
