import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive Tool Model for PocketGang Tools Library
class PocketGangToolInfo {
  final String key;
  final String name;
  final String category;
  final String icon;
  final String description;
  final bool isDefault;
  final bool isInstalled;

  const PocketGangToolInfo({
    required this.key,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
    this.isDefault = false,
    this.isInstalled = false,
  });
}

/// Dynamic Tools Library Bottom Sheet Modal
class PocketGangToolsLibrarySheet extends StatefulWidget {
  final String gangTypeKey;
  final List<String> installedToolKeys;
  final ValueChanged<List<String>> onToolsUpdated;

  const PocketGangToolsLibrarySheet({
    super.key,
    required this.gangTypeKey,
    required this.installedToolKeys,
    required this.onToolsUpdated,
  });

  static Future<List<String>?> show(
    BuildContext context, {
    required String gangTypeKey,
    required List<String> currentTools,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketGangToolsLibrarySheet(
        gangTypeKey: gangTypeKey,
        installedToolKeys: List<String>.from(currentTools),
        onToolsUpdated: (_) {},
      ),
    );
  }

  @override
  State<PocketGangToolsLibrarySheet> createState() => _PocketGangToolsLibrarySheetState();
}

class _PocketGangToolsLibrarySheetState extends State<PocketGangToolsLibrarySheet> {
  late Set<String> _selectedKeys;

  @override
  void initState() {
    super.initState();
    _selectedKeys = Set<String>.from(widget.installedToolKeys);
  }

  List<PocketGangToolInfo> _getAvailableTools() {
    if (widget.gangTypeKey == 'individual') {
      return const [
        PocketGangToolInfo(key: 'chat', name: 'Chat & Notes', category: 'Communication', icon: '💬', description: 'Personal reflections & voice notes', isDefault: true),
        PocketGangToolInfo(key: 'personal_tasks', name: 'Personal Tasks', category: 'Productivity', icon: '✅', description: 'Due dates, checklists & priority management'),
        PocketGangToolInfo(key: 'goals', name: 'Goals & Milestones', category: 'Productivity', icon: '🎯', description: 'Long & short-term target milestones'),
        PocketGangToolInfo(key: 'habits', name: 'Habit Tracker', category: 'Self-Care', icon: '🔥', description: 'Daily consistency and streak tracking'),
        PocketGangToolInfo(key: 'planner', name: 'Daily Planner', category: 'Productivity', icon: '📅', description: 'Schedule day activities and time blocks'),
        PocketGangToolInfo(key: 'focus_timer', name: 'Focus Timer', category: 'Productivity', icon: '⏱️', description: 'Pomodoro timer with study intervals'),
        PocketGangToolInfo(key: 'journal', name: 'Personal Journal', category: 'Self-Care', icon: '📖', description: 'Private daily thoughts & markdown entries'),
        PocketGangToolInfo(key: 'diagram', name: 'Mind Map', category: 'Creative', icon: '🧠', description: 'Visual mapping for personal projects'),
        PocketGangToolInfo(key: 'dashboard', name: 'Personal Dashboard', category: 'Analytics', icon: '📊', description: 'Personal progress & completion stats'),
      ];
    } else if (widget.gangTypeKey == 'couple') {
      return const [
        PocketGangToolInfo(key: 'chat', name: 'Couple Chat', category: 'Communication', icon: '💬', description: 'Private, secure chat for two', isDefault: true),
        PocketGangToolInfo(key: 'calendar', name: 'Shared Calendar', category: 'Life Planning', icon: '📅', description: 'Important dates, anniversaries & alerts'),
        PocketGangToolInfo(key: 'date_planner', name: 'Date Planner', category: 'Romance', icon: '🍷', description: 'Places to visit, activities & date ideas'),
        PocketGangToolInfo(key: 'countdown', name: 'Milestone Countdowns', category: 'Romance', icon: '⏳', description: 'Live countdowns for special days'),
        PocketGangToolInfo(key: 'bucket_list', name: 'Bucket List', category: 'Adventures', icon: '✨', description: 'Shared dreams & adventures to check off'),
        PocketGangToolInfo(key: 'memories', name: 'Memories Timeline', category: 'Romance', icon: '📸', description: 'Photo albums & timestamped moments'),
        PocketGangToolInfo(key: 'love_notes', name: 'Love Letters', category: 'Romance', icon: '💌', description: 'Private letters with open-by date seals'),
        PocketGangToolInfo(key: 'shared_goals', name: 'Shared Goals', category: 'Life Planning', icon: '🏡', description: 'Home, travel & joint savings goals'),
        PocketGangToolInfo(key: 'couple_tasks', name: 'Shared Tasks', category: 'Household', icon: '📝', description: 'Joint responsibilities and errands'),
        PocketGangToolInfo(key: 'couple_dashboard', name: 'Shared Dashboard', category: 'Analytics', icon: '💖', description: 'Celebration of memories and joint growth'),
      ];
    } else {
      // Friends & Team
      return const [
        PocketGangToolInfo(key: 'chat', name: 'Team Chat', category: 'Communication', icon: '💬', description: 'Instant messaging, files, and voice notes', isDefault: true),
        PocketGangToolInfo(key: 'ranking', name: 'Ranking Trail', category: 'Community', icon: '🏆', description: 'Mate fluency leaderboard & milestones', isDefault: true),
        PocketGangToolInfo(key: 'team_mgmt', name: 'Team Management', category: 'Workflows', icon: '👥', description: 'Member roles, responsibilities & settings'),
        PocketGangToolInfo(key: 'tasks_kanban', name: 'Kanban Tasks & Sprints', category: 'Workflows', icon: '📋', description: '6-stage workflow, assignments & effort points'),
        PocketGangToolInfo(key: 'time_tracker', name: 'Time Tracking', category: 'Productivity', icon: '⏱️', description: 'Voluntary work stopwatch & logged hours'),
        PocketGangToolInfo(key: 'dashboard', name: '100% Contribution Donut', category: 'Analytics', icon: '📊', description: 'Verified contribution breakdown totaling 100%'),
        PocketGangToolInfo(key: 'diagram_studio', name: 'Diagram Studio', category: 'Creative', icon: '📐', description: '15 diagram templates & flowcharts'),
        PocketGangToolInfo(key: 'whiteboard', name: 'Collab Whiteboard', category: 'Creative', icon: '🎨', description: 'Real-time brainstorming canvas'),
        PocketGangToolInfo(key: 'ideas_board', name: 'Ideas & Voting', category: 'Innovation', icon: '💡', description: 'Collect proposals, vote & convert to tasks'),
        PocketGangToolInfo(key: 'docs', name: 'Team Knowledge Base', category: 'Documents', icon: '📚', description: 'Shared documents & meeting minutes'),
        PocketGangToolInfo(key: 'finance', name: 'Finance & Profit Split', category: 'Business', icon: '💰', description: 'Expenses, revenue & agreed % profit share'),
      ];
    }
  }

