import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 📋 Gang Team Task Model
class PocketGangTask {
  final String id;
  final String groupId;
  String title;
  String description;
  String status; // 'todo', 'in_progress', 'review', 'completed'
  double estimatedHours; // Replaces effortPoints
  int effortPoints; // Kept for backward compatibility
  List<String> assignedMemberNames;
  List<String> assignedUserIds;
  List<String> approverMemberNames;
  List<String> approverUserIds;
  String createdBy;
  String? approvedBy;
  DateTime? approvedAt;
  String? rejectionReason;
  DateTime? dueDate;
  DateTime createdAt;

  PocketGangTask({
    required this.id,
    required this.groupId,
    required this.title,
    this.description = '',
    this.status = 'todo',
    this.estimatedHours = 1.0,
    this.effortPoints = 5,
    this.assignedMemberNames = const [],
    this.assignedUserIds = const [],
    this.approverMemberNames = const [],
    this.approverUserIds = const [],
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_id': groupId,
        'title': title,
        'description': description,
        'status': status,
        'estimated_hours': estimatedHours,
        'effort_points': effortPoints,
        'assigned_member_names': assignedMemberNames,
        'assigned_user_ids': assignedUserIds,
        'approver_member_names': approverMemberNames,
        'approver_user_ids': approverUserIds,
        'created_by': createdBy,
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'rejection_reason': rejectionReason,
        'due_date': dueDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory PocketGangTask.fromJson(Map<String, dynamic> json) {
    return PocketGangTask(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Task',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'todo',
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble() ??
          (json['effort_points'] as num?)?.toDouble() ??
          1.0,
      effortPoints: (json['effort_points'] as num?)?.toInt() ?? 5,
      assignedMemberNames: (json['assigned_member_names'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      assignedUserIds: (json['assigned_user_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      approverMemberNames: (json['approver_member_names'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      approverUserIds: (json['approver_user_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdBy: json['created_by']?.toString() ?? '',
      approvedBy: json['approved_by']?.toString(),
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// 📈 Real Gang Member Contribution Computation
/// Contribution is strictly calculated from APPROVED COMPLETED tasks.
/// If a task has N assignees, each receives 1/N task units (equal split).
class RealMemberContribution {
  final String userId;
  final String name;
  final int totalAssigned;
  final int completedTasks;
  final int reviewTasks;
  final double approvedUnits; // 1.0 split among assignees
  final int approvedEffortPoints; // Backward compatibility
  final double contributionPercentage;

  const RealMemberContribution({
    required this.userId,
    required this.name,
    required this.totalAssigned,
    required this.completedTasks,
    required this.reviewTasks,
    this.approvedUnits = 0.0,
    required this.approvedEffortPoints,
    required this.contributionPercentage,
  });
}

/// 🏢 PocketGang Task & Real Contribution Service
class PocketGangTaskService {
  PocketGangTaskService._();
  static final PocketGangTaskService instance = PocketGangTaskService._();

  static const String _activitiesTableName = 'group_activities';

  /// Load real tasks for the group
  Future<List<PocketGangTask>> getTasks(String groupId) async {
    if (groupId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_tasks_$groupId';

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from(_activitiesTableName)
          .select('data')
          .eq('group_id', groupId)
          .eq('activity_type', 'gang_kanban_tasks')
          .maybeSingle();

      if (res != null && res['data'] != null) {
        final data = res['data'];
        List<dynamic> list = [];
        if (data is Map && data['tasks'] is List) {
          list = data['tasks'];
        } else if (data is List) {
          list = data;
        }
        final tasks = list
            .map((item) =>
                PocketGangTask.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        await prefs.setString(
            cacheKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
        return tasks;
      }
    } catch (e) {
      debugPrint('Error loading group tasks: $e');
    }

    // Fallback to local cache
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final List list = jsonDecode(cached);
        return list
            .map((e) => PocketGangTask.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    return [];
  }

  /// Save tasks back to group
  Future<void> saveTasks({
    required String groupId,
    required List<PocketGangTask> tasks,
    required String userId,
  }) async {
    if (groupId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_tasks_$groupId';
    await prefs.setString(
        cacheKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));

    try {
      final supabase = Supabase.instance.client;
      await supabase.from(_activitiesTableName).upsert({
        'group_id': groupId,
        'activity_type': 'gang_kanban_tasks',
        'title': 'Kanban Tasks',
        'data': {
          'tasks': tasks.map((t) => t.toJson()).toList(),
          'updated_by': userId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'created_by': userId,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('Error saving gang tasks: $e');
    }
  }

  /// Calculate genuine real contributions based strictly on approved completed tasks
  /// If a task has N assignees, 1 task unit is split equally: 1 / N per member.
  List<RealMemberContribution> calculateContributions({
    required List<Map<String, dynamic>> groupMembers,
    required List<PocketGangTask> tasks,
  }) {
    if (groupMembers.isEmpty) return [];

    // Map members by userId and name
    final Map<String, String> memberNameMap = {};
    for (final m in groupMembers) {
      final uid = m['user_id']?.toString() ?? '';
      final name = m['profile']?['name']?.toString() ??
          m['name']?.toString() ??
          'Member';
      if (uid.isNotEmpty) {
        memberNameMap[uid] = name;
      }
    }

    final Map<String, double> approvedUnitsMap = {};
    final Map<String, int> totalAssignedMap = {};
    final Map<String, int> completedCountMap = {};
    final Map<String, int> reviewCountMap = {};

    for (final uid in memberNameMap.keys) {
      approvedUnitsMap[uid] = 0.0;
      totalAssignedMap[uid] = 0;
      completedCountMap[uid] = 0;
      reviewCountMap[uid] = 0;
    }

    for (final task in tasks) {
      final assignees = task.assignedUserIds.isNotEmpty
          ? task.assignedUserIds
          : (task.assignedMemberNames.isNotEmpty
              ? memberNameMap.entries
                  .where((e) => task.assignedMemberNames.contains(e.value))
                  .map((e) => e.key)
                  .toList()
              : []);

      final isApproved = task.status == 'completed' &&
          (task.approvedBy != null && task.approvedBy!.isNotEmpty);

      final shareCount = assignees.isEmpty ? 1 : assignees.length;
      final unitPerMember = 1.0 / shareCount;

      for (final uid in assignees) {
        totalAssignedMap[uid] = (totalAssignedMap[uid] ?? 0) + 1;
        if (task.status == 'review') {
          reviewCountMap[uid] = (reviewCountMap[uid] ?? 0) + 1;
        }
        if (isApproved) {
          completedCountMap[uid] = (completedCountMap[uid] ?? 0) + 1;
          approvedUnitsMap[uid] = (approvedUnitsMap[uid] ?? 0.0) + unitPerMember;
        }
      }
    }

    final totalUnits =
        approvedUnitsMap.values.fold<double>(0.0, (sum, u) => sum + u);

    final List<RealMemberContribution> results = [];

    for (final entry in memberNameMap.entries) {
      final uid = entry.key;
      final name = entry.value;
      final units = approvedUnitsMap[uid] ?? 0.0;
      final pct = totalUnits > 0
          ? double.parse(((units / totalUnits) * 100).toStringAsFixed(1))
          : 0.0;

      results.add(RealMemberContribution(
        userId: uid,
        name: name,
        totalAssigned: totalAssignedMap[uid] ?? 0,
        completedTasks: completedCountMap[uid] ?? 0,
        reviewTasks: reviewCountMap[uid] ?? 0,
        approvedUnits: units,
        approvedEffortPoints: units.round(),
        contributionPercentage: pct,
      ));
    }

    return results;
  }
}
