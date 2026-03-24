import 'package:supabase_flutter/supabase_flutter.dart';

class Team {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class TeamMember {
  final String id;
  final String teamId;
  final String userId;
  final String role; // owner, admin, member
  final String status; // pending, approved, rejected
  final Map<String, dynamic>? profile; // Joined profile data

  TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    required this.status,
    this.profile,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      teamId: json['team_id'],
      userId: json['user_id'],
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'pending',
      profile: json['user_profile'] ??
          json['profile'], // Adjust based on your profile table join
    );
  }
}

class TeamTask {
  final String id;
  final String teamId;
  final String title;
  final String? description;
  final String? assignedTo;
  final String createdBy;
  final DateTime? dueDate;
  final String status; // todo, in_progress, completed, bug, on_hold
  final String priority; // low, medium, high
  final int timeSpent; // in minutes
  final DateTime? timerStartedAt;

  TeamTask({
    required this.id,
    required this.teamId,
    required this.title,
    this.description,
    this.assignedTo,
    required this.createdBy,
    this.dueDate,
    required this.status,
    required this.priority,
    this.timeSpent = 0,
    this.timerStartedAt,
  });

  factory TeamTask.fromJson(Map<String, dynamic> json) {
    return TeamTask(
      id: json['id'],
      teamId: json['team_id'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assigned_to'],
      createdBy: json['created_by'],
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      timeSpent: json['time_spent'] ?? 0,
      timerStartedAt: json['timer_started_at'] != null
          ? DateTime.parse(json['timer_started_at'])
          : null,
    );
  }
}

class UserResult {
  final String id;
  final String userId;
  final String name;
  final String? profileImageUrl;
  final String? email;

  UserResult(
      {required this.id,
      required this.userId,
      required this.name,
      this.profileImageUrl,
      this.email});

  factory UserResult.fromJson(Map<String, dynamic> json) {
    String? email = json['email'];
    if (email == null && json['users'] != null && json['users'] is Map) {
      email = json['users']['email'];
    }

    return UserResult(
      id: json['id'],
      userId: json['user_id'] ?? json['id'],
      name: json['name'] ?? 'Unknown',
      profileImageUrl: json['profile_image_url'],
      email: email,
    );
  }
}

class TeamsService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get authUserId => _client.auth.currentUser?.id;

  // --- Teams ---

