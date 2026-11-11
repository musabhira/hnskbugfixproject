import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';

/// 🏝️ Pocket Island Group Service
/// Manages dedicated 25-Resident Neighborhood Groups for every island in Poket Cosmos.
/// Enforces exclusive island residency: when a user relocates or purchases a plot
/// on another island, they automatically leave the old group and join the new one!
class PocketIslandGroupService {
  PocketIslandGroupService._();
  static final PocketIslandGroupService instance = PocketIslandGroupService._();

  static const String _kIslandGroupPrefix = 'cosmos_island_';
  static const String _kUserJoinedGroupKey = 'cosmos_user_active_island_group_';
  static const String _kIslandNamespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

  /// Deterministic unique UUID for an island group (100% compliant with PostgreSQL uuid type!)
  String getIslandGroupId({
    required String planetCode,
    required int wave,
    int islandIndex = 1,
  }) {
    final cleanCode = planetCode.trim().toLowerCase();
    final seed = '$_kIslandGroupPrefix${cleanCode}_w${wave}_i$islandIndex';
    return const Uuid().v5(_kIslandNamespace, seed);
  }

  /// Official Island Neighbors Group Name (Minimal & Clean)
  String getIslandGroupName({
    required String planetName,
    required int wave,
    String? islandName,
  }) {
    final cleanPlanet = planetName.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    return '🏝️ $cleanPlanet Neighbors';
  }

  /// Checks if a group name or ID belongs to an Island Neighbors group
  static bool isIslandGroup(String groupId, String groupName) {
    final nameLower = groupName.toLowerCase();
    final idLower = groupId.toLowerCase();
    return nameLower.contains('neighbors') ||
        idLower.contains('cosmos_island_') ||
        nameLower.startsWith('🏝️');
  }

  /// Extracts the planet name from an island group name or planet string
  static String extractPlanetName(String groupName) {
    // Expected patterns: '🏝️ Mercury Neighbors', 'Mercury Neighbors', '🏝️ Kepler-452b Neighbors'
    String clean = groupName.replaceAll('🏝️', '').trim();
    final match = RegExp(r'^(.*?)\s+Neighbors', caseSensitive: false).firstMatch(clean);
    if (match != null) {
      return match.group(1)?.trim() ?? clean;
    }
    return clean;
  }

  /// Returns the planetary theme color for an island group avatar aura
  static Color getPlanetThemeColor(String groupName) {
    final pName = extractPlanetName(groupName).toLowerCase();
    if (pName.contains('mercury')) return const Color(0xFF94A3B8); // Slate / Silver
    if (pName.contains('mars')) return const Color(0xFFEF4444); // Red
    if (pName.contains('jupiter')) return const Color(0xFFF97316); // Amber Orange
    if (pName.contains('saturn')) return const Color(0xFFEAB308); // Golden Yellow
    if (pName.contains('moon')) return const Color(0xFFCBD5E1); // Silver White
    if (pName.contains('europa')) return const Color(0xFF38BDF8); // Ice Cyan
    if (pName.contains('venus')) return const Color(0xFFFBBF24); // Solar Gold
    if (pName.contains('titan')) return const Color(0xFF10B981); // Emerald Teal
    if (pName.contains('pluto')) return const Color(0xFFA855F7); // Cosmic Purple
    if (pName.contains('neptune')) return const Color(0xFF2563EB); // Deep Ocean Blue
    if (pName.contains('ganymede')) return const Color(0xFF0EA5E9); // Magnetic Azure
    if (pName.contains('uranus')) return const Color(0xFF06B6D4); // Cyan Diamond
    if (pName.contains('triton')) return const Color(0xFF6366F1); // Indigo
    if (pName.contains('kepler')) return const Color(0xFF8B5CF6); // Bioluminescent Violet
    return const Color(0xFF0284C7); // Earth Prime Azure
  }

