import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

class RunningTasksWidget extends StatefulWidget {
  final TeamsService service;
  const RunningTasksWidget({Key? key, required this.service}) : super(key: key);

  @override
  State<RunningTasksWidget> createState() => _RunningTasksWidgetState();
}

class _RunningTasksWidgetState extends State<RunningTasksWidget> {
  List<Map<String, dynamic>> _activeTasks = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveTasks();
    // Refresh task list every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
    
    // Poll for new tasks every 10 seconds (or use stream if available)
    Timer.periodic(const Duration(seconds: 10), (timer) {
       if (mounted) _loadActiveTasks();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveTasks() async {
    try {
      final tasks = await widget.service.getActiveTimers();
      if (mounted) {
        setState(() {
          _activeTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active tasks: $e');
    }
  }

  String _formatDuration(String? startedAtIso) {
    if (startedAtIso == null) return "00:00:00";
    final startedAt = DateTime.parse(startedAtIso).toUtc();
    final now = DateTime.now().toUtc();
    final diff = now.difference(startedAt);
    
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(diff.inHours);
    final minutes = twoDigits(diff.inMinutes.remainder(60));
    final seconds = twoDigits(diff.inSeconds.remainder(60));
    
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTasks.isEmpty && !_isLoading) return const SizedBox.shrink();
    if (_isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(1), // Border width
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.yellow.withValues(alpha: 0.5),
            Colors.orange.withValues(alpha: 0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(Icons.timer_outlined, size: 14, color: Colors.black),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ACTIVE TASKS',
                      style: GoogleFonts.outfit(
                        color: Colors.yellow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: GoogleFonts.outfit(
                        color: Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._activeTasks.map((task) => _buildTaskRow(task)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskRow(Map<String, dynamic> task) {
    final teamName = task['teams']?['name'] ?? 'Project';
    final taskTitle = task['title'] ?? 'Untitled Task';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatDuration(task['timer_started_at']),
              style: GoogleFonts.jetBrainsMono(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent, size: 28),
            onPressed: () async {
              await widget.service.stopTimer(task['id']);
              _loadActiveTasks();
            },
          ),
        ],
      ),
    );
  }
}