  Future<List<Team>> getMyTeams() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    // Fetch teams where user is a member with 'approved' status
    final response = await _client
        .from('teams')
        .select('*, team_members!inner(user_id, status)')
        .eq('team_members.user_id', userId)
        .eq('team_members.status', 'approved')
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data.map((json) => Team.fromJson(json)).toList();
  }

  Future<Team> createTeam(
      String name, String description, List<String> initialMemberIds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('teams')
        .insert({
          'name': name,
          'description': description,
          'created_by': userId,
        })
        .select()
        .single();

    final team = Team.fromJson(response);

    // Auto-add creator as owner
    await _client.from('team_members').insert({
      'team_id': team.id,
      'user_id': userId,
      'role': 'owner',
      'status': 'approved',
    });

    // Invite initial members
    for (var memberId in initialMemberIds) {
      await inviteMember(team.id, memberId);
    }

    return team;
  }

  // --- Search ---

  Future<List<UserResult>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      // 1. Search in profile table by name
      final profileRes = await _client
          .from('profile')
          .select('id, user_id, name, profile_image_url')
          .ilike('name', '%$query%')
          .limit(20);

      final profiles = profileRes as List<dynamic>;
      final results = profiles.map((p) => UserResult.fromJson(p)).toList();

      // 2. If results are few and query might be an email, search by email separately
      if (results.length < 5 && query.contains('@')) {
        final userRes = await _client
            .from('users')
            .select('id, email, profile:profile(id, user_id, name, profile_image_url)')
            .ilike('email', '%$query%')
            .limit(5);

        final users = userRes as List<dynamic>;
        for (var u in users) {
          if (u['profile'] != null) {
            final p = u['profile'] as Map<String, dynamic>;
            p['email'] = u['email'];
            // Check if already in results
            if (!results.any((r) => r.userId == p['user_id'])) {
              results.add(UserResult.fromJson(p));
            }
          }
        }
      }

      return results;
    } catch (e) {
      print('Search failed: $e');
      // Minimal fallback
      final resp = await _client
          .from('profile')
          .select('id, user_id, name, profile_image_url')
          .ilike('name', '%$query%')
          .limit(10);
      return (resp as List).map((j) => UserResult.fromJson(j)).toList();
    }
  }

  // --- Members & Invites ---

  Future<List<TeamMember>> getTeamMembers(String teamId) async {
    try {
      // 1. Fetch members
      final response = await _client
          .from('team_members')
          .select('*')
          .eq('team_id', teamId);
      
      final membersData = response as List<dynamic>;
      if (membersData.isEmpty) return [];

      // 2. Fetch profiles for these users separately to avoid join errors
      final userIds = membersData.map((m) => m['user_id'] as String).toList();
      final profileResponse = await _client
          .from('profile')
          .select('id, user_id, name, profile_image_url')
          .inFilter('user_id', userIds);
      
      final profiles = profileResponse as List<dynamic>;
      final profileMap = { for (var p in profiles) p['user_id'] as String : p };

      // 3. Combine
      return membersData.map((json) {
        final uid = json['user_id'] as String;
        final memberJson = Map<String, dynamic>.from(json);
        memberJson['user_profile'] = profileMap[uid];
        return TeamMember.fromJson(memberJson);
      }).toList();
    } catch (e) {
      print('Error in getTeamMembers: $e');
      return [];
    }
  }

  Future<void> inviteMember(String teamId, String userId,
      {String role = 'member'}) async {
    final currentUserId = _client.auth.currentUser?.id;

    // 1. Create Team Member (Pending)
    await _client.from('team_members').upsert({
      'team_id': teamId,
      'user_id': userId,
      'role': role,
      'status': 'pending',
    }, onConflict: 'team_id, user_id');

    // 2. Create Notification
    // Need team name for the message
    final teamRes =
        await _client.from('teams').select('name').eq('id', teamId).single();
    final teamName = teamRes['name'];

    await _client.from('notifications').insert({
      'user_id': userId,
      'type': 'project_invite',
      'source_id': teamId,
      'message': 'You have been invited to join project "$teamName"',
      'sender_id': currentUserId,
    });
  }

  Future<void> updateMemberStatus(String memberId, String status) async {
    await _client.from('team_members').update({
      'status': status,
    }).eq('id', memberId);
  }

  Future<void> acceptInvite(String teamId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('team_members').update({
      'status': 'approved',
    }).match({'team_id': teamId, 'user_id': userId});

    // Mark related notification as read/accepted?
    // Optionally find notification by source_id and user_id
  }

  Future<void> declineInvite(String teamId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('team_members').update({
      'status': 'rejected',
    }).match({'team_id': teamId, 'user_id': userId});
  }

  // --- Tasks ---

  Future<List<TeamTask>> getTeamTasks(String teamId) async {
    final response = await _client
        .from('team_tasks')
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data.map((json) => TeamTask.fromJson(json)).toList();
  }

  Future<void> createTeamTask(String teamId, String title,
      {String? description,
      String? assignedTo,
      DateTime? dueDate,
      String priority = 'medium'}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('team_tasks')
        .insert({
          'team_id': teamId,
          'title': title,
          'description': description,
          'assigned_to': assignedTo,
          'created_by': userId,
          'due_date': dueDate?.toIso8601String(),
          'status': 'todo',
          'priority': priority,
        })
        .select()
        .single();

    final newTaskId = response['id'];

    if (assignedTo != null && assignedTo != userId) {
      final teamRes =
          await _client.from('teams').select('name').eq('id', teamId).single();
      final teamName = teamRes['name'];

      await _client.from('notifications').insert({
        'user_id': assignedTo,
        'type': 'task_assign',
        'source_id': newTaskId,
        'message':
            'You have been assigned task "$title" in project "$teamName"',
        'sender_id': userId,
      });
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    await _client.from('team_tasks').update({
      'status': status,
    }).eq('id', taskId);
  }

  Future<void> logTime(String taskId, int minutesToAdd) async {
    // 1. Get current time
    final taskRes = await _client
        .from('team_tasks')
        .select('time_spent')
        .eq('id', taskId)
        .single();
    final current = taskRes['time_spent'] as int? ?? 0;

    // 2. Update
    await _client.from('team_tasks').update({
      'time_spent': current + minutesToAdd,
    }).eq('id', taskId);
  }

  Future<void> startTimer(String taskId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from('team_tasks').update({
      'timer_started_at': now,
      'status': 'in_progress',
    }).eq('id', taskId);
  }

  Future<void> stopTimer(String taskId) async {
    // 1. Get task data
    final taskRes = await _client
        .from('team_tasks')
        .select('timer_started_at, time_spent')
        .eq('id', taskId)
        .single();

    final startedAtJoined = taskRes['timer_started_at'];
    if (startedAtJoined == null) return;

    final startedAt = DateTime.parse(startedAtJoined);
    final currentSpent = taskRes['time_spent'] as int? ?? 0;

    // 2. Calculate duration
    final diff = DateTime.now().toUtc().difference(startedAt);
    final minutes = diff.inMinutes;

    // 3. Update task
    await _client.from('team_tasks').update({
      'timer_started_at': null,
      'time_spent': currentSpent + minutes,
    }).eq('id', taskId);
  }

  Future<void> updateTaskAssignment(String taskId, String? userId) async {
    await _client
        .from('team_tasks')
        .update({'assigned_to': userId}).eq('id', taskId);

    if (userId != null) {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId != null && userId != currentUserId) {
        // Fetch task details for notification
        final taskRes = await _client
            .from('team_tasks')
            .select('title, team_id, teams(name)')
            .eq('id', taskId)
            .single();

        final taskTitle = taskRes['title'];
        final teamName = taskRes['teams']['name'];

        await _client.from('notifications').insert({
          'user_id': userId,
          'type': 'task_assign',
          'source_id': taskId,
          'message':
              'You have been assigned task "$taskTitle" in project "$teamName"',
          'sender_id': currentUserId,
        });
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from('team_tasks').delete().eq('id', taskId);
  }

  // --- Notifications ---

  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .map((event) => event);
  }

  Future<List<Map<String, dynamic>>> getActiveTimers() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('team_tasks')
        .select('*, teams(*)')
        .eq('assigned_to', userId)
        .not('timer_started_at', 'is', null);

    return List<Map<String, dynamic>>.from(response as List);
  }
}