  /// Returns a themed vector avatar config for an Island Neighbors group
  static VectorAvatarConfig getIslandGroupAvatarConfig(String groupName) {
    final pName = extractPlanetName(groupName).toLowerCase();
    int stage = 30; // Default high celestial level
    if (pName.contains('mercury')) {
      stage = 1;
    } else if (pName.contains('venus')) {
      stage = 2;
    } else if (pName.contains('mars')) {
      stage = 4;
    } else if (pName.contains('jupiter')) {
      stage = 5;
    } else if (pName.contains('saturn')) {
      stage = 6;
    } else if (pName.contains('uranus')) {
      stage = 7;
    } else if (pName.contains('neptune')) {
      stage = 8;
    } else if (pName.contains('pluto')) {
      stage = 9;
    } else if (pName.contains('kepler')) {
      stage = 90;
    } else if (pName.contains('moon')) {
      stage = 30;
    } else if (pName.contains('europa')) {
      stage = 51;
    } else if (pName.contains('ganymede')) {
      stage = 52;
    } else if (pName.contains('titan')) {
      stage = 61;
    }
    return VectorAvatarConfig.getEvolutionAvatarForStage(stage);
  }

  /// Ensures the island group exists in Supabase `groups` table,
  /// and ensures the given user is enrolled in `group_members` with `is_active: true`.
  Future<String> ensureIslandGroupAndMember({
    required String planetCode,
    required String planetName,
    required int wave,
    required String userId,
    String? islandName,
    int islandIndex = 1,
  }) async {
    final groupId = getIslandGroupId(
      planetCode: planetCode,
      wave: wave,
      islandIndex: islandIndex,
    );
    final groupName = getIslandGroupName(
      planetName: planetName,
      wave: wave,
      islandName: islandName,
    );

    if (userId.isEmpty) return groupId;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Check/Create Group Record in `groups` table
      try {
        final existingGroup = await SupaFlow.client
            .from('groups')
            .select('id')
            .eq('id', groupId)
            .maybeSingle();

        if (existingGroup == null) {
          await SupaFlow.client.from('groups').insert({
            'id': groupId,
            'name': groupName,
            'description':
                'Official Neighborhood Group for the 25 residents of $planetName Island (Wave $wave). Real-time defense coordination & cosmos chats!',
            'group_image_url': 'assets/images/pocket_mates_logo.png',
            'is_active': true,
            'is_public': false,
            'max_members': 25,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        debugPrint('PocketIslandGroupService ensure group non-fatal: $e');
      }

      // 2. Check/Add Member to `group_members`
      try {
        final memberCheck = await SupaFlow.client
            .from('group_members')
            .select('id, is_active')
            .eq('group_id', groupId)
            .eq('user_id', userId)
            .maybeSingle();

        if (memberCheck == null) {
          await SupaFlow.client.from('group_members').insert({
            'group_id': groupId,
            'user_id': userId,
            'role': 'member',
            'is_active': true,
            'joined_at': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });
        } else if (memberCheck['is_active'] != true) {
          await SupaFlow.client
              .from('group_members')
              .update({'is_active': true})
              .eq('group_id', groupId)
              .eq('user_id', userId);
        }
      } catch (e) {
        debugPrint('PocketIslandGroupService ensure member non-fatal: $e');
      }

      // 3. Persist local tracking
      await prefs.setString('$_kUserJoinedGroupKey$userId', groupId);
      await prefs.setString('cosmos_user_island_group_id', groupId);
      await prefs.setString('cosmos_user_island_group_name', groupName);
    } catch (e) {
      debugPrint('PocketIslandGroupService error: $e');
    }

    return groupId;
  }

  /// 🚪 Relocation Engine: Automatically leaves the old island group
  /// and joins the new island group whenever a plot deed or planet is switched!
  Future<void> onUserRelocated({
    required String userId,
    required String oldPlanetCode,
    required String newPlanetCode,
    required int oldWave,
    required int newWave,
    required int newPlotNumber,
    String? newPlanetName,
    String? newIslandName,
  }) async {
    if (userId.isEmpty) return;

    final oldGroupId =
        getIslandGroupId(planetCode: oldPlanetCode, wave: oldWave);
    final newGroupId =
        getIslandGroupId(planetCode: newPlanetCode, wave: newWave);

    // If staying on the same island, nothing to switch
    if (oldGroupId == newGroupId) return;

    try {
      debugPrint(
          '🏝️ [IslandGroupService] User $userId relocating: Leaving $oldGroupId -> Joining $newGroupId');

      // 1. Remove user from old island's group (delete or deactivate)
      try {
        await SupaFlow.client
            .from('group_members')
            .delete()
            .eq('group_id', oldGroupId)
            .eq('user_id', userId);
      } catch (e) {
        // Fallback: mark is_active = false
        try {
          await SupaFlow.client
              .from('group_members')
              .update({'is_active': false})
              .eq('group_id', oldGroupId)
              .eq('user_id', userId);
        } catch (_) {}
      }

      // 2. Join new island group
      await ensureIslandGroupAndMember(
        planetCode: newPlanetCode,
        planetName: newPlanetName ?? newPlanetCode,
        wave: newWave,
        userId: userId,
        islandName: newIslandName,
      );

      // 3. Post System Notice in new group welcoming citizen
      try {
        final userName =
            SupaFlow.client.auth.currentUser?.email?.split('@').first ??
                'Citizen';
        await SupaFlow.client.from('group_messages').insert({
          'group_id': newGroupId,
          'sender_id': 'system_cosmos_guard',
          'sender_name': 'Cosmos Island Guard 🛡️',
          'message_text':
              '🚀 Citizen $userName has relocated to Plot #$newPlotNumber! Welcome your new island neighbor! 🏡✨',
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('PocketIslandGroupService onUserRelocated error: $e');
    }
  }

  /// Syncs an entire island's 25 plots/residents into `group_members`
  Future<void> syncAllIslandResidents({
    required String planetCode,
    required String planetName,
    required int wave,
    required List<CitizenPlot> plots,
    String? islandName,
  }) async {
    final groupId = getIslandGroupId(planetCode: planetCode, wave: wave);
    final groupName = getIslandGroupName(
      planetName: planetName,
      wave: wave,
      islandName: islandName,
    );

    // Filter valid user IDs
    final validUids = plots
        .map((p) => p.userId.trim())
        .where((uid) =>
            uid.isNotEmpty &&
            !uid.startsWith('vacant') &&
            !uid.startsWith('empty'))
        .toSet();

    if (validUids.isEmpty) return;

    try {
      // 1. Ensure group exists
      try {
        final existingGroup = await SupaFlow.client
            .from('groups')
            .select('id')
            .eq('id', groupId)
            .maybeSingle();

        if (existingGroup == null) {
          await SupaFlow.client.from('groups').insert({
            'id': groupId,
            'name': groupName,
            'description':
                'Official Neighborhood Group for the 25 residents of $planetName Island (Wave $wave).',
            'group_image_url': 'assets/images/pocket_mates_logo.png',
            'is_active': true,
            'is_public': false,
            'max_members': 25,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (_) {}

      // 2. Batch add all resident members
      for (final uid in validUids) {
        try {
          final memberCheck = await SupaFlow.client
              .from('group_members')
              .select('id')
              .eq('group_id', groupId)
              .eq('user_id', uid)
              .maybeSingle();

          if (memberCheck == null) {
            await SupaFlow.client.from('group_members').insert({
              'group_id': groupId,
              'user_id': uid,
              'role': 'member',
              'is_active': true,
              'joined_at': DateTime.now().toIso8601String(),
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('PocketIslandGroupService syncAllIslandResidents error: $e');
    }
  }

  /// 💬 Launches the WhatsApp group chat for this specific island
  Future<void> openIslandGroupChat(
    BuildContext context, {
    required String planetCode,
    required String planetName,
    required int wave,
    String? islandName,
  }) async {
    final currentUserId = SupaFlow.client.auth.currentUser?.id ?? '';
    final groupId = getIslandGroupId(planetCode: planetCode, wave: wave);
    final groupName = getIslandGroupName(
      planetName: planetName,
      wave: wave,
      islandName: islandName,
    );

    // Ensure group and membership exist in background
    if (currentUserId.isNotEmpty) {
      unawaited(
        ensureIslandGroupAndMember(
          planetCode: planetCode,
          planetName: planetName,
          wave: wave,
          userId: currentUserId,
          islandName: islandName,
        ),
      );
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WhatsAppGroupChat(
          groupId: groupId,
          groupName: groupName,
          showBackButton: true,
        ),
      ),
    );
  }
}
