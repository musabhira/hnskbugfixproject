import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketgang_task_service.dart';

/// 📊 PocketGang Genuine Minimal Dashboard
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

    final totalEffort = tasks
        .where((t) => t.status == 'completed' && t.approvedBy != null)
        .fold<int>(0, (sum, t) => sum + t.effortPoints);

    final progressPct = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return Container(
      color: const Color(0xFF0F172A),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GANG METRICS DASHBOARD',
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

          // Progress Card
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
              _buildKpiCard('Review', '$reviewTasks', const Color(0xFFA855F7)),
              const SizedBox(width: 8),
              _buildKpiCard('Approved', '$completedTasks', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 20),

          // Genuine Member Contribution Section
          Text('REAL VERIFIED CONTRIBUTIONS',
              style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),

          if (totalEffort == 0 || contributions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text('No approved contributions yet.',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  const Text(
                    'Contribution percentages will calculate dynamically once an admin reviews and approves completed tasks.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...contributions.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0F172A),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            '${c.approvedEffortPoints} verified pts · ${c.completedTasks} completed · ${c.reviewTasks} in review',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${c.contributionPercentage}%',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 18),
          // Legal disclaimer per requirement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PocketGang Contribution represents verified work completed within this group. It does not automatically establish legal business ownership or profit-sharing rights.',
                    style: TextStyle(
                        color: Colors.white60, fontSize: 10.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.outfit(
                    color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

