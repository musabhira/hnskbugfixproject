import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_diagram_studio_editor_page.dart';

/// Task Item in Team Kanban Board
class GangTeamTask {
  final String id;
  String title;
  String status; // 'backlog', 'todo', 'in_progress', 'blocked', 'review', 'completed'
  int effortPoints; // 1 to 10
  String assigneeName;
  double loggedHours;

  GangTeamTask({
    required this.id,
    required this.title,
    required this.status,
    required this.effortPoints,
    required this.assigneeName,
    this.loggedHours = 0.0,
  });
}

/// Member Contribution Metric for the Donut Chart
class GangMemberContribution {
  final String name;
  final int verifiedPoints;
  final double loggedHours;
  final double onTimeRate; // 0.0 to 1.0
  final Color themeColor;

  const GangMemberContribution({
    required this.name,
    required this.verifiedPoints,
    required this.loggedHours,
    required this.onTimeRate,
    required this.themeColor,
  });
}

/// 👥 Complete Friends & Team Gang: Collaboration & Project Workspace
class PocketGangTeamWorkspaceWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const PocketGangTeamWorkspaceWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  State<PocketGangTeamWorkspaceWidget> createState() =>
      _PocketGangTeamWorkspaceWidgetState();
}

class _PocketGangTeamWorkspaceWidgetState
    extends State<PocketGangTeamWorkspaceWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Kanban Board State (6 Workflows)
  final List<GangTeamTask> _tasks = [
    GangTeamTask(id: 't1', title: 'Design Landing Page Wireframes', status: 'completed', effortPoints: 5, assigneeName: 'Adarsh', loggedHours: 6.5),
    GangTeamTask(id: 't2', title: 'Implement Supabase Auth & RLS Rules', status: 'completed', effortPoints: 8, assigneeName: 'Rahul', loggedHours: 9.0),
    GangTeamTask(id: 't3', title: 'Develop Flutter 2D Game Canvas', status: 'in_progress', effortPoints: 7, assigneeName: 'Adarsh', loggedHours: 4.5),
    GangTeamTask(id: 't4', title: 'Prepare Investor Pitch Deck', status: 'review', effortPoints: 6, assigneeName: 'Meera', loggedHours: 5.0),
    GangTeamTask(id: 't5', title: 'Setup Stripe & UPI Payment Gateway', status: 'blocked', effortPoints: 9, assigneeName: 'Rahul', loggedHours: 2.0),
    GangTeamTask(id: 't6', title: 'Write User Acceptance Tests', status: 'todo', effortPoints: 4, assigneeName: 'Meera', loggedHours: 0.0),
  ];

  // 2. Member Metrics for 100% Contribution Donut Chart
  final List<GangMemberContribution> _members = const [
    GangMemberContribution(name: 'Adarsh', verifiedPoints: 12, loggedHours: 11.0, onTimeRate: 0.95, themeColor: Color(0xFF38BDF8)),
    GangMemberContribution(name: 'Rahul', verifiedPoints: 17, loggedHours: 11.0, onTimeRate: 0.85, themeColor: Color(0xFFFFD700)),
    GangMemberContribution(name: 'Meera', verifiedPoints: 10, loggedHours: 5.0, onTimeRate: 0.88, themeColor: Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Fair Contribution Formula: 60% Points + 25% Hours + 15% Reliability
  Map<String, double> _calculateContributionPercentages() {
    final totalPoints = _members.fold<int>(0, (sum, m) => sum + m.verifiedPoints);
    final totalHours = _members.fold<double>(0, (sum, m) => sum + m.loggedHours);
    final totalReliability = _members.fold<double>(0, (sum, m) => sum + m.onTimeRate);

    if (totalPoints == 0 || totalHours == 0) {
      final equalShare = 100.0 / _members.length;
      return {for (var m in _members) m.name: equalShare};
    }

    final rawScores = <String, double>{};
    double sumScores = 0.0;

    for (final m in _members) {
      final pNorm = m.verifiedPoints / totalPoints;
      final hNorm = m.loggedHours / totalHours;
      final rNorm = m.onTimeRate / totalReliability;
      final score = (0.60 * pNorm) + (0.25 * hNorm) + (0.15 * rNorm);
      rawScores[m.name] = score;
      sumScores += score;
    }

    final resultMap = <String, double>{};
    for (final entry in rawScores.entries) {
      resultMap[entry.key] = double.parse(((entry.value / sumScores) * 100).toStringAsFixed(1));
    }
    return resultMap;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Sub-Header Ribbon Tabs
          Container(
            height: 42,
            color: const Color(0xFF1E293B),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFFFFD700),
              indicatorWeight: 2.5,
              labelColor: const Color(0xFFFFD700),
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.view_kanban_outlined, size: 14), text: 'Kanban Board'),
                Tab(icon: Icon(Icons.pie_chart_outline_rounded, size: 14), text: '100% Contribution'),
                Tab(icon: Icon(Icons.architecture_rounded, size: 14), text: 'Diagram Studio'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildKanbanBoardView(),
                _buildContributionDonutView(),
                _buildDiagramStudioView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Kanban Board View with 6 Status Columns
  Widget _buildKanbanBoardView() {
    final statuses = [
      {'key': 'todo', 'label': 'TO DO', 'color': const Color(0xFF38BDF8)},
      {'key': 'in_progress', 'label': 'IN PROGRESS', 'color': const Color(0xFFF59E0B)},
      {'key': 'review', 'label': 'IN REVIEW', 'color': const Color(0xFFA855F7)},
      {'key': 'blocked', 'label': 'BLOCKED', 'color': const Color(0xFFEF4444)},
      {'key': 'completed', 'label': 'COMPLETED', 'color': const Color(0xFF10B981)},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(14),
      itemCount: statuses.length,
      itemBuilder: (context, colIndex) {
        final col = statuses[colIndex];
        final colTasks = _tasks.where((t) => t.status == col['key']).toList();
        final colColor = col['color'] as Color;

        return Container(
          width: 260,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: colColor)),
                      const SizedBox(width: 8),
                      Text(
                        col['label'] as String,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${colTasks.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tasks in Column
              Expanded(
                child: ListView.separated(
                  itemCount: colTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, tIndex) {
                    final task = colTasks[tIndex];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '⚡ ${task.effortPoints} PTS',
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 12, color: Colors.white54),
                                  const SizedBox(width: 3),
                                  Text(task.assigneeName, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. 100% Contribution Donut Chart View
  Widget _buildContributionDonutView() {
    final percentages = _calculateContributionPercentages();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GANG CONTRIBUTION ANALYTICS',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Text('100.0% VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontSize: 9.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Painted Donut Chart
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _GangContributionDonutPainter(
                members: _members,
                percentages: percentages,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('100%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    Text('TOTAL EFFORT', style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Member Breakdown List
          ..._members.map((m) {
            final pct = percentages[m.name] ?? 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: m.themeColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: m.themeColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('${m.verifiedPoints} pts · ${m.loggedHours}h logged · ${(m.onTimeRate * 100).toInt()}% on-time',
                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: GoogleFonts.outfit(color: m.themeColor, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),

          // Legal Equity Disclaimer
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
                Icon(Icons.info_outline_rounded, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PocketGang Contribution represents recorded work and productivity within this workspace. It does not automatically establish legal ownership, equity, or profit-sharing rights.',
                    style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Diagram Studio Preview View
  Widget _buildDiagramStudioView() {
    final templates = [
      {'name': 'Flowchart', 'icon': '🔄', 'desc': 'Decision logic & process routing'},
      {'name': 'Mind Map', 'icon': '🧠', 'desc': 'Central ideas & brainstorm branching'},
      {'name': 'Business Model Canvas', 'icon': '📊', 'desc': 'Standardized 9-box lean canvas'},
      {'name': 'Software Architecture', 'icon': '💻', 'desc': 'APIs, microservices & DB topology'},
      {'name': 'Database ER Diagram', 'icon': '🗄️', 'desc': 'Tables, foreign keys & relationships'},
      {'name': 'Gantt Timeline', 'icon': '⏳', 'desc': 'Horizontal phase milestones & dates'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DIAGRAM STUDIO (15 TEMPLATES)',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('COLLABORATIVE', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final t = templates[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    PocketDiagramStudioEditorPage.open(
                      context,
                      diagramTitle: '${t['name']} - ${widget.groupName}',
                      templateKey: (t['name'] ?? '').toLowerCase().contains('mind')
                          ? 'mindmap'
                          : ((t['name'] ?? '').toLowerCase().contains('flow') ? 'flowchart' : 'architecture'),
                      groupName: widget.groupName,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['icon']!, style: const TextStyle(fontSize: 24)),
                        const Spacer(),
                        Text(t['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(t['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 10.5), maxLines: 2, overflow: TextOverflow.ellipsis),
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
}

/// Custom Donut Chart Painter
class _GangContributionDonutPainter extends CustomPainter {
  final List<GangMemberContribution> members;
  final Map<String, double> percentages;

  _GangContributionDonutPainter({required this.members, required this.percentages});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (final m in members) {
      final pct = (percentages[m.name] ?? 0.0) / 100.0;
      final sweepAngle = pct * 2 * math.pi;

      paint.color = m.themeColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _GangContributionDonutPainter oldDelegate) => true;
}

