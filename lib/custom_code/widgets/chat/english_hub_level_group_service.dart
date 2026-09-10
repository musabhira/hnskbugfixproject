import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🌐 Model representing a configured English Hub level bracket group
class EnglishHubLevelGroup {
  final String id;
  final String groupId;
  final String groupName;
  final int minLevel;
  final int maxLevel;
  final String stageTitle;
  final String tagBadge;
  final String iconEmoji;
  final bool isActive;
  final int sortOrder;

  const EnglishHubLevelGroup({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.minLevel,
    required this.maxLevel,
    required this.stageTitle,
    required this.tagBadge,
    required this.iconEmoji,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory EnglishHubLevelGroup.fromMap(Map<String, dynamic> map) {
    return EnglishHubLevelGroup(
      id: map['id']?.toString() ?? '',
      groupId: map['group_id']?.toString() ?? '',
      groupName: map['group_name']?.toString() ?? 'English Hub',
      minLevel: (map['min_level'] as num?)?.toInt() ?? 1,
      maxLevel: (map['max_level'] as num?)?.toInt() ?? 6,
      stageTitle: map['stage_title']?.toString() ?? 'Language Hub',
      tagBadge: map['tag_badge']?.toString() ?? 'Cohort',
      iconEmoji: map['icon_emoji']?.toString() ?? '💬',
      isActive: map['is_active'] as bool? ?? true,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'min_level': minLevel,
      'max_level': maxLevel,
      'stage_title': stageTitle,
      'tag_badge': tagBadge,
      'icon_emoji': iconEmoji,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  bool containsLevel(int level) => level >= minLevel && level <= maxLevel;
}

/// 🚀 Service to manage Dynamic Multi-Level English Hub WhatsApp Groups,
/// Auto-transition/graduation, and Custom Admin configurations.
class EnglishHubLevelGroupService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Default bracket specifications as defined in user audio directives:
  /// - Level 1 to 6
  /// - Level 6 to 11
  /// - 12 onwards in 5-level increments up to Day 90
  static const List<Map<String, dynamic>> kDefaultBrackets = [
    {
      'name': 'English Hub (Lvl 1 - 5)',
      'min': 1,
      'max': 5,
      'title': 'Rookie Foundations',
      'tag': 'A1 Beginner',
      'emoji': '🌱',
      'order': 1,
    },
    {
      'name': 'English Hub (Lvl 6 - 11)',
      'min': 6,
      'max': 11,
      'title': 'Intermediate Grammar',
      'tag': 'A2 Elementary',
      'emoji': '⚡',
      'order': 2,
    },
    {
      'name': 'English Hub (Lvl 12 - 16)',
      'min': 12,
      'max': 16,
      'title': 'Conversational Agility',
      'tag': 'B1 Threshold',
      'emoji': '🔥',
      'order': 3,
    },
    {
      'name': 'English Hub (Lvl 17 - 21)',
      'min': 17,
      'max': 21,
      'title': 'Public Speaking & Logic',
      'tag': 'B1 Intermediate',
      'emoji': '🗣️',
      'order': 4,
    },
    {
      'name': 'English Hub (Lvl 22 - 26)',
      'min': 22,
      'max': 26,
      'title': 'Idioms & Natural Flow',
      'tag': 'B2 Vantage',
      'emoji': '🎯',
      'order': 5,
    },
    {
      'name': 'English Hub (Lvl 27 - 31)',
      'min': 27,
      'max': 31,
      'title': 'Spontaneous Discourse',
      'tag': 'B2 Higher',
      'emoji': '💡',
      'order': 6,
    },
    {
      'name': 'English Hub (Lvl 32 - 36)',
      'min': 32,
      'max': 36,
      'title': 'Professional Oratory',
      'tag': 'B2+ Advanced',
      'emoji': '💼',
      'order': 7,
    },
    {
      'name': 'English Hub (Lvl 37 - 41)',
      'min': 37,
      'max': 41,
      'title': 'Rhetorical Eloquence',
      'tag': 'C1 Effective',
      'emoji': '🏛️',
      'order': 8,
    },
    {
      'name': 'English Hub (Lvl 42 - 46)',
      'min': 42,
      'max': 46,
      'title': 'Dialectic & Debate',
      'tag': 'C1 Expert',
      'emoji': '🏆',
      'order': 9,
    },
    {
      'name': 'English Hub (Lvl 47 - 51)',
      'min': 47,
      'max': 51,
      'title': 'Literature & Nuance',
      'tag': 'C1+ Elite',
      'emoji': '📜',
      'order': 10,
    },
    {
      'name': 'English Hub (Lvl 52 - 56)',
      'min': 52,
      'max': 56,
      'title': 'Master Communicator',
      'tag': 'C2 Mastery',
      'emoji': '✨',
      'order': 11,
    },
    {
      'name': 'English Hub (Lvl 57 - 61)',
      'min': 57,
      'max': 61,
      'title': 'Executive Statecraft',
      'tag': 'C2 Elite',
      'emoji': '👑',
      'order': 12,
    },
    {
      'name': 'English Hub (Lvl 62 - 66)',
      'min': 62,
      'max': 66,
      'title': 'Diplomatic Summit',
      'tag': 'C2 Sovereign',
      'emoji': '🌐',
      'order': 13,
    },
    {
      'name': 'English Hub (Lvl 67 - 70)',
      'min': 67,
      'max': 70,
      'title': 'Philosophical Dialectic',
      'tag': 'C2 Socratic',
      'emoji': '🪐',
      'order': 14,
    },
    {
      'name': 'English Hub (Lvl 71 - 80)',
      'min': 71,
      'max': 80,
      'title': 'Apex Oratory & Stewardship',
      'tag': 'C2+ Apex Council',
      'emoji': '🌌',
      'order': 15,
    },
    {
      'name': 'English Hub (Lvl 81 - 90)',
      'min': 81,
      'max': 90,
      'title': 'The Grand Council Summit',
      'tag': 'C2+ Sovereign Master',
      'emoji': '🎓',
      'order': 16,
    },
  ];

  /// Fetch all active level groups from Supabase, auto-seeding defaults if empty
  static Future<List<EnglishHubLevelGroup>> getLevelGroups({bool activeOnly = true}) async {
    try {
      var query = _supabase.from('english_hub_level_groups').select('*');
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      final res = await query.order('min_level', ascending: true);
      var list = (res as List).map((m) => EnglishHubLevelGroup.fromMap(m)).toList();

      // Ensure Level 1-5 and Level 6-11 are strictly enforced (auto-reseed if stale brackets exist)
      final bool needsReSeed = list.isEmpty ||
          !list.any((g) => g.minLevel == 6) ||
          list.any((g) => g.minLevel == 1 && g.maxLevel > 5);

      if (needsReSeed) {
        await seedDefaultLevelGroups();
        var reQuery = _supabase.from('english_hub_level_groups').select('*');
        if (activeOnly) {
          reQuery = reQuery.eq('is_active', true);
        }
        final reRes = await reQuery.order('min_level', ascending: true);
        list = (reRes as List).map((m) => EnglishHubLevelGroup.fromMap(m)).toList();
      }
      return list;
    } catch (e) {
      debugPrint('Error loading english_hub_level_groups: $e');
      // Fallback in-memory list
      return kDefaultBrackets.map((b) => EnglishHubLevelGroup(
        id: 'fallback_${b['order']}',
        groupId: 'english_hub_lvl_${b['min']}_${b['max']}',
        groupName: b['name'] as String,
        minLevel: b['min'] as int,
        maxLevel: b['max'] as int,
        stageTitle: b['title'] as String,
        tagBadge: b['tag'] as String,
        iconEmoji: b['emoji'] as String,
        sortOrder: b['order'] as int,
      )).toList();
    }
  }

  /// Provision default level groups into `groups` and `english_hub_level_groups`
  static Future<void> seedDefaultLevelGroups() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      for (final b in kDefaultBrackets) {
        final groupName = b['name'] as String;
        final minLvl = b['min'] as int;
        final maxLvl = b['max'] as int;
        final title = b['title'] as String;
        final tag = b['tag'] as String;
        final emoji = b['emoji'] as String;
        final order = b['order'] as int;

        // Check or create in `groups` table
        final existing = await _supabase
            .from('groups')
            .select('id')
            .eq('name', groupName)
            .limit(1);

        String groupId;
        if ((existing as List).isNotEmpty) {
          groupId = existing.first['id'].toString();
        } else {
          final newGroup = await _supabase.from('groups').insert({
            'name': groupName,
            'description': '$title (Level $minLvl to $maxLvl English Hub Practice)',
            'created_by': currentUserId,
            'is_public': true,
            'is_active': true,
          }).select('id').single();
          groupId = newGroup['id'].toString();
        }

        // Upsert into `english_hub_level_groups`
        final existingLg = await _supabase
            .from('english_hub_level_groups')
            .select('id')
            .eq('group_name', groupName)
            .limit(1);

        if ((existingLg as List).isNotEmpty) {
          await _supabase.from('english_hub_level_groups').update({
            'group_id': groupId,
            'min_level': minLvl,
            'max_level': maxLvl,
            'stage_title': title,
            'tag_badge': tag,
            'icon_emoji': emoji,
            'is_active': true,
            'sort_order': order,
          }).eq('id', existingLg.first['id']);
        } else {
          await _supabase.from('english_hub_level_groups').insert({
            'group_id': groupId,
            'group_name': groupName,
            'min_level': minLvl,
            'max_level': maxLvl,
            'stage_title': title,
            'tag_badge': tag,
            'icon_emoji': emoji,
            'is_active': true,
            'sort_order': order,
          });
        }
      }
    } catch (e) {
      debugPrint('Error seeding default level groups: $e');
    }
  }

  /// Find the matching level group for a given user level
  static Future<EnglishHubLevelGroup> getGroupByLevel(int userLevel) async {
    final groups = await getLevelGroups(activeOnly: true);
    // Sort descending by minLevel so that when user reaches level 6, bracket 6-11 matches first
    final sorted = List<EnglishHubLevelGroup>.from(groups)
      ..sort((a, b) => b.minLevel.compareTo(a.minLevel));
    for (final g in sorted) {
      if (g.containsLevel(userLevel)) {
        return g;
      }
    }
    // Fallback: if user is beyond highest bracket, return highest
    if (sorted.isNotEmpty) {
      if (userLevel >= sorted.first.maxLevel) return sorted.first;
      return sorted.last;
    }
    return const EnglishHubLevelGroup(
      id: 'default',
      groupId: '5ffb8e2d-86a9-4ad7-ac93-9fdefdf43e87',
      groupName: 'English Hub (Lvl 1 - 5)',
      minLevel: 1,
      maxLevel: 5,
      stageTitle: 'Rookie Foundations',
      tagBadge: 'A1 Beginner',
      iconEmoji: '🌱',
    );
  }

  /// 🎯 Get current user learning level from SharedPreferences / Supabase
  static Future<int> resolveCurrentUserLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localStage = prefs.getInt('pocket_learning_user_stage');
      final localDay = prefs.getInt('learning_last_completed_day');
      final targetDay = (localStage != null && localStage > 0)
          ? localStage
          : ((localDay != null && localDay > 0) ? (localDay + 1) : 1);

      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          final res = await _supabase
              .from('profile')
              .select('learning_day')
              .eq('user_id', user.id)
              .maybeSingle();
          if (res != null && res['learning_day'] != null) {
            final supaDay = (res['learning_day'] as num).toInt();
            return supaDay > targetDay ? supaDay : targetDay;
          }
        } catch (_) {}
      }
      return targetDay;
    } catch (_) {
      return 1;
    }
  }

  /// 🔍 Check if a user has an active manual group override assigned by Admin
  static Future<EnglishHubLevelGroup?> getUserManualAssignment(String userId) async {
    try {
      final res = await _supabase
          .from('english_hub_user_assignments')
          .select('group_id, level_group_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        final assignedGroupId = res['group_id']?.toString();
        if (assignedGroupId != null && assignedGroupId.isNotEmpty) {
          final allGroups = await getLevelGroups(activeOnly: false);
          for (final g in allGroups) {
            if (g.groupId == assignedGroupId || g.id == res['level_group_id']?.toString()) {
              return g;
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user manual assignment: $e');
      return null;
    }
  }

  /// 👑 Admin Power: Manually assign/move any user to ANY English Hub group.
  /// User voice directive: "സാഹചര്യങ്ങൾക്ക് അനുസരിച്ച് എനിക്ക് വേറെ വേറെ ഗ്രൂപ്പിൽ ഇടാനും പറ്റണം.
  /// ഒരു യൂസർ ഇംഗ്ലീഷിന്റെ ഗ്രൂപ്പിൽ ഒറ്റ ഗ്രൂപ്പിൽ ഉണ്ടാവാൻ പറ്റുള്ളൂ. ഒരു യൂസർ രണ്ടു വട്ടം ഉണ്ടാവാൻ പറ്റില്ല."
  static Future<bool> assignUserToGroup({
    required String userId,
    required String targetGroupId,
    String? assignedBy,
    String? notes,
  }) async {
    try {
      final allGroups = await getLevelGroups(activeOnly: false);
      final targetGroup = allGroups.firstWhere(
        (g) => g.groupId == targetGroupId || g.id == targetGroupId,
        orElse: () => allGroups.first,
      );

      // 1. Record the manual override in `english_hub_user_assignments`
      await _supabase.from('english_hub_user_assignments').upsert({
        'user_id': userId,
        'group_id': targetGroup.groupId,
        'level_group_id': targetGroup.id,
        'assigned_by': assignedBy ?? _supabase.auth.currentUser?.id,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Resolve profileId
      final profRes = await _supabase
          .from('profile')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      final profileId = profRes?['id']?.toString() ?? userId;

      // 3. Remove user from ALL other English Hub groups (enforce SINGLE GROUP)
      final otherGroupIds = allGroups
          .where((g) => g.groupId.isNotEmpty && g.groupId != targetGroup.groupId)
          .map((g) => g.groupId)
          .toList();

      if (otherGroupIds.isNotEmpty) {
        await _supabase
            .from('group_members')
            .update({'is_active': false})
            .eq('user_id', userId)
            .filter('group_id', 'in', '(${otherGroupIds.join(',')})');
      }

      // 4. Activate or insert user in the target group
      final existing = await _supabase
          .from('group_members')
          .select('id')
          .eq('group_id', targetGroup.groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('group_members')
            .update({'is_active': true})
            .eq('id', existing['id']);
      } else {
        await _supabase.from('group_members').insert({
          'group_id': targetGroup.groupId,
          'user_id': userId,
          'profile_id': profileId,
          'role': 'member',
          'is_active': true,
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error assigning user to group: $e');
      return false;
    }
  }

  /// 🔄 Admin Power: Reset a user to automatic level-based routing
  static Future<bool> resetUserToAutoLevelRouting(String userId) async {
    try {
      await _supabase
          .from('english_hub_user_assignments')
          .delete()
          .eq('user_id', userId);

      final userLevel = await resolveCurrentUserLevel();
      await ensureUserInLevelGroup(userLevel: userLevel, userId: userId);
      return true;
    } catch (e) {
      debugPrint('Error resetting user to auto routing: $e');
      return false;
    }
  }

  /// 📋 Get list of learners with their current English Hub group and manual assignment status
  static Future<List<Map<String, dynamic>>> getLearnersWithHubGroups({String searchQuery = ''}) async {
    try {
      var query = _supabase
          .from('profile')
          .select('id, user_id, name, profile_image_url, learning_day, verified');
      
      if (searchQuery.trim().isNotEmpty) {
        query = query.ilike('name', '%${searchQuery.trim()}%');
      }
      final profiles = await query.limit(50);
      final allGroups = await getLevelGroups(activeOnly: false);
      final groupMap = {for (final g in allGroups) g.groupId: g};

      // Fetch manual assignments
      final userIds = (profiles as List)
          .map((p) => p['user_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      Map<String, String> assignments = {};
      if (userIds.isNotEmpty) {
        final assignRes = await _supabase
            .from('english_hub_user_assignments')
            .select('user_id, group_id')
            .filter('user_id', 'in', '(${userIds.join(',')})');
        for (final a in (assignRes as List)) {
          assignments[a['user_id'].toString()] = a['group_id'].toString();
        }
      }

      // Fetch active group memberships in English Hub groups
      Map<String, String> activeMemberships = {};
      final allHubGroupIds = allGroups.map((g) => g.groupId).where((id) => id.isNotEmpty).toList();
      if (userIds.isNotEmpty && allHubGroupIds.isNotEmpty) {
        final memRes = await _supabase
            .from('group_members')
            .select('user_id, group_id')
            .eq('is_active', true)
            .filter('user_id', 'in', '(${userIds.join(',')})')
            .filter('group_id', 'in', '(${allHubGroupIds.join(',')})');
        for (final m in (memRes as List)) {
          activeMemberships[m['user_id'].toString()] = m['group_id'].toString();
        }
      }

      final result = <Map<String, dynamic>>[];
      for (final p in profiles) {
        final uid = p['user_id']?.toString() ?? '';
        final manualGroupId = assignments[uid];
        final activeGroupId = activeMemberships[uid];
        
        final assignedGroup = manualGroupId != null ? groupMap[manualGroupId] : null;
        final currentGroup = activeGroupId != null ? groupMap[activeGroupId] : null;

        result.add({
          'profile': p,
          'user_id': uid,
          'is_manual': manualGroupId != null,
          'assigned_group': assignedGroup,
          'current_group': currentGroup,
        });
      }
      return result;
    } catch (e) {
      debugPrint('Error getting learners with hub groups: $e');
      return [];
    }
  }

  /// 🚪 Auto-Transition & Enforce Single Level Group Membership:
  /// Prioritizes Admin Manual Assignment, then falls back to userLevel.
  /// Guarantees that user is ONLY in ONE active English Hub group.
  static Future<EnglishHubLevelGroup> ensureUserInLevelGroup({
    required int userLevel,
    required String userId,
    String? profileId,
    bool forceLevelMatch = false,
  }) async {
    // 1. If forceLevelMatch is true (e.g. testing or level up), clear manual override so cohort moves dynamically!
    if (forceLevelMatch) {
      try {
        await _supabase
            .from('english_hub_user_assignments')
            .delete()
            .eq('user_id', userId);
      } catch (_) {}
    }

    final manualGroup = forceLevelMatch ? null : await getUserManualAssignment(userId);
    final targetGroup = manualGroup ?? await getGroupByLevel(userLevel);
    final allGroups = await getLevelGroups(activeOnly: false);

    try {
      // 2. Resolve profileId if null
      String effectiveProfileId = profileId ?? '';
      if (effectiveProfileId.isEmpty) {
        final profRes = await _supabase
            .from('profile')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();
        effectiveProfileId = profRes?['id']?.toString() ?? userId;
      }

      // 3. Deactivate from ALL other English Hub groups (enforce SINGLE GROUP)
      final otherGroupIds = allGroups
          .where((g) => g.groupId.isNotEmpty && g.groupId != targetGroup.groupId)
          .map((g) => g.groupId)
          .toList();

      if (otherGroupIds.isNotEmpty) {
        await _supabase
            .from('group_members')
            .update({'is_active': false})
            .eq('user_id', userId)
            .filter('group_id', 'in', '(${otherGroupIds.join(',')})');
      }

      // 4. Ensure active membership in target group
      if (targetGroup.groupId.isNotEmpty) {
        final existingMember = await _supabase
            .from('group_members')
            .select('id, is_active')
            .eq('group_id', targetGroup.groupId)
            .eq('user_id', userId)
            .maybeSingle();

        if (existingMember != null) {
          if (existingMember['is_active'] != true) {
            await _supabase
                .from('group_members')
                .update({'is_active': true})
                .eq('id', existingMember['id']);
          }
        } else {
          await _supabase.from('group_members').insert({
            'group_id': targetGroup.groupId,
            'user_id': userId,
            'profile_id': effectiveProfileId,
            'role': 'member',
            'is_active': true,
          });
        }
      }
    } catch (e) {
      debugPrint('Error in ensureUserInLevelGroup: $e');
    }

    return targetGroup;
  }

  /// ⚙️ Admin: Create Custom Level Bracket Group
  static Future<EnglishHubLevelGroup?> createCustomLevelGroup({
    required String groupName,
    required int minLevel,
    required int maxLevel,
    required String stageTitle,
    required String tagBadge,
    required String iconEmoji,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      // 1. Create in `groups` table
      final newGroup = await _supabase.from('groups').insert({
        'name': groupName,
        'description': '$stageTitle (Level $minLevel to $maxLevel English Hub Cohort)',
        'created_by': currentUserId,
        'is_public': true,
        'is_active': true,
      }).select('id').single();

      final groupId = newGroup['id'].toString();

      // 2. Insert into `english_hub_level_groups`
      final record = await _supabase.from('english_hub_level_groups').insert({
        'group_id': groupId,
        'group_name': groupName,
        'min_level': minLevel,
        'max_level': maxLevel,
        'stage_title': stageTitle,
        'tag_badge': tagBadge,
        'icon_emoji': iconEmoji,
        'is_active': true,
        'sort_order': minLevel,
      }).select().single();

      return EnglishHubLevelGroup.fromMap(record);
    } catch (e) {
      debugPrint('Error creating custom level group: $e');
      return null;
    }
  }

  /// ⚙️ Admin: Update Level Group Range / Info
  static Future<bool> updateLevelGroup({
    required String id,
    required String groupId,
    required String groupName,
    required int minLevel,
    required int maxLevel,
    required String stageTitle,
    required String tagBadge,
    required String iconEmoji,
    required bool isActive,
  }) async {
    try {
      await _supabase.from('english_hub_level_groups').update({
        'group_name': groupName,
        'min_level': minLevel,
        'max_level': maxLevel,
        'stage_title': stageTitle,
        'tag_badge': tagBadge,
        'icon_emoji': iconEmoji,
        'is_active': isActive,
        'sort_order': minLevel,
      }).eq('id', id);

      if (groupId.isNotEmpty) {
        await _supabase.from('groups').update({
          'name': groupName,
          'description': '$stageTitle (Level $minLevel to $maxLevel English Hub)',
          'is_active': isActive,
        }).eq('id', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating level group: $e');
      return false;
    }
  }

  /// ⚙️ Admin: Delete / Archive Level Group
  static Future<bool> deleteLevelGroup({required String id, String? groupId}) async {
    try {
      await _supabase.from('english_hub_level_groups').delete().eq('id', id);
      if (groupId != null && groupId.isNotEmpty) {
        await _supabase.from('groups').update({'is_active': false}).eq('id', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting level group: $e');
      return false;
    }
  }

  /// 📊 Get Member Count for a group
  static Future<int> getGroupMemberCount(String groupId) async {
    try {
      if (groupId.isEmpty) return 0;
      final res = await _supabase
          .from('group_members')
          .select('id')
          .eq('group_id', groupId)
          .eq('is_active', true);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// 👥 Get active members of a level group with profile info
  static Future<List<Map<String, dynamic>>> getGroupMembersWithLevel(String groupId) async {
    try {
      if (groupId.isEmpty) return [];
      final res = await _supabase
          .from('group_members')
          .select('id, user_id, role, joined_at, profile:profile_id(id, name, profile_image_url, learning_day)')
          .eq('group_id', groupId)
          .eq('is_active', true)
          .order('joined_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      debugPrint('Error fetching group members with level: $e');
      return [];
    }
  }

  /// 🌟 Preset: Single Unified Mega Hub (Lvl 1 - 90)
  static const List<Map<String, dynamic>> kPresetSingleUnifiedHub = [
    {
      'name': 'English Hub (All Learners • Lvl 1 - 90)',
      'min': 1,
      'max': 90,
      'title': 'The Sovereign English Commonwealth',
      'tag': 'All 90 Levels',
      'emoji': '🌟',
      'order': 1,
    },
  ];

  /// 🎯 Preset: 2 Mega Cohorts (Lvl 1 - 35 Foundations & Lvl 36 - 90 Mastery)
  static const List<Map<String, dynamic>> kPresetTwoMegaCohorts = [
    {
      'name': 'English Hub (Lvl 1 - 35)',
      'min': 1,
      'max': 35,
      'title': 'Foundations & Conversational Agility',
      'tag': 'A1 to B2 Fluency',
      'emoji': '🌱',
      'order': 1,
    },
    {
      'name': 'English Hub (Lvl 36 - 90)',
      'min': 36,
      'max': 90,
      'title': 'Advanced Oratory & Planetary Statecraft',
      'tag': 'C1 to C2 Mastery',
      'emoji': '👑',
      'order': 2,
    },
  ];

  /// 🏆 Preset: 3 Cohorts (1 - 30 Beginner, 31 - 60 Intermediate, 61 - 90 Master)
  static const List<Map<String, dynamic>> kPresetThreeCohorts = [
    {
      'name': 'English Hub (Lvl 1 - 30)',
      'min': 1,
      'max': 30,
      'title': 'Rookie to Conversationalist',
      'tag': 'A1-B1 Stages',
      'emoji': '🌱',
      'order': 1,
    },
    {
      'name': 'English Hub (Lvl 31 - 60)',
      'min': 31,
      'max': 60,
      'title': 'Professional Oratory & Debate',
      'tag': 'B2-C1 Stages',
      'emoji': '💼',
      'order': 2,
    },
    {
      'name': 'English Hub (Lvl 61 - 90)',
      'min': 61,
      'max': 90,
      'title': 'The Sovereign Council Summit',
      'tag': 'C2 Master',
      'emoji': '🎓',
      'order': 3,
    },
  ];

  /// ⚡ Dynamic Re-Partitioning Engine:
  /// User voice directive: "ചില സമയത്ത് ഒന്നോട്ട് 90 വരെയുള്ള ആൾക്കാര് ഫുൾ ലെവൽ ഉള്ള ആൾക്കാര് ഒറ്റ ഗ്രൂപ്പിലേക്ക്
  /// കാണിക്കേണ്ട സാഹചര്യം വരുമ്പോൾ അഡ്മിനിൽ പെട്ടെന്ന് മാറ്റി കഴിഞ്ഞുകഴിഞ്ഞാൽ ആ രീതിക്ക് അവർ മാറണം!
  /// ഒന്നോട്ട് 35 വരെയുള്ളവർ ഒരു ഗ്രൂപ്പിൽ, 35 മുതൽ 90 വരെയുള്ളവർ വേറെ ഗ്രൂപ്പിൽ... സ്പ്ലിറ്റ് ആവുകയും വേണം,
  /// മറ്റേ ഗ്രൂപ്പിൽ നിന്ന് അവർ ലെഫ്റ്റ് ആയിട്ട് ഈ ഗ്രൂപ്പിലേക്ക് വരണം!"
  static Future<bool> applyCohortPartitionPlan(List<Map<String, dynamic>> plan) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      final newLevelGroups = <EnglishHubLevelGroup>[];

      // 1. Ensure each bracket in plan exists in `groups` and `english_hub_level_groups`
      for (int i = 0; i < plan.length; i++) {
        final b = plan[i];
        final groupName = b['name'] as String;
        final minLvl = b['min'] as int;
        final maxLvl = b['max'] as int;
        final title = b['title'] as String? ?? 'English Hub Cohort';
        final tag = b['tag'] as String? ?? 'Cohort';
        final emoji = b['emoji'] as String? ?? '💬';
        final order = b['order'] as int? ?? (i + 1);

        // Check or create in `groups` table
        final existingGroup = await _supabase
            .from('groups')
            .select('id')
            .eq('name', groupName)
            .limit(1);

        String groupId;
        if ((existingGroup as List).isNotEmpty) {
          groupId = existingGroup.first['id'].toString();
        } else {
          final newGroup = await _supabase.from('groups').insert({
            'name': groupName,
            'description': '$title (Level $minLvl to $maxLvl English Hub Practice)',
            'created_by': currentUserId,
            'is_public': true,
            'is_active': true,
          }).select('id').single();
          groupId = newGroup['id'].toString();
        }

        // Upsert into `english_hub_level_groups` with is_active = true
        final existingLg = await _supabase
            .from('english_hub_level_groups')
            .select('id')
            .eq('group_name', groupName)
            .limit(1);

        String levelGroupId;
        if ((existingLg as List).isNotEmpty) {
          levelGroupId = existingLg.first['id'].toString();
          await _supabase.from('english_hub_level_groups').update({
            'group_id': groupId,
            'min_level': minLvl,
            'max_level': maxLvl,
            'stage_title': title,
            'tag_badge': tag,
            'icon_emoji': emoji,
            'is_active': true,
            'sort_order': order,
          }).eq('id', levelGroupId);
        } else {
          final inserted = await _supabase.from('english_hub_level_groups').insert({
            'group_id': groupId,
            'group_name': groupName,
            'min_level': minLvl,
            'max_level': maxLvl,
            'stage_title': title,
            'tag_badge': tag,
            'icon_emoji': emoji,
            'is_active': true,
            'sort_order': order,
          }).select('id').single();
          levelGroupId = inserted['id'].toString();
        }

        newLevelGroups.add(EnglishHubLevelGroup(
          id: levelGroupId,
          groupId: groupId,
          groupName: groupName,
          minLevel: minLvl,
          maxLevel: maxLvl,
          stageTitle: title,
          tagBadge: tag,
          iconEmoji: emoji,
          isActive: true,
          sortOrder: order,
        ));
      }

      // 2. Deactivate any existing level groups that are NOT part of this new plan
      final activeGroupNames = plan.map((p) => p['name'] as String).toList();
      final allDbGroups = await _supabase.from('english_hub_level_groups').select('id, group_name');
      for (final g in (allDbGroups as List)) {
        final gName = g['group_name'].toString();
        if (!activeGroupNames.contains(gName)) {
          await _supabase
              .from('english_hub_level_groups')
              .update({'is_active': false})
              .eq('id', g['id']);
        }
      }

      // 3. Re-partition all learners across the new cohorts immediately!
      final profiles = await _supabase.from('profile').select('id, user_id, learning_day');
      final manualAssignments = await _supabase.from('english_hub_user_assignments').select('user_id');
      final manuallyAssignedUserIds = (manualAssignments as List)
          .map((m) => m['user_id']?.toString() ?? '')
          .toSet();

      final allHubGroupRows = await _supabase.from('english_hub_level_groups').select('group_id');
      final allHubGroupIds = (allHubGroupRows as List)
          .map((r) => r['group_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      for (final p in (profiles as List)) {
        final userId = p['user_id']?.toString() ?? '';
        final profileId = p['id']?.toString() ?? userId;
        if (userId.isEmpty) continue;

        // Skip users with active manual admin override
        if (manuallyAssignedUserIds.contains(userId)) continue;

        final learningDay = (p['learning_day'] as num?)?.toInt() ?? 1;

        // Find matching group from new plan (descending match)
        EnglishHubLevelGroup? matchedGroup;
        final sortedNew = List<EnglishHubLevelGroup>.from(newLevelGroups)
          ..sort((a, b) => b.minLevel.compareTo(a.minLevel));
        for (final g in sortedNew) {
          if (g.containsLevel(learningDay)) {
            matchedGroup = g;
            break;
          }
        }
        matchedGroup ??= sortedNew.isNotEmpty ? sortedNew.first : null;
        if (matchedGroup == null) continue;

        // Deactivate old English Hub memberships
        final otherGroupIds = allHubGroupIds
            .where((gid) => gid != matchedGroup!.groupId)
            .toList();

        if (otherGroupIds.isNotEmpty) {
          await _supabase
              .from('group_members')
              .update({'is_active': false})
              .eq('user_id', userId)
              .filter('group_id', 'in', '(${otherGroupIds.join(',')})');
        }

        // Activate or insert in new matched group
        final existingMember = await _supabase
            .from('group_members')
            .select('id')
            .eq('group_id', matchedGroup.groupId)
            .eq('user_id', userId)
            .maybeSingle();

        if (existingMember != null) {
          await _supabase
              .from('group_members')
              .update({'is_active': true})
              .eq('id', existingMember['id']);
        } else {
          await _supabase.from('group_members').insert({
            'group_id': matchedGroup.groupId,
            'user_id': userId,
            'profile_id': profileId,
            'role': 'member',
            'is_active': true,
          });
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error applying cohort partition plan: $e');
      return false;
    }
  }
}