  void _toggleTool(PocketGangToolInfo tool) {
    if (tool.isDefault) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tool.name} is a permanent core tool!'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF1E293B),
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedKeys.contains(tool.key)) {
        _selectedKeys.remove(tool.key);
      } else {
        _selectedKeys.add(tool.key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = _getAvailableTools();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('📦 ', style: TextStyle(fontSize: 22)),
              const Text(
                'PocketGang Tools Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1),
                ),
                child: Text(
                  '${_selectedKeys.length} Installed',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Install modular tools to personalize your Gang workspace. Core tools remain permanent.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Tools Grid / List
          Expanded(
            child: ListView.separated(
              itemCount: available.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tool = available[index];
                final isInstalled = _selectedKeys.contains(tool.key);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isInstalled
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isInstalled
                          ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                          : Colors.white12,
                      width: isInstalled ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(tool.icon, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tool.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (tool.isDefault) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'CORE',
                                      style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tool.description,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _toggleTool(tool),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: tool.isDefault
                                ? Colors.white12
                                : (isInstalled ? const Color(0xFFDC2626).withValues(alpha: 0.2) : const Color(0xFFFFD700)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: tool.isDefault
                                  ? Colors.transparent
                                  : (isInstalled ? const Color(0xFFDC2626) : const Color(0xFFFFD700)),
                            ),
                          ),
                          child: Text(
                            tool.isDefault ? 'LOCKED' : (isInstalled ? 'REMOVE' : 'INSTALL'),
                            style: TextStyle(
                              color: tool.isDefault ? Colors.white38 : (isInstalled ? const Color(0xFFF87171) : Colors.black),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedKeys.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Save Workspace Tools',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

