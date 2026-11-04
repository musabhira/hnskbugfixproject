import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketgang_task_service.dart';

/// 📊 PocketGang Genuine Dashboard with Circular Donut Contribution Chart
class PocketGangDashboardWidget extends StatelessWidget {
  final String groupId;
  final String groupName;
  final List<PocketGangTask> tasks;
  final List<RealMemberContribution> contributions;

  const PocketGangDashboardWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.tasks,
    required this.contributions,
  });

  @override
  Widget build(BuildContext context) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == 'completed').length;
    final reviewTasks = tasks.where((t) => t.status == 'review').length;
    final inProgressTasks = tasks.where((t) => t.status == 'in_progress').length;
    final todoTasks = tasks.where((t) => t.status == 'todo').length;

    // Completed approved tasks count
    final approvedTasks = tasks
        .where((t) => t.status == 'completed' && t.approvedBy != null && t.approvedBy!.isNotEmpty)
        .length;

    final progressPct = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    // Filter contributions with actual approved units
    final activeContributions = contributions.where((c) => c.approvedUnits > 0).toList();

    return Container(
      color: const Color(0xFF0F172A),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TEAM CONTRIBUTION DASHBOARD',
                  style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text('$totalTasks TOTAL TASKS',
                    style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project Progress Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Project Completion Progress',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Text('${(progressPct * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressPct,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Block KPI Summary
          Row(
            children: [
              _buildKpiCard('To Do', '$todoTasks', const Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              _buildKpiCard('In Progress', '$inProgressTasks', const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildKpiCard('Pending Appr.', '$reviewTasks', const Color(0xFFA855F7)),
              const SizedBox(width: 8),
              _buildKpiCard('Approved', '$approvedTasks', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 24),

          // Circular/Donut Team Contribution Chart Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TEAM CONTRIBUTION',
                  style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              Text('$approvedTasks Approved Tasks',
                  style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),

          if (approvedTasks == 0 || activeContributions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text('🍩', style: TextStyle(fontSize: 34)),
                  const SizedBox(height: 8),
                  Text('No approved tasks completed yet.',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Contribution percentages calculate automatically as approved completed tasks are finished (1 unit split equally across assignees).',
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            // Donut Chart & Legend Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  // Donut Visual
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(160, 160),
                          painter: _DonutChartPainter(contributions: activeContributions),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$approvedTasks',
                                style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900)),
                            const Text('Approved',
                                style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Member Breakdown List
                  ...activeContributions.map((c) {
                    final color = _getMemberColor(c.name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.name,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${c.approvedUnits.toStringAsFixed(1)} units',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${c.contributionPercentage}%',
                            style: GoogleFonts.outfit(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static final List<Color> _palette = [
    const Color(0xFFFFD700),
    const Color(0xFF38BDF8),
    const Color(0xFF10B981),
    const Color(0xFFA855F7),
    const Color(0xFFF97316),
    const Color(0xFFEC4899),
    const Color(0xFF6366F1),
  ];

  static Color _getMemberColor(String name) {
    final hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return _palette[hash % _palette.length];
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.outfit(
                    color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<RealMemberContribution> contributions;

  _DonutChartPainter({required this.contributions});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    double startAngle = -math.pi / 2;

    for (final c in contributions) {
      final sweepAngle = (c.contributionPercentage / 100.0) * (2 * math.pi);
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = PocketGangDashboardWidget._getMemberColor(c.name)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04, // slight gap
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
